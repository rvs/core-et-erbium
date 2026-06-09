import cocotb
from tb import *


SLOW_CLOCK_PERIOD_NS = 71.434
WORD_BYTES = 8
READ_BYTES = 16
AXI_WORD_SIZE = 3
TIMEOUT_NS = 50_000


@cocotb.test()
async def slow_clock_two_writes_read_first_two_addresses(dut):
    """Run the AXI2MRAM wrapper on a slow clock and verify the first two words."""
    my_tb.set_dut(dut)
    my_tb.setup_tb(clock_period_ns=SLOW_CLOCK_PERIOD_NS)
    await my_tb.reset_sequence(reset_low_cycles=4, reset_release_cycles=4)

    axi_master = my_tb.axi_master
    first_addr = 0x0
    second_addr = WORD_BYTES
    first_data = (0x0123456789ABCDEF).to_bytes(WORD_BYTES, "little")
    second_data = (0xFEDCBA9876543210).to_bytes(WORD_BYTES, "little")

    await cocotb.triggers.with_timeout(
        axi_master.write(first_addr, first_data, size=AXI_WORD_SIZE),
        TIMEOUT_NS,
        "ns",
    )
    await cocotb.triggers.with_timeout(
        axi_master.write(second_addr, second_data, size=AXI_WORD_SIZE),
        TIMEOUT_NS,
        "ns",
    )

    read_op = axi_master.init_read(first_addr, READ_BYTES, size=AXI_WORD_SIZE)
    await cocotb.triggers.with_timeout(read_op.wait(), TIMEOUT_NS, "ns")

    expected = first_data + second_data
    actual = axi_data(read_op)
    assert actual == expected, (
        f"Readback mismatch at 0x{first_addr:08x}: "
        f"expected={expected.hex()} actual={actual.hex()}"
    )
