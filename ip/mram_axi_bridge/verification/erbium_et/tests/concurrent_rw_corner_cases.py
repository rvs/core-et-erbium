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
async def concurrent_rw_corner_cases(dut):
    """Corner cases for the independent-FSM architecture where read, write,
    and MRAM-read FSMs run concurrently.

    Exercises:
      1. Concurrent read + write to the same address
      2. Read while cmd queue is draining (cmd_que_running gate)
      3. Both-instance write in a single bank (ship loop lower/upper)
      4. Multi-beat wide bursts with different address regions per beat
      5. Write-after-read to the same bank with overlapping timing
      6. Rapid alternating small read/write pairs (FSM restart stress)
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(200)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    shadow_size = 64 * 1024
    shadow = bytearray(shadow_size)

    async def write_and_update(addr, data, size, timeout=500):
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size), timeout, 'ns'
        )
        shadow[addr:addr + len(data)] = data

    async def read_and_check(addr, length, size, label, timeout=500):
        r_op = axi_master.init_read(addr, length, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), timeout, 'ns')
        expected = bytes(shadow[addr:addr + length])
        assert axi_data(r_op) == expected, (
            f"[{label}] Read mismatch at 0x{addr:06x}: "
            f"expected {expected[:16].hex()}, got {axi_data(r_op)[:16].hex()}"
        )

    # ----------------------------------------------------------------
    # Section 1: Concurrent read + write to the same address
    # Issue write, then immediately read (no await on write).
    # Read should return either old or new data consistently.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 1: Same-address read+write ===")
    for trial in range(8):
        addr = 0x1000 + trial * 0x40
        old_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))
        while new_data == old_data:
            new_data = bytearray(rand_bytes(8))

        # Seed with old data
        await write_and_update(addr, old_data, 3)

        # Fire write and read simultaneously
        w_op = axi_master.init_write(addr, bytes(new_data), size=3)
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(w_op.wait(), 1000, 'ns')
        await cocotb.triggers.with_timeout(r_op.wait(), 1000, 'ns')

        # Read must return either old or new data (not garbage)
        assert axi_data(r_op) in (bytes(old_data), bytes(new_data)), (
            f"Section 1 trial {trial}: read returned neither old nor new data at 0x{addr:04x}"
        )
        # Update shadow with write data (write always completes)
        shadow[addr:addr + 8] = new_data

        # Verify final state
        await read_and_check(addr, 8, 3, f"s1_verify_{trial}")

    my_tb.dut._log.info("  Section 1 OK")

    # ----------------------------------------------------------------
    # Section 2: Read while write cmd queue is draining
    # Issue a partial write (triggers RMW, slow cmd queue drain),
    # then immediately issue a read to a different address.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 2: Read during cmd queue drain ===")
    for trial in range(4):
        wr_addr = 0x2000 + trial * 0x100
        rd_addr = 0x3000 + trial * 0x100  # different address

        # Seed both addresses
        wr_seed = bytearray(rand_bytes(8))
        rd_seed = bytearray(rand_bytes(8))
        await write_and_update(wr_addr, wr_seed, 3)
        await write_and_update(rd_addr, rd_seed, 3)

        # Partial write (RMW path) — only 2 bytes
        patch = bytearray(rand_bytes(2))
        w_op = axi_master.init_write(wr_addr + 2, bytes(patch), size=1)

        # Read from different address while RMW is in progress
        r_op = axi_master.init_read(rd_addr, 8, size=3)

        await cocotb.triggers.with_timeout(w_op.wait(), 2000, 'ns')
        await cocotb.triggers.with_timeout(r_op.wait(), 2000, 'ns')

        shadow[wr_addr + 2:wr_addr + 4] = patch
        assert axi_data(r_op) == bytes(rd_seed), (
            f"Section 2 trial {trial}: read at 0x{rd_addr:04x} returned wrong data "
            f"during cmd queue drain"
        )

    my_tb.dut._log.info("  Section 2 OK")

    # ----------------------------------------------------------------
    # Section 3: Both-instance write in a single bank
    # A 16-byte write to one bank puts data in both the lower (bytes 0-7)
    # and upper (bytes 8-15) instances. The ship loop uses else-if, so it
    # takes two iterations to enqueue both. Verify both halves are written.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 3: Both-instance bank write ===")
    # addr[5:4] selects bank. A 16-byte aligned write within one bank
    # hits both instances of one pair.
    for bank in range(4):
        for pair in range(4):
            addr = (pair << 6) | (bank << 4)  # sets addr[7:6]=pair, addr[5:4]=bank
            data = bytearray(rand_bytes(16))
            await write_and_update(addr, data, 4)  # size=4 → 16B per beat
            await read_and_check(addr, 16, 4, f"s3_bank{bank}_pair{pair}")

            # Also verify MRAM directly
            mismatches = my_tb.verify_mram_contents(addr, bytes(data))
            assert len(mismatches) == 0, (
                f"Section 3 MRAM mismatch bank{bank}_pair{pair}: {mismatches[0]}"
            )

    my_tb.dut._log.info("  Section 3 OK")

    # ----------------------------------------------------------------
    # Section 4: Multi-beat wide burst (size=6, multiple beats)
    # Each 64B beat covers all 4 banks. Multiple beats advance the
    # MRAM address. Tests shipped_lsb_addr tracking across beats.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 4: Multi-beat wide bursts ===")
    wide_cases = [
        (0x0000, 6, 2),   # 64B x 2 = 128B
        (0x0000, 6, 4),   # 64B x 4 = 256B
        (0x0100, 6, 4),   # starting at MRAM addr boundary
        (0x00C0, 6, 4),   # crosses MRAM addr boundary at 0x100
        (0x0000, 6, 8),   # 64B x 8 = 512B
        (0x0000, 6, 16),  # 64B x 16 = 1024B (max practical)
    ]
    for addr, size, beats in wide_cases:
        length = (1 << size) * beats
        if addr + length > shadow_size:
            continue
        data = bytearray(rand_bytes(length))
        timeout = max(500, 100 * beats)
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size), timeout, 'ns'
        )
        shadow[addr:addr + length] = data
        await read_and_check(addr, length, size, f"s4_{addr:#x}_x{beats}", timeout)

    my_tb.dut._log.info("  Section 4 OK")

    # ----------------------------------------------------------------
    # Section 5: Write-after-read to the same bank (overlapping timing)
    # Issue a read, then immediately issue a write to the same bank
    # before the read response comes back. With independent FSMs and
    # different AXI IDs, there is no ordering guarantee — the read
    # may return old or new data depending on which FSM wins.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 5: Write-after-read same bank ===")
    for trial in range(8):
        addr = 0x4000 + trial * 0x10  # same bank for small offsets
        seed_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))
        while new_data == seed_data:
            new_data = bytearray(rand_bytes(8))

        await write_and_update(addr, seed_data, 3)

        # Fire read (non-blocking), then immediately fire write
        r_op = axi_master.init_read(addr, 8, size=3)
        w_op = axi_master.init_write(addr, bytes(new_data), size=3)

        await cocotb.triggers.with_timeout(r_op.wait(), 1000, 'ns')
        await cocotb.triggers.with_timeout(w_op.wait(), 1000, 'ns')

        # No ordering guarantee between different-ID read and write issued
        # simultaneously — read may return old or new data, but not garbage.
        assert axi_data(r_op) in (bytes(seed_data), bytes(new_data)), (
            f"Section 5 trial {trial}: read at 0x{addr:04x} returned neither "
            f"old ({seed_data.hex()}) nor new ({new_data.hex()}) data, "
            f"got {axi_data(r_op).hex()}"
        )
        shadow[addr:addr + 8] = new_data

        # Verify final state is the write's data
        await read_and_check(addr, 8, 3, f"s5_verify_{trial}")

    my_tb.dut._log.info("  Section 5 OK")

    # ----------------------------------------------------------------
    # Section 6: Rapid alternating small read/write pairs
    # Exercises FSM restart speed — each op is tiny (1-8 bytes),
    # alternating read/write with no idle.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Concurrent RW Section 6: Rapid alternating R/W ===")
    base = 0x5000
    # Initialize a region
    init_data = bytearray(rand_bytes(256))
    await write_and_update(base, init_data, 6, timeout=1000)

    for i in range(64):
        size = _rng.randrange(0, 4)  # 1, 2, 4, or 8 bytes
        byte_width = 1 << size
        offset = _rng.randrange(0, 256 - byte_width) & ~(byte_width - 1)
        addr = base + offset

        if i % 2 == 0:
            # Write
            data = bytearray(rand_bytes(byte_width))
            await cocotb.triggers.with_timeout(
                axi_master.write(addr, bytes(data), size=size), 200, 'ns'
            )
            shadow[addr:addr + byte_width] = data
        else:
            # Read and verify
            r_op = axi_master.init_read(addr, byte_width, size=size)
            await cocotb.triggers.with_timeout(r_op.wait(), 200, 'ns')
            expected = bytes(shadow[addr:addr + byte_width])
            assert axi_data(r_op) == expected, (
                f"Section 6 iter {i}: mismatch at 0x{addr:04x} sz{size}"
            )

    # Final coherence check on the region
    await read_and_check(base, 256, 6, "s6_final", timeout=1000)

    my_tb.dut._log.info("  Section 6 OK")
    my_tb.dut._log.info("=== All concurrent RW corner case tests passed ===")
    await Timer(1000, unit="ns")
