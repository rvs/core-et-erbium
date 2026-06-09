import cocotb
from cocotb.triggers import Timer
from env import ETEnv
import random


def fmt_hex_word(data: bytes) -> str:
    """Format a byte payload as a zero-padded little-endian hex word."""
    return f"0x{int.from_bytes(data, 'little'):0{len(data) * 2}x}"


async def read_mem_bytes(
    xspi_cmd,
    address: int,
    byte_count: int,
    latency_offset_cycles: int = 0,
) -> bytes:
    """Read byte_count bytes from memory using burstlength-sized xSPI transfers."""
    prev_burst = xspi_cmd.burstlength
    prev_latency = xspi_cmd.latency
    xspi_cmd.set_BurstLength(max(1, (byte_count + 7) // 8))
    if latency_offset_cycles:
        xspi_cmd.setLatency(prev_latency + latency_offset_cycles)
    try:
        data = await xspi_cmd.read_Mem(address)
    finally:
        xspi_cmd.set_BurstLength(prev_burst)
        xspi_cmd.setLatency(prev_latency)
    return data[:byte_count]




@cocotb.test(timeout_time=1990000, timeout_unit="ns")
async def default_test(dut):
    cocotb.log.info("Starting Test")
    tb = ETEnv(dut)
    cocotb.log.info("Starting Test")
    await tb.reset()
    tb.start()
    #await Timer(100,'us')
    #await tb.xspi_cmd.Reset()
    #await Timer(100,'us')
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    id = await tb.reg.system_registers.Version.read_fields()
    assert id == {'chipid': 60264, 'respin': 0, 'variation': 0}, "Error chip id match failed"
    assert data[0:4] == b'SFDP'
    data = await tb.xspi_cmd.write_Mem(0x40000060, b'Hi world')
    await tb.reg.system_registers.Mailbox1.write(0xaabbccdd)
    # await tb.reg.cpu_registers.D_hart_esr.NXDATA0.write_fields(Nxdata0=1)
    
    ###############################
    # ROMRAM Test
    ###############################
    rv = await tb.reg.ROMRAM.ROM.read(0, 1)
    assert rv[0] == 0x1BADB0022BADB002
    rv = await tb.reg.ROMRAM.SRAM.read(0, 1)
    assert rv[0] == 0xABADBABE8BADF00D
    await tb.reg.ROMRAM.SRAM.write(0, [1, 2, 3, 4, 5])
    await tb.reg.mram.write(0, [1, 2, 3, 4, 5])
    await tb.assert_no_xspi_errors(msg="SRAM Burst Write")
    await tb.xspi_cmd.write_Mem(0x40008000, b'Hi World')  # Write to ROM, Fails
    await tb.assert_no_xspi_errors( slvError=True,msg="Bootrom Write")

    # Write to unmapped area, Fails
    await tb.xspi_cmd.write_Mem(0x40005000, b'Hi World')
    await tb.assert_no_xspi_errors( decodeError=True,msg="Old bootrom area")
    # Read Last word in bootrom, OK
    rv = await tb.xspi_cmd.read_Mem(0x40009ff8)
    await tb.assert_no_xspi_errors(msg="Bootrom last word")
    assert int.from_bytes(rv, "little") == 0x3132333435363738
    # Read Last + 1 word in bootrom, Decode Error
    rv = await tb.xspi_cmd.read_Mem(0x4000A000)
    await tb.assert_no_xspi_errors(decodeError=True,msg="Brrotom Last+1 address")
    rv = await tb.reg.ROMRAM.ROM.read(1000, 24)

    # Read and write to MRAM -- OTP Gap should give slave error.

    ############################################
    # MRAM Test
    ############################################
    # Check that MRAM is ready.
    cocotb.log.info("Checking MRAM Ready...")
    mram_ready = await tb.reg.mram_registers.bridge_regs.bridge_status_reg.mram_ready.read()
    cocotb.log.info(f"MRAM Status: {mram_ready:04b}")
    if mram_ready == 0xf:
        cocotb.log.info(f"MRAM Available for Writes / Reads")
        test_values = [
            0xC001D00D_DEADBEEF,
            0xABADBABE_BAADF00D,
            0xFEE1DEAD_CAFEBABE,
            0xDEADC0DE_0BADC0DE,
            0x8BADF00D_FEEDFACE,
            # 0x,
            # 0x,
            # 0x,
            # 0x,
            # 0x,
        ]
        addresses = [idx * 64 for idx in range(len(test_values))]

        # Batch write first, then batch read.
        await tb.reg.mram.write(0, test_values)
        cocotb.log.info("MRAM writes done -- starting batch reads.")

        readbacks = []
        for idx, addr in enumerate(addresses):
            rv = await read_mem_bytes(tb.xspi_cmd, addr, 64, latency_offset_cycles=1)
            await Timer(10,"ns")
            readbacks.append(rv)
            cocotb.log.info(f"rv{idx}[64B] @0x{addr:08x} = {fmt_hex_word(rv)}")

        for idx, (addr, expected, raw) in enumerate(zip(addresses, test_values, readbacks)):
            actual = int.from_bytes(raw, "little")
            cocotb.log.info(
                f"check rv{idx} @0x{addr:08x}: expected=0x{expected:016x} actual=0x{actual:016x}"
            )
            assert actual == expected, (
                f"MRAM read mismatch idx={idx} addr=0x{addr:08x} "
                f"expected=0x{expected:016x} actual=0x{actual:016x}"
            )
    await tb.xspi_cmd.write_Mem(0x00000000, b'01234567012345670123456701234567')
    await tb.assert_no_xspi_errors(msg="MRAM Address 0")
    mram_hole = [0x1000000, 0x3fffcfff]
    mram_hole.extend([random.randint(0x1000000, 0x3fffcfff)
                     for _ in range(50)])
    cocotb.log.info(f"{mram_hole=}")
    for x in mram_hole:
        await tb.xspi_cmd.write_Mem(x, b'Hi World')  # Decode error
        status = await tb.reg.mram_registers.bridge_regs.slverr_status_reg.read_fields()
        cocotb.log.info(f"{status=}")
        assert (status['oor_write'] == 1) & (status['oor_read'] == 0)
        await tb.assert_no_xspi_errors(slvError=True, msg="MRAM Hole Check")
        await tb.xspi_cmd.read_Mem(x)  # decode error
        status = await tb.reg.mram_registers.bridge_regs.slverr_status_reg.read_fields()
        assert (status['oor_read'] == 1) & (status['oor_write'] == 0)
        await tb.assert_no_xspi_errors( slvError=True,msg="MRAM Register Read")
    rv = await tb.xspi_cmd.read_Mem(0x00000000)
    await tb.assert_no_xspi_errors(msg="MRAM First Address Read")
    assert rv == b'01234567'
    await Timer(10, 'us')
