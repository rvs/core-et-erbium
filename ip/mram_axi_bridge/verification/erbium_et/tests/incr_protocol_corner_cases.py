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
async def incr_protocol_corner_cases(dut):
    """INCR-only protocol corner cases: unaligned accesses and 4KB boundaries.

    Notes:
    - This environment only supports INCR bursts.
    - We intentionally do not test FIXED/WRAP burst types here.
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(300)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    SHADOW_SIZE = 64 * 1024
    shadow = bytearray(SHADOW_SIZE)

    async def do_write(addr, data, size, timeout=2000):
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size), timeout, "ns"
        )
        shadow[addr:addr + len(data)] = data

    async def do_read_and_check(addr, length, size, label, timeout=2000):
        r_op = axi_master.init_read(addr, length, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), timeout, "ns")
        actual = axi_data(r_op)
        expected = bytes(shadow[addr:addr + length])
        assert actual == expected, (
            f"[{label}] mismatch @0x{addr:06x} size={size} len={length}: "
            f"expected {expected.hex()}, got {actual.hex()}"
        )

    # ----------------------------------------------------------------
    # Section 1: Unaligned single-beat writes/reads
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== INCR Corner Section 1: Unaligned single-beat ===")
    unaligned_single_cases = [
        # (address, size)
        (0x0003, 1),   # 2B beat, odd alignment
        (0x0015, 2),   # 4B beat
        (0x0027, 3),   # 8B beat
        (0x0039, 4),   # 16B beat
        (0x0065, 5),   # 32B beat
        (0x0089, 6),   # 64B beat
    ]
    for addr, size in unaligned_single_cases:
        byte_width = 1 << size
        if addr + byte_width > SHADOW_SIZE:
            continue
        data = bytearray(rand_bytes(byte_width))
        await do_write(addr, data, size, timeout=3000)
        await do_read_and_check(addr, byte_width, size, f"s1_{addr:#x}_sz{size}", timeout=3000)
        mismatches = my_tb.verify_mram_contents(addr, bytes(data))
        assert len(mismatches) == 0, (
            f"[s1_{addr:#x}_sz{size}] MRAM mismatch: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 2: Unaligned multi-beat INCR bursts
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== INCR Corner Section 2: Unaligned multi-beat ===")
    unaligned_multi_cases = [
        # (address, size, beats)
        (0x0103, 2, 4),   # 4B x 4
        (0x0205, 3, 8),   # 8B x 8
        (0x0311, 4, 4),   # 16B x 4
        (0x0457, 5, 2),   # 32B x 2
        (0x0833, 6, 2),   # 64B x 2
    ]
    for addr, size, beats in unaligned_multi_cases:
        length = (1 << size) * beats
        if addr + length > SHADOW_SIZE:
            continue
        data = bytearray(rand_bytes(length))
        timeout = max(3000, 400 * beats)
        await do_write(addr, data, size, timeout=timeout)
        await do_read_and_check(addr, length, size, f"s2_{addr:#x}_sz{size}_b{beats}", timeout=timeout)
        mismatches = my_tb.verify_mram_contents(addr, bytes(data))
        assert len(mismatches) == 0, (
            f"[s2_{addr:#x}_sz{size}_b{beats}] MRAM mismatch: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 3: 4KB boundary behavior (near and crossing)
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== INCR Corner Section 3: 4KB boundary behavior ===")
    boundary_4k_cases = [
        # Legal near-boundary (does not cross 0x1000)
        (0x0FC0, 4, 4),   # 16B x 4 = 64B, ends at 0x1000
        (0x0FE0, 3, 4),   # 8B x 4 = 32B, ends at 0x1000
        # Crossing 4KB boundary
        (0x0FF8, 3, 4),   # 8B x 4 crosses 0x1000
        (0x0FF0, 4, 2),   # 16B x 2 crosses 0x1000
        (0x0FC8, 6, 2),   # 64B x 2 crosses 0x1000
        (0x1FF0, 4, 2),   # crosses 0x2000
    ]
    for addr, size, beats in boundary_4k_cases:
        length = (1 << size) * beats
        if addr + length > SHADOW_SIZE:
            continue
        data = bytearray(rand_bytes(length))
        timeout = max(3000, 400 * beats)
        await do_write(addr, data, size, timeout=timeout)
        await do_read_and_check(addr, length, size, f"s3_{addr:#x}_sz{size}_b{beats}", timeout=timeout)
        mismatches = my_tb.verify_mram_contents(addr, bytes(data))
        assert len(mismatches) == 0, (
            f"[s3_{addr:#x}_sz{size}_b{beats}] MRAM mismatch: {mismatches[0]}"
        )

    my_tb.dut._log.info("=== INCR protocol corner-case tests passed ===")
    await Timer(1000, unit="ns")
