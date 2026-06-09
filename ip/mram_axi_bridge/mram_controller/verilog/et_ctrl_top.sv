module et_ctrl_top(
    input  [16:0]  axi_add,
    input  [63:0]  axi_bwe,
    input  [78:0]  axi_din,
    input  [7:0]   axi_ce,
    input  [7:0]   axi_dout_en,

    input          axi_we,
    input  [7:0]   mram_busy,
    output [7:0]   axi_busy,
    // REMOVED — now driven by hwif_out at bank_wrapper level:
    //   output         test_cal_en,       // still used internally by ctrl_cnfg_ovr_logic
    input          clk,
    output [1:0]   cpu_intr_flag,
    input  [2:0]   ecc_disable_bit,
    input          dsleep,
    input  [1:0]   ecc_1bit,
    input  [1:0]   ecc_2bit,
    input  [1:0]   ecc_3bit,
    inout  [42:0]  gbl_cfg,
    output controller_regs_pkg::controller_regs__in_t  hwif_in,
    input  controller_regs_pkg::controller_regs__out_t hwif_out,
    output [16:0]  mram_add,
    output [78:0]  mram_bwe,
    output [3:0]   mram_clk,
    output [78:0]  mram_din,
    input  [157:0] mram_dout,
    output [7:0]   mram_ce,
    output [7:0]   mram_dout_en,
    output         mram_dsleep,
    output         mram_rst_b,
    output         mram_we,
    input          nvsram_startup_bypass,
    input          pwr_ok,
    output         pwr_up_sel,
    output         reg_logic_sup_sleep,
    output         mram_ready,
    // REMOVED — now driven by hwif_out (bist_wrapper outputs kept internal):
    //   output [6:0]   rca_ovr,           // still driven internally by bist_wrapper
    //   output         rca_ovr_en,        // still driven internally by bist_wrapper
    output         ref_prg_en,
    input          rst_b,
    // REMOVED — tp (test port) signals; not connected from et_ctrl_wrapper:
    //   input  [3:0]   tp_add,
    //   output         tp_busy,
    //   input  [63:0]  tp_bwe,
    //   input          tp_ce,
    //   input  [63:0]  tp_din,
    //   output [63:0]  tp_reg_out,
    //   output         tp_valid,
    //   input          tp_we,
    // REMOVED — treg outputs now driven by hwif_out at bank_wrapper level:
    //   output [2:0]   treg_anatest0_sel,
    //   output [2:0]   treg_anatest1_sel,
    //   output         treg_dma_en,
    //   output [3:0]   treg_even_man_stripe_sel,
    //   output [3:0]   treg_even_man_wr,
    //   output         treg_gbl_cfg_ovr_en,  // still used internally by ctrl_cnfg_ovr_logic
    //   output [3:0]   treg_odd_man_stripe_sel,
    //   output [3:0]   treg_odd_man_wr,
    //   output         treg_otp_wr_en,
    //   output         treg_prg_rd1_byp,
    //   output         treg_rd_en_ovr,
    //   output         treg_rd_pulse_meas_en,
    //   output         treg_sah_en,
    //   output         treg_scc_otp_en,
    //   output         treg_vblslx_gain_mode_ovr,
    //   output         treg_wr_en_ovr,
    // REMOVED — treg inputs now read by hwif_in at bank_wrapper level:
    //   input  [1:0]   treg_temp,
    // REMOVED — blk man signals now connected directly via hwif_in at bank_wrapper level:
    //   input  [3:0]   treg_blk0_man_ccnt,
    //   inout  [3:0]   treg_blk0_man_cnfg,
    //   input  [1:0]   treg_blk0_man_fcnt,
    //   input  [3:0]   treg_blk1_man_ccnt,
    //   inout  [3:0]   treg_blk1_man_cnfg,
    //   input  [1:0]   treg_blk1_man_fcnt,
    //   input  [3:0]   treg_blk2_man_ccnt,
    //   inout  [3:0]   treg_blk2_man_cnfg,
    //   input  [1:0]   treg_blk2_man_fcnt,
    //   input  [3:0]   treg_blk3_man_ccnt,
    //   inout  [3:0]   treg_blk3_man_cnfg,
    //   input  [1:0]   treg_blk3_man_fcnt,
    //   input  [3:0]   treg_blk4_man_ccnt,
    //   inout  [3:0]   treg_blk4_man_cnfg,
    //   input  [1:0]   treg_blk4_man_fcnt,
    //   input  [3:0]   treg_blk5_man_ccnt,
    //   inout  [3:0]   treg_blk5_man_cnfg,
    //   input  [1:0]   treg_blk5_man_fcnt,
    //   input  [3:0]   treg_blk6_man_ccnt,
    //   inout  [3:0]   treg_blk6_man_cnfg,
    //   input  [1:0]   treg_blk6_man_fcnt,
    //   input  [3:0]   treg_blk7_man_ccnt,
    //   inout  [3:0]   treg_blk7_man_cnfg,
    //   input  [1:0]   treg_blk7_man_fcnt,

    // Still connected — internal to et_ctrl_wrapper (feed et_ecc_wrapper):
    output         treg_disable_ted,
    output         treg_ecc_bypass_en,
    output         treg_ref_ecc_sel
  );

  // -------------------------------------------------------------------------
  // Internal wires — these were previously ports but are still driven/used
  // by submodules within this hierarchy. They need refactoring to connect
  // to hwif_out/hwif_in via new ports or a different mechanism.
  // -------------------------------------------------------------------------

  wire             boot_axi_busy;
  wire             boot_mram_busy;

  // Driven by bist_wrapper, previously output ports:
  wire     [6:0]   rca_ovr;         // bist_wrapper .bist_rca_ovr
  wire             rca_ovr_en;      // bist_wrapper .bist_rca_ovr_en

  // Previously output ports, driven by test_regs (removed);
  // still used internally by ctrl_cnfg_ovr_logic:
  wire             test_cal_en;          // ctrl_cnfg_ovr_logic .test_cal_en
  wire             treg_gbl_cfg_ovr_en;  // ctrl_cnfg_ovr_logic .treg_gbl_cfg_ovr_en

  // Previously output ports, driven by test_regs (removed);
  // TODO: these are undriven — need refactoring to connect to hwif_out
  //       or remove from submodule connections:
  wire     [2:0]   treg_anatest0_sel;
  wire     [2:0]   treg_anatest1_sel;
  wire             treg_dma_en;
  wire     [3:0]   treg_even_man_stripe_sel;
  wire     [3:0]   treg_even_man_wr;
  wire     [3:0]   treg_odd_man_stripe_sel;
  wire     [3:0]   treg_odd_man_wr;
  wire             treg_otp_wr_en;
  wire             treg_prg_rd1_byp;
  wire             treg_rd_en_ovr;
  wire             treg_rd_pulse_meas_en;
  wire             treg_sah_en;
  wire             treg_scc_otp_en;
  wire     [1:0]   treg_temp;
  wire             treg_vblslx_gain_mode_ovr;
  wire             treg_wr_en_ovr;

  // -------------------------------------------------------------------------
  // Original internal wires (unchanged)
  // -------------------------------------------------------------------------
  wire     [4:0]   RH4margin;
  wire     [4:0]   RH2offset;
  wire     [78:0]  axi_bwe_79b;
  wire     [16:0]  bist_add;
  wire     [78:0]  bist_bwe;
  wire     [7:0]   bist_dout_en;
  wire             bist_clk_en;
  wire     [78:0]  bist_din;
  wire             bist_busy;
  wire             bist_err;
  wire     [19:0]  bist_err_add;
  wire             bist_reset;
  wire             bist_rst_b;
  wire             bist_rd_en;
  wire     [7:0]   bist_ce;
  wire             bist_we;
  wire             bist_wr_en;
  wire             cmx_bist_sel;
  wire             data_inv;
  wire             disable_cpu_intr;
  wire     [2:0]   ecc_en;
  wire     [2:0]   bist_add_inc;
  wire     [1:0]   ecc_1bit_flag_lane;
  wire     [1:0]   ecc_2bit_flag_lane;
  wire     [1:0]   ecc_3bit_flag_lane;
  wire     [18:0]  intr_error_add_lane [1:0];
  wire     [3:0]   powerup_trim_load_ovr;
  wire             bist_rte_en;
  wire     [4:0]   reg_add_cnt_o;
  wire             reg_logic_sup_sleep_ovr;
  wire     [7:0]   rom_add;
  wire             rom_ce;
  wire     [78:0]  rom_data;
  wire             rst_cpu_intr;
  wire     [19:0]  start_add;
  wire             treg_bist_start;
  wire     [15:0]  loop_cnt;
  wire             trim_mode;
  wire             treg_bist_stop_on_repl_of;
  wire     [19:0]  stop_add;
  wire             stop_on_err;
  wire             test_reg_ovr_en;
  wire     [16:0]  treg_add;
  wire     [78:0]  treg_bwe;
  wire             treg_clk_en;
  wire     [78:0]  treg_din;
  wire     [7:0]   treg_dout_en;
  wire             treg_eccrom_deep_sleep;
  wire             treg_eccrom_pwr_ok;
  // Individual gbl_cfg override wires — named to match the dpath_lrbuff instance
  // base names in the netlist (e.g. isa_equal_trim_lr → sa_equal_trim).
  // _l / _r variants are the same logical signal fanned out inside the cell.
  wire [1:0]  sa_equal_trim;        // gbl_cfg[1:0]
  wire [2:0]  vblslx_boost_trim;    // gbl_cfg[4:2]
  wire [3:0]  wr_en_msb_trim;      // gbl_cfg[8:5]
  wire [2:0]  wr_en_lsb_trim;      // gbl_cfg[11:9]
  wire        vblslx_gain_mode;    // gbl_cfg[12]
  wire [3:0]  repulse_trim;        // gbl_cfg[16:13]
  wire        repulse_en;          // gbl_cfg[17]
  wire [2:0]  rd_en_trim;          // gbl_cfg[20:18]
  wire [3:0]  osc_wr_div_trim;     // gbl_cfg[24:21]
  // gbl_cfg[28:25] — no netlist connection (no dpath_lrbuff instance for these bits)
  wire [3:0]  tcsel_trm;           // gbl_cfg[32:29] (RDL field: tcsel_trim[33:30])
  wire [3:0]  vwlwr_trm;           // gbl_cfg[36:33] (RDL field: vwlwr_trim[37:34])
  wire [3:0]  vcr_gate_trm;        // gbl_cfg[40:37] (RDL field: vcr_gate_trim[41:38])
  wire [40:0] flat_gbl_cfg;
  wire [40:0] flat_gbl_cfg_ovr;
  wire [42:0] treg_gbl_cfg_ovr;
  wire             treg_mram_dsleep_en;
  wire     [7:0]   treg_ce;
  wire     [6:0]   treg_rca_ovr;
  wire             treg_rca_ovr_en;
  wire             treg_ref_prg_en;
  wire             treg_we;

  wire      [15:0] treg_bist_error_loop;
  wire      [6:0]  treg_bist_rh0;
  wire      [6:0]  treg_bist_rh1;
  wire      [6:0]  treg_bist_rh2;
  wire      [16:0] treg_bist_error_count;
  wire      [78:0] treg_bist_error_value;

  wire      [1:0]  cpu_intr_lane;
  assign boot_mram_busy = |mram_busy;
  assign axi_busy = mram_busy;// | {8{boot_axi_busy & ~boot_mram_busy}};
  assign cpu_intr_flag = cpu_intr_lane;

  // Assignments from Register Bank
  assign treg_add             = hwif_out.test_regs.mram_control.addr_in.value;
  assign treg_ce              = hwif_out.test_regs.mram_control.ce.value;
  assign treg_we              = hwif_out.test_regs.mram_control.we.value;
  assign treg_gbl_cfg_ovr_en  = hwif_out.test_regs.mram_control.gbl_cfg_ovr_en.value;
  assign treg_mram_dsleep_en  = hwif_out.test_regs.mram_control.dsleep_mram_en.value;
  assign reg_logic_sup_sleep_ovr = hwif_out.test_regs.mram_control.reg_logic_sup_sleep_ovr.value;
  assign test_cal_en          = hwif_out.test_regs.mram_control.test_cal_en.value;
  assign treg_ref_prg_en      = hwif_out.test_regs.mram_control.ref_prg_en.value;
  assign treg_rca_ovr         = hwif_out.test_regs.mram_control.rca_ovr.value;
  assign treg_rca_ovr_en      = hwif_out.test_regs.mram_control.rca_ovr_en.value;
  assign bist_reset           = hwif_out.test_regs.bist_control.bist_reset.value;
  assign bist_rst_b           = hwif_out.test_regs.bist_control.bist_rst_b.value;
  assign bist_rd_en           = hwif_out.test_regs.bist_control.bist_rd_en.value;
  assign bist_wr_en           = hwif_out.test_regs.bist_control.bist_wr_en.value;
  assign treg_eccrom_deep_sleep = hwif_out.test_regs.mram_control.eccrom_deep_sleep.value;
  assign treg_ref_ecc_sel     = hwif_out.test_regs.mram_control.ref_ecc_sel.value;
  assign treg_bwe             = hwif_out.test_regs.mram_control.bwe.value;
  assign treg_clk_en          = hwif_out.test_regs.mram_control.mram_clk_en.value | hwif_out.test_regs.mram_control_pulse.mram_clk_single_pulse.value;
  assign treg_din             = hwif_out.test_regs.mram_control.din.value;
  assign treg_dout_en         = hwif_out.test_regs.mram_control.dout_en.value;
  assign test_reg_ovr_en      = hwif_out.test_regs.mram_control.test_reg_ovr_en.value;
  assign bist_rte_en          = hwif_out.test_regs.bist_control.bist_rte_en.value;
  assign rst_cpu_intr         = hwif_out.test_regs.mram_control.rst_cpu_intr.value;
  assign RH4margin            = hwif_out.test_regs.bist_control.RH4margin.value;
  assign RH2offset            = hwif_out.test_regs.bist_control.rh2_offset.value;
  assign stop_on_err          = hwif_out.test_regs.bist_control.bist_stop_on_error.value;
  assign start_add            = hwif_out.test_regs.bist_control.bist_start_add.value;
  assign data_inv             = hwif_out.test_regs.bist_control.bist_data_inv.value;
  assign disable_cpu_intr     = hwif_out.test_regs.mram_control.disable_cpu_intr.value;
  assign treg_disable_ted     = hwif_out.test_regs.mram_control.disable_ted.value;
  assign treg_ecc_bypass_en   = hwif_out.test_regs.mram_control.ecc_bypass_en.value;
  assign ecc_en               = hwif_out.test_regs.mram_control.ecc_en.value;
  assign bist_add_inc         = hwif_out.test_regs.bist_control.bist_add_inc.value;
  assign stop_add             = hwif_out.test_regs.bist_control.bist_stop_add.value;
  assign loop_cnt             = hwif_out.test_regs.bist_control.bist_loop_count.value;
  assign treg_bist_start      = hwif_out.test_regs.bist_control.bist_start.value;
  assign trim_mode            = hwif_out.test_regs.bist_control.bist_trim_mode.value;
  assign treg_bist_stop_on_repl_of = hwif_out.test_regs.bist_control.bist_stop_on_repl_of.value;

  // From the top level Bank level, the connection of the gbl_cfg signals is as follows:
  //  gbl_cfg<41:22,20:0> -> gbl_cfg<40:0>
  // Condensed gbl_cfg netlist connections (power/ground pins omitted).
  //
  // gbl_cfg bus -> dpath_lrbuff L/R fanout cells (sorted by bit position):
  //   dpath_lrbuff  isa_equal_trim_lr[1:0]    ( gbl_cfg[1:0],   ... -> sa_equal_trim_l,       sa_equal_trim_r        )
  //   dpath_lrbuff  ivblslx_boost_trim_lr[2:0]( gbl_cfg[4:2],   ... -> vblslx_boost_trim_l,   vblslx_boost_trim_r    )
  //   dpath_lrbuff  iwr_en_msb_trim_lr[3:0]   ( gbl_cfg[8:5],   ... -> wr_en_msb_trim_l,      wr_en_msb_trim_r       )
  //   dpath_lrbuff  iwr_en_lsb_trim_lr[2:0]   ( gbl_cfg[11:9],  ... -> wr_en_lsb_trim_l,      wr_en_lsb_trim_r       )
  //   dpath_lrbuff  ivblslx_en_lr             ( gbl_cfg[12],    ... -> vblslx_gain_mode_l[0], vblslx_gain_mode_r[0]  )
  //   dpath_lrbuff  irepulse_trim_lr[3:0]     ( gbl_cfg[16:13], ... -> repulse_trim_l,        repulse_trim_r         )
  //   dpath_lrbuff  irepulse_en_lr            ( gbl_cfg[17],    ... -> repulse_en_l,          repulse_en_r           )
  //   dpath_lrbuff  ird_en_trim_lr[2:0]       ( gbl_cfg[20:18], ... -> rd_en_trim_l,          rd_en_trim_r           )
  //   dpath_lrbuff  iosc_wr_div_trim_lr[3:0]  ( gbl_cfg[24:21], ... -> osc_wr_div_trim_l,     osc_wr_div_trim_r      )
  //   // gbl_cfg[28:25] -- no connection in netlist
  //   dpath_lrbuff  itcsel_trm_lr[3:0]        ( gbl_cfg[32:29], ... -> tcsel_trm_l,           tcsel_trm_r            )
  //   dpath_lrbuff  ivwlwr_trm_lr[3:0]        ( gbl_cfg[36:33], ... -> vwlwr_trm_l,           vwlwr_trm_r            )
  //   dpath_lrbuff  ivcr_gate_trm_lr[3:0]     ( gbl_cfg[40:37], ... -> vcr_gate_trm_l,        vcr_gate_trm_r         )
  //
  // vblslx_gain_mode has a second source (override, not from gbl_cfg):
  //   dpath_lrbuff  I241( vblslx_gain_mode_ovr, ... -> vblslx_gain_mode_l[1], vblslx_gain_mode_r[1] )
  //
  // Override enable path:
  //   cc_buff1x4_svt_16   icfg_ovr_en  ( gbl_cfg_ovr_en -> cfg_ovr_en )
  //   cc_inv1x4_svt_16    icfg_ovr_en_b( cfg_ovr_en -> cfg_ovr_en_b )
  //   cc_tsinv1x8_svt_16  igbl_cfg_nv  ( gcfg_b, {cfg_ovr_en_b, cfg_ovr_en} -> gbl_cfg_nv )

  // Assignments from hwif_out gbl_cfg_ovr_0 fields to individual gbl_cfg wires
  assign sa_equal_trim      = hwif_out.test_regs.gbl_cfg_ovr_0.sa_equal_trim.value;
  assign vblslx_boost_trim  = hwif_out.test_regs.gbl_cfg_ovr_0.vblslx_boost_trim.value;
  assign wr_en_msb_trim     = hwif_out.test_regs.gbl_cfg_ovr_0.wr_en_msb_trim.value;
  assign wr_en_lsb_trim     = hwif_out.test_regs.gbl_cfg_ovr_0.wr_en_lsb_trim.value;
  assign vblslx_gain_mode   = hwif_out.test_regs.gbl_cfg_ovr_0.vblslx_gain_mode.value;
  assign repulse_trim       = hwif_out.test_regs.gbl_cfg_ovr_0.repulse_trim.value;
  assign repulse_en         = hwif_out.test_regs.gbl_cfg_ovr_0.repulse_en.value;
  assign rd_en_trim         = hwif_out.test_regs.gbl_cfg_ovr_0.rd_en_trim.value;
  assign osc_wr_div_trim    = hwif_out.test_regs.gbl_cfg_ovr_0.osc_wr_div_trim.value;
  assign tcsel_trm          = hwif_out.test_regs.gbl_cfg_ovr_0.tcsel_trim.value;
  assign vwlwr_trm          = hwif_out.test_regs.gbl_cfg_ovr_0.vwlwr_trim.value;
  assign vcr_gate_trm       = hwif_out.test_regs.gbl_cfg_ovr_0.vcr_gate_trim.value;

  // Bitsliced assignments packing individual wires into treg_gbl_cfg_ovr
  assign flat_gbl_cfg_ovr[1:0]   = sa_equal_trim;
  assign flat_gbl_cfg_ovr[4:2]   = vblslx_boost_trim;
  assign flat_gbl_cfg_ovr[8:5]   = wr_en_msb_trim;
  assign flat_gbl_cfg_ovr[11:9]  = wr_en_lsb_trim;
  assign flat_gbl_cfg_ovr[12]    = vblslx_gain_mode;
  assign flat_gbl_cfg_ovr[16:13] = repulse_trim;
  assign flat_gbl_cfg_ovr[17]    = repulse_en;
  assign flat_gbl_cfg_ovr[20:18] = rd_en_trim;
  assign flat_gbl_cfg_ovr[24:21] = osc_wr_div_trim;
  assign flat_gbl_cfg_ovr[28:25] = '0; // no netlist connection for these bits
  assign flat_gbl_cfg_ovr[32:29] = tcsel_trm;
  assign flat_gbl_cfg_ovr[36:33] = vwlwr_trm;
  assign flat_gbl_cfg_ovr[40:37] = vcr_gate_trm;

  // Reversing the translation down to the global configuration bits.
  assign treg_gbl_cfg_ovr[41:22] = flat_gbl_cfg_ovr[40:21];
  assign treg_gbl_cfg_ovr[20: 0] = flat_gbl_cfg_ovr[20: 0];

  // Unassigned bits.
  assign treg_gbl_cfg_ovr[42]    = '0;
  assign treg_gbl_cfg_ovr[21]    = '0;

  // The top-level bank bus carries the flat 41-bit gbl_cfg payload with holes at
  // bit positions 21 and 42. Collapse it back to the contiguous field layout
  // before publishing readback into the test-register hwif.
  assign flat_gbl_cfg[40:21] = gbl_cfg[41:22];
  assign flat_gbl_cfg[20: 0] = gbl_cfg[20: 0];

  assign hwif_in.test_regs.gbl_cfg_0.sa_equal_trim.next             = flat_gbl_cfg[1:0];
  assign hwif_in.test_regs.gbl_cfg_0.vblslx_boost_trim.next         = flat_gbl_cfg[4:2];
  assign hwif_in.test_regs.gbl_cfg_0.wr_en_msb_trim.next            = flat_gbl_cfg[8:5];
  assign hwif_in.test_regs.gbl_cfg_0.wr_en_lsb_trim.next            = flat_gbl_cfg[11:9];
  assign hwif_in.test_regs.gbl_cfg_0.vblslx_gain_mode.next          = flat_gbl_cfg[12];
  assign hwif_in.test_regs.gbl_cfg_0.repulse_trim.next              = flat_gbl_cfg[16:13];
  assign hwif_in.test_regs.gbl_cfg_0.repulse_en.next                = flat_gbl_cfg[17];
  assign hwif_in.test_regs.gbl_cfg_0.rd_en_trim.next                = flat_gbl_cfg[20:18];
  assign hwif_in.test_regs.gbl_cfg_0.osc_wr_div_trim.next           = flat_gbl_cfg[24:21];
  assign hwif_in.test_regs.gbl_cfg_0.vblsl_trim.next                = flat_gbl_cfg[28:25];
  assign hwif_in.test_regs.gbl_cfg_0.tcsel_trim.next                = flat_gbl_cfg[32:29];
  assign hwif_in.test_regs.gbl_cfg_0.vwlwr_trim.next                = flat_gbl_cfg[36:33];
  assign hwif_in.test_regs.gbl_cfg_0.vcr_gate_trim.next             = flat_gbl_cfg[40:37];
  assign hwif_in.test_regs.mram_status_0.bist_rh2.next              = treg_bist_rh2;
  assign hwif_in.test_regs.mram_status_0.bist_rh1.next              = treg_bist_rh1;
  assign hwif_in.test_regs.mram_status_0.bist_rh0.next              = treg_bist_rh0;
  assign hwif_in.test_regs.mram_status_0.bist_error_loop.next       = treg_bist_error_loop;
  assign hwif_in.test_regs.mram_status_0.bist_error_count.next      = treg_bist_error_count;
  assign hwif_in.test_regs.mram_status_0.ecc_1bit_flag.next         = ecc_1bit_flag_lane;
  assign hwif_in.test_regs.mram_status_0.ecc_2bit_flag.next         = ecc_2bit_flag_lane;
  assign hwif_in.test_regs.mram_status_0.ecc_3bit_flag.next         = ecc_3bit_flag_lane;
  assign hwif_in.test_regs.mram_status_1.eccrom_pwr_ok.next         = treg_eccrom_pwr_ok;
  assign hwif_in.test_regs.mram_status_1.intr_error_lane0_addr.next = intr_error_add_lane[0];
  assign hwif_in.test_regs.mram_status_1.intr_error_lane1_addr.next = intr_error_add_lane[1];
  assign hwif_in.test_regs.bist_status_0.bist_error_value.next      = treg_bist_error_value[63:0];
  assign hwif_in.test_regs.bist_control.bist_error_value.next       = treg_bist_error_value[78:64];
  assign hwif_in.test_regs.bist_status_1.bist_err_add.next          = bist_err_add;
  assign hwif_in.test_regs.bist_status_1.bist_error.next            = bist_err;
  assign hwif_in.test_regs.bist_status_1.bist_busy.next             = bist_busy;
  assign hwif_in.test_regs.mram_status_1.ecc_1bit.next              = ecc_1bit;
  assign hwif_in.test_regs.mram_status_1.ecc_2bit.next              = ecc_2bit;
  assign hwif_in.test_regs.mram_status_1.ecc_3bit.next              = ecc_3bit;

  //
  ecc_rom_wrapper  ecc_rom_wrapper_u(
    .clk(clk),
    .rst_b(rst_b),
    .rom_add(rom_add),
    .rom_ce(rom_ce),
    .rom_ds(treg_eccrom_deep_sleep),
    .rom_data(rom_data),
    .rom_pwr_ok(treg_eccrom_pwr_ok)
  );
  //
  ctrl_cnfg_ovr_logic  ctrl_cfg_ovr_logic_u(
    .treg_gbl_cfg_ovr(treg_gbl_cfg_ovr),
    .treg_gbl_cfg_ovr_en(treg_gbl_cfg_ovr_en),
    .gbl_cfg(gbl_cfg),
    .dsleep(dsleep),
    .treg_mram_dsleep_en(treg_mram_dsleep_en),
    .test_cal_en(test_cal_en),
    .mram_dsleep(mram_dsleep)
  );
  //
  clk_gate_lvt  clk_gate_u[3:0](
    .clk_in({clk, clk, clk, clk}),
    .gate0({bist_clk_en, bist_clk_en, bist_clk_en, bist_clk_en}),
    .gate1({bist_clk_en, bist_clk_en, bist_clk_en, bist_clk_en}),
    .rst_b({rst_b, rst_b, rst_b, rst_b}),
    .clk_out(mram_clk)
  );

  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin : g_et_cpu_intr_logic
      et_cpu_intr_logic et_cpu_intr_logic_u(
        .clk(mram_clk[0]),
        .rst_b(rst_b),
        .disable_i(disable_cpu_intr),
        .rst_intr_i(rst_cpu_intr),
        .single_bit_error_i(ecc_1bit[i]),
        .double_bit_error_i(ecc_2bit[i]),
        .triple_bit_error_i(ecc_3bit[i]),
        .mask_single_bit_errors_i(ecc_disable_bit[0]),
        .mask_double_bit_errors_i(ecc_disable_bit[1]),
        .mask_triple_bit_errors_i(ecc_disable_bit[2]),
        .dout_en_i({
            mram_dout_en[i + 6],
            mram_dout_en[i + 4],
            mram_dout_en[i + 2],
            mram_dout_en[i + 0]
          }
        ),
        .add_i(mram_add),
        .error_add_o(intr_error_add_lane[i]),
        .ecc_1bit_flag_o(ecc_1bit_flag_lane[i]),
        .ecc_2bit_flag_o(ecc_2bit_flag_lane[i]),
        .ecc_3bit_flag_o(ecc_3bit_flag_lane[i]),
        .cpu_intr_o(cpu_intr_lane[i])
      );
    end
  endgenerate
  //
  et_bwe_convert  et_bwe_convert_u(
    .bwe_in(axi_bwe),
    .bwe_out(axi_bwe_79b)
  );
  //
  et_ctrl_mux  ctrl_mux_u(
    .sel(cmx_bist_sel),
    .bist_add(bist_add),
    .bist_dout_en(bist_dout_en),
    .bist_ce(bist_ce),
    .bist_we(bist_we),
    .bist_din(bist_din),
    .bist_bwe(bist_bwe),
    .axi_add(axi_add),
    .axi_ce(axi_ce),
    .axi_dout_en(axi_dout_en),
    .axi_we(axi_we),
    .axi_din(axi_din),
    .axi_bwe(axi_bwe_79b),
    .mram_add(mram_add),
    .mram_ce(mram_ce),
    .mram_dout_en(mram_dout_en),
    .mram_we(mram_we),
    .mram_bwe(mram_bwe),
    .mram_din(mram_din)
  );
  //
  et_bist_wrapper  bist_wrapper_u(
    .clk(clk),
    .rst_b(rst_b),
    .busy(mram_busy),
    .bist_rte_en(bist_rte_en),
    .bist_wr_en(bist_wr_en),
    .bist_rd_en(bist_rd_en),
    .bist_reset(bist_reset),
    .bist_rst_b(bist_rst_b),
    .bist_start(treg_bist_start),
    .ecc_en(ecc_en),
    .ecc_1bit(|ecc_1bit),
    .ecc_2bit(|ecc_2bit),
    .ecc_3bit(|ecc_3bit),
    .mram_dout(mram_dout),
    .rom_data(rom_data),
    .RH_margin(RH4margin),
    .rh2_offset(RH2offset),
    .start_add(start_add),
    .stop_add(stop_add),
    .bist_add_inc(bist_add_inc),
    .stop_on_err(stop_on_err),
    .loop_cnt(loop_cnt),
    .trim_mode(trim_mode),
    .stop_on_repl_of(treg_bist_stop_on_repl_of),

    .reg_ovr_en(test_reg_ovr_en),
    .reg_ce(treg_ce),
    .reg_dout_en(treg_dout_en),
    .reg_we(treg_we),
    .reg_ref_prg_en(treg_ref_prg_en),
    .reg_rca_ovr_en(treg_rca_ovr_en),
    .reg_clk_en(treg_clk_en),
    .reg_rca_ovr(treg_rca_ovr),
    .reg_bwe(treg_bwe),
    .reg_add(treg_add),
    .reg_din(treg_din),
    .data_inv(data_inv),
    .bist_ce(bist_ce),
    .bist_dout_en(bist_dout_en),
    .bist_we(bist_we),
    .bist_bwe(bist_bwe),
    .bist_ref_prg_en(ref_prg_en),       // now internal wire (was output port)
    .bist_rca_ovr_en(rca_ovr_en),       // now internal wire (was output port)
    .bist_rca_ovr(rca_ovr),             // now internal wire (was output port)
    .bist_din(bist_din),
    .bist_add(bist_add),
    .cmx_bist_sel(cmx_bist_sel),
    .rom_add(rom_add),
    .bist_busy(bist_busy),
    .bist_err(bist_err),
    .bist_err_add(bist_err_add),
    .bist_error_loop(treg_bist_error_loop),
    .bist_rh0(treg_bist_rh0),
    .bist_rh1(treg_bist_rh1),
    .bist_rh2(treg_bist_rh2),
    .bist_error_count(treg_bist_error_count),
    .bist_error_value(treg_bist_error_value),
    .clk_en(bist_clk_en),
    .rom_ce(rom_ce)
  );
  //
  boot_sequencer  iboot_sequencer(
    .clk_i(clk),
    .rst_bi(rst_b),
    .pwr_ok_i(pwr_ok),
    .nvsram_startup_bypass_i(nvsram_startup_bypass),
    .mram_busy_i(boot_mram_busy),
    .reg_logic_sup_sleep_ovr_i(reg_logic_sup_sleep_ovr),
    .mram_rst_bo(mram_rst_b),
    .pwr_up_sel_o(pwr_up_sel),
    .reg_logic_sup_sleep_o(reg_logic_sup_sleep), // now internal wire (was output port)
    .axi_busy_o(boot_axi_busy),
    .mram_ready_o(mram_ready)
  );
endmodule : et_ctrl_top
