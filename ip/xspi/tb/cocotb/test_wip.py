"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-02
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
    await env.cmd.read_Reg(0x0)
    await env.assert_no_xspi_errors(msg="ReadReg")
    data=0xaabb
    await env.cmd.write_Reg(0x0,data.to_bytes(4,"little"))
    await env.assert_no_xspi_errors(msg="WriteReg")
    await env.cmd.read_Mem(0x0)
    await env.assert_no_xspi_errors(msg="ReadMem")
    await env.cmd.write_Mem(0x0,0xaabb.to_bytes(8,"little"))
    await env.assert_no_xspi_errors(msg="WriteMem")


