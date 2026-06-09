"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-06
 Description: Comprehensive cocotb test suite for APB-to-I2C bridge.
              Trust nothing, check everything.

 Register Map (alignment=8):
   Commands @ 0x00  : start[0], read[1], write[2], write_multiple[3],
                       stop[4], enq[5](singlepulse), address[14:8]
   Status   @ 0x08  : busy[0], bus_control[1], bus_active[2],
                       missed_ack[3], cmd_ff_n_full[4], tx_ff_n_full[5],
                       rx_ff_n_full[6], rx_overflow[7]
   Cfg      @ 0x10  : prescale[15:0], stop_on_idle[16]
   Wdata    @ 0x18  : wdata[7:0], wlast[8]
   Rdata    @ 0x20  : rdata[7:0], rlast[8]

 I2C target: I2cMemory @ address 0x50, 256 bytes (EEPROM-style)
"""

import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from env import Env

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
I2C_ADDR        = 0x50
I2C_MEM_SIZE    = 256
MAX_POLL_US     = 5000   # hard timeout for any single poll loop
TRANSACTION_WAIT_US = 500  # generous wait after a transaction

# ---------------------------------------------------------------------------
# Boot helper (mirrors reference test_apb.py)
# ---------------------------------------------------------------------------
async def boot(dut, tb):
    cocotb.start_soon(Clock(dut.clk, 5, "ns").start())
    await tb.reset()
    tb.start()


# ---------------------------------------------------------------------------
# Low-level polling helpers
# ---------------------------------------------------------------------------
async def wait_not_busy(tb, timeout_us=MAX_POLL_US):
    """Spin-wait until busy==0. Raises on timeout."""
    elapsed = 0
    saw_missed_ack = 0
    sticky = {"missed_ack": 0, "rx_overflow": 0}
    while True:
        status_val = await tb.reg.Status.read_fields()
        busy = status_val['busy']
        sticky['missed_ack'] |= status_val['missed_ack']
        sticky['rx_overflow'] |= status_val['rx_overflow']

        if busy == 0:
            return sticky  # Return the "sticky" result
        assert elapsed < timeout_us, (
            f"DUT busy for more than {timeout_us} µs — possible hang"
        )
        await Timer(1, "us")
        elapsed += 1


async def wait_tx_ff_not_full(tb, timeout_us=MAX_POLL_US):
    """Spin-wait until tx FIFO has room."""
    elapsed = 0
    while True:
        not_full = await tb.reg.Status.tx_ff_n_full.read()
        if not_full == 1:
            return
        assert elapsed < timeout_us, "TX FIFO never drained — possible deadlock"
        await Timer(1, "us")
        elapsed += 1


async def wait_cmd_ff_not_full(tb, timeout_us=MAX_POLL_US):
    """Spin-wait until command FIFO has room."""
    elapsed = 0
    while True:
        not_full = await tb.reg.Status.cmd_ff_n_full.read()
        if not_full == 1:
            return
        assert elapsed < timeout_us, "CMD FIFO never drained — possible deadlock"
        await Timer(1, "us")
        elapsed += 1


async def wait_rx_ff_not_empty(tb, timeout_us=MAX_POLL_US):
    """Spin-wait until rx FIFO has data (rx_ff_n_full goes 0→1 means not full,
       but for 'has data' we read Rdata and check rlast; here we poll until
       rx_ff_n_full is 0 which means at least one byte arrived and FIFO is full,
       OR we just read and check the returned value is valid.
       In practice: read Rdata — the swacc attribute auto-advances the FIFO."""
    elapsed = 0
    while True:
        # rx_ff_n_full==0 means FIFO is full; ==1 means not full (could be empty).
        # We cannot distinguish empty vs partially filled from this bit alone.
        # Strategy: attempt read; if rdata changes from previous read it's valid.
        # Simplest approach for protocol correctness: wait for busy==0 first,
        # then read — the FIFO must have data by then.
        busy = await tb.reg.Status.busy.read()
        if busy == 0:
            return
        assert elapsed < timeout_us, "RX data never arrived"
        await Timer(1, "us")
        elapsed += 1


# ---------------------------------------------------------------------------
# High-level transaction helpers
# ---------------------------------------------------------------------------
async def i2c_write_bytes(tb, mem_addr, data_bytes, *, stop=True):
    """
    Write ``data_bytes`` to I2C target starting at ``mem_addr``.
    Uses write_multiple for >1 byte; single write for exactly 1 byte.

    Sends: START + ADDR(W) + mem_addr_byte + data... + STOP
    """
    assert len(data_bytes) >= 1
    is_multi = len(data_bytes) > 1

    # Enqueue command
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        # field_write=0 if is_multi else 1,
        write_multiple=1, # if is_multi else 0,
        stop=0,                 # stop comes after last data byte
        enq=1,
        field_address=I2C_ADDR,
    )

    # First byte is always the EEPROM internal memory address
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=mem_addr & 0xFF, wlast=0)

    # Payload bytes
    for idx, byte in enumerate(data_bytes):
        is_last = idx == len(data_bytes) - 1
        await wait_tx_ff_not_full(tb)
        await tb.reg.Wdata.write_fields(wdata=byte & 0xFF, wlast=1 if is_last else 0)

    if stop:
        await wait_cmd_ff_not_full(tb)
        await tb.reg.Commands.write_fields(
            start=0,
            field_read=0,
            field_write=0,
            write_multiple=0,
            stop=1,
            enq=1,
            field_address=I2C_ADDR,
        )

    missed_ack= await wait_not_busy(tb)
    return missed_ack


async def i2c_read_bytes(tb, mem_addr, count):
    """
    Read ``count`` bytes from I2C target starting at ``mem_addr``.

    EEPROM random-read sequence:
      1) Dummy write (no data) to set internal address pointer.
      2) Repeated START + ADDR(R) to clock out bytes.

    Returns list of ints.
    """
    assert count >= 1

    # Step 1: Dummy write to set address pointer (START + ADDR(W) + mem_addr, no STOP yet)
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        field_write=1,
        write_multiple=0,
        stop=0,
        enq=1,
        field_address=I2C_ADDR,
    )
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=mem_addr & 0xFF, wlast=1)

    # Step 2: Repeated START + READ
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=1,
        field_write=0,
        write_multiple=0,
        stop=1,
        enq=1,
        field_address=I2C_ADDR,
    )

    missed_ack = await wait_not_busy(tb)

    # Drain RX FIFO
    received = []
    for _ in range(count):
        raw = await tb.reg.Rdata.read()        # swacc pops the FIFO
        rdata = raw & 0xFF
        received.append(rdata)

    return received


# ===========================================================================
#  TEST 1 — Reset values of all registers
# ===========================================================================
@cocotb.test()
async def test_reset_values(dut):
    """Verify every register comes out of reset with the correct default value."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Commands: all fields default 0
    cmd_val = await tb.reg.Commands.read()
    assert cmd_val == 0x0000_0000, (
        f"Commands reset value wrong: 0x{cmd_val:08X} (expected 0x00000000)"
    )

    # Status: reset value not architecturally defined for hw=w fields,
    # but busy/missed_ack/rx_overflow should be 0; FIFO 'not-full' bits may be 1.
    status_val = await tb.reg.Status.read()
    busy       = (status_val >> 0) & 1
    missed_ack = (status_val >> 3) & 1
    rx_ov      = (status_val >> 7) & 1
    assert busy == 0,       f"busy should be 0 at reset, got {busy}"
    assert missed_ack == 0, f"missed_ack should be 0 at reset, got {missed_ack}"
    assert rx_ov == 0,      f"rx_overflow should be 0 at reset, got {rx_ov}"

    # Cfg: prescale=0, stop_on_idle=0
    cfg_val = await tb.reg.Cfg.read()
    assert cfg_val == 0x0000_0000, (
        f"Cfg reset value wrong: 0x{cfg_val:08X} (expected 0x00000000)"
    )

    # Wdata: sw=w so readback is not meaningful, but register must not error
    # Rdata: sw=r (hw-written); just read without asserting data value at reset
    # await tb.reg.Wdata.read()
    await tb.reg.Rdata.read()

    dut._log.info("PASS: test_reset_values")


# ===========================================================================
#  TEST 2 — Cfg register write/read-back (prescale + stop_on_idle)
# ===========================================================================
@cocotb.test()
async def test_cfg_register(dut):
    """Write/read-back Cfg register with various prescale and stop_on_idle values."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    test_vectors = [
        (0x0000, 0),
        (0x0001, 0),
        (0xFFFF, 0),
        (0x0004, 1),   # prescale=4, stop_on_idle=1
        (0x1234, 1),
        (0xABCD, 0),
    ]

    for prescale, soi in test_vectors:
        await tb.reg.Cfg.write_fields(prescale=prescale, stop_on_idle=soi)
        rb = await tb.reg.Cfg.read()
        rb_prescale = rb & 0xFFFF
        rb_soi      = (rb >> 16) & 1
        assert rb_prescale == prescale, (
            f"Cfg.prescale: wrote 0x{prescale:04X}, read back 0x{rb_prescale:04X}"
        )
        assert rb_soi == soi, (
            f"Cfg.stop_on_idle: wrote {soi}, read back {rb_soi}"
        )

    dut._log.info("PASS: test_cfg_register")


# ===========================================================================
#  TEST 3 — Status FIFO 'not-full' bits are set after reset (FIFOs empty)
# ===========================================================================
@cocotb.test()
async def test_status_fifo_bits_after_reset(dut):
    """After reset, cmd_ff_n_full and tx_ff_n_full must be 1 (FIFOs are empty/ready)."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    cmd_nf = await tb.reg.Status.cmd_ff_n_full.read()
    tx_nf  = await tb.reg.Status.tx_ff_n_full.read()

    assert cmd_nf == 1, f"cmd_ff_n_full should be 1 (not full) after reset, got {cmd_nf}"
    assert tx_nf  == 1, f"tx_ff_n_full should be 1 (not full) after reset, got {tx_nf}"

    dut._log.info("PASS: test_status_fifo_bits_after_reset")


# ===========================================================================
#  TEST 4 — Single-byte write, no missed-ACK (device present at 0x50)
# ===========================================================================
@cocotb.test()
async def test_single_byte_write_no_nak(dut):
    """Write one byte; verify device ACKs (missed_ack stays 0)."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    sticky = await i2c_write_bytes(tb, mem_addr=0x00, data_bytes=[0xA5])

    missed=sticky['missed_ack']
    #missed = await tb.reg.Status.missed_ack.read()
    assert missed == 0, f"missed_ack set after write to valid address: {missed}"

    dut._log.info("PASS: test_single_byte_write_no_nak")


# ===========================================================================
#  TEST 5 — Single-byte write → read-back roundtrip
# ===========================================================================
@cocotb.test()
async def test_single_byte_write_read_roundtrip(dut):
    """Write a known byte then read it back and confirm match."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    addr    = 0x10
    payload = 0xBE

    await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[payload])
    result = await i2c_read_bytes(tb, mem_addr=addr, count=1)

    assert result[0] == payload, (
        f"Readback mismatch at mem[0x{addr:02X}]: "
        f"wrote 0x{payload:02X}, got 0x{result[0]:02X}"
    )

    dut._log.info(f"PASS: test_single_byte_write_read_roundtrip  (0x{payload:02X} @ 0x{addr:02X})")


# ===========================================================================
#  TEST 6 — Multi-byte sequential write + readback
# ===========================================================================
@cocotb.test()
async def test_multi_byte_write_read(dut):
    """Write 8 consecutive bytes with write_multiple, read all back."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    start_addr = 0x20
    payload    = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]

    await i2c_write_bytes(tb, mem_addr=start_addr, data_bytes=payload)

    # Read back one byte at a time from each address
    for i, expected in enumerate(payload):
        result = await i2c_read_bytes(tb, mem_addr=start_addr + i, count=1)
        assert result[0] == expected, (
            f"Mismatch at mem[0x{start_addr+i:02X}]: "
            f"expected 0x{expected:02X}, got 0x{result[0]:02X}"
        )

    dut._log.info("PASS: test_multi_byte_write_read")


# ===========================================================================
#  TEST 7 — Random data: write N bytes, read entire region back
# ===========================================================================
@cocotb.test()
async def test_random_write_read_roundtrip(dut):
    """Write random data to a region, read it back byte-by-byte."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    rng         = random.Random(0xDEAD_BEEF)
    start_addr  = 0x40
    num_bytes   = 16
    payload     = [rng.randint(0, 0xFF) for _ in range(num_bytes)]

    await i2c_write_bytes(tb, mem_addr=start_addr, data_bytes=payload)

    errors = []
    for i, expected in enumerate(payload):
        result = await i2c_read_bytes(tb, mem_addr=start_addr + i, count=1)
        if result[0] != expected:
            errors.append(
                f"  mem[0x{start_addr+i:02X}]: expected 0x{expected:02X}, "
                f"got 0x{result[0]:02X}"
            )

    assert not errors, "Data integrity errors:\n" + "\n".join(errors)
    dut._log.info("PASS: test_random_write_read_roundtrip")


# ===========================================================================
#  TEST 8 — busy bit asserts during transaction, clears after
# ===========================================================================
@cocotb.test()
async def test_busy_during_transaction(dut):
    """Verify busy is asserted while a transaction is active."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Kick off a write
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        field_write=1,
        write_multiple=0,
        stop=1,
        enq=1,
        field_address=I2C_ADDR,
    )
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=0x00, wlast=0)
    await tb.reg.Wdata.write_fields(wdata=0x55, wlast=1)

    # Poll for busy==1 (within a reasonable window)
    saw_busy = False
    for _ in range(500):
        b = await tb.reg.Status.busy.read()
        if b == 1:
            saw_busy = True
            break
        await Timer(100, "ns")

    # Always wait for completion
    await wait_not_busy(tb)

    assert saw_busy, "busy bit never asserted during transaction"

    # After completion busy must be 0
    final_busy = await tb.reg.Status.busy.read()
    assert final_busy == 0, f"busy still set after transaction completed: {final_busy}"

    dut._log.info("PASS: test_busy_during_transaction")


# ===========================================================================
#  TEST 9 — tx FIFO backpressure: respect tx_ff_n_full
# ===========================================================================
@cocotb.test()
async def test_tx_fifo_backpressure(dut):
    """Push many bytes via write_multiple; always gate on tx_ff_n_full."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    start_addr = 0x00
    num_bytes  = 32
    payload    = list(range(num_bytes))

    # Enqueue multi-byte write command
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        field_write=0,
        write_multiple=1,
        stop=0,
        enq=1,
        field_address=I2C_ADDR,
    )

    # Memory address byte
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=start_addr, wlast=0)

    # Data bytes — gate each write on tx_ff_n_full
    for i, byte in enumerate(payload):
        await wait_tx_ff_not_full(tb)
        await tb.reg.Wdata.write_fields(
            wdata=byte, wlast=1 if i == len(payload) - 1 else 0
        )

    # Send STOP command
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=0, field_read=0, field_write=0,
        write_multiple=0, stop=1, enq=1,
        field_address=I2C_ADDR,
    )
    sticky = await wait_not_busy(tb)

    missed=sticky['missed_ack']
    # missed = await tb.reg.Status.missed_ack.read()
    assert missed == 0, "missed_ack set during back-pressure write"

    # Verify a sample of the written bytes
    for i in [0, 1, 15, 31]:
        result = await i2c_read_bytes(tb, mem_addr=start_addr + i, count=1)
        assert result[0] == payload[i], (
            f"Backpressure write: mem[{start_addr+i}] "
            f"expected {payload[i]}, got {result[0]}"
        )

    dut._log.info("PASS: test_tx_fifo_backpressure")


# ===========================================================================
#  TEST 10 — missed_ack detection: write to non-existent device
# ===========================================================================
@cocotb.test()
async def test_missed_ack_bad_address(dut):
    """Write to a device address with no listener; missed_ack must assert."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    BAD_ADDR = 0x7F   # Nothing listening here

    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        field_write=1,
        write_multiple=0,
        stop=1,
        enq=1,
        field_address=BAD_ADDR,
    )
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=0x00, wlast=0)
    await tb.reg.Wdata.write_fields(wdata=0xDE, wlast=1)

    sticky = await wait_not_busy(tb)

    missed=sticky['missed_ack']
    # missed = await tb.reg.Status.missed_ack.read()
    assert missed == 1, (
        f"missed_ack not set after writing to invalid address 0x{BAD_ADDR:02X}"
    )

    dut._log.info("PASS: test_missed_ack_bad_address")


# ===========================================================================
#  TEST 11 — Sequential independent transactions
# ===========================================================================
@cocotb.test()
async def test_sequential_transactions(dut):
    """Run multiple independent write→read sequences back-to-back."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    rng = random.Random(0xCAFE_BABE)
    N   = 8
    addrs   = rng.sample(range(0x00, 0xF0), N)
    payloads = [rng.randint(0, 0xFF) for _ in range(N)]

    # Write all
    for addr, data in zip(addrs, payloads):
        await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[data])

    # Verify all
    errors = []
    for addr, expected in zip(addrs, payloads):
        result = await i2c_read_bytes(tb, mem_addr=addr, count=1)
        if result[0] != expected:
            errors.append(
                f"  mem[0x{addr:02X}]: expected 0x{expected:02X}, "
                f"got 0x{result[0]:02X}"
            )

    assert not errors, "Sequential transaction errors:\n" + "\n".join(errors)
    dut._log.info("PASS: test_sequential_transactions")


# ===========================================================================
#  TEST 12 — Write-then-overwrite: verify new value visible
# ===========================================================================
@cocotb.test()
async def test_overwrite_same_address(dut):
    """Write a value, overwrite it, confirm readback shows the new value."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    addr = 0x30
    val1 = 0xAA
    val2 = 0x55

    await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[val1])
    rb1 = await i2c_read_bytes(tb, mem_addr=addr, count=1)
    assert rb1[0] == val1, f"Initial write: expected 0x{val1:02X}, got 0x{rb1[0]:02X}"

    await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[val2])
    rb2 = await i2c_read_bytes(tb, mem_addr=addr, count=1)
    assert rb2[0] == val2, (
        f"After overwrite: expected 0x{val2:02X}, got 0x{rb2[0]:02X} "
        f"(old value 0x{val1:02X} may be stuck)"
    )

    dut._log.info("PASS: test_overwrite_same_address")


# ===========================================================================
#  TEST 13 — Address boundary: first (0x00) and last (0xFF) addresses
# ===========================================================================
@cocotb.test()
async def test_address_boundaries(dut):
    """Exercise the first and last addresses in the 256-byte EEPROM."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    for addr, data in [(0x00, 0x11), (0xFF, 0xEE)]:
        await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[data])
        result = await i2c_read_bytes(tb, mem_addr=addr, count=1)
        assert result[0] == data, (
            f"Boundary address 0x{addr:02X}: expected 0x{data:02X}, "
            f"got 0x{result[0]:02X}"
        )

    dut._log.info("PASS: test_address_boundaries")


# ===========================================================================
#  TEST 14 — Data value boundaries: 0x00 and 0xFF
# ===========================================================================
@cocotb.test()
async def test_data_value_boundaries(dut):
    """Write 0x00 and 0xFF; confirm no corruption."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    for addr, data in [(0x50, 0x00), (0x51, 0xFF)]:
        await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[data])
        result = await i2c_read_bytes(tb, mem_addr=addr, count=1)
        assert result[0] == data, (
            f"Value boundary @ 0x{addr:02X}: expected 0x{data:02X}, "
            f"got 0x{result[0]:02X}"
        )

    dut._log.info("PASS: test_data_value_boundaries")


# ===========================================================================
#  TEST 15 — enq singlepulse: Commands register clears enq after write
# ===========================================================================
@cocotb.test()
async def test_enq_singlepulse_clears(dut):
    """enq[5] is singlepulse: readback of Commands must show enq==0."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Write with enq=1
    await tb.reg.Commands.write_fields(
        start=0, field_read=0, field_write=0,
        write_multiple=0, stop=0, enq=1,
        field_address=0x00,
    )

    # One cycle later, read back
    await RisingEdge(dut.clk)
    cmd_val = await tb.reg.Commands.read()
    enq_bit = (cmd_val >> 5) & 1

    assert enq_bit == 0, (
        f"enq singlepulse did not clear: Commands=0x{cmd_val:08X}, enq={enq_bit}"
    )

    dut._log.info("PASS: test_enq_singlepulse_clears")


# ===========================================================================
#  TEST 16 — Cfg prescale persists across a transaction
# ===========================================================================
@cocotb.test()
async def test_cfg_persists_across_transaction(dut):
    """Set a Cfg value, run a transaction, re-read Cfg — must be unchanged."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    prescale_val = 0x0004
    await tb.reg.Cfg.write_fields(prescale=prescale_val, stop_on_idle=0)

    # Run a transaction
    await i2c_write_bytes(tb, mem_addr=0x10, data_bytes=[0x42])

    # Re-read Cfg
    cfg_rb = await tb.reg.Cfg.read()
    rb_prescale = cfg_rb & 0xFFFF
    assert rb_prescale == prescale_val, (
        f"Cfg.prescale changed after transaction: "
        f"expected 0x{prescale_val:04X}, got 0x{rb_prescale:04X}"
    )

    dut._log.info("PASS: test_cfg_persists_across_transaction")


# ===========================================================================
#  TEST 17 — Commands fields are individually correct (bit-field encoding)
# ===========================================================================
@cocotb.test()
async def test_command_bit_field_encoding(dut):
    """Read back Commands after write and verify every bit field in isolation."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Write all SW-RW fields with known pattern; do NOT set enq (singlepulse)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=1,
        field_write=0,
        write_multiple=1,
        stop=1,
        enq=0,
        field_address=0x50,
    )

    raw = await tb.reg.Commands.read()

    def bit(r, pos):
        return (r >> pos) & 1

    assert bit(raw,  0) == 1,    f"start bit wrong in 0x{raw:08X}"
    assert bit(raw,  1) == 1,    f"read bit wrong in 0x{raw:08X}"
    assert bit(raw,  2) == 0,    f"write bit wrong in 0x{raw:08X}"
    assert bit(raw,  3) == 1,    f"write_multiple bit wrong in 0x{raw:08X}"
    assert bit(raw,  4) == 1,    f"stop bit wrong in 0x{raw:08X}"
    assert bit(raw,  5) == 0,    f"enq (singlepulse) should be 0 on readback"
    addr_field = (raw >> 8) & 0x7F
    assert addr_field == 0x50,   f"address field wrong: 0x{addr_field:02X} != 0x50"

    dut._log.info("PASS: test_command_bit_field_encoding")


# ===========================================================================
#  TEST 18 — bus_active deasserts after STOP
# ===========================================================================
@cocotb.test()
async def test_bus_active_after_stop(dut):
    """bus_active must be 0 once the transaction is fully complete."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    await i2c_write_bytes(tb, mem_addr=0x00, data_bytes=[0x5A])

    # wait_not_busy already ensures transaction is over
    bus_active = await tb.reg.Status.bus_active.read()
    assert bus_active == 0, (
        f"bus_active still set after STOP: {bus_active}"
    )

    dut._log.info("PASS: test_bus_active_after_stop")


# ===========================================================================
#  TEST 19 — Multiple writes to same page, then bulk-read verification
# ===========================================================================
@cocotb.test()
async def test_page_write_bulk_readback(dut):
    """Write a full 16-byte 'page', read back each byte individually."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    page_base = 0x60
    page_data = [i ^ 0x5A for i in range(16)]   # deterministic pattern

    await i2c_write_bytes(tb, mem_addr=page_base, data_bytes=page_data)

    errors = []
    for i, expected in enumerate(page_data):
        result = await i2c_read_bytes(tb, mem_addr=page_base + i, count=1)
        if result[0] != expected:
            errors.append(
                f"  mem[0x{page_base+i:02X}] expected 0x{expected:02X}, "
                f"got 0x{result[0]:02X}"
            )

    assert not errors, "Page write / readback errors:\n" + "\n".join(errors)
    dut._log.info("PASS: test_page_write_bulk_readback")


# ===========================================================================
#  TEST 20 — Stress: random write/read across entire address space
# ===========================================================================
@cocotb.test()
async def test_stress_full_address_space(dut):
    """
    Write random values to every 8th address in the EEPROM, then read all back.
    Gives ~32 transactions and exercises a wide span of addresses.
    """
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    rng = random.Random(0x1234_5678)

    addrs = list(range(0x00, 0xF8, 8))
    data  = {a: rng.randint(0, 0xFF) for a in addrs}

    # Write phase
    for addr, val in data.items():
        await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[val])

    # Verify phase
    errors = []
    for addr, expected in data.items():
        result = await i2c_read_bytes(tb, mem_addr=addr, count=1)
        if result[0] != expected:
            errors.append(
                f"  mem[0x{addr:02X}]: expected 0x{expected:02X}, "
                f"got 0x{result[0]:02X}"
            )

    assert not errors, (
        f"Stress test: {len(errors)} address(es) mismatched:\n" + "\n".join(errors)
    )
    dut._log.info(f"PASS: test_stress_full_address_space ({len(addrs)} addresses)")

@cocotb.test()
async def test_rx_overflow_detection(dut):
    """Trigger multiple reads without draining Rdata to force an RX overflow."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # 1. Setup Address pointer to 0x00

    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1,
        field_read=0,
        field_write=1,
        write_multiple=0,
        stop=0,
        enq=1,
        field_address=I2C_ADDR,
    )
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=0x10 & 0xFF, wlast=1)

    # Step 2: Repeated START + READ
    await wait_cmd_ff_not_full(tb)
    for i in range(10):
        await tb.reg.Commands.write_fields(
            start=1,
            field_read=1,
            field_write=0,
            write_multiple=0,
            stop=1,
            enq=1,
            field_address=I2C_ADDR,
        )
        await Timer(50,'us')

    # 3. Wait for transaction to finish WITHOUT reading Rdata
    status = await wait_not_busy(tb)

    # 4. Check overflow bit
    assert status["rx_overflow"] == 1, "rx_overflow bit was not set after FIFO saturation"
    dut._log.info("PASS: test_rx_overflow_detection")

@cocotb.test()
async def test_prescale_slow_clock(dut):
    """Run a transaction with a very high prescale (slow I2C clock)."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Set a high prescale value
    await tb.reg.Cfg.write_fields(prescale=0x00FF, stop_on_idle=0)

    addr = 0x05
    data = 0x77
    
    # This will take significantly longer in simulation time
    await i2c_write_bytes(tb, mem_addr=addr, data_bytes=[data])
    result = await i2c_read_bytes(tb, mem_addr=addr, count=1)

    assert result[0] == data, f"Slow clock readback failed: expected {data}, got {result[0]}"
    dut._log.info("PASS: test_prescale_slow_clock")

@cocotb.test()
async def test_repeated_start_bus_hold(dut):
    """Verify bus_active stays high when a transaction ends without a STOP."""
    tb = Env(dut, dut.clk, dut.arst_n)
    await boot(dut, tb)

    # Start a write but do NOT send a stop
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=1, field_read=0, field_write=1,
        write_multiple=0, stop=0, enq=1, 
        field_address=I2C_ADDR,
    )
    await wait_tx_ff_not_full(tb)
    await tb.reg.Wdata.write_fields(wdata=0x00, wlast=1)

    await wait_not_busy(tb)

    # bus_active should still be 1 because no STOP was issued
    active = await tb.reg.Status.bus_active.read()
    assert active == 1, "Bus went idle even though STOP bit was 0"

    # Now send the STOP manually
    await wait_cmd_ff_not_full(tb)
    await tb.reg.Commands.write_fields(
        start=0, field_read=0, field_write=0,
        write_multiple=0, stop=1, enq=1,
        field_address=I2C_ADDR,
    )
    await wait_not_busy(tb)
    await Timer(1,'us')
    
    active_after = await tb.reg.Status.bus_active.read()

    assert active_after == 0, "Bus failed to go idle after manual STOP"
    dut._log.info("PASS: test_repeated_start_bus_hold")
