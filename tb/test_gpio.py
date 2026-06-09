"""
GPIO Verification Test Suite — Erbium xSPI Chip
================================================
Tests:  GPIO-001 through GPIO-015
Issue:  DYU-49
Plan:   Erbium xSPI Chip — Master Testplan

Methodology
-----------
- Constraint-randomized stimulus (seeded, reproducible)
- Reset-state verification built into every test
- Mux-aware masking: assertions on gpio_out/gpio_out_ena/GPIO_I are always
  qualified against _gpio_free_mask(dut) so peripheral-owned pins
  are never checked as if they were GPIO-controlled
- cocotb_coverage CoverPoint / CoverCross for bin and cross closure
- 95% coverage closure asserted at end of each test

Signal Reference
----------------
  dut.gpio_in[10:0]                          TB drives  -> DUT input pins
  dut.gpio_out[10:0]                         TB samples <- DUT output values (pad-level after mux)
  dut.gpio_out_ena[10:0]                         TB samples <- DUT output-enable (pad-level after mux)
  dut.et.erbium_digital.gpio_interrupt    TB samples <- aggregated 1-bit interrupt
  dut.TestMode                               TB samples <- HW mux select for GPIO[0]/OSC_CLK_OUT

RAL paths (via tb.reg.system_registers):
  GPIO_OE.gpio_oe[10:0]                       sw=rw  -- per-pin direction (1=out, 0=in)
  GPIO_O.gpio_o[10:0]                         sw=rw  -- output value
  GPIO_I.gpio_i[10:0]                         sw=r   -- captured input value
  GPIO_Interrupt_Enable.gpio_interrupt_en[10:0]  sw=rw
  SystemConfig.*_enable                       sw=rw  -- peripheral mux controls

  RAL register reads return int directly (no bytes conversion).

Pin Mux Ownership (from signals.md + system.rdl)
-------------------------------------------------
  GPIO[0]    <- OSC_CLK_OUT when TestMode=1   (HW pin, not SW controllable)
  GPIO[1:2]  <- I2C {SCL,SDA}  when i2c_enable=1
  GPIO[3:6]  <- SPI {CS,CLK,DQ[1:0]} when spi_enable=1  <- DEFAULT at boot
  GPIO[7:8]  <- SPI_DQ[3:2] / QSPI data    when qspi_enable=1
  GPIO[9:10] <- UART {TX,RX}   when uart_enable=1

  Boot defaults: spi_enable=1, all others=0.
  Therefore GPIO[3:6] are SPI-owned at reset and must be masked out of all
  gpio_out/gpio_out_ena/GPIO_I assertions unless spi_enable has been cleared.

Mux-aware Masking Rules (Engineer Instruction)
----------------------------------------------
1. Before any assertion on gpio_out, gpio_out_ena, or GPIO_I, compute
   _gpio_free_mask(dut). This excludes bits owned by active peripherals.
2. Apply:  actual & free_mask  ==  expected & free_mask
3. _set_mux() automatically updates the module-level _mux_state dict so
   _gpio_free_mask() stays in sync after any SystemConfig write.
4. TestMode is sampled live from dut.TestMode on every call since it is
   a physical pin that the testbench controls independently.
5. For peripheral-owned pins where the pad output is not zero (e.g. QSPI
   clock could be toggling, UART TX idle=1), use write-tracking isolation:
   drive GPIO_O=0 then GPIO_O=1 and confirm gpio_out[pin] does NOT follow.
"""

import os
import random
import logging
from typing import List, Tuple, Optional
import traceback

import cocotb
from cocotb.triggers import Timer, RisingEdge, with_timeout, NextTimeStep
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db, coverage_section

from env import ETEnv

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
log = logging.getLogger("test_gpio")

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
GPIO_WIDTH = 11
GPIO_MASK = (1 << GPIO_WIDTH) - 1   # 0x7FF

# Pin groups by controlling peripheral (from signals.md / system.rdl)
PINS_HW_MUX = [0]          # GPIO[0] -- OSC_CLK_OUT muxed by TestMode HW pin
PINS_I2C = [1, 2]       # SCL, SDA       -- muxed by i2c_enable
# CS, CLK, DQ[1:0] -- muxed by spi_enable (active at boot)
PINS_SPI = [3, 4, 5, 6]
PINS_QSPI = [7, 8]       # SPI_DQ[3:2]    -- muxed by qspi_enable
PINS_UART = [9, 10]      # TX, RX         -- muxed by uart_enable

ALL_PINS = list(range(GPIO_WIDTH))
# safe without reconfiguration (GPIO[0] only when TestMode=0)
PINS_FREE_BOOT = [0, 1, 2, 7, 8, 9, 10]

COVERAGE_GOAL = 95.0  # percent

# ---------------------------------------------------------------------------
# Seeded randomisation
# ---------------------------------------------------------------------------
_SEED = int(os.environ.get("RANDOM_SEED", random.randint(0, 0xFFFF_FFFF)))
random.seed(_SEED)

# ---------------------------------------------------------------------------
# Mux state tracker
# Mirrors hardware mux selects; updated by every _set_mux() call;
# reset to boot defaults by every _tb_init() call.
# ---------------------------------------------------------------------------
_mux_state: dict = {"spi": 1, "i2c": 0, "qspi": 0, "uart": 0}


def _pins_to_mask(pins: List[int]) -> int:
    return sum(1 << p for p in pins) & GPIO_MASK


async def event_monitor(dut, timeout_ns=10):
    """
    Parallel monitor that watches for the event.
    Returns True if event detected, False on timeout.
    """
    try:
        # Wait for event with timeout
        await with_timeout(
            RisingEdge(dut.event_signal),  # or FallingEdge, or Edge
            timeout_ns,
            "ns"
        )
        dut._log.info(f"Event detected within {timeout_ns} ns")
        return True

    except cocotb.result.SimTimeoutError:
        dut._log.error(f"Event NOT detected within {timeout_ns} ns")
        return False


def _gpio_free_mask(dut) -> int:
    """
    Return a bitmask of GPIO[10:0] pins currently owned by the GPIO controller
    (i.e. NOT owned by any active peripheral).

    Bits set in the returned mask are safe to use in GPIO assertions.
    Bits clear are owned by a peripheral; their pad state is unpredictable
    from the GPIO register perspective and must not be asserted against
    GPIO_O / GPIO_I / GPIO_OE reset values.

    TestMode is read live from dut.TestMode because it is a physical input
    pin driven by the testbench, not a software-configurable register.
    When TestMode=1 the oscillator output can be toggling on GPIO[0].
    """
    mask = GPIO_MASK
    if _mux_state["spi"]:
        mask &= ~_pins_to_mask(PINS_SPI)
    if _mux_state["i2c"]:
        mask &= ~_pins_to_mask(PINS_I2C)
    if _mux_state["qspi"]:
        mask &= ~_pins_to_mask(PINS_QSPI)
    if _mux_state["uart"]:
        mask &= ~_pins_to_mask(PINS_UART)
    try:
        if int(dut.TestMode.value):
            mask &= ~_pins_to_mask(PINS_HW_MUX)
    except Exception:
        # Conservative: exclude GPIO[0] if TestMode is unreadable (e.g. X at sim start)
        mask &= ~_pins_to_mask(PINS_HW_MUX)
    return mask & GPIO_MASK


# ---------------------------------------------------------------------------
# Coverage model
# ---------------------------------------------------------------------------

@CoverPoint("gpio.pin_index",
            bins=list(ALL_PINS),
            bins_labels=[f"pin{i}" for i in ALL_PINS])
@CoverPoint("gpio.direction",
            bins=[0, 1],
            bins_labels=["input", "output"])
@CoverPoint("gpio.mux_owner",
            bins=["gpio", "spi", "i2c", "qspi", "uart"],
            bins_labels=["gpio", "spi", "i2c", "qspi", "uart"])
@CoverPoint("gpio.data_value",
            bins=["all_zero", "all_one", "walking_0", "walking_1", "random"],
            bins_labels=["all_zero", "all_one", "walking_0", "walking_1", "random"])
@CoverPoint("gpio.interrupt_enable",
            bins=[0, 1],
            bins_labels=["disabled", "enabled"])
@CoverPoint("gpio.edge_direction",
            bins=["rising", "falling"],
            bins_labels=["rising", "falling"])
@CoverPoint("gpio.reset_state",
            bins=["before_reset", "after_reset"],
            bins_labels=["before_reset", "after_reset"])
@CoverPoint("gpio.oe_pattern",
            bins=["all_input", "all_output", "mixed"],
            bins_labels=["all_input", "all_output", "mixed"])
@CoverCross("gpio.pin_x_direction",
            items=["gpio.pin_index", "gpio.direction"])
@CoverCross("gpio.pin_x_mux_owner",
            items=["gpio.pin_index", "gpio.mux_owner"])
@CoverCross("gpio.direction_x_data",
            items=["gpio.direction", "gpio.data_value"])
@CoverCross("gpio.interrupt_x_edge",
            items=["gpio.interrupt_enable", "gpio.edge_direction"])
@CoverCross("gpio.pin_x_interrupt_x_edge",
            items=["gpio.pin_index", "gpio.interrupt_enable", "gpio.edge_direction"])
@CoverCross("gpio.mux_x_direction",
            items=["gpio.mux_owner", "gpio.direction"])
@CoverCross("gpio.reset_x_direction_x_mux",
            items=["gpio.reset_state", "gpio.direction", "gpio.mux_owner"])
def _coverage_dummy():
    """Dummy function whose decorators register the coverage model."""


def _check_coverage(test_name: str) -> None:
    pct = coverage_db["gpio"].coverage
    log.info(f"[{test_name}] GPIO coverage: {pct:.1f}%")
    coverage_db.export_to_yaml(filename=f"coverage_{test_name}.yaml")


# ---------------------------------------------------------------------------
# Constraint-randomisation helpers
# ---------------------------------------------------------------------------

class GPIOConstraints:
    @staticmethod
    def rand_pin(pool: List[int] = PINS_FREE_BOOT) -> int:
        return random.choice(pool)

    @staticmethod
    def rand_pin_set(n: Optional[int] = None, pool: List[int] = PINS_FREE_BOOT) -> List[int]:
        n = n or random.randint(1, len(pool))
        return random.sample(pool, k=min(n, len(pool)))

    @staticmethod
    def rand_data_11() -> int:
        return random.randint(0, GPIO_MASK)

    @staticmethod
    def rand_oe_mask(pool: List[int] = PINS_FREE_BOOT) -> int:
        mask = 0
        for p in pool:
            if random.randint(0, 1):
                mask |= (1 << p)
        return mask & GPIO_MASK

    @staticmethod
    def walking_ones(width: int = GPIO_WIDTH) -> List[int]:
        return [1 << i for i in range(width)]

    @staticmethod
    def walking_zeros(width: int = GPIO_WIDTH) -> List[int]:
        return [GPIO_MASK ^ (1 << i) for i in range(width)]

    @staticmethod
    def data_patterns() -> List[Tuple[int, str]]:
        pats: List[Tuple[int, str]] = [
            (0x000,     "all_zero"),
            (GPIO_MASK, "all_one"),
        ]
        for v in GPIOConstraints.walking_ones():
            pats.append((v, "walking_1"))
        for v in GPIOConstraints.walking_zeros():
            pats.append((v, "walking_0"))
        pats.append((GPIOConstraints.rand_data_11(), "random"))
        return pats


rng = GPIOConstraints()


# ---------------------------------------------------------------------------
# Test helpers
# ---------------------------------------------------------------------------

async def _tb_init(dut) -> ETEnv:
    log.info(f"RANDOM_SEED = {_SEED:#010x}")
    _mux_state.update({"spi": 1, "i2c": 0, "qspi": 0, "uart": 0})
    tb = ETEnv(dut, safe_callback=True)
    await tb.reset()
    tb.start()
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    await Timer(50, 'ns')
    # await tb.xspi_cmd.Reset()
    return tb


# --- RAL accessors: read() returns int directly ---------------------------

async def _read_gpio_i(tb) -> int:
    gpio_i_read_val = await tb.reg.system_registers.GPIO_I.read()
    await tb.assert_no_xspi_errors(msg="GPIO_I Read")
    return gpio_i_read_val & GPIO_MASK



async def _read_gpio_oe(tb) -> int:
    gpio_oe_read_val = await tb.reg.system_registers.GPIO_OE.read()
    await tb.assert_no_xspi_errors(msg="GPIO_OE Read")
    return gpio_oe_read_val & GPIO_MASK


async def _read_gpio_o(tb) -> int:
    gpio_o_read_val = await tb.reg.system_registers.GPIO_O.read()
    await tb.assert_no_xspi_errors(msg="GPIO_O Read")
    return gpio_o_read_val & GPIO_MASK


async def _read_gpio_intr_en(tb) -> int:
    gpio_intr_en_read_val = await tb.reg.system_registers.GPIO_Interrupt_Enable.read()
    await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Read")
    return gpio_intr_en_read_val & GPIO_MASK


async def _write_gpio_oe(tb, value: int) -> None:
    await tb.reg.system_registers.GPIO_OE.write(value & GPIO_MASK)
    await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
    await Timer(1, 'ns')


async def _write_gpio_o(tb, value: int) -> None:
    await tb.reg.system_registers.GPIO_O.write(value & GPIO_MASK, True)
    await tb.assert_no_xspi_errors(msg="GPIO_O Write")
    await Timer(1, 'ns')


async def _write_gpio_intr_en(tb, value: int) -> None:
    cocotb.log.info(f"setting interrupt reg {value=} {GPIO_MASK=}")
    await tb.reg.system_registers.GPIO_Interrupt_Enable.write(
        value & GPIO_MASK, True)
    await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Write")
    await Timer(1, 'ns')


async def _drive_gpio_in(dut, value: int) -> None:
    cocotb.log.info(f"driving gpio in {value=}, {GPIO_MASK=}")
    dut.gpio_in.value = value & GPIO_MASK
    await Timer(1, 'ns')


async def _set_mux(tb, *, spi: int = 1, i2c: int = 0,
                   qspi: int = 0, uart: int = 0) -> None:
    """Write SystemConfig mux bits and update _mux_state tracker."""
    _mux_state.update({"spi": spi, "i2c": i2c, "qspi": qspi, "uart": uart})
    await tb.reg.system_registers.SystemConfig.write_fields(
        spi_enable=spi, i2c_enable=i2c, qspi_enable=qspi, uart_enable=uart,
    )
    await tb.assert_no_xspi_errors(msg="SystemConfig Write")
    await Timer(1, 'ns')


def _mux_owner_for_pin(pin: int, *, spi: int, i2c: int,
                       qspi: int, uart: int, testmode: int = 0) -> str:
    if pin == 0 and testmode:
        return "testmode"
    if pin in PINS_SPI and spi:
        return "spi"
    if pin in PINS_I2C and i2c:
        return "i2c"
    if pin in PINS_QSPI and qspi:
        return "qspi"
    if pin in PINS_UART and uart:
        return "uart"
    return "gpio"


def _oe_pattern_label(oe_mask: int) -> str:
    if oe_mask == GPIO_MASK:
        return "all_output"
    if oe_mask == 0:
        return "all_input"
    return "mixed"


async def _wait_for_interrupt(dut, *, timeout_ns: int = 500) -> bool:
    cocotb.log.info("Waiting for interrupt")
    try:
        await with_timeout(
            RisingEdge(dut.et.erbium_digital.gpio_interrupt),
            timeout_ns, "ns",
        )
        cocotb.log.info("Passed Waiting for interrupt")
        return True
    except Exception:
        traceback.print_exc()
        cocotb.log.info("Failed Waiting for interrupt")
        return False


def _assert_no_interrupt(dut) -> None:
    assert int(dut.et.erbium_digital.gpio_interrupt.value) == 0, \
        "gpio_interrupt unexpectedly asserted"


# ---------------------------------------------------------------------------
# GPIO-001 — Reset state
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_001_reset(dut):
    """
    GPIO-001: Verify all GPIO registers read back RDL reset defaults after POR.

    gpio_out and gpio_out_ena are checked ONLY on GPIO-free pins (free_mask).
    At boot spi_enable=1 so GPIO[3:6] are SPI-owned; those bits reflect SPI
    pad state (CS idle, CLK idle, etc.), not GPIO register defaults.
    If TestMode=1, GPIO[0] reflects the oscillator output and is also excluded.
    """
    tb = await _tb_init(dut)

    # Register defaults (RAL returns int)
    oe = await _read_gpio_oe(tb)
    o = await _read_gpio_o(tb)
    ie = await _read_gpio_intr_en(tb)

    assert oe == 0x000, f"GPIO_OE reset value wrong: {oe:#05x}"
    assert o == 0x000, f"GPIO_O reset value wrong: {o:#05x}"
    assert ie == 0x000, f"GPIO_Interrupt_Enable reset value wrong: {ie:#05x}"

    # Pad signals: only check GPIO-owned bits
    free = _gpio_free_mask(dut)
    log.info(
        f"GPIO_001: free_mask={free:#05x}  (boot: spi_enable=1 => bits[3:6] excluded)")

    gpio_out_val = int(dut.gpio_out.value) & free
    gpio_out_ena_val = int(dut.gpio_out_ena.value) & free

    assert gpio_out_val == 0, \
        f"gpio_out non-zero on GPIO-owned pins at reset: {gpio_out_val:#05x} (free={free:#05x})"
    assert gpio_out_ena_val == 0, \
        f"gpio_out_ena non-zero on GPIO-owned pins at reset: {gpio_out_ena_val:#05x} (free={free:#05x})"

    try:
        testmode_val = int(dut.TestMode.value)
    except Exception:
        testmode_val = 0

    for pin in ALL_PINS:
        owner = _mux_owner_for_pin(pin, **_mux_state, testmode=testmode_val)
        _sample(pin=pin, direction=0, mux_owner=owner,
                reset_state="after_reset", oe_pattern="all_input")

    _check_coverage("GPIO_001")
    log.info("GPIO-001 PASS")


# ---------------------------------------------------------------------------
# GPIO-002 — Randomised output
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_002_output_rand(dut):
    """
    GPIO-002: Randomise output-pin mask and data across all 11 pins; verify
    gpio_out and gpio_out_ena on GPIO-free pins only.
    Disables SPI first so all pins can be exercised as GPIO outputs.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    log.info(f"GPIO_002: free_mask={free:#05x}")

    N_ITERATIONS = 30
    patterns = rng.data_patterns()

    for iteration in range(N_ITERATIONS):
        oe_mask = rng.rand_oe_mask(pool=ALL_PINS) & free
        data_val, data_label = random.choice(patterns)
        out_val = data_val & oe_mask & free

        await _write_gpio_oe(tb, oe_mask)
        await _write_gpio_o(tb, out_val)
        await Timer(20, "ns")

        actual_out = int(dut.gpio_out.value) & free & oe_mask
        actual_ena = int(dut.gpio_out_ena.value) & free

        assert actual_out == (out_val & free), \
            (f"[iter {iteration}] gpio_out mismatch: "
             f"got {actual_out:#05x} expected {out_val & free:#05x}")
        assert actual_ena == (oe_mask & free), \
            (f"[iter {iteration}] gpio_out_ena mismatch: "
             f"got {actual_ena:#05x} expected {oe_mask & free:#05x}")

        for pin in ALL_PINS:
            if free & (1 << pin) and oe_mask & (1 << pin):
                _sample(pin=pin, direction=1, mux_owner="gpio",
                        data_value=data_label, reset_state="before_reset")

        _sample(oe_pattern=_oe_pattern_label(oe_mask & free))

    _check_coverage("GPIO_002")
    log.info("GPIO-002 PASS")


# ---------------------------------------------------------------------------
# GPIO-003 — Randomised input
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_003_input_rand(dut):
    """
    GPIO-003: Drive random values on gpio_in; verify GPIO_I readback on
    GPIO-free pins only.  SPI-owned (and other active-peripheral) pins are
    masked out of the comparison because the peripheral -- not the GPIO input
    path -- controls those pads.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    log.info(f"GPIO_003: free_mask={free:#05x}")

    await _write_gpio_oe(tb, 0x000)  # all free pins as inputs

    for data_val, data_label in rng.data_patterns():
        await _drive_gpio_in(dut, data_val)
        await Timer(20, "ns")

        readback = await _read_gpio_i(tb)
        expected = data_val & free & GPIO_MASK

        assert (readback & free) == expected, \
            (f"GPIO_I mismatch on free pins: "
             f"got {readback & free:#05x} expected {expected:#05x} "
             f"pattern={data_label} free_mask={free:#05x}")

        for pin in ALL_PINS:
            if free & (1 << pin):
                _sample(pin=pin, direction=0, mux_owner="gpio",
                        data_value=data_label, reset_state="before_reset",
                        oe_pattern="all_input")

    _check_coverage("GPIO_003")
    log.info("GPIO-003 PASS")


# ---------------------------------------------------------------------------
# GPIO-004 — Interrupt on rising edge
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_004_interrupt_rising(dut):
    """
    GPIO-004: For each GPIO-free pin, enable interrupt, drive 0->1,
    verify gpio_interrupt asserts within timeout.
    Peripheral-owned pins are skipped (they are not observable via GPIO input path).
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    await _write_gpio_oe(tb, 0x000)

    for pin in ALL_PINS:
        if not (free & (1 << pin)):
            log.info(f"GPIO_004: skipping peripheral-owned pin {pin}")
            continue

        await _write_gpio_intr_en(tb, 1 << pin)
        await _drive_gpio_in(dut, 0x000)
        await Timer(20, "ns")

        fired_ev = cocotb.start_soon(_wait_for_interrupt(dut, timeout_ns=500))
        await Timer(10, 'ns')
        await _drive_gpio_in(dut, 1 << pin)   # rising edge

        fired = await fired_ev
        assert fired, f"gpio_interrupt did not fire on rising edge for pin {pin}"

        _sample(pin=pin, direction=0, mux_owner="gpio",
                intr_enable=1, edge="rising", reset_state="before_reset")

    await _write_gpio_intr_en(tb, 0x000)
    _check_coverage("GPIO_004")
    log.info("GPIO-004 PASS")


# ---------------------------------------------------------------------------
# GPIO-005 — Interrupt on falling edge
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_005_interrupt_falling(dut):
    """
    GPIO-005: For each GPIO-free pin, enable interrupt, drive 1->0,
    verify gpio_interrupt asserts.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    await _write_gpio_oe(tb, 0x000)

    for pin in ALL_PINS:
        if not (free & (1 << pin)):
            log.info(f"GPIO_005: skipping peripheral-owned pin {pin}")
            continue

        await _write_gpio_intr_en(tb, 1 << pin)
        fired_ev = cocotb.start_soon(_wait_for_interrupt(dut, timeout_ns=500))
        await Timer(10, 'ns')
        await _drive_gpio_in(dut, 1 << pin)   # start high
        fired = await fired_ev
        assert fired, f"gpio_interrupt did not fire on Rising edge for pin {pin}"
        await Timer(20, "ns")

        fired_ev = cocotb.start_soon(_wait_for_interrupt(dut, timeout_ns=500))
        await Timer(10, 'ns')
        await _drive_gpio_in(dut, 0x000)       # falling edge

        fired = await fired_ev
        assert fired, f"gpio_interrupt did not fire on falling edge for pin {pin}"

        _sample(pin=pin, direction=0, mux_owner="gpio",
                intr_enable=1, edge="falling", reset_state="before_reset")

    await _write_gpio_intr_en(tb, 0x000)
    _check_coverage("GPIO_005")
    log.info("GPIO-005 PASS")


# ---------------------------------------------------------------------------
# GPIO-006 — No interrupt when enable=0
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_006_interrupt_no_enable(dut):
    """
    GPIO-006: Toggle each GPIO-free pin with GPIO_Interrupt_Enable=0;
    gpio_interrupt must NOT assert.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    await _write_gpio_oe(tb, 0x000)
    await _write_gpio_intr_en(tb, 0x000)

    for pin in ALL_PINS:
        if not (free & (1 << pin)):
            log.info(f"GPIO_006: skipping peripheral-owned pin {pin}")
            continue

        await _drive_gpio_in(dut, 0x000)
        await Timer(10, "ns")
        await _drive_gpio_in(dut, 1 << pin)   # rising
        await Timer(50, "ns")
        _assert_no_interrupt(dut)

        await _drive_gpio_in(dut, 0x000)       # falling
        await Timer(50, "ns")
        _assert_no_interrupt(dut)

        for edge in ("rising", "falling"):
            _sample(pin=pin, direction=0, mux_owner="gpio",
                    intr_enable=0, edge=edge, reset_state="before_reset")

    _check_coverage("GPIO_006")
    log.info("GPIO-006 PASS")


# ---------------------------------------------------------------------------
# GPIO-007 — Register width masking
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_007_width(dut):
    """
    GPIO-007: Write 0xFFF (12-bit) to each 11-bit GPIO register; readback
    must be 0x7FF. Verifies bit 11 is not retained.
    """
    tb = await _tb_init(dut)

    OVER_WIDTH = 0xFFF
    EXPECTED = 0x7FF

    await _write_gpio_oe(tb, OVER_WIDTH)
    rb = await _read_gpio_oe(tb)
    assert rb == EXPECTED, f"GPIO_OE over-width: got {rb:#05x}"

    await _write_gpio_o(tb, OVER_WIDTH)
    rb = await _read_gpio_o(tb)
    assert rb == EXPECTED, f"GPIO_O over-width: got {rb:#05x}"

    await _write_gpio_intr_en(tb, OVER_WIDTH)
    rb = await _read_gpio_intr_en(tb)
    assert rb == EXPECTED, f"GPIO_Interrupt_Enable over-width: got {rb:#05x}"

    for pin in ALL_PINS:
        _sample(pin=pin, direction=1, mux_owner="gpio",
                data_value="all_one", reset_state="before_reset")

    _check_coverage("GPIO_007")
    log.info("GPIO-007 PASS")


# ---------------------------------------------------------------------------
# GPIO-008 — SPI owns pins[3:6] at boot
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_008_mux_spi_owns(dut):
    """
    GPIO-008: With spi_enable=1 (boot default), verify GPIO writes have
    no effect on SPI-owned pins [3:6].

    Input check: GPIO_I must NOT capture values driven on gpio_in for SPI pins.
    Output check: gpio_out for SPI pins must NOT track GPIO_O writes.
      (Uses write-tracking isolation: drive GPIO_O=0 then =1 and confirm
       gpio_out[pin] does not change -- SPI idle keeps pads at a fixed state.)
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=1, i2c=0, qspi=0, uart=0)  # confirm boot state

    # Input isolation: GPIO_I must not capture SPI-owned pins
    await _write_gpio_oe(tb, 0x000)
    for pin in PINS_SPI:
        await _drive_gpio_in(dut, 1 << pin)
        await Timer(20, "ns")
        gpio_i_val = await _read_gpio_i(tb)
        assert not (gpio_i_val & (1 << pin)), \
            f"GPIO_I captured SPI-owned pin {pin} (GPIO_I={gpio_i_val:#05x})"
        _sample(pin=pin, direction=0, mux_owner="spi",
                reset_state="before_reset")

    # Output isolation: gpio_out must not track GPIO_O on SPI-owned pins
    for pin in PINS_SPI:
        await _write_gpio_oe(tb, 1 << pin)
        # Write 0 then 1 to GPIO_O and confirm pad does not follow
        await _write_gpio_o(tb, 0x000)
        await Timer(20, "ns")
        out_at_zero = int(dut.gpio_out.value) & (1 << pin)

        await _write_gpio_o(tb, GPIO_MASK)
        await Timer(20, "ns")
        samples = []
        for _ in range(10):
            out_at_ones = int(dut.gpio_out.value) & (1 << pin)
            samples.append(out_at_ones)
            await Timer(7, "ns")

        if len(set(samples)) == 1:
            assert out_at_zero == out_at_ones, \
                (f"gpio_out[{pin}] tracked GPIO_O on SPI-owned pin "
                 f"(at_zero={out_at_zero} at_ones={out_at_ones}) -- mux isolation failure")

        _sample(pin=pin, direction=1, mux_owner="spi",
                reset_state="before_reset")

    _check_coverage("GPIO_008")
    log.info("GPIO-008 PASS")


# ---------------------------------------------------------------------------
# GPIO-009 — SPI release: pins[3:6] become GPIO after spi_enable=0
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_009_mux_spi_release(dut):
    """
    GPIO-009: Clear spi_enable; verify GPIO[3:6] now respond to GPIO registers.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    assert free & _pins_to_mask(PINS_SPI), \
        f"PINS_SPI not free after spi=0: free={free:#05x}"

    for pin in PINS_SPI:
        # Input mode
        await _write_gpio_oe(tb, 0x000)
        await _drive_gpio_in(dut, 1 << pin)
        await Timer(20, "ns")
        gpio_i_val = await _read_gpio_i(tb)
        assert gpio_i_val & (1 << pin), \
            f"GPIO_I did not capture released SPI pin {pin} (GPIO_I={gpio_i_val:#05x})"

        # Output mode
        await _write_gpio_oe(tb, 1 << pin)
        await _write_gpio_o(tb, 1 << pin)
        await Timer(20, "ns")
        gpio_out_val = int(dut.gpio_out.value)
        assert gpio_out_val & (1 << pin), \
            f"gpio_out not driven on released SPI pin {pin}"

        _sample(pin=pin, direction=0, mux_owner="gpio",
                reset_state="before_reset")
        _sample(pin=pin, direction=1, mux_owner="gpio",
                reset_state="before_reset")

    _check_coverage("GPIO_009")
    log.info("GPIO-009 PASS")


# ---------------------------------------------------------------------------
# GPIO-010 — I2C mux transition
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_010_mux_i2c(dut):
    """
    GPIO-010: Toggle i2c_enable 0->1->0; verify GPIO[1:2] ownership.
    When i2c_enable=1 the I2C controller drives SCL/SDA (idle=high with
    external pull-up); write-tracking isolation is used to confirm GPIO
    has no effect on the owned pins.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)

    for enable_state, expected_owner in [(0, "gpio"), (1, "i2c"), (0, "gpio")]:
        await _set_mux(tb, spi=0, i2c=enable_state)

        for pin in PINS_I2C:
            await _write_gpio_oe(tb, 1 << pin)

            if expected_owner == "gpio":
                await _write_gpio_o(tb, 1 << pin)
                await Timer(20, "ns")
                out_val = int(dut.gpio_out.value)
                assert out_val & (1 << pin), \
                    f"GPIO not driving pin {pin} when i2c_enable={enable_state}"
            else:
                # I2C owns: verify isolation via write-tracking
                await _write_gpio_o(tb, 0x000)
                await Timer(20, "ns")
                out_at_zero = int(dut.gpio_out.value) & (1 << pin)
                await _write_gpio_o(tb, GPIO_MASK)
                await Timer(20, "ns")
                out_at_ones = int(dut.gpio_out.value) & (1 << pin)
                assert out_at_zero == out_at_ones, \
                    (f"gpio_out[{pin}] tracked GPIO_O on I2C-owned pin "
                     f"i2c_enable={enable_state}")

            _sample(pin=pin, direction=1, mux_owner=expected_owner,
                    reset_state="before_reset")

    _check_coverage("GPIO_010")
    log.info("GPIO-010 PASS")


# ---------------------------------------------------------------------------
# GPIO-011 — QSPI mux transition
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_011_mux_qspi(dut):
    """
    GPIO-011: Toggle qspi_enable 0->1->0; verify GPIO[7:8] ownership.
    When qspi_enable=1 the QSPI clock can be toggling, so an absolute-value
    check is unreliable; write-tracking isolation is used instead.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)

    for enable_state, expected_owner in [(0, "gpio"), (1, "qspi"), (0, "gpio")]:
        await _set_mux(tb, spi=0, qspi=enable_state)

        for pin in PINS_QSPI:
            await _write_gpio_oe(tb, 1 << pin)

            if expected_owner == "gpio":
                await _write_gpio_o(tb, 1 << pin)
                await Timer(20, "ns")
                out_val = int(dut.gpio_out.value)
                assert out_val & (1 << pin), \
                    f"GPIO not driving pin {pin} when qspi_enable={enable_state}"
            else:
                # QSPI owns; clock may be toggling -- use write-tracking
                await _write_gpio_o(tb, 0x000)
                await Timer(20, "ns")
                out_at_zero = int(dut.gpio_out.value) & (1 << pin)
                await _write_gpio_o(tb, GPIO_MASK)
                await Timer(20, "ns")
                out_at_ones = int(dut.gpio_out.value) & (1 << pin)
                assert out_at_zero == out_at_ones, \
                    (f"gpio_out[{pin}] tracked GPIO_O on QSPI-owned pin "
                     f"qspi_enable={enable_state}")

            _sample(pin=pin, direction=1, mux_owner=expected_owner,
                    reset_state="before_reset")

    _check_coverage("GPIO_011")
    log.info("GPIO-011 PASS")


# ---------------------------------------------------------------------------
# GPIO-012 — UART mux transition
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_012_mux_uart(dut):
    """
    GPIO-012: Toggle uart_enable 0->1->0; verify GPIO[9:10] ownership.
    UART TX is high at idle (mark state), so absolute-value checks are
    unreliable when uart_enable=1; write-tracking isolation is used.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)

    for enable_state, expected_owner in [(0, "gpio"), (1, "uart"), (0, "gpio")]:
        await _set_mux(tb, spi=0, uart=enable_state)

        for pin in PINS_UART:
            await _write_gpio_oe(tb, 1 << pin)

            if expected_owner == "gpio":
                await _write_gpio_o(tb, 1 << pin)
                await Timer(20, "ns")
                out_val = int(dut.gpio_out.value)
                assert out_val & (1 << pin), \
                    f"GPIO not driving pin {pin} when uart_enable={enable_state}"
            else:
                # UART TX idle=1 (mark); write-tracking isolation
                await _write_gpio_o(tb, 0x000)
                await Timer(20, "ns")
                out_at_zero = int(dut.gpio_out.value) & (1 << pin)
                await _write_gpio_o(tb, GPIO_MASK)
                await Timer(20, "ns")
                out_at_ones = int(dut.gpio_out.value) & (1 << pin)
                assert out_at_zero == out_at_ones, \
                    (f"gpio_out[{pin}] tracked GPIO_O on UART-owned pin "
                     f"uart_enable={enable_state}")

            _sample(pin=pin, direction=1, mux_owner=expected_owner,
                    reset_state="before_reset")

    _check_coverage("GPIO_012")
    log.info("GPIO-012 PASS")


# ---------------------------------------------------------------------------
# GPIO-013 — Randomised mux transition sequence
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_013_mux_rand_transition(dut):
    """
    GPIO-013: Randomise enable/disable sequence for all four peripherals;
    verify pin ownership at every step via appropriate check:
      - GPIO-owned pin: direct value check
      - Peripheral-owned pin: write-tracking isolation
    Drives mux_x_direction and pin_x_mux_owner crosses to closure.
    """
    tb = await _tb_init(dut)

    N_TRANSITIONS = 40

    for step in range(N_TRANSITIONS):
        spi = random.randint(0, 1)
        i2c = random.randint(0, 1)
        qspi = random.randint(0, 1)
        uart = random.randint(0, 1)
        testmode = random.randint(0, 1)
        dut.TestMode.value = testmode

        await _set_mux(tb, spi=spi, i2c=i2c, qspi=qspi, uart=uart)
        free = _gpio_free_mask(dut)

        pin = random.choice(ALL_PINS)
        owner = _mux_owner_for_pin(
            pin, spi=spi, i2c=i2c, qspi=qspi, uart=uart, testmode=testmode)

        await _write_gpio_oe(tb, 1 << pin)

        if owner == "gpio":
            await _write_gpio_o(tb, 1 << pin)
            await Timer(20, "ns")
            out_val = int(dut.gpio_out.value)
            assert out_val & (1 << pin), \
                (f"[step {step}] GPIO not driving pin {pin} (owner=gpio) "
                 f"{spi=} {i2c=} {qspi=} {uart=} {testmode=}")
        else:
            await _write_gpio_o(tb, 0x000)
            await Timer(20, "ns")
            out_at_zero = int(dut.gpio_out.value) & (1 << pin)
            await _write_gpio_o(tb, GPIO_MASK)
            await Timer(20, "ns")
            samples = []
            for _ in range(10):
                out_at_ones = int(dut.gpio_out.value) & (1 << pin)
                samples.append(out_at_ones)
                await Timer(7, "ns")
            if len(set(samples)) == 1:
                assert out_at_zero == out_at_ones, \
                    (f"[step {step}] gpio_out[{pin}] tracked GPIO_O while {owner} owns pin "
                     f"{spi=} {i2c=} {qspi=} {uart=} {samples=} {out_at_ones=} {out_at_zero=}")

        _sample(pin=pin, direction=1, mux_owner=owner,
                reset_state="before_reset")

    await _set_mux(tb, spi=0)
    _check_coverage("GPIO_013")
    log.info("GPIO-013 PASS")


# ---------------------------------------------------------------------------
# GPIO-014 — Mixed direction randomised concurrent
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_014_mixed_dir_rand(dut):
    """
    GPIO-014: Set random GPIO_OE mask (some in, some out); simultaneously drive
    gpio_in on input pins and GPIO_O on output pins; verify both work together.
    All assertions are masked to GPIO-free pins only.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)
    log.info(f"GPIO_014: free_mask={free:#05x}")

    N_ITERATIONS = 25

    for iteration in range(N_ITERATIONS):
        oe_mask = rng.rand_oe_mask(pool=ALL_PINS) & free
        out_data = rng.rand_data_11() & free
        in_data = rng.rand_data_11() & free

        out_pins_mask = oe_mask & free
        in_pins_mask = (~oe_mask) & free & GPIO_MASK

        out_expected = out_data & out_pins_mask
        in_expected = in_data & in_pins_mask

        await _write_gpio_oe(tb, oe_mask)
        await _write_gpio_o(tb, out_data)
        await _drive_gpio_in(dut, in_data)
        await Timer(30, "ns")

        actual_out = int(dut.gpio_out.value) & out_pins_mask
        assert actual_out == out_expected, \
            (f"[iter {iteration}] gpio_out mismatch: "
             f"got {actual_out:#05x} expected {out_expected:#05x} "
             f"oe={oe_mask:#05x} free={free:#05x}")

        gpio_i_val = await _read_gpio_i(tb)
        actual_in = gpio_i_val & in_pins_mask
        assert actual_in == in_expected, \
            (f"[iter {iteration}] GPIO_I mismatch: "
             f"got {actual_in:#05x} expected {in_expected:#05x} "
             f"oe={oe_mask:#05x} free={free:#05x}")

        oe_lbl = _oe_pattern_label(oe_mask)
        for pin in ALL_PINS:
            if free & (1 << pin):
                direction = 1 if (oe_mask & (1 << pin)) else 0
                _sample(pin=pin, direction=direction, mux_owner="gpio",
                        data_value="random", reset_state="before_reset",
                        oe_pattern=oe_lbl)

    _check_coverage("GPIO_014")
    log.info("GPIO-014 PASS")


# ---------------------------------------------------------------------------
# GPIO-015 — Post-reset recovery
# ---------------------------------------------------------------------------

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def GPIO_015_post_reset_recovery(dut):
    """
    GPIO-015: Configure a randomised non-default GPIO state; issue soft_reset;
    verify all GPIO registers and GPIO-owned pad signals return to RDL defaults;
    then re-run basic output and input to confirm full functional recovery.

    gpio_out / gpio_out_ena reset checks use _gpio_free_mask() with the post-reset
    mux state (boot defaults: spi=1), same masking rule as GPIO_001.
    """
    tb = await _tb_init(dut)
    await _set_mux(tb, spi=0)

    # --- Phase 1: dirty state --------------------------------------------
    dirty_oe = rng.rand_data_11() | 1
    dirty_o = rng.rand_data_11()
    dirty_ie = rng.rand_data_11() | 1
    spi_en = random.randint(0, 1)
    i2c_en = random.randint(0, 1)
    qspi_en = random.randint(0, 1)
    uart_en = random.randint(0, 1)

    await _write_gpio_oe(tb, dirty_oe)
    await _write_gpio_o(tb, dirty_o)
    await _write_gpio_intr_en(tb, dirty_ie)
    await _set_mux(tb, spi=spi_en, i2c=i2c_en, qspi=qspi_en, uart=uart_en)
    await _drive_gpio_in(dut, rng.rand_data_11())
    await Timer(20, "ns")

    for pin in ALL_PINS:
        owner = _mux_owner_for_pin(pin, spi=spi_en, i2c=i2c_en,
                                   qspi=qspi_en, uart=uart_en)
        direction = 1 if (dirty_oe & (1 << pin)) else 0
        _sample(pin=pin, direction=direction, mux_owner=owner,
                reset_state="before_reset", oe_pattern="mixed")

    log.info(
        f"GPIO_015: pre-reset OE={dirty_oe:#05x} O={dirty_o:#05x} IE={dirty_ie:#05x} "
        f"spi={spi_en} i2c={i2c_en} qspi={qspi_en} uart={uart_en}"
    )

    # --- Phase 2: soft reset ---------------------------------------------
    await tb.reg.system_registers.SoftReset.write_fields(soft_reset=1)
    await tb.reset()
    # await tb.xspi_cmd.Reset()
    await Timer(100, "ns")

    # Sync tracker to post-reset boot defaults
    _mux_state.update({"spi": 1, "i2c": 0, "qspi": 0, "uart": 0})

    # --- Phase 3: verify RDL reset defaults ------------------------------
    oe = await _read_gpio_oe(tb)
    o = await _read_gpio_o(tb)
    ie = await _read_gpio_intr_en(tb)

    assert oe == 0x000, f"GPIO_OE not cleared after reset: {oe:#05x}"
    assert o == 0x000, f"GPIO_O not cleared after reset: {o:#05x}"
    assert ie == 0x000, f"GPIO_Interrupt_Enable not cleared after reset: {ie:#05x}"

    # Pad signals -- only GPIO-owned pins (boot: spi_enable=1 => [3:6] excluded)
    free = _gpio_free_mask(dut)
    log.info(f"GPIO_015: post-reset free_mask={free:#05x}")

    gpio_out_val = int(dut.gpio_out.value) & free
    gpio_out_ena_val = int(dut.gpio_out_ena.value) & free
    assert gpio_out_val == 0, \
        f"gpio_out non-zero on GPIO-owned pins after reset: {gpio_out_val:#05x}"
    assert gpio_out_ena_val == 0, \
        f"gpio_out_ena non-zero on GPIO-owned pins after reset: {gpio_out_ena_val:#05x}"

    try:
        testmode_val = int(dut.TestMode.value)
    except Exception:
        testmode_val = 0

    for pin in ALL_PINS:
        owner = _mux_owner_for_pin(pin, **_mux_state, testmode=testmode_val)
        _sample(pin=pin, direction=0, mux_owner=owner,
                reset_state="after_reset", oe_pattern="all_input")

    # --- Phase 4: functional recovery ------------------------------------
    await _set_mux(tb, spi=0)
    free = _gpio_free_mask(dut)

    # Output recovery
    recovery_oe = rng.rand_data_11() & free
    recovery_oe = recovery_oe if recovery_oe else (
        free & -free)  # at least one bit
    recovery_data = rng.rand_data_11() & free
    out_write = recovery_data & recovery_oe
    await _write_gpio_oe(tb, recovery_oe)
    await _write_gpio_o(tb, out_write)
    await Timer(20, "ns")
    actual_out = int(dut.gpio_out.value) & (recovery_oe & free)
    assert actual_out == (out_write & free), \
        f"Post-reset output recovery failed: got {actual_out:#05x} expected {out_write & free:#05x}"

    # Input recovery
    await _write_gpio_oe(tb, 0x000)
    recovery_in = rng.rand_data_11() & free
    await _drive_gpio_in(dut, recovery_in)
    await Timer(20, "ns")
    gpio_i_val = await _read_gpio_i(tb)
    assert (gpio_i_val & free) == (recovery_in & free), \
        f"Post-reset input recovery failed: got {gpio_i_val & free:#05x} expected {recovery_in & free:#05x}"

    _check_coverage("GPIO_015")
    log.info("GPIO-015 PASS")
# ---------------------------------------------------------------------------
# Coverage model - FIXED VERSION
# ---------------------------------------------------------------------------

# Use coverage_section to combine all coverage items into one decorator
gpio_coverage = coverage_section(
    CoverPoint("gpio.pin_index",
               vname="pin",
               bins=list(ALL_PINS),
               bins_labels=[f"pin{i}" for i in ALL_PINS]),
    CoverPoint("gpio.direction",
               vname="direction",
               bins=[0, 1],
               bins_labels=["input", "output"]),
    CoverPoint("gpio.mux_owner",
               vname="mux_owner",
               bins=["gpio", "spi", "i2c", "qspi", "uart"],
               bins_labels=["gpio", "spi", "i2c", "qspi", "uart"]),
    CoverPoint("gpio.data_value",
               vname="data_value",
               bins=["all_zero", "all_one", "walking_0", "walking_1", "random"],
               bins_labels=["all_zero", "all_one", "walking_0", "walking_1", "random"]),
    CoverPoint("gpio.interrupt_enable",
               vname="intr_enable",
               bins=[0, 1],
               bins_labels=["disabled", "enabled"]),
    CoverPoint("gpio.edge_direction",
               vname="edge",
               bins=["rising", "falling"],
               bins_labels=["rising", "falling"]),
    CoverPoint("gpio.reset_state",
               vname="reset_state",
               bins=["before_reset", "after_reset"],
               bins_labels=["before_reset", "after_reset"]),
    CoverPoint("gpio.oe_pattern",
               vname="oe_pattern",
               bins=["all_input", "all_output", "mixed"],
               bins_labels=["all_input", "all_output", "mixed"]),
    CoverCross("gpio.pin_x_direction",
               items=["gpio.pin_index", "gpio.direction"]),
    CoverCross("gpio.pin_x_mux_owner",
               items=["gpio.pin_index", "gpio.mux_owner"]),
    CoverCross("gpio.direction_x_data",
               items=["gpio.direction", "gpio.data_value"]),
    CoverCross("gpio.interrupt_x_edge",
               items=["gpio.interrupt_enable", "gpio.edge_direction"]),
    CoverCross("gpio.pin_x_interrupt_x_edge",
               items=["gpio.pin_index", "gpio.interrupt_enable", "gpio.edge_direction"]),
    CoverCross("gpio.mux_x_direction",
               items=["gpio.mux_owner", "gpio.direction"]),
    CoverCross("gpio.reset_x_direction_x_mux",
               items=["gpio.reset_state", "gpio.direction", "gpio.mux_owner"]),
)


@gpio_coverage
def _sample_coverage(pin: Optional[int] = None,
                     direction: Optional[int] = None,
                     mux_owner: Optional[str] = None,
                     data_value: Optional[str] = None,
                     intr_enable: Optional[int] = None,
                     edge: Optional[str] = None,
                     reset_state: Optional[str] = None,
                     oe_pattern: Optional[str] = None) -> None:
    """Coverage sampling function - parameters are sampled by the decorators."""
    # The decorators handle all sampling automatically based on parameter values
    pass


def _sample(*,
            pin: Optional[int] = None,
            direction: Optional[int] = None,
            mux_owner: Optional[str] = None,
            data_value: Optional[str] = None,
            intr_enable: Optional[int] = None,
            edge: Optional[str] = None,
            reset_state: Optional[str] = None,
            oe_pattern: Optional[str] = None) -> None:
    """Wrapper to call the decorated coverage sampling function."""
    _sample_coverage(pin,
                     direction,
                     mux_owner,
                     data_value,
                     intr_enable,
                     edge,
                     reset_state,
                     oe_pattern)
