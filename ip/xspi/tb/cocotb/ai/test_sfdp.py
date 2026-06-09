"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-03  SFDP header parseable at address 0x000000
       - First 4 bytes must equal b"SFDP"  (0x50444653 little-endian)
       - SFDP readable at ≤50 MHz as required by JESD216H §4.4
       - Test in SPI and Octal modes (xspi.md §Modes)
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode

# SFDP signature: bytes 0..3 = "SFDP" (ASCII 0x53 0x46 0x44 0x50)
SFDP_SIGNATURE = b"SFDP"

# Read SFDP at address 0 (header) and a few section offsets
SFDP_ADDRESSES = [
    0x000000,   # SFDP header (mandatory)
    0x000008,   # First parameter header
]


# ── CP-03: SPI 1S-1S-1S SFDP ─────────────────────────────────────────────────
@cocotb.test(timeout_time=25000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_sfdp_spi_signature(dut, default_mode_pin):
    """CP-03: Read SFDP in 1S-1S-1S mode; bytes[0:4] must be b'SFDP'.

    Per JESD216H §4.1 the first instruction a device receives during POR
    discovery is READ SFDP (0x5A) and the signature at address 0x000000
    must be 0x50444653h ("SFDP" in little-endian).
    """
    cocotb.log.info(f"CP-03 SFDP SPI pin={default_mode_pin}")
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    cocotb.log.info("CP-03 reading SFDP at address 0x000000")
    data = await env.cmd.read_SFDP(0x000000)

    assert len(data) >= 4, (
        f"CP-03 SFDP returned fewer than 4 bytes: got {len(data)}"
    )
    assert data[0:4] == SFDP_SIGNATURE, (
        f"CP-03 SFDP signature mismatch: "
        f"expected {SFDP_SIGNATURE!r} got {data[0:4]!r} "
        f"(full header hex: {data[0:16].hex()})"
    )
    cocotb.log.info(f"CP-03 PASS: SFDP header = {data[0:16].hex()}")

    await env.assert_no_xspi_errors(msg="CP-03 SPI SFDP unexpected errors")


# ── CP-03: Octal DDR SFDP ────────────────────────────────────────────────────
@cocotb.test(timeout_time=25000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_sfdp_octal_signature(dut, latency, default_mode_pin):
    """CP-03: Read SFDP in 8D-8D-8D Octal mode; signature must remain b'SFDP'.

    The Octal DDR SFDP read uses Format 1.B (CMD+EXT, 4B addr, latency, data).
    Per JESD216H §4.5.5 the signature and 50 MHz requirement still apply.
    """
    cocotb.log.info(
        f"CP-03 SFDP Octal DDR latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)

    cocotb.log.info("CP-03 reading SFDP (Octal DDR) at address 0x000000")
    data = await env.cmd.read_SFDP(0x000000)

    assert len(data) >= 4, (
        f"CP-03 Octal SFDP returned < 4 bytes: got {len(data)}"
    )
    assert data[0:4] == SFDP_SIGNATURE, (
        f"CP-03 Octal SFDP signature mismatch: "
        f"expected {SFDP_SIGNATURE!r} got {data[0:4]!r}"
    )
    cocotb.log.info(f"CP-03 PASS Octal: SFDP header = {data[0:16].hex()}")

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-03 Octal SFDP unexpected errors")


# ── CP-03: Quad SFDP ──────────────────────────────────────────────────────────
@cocotb.test(timeout_time=25000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_sfdp_quad_signature(dut, default_mode_pin):
    """CP-03: Read SFDP in 4S-4D-4D Quad DDR mode; signature must be b'SFDP'."""
    cocotb.log.info(f"CP-03 SFDP Quad DDR pin={default_mode_pin}")
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(17)
    await env.cmd.setRate(Mode.S4, Mode.D4, Mode.D4)

    data = await env.cmd.read_SFDP(0x000000)
    assert data[0:4] == SFDP_SIGNATURE, (
        f"CP-03 Quad SFDP signature mismatch: got {data[0:4]!r}"
    )
    cocotb.log.info(f"CP-03 PASS Quad: header = {data[0:16].hex()}")

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-03 Quad SFDP unexpected errors")


# ── SFDP content consistency across modes ────────────────────────────────────
@cocotb.test(timeout_time=40000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_sfdp_consistent_across_modes(dut, default_mode_pin):
    """SFDP bytes[0:16] must be identical whether read in SPI or Octal mode.

    The SFDP database is static (factory default) – the same bytes must be
    returned regardless of the xSPI bus mode in use.
    """
    cocotb.log.info(
        f"SFDP consistency SPI vs Octal pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False

    # Read in SPI
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)
    spi_data = await env.cmd.read_SFDP(0x000000)
    cocotb.log.info(f"  SPI SFDP header: {spi_data[0:16].hex()}")
    assert spi_data[0:4] == SFDP_SIGNATURE, "SPI SFDP signature wrong"

    # Switch to Octal DDR, read again
    await env.cmd.setLatency(17)
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)
    oct_data = await env.cmd.read_SFDP(0x000000)
    cocotb.log.info(f"  Octal SFDP header: {oct_data[0:16].hex()}")
    assert oct_data[0:4] == SFDP_SIGNATURE, "Octal SFDP signature wrong"

    # Both reads must return the same header bytes
    assert spi_data[0:16] == oct_data[0:16], (
        f"SFDP inconsistency between SPI and Octal:\n"
        f"  SPI  : {spi_data[0:16].hex()}\n"
        f"  Octal: {oct_data[0:16].hex()}"
    )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="SFDP consistency unexpected errors")
