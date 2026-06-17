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
import random

from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
from cocotbext.axi import AxiBus, AxiMaster
from cocotb.binary import BinaryValue
from cocotb.handle import Force

import math

import random

import secrets

class ErbiumInstance:
    def __init__(self, dut):
        self.dut  =  dut

    def set_rst(self, value:int):
        self.dut.rst_b_i.value  =  value & 0x1

    def set_ce(self, value:int):
        self.dut.ce_i.value     =  value & 0x1

    def set_we(self, value:int):
        self.dut.we_i.value     =  value & 0x1

    def set_addr(self, value:int):
        self.dut.addr_i.value  =  value & 0xFFFF

    def set_din(self, value:int):
        self.dut.din_i.value      =  value & 0xFFFF_FFFF_FFFF_FFFF

    def set_bwe(self, value:int):
        self.dut.bwe_i.value      =  value & 0xFFFF_FFFF_FFFF_FFFF
        
    def set_dout_en(self, value:int):
        self.dut.dout_en_i.value      =  value & 0b1
        
    def get_dout(self) -> int:
        ret_value  =  self.dut.dout_o.value & 0xFFFF_FFFF_FFFF_FFFF
        return(ret_value)
    
    def get_busy(self) -> int:
        return(self.dut.busy_o.value & 0x1)
    
    def initialize_clock(self):
        print("INFO : Initializing clock.", flush=True)
        cocotb.start_soon(Clock(self.dut.clk_i, 1, units="ns").start())

    async def clk_rising(self, value:int=1, clk_margin:int=250):
        for _ in range(value):
            await RisingEdge(self.dut.clk_i)
        await Timer(clk_margin, units='ps')

    async def clk_falling(self, value:int=1, clk_margin:int=250):
        for _ in range(value):
            await FallingEdge(self.dut.clk_i)
        await Timer(clk_margin, units='ps')

    async def busy_falling(self, value:int=1):
        for _ in range(value):
            await FallingEdge(self.dut.busy_o)

    async def advance_clk(self, value:int=1, position_at_falling:bool=True, clk_margin:int=250):
        await self.clk_rising(value)
        if position_at_falling:
            await self.clk_falling(1)
        await Timer(clk_margin, units="ps")

    async def no_op(self, value:int, position_at_falling:bool=True):
        self.set_ce()
        await self.clk_rising(value)
        if position_at_falling:
            await self.clk_falling(1)
        await Timer(250, units="ps")

    def set_mem_clk_en(self, value:int):
        self.dut.mem_clk_en_i.value  =  value & 0b1
    
    async def write(self, addr:int, data:int, bwe:int=0xFFFF_FFFF_FFFF_FFFF, get_data:bool=False) -> int:
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        if get_data:
            self.set_dout_en(0b1)
        else:
            self.set_dout_en(0b0)
        self.set_addr(addr)
        self.set_ce(0b1)
        self.set_we(0b1)
        self.set_din(data)
        self.set_bwe(bwe)
        await self.clk_rising()
        if get_data:
            return_data = self.get_dout()
        else:
            return_data = None
        self.set_dout_en(0b0)
        self.set_mem_clk_en(0b0)
        await self.clk_falling()
        self.set_ce(0b0)
        self.set_we(0b0)
        await self.busy_falling()
        await self.clk_falling()
        return return_data

    async def read(self, addr:int, get_data:bool=True) -> int:
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        if get_data:
            self.set_dout_en(0b1)
        else:
            self.set_dout_en(0b0)
        self.set_addr(addr)
        self.set_ce(0b1)
        self.set_we(0b0)
        await self.clk_rising()
        if get_data:
            return_data = self.get_dout()
        else:
            return_data = None
        self.set_dout_en(0b0)
        self.set_mem_clk_en(0b0)
        await self.clk_falling()
        self.set_ce(0b0)
        await self.busy_falling()
        await self.clk_falling()
        return(return_data)

    async def get_data(self) -> int:
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        self.set_dout_en(0b1)
        await self.clk_rising()
        return_data  =  self.get_dout()
        self.set_mem_clk_en(0b0)
        await self.clk_falling()
        self.set_dout_en(0b0)
        return  return_data

class TB:
    def __init__(self, dut):
        self.set_dut(dut)
        self.inst           =  ErbiumInstance(self.dut)
        self.reset_cycles   =  5

    def set_dut(self, dut):
        print("INFO : Setting DUT.", flush=True)
        self.dut = dut

    def initialize_clock(self):
        self.inst.initialize_clock()

    async def clk_rising(self, value:int=1):
        self.inst.clk_rising(value)

    async def clk_falling(self, value:int=1):
        self.inst.clk_falling(value)

    async def no_op(self, value:int, position_at_falling:bool=True):
        self.inst.no_op(value=value, position_at_falling=position_at_falling)

    async def reset_sequence(self):
        print("INFO : Performing reset.", flush=True)
        self.inst.set_rst(0)
        await Timer(10, units="ns")
        self.inst.set_mem_clk_en(0b0)
        self.inst.set_rst(0)
        self.inst.set_ce(0)
        self.inst.set_we(0)
        self.inst.set_addr(0x0)
        self.inst.set_din(0x0)
        self.inst.set_bwe(0xFFFF_FFFF_FFFF_FFFF)
        self.inst.set_dout_en(0x0)
        for _ in range(self.reset_cycles + 1):
            await RisingEdge(self.inst.dut.clk_i)
        self.inst.set_rst(1)
        await self.clk_falling()
        await Timer(250, units="ps")

    async def setup_tb(self):
        print("INFO : Setting up testbench.", flush=True)
        self.inst.set_rst(0)
        self.initialize_clock()
        await self.clk_rising()
        await self.clk_falling()
        await Timer(250, units="ps")

@cocotb.test()
async def test_instance(dut):

    my_tb  =  TB(dut)
    await my_tb.setup_tb()
    await my_tb.reset_sequence()

    for index in range(10):
        print(f"Writing address {index:05X}", flush=True)
        await my_tb.inst.write(index, (0xFACE_ABCD_0F0F_0000 | index))

    for index in range(10):
        read_value = await my_tb.inst.read(index, get_data=False if index == 0 else True)
        if index > 0:
            print(f"Reading address {(index-1):05X}", flush=True)
            print(f"ADDRESS : {(index-1):05X}  |  DATA : {read_value:016X}", flush=True)
    indx  =  9
    read_value  =  await my_tb.inst.get_data()
    print(f"Reading address {indx:05X}", flush=True)
    print(f"ADDRESS : {indx:05X}  |  DATA : {read_value:016X}", flush=True)

