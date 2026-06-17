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

import cocotb
from uart_env import UARTEnv
from cocotb.triggers import Timer, RisingEdge, First
from cocotbext.uart import UartSource, UartSink, UartParity
import cocotb.result
import random
# --- Patch for float precision issue in cocotb ---
orig_timer_init = Timer.__init__
def patched_timer_init(self, time, *args, **kwargs):
    kwargs["round_mode"] = "round"
    orig_timer_init(self, time, *args, **kwargs)
Timer.__init__ = patched_timer_init
# -------------------------------------------------


# ==============================================================================
#  Constants
# ==============================================================================

# UART Register offsets (relative to 0x40004000)
UART_BASE       = 0x40004000
BAUD_REG_OFF    = 0x000
TX_REG_OFF      = 0x008
RX_REG_OFF      = 0x010
STATUS_REG_OFF  = 0x018
DELAY_REG_OFF   = 0x020
CONTROL_REG_OFF = 0x028
IRQ_EN_OFF      = 0x030
IQC_OFF         = 0x038
RX_THRESH_OFF   = 0x040

# Status register bit positions
STS_TX_EMPTY        = 0
STS_TX_FULL         = 1
STS_RX_NOT_EMPTY    = 2
STS_RX_FULL         = 3
STS_PARITY_ERROR    = 4
STS_OVERRUN_ERROR   = 5
STS_FRAME_ERROR     = 6
STS_BREAK_ERROR     = 7
STS_RX_THRESHOLD    = 8

# FIFO depth from RTL
TX_FIFO_DEPTH = 16
RX_FIFO_DEPTH = 16


# ==============================================================================
#  Helper: safe integer from potentially X/Z values
# ==============================================================================
def safe_int(logic_array):
    """Convert a cocotb LogicArray to int, masking X/Z to 0."""
    try:
        return logic_array.integer
    except ValueError:
        bin_str = logic_array.binstr.lower().replace('x', '0').replace('z', '0')
        return int(bin_str, 2)

async def _tb_init(dut) -> UARTEnv:
    tb = UARTEnv(dut)
    await tb.reset()
    tb.start()
    return tb

def calc_bit_time_ns(baud_val, clk_freq_mhz=1000.0):
    """Calculate the bit time in ns given baud_val and UART clock frequency."""
    if baud_val < 1:
        baud_val = 1
    clk_freq = clk_freq_mhz * 1e6
    baud = clk_freq / (16 * baud_val)
    return int(1e9 / baud)


def calc_frame_time_ns(baud_val, charsize=8, parity=0, stopbits=0, clk_freq_mhz=1000.0):
    """Calculate full frame time in ns (start + data + parity + stop)."""
    bt = calc_bit_time_ns(baud_val, clk_freq_mhz)
    nbits = 1 + charsize  # start + data
    if parity != 0:
        nbits += 1
    if stopbits == 0:
        nbits += 1       # 1 stop
    elif stopbits == 1:
        nbits += 2        # 1.5 → round to 2
    elif stopbits == 2:
        nbits += 2        # 2 stop
    return bt * nbits


async def measure_clk_freq_mhz(dut, num_cycles=8):
    """
    Measure the UART system clock (dut.CLK) frequency by timing
    N consecutive rising edges and averaging the period.

    Returns:
        float: clock frequency in MHz
    """
    import cocotb.utils
    # Align to a rising edge first
    await RisingEdge(dut.CLK)
    t0 = cocotb.utils.get_sim_time('ps')  # picosecond resolution
    for _ in range(num_cycles):
        await RisingEdge(dut.CLK)
    t1 = cocotb.utils.get_sim_time('ps')
    period_ps = (t1 - t0) / num_cycles
    freq_mhz = 1e6 / period_ps  # 1e12 ps/s / period_ps = Hz; /1e6 = MHz
    cocotb.log.info(
        f"Measured system_clk: period={period_ps:.1f}ps, freq={freq_mhz:.3f} MHz"
    )
    return freq_mhz


def calc_baud_val_for_target(target_baud, clk_freq_mhz):
    """
    Compute the integer baud_val register value to achieve a target baud rate.

    UART baud generator formula (from RTL):
        actual_baud = clk_freq / (16 * baud_val)
    So:
        baud_val = round(clk_freq / (16 * target_baud))

    Returns:
        (baud_val, actual_baud, error_pct)
        baud_val    -- integer register value (1 … 65535)
        actual_baud -- achieved baud rate (float)
        error_pct   -- % deviation from target
    Returns (None, None, None) if baud_val would be out of range [1, 0xFFFF].
    """
    clk_hz = clk_freq_mhz * 1e6
    baud_val_f = clk_hz / (16.0 * target_baud)
    baud_val = round(baud_val_f)
    if baud_val < 1 or baud_val > 0xFFFF:
        return None, None, None
    actual_baud = clk_hz / (16.0 * baud_val)
    error_pct = abs(actual_baud - target_baud) / target_baud * 100.0
    return baud_val, actual_baud, error_pct


# ==============================================================================
#  Common Setup Helpers
# ==============================================================================
async def uart_setup(tb, baud_val=10, charsize=8, parity=0, stopbits=0):
    """
    Configure UART registers for a test.
    Follows the GPIO TB style of register access via tb.reg.
    """
    # Enable UART in system configuration

    # Set baud rate
    await tb.reg.BaudReg.write(baud_val)

    # Set control register: charsize[10:5] | parity[4:3] | stopbits[2:1]
    ctrl_val = (charsize << 5) | (parity << 3) | (stopbits << 1)
    await tb.reg.ControlReg.write(ctrl_val)

    # Allow CDC propagation — register writes go through SyncFIFO
    await Timer(2, 'us')

    cocotb.log.info(f"UART configured: baud_val={baud_val}, charsize={charsize}, "
                    f"parity={parity}, stopbits={stopbits}")


async def read_status(tb):
    """Read and return the UART StatusReg value (read-only register)."""
    val = await tb.reg.StatusReg.read()
    return val


async def wait_tx_empty(tb, timeout_us=500):
    """Poll StatusReg until tx_empty is asserted."""
    # Each xSPI read takes ~1.3us, account for that in iteration count
    max_reads = max(10, int(timeout_us / 2))
    for _ in range(max_reads):
        status = await read_status(tb)
        if status & (1 << STS_TX_EMPTY):
            return True
        await Timer(1, 'us')
    cocotb.log.warning("wait_tx_empty: TIMEOUT")
    return False


async def wait_rx_not_empty(tb, timeout_us=500):
    """Poll StatusReg until rx_notEmpty is asserted."""
    max_reads = max(10, int(timeout_us / 2))
    for _ in range(max_reads):
        status = await read_status(tb)
        if status & (1 << STS_RX_NOT_EMPTY):
            return True
        await Timer(1, 'us')
    cocotb.log.warning("wait_rx_not_empty: TIMEOUT")
    return False


# ==============================================================================
#  UART Model Helpers
# ==============================================================================

def _parity_int_to_enum(parity_int):
    """Convert DUT parity encoding (0=none, 1=odd, 2=even) to UartParity enum."""
    return {0: UartParity.NONE, 1: UartParity.ODD, 2: UartParity.EVEN}.get(
        parity_int, UartParity.NONE)


def _stopbits_int_to_float(stopbits_int):
    """Convert DUT stop-bits encoding (0=1, 1=1.5, 2=2) to float."""
    return {0: 1.0, 1: 1.5, 2: 2.0}.get(stopbits_int, 1.0)


async def uart_reconfigure(tb, dut, target_baud, baud_val,
                            charsize=8, parity=0, stopbits=0):
    """
    Reconfigure both the DUT UART registers and the cocotbext UartSource/UartSink
    models to use the given target baud rate.

    Parameters
    ----------
    tb          : UARTEnv instance
    dut         : cocotb DUT handle
    target_baud : target baud rate in bps (used by UartSource / UartSink)
    baud_val    : integer BaudReg value computed from measured PRCM clock
    charsize    : data bits (8 or 16)
    parity      : 0=none, 1=odd, 2=even
    stopbits    : 0=1, 1=1.5, 2=2

    The UartSource/UartSink only ever see the real target baud rate — no DUT
    clock information is passed to them, exactly as in real hardware.
    """
    parity_enum   = _parity_int_to_enum(parity)
    stop_float    = _stopbits_int_to_float(stopbits)
    bits_per_word = charsize if charsize <= 8 else 8  # cocotbext works per-byte

    # Update UartSource attributes — _restart() kills the old coroutine internally
    tb.uart_tx._baud      = target_baud
    tb.uart_tx._bits      = bits_per_word
    tb.uart_tx._stop_bits = stop_float
    tb.uart_tx._parity    = parity_enum
    tb.uart_tx._restart()

    # Update UartSink attributes and drain stale bytes
    tb.uart_rx._baud      = target_baud
    tb.uart_rx._bits      = bits_per_word
    tb.uart_rx._stop_bits = stop_float
    tb.uart_rx._parity    = parity_enum
    tb.uart_rx._restart()
    tb.uart_rx.clear()

    cocotb.log.info(
        f"uart_reconfigure: target_baud={target_baud} bps, baud_val={baud_val}, "
        f"charsize={charsize}, parity={parity}, stopbits={stopbits}"
    )

    # Configure DUT BaudReg + ControlReg
    await uart_setup(tb, baud_val=baud_val, charsize=charsize,
                     parity=parity, stopbits=stopbits)


async def inject_rx_error_frame(dut, data, target_baud, charsize=8,
                                 parity=0, inject_error="none"):
    """
    Bit-bang a UART frame directly on dut.UART_RX to inject protocol errors
    (parity, frame, break) that the UartSource model cannot produce.

    The bit time is derived from target_baud (bps), NOT from the DUT clock.
    This matches real hardware: the transmitter timing is its own clock domain.

    Parameters
    ----------
    inject_error : "parity" | "frame" | "break" | "none"
    """
    bit_ns = int(1e9 / target_baud)

    # === Break: hold line low for entire frame duration ===
    if inject_error == "break":
        total_bits = 1 + charsize + (1 if parity else 0) + 1
        dut.UART_RX.value = 0
        await Timer(bit_ns * (total_bits + 2), units='ns')
        dut.UART_RX.value = 1
        await Timer(bit_ns, units='ns')
        return

    # === Start bit ===
    dut.UART_RX.value = 0
    await Timer(bit_ns, units='ns')

    # === Data bits (LSB first) ===
    mask = (1 << charsize) - 1
    data = data & mask
    parity_calc = 0
    for i in range(charsize):
        bit = (data >> i) & 1
        dut.UART_RX.value = bit
        parity_calc ^= bit
        await Timer(bit_ns, units='ns')

    # === Parity bit ===
    if parity != 0:
        parity_bit = (1 - parity_calc) if parity == 1 else parity_calc  # odd / even
        if inject_error == "parity":
            parity_bit = 1 - parity_bit  # flip to inject error
        dut.UART_RX.value = parity_bit
        await Timer(bit_ns, units='ns')

    # === Stop bit ===
    dut.UART_RX.value = 0 if inject_error == "frame" else 1
    await Timer(bit_ns, units='ns')

    # Return to idle
    dut.UART_RX.value = 1
    await Timer(bit_ns, units='ns')





@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_02_smoke_tx_rx(dut):
    """Basic smoke: TxReg → UartSink, UartSource → DUT RX FIFO."""
    tb = await _tb_init(dut)

    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 02: UART Smoke TX/RX Test")
    cocotb.log.info("=" * 60)

    clk_freq_mhz = await measure_clk_freq_mhz(dut)
    cocotb.log.info(f"Measured system_clk = {clk_freq_mhz:.3f} MHz")

    BAUD_VAL = 5
    actual_baud = int(clk_freq_mhz * 1e6 / (16 * BAUD_VAL))
    frame_ns   = calc_frame_time_ns(BAUD_VAL, 8, clk_freq_mhz=clk_freq_mhz)
    timeout_us = max(500, frame_ns * 5 // 1000 + 100)
    cocotb.log.info(f"baud_val={BAUD_VAL} → {actual_baud} bps, timeout={timeout_us}us")
    await uart_reconfigure(tb, dut, actual_baud, BAUD_VAL, charsize=8, parity=0, stopbits=0)

    # --- TX: DUT → UartSink ---
    cocotb.log.info("--- TX Path: TxReg → UartSink ---")
    tb.uart_rx.clear()
    await tb.reg.TxReg.write(0xA5)
    await tb.uart_rx.wait(timeout=timeout_us, timeout_unit="us")
    if not tb.uart_rx.empty():
        tx_captured = tb.uart_rx.read_nowait(1)[0]
        cocotb.log.info(f"TX captured by UartSink: 0x{tx_captured:02X}")
        assert tx_captured == 0xA5, f"TX mismatch: expected 0xA5, got 0x{tx_captured:02X}"
    else:
        cocotb.log.warning("UartSink did not capture TX byte")
    await wait_tx_empty(tb, timeout_us=timeout_us)

    # --- RX: UartSource → DUT FIFO ---
    cocotb.log.info("--- RX Path: UartSource → DUT FIFO ---")
    await tb.uart_tx.write(bytes([0x5A]))
    await tb.uart_tx.wait()
    await Timer(max(10, frame_ns * 3 // 1000), 'us')
    if await wait_rx_not_empty(tb, timeout_us=timeout_us):
        rx_val = await tb.reg.RxReg.read()
        rx_val &= 0xFF
        cocotb.log.info(f"RX from DUT FIFO: 0x{rx_val:02X}")
        assert rx_val == 0x5A, f"RX mismatch: expected 0x5A, got 0x{rx_val:02X}"
    else:
        cocotb.log.error("RX FIFO never became non-empty!")

    cocotb.log.info("TEST 02: SMOKE TEST PASSED")
    print("\n" + "=" * 60)
    print("TEST 02: SMOKE TX/RX TEST PASSED")
    print("=" * 60)

