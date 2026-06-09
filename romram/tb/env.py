"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-14
 Description: A brief description of the file's purpose.
"""
import cocotb
from cocotbext.axi import AxiBus, AxiMaster
from cocotbext.dyulib.reset import reset_n
from cocotb.clock import Clock

class Env:
    def __init__(self, dut):
        self.axi_master = AxiMaster(AxiBus.from_prefix(dut, ""), dut.CLK, dut.RST_N, reset_active_level=False)
        self.dut = dut


    async def reset_n(self):
        cocotb.start_soon(Clock(self.dut.CLK, 10, "ns").start())
        await reset_n(self.dut.CLK, self.dut.RST_N)
