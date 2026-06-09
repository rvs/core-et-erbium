"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-04  SPI→Octal mode switch via setRate – subsequent Octal read must succeed
CP-08  Octal→Reset (soft-reset) – driver and DUT revert to 1S-1S-1S
CP-10  setRate → HB mode – all three rate registers must read HB (8)
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

random.seed(0xBEEFCAFE)

ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(20)]
DATA  = [random.randint(0, 2**64 - 1)          for _ in range(20)]

def _get_default_mode(default_mode_pin):
    if default_mode_pin == 1:
        default_mode = Mode.D8
    if default_mode_pin == 2:
        default_mode = Mode.S4
    if default_mode_pin == 3:
        default_mode = Mode.S1
    return default_mode


# ── CP-04: SPI → Octal mode switch ───────────────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 12, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_spi_to_octal_switch(dut, latency, default_mode_pin):
    """CP-04: Boot in SPI, switch to Octal DDR via setRate; read/write must succeed.

    Pass criterion: after setRate(D8,D8,D8) DUT rate registers reflect D8
                    and a read_Mem/write_Mem round-trip succeeds.
    """
    cocotb.log.info(
        f"CP-04 SPI→Octal latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    # ── Step 1: verify SPI baseline ──────────────────────────────────────────
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)
    spi_addr = ADDRS[0]
    spi_val  = DATA[0]
    env.axi_ram.write(spi_addr, list(spi_val.to_bytes(8, "little")))
    rdata = await env.cmd.read_Mem(spi_addr)
    assert hex(int.from_bytes(rdata, "little")) == hex(spi_val), (
        "CP-04 SPI baseline read failed"
    )

    # ── Step 2: switch to Octal DDR ──────────────────────────────────────────
    cocotb.log.info("CP-04 switching SPI → Octal DDR (D8-D8-D8)")
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)

    assert dut.dut.cmd_rate_wget.value.to_unsigned()     == Mode.D8.value, (
        f"CP-04 cmd_rate after switch: "
        f"expected={Mode.D8.value} got={dut.dut.cmd_rate_wget.value.to_unsigned()}"
    )
    assert dut.dut.data_rate_wget.value.to_unsigned()    == Mode.D8.value, (
        "CP-04 data_rate after switch"
    )
    assert dut.dut.address_rate_wget.value.to_unsigned() == Mode.D8.value, (
        "CP-04 addr_rate after switch"
    )

    # ── Step 3: Octal DDR read/write must work ───────────────────────────────
    oct_addr = ADDRS[1]
    oct_val  = DATA[1]
    cocotb.log.info(f"CP-04 Octal read addr=0x{oct_addr:08x}")
    env.axi_ram.write(oct_addr, list(oct_val.to_bytes(8, "little")))
    rdata = await env.cmd.read_Mem(oct_addr)
    assert hex(int.from_bytes(rdata, "little")) == hex(oct_val), (
        f"CP-04 Octal read mismatch: "
        f"expected=0x{oct_val:016x} "
        f"got=0x{int.from_bytes(rdata,'little'):016x}"
    )

    wval  = DATA[2]
    waddr = ADDRS[2]
    await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
    rv = await env.cmd.read_Mem(waddr)
    assert hex(int.from_bytes(rv, "little")) == hex(wval), (
        f"CP-04 Octal write-back mismatch addr=0x{waddr:08x}"
    )

    await env.assert_no_xspi_errors(msg="CP-04 unexpected errors after mode switch")


# ── CP-08: Octal → Reset → SPI ───────────────────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 12, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_octal_reset_to_spi(dut, latency, default_mode_pin):
    """CP-08: Switch to Octal DDR, send Reset command; driver must revert to S1-S1-S1.

    Pass criterion:
      - env.cmd.cmd_mode  == Mode.S1  after Reset()
      - DUT rate registers reflect S1 (0) after subsequent setRate(S1,S1,S1)
      - SPI read_Mem still works after reset
    """
    cocotb.log.info(
        f"CP-08 Octal→Reset latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    # ── Step 1: move to Octal DDR ────────────────────────────────────────────
    cocotb.log.info("CP-08 switching to Octal DDR")
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)

    # ── Step 2: soft reset in Octal mode (Format 1.A) ────────────────────────
    cocotb.log.info("CP-08 issuing Reset() in Octal DDR mode")
    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)

    # ── Step 3: driver mode must be S1-S1-S1 after Reset ────────────────────
    default_mode = _get_default_mode(default_mode_pin)
    assert env.cmd.cmd_mode      == default_mode, (
        f"CP-08 cmd_mode after Reset: expected=S1 got={env.cmd.cmd_mode}"
    )
    assert env.cmd.modifier_mode == default_mode, (
        f"CP-08 modifier_mode after Reset: expected=S1 got={env.cmd.modifier_mode}"
    )
    assert env.cmd.data_mode     == default_mode, (
        f"CP-08 data_mode after Reset: expected=S1 got={env.cmd.data_mode}"
    )

    # ── Step 4: SPI operations must work after reset ─────────────────────────
    cocotb.log.info("CP-08 Start SetLatency")
    await env.cmd.setLatency(latency)
    cocotb.log.info("CP-08 setLatency Done")
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)
    cocotb.log.info("CP-08 setRate Done")
    assert dut.dut.cmd_rate_wget.value.to_unsigned() == Mode.S1.value, (
        "CP-08 cmd_rate not S1 after reset+setRate(S1)"
    )

    addr = ADDRS[5]
    val  = DATA[5]
    cocotb.log.info(f"CP-08 SPI read after reset addr=0x{addr:08x}")
    env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
    rdata = await env.cmd.read_Mem(addr)
    assert hex(int.from_bytes(rdata, "little")) == hex(val), (
        f"CP-08 SPI read after reset mismatch addr=0x{addr:08x}"
    )

    await env.assert_no_xspi_errors(msg="CP-08 unexpected errors after Octal→Reset")


# ── CP-10: setRate → Hyperbus ─────────────────────────────────────────────────
@cocotb.test(timeout_time=20000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_setrate_hyperbus(dut, default_mode_pin):
    """CP-10: setRate(HB, HB, HB) – all three DUT rate registers must read HB (8).

    Pass criterion: cmd_rate_wget == addr_rate_wget == data_rate_wget == 8
                    (Mode.HB.value == 8, per xspi.md SetRate encoding)
    """
    cocotb.log.info(f"CP-10 setRate→HB pin={default_mode_pin}")
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False

    # setRate in SPI first, confirm baseline
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)
    assert dut.dut.cmd_rate_wget.value.to_unsigned() == Mode.S1.value

    # Switch to Hyperbus
    cocotb.log.info("CP-10 issuing setRate(HB, HB, HB)")
    await env.cmd.setRate(Mode.HB, Mode.HB, Mode.HB)

    assert dut.dut.cmd_rate_wget.value.to_unsigned()     == Mode.HB.value, (
        f"CP-10 cmd_rate: expected={Mode.HB.value} "
        f"got={dut.dut.cmd_rate_wget.value.to_unsigned()}"
    )
    assert dut.dut.address_rate_wget.value.to_unsigned() == Mode.HB.value, (
        f"CP-10 addr_rate: expected={Mode.HB.value} "
        f"got={dut.dut.address_rate_wget.value.to_unsigned()}"
    )
    assert dut.dut.data_rate_wget.value.to_unsigned()    == Mode.HB.value, (
        f"CP-10 data_rate: expected={Mode.HB.value} "
        f"got={dut.dut.data_rate_wget.value.to_unsigned()}"
    )
    cocotb.log.info(
        f"CP-10 PASS: all rates = {Mode.HB.value} (HB)"
    )


# ── Full transition chain: S1 → S4 → D4 → D8 → Reset → S1 ──────────────────
_TRANSITIONS = [
    (Mode.S4, Mode.S4, Mode.S4),
    (Mode.S4, Mode.D4, Mode.D4),
    (Mode.D4, Mode.D4, Mode.D4),
    (Mode.S8, Mode.S8, Mode.S8),
    (Mode.D8, Mode.D8, Mode.D8),
]

@cocotb.test(timeout_time=50000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_full_mode_transition_chain(dut, latency, default_mode_pin):
    """CP-04+CP-08: Walk through all supported modes; verify DUT rate registers
    and a read/write round-trip at each step; finally Reset and confirm SPI.
    """
    cocotb.log.info(
        f"mode_chain latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    # Start in SPI
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    for step, (cmd_m, addr_m, data_m) in enumerate(_TRANSITIONS):
        cocotb.log.info(
            f"  step {step}: setRate({cmd_m.name},{addr_m.name},{data_m.name})"
        )
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        assert dut.dut.cmd_rate_wget.value.to_unsigned()     == cmd_m.value,  (
            f"step {step} cmd_rate mismatch"
        )
        assert dut.dut.address_rate_wget.value.to_unsigned() == addr_m.value, (
            f"step {step} addr_rate mismatch"
        )
        assert dut.dut.data_rate_wget.value.to_unsigned()    == data_m.value, (
            f"step {step} data_rate mismatch"
        )

        addr = ADDRS[step + 3]
        val  = DATA[step + 3]
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"step {step} read mismatch after setRate({cmd_m.name})"
        )

    # Final Reset must return to S1
    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    default_mode = _get_default_mode(default_mode_pin)
    assert env.cmd.cmd_mode  == default_mode, f"mode_chain: cmd_mode != {default_mode} after Reset"
    assert env.cmd.data_mode == default_mode, f"mode_chain: data_mode != {default_mode} after Reset"

    await env.assert_no_xspi_errors(msg="mode_chain unexpected errors")
