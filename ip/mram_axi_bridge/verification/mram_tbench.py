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
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock

import random


async def read(dut, add):
    dut.add.value = add
    dut.ce_b.value = 0
    dut.we.value = 0
    await RisingEdge(dut.clk)


async def write(dut, din, add):
    dut.add.value = add
    dut.ce_b.value = 0
    dut.we.value = 1
    dut.din.value = din
    await RisingEdge(dut.clk)
    await FallingEdge(dut.busy)


@cocotb.test()
async def basic_read_write(dut):
    """Try accessing the design."""
    """
    input [63:0]            din,
    input [ADD_WIDTH-1:0]   add, // 2^21 = 2M addresses.
    input                   clk,
    input                   ce_b,
    input                   we,
    input                   rst_b,
    """
    cocotb.start_soon(Clock(dut.clk, 5, units="ns").start())
    dut.din.value = 0
    dut.bwe.value = 0xffffffffffffffff
    dut.add.value = 0
    dut.ce_b.value = 1
    dut.we.value = 0
    dut.rst_b.value = 0
    dut.clk.value = 0

    # Setup for the test
    num_of_addresses = 2 ** dut.ADD_WIDTH.value
    print(dut.ADD_WIDTH.value)
    print(num_of_addresses)
    num_of_values = 10000
    random_dins = [random.randint(0, (2 ** 64)) for i in range(num_of_values)]
    random_adds = [i for i in range(num_of_values)]
    random.shuffle(random_adds)

    await Timer(10, units="ns")
    dut.rst_b.value = 1

    await RisingEdge(dut.clk)
    assorted_codes = list(zip(random_dins, random_adds))
    random.shuffle(assorted_codes)
    for din, add in assorted_codes:
        dut._log.info(f"Write: 0x{din:0>16x} @ 0x{add:0>6x}")
        await write(dut, din, add)
    read_queue = []
    random.shuffle(assorted_codes)
    for dout, add in assorted_codes:
        read_queue.insert(0, dout)
        # print(read_queue)
        expected = read_queue.pop()
        await read(dut, add)
        await FallingEdge(dut.busy)
        await Edge(dut.dout)
        assert dut.dout.value.integer == expected

