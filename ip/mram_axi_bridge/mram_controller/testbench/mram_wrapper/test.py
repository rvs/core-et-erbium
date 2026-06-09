import cocotb
import os
from env import TestEnv
from testlist import TestMode
from cocotb.triggers import Timer, RisingEdge


@cocotb.test()
async def test(dut):
    cocotb.log.info("Test Started")
    test = getattr(TestMode, os.getenv("TESTNAME", "LiveCheck"))

    # await RisingEdge(dut.clk)
    # await Timer(1, 'ps')
    # assert 1 == 0
    env = TestEnv(dut, test, timeout=100000)
    await env.default_run()
    await Timer(1, 'us')
