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

import cocotb
from tb import *


@cocotb.test()
async def randomized_stress(dut):
    """Fully randomized stress test exercising reads, writes, partial writes,
    exclusive accesses, and various sizes/bursts in random order.

    Uses a shadow memory model to verify every read returns correct data.
    Covers corner cases:
      - Wide writes spanning all 4 banks
      - Rapid same-bank writes (command queue back-pressure)
      - RMW paths via partial strobes
      - Mixed sizes to overlapping addresses
      - Exclusive access interleaved with normal traffic
      - Back-to-back operations with no idle
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(100)
    # Shadow memory — 64 KB to match address space we'll exercise
    SHADOW_SIZE = 64 * 1024
    shadow = bytearray(SHADOW_SIZE)
    my_tb.initialize_memory_region(0, SHADOW_SIZE, value=0)
    axi_master = my_tb.axi_master

    # AXI sizes: 0=1B, 1=2B, 2=4B, 3=8B, 4=16B, 5=32B, 6=64B
    SIZES = [0, 1, 2, 3, 4, 5, 6]
    # Burst lengths (in beats) — powers of 2 up to 16
    BURST_LENS = [1, 2, 4, 8, 16]

    # Exclusive access tracking (mirrors what the monitor should have)
    excl_reservations = {}  # id -> (addr, size)

    num_iterations = 10000
    timeout_base = 500  # ns

    # Operation weights: (name, weight)
    # More writes than reads to stress the write path harder
    OP_WEIGHTS = [
        ("write",          30),
        ("read",           25),
        ("partial_write",  15),
        ("wide_write",     10),
        ("excl_cycle",      8),
        ("rapid_same_bank", 7),
        ("verify_region",   5),
    ]
    total_weight = sum(w for _, w in OP_WEIGHTS)

    def pick_op():
        """Pick a random operation based on weights."""
        r = _rng.randint(0, total_weight - 1)
        cumulative = 0
        for name, weight in OP_WEIGHTS:
            cumulative += weight
            if r < cumulative:
                return name
        return OP_WEIGHTS[-1][0]

    def rand_aligned_addr(size, max_addr=None):
        """Return a random address aligned to the given AXI size."""
        if max_addr is None:
            max_addr = SHADOW_SIZE
        byte_width = 1 << size
        addr = _rng.randrange(0, max_addr) & ~(byte_width - 1)
        return addr

    def clamp_length(addr, length):
        """Clamp transfer length so it doesn't exceed shadow memory."""
        if addr + length > SHADOW_SIZE:
            length = SHADOW_SIZE - addr
        return max(length, 1)

    async def do_write(addr, data, size):
        """Write data and update shadow."""
        length = len(data)
        byte_width = 1 << size
        burst_len = max(1, length // byte_width)
        timeout = max(timeout_base, 50 * burst_len)
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size), timeout, 'ns'
        )
        shadow[addr:addr + length] = data

    async def do_read_and_check(addr, length, size, label):
        """Read back and compare against shadow."""
        byte_width = 1 << size
        burst_len = max(1, length // byte_width)
        timeout = max(timeout_base, 50 * burst_len)
        r_op = axi_master.init_read(addr, length, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), timeout, 'ns')
        actual = axi_data(r_op)
        expected = bytes(shadow[addr:addr + length])
        assert actual == expected, (
            f"[{label}] Read mismatch at 0x{addr:06x}, size={size}, len={length}: "
            f"expected {expected[:32].hex()}{'...' if length > 32 else ''}, "
            f"got {actual[:32].hex()}{'...' if length > 32 else ''}"
        )

    for iteration in range(num_iterations):
        op = pick_op()

        if op == "write":
            # Random write with random size and burst length
            size = _rng.choice(SIZES)
            byte_width = 1 << size
            burst_len = _rng.choice(BURST_LENS)
            length = byte_width * burst_len
            addr = rand_aligned_addr(size)
            length = clamp_length(addr, length)
            # Re-align length to beat size
            length = (length // byte_width) * byte_width
            if length == 0:
                length = byte_width
            if addr + length > SHADOW_SIZE:
                continue
            data = bytearray(rand_bytes(length))
            await do_write(addr, data, size)

        elif op == "read":
            # Random read and verify against shadow
            size = _rng.choice(SIZES)
            byte_width = 1 << size
            burst_len = _rng.choice(BURST_LENS)
            length = byte_width * burst_len
            addr = rand_aligned_addr(size)
            length = clamp_length(addr, length)
            length = (length // byte_width) * byte_width
            if length == 0:
                length = byte_width
            if addr + length > SHADOW_SIZE:
                continue
            await do_read_and_check(addr, length, size, f"iter{iteration}_read")

        elif op == "partial_write":
            # Write a full word, then partial-overwrite a subset (RMW path)
            base_size = _rng.choice([3, 4, 5])  # 8, 16, or 32 bytes
            base_width = 1 << base_size
            addr = rand_aligned_addr(base_size)
            if addr + base_width > SHADOW_SIZE:
                continue
            # Full write to establish data
            full_data = bytearray(rand_bytes(base_width))
            await do_write(addr, full_data, base_size)
            # Partial overwrite with smaller size
            partial_size = _rng.randrange(0, base_size)
            partial_width = 1 << partial_size
            offset = _rng.randrange(0, base_width - partial_width + 1) & ~(partial_width - 1)
            partial_data = bytearray(rand_bytes(partial_width))
            await do_write(addr + offset, partial_data, partial_size)
            # Verify the full region
            await do_read_and_check(addr, base_width, base_size, f"iter{iteration}_partial")

        elif op == "wide_write":
            # 64-byte write (size=6) hitting all 4 banks simultaneously
            addr = rand_aligned_addr(6)
            if addr + 64 > SHADOW_SIZE:
                continue
            data = bytearray(rand_bytes(64))
            await do_write(addr, data, 6)
            # Optionally follow with a multi-beat wide write
            if _rng.random() < 0.5:
                burst_len = _rng.choice([2, 4])
                length = 64 * burst_len
                if addr + length <= SHADOW_SIZE:
                    data = bytearray(rand_bytes(length))
                    await do_write(addr, data, 6)
            # Verify
            read_len = min(64, SHADOW_SIZE - addr)
            await do_read_and_check(addr, read_len, 6, f"iter{iteration}_wide")

        elif op == "excl_cycle":
            # Full exclusive read-modify-write cycle
            excl_id = _rng.choice([0x10, 0x11, 0x12, 0x13])
            size = _rng.choice([0, 1, 2, 3])
            byte_width = 1 << size
            addr = rand_aligned_addr(size)
            if addr + byte_width > SHADOW_SIZE:
                continue

            # Ensure known data at the address
            seed_data = bytearray(rand_bytes(byte_width))
            await do_write(addr, seed_data, size)

            # Exclusive read
            r_op = axi_master.init_read(addr, byte_width, arid=excl_id, size=size,
                                         lock=AxiLockType.EXCLUSIVE)
            await cocotb.triggers.with_timeout(r_op.wait(), timeout_base, 'ns')
            assert axi_resp(r_op) == AxiResp.EXOKAY, (
                f"[iter{iteration}_excl] Exclusive read at 0x{addr:06x}: "
                f"expected EXOKAY, got {axi_resp(r_op)}"
            )

            # Randomly decide: successful excl write or intervening normal write
            if _rng.random() < 0.6:
                # Successful exclusive write
                new_data = bytearray(rand_bytes(byte_width))
                w_op = axi_master.init_write(addr, bytes(new_data), awid=excl_id,
                                              size=size, lock=AxiLockType.EXCLUSIVE)
                await cocotb.triggers.with_timeout(w_op.wait(), timeout_base, 'ns')
                assert axi_resp(w_op) == AxiResp.EXOKAY, (
                    f"[iter{iteration}_excl] Exclusive write at 0x{addr:06x}: "
                    f"expected EXOKAY, got {axi_resp(w_op)}"
                )
                shadow[addr:addr + byte_width] = new_data
            else:
                # Intervening normal write invalidates reservation
                interloper = bytearray(rand_bytes(byte_width))
                await do_write(addr, interloper, size)
                # Exclusive write should fail
                excl_data = bytearray(rand_bytes(byte_width))
                w_op = axi_master.init_write(addr, bytes(excl_data), awid=excl_id,
                                              size=size, lock=AxiLockType.EXCLUSIVE)
                await cocotb.triggers.with_timeout(w_op.wait(), timeout_base, 'ns')
                assert axi_resp(w_op) == AxiResp.OKAY, (
                    f"[iter{iteration}_excl] Failed exclusive write at 0x{addr:06x}: "
                    f"expected OKAY, got {axi_resp(w_op)}"
                )
                # Shadow already has interloper data

            # Verify
            await do_read_and_check(addr, byte_width, size, f"iter{iteration}_excl_verify")

        elif op == "rapid_same_bank":
            # Fire multiple writes to the same bank to stress cmd queue back-pressure
            # Bank is selected by addr[5:4], so keep those bits fixed
            bank = _rng.randrange(4)
            base = bank * 16  # addr[5:4] = bank
            events = []
            records = []
            for j in range(4):
                # Different instance pairs (addr[7:6]) within the same bank
                inst_pair = j & 0x3
                addr = base + (inst_pair << 6)
                if addr + 8 > SHADOW_SIZE:
                    continue
                data = bytearray(rand_bytes(8))
                event = axi_master.init_write(addr, bytes(data), size=3)
                events.append(event)
                records.append((addr, data))
            for event in events:
                await cocotb.triggers.with_timeout(event.wait(), 2000, 'ns')
            # Update shadow and verify
            for addr, data in records:
                shadow[addr:addr + 8] = data
            for addr, data in records:
                await do_read_and_check(addr, 8, 3, f"iter{iteration}_rapid_bank{bank}")

        elif op == "verify_region":
            # Periodic full-region coherence check against shadow
            region_base = rand_aligned_addr(6)
            region_len = _rng.choice([64, 128, 256])
            region_len = clamp_length(region_base, region_len)
            region_len = (region_len // 64) * 64
            if region_len == 0:
                region_len = 64
            if region_base + region_len > SHADOW_SIZE:
                continue
            await do_read_and_check(region_base, region_len, 6,
                                     f"iter{iteration}_verify_region")

        if iteration % 50 == 0:
            my_tb.dut._log.info(f"  Stress iteration {iteration}/{num_iterations} ({op})")

    # ----------------------------------------------------------------
    # Final full coherence sweep — read all touched memory and compare
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Final coherence sweep ===")
    sweep_range = min(SHADOW_SIZE, 16384)  # check first 16KB
    chunk = 256
    for addr in range(0, sweep_range, chunk):
        r_op = axi_master.init_read(addr, chunk, size=6)
        await cocotb.triggers.with_timeout(r_op.wait(), 2000, 'ns')
        actual = axi_data(r_op)
        expected = bytes(shadow[addr:addr + chunk])
        if actual != expected:
            for j in range(chunk):
                if actual[j] != expected[j]:
                    my_tb.dut._log.error(
                        f"Coherence fail at AXI 0x{addr + j:06x}: "
                        f"expected 0x{expected[j]:02x}, got 0x{actual[j]:02x}"
                    )
                    break
            assert False, f"Final coherence failed at chunk 0x{addr:06x}"

    my_tb.dut._log.info(f"=== Randomized stress test passed ({num_iterations} iterations) ===")
    await Timer(1000, unit="ns")
