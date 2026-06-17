# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import math
import os
from cocotb.triggers import ClockCycles, RisingEdge, Timer

import cocotb

from tb import *


MIN_FREQ_HZ = 1_000
MAX_FREQ_HZ = 1_000_000_000
MIN_UNIQUE_FREQS = max(400, int(os.environ.get("FREQ_SWEEP_UNIQUE_FREQS", "400")))
MIN_TXNS_PER_FREQ = max(100, int(os.environ.get("FREQ_SWEEP_TXNS_PER_FREQ", "100")))
SLOWEST_CLOCK_PERIOD_NS = 1_000_000  # 1 KHz


def format_frequency(freq_hz):
    if freq_hz >= 1_000_000_000:
        return f"{freq_hz / 1_000_000_000:.3f} GHz"
    if freq_hz >= 1_000_000:
        return f"{freq_hz / 1_000_000:.3f} MHz"
    if freq_hz >= 1_000:
        return f"{freq_hz / 1_000:.3f} KHz"
    return f"{freq_hz} Hz"


def format_data_bytes(data):
    return " ".join(f"{byte:02x}" for byte in data)


def build_frequency_plan():
    """Build a random log-distributed list of unique effective clock rates."""
    frequencies = []
    used_freqs = set()
    used_periods_ps = set()

    while len(frequencies) < MIN_UNIQUE_FREQS:
        freq_hz = int(round(10 ** _rng.uniform(math.log10(MIN_FREQ_HZ), math.log10(MAX_FREQ_HZ))))
        period_ps = TB.frequency_to_period_ps(freq_hz)
        if freq_hz in used_freqs or period_ps in used_periods_ps:
            continue
        frequencies.append(freq_hz)
        used_freqs.add(freq_hz)
        used_periods_ps.add(period_ps)

    _rng.shuffle(frequencies)
    return frequencies


def transfer_timeout_ns(length, size):
    byte_width = 1 << size
    burst_len = max(1, length // byte_width)
    timeout_cycles = 512 + 128 * burst_len
    return timeout_cycles * SLOWEST_CLOCK_PERIOD_NS


@cocotb.test()
async def randomized_frequency_sweep_stress(dut):
    """Randomized stress test with dynamic clock frequency changes.

    The bridge clock changes at random times across at least 400 different
    frequencies spanning 1 KHz through 1 GHz. Each AXI transaction is counted
    against the frequency that was active when that transaction started, and
    each frequency gets at least 100 transaction starts.
    """

    my_tb.set_dut(dut)
    my_tb.setup_tb(dynamic_clock=True, frequency_hz=MAX_FREQ_HZ)
    await my_tb.reset_sequence()
    seed_rng(401)

    shadow_size = 64 * 1024
    shadow = bytearray(shadow_size)
    my_tb.initialize_memory_region(0, shadow_size, value=0)
    axi_master = my_tb.axi_master

    sizes = [0, 1, 2, 3, 4, 5, 6]
    burst_lens = [1, 2, 4, 8, 16]
    op_weights = [
        ("write", 30),
        ("read", 25),
        ("partial_write", 15),
        ("wide_write", 10),
        ("excl_cycle", 8),
        ("rapid_same_bank", 7),
        ("verify_region", 5),
    ]
    total_weight = sum(weight for _, weight in op_weights)

    frequency_plan = build_frequency_plan()
    txn_starts_per_freq = {freq: 0 for freq in frequency_plan}
    freq_state = SimpleNamespace(
        current_index=0,
        current_frequency_hz=frequency_plan[0],
        done=False,
    )

    def pick_op():
        draw = _rng.randint(0, total_weight - 1)
        cumulative = 0
        for name, weight in op_weights:
            cumulative += weight
            if draw < cumulative:
                return name
        return op_weights[-1][0]

    def rand_aligned_addr(size, max_addr=None):
        if max_addr is None:
            max_addr = shadow_size
        byte_width = 1 << size
        return _rng.randrange(0, max_addr) & ~(byte_width - 1)

    def clamp_length(addr, length):
        if addr + length > shadow_size:
            length = shadow_size - addr
        return max(length, 1)

    async def do_write(addr, data, size):
        timeout_ns = transfer_timeout_ns(len(data), size)
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size),
            timeout_ns,
            "ns",
        )
        shadow[addr:addr + len(data)] = data

    async def do_read_and_check(addr, length, size, label):
        timeout_ns = transfer_timeout_ns(length, size)
        read_op = axi_master.init_read(addr, length, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
        actual = axi_data(read_op)
        expected = bytes(shadow[addr:addr + length])
        if actual != expected:
            dut._log.info(
                "Expected read addr: 0x%08x size: %d len: %d data: %s",
                addr,
                size,
                length,
                format_data_bytes(expected),
            )
        assert actual == expected, (
            f"[{label}] Read mismatch at 0x{addr:06x}, size={size}, len={length}: "
            f"expected {expected[:32].hex()}{'...' if length > 32 else ''}, "
            f"got {actual[:32].hex()}{'...' if length > 32 else ''}"
        )

    async def frequency_controller():
        for index, freq_hz in enumerate(frequency_plan):
            freq_state.current_index = index
            freq_state.current_frequency_hz = freq_hz
            my_tb.set_clock_frequency_hz(freq_hz)

            dut._log.info(
                "Frequency phase %d/%d -> %s",
                index + 1,
                len(frequency_plan),
                format_frequency(freq_hz),
            )

            while txn_starts_per_freq[freq_hz] < MIN_TXNS_PER_FREQ:
                await RisingEdge(my_tb.dut.clk)

            extra_cycles = _rng.randrange(0, 65)
            if extra_cycles != 0:
                await ClockCycles(my_tb.dut.clk, extra_cycles)

        freq_state.done = True

    controller_task = cocotb.start_soon(frequency_controller())

    total_txn_starts = 0
    while not freq_state.done:
        start_freq_hz = freq_state.current_frequency_hz
        txn_starts_per_freq[start_freq_hz] += 1
        total_txn_starts += 1

        op = pick_op()

        if op == "write":
            size = _rng.choice(sizes)
            byte_width = 1 << size
            burst_len = _rng.choice(burst_lens)
            length = byte_width * burst_len
            addr = rand_aligned_addr(size)
            length = clamp_length(addr, length)
            length = (length // byte_width) * byte_width
            if length == 0:
                length = byte_width
            if addr + length > shadow_size:
                continue
            data = bytearray(rand_bytes(length))
            await do_write(addr, data, size)

        elif op == "read":
            size = _rng.choice(sizes)
            byte_width = 1 << size
            burst_len = _rng.choice(burst_lens)
            length = byte_width * burst_len
            addr = rand_aligned_addr(size)
            length = clamp_length(addr, length)
            length = (length // byte_width) * byte_width
            if length == 0:
                length = byte_width
            if addr + length > shadow_size:
                continue
            await do_read_and_check(addr, length, size, f"freq{start_freq_hz}_read")

        elif op == "partial_write":
            base_size = _rng.choice([3, 4, 5])
            base_width = 1 << base_size
            addr = rand_aligned_addr(base_size)
            if addr + base_width > shadow_size:
                continue
            full_data = bytearray(rand_bytes(base_width))
            await do_write(addr, full_data, base_size)

            partial_size = _rng.randrange(0, base_size)
            partial_width = 1 << partial_size
            offset = _rng.randrange(0, base_width - partial_width + 1) & ~(partial_width - 1)
            partial_data = bytearray(rand_bytes(partial_width))
            await do_write(addr + offset, partial_data, partial_size)
            await do_read_and_check(addr, base_width, base_size, f"freq{start_freq_hz}_partial")

        elif op == "wide_write":
            addr = rand_aligned_addr(6)
            if addr + 64 > shadow_size:
                continue
            data = bytearray(rand_bytes(64))
            await do_write(addr, data, 6)
            if _rng.random() < 0.5:
                burst_len = _rng.choice([2, 4])
                length = 64 * burst_len
                if addr + length <= shadow_size:
                    data = bytearray(rand_bytes(length))
                    await do_write(addr, data, 6)
            read_len = min(64, shadow_size - addr)
            await do_read_and_check(addr, read_len, 6, f"freq{start_freq_hz}_wide")

        elif op == "excl_cycle":
            excl_id = _rng.choice([0x10, 0x11, 0x12, 0x13])
            size = _rng.choice([0, 1, 2, 3])
            byte_width = 1 << size
            addr = rand_aligned_addr(size)
            if addr + byte_width > shadow_size:
                continue

            seed_data = bytearray(rand_bytes(byte_width))
            await do_write(addr, seed_data, size)

            timeout_ns = transfer_timeout_ns(byte_width, size)
            read_op = axi_master.init_read(
                addr,
                byte_width,
                arid=excl_id,
                size=size,
                lock=AxiLockType.EXCLUSIVE,
            )
            await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
            assert axi_resp(read_op) == AxiResp.EXOKAY, (
                f"[freq{start_freq_hz}_excl] Exclusive read at 0x{addr:06x}: "
                f"expected EXOKAY, got {axi_resp(read_op)}"
            )

            if _rng.random() < 0.6:
                new_data = bytearray(rand_bytes(byte_width))
                write_op = axi_master.init_write(
                    addr,
                    bytes(new_data),
                    awid=excl_id,
                    size=size,
                    lock=AxiLockType.EXCLUSIVE,
                )
                await cocotb.triggers.with_timeout(write_op.wait(), timeout_ns, "ns")
                assert axi_resp(write_op) == AxiResp.EXOKAY, (
                    f"[freq{start_freq_hz}_excl] Exclusive write at 0x{addr:06x}: "
                    f"expected EXOKAY, got {axi_resp(write_op)}"
                )
                shadow[addr:addr + byte_width] = new_data
            else:
                interloper = bytearray(rand_bytes(byte_width))
                await do_write(addr, interloper, size)

                excl_data = bytearray(rand_bytes(byte_width))
                write_op = axi_master.init_write(
                    addr,
                    bytes(excl_data),
                    awid=excl_id,
                    size=size,
                    lock=AxiLockType.EXCLUSIVE,
                )
                await cocotb.triggers.with_timeout(write_op.wait(), timeout_ns, "ns")
                assert axi_resp(write_op) == AxiResp.OKAY, (
                    f"[freq{start_freq_hz}_excl] Failed exclusive write at 0x{addr:06x}: "
                    f"expected OKAY, got {axi_resp(write_op)}"
                )

            await do_read_and_check(addr, byte_width, size, f"freq{start_freq_hz}_excl_verify")

        elif op == "rapid_same_bank":
            bank = _rng.randrange(4)
            base = bank * 16
            events = []
            records = []
            for lane in range(4):
                inst_pair = lane & 0x3
                addr = base + (inst_pair << 6)
                if addr + 8 > shadow_size:
                    continue
                data = bytearray(rand_bytes(8))
                events.append(axi_master.init_write(addr, bytes(data), size=3))
                records.append((addr, data))

            timeout_ns = transfer_timeout_ns(8, 3)
            for event in events:
                await cocotb.triggers.with_timeout(event.wait(), timeout_ns, "ns")

            for addr, data in records:
                shadow[addr:addr + 8] = data
            for addr, _ in records:
                await do_read_and_check(addr, 8, 3, f"freq{start_freq_hz}_rapid_bank{bank}")

        elif op == "verify_region":
            region_base = rand_aligned_addr(6)
            region_len = _rng.choice([64, 128, 256])
            region_len = clamp_length(region_base, region_len)
            region_len = (region_len // 64) * 64
            if region_len == 0:
                region_len = 64
            if region_base + region_len > shadow_size:
                continue
            await do_read_and_check(region_base, region_len, 6, f"freq{start_freq_hz}_verify_region")

        if total_txn_starts % 100 == 0:
            dut._log.info(
                "Started %d transactions, current phase %d/%d at %s",
                total_txn_starts,
                freq_state.current_index + 1,
                len(frequency_plan),
                format_frequency(freq_state.current_frequency_hz),
            )

    await controller_task

    for freq_hz in frequency_plan:
        assert txn_starts_per_freq[freq_hz] >= MIN_TXNS_PER_FREQ, (
            f"Frequency {freq_hz} Hz only started {txn_starts_per_freq[freq_hz]} transactions"
        )

    dut._log.info("=== Final coherence sweep ===")
    sweep_range = min(shadow_size, 16 * 1024)
    chunk = 256
    for addr in range(0, sweep_range, chunk):
        timeout_ns = transfer_timeout_ns(chunk, 6)
        read_op = axi_master.init_read(addr, chunk, size=6)
        await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
        actual = axi_data(read_op)
        expected = bytes(shadow[addr:addr + chunk])
        if actual != expected:
            for index in range(chunk):
                if actual[index] != expected[index]:
                    dut._log.error(
                        "Coherence fail at AXI 0x%06x: expected 0x%02x, got 0x%02x",
                        addr + index,
                        expected[index],
                        actual[index],
                    )
                    break
            assert False, f"Final coherence failed at chunk 0x{addr:06x}"

    dut._log.info(
        "=== Randomized frequency sweep stress passed (%d frequencies, %d tx starts minimum each, %d total starts) ===",
        len(frequency_plan),
        MIN_TXNS_PER_FREQ,
        total_txn_starts,
    )
    await Timer(1000, unit="ns")
