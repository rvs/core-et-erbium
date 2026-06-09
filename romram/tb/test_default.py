"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-14
 Description: A brief description of the file's purpose.
"""
import cocotb 
from cocotb.triggers import Timer, RisingEdge
from env import Env

@cocotb.test()
async def default_test(dut):
    tb = Env(dut)
    await tb.reset_n()
    await Timer(10,"ns")
    msg=b'We have so much to say, and we shall never say it.345678'
    cocotb.log.info(msg)
    await tb.axi_master.write(0xC000,msg)
    rv = await tb.axi_master.read(0xC000,len(msg))
    cocotb.log.info(rv)
    assert rv.data == msg


