# MRAM Controller

This block contains the MRAM controller RTL, its test-register interface, the
ET BIST implementation, and the generated register collateral used by software
and cocotb.

## Directory Structure

```
mram_controller/
├── verilog/          RTL source files
├── regblocks/        Register block (PeakRDL sources and generated outputs)
│   ├── systemrdl/    .rdl source files
│   └── verilog/      Generated SystemVerilog register block
├── testbench/
│   └── erbium_et_bank_wrapper/   Cocotb testbench for the bank wrapper
└── bsv/              Bluespec source files
```

---

## Usage

### Test-register control path

The controller exposes a direct test-register path for bring-up, debug, OTP
access, reference programming, and BIST control.

Use `mram_control` as the main programming register:

- `test_reg_ovr_en`: routes the bank/controller control path to the test
  registers.
- `addr_in[16:0]`: raw MRAM word address presented to the bank.
- `ce[7:0]`: per-instance chip enable.
- `we`: write enable for direct register-driven accesses.
- `din[78:0]`: raw 79-bit MRAM write data.
- `bwe[78:0]`: per-bit write mask.
- `dout_en[7:0]`: per-instance read strobe/enable.
- `ecc_en[2:0]`: ECC enable controls.
- `mram_clk_en`: continuous MRAM clock enable.
- `ref_prg_en`: switch the bank into reference programming/read behavior.
- `otp_wr_en`: enable OTP writes on the direct path.
- `dsleep_mram_en`: place the MRAM into deep sleep.
- `maintenance_mode`: drives the controller maintenance-mode path.
- `disable_cpu_intr`, `rst_cpu_intr`: CPU-interrupt control.
- `ecc_bypass_en`, `ref_ecc_sel`: ECC behavior overrides.
- `gbl_cfg_ovr_en`, `gbl_cfg_ovr_0`: test-register-driven global trim/config
  override path.
- `rca_ovr`, `rca_ovr_en`, `rd_en_ovr`, `wr_en_ovr`: direct override knobs for
  controller/bank debug.

Use `mram_control_pulse` for one-shot controls:

- `powerup_trim_load_ovr_single_pulse[3:0]`
- `mram_clk_single_pulse`

This is the preferred place for pulse-style actions. The pulse register exists
so the software/testbench does not need to rewrite the full 256-bit
`mram_control` register just to toggle a single pulse bit.

### Direct read/write flow through test registers

For direct test-register-driven accesses:

1. Set `test_reg_ovr_en=1`.
2. Program `addr_in`, `ce`, and any mode bits needed (`ref_prg_en`, `otp_wr_en`,
   `ecc_en`, etc.).
3. For writes:
   Set `we=1`, drive `din` and `bwe`, then issue the required clocking
   (`mram_clk_en` or `mram_clk_single_pulse`).
4. For reads:
   Set `we=0`, assert the relevant `dout_en` bit(s), then issue the required
   clocking.
5. Read data/status back from:
   - `mram_dout_even_lower`
   - `mram_dout_odd_lower`
   - `mram_dout_uppers`
   - `ecc_correction`
   - `mram_status_0`
   - `mram_status_1`

### Status and debug registers

The main status registers are:

- `mram_status_0`
  - `bist_error_loop`
  - `bist_error_count[16:0]`
  - `bist_rh0`, `bist_rh1`, `bist_rh2`
  - `cpu_intr_flag`
  - `ecc_1bit_flag`, `ecc_2bit_flag`, `ecc_3bit_flag`
- `mram_status_1`
  - temperature/status bits
  - ECC event summaries
  - `pwr_ok`, `eccrom_pwr_ok`
  - `intr_error_lane0_addr`, `intr_error_lane1_addr`
  - `busy[7:0]`
- `bist_status_0`
  - low 64 bits of `bist_error_value`
- `bist_status_1`
  - `bist_err_add`
  - `bist_error`
  - `bist_busy`

`bist_error_value[78:64]` is exposed in the upper portion of `bist_control`, so
software/testbench must combine `bist_status_0` and `bist_control` to recover
the full 79-bit value.

### BIST sequencing

All three BIST modes use the same general sequencing.

Bring-up and clear sequence:

1. Assert `bist_rst_b=1` before using BIST.
2. If a previous run left sticky error state behind, clear it with:
   - `bist_wr_en=0`
   - `bist_rd_en=0`
   - `bist_rte_en=0`
   - `bist_reset=1`
   - pulse `bist_start=1`
   - deassert `bist_start` and `bist_reset`
3. Program `bist_start_add` and `bist_stop_add`.
4. Program any mode-specific knobs (`bist_loop_count`, `bist_add_inc`,
   `bist_data_inv`, `bist_trim_mode`, `RH4margin`, `rh2_offset`, etc.).
5. Select exactly one BIST mode:
   - `bist_wr_en=1` for write BIST
   - `bist_rd_en=1` for read BIST
   - `bist_rte_en=1` for reference trim BIST
6. Pulse `bist_start=1` to launch the run.
7. Poll `bist_busy` until it drops.
8. Inspect `bist_error`, `bist_err_add`, `bist_error_loop`,
   `bist_error_count`, and `bist_error_value` as needed.

If a run stops because `bist_stop_on_error=1`, the latched address/value/status
can be inspected and the run can be continued by pulsing `bist_start` again.
The implementation resumes from the next address rather than restarting the
entire range.

### Key BIST control bits

| Field | Meaning | Notes |
|------|---------|-------|
| `bist_wr_en` | Enable write BIST | Mutually exclusive with `bist_rd_en` / `bist_rte_en` |
| `bist_rd_en` | Enable read BIST | Compares against `din`/inverted `din` |
| `bist_rte_en` | Enable reference trim engine BIST | Row-based trim flow |
| `bist_start_add` | Start address | 20-bit BIST address |
| `bist_stop_add` | Stop address | 20-bit BIST address |
| `bist_loop_count` | Number of loop iterations | Used by read/write BIST |
| `bist_add_inc` | Address increment exponent | Effective increment is `1 << bist_add_inc` |
| `bist_data_inv` | Invert pattern on odd loops | Current ET BIST behavior is loop-parity based |
| `bist_stop_on_error` | Stop and latch the first error | Uses `bist_err_add`, `bist_error`, `bist_error_loop`, `bist_error_value` |
| `bist_stop_on_repl_of` | Accumulate replacement/error counts | Used for counting mismatches without immediately stopping |
| `bist_trim_mode` | Enable sibling-plane trim behavior | Relevant only to RTE BIST |
| `RH4margin` | RH4 margin used by RTE | Default reset value is `0x0A` |
| `rh2_offset` | Signed RH2 offset for RTE | 5-bit signed field |
| `bist_rst_b` | BIST reset release | Must be high for normal operation |
| `bist_reset` | Internal BIST state clear | Used with `bist_start` to clear sticky state |
| `bist_start` | Launch / continue pulse | Also used for stop-on-error continue |

### Write BIST

Write BIST writes `din` across the selected range.

Supported features:

- range selection with `bist_start_add` / `bist_stop_add`
- looping with `bist_loop_count`
- address stepping with `bist_add_inc`
- loop-based inversion through `bist_data_inv`
- stop-at-first-failure behavior through `bist_stop_on_error`
- mismatch accumulation through `bist_stop_on_repl_of`

When `bist_stop_on_error=1`, the controller latches the failing address, loop,
and 79-bit error value. When `bist_stop_on_repl_of=1`, the controller counts
masked mismatch bits in `bist_error_count[16:0]`. Bit 16 acts as the overflow
sentinel and saturates the count at `0x10000`.

### Read BIST

Read BIST reads the selected range and compares the returning data against the
expected pattern.

Supported features are the same core range/loop/inversion controls as write
BIST. Read BIST is the primary mode for validating compare behavior,
stop-on-error behavior, and continue-after-stop flows.

### Reference trim engine (RTE) BIST

RTE BIST is different from plain read/write BIST.

Key behavior:

- iteration is row-based, using `bist_start_add[19:4]` through
  `bist_stop_add[19:4]`
- `bist_trim_mode=0` trims the directly addressed rows
- `bist_trim_mode=1` also exercises sibling-plane behavior
- `RH4margin` controls where a trim run transitions from pass to fail
- `rh2_offset` shifts the computed RH2 result
- status is reported through `bist_rh0`, `bist_rh1`, `bist_rh2`

The reference trim flow uses the reference-word ECC/ROM path rather than the
normal BCH data-path encoding. In practice, this is the path used to validate
row trim windows, block crossings, sibling-plane trim behavior, and RH margin
sweeps.

---

## Register Block Generation

Run from `regblocks/` (note: the mram_controller regblock sources are consumed by
the top-level `regblocks/` Makefile at the repo root).

```bash
cd /path/to/repo/regblocks

# Generate everything (Verilog regblock + Python RAL + Markdown docs)
make

# Generate only the SystemVerilog register block
make regblock

# Generate only the Python register access package (output: regblocks/python/)
make python

# Generate only the Markdown documentation (output: regblocks/README.md)
make docs

# Clean all generated outputs
make clean
```

If `peakrdl` is not on your PATH, `make` will automatically create a venv and
install from `requirements.txt`.

---

## Simulation (Cocotb)

Run from `testbench/erbium_et_bank_wrapper/`.

### Default (VCS)

```bash
make
# or equivalently:
make SIM=vcs
```

### Verilator

```bash
make SIM=verilator
```

### Run a specific test

```bash
make SIM=vcs TESTCASE=smoke_reset_and_outputs
make SIM=verilator TESTCASE=basic_axi_activity
```

### Clean simulation artifacts

```bash
make clean
```

Removes `sim_build/`, `__pycache__/`, `*.xml`, `*.vcd`, `*.fst`, `*.wlf`, `*.log`.

---

## Makefile Variables

| Variable        | Default   | Description                                      |
|-----------------|-----------|--------------------------------------------------|
| `SIM`           | `vcs`     | Simulator to use (`vcs` or `verilator`)          |
| `TOPLEVEL`      | `tb`      | Top-level Verilog module name                    |
| `MODULE`        | `tb`      | Python cocotb module (tests discovered via `tb`) |
| `TESTCASE`      | *(all)*   | Run a single named test function                 |
| `SIM_BUILD`     | `sim_build/` | Build output directory                        |

---

## Waveforms

Both simulators dump `dump.vcd` in the run directory automatically.

- **VCS**: enabled via `+vcs+dumpvars+dump.vcd +vcs+dumpon`
- **Verilator**: enabled via `--trace` + `-DDUMP_WAVES` (handled in `tb.sv` via `` `ifdef DUMP_WAVES ``)

---

## Adding Tests

Drop a new `.py` file in `testbench/erbium_et_bank_wrapper/tests/`. Any
`@cocotb.test()` function in that file is automatically discovered and included
in the regression — no import changes needed in `tb.py`.

```python
# tests/my_new_test.py
import cocotb
from tb import WrapperTB

@cocotb.test()
async def my_new_test(top):
    tb = WrapperTB(top)
    await tb.reset()
    # ... your test logic here
```

---

## PYTHONPATH

The simulation Makefile exports:

```
PYTHONPATH = <tb_dir>:<regblocks_python_dir>
```

This makes both the cocotb testbench (`tb.py`, `tests/`) and the generated
PeakRDL Python register access package (`axi2mram_bridge_registers`) importable
from test files.
