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

module tb_hyperbus;
reg clk,rst_n;
	initial begin
		$dumpfile("waves.vcd");
		$dumpvars;
	end
initial begin
	clk=0;
	#1;
	forever clk = #5 ~clk;
end
initial begin
	rst_n=1;
	#10;
	rst_n=0;
	#50;
	rst_n=1;
end

        wire debug_imem_valid;
        wire debug_omem_ready;
        wire [31:0] debug_counter;
        wire [2:0] debug_state;
  // action method axi_m_awvalid
  logic  axi_awvalid;
  logic  [1 : 0] axi_awid;
  logic  [31 : 0] axi_awaddr;
  logic  [7 : 0] axi_awlen;
  logic  [2 : 0] axi_awsize;
  logic  [1 : 0] axi_awburst;
  logic  axi_awlock;
  logic  [3 : 0] axi_awcache;
  logic  [2 : 0] axi_awprot;
  logic  [3 : 0] axi_awqos;
  logic  [3 : 0] axi_awregion;

  // value method axi_m_awready
  logic axi_awready;

  // action method axi_m_wvalid
  logic  axi_wvalid;
  logic  [63 : 0] axi_wdata;
  logic  [7 : 0] axi_wstrb;
  logic  axi_wlast;

  // value method axi_m_wready
  logic axi_wready;

  // value method axi_m_bvalid
  logic axi_bvalid;

  // value method axi_m_bid
  logic [1 : 0] axi_bid;

  // value method axi_m_bresp
  logic [1 : 0] axi_bresp;

  // value method axi_m_buser

  // action method axi_m_bready
  logic  axi_bready;

  // action method axi_m_arvalid
  logic  axi_arvalid;
  logic  [1 : 0] axi_arid;
  logic  [31 : 0] axi_araddr;
  logic  [7 : 0] axi_arlen;
  logic  [2 : 0] axi_arsize;
  logic  [1 : 0] axi_arburst;
  logic  axi_arlock;
  logic  [3 : 0] axi_arcache;
  logic  [2 : 0] axi_arprot;
  logic  [3 : 0] axi_arqos;
  logic  [3 : 0] axi_arregion;

  // value method axi_m_arready
  logic axi_arready;

  // value method axi_m_rvalid
  logic axi_rvalid;

  // value method axi_m_rid
  logic [1 : 0] axi_rid;

  // value method axi_m_rdata
  logic [63 : 0] axi_rdata;

  // value method axi_m_rresp
  logic [1 : 0] axi_rresp;

  // value method axi_m_rlast
  logic axi_rlast;

  // value method axi_m_ruser

  // action method axi_m_rready
  logic  axi_rready;

  // value method hb_out_csn
  logic hb_out_csn;

  // value method hb_out_clk
  logic hb_out_clk;

  // value method hb_out_dq_o
  logic [7 : 0] hb_out_dq_o;
  logic RDY_hb_out_dq_o;

  // value method hb_out_resetn
  logic hb_out_resetn;

  // value method hb_out_rwds_o
  logic hb_out_rwds_o;
  logic RDY_hb_out_rwds_o;

  // action method hb_out_in
  logic  [7 : 0] hb_out_in_i_dq;
  logic  hb_out_in_i_rwds;

  // action method cfg
  logic  [3 : 0] cfg_i_initial_latency;
  logic  [5 : 0] cfg_i_burst_length;
  logic  cfg_i_burst_type;
  logic  cfg_i_txn_32_64;
  logic  cfg_i_cfg_access;
  logic CLK_hb_clk;
  logic RST_N_hb_rstn;
  assign RST_N_hb_rstn=rst_n;
  assign cfg_i_cfg_access=hwif_out.HB_CTRL.reg_access.value;
  assign cfg_i_burst_type=hwif_out.HB_CTRL.burst_type.value;
  assign cfg_i_initial_latency= hwif_out.HB_CTRL.initial_latency.value;
  assign cfg_i_burst_length= hwif_out.HB_CTRL.burst_length.value;
  //assign cfg_i_txn_32_64=hwif_out.HB_CTRL.txn_32_64.value;
  assign cfg_i_txn_32_64=1;
  mkHB_Wrapper hb_ctrl(
	  .CLK(clk),
	  .RST_N(rst_n),
	  .*);
        logic s_axil_awready;
        wire s_axil_awvalid;
        wire [2:0] s_axil_awaddr;
        wire [2:0] s_axil_awprot;
        logic s_axil_wready;
        wire s_axil_wvalid;
        wire [31:0] s_axil_wdata;
        wire [3:0]s_axil_wstrb;
        wire s_axil_bready;
        logic s_axil_bvalid;
        logic [1:0] s_axil_bresp;
        logic s_axil_arready;
        wire s_axil_arvalid;
        wire [2:0] s_axil_araddr;
        wire [2:0] s_axil_arprot;
        wire s_axil_rready;
        logic s_axil_rvalid;
        logic [31:0] s_axil_rdata;
        logic [1:0] s_axil_rresp;

        HB_Reg_pkg::HB_Reg__in_t hwif_in;
        HB_Reg_pkg::HB_Reg__out_t hwif_out;
  HB_Reg hbreg(
	  .arst_n(rst_n),
	  .*);

 wire [31:0] hbslv_awaddr;
 wire [7:0] hbslv_awlen;
 wire [2:0] hbslv_awsize;
 wire [1:0] hbslv_awburst;
 wire hbslv_awlock;
 wire [3:0] hbslv_awcache;
 wire [2:0] hbslv_awprot;
 wire hbslv_awvalid;
 wire hbslv_awready;
 reg  [63:0] hbslv_wdata;
 reg [7:0] hbslv_wstrb;
 reg hbslv_wlast;
 reg hbslv_wvalid;
 wire hbslv_wready;

wire [1:0] hbslv_bresp;
wire hbslv_bvalid;
 wire hbslv_bready;

 wire [31:0] hbslv_araddr;
 wire [7:0]  hbslv_arlen;
 wire [2:0]  hbslv_arsize;
 wire [1:0]  hbslv_arburst;
 wire        hbslv_arlock;
 wire [3:0]  hbslv_arcache;
 wire [2:0]  hbslv_arprot;
 wire         hbslv_arvalid;
 wire        hbslv_arready;
 wire [63:0] hbslv_rdata;
 wire [1:0]  hbslv_rresp;
 wire        hbslv_rlast;
 wire        hbslv_rvalid;
 reg        hbslv_rready;

wire [1:0] hbslv_awid;
wire [1:0] hbslv_arid;
wire [1:0] hbslv_bid;
wire [1:0] hbslv_rid;
  hyperbus dut(
	.dq_in(hb_out_dq_o),
	.dq_out(hb_out_in_i_dq),
	.dq_oen(),
	.rwds_in(hb_out_rwds_o),
	.rwds_out(hb_out_in_i_rwds),
	.rwds_oen(),
// Register Access
        .burst_enable(1'b0),
        .burst_length(2'b0),
	.reg_initial_latency(4'd6),
	.cs_n(hb_out_csn),
// AXI4 Bus side signals
.awaddr(hbslv_awaddr),
.awlen(hbslv_awlen),
.awsize(hbslv_awsize),
.awburst(hbslv_awburst),
.awlock(hbslv_awlock),
.awcache(hbslv_awcache),
.awprot(hbslv_awprot),
.awvalid(hbslv_awvalid),
.awready(hbslv_awready),
.wdata(hbslv_wdata),
.wstrb(hbslv_wstrb),
.wlast(hbslv_wlast),
.wvalid(hbslv_wvalid),
.wready(hbslv_wready),

.bresp(hbslv_bresp),
.bvalid(hbslv_bvalid),
.bready(hbslv_bready),

.araddr(hbslv_araddr),
.arlen(hbslv_arlen),
.arsize(hbslv_arsize),
.arburst(hbslv_arburst),
.arlock(hbslv_arlock),
.arcache(hbslv_arcache),
.arprot(hbslv_arprot),
.arvalid(hbslv_arvalid),
.arready(hbslv_arready),
.rdata(hbslv_rdata),
.rresp(hbslv_rresp),
.rlast(hbslv_rlast),
.rvalid(hbslv_rvalid),
.rready(hbslv_rready),
//
	// ID Signals
//output wire [1:0] awid,
//output wire [1:0] arid,
//input wire [1:0] bid,
//input wire [1:0] rid,

	.clk(hb_out_clk),
	.clk_n(),//Unused
	.rst_n(hb_out_resetn)
  );
endmodule
