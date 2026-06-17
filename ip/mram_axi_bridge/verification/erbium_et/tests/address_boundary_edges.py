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
async def address_boundary_edges(dut):
    """Test reads and writes at address boundaries with varied sizes, bursts, and lengths.

    Exercises:
    - Bank boundaries (every 16 bytes, bits [5:4])
    - Instance pair boundaries (every 64 bytes, bits [7:6])
    - Even/odd instance split (byte offset 8 within 16-byte word)
    - MRAM address transitions (every 256 bytes, bits [15:8])

    For every write, verifies:
    1. AXI readback matches what was written
    2. Direct MRAM instance memory contains the data at the correct location
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(4)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # Shadow memory to track all writes
    shadow_size = 2 ** 16
    shadow = bytearray(shadow_size)

    async def write_and_verify(address, data, size, label):
        """Write data via AXI, then verify via AXI readback and direct MRAM inspection."""
        transfer_bytes = len(data)
        byte_width = 1 << size
        burst_len = transfer_bytes // byte_width
        timeout_ns = max(200, 100 * burst_len)

        my_tb.dut._log.info(
            f"[{label}] Write addr=0x{address:06x}, size={size} ({byte_width}B), "
            f"len={transfer_bytes}B ({burst_len} beats)"
        )

        # Write via AXI
        await cocotb.triggers.with_timeout(
            axi_master.write(address, bytes(data), size=size),
            timeout_ns, 'ns'
        )

        # Update shadow
        shadow[address:address + transfer_bytes] = data

        # Verify 1: AXI readback
        read_op = axi_master.init_read(address, transfer_bytes, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, 'ns')
        actual_axi = axi_data(read_op)

        assert actual_axi == bytes(data), (
            f"[{label}] AXI readback mismatch at addr=0x{address:06x}, size={size}: "
            f"expected {data.hex()}, got {actual_axi.hex()}"
        )

        # Verify 2: Direct MRAM instance inspection
        mismatches = my_tb.verify_mram_contents(address, data)
        assert len(mismatches) == 0, (
            f"[{label}] MRAM content mismatch at addr=0x{address:06x}, size={size}: "
            f"{len(mismatches)} byte(s) wrong. First: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 1: Bank boundary crossing (16-byte boundary, bits [5:4])
    # Writes that start in one bank and cross into the next
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 1: Bank boundary crossings ===")
    bank_boundaries = [0x10, 0x20, 0x30, 0x40]  # 16-byte aligned
    for base in bank_boundaries:
        for size in range(4):  # 1, 2, 4, 8 byte beats
            byte_width = 1 << size
            # Start a few bytes before the boundary
            start = base - byte_width
            start = (start // byte_width) * byte_width  # align
            length = byte_width * 4  # cross well past boundary
            if start < 0:
                continue
            data = bytearray(rand_bytes(length))
            await write_and_verify(start, data, size, f"bank_cross_0x{base:02x}_sz{size}")

    # ----------------------------------------------------------------
    # Section 2: Instance pair boundary crossing (64-byte boundary, bits [7:6])
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 2: Instance pair boundary crossings ===")
    pair_boundaries = [0x40, 0x80, 0xC0, 0x100]
    for base in pair_boundaries:
        for size in range(4):
            byte_width = 1 << size
            start = base - byte_width * 2
            start = (start // byte_width) * byte_width
            length = byte_width * 8
            data = bytearray(rand_bytes(length))
            await write_and_verify(start, data, size, f"pair_cross_0x{base:03x}_sz{size}")

    # ----------------------------------------------------------------
    # Section 3: Even/odd instance split (byte offset 8 within 16-byte word)
    # Writes that straddle the 8-byte boundary inside a bank word
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 3: Even/odd instance boundary ===")
    for bank_base in [0x00, 0x10, 0x20, 0x30]:
        for size in range(4):
            byte_width = 1 << size
            # Start at byte 6 or 7 within the 16-byte word to cross byte-8
            for inner_offset in [8 - byte_width, 8 - byte_width * 2]:
                if inner_offset < 0:
                    continue
                start = bank_base + inner_offset
                start = (start // byte_width) * byte_width
                length = byte_width * 4
                if start + length > shadow_size:
                    continue
                data = bytearray(rand_bytes(length))
                await write_and_verify(
                    start, data, size,
                    f"inst_split_0x{bank_base:02x}+{inner_offset}_sz{size}"
                )

    # ----------------------------------------------------------------
    # Section 4: MRAM address transition (256-byte boundary, bits [15:8])
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 4: MRAM address transitions ===")
    mram_boundaries = [0x100, 0x200, 0x1000]
    for base in mram_boundaries:
        for size in [0, 1, 2, 3]:
            byte_width = 1 << size
            start = base - byte_width * 4
            start = (start // byte_width) * byte_width
            length = byte_width * 8
            data = bytearray(rand_bytes(length))
            await write_and_verify(start, data, size, f"mram_addr_0x{base:04x}_sz{size}")

    # ----------------------------------------------------------------
    # Section 5: Larger burst sizes crossing multiple boundaries
    # Use size=4 (16B), 5 (32B), 6 (64B) with multi-beat bursts
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 5: Large bursts across boundaries ===")
    large_cases = [
        # (address, size, num_beats, label)
        (0x00,  4, 16, "full_sweep_sz4"),      # 16B x 16 = 256B from addr 0
        (0x08,  4,  4, "unaligned_16B_start"),  # 16B beats starting mid-word
        (0x30,  5,  8, "cross_banks_sz5"),       # 32B x 8 = 256B crossing banks
        (0x38,  6,  4, "cross_pairs_sz6"),       # 64B x 4 = 256B crossing instance pairs
        (0xF0,  4,  8, "cross_mram_addr_sz4"),   # 16B x 8 across 0x100 boundary
        (0x00,  6, 16, "max_burst_sz6"),         # 64B x 16 = 1024B
    ]
    for address, size, num_beats, label in large_cases:
        byte_width = 1 << size
        length = byte_width * num_beats
        if address + length > shadow_size:
            continue
        # Align address to beat size
        address = (address // byte_width) * byte_width
        data = bytearray(rand_bytes(length))
        await write_and_verify(address, data, size, label)

    # ----------------------------------------------------------------
    # Section 6: Edge-of-address-space with various sizes
    # First and last addressable locations
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 6: Address space edges ===")
    edge_cases = [
        # Very beginning of address space
        (0x00, 0, 1),   # 1 byte at address 0
        (0x00, 1, 2),   # 2 bytes at address 0
        (0x00, 2, 4),   # 4 bytes at address 0
        (0x00, 3, 8),   # 8 bytes at address 0
        # Single beats at key alignment points
        (0x08, 3, 8),   # 8B at the even/odd instance split
        (0x0F, 0, 1),   # last byte of first bank word
        (0x10, 0, 1),   # first byte of second bank
        (0x3F, 0, 1),   # last byte before instance pair change
        (0x40, 0, 1),   # first byte of second instance pair
        (0xFF, 0, 1),   # last byte before MRAM addr change
        (0x100, 0, 1),  # first byte of next MRAM address
    ]
    for address, size, length in edge_cases:
        data = bytearray(rand_bytes(length))
        await write_and_verify(address, data, size, f"edge_0x{address:04x}_sz{size}")

    # ----------------------------------------------------------------
    # Section 7: Full shadow memory coherence check
    # Re-read everything we wrote and compare against shadow memory
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Section 7: Full shadow coherence check ===")
    # Read in 256-byte chunks using size=6 (64B per beat, 4 beats)
    check_range = 0x1100  # cover all regions we touched
    chunk = 256
    for addr in range(0, check_range, chunk):
        read_op = axi_master.init_read(addr, chunk, size=6)
        await cocotb.triggers.with_timeout(read_op.wait(), 2000, 'ns')
        actual = axi_data(read_op)
        expected = bytes(shadow[addr:addr + chunk])
        if actual != expected:
            for j in range(chunk):
                if actual[j] != expected[j]:
                    bank, pair, maddr, boff = my_tb.axi_addr_to_mram_location(addr + j)
                    my_tb.dut._log.error(
                        f"Shadow mismatch at AXI 0x{addr + j:06x} "
                        f"(bank={bank}, pair={pair}, mram_addr={maddr}, boff={boff}): "
                        f"expected 0x{expected[j]:02x}, got 0x{actual[j]:02x}"
                    )
            assert False, f"Shadow coherence failed at chunk starting 0x{addr:06x}"

    my_tb.dut._log.info("=== All address boundary edge tests passed ===")
    await Timer(1000, unit="ns")
