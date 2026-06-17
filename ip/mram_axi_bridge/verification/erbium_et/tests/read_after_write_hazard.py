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
async def read_after_write_hazard(dut):
    """Test read-after-write hazards with no idle cycles between operations.

    Issues a write immediately followed by a read to the same address to verify
    data forwarding or correct pipeline stalling. Covers various sizes and
    boundary conditions.
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(7)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # ----------------------------------------------------------------
    # Section 1: Tight write-then-read pairs at various sizes
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RAW Section 1: Tight write-read pairs ===")
    raw_cases = [
        # (address, size, length)
        (0x000, 0,  1),   # 1 byte
        (0x000, 1,  2),   # 2 bytes
        (0x000, 2,  4),   # 4 bytes
        (0x000, 3,  8),   # 8 bytes
        (0x000, 4, 16),   # 16 bytes (full bank word)
        (0x000, 5, 32),   # 32 bytes (2 bank words)
        (0x000, 6, 64),   # 64 bytes (full instance pair set)
        (0x010, 3,  8),   # different bank
        (0x040, 3,  8),   # different instance pair
        (0x100, 3,  8),   # different MRAM address
    ]
    for address, size, length in raw_cases:
        byte_width = 1 << size
        data = bytearray(rand_bytes(length))

        # Write and await BRESP before reading (AXI4 has no cross-ID ordering)
        await cocotb.triggers.with_timeout(
            axi_master.write(address, bytes(data), size=size), 500, 'ns'
        )
        r_op = axi_master.init_read(address, length, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

        assert axi_data(r_op) == bytes(data), (
            f"RAW hazard at 0x{address:04x} sz{size}: "
            f"expected {data.hex()}, got {axi_data(r_op).hex()}"
        )

        # Verify MRAM
        mismatches = my_tb.verify_mram_contents(address, bytes(data))
        assert len(mismatches) == 0, (
            f"RAW MRAM mismatch at 0x{address:04x}: {mismatches[0]}"
        )
        my_tb.dut._log.info(f"  RAW OK: addr=0x{address:04x}, sz={size}, len={length}")

    # ----------------------------------------------------------------
    # Section 2: Write-write-read — second write overwrites first,
    # read should return second write's data
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RAW Section 2: Write-write-read ===")
    for address in [0x200, 0x210, 0x240, 0x300]:
        data1 = bytearray(rand_bytes(8))
        data2 = bytearray(rand_bytes(8))

        # Await both writes before reading (AXI4 has no cross-ID ordering)
        await cocotb.triggers.with_timeout(
            axi_master.write(address, bytes(data1), size=3), 500, 'ns'
        )
        await cocotb.triggers.with_timeout(
            axi_master.write(address, bytes(data2), size=3), 500, 'ns'
        )
        r_op = axi_master.init_read(address, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

        assert axi_data(r_op) == bytes(data2), (
            f"W-W-R at 0x{address:04x}: expected {data2.hex()}, got {axi_data(r_op).hex()}"
        )
        my_tb.dut._log.info(f"  W-W-R OK: addr=0x{address:04x}")

    # ----------------------------------------------------------------
    # Section 3: Partial write then full read — RMW + RAW combined
    # Write 8B, then immediately partial-overwrite 2B, then read full 8B
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RAW Section 3: Partial write + RAW ===")
    for address in [0x400, 0x410, 0x440]:
        full_data = bytearray(rand_bytes(8))
        patch = bytearray(rand_bytes(2))

        # Full write
        w1 = axi_master.init_write(address, bytes(full_data), size=3)
        await cocotb.triggers.with_timeout(w1.wait(), 500, 'ns')

        # Partial overwrite at offset +2, await BRESP before reading
        await cocotb.triggers.with_timeout(
            axi_master.write(address + 2, bytes(patch), size=1), 500, 'ns'
        )
        r_op = axi_master.init_read(address, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

        expected = bytearray(full_data)
        expected[2:4] = patch
        assert axi_data(r_op) == bytes(expected), (
            f"Partial RAW at 0x{address:04x}: "
            f"expected {expected.hex()}, got {axi_data(r_op).hex()}"
        )
        my_tb.dut._log.info(f"  Partial RAW OK: addr=0x{address:04x}")

    # ----------------------------------------------------------------
    # Section 4: Alternating addresses — write A, write B, read A, read B
    # Tests that the pipeline correctly routes non-conflicting addresses
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== RAW Section 4: Alternating address pairs ===")
    addr_pairs = [
        (0x500, 0x510),  # different banks
        (0x500, 0x540),  # different instance pairs
        (0x500, 0x600),  # different MRAM addresses
    ]
    for addr_a, addr_b in addr_pairs:
        data_a = bytearray(rand_bytes(8))
        data_b = bytearray(rand_bytes(8))

        # Await both writes before reading (AXI4 has no cross-ID ordering)
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_a, bytes(data_a), size=3), 500, 'ns'
        )
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_b, bytes(data_b), size=3), 500, 'ns'
        )
        ra = axi_master.init_read(addr_a, 8, size=3)
        rb = axi_master.init_read(addr_b, 8, size=3)
        await cocotb.triggers.with_timeout(ra.wait(), 500, 'ns')
        await cocotb.triggers.with_timeout(rb.wait(), 500, 'ns')

        assert axi_data(ra) == bytes(data_a), (
            f"Alt-addr read A at 0x{addr_a:04x} failed"
        )
        assert axi_data(rb) == bytes(data_b), (
            f"Alt-addr read B at 0x{addr_b:04x} failed"
        )
        my_tb.dut._log.info(f"  Alt OK: A=0x{addr_a:04x}, B=0x{addr_b:04x}")

    my_tb.dut._log.info("=== All read-after-write hazard tests passed ===")
    await Timer(1000, unit="ns")
