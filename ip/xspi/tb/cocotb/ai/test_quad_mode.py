"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-09  Quad 4S-4D-4D read – correct nibble ordering
       Quad 4S-4S-4S read/write – additional coverage
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

random.seed(0xFEEDFACE)

ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(20)]
DATA  = [random.randint(0, 2**64 - 1)          for _ in range(20)]

# Nibble-sensitive patterns – catch any high/low nibble swap
NIBBLE_PATTERNS = [
    0xf0f0f0f0f0f0f0f0,   # high nibbles all-F
    0x0f0f0f0f0f0f0f0f,   # low nibbles all-F
    0xf00ff00ff00ff00f,   # alternating 4-bit groups
    0x0ff00ff00ff00ff0,   # complement of above
    0x1234567890abcdef,   # incrementing nibbles
    0xfedcba9876543210,   # decrementing nibbles
    0xaaaaaaaaaaaaaaaa,
    0x5555555555555555,
]

QUAD_MODES = [
    (Mode.S4, Mode.D4, Mode.D4),   # 4S-4D-4D
    (Mode.S4, Mode.S4, Mode.S4),   # 4S-4S-4S
    (Mode.D4, Mode.D4, Mode.D4),   # 4D-4D-4D
]


# ── CP-09: 4S-4D-4D nibble ordering ──────────────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=list(range(8, 21, 3)),
    default_mode_pin=[1, 2, 3],
)
async def test_quad_ddr_nibble_ordering(dut, latency, default_mode_pin):
    """CP-09: Read and write in 4S-4D-4D mode with nibble-sensitive patterns.

    Pass criterion: every reconstructed byte returned by read_Mem() has
    high and low nibbles in the correct order (matches the written value).
    """
    cocotb.log.info(
        f"CP-09 4S-4D-4D nibble latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency, (
        f"latency_count mismatch: expected={latency} "
        f"got={int(dut.dut.latency_count.value)}"
    )
    await env.cmd.setRate(Mode.S4, Mode.D4, Mode.D4)

    assert dut.dut.cmd_rate_wget.value.to_unsigned()     == Mode.S4.value, (
        "CP-09 cmd_rate != S4"
    )
    assert dut.dut.address_rate_wget.value.to_unsigned() == Mode.D4.value, (
        "CP-09 addr_rate != D4"
    )
    assert dut.dut.data_rate_wget.value.to_unsigned()    == Mode.D4.value, (
        "CP-09 data_rate != D4"
    )

    for idx, val in enumerate(NIBBLE_PATTERNS):
        addr = ADDRS[idx]
        cocotb.log.info(
            f"  CP-09 nibble idx={idx} addr=0x{addr:08x} data=0x{val:016x}"
        )
        # AXI backdoor → 4S-4D-4D read
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
        rdata = await env.cmd.read_Mem(addr)
        got = int.from_bytes(rdata, "little")
        assert hex(got) == hex(val), (
            f"CP-09 nibble mismatch idx={idx} addr=0x{addr:08x} "
            f"expected=0x{val:016x} got=0x{got:016x}\n"
            f"  high_half expected=0x{val>>32:08x} got=0x{got>>32:08x}\n"
            f"  low_half  expected=0x{val&0xffffffff:08x} got=0x{got&0xffffffff:08x}"
        )

    await env.assert_no_xspi_errors(msg="CP-09 unexpected errors in 4S-4D-4D")


# ── Quad write-back in 4S-4D-4D ──────────────────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 12, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_quad_ddr_write_back(dut, latency, default_mode_pin):
    """CP-09 write side: write via 4S-4D-4D, read back, verify nibble integrity."""
    cocotb.log.info(
        f"CP-09 4S-4D-4D write latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S4, Mode.D4, Mode.D4)

    for idx, val in enumerate(NIBBLE_PATTERNS):
        waddr = ADDRS[8 + idx]
        cocotb.log.info(
            f"  write idx={idx} addr=0x{waddr:08x} data=0x{val:016x}"
        )
        await env.cmd.write_Mem(waddr, val.to_bytes(8, "little"))
        rv = await env.cmd.read_Mem(waddr)
        got = int.from_bytes(rv, "little")
        assert hex(got) == hex(val), (
            f"CP-09 write-back nibble mismatch idx={idx} "
            f"addr=0x{waddr:08x} expected=0x{val:016x} got=0x{got:016x}"
        )

    await env.assert_no_xspi_errors(msg="CP-09 write-back unexpected errors")


# ── All Quad modes sweep ──────────────────────────────────────────────────────
@cocotb.test(timeout_time=45000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_quad_all_modes(dut, latency, default_mode_pin):
    """Quad 4S-4D-4D, 4S-4S-4S, 4D-4D-4D: read/write round-trip for each mode."""
    cocotb.log.info(
        f"quad_all_modes latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency

    for cmd_m, addr_m, data_m in QUAD_MODES:
        cocotb.log.info(
            f"  mode {cmd_m.name}-{addr_m.name}-{data_m.name}"
        )
        await env.cmd.setRate(cmd_m, addr_m, data_m)

        assert dut.dut.cmd_rate_wget.value.to_unsigned()     == cmd_m.value,  (
            f"cmd_rate mismatch mode={cmd_m.name}"
        )
        assert dut.dut.address_rate_wget.value.to_unsigned() == addr_m.value, (
            f"addr_rate mismatch mode={cmd_m.name}"
        )
        assert dut.dut.data_rate_wget.value.to_unsigned()    == data_m.value, (
            f"data_rate mismatch mode={cmd_m.name}"
        )

        for i in range(4):
            addr = ADDRS[i]
            val  = DATA[i]
            env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
            rdata = await env.cmd.read_Mem(addr)
            assert hex(int.from_bytes(rdata, "little")) == hex(val), (
                f"read mismatch mode={cmd_m.name} i={i}"
            )
            waddr = ADDRS[i + 4]
            wval  = DATA[i + 4]
            await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))
            rv = await env.cmd.read_Mem(waddr)
            assert hex(int.from_bytes(rv, "little")) == hex(wval), (
                f"write-back mismatch mode={cmd_m.name} i={i}"
            )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="quad_all_modes unexpected errors")
