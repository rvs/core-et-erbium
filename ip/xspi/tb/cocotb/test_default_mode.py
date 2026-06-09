"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-31
 Description: A brief description of the file's purpose.
"""

import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

@cocotb.test(timeout_time=40110,timeout_unit="ns")
@cocotb.parametrize(defaultmode=[1,2,3])
async def default_test(dut, defaultmode):
    cocotb.log.info("Starting default test")
    dut.cfg_default_mode_m.value=defaultmode
    env=Env(dut)
    env.cmd.set_Default_Mode(defaultmode)
    #env.cmd.check_enables = False
    await env.boot()
    data = await env.cmd.read_SFDP(0)
    assert data[0:4] == b'SFDP'


