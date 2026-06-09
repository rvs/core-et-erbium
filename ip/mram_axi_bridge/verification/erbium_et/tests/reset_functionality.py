import cocotb
from tb import *


@cocotb.test()
async def reset_functionality(dut):
    """Working through the different reset combinations to verify their intention."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()

    my_tb.dut.rst_b.value = 1
    my_tb.dut.mram_rst_b.value = 1

    # First, master reset only
    my_tb.dut._log.info(f"# Condition 1: Master reset only")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 0
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)

    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 1

    # now, MRAM reset only
    my_tb.dut._log.info(f"# Condition 2: MRAM reset only")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.mram_rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 1
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)

    await Timer(10, unit="ns")
    my_tb.dut.mram_rst_b.value = 1

    # now, both resets
    my_tb.dut._log.info(f"# Condition 3: Both Resets")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 0
    my_tb.dut.mram_rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 0
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 1
    my_tb.dut.mram_rst_b.value = 1
    await Timer(100, unit="ns")
