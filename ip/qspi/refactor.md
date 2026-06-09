# QSPI BSV Refactoring Prompts

These prompts document the refactoring from the original monolithic
`/opt/data/project/hdl-et/shakti_ip/bsv/qspi_wrapper.bsv`  to a layered multi-file architecture in `/opt/data/project/qspi/bsv/`.

Note: `/opt/data/project/hdl-et/shakti_ip/bsv/qspi_axil.bsv` is an incomplete prior
split attempt that imports a non-existent `qspi_controller` package; it is superseded by
this plan.

The logic should not change during the refactor process, we are just moving code around not changing logic.
After each step compile the bsv code to generate verilog code and run yosys equivalence checking to ensure the logic is equivalent to the original code.

---

## Verification Strategy — Yosys Equivalence Wrapper

`mkqspi_axi4lite` and `mkqspi_axi4` take `slow_clk`/`slow_rst` as parameters, so the
generated Verilog has two clock ports (`CLK` and `slow_clock`). Yosys `equiv_check` is a
single-clock flow and cannot reason across clock-domain crossings.

**Resolution**: create a thin Verilog wrapper `qspi_equiv_top.v` that ties both clock
inputs to the same net and both reset inputs to the same net before passing to yosys.
Under a single clock the sync-FIFOs become transparent and the design is fully
combinational/registered in one domain — yosys can then verify it correctly.

The wrapper uses clean AXI names as its own ports. The internal `.port(wire)` connections
map those names to whatever BSV-generated names the current `qspi_32_64_0` has. Before
RF-Q02 the mapping is non-trivial; after RF-Q02 it becomes 1:1. The wrapper's port
signature never changes, so the same golden can be used for every step.

```verilog
// qspi_equiv_top.v  — for equivalence checking only, not for synthesis
module qspi_equiv_top (
    input         CLK,
    input         RST_N,
    // QSPI IO
    output        qspi_clk_o,
    output [3:0]  qspi_io_o,
    output [3:0]  qspi_io_enable,
    input  [3:0]  qspi_io_i,
    output        qspi_ncs_o,
    // AXI4-Lite write-address channel
    input         axi_awvalid,
    input  [31:0] axi_awaddr,
    input  [1:0]  axi_awsize,
    input  [2:0]  axi_awprot,
    output        axi_awready,
    // AXI4-Lite write-data channel
    input         axi_wvalid,
    input  [63:0] axi_wdata,
    input  [7:0]  axi_wstrb,
    output        axi_wready,
    // AXI4-Lite write-response channel
    output        axi_bvalid,
    output [1:0]  axi_bresp,
    input         axi_bready,
    // AXI4-Lite read-address channel
    input         axi_arvalid,
    input  [31:0] axi_araddr,
    input  [1:0]  axi_arsize,
    input  [2:0]  axi_arprot,
    output        axi_arready,
    // AXI4-Lite read-data channel
    output        axi_rvalid,
    output [1:0]  axi_rresp,
    output [63:0] axi_rdata,
    input         axi_rready,
    output        interrupts
);
    qspi_32_64_0 dut (
        .CLK                      (CLK),
        .RST_N                    (RST_N),
        .CLK_slow_clock           (CLK),    // tied to core clock
        .RST_N_slow_reset         (RST_N),  // tied to core reset
        .io_clk_o                 (qspi_clk_o),
        .io_io_o                  (qspi_io_o),
        .io_io_enable             (qspi_io_enable),
        .io_io_i_io_i             (qspi_io_i),      // BSV-mangled name; becomes qspi_io_i after RF-Q02
        .io_ncs_o                 (qspi_ncs_o),
        // AXI write-address — BSV-mangled names before RF-Q02
        .slave_m_awvalid_awvalid  (axi_awvalid),
        .slave_m_awvalid_awaddr   (axi_awaddr),
        .slave_m_awvalid_awsize   (axi_awsize),
        .slave_m_awvalid_awprot   (axi_awprot),
        .slave_awready            (axi_awready),
        // AXI write-data
        .slave_m_wvalid_wvalid    (axi_wvalid),
        .slave_m_wvalid_wdata     (axi_wdata),
        .slave_m_wvalid_wstrb     (axi_wstrb),
        .slave_wready             (axi_wready),
        // AXI write-response
        .slave_bvalid             (axi_bvalid),
        .slave_bresp              (axi_bresp),
        .slave_m_bready_bready    (axi_bready),
        // AXI read-address
        .slave_m_arvalid_arvalid  (axi_arvalid),
        .slave_m_arvalid_araddr   (axi_araddr),
        .slave_m_arvalid_arsize   (axi_arsize),
        .slave_m_arvalid_arprot   (axi_arprot),
        .slave_arready            (axi_arready),
        // AXI read-data
        .slave_rvalid             (axi_rvalid),
        .slave_rresp              (axi_rresp),
        .slave_rdata              (axi_rdata),
        .slave_m_rready_rready    (axi_rready),
        .interrupts               (interrupts),
        .RDY_interrupts           ()          // unconnected until RF-Q02 adds (*always_ready*)
    );
endmodule
```

After RF-Q02 the `.slave_m_xxx` port names on `qspi_32_64_0` change to `.axi_xxx`; update
only the internal connection names in the `dut` instantiation — the wrapper's own port
list stays unchanged.

Generate this wrapper once from the **original** Verilog (before any refactoring) and keep
it as the golden reference for all steps. After each refactor step, compile the new BSV to
Verilog, wrap the output the same way, and run:

```
yosys -p "read_verilog gold/qspi_equiv_top.v; read_verilog gate/qspi_equiv_top.v; \
          equiv_make gold/qspi_equiv_top gate/qspi_equiv_top equiv; \
          equiv_simple; equiv_status -assert"
```

---

## RF-Q00 — Fix package name in qspi_wrapper.bsv

`qspi_wrapper.bsv` currently declares `package qspi_template` which does not match the
filename. BSV requires package name and filename to match.

Change the package declaration to:

```bsv
package qspi_wrapper;
```

No other changes. Recompile and confirm `qspi_32_64_0` is generated identically before
proceeding to RF-Q01.

---

## RF-Q01 — Split monolithic qspi.bsv into qspi_controller.bsv qspi_axil.bsv and qspi_axi.bsv

The original `qspi.bsv` contains three modules and all supporting types in one package:

- `mkqspi_controller` (lines 146–1529): QSPI state machine, registers, SPI I/O
- `mkqspi_axi4lite` (lines 1540–1622): AXI4-Lite slave + sync-FIFO CDC bridge
- `mkqspi_axi4` (lines 1633–1882): AXI4 full slave + sync-FIFO CDC bridge with clock-gate
  and local-reset guards

Split them:

- Delete the existing `qspi_axil.bsv` — it is an incomplete prior attempt that imports a
  non-existent `qspi_controller` package and cannot compile. It will be recreated cleanly
  in this step.
- Move each module to a separate file.
- Create a new package `qspi_common` in `qspi_common.bsv` containing only `readOnlyReg`
  — the one helper used outside `qspi_controller` (in `mkqspi_axi4`). Export
  `readOnlyReg`. Both `qspi_controller` and `qspi_axi` import `qspi_common`.

- Move `Write_req`, `Read_req`, `Rd_resp`, `QSPI_out`, `Ifc_qspi_controller`, the
  `Phase` enum, and `mkqspi_controller` into a new package `qspi_controller` in
  `qspi_controller.bsv`. Keep `conditionalWrite`, `clearSideEffect`, `writeSideEffect`,
  `writeCCREffect` here as unexported package-scope functions — they are only used inside
  `mkqspi_controller`. Import `qspi_common`. Export `QSPI_out(..)`,
  `Ifc_qspi_controller(..)`, `mkqspi_controller`, `Phase(..)`, `Write_req(..)`,
  `Read_req(..)`, `Rd_resp(..)`.

- Move `Ifc_qspi_axi4lite` and `mkqspi_axi4lite` into a new package `qspi_axil` in
  `qspi_axil.bsv`. Import `qspi_controller`. Export `Ifc_qspi_axi4lite(..)`,
  `mkqspi_axi4lite`.

- Move `Ifc_qspi_axi4` and `mkqspi_axi4` into a new package `qspi_axi` in
  `qspi_axi.bsv`. Also move `Read_req_axi` and `Rd_resp_axi` here — they are only used
  inside `mkqspi_axi4` and are not part of the controller interface. Import
  `qspi_controller` and `qspi_common` (for `readOnlyReg` used in the
  `qspi_clk_gate_loc_rst_en` register concat). Export `Ifc_qspi_axi4(..)`, `mkqspi_axi4`.
  Do not export `Read_req_axi` or `Rd_resp_axi` — they are implementation details.

- Replace the original `qspi.bsv` with a thin re-export shim that imports
  `qspi_controller`, `qspi_axil`, and `qspi_axi` and re-exports:
  - From `qspi_controller`: `QSPI_out(..)`, `Write_req(..)`, `Read_req(..)`,
    `Rd_resp(..)`, `Ifc_qspi_controller(..)`,
    `Phase(..)`
  - From `qspi_axil`: `Ifc_qspi_axi4lite(..)`, `mkqspi_axi4lite`
  - From `qspi_axi`: `Ifc_qspi_axi4(..)`, `mkqspi_axi4`

  This makes `qspi.bsv` a true compatibility shim — any existing `import qspi::*`
  continues to see the same names as before the split.

The `qspi.defines` file, `QSPI_out` interface, all provisos, and all `ifdef` guards
(`qspi_clk_gate_en`, `qspi_loc_rst_en`, `qspi_clk_gate_loc_rst_en`, `simulate`) must be
preserved unchanged.


---

## RF-Q02 — Flatten the AXI4-Lite slave interface to explicit signal methods

The current `Ifc_qspi_axi4lite` exposes a single sub-interface
`AXI4_Lite_Slave_IFC#(addr_width, data_width, user_width) slave` which causes BSC to
mangle port names (e.g. `slave_m_awvalid_awvalid`, `io_io_i_io_i`, `RDY_interrupts`).
Replace it with flat methods using explicit port annotations, following
`/opt/data/project/uart/bsv/uart_axi.bsv` `Ifc_uart_axi4lite` as the reference.

### Target interface definition

```bsv
interface Ifc_qspi_axi4lite#(numeric type addr_width,
                              numeric type data_width,
                              numeric type user_width);
  // AXI4-Lite slave write-address channel
  (*always_ready, always_enabled, prefix=""*)
  method Action axi_awvalid(
    (*port="axi_awvalid"*) Bool             awvalid,
    (*port="axi_awaddr"*)  Bit#(addr_width) awaddr,
    (*port="axi_awsize"*)  Bit#(2)          awsize,
    (*port="axi_awuser"*)  Bit#(user_width) awuser,
    (*port="axi_awprot"*)  Bit#(3)          awprot);
  (*always_ready, result="axi_awready"*) method Bool axi_awready;

  // AXI4-Lite slave write-data channel
  (*always_ready, always_enabled, prefix=""*)
  method Action axi_wvalid(
    (*port="axi_wvalid"*) Bool                      wvalid,
    (*port="axi_wdata"*)  Bit#(data_width)          wdata,
    (*port="axi_wstrb"*)  Bit#(TDiv#(data_width,8)) wstrb);
  (*always_ready, result="axi_wready"*) method Bool axi_wready;

  // AXI4-Lite slave write-response channel
  (*always_ready, result="axi_bvalid"*) method Bool    axi_bvalid;
  (*always_ready, result="axi_bresp"*)  method Bit#(2) axi_bresp;
  (*always_ready, always_enabled, prefix=""*)
  method Action axi_bready((*port="axi_bready"*) Bool bready);

  // AXI4-Lite slave read-address channel
  (*always_ready, always_enabled, prefix=""*)
  method Action axi_arvalid(
    (*port="axi_arvalid"*) Bool             arvalid,
    (*port="axi_araddr"*)  Bit#(addr_width) araddr,
    (*port="axi_arsize"*)  Bit#(2)          arsize,
    (*port="axi_aruser"*)  Bit#(user_width) aruser,
    (*port="axi_arprot"*)  Bit#(3)          arprot);
  (*always_ready, result="axi_arready"*) method Bool axi_arready;

  // AXI4-Lite slave read-data channel
  (*always_ready, result="axi_rvalid"*) method Bool             axi_rvalid;
  (*always_ready, result="axi_rresp"*)  method Bit#(2)          axi_rresp;
  (*always_ready, result="axi_rdata"*)  method Bit#(data_width) axi_rdata;
  (*always_ready, always_enabled, prefix=""*)
  method Action axi_rready((*port="axi_rready"*) Bool rready);

  (*always_ready, always_enabled*)
  (*prefix="qspi"*) interface QSPI_out io;  // ports: qspi_clk_o, qspi_io_o, qspi_io_enable, qspi_io_i, qspi_ncs_o

  (*always_ready*)
  method Bit#(1) interrupts;               // suppresses RDY_interrupts
endinterface
```

### Notes

- `axi_awuser` / `axi_aruser`: included for consistency with UART. At `user_width=0`
  (as in `qspi_32_64_0`) BSC emits zero-width ports which Verilog tools silently drop.
- `prefix="qspi"` on `QSPI_out io` yields `qspi_clk_o`, `qspi_io_o`, `qspi_io_enable`,
  `qspi_io_i`, `qspi_ncs_o`. The current mangled `io_io_i_io_i` is fixed by this alone.
- `(*always_ready*)` on `interrupts` suppresses the spurious `RDY_interrupts` port.
  Name stays `interrupts` (plural) — it is not the same signal as UART's `interrupt`.

### Implementation

In `mkqspi_axi4lite`, wire each method through to `s_xactor.axi_side` exactly as done
in `mkuart_axi4lite`:

```bsv
method Action axi_awvalid(awvalid, awaddr, awsize, awuser, awprot);
  s_xactor.axi_side.m_awvalid(awvalid, awaddr, awsize, awuser, awprot);
endmethod
method axi_awready = s_xactor.axi_side.m_awready;
// ... and so on for all channels
interface io = qspi.io;
method interrupts = qspi.interrupts;
```

Remove the `interface slave = s_xactor.axi_side` shorthand.

### Equivalence wrapper update

After this step the `qspi_32_64_0` port names change. Update only the internal
`.port(wire)` connections in `qspi_equiv_top.v` — the wrapper's own port list
(`axi_awvalid`, `qspi_clk_o`, etc.) remains unchanged, confirming the golden is stable.
Also remove the `.RDY_interrupts()` open connection — the port no longer exists after
`(*always_ready*)` is applied.

---

## RF-Q100 — Extract AXI-programmable register file into mkqspi_regs (deferred)

Move all AXI-programmable registers and their read/write/set/clear logic out of
`mkqspi_controller` into a new module `mkqspi_regs`. `mkqspi_controller` becomes a
pure SPI engine that receives configuration via an interface rather than reading
registers directly.

This step is deferred because it requires designing a wide bidirectional interface
between the register file and the SPI engine:

- ~30 control signals flow from registers into the state machine (`ccr_fmode`,
  `ccr_dmode`, `cr_abort`, `cr_en`, `prescaler`, etc.)
- ~6 status bits flow back from the state machine into registers (`sr_busy`,
  `sr_tof`, `sr_smf`, `sr_ftf`, `sr_tcf`, `sr_tef`)
- `conditionalWrite` wrappers gate register writes on `sr_busy`, creating a
  feedback dependency that must be preserved across the module boundary

This interface must be fully designed and agreed before any code moves.

---

## RF-Q101 — Remove clock-gate and local-reset guards from mkqspi_axi4 (deferred)

`mkqspi_axi4` contains `qspi_clk_gate_en`, `qspi_loc_rst_en`, and
`qspi_clk_gate_loc_rst_en` ifdef guards that `mkqspi_axi4lite` does not have. This
asymmetry is a pre-existing condition; RF-Q01 moves both modules as-is.

This step removes the clock-gate and local-reset guards from `mkqspi_axi4` to make
both wrappers consistent. After removal, clock gating is handled outside the IP
boundary rather than inside the AXI wrapper.

Verify with the equivalence check (compiled without `qspi_clk_gate_en` and
`qspi_loc_rst_en` defined) that the simplified `mkqspi_axi4` is equivalent to the
original compiled under the same conditions.
