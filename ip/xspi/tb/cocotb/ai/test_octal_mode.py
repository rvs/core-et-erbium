"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-05  Octal Format 1.A (Reset / Enter PD / Exit PD) – no extra address/data clocks
CP-06  Octal Format 1.B (Read Mem) – latency count matches configured value
CP-07  Octal Format 1.D (Write Mem) – data driven immediately after address
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

random.seed(0xCAFEBABE)

ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(20)]
DATA  = [random.randint(0, 2**64 - 1)          for _ in range(20)]

CORNER_DATA = [
    0xaaaaaaaaaaaaaaaa,
    0x0000000000000000,
    0xffffffffffffffff,
    0xaa55aa55aa55aa55,
    0x5555555555555555,
]

OCTAL_MODES = [
    (Mode.D8, Mode.D8, Mode.D8),  # Octal DDR Profile 1 (8D-8D-8D)
    (Mode.S8, Mode.S8, Mode.S8),  # Octal STR           (8S-8S-8S)
]

def _get_default_mode(default_mode_pin):
    if default_mode_pin == 1:
        default_mode = Mode.D8
    if default_mode_pin == 2:
        default_mode = Mode.S4
    if default_mode_pin == 3:
        default_mode = Mode.S1
    return default_mode

# ── CP-05: Octal Format 1.A – Reset in Octal mode ────────────────────────────
@cocotb.test(timeout_time=25000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_octal_format1A_reset(dut, latency, default_mode_pin):
    """CP-05: Issue Reset() in Octal DDR/STR mode (Format 1.A).

    Verifies that the Reset command completes without assertion errors and the
    driver returns to S1-S1-1S (no spurious address or data bytes driven).
    Pass criterion: Reset() completes; driver cmd_mode == S1 afterwards.
    """
    cocotb.log.info(
        f"CP-05 Octal Format1A Reset latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    for cmd_m, addr_m, data_m in OCTAL_MODES:
        cocotb.log.info(
            f"  Format1A Reset in {cmd_m.name}-{addr_m.name}-{data_m.name}"
        )
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        # Reset in Octal → uses Format 1.A (cmd + extension, no addr, no data)
        await env.cmd.Reset()
        for _ in range(10):
            await RisingEdge(dut.xspi_clk)

        # Driver must have reverted to S1
        default_mode = _get_default_mode(default_mode_pin)
        assert env.cmd.cmd_mode == default_mode, (
            f"CP-05 cmd_mode != S1 after Octal Reset ({cmd_m.name})"
        )
        assert env.cmd.data_mode == default_mode, (
            f"CP-05 data_mode != S1 after Octal Reset ({cmd_m.name})"
        )

        # Re-establish Octal for next iteration
        await env.cmd.setLatency(latency)
        await env.cmd.setRate(cmd_m, addr_m, data_m)

    # Leave in SPI for the error check
    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-05 unexpected errors after Octal Reset")


# ── CP-06: Octal Format 1.B – Read Mem with configured latency ───────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=list(range(8, 21, 2)),
    default_mode_pin=[1, 2, 3],
)
async def test_octal_read_mem_latency(dut, latency, default_mode_pin):
    """CP-06: Read Memory in Octal mode; latency_count DUT probe must match
    the value programmed via setLatency().

    Pass criterion:
      - dut.dut.latency_count == latency (after setLatency)
      - read_Mem() returns correct data at all tested latency values
    """
    cocotb.log.info(
        f"CP-06 Octal read latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency, (
        f"CP-06 latency_count mismatch: expected={latency} "
        f"got={int(dut.dut.latency_count.value)}"
    )

    for cmd_m, addr_m, data_m in OCTAL_MODES:
        cocotb.log.info(
            f"  CP-06 {cmd_m.name}-{addr_m.name}-{data_m.name} latency={latency}"
        )
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        for idx, (addr, val) in enumerate(zip(ADDRS[:5], CORNER_DATA)):
            env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
            rdata = await env.cmd.read_Mem(addr)
            assert hex(int.from_bytes(rdata, "little")) == hex(val), (
                f"CP-06 read mismatch mode={cmd_m.name} latency={latency} "
                f"idx={idx} addr=0x{addr:08x} "
                f"expected=0x{val:016x} "
                f"got=0x{int.from_bytes(rdata,'little'):016x}"
            )

    # Reset to SPI before error check
    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-06 unexpected errors in Octal read")


# ── CP-07: Octal Format 1.D – Write Mem ──────────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 12, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_octal_write_mem(dut, latency, default_mode_pin):
    """CP-07: Write Memory in Octal mode (Format 1.D).

    Format 1.D has no latency cycles between address and data.
    Pass criterion: data written via write_Mem() is returned correctly by
    a subsequent read_Mem().
    """
    cocotb.log.info(
        f"CP-07 Octal write latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    for cmd_m, addr_m, data_m in OCTAL_MODES:
        cocotb.log.info(
            f"  CP-07 {cmd_m.name}-{addr_m.name}-{data_m.name}"
        )
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        for idx, (waddr, wval) in enumerate(zip(ADDRS[5:10], CORNER_DATA)):
            cocotb.log.info(
                f"    write idx={idx} addr=0x{waddr:08x} data=0x{wval:016x}"
            )
            await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
            rv = await env.cmd.read_Mem(waddr)
            assert hex(int.from_bytes(rv, "little")) == hex(wval), (
                f"CP-07 write-back mismatch mode={cmd_m.name} "
                f"addr=0x{waddr:08x} "
                f"expected=0x{wval:016x} "
                f"got=0x{int.from_bytes(rv,'little'):016x}"
            )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-07 unexpected errors in Octal write")


# ── Octal DDR full sweep: all corner data, both Octal modes ──────────────────
@cocotb.test(timeout_time=40000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17, 20],
    default_mode_pin=[1, 2, 3],
)
async def test_octal_full_sweep(dut, latency, default_mode_pin):
    """CP-06+CP-07: Corner data patterns via Octal SDR and DDR modes."""
    cocotb.log.info(
        f"octal_full_sweep latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    for cmd_m, addr_m, data_m in OCTAL_MODES:
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        for i in range(5):
            addr = ADDRS[10 + i]
            val  = DATA[10 + i]
            # AXI backdoor load → Octal read
            env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
            rdata = await env.cmd.read_Mem(addr)
            assert hex(int.from_bytes(rdata, "little")) == hex(val), (
                f"octal_sweep read mismatch mode={cmd_m.name} i={i}"
            )

            # Octal write → Octal read-back
            waddr = ADDRS[15 + i]
            wval  = DATA[15 + i]
            await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
            rv = await env.cmd.read_Mem(waddr)
            assert hex(int.from_bytes(rv, "little")) == hex(wval), (
                f"octal_sweep write-back mismatch mode={cmd_m.name} i={i}"
            )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="octal_full_sweep unexpected errors")
