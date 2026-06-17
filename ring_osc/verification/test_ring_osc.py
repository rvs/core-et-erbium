# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
cocotb testbench for ring_osc.

Tests:
  1. test_enable_disable         - verify clk toggles when enabled and stops when disabled
  2. test_frequency_vs_trm       - measure frequency for several trm values, compare to model
  3. test_divby2                 - verify divby2_sel roughly halves the frequency
  4. test_debug_mode             - verify dbg_en overrides independently control anachip/rohcip
  5. test_debug_invalid_states   - invalid/edge-case debug enable combinations and dbg_en
                                   transitions (both enables low; asymmetric enable combos;
                                   entering/exiting debug while oscillating; sah_en_b=1 path)

Expected frequency model (from rochip.sv):
  divby2_sel=0: f_fast=1.608 GHz (trm=0) ... f_slow=0.899 GHz (trm=31)
  divby2_sel=1: f_fast=0.794 GHz (trm=0) ... f_slow=0.449 GHz (trm=31)
  f(trm) = f_fast - (trm/31) * (f_fast - f_slow)

Timescale: 1ps/1ps  (set in tb_ring_osc.sv / rochip.sv)
"""

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, First
import cocotb.utils


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

def expected_freq_hz(divby2_sel: int, trm: int) -> float:
    """Return the expected ring-osc frequency in Hz per the rochip model."""
    if divby2_sel == 0:
        f_fast, f_slow = 1.608e9, 0.899e9
    else:
        f_fast, f_slow = 0.794e9, 0.449e9
    a = trm / 31.0
    return f_fast - a * (f_fast - f_slow)


async def _init(dut):
    """Drive all inputs to safe defaults and wait briefly."""
    dut.trm.value         = 0
    dut.divby2_sel.value  = 0
    dut.en.value          = 0
    dut.dbg_en.value      = 0
    dut.dbg_anachip_en.value = 0
    dut.dbg_rohcip_en.value  = 0
    dut.dbg_sah_en_b.value   = 0
    await Timer(10, 'ns')


async def measure_period_ps(dut, n_cycles: int = 20) -> float:
    """Return the average clock period in picoseconds over n_cycles rising edges."""
    # Align to the next rising edge first so we start clean
    await RisingEdge(dut.clk)
    t_start = cocotb.utils.get_sim_time('ps')
    for _ in range(n_cycles):
        await RisingEdge(dut.clk)
    t_end = cocotb.utils.get_sim_time('ps')
    return (t_end - t_start) / n_cycles


# --------------------------------------------------------------------------- #
# Tests
# --------------------------------------------------------------------------- #

@cocotb.test(timeout_time=10_000, timeout_unit='ns')
async def test_enable_disable(dut):
    """Enable the ring osc, confirm clk toggles; disable, confirm clk stops."""
    await _init(dut)

    # ---- enable ----
    dut.en.value = 1
    cocotb.log.info("Enabled ring_osc, waiting for rising edges...")

    # Expect at least 5 rising edges within the timeout
    for i in range(5):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"  Rising edge {i + 1} detected")

    # ---- disable ----
    dut.en.value = 0
    # Give one full (slowest possible) period for the osc to stop:
    #   at f_slow = 0.449 GHz -> T ~ 2.23 ns -> 5 ns is plenty
    await Timer(5, 'ns')

    assert dut.clk.value == 0, (
        f"Expected clk=0 after disable, got clk={dut.clk.value}"
    )
    cocotb.log.info("test_enable_disable PASSED")


@cocotb.test(timeout_time=50_000, timeout_unit='ns')
async def test_frequency_vs_trm(dut):
    """Measure clock frequency for several trm values and compare to the model."""
    await _init(dut)
    dut.en.value = 1

    # Wait for oscillation to start
    await RisingEdge(dut.clk)

    TOLERANCE = 0.06        # 6% - allows for PRNG duty-cycle jitter
    TRM_POINTS = [0, 8, 16, 24, 31]
    N_CYCLES   = 20         # average over this many cycles

    for trm in TRM_POINTS:
        dut.trm.value = trm
        # Let the model settle after a trm change
        await Timer(10, 'ns')

        period_ps    = await measure_period_ps(dut, N_CYCLES)
        meas_freq_hz = 1e12 / period_ps
        exp_freq_hz  = expected_freq_hz(dut.divby2_sel.value.integer, trm)
        err          = abs(meas_freq_hz - exp_freq_hz) / exp_freq_hz

        cocotb.log.info(
            f"trm={trm:2d}: measured={meas_freq_hz / 1e6:8.2f} MHz, "
            f"expected={exp_freq_hz / 1e6:8.2f} MHz, err={err * 100:.2f}%"
        )
        assert err < TOLERANCE, (
            f"trm={trm}: frequency error {err * 100:.2f}% exceeds {TOLERANCE * 100:.0f}%"
        )

    dut.en.value = 0
    cocotb.log.info("test_frequency_vs_trm PASSED")


@cocotb.test(timeout_time=50_000, timeout_unit='ns')
async def test_divby2(dut):
    """Verify that asserting divby2_sel roughly halves the frequency."""
    await _init(dut)
    dut.trm.value = 15      # mid-range trim - avoids edge cases

    # --- Measure at divby2_sel=0 ---
    dut.divby2_sel.value = 0
    dut.en.value = 1
    await RisingEdge(dut.clk)
    period_full_ps = await measure_period_ps(dut, 20)
    freq_full = 1e12 / period_full_ps

    # --- Measure at divby2_sel=1 ---
    dut.divby2_sel.value = 1
    await Timer(10, 'ns')
    period_div2_ps = await measure_period_ps(dut, 20)
    freq_div2 = 1e12 / period_div2_ps

    ratio = freq_full / freq_div2
    cocotb.log.info(
        f"divby2_sel=0: {freq_full / 1e6:.2f} MHz, "
        f"divby2_sel=1: {freq_div2 / 1e6:.2f} MHz, "
        f"ratio={ratio:.3f} (expected ~{1.608e9 / 0.794e9:.3f})"
    )

    # The divby2 ratio is not exactly 2.0 - it is the ratio of the two VCO
    # corners (~2.02 at trm=0, ~2.00 at trm=31).  Allow 10% tolerance.
    assert 1.8 < ratio < 2.2, (
        f"Unexpected divby2 frequency ratio: {ratio:.3f} (expected ~2.0)"
    )

    dut.en.value = 0
    cocotb.log.info("test_divby2 PASSED")


@cocotb.test(timeout_time=10_000, timeout_unit='ns')
async def test_debug_mode(dut):
    """Test dbg_en override: independently enable/disable anachip and rohcip."""
    await _init(dut)
    dut.dbg_en.value = 1

    # ---- Both enables asserted via debug -> clk should oscillate ----
    dut.dbg_anachip_en.value = 1
    dut.dbg_rohcip_en.value  = 1
    dut.dbg_sah_en_b.value   = 0   # Normal SAH mode (anachip mode={1,0,0})

    cocotb.log.info("debug mode: both enables high -> expect oscillation")
    for i in range(5):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"  Debug rising edge {i + 1}")

    # ---- Disable rohcip only -> clk should stop ----
    dut.dbg_rohcip_en.value = 0
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"Expected clk=0 when rohcip disabled via debug, got clk={dut.clk.value}"
    )
    cocotb.log.info("debug mode: rohcip disabled -> clk=0 [OK]")

    # ---- Re-enable rohcip, disable anachip -> h1_mnvdd09_g=0 -> clk should stop ----
    dut.dbg_rohcip_en.value  = 1
    dut.dbg_anachip_en.value = 0
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"Expected clk=0 when anachip disabled via debug, got clk={dut.clk.value}"
    )
    cocotb.log.info("debug mode: anachip disabled -> h1=0 -> clk=0 [OK]")

    cocotb.log.info("test_debug_mode PASSED")


@cocotb.test(timeout_time=10_000, timeout_unit='ns')
async def test_debug_invalid_states(dut):
    """
    Exhaustively test invalid / edge-case debug-enable combinations and
    dbg_en transition behaviour.

    anachip valid modes: mode = {anachip_en, anachip_en_b, sah_en_b}
      010 -> h1=0 (power-down, sah_en_b=0)
      011 -> h1=0 (power-down, sah_en_b=1)
      100 -> h1=1 (normal SAH,  sah_en_b=0)
      101 -> h1=1 (test mode,   sah_en_b=1)
    ring_osc always drives anachip_en_b = ~anachip_en, so the anachip
    default/X case is unreachable from the RTL -- what we CAN hit are the
    four asymmetric debug-enable combinations that leave one chip in a
    conflicting power state.
    """
    # ------------------------------------------------------------------ #
    # 1. Both debug enables low while already in debug mode -> clk=0
    # ------------------------------------------------------------------ #
    await _init(dut)
    dut.dbg_en.value         = 1
    dut.dbg_anachip_en.value = 0   # anachip powered down  -> h1=0
    dut.dbg_rohcip_en.value  = 0   # rohcip  disabled
    dut.dbg_sah_en_b.value   = 0
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"[1] Both enables low: expected clk=0, got {dut.clk.value}"
    )
    cocotb.log.info("[1] both enables low: clk=0 [OK]")

    # ------------------------------------------------------------------ #
    # 2. Anachip ON, rohcip OFF -> h1=1 but rohcip never toggles -> clk=0
    # ------------------------------------------------------------------ #
    dut.dbg_anachip_en.value = 1
    dut.dbg_rohcip_en.value  = 0
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"[2] Anachip on / rohcip off: expected clk=0, got {dut.clk.value}"
    )
    cocotb.log.info("[2] anachip on, rohcip off (h1=1 but rochip disabled): clk=0 [OK]")

    # ------------------------------------------------------------------ #
    # 3. Anachip OFF, rohcip ON -> h1=0 gates rochip even though en=1 -> clk=0
    # ------------------------------------------------------------------ #
    dut.dbg_anachip_en.value = 0
    dut.dbg_rohcip_en.value  = 1
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"[3] Anachip off / rohcip on: expected clk=0 (h1=0 gates rochip), got {dut.clk.value}"
    )
    cocotb.log.info("[3] anachip off (h1=0), rohcip on: clk=0 [OK]")

    # ------------------------------------------------------------------ #
    # 4. dbg_sah_en_b=1 (test-mode operation): h1 must still be 1 -> oscillates
    # ------------------------------------------------------------------ #
    dut.dbg_anachip_en.value = 1
    dut.dbg_rohcip_en.value  = 1
    dut.dbg_sah_en_b.value   = 1   # anachip mode={1,0,1}=0b101 -> h1=1 (test mode)
    for i in range(5):
        await RisingEdge(dut.clk)
    cocotb.log.info("[4] sah_en_b=1 (test-mode op): oscillating [OK]")

    # Back to sah_en_b=0 before next steps
    dut.dbg_sah_en_b.value = 0

    # ------------------------------------------------------------------ #
    # 5. Enter debug mode MID-OSCILLATION with enables LOW -> clock stops
    #    at the dbg_en rising edge (debug enables were pre-set to 0).
    # ------------------------------------------------------------------ #
    await _init(dut)
    dut.en.value = 1                # start normal oscillation
    for _ in range(3):
        await RisingEdge(dut.clk)  # confirm it is running

    # Pre-arm debug enables low, then flip dbg_en
    dut.dbg_anachip_en.value = 0
    dut.dbg_rohcip_en.value  = 0
    dut.dbg_en.value         = 1   # hand control to debug with both enables=0
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"[5] dbg_en asserted mid-osc with enables low: expected clk=0, got {dut.clk.value}"
    )
    cocotb.log.info("[5] dbg_en asserted mid-oscillation with enables low: clk=0 [OK]")

    # ------------------------------------------------------------------ #
    # 6. Enter debug mode MID-OSCILLATION with enables HIGH -> clock keeps running
    # ------------------------------------------------------------------ #
    await _init(dut)
    dut.en.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)

    # Pre-arm debug enables high so the hand-off is seamless
    dut.dbg_anachip_en.value = 1
    dut.dbg_rohcip_en.value  = 1
    dut.dbg_sah_en_b.value   = 0
    dut.dbg_en.value         = 1
    for i in range(5):             # clock must keep running without a gap
        await RisingEdge(dut.clk)
    cocotb.log.info("[6] dbg_en asserted mid-oscillation with enables high: still running [OK]")

    # ------------------------------------------------------------------ #
    # 7. Exit debug mode back to normal with en=0 -> clock must stop
    # ------------------------------------------------------------------ #
    dut.en.value    = 0            # normal-mode enable is low
    dut.dbg_en.value = 0           # hand control back to normal mode
    await Timer(5, 'ns')
    assert dut.clk.value == 0, (
        f"[7] Exit debug with en=0: expected clk=0, got {dut.clk.value}"
    )
    cocotb.log.info("[7] exit debug (en=0): clk=0 [OK]")

    # ------------------------------------------------------------------ #
    # 8. Exit debug mode back to normal with en=1 -> clock must resume
    # ------------------------------------------------------------------ #
    await _init(dut)
    dut.dbg_anachip_en.value = 1
    dut.dbg_rohcip_en.value  = 1
    dut.dbg_en.value         = 1
    for _ in range(3):
        await RisingEdge(dut.clk)  # oscillating in debug

    dut.en.value     = 1           # arm normal enable before exiting debug
    dut.dbg_en.value = 0           # hand back to normal mode (en=1)
    for i in range(5):
        await RisingEdge(dut.clk)
    cocotb.log.info("[8] exit debug (en=1): clock resumes [OK]")

    cocotb.log.info("test_debug_invalid_states PASSED")
