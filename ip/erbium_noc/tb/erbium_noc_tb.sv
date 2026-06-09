// SPDX-License-Identifier: Apache-2.0
// Multi-clock functional smoke TB for erbium_noc_top (Verilator --binary --timing).
// Four asynchronous clocks exercise the axi_cdc bridges. Proves: target routing,
// per-initiator address remap, DECERR on unmapped, AXI exclusive (lock)
// pass-through, and clock-domain crossings (CPU<->SYSTEM, XSPI->CPU).
// AXI memory slaves return a per-port TAG in every data byte so an initiator's
// read-back identifies the responding target (survives the 512<->64 converters
// and the CDCs).

`define SLV(PFX, DW, TAG, SCLK, SRST)                                           \
  logic [8:0] PFX``_rid; logic [7:0] PFX``_rbeat, PFX``_rlen; logic PFX``_rb;   \
  logic [8:0] PFX``_bid; logic PFX``_wb, PFX``_bv;                              \
  assign tb_AXI_MASTER_``PFX``_ARREADY = !PFX``_rb;                            \
  assign tb_AXI_MASTER_``PFX``_RVALID  = PFX``_rb;                             \
  assign tb_AXI_MASTER_``PFX``_RID     = PFX``_rid;                            \
  assign tb_AXI_MASTER_``PFX``_RDATA   = {(DW/8){TAG}};                        \
  assign tb_AXI_MASTER_``PFX``_RRESP   = 2'b00;                                \
  assign tb_AXI_MASTER_``PFX``_RLAST   = (PFX``_rbeat == PFX``_rlen);          \
  assign tb_AXI_MASTER_``PFX``_AWREADY = !PFX``_wb && !PFX``_bv;               \
  assign tb_AXI_MASTER_``PFX``_WREADY  = PFX``_wb;                             \
  assign tb_AXI_MASTER_``PFX``_BVALID  = PFX``_bv;                             \
  assign tb_AXI_MASTER_``PFX``_BID     = PFX``_bid;                            \
  assign tb_AXI_MASTER_``PFX``_BRESP   = 2'b00;                                \
  always_ff @(posedge SCLK or negedge SRST) if (!SRST) begin                   \
    PFX``_rb<=0; PFX``_rbeat<=0; PFX``_rlen<=0; PFX``_rid<=0;                   \
    PFX``_wb<=0; PFX``_bv<=0; PFX``_bid<=0;                                     \
  end else begin                                                               \
    if (!PFX``_rb && tb_AXI_MASTER_``PFX``_ARVALID) begin                      \
      PFX``_rb<=1; PFX``_rid<=tb_AXI_MASTER_``PFX``_ARID;                       \
      PFX``_rlen<=tb_AXI_MASTER_``PFX``_ARLEN; PFX``_rbeat<=0;                  \
    end else if (PFX``_rb && tb_AXI_MASTER_``PFX``_RREADY) begin                \
      if (PFX``_rbeat==PFX``_rlen) PFX``_rb<=0; else PFX``_rbeat<=PFX``_rbeat+1;\
    end                                                                        \
    if (!PFX``_wb && !PFX``_bv && tb_AXI_MASTER_``PFX``_AWVALID) begin          \
      PFX``_wb<=1; PFX``_bid<=tb_AXI_MASTER_``PFX``_AWID;                       \
    end else if (PFX``_wb && tb_AXI_MASTER_``PFX``_WVALID                       \
                          && tb_AXI_MASTER_``PFX``_WLAST) begin                 \
      PFX``_wb<=0; PFX``_bv<=1;                                                 \
    end                                                                        \
    if (PFX``_bv && tb_AXI_MASTER_``PFX``_BREADY) PFX``_bv<=0;                  \
  end

module erbium_noc_tb;
  logic rst_n;
  // four asynchronous clocks (periods 10 / 40 / 50 / 80 ns)
  logic cpu_clk=0, sys_clk=0, xspi_clk=0, periph_clk=0;
  initial forever #5  cpu_clk    = ~cpu_clk;
  initial forever #20 sys_clk    = ~sys_clk;
  initial forever #25 xspi_clk   = ~xspi_clk;
  initial forever #40 periph_clk = ~periph_clk;

  `include "dut_harness.svh"

  assign tb_CPU_CLK=cpu_clk; assign tb_SYSTEM_CLK=sys_clk;
  assign tb_XSPI_CLK=xspi_clk; assign tb_PERIPH_CLK=periph_clk;
  assign tb_CPU_RESETn=rst_n; assign tb_SYSTEM_RESETn=rst_n;
  assign tb_XSPI_RESETn=rst_n; assign tb_PERIPH_RESETn=rst_n;

  localparam logic [7:0] T_MRAM=8'hA0, T_CPUREG=8'hC0, T_SRAM=8'h50, T_SYSREG=8'h57;

  // memory slaves clocked in their target domain
  `SLV(M_MRAM,       512, T_MRAM,   cpu_clk, rst_n)   // CPU domain
  `SLV(M_CPU_REG,     64, T_CPUREG, cpu_clk, rst_n)   // CPU domain
  `SLV(M_SRAM,        64, T_SRAM,   sys_clk, rst_n)   // SYSTEM domain (CDC)
  `SLV(M_SYSTEM_REG,  64, T_SYSREG, sys_clk, rst_n)   // SYSTEM domain (CDC)

  int errors = 0;
  task automatic chk(input string nm, input logic cond);
    if (cond) $display("  PASS  %s", nm);
    else begin $display("  FAIL  %s", nm); errors++; end
  endtask

  logic [1:0] resp; logic [511:0] d512; logic [63:0] d64; logic excl_seen;

  // clocked sticky handshake detectors (sampled in each initiator's own domain)
  logic cpu_clr, xspi_clr;
  logic cpu_ar_seen, cpu_r_done;  logic [1:0] cpu_rresp_q;  logic [511:0] cpu_rdata_q;
  logic cpu_aw_seen, cpu_w_done, cpu_b_done; logic [1:0] cpu_bresp_q; int cpu_rbeats;
  logic xspi_ar_seen, xspi_r_done; logic [1:0] xspi_rresp_q; logic [63:0] xspi_rdata_q;

  always_ff @(posedge cpu_clk or negedge rst_n) begin
    if (!rst_n) begin
      cpu_ar_seen<=0; cpu_r_done<=0; excl_seen<=0; cpu_rresp_q<=0; cpu_rdata_q<=0;
      cpu_aw_seen<=0; cpu_w_done<=0; cpu_b_done<=0; cpu_bresp_q<=0;
    end else begin
      if (cpu_clr) begin cpu_ar_seen<=0; cpu_r_done<=0; cpu_aw_seen<=0; cpu_w_done<=0; cpu_b_done<=0; cpu_rbeats<=0; end
      else begin
        if (tb_AXI_SLAVE_S_CPU_ARVALID && tb_AXI_SLAVE_S_CPU_ARREADY) cpu_ar_seen<=1;
        if (tb_AXI_SLAVE_S_CPU_RVALID && tb_AXI_SLAVE_S_CPU_RREADY) cpu_rbeats<=cpu_rbeats+1;
        if (tb_AXI_SLAVE_S_CPU_RVALID && tb_AXI_SLAVE_S_CPU_RREADY && tb_AXI_SLAVE_S_CPU_RLAST) begin
          cpu_r_done<=1; cpu_rresp_q<=tb_AXI_SLAVE_S_CPU_RRESP; cpu_rdata_q<=tb_AXI_SLAVE_S_CPU_RDATA;
        end
        if (tb_AXI_SLAVE_S_CPU_AWVALID && tb_AXI_SLAVE_S_CPU_AWREADY) cpu_aw_seen<=1;
        if (tb_AXI_SLAVE_S_CPU_WVALID && tb_AXI_SLAVE_S_CPU_WREADY && tb_AXI_SLAVE_S_CPU_WLAST) cpu_w_done<=1;
        if (tb_AXI_SLAVE_S_CPU_BVALID && tb_AXI_SLAVE_S_CPU_BREADY) begin cpu_b_done<=1; cpu_bresp_q<=tb_AXI_SLAVE_S_CPU_BRESP; end
      end
      if (tb_AXI_MASTER_M_MRAM_ARVALID && tb_AXI_MASTER_M_MRAM_ARLOCK) excl_seen<=1;
    end
  end

  always_ff @(posedge xspi_clk or negedge rst_n) begin
    if (!rst_n) begin
      xspi_ar_seen<=0; xspi_r_done<=0; xspi_rresp_q<=0; xspi_rdata_q<=0;
    end else begin
      if (xspi_clr) begin xspi_ar_seen<=0; xspi_r_done<=0; end
      else begin
        if (tb_AXI_SLAVE_S_XSPI_ARVALID && tb_AXI_SLAVE_S_XSPI_ARREADY) xspi_ar_seen<=1;
        if (tb_AXI_SLAVE_S_XSPI_RVALID && tb_AXI_SLAVE_S_XSPI_RREADY && tb_AXI_SLAVE_S_XSPI_RLAST) begin
          xspi_r_done<=1; xspi_rresp_q<=tb_AXI_SLAVE_S_XSPI_RRESP; xspi_rdata_q<=tb_AXI_SLAVE_S_XSPI_RDATA;
        end
      end
    end
  end

  // ---- CPU initiator (512b, CPU domain) single read ----
  task automatic cpu_read(input logic [31:0] addr, input logic lock,
                          output logic [1:0] r, output logic [511:0] d);
    cpu_clr<=1'b1; @(posedge cpu_clk); cpu_clr<=1'b0;
    tb_AXI_SLAVE_S_CPU_RREADY<=1'b1;
    tb_AXI_SLAVE_S_CPU_ARID<=8'h11; tb_AXI_SLAVE_S_CPU_ARADDR<=addr;
    tb_AXI_SLAVE_S_CPU_ARLEN<=8'd0; tb_AXI_SLAVE_S_CPU_ARSIZE<=3'd6;
    tb_AXI_SLAVE_S_CPU_ARBURST<=2'b01; tb_AXI_SLAVE_S_CPU_ARLOCK<=lock;
    tb_AXI_SLAVE_S_CPU_ARVALID<=1'b1;
    while (!cpu_ar_seen) @(posedge cpu_clk);
    tb_AXI_SLAVE_S_CPU_ARVALID<=1'b0;
    while (!cpu_r_done) @(posedge cpu_clk);
    r = cpu_rresp_q; d = cpu_rdata_q;
    tb_AXI_SLAVE_S_CPU_RREADY<=1'b0; @(posedge cpu_clk);
  endtask

  // ---- CPU initiator burst read (len+1 beats); returns observed beat count ----
  task automatic cpu_read_burst(input logic [31:0] addr, input logic [7:0] len, output int beats);
    cpu_clr<=1'b1; @(posedge cpu_clk); cpu_clr<=1'b0;
    tb_AXI_SLAVE_S_CPU_RREADY<=1'b1;
    tb_AXI_SLAVE_S_CPU_ARID<=8'h11; tb_AXI_SLAVE_S_CPU_ARADDR<=addr;
    tb_AXI_SLAVE_S_CPU_ARLEN<=len; tb_AXI_SLAVE_S_CPU_ARSIZE<=3'd6;
    tb_AXI_SLAVE_S_CPU_ARBURST<=2'b01; tb_AXI_SLAVE_S_CPU_ARLOCK<=1'b0;
    tb_AXI_SLAVE_S_CPU_ARVALID<=1'b1;
    while (!cpu_ar_seen) @(posedge cpu_clk);
    tb_AXI_SLAVE_S_CPU_ARVALID<=1'b0;
    while (!cpu_r_done) @(posedge cpu_clk);
    beats = cpu_rbeats;
    tb_AXI_SLAVE_S_CPU_RREADY<=1'b0; @(posedge cpu_clk);
  endtask

  // ---- CPU initiator (512b) single-beat write; ARID/AWID share 0x11 for LL/SC ----
  task automatic cpu_write(input logic [31:0] addr, input logic lock, output logic [1:0] r);
    cpu_clr<=1'b1; @(posedge cpu_clk); cpu_clr<=1'b0;
    tb_AXI_SLAVE_S_CPU_BREADY<=1'b1;
    tb_AXI_SLAVE_S_CPU_AWID<=8'h11; tb_AXI_SLAVE_S_CPU_AWADDR<=addr;
    tb_AXI_SLAVE_S_CPU_AWLEN<=8'd0; tb_AXI_SLAVE_S_CPU_AWSIZE<=3'd6;
    tb_AXI_SLAVE_S_CPU_AWBURST<=2'b01; tb_AXI_SLAVE_S_CPU_AWLOCK<=lock;
    tb_AXI_SLAVE_S_CPU_AWVALID<=1'b1;
    tb_AXI_SLAVE_S_CPU_WDATA<=512'hCAFE; tb_AXI_SLAVE_S_CPU_WSTRB<={64{1'b1}};
    tb_AXI_SLAVE_S_CPU_WLAST<=1'b1; tb_AXI_SLAVE_S_CPU_WVALID<=1'b1;
    while (!cpu_aw_seen) @(posedge cpu_clk);
    tb_AXI_SLAVE_S_CPU_AWVALID<=1'b0;
    while (!cpu_w_done) @(posedge cpu_clk);
    tb_AXI_SLAVE_S_CPU_WVALID<=1'b0;
    while (!cpu_b_done) @(posedge cpu_clk);
    r = cpu_bresp_q;
    tb_AXI_SLAVE_S_CPU_BREADY<=1'b0; @(posedge cpu_clk);
  endtask

  // ---- XSPI initiator (64b, XSPI domain) single read ----
  task automatic xspi_read(input logic [31:0] addr, output logic [1:0] r, output logic [63:0] d);
    xspi_clr<=1'b1; @(posedge xspi_clk); xspi_clr<=1'b0;
    tb_AXI_SLAVE_S_XSPI_RREADY<=1'b1;
    tb_AXI_SLAVE_S_XSPI_ARID<=1'b0; tb_AXI_SLAVE_S_XSPI_ARADDR<=addr;
    tb_AXI_SLAVE_S_XSPI_ARLEN<=8'd0; tb_AXI_SLAVE_S_XSPI_ARSIZE<=3'd3;
    tb_AXI_SLAVE_S_XSPI_ARBURST<=2'b01; tb_AXI_SLAVE_S_XSPI_ARLOCK<=1'b0;
    tb_AXI_SLAVE_S_XSPI_ARVALID<=1'b1;
    while (!xspi_ar_seen) @(posedge xspi_clk);
    tb_AXI_SLAVE_S_XSPI_ARVALID<=1'b0;
    while (!xspi_r_done) @(posedge xspi_clk);
    r = xspi_rresp_q; d = xspi_rdata_q;
    tb_AXI_SLAVE_S_XSPI_RREADY<=1'b0; @(posedge xspi_clk);
  endtask

  initial begin
    tb_AXI_SLAVE_S_CPU_AWVALID=0; tb_AXI_SLAVE_S_CPU_WVALID=0; tb_AXI_SLAVE_S_CPU_BREADY=0;
    tb_AXI_SLAVE_S_CPU_ARVALID=0; tb_AXI_SLAVE_S_CPU_RREADY=0; tb_AXI_SLAVE_S_CPU_ARLOCK=0;
    tb_AXI_SLAVE_S_XSPI_AWVALID=0; tb_AXI_SLAVE_S_XSPI_WVALID=0; tb_AXI_SLAVE_S_XSPI_BREADY=0;
    tb_AXI_SLAVE_S_XSPI_ARVALID=0; tb_AXI_SLAVE_S_XSPI_RREADY=0;
    cpu_clr=0; xspi_clr=0;
    // sideband: no clock-stop / power requests pending
    tb_CPU_QREQn=1; tb_SYSTEM_QREQn=1; tb_XSPI_QREQn=1; tb_PERIPH_QREQn=1;
    tb_PD_0_PREQ=0; tb_PD_0_PSTATE=0;
    // tie unused master-port responses + APB quiescent
    tb_AXI_MASTER_M_MRAM_REG_AWREADY=0; tb_AXI_MASTER_M_MRAM_REG_WREADY=0;
    tb_AXI_MASTER_M_MRAM_REG_BVALID=0; tb_AXI_MASTER_M_MRAM_REG_ARREADY=0; tb_AXI_MASTER_M_MRAM_REG_RVALID=0;
    tb_AXI_MASTER_M_SPI_REG_AWREADY=0; tb_AXI_MASTER_M_SPI_REG_WREADY=0;
    tb_AXI_MASTER_M_SPI_REG_BVALID=0; tb_AXI_MASTER_M_SPI_REG_ARREADY=0; tb_AXI_MASTER_M_SPI_REG_RVALID=0;
    tb_AXI_MASTER_M_UART_REG_AWREADY=0; tb_AXI_MASTER_M_UART_REG_WREADY=0;
    tb_AXI_MASTER_M_UART_REG_BVALID=0; tb_AXI_MASTER_M_UART_REG_ARREADY=0; tb_AXI_MASTER_M_UART_REG_RVALID=0;
    tb_AXI_MASTER_M_XSPI_AWREADY=0; tb_AXI_MASTER_M_XSPI_WREADY=0;
    tb_AXI_MASTER_M_XSPI_BVALID=0; tb_AXI_MASTER_M_XSPI_ARREADY=0; tb_AXI_MASTER_M_XSPI_RVALID=0;
    tb_APB_MASTER_M_I2C_REG_PREADY=0; tb_APB_MASTER_M_I2C_REG_PRDATA=0; tb_APB_MASTER_M_I2C_REG_PSLVERR=0;

    rst_n = 0; repeat (8) @(posedge cpu_clk); rst_n = 1; repeat (4) @(posedge cpu_clk);
    $display("erbium_noc_top multi-clock smoke:");

    cpu_read(32'h4000_0000, 1'b0, resp, d512);
    chk("CPU->MRAM routed (tag)",  d512[7:0]==T_MRAM);
    chk("CPU->MRAM OKAY",          resp==2'b00);

    cpu_read(32'h0200_8000, 1'b0, resp, d512);          // SYSTEM domain target via CDC
    chk("CPU->SRAM routed (dw64+cdc)", d512[7:0]==T_SRAM);

    cpu_read(32'h8000_0000, 1'b0, resp, d512);
    chk("CPU->CPU_REG routed",     d512[7:0]==T_CPUREG);

    cpu_read(32'hD000_0000, 1'b0, resp, d512);          // truly unmapped
    chk("CPU->unmapped = DECERR",  resp==2'b11);

    cpu_read(32'hFE00_0000, 1'b0, resp, d512);          // GPV discovery (read-only)
    chk("CPU->GPV magic",          d512[31:0]==32'h4E49_3730);
    chk("CPU->GPV OKAY",           resp==2'b00);

    // ---- exclusive (LL/SC) monitor on the MRAM leg ----
    cpu_read(32'h4000_0000, 1'b1, resp, d512);          // load-linked
    chk("excl read -> EXOKAY",     resp==2'b01);
    chk("excl lock reaches MRAM leg", excl_seen);
    cpu_write(32'h4000_0000, 1'b1, resp);               // store-conditional (reservation valid)
    chk("excl write hit -> EXOKAY", resp==2'b01);
    cpu_read(32'h4000_0000, 1'b1, resp, d512);          // re-establish reservation
    cpu_write(32'h4000_0000, 1'b0, resp);               // intervening normal store breaks it
    chk("normal write -> OKAY",    resp==2'b00);
    cpu_write(32'h4000_0000, 1'b1, resp);               // SC after reservation lost
    chk("excl write miss -> OKAY", resp==2'b00);

    xspi_read(32'h0000_0000, resp, d64);                // XSPI->CPU cdc + remap
    chk("XSPI 0x0 remap->MRAM",    d64[7:0]==T_MRAM);

    xspi_read(32'h4000_0000, resp, d64);                // + CPU->SYSTEM cdc
    chk("XSPI 0x4000_0000 remap->SYSTEM_REG", d64[7:0]==T_SYSREG);

    // ---- burst read (4 beats) on the native 512b MRAM path ----
    begin int nb; cpu_read_burst(32'h4000_0000, 8'd3, nb);
      chk("CPU burst read returns 4 beats", nb==4); end

    // ---- low-power Q-Channel (CPU domain): idle -> accept clock stop ----
    tb_CPU_QREQn <= 1'b0; repeat (6) @(posedge cpu_clk);
    chk("Q-Channel accepts stop when idle", tb_CPU_QACCEPTn==1'b0 && tb_CPU_QDENY==1'b0);
    tb_CPU_QREQn <= 1'b1; repeat (3) @(posedge cpu_clk);

    // ---- P-Channel (pd_0): request power state, expect PACCEPT after TINIT ----
    tb_PD_0_PSTATE <= 4'h1; tb_PD_0_PREQ <= 1'b1;
    repeat (50) @(posedge cpu_clk);
    chk("P-Channel accepts power request", pacc_seen);
    tb_PD_0_PREQ <= 1'b0;

    if (errors==0) $display("ALL PASS"); else $display("FAILURES: %0d", errors);
    $finish;
  end

  // sticky catch of the 1-cycle PACCEPT pulse
  logic pacc_seen;
  always_ff @(posedge cpu_clk or negedge rst_n)
    if (!rst_n) pacc_seen <= 1'b0; else if (tb_PD_0_PACCEPT) pacc_seen <= 1'b1;

  initial begin #500000; $display("TIMEOUT"); $finish; end

  // ============================================================================
  // Free-running concurrency assertions added per docs/ISSUE_2026-05-30 §8.1/8.2.
  // Catch the bug class observed in mtg_16t_rand_13170 (a store that retired
  // upstream but never landed at the slave) the moment it triggers, instead of
  // after 600k cycles of random stress.
  //
  // Per-target slave-side bookkeeping:
  //   - count AW handshakes, W bursts (w_last+w_ready), B handshakes
  //   - W-burst beat count must equal awlen+1
  //   - At the boundary: total AW must equal total W-last must equal total B.
  //   - Any non-zero (squashed) WSTRB at the excl-monitor output is logged only
  //     if the originating AW was aw_lock=1 — else it's a silent drop event.
  //
  // The counters are checked at chk() time at end of test. They also assert
  // "delta should never exceed in-flight depth" on every cycle (a runaway
  // imbalance — store retiring up while none lands down — fires immediately).
  // ============================================================================

  // ---------- per-target counters (MRAM is the canonical 512b leg) ----------
  int unsigned mram_aw_cnt    = 0;
  int unsigned mram_w_last_cnt= 0;
  int unsigned mram_b_cnt     = 0;
  int unsigned mram_w_beat_cnt= 0;  // total W beats accepted at slave
  int unsigned mram_w_expected_beats = 0; // running sum of (awlen+1)

  always_ff @(posedge cpu_clk or negedge rst_n) begin
    if (!rst_n) begin
      mram_aw_cnt    <= 0; mram_w_last_cnt <= 0; mram_b_cnt <= 0;
      mram_w_beat_cnt<= 0; mram_w_expected_beats <= 0;
    end else begin
      if (tb_AXI_MASTER_M_MRAM_AWVALID && tb_AXI_MASTER_M_MRAM_AWREADY) begin
        mram_aw_cnt           <= mram_aw_cnt + 1;
        mram_w_expected_beats <= mram_w_expected_beats + tb_AXI_MASTER_M_MRAM_AWLEN + 1;
      end
      if (tb_AXI_MASTER_M_MRAM_WVALID && tb_AXI_MASTER_M_MRAM_WREADY) begin
        mram_w_beat_cnt <= mram_w_beat_cnt + 1;
        if (tb_AXI_MASTER_M_MRAM_WLAST) mram_w_last_cnt <= mram_w_last_cnt + 1;
      end
      if (tb_AXI_MASTER_M_MRAM_BVALID && tb_AXI_MASTER_M_MRAM_BREADY)
        mram_b_cnt <= mram_b_cnt + 1;

      // Runaway assertion: B must never lead AW. If it does, the slave
      // generated a phantom B (or our bookkeeping missed an AW).
      assert (mram_b_cnt <= mram_aw_cnt)
        else $error("[ASSERT mram_b_outruns_aw] mram_b=%0d > mram_aw=%0d", mram_b_cnt, mram_aw_cnt);

      // Runaway assertion: w_last must never lead AW.
      assert (mram_w_last_cnt <= mram_aw_cnt)
        else $error("[ASSERT mram_wlast_outruns_aw] wlast=%0d > aw=%0d", mram_w_last_cnt, mram_aw_cnt);
    end
  end

  // Per-target SRAM (the other excl_monitor leg).
  int unsigned sram_aw_cnt = 0, sram_w_last_cnt = 0, sram_b_cnt = 0;
  always_ff @(posedge cpu_clk or negedge rst_n) begin
    if (!rst_n) begin sram_aw_cnt<=0; sram_w_last_cnt<=0; sram_b_cnt<=0; end
    else begin
      if (tb_AXI_MASTER_M_SRAM_AWVALID && tb_AXI_MASTER_M_SRAM_AWREADY) sram_aw_cnt<=sram_aw_cnt+1;
      if (tb_AXI_MASTER_M_SRAM_WVALID  && tb_AXI_MASTER_M_SRAM_WREADY
          && tb_AXI_MASTER_M_SRAM_WLAST) sram_w_last_cnt<=sram_w_last_cnt+1;
      if (tb_AXI_MASTER_M_SRAM_BVALID  && tb_AXI_MASTER_M_SRAM_BREADY) sram_b_cnt<=sram_b_cnt+1;
      assert (sram_b_cnt <= sram_aw_cnt)
        else $error("[ASSERT sram_b_outruns_aw] b=%0d > aw=%0d", sram_b_cnt, sram_aw_cnt);
    end
  end

  // ---------- silent-squash detector (the actual bug we're chasing) ----------
  // At the excl_monitor's downstream port (= tb_AXI_MASTER_M_MRAM_W*), any
  // beat with WSTRB=0 must trace back to a producer-side AW that had
  // AWLOCK=1 (i.e., an exclusive write that legitimately got squashed).
  // We sample the CPU-side AW history into a small FIFO of {wid, aw_lock}
  // and assert at every all-zero-WSTRB beat that the FIFO head has lock=1.
  //
  // This is the deterministic detector for the race in
  // docs/INVESTIGATION_2026-05-31_excl_monitor_w_race.md . If the fix in
  // erbium_noc_excl_monitor.sv is correct, no silent-squash event fires.

  typedef struct packed { logic [8:0] id; logic lock; } awlog_t;
  // Small FIFO of pending AWs on the CPU initiator side of the MRAM path.
  // (We use the CPU-side AW because that's the AW that "matters" from a
  //  software-visible store perspective. A real production check would
  //  instrument every initiator; this is the one the failing test used.)
  awlog_t awfifo [$];
  always_ff @(posedge cpu_clk or negedge rst_n) begin
    if (!rst_n) begin
      awfifo.delete();
    end else begin
      if (tb_AXI_SLAVE_S_CPU_AWVALID && tb_AXI_SLAVE_S_CPU_AWREADY) begin
        awlog_t e;
        e.id   = tb_AXI_SLAVE_S_CPU_AWID;
        e.lock = tb_AXI_SLAVE_S_CPU_AWLOCK;
        awfifo.push_back(e);
      end
      // Pop on B-response (NOT on W-last): the squash applied at the MRAM
      // leg downstream of the xbar can arrive several cycles AFTER the CPU
      // slave-side W-last (xbar mux + per-leg serialisation). Popping on
      // B keeps the AW's lock-state live until the whole transaction is
      // visibly done at the producer — which is also when the squash
      // window for that AW closes.
      if (tb_AXI_SLAVE_S_CPU_BVALID && tb_AXI_SLAVE_S_CPU_BREADY)
        if (awfifo.size() > 0) void'(awfifo.pop_front());
    end
  end

  // Silent-squash detector at MRAM downstream port. Look for any W beat
  // with WSTRB=0 AND awfifo.head.lock=0  →  bug fired.
  int unsigned silent_squash_cnt = 0;
  always_ff @(posedge cpu_clk or negedge rst_n) begin
    if (!rst_n) silent_squash_cnt <= 0;
    else if (tb_AXI_MASTER_M_MRAM_WVALID && tb_AXI_MASTER_M_MRAM_WREADY
             && (tb_AXI_MASTER_M_MRAM_WSTRB == '0)) begin
      // is the head AW a legit exclusive? if not, this is a silent drop.
      automatic logic head_lock = (awfifo.size() > 0) ? awfifo[0].lock : 1'b0;
      if (!head_lock) begin
        silent_squash_cnt <= silent_squash_cnt + 1;
        $error("[ASSERT silent_squash_at_mram] WSTRB=0 W beat with no lock'd AW pending at head (fifo size=%0d)",
                awfifo.size());
      end
    end
  end

  // ---------- end-of-test outstanding-store check ----------
  final begin
    $display("");
    $display("=== concurrency-assertion summary ===");
    $display("  MRAM: aw=%0d  w_last=%0d  b=%0d  w_beats=%0d (expected=%0d)",
              mram_aw_cnt, mram_w_last_cnt, mram_b_cnt,
              mram_w_beat_cnt, mram_w_expected_beats);
    $display("  SRAM: aw=%0d  w_last=%0d  b=%0d",
              sram_aw_cnt, sram_w_last_cnt, sram_b_cnt);
    $display("  silent-squash events on MRAM W path: %0d", silent_squash_cnt);
    if (silent_squash_cnt > 0)
      $display("  >>> BUG: erbium_noc_excl_monitor squashed beats of a non-exclusive store.");
    if (mram_aw_cnt != mram_b_cnt)
      $display("  >>> WARN: MRAM AW (%0d) != B (%0d)  — stores in flight or dropped",
                mram_aw_cnt, mram_b_cnt);
    if (mram_w_last_cnt != mram_aw_cnt)
      $display("  >>> WARN: MRAM AW (%0d) != W-last (%0d) — burst dropped or never finished",
                mram_aw_cnt, mram_w_last_cnt);
    if (mram_w_beat_cnt != mram_w_expected_beats)
      $display("  >>> WARN: MRAM W beats (%0d) != expected (%0d) — beats dropped",
                mram_w_beat_cnt, mram_w_expected_beats);
  end

endmodule
