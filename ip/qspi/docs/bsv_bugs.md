# QSPI Silicon Bugs

Taped-out IP (`qspi_32_64_0`). No RTL fixes possible. Workarounds are in
`cocotb/cocotb_workaround.md`.

---

## Bug 1 — `if_abort` preempts all AXI reads when `cr_en = 0`

**File:** `bsv/qspi.bsv` ~line 754  
**Compiled signal:** `CAN_FIRE_RL_qspi_if_abort = qspi_cr_abort || !qspi_cr_en`

```bsv
Bool qspi_flush = (cr_abort == 1 || cr_en == 0);   // line ~307

(*preempts = "if_abort, rl_read_request_from_AXI"*)
rule if_abort(qspi_flush);
```

`if_abort` fires unconditionally on every clock when `cr_en = 0` (reset state) or
`cr_abort = 1`. The `(*preempts*)` attribute means `rl_read_request_from_AXI` can
never fire while `if_abort` is active. Any AXI read transaction enqueued in
`ff_rd_req` sits there forever — no response is ever sent and the AXI bus hangs.

**Secondary effect:** The SLVERR path inside `rl_read_request_from_AXI` (triggered
when the address falls inside the XiP MM range with wrong fmode — see Bug 2) also
executes `cr_en <= 0`. So a single failed register read re-disables the controller,
causing all subsequent reads to hang via this same rule.

**Impact:** Cannot read any register before the controller is enabled. A read issued
before `enable()` or with an incorrect address will deadlock the AXI bus.

**Note:** AXI writes are unaffected. `rl_write_request_from_AXI` does not appear in
the `if_abort` preempt set:
```verilog
// qspi_32_64_0.v
CAN_FIRE_RL_qspi_rl_write_request_from_AXI = ff_wr_req_dEMPTY_N && ff_wr_req_dD_OUT[99];
WILL_FIRE = CAN_FIRE && !WILL_FIRE_RL_qspi_rl_data_read_phase;  // no if_abort
```

---

## Bug 2 — `start_mm_addr = 0` routes all register reads through the XiP SLVERR path

**File:** `bsv/qspi_wrapper.bsv`

```bsv
module qspi_32_64_0#(Clock slow_clock, Reset slow_reset)(...);
    let _tmp <- mkqspi_axi4lite(slow_clock, slow_reset, 0, 'hffffff);
    //                                                   ^  ^^^^^^^^^
    //                                        start_mm_addr  end_mm_addr
```

The MM (memory-mapped / XiP) address range is hardcoded to `[0x0, 0xFFFFFF]`.

Inside `rl_read_request_from_AXI` the routing logic is:

```
if araddr in [start_mm_addr, end_mm_addr]:          // [0, 0xFFFFFF]
    if ccr_fmode != 2'b11 OR araddr > address_limit:
        → SLVERR response + cr_en <= 0              // always hit in non-XiP use
    else if sr_busy OR thres:
        → XiP burst continuation
    else:
        → access_register(araddr[7:0])              // only in XiP mode
else:                                               // araddr > 0xFFFFFF
    → access_register(araddr[7:0])                  // always correct
```

Compiled Verilog confirmation (`qspi_32_64_0.v`):
```verilog
// _d257 = (araddr <= 32'h00FFFFFF)
assign MUX_qspi_wr_rd_resp_wset_1__VAL_1 =
    _d257 ?
      ((fmode != 2'b11 || araddr > address_limit) ?
        67'h60000000000000000 :   // SLVERR
        { 3'd4, rdata__h18648 }) :  // XiP flash data
      { 3'd4, rdata__h21250 } ;   // register data  ← only when araddr > 0xFFFFFF
```

The register decode uses `qspi_ff_rd_req_D_OUT[10:3]` = `araddr[7:0]`, so the lower
8 bits correctly select the register regardless of the upper address bits.

**Root cause:** The design assumes the IP receives the **full 32-bit SoC address**
(base + offset). With the IP placed at `0x02003000` or `0x40003000` in the SoC, the
DUT sees araddr > `0xFFFFFF` for all register accesses and the `else` path
(access_register) is taken correctly. The `[0, 0xFFFFFF]` range is reserved for the
XiP flash window in the physical address map.

**Impact in simulation:** Bare register offsets `0x00`–`0x60` all satisfy
`araddr <= 0xFFFFFF`, so every register read returns SLVERR and clears `cr_en`.

---

## Bug 3 — `cr_abort` is never auto-cleared by `if_abort`

**File:** `bsv/qspi.bsv` lines 756-767

```bsv
rule if_abort(qspi_flush);   // fires while cr_abort==1 OR cr_en==0
   rg_phase <= Idle;
   ncs <= 1;
   sr_busy <= 0;
   thres <= False;
   ...
   fifo.clear();
endrule
```

`if_abort` resets all transaction state but never writes `cr_abort <= 0`. Combined
with Bug 1, this means that once software sets `CR.ABORT=1`, `if_abort` fires every
subsequent cycle and permanently blocks all AXI reads — the bus hangs even after the
transaction has been cancelled and `sr_busy` has been cleared.

Standard QSPI controllers (e.g. STM32 QUADSPI) auto-clear the abort bit once the
abort sequence completes. Shakti does not.

**Impact:** Any test that reads SR (or any other register) after issuing an abort
will deadlock unless it first writes `CR.ABORT=0`.

**Workaround:** After writing `CR` with ABORT=1, immediately write `CR` again with
ABORT=0 (keeping `CR_EN=1`) before issuing any AXI read. AXI writes are not
preempted by `if_abort`, so the clear write always succeeds. See
`cocotb_workaround.md` Workaround 4 for details.

---

## Bug 4 — DLR=N transfers exactly N bytes (not N+1)

**File:** `bsv/qspi.bsv` lines 1301-1352 (`rl_data_read_phase`, `rl_data_write_phase`)

The STM32 QSPI convention is DLR = number\_of\_bytes − 1 (so DLR=0 → 1 byte).
Shakti terminates the data phase when `count_byte == dlr` (line 1302), where
`count_byte` starts at 0 and is incremented AFTER each complete byte is
enqueued/dequeued. This means:

| DLR written | Bytes transferred |
|-------------|-------------------|
| 0           | 0 bytes (terminates on first clock edge before any byte completes) |
| 1           | 1 byte |
| N           | N bytes |

**Impact:** Any driver that uses the STM32 convention `DLR = N - 1` for N bytes
will transfer `N - 1` bytes instead of N.

**Workaround:** Write `DLR = N` for N bytes. See `cocotb_workaround.md` Workaround 6.

---

## Bug 5 — TCF is cleared by `delayed_sr_tcf_signal` in the same cycle `rl_reset_busy_signal` reads it

**File:** `bsv/qspi.bsv` lines 616-618, 770-793

When the last data byte is processed, `rl_data_read_phase` sets `sr_tcf <= 1`
directly (line 1346). In the very next cycle, both rules fire simultaneously:

- `rl_reset_busy_signal` reads `sr_tcf=1` → sets `sr_busy <= 0` ✓
- `delayed_sr_tcf_signal` fires (because `transfer_cond` is still True for
  this cycle since `sr_busy=1` is the stale value) → sets `sr_tcf <= delay_sr_tcf`
  where `delay_sr_tcf=0` (last set by an earlier phase) → **clears TCF back to 0**

Net result: `sr_busy=0`, `sr_tcf=0`. TCF is observable for zero clock cycles.
Reading SR after BUSY clears will always show TCF=0.

**Secondary effect (Bug 4 interaction):** Leftover `sr_tcf=1` from a completed
transaction causes `rl_reset_busy_signal` to abort the very next transaction in
its first cycle of BUSY=1. CS_N pulses for one clock cycle and the transaction
never runs. FCR must be written to clear TCF before the next transaction.

**Workaround:** Poll BUSY (not TCF) to detect completion; always clear FCR
(TCF+TEF) at the **start** of each new transaction. See `cocotb_workaround.md`
Workaround 6.

---

## Bug 6 — `dcr_fsize=0` at reset makes `address_limit=1`; any address > 1 sets TEF

**File:** `bsv/qspi.bsv` line 854 (`rule set_error_signal`)

```bsv
rule set_error_signal;
    Bit#(32) actual_address = 1 << dcr_fsize;   // fsize=0 at reset → limit = 1
    if (wr_address_written && ar > actual_address && (ccr_fmode=='b00 || ccr_fmode=='b01))
        sr_tef <= 1;
```

`wr_address_written` is a DReg that pulses True for one cycle after AR is written.
`set_error_signal` fires every cycle (no guard), preempted only by
`rl_write_request_from_AXI`. So on the cycle after AR is written, if the address
exceeds `1 << dcr_fsize`, TEF is immediately set.

At reset `dcr_fsize=0`, so `address_limit = 1`. Any address > 1 in INDIRECT_WRITE
or INDIRECT_READ mode sets TEF=1 one cycle after AR.write.

**Impact:** In simulation with default DCR, every indirect transaction to an address
> 1 asserts TEF. TEF does not abort the transaction (it is a status flag only), so
functional behaviour is unaffected for correct transactions. However, the TEF=1 in SR
is misleading and triggers TEIE interrupts if `cr_teie=1`.

**Note:** In the physical SoC the flash device is sized correctly and DCR.fsize is
programmed before use, so this does not fire in production.

**Workaround:** Either write `DCR.fsize` to a value large enough to cover the flash
address space before indirect transactions, or leave TEF asserted and ignore it in
testbench assertions (do not check SR.TEF unless specifically testing error paths).

---

## Bug 7 — `rl_data_wait` requires TX FIFO completely full (16 bytes) before starting indirect write

**File:** `bsv/qspi.bsv` line ~838 (`rule rl_data_wait`)

For an indirect write transaction **with address and data** (`ccr_admode≠0`, `ccr_dmode≠0`,
`ccr_fmode=00`):

- Writing CCR does **not** set `wr_instruction_written` (gated by `writeCCREffect` condition
  `x[11:10]==0` — only fires when `admode==0`).
- Writing AR does **not** set BUSY (the `rl_set_busy_signal` AR branch requires
  `ccr_fmode=='b01 || ccr_dmode=='d0 || ccr_fmode=='b10` — none match indirect write with data).
- Writing DR sets `wr_data_written` → `rg_phase = DataWait_phase`.

The transaction then waits in `rl_data_wait`:

```bsv
rule rl_data_wait(sr_busy==0 && rg_phase==DataWait_phase && cr_abort==0 && cr_en==1);
    if (fifo.count >= 16) begin   // FIFO must be COMPLETELY FULL
        sr_busy <= 1;
        ncs <= 0;
        ...
    end
endrule
```

The threshold is hardcoded to 16 (full FIFO depth). For any write of N < 16 bytes,
`fifo.count` never reaches 16 and the transaction never starts — CS_N never asserts.

**Impact:** Indirect writes of fewer than 16 data bytes never execute in simulation without
pre-filling the TX FIFO with padding.

**Note:** In the SoC, the flash page-program command typically writes 256 bytes in one
transaction (well above 16), so this threshold is rarely hit in production.

**Workaround:** After writing the N real data bytes, write (16 − N) zero-byte padding
values to DR. DLR controls how many bytes the SPI engine actually transmits; the remaining
padding bytes stay in the FIFO and are discarded on the next transaction's ABORT/reset.
See `cocotb_workaround.md` Workaround 8.

---

## Bug 8 — DR byte ordering is wrong for awsize≥2; DR read dequeues 4 bytes for arsize≥2

**File:** `bsv/qspi.bsv` `rl_write_request_from_AXI` / `rl_read_request_from_AXI`

The DR register has a fixed 32-bit byte-lane interpretation with no support for 64-bit (awsize=3):

**Write path:**
```bsv
if (awsize==0) begin
    temp[0] = wdata[7:0];        fifo.enq(1, temp)   // byte → temp[0] (first out) ✓
end else if (awsize==1) begin
    temp[0] = wdata[15:8];
    temp[1] = wdata[7:0];        fifo.enq(2, temp)   // MSB-first 16-bit
end else begin                   // awsize 2 or 3 — treated identically
    temp[0] = wdata[31:24];      // MSB of lower-32 → first byte transmitted
    temp[1] = wdata[23:16];
    temp[2] = wdata[15:8];
    temp[3] = wdata[7:0];        fifo.enq(4, temp)   // big-endian 32-bit
end
```

For a 64-bit AXI transaction (awsize=3) the upper 32 bits `wdata[63:32]` are silently
discarded. The SPI byte order follows `wdata[31:0]` in big-endian (MSB transmitted first).

**Consequence on a 64-bit AXI bus:** Any software that writes a single byte to DR using
a naturally-aligned 64-bit store places the byte in `wdata[7:0]`. The DUT transmits
`wdata[31:24] = 0x00` first, and the intended byte last. DLR=1 would then send `0x00`
instead of the intended value — **silent data corruption with no error indication.**

**Read path:**
```bsv
if (arsize==0) then deqReadyN(1) → fifo.first[0]          // 1 byte ✓
else if (arsize==1) then deqReadyN(2) → {first[0],first[1]}
else  /* arsize 2 or 3 */ then deqReadyN(4) → {first[0..3]}  // requires 4 bytes
```

`deqReadyN(4)` fails when fewer than 4 bytes are in the RX FIFO, and the rule falls
through to returning stale `rg_data` bits. Any read shorter than 4 bytes on a 64-bit
bus (arsize=3) returns wrong data.

**Root cause:** The IP was designed for a 32-bit AXI data bus. The `qspi_32_64_0` wrapper
exposes a 64-bit AXI slave but the DR access logic was never updated to handle awsize=3
or wdata[63:32]. The `else` branch treats awsize=3 identically to awsize=2.

**Impact in SoC:** A correctly-written RISC-V driver uses byte stores (`sb`) to write to
DR (awsize=0) and byte loads (`lb`) to read it (arsize=0), so production firmware is
unaffected. **Any 32- or 64-bit width store/load to the DR offset produces wrong results.**

**Workaround:** Hardcode `awsize=2'd0` and `arsize=2'd0` in the AXI wrapper (`tb_qspi.v`)
so all DR accesses use 8-bit lanes regardless of the AXI bus width.
See `cocotb_workaround.md` Workaround 8.

---

## Bug 9 — `rl_data_read_phase` overflows RX FIFO for DLR > 16

**File:** `bsv/qspi.bsv` lines 1264/1279/1292 (`rl_data_read_phase`)

```bsv
if (!first_read)
fifo.enq(1, temp);   // no fifo.enqReadyN(1) guard
count_byte = count_byte + 1;
```

In contrast to the DR write path (lines 428-429) which explicitly guards `fifo.enq`
with `if (fifo.enqReadyN(1))`, the data-read phase calls `fifo.enq` unconditionally
(gated only by `!first_read`, which is always False in indirect-read mode). When DLR
exceeds the FIFO depth (16 bytes), the MIMO circular-buffer write pointer wraps
around past the read pointer: after exactly 32 enqueues into a 16-deep FIFO the
5-bit count register returns to 0. `fifo.deqReadyN(1)` then reports False and all
DR reads return the stale `dr` shift-register value instead of received data.

The `dr` register holds the last 32-bit accumulation from the shift register:
`dr[31:0] = {byte_{N-3}, byte_{N-2}, byte_{N-1}, byte_N}` (big-endian, last 4 bytes
received). With `arsize=0` every DR read returns `duplicate(dr)[7:0]` = `byte_N` —
every read returns the same last byte received.

**Impact in simulation:** Indirect reads with `nbytes > 16` silently return wrong data
(last received byte repeated). No error flag is asserted.

**Impact in SoC:** A correctly written RISC-V driver reads DR bytes as they become
available (polling FTF or using the FTF interrupt) and never lets the FIFO fill
completely, so this path is not hit in production.

**Workaround:** Split indirect reads into ≤ 16-byte SPI transactions.
See `cocotb_workaround.md` Workaround 9.
