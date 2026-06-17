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
cocotb testbench for tsense_wrap.

Single test covering:
  T1  — Reset values
  T2  — Sensor tri-state (all 4 sensors, global enable)
  T3  — Basic single conversion (sensor 0, clk_div=1)
  T4  — ADC timing (conv_b low during conv, high at drdy, drdy 1-cycle pulse)
  T5  — Conversion on each of the 4 sensors
  T6  — Reset mid-conversion, then recovery
  T7  — Clock divider: fast (div=0) and slow (div=7)
  T8  — Back-to-back conversions
  T9  — Conv with no sensor enabled (should never complete)
  T10 — Valid clears immediately on re-trigger
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer


# ------------------------------------------------------------------ #
# Helpers
# ------------------------------------------------------------------ #

SETTLE = Timer(1, "ps")   # let NBA resolve before reading signals


def set_label(dut, label: str):
    """Write an ASCII tag into the test_label reg for waveform annotation."""
    dut.test_label.value = int.from_bytes(label.encode("ascii"), "big")


async def check(dut, condition, msg):
    """Assert with a 10 ns grace period so the waveform captures context."""
    if not condition:
        cocotb.log.error(f"FAIL: {msg}")
        set_label(dut, "FAIL")
        await Timer(10, "ns")
        assert False, msg


async def reset_dut(dut):
    """Assert reset, hold, then release."""
    dut.rst_n.value = 0
    dut.conv.value = 0
    await ClockCycles(dut.sys_clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.sys_clk, 5)


async def trigger_conv(dut):
    """Pulse conv high for exactly one sys_clk cycle."""
    await RisingEdge(dut.sys_clk)
    dut.conv.value = 1
    await RisingEdge(dut.sys_clk)
    dut.conv.value = 0


async def wait_valid(dut, timeout_clks=1000):
    """Wait for valid=1, return True on success, False on timeout."""
    for _ in range(timeout_clks):
        await RisingEdge(dut.sys_clk)
        if dut.valid.value == 1:
            return True
    return False


# ------------------------------------------------------------------ #
# Main test
# ------------------------------------------------------------------ #

@cocotb.test(timeout_time=500_000, timeout_unit="ns")
async def test_tsense(dut):
    """Full tsense_wrap verification."""

    # -- startup -------------------------------------------------------
    set_label(dut, "INIT")
    dut.rst_n.value   = 0
    dut.conv.value    = 0
    dut.sen_sel.value = 0
    dut.clk_div.value = 1
    cocotb.start_soon(Clock(dut.sys_clk, 10, units="ns").start())

    # ==================================================================
    # T1 — Reset
    # ==================================================================
    set_label(dut, "T1_RESET")
    cocotb.log.info("T1: Reset")
    await reset_dut(dut)

    await check(dut, dut.data.value  == 0, f"data not 0 after reset: {dut.data.value}")
    await check(dut, dut.valid.value == 0, "valid not 0 after reset")
    cocotb.log.info("  PASS")

    # ==================================================================
    # T2 — Sensor tri-state
    # ==================================================================
    set_label(dut, "T2_ALL_OFF")
    cocotb.log.info("T2: Sensor tri-state")

    # All sensors off
    dut.sen_sel.value = 0b000
    await Timer(1, "ns")
    vctat_str = dut.u_wrap.hc_tsense_vctat.value.binstr.lower()
    vref_str  = dut.u_wrap.hc_tsense_vref.value.binstr.lower()
    await check(dut, "z" in vctat_str, f"vctat not z when all off: {vctat_str}")
    await check(dut, "z" in vref_str,  f"vref not z when all off: {vref_str}")

    # Each sensor individually
    for i in range(4):
        set_label(dut, f"T2_SEN{i}")
        dut.sen_sel.value = 0b100 | i        # enable + select i
        await Timer(1, "ns")
        await check(dut, dut.u_wrap.hc_tsense_vctat.value == 1,
                    f"vctat not 1 for sensor {i}")
        await check(dut, dut.u_wrap.hc_tsense_vref.value == 1,
                    f"vref not 1 for sensor {i}")
        cocotb.log.info(f"  sensor {i}: vctat=1, vref=1")

    # Disable again
    set_label(dut, "T2_OFF_AGAIN")
    dut.sen_sel.value = 0b000
    await Timer(1, "ns")
    await check(dut, "z" in dut.u_wrap.hc_tsense_vctat.value.binstr.lower(),
                "vctat not z after disable")
    cocotb.log.info("  PASS")

    # ==================================================================
    # T3 — Basic single conversion (sensor 0, clk_div=1)
    # ==================================================================
    set_label(dut, "T3_CONV")
    cocotb.log.info("T3: Basic conversion (sensor 0, clk_div=1)")
    dut.sen_sel.value = 0b100
    dut.clk_div.value = 1
    await ClockCycles(dut.sys_clk, 5)

    await trigger_conv(dut)
    await RisingEdge(dut.sys_clk)
    await SETTLE
    await check(dut, dut.valid.value == 0, "valid not cleared on conv trigger")

    ok = await wait_valid(dut)
    await check(dut, ok, "valid never asserted")
    cocotb.log.info(f"  data=0x{int(dut.data.value):x}  PASS")

    # ==================================================================
    # T4 — ADC timing (conv_b / drdy through the wrapper)
    # ==================================================================
    set_label(dut, "T4_TIMING")
    cocotb.log.info("T4: ADC timing")

    await trigger_conv(dut)

    # Wait for conv_b to fall (conversion starts)
    set_label(dut, "T4_WAIT_CONVB")
    await FallingEdge(dut.u_wrap.adc_conv_b)
    await SETTLE
    set_label(dut, "T4_CONV_ACTIVE")

    # conv_b must stay low during conversion (check a few adc_clk cycles)
    for _ in range(3):
        await RisingEdge(dut.u_wrap.adc_clk)
        await SETTLE
        await check(dut, dut.u_wrap.adc_conv_b.value == 0,
                    "conv_b went high during conversion")

    # Wait for drdy pulse
    await RisingEdge(dut.u_wrap.adc_drdy)
    await SETTLE
    set_label(dut, "T4_DRDY_HI")
    await check(dut, dut.u_wrap.adc_conv_b.value == 1,
                "conv_b not high when drdy asserted")
    cocotb.log.info("  conv_b high when drdy high — OK")

    # drdy should be high for exactly 1 adc_clk, then fall
    await RisingEdge(dut.u_wrap.adc_clk)
    await SETTLE
    set_label(dut, "T4_DRDY_LO")
    # Note: wrapper may have already cleared adc_en here, so the ADC
    # may have reset rather than entering GAP.  Either way drdy is low.
    await check(dut, dut.u_wrap.adc_drdy.value == 0,
                "drdy still high after 1 adc_clk")
    cocotb.log.info("  drdy pulse width = 1 adc_clk — OK")

    ok = await wait_valid(dut)
    await check(dut, ok, "valid never asserted after timing check")
    cocotb.log.info(f"  data=0x{int(dut.data.value):x}  PASS")

    # ==================================================================
    # T5 — Conversion on each of the 4 sensors
    # ==================================================================
    cocotb.log.info("T5: Conversion per sensor")
    for i in range(4):
        set_label(dut, f"T5_SEN{i}")
        dut.sen_sel.value = 0b100 | i
        await ClockCycles(dut.sys_clk, 5)
        await trigger_conv(dut)
        ok = await wait_valid(dut)
        await check(dut, ok, f"sensor {i}: valid never asserted")
        cocotb.log.info(
            f"  sensor {i}: data=0x{int(dut.data.value):x}")
    cocotb.log.info("  PASS")

    # ==================================================================
    # T6 — Reset mid-conversion
    # ==================================================================
    set_label(dut, "T6_MID_RST")
    cocotb.log.info("T6: Reset mid-conversion")
    dut.sen_sel.value = 0b100
    dut.clk_div.value = 1
    await ClockCycles(dut.sys_clk, 5)

    await trigger_conv(dut)
    await ClockCycles(dut.sys_clk, 10)   # let conversion start

    dut.rst_n.value = 0                   # assert reset
    await ClockCycles(dut.sys_clk, 3)
    await SETTLE
    await check(dut, dut.valid.value == 0, "valid not 0 during reset")
    await check(dut, dut.data.value  == 0, "data not 0 during reset")

    dut.rst_n.value = 1                   # release
    await ClockCycles(dut.sys_clk, 5)
    await SETTLE
    await check(dut, dut.valid.value == 0, "valid not 0 after reset release")

    # Recovery conversion
    set_label(dut, "T6_RECOVER")
    await trigger_conv(dut)
    ok = await wait_valid(dut)
    await check(dut, ok, "valid never asserted after recovery")
    cocotb.log.info(
        f"  recovery data=0x{int(dut.data.value):x}  PASS")

    # ==================================================================
    # T7 — Clock divider: fast and slow
    # ==================================================================
    cocotb.log.info("T7: Clock divider variations")
    dut.sen_sel.value = 0b100

    set_label(dut, "T7_DIV0")
    dut.clk_div.value = 0                 # adc_clk = sys_clk / 2
    await ClockCycles(dut.sys_clk, 5)
    await trigger_conv(dut)
    ok = await wait_valid(dut)
    await check(dut, ok, "clk_div=0: valid never asserted")
    cocotb.log.info(
        f"  clk_div=0 (fast): data=0x{int(dut.data.value):x}")

    set_label(dut, "T7_DIV7")
    dut.clk_div.value = 7                 # adc_clk = sys_clk / 16
    await ClockCycles(dut.sys_clk, 5)
    await trigger_conv(dut)
    ok = await wait_valid(dut)
    await check(dut, ok, "clk_div=7: valid never asserted")
    cocotb.log.info(
        f"  clk_div=7 (slow): data=0x{int(dut.data.value):x}")
    cocotb.log.info("  PASS")

    # ==================================================================
    # T8 — Back-to-back conversions
    # ==================================================================
    set_label(dut, "T8_B2B")
    cocotb.log.info("T8: Back-to-back conversions")
    dut.clk_div.value = 1
    await ClockCycles(dut.sys_clk, 5)

    for i in range(4):
        await trigger_conv(dut)
        ok = await wait_valid(dut)
        await check(dut, ok, f"back-to-back iter {i}: valid never asserted")
        cocotb.log.info(
            f"  iter {i}: data=0x{int(dut.data.value):x}")
    cocotb.log.info("  PASS")

    # ==================================================================
    # T9 — Conv with no sensor enabled (should never complete)
    # ==================================================================
    set_label(dut, "T9_NO_SEN")
    cocotb.log.info("T9: Conv with no sensor enabled")
    dut.sen_sel.value = 0b000
    await ClockCycles(dut.sys_clk, 5)

    await trigger_conv(dut)
    ok = await wait_valid(dut, timeout_clks=200)
    await check(dut, not ok, "valid should not assert with no sensor")
    cocotb.log.info("  PASS (timed out as expected)")

    # Clean up: reset so adc_en is cleared
    await reset_dut(dut)

    # ==================================================================
    # T10 — Valid clears on re-trigger
    # ==================================================================
    set_label(dut, "T10_VCLR")
    cocotb.log.info("T10: Valid clears on re-trigger")
    dut.sen_sel.value = 0b100
    dut.clk_div.value = 1
    await ClockCycles(dut.sys_clk, 5)

    # First conversion
    await trigger_conv(dut)
    ok = await wait_valid(dut)
    await check(dut, ok, "first conv: valid never asserted")
    await check(dut, dut.valid.value == 1, "valid not 1 before re-trigger")

    # Re-trigger — valid must clear
    set_label(dut, "T10_RETRIG")
    await trigger_conv(dut)
    await RisingEdge(dut.sys_clk)
    await SETTLE
    await check(dut, dut.valid.value == 0, "valid not cleared on re-trigger")

    ok = await wait_valid(dut)
    await check(dut, ok, "re-trigger: valid never asserted")
    cocotb.log.info(
        f"  data=0x{int(dut.data.value):x}  PASS")

    # ==================================================================
    # Done
    # ==================================================================
    set_label(dut, "DONE")
    await ClockCycles(dut.sys_clk, 10)
    cocotb.log.info("=== ALL TESTS PASSED ===")
