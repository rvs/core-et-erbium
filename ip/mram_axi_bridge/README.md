# MRAM AXI Bridge: Build and Verification Commands

## Initial repository setup

If cloning fresh:

```bash
git clone --recurse-submodules <repo-url>
cd mram-axi-bridge
```

If already cloned (or submodules changed):

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

## Quick start

From repo root:

```bash
# 1) Ensure submodules are present
git submodule update --init --recursive

# 2) Generate regblocks (top-level regblocks now builds mram_controller/regblocks first)
make -C regblocks all

# 3) Generate bridge Bluespec RTL
make -C bsv verilog

# 4) (If editing mram_controller/bsv) generate BIST RTL
make -C mram_controller/bsv build

# 5) Run cocotb verification interactively on SLURM (recommended on server)
make -C verification/erbium_et TESTCASE=basic_read_write srun
```

## Generated file overview

### Register maps / models

```bash
# Controller test-register outputs
make -C mram_controller/regblocks all

# Bridge + unified top-level regblock outputs (also runs mram_controller/regblocks first)
make -C regblocks all
```

Key outputs:

- `mram_controller/regblocks/verilog/controller_regs.sv`
- `mram_controller/regblocks/verilog/controller_regs_pkg.sv`
- `regblocks/verilog/axi2mram_bridge_registers.sv`
- `regblocks/verilog/axi2mram_bridge_registers_pkg.sv`
- `regblocks/python/axi2mram_bridge_registers/` (generated Python API used by cocotb)

### Bluespec RTL

```bash
# AXI bridge
make -C bsv verilog

# BIST blocks
make -C mram_controller/bsv build
```

Key outputs:

- `verilog/mkAxi2Mram.v`
- `verilog/mkBist.v`
- `verilog/mkEtBist.v`

## BSV build commands

Run from repo root:

```bash
make -C bsv compile     # build Bluespec .bo artifacts
make -C bsv verilog     # generate verilog/mkAxi2Mram.v
make -C bsv clean       # remove generated BSV outputs
```

Useful overrides:

```bash
make -C bsv verilog TOP=mkAxi2Mram PKG=Axi2Mram
```

## Erbium ET verification commands

Run from repo root:

```bash
make -C verification/erbium_et sim    # run simulation directly
make -C verification/erbium_et srun   # interactive SLURM run (recommended for license servers)
make -C verification/erbium_et run    # submit batch SLURM job
make -C verification/erbium_et clean  # cleanup sim artifacts
```

Notes:

- `verification/erbium_et/Makefile` auto-tracks BSV sources and regenerates `verilog/mkAxi2Mram.v` when needed.
- `verification/erbium_et/Makefile` also tracks RTL/filelist dependencies and invalidates `sim_build/` when required, so `make clean` is usually not needed for source edits.
- `srun` and `run` use these defaults unless overridden: `SLURM_PARTITION=batch`, `SLURM_TIME=01:00:00`, `SLURM_CPUS=4`, `SLURM_MEM=8G`.

Examples:

```bash
make -C verification/erbium_et srun SLURM_TIME=02:00:00 SLURM_MEM=16G
make -C verification/erbium_et srun COV_EN=1
make -C verification/erbium_et TESTCASE=basic_read_write BEHAVIORAL_BANK=1 CONTROLLER_BYPASS=0 srun
make -C verification/erbium_et TESTCASE=bist_write_read_smoke BEHAVIORAL_BANK=1 CONTROLLER_BYPASS=0 srun
```

## Run a specific testcase

Use cocotb `TESTCASE=<python_test_name>`:

```bash
make -C verification/erbium_et srun TESTCASE=basic_read_write
```

When `TESTCASE` is not set, `srun` runs the full regression. The
`delayed_write_busy_early_busy` test changes the MRAM model's
`write_busy_rise_delay_ps` at runtime and exercises both 0 ps and 800 ps
busy-rise delays inside that normal regression run.

Focused delayed write-busy regression only:

```bash
make -C verification/erbium_et delayed_write_busy_regression_srun
```

This runs only `delayed_write_busy_early_busy`, with the default runtime delay
sweep of 0 ps and 800 ps.

For direct `sim`, if `TESTCASE` is not set, cocotb runs all tests in
`verification/erbium_et/tb.py`.

Common verification knobs:

```bash
# Use the behavioral ET bank model (default: 1)
BEHAVIORAL_BANK=1

# Keep the ET controller in the path (default: 0)
CONTROLLER_BYPASS=0

# Legacy alias still accepted for CONTROLLER_BYPASS
BYPASS_CONTROLLER=0
```

## Available cocotb tests (`verification/erbium_et/tb.py`)

1. `reset_functionality` - reset behavior and bring-up sanity.
2. `basic_read_functionality` - baseline read path checks.
3. `basic_read_write` - baseline write/readback checks.
4. `otp_read_write_window` - programs and reads back the full 12 KB OTP aperture, with direct hierarchy checks against the behavioral bank model.
5. `wstrb_masks_unused_wdata_bytes` - proves non-strobed `WDATA` bytes are ignored using raw AXI AW/W channel driving.
6. `address_boundary_edges` - edge addresses and boundary behavior.
7. `partial_write_rmw` - partial write and RMW correctness.
8. `back_to_back_pipelined` - pipelined back-to-back traffic.
9. `read_after_write_hazard` - RAW hazard handling.
10. `cross_size_raw_hazard` - regression for a cross-size read-after-write hazard observed in production traffic; exact replay of the failing AXI sequence (7 transactions from 1200–1297 ns): a SIZE_64B write to `0x0` whose byte `0x2B` = `0x5E`, followed immediately by a SIZE_1B read at `0x2B`.
11. `generated_bridge_reg_model_smoke` - sanity-checks the generated Python bridge reg model against the AXI-Lite register interface.
12. `generated_controller_treg_smoke` - sanity-checks the generated Python controller test-register model and downstream wiring.
13. `arbiter_mode_verification` - arbitration behavior checks.
14. `exclusive_access_verification` - AXI exclusive access semantics (reservation, snoop-invalidation, response codes).
15. `exclusive_capacity_verification` - stress-tests the exclusive monitor with 32 simultaneous IDs each holding 1–4 address reservations; verifies eviction when the per-ID limit (4) is exceeded.
16. `concurrent_rw_corner_cases` - concurrent read/write corner cases.
17. `randomized_stress` - broad randomized stress traffic.
18. `randomized_unaligned_stress` - randomized stress focused on unaligned accesses.
19. `incr_protocol_corner_cases` - INCR-only corner cases (unaligned + 4KB boundary behavior).
20. `out_of_range_address_slverr` - verifies that reads and writes to addresses ≥ 16 MB (`addr[31:24] != 0`) return `SLVERR`; also checks the last valid address (`0x0FF_FFF8`) and that in-range data is unaffected.
21. `slverr_status_register_verification` - verifies the sticky out-of-range error status bits and their clear-on-read behavior.
22. `test_reg_manual_controls_test` - uses the controller test registers to issue direct MRAM word reads and writes, then cross-checks the targeted hierarchy locations.

## Bridge behavior notes

**Address range**
The MRAM occupies a 16 MB window starting at address `0x0000_0000`.
Any AXI read or write with `addr[31:24] != 0` (i.e., `addr ≥ 0x100_0000`) is rejected:
- Reads return `SLVERR` on every beat (`RRESP = 2`); `RDATA = 0`.
- Writes drain the write-data channel normally but no MRAM write is issued; `BRESP = SLVERR (2)`.

**MRAM address bus width**
The physical MRAM bank `addr_o` is **17 bits** wide.  Internal command-address paths
(`rd_cmd_addr`, `wr_cmd_addr`, `wl_addr`) and the `bank_addresses_calculation` helper
are correspondingly 17/20 bits wide to drive the full address bus without truncation.

**AXI4 exclusive access monitor**
`mkExclusiveMonitor` is instantiated with parameters `(32, 4, Wd_Id, Wd_Addr)`:
- Up to **32 unique AXI IDs** tracked simultaneously (round-robin eviction when full).
- Up to **4 address reservations per ID** (round-robin eviction when full).
- Exclusive reads always return `EXOKAY`; exclusive writes return `EXOKAY` on a matching reservation (which is then cleared) or `OKAY` on no match.
- Normal writes snoop-invalidate any overlapping reservations.

## Waveform dumping

By default no waveform is generated. Enable via the Makefile:

```bash
# VPD (Synopsys, viewable in DVE/Verdi)
make -C verification/erbium_et srun WAVES=1        # alias for DUMP_VPD=1
make -C verification/erbium_et srun DUMP_VPD=1

# VCD
make -C verification/erbium_et srun VCD=1          # alias for DUMP_VCD=1
make -C verification/erbium_et srun DUMP_VCD=1
```

Outputs land in `verification/erbium_et/` as `dump.vpd` / `dump.vcd`.

## Useful environment knobs

```bash
# Reproducible randomization seed for tests (default base is 42 in tb.py)
COCOTB_TEST_SEED=1234

# Iterations for randomized_unaligned_stress (default: 4000)
UNALIGNED_STRESS_ITERS=10000
```

Example:

```bash
COCOTB_TEST_SEED=1234 UNALIGNED_STRESS_ITERS=12000 \
make -C verification/erbium_et srun TESTCASE=randomized_unaligned_stress
```

Controller-path example:

```bash
COCOTB_TEST_SEED=1234 \
make -C verification/erbium_et TESTCASE=test_reg_manual_controls_test \
    BEHAVIORAL_BANK=1 CONTROLLER_BYPASS=0 srun
```

## Artifacts

Common outputs under `verification/erbium_et/`:

- `sim_build/`
- `results.xml`
- `dump.vcd` (if enabled by simulator args)
- `slurm-<jobid>.log` (for batch `run`)

## Known lint waivers

- `Warning-[TFIPC] Too few instance port connections` on
  `verilog/axi2mram_et_wrapper.sv` for `mram_bank[*].bank_wrapper_u`:
  `erbium_et_bank_wrapper` includes `vdd`, `vdd18`, and `vss` pins used for
  gate-level power simulation. These pins are intentionally left unconnected in
  RTL/behavioral simulation flows.
- `Warning-[TFIPC] Too few instance port connections` on
  `verification/erbium_et/tb.sv` for `axi2mram_et_wrapper dut()`:
  this shell testbench intentionally keeps a minimal `dut()` instance because
  cocotb drives and observes signals through hierarchy handles in Python.
