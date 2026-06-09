"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-01  SPI Read Memory  – preload via AXI RAM backdoor, read via 1S-1S-1S xSPI, verify
CP-02  SPI Write Memory – write via 1S-1S-1S xSPI, read back via xSPI, verify
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

# ── shared test vectors ───────────────────────────────────────────────────────
# Walking-one, all-zero, all-F, alternating, and a few pseudorandom patterns
CORNER_DATA = [
    0xaaaaaaaaaaaaaaaa,   # alternating 1010…
    0x0000000000000000,   # all-zero
    0x12345678abcdef5a,   # pseudo-random
    0xaa55aa55aa55aa55,   # complementary nibbles
    0xffffffffffffffff,   # all-one
    0x5555555555555555,   # alternating 0101…
    0x0102030405060708,   # walking byte
]

CORNER_ADDRS = [          # 8-byte aligned
    0x00001000,
    0x00010000,
    0x00100000,
    0x01000008,
    0x00fff8,
    0x00008000,
    0x00080000,
]

random.seed(0xDEADBEEF)
RAND_ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(30)]
RAND_DATA  = [random.randint(0, 2**64 - 1)          for _ in range(30)]


# ── CP-01: SPI Read Memory ────────────────────────────────────────────────────
@cocotb.test(timeout_time=30000, timeout_unit="ns")
@cocotb.parametrize(
    latency=list(range(8, 21, 4)),
    default_mode_pin=[1, 2, 3],
)
async def test_spi_read_mem(dut, latency, default_mode_pin):
    """CP-01: Preload AXI RAM with corner patterns; read via 1S-1S-1S xSPI.

    Pass criterion: every read_Mem() result matches the preloaded value.
    """
    cocotb.log.info(
        f"CP-01 spi_read latency={latency} default_mode_pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency, (
        f"latency_count DUT mismatch: expected={latency} "
        f"got={int(dut.dut.latency_count.value)}"
    )
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    for idx, (addr, val) in enumerate(zip(CORNER_ADDRS, CORNER_DATA)):
        cocotb.log.info(
            f"  iter {idx}: addr=0x{addr:08x} data=0x{val:016x}"
        )
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"CP-01 mismatch addr=0x{addr:08x} "
            f"expected=0x{val:016x} "
            f"got=0x{int.from_bytes(rdata,'little'):016x}"
        )

    await env.assert_no_xspi_errors(msg="CP-01 unexpected xSPI error flags")


# ── CP-02: SPI Write Memory ───────────────────────────────────────────────────
@cocotb.test(timeout_time=30000, timeout_unit="ns")
@cocotb.parametrize(
    latency=list(range(8, 21, 4)),
    default_mode_pin=[1, 2, 3],
)
async def test_spi_write_mem(dut, latency, default_mode_pin):
    """CP-02: Write corner patterns via 1S-1S-1S xSPI; read back; verify equality.

    Pass criterion: read_Mem() after write_Mem() returns identical 8 bytes.
    """
    cocotb.log.info(
        f"CP-02 spi_write latency={latency} default_mode_pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    for idx, (waddr, wval) in enumerate(zip(CORNER_ADDRS, CORNER_DATA)):
        cocotb.log.info(
            f"  iter {idx}: addr=0x{waddr:08x} data=0x{wval:016x}"
        )
        await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
        rv = await env.cmd.read_Mem(waddr)
        assert hex(int.from_bytes(rv, "little")) == hex(wval), (
            f"CP-02 write-back mismatch addr=0x{waddr:08x} "
            f"expected=0x{wval:016x} "
            f"got=0x{int.from_bytes(rv,'little'):016x}"
        )

    await env.assert_no_xspi_errors(msg="CP-02 unexpected xSPI error flags")


# ── Random address / data sweep ───────────────────────────────────────────────
@cocotb.test(timeout_time=40000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 12, 17, 20],
    default_mode_pin=[1, 2, 3],
)
async def test_spi_random_addr_data(dut, latency, default_mode_pin):
    """CP-01+CP-02: Random addresses and data in 1S-1S-1S mode.

    Exercises AXI-backdoor → xSPI-read and xSPI-write → xSPI-read paths
    across varied addresses to catch any address-decoding corner cases.
    """
    cocotb.log.info(
        f"SPI random addr/data latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    for i in range(5):
        # AXI backdoor preload → xSPI read
        addr = RAND_ADDRS[i]
        val  = RAND_DATA[i]
        cocotb.log.info(f"  read  {i}: addr=0x{addr:08x} data=0x{val:016x}")
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"random AXI→xSPI read mismatch i={i} addr=0x{addr:08x}"
        )

        # xSPI write → xSPI read-back
        waddr = RAND_ADDRS[i + 10]
        wval  = RAND_DATA[i + 10]
        cocotb.log.info(f"  write {i}: addr=0x{waddr:08x} data=0x{wval:016x}")
        await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
        rv = await env.cmd.read_Mem(waddr)
        assert hex(int.from_bytes(rv, "little")) == hex(wval), (
            f"random xSPI write-back mismatch i={i} addr=0x{waddr:08x}"
        )

    await env.assert_no_xspi_errors(msg="SPI random test unexpected errors")
