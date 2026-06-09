"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-06
 Description: A brief description of the file's purpose.
"""
import cocotb 
import random
from cocotb.clock import Clock
from env import Env 
from cocotb.triggers import Timer
async def boot(dut,tb):
    cocotb.start_soon(Clock(dut.clk,5,"ns").start())
    await tb.reset()
    tb.start()
@cocotb.test()
async def simple_write(dut):
    tb=Env(dut,dut.clk,dut.arst_n)
    await boot(dut,tb)
    await tb.reg.Commands.write_fields(start=1,
                                 field_read=0,
                                 field_write=1,
                                 write_multiple=0,
                                 stop=1,
                                 enq=1,
                                 field_address=0x50)
    await tb.reg.Wdata.write_fields(wdata=random.randint(0,0xff),
                              wlast=1)
    await Timer(100,'us')
@cocotb.test()
async def test_default(dut):
    tb=Env(dut,dut.clk,dut.arst_n)
    await boot(dut,tb)
    await tb.reg.Commands.write_fields(start=1,
                                 field_read=0,
                                 field_write=0,
                                 write_multiple=1,
                                 stop=0,
                                 enq=1,
                                 field_address=0x50)

    for i in range(random.randint(0,100)):
        #await tb.reg.Wdata.write_fields(wdata=random.randint(0,0xff),
        await tb.reg.Wdata.write_fields(wdata=i,
                                  wlast=0)
        while await tb.reg.Status.tx_ff_n_full.read() != 1:
            await Timer(1,"us")
    await tb.reg.Wdata.write_fields(wdata=random.randint(0,0xff),
    #await tb.reg.Wdata.write_fields(wdata=i,
                              wlast=1)
    await tb.reg.Commands.write_fields(start=0,
                                 field_read=0,
                                 field_write=0,
                                 write_multiple=1,
                                 stop=1,
                                 enq=1,
                                 field_address=0x50)
    await Timer(100,"us")



