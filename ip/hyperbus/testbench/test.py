import random
import cocotb
from cocotb.triggers import RisingEdge,Timer, NextTimeStep
from env import Env

@cocotb.test()
async def test(dut):
    env=Env(dut)
    await Timer(100,'ns')
    for _ in range(10):
        initial_latency=random.randint(0,15)
        initial_latency = 6 # The controller code does not support other latencies.
        cocotb.log.info(f"Setting initial latency to {initial_latency}")
        await env.reg.HB_CTRL.write_fields(initial_latency=initial_latency, reg_access=1)
        await env.axi.write(8030,int.to_bytes(0x810a |initial_latency<<4,4,"little"))
        await env.reg.HB_CTRL.write_fields(initial_latency=initial_latency, reg_access=0)
        await test_run(env,read=False)
        await test_run(env,write=False)
        await test_run(env)
    # with open('test.py','r')as file:
    #     line=file.read()
    #     await axi.write(0x10,bytes(line,'utf-8'))
    
async def test_run(env,read=True,write=True):
    cocotb.log.warning(f"Running test with read={read} and write={write}")
    for i in range(100):
        wdata=b'hello wo'
        addr = 0x2000+i*8
        if write:
            await env.axi.write(addr,wdata)
        env.checker.exp.append(wdata)
        if read:
            rdata=await env.axi.read(addr,8)
            cocotb.log.info(rdata)
            assert rdata.data == wdata
