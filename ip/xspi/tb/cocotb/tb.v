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

module tb(
output reg xspi_clk,
input wire axi_bid,
input wire axi_rid,
output wire axi_awid,
output wire axi_arid,
input wire bid,
input wire probe_cmd_start,
input wire probe_ext_start,
input wire probe_address_start,
input wire probe_latency_start,
input wire probe_data_start,
input wire probe_cmd_end,
input wire probe_ext_end,
input wire probe_address_end,
input wire probe_latency_end,
input wire probe_data_end,
input wire [255:0] xspi_fsm,
input wire xspi_clk_en,
input wire  RST_N,
input wire flag
);
assign axi_awid=0;
assign axi_arid=0;
  reg  CLK;
  assign #1 CLK = xspi_clk;
  wire  cfg_regs;
  wire  EN_cfg;
  wire RDY_cfg;
  wire status;
  wire RDY_status;
  wire axi_awvalid;
  wire [31 : 0] axi_awaddr;
  wire [7 : 0] axi_awlen;
  wire [2 : 0] axi_awsize;
  wire [1 : 0] axi_awburst;
  wire axi_awlock;
  wire [3 : 0] axi_awcache;
  wire [2 : 0] axi_awprot;
  wire [3 : 0] axi_awqos;
  wire [3 : 0] axi_awregion;
  wire  axi_awready;
  wire axi_wvalid;
  wire [63 : 0] axi_wdata;
  wire [7 : 0] axi_wstrb;
  wire axi_wlast;
  wire  axi_wready;
  wire  axi_bvalid;
  wire  [1 : 0] axi_bresp;
  wire axi_bready;
  wire axi_arvalid;
  wire [31 : 0] axi_araddr;
  wire [7 : 0] axi_arlen;
  wire [2 : 0] axi_arsize;
  wire [1 : 0] axi_arburst;
  wire axi_arlock;
  wire [3 : 0] axi_arcache;
  wire [2 : 0] axi_arprot;
  wire [3 : 0] axi_arqos;
  wire [3 : 0] axi_arregion;
  wire  axi_arready;
  wire  axi_rvalid;
  reg  [63 : 0] axi_rdata;
  wire  [1 : 0] axi_rresp;
  wire  axi_rlast;
  wire axi_rready;
  reg  [7 : 0] xspi_dq_in;
  wire  xspi_rwds_in;
  wire  xspi_csn;
  wire xspi_rwds_out;
  wire RDY_xspi_rwds_out;
  wire [7 : 0] xspi_dq_out;
  wire         xspi_dq_out_ena;
  wire RDY_xspi_dout_data;
 wire mosi=xspi_dq_in[0];
 wire miso=xspi_dq_out[1];
 reg [31:0] miso_data;
 always @(posedge xspi_clk) miso_data <={miso_data[30:0],miso};

 wire  [31 : 0] apb_PADDR;
 wire  [2 : 0] apb_PROT;
 wire  apb_PENABLE;
 wire  apb_PWRITE;
 wire  [63 : 0] apb_PWDATA;
 wire  [7 : 0] apb_PSTRB;
 wire  apb_PSEL;

  // value method apb_s_pready
  wire apb_PREADY;

  // value method apb_s_prdata
  wire [63 : 0] apb_PRDATA;

  // value method apb_s_pslverr
  wire apb_PSLVERR;

  // value method xspi_rwds_out_ena
  wire xspi_rwds_out_ena;

  // action method cfg_default_mode
  wire  [1 : 0] cfg_default_mode_m; // =3;

  // value method cfg_deep_power_down
  wire cfg_deep_power_down;

  // value method cfg_ultra_deep_power_down
  wire cfg_ultra_deep_power_down;

  // value method cfg_drive_strength
  wire [2 : 0] cfg_drive_strength;

  // value method cfg_use_xspi_clk
  wire cfg_use_xspi_clk;

  // value method cfg_reset_device
  wire cfg_reset_device;

  // value method cfg_interrupt
  wire cfg_interrupt;
wire xspi_rwds_out_int;
wire [7:0] xspi_dq_in_int;
wire [7:0] xspi_dq_out_int;
assign xspi_dq_out  = xspi_dq_out_ena ? xspi_dq_out_int : 8'bz;
assign xspi_dq_in_int  = xspi_dq_out_ena ? 8'bz:xspi_dq_in;
assign  xspi_rwds_out = xspi_rwds_out_int;
wire cfg_reset_req;
reg soft_reset_n;
always @(posedge CLK, negedge RST_N)
	if(!RST_N) soft_reset_n <=1'b0;
	else if(cfg_reset_req) soft_reset_n <= 1'b0;
	else soft_reset_n <= 1'b1;
mkxspi dut(
	.xspi_rwds_out(xspi_rwds_out_int),
	.xspi_dq_in(xspi_dq_in_int),
	.xspi_dq_out(xspi_dq_out_int),
	.cfg_reset_device(cfg_reset_req),
	.RST_N(soft_reset_n),
	.*);
initial begin 
	forever begin 
		xspi_clk = 0;
		#5;
		while(xspi_clk_en)begin
			#5 xspi_clk = 1;
			#5 xspi_clk = 0;
		end
	end
end
endmodule
