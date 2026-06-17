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
async def basic_read_write(dut):
    """Performing a set of AXI reads and writes to the MRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(3)
    random.seed(TEST_SEED + 3)
    axi_master = my_tb.axi_master
    max_address_range = 1024
    total_bytes = max_address_range * 8
    saved_values = bytearray(total_bytes)
    size_list = [0, 1, 2, 3, 4, 5, 6]  # 1, 2, 4, 8, 16, 32, 64 bytes per beat
    burst_lengths = [1, 2, 4, 8, 16]  # beats per burst

    # Initialize full memory with 8-byte writes
    for addr in range(max_address_range):
        value = random.randrange(2 ** 64)
        data = value.to_bytes(8, 'little')
        byte_addr = addr * 8
        await cocotb.triggers.with_timeout(
            axi_master.write(byte_addr, data, size=3),
            100, 'ns'
        )
        saved_values[byte_addr:byte_addr + 8] = data

    # Test each combination of word size and burst length
    for size in size_list:
        byte_width = 1 << size
        for burst_len in burst_lengths:
            transfer_bytes = burst_len * byte_width
            if transfer_bytes > total_bytes:
                continue
            max_start = total_bytes - transfer_bytes
            # Align address to word size
            address = (random.randrange(0, max_start + 1) // byte_width) * byte_width

            # Write random data
            data = bytearray(random.getrandbits(8) for _ in range(transfer_bytes))
            await cocotb.triggers.with_timeout(
                axi_master.write(address, bytes(data), size=size),
                100 * burst_len, 'ns'
            )
            saved_values[address:address + transfer_bytes] = data

            # Read back and verify
            read_op = axi_master.init_read(address, transfer_bytes, size=size)
            await cocotb.triggers.with_timeout(
                read_op.wait(),
                100 * burst_len, 'ns'
            )
            assert axi_data(read_op) == saved_values[address:address + transfer_bytes], \
                f"Mismatch at addr=0x{address:x}, size={size}, burst_len={burst_len}"

    # Final full readback to verify all writes landed correctly
    for addr in range(max_address_range):
        byte_addr = addr * 8
        read_op = axi_master.init_read(byte_addr, 8, size=3)
        await cocotb.triggers.with_timeout(
            read_op.wait(),
            1000, 'ns'
        )
        assert axi_data(read_op) == saved_values[byte_addr:byte_addr + 8], \
            f"Final readback mismatch at addr=0x{byte_addr:x}"

    await Timer(1000, unit="ns")
