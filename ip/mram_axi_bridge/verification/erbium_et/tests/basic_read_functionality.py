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
async def basic_read_functionality(dut):
    """Bringup of the read functionality of the AXI bridge."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(2)
    init_full_mram = env_flag("BASIC_READ_INIT_FULL_MRAM", "0")
    axi_master = my_tb.axi_master
    saved_values = bytearray()
    max_address_range = 2 ** 10
    size_list = [0, 1, 2, 3]

    random.seed(10)
    # address = random.randrange(max_address_range)
    # length = random.randrange(8) + 1
    # size=random.choice(size_list)
    basic_read_function_cases = []
    targeted_cases = [
        # address, length, size
        (0, 256 * 1 << 0, 0),
        (0, 256 * 1 << 1, 1),
        (0, 256 * 1 << 2, 2),
        (0, 256 * 1 << 3, 3),
        (0, 256 * 1 << 4, 4),
        (0, 256 * 1 << 5, 5),
        (0, 256 * 1 << 6, 6),
        (0x1000, 256 * 1 << 0, 0),

    ]

    num_random_cases = 50
    random_cases = []
    for i in range(num_random_cases):
        rand_size   = random.randrange(0, 7)
        rand_address = random.randrange(0, 2 ** 16) & (0xffffffff ^ ((1 << rand_size) - 1))
        rand_length = 1 << random.randrange(0, 7)
        random_cases.append(
            (rand_address, rand_length, rand_size)
        )
    basic_read_function_cases += targeted_cases + random_cases
    num_of_cases = len(basic_read_function_cases)

    def merged_read_regions(cases):
        intervals = sorted(
            (address, address + length)
            for address, length, _size in cases
            if length > 0
        )
        merged = []

        for start, end in intervals:
            if not merged or start > merged[-1][1]:
                merged.append([start, end])
            else:
                merged[-1][1] = max(merged[-1][1], end)

        return [(start, end - start) for start, end in merged]

    if init_full_mram:
        my_tb.randomize_all_memory(seed=42)
    else:
        read_regions = merged_read_regions(basic_read_function_cases)
        my_tb.dut._log.info(
            "Skipping full MRAM randomization; initializing %d read regions",
            len(read_regions),
        )
        for address, length in read_regions:
            my_tb.write_memory_bytes(address, rand_bytes(length))

    for i in range(num_of_cases):
        address = basic_read_function_cases[i][0]
        length = basic_read_function_cases[i][1]
        size = basic_read_function_cases[i][2]
        print(f"""Running:
            address={address},
            length={length},
            size={size}
        """)
        read_op = axi_master.init_read(address, length, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), 1000, 'ns')

        # Get expected data from MRAM instances and compare
        expected_data = my_tb.get_expected_bytes(address, length)
        actual_data = axi_data(read_op)

        if actual_data != expected_data:
            my_tb.dut._log.error(f"Data mismatch at address 0x{address:x}, length {length}")
            my_tb.dut._log.error(f"  Expected: {expected_data.hex()}")
            my_tb.dut._log.error(f"  Actual:   {actual_data.hex()}")
            # Find first mismatched byte for debugging
            for j in range(min(len(expected_data), len(actual_data))):
                if expected_data[j] != actual_data[j]:
                    my_tb.dut._log.error(f"  First mismatch at byte offset {j}: expected 0x{expected_data[j]:02x}, got 0x{actual_data[j]:02x}")
                    break
        assert actual_data == expected_data, f"Read data mismatch at address 0x{address:x}"

    await Timer(1000, unit="ns")
