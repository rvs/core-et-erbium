module erbium_et_bank_wrapper (
    input               reg_clk,
    input               reg_rst_b,
    input wire          reg_req,
    input wire          reg_req_is_wr,
    input wire [7:0]    reg_addr,
    input wire [63:0]   reg_wr_data,
    input wire [63:0]   reg_wr_biten,
    output wire         reg_req_stall_wr,
    output wire         reg_req_stall_rd,
    output wire         reg_rd_ack,
    output wire         reg_rd_err,
    output wire [63:0]  reg_rd_data,
    output wire         reg_wr_ack,
    output wire         reg_wr_err,

    input  [16:0]   axi_add,
    input  [63:0]   axi_bwe,
    input  [63:0]   axi_din,
    input  [7:0]    axi_ce,
    input  [7:0]    axi_dout_en,
    input           axi_we,
    input           clk,
    input           dsleep,
    input           nvsram_startup_bypass,
    input           rst_b,
    input           vdd,
    input           vdd18,
    input           vss,
    output [7:0]    axi_busy,
    output [127:0]  axi_dout,
    input  [2:0]    ecc_disable_bit,
    output [1:0]    ecc_single_error,
    output [1:0]    ecc_double_error,
    output [1:0]    ecc_triple_error,
    output          cpu_intr,
    output          mram_ready,
    output          mram_pwr_ok,
    output          mram_maintenance,
    inout           ANATEST0,
    inout           ANATEST1
  );
  //
  wire  [2:0]  anatest0_sel;
  wire  [2:0]  anatest1_sel;
  wire  [3:0]  blk0_man_ccnt;
  wire  [3:0]  blk0_man_cnfg;
  wire  [1:0]  blk0_man_fcnt;
  wire  [3:0]  blk1_man_ccnt;
  wire  [3:0]  blk1_man_cnfg;
  wire  [1:0]  blk1_man_fcnt;
  wire  [3:0]  blk2_man_ccnt;
  wire  [3:0]  blk2_man_cnfg;
  wire  [1:0]  blk2_man_fcnt;
  wire  [3:0]  blk3_man_ccnt;
  wire  [3:0]  blk3_man_cnfg;
  wire  [1:0]  blk3_man_fcnt;
  wire  [3:0]  blk4_man_ccnt;
  wire  [3:0]  blk4_man_cnfg;
  wire  [1:0]  blk4_man_fcnt;
  wire  [3:0]  blk5_man_ccnt;
  wire  [3:0]  blk5_man_cnfg;
  wire  [1:0]  blk5_man_fcnt;
  wire  [3:0]  blk6_man_ccnt;
  wire  [3:0]  blk6_man_cnfg;
  wire  [1:0]  blk6_man_fcnt;
  wire  [3:0]  blk7_man_ccnt;
  wire  [3:0]  blk7_man_cnfg;
  wire  [1:0]  blk7_man_fcnt;
  wire         dma_en;
  wire  [3:0]  even_man_stripe_sel;
  wire  [3:0]  even_man_wr;
  wire  [42:0] gbl_cfg;
  wire         gbl_cfg_ovr_en;
  wire  [1:0]  cpu_intr_flag;
  wire  [7:0]  mram_ce;
  wire  [7:0]  mram_dout_en;
  wire  [16:0] mram_addr_in;
  wire  [7:0]  mram_busy;
  wire  [78:0] mram_bwe;
  wire  [3:0]  mram_clk;
  wire  [78:0] mram_din;
  wire  [157:0] mram_dout;
  wire         mram_dsleep;
  wire         mram_rst_b;
  wire  [3:0]  mram_stripe_sel;
  wire         mram_we;
  wire  [3:0]  odd_man_stripe_sel;
  wire  [3:0]  odd_man_wr;
  wire         otp_wr_en;
  wire         prg_rd1_byp;
  wire         pwr_up_sel;
  wire  [3:0]  powerup_trim_load_ovr;
  wire  [3:0]  powerup_trim_load_ovr_single_pulse;
  wire  [6:0]  rca_ovr;
  wire         rca_ovr_en;
  wire         rd_en_ovr;
  wire         rd_pulse_meas_en;
  wire         ref_prg_en;
  wire         reg_logic_sup_sleep;
  wire         sah_en;
  wire         scc_otp_en;
  wire  [1:0]  temp;
  wire         test_cal_en;
  wire         vblslx_gain_mode_ovr;
  wire         wr_en_ovr;
  import controller_regs_pkg::*;
  controller_regs_pkg::controller_regs__in_t hwif_in;
  controller_regs_pkg::controller_regs__out_t hwif_out;

  controller_regs controller_regs_u(
    .clk(reg_clk),
    .arst_n(reg_rst_b),
    .s_cpuif_req(reg_req),
    .s_cpuif_req_is_wr(reg_req_is_wr),
    .s_cpuif_addr(reg_addr),
    .s_cpuif_wr_data(reg_wr_data),
    .s_cpuif_wr_biten(reg_wr_biten),
    .s_cpuif_req_stall_wr(reg_req_stall_wr),
    .s_cpuif_req_stall_rd(reg_req_stall_rd),
    .s_cpuif_rd_ack(reg_rd_ack),
    .s_cpuif_rd_err(reg_rd_err),
    .s_cpuif_rd_data(reg_rd_data),
    .s_cpuif_wr_ack(reg_wr_ack),
    .s_cpuif_wr_err(reg_wr_err),

    .hwif_in(hwif_in),
    .hwif_out(hwif_out)
  );

  controller_regs_pkg::controller_regs__in_t  et_ctrl_wrapper_hwif_in;

  // mram_dout_even_lower: dout<63:0>
  assign hwif_in.test_regs.mram_dout_even_lower.dout.next = mram_dout[63:0];

  // mram_dout_odd_lower: dout<142:79>
  assign hwif_in.test_regs.mram_dout_odd_lower.dout.next = mram_dout[142:79];

  // mram_dout_uppers: dout<78:64> (even MSBs) and dout<157:143> (odd MSBs)
  assign hwif_in.test_regs.mram_dout_uppers.dout_even_msb.next = mram_dout[78:64];
  assign hwif_in.test_regs.mram_dout_uppers.dout_odd_msb.next  = mram_dout[157:143];

  // ecc_correction: corrected 128b read data from et_ecc_wrapper via axi_dout.
  assign hwif_in.test_regs.ecc_correction.dout.next            = axi_dout;
  // mram_status_0
  assign hwif_in.test_regs.mram_status_0.bist_rh2.next          = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.bist_rh2.next;
  assign hwif_in.test_regs.mram_status_0.bist_rh1.next          = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.bist_rh1.next;
  assign hwif_in.test_regs.mram_status_0.bist_rh0.next          = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.bist_rh0.next;
  assign hwif_in.test_regs.mram_status_0.bist_error_loop.next   = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.bist_error_loop.next;
  assign hwif_in.test_regs.mram_status_0.bist_error_count.next  = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.bist_error_count.next;
  assign hwif_in.test_regs.mram_status_0.ecc_1bit_flag.next     = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.ecc_1bit_flag.next;
  assign hwif_in.test_regs.mram_status_0.ecc_2bit_flag.next     = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.ecc_2bit_flag.next;
  assign hwif_in.test_regs.mram_status_0.ecc_3bit_flag.next     = et_ctrl_wrapper_hwif_in.test_regs.mram_status_0.ecc_3bit_flag.next;
  assign hwif_in.test_regs.mram_status_0.cpu_intr_flag.next     = cpu_intr_flag;
  assign cpu_intr = |cpu_intr_flag;

  // mram_status_1
  assign hwif_in.test_regs.mram_status_1.temp.next           = temp;
  assign hwif_in.test_regs.mram_status_1.pwr_ok.next         = mram_pwr_ok;
  assign hwif_in.test_regs.mram_status_1.eccrom_pwr_ok.next  = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.eccrom_pwr_ok.next;
  assign hwif_in.test_regs.mram_status_1.intr_error_lane0_addr.next = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.intr_error_lane0_addr.next;
  assign hwif_in.test_regs.mram_status_1.intr_error_lane1_addr.next = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.intr_error_lane1_addr.next;
  assign hwif_in.test_regs.mram_status_1.busy.next           = mram_busy;
  assign hwif_in.test_regs.mram_status_1.ecc_1bit.next       = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.ecc_1bit.next;
  assign hwif_in.test_regs.mram_status_1.ecc_2bit.next       = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.ecc_2bit.next;
  assign hwif_in.test_regs.mram_status_1.ecc_3bit.next       = et_ctrl_wrapper_hwif_in.test_regs.mram_status_1.ecc_3bit.next;

  // bist error-value readback split across bist_status_0 (low 64) and
  // bist_control (upper 15) in the register map.
  assign hwif_in.test_regs.bist_status_0.bist_error_value.next = et_ctrl_wrapper_hwif_in.test_regs.bist_status_0.bist_error_value.next;
  assign hwif_in.test_regs.bist_control.bist_error_value.next = et_ctrl_wrapper_hwif_in.test_regs.bist_control.bist_error_value.next;

  // bist_status_1
  assign hwif_in.test_regs.bist_status_1.bist_err_add.next   = et_ctrl_wrapper_hwif_in.test_regs.bist_status_1.bist_err_add.next;
  assign hwif_in.test_regs.bist_status_1.bist_error.next     = et_ctrl_wrapper_hwif_in.test_regs.bist_status_1.bist_error.next;
  assign hwif_in.test_regs.bist_status_1.bist_busy.next      = et_ctrl_wrapper_hwif_in.test_regs.bist_status_1.bist_busy.next;

  // man_control_0: blk0–blk3
  assign hwif_in.test_regs.man_control_0.blk0_man_ccnt.next = blk0_man_ccnt;
  assign hwif_in.test_regs.man_control_0.blk0_man_fcnt.next = blk0_man_fcnt;
  assign hwif_in.test_regs.man_control_0.blk1_man_ccnt.next = blk1_man_ccnt;
  assign hwif_in.test_regs.man_control_0.blk1_man_fcnt.next = blk1_man_fcnt;
  assign hwif_in.test_regs.man_control_0.blk2_man_ccnt.next = blk2_man_ccnt;
  assign hwif_in.test_regs.man_control_0.blk2_man_fcnt.next = blk2_man_fcnt;
  assign hwif_in.test_regs.man_control_0.blk3_man_ccnt.next = blk3_man_ccnt;
  assign hwif_in.test_regs.man_control_0.blk3_man_fcnt.next = blk3_man_fcnt;

  // man_control_1: blk4–blk7
  assign hwif_in.test_regs.man_control_1.blk4_man_ccnt.next = blk4_man_ccnt;
  assign hwif_in.test_regs.man_control_1.blk4_man_fcnt.next = blk4_man_fcnt;
  assign hwif_in.test_regs.man_control_1.blk5_man_ccnt.next = blk5_man_ccnt;
  assign hwif_in.test_regs.man_control_1.blk5_man_fcnt.next = blk5_man_fcnt;
  assign hwif_in.test_regs.man_control_1.blk6_man_ccnt.next = blk6_man_ccnt;
  assign hwif_in.test_regs.man_control_1.blk6_man_fcnt.next = blk6_man_fcnt;
  assign hwif_in.test_regs.man_control_1.blk7_man_ccnt.next = blk7_man_ccnt;
  assign hwif_in.test_regs.man_control_1.blk7_man_fcnt.next = blk7_man_fcnt;

  assign blk0_man_cnfg = hwif_out.test_regs.mram_control.even_man_wr_0.value? hwif_out.test_regs.man_control_0.blk0_man_cnfg.value : 4'bz;
  assign blk1_man_cnfg = hwif_out.test_regs.mram_control.even_man_wr_1.value? hwif_out.test_regs.man_control_0.blk1_man_cnfg.value : 4'bz;
  assign blk2_man_cnfg = hwif_out.test_regs.mram_control.even_man_wr_2.value? hwif_out.test_regs.man_control_0.blk2_man_cnfg.value : 4'bz;
  assign blk3_man_cnfg = hwif_out.test_regs.mram_control.even_man_wr_3.value? hwif_out.test_regs.man_control_0.blk3_man_cnfg.value : 4'bz;
  assign blk4_man_cnfg = hwif_out.test_regs.mram_control.odd_man_wr_0.value ? hwif_out.test_regs.man_control_1.blk4_man_cnfg.value : 4'bz;
  assign blk5_man_cnfg = hwif_out.test_regs.mram_control.odd_man_wr_1.value ? hwif_out.test_regs.man_control_1.blk5_man_cnfg.value : 4'bz;
  assign blk6_man_cnfg = hwif_out.test_regs.mram_control.odd_man_wr_2.value ? hwif_out.test_regs.man_control_1.blk6_man_cnfg.value : 4'bz;
  assign blk7_man_cnfg = hwif_out.test_regs.mram_control.odd_man_wr_3.value ? hwif_out.test_regs.man_control_1.blk7_man_cnfg.value : 4'bz;

  // gbl_cfg readback is assembled in et_ctrl_top and forwarded through
  // et_ctrl_wrapper_hwif_in so it can share the controller's bit mapping.
  assign hwif_in.test_regs.gbl_cfg_0.sa_equal_trim.next     = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.sa_equal_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.vblslx_boost_trim.next = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.vblslx_boost_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.wr_en_msb_trim.next    = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.wr_en_msb_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.wr_en_lsb_trim.next    = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.wr_en_lsb_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.vblslx_gain_mode.next  = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.vblslx_gain_mode.next;
  assign hwif_in.test_regs.gbl_cfg_0.repulse_trim.next      = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.repulse_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.repulse_en.next        = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.repulse_en.next;
  assign hwif_in.test_regs.gbl_cfg_0.rd_en_trim.next        = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.rd_en_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.osc_wr_div_trim.next   = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.osc_wr_div_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.vblsl_trim.next        = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.vblsl_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.tcsel_trim.next        = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.tcsel_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.vwlwr_trim.next        = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.vwlwr_trim.next;
  assign hwif_in.test_regs.gbl_cfg_0.vcr_gate_trim.next     = et_ctrl_wrapper_hwif_in.test_regs.gbl_cfg_0.vcr_gate_trim.next;

  // mram_control hwif_out
  assign rd_pulse_meas_en    = hwif_out.test_regs.mram_control.rd_pulse_meas_en.value;
  assign rca_ovr             = hwif_out.test_regs.mram_control.rca_ovr.value;
  assign rca_ovr_en          = hwif_out.test_regs.mram_control.rca_ovr_en.value;
  assign gbl_cfg_ovr_en      = hwif_out.test_regs.mram_control.gbl_cfg_ovr_en.value;
  assign rd_en_ovr           = hwif_out.test_regs.mram_control.rd_en_ovr.value;
  assign prg_rd1_byp         = hwif_out.test_regs.mram_control.prg_rd1_byp.value;
  assign wr_en_ovr           = hwif_out.test_regs.mram_control.wr_en_ovr.value;
  assign dma_en              = hwif_out.test_regs.mram_control.dma_en.value;
  assign vblslx_gain_mode_ovr = hwif_out.test_regs.mram_control.vblslx_gain_mode_ovr.value;
  assign powerup_trim_load_ovr_single_pulse = {
    hwif_out.test_regs.mram_control_pulse.powerup_trim_load_ovr_single_pulse_3.value,
    hwif_out.test_regs.mram_control_pulse.powerup_trim_load_ovr_single_pulse_2.value,
    hwif_out.test_regs.mram_control_pulse.powerup_trim_load_ovr_single_pulse_1.value,
    hwif_out.test_regs.mram_control_pulse.powerup_trim_load_ovr_single_pulse_0.value
  };
  assign powerup_trim_load_ovr = hwif_out.test_regs.mram_control.powerup_trim_load_ovr.value |
                                 powerup_trim_load_ovr_single_pulse;
  assign test_cal_en         = hwif_out.test_regs.mram_control.test_cal_en.value;
  assign anatest0_sel        = hwif_out.test_regs.mram_control.anatest0_sel.value;
  assign anatest1_sel        = hwif_out.test_regs.mram_control.anatest1_sel.value;

  assign otp_wr_en           = hwif_out.test_regs.mram_control.otp_wr_en.value;

  assign even_man_stripe_sel = hwif_out.test_regs.mram_control.even_man_stripe_sel.value;
  assign even_man_wr[0]      = hwif_out.test_regs.mram_control.even_man_wr_0.value;
  assign even_man_wr[1]      = hwif_out.test_regs.mram_control.even_man_wr_1.value;
  assign even_man_wr[2]      = hwif_out.test_regs.mram_control.even_man_wr_2.value;
  assign even_man_wr[3]      = hwif_out.test_regs.mram_control.even_man_wr_3.value;
  assign odd_man_stripe_sel  = hwif_out.test_regs.mram_control.odd_man_stripe_sel.value;
  assign odd_man_wr[0]       = hwif_out.test_regs.mram_control.odd_man_wr_0.value;
  assign odd_man_wr[1]       = hwif_out.test_regs.mram_control.odd_man_wr_1.value;
  assign odd_man_wr[2]       = hwif_out.test_regs.mram_control.odd_man_wr_2.value;
  assign odd_man_wr[3]       = hwif_out.test_regs.mram_control.odd_man_wr_3.value;
  assign sah_en              = hwif_out.test_regs.mram_control.sah_en.value;
  assign scc_otp_en          = hwif_out.test_regs.mram_control.scc_otp_en.value;
  assign mram_maintenance    = hwif_out.test_regs.mram_control.maintenance_mode.value;

  //
  et_ctrl_wrapper  et_ctrl_wrapper_u(
    .rst_b(rst_b),
    .pwr_ok(mram_pwr_ok),
    .pwr_up_sel(pwr_up_sel),
    .reg_logic_sup_sleep(reg_logic_sup_sleep),
    .ref_prg_en(ref_prg_en),
    .mram_ready(mram_ready),
    .nvsram_startup_bypass(nvsram_startup_bypass),
    .mram_we(mram_we),
    .mram_ce(mram_ce),
    .mram_dout_en(mram_dout_en),
    .mram_dsleep(mram_dsleep),
    .mram_dout(mram_dout),
    .mram_din(mram_din),
    .mram_clk(mram_clk),
    .mram_bwe(mram_bwe),
    .mram_add(mram_addr_in),
    .mram_busy(mram_busy),
    .gbl_cfg(gbl_cfg),
    .dsleep(dsleep),
    .ecc_disable_bit(ecc_disable_bit),
    .ecc_single_error(ecc_single_error),
    .ecc_double_error(ecc_double_error),
    .ecc_triple_error(ecc_triple_error),
    .cpu_intr_flag(cpu_intr_flag),
    .clk(clk),
    .axi_busy(axi_busy),
    .axi_we(axi_we),
    .axi_dout_en(axi_dout_en),
    .axi_ce(axi_ce),
    .axi_dout(axi_dout),
    .axi_din(axi_din),
    .axi_bwe(axi_bwe),
    .axi_add(axi_add),
    .hwif_in(et_ctrl_wrapper_hwif_in),
    .hwif_out(hwif_out),
    .mram_rst_b(mram_rst_b)
  );
  //
`ifdef BEHAVIORAL_BANK


  bank_et #(
    .NUM_INSTANCES(8),
    .ADDR_WIDTH(17),
    .DATA_WIDTH(79)
  ) bank_u (
    .rst_b(mram_rst_b),
    .clk(mram_clk),
    .ce(mram_ce),
    .we(mram_we),
    .addr_in(mram_addr_in),
    .din(mram_din),
    .bwe(mram_bwe),
    .dout_en(mram_dout_en),
    .dout(mram_dout),
    .busy(mram_busy),

    .blk7_man_fcnt(blk7_man_fcnt),
    .blk7_man_cnfg(blk7_man_cnfg),
    .blk7_man_ccnt(blk7_man_ccnt),
    .blk6_man_fcnt(blk6_man_fcnt),
    .blk6_man_cnfg(blk6_man_cnfg),
    .blk6_man_ccnt(blk6_man_ccnt),
    .blk5_man_fcnt(blk5_man_fcnt),
    .blk5_man_cnfg(blk5_man_cnfg),
    .blk5_man_ccnt(blk5_man_ccnt),
    .blk4_man_fcnt(blk4_man_fcnt),
    .blk4_man_cnfg(blk4_man_cnfg),
    .blk4_man_ccnt(blk4_man_ccnt),
    .blk3_man_fcnt(blk3_man_fcnt),
    .blk3_man_cnfg(blk3_man_cnfg),
    .blk3_man_ccnt(blk3_man_ccnt),
    .blk2_man_fcnt(blk2_man_fcnt),
    .blk2_man_cnfg(blk2_man_cnfg),
    .blk2_man_ccnt(blk2_man_ccnt),
    .blk1_man_fcnt(blk1_man_fcnt),
    .blk1_man_cnfg(blk1_man_cnfg),
    .blk1_man_ccnt(blk1_man_ccnt),
    .blk0_man_fcnt(blk0_man_fcnt),
    .blk0_man_cnfg(blk0_man_cnfg),
    .blk0_man_ccnt(blk0_man_ccnt),

    .ANATEST0(ANATEST0),
    .ANATEST1(ANATEST1),
    .anatest0_sel(anatest0_sel),
    .anatest1_sel(anatest1_sel),
    .dma_en(dma_en),
    .dsleep(mram_dsleep),
    .even_man_stripe_sel(even_man_stripe_sel),
    .even_man_wr(even_man_wr),
    .gbl_cfg(gbl_cfg),
    .gbl_cfg_ovr_en(gbl_cfg_ovr_en),
    .odd_man_stripe_sel(odd_man_stripe_sel),
    .odd_man_wr(odd_man_wr),
    .otp_wr_en(otp_wr_en),
    .prg_rd1_byp(prg_rd1_byp),
    .pwr_ok(mram_pwr_ok),
    .rca_ovr(rca_ovr),
    .rca_ovr_en(rca_ovr_en),
    .rd_en_ovr(rd_en_ovr),
    .rd_pulse_meas_en(rd_pulse_meas_en),
    .ref_prg_en(ref_prg_en),
    .reg_logic_sup_sleep(reg_logic_sup_sleep),
    .sah_en(sah_en),
    .scc_otp_en(scc_otp_en),
    .temp(temp),
    .vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),
    .test_cal_en(test_cal_en),
    .pwr_up_sel(pwr_up_sel),
    .powerup_trim_load_ovr(powerup_trim_load_ovr),
    .wr_en_ovr(wr_en_ovr)
  );
`else
  `define BANK_PORT_LIST     \
    .ANATEST0(ANATEST0), \
    .ANATEST1(ANATEST1),  \
    .addr_in(mram_addr_in), \
    .anatest0_sel(anatest0_sel),  \
    .anatest1_sel(anatest1_sel),  \
    .blk0_man_ccnt(blk0_man_ccnt),  \
    .blk0_man_cnfg(blk0_man_cnfg),  \
    .blk0_man_fcnt(blk0_man_fcnt),  \
    .blk1_man_ccnt(blk1_man_ccnt),  \
    .blk1_man_cnfg(blk1_man_cnfg),  \
    .blk1_man_fcnt(blk1_man_fcnt),  \
    .blk2_man_ccnt(blk2_man_ccnt),  \
    .blk2_man_cnfg(blk2_man_cnfg),  \
    .blk2_man_fcnt(blk2_man_fcnt),  \
    .blk3_man_ccnt(blk3_man_ccnt),  \
    .blk3_man_cnfg(blk3_man_cnfg),  \
    .blk3_man_fcnt(blk3_man_fcnt),  \
    .blk4_man_ccnt(blk4_man_ccnt),  \
    .blk4_man_cnfg(blk4_man_cnfg),  \
    .blk4_man_fcnt(blk4_man_fcnt),  \
    .blk5_man_ccnt(blk5_man_ccnt),  \
    .blk5_man_cnfg(blk5_man_cnfg),  \
    .blk5_man_fcnt(blk5_man_fcnt),  \
    .blk6_man_ccnt(blk6_man_ccnt),  \
    .blk6_man_cnfg(blk6_man_cnfg),  \
    .blk6_man_fcnt(blk6_man_fcnt),  \
    .blk7_man_ccnt(blk7_man_ccnt),  \
    .blk7_man_cnfg(blk7_man_cnfg),  \
    .blk7_man_fcnt(blk7_man_fcnt),  \
    .busy(mram_busy), \
    .bwe(mram_bwe), \
    .ce(mram_ce), \
    .clk(mram_clk), \
    .din(mram_din), \
    .dma_en(dma_en),  \
    .dout(mram_dout), \
    .dout_en(mram_dout_en), \
    .dsleep(mram_dsleep), \
    .even_man_stripe_sel(even_man_stripe_sel),  \
    .even_man_wr(even_man_wr),  \
    .gbl_cfg(gbl_cfg),  \
    .gbl_cfg_ovr_en(gbl_cfg_ovr_en),  \
    .odd_man_stripe_sel(odd_man_stripe_sel),  \
    .odd_man_wr(odd_man_wr),  \
    .otp_wr_en(otp_wr_en),  \
    .prg_rd1_byp(prg_rd1_byp),  \
    .pwr_ok(mram_pwr_ok), \
    .rca_ovr(rca_ovr),  \
    .rca_ovr_en(rca_ovr_en),  \
    .rd_en_ovr(rd_en_ovr),  \
    .rd_pulse_meas_en(rd_pulse_meas_en),  \
    .ref_prg_en(ref_prg_en),  \
    .reg_logic_sup_sleep(reg_logic_sup_sleep),  \
    .rst_b(mram_rst_b), \
    .sah_en(sah_en),  \
    .scc_otp_en(scc_otp_en),  \
    .temp(temp),  \
    .vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),  \
    .test_cal_en(test_cal_en),  \
    .pwr_up_sel(pwr_up_sel),  \
    .powerup_trim_load_ovr(powerup_trim_load_ovr),  \
    .wr_en_ovr(wr_en_ovr),  \
    .we(mram_we)

  bank_et bank_u (`BANK_PORT_LIST);
`endif
endmodule : erbium_et_bank_wrapper
