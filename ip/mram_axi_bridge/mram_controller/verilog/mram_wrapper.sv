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
// Cell             : mram_wrapper
// View             : schematic
// View Search List : verilog functional behavioral cmos.sch cmos_sch vsymbol schematic symbol
// View Stop List   : functional behavioral symbol vsymbol
////////////////////////////////////////////////////////////////////////////////
module mram_wrapper # (
      int BANK_ID = 0
    ) (
    input  [4:0]    PADDR,
    input           PENABLE,
    input           PSEL,
    input  [3:0]    PSTRB,
    input  [31:0]   PWDATA,
    input           PWRITE,
    input  [17:0]   axi_add,
    input  [7:0]    axi_bwe,
    input  [63:0]   axi_din,
    input  [3:0]    axi_stripe_sel,
    input           axi_we,
    input           clk,
    input           dsleep,
    input           nvsram_startup_bypass,
    input           rst_b,
    input  [3:0]    tp_add,
    input  [63:0]   tp_bwe,
    input           tp_ce,
    input  [63:0]   tp_din,
    input           tp_we,
    input           vdd,
    input           vdd18,
    input           vss,
    output [31:0]   PRDATA,
    output          PREADY,
    output          axi_busy,
    output [63:0]   axi_dout,
    output          cpu_intr,
    output          tp_busy,
    output [63:0]   tp_reg_out,
    output          tp_valid,
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
  wire  [17:0] mram_addr_in;
  wire         mram_busy;
  wire  [78:0] mram_bwe;
  wire  [3:0]  mram_clk;
  wire  [78:0] mram_din;
  wire  [78:0] mram_dout;
  wire         mram_dsleep;
  wire         mram_pwr_ok;
  wire         mram_rst_b;
  wire  [3:0]  mram_stripe_sel;
  wire         mram_we;
  wire  [3:0]  odd_man_stripe_sel;
  wire  [3:0]  odd_man_wr;
  wire         otp_wr_en;
  wire  [3:0]  powerup_trim_load_ovr;
  wire         prg_rd1_byp;
  wire         pwr_up_sel;
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
  //
  ctrl_wrapper  ctrl_wrapper_u(
    .wr_en_ovr(wr_en_ovr),
    .vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),
    .tp_we(tp_we),
    .tp_valid(tp_valid),
    .tp_reg_out(tp_reg_out),
    .tp_din(tp_din),
    .tp_ce(tp_ce),
    .tp_bwe(tp_bwe),
    .tp_busy(tp_busy),
    .tp_add(tp_add),
    .temp(temp),
    .sah_en(sah_en),
    .rst_b(rst_b),
    .reg_logic_sup_sleep(reg_logic_sup_sleep),
    .ref_prg_en(ref_prg_en),
    .rd_pulse_meas_en(rd_pulse_meas_en),
    .rd_en_ovr(rd_en_ovr),
    .rca_ovr_en(rca_ovr_en),
    .rca_ovr(rca_ovr),
    .pwr_up_sel(pwr_up_sel),
    .pwr_ok(mram_pwr_ok),
    .prg_rd1_byp(prg_rd1_byp),
    .otp_wr_en(otp_wr_en),
    .powerup_trim_load_ovr(powerup_trim_load_ovr),
    .odd_man_wr(odd_man_wr),
    .odd_man_stripe_sel(odd_man_stripe_sel),
    .nvsram_startup_bypass(nvsram_startup_bypass),
    .mram_we(mram_we),
    .mram_stripe_sel(mram_stripe_sel),
    .mram_dsleep(mram_dsleep),
    .mram_dout(mram_dout),
    .mram_din(mram_din),
    .mram_clk(mram_clk),
    .mram_bwe(mram_bwe),
    .mram_add(mram_addr_in),
    .test_cal_en(test_cal_en),
    .gbl_cfg_ovr_en(gbl_cfg_ovr_en),
    .gbl_cfg(gbl_cfg),
    .even_man_wr(even_man_wr),
    .even_man_stripe_sel(even_man_stripe_sel),
    .dsleep(dsleep),
    .dma_en(dma_en),
    .cpu_intr(cpu_intr),
    .clk(clk),
    .mram_busy(mram_busy),
    .axi_busy(axi_busy),
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
    .axi_we(axi_we),
    .axi_stripe_sel(axi_stripe_sel),
    .axi_dout(axi_dout),
    .axi_din(axi_din),
    .axi_bwe(axi_bwe),
    .axi_add(axi_add),
    .anatest1_sel(anatest1_sel),
    .anatest0_sel(anatest0_sel),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PSEL(PSEL),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .scc_otp_en(scc_otp_en),
    .mram_rst_b(mram_rst_b)
  );
  //
`ifdef BEHAVIORAL_BANK
  bank #(
    .ADDR_WIDTH(18)
  ) bank_u (
    .din(mram_din),
    .bwe(mram_bwe),
    .addr_in(mram_addr_in), // 2^21 = 2M addresses.
    .clk(mram_clk[0]),
    .stripe_sel(mram_stripe_sel),
    .we(mram_we),
    .rst_b(mram_rst_b),
    .dout(mram_dout),
    .pwr_ok(mram_pwr_ok),
    .busy(mram_busy),
    .anatest0_sel(anatest0_sel),
    .anatest1_sel(anatest1_sel),
    .cal_clk_en(cal_clk_en),
    .cal_clk_speed(cal_clk_speed),
    .dma_en(dma_en),
    .dsleep(mram_dsleep),
    .gbl_cfg_ovr_en(gbl_cfg_ovr_en),
    .nv_sram_en(nvsram_en),
    .otp_wr_en(otp_wr_en),
    .powerup_trim_load_ovr(powerup_trim_load_ovr),
    .prg_rd1_byp(prg_rd1_byp),
    .pwr_up_sel(pwr_up_sel),
    .rca_ovr(rca_ovr),
    .rca_ovr_en(rca_ovr_en),
    .rd_en_ovr(rd_en_ovr),
    .rd_pulse_meas_en(rd_pulse_meas_en),
    .ref_prg_en(ref_prg_en),
    .reg_logic_sup_sleep(reg_logic_sup_sleep),
    .reg_logic_sup_sleep_b(reg_logic_sup_sleep_b),
    .sa_cal_clk(sa_cal_clk),
    .sa_cal_en(sa_cal_en),
    .sah_en(sah_en),
    .scc_otp_en(scc_otp_en),
    .vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),
    .wr_en_ovr(wr_en_ovr),
    .gen_sa_cal_clk(gen_sa_cal_clk),
    .nvsram_boot_err(nvsram_boot_err),
    .temp(temp),
    .ANATEST0(ANATEST0),
    .ANATEST1(ANATEST1),
    .blk0_man_ccnt(blk0_man_ccnt),
    .blk0_man_cnfg(blk0_man_cnfg),
    .blk0_man_fcnt(blk0_man_fcnt),
    .blk1_man_ccnt(blk1_man_ccnt),
    .blk1_man_cnfg(blk1_man_cnfg),
    .blk1_man_fcnt(blk1_man_fcnt),
    .blk2_man_ccnt(blk2_man_ccnt),
    .blk2_man_cnfg(blk2_man_cnfg),
    .blk2_man_fcnt(blk2_man_fcnt),
    .blk3_man_ccnt(blk3_man_ccnt),
    .blk3_man_cnfg(blk3_man_cnfg),
    .blk3_man_fcnt(blk3_man_fcnt),
    .blk4_man_ccnt(blk4_man_ccnt),
    .blk4_man_cnfg(blk4_man_cnfg),
    .blk4_man_fcnt(blk4_man_fcnt),
    .blk5_man_ccnt(blk5_man_ccnt),
    .blk5_man_cnfg(blk5_man_cnfg),
    .blk5_man_fcnt(blk5_man_fcnt),
    .blk6_man_ccnt(blk6_man_ccnt),
    .blk6_man_cnfg(blk6_man_cnfg),
    .blk6_man_fcnt(blk6_man_fcnt),
    .blk7_man_ccnt(blk7_man_ccnt),
    .blk7_man_cnfg(blk7_man_cnfg),
    .blk7_man_fcnt(blk7_man_fcnt),
    .even_man_stripe_sel(even_man_stripe_sel),
    .even_man_wr(even_man_wr),
    .gbl_cfg(gbl_cfg),
    .odd_man_stripe_sel(odd_man_stripe_sel),
    .odd_man_wr(odd_man_wr)
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
    .clk(mram_clk), \
    .din(mram_din), \
    .dma_en(dma_en),  \
    .dout(mram_dout), \
    .dsleep(mram_dsleep), \
    .even_man_stripe_sel(even_man_stripe_sel),  \
    .even_man_wr(even_man_wr),  \
    .gbl_cfg(gbl_cfg),  \
    .gbl_cfg_ovr_en(gbl_cfg_ovr_en),  \
    .odd_man_stripe_sel(odd_man_stripe_sel),  \
    .odd_man_wr(odd_man_wr),  \
    .otp_wr_en(otp_wr_en),  \
    .powerup_trim_load_ovr(powerup_trim_load_ovr),  \
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
    .stripe_sel(mram_stripe_sel), \
    .temp(temp),  \
    .vblslx_gain_mode_ovr(vblslx_gain_mode_ovr),  \
    .test_cal_en(test_cal_en),  \
    .pwr_up_sel(pwr_up_sel),  \
    .wr_en_ovr(wr_en_ovr),  \
    .we(mram_we)

  generate
    if (BANK_ID == 0) begin : g_bank1
      `ifdef BANK_1_MODULE
        `BANK_1_MODULE bank_u (`BANK_PORT_LIST);
      `else
        bank          bank_u (`BANK_PORT_LIST); // fallback
      `endif
    end else if (BANK_ID == 1) begin : g_bank2
      `ifdef BANK_2_MODULE
        `BANK_2_MODULE bank_u (`BANK_PORT_LIST);
      `else
        bank          bank_u (`BANK_PORT_LIST); // fallback
      `endif
    end else begin : g_default
      bank bank_u (`BANK_PORT_LIST); // default if neither 1 nor 2
    end
  endgenerate
`endif
endmodule : mram_wrapper
