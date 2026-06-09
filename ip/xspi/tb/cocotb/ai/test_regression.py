"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

Regression test – cross-coverage sweep
  Axes: protocol mode × latency × burst address pattern × data pattern
  Mirrors the coverage model in verification_plan.md §4.1
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

random.seed(0x5EED5EED)

# ── All supported modes from test_default.py ─────────────────────────────────
ALL_MODES = [
    (Mode.S1, Mode.S1, Mode.S1),   # 1S-1S-1S  SPI
    (Mode.S1, Mode.D1, Mode.D1),   # 1S-1D-1D  DDR SPI
    (Mode.S4, Mode.D4, Mode.D4),   # 4S-4D-4D  Quad DDR
    (Mode.D4, Mode.D4, Mode.D4),   # 4D-4D-4D  Quad DDR full
    (Mode.S8, Mode.S8, Mode.S8),   # 8S-8S-8S  Octal SDR
    (Mode.D8, Mode.D8, Mode.D8),   # 8D-8D-8D  Octal DDR
]

# ── Address patterns (8-byte aligned) ────────────────────────────────────────
def _walking_ones_addrs(n=8):
    addrs = []
    for bit in range(min(n, 28)):
        addrs.append((1 << bit) & 0xfffffff8)
    return addrs[:n]

ADDR_PATTERNS = {
    "zero":       [0x00000000],
    "max":        [0x0ffffff8],
    "walking_1":  _walking_ones_addrs(8),
    "alternating":[0x0aaaaaaa & 0xfffffff8, 0x05555558 & 0xfffffff8],
    "random":     [random.randint(0, 2**28) & 0xfffffff8 for _ in range(8)],
}

# ── Data patterns ─────────────────────────────────────────────────────────────
DATA_PATTERNS = {
    "zero":       [0x0000000000000000],
    "ff":         [0xffffffffffffffff],
    "walking_1":  [1 << i for i in range(8)],
    "alternating":[0xaaaaaaaaaaaaaaaa, 0x5555555555555555],
    "random":     [random.randint(0, 2**64 - 1) for _ in range(8)],
}


# ── Helper: run a read/write sweep for a given mode ───────────────────────────
async def _mode_sweep(env, mode, latency, addr_list, data_list, tag):
    cmd_m, addr_m, data_m = mode
    await env.cmd.setRate(cmd_m, addr_m, data_m)

    assert env.dut.dut.cmd_rate_wget.value.to_unsigned()     == cmd_m.value,  (
        f"{tag} cmd_rate mismatch"
    )
    assert env.dut.dut.address_rate_wget.value.to_unsigned() == addr_m.value, (
        f"{tag} addr_rate mismatch"
    )
    assert env.dut.dut.data_rate_wget.value.to_unsigned()    == data_m.value, (
        f"{tag} data_rate mismatch"
    )

    pairs = list(zip(
        addr_list * ((len(data_list) // len(addr_list)) + 1),
        data_list,
    ))[:len(data_list)]

    for idx, (addr, val) in enumerate(pairs):
        # AXI backdoor → xSPI read
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"{tag} read mismatch idx={idx} addr=0x{addr:08x} "
            f"expected=0x{val:016x} got=0x{int.from_bytes(rdata,'little'):016x}"
        )

        # xSPI write → read-back
        waddr = (addr + 0x1000) & 0x0fffffff8
        await env.cmd.write_Mem(waddr, val.to_bytes(8, "little"))
        rv = await env.cmd.read_Mem(waddr)
        assert hex(int.from_bytes(rv, "little")) == hex(val), (
            f"{tag} write-back mismatch idx={idx} addr=0x{waddr:08x}"
        )


# ── Regression: mode × latency × data_pattern ────────────────────────────────
@cocotb.test(timeout_time=40110, timeout_unit="ns")
@cocotb.parametrize(
    mode=ALL_MODES,
    latency=list(range(8, 16)),
    default_mode_pin=[1, 2, 3],
)
async def test_regression_mode_latency(dut, mode, latency, default_mode_pin):
    """Cross-coverage: every (mode, latency, default_mode_pin) combination.

    For each combination: AXI-backdoor → xSPI-read and xSPI-write → read-back,
    using the same 5-iteration pattern as test_default.py::regress().
    """
    cocotb.log.info(
        f"regression mode={mode[0].name}-{mode[1].name}-{mode[2].name} "
        f"latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    addrs = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(5)]
    data  = [random.randint(0, 2**64 - 1)          for _ in range(5)]
    data[0] = 0xaaaaaaaaaaaaaaaa
    data[1] = 0x0000000000000000
    data[2] = 0x12345678abcdef5a
    data[3] = 0xaa55aa55aa55aa55
    data[4] = 0xffffffffffffffff

    await _mode_sweep(
        env, mode, latency, addrs, data,
        tag=f"mode={mode[0].name} lat={latency}",
    )

    await env.assert_no_xspi_errors(
        msg=f"regression mode={mode[0].name} latency={latency} unexpected errors"
    )


# ── Regression: data patterns × address patterns ─────────────────────────────
@cocotb.test(timeout_time=550000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_regression_data_addr_patterns(dut, latency, default_mode_pin):
    """Regression: sweep corner address patterns × corner data patterns.

    Covers the coverage model cross-product:
      address_pattern × {zero, max, walking_1, alternating, random}
      data_pattern    × {zero, ff, walking_1, alternating, random}
    for both SPI and Octal DDR modes.
    """
    cocotb.log.info(
        f"regression data/addr patterns latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    for mode in [(Mode.S1, Mode.S1, Mode.S1), (Mode.D8, Mode.D8, Mode.D8)]:
        for addr_name, addr_list in ADDR_PATTERNS.items():
            for data_name, data_list in DATA_PATTERNS.items():
                tag = (
                    f"mode={mode[0].name} "
                    f"addr={addr_name} data={data_name} lat={latency}"
                )
                cocotb.log.info(f"  sweep {tag}")
                await _mode_sweep(env, mode, latency, addr_list, data_list, tag)

        # Reset to SPI between major mode groups
        await env.cmd.Reset()
        for _ in range(10):
            await RisingEdge(dut.xspi_clk)
        await env.cmd.setLatency(latency)

    await env.assert_no_xspi_errors(msg="regression data/addr patterns unexpected errors")


# ── Regression: random mode transitions with intermixed reads/writes ──────────
@cocotb.test(timeout_time=50000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_regression_random_mode_transitions(dut, latency, default_mode_pin):
    """Regression: randomly switch between modes between transactions.

    Verifies that the mode state machine stays consistent across arbitrary
    mode transitions without losing data or hanging.
    """
    cocotb.log.info(
        f"regression random mode transitions latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    rng = random.Random(0xDEAD1234)
    for step in range(10):
        mode = rng.choice(ALL_MODES)
        addr = rng.randint(0, 2**28) & 0xfffffff8
        val  = rng.randint(0, 2**64 - 1)
        cocotb.log.info(
            f"  step={step} mode={mode[0].name}-{mode[1].name}-{mode[2].name} "
            f"addr=0x{addr:08x} data=0x{val:016x}"
        )
        await env.cmd.setRate(*mode)
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"random_transition step={step} mode={mode[0].name} mismatch"
        )
        waddr = (addr + 0x2000) & 0x0fffffff8
        wval  = rng.randint(0, 2**64 - 1)
        await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
        rv = await env.cmd.read_Mem(waddr)
        assert hex(int.from_bytes(rv, "little")) == hex(wval), (
            f"random_transition write-back step={step}"
        )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="random_mode_transitions unexpected errors")
