# UART BSV Refactoring Prompts

These prompts document the refactoring from the original monolithic
`/opt/data/project/hdl-et/shakti_ip/bsv/uart.bsv` (603 lines, two modules) to the
layered three-file architecture in `/opt/data/project/uart/bsv/`.

---

## RF-01 — Split monolithic uart.bsv into uart_cfg_regs.bsv and uart_axi.bsv

The original `uart.bsv` contains both `mkuart_user` (register access, interrupt logic,
IO interface) and `mkuart_axi4lite` (AXI4-Lite slave, clock-domain crossing, sync FIFOs)
in the same package. Split them:

- Move `mkuart_user` and its `UserInterface` definition into a new package
  `uart_cfg_regs` in `uart_cfg_regs.bsv`. Export `RS232(..)`, `UserInterface(..)`,
  `mkuart_user`.
- Move `mkuart_axi4lite` and its `Ifc_uart_axi4lite` definition into a new package
  `uart_axi` in `uart_axi.bsv`. Import `uart_cfg_regs`. Export `Ifc_uart_axi4lite(..)`,
  `mkuart_axi4lite`.
- Replace the original `uart.bsv` with a thin re-export wrapper that imports both
  packages and re-exports `mkuart_axi4lite`.

The `uart.defines` file, RS232 interface, UART provisos, and all `ifdef` guards
(`uart_modem`, `IQC`, `uart_clk_gate_en`, `uart_loc_rst_en`) must be preserved
unchanged.

---

## RF-02 — Refactor the error_status interface in RS232_modified.bsv

The original `mkUART` exports `error_status` as 5 bits:
`{fifo_almost_full, break_error, frame_error, overrun, parity_error}`. This mixes a
level signal (fifo_almost_full) with transient event bits that are only valid for one
cycle each.

Refactor:
- Reduce `error_status` to 1 bit — return only `fifo_almost_full`.
- Add a new `Maybe#(Bit#(4)) new_error_bits` method backed by an `RWire`. Fire it with
  `tagged Valid {break, frame, overrun, parity}` in the cycle an error is detected;
  return `tagged Invalid` otherwise.

In `uart_cfg_regs.bsv`, add a persistent `Reg#(Bit#(4)) error_status_register` and a
rule `rl_capture_error_bits` that stores the `Maybe` payload into it whenever it is
`Valid`. Update the `status` wire to reconstruct the original 16-bit layout:
`{modem[7:1], uart.error_status{1b}, error_status_register{4b}, rx_full, rx_notEmpty,
tx_full, tx_empty}`.

---

## RF-03 — Introduce a raw interrupt register and separate enable from status

The original design uses a single 9-bit `interrupt_status` register that is immediately
masked by `rg_interrupt_en`:
```
interrupt_status <= (interrupt_status | (status[8:0] & rg_interrupt_en[8:0]))
                    & ~dw_interrupt_status_clear;
```
Clear is triggered by a `DWire` written from the `InterruptStatus` write handler.

Replace with the standard raw/enable/status split used in ARM PL011 and similar UARTs:

- Add `Reg#(Bit#(16)) rg_interrupt_raw` (sticky OR accumulator, all sources regardless
  of enable).
- Keep `Reg#(Bit#(16)) rg_interrupt_en` as the mask.
- Replace `setInterruptStatus` with `rl_capture_interrupt_bits` that ORs the current
  status into `rg_interrupt_raw` unconditionally every cycle.
- Remove `dw_interrupt_status_clear`. Implement clear-on-write to `InterruptRaw` as XOR:
  `rg_interrupt_raw <= rg_interrupt_raw ^ {6'd0, data[9:0]}`.
- `InterruptStatus` (read-only) returns `rg_interrupt_raw & rg_interrupt_en`.
- The `interrupt` output pin remains `|(rg_interrupt_raw[8:0] & rg_interrupt_en[8:0])`.

---

## RF-04 — Update uart.defines register address map

The original map:

| Register       | Address |
|----------------|---------|
| InterruptEn    | 0x18    |
| IQ_cycles      | 0x1C    |
| RX_Threshold   | 0x20    |
| UART_Clk_en    | 0x24    |
| InterruptStatus| 0x28    |

After adding `InterruptRaw` and shuffling to keep contiguous alignment (8-byte stride
matching the SystemRDL `alignment=8`), update to:

| Register       | Address |
|----------------|---------|
| IQ_cycles      | 0x18    |
| RX_Threshold   | 0x1C    |
| UART_Clk_en    | 0x20    |
| InterruptRaw   | 0x24    |
| InterruptEn    | 0x28    |
| InterruptStatus| 0x2C    |

Update all `` `define `` entries in `uart.defines` and regenerate the SystemRDL
`uart.rdl` to add the `InterruptRaw` register with `hwset; woclr` field attributes.

---

## RF-05 — Add error_status_register write-clear to StatusReg write handler

In the original, writing to `StatusReg` calls `uart.clear_status(clear_status_errors)`
which clears the internal error flags in the UART core. After RF-02 the error bits are
now held in `error_status_register` in `uart_cfg_regs`. Update the `StatusReg` write
handler to also clear `error_status_register`:

```bsv
error_status_register <= error_status_register & clear_status_errors[3:0];
```

This ensures software write-clear to StatusReg still clears all error sticky bits.

---

## RF-06 — Regenerate the cocotb RAL model from the updated SystemRDL

After RF-04 the register offsets have changed. Regenerate `UART_Reg.py` from `uart.rdl`
using the existing RAL generation tool (peakrdl or equivalent). Verify the generated
offsets match the new address map:

- BaudReg +0x000, TxReg +0x008, RxReg +0x010, StatusReg +0x018
- DelayReg +0x020, ControlReg +0x028
- IQC +0x030, Rx_Threshold +0x038, NotUsed +0x040
- InterruptRaw +0x048, InterruptMask +0x050, InterruptStatus +0x058

Update `tb_uart.v` if the base address or stride has changed.

---

## RF-07 — Migrate testbench helper read_status to read StatusReg

After the split, `read_status` in `test_uart_suite.py` reads `tb.reg.InterruptRaw` and
writes it back (destroying interrupt state). Replace with a read of `tb.reg.StatusReg`
with no write-back:

```python
async def read_status(tb):
    return await tb.reg.StatusReg.read()
```

This is a pure read of the level-sensitive status register and has no side effects.
