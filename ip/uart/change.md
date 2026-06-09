# UART Change Request Prompts

These prompts document the bug fixes and feature changes applied to
`/opt/data/project/uart/` after the refactoring. Each prompt is self-contained and
references the specific file and location.

---

## CR-01 — Fix interrupt bit ordering for rx_not_empty and rx_full (tests 15, 21)

**Files**: `uart_cfg_regs.bsv`, `systemrdl/uart.rdl`, `bsv/uart.defines`

The `status` wire in `uart_cfg_regs.bsv` places `receiver_not_empty` at bit 2 and
`receiver_full` at bit 3. The `InterruptRaw` register defined in `uart.rdl` originally
named these `rx_not_full[2]` and `rx_not_empty[3]`, which is reversed relative to the
RTL signals.

Fix the SystemRDL to match the RTL signal assignments:
- Rename `InterruptRaw` bit 2 from `rx_not_full` to `rx_not_empty`
  (source: `pack(uart.receiver_not_empty)`).
- Rename `InterruptRaw` bit 3 from `rx_not_empty` to `rx_full`
  (source: `pack(uart.receiver_full)`).
- Apply the same rename to the matching fields in `InterruptMask` and `InterruptStatus`.
- Update the comment block for `InterruptEn` in `uart.defines` bits 2 and 3 to match.

After this change, regenerate the RAL model from `uart.rdl`.

---

## CR-02 — Fix tx_not_full interrupt bit polarity (test 15)

**File**: `uart_cfg_regs.bsv`, rule `rl_capture_interrupt_bits`

`status[1]` = `pack(uart.transmittor_full)` — it is 1 when the TX FIFO is full.
`InterruptRaw[1]` is defined as `tx_not_full` — it should be 1 when the TX FIFO has
space. The current rule ORs `status` directly:

```bsv
rg_interrupt_raw <= rg_interrupt_raw | status;
```

This means IRQ bit 1 fires when the FIFO IS full, which is the opposite of the intent.
Fix: invert bit 1 only when accumulating into the raw register, leaving the `status`
wire unchanged for StatusReg readback:

```bsv
rg_interrupt_raw <= rg_interrupt_raw | {status[15:2], ~status[1], status[0]};
```

---

## CR-03 — Remove `ifdef IQC` guards so the IQ_cycles register is always present (test 26)

**Files**: `uart_cfg_regs.bsv`, `bsv/uart.defines`

### What IQC does

IQC (Input Qualification Cycles) is a programmable digital glitch filter applied to the
UART SIN (RX) input pin. The module `mkiqc(rg_qual_cycles)` implements a hold-stable
debouncer: its `qualify(x)` ActionValue method samples the raw SIN bit on every
`baud_tick_16x` tick and only propagates a new value to `uart.rs232.sin()` once the
input has been stable (unchanged) for `rg_qual_cycles` consecutive ticks.

With `rg_qual_cycles = 0` (the reset default) the filter is transparent — the very
first sample is accepted and forwarded immediately, so UART behaviour is identical to
having no filter at all.

### Why it exists

Noise, coupling, and metastability on the SIN line can produce glitch pulses shorter
than one bit period. A sufficiently narrow glitch can look like a falling edge to a
bare UART receiver and trigger a false start-bit detection, corrupting the receive
stream. IQC rejects any transition that does not persist for at least `rg_qual_cycles`
16× oversampling ticks, providing a configurable rejection window without altering
the sampling position for valid data bits.

### Current problem

IQC is gated by `` `ifdef IQC `` in five separate places in `uart_cfg_regs.bsv`:

1. `import iqc::*;` at the top of the file.
2. The `rg_qual_cycles` register and `iqc <- mkiqc(rg_qual_cycles)` instantiation.
3. The `else if (addr[5:0]==\`IQ_cycles)` read decoder case.
4. The `else if (addr[5:0]==\`IQ_cycles)` write decoder case.
5. The `sin` method body, which switches between `iqc.qualify(x)` and the
   bare passthrough `let lv_qualified_inputs = x`.

The address definition itself is also inside an `` `ifdef IQC `` block in `uart.defines`:
```
`ifdef IQC
  `define IQ_cycles 'h18
`endif
```

When the design is compiled without `-D IQC`, all five guards collapse to dead code:
the register at 0x18 does not exist, reads return the default error response, the SIN
path bypasses the filter entirely, and any test that writes or reads `IQC.qual_cycles`
will always fail. The test for this feature (`test_26`) is permanently marked
`@pytest.mark.skip`.

### Fix

Remove all five `` `ifdef IQC `` / `` `endif `` guards in `uart_cfg_regs.bsv`:
- The `import iqc::*;` at the top of the file.
- The `rg_qual_cycles` and `iqc` instantiation block.
- The `else if (addr[5:0]==\`IQ_cycles)` read decoder case.
- The `else if (addr[5:0]==\`IQ_cycles)` write decoder case.
- The `` `ifdef IQC `` guard in the `sin` method that selects between
  `iqc.qualify(x)` and the passthrough.

Move `` `define IQ_cycles 'h18 `` in `uart.defines` outside its `` `ifdef IQC `` block
so the address is always defined.

After this change, `import iqc::*` must always be satisfied; ensure `iqc.bsv` is on the
compile path unconditionally. With `rg_qual_cycles` initialised to 0, existing tests are
unaffected — the filter passes every input on the first tick. Test_26 can be un-skipped.

---

## CR-04 — Fix test_13 interrupt arm-before-write sequencing (test 13)

**File**: `tb/ai/test_uart_suite.py`, `test_13_irq_tx_done`

`rl_capture_interrupt_bits` fires every clock. With an empty TX FIFO after reset,
`transmittor_empty=1` → `status[0]=1` → `rg_interrupt_raw[0]` is set immediately
after any clear. If the interrupt mask is enabled before writing a byte, the interrupt
fires from the stale empty-FIFO state, not from the actual TX-done event.

Reorder: write the byte to TxReg first (making `transmittor_empty=0`), then clear the
interrupt raw register, then enable the mask. The raw bit starts at 0 and only rises
when the byte finishes draining.

```python
await tb.reg.TxReg.write(0x42)      # FIFO occupied → tx_done=0
await clear_interrupt(tb)           # clears stale sticky bits
await tb.reg.InterruptMask.write(1 << 0)
assert await wait_tx_empty(tb, tus), "TX did not drain"
irq = await re_interrupt(dut.interrupt, 50)
assert irq == 1
```

---

## CR-05 — Fix test_21 for new rx_not_empty semantics (test 21)

**File**: `tb/ai/test_uart_suite.py`, `test_21_irq_rx_not_full` → `test_21_irq_rx_not_empty`

After CR-01, IRQ bit 2 fires when the RX FIFO has data (`receiver_not_empty=1`), not
when the FIFO is not-full. The original test asserts interrupt when the FIFO is empty
(expecting not-full semantics) and deasserts when full — both assertions are now
inverted.

Rewrite the test body:
1. Enable mask bit 2. Check `dut.interrupt == 0` (FIFO empty → `rx_not_empty=0` → no IRQ).
2. Send one byte via UartSource. Wait one frame period. Assert `re_interrupt == 1`.
3. Read the RX register to drain the byte. Call `clear_interrupt`. Wait 2 µs.
   Assert `dut.interrupt == 0`.

Rename the function to `test_21_irq_rx_not_empty` and update its docstring.

---

## CR-06 — Fix test_22 delay assertion: tick units vs bit-period units (test 22)

**File**: `tb/ai/test_uart_suite.py`, `test_22_delay_reg`

`DelayReg` counts in `baud_tick_16x` ticks. Each tick fires every `baud_value` clock
cycles. With `baud_value=5` and a 100 MHz clock one tick = 50 ns. One bit period = 16
ticks = 800 ns. The test computes:

```python
min_expected_ns = DELAY_CYCLES * calc_bit_time_ns(bv, clk)   # 32 × 800 = 25 600 ns
```

The actual inter-frame gap for `DELAY_CYCLES=32` is 32 × 50 = 1 600 ns, so the
assertion always fails. Fix:

```python
tick_ns = calc_bit_time_ns(bv, clk) // 16
min_expected_ns = DELAY_CYCLES * tick_ns
```

---

## CR-07 — Fix test_15 deassert check: remove Timer after clear_interrupt (test 15)

**File**: `tb/ai/test_uart_suite.py`, `test_15_irq_tx_not_full`

After filling the TX FIFO (16 bytes at AXI speed ≈ 1.6 µs), the transmitter starts
consuming bytes within one baud tick (2 µs at bv=200). The original sequence:

```python
await clear_interrupt(tb)
await Timer(2, 'us')          # ← FIFO drains during this wait
irq = safe_int(dut.interrupt) # → bit 1 re-set; always reads 1
```

The 2 µs Timer gives the rule time to re-fire with `~status[1]=1` (FIFO no longer full).
Fix: read `dut.interrupt` immediately after the AXI write completes, before the next
clock edge re-asserts the bit:

```python
await clear_interrupt(tb)
irq = safe_int(dut.interrupt)  # combinational read before next rising edge
assert irq == 0
```

---

## CR-08 — Fix read_status helper: read StatusReg not InterruptRaw (all tests using wait_tx_empty)

**File**: `tb/ai/test_uart_suite.py`, `read_status`

Current implementation:
```python
async def read_status(tb):
    rv = await tb.reg.InterruptRaw.read()
    await tb.reg.InterruptRaw.write(rv)   # XOR-clears interrupt bits!
    return rv
```

This reads the wrong register (InterruptRaw instead of StatusReg) and destroys interrupt
state on every call. `wait_tx_empty` calls this in a polling loop, clearing all pending
interrupts as a side-effect.

Fix:
```python
async def read_status(tb):
    return await tb.reg.StatusReg.read()
```

StatusReg is level-sensitive and has no write side-effects. The `STS_TX_EMPTY` bit
(bit 0) correctly reflects the current `transmittor_empty` signal.
