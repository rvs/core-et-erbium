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

module tb;
  logic [16:0]  axi_add;
  logic [63:0]  axi_bwe;
  logic [63:0]  axi_din;
  logic [7:0]   axi_ce;
  logic [7:0]   axi_dout_en;
  logic         axi_we;
  logic         clk;
  logic         dsleep;
  logic         nvsram_startup_bypass;
  logic         rst_b;
  logic         vdd;
  logic         vdd18;
  logic         vss;

  wire [7:0]    axi_busy;
  wire [127:0]  axi_dout;
  wire          cpu_intr;
  tri           ANATEST0;
  tri           ANATEST1;
  logic         tregs_s_axil_awready;
  logic         tregs_s_axil_awvalid;
  logic [9:0]   tregs_s_axil_awaddr;
  logic [2:0]   tregs_s_axil_awprot;
  logic         tregs_s_axil_wready;
  logic         tregs_s_axil_wvalid;
  logic [63:0]  tregs_s_axil_wdata;
  logic [7:0]   tregs_s_axil_wstrb;
  logic         tregs_s_axil_bready;
  logic         tregs_s_axil_bvalid;
  logic [1:0]   tregs_s_axil_bresp;
  logic         tregs_s_axil_arready;
  logic         tregs_s_axil_arvalid;
  logic [9:0]   tregs_s_axil_araddr;
  logic [2:0]   tregs_s_axil_arprot;
  logic         tregs_s_axil_rready;
  logic         tregs_s_axil_rvalid;
  logic [63:0]  tregs_s_axil_rdata;
  logic [1:0]   tregs_s_axil_rresp;

  initial begin
    tregs_s_axil_awvalid = 1'b0;
    tregs_s_axil_awaddr  = '0;
    tregs_s_axil_awprot  = '0;
    tregs_s_axil_wvalid  = 1'b0;
    tregs_s_axil_wdata   = '0;
    tregs_s_axil_wstrb   = '0;
    tregs_s_axil_bready  = 1'b1;
    tregs_s_axil_arvalid = 1'b0;
    tregs_s_axil_araddr  = '0;
    tregs_s_axil_arprot  = '0;
    tregs_s_axil_rready  = 1'b1;
  end
  import external_test_regs_pkg::*;
  external_test_regs_pkg::external_test_regs__out_t tregs_hwif_out;
  external_test_regs_pkg::external_test_regs__in_t tregs_hwif_in;
  erbium_et_bank_wrapper dut (
    .reg_clk(clk),
    .reg_rst_b(rst_b),
    .reg_req(tregs_hwif_out.test_regs.req),
    .reg_req_is_wr(tregs_hwif_out.test_regs.req_is_wr),
    .reg_addr(tregs_hwif_out.test_regs.addr),
    .reg_wr_data(tregs_hwif_out.test_regs.wr_data),
    .reg_wr_biten(tregs_hwif_out.test_regs.wr_biten),
    .reg_req_stall_wr(),
    .reg_req_stall_rd(),
    .reg_rd_ack(tregs_hwif_in.test_regs.rd_ack),
    .reg_rd_err(),
    .reg_rd_data(tregs_hwif_in.test_regs.rd_data),
    .reg_wr_ack(tregs_hwif_in.test_regs.wr_ack),
    .reg_wr_err(),


    .axi_add(axi_add),
    .axi_bwe(axi_bwe),
    .axi_din(axi_din),
    .axi_ce(axi_ce),
    .axi_dout_en(axi_dout_en),
    .axi_we(axi_we),
    .clk(clk),
    .dsleep(dsleep),
    .nvsram_startup_bypass(nvsram_startup_bypass),
    .rst_b(rst_b),
    .vdd(vdd),
    .vdd18(vdd18),
    .vss(vss),
    .axi_busy(axi_busy),
    .axi_dout(axi_dout),
    .cpu_intr(cpu_intr),
    .ANATEST0(ANATEST0),
    .ANATEST1(ANATEST1)
  );

  external_test_regs tregs (
    .clk(clk),
    .arst_n(rst_b),
    .s_axil_awready(tregs_s_axil_awready),
    .s_axil_awvalid(tregs_s_axil_awvalid),
    .s_axil_awaddr(tregs_s_axil_awaddr),
    .s_axil_awprot(tregs_s_axil_awprot),
    .s_axil_wready(tregs_s_axil_wready),
    .s_axil_wvalid(tregs_s_axil_wvalid),
    .s_axil_wdata(tregs_s_axil_wdata),
    .s_axil_wstrb(tregs_s_axil_wstrb),
    .s_axil_bready(tregs_s_axil_bready),
    .s_axil_bvalid(tregs_s_axil_bvalid),
    .s_axil_bresp(tregs_s_axil_bresp),
    .s_axil_arready(tregs_s_axil_arready),
    .s_axil_arvalid(tregs_s_axil_arvalid),
    .s_axil_araddr(tregs_s_axil_araddr),
    .s_axil_arprot(tregs_s_axil_arprot),
    .s_axil_rready(tregs_s_axil_rready),
    .s_axil_rvalid(tregs_s_axil_rvalid),
    .s_axil_rdata(tregs_s_axil_rdata),
    .s_axil_rresp(tregs_s_axil_rresp),
    .hwif_in(tregs_hwif_in),
    .hwif_out(tregs_hwif_out)
  );

`ifdef DUMP_WAVES
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
`endif
endmodule
