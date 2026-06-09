import cocotb
from tb import *


@cocotb.test()
async def otp_read_write_window(dut):
    """Exercise the full 12 KB OTP window through AXI and verify via hierarchy."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(91)
    axi_master = my_tb.axi_master
    timeout_ns = 30000

    my_tb.initialize_memory_region(OTP_BASE_ADDR, OTP_SIZE_BYTES, value=0)
    init_data = rand_bytes(OTP_SIZE_BYTES)
    my_tb.write_memory_bytes(OTP_BASE_ADDR, init_data)

    read_op = axi_master.init_read(OTP_BASE_ADDR, OTP_SIZE_BYTES, size=6)
    await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
    initial_readback = bytes(axi_data(read_op))
    if initial_readback != bytes(init_data):
        first_mismatch = next(
            idx for idx, (actual, expected) in enumerate(zip(initial_readback, init_data))
            if actual != expected
        )
        assert False, (
            f"Initial OTP readback mismatch at offset 0x{first_mismatch:x}: "
            f"expected 0x{init_data[first_mismatch]:02x}, got 0x{initial_readback[first_mismatch]:02x}"
        )

    write_data = rand_bytes(OTP_SIZE_BYTES)
    await cocotb.triggers.with_timeout(
        axi_master.write(OTP_BASE_ADDR, bytes(write_data), size=6),
        timeout_ns,
        "ns",
    )

    verify_op = axi_master.init_read(OTP_BASE_ADDR, OTP_SIZE_BYTES, size=6)
    await cocotb.triggers.with_timeout(verify_op.wait(), timeout_ns, "ns")
    bridge_readback = bytes(axi_data(verify_op))
    if bridge_readback != bytes(write_data):
        first_mismatch = next(
            idx for idx, (actual, expected) in enumerate(zip(bridge_readback, write_data))
            if actual != expected
        )
        assert False, (
            f"OTP bridge readback mismatch at offset 0x{first_mismatch:x}: "
            f"expected 0x{write_data[first_mismatch]:02x}, got 0x{bridge_readback[first_mismatch]:02x}"
        )

    hierarchy_bytes = my_tb.get_expected_bytes(OTP_BASE_ADDR, OTP_SIZE_BYTES)
    if hierarchy_bytes != bytes(write_data):
        first_mismatch = next(
            idx for idx, (actual, expected) in enumerate(zip(hierarchy_bytes, write_data))
            if actual != expected
        )
        assert False, (
            f"OTP hierarchy mismatch at offset 0x{first_mismatch:x}: "
            f"expected 0x{write_data[first_mismatch]:02x}, got 0x{hierarchy_bytes[first_mismatch]:02x}"
        )
