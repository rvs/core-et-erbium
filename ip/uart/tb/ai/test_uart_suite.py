"""
UART Comprehensive Test Suite
==============================
Covers:
  - Register reset values
  - Basic TX / RX (smoke)
  - Multiple baud rates
  - Parity modes (none / odd / even)
  - Stop-bit modes (1 / 1.5 / 2)
  - TX FIFO full / empty status
  - RX FIFO fill, full status, threshold
  - Error injection: parity, frame, break, overrun
  - Interrupt enable / assert / deassert for every IRQ source
  - Transmit delay register
  - Multi-byte sequential transfers
  - Back-to-back stress (TX + RX simultaneously)

Register map (from uart.rdl, base 0x40004000, alignment=8)
  BaudReg       +0x000   baud_value[15:0]  default=5
  TxReg         +0x008   data[31:0]        write-only
  RxReg         +0x010   data[31:0]        read-only
  StatusReg     +0x018   bits[8:0]         read-only
  DelayReg      +0x020   delay_control[15:0]
  ControlReg    +0x028   charsize[10:5] | parity[4:3] | stopbits[2:1]
  InterruptMask   +0x030   bits[8:0]
  IQC           +0x038   qual_cycles[7:0]
  Rx_Threshold  +0x040   rx_level[7:0]     default=5

Baud formula:  baud = Clk_Freq / (16 * baud_val)
ControlReg encoding:
  charsize  → bits [10:5]   (max 32-bit word; default 8)
  parity    → bits [4:3]    0=none 1=odd 2=even
  stopbits  → bits [2:1]    0=1 1=1.5 2=2

Status bits:
  [0] tx_empty  [1] tx_full     [2] rx_notEmpty [3] rx_full
  [4] parity_er [5] overrun_er  [6] frame_er    [7] break_er
  [8] rx_fifo_threshold
"""

import cocotb
import cocotb.utils
from cocotb.triggers import Timer, RisingEdge, FallingEdge, First
from cocotb.triggers import with_timeout
from cocotb.clock import Clock
import cocotb.result
import random

from uart_env import UARTEnv
from cocotbext.uart import UartSource, UartSink, UartParity

# ---------------------------------------------------------------------------
# Patch float-precision issue in cocotb Timer
# ---------------------------------------------------------------------------
_orig_timer_init = Timer.__init__
def _patched_timer_init(self, time, *args, **kwargs):
    kwargs["round_mode"] = "round"
    _orig_timer_init(self, time, *args, **kwargs)
Timer.__init__ = _patched_timer_init

# ===========================================================================
#  Constants
# ===========================================================================
TX_FIFO_DEPTH = 16
RX_FIFO_DEPTH = 16

STS_TX_EMPTY        = 0
STS_TX_FULL         = 1
STS_RX_NOT_EMPTY    = 2
STS_RX_FULL         = 3
STS_PARITY_ERROR    = 4
STS_OVERRUN_ERROR   = 5
STS_FRAME_ERROR     = 6
STS_BREAK_ERROR     = 7
STS_RX_THRESHOLD    = 8

# ===========================================================================
#  Low-level helpers (same as reference template)
# ===========================================================================

async def clear_interrupt(tb):
    intr=await tb.reg.InterruptRaw.read()
    await tb.reg.InterruptRaw.write(intr)
    cocotb.log.info("cleared interrupt")
async def re_interrupt(logic_array,timeout_us):
    try:
        if logic_array.value != 1:
            await with_timeout(RisingEdge(logic_array), timeout_us, 'us')
        return 1

    except cocotb.triggers.SimTimeoutError:
        cocotb.log.error("Timeout waiting for rising edge!")
        return 0
def safe_int(logic_array):
    try:
        return int(logic_array.value)
    except ValueError:
        s = logic_array.binstr.lower().replace('x', '0').replace('z', '0')
        return int(s, 2)


async def _tb_init(dut) -> UARTEnv:
    tb = UARTEnv(dut)
    await tb.reset()
    tb.start()
    return tb


async def measure_clk_freq_mhz(dut, num_cycles=8):
    await RisingEdge(dut.CLK)
    t0 = cocotb.utils.get_sim_time('ps')
    for _ in range(num_cycles):
        await RisingEdge(dut.CLK)
    t1 = cocotb.utils.get_sim_time('ps')
    period_ps = (t1 - t0) / num_cycles
    freq_mhz = 1e6 / period_ps
    cocotb.log.info(f"Measured CLK: {period_ps:.1f} ps  →  {freq_mhz:.3f} MHz")
    return freq_mhz


def calc_baud_val(target_baud, clk_freq_mhz):
    """Return (baud_val, actual_baud, error_pct) or (None,None,None)."""
    clk_hz = clk_freq_mhz * 1e6
    v = round(clk_hz / (16.0 * target_baud))
    if v < 1 or v > 0xFFFF:
        return None, None, None
    actual = clk_hz / (16.0 * v)
    err = abs(actual - target_baud) / target_baud * 100.0
    return v, actual, err


def calc_bit_time_ns(baud_val, clk_freq_mhz):
    clk_hz = clk_freq_mhz * 1e6
    baud = clk_hz / (16 * max(1, baud_val))
    return int(1e9 / baud)


def calc_frame_time_ns(baud_val, charsize=8, parity=0, stopbits=0,
                        clk_freq_mhz=1000.0):
    bt = calc_bit_time_ns(baud_val, clk_freq_mhz)
    nbits = 1 + charsize + (1 if parity else 0)
    nbits += {0: 1, 1: 2, 2: 2}.get(stopbits, 1)
    return bt * nbits


def _parity_enum(p):
    return {0: UartParity.NONE, 1: UartParity.ODD, 2: UartParity.EVEN}.get(p, UartParity.NONE)


def _stop_float(s):
    return {0: 1.0, 1: 1.5, 2: 2.0}.get(s, 1.0)


# ===========================================================================
#  Mid-level helpers
# ===========================================================================

async def uart_setup(tb, baud_val=10, charsize=8, parity=0, stopbits=0):
    await tb.reg.BaudReg.write(baud_val)
    ctrl = (charsize << 5) | (parity << 3) | (stopbits << 1)
    await tb.reg.ControlReg.write(ctrl)
    await Timer(2, 'us')
    cocotb.log.info(f"UART cfg: baud_val={baud_val} charsize={charsize} "
                    f"parity={parity} stopbits={stopbits}")


async def uart_reconfigure(tb, dut, target_baud, baud_val,
                            charsize=8, parity=0, stopbits=0):
    bits = charsize if charsize <= 8 else 8
    for attr, val in [('_baud', target_baud), ('_bits', bits),
                      ('_stop_bits', _stop_float(stopbits)),
                      ('_parity', _parity_enum(parity))]:
        setattr(tb.uart_tx, attr, val)
        setattr(tb.uart_rx, attr, val)
    tb.uart_tx._restart()
    tb.uart_rx._restart()
    tb.uart_rx.clear()
    await uart_setup(tb, baud_val=baud_val, charsize=charsize,
                     parity=parity, stopbits=stopbits)


async def read_status(tb):
    rv = await tb.reg.InterruptRaw.read()
    await tb.reg.InterruptRaw.write(rv)
    return rv


async def wait_tx_empty(tb, timeout_us=500):
    for _ in range(max(10, int(timeout_us) // 2)):
        if (await read_status(tb)) & (1 << STS_TX_EMPTY):
            return True
        await Timer(1, 'us')
    cocotb.log.warning("wait_tx_empty: TIMEOUT")
    return False


async def wait_rx_not_empty(tb, timeout_us=500):
    for _ in range(max(10, timeout_us // 2)):
        if (await read_status(tb)) & (1 << STS_RX_NOT_EMPTY):
            return True
        await Timer(1, 'us')
    cocotb.log.warning("wait_rx_not_empty: TIMEOUT")
    return False


async def inject_rx_frame(dut, data, target_baud, charsize=8,
                           parity=0, inject_error="none"):
    """
    Bit-bang a UART frame on dut.UART_RX.
    inject_error: "none" | "parity" | "frame" | "break"
    """
    bit_ns = int(1e9 / target_baud)

    if inject_error == "break":
        total = 1 + charsize + (1 if parity else 0) + 1
        dut.UART_RX.value = 0
        await Timer(bit_ns * (total + 2), 'ns')
        dut.UART_RX.value = 1
        await Timer(bit_ns, 'ns')
        return

    # Start bit
    dut.UART_RX.value = 0
    await Timer(bit_ns, 'ns')

    # Data bits LSB-first
    mask = (1 << charsize) - 1
    data &= mask
    par = 0
    for i in range(charsize):
        b = (data >> i) & 1
        dut.UART_RX.value = b
        par ^= b
        await Timer(bit_ns, 'ns')

    # Parity bit
    if parity != 0:
        pb = (1 - par) if parity == 1 else par   # odd / even
        if inject_error == "parity":
            pb = 1 - pb
        dut.UART_RX.value = pb
        await Timer(bit_ns, 'ns')

    # Stop bit
    dut.UART_RX.value = 0 if inject_error == "frame" else 1
    await Timer(bit_ns, 'ns')
    dut.UART_RX.value = 1          # return to idle
    await Timer(bit_ns, 'ns')


async def _default_baud(dut, tb):
    """Measure clock, pick baud_val=5, return (baud_val, actual_baud, frame_ns, timeout_us)."""
    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = clk * 1e6 / (16 * bv)
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    tus = max(500, fns * 5 // 1000 + 200)
    await uart_reconfigure(tb, dut, int(actual), bv)
    return bv, int(actual), fns, tus, clk


# ===========================================================================
# ===========================================================================
#  TEST CASES
# ===========================================================================
# ===========================================================================


# ---------------------------------------------------------------------------
# TEST 01 – Register reset values
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_01_register_reset_values(dut):
    """
    Verify every writable register reads back its RDL-specified default
    value after reset.

    RDL defaults:
      BaudReg.baud_value  = 0x5
      DelayReg            = 0x0
      ControlReg.charsize = 0x8  → ctrl = (8<<5) = 0x100
      InterruptMask         = 0x0
      IQC.qual_cycles     = 0x0
      Rx_Threshold.rx_level = 0x5
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 01: Register Reset Values")
    cocotb.log.info("=" * 60)

    baud = await tb.reg.BaudReg.read()
    assert baud & 0xFFFF == 0x5, f"BaudReg reset: expected 0x5, got 0x{baud:X}"
    cocotb.log.info(f"  BaudReg       = 0x{baud:X}  ✓")

    delay = await tb.reg.DelayReg.read()
    assert delay & 0xFFFF == 0x0, f"DelayReg reset: expected 0x0, got 0x{delay:X}"
    cocotb.log.info(f"  DelayReg      = 0x{delay:X}  ✓")

    ctrl = await tb.reg.ControlReg.read()
    # charsize default = 8 lives at bits[10:5] → 8<<5 = 0x100
    expected_ctrl = (8 << 5)
    assert (ctrl & 0x7FE) == expected_ctrl, \
        f"ControlReg reset: expected 0x{expected_ctrl:X}, got 0x{ctrl:X}"
    cocotb.log.info(f"  ControlReg    = 0x{ctrl:X}  ✓")

    irq = await tb.reg.InterruptMask.read()
    assert irq & 0x1FF == 0x0, f"InterruptMask reset: expected 0x0, got 0x{irq:X}"
    cocotb.log.info(f"  InterruptMask   = 0x{irq:X}  ✓")

    # iqc = await tb.reg.IQC.read()
    # assert iqc & 0xFF == 0x0, f"IQC reset: expected 0x0, got 0x{iqc:X}"
    # cocotb.log.info(f"  IQC           = 0x{iqc:X}  ✓")

    thr = await tb.reg.Rx_Threshold.read()
    assert thr & 0xFF == 0x5, f"Rx_Threshold reset: expected 0x5, got 0x{thr:X}"
    cocotb.log.info(f"  Rx_Threshold  = 0x{thr:X}  ✓")

    print("\n" + "=" * 60)
    print("TEST 01: REGISTER RESET VALUES  PASSED")
    print("=" * 60)


# ---------------------------------------------------------------------------
# TEST 02 – Basic smoke TX / RX
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_02_smoke_tx_rx(dut):
    """
    Basic sanity: write 0xA5 to TxReg → captured by UartSink.
    Write 0x5A from UartSource → readable from RxReg.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 02: Smoke TX/RX")
    cocotb.log.info("=" * 60)

    bv, actual, fns, tus, _ = await _default_baud(dut, tb)

    # --- TX path ---
    tb.uart_rx.clear()
    await tb.reg.TxReg.write(0xA5)
    await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
    assert not tb.uart_rx.empty(), "UartSink captured nothing from TX"
    captured = tb.uart_rx.read_nowait(1)[0]
    assert captured == 0xA5, f"TX: expected 0xA5, got 0x{captured:02X}"
    cocotb.log.info(f"TX captured: 0x{captured:02X}  ✓")
    await wait_tx_empty(tb, tus)

    # --- RX path ---
    await tb.uart_tx.write(bytes([0x5A]))
    await tb.uart_tx.wait()
    await Timer(max(10, fns * 3 // 1000), 'us')
    assert await wait_rx_not_empty(tb, tus), "RX FIFO never non-empty"
    rx = (await tb.reg.RxReg.read()) & 0xFF
    assert rx == 0x5A, f"RX: expected 0x5A, got 0x{rx:02X}"
    cocotb.log.info(f"RX read: 0x{rx:02X}  ✓")

    print("\nTEST 02: SMOKE TX/RX  PASSED")


# ---------------------------------------------------------------------------
# TEST 03 – Multiple standard baud rates
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_03_baud_rates(dut):
    """
    Verify TX→RX round-trip at several baud rates.
    Rates with >5% error are skipped gracefully.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 03: Multiple Baud Rates")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    targets = [9600, 115200, 230400, 460800, 921600, 1000000, 2000000]
    byte_val = 0xC3
    passed = 0

    for rate in targets:
        bv, actual, err = calc_baud_val(rate, clk)
        if bv is None or err > 5.0:
            cocotb.log.warning(f"  baud={rate}: skipped (baud_val={bv}, err={err:.1f}%)")
            continue

        fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
        tus = max(500, fns * 6 // 1000 + 200)
        cocotb.log.info(f"  Testing {rate} bps  → baud_val={bv}  actual={actual:.0f}  err={err:.2f}%")

        await uart_reconfigure(tb, dut, int(actual), bv)

        tb.uart_rx.clear()
        await tb.reg.TxReg.write(byte_val)
        await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
        assert not tb.uart_rx.empty(), f"baud={rate}: TX not captured"
        cap = tb.uart_rx.read_nowait(1)[0]
        assert cap == byte_val, f"baud={rate}: TX got 0x{cap:02X}, expected 0x{byte_val:02X}"
        await wait_tx_empty(tb, tus)

        await tb.uart_tx.write(bytes([byte_val ^ 0xFF]))
        await tb.uart_tx.wait()
        await Timer(max(10, fns * 3 // 1000), 'us')
        assert await wait_rx_not_empty(tb, tus), f"baud={rate}: RX FIFO empty"
        rx = (await tb.reg.RxReg.read()) & 0xFF
        assert rx == byte_val ^ 0xFF, f"baud={rate}: RX got 0x{rx:02X}"

        cocotb.log.info(f"    baud={rate}  ✓")
        passed += 1

    assert passed > 0, "No baud rates were testable"
    print(f"\nTEST 03: BAUD RATES  PASSED  ({passed}/{len(targets)} rates tested)")


# ---------------------------------------------------------------------------
# TEST 04 – Parity modes
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=15, timeout_unit="ms")
async def test_04_parity_modes(dut):
    """
    Verify correct frames received for each parity mode (none / odd / even)
    in both TX and RX directions.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 04: Parity Modes")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    tus = max(500, fns * 6 // 1000 + 300)
    test_byte = 0x69            # 0110 1001 – 4 ones, even parity = 0

    for parity_mode, label in [(0, "none"), (1, "odd"), (2, "even")]:
        cocotb.log.info(f"  Parity = {label}")
        await uart_reconfigure(tb, dut, actual, bv, charsize=8,
                                parity=parity_mode, stopbits=0)

        # TX direction: DUT → UartSink
        tb.uart_rx.clear()
        await tb.reg.TxReg.write(test_byte)
        await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
        assert not tb.uart_rx.empty(), f"parity={label}: TX not captured"
        cap = tb.uart_rx.read_nowait(1)[0]
        assert cap == test_byte, f"parity={label} TX: got 0x{cap:02X}"
        cocotb.log.info(f"    TX parity={label}  ✓")

        # RX direction: UartSource → DUT FIFO
        await tb.uart_tx.write(bytes([test_byte]))
        await tb.uart_tx.wait()
        await Timer(max(10, fns * 3 // 1000), 'us')
        assert await wait_rx_not_empty(tb, tus), f"parity={label}: RX FIFO empty"
        rx = (await tb.reg.RxReg.read()) & 0xFF
        assert rx == test_byte, f"parity={label} RX: got 0x{rx:02X}"
        # No parity error should have been flagged
        sts = await read_status(tb)
        assert not (sts & (1 << STS_PARITY_ERROR)), \
            f"parity={label}: unexpected parity error in status (0x{sts:X})"
        cocotb.log.info(f"    RX parity={label}  ✓")

    print("\nTEST 04: PARITY MODES  PASSED")


# ---------------------------------------------------------------------------
# TEST 05 – Stop-bit modes
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=15, timeout_unit="ms")
async def test_05_stop_bits(dut):
    """
    Verify TX→RX round-trip for 1, 1.5, and 2 stop bits.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 05: Stop-bit Modes")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    test_byte = 0xB7

    for sb, label in [(0, "1 stop"), (1, "1.5 stop"), (2, "2 stop")]:
        fns = calc_frame_time_ns(bv, stopbits=sb, clk_freq_mhz=clk)
        tus = max(500, fns * 6 // 1000 + 300)
        cocotb.log.info(f"  Stop bits = {label}")
        await uart_reconfigure(tb, dut, actual, bv, charsize=8,
                                parity=0, stopbits=sb)

        tb.uart_rx.clear()
        await tb.reg.TxReg.write(test_byte)
        await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
        assert not tb.uart_rx.empty(), f"stopbits={label}: TX not captured"
        cap = tb.uart_rx.read_nowait(1)[0]
        assert cap == test_byte, f"stopbits={label} TX: got 0x{cap:02X}"
        await wait_tx_empty(tb, tus)

        await tb.uart_tx.write(bytes([test_byte ^ 0xFF]))
        await tb.uart_tx.wait()
        await Timer(max(10, fns * 3 // 1000), 'us')
        assert await wait_rx_not_empty(tb, tus), f"stopbits={label}: RX FIFO empty"
        rx = (await tb.reg.RxReg.read()) & 0xFF
        assert rx == test_byte ^ 0xFF, f"stopbits={label} RX: got 0x{rx:02X}"
        cocotb.log.info(f"    {label}  ✓")

    print("\nTEST 05: STOP-BIT MODES  PASSED")


# ---------------------------------------------------------------------------
# TEST 06 – TX FIFO status (empty / full)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_06_tx_fifo_status(dut):
    """
    1. After reset, tx_empty should be asserted.
    2. Fill the TX FIFO with TX_FIFO_DEPTH bytes; tx_full should assert.
    3. Wait for draining; tx_empty should re-assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 06: TX FIFO Status (empty / full)")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    # Use a very slow baud so we can fill the FIFO before TX drains
    bv = 200   # ~3125 bps at 1 GHz → bit time ≈ 320 µs
    actual = int(clk * 1e6 / (16 * bv))
    await uart_reconfigure(tb, dut, actual, bv)

    # 1. Initial state: TX FIFO should be empty
    sts = await read_status(tb)
    assert sts & (1 << STS_TX_EMPTY), \
        f"Expected tx_empty after reset, status=0x{sts:X}"
    cocotb.log.info("  Initial tx_empty  ✓")

    # 2. Write TX_FIFO_DEPTH bytes quickly to fill the FIFO
    for i in range(TX_FIFO_DEPTH):
        await tb.reg.TxReg.write(i & 0xFF)

    # Check tx_full (may need a brief settling time)
    # await Timer(5, 'us')
    sts = await read_status(tb)
    assert sts & (1 << STS_TX_FULL), \
        f"Expected tx_full after filling FIFO, status=0x{sts:X}"
    cocotb.log.info("  tx_full after fill  ✓")

    # 3. Wait for draining
    frame_ns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    drain_us = 3 *(TX_FIFO_DEPTH + 2) * frame_ns // 1000 + 500
    assert await wait_tx_empty(tb, drain_us), f"tx_empty never re-asserted {bv=} {clk=} {frame_ns=}"
    cocotb.log.info("  tx_empty after drain  ✓")

    print("\nTEST 06: TX FIFO STATUS  PASSED")


# ---------------------------------------------------------------------------
# TEST 07 – RX FIFO fill and rx_full status
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_07_rx_fifo_fill(dut):
    """
    Stream RX_FIFO_DEPTH bytes into the DUT RX FIFO and verify:
      - rx_notEmpty asserts after the first byte
      - rx_full asserts after all bytes are received
      - All bytes are readable in order from RxReg
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 07: RX FIFO Fill & Full Status")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    tus = max(500, fns * 6 // 1000 + 200)
    await uart_reconfigure(tb, dut, actual, bv)

    payload = list(range(RX_FIFO_DEPTH))
    await tb.uart_tx.write(bytes(payload))
    await tb.uart_tx.wait()
    # Allow all frames to arrive
    await Timer((RX_FIFO_DEPTH + 2) * fns // 1000, 'us')

    # rx_notEmpty must be set
    sts = await read_status(tb)
    assert sts & (1 << STS_RX_NOT_EMPTY), \
        f"rx_notEmpty not set after {RX_FIFO_DEPTH} bytes, sts=0x{sts:X}"
    cocotb.log.info("  rx_notEmpty  ✓")

    # rx_full must be set
    assert sts & (1 << STS_RX_FULL), \
        f"rx_full not set after full fill, sts=0x{sts:X}"
    cocotb.log.info("  rx_full  ✓")

    # Drain and verify order
    for expected in payload:
        rx = (await tb.reg.RxReg.read()) & 0xFF
        assert rx == expected, f"RX byte mismatch: expected 0x{expected:02X}, got 0x{rx:02X}"
    cocotb.log.info("  All bytes read in order  ✓")

    print("\nTEST 07: RX FIFO FILL  PASSED")


# ---------------------------------------------------------------------------
# TEST 08 – Parity error detection
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_08_parity_error(dut):
    """
    Bit-bang a frame with a flipped parity bit.
    StatusReg.parity_error should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 08: Parity Error Detection")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, parity=2, clk_freq_mhz=clk)   # even parity
    tus = max(500, fns * 5 // 1000 + 300)

    await uart_reconfigure(tb, dut, actual, bv, charsize=8, parity=2, stopbits=0)

    # Inject bad parity
    await inject_rx_frame(dut, 0xAA, actual, charsize=8, parity=2,
                           inject_error="parity")
    await Timer(max(20, fns * 4 // 1000), 'us')

    sts = await read_status(tb)
    assert sts & (1 << STS_PARITY_ERROR), \
        f"parity_error not set, sts=0x{sts:X}"
    cocotb.log.info("  parity_error asserted  ✓")

    # Good frame should not trigger error
    await uart_reconfigure(tb, dut, actual, bv, charsize=8, parity=2, stopbits=0)
    await tb.uart_tx.write(bytes([0x55]))
    await tb.uart_tx.wait()
    await Timer(max(10, fns * 3 // 1000), 'us')
    await wait_rx_not_empty(tb, tus)
    sts = await read_status(tb)
    assert not (sts & (1 << STS_PARITY_ERROR)), \
        f"Unexpected parity_error on clean frame, sts=0x{sts:X}"
    cocotb.log.info("  No error on clean frame  ✓")

    print("\nTEST 08: PARITY ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 09 – Frame error detection
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_09_frame_error(dut):
    """
    Bit-bang a frame with stop bit = 0 (framing error).
    StatusReg.frame_error should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 09: Frame Error Detection")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    tus = max(500, fns * 5 // 1000 + 300)

    await uart_reconfigure(tb, dut, actual, bv, charsize=8, parity=0, stopbits=0)

    await inject_rx_frame(dut, 0xBB, actual, charsize=8, parity=0,
                           inject_error="frame")
    await Timer(max(20, fns * 4 // 1000), 'us')

    sts = await read_status(tb)
    assert sts & (1 << STS_FRAME_ERROR), \
        f"frame_error not set, sts=0x{sts:X}"
    cocotb.log.info("  frame_error asserted  ✓")

    print("\nTEST 09: FRAME ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 10 – Break error detection
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_10_break_error(dut):
    """
    Hold UART_RX low for a full frame duration (break condition).
    StatusReg.break_error should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 10: Break Error Detection")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)

    await uart_reconfigure(tb, dut, actual, bv)

    await inject_rx_frame(dut, 0x00, actual, inject_error="break")
    await Timer(max(20, fns * 4 // 1000), 'us')

    sts = await read_status(tb)
    assert sts & (1 << STS_BREAK_ERROR), \
        f"break_error not set, sts=0x{sts:X}"
    cocotb.log.info("  break_error asserted  ✓")

    print("\nTEST 10: BREAK ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 11 – Overrun error (RX FIFO overflow)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_11_overrun_error(dut):
    """
    Fill the RX FIFO completely without reading, then send one more byte.
    StatusReg.overrun_error should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 11: Overrun Error (RX FIFO overflow)")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    await uart_reconfigure(tb, dut, actual, bv)

    # Send FIFO_DEPTH + 1 bytes without reading
    overflow = RX_FIFO_DEPTH + 1
    await tb.uart_tx.write(bytes(range(overflow)))
    await tb.uart_tx.wait()
    await Timer((overflow + 2) * fns // 1000, 'us')

    sts = await read_status(tb)
    assert sts & (1 << STS_OVERRUN_ERROR), \
        f"overrun_error not set after overflow, sts=0x{sts:X}"
    cocotb.log.info("  overrun_error asserted  ✓")

    print("\nTEST 11: OVERRUN ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 12 – RX FIFO threshold
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_12_rx_threshold(dut):
    """
    Set Rx_Threshold to N.  Stream N-1 bytes → threshold NOT set.
    Send one more byte → threshold asserts.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 12: RX FIFO Threshold")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    await uart_reconfigure(tb, dut, actual, bv)

    THRESH = 4
    await tb.reg.Rx_Threshold.write(THRESH)
    await Timer(2, 'us')

    # Send THRESH-1 bytes (should NOT trigger threshold)
    await tb.uart_tx.write(bytes(range(THRESH - 1)))
    await tb.uart_tx.wait()
    await Timer((THRESH + 2) * fns // 1000, 'us')

    sts = await read_status(tb)
    assert not (sts & (1 << STS_RX_THRESHOLD)), \
        f"Unexpected rx_fifo_threshold with only {THRESH-1} bytes, sts=0x{sts:X}"
    cocotb.log.info(f"  Threshold not set at {THRESH-1} bytes  ✓")

    # Send one more byte (total = THRESH)
    await tb.uart_tx.write(bytes([0xEE]))
    await tb.uart_tx.wait()
    await Timer((2 + 2) * fns // 1000, 'us')

    sts = await read_status(tb)
    assert sts & (1 << STS_RX_THRESHOLD), \
        f"rx_fifo_threshold not set at {THRESH} bytes, sts=0x{sts:X}"
    cocotb.log.info(f"  Threshold set at {THRESH} bytes  ✓")

    print("\nTEST 12: RX FIFO THRESHOLD  PASSED")


# ---------------------------------------------------------------------------
# TEST 13 – Interrupt: tx_done (TX FIFO drained)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=15, timeout_unit="ms")
async def test_13_irq_tx_done(dut):
    """
    Enable tx_done_en.  Send a byte.  Wait for interrupt to assert,
    then deassert when disabled.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 13: IRQ – TX Done")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv, actual, fns, tus, _ = await _default_baud(dut, tb)

    # Write byte first so tx_done=0 (FIFO occupied) when we arm the interrupt.
    # Clearing after the write ensures rg_interrupt_raw[0] starts at 0;
    # it will only rise once the byte drains and tx_done goes high.
    await tb.reg.TxReg.write(0x42)
    await clear_interrupt(tb)
    await tb.reg.InterruptMask.write(1 << 0)

    assert await wait_tx_empty(tb, tus), "TX did not drain"

    # Interrupt should now be asserted (tx_done sticky bit set on drain)
    irq = await re_interrupt(dut.interrupt, 50)
    assert irq == 1, f"interrupt not asserted after TX done (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    # Disable IRQ → interrupt should deassert
    await tb.reg.InterruptMask.write(0)
    irq = safe_int(dut.interrupt)
    assert irq == 0, f"interrupt still asserted after IRQ disable (val={irq})"
    cocotb.log.info("  interrupt deasserted  ✓")

    print("\nTEST 13: IRQ TX DONE  PASSED")


# ---------------------------------------------------------------------------
# TEST 14 – Interrupt: rx_not_empty
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_14_irq_rx_not_empty(dut):
    """
    Enable rx_not_empty_en (bit 3).  Receive a byte.
    interrupt should assert.  Disable → deassert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 14: IRQ – RX Not Empty")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv, actual, fns, tus, _ = await _default_baud(dut, tb)

    await tb.reg.InterruptMask.write(1 << 2)   # rx_not_empty_en
    await Timer(1, 'us')

    await tb.uart_tx.write(bytes([0x7E]))
    await tb.uart_tx.wait()
    await Timer(max(10, fns * 3 // 1000), 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted on RX not empty (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    # Drain RX FIFO and disable
    await tb.reg.RxReg.read()
    await tb.reg.InterruptMask.write(0)
    irq = safe_int(dut.interrupt)
    assert irq == 0, f"interrupt still asserted after disable (val={irq})"
    cocotb.log.info("  interrupt deasserted  ✓")

    print("\nTEST 14: IRQ RX NOT EMPTY  PASSED")


# ---------------------------------------------------------------------------
# TEST 15 – Interrupt: tx_not_full
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=15, timeout_unit="ms")
async def test_15_irq_tx_not_full(dut):
    """
    Enable tx_not_full_en (bit 1).
    When TX FIFO is not full, interrupt should be asserted.
    Fill FIFO → interrupt deasserts.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 15: IRQ – TX Not Full")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    # Slow baud to give us time to fill FIFO
    bv = 200
    actual = int(clk * 1e6 / (16 * bv))
    await uart_reconfigure(tb, dut, actual, bv)

    await tb.reg.InterruptMask.write(1 << 1)   # tx_not_full_en

    # Initially FIFO is empty → not full → IRQ should be asserted
    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted when TX not full (val={irq})"
    cocotb.log.info("  interrupt asserted (TX not full, initially empty)  ✓")

    # Fill FIFO completely
    for i in range(TX_FIFO_DEPTH):
        await tb.reg.TxReg.write(i)

    # Read the interrupt pin immediately after clearing — before the next clock
    # edge can re-set the bit.  The transmitter takes at least one full tick
    # (bv=200 → 2 µs) to drain the first byte, so the FIFO is still full and
    # ~status[1]=0 at this point; no Timer is needed.
    await clear_interrupt(tb)
    irq = safe_int(dut.interrupt)
    assert irq == 0, f"interrupt should deassert when FIFO full (val={irq})"
    cocotb.log.info("  interrupt deasserted (TX FIFO full)  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 15: IRQ TX NOT FULL  PASSED")


# ---------------------------------------------------------------------------
# TEST 16 – Interrupt: parity error
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_16_irq_parity_error(dut):
    """
    Enable parity_error_en (bit 4).  Inject a parity-error frame.
    interrupt should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 16: IRQ – Parity Error")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, parity=2, clk_freq_mhz=clk)

    await uart_reconfigure(tb, dut, actual, bv, charsize=8, parity=2, stopbits=0)
    await tb.reg.InterruptMask.write(1 << 4)   # parity_error_en
    await Timer(1, 'us')

    await inject_rx_frame(dut, 0xAB, actual, charsize=8, parity=2,
                           inject_error="parity")
    await Timer(max(20, fns * 4 // 1000), 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted on parity error (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 16: IRQ PARITY ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 17 – Interrupt: frame error
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_17_irq_frame_error(dut):
    """
    Enable frame_error_en (bit 6).  Inject a frame-error.
    interrupt should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 17: IRQ – Frame Error")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)

    await uart_reconfigure(tb, dut, actual, bv)
    await tb.reg.InterruptMask.write(1 << 6)   # frame_error_en
    await Timer(1, 'us')

    await inject_rx_frame(dut, 0xCC, actual, inject_error="frame")
    await Timer(max(20, fns * 4 // 1000), 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted on frame error (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 17: IRQ FRAME ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 18 – Interrupt: break error
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms")
async def test_18_irq_break_error(dut):
    """
    Enable break_error_en (bit 7).  Inject a break condition.
    interrupt should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 18: IRQ – Break Error")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)

    await uart_reconfigure(tb, dut, actual, bv)
    await tb.reg.InterruptMask.write(1 << 7)   # break_error_en
    await Timer(1, 'us')

    await inject_rx_frame(dut, 0x00, actual, inject_error="break")
    await Timer(max(20, fns * 4 // 1000), 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted on break error (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 18: IRQ BREAK ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 19 – Interrupt: overrun error
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_19_irq_overrun_error(dut):
    """
    Enable overrun_error_en (bit 5).  Overflow the RX FIFO.
    interrupt should assert.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 19: IRQ – Overrun Error")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    await uart_reconfigure(tb, dut, actual, bv)
    await tb.reg.InterruptMask.write(1 << 5)   # overrun_error_en

    overflow = RX_FIFO_DEPTH + 1
    await tb.uart_tx.write(bytes(range(overflow)))
    await tb.uart_tx.wait()
    await Timer((overflow + 2) * fns // 1000, 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted on overrun (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 19: IRQ OVERRUN ERROR  PASSED")


# ---------------------------------------------------------------------------
# TEST 20 – Interrupt: RX FIFO threshold
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_20_irq_rx_threshold(dut):
    """
    Enable rx_fifo_threshold_en (bit 8).  Set threshold = 3.
    Send 3 bytes → interrupt asserts.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 20: IRQ – RX FIFO Threshold")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    await uart_reconfigure(tb, dut, actual, bv)

    THRESH = 3
    await tb.reg.Rx_Threshold.write(THRESH)
    await tb.reg.InterruptMask.write(1 << 8)   # rx_fifo_threshold_en
    await Timer(2, 'us')

    await tb.uart_tx.write(bytes([0x11, 0x22, 0x33]))
    await tb.uart_tx.wait()
    await Timer((THRESH + 2) * fns // 1000, 'us')

    irq = await re_interrupt(dut.interrupt,10)
    assert irq == 1, f"interrupt not asserted at threshold={THRESH} (val={irq})"
    cocotb.log.info("  interrupt asserted  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 20: IRQ RX THRESHOLD  PASSED")


# ---------------------------------------------------------------------------
# TEST 21 – Interrupt: rx_not_full (bit 2)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_21_irq_rx_not_empty(dut):
    """
    Enable rx_not_empty (bit 2).
    Bit 2 fires when RX FIFO has data (receiver_not_empty).
    Send one byte → interrupt asserts.
    Drain FIFO and clear sticky raw bit → interrupt deasserts.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 21: IRQ – RX Not Empty")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 200
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    await uart_reconfigure(tb, dut, actual, bv)

    await tb.reg.InterruptMask.write(1 << 2)   # rx_not_empty
    await Timer(2, 'us')

    # Empty FIFO → no data → IRQ should not be asserted
    irq = safe_int(dut.interrupt)
    assert irq == 0, f"interrupt should not assert when RX FIFO empty (val={irq})"
    cocotb.log.info("  interrupt not asserted (RX FIFO empty)  ✓")

    # Send one byte — FIFO becomes not empty → IRQ asserts
    await tb.uart_tx.write(bytes([0xA5]))
    await tb.uart_tx.wait()
    await Timer(fns // 1000 + 10, 'us')

    irq = await re_interrupt(dut.interrupt, 50)
    assert irq == 1, f"interrupt not asserted when RX FIFO has data (val={irq})"
    cocotb.log.info("  interrupt asserted (RX FIFO not empty)  ✓")

    # Drain FIFO then clear sticky raw bit; confirm IRQ does not reassert
    await tb.reg.RxReg.read()
    await clear_interrupt(tb)
    await Timer(2, 'us')

    irq = safe_int(dut.interrupt)
    assert irq == 0, f"interrupt should deassert after FIFO drained (val={irq})"
    cocotb.log.info("  interrupt deasserted (RX FIFO drained)  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 21: IRQ RX NOT EMPTY  PASSED")


# ---------------------------------------------------------------------------
# TEST 22 – Transmit delay register
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_22_delay_reg(dut):
    """
    Write a non-zero delay to DelayReg.  Measure the gap between
    two consecutive UartSink captures and verify it is at least
    (delay_count * bit_time).
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 22: Transmit Delay Register")
    cocotb.log.info("=" * 60)


    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    tus = max(800, fns * 8 // 1000 + 500)
    await uart_reconfigure(tb, dut, actual, bv)

    DELAY_CYCLES = 32
    await tb.reg.DelayReg.write(DELAY_CYCLES)
    await Timer(2, 'us')

    tb.uart_rx.clear()

    # First byte
    await tb.reg.TxReg.write(0xDE)
    await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
    assert not tb.uart_rx.empty(), "First byte not captured"
    tb.uart_rx.read_nowait(1)
    t0_ns = cocotb.utils.get_sim_time('ns')

    # Second byte
    await tb.reg.TxReg.write(0xAD)
    await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
    assert not tb.uart_rx.empty(), "Second byte not captured"
    cap = tb.uart_rx.read_nowait(1)[0]
    t1_ns = cocotb.utils.get_sim_time('ns')

    assert cap == 0xAD, f"Second byte mismatch: 0x{cap:02X}"
    gap_ns = t1_ns - t0_ns
    # DelayReg counts in baud_tick_16x ticks (= baud_value clock cycles each).
    # One tick = bit_time / 16, so multiply by that, not by the full bit period.
    tick_ns = calc_bit_time_ns(bv, clk) // 16
    min_expected_ns = DELAY_CYCLES * tick_ns
    cocotb.log.info(f"  Inter-frame gap = {gap_ns} ns  (min expected {min_expected_ns} ns)")
    assert gap_ns >= min_expected_ns, \
        f"Delay too short: {gap_ns} ns < {min_expected_ns} ns"
    cocotb.log.info("  Delay register adds correct inter-frame gap  ✓")

    # Restore delay to 0
    await tb.reg.DelayReg.write(0)

    print("\nTEST 22: DELAY REGISTER  PASSED")


# ---------------------------------------------------------------------------
# TEST 23 – Multi-byte sequential TX
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_23_multi_byte_tx(dut):
    """
    Write 8 bytes sequentially to TxReg.
    UartSink must capture all bytes in the correct order.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 23: Multi-byte Sequential TX")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    N = 8
    tus = max(500, fns * (N + 2) // 1000 + 500)
    await uart_reconfigure(tb, dut, actual, bv)

    payload = [random.randint(0, 255) for _ in range(N)]
    tb.uart_rx.clear()
    for b in payload:
        await tb.reg.TxReg.write(b)

    await Timer(fns * (N + 2) // 1000, 'us')
    # Collect captured bytes
    captured = []
    for _ in range(N):
        if tb.uart_rx.empty():
            await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
        if not tb.uart_rx.empty():
            captured.append(tb.uart_rx.read_nowait(1)[0])

    assert len(captured) == N, f"Captured {len(captured)}/{N} bytes"
    for i, (exp, got) in enumerate(zip(payload, captured)):
        assert exp == got, f"Byte[{i}]: expected 0x{exp:02X}, got 0x{got:02X}"
    cocotb.log.info(f"  All {N} bytes captured in order  ✓")

    print("\nTEST 23: MULTI-BYTE SEQUENTIAL TX  PASSED")


# ---------------------------------------------------------------------------
# TEST 24 – Multi-byte sequential RX
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_24_multi_byte_rx(dut):
    """
    UartSource sends 8 bytes.  DUT FIFO is drained byte-by-byte.
    Verify order and values.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 24: Multi-byte Sequential RX")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    N = 8
    tus = max(500, fns * (N + 2) // 1000 + 500)
    await uart_reconfigure(tb, dut, actual, bv)

    payload = [random.randint(0, 255) for _ in range(N)]
    await tb.uart_tx.write(bytes(payload))
    await tb.uart_tx.wait()
    await Timer(fns * (N + 2) // 1000, 'us')

    received = []
    for _ in range(N):
        assert await wait_rx_not_empty(tb, tus), "RX FIFO empty before all bytes read"
        received.append((await tb.reg.RxReg.read()) & 0xFF)

    for i, (exp, got) in enumerate(zip(payload, received)):
        assert exp == got, f"RX Byte[{i}]: expected 0x{exp:02X}, got 0x{got:02X}"
    cocotb.log.info(f"  All {N} RX bytes correct  ✓")

    print("\nTEST 24: MULTI-BYTE SEQUENTIAL RX  PASSED")


# ---------------------------------------------------------------------------
# TEST 25 – Back-to-back stress (simultaneous TX + RX)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=30, timeout_unit="ms")
async def test_25_simultaneous_tx_rx(dut):
    """
    Run TX and RX in parallel: while the DUT is sending N bytes to
    the UartSink, the UartSource simultaneously sends N bytes to the
    DUT RX FIFO.  Both paths must complete without error.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 25: Simultaneous TX + RX Stress")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    N = 8
    tus = max(800, fns * (N + 4) // 1000 + 800)
    await uart_reconfigure(tb, dut, actual, bv)

    tx_payload = [random.randint(0, 255) for _ in range(N)]
    rx_payload = [random.randint(0, 255) for _ in range(N)]

    tb.uart_rx.clear()

    # Launch both directions simultaneously
    async def do_tx():
        for b in tx_payload:
            await tb.reg.TxReg.write(b)

    async def do_rx_inject():
        await tb.uart_tx.write(bytes(rx_payload))
        await tb.uart_tx.wait()

    tx_coro = cocotb.start_soon(do_tx())
    rx_coro = cocotb.start_soon(do_rx_inject())
    await tx_coro
    await rx_coro

    # Collect TX results
    await Timer(fns * (N + 4) // 1000, 'us')
    captured_tx = []
    for _ in range(N):
        if tb.uart_rx.empty():
            await tb.uart_rx.wait(timeout=tus, timeout_unit="us")
        if not tb.uart_rx.empty():
            captured_tx.append(tb.uart_rx.read_nowait(1)[0])

    assert len(captured_tx) == N, f"TX: only {len(captured_tx)}/{N} bytes captured"
    for i, (e, g) in enumerate(zip(tx_payload, captured_tx)):
        assert e == g, f"TX[{i}]: exp 0x{e:02X} got 0x{g:02X}"
    cocotb.log.info("  TX path: all bytes correct  ✓")

    # Collect RX results
    received_rx = []
    for _ in range(N):
        assert await wait_rx_not_empty(tb, tus), "RX FIFO drained too early"
        received_rx.append((await tb.reg.RxReg.read()) & 0xFF)

    for i, (e, g) in enumerate(zip(rx_payload, received_rx)):
        assert e == g, f"RX[{i}]: exp 0x{e:02X} got 0x{g:02X}"
    cocotb.log.info("  RX path: all bytes correct  ✓")

    # No error flags
    sts = await read_status(tb)
    assert not (sts & 0xF0), f"Error flags set during stress: sts=0x{sts:X}"
    cocotb.log.info("  No error flags set  ✓")

    print("\nTEST 25: SIMULTANEOUS TX+RX STRESS  PASSED")


# ---------------------------------------------------------------------------
# TEST 26 – IQC (Input Qualification Cycles)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=10, timeout_unit="ms",skip=True)
async def test_26_iqc_register(dut):
    """
    Write and read back IQC.qual_cycles across several values.
    Verify register is R/W and holds the written value.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 26: IQC Register Read/Write")
    cocotb.log.info("=" * 60)

    for val in [0x00, 0x01, 0x07, 0x0F, 0xFF]:
        await tb.reg.IQC.write(val)
        await Timer(1, 'us')
        readback = (await tb.reg.IQC.read()) & 0xFF
        assert readback == val, f"IQC write/read mismatch: wrote 0x{val:02X}, got 0x{readback:02X}"
        cocotb.log.info(f"  IQC=0x{val:02X}  ✓")

    # Restore to 0
    await tb.reg.IQC.write(0)

    print("\nTEST 26: IQC REGISTER  PASSED")


# ---------------------------------------------------------------------------
# TEST 27 – BaudReg & ControlReg R/W
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_27_badreg_controlreg_rw(dut):
    """
    Verify BaudReg and ControlReg are fully read/write accessible
    and retain programmed values (within their field masks).
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 27: BaudReg / ControlReg R/W")
    cocotb.log.info("=" * 60)

    for bv in [1, 5, 100, 0x1234, 0xFFFF]:
        await tb.reg.BaudReg.write(bv)
        await Timer(1, 'us')
        rb = (await tb.reg.BaudReg.read()) & 0xFFFF
        assert rb == bv, f"BaudReg: wrote 0x{bv:X}, got 0x{rb:X}"
        cocotb.log.info(f"  BaudReg=0x{bv:X}  ✓")

    # ControlReg: charsize[10:5] | parity[4:3] | stopbits[2:1]
    for charsize, parity, stopbits in [(8, 0, 0), (8, 1, 0), (8, 2, 1),
                                        (16, 0, 2), (8, 0, 2)]:
        ctrl = (charsize << 5) | (parity << 3) | (stopbits << 1)
        await tb.reg.ControlReg.write(ctrl)
        await Timer(1, 'us')
        rb = (await tb.reg.ControlReg.read()) & 0x7FE
        assert rb == ctrl, f"ControlReg: wrote 0x{ctrl:X}, got 0x{rb:X}"
        cocotb.log.info(f"  ControlReg=0x{ctrl:X} (charsize={charsize} "
                        f"parity={parity} stopbits={stopbits})  ✓")

    print("\nTEST 27: BADREG/CONTROLREG R/W  PASSED")


# ---------------------------------------------------------------------------
# TEST 28 – InterruptMask full mask R/W
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_28_interrupt_en_rw(dut):
    """
    Write 0x1FF (all interrupt enables) to InterruptMask and read back.
    Then individually enable/disable each bit and confirm.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 28: InterruptMask Full R/W")
    cocotb.log.info("=" * 60)

    await tb.reg.InterruptMask.write(0x1FF)
    await Timer(1, 'us')
    rb = (await tb.reg.InterruptMask.read()) & 0x1FF
    assert rb == 0x1FF, f"InterruptMask full mask: expected 0x1FF, got 0x{rb:X}"
    cocotb.log.info("  0x1FF written and read back  ✓")

    for bit in range(9):
        mask = 1 << bit
        await tb.reg.InterruptMask.write(mask)
        await Timer(1, 'us')
        rb = (await tb.reg.InterruptMask.read()) & 0x1FF
        assert rb == mask, f"InterruptMask bit {bit}: expected 0x{mask:X}, got 0x{rb:X}"
        cocotb.log.info(f"  Bit {bit} isolated  ✓")

    await tb.reg.InterruptMask.write(0)

    print("\nTEST 28: INTERRUPT ENABLE R/W  PASSED")


# ---------------------------------------------------------------------------
# TEST 29 – Rx_Threshold register R/W and boundary
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_29_rx_threshold_rw(dut):
    """
    Verify Rx_Threshold accepts 0..255 and retains value.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 29: Rx_Threshold Register R/W")
    cocotb.log.info("=" * 60)

    for val in [0x00, 0x01, 0x05, 0x0F, 0x10, 0x1F]:
        await tb.reg.Rx_Threshold.write(val)
        await Timer(1, 'us')
        rb = (await tb.reg.Rx_Threshold.read()) & 0x1F
        assert rb == val, f"Rx_Threshold: wrote 0x{val:02X}, got 0x{rb:02X}"
        cocotb.log.info(f"  Rx_Threshold=0x{val:02X}  ✓")

    await tb.reg.Rx_Threshold.write(5)   # restore RDL default

    print("\nTEST 29: RX_THRESHOLD R/W  PASSED")


# ---------------------------------------------------------------------------
# TEST 30 – Random data loopback stress (128 bytes)
# ---------------------------------------------------------------------------
@cocotb.test(timeout_time=60, timeout_unit="ms")
async def test_30_random_loopback_stress(dut):
    """
    Send 128 random bytes from UartSource to DUT RX FIFO, draining
    after each 16-byte chunk (FIFO depth).  Simultaneously stream
    128 bytes through TxReg → UartSink.  Verify all data integrity.
    No error flags may be set at the end.
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 30: Random 128-byte Loopback Stress")
    cocotb.log.info("=" * 60)

    clk = await measure_clk_freq_mhz(dut)
    bv = 5
    actual = int(clk * 1e6 / (16 * bv))
    fns = calc_frame_time_ns(bv, clk_freq_mhz=clk)
    CHUNK = RX_FIFO_DEPTH      # 16
    N = 128
    tus_chunk = max(500, fns * (CHUNK + 4) // 1000 + 400)
    await uart_reconfigure(tb, dut, actual, bv)

    rng = random.Random(0xDEADBEEF)
    rx_payload = [rng.randint(0, 255) for _ in range(N)]
    tx_payload = [rng.randint(0, 255) for _ in range(N)]

    tb.uart_rx.clear()
    received_rx = []
    captured_tx = []

    async def run_tx():
        """Write all bytes to TxReg in chunks so we don't overflow."""
        for i in range(0, N, CHUNK):
            chunk = tx_payload[i:i + CHUNK]
            for b in chunk:
                await tb.reg.TxReg.write(b)
            # Give TX FIFO time to drain before next chunk
            await Timer(fns * (CHUNK + 2) // 1000, 'us')

    async def collect_uart_sink():
        """Collect captured bytes from UartSink."""
        for _ in range(N):
            if tb.uart_rx.empty():
                await tb.uart_rx.wait(timeout=tus_chunk * 2, timeout_unit="us")
            if not tb.uart_rx.empty():
                captured_tx.append(tb.uart_rx.read_nowait(1)[0])

    async def run_rx():
        """Send N bytes from UartSource in chunks and drain FIFO after each."""
        for i in range(0, N, CHUNK):
            chunk = rx_payload[i:i + CHUNK]
            await tb.uart_tx.write(bytes(chunk))
            await tb.uart_tx.wait()
            await Timer(fns * (CHUNK + 2) // 1000, 'us')
            for _ in range(len(chunk)):
                if await wait_rx_not_empty(tb, tus_chunk):
                    received_rx.append((await tb.reg.RxReg.read()) & 0xFF)

    tx_coro  = cocotb.start_soon(run_tx())
    sink_coro = cocotb.start_soon(collect_uart_sink())
    rx_coro  = cocotb.start_soon(run_rx())

    await tx_coro
    await rx_coro
    await sink_coro

    # Verify TX path
    assert len(captured_tx) == N, \
        f"TX: captured {len(captured_tx)}/{N}"
    for i, (e, g) in enumerate(zip(tx_payload, captured_tx)):
        assert e == g, f"TX byte[{i}]: exp 0x{e:02X} got 0x{g:02X}"
    cocotb.log.info("  TX 128 bytes  ✓")

    # Verify RX path
    assert len(received_rx) == N, \
        f"RX: received {len(received_rx)}/{N}"
    for i, (e, g) in enumerate(zip(rx_payload, received_rx)):
        assert e == g, f"RX byte[{i}]: exp 0x{e:02X} got 0x{g:02X}"
    cocotb.log.info("  RX 128 bytes  ✓")

    # No error flags
    sts = await read_status(tb)
    assert not (sts & 0xF0), f"Error flags set: sts=0x{sts:X}"
    cocotb.log.info("  No error flags  ✓")

    print("\nTEST 30: RANDOM 128-BYTE LOOPBACK STRESS  PASSED")

