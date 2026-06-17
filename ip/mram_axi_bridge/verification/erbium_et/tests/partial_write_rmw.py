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
async def partial_write_rmw(dut):
    """Test partial writes (sub-word strobes) to exercise the read-modify-write path.

    Writes a full word first to establish known data, then overwrites a subset
    of bytes using a smaller size. Verifies that:
    1. Only the targeted bytes changed (AXI readback)
    2. Untouched bytes in MRAM are preserved
    3. Modified bytes in MRAM contain the new values
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(5)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # Shadow memory
    shadow_size = 2 ** 16
    shadow = bytearray(shadow_size)

    async def full_write(address, data, size=3):
        """Write and update shadow."""
        await cocotb.triggers.with_timeout(
            axi_master.write(address, bytes(data), size=size), 500, 'ns'
        )
        shadow[address:address + len(data)] = data

    async def read_and_check(address, length, size, label):
        """Read back and compare against shadow."""
        read_op = axi_master.init_read(address, length, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), 500, 'ns')
        actual = axi_data(read_op)
        expected = bytes(shadow[address:address + length])
        assert actual == expected, (
            f"[{label}] Readback mismatch at 0x{address:06x}: "
            f"expected {expected.hex()}, got {actual.hex()}"
        )

    # ----------------------------------------------------------------
    # Section 1: Single-byte partial writes within an 8-byte word
    # Write 8 bytes, then overwrite individual bytes at each offset
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RMW Section 1: Single-byte overwrites ===")
    for base_addr in [0x00, 0x10, 0x40, 0x100]:
        # Establish known 8-byte word
        init_data = bytearray(rand_bytes(8))
        await full_write(base_addr, init_data)

        # Overwrite each byte individually
        for byte_off in range(8):
            new_byte = bytearray([rand_bytes(1)[0]])
            addr = base_addr + byte_off
            await cocotb.triggers.with_timeout(
                axi_master.write(addr, bytes(new_byte), size=0), 200, 'ns'
            )
            shadow[addr] = new_byte[0]

            # Read back the full 8-byte word — only this byte should differ
            await read_and_check(base_addr, 8, 3, f"byte_overwrite_0x{base_addr:04x}+{byte_off}")

        # Also verify MRAM directly
        mismatches = my_tb.verify_mram_contents(base_addr, bytes(shadow[base_addr:base_addr + 8]))
        assert len(mismatches) == 0, (
            f"MRAM mismatch after byte overwrites at 0x{base_addr:04x}: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 2: 2-byte and 4-byte partial writes within larger words
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RMW Section 2: Multi-byte partial overwrites ===")
    partial_cases = [
        # (base, init_size_bytes, partial_addr_offset, partial_size, partial_len)
        # 2-byte writes within an 8-byte word
        (0x200, 8, 0, 1, 2),   # overwrite bytes 0-1
        (0x200, 8, 2, 1, 2),   # overwrite bytes 2-3
        (0x200, 8, 4, 1, 2),   # overwrite bytes 4-5
        (0x200, 8, 6, 1, 2),   # overwrite bytes 6-7
        # 4-byte writes within an 8-byte word
        (0x208, 8, 0, 2, 4),   # overwrite bytes 0-3
        (0x208, 8, 4, 2, 4),   # overwrite bytes 4-7
        # 1-byte writes within a 16-byte region (crosses even/odd instance)
        (0x210, 16, 7,  0, 1),  # last byte of even instance
        (0x210, 16, 8,  0, 1),  # first byte of odd instance
        (0x210, 16, 15, 0, 1),  # last byte of odd instance
        # 2-byte write straddling the 8-byte instance boundary
        (0x220, 16, 6, 1, 2),   # bytes 6-7 (within even instance)
        (0x220, 16, 8, 1, 2),   # bytes 8-9 (within odd instance)
        # 4-byte write near instance boundary
        (0x230, 16, 4, 2, 4),   # bytes 4-7 (end of even instance)
        (0x230, 16, 8, 2, 4),   # bytes 8-11 (start of odd instance)
    ]

    current_base = None
    for base, init_len, offset, p_size, p_len in partial_cases:
        # Re-initialize when base changes
        if base != current_base:
            init_data = bytearray(rand_bytes(init_len))
            await full_write(base, init_data, size=3 if init_len == 8 else 4)
            current_base = base

        # Partial write
        addr = base + offset
        new_data = bytearray(rand_bytes(p_len))
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(new_data), size=p_size), 200, 'ns'
        )
        shadow[addr:addr + p_len] = new_data

        # Verify full region via AXI
        read_size = 3 if init_len == 8 else 4
        await read_and_check(base, init_len, read_size,
                             f"partial_0x{base:04x}+{offset}_sz{p_size}")

        # Verify MRAM directly
        mismatches = my_tb.verify_mram_contents(base, bytes(shadow[base:base + init_len]))
        assert len(mismatches) == 0, (
            f"MRAM mismatch partial write 0x{base:04x}+{offset}: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 3: Partial writes at bank and instance pair boundaries
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RMW Section 3: Boundary partial writes ===")
    boundary_partials = [
        # Write 64 bytes spanning multiple banks, then partial-overwrite within each bank
        (0x00, 64),
        (0x40, 64),  # starts at instance pair boundary
        (0xF0, 64),  # crosses MRAM address boundary at 0x100
    ]
    for region_base, region_len in boundary_partials:
        # Initialize region
        init_data = bytearray(rand_bytes(region_len))
        await cocotb.triggers.with_timeout(
            axi_master.write(region_base, bytes(init_data), size=6), 500, 'ns'
        )
        shadow[region_base:region_base + region_len] = init_data

        # Partial-overwrite every 16 bytes with 4-byte writes at offset 2
        for off in range(0, region_len, 16):
            addr = region_base + off + 2
            patch = bytearray(rand_bytes(4))
            await cocotb.triggers.with_timeout(
                axi_master.write(addr, bytes(patch), size=2), 200, 'ns'
            )
            shadow[addr:addr + 4] = patch

        # Full region readback
        read_op = axi_master.init_read(region_base, region_len, size=6)
        await cocotb.triggers.with_timeout(read_op.wait(), 1000, 'ns')
        actual = axi_data(read_op)
        expected = bytes(shadow[region_base:region_base + region_len])
        assert actual == expected, (
            f"RMW boundary region 0x{region_base:04x} readback mismatch"
        )

        # MRAM direct check
        mismatches = my_tb.verify_mram_contents(region_base, expected)
        assert len(mismatches) == 0, (
            f"RMW boundary MRAM mismatch at 0x{region_base:04x}: {mismatches[0]}"
        )

    my_tb.dut._log.info("=== All partial write / RMW tests passed ===")
    await Timer(1000, unit="ns")
