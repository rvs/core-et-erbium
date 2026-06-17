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
from cocotbext.axi import AxiMaster,AxiBus,AxiLiteRam
from cocotb.triggers import Timer
from cocotb.clock import Clock

@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.CLK_hb_clk,1,'ns').start())
    cocotb.start_soon(timeout(1,'ms'))
    bus=AxiBus.from_prefix(dut,"axi")
    axi=AxiMaster(bus,dut.clk,dut.rst_n,False)
    rambus=AxiBus.from_prefix(dut,"hbslv")
    AxiLiteRam(rambus,dut.hb_out_clk,dut.hb_out_resetn,False,size=2**32)
    await Timer(100,'ns')
    # with open('test.py','r')as file:
    #     line=file.read()
    #     await axi.write(0x10,bytes(line,'utf-8'))
    
    for i in range(10):
        await axi.write(0x5000+i*4,b'hello world')
        rdata=await axi.read(0x5000+i*4,4)
async def timeout(t,unit):
    await Timer(t,unit)
    assert 0, "Timeout error"
