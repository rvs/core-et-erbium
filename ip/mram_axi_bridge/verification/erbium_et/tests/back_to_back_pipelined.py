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
async def back_to_back_pipelined(dut):
    """Test back-to-back pipelined operations to stress command queuing.

    Issues multiple writes and reads without waiting for completion between them,
    then collects all results. This exercises the command queue and batching logic.
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(6)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # ----------------------------------------------------------------
    # Section 1: Pipelined writes — fire many writes, then verify all
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Pipeline Section 1: Burst of pipelined writes ===")
    num_writes = 32
    write_records = []
    write_events = []

    for i in range(num_writes):
        addr = i * 64  # spread across banks and instance pairs
        data = bytearray(rand_bytes(8))
        event = axi_master.init_write(addr, bytes(data), size=3)
        write_events.append(event)
        write_records.append((addr, data))

    # Wait for all writes to complete
    for event in write_events:
        await cocotb.triggers.with_timeout(event.wait(), 2000, 'ns')

    # Verify all writes via AXI read
    for addr, expected_data in write_records:
        read_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(read_op.wait(), 500, 'ns')
        assert axi_data(read_op) == bytes(expected_data), (
            f"Pipelined write verify failed at 0x{addr:04x}"
        )

    # Verify via MRAM
    for addr, expected_data in write_records:
        mismatches = my_tb.verify_mram_contents(addr, bytes(expected_data))
        assert len(mismatches) == 0, (
            f"Pipelined write MRAM mismatch at 0x{addr:04x}: {mismatches[0]}"
        )

    # ----------------------------------------------------------------
    # Section 2: Pipelined reads — fire many reads simultaneously
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Pipeline Section 2: Burst of pipelined reads ===")
    read_ops = []
    for addr, expected_data in write_records:
        read_op = axi_master.init_read(addr, 8, size=3)
        read_ops.append((addr, expected_data, read_op))

    for addr, expected_data, read_op in read_ops:
        await cocotb.triggers.with_timeout(read_op.wait(), 2000, 'ns')
        assert axi_data(read_op) == bytes(expected_data), (
            f"Pipelined read failed at 0x{addr:04x}"
        )

    # ----------------------------------------------------------------
    # Section 3: Interleaved writes and reads
    # AXI4 has no ordering guarantee between different-ID reads and writes,
    # so we await each write's BRESP before issuing the read to that address.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Pipeline Section 3: Interleaved write/read ===")
    interleave_addrs = [0x800, 0x810, 0x840, 0x880, 0x900, 0x940, 0x980, 0xA00]
    write_records = []

    for addr in interleave_addrs:
        data = bytearray(rand_bytes(16))
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=4), 500, 'ns'
        )
        write_records.append((addr, data))

        # After every 2 writes, read back the previous 2 addresses
        if len(write_records) >= 2 and len(write_records) % 2 == 0:
            for prev_addr, prev_data in write_records[-2:]:
                read_op = axi_master.init_read(prev_addr, 16, size=4)
                await cocotb.triggers.with_timeout(read_op.wait(), 500, 'ns')
                assert axi_data(read_op) == bytes(prev_data), (
                    f"Interleaved read mismatch at 0x{prev_addr:04x}"
                )

    # ----------------------------------------------------------------
    # Section 4: Same-address rapid writes (last writer wins)
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Pipeline Section 4: Same-address contention ===")
    contention_addr = 0xC00
    last_data = None
    contention_events = []
    for i in range(8):
        data = bytearray(rand_bytes(8))
        event = axi_master.init_write(contention_addr, bytes(data), size=3)
        contention_events.append(event)
        last_data = data

    for event in contention_events:
        await cocotb.triggers.with_timeout(event.wait(), 2000, 'ns')

    # The final value should be the last write's data
    read_op = axi_master.init_read(contention_addr, 8, size=3)
    await cocotb.triggers.with_timeout(read_op.wait(), 500, 'ns')
    assert axi_data(read_op) == bytes(last_data), (
        f"Same-address contention: expected last write {last_data.hex()}, "
        f"got {axi_data(read_op).hex()}"
    )

    my_tb.dut._log.info("=== All pipelined tests passed ===")
    await Timer(1000, unit="ns")
