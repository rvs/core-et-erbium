"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-11  tCS_high guard – back-to-back transactions respect minimum CS# deselect time
       CS# deasserts after last data bit of each transaction
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge
from env import Env
from cocotbext.xspi.types import Mode
from cocotbext.xspi.config import default_config
import random

random.seed(0xBAADF00D)

ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(20)]
DATA  = [random.randint(0, 2**64 - 1)          for _ in range(20)]

# tCS_high from config (ns)
TCS_HIGH_NS = default_config.tCS_high   # typically 20 ns


async def _measure_cs_gap(dut):
    """Return the time (ns) between CS# rising edge and next CS# falling edge."""
    await RisingEdge(dut.xspi_csn)
    t_deassert = cocotb.utils.get_sim_time("ns")
    await FallingEdge(dut.xspi_csn)
    t_assert = cocotb.utils.get_sim_time("ns")
    return t_assert - t_deassert


# ── CP-11: tCS_high back-to-back ─────────────────────────────────────────────
@cocotb.test(timeout_time=30000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_tcs_high_back_to_back(dut, latency, default_mode_pin):
    """CP-11: Issue two back-to-back transactions; measure CS# gap.

    Pass criterion: gap between CS# deassert and next assert ≥ tCS_high.
    """
    cocotb.log.info(
        f"CP-11 tCS_high latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    # Preload memory for first read
    addr1 = ADDRS[0]
    val1  = DATA[0]
    addr2 = ADDRS[1]
    val2  = DATA[1]
    env.axi_ram.write(addr1, list(val1.to_bytes(8, "little")))
    env.axi_ram.write(addr2, list(val2.to_bytes(8, "little")))

    # Start gap monitor before issuing transactions
    gap_coro = cocotb.start_soon(_measure_cs_gap(dut))

    # First transaction
    rdata1 = await env.cmd.read_Mem(addr1)
    assert hex(int.from_bytes(rdata1, "little")) == hex(val1), (
        "CP-11 first read mismatch"
    )

    # Second transaction – driver's tCS_high guard must enforce the gap
    rdata2 = await env.cmd.read_Mem(addr2)
    assert hex(int.from_bytes(rdata2, "little")) == hex(val2), (
        "CP-11 second read mismatch"
    )

    gap_ns = await gap_coro
    cocotb.log.info(
        f"CP-11 measured CS# gap = {gap_ns:.1f} ns "
        f"(minimum required = {TCS_HIGH_NS} ns)"
    )
    assert gap_ns >= TCS_HIGH_NS, (
        f"CP-11 tCS_high violation: "
        f"gap={gap_ns:.1f} ns < minimum={TCS_HIGH_NS} ns"
    )

    await env.assert_no_xspi_errors(msg="CP-11 tCS_high unexpected errors")


# ── CP-11: tCS_high across write/read pairs ───────────────────────────────────
@cocotb.test(timeout_time=35000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_tcs_high_write_then_read(dut, latency, default_mode_pin):
    """CP-11: write_Mem → read_Mem transition; CS# gap must still meet tCS_high."""
    cocotb.log.info(
        f"CP-11 write→read gap latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    addr = ADDRS[2]
    val  = DATA[2]

    gap_coro = cocotb.start_soon(_measure_cs_gap(dut))

    await env.cmd.write_Mem(addr, val.to_bytes(8, "little"))
    rv = await env.cmd.read_Mem(addr)
    assert hex(int.from_bytes(rv, "little")) == hex(val), (
        "CP-11 write→read mismatch"
    )

    gap_ns = await gap_coro
    cocotb.log.info(
        f"CP-11 write→read gap = {gap_ns:.1f} ns (min={TCS_HIGH_NS} ns)"
    )
    assert gap_ns >= TCS_HIGH_NS, (
        f"CP-11 tCS_high write→read violation: {gap_ns:.1f} ns < {TCS_HIGH_NS} ns"
    )

    await env.assert_no_xspi_errors(msg="CP-11 write→read unexpected errors")


# ── CP-11: tCS_high in Octal DDR ─────────────────────────────────────────────
@cocotb.test(timeout_time=30000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_tcs_high_octal(dut, latency, default_mode_pin):
    """CP-11: tCS_high compliance in Octal DDR mode."""
    cocotb.log.info(
        f"CP-11 Octal tCS_high latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)

    addr1 = ADDRS[3]
    val1  = DATA[3]
    addr2 = ADDRS[4]
    val2  = DATA[4]
    env.axi_ram.write(addr1, list(val1.to_bytes(8, "little")))
    env.axi_ram.write(addr2, list(val2.to_bytes(8, "little")))

    gap_coro = cocotb.start_soon(_measure_cs_gap(dut))

    rdata1 = await env.cmd.read_Mem(addr1)
    assert hex(int.from_bytes(rdata1, "little")) == hex(val1), (
        "CP-11 Octal first read mismatch"
    )
    rdata2 = await env.cmd.read_Mem(addr2)
    assert hex(int.from_bytes(rdata2, "little")) == hex(val2), (
        "CP-11 Octal second read mismatch"
    )

    gap_ns = await gap_coro
    cocotb.log.info(
        f"CP-11 Octal CS# gap = {gap_ns:.1f} ns (min={TCS_HIGH_NS} ns)"
    )
    assert gap_ns >= TCS_HIGH_NS, (
        f"CP-11 Octal tCS_high violation: {gap_ns:.1f} ns < {TCS_HIGH_NS} ns"
    )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-11 Octal tCS_high unexpected errors")


# ── Latency sweep: tCS_high must hold at all latency values ──────────────────
@cocotb.test(timeout_time=50000, timeout_unit="ns")
@cocotb.parametrize(
    latency=list(range(8, 21, 3)),
    default_mode_pin=[1, 2, 3],
)
async def test_tcs_high_latency_sweep(dut, latency, default_mode_pin):
    """CP-11: Verify tCS_high across the full latency range (8..20)."""
    cocotb.log.info(
        f"CP-11 latency_sweep latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    for i in range(3):
        addr = ADDRS[5 + i]
        val  = DATA[5 + i]
        env.axi_ram.write(addr, list(val.to_bytes(8, "little")))

        gap_coro = cocotb.start_soon(_measure_cs_gap(dut))
        rdata = await env.cmd.read_Mem(addr)
        waddr = ADDRS[8 + i]
        wval  = DATA[8 + i]
        await env.cmd.write_Mem(waddr, wval.to_bytes(8, "little"))

        gap_ns = await gap_coro
        cocotb.log.info(
            f"  i={i} latency={latency} gap={gap_ns:.1f} ns"
        )
        assert gap_ns >= TCS_HIGH_NS, (
            f"CP-11 latency_sweep violation: "
            f"latency={latency} i={i} gap={gap_ns:.1f} ns < {TCS_HIGH_NS} ns"
        )
        assert hex(int.from_bytes(rdata, "little")) == hex(val), (
            f"latency_sweep read mismatch i={i}"
        )

    await env.assert_no_xspi_errors(msg="CP-11 latency_sweep unexpected errors")
