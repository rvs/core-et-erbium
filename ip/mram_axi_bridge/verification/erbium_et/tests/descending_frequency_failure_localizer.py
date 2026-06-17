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
from types import SimpleNamespace

import cocotb

from tb import *


MIN_FREQ_HZ = 1_000
MAX_FREQ_HZ = 1_000_000_000
LOCALIZER_COARSE_POINTS = max(3, int(os.environ.get("FREQ_LOCALIZER_COARSE_POINTS", "12")))
LOCALIZER_TXNS_PER_PERIOD = max(1, int(os.environ.get("FREQ_LOCALIZER_TXNS_PER_PERIOD", "64")))
LOCALIZER_PERIOD_TOLERANCE_PS = max(1, int(os.environ.get("FREQ_LOCALIZER_PERIOD_TOLERANCE_PS", "1000")))
SLOWEST_CLOCK_PERIOD_NS = 1_000_000  # 1 KHz


def format_frequency(freq_hz):
    if freq_hz >= 1_000_000_000:
        return f"{freq_hz / 1_000_000_000:.3f} GHz"
    if freq_hz >= 1_000_000:
        return f"{freq_hz / 1_000_000:.3f} MHz"
    if freq_hz >= 1_000:
        return f"{freq_hz / 1_000:.3f} KHz"
    return f"{freq_hz} Hz"


def format_period_ps(period_ps):
    if period_ps >= 1_000_000_000:
        return f"{period_ps / 1_000_000_000:.3f} ms"
    if period_ps >= 1_000_000:
        return f"{period_ps / 1_000_000:.3f} us"
    if period_ps >= 1_000:
        return f"{period_ps / 1_000:.3f} ns"
    return f"{period_ps} ps"


def format_data_bytes(data):
    return " ".join(f"{byte:02x}" for byte in data)


def period_ps_to_frequency_hz(period_ps):
    return max(1, int(round(1_000_000_000_000 / float(period_ps))))


def build_descending_period_plan():
    min_period_ps = TB.frequency_to_period_ps(MAX_FREQ_HZ)
    max_period_ps = TB.frequency_to_period_ps(MIN_FREQ_HZ)

    if LOCALIZER_COARSE_POINTS == 1:
        return [min_period_ps]

    log_min = math.log10(min_period_ps)
    log_max = math.log10(max_period_ps)
    periods = {min_period_ps, max_period_ps}

    for index in range(LOCALIZER_COARSE_POINTS):
        fraction = index / (LOCALIZER_COARSE_POINTS - 1)
        period_ps = int(round(10 ** (log_min + fraction * (log_max - log_min))))
        periods.add(max(2, period_ps))

    return sorted(periods)


def transfer_timeout_ns(length, size):
    byte_width = 1 << size
    burst_len = max(1, length // byte_width)
    timeout_cycles = 512 + 128 * burst_len
    return timeout_cycles * SLOWEST_CLOCK_PERIOD_NS


@cocotb.test()
async def descending_frequency_failure_localizer(dut):
    """Search for failure boundaries by walking from high frequency to low frequency.

    Each coarse sample runs the same randomized traffic from reset at a fixed clock
    period. Whenever adjacent coarse samples differ in pass/fail status, the test
    bisects that period range until the bracket is within 1 ns by default.
    """

    my_tb.set_dut(dut)
    my_tb.setup_tb(dynamic_clock=True, frequency_hz=MAX_FREQ_HZ)
    await my_tb.reset_sequence()
    my_tb.initialize_memory_region(0, shadow_size := 64 * 1024, value=0)
    seed_rng(401)

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
    coarse_periods = build_descending_period_plan()

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

    async def run_trial(period_ps, trial_label):
        frequency_hz = period_ps_to_frequency_hz(period_ps)
        dut._log.info(
            "Trial %s START at period %s (%s)",
            trial_label,
            format_period_ps(period_ps),
            format_frequency(frequency_hz),
        )
        my_tb._clock_period_ps = int(period_ps)
        axi_master = my_tb.axi_master
        shadow = run_trial.shadow

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

        total_txn_starts = 0
        try:
            for txn_index in range(LOCALIZER_TXNS_PER_PERIOD):
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
                    await do_read_and_check(addr, length, size, f"{trial_label}_read")

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
                    await do_read_and_check(addr, base_width, base_size, f"{trial_label}_partial")

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
                    await do_read_and_check(addr, read_len, 6, f"{trial_label}_wide")

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
                        f"[{trial_label}_excl] Exclusive read at 0x{addr:06x}: "
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
                            f"[{trial_label}_excl] Exclusive write at 0x{addr:06x}: "
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
                            f"[{trial_label}_excl] Failed exclusive write at 0x{addr:06x}: "
                            f"expected OKAY, got {axi_resp(write_op)}"
                        )

                    await do_read_and_check(addr, byte_width, size, f"{trial_label}_excl_verify")

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
                        await do_read_and_check(addr, 8, 3, f"{trial_label}_rapid_bank{bank}")

                elif op == "verify_region":
                    region_base = rand_aligned_addr(6)
                    region_len = _rng.choice([64, 128, 256])
                    region_len = clamp_length(region_base, region_len)
                    region_len = (region_len // 64) * 64
                    if region_len == 0:
                        region_len = 64
                    if region_base + region_len > shadow_size:
                        continue
                    await do_read_and_check(region_base, region_len, 6, f"{trial_label}_verify_region")

            dut._log.info(
                "Trial %s PASS at period %s (%s) after %d transaction starts",
                trial_label,
                format_period_ps(period_ps),
                format_frequency(frequency_hz),
                total_txn_starts,
            )
            return SimpleNamespace(
                passed=True,
                period_ps=int(period_ps),
                frequency_hz=frequency_hz,
                total_txn_starts=total_txn_starts,
                error=None,
            )
        except Exception as exc:
            dut._log.error(
                "Trial %s FAIL at period %s (%s) after %d transaction starts: %s",
                trial_label,
                format_period_ps(period_ps),
                format_frequency(frequency_hz),
                total_txn_starts,
                exc,
            )
            return SimpleNamespace(
                passed=False,
                period_ps=int(period_ps),
                frequency_hz=frequency_hz,
                total_txn_starts=total_txn_starts,
                error=f"{type(exc).__name__}: {exc}",
            )

    run_trial.shadow = bytearray(shadow_size)

    async def localize_transition(lower_result, upper_result, transition_index):
        lower_period_ps = int(lower_result.period_ps)
        upper_period_ps = int(upper_result.period_ps)

        dut._log.info(
            "Localizing transition %d between %s (%s, %s) and %s (%s, %s)",
            transition_index,
            format_period_ps(lower_period_ps),
            format_frequency(lower_result.frequency_hz),
            "PASS" if lower_result.passed else "FAIL",
            format_period_ps(upper_period_ps),
            format_frequency(upper_result.frequency_hz),
            "PASS" if upper_result.passed else "FAIL",
        )

        while upper_period_ps - lower_period_ps > LOCALIZER_PERIOD_TOLERANCE_PS:
            midpoint_period_ps = (lower_period_ps + upper_period_ps) // 2
            if midpoint_period_ps <= lower_period_ps:
                midpoint_period_ps = lower_period_ps + 1
            if midpoint_period_ps >= upper_period_ps:
                midpoint_period_ps = upper_period_ps - 1
            if midpoint_period_ps <= lower_period_ps or midpoint_period_ps >= upper_period_ps:
                break

            midpoint_result = await run_trial(
                midpoint_period_ps,
                f"bisect_{transition_index}_{midpoint_period_ps}",
            )
            if midpoint_result.passed == lower_result.passed:
                lower_period_ps = midpoint_result.period_ps
                lower_result = midpoint_result
            else:
                upper_period_ps = midpoint_result.period_ps
                upper_result = midpoint_result

        return SimpleNamespace(
            lower_result=lower_result,
            upper_result=upper_result,
            bracket_ps=upper_period_ps - lower_period_ps,
        )

    coarse_results = []
    localized_transitions = []

    dut._log.info(
        "Starting descending frequency failure localizer with %d coarse points, %d transactions per point, %s period tolerance",
        len(coarse_periods),
        LOCALIZER_TXNS_PER_PERIOD,
        format_period_ps(LOCALIZER_PERIOD_TOLERANCE_PS),
    )

    for index, period_ps in enumerate(coarse_periods):
        result = await run_trial(period_ps, f"coarse_{index + 1:02d}")
        coarse_results.append(result)

        if len(coarse_results) < 2:
            continue

        previous = coarse_results[-2]
        current = coarse_results[-1]
        if previous.passed != current.passed:
            localized = await localize_transition(
                previous,
                current,
                len(localized_transitions) + 1,
            )
            localized_transitions.append(localized)

    dut._log.info("=== Descending frequency localizer summary ===")
    for result in coarse_results:
        dut._log.info(
            "Coarse sample: %s (%s) -> %s",
            format_period_ps(result.period_ps),
            format_frequency(result.frequency_hz),
            "PASS" if result.passed else f"FAIL [{result.error}]",
        )

    for index, localized in enumerate(localized_transitions, start=1):
        dut._log.info(
            "Localized transition %d: %s (%s, %s) -> %s (%s, %s), bracket=%s",
            index,
            format_period_ps(localized.lower_result.period_ps),
            format_frequency(localized.lower_result.frequency_hz),
            "PASS" if localized.lower_result.passed else "FAIL",
            format_period_ps(localized.upper_result.period_ps),
            format_frequency(localized.upper_result.frequency_hz),
            "PASS" if localized.upper_result.passed else "FAIL",
            format_period_ps(localized.bracket_ps),
        )

    if localized_transitions:
        summary = "; ".join(
            f"{'PASS' if item.lower_result.passed else 'FAIL'} @ {format_period_ps(item.lower_result.period_ps)} -> "
            f"{'PASS' if item.upper_result.passed else 'FAIL'} @ {format_period_ps(item.upper_result.period_ps)}"
            for item in localized_transitions
        )
        assert False, f"Localized failing period ranges: {summary}"

    dut._log.info("Descending frequency failure localizer found no failing regions")
    await Timer(1000, unit="ns")
