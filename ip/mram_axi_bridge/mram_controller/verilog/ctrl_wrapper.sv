// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Library          : copper_ctrl
// Cell             : ctrl_top
// View             : schematic
// View Search List : verilog functional behavioral cmos.sch cmos_sch vsymbol schematic symbol
// View Stop List   : functional behavioral symbol vsymbol
////////////////////////////////////////////////////////////////////////////////
module ctrl_top(
    input  [4:0]   PADDR,
    input          PENABLE,
    output [31:0]  PRDATA,
    output         PREADY,
    input          PSEL,
    input  [3:0]   PSTRB,
    input  [31:0]  PWDATA,
    input          PWRITE,
    input  [17:0]  axi_add,
    input  [7:0]   axi_bwe,
    input  [78:0]  axi_din,
    input  [3:0]   axi_stripe_sel,
    input          axi_we,
    input          mram_busy,
    output         axi_busy,
    output         test_cal_en,
    input          clk,
    output         cpu_intr,
    input          dsleep,
    input          ecc_1bit,
    input          ecc_2bit,
    input          ecc_3bit,
    inout  [42:0]  gbl_cfg,
    output [17:0]  mram_add,
    output [78:0]  mram_bwe,
    output [3:0]   mram_clk,
    output [78:0]  mram_din,
    input  [78:0]  mram_dout,
    output         mram_dsleep,
    output         mram_rst_b,
    output [3:0]   mram_stripe_sel,
    output         mram_we,
    input          nvsram_startup_bypass,
    output         pwr_up_sel,
    input          pwr_ok,
    output [6:0]   rca_ovr,
    output         rca_ovr_en,
    output         ref_prg_en,
    output         reg_logic_sup_sleep,
    input          rst_b,
    input  [3:0]   tp_add,
    output         tp_busy,
    input  [63:0]  tp_bwe,
    input          tp_ce,
    input  [63:0]  tp_din,
    output [63:0]  tp_reg_out,
    output         tp_valid,
    input          tp_we,
    output [2:0]   treg_anatest0_sel,
    output [2:0]   treg_anatest1_sel,
    input  [3:0]   treg_blk0_man_ccnt,
    inout  [3:0]   treg_blk0_man_cnfg,
    input  [1:0]   treg_blk0_man_fcnt,
    input  [3:0]   treg_blk1_man_ccnt,
    inout  [3:0]   treg_blk1_man_cnfg,
    input  [1:0]   treg_blk1_man_fcnt,
    input  [3:0]   treg_blk2_man_ccnt,
    inout  [3:0]   treg_blk2_man_cnfg,
    input  [1:0]   treg_blk2_man_fcnt,
    input  [3:0]   treg_blk3_man_ccnt,
    inout  [3:0]   treg_blk3_man_cnfg,
    input  [1:0]   treg_blk3_man_fcnt,
    input  [3:0]   treg_blk4_man_ccnt,
    inout  [3:0]   treg_blk4_man_cnfg,
    input  [1:0]   treg_blk4_man_fcnt,
    input  [3:0]   treg_blk5_man_ccnt,
    inout  [3:0]   treg_blk5_man_cnfg,
    input  [1:0]   treg_blk5_man_fcnt,
    input  [3:0]   treg_blk6_man_ccnt,
    inout  [3:0]   treg_blk6_man_cnfg,
    input  [1:0]   treg_blk6_man_fcnt,
    input  [3:0]   treg_blk7_man_ccnt,
    inout  [3:0]   treg_blk7_man_cnfg,
    input  [1:0]   treg_blk7_man_fcnt,
    output         treg_disable_ted,
    output         treg_dma_en,
    output         treg_ecc_bypass_en,
    output         treg_ref_ecc_sel,
    output [3:0]   treg_even_man_stripe_sel,
    output [3:0]   treg_even_man_wr,
    output         treg_gbl_cfg_ovr_en,
    output [3:0]   treg_odd_man_stripe_sel,
    output [3:0]   treg_odd_man_wr,
    output         treg_otp_wr_en,
    output [3:0]   treg_powerup_trim_load_ovr,
    output         treg_prg_rd1_byp,
    output         treg_rd_en_ovr,
    output         treg_rd_pulse_meas_en,
    output         treg_sah_en,
    output         treg_scc_otp_en,
    input  [1:0]   treg_temp,
    output         treg_vblslx_gain_mode_ovr,
    output         treg_wr_en_ovr
  );
  //
  wire     [4:0]   RH4margin;
  wire     [78:0]  axi_bwe_79b;
  wire     [17:0]  bist_add;
  wire     [78:0]  bist_bwe;
  wire             bist_clk_en;
  wire     [78:0]  bist_din;
  wire             bist_busy;
  wire             bist_err;
  wire     [19:0]  bist_err_add;
  wire             bist_reset;
  wire             bist_rd_en;
  wire     [3:0]   bist_stripe_sel;
  wire             bist_we;
  wire             bist_wr_en;
  wire             cmx_bist_sel;
  wire             data_inv;
  wire             disable_cpu_intr;
  wire     [2:0]   ecc_en;
  wire     [2:0]   bist_add_inc;
  wire     [19:0]  intr_error_add;
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
  wire     [17:0]  treg_add;
  wire     [78:0]  treg_bwe;
  wire             treg_clk_en;
  wire     [78:0]  treg_din;
  wire             treg_eccrom_deep_sleep;
  wire             treg_eccrom_pwr_ok;
  wire     [42:0]  treg_gbl_cfg_ovr;
  wire             treg_mram_dsleep_en;
  wire     [6:0]   treg_rca_ovr;
  wire             treg_rca_ovr_en;
  wire             treg_ref_prg_en;
  wire     [3:0]   treg_powerup_trim_load_ovr;
  wire     [3:0]   treg_stripe_sel;
  wire             treg_we;

  wire      [15:0] treg_bist_error_loop;
  wire      [6:0]  treg_bist_rh0;
  wire      [6:0]  treg_bist_rh1;
  wire      [6:0]  treg_bist_rh2;
  wire      [16:0] treg_bist_error_count;
  wire      [78:0] treg_bist_error_value;
  //
  wire             boot_sequencer_busy;
  reg       [3:0]  mram_busy_q;
  wire             mram_busy_d;
  reg       [3:0]  axi_busy_q;
  wire             axi_busy_d;

  assign mram_busy_d =  mram_busy | (|mram_stripe_sel & mram_we);
  assign axi_busy_d  =  boot_sequencer_busy | mram_busy_d;
  assign axi_busy    = |axi_busy_q;
  genvar bitslice;
  generate
    for (bitslice = 0; bitslice < 4; bitslice = bitslice + 1) begin
      always @(posedge mram_clk[bitslice] or negedge rst_b) begin
        if (!rst_b) begin
          mram_busy_q[bitslice] <= 1'b1;
        end else begin
          mram_busy_q[bitslice] <= mram_busy_d;
        end
      end
      always @(posedge mram_clk[bitslice] or negedge rst_b) begin
        if (!rst_b) begin
          axi_busy_q[bitslice] <= 1'b1;
        end else begin
          axi_busy_q[bitslice] <= axi_busy_d;
        end
      end
    end
  endgenerate
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
  clk_gate  clk_gate_u[3:0](
    .clk_in({clk, clk, clk, clk}),
    .gate0({bist_clk_en, bist_clk_en, bist_clk_en, bist_clk_en}),
    .gate1({bist_clk_en, bist_clk_en, bist_clk_en, bist_clk_en}),
    .rst_b({rst_b, rst_b, rst_b, rst_b}),
    .clk_out(mram_clk)
  );
  //
  cpu_intr_logic  cpu_intr_logic_u(
    .clk(clk),
    .rst_b(rst_b),
    .disable_i(disable_cpu_intr),
    .rst_intr_i(rst_cpu_intr),
    .double_bit_error_i(ecc_2bit),
    .triple_bit_error_i(ecc_3bit),
    .stripe_sel_i(mram_stripe_sel),
    .add_i(mram_add),
    .error_add_o(intr_error_add),
    .cpu_intr_o(cpu_intr)
  );
  //
  bwe_convert  bwe_convert_u(
    .bwe_in(axi_bwe),
    .bwe_out(axi_bwe_79b)
  );
  //
  test_regs  test_regs_u(
    .PCLK(clk),
    .PRESETn(rst_b),
    .PSEL(PSEL),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .tp_add(tp_add),
    .tp_ce(tp_ce),
    .tp_we(tp_we),
    .tp_bwe(tp_bwe),
    .tp_din(tp_din),
    .tp_busy(tp_busy),
    .tp_valid(tp_valid),
    .tp_reg_out(tp_reg_out),
    .treg_RH4margin(RH4margin),
    .treg_addr_in(treg_add),
    .treg_anatest0_sel(treg_anatest0_sel),
    .treg_anatest1_sel(treg_anatest1_sel),
    .treg_eccrom_deep_sleep(treg_eccrom_deep_sleep),
    .treg_ref_ecc_sel(treg_ref_ecc_sel),
    .treg_bist_busy(bist_busy),
    .treg_bist_error(bist_err),
    .treg_bist_err_add(bist_err_add),
    .treg_bist_reset(bist_reset),
    .treg_bist_rd_en(bist_rd_en),
    .treg_bist_wr_en(bist_wr_en),
    .treg_blk0_man_ccnt(treg_blk0_man_ccnt),
    .treg_blk0_man_cnfg(treg_blk0_man_cnfg),
    .treg_blk0_man_fcnt(treg_blk0_man_fcnt),
    .treg_blk1_man_ccnt(treg_blk1_man_ccnt),
    .treg_blk1_man_cnfg(treg_blk1_man_cnfg),
    .treg_blk1_man_fcnt(treg_blk1_man_fcnt),
    .treg_blk2_man_ccnt(treg_blk2_man_ccnt),
    .treg_blk2_man_cnfg(treg_blk2_man_cnfg),
    .treg_blk2_man_fcnt(treg_blk2_man_fcnt),
    .treg_blk3_man_ccnt(treg_blk3_man_ccnt),
    .treg_blk3_man_cnfg(treg_blk3_man_cnfg),
    .treg_blk3_man_fcnt(treg_blk3_man_fcnt),
    .treg_blk4_man_ccnt(treg_blk4_man_ccnt),
    .treg_blk4_man_cnfg(treg_blk4_man_cnfg),
    .treg_blk4_man_fcnt(treg_blk4_man_fcnt),
    .treg_blk5_man_ccnt(treg_blk5_man_ccnt),
    .treg_blk5_man_cnfg(treg_blk5_man_cnfg),
    .treg_blk5_man_fcnt(treg_blk5_man_fcnt),
    .treg_blk6_man_ccnt(treg_blk6_man_ccnt),
    .treg_blk6_man_cnfg(treg_blk6_man_cnfg),
    .treg_blk6_man_fcnt(treg_blk6_man_fcnt),
    .treg_blk7_man_ccnt(treg_blk7_man_ccnt),
    .treg_blk7_man_cnfg(treg_blk7_man_cnfg),
    .treg_blk7_man_fcnt(treg_blk7_man_fcnt),
    .treg_busy(mram_busy),
    .treg_bwe(treg_bwe),
    .treg_test_cal_en(test_cal_en),
    .treg_mram_clk_en(treg_clk_en),
    .treg_cpu_intr_flag(cpu_intr),
    .treg_din(treg_din),
    .treg_bist_data_inv(data_inv),
    .treg_disable_cpu_intr(disable_cpu_intr),
    .treg_disable_ted(treg_disable_ted),
    .treg_dma_en(treg_dma_en),
    .treg_dout(mram_dout),
    .treg_dsleep_mram_en(treg_mram_dsleep_en),
    .treg_ecc_1bit(ecc_1bit),
    .treg_ecc_2bit(ecc_2bit),
    .treg_ecc_3bit(ecc_3bit),
    .treg_ecc_bypass_en(treg_ecc_bypass_en),
    .treg_ecc_en(ecc_en),
    .treg_even_man_stripe_sel(treg_even_man_stripe_sel),
    .treg_even_man_wr(treg_even_man_wr),
    .treg_gbl_cfg(gbl_cfg),
    .treg_gbl_cfg_ovr(treg_gbl_cfg_ovr),
    .treg_gbl_cfg_ovr_en(treg_gbl_cfg_ovr_en),
    .treg_bist_add_inc(bist_add_inc),
    .treg_intr_error_add(intr_error_add),
    .treg_odd_man_stripe_sel(treg_odd_man_stripe_sel),
    .treg_odd_man_wr(treg_odd_man_wr),
    .treg_otp_wr_en(treg_otp_wr_en),
    .treg_powerup_trim_load_ovr(treg_powerup_trim_load_ovr),
    .treg_prg_rd1_byp(treg_prg_rd1_byp),
    .treg_pwr_ok(pwr_ok),
    .treg_eccrom_pwr_ok(treg_eccrom_pwr_ok),
    .treg_rca_ovr(treg_rca_ovr),
    .treg_rca_ovr_en(treg_rca_ovr_en),
    .treg_rd_en_ovr(treg_rd_en_ovr),
    .treg_rd_pulse_meas_en(treg_rd_pulse_meas_en),
    .treg_ref_prg_en(treg_ref_prg_en),
    .treg_bist_rte_en(bist_rte_en),
    .treg_reg_logic_sup_sleep_ovr(reg_logic_sup_sleep_ovr),
    .treg_rst_cpu_intr(rst_cpu_intr),
    .treg_sah_en(treg_sah_en),
    .treg_scc_otp_en(treg_scc_otp_en),
    .treg_bist_start_add(start_add),
    .treg_bist_start(treg_bist_start),
    .treg_bist_loop_count(loop_cnt),
    .treg_bist_trim_mode(trim_mode),
    .treg_bist_stop_on_repl_of(treg_bist_stop_on_repl_of),
    .treg_bist_stop_add(stop_add),
    .treg_bist_stop_on_error(stop_on_err),
    .treg_stripe_sel(treg_stripe_sel),
    .treg_temp(treg_temp),
    .treg_bist_error_loop(treg_bist_error_loop),
    .treg_bist_rh0(treg_bist_rh0),
    .treg_bist_rh1(treg_bist_rh1),
    .treg_bist_rh2(treg_bist_rh2),
    .treg_bist_error_count(treg_bist_error_count),
    .treg_bist_error_value(treg_bist_error_value),
    .treg_test_reg_ovr_en(test_reg_ovr_en),
    .treg_vblslx_gain_mode_ovr(treg_vblslx_gain_mode_ovr),
    .treg_we(treg_we),
    .treg_wr_en_ovr(treg_wr_en_ovr)
  );
  //
  ctrl_mux  ctrl_mux_u(
    .sel(cmx_bist_sel),
    .bist_add(bist_add),
    .bist_stripe_sel(bist_stripe_sel),
    .bist_we(bist_we),
    .bist_din(bist_din),
    .bist_bwe(bist_bwe),
    .axi_add(axi_add),
    .axi_stripe_sel(axi_stripe_sel),
    .axi_we(axi_we),
    .axi_din(axi_din),
    .axi_bwe(axi_bwe_79b),
    .mram_add(mram_add),
    .mram_stripe_sel(mram_stripe_sel),
    .mram_we(mram_we),
    .mram_bwe(mram_bwe),
    .mram_din(mram_din)
  );
  //
  bist_wrapper  bist_wrapper_u(
    .clk(clk),
    .rst_b(rst_b),
    .busy(|mram_busy_q),
    .bist_rte_en(bist_rte_en),
    .bist_wr_en(bist_wr_en),
    .bist_rd_en(bist_rd_en),
    .bist_reset(bist_reset),
    .bist_start(treg_bist_start),
    .ecc_en(ecc_en),
    .ecc_1bit(ecc_1bit),
    .ecc_2bit(ecc_2bit),
    .ecc_3bit(ecc_3bit),
    .mram_dout(mram_dout),
    .rom_data(rom_data),
    .RH_margin(RH4margin),
    .start_add(start_add),
    .stop_add(stop_add),
    .bist_add_inc(bist_add_inc),
    .stop_on_err(stop_on_err),
    .loop_cnt(loop_cnt),
    .trim_mode(trim_mode),
    .stop_on_repl_of(treg_bist_stop_on_repl_of),

    .reg_ovr_en(test_reg_ovr_en),
    .reg_stripe_sel(treg_stripe_sel),
    .reg_we(treg_we),
    .reg_ref_prg_en(treg_ref_prg_en),
    .reg_rca_ovr_en(treg_rca_ovr_en),
    .reg_clk_en(treg_clk_en),
    .reg_rca_ovr(treg_rca_ovr),
    .reg_bwe(treg_bwe),
    .reg_add(treg_add),
    .reg_din(treg_din),
    .data_inv(data_inv),
    .bist_stripe_sel(bist_stripe_sel),
    .bist_we(bist_we),
    .bist_bwe(bist_bwe),
    .bist_ref_prg_en(ref_prg_en),
    .bist_rca_ovr_en(rca_ovr_en),
    .bist_rca_ovr(rca_ovr),
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
    .mram_busy_i(mram_busy),
    .reg_logic_sup_sleep_ovr_i(reg_logic_sup_sleep_ovr),
    .mram_rst_bo(mram_rst_b),
    .pwr_up_sel_o(pwr_up_sel),
    .reg_logic_sup_sleep_o(reg_logic_sup_sleep),
    .axi_busy_o(boot_sequencer_busy)
  );
endmodule : ctrl_top

////////////////////////////////////////////////////////////////////////////////
// Library          : copper_ctrl
// Cell             : ctrl_wrapper
// View             : schematic
// View Search List : verilog functional behavioral cmos.sch cmos_sch vsymbol schematic symbol
// View Stop List   : functional behavioral symbol vsymbol
////////////////////////////////////////////////////////////////////////////////
module ctrl_wrapper(
    output         wr_en_ovr,
    output         vblslx_gain_mode_ovr,
    input          tp_we,
    output         tp_valid,
    output [63:0]  tp_reg_out,
    input  [63:0]  tp_din,
    input          tp_ce,
    input  [63:0]  tp_bwe,
    output         tp_busy,
    input  [3:0]   tp_add,
    input  [1:0]   temp,
    output         sah_en,
    input          rst_b,
    output         reg_logic_sup_sleep,
    output         ref_prg_en,
    output         rd_pulse_meas_en,
    output         rd_en_ovr,
    output         rca_ovr_en,
    output [6:0]   rca_ovr,
    output         pwr_up_sel,
    input          pwr_ok,
    output         prg_rd1_byp,
    output         otp_wr_en,
    output [3:0]   powerup_trim_load_ovr,
    output [3:0]   odd_man_wr,
    output [3:0]   odd_man_stripe_sel,
    input          nvsram_startup_bypass,
    output         mram_we,
    output [3:0]   mram_stripe_sel,
    output         mram_dsleep,
    input  [78:0]  mram_dout,
    output [78:0]  mram_din,
    output [3:0]   mram_clk,
    output [78:0]  mram_bwe,
    output [17:0]  mram_add,
    output         test_cal_en,
    output         gbl_cfg_ovr_en,
    output [42:0]  gbl_cfg,
    output [3:0]   even_man_wr,
    output [3:0]   even_man_stripe_sel,
    input          dsleep,
    output         dma_en,
    output         cpu_intr,
    input          clk,
    input          mram_busy,
    output         axi_busy,
    input  [1:0]   blk7_man_fcnt,
    inout  [3:0]   blk7_man_cnfg,
    input  [3:0]   blk7_man_ccnt,
    input  [1:0]   blk6_man_fcnt,
    inout  [3:0]   blk6_man_cnfg,
    input  [3:0]   blk6_man_ccnt,
    input  [1:0]   blk5_man_fcnt,
    inout  [3:0]   blk5_man_cnfg,
    input  [3:0]   blk5_man_ccnt,
    input  [1:0]   blk4_man_fcnt,
    inout  [3:0]   blk4_man_cnfg,
    input  [3:0]   blk4_man_ccnt,
    input  [1:0]   blk3_man_fcnt,
    inout  [3:0]   blk3_man_cnfg,
    input  [3:0]   blk3_man_ccnt,
    input  [1:0]   blk2_man_fcnt,
    inout  [3:0]   blk2_man_cnfg,
    input  [3:0]   blk2_man_ccnt,
    input  [1:0]   blk1_man_fcnt,
    inout  [3:0]   blk1_man_cnfg,
    input  [3:0]   blk1_man_ccnt,
    input  [1:0]   blk0_man_fcnt,
    inout  [3:0]   blk0_man_cnfg,
    input  [3:0]   blk0_man_ccnt,
    input          axi_we,
    input  [3:0]   axi_stripe_sel,
    output [63:0]  axi_dout,
    input  [63:0]  axi_din,
    input  [7:0]   axi_bwe,
    input  [17:0]  axi_add,
    output [2:0]   anatest1_sel,
    output [2:0]   anatest0_sel,
    input          PWRITE,
    input  [31:0]  PWDATA,
    input  [3:0]   PSTRB,
    input          PSEL,
    output         PREADY,
    output [31:0]  PRDATA,
    input          PENABLE,
    input  [4:0]   PADDR,
    output         scc_otp_en,
    output         mram_rst_b
  );
  //
  wire     [78:0]  cmx_axi_din;
  wire             ecc_bypass_en;
  wire             ecc_disable_ted;
  wire             ref_ecc_sel;
  wire             ecc_double_error;
  wire             ecc_single_error;
  wire             ecc_triple_error;
  //
  ctrl_top  ctrl_top_u(
    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSEL(PSEL),
    .PSTRB(PSTRB),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .axi_add(axi_add),
    .axi_bwe(axi_bwe),
    .axi_din(cmx_axi_din),
    .axi_stripe_sel(axi_stripe_sel),
    .axi_we(axi_we),
    .mram_busy(mram_busy),
    .axi_busy(axi_busy),
    .test_cal_en(test_cal_en),
    .clk(clk),
    .cpu_intr(cpu_intr),
    .dsleep(dsleep),
    .ecc_1bit(ecc_single_error),
    .ecc_2bit(ecc_double_error),
    .ecc_3bit(ecc_triple_error),
    .gbl_cfg(gbl_cfg),
    .mram_add(mram_add),
    .mram_bwe(mram_bwe),
    .mram_clk(mram_clk),
    .mram_din(mram_din),
    .mram_dout(mram_dout),
    .mram_dsleep(mram_dsleep),
    .mram_rst_b(mram_rst_b),
    .mram_stripe_sel(mram_stripe_sel),
    .mram_we(mram_we),
    .nvsram_startup_bypass(nvsram_startup_bypass),
    .pwr_up_sel(pwr_up_sel),
    .pwr_ok(pwr_ok),
    .rca_ovr(rca_ovr),
    .rca_ovr_en(rca_ovr_en),
    .ref_prg_en(ref_prg_en),
    .reg_logic_sup_sleep(reg_logic_sup_sleep),
    .rst_b(rst_b),
    .tp_add(tp_add),
    .tp_busy(tp_busy),
    .tp_bwe(tp_bwe),
    .tp_ce(tp_ce),
    .tp_din(tp_din),
    .tp_reg_out(tp_reg_out),
    .tp_valid(tp_valid),
    .tp_we(tp_we),
    .treg_anatest0_sel(anatest0_sel),
    .treg_anatest1_sel(anatest1_sel),
    .treg_blk0_man_ccnt(blk0_man_ccnt),
    .treg_blk0_man_cnfg(blk0_man_cnfg),
    .treg_blk0_man_fcnt(blk0_man_fcnt),
    .treg_blk1_man_ccnt(blk1_man_ccnt),
    .treg_blk1_man_cnfg(blk1_man_cnfg),
    .treg_blk1_man_fcnt(blk1_man_fcnt),
    .treg_blk2_man_ccnt(blk2_man_ccnt),
    .treg_blk2_man_cnfg(blk2_man_cnfg),
    .treg_blk2_man_fcnt(blk2_man_fcnt),
    .treg_blk3_man_ccnt(blk3_man_ccnt),
    .treg_blk3_man_cnfg(blk3_man_cnfg),
    .treg_blk3_man_fcnt(blk3_man_fcnt),
    .treg_blk4_man_ccnt(blk4_man_ccnt),
    .treg_blk4_man_cnfg(blk4_man_cnfg),
    .treg_blk4_man_fcnt(blk4_man_fcnt),
    .treg_blk5_man_ccnt(blk5_man_ccnt),
    .treg_blk5_man_cnfg(blk5_man_cnfg),
    .treg_blk5_man_fcnt(blk5_man_fcnt),
    .treg_blk6_man_ccnt(blk6_man_ccnt),
    .treg_blk6_man_cnfg(blk6_man_cnfg),
    .treg_blk6_man_fcnt(blk6_man_fcnt),
    .treg_blk7_man_ccnt(blk7_man_ccnt),
    .treg_blk7_man_cnfg(blk7_man_cnfg),
    .treg_blk7_man_fcnt(blk7_man_fcnt),
    .treg_disable_ted(ecc_disable_ted),
    .treg_dma_en(dma_en),
    .treg_ecc_bypass_en(ecc_bypass_en),
    .treg_ref_ecc_sel(ref_ecc_sel),
    .treg_even_man_stripe_sel(even_man_stripe_sel),
    .treg_even_man_wr(even_man_wr),
    .treg_gbl_cfg_ovr_en(gbl_cfg_ovr_en),
    .treg_odd_man_stripe_sel(odd_man_stripe_sel),
    .treg_odd_man_wr(odd_man_wr),
    .treg_otp_wr_en(otp_wr_en),
    .treg_powerup_trim_load_ovr(powerup_trim_load_ovr),
    .treg_prg_rd1_byp(prg_rd1_byp),
    .treg_rd_en_ovr(rd_en_ovr),
    .treg_rd_pulse_meas_en(rd_pulse_meas_en),
    .treg_sah_en(sah_en),
    .treg_scc_otp_en(scc_otp_en),
    .treg_temp(temp),
    .treg_vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),
    .treg_wr_en_ovr(wr_en_ovr)
  );
  //
  ecc_wrapper  ecc_wrapper_u(
    .data_to_encode_i(axi_din),
    .ecc_encoded_data_o(cmx_axi_din),
    .uncorrected_data_i(mram_dout),
    .corrected_data_o(axi_dout),
    .ecc_bypass_en_i(ecc_bypass_en),
    .ref_ecc_sel_i(ref_ecc_sel),
    .single_error_o(ecc_single_error),
    .double_error_o(ecc_double_error),
    .triple_error_o(ecc_triple_error),
    .disable_ted_i(ecc_disable_ted)
  );
endmodule : ctrl_wrapper
