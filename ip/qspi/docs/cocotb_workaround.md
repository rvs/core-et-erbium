# cocotb Workarounds for QSPI Silicon Bugs

See `../bsv_bugs.md` for root-cause analysis.

---

## Workaround 1 — Use full SoC base address for all register accesses (Bug 2)

**Addresses:** `bsv_bugs.md` Bug 2 (`start_mm_addr = 0`)

In the real SoC the AXI interconnect forwards the **full 32-bit address** to the
QSPI slave port. Because the IP is placed at `0x02003000` (instance 0) or
`0x40003000` (instance 1), the DUT always sees `araddr > 0xFFFFFF` and correctly
routes to `access_register()`.

In cocotb there is no AXI interconnect, so the testbench must supply the base address
explicitly. Both env classes now accept a `base` constructor parameter:

```python
# Instance 0 (default)
env = QSPIEnv(dut)                        # base=0x02003000
env = QSPIEnv(dut, base=0x02003000)

# Instance 1
env = QSPIEnv(dut, base=0x40003000)

# Same for Env
env = Env(dut, base=0x40003000)
```

Every register access in `_read`, `_write`, `_AxiHelper.read`, and
`_AxiHelper.write` prepends `self._base` to the register offset before driving
the AXI address bus.

**Why it works:** After the testbench's `>> 1` shift (`tb_qspi.v` line 64/76):

```
DUT araddr = (base + reg_offset) >> 1
           = (0x02003000 + offset) >> 1
           = 0x01001800 + (offset >> 1)
```

`0x01001800 > 0x00FFFFFF` → the `_d257` MM-range check fails → `access_register()`
is taken. The register decode uses `araddr[7:0] = (offset >> 1)[7:0]`, which is
identical to what it would be without the base — no register aliasing.

---

## Workaround 2 — Direct write to CR for `enable()`, no read-modify-write (Bug 1)

**Addresses:** `bsv_bugs.md` Bug 1 (`if_abort` preempts reads when `cr_en = 0`)

At reset `cr_en = 0`, so `if_abort` fires every cycle and any AXI read hangs.
`enable()` must not issue a read before setting `cr_en = 1`.

**Before (broken):**
```python
async def enable(self):
    cr = await self.reg.CR.read()          # hangs — cr_en=0 blocks reads
    await self.reg.CR.write(cr | (1 << CR_EN))
```

**After (fixed):**
```python
async def enable(self):
    # AXI writes are not blocked by if_abort
    await self.axim.write(self._base + QspiRegs.CR, (1 << CR_EN).to_bytes(8, "little"))
```

Writes go through `rl_write_request_from_AXI` which has no `if_abort` dependency.

**Implication:** `enable()` always writes `CR = 0x00000001` (only `QSPI_ENABLE`
set, all other fields zeroed). If the prescaler or other CR fields need to be
configured, write them in the same call or after `enable()` via a full register
write — do not attempt read-modify-write before the IP is enabled.

---

## Workaround 3 — Write CCR before AR in indirect transactions

**Addresses:** Incorrect transaction trigger ordering (testbench bug, not silicon)

Per the programming guide (`doc/qspi.md`), writing AR triggers the SPI transaction.
CCR must be fully configured first. The env previously had these reversed.

**Indirect write sequence (corrected):**
```
DLR → CCR (FMODE=00, configure mode) → AR (trigger) → DR (fill FIFO)
```

**Indirect read sequence (corrected):**
```
DLR → CCR (FMODE=01, configure mode) → AR (trigger) → read DR
```

Applied to all four methods: `QSPIEnv.indirect_write`, `QSPIEnv.indirect_read`,
`Env.indirect_write`, `Env.indirect_read`.

---

## Workaround 4 — Clear CR.ABORT before polling SR (Bug 3)

**Addresses:** `bsv_bugs.md` Bug 3 (`cr_abort` never auto-cleared by `if_abort`)

After writing `CR.ABORT=1` to cancel a transaction, `if_abort` fires every cycle
and (via Bug 1's `(*preempts*)`) blocks every subsequent AXI read. `sr_busy` is
cleared immediately by `if_abort`, but you can never observe it while ABORT=1.

**Sequence:**
```python
await tb.reg.CR.write(cr | (1 << 1))   # CR.abort = 1  (triggers abort)
await tb.reg.CR.write(cr & ~(1 << 1))  # CR.abort = 0  (clear so reads work)
cleared = await tb.poll_not_busy(...)
```

AXI writes are not preempted by `if_abort`, so the second write always succeeds.
By the time the first AXI write completes, `if_abort` has already fired (CS_N
deasserts before the write-response comes back on the AXI bus), so clearing ABORT
on the next write does not race with the abort sequence itself.

---

## Workaround 6 — DLR=N for N bytes; clear FCR at the START of each transaction (Bugs 4+5)

**Addresses:** `bsv_bugs.md` Bug 4 (DLR=N → N bytes) and Bug 5 (TCF immediately cleared)

**DLR convention:** Write `DLR = N` for N bytes. The STM32 convention `DLR = N-1`
transfers `N-1` bytes in Shakti.

**FCR clear at START of each transaction:** `sr_tcf` from a completed transaction
persists into the next. `rl_reset_busy_signal` fires every cycle while `sr_busy=1`
and immediately clears BUSY when `sr_tcf=1` (indirect write/read modes). This kills
the new transaction in its very first cycle — CS_N never asserts.

Write `FCR = 0x3` (clear TCF + TEF) at the **beginning** of each indirect method,
before DLR/CCR/AR:
```python
await self.reg.FCR.write(0x3)   # bit 1 = ctcf, bit 0 = ctef  ← FIRST thing
await self.reg.DLR.write(nbytes)
...
await self.reg.AR.write(addr)
await self.poll_not_busy()
# Do NOT clear FCR here — leave TCF intact for callers (e.g. interrupt tests)
```

Clearing at START (not END) also preserves the current transaction's TCF for the
caller, which is needed when `cr_tcie=1` and the caller polls the interrupt pin.

**Read ordering:** For indirect reads, call `poll_not_busy()` BEFORE reading DR.
The FIFO is not populated until BUSY clears. Reading DR while BUSY=1 returns
stale or zero data.

```python
# Correct indirect read sequence:
await self.reg.FCR.write(0x3)       # clear TCF+TEF from PREVIOUS transaction
await self.reg.DLR.write(nbytes)    # DLR=N for N bytes
await self.reg.CCR.write(ccr)
await self.reg.AR.write(addr)       # triggers transfer
await self.poll_not_busy()          # wait for FIFO to fill
for _ in range(nbytes):
    val = await self.reg.DR.read()
# TCF left intact — cleared at start of next transaction
```

**FTF threshold:** Shakti FTF fires when `fifo_count >= cr_fthres + 1`. To fire
when exactly N bytes are in the FIFO, set `cr_fthres = N - 1`.

---

## Workaround 7 — CS_N abort detection in flash model send/receive paths

**Addresses:** `SpiFlashModel._recv_bit` sampling wrong SCK edge; `SpiFlashModel._send_bit` getting stuck after the last data byte of a read.

### `_recv_bit` — sample on SCK falling edge

From BSV `rl_generate_clk_from_master`: when `rg_clk` transitions 1→0 (SCK falls),
`wr_sdr_clock` is driven True in that same non-blocking delta, which fires
`rl_transfer_instruction` and updates `rg_output` (MOSI). Sampling on `RisingEdge(sck)`
reads the stale value — every received byte is right-shifted by 1.

**After (fixed):**
```python
async def _recv_bit(self) -> int:
    trigger = await First(FallingEdge(self.dut.qspi_sck), RisingEdge(self.dut.qspi_cs_n))
    if self._cs_high():
        raise RuntimeError("CS_N deasserted mid-transaction")
    ...
```

### `_send_bit` — abort if CS_N rises before the next SCK edge

After the DUT receives the last data bit of an indirect read (determined by DLR), it
deasserts CS_N one BSV clock cycle after the final SCK falling edge. The flash model's
`_send_byte` loop checks `_cs_high()` AFTER `_send_bit` returns, but at that point CS_N
is still low. The loop attempts a second byte: `_send_bit` waits for the next
`FallingEdge(sck)` which never comes (DUT has stopped SCK). The model is stuck.

When the next transaction starts, its first SCK edge fires the stuck `_send_bit`, driving
incorrect MISO bits into the new transaction's data phase.

**After (fixed):**
```python
async def _send_bit(self, bit: int):
    trigger = await First(FallingEdge(self.dut.qspi_sck), RisingEdge(self.dut.qspi_cs_n))
    if self._cs_high():
        raise RuntimeError("CS_N deasserted mid-send")
    self.dut.qspi_dq_i.value = ((bit & 1) << 1) | 0xD
```

In both cases, the `RuntimeError` is caught by the `except Exception` handler in
`SpiFlashModel._run`, the `finally` block restores `qspi_dq_i = 0xF`, and the outer
loop waits correctly for the next `FallingEdge(qspi_cs_n)`.

---

## Workaround 8 — arsize=2'd0, awsize=2'd0 + pad TX FIFO to 16 bytes for indirect writes (Bugs 7 + DR byte ordering)

**Addresses:**
- `tb_qspi.v` arsize/awsize hardcoding
- `bsv_bugs.md` Bug 7 (`rl_data_wait` requires FIFO full)
- DR write byte ordering: BSV `else` branch (awsize≥2) puts `wdata[7:0]` in `temp[3]` (sent last), not `temp[0]` (sent first).

### arsize and awsize must both be 2'd0

**DR write path (awsize):**
```bsv
if (awsize==0)  temp[0]=wdata[7:0];  fifo.enq(1, temp)  // 1 byte, wdata[7:0] first ✓
else            temp[0]=wdata[31:24]; ... temp[3]=wdata[7:0]; fifo.enq(4, temp)
                                                           // 4 bytes, data byte last ✗
```
Python writes byte `b` as `b.to_bytes(8, "little")` → `wdata[7:0]=b`.
With awsize≥2: `temp[3]=b` is sent 4th; for DLR=1 only `temp[0]=0x00` is transmitted.

**DR read path (arsize):**
```bsv
if (arsize==0)  deqReadyN(1) → fifo.first[0]    // 1 byte per read ✓
else            deqReadyN(4) → {first[0..3]}     // needs 4 bytes in FIFO
```
For reads of N < 4 bytes, `deqReadyN(4)` fails and returns stale `rg_data`.

`tb_qspi.v` (both already applied):
```verilog
.slave_m_awvalid_awsize  (2'd0),
.slave_m_arvalid_arsize  (2'd0),
```
Non-DR register accesses are unaffected: the BSV write path ignores awsize for non-DR
addresses (`reg1 <= wdata[31:0]`), and register reads return the register value directly.

### Pad TX FIFO to 16 bytes for indirect writes with data (Bug 7)

For indirect write (fmode=00) with `admode≠0` and `dmode≠0`, the transaction starts
only when `fifo.count >= 16`. After writing the real data bytes, pad with zeros:

```python
for i, b in enumerate(data):
    if i >= 16:
        # Wait for FIFO space: FTF=1 in write mode means count < 16.
        while not ((await self.reg.SR.read() >> SR_FTF) & 1):
            await RisingEdge(self.dut.CLK)
    await self.reg.DR.write(b)
# Bug 7: rl_data_wait fires only when fifo.count >= 16. Pad to fill FIFO.
if len(data) > 0:
    for _ in range(max(0, 16 - len(data))):
        await self.reg.DR.write(0x00)
await self.poll_not_busy()
```

**Backpressure for N > 16 bytes:** The FIFO depth is 16. When N > 16, the first 16
DR writes fill the FIFO and trigger the transaction. Subsequent DR writes arrive at
~100 ns/write while the SPI drains at ~160 ns/byte. The testbench is faster than the
SPI, so bytes 17+ arrive while the FIFO is still full. The BSV `if (fifo.enqReadyN(1))`
guard silently drops those writes without error. The solution is to poll `SR.FTF` before
each write for bytes 17+: `FTF=1` indicates free space exists (count < 16).

**No-data transactions** (WREN, SECTOR_ERASE-class with `dmode=0`): triggered via
`wr_instruction_written` (CCR write) or AR write; no padding needed or used.

**Writes of N ≥ 16 bytes**: naturally fill the FIFO to 16 on the 16th write → transaction
starts; subsequent bytes stream in as the SPI engine drains the FIFO. No padding needed.

**Stale padding bytes:** After an N-byte write (N < 16), 16−N zero bytes remain in
the TX FIFO. These are harmless: each test starts with a hardware reset (clears FIFO
via RST_N), and the padding zeros cannot be consumed by the SPI engine (DLR=N stops
transmission after N bytes).

---

## Workaround 9 — Split indirect reads into ≤ 16-byte chunks (Bug 9)

**Addresses:** `bsv_bugs.md` Bug 9 (RX FIFO overflow wraps count to 0)

`rl_data_read_phase` calls `fifo.enq(1, temp)` without a `fifo.enqReadyN(1)` guard.
For DLR > 16, the MIMO circular-buffer write pointer wraps past the read pointer after
32 total enqueues into a 16-deep FIFO, leaving `fifo.count = 0`. All subsequent DR
reads then return stale shift-register data.

`indirect_read` in both `QSPIEnv` and `Env` now splits any request with `nbytes > 16`
into multiple 16-byte (or smaller) SPI transactions:

```python
if nbytes > 16:
    result = bytearray()
    offset = 0
    while offset < nbytes:
        chunk = min(16, nbytes - offset)
        part = await self.indirect_read(addr + offset, chunk, ...)
        result.extend(part)
        offset += chunk
    return bytes(result)
```

Each chunk issues its own FCR→DLR→CCR→AR→poll→DR-reads sequence. The flash model
handles the additional CS_N cycles correctly. This is transparent to callers — the
returned bytes are identical to what a driver reading DR on-the-fly would produce.
