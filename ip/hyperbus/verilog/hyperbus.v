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

module hyperbus(
	input wire [7:0] dq_in,
	output wire[7:0]  dq_out,
	output wire dq_oen,

	input wire rwds_in,
	output wire rwds_out,
	output wire rwds_oen,
// Register Access
        input wire       burst_enable,
        input wire [1:0] burst_length,
	input wire [3:0] reg_initial_latency,
	input wire cs_n,
// AXI4 Bus side signals
	output wire [31:0] awaddr,
	output wire [7:0] awlen,
	output wire [2:0] awsize,
	output wire [1:0] awburst,
	output wire awlock,
	output wire [3:0] awcache,
	output wire [2:0] awprot,
	output wire awvalid,
	input  wire awready,
	output reg  [63:0] wdata,
	output reg [7:0] wstrb,
	output reg wlast,
	output reg wvalid,
	input  wire wready,

	input wire [1:0] bresp,
	input wire bvalid,
	output wire bready,

	output wire [31:0] araddr,
	output wire [7:0]  arlen,
	output wire [2:0]  arsize,
	output wire [1:0]  arburst,
	output wire        arlock,
	output wire [3:0]  arcache,
	output wire [2:0]  arprot,
	output wire         arvalid,
	input  wire        arready,
	input  wire [63:0] rdata,
	input  wire [1:0]  rresp,
	input  wire        rlast,
	input  wire        rvalid,
	output reg        rready,
	// ID Signals
//output wire [1:0] awid,
//output wire [1:0] arid,
//input wire [1:0] bid,
//input wire [1:0] rid,

	input wire clk,
	input wire clk_n,//Unused
	input wire rst_n


);

// Parameters
	parameter CMD=1;
	parameter LATENCY=2;
	parameter WRITE=3;
	parameter READ=4;
	parameter TCM_MAX_ADDRESS='h5000;

//Wires
	reg ddr_out_en;
	wire reg_txn, ddr_rwds_out;
	wire zero_latency=reg_txn ;
	reg double_latency;
	reg next_double_latency;
	reg [3:0] state;
	reg [3:0] next_state;
	reg[5:0] count;
	reg[5:0] next_count;


// Command Decode
// ///////Alternative
       reg[7:0] xwstrb;
       wire [63:0]rdata_mux;
      assign rdata_mux[63:32]=rdata[63:32];
      assign rdata_mux[31:0]= araddr[2] ? rdata[63:32]: rdata[31:0];

	reg[47:0] xcmd;
	reg[5:0] xcount;
	reg [3:0] xstate;
	wire read_txn=xcmd[47]==1;
	wire write_txn=!read_txn;
	wire mem_txn=xcmd[46]==0;
	assign reg_txn=!mem_txn;
	wire linear_burst=xcmd[45];
	wire wrapped_burst=!linear_burst;
	reg avalid;
	reg [31:0] address;
	assign awaddr=address;
	assign araddr=address;
	assign awvalid=avalid &&write_txn;
	assign arvalid=avalid &&read_txn;
	wire axi_atxn = (awvalid && awready) || (arvalid && arready);
	wire axi_wtxn = (wvalid && wready);
// address logic
always @(*)begin
	address[31:3]=xcmd[44:16];
	address[2:0]=xcmd[2:0];
	if (reg_txn)
		address=address|'h5000;
end
// /////////////////

// RWDS
notAClockGate rwds_mux_clk(
	.a(clk),
	.b(ddr_rwds_out),
	.a_and_b(rwds_and_clk)
);
// assign rwds_out=ddr_out_en ?clk& ddr_rwds_out:0;
assign rwds_out=ddr_out_en ?rwds_and_clk:0;
assign rwds_oen=(state==CMD||state== READ)?1:0;

// AXI Signals
	//Defaults
	// assign awid=0;
	// assign arid=0;
	assign awcache=0;
	assign arcache=0;
	assign arsize=3;
	assign awsize=3;
	assign awburst=1;
	assign arburst=1;
	assign arlock=0;// Removed in AXI4
	assign awlock=0;// Removed in AXI4
	assign arprot=0;// No Burst. TODO Should we change this based on Register/Memory Access?
	assign awprot=0;// No Burst. TODO Should we change this based on Register/Memory Access?
	assign bready=1;


// Transaction Signals
 reg addr_valid,next_addr_valid;

	

//burst_decode
reg [7:0] burst_count;
wire [7:0] axi_len = (reg_txn || (burst_enable==0))?0 : burst_length==00 ? 15 : burst_length==01 ? 7 : burst_length ==2 ? 1: 3;
assign awlen =axi_len;
assign arlen =axi_len;
// Latency decode
	wire [3:0] latency_cycles=(reg_initial_latency==4'b1111)?4:
		(reg_initial_latency== 4'b1110)?3:
		(reg_initial_latency== 4'b1011)?16:
		(reg_initial_latency== 4'b1010)?15:
		(reg_initial_latency== 4'b1001)?14:
		(reg_initial_latency== 4'b1000)?13:
		(reg_initial_latency== 4'b0111)?12:
		(reg_initial_latency== 4'b0110)?11:
		(reg_initial_latency== 4'b0101)?10:
		(reg_initial_latency== 4'b0100)?9:
		(reg_initial_latency== 4'b0011)?8:
		(reg_initial_latency== 4'b0010)?7:
		(reg_initial_latency== 4'b0001)?6:
		(reg_initial_latency== 4'b0000)?5:0;

// FSM
reg cs_delayed;
wire fe_csn = ~cs_n && cs_delayed;
	always@(posedge clk)begin
		cs_delayed<=cs_n;
	end
	always@(negedge clk)begin
		if(cs_n && cs_delayed)begin
			state<=CMD;
			count<=2;
			double_latency<=0;
			addr_valid<=0;
		end else begin
			state<=next_state;
			count<=next_count;
			double_latency<=next_double_latency;
			addr_valid<=next_addr_valid;

		end
	end
	always @(*)begin
		next_state=state;
		next_count=count;
		next_addr_valid=addr_valid && !((read_txn & arready)||(write_txn&&awready));
		next_double_latency=double_latency;
		case(state)
		CMD:begin
			next_count=count-1;
			if(count==0)begin
				next_addr_valid=1;
				if (zero_latency)begin
					next_count=3;
					if(write_txn) next_state=WRITE;
					else next_state=READ;
				end else begin
					next_count = {2'b0,latency_cycles}-1;
					next_state=LATENCY;
				end
			end
		end
		LATENCY:begin
			next_count=count-1;
			if (count==0)begin
				if(double_latency)begin
					next_count={2'b0,latency_cycles};
					next_double_latency=0;
				end
				else begin
					next_count=3;
					if(write_txn) next_state=WRITE;
					else next_state=READ;
				end
			end
		end
		WRITE:begin
			if (count == 0 ) next_count =3;
			else next_count=count -1;
		end
		READ:begin
			if (count == 0 ) next_count =3;
			else next_count = count - 1;
		end
		default:
			next_state =CMD;

		endcase
	end
	wire [15:0] ddr_out;
	wire [1:0]ddr_out_wstrb;
	wire ddr_out_valid;
	ddr_in_cell #(.WIDTH(8))d(
		.d_in(dq_in),
		.d_out(ddr_out),
		.d_out_valid(ddr_out_valid),
		.rwds_in(rwds_in),
		.wstrb(ddr_out_wstrb),
		.en(state==CMD || state==WRITE),
		.cs_n(cs_n),
		.clk(clk),
		.rst_n(~(cs_delayed&&cs_n))

	);

	always @(posedge clk)begin
		ddr_out_en<=rvalid&&state==READ;
	end
	//// Alternative ending.
	reg [15:0] dout_data_in ;
	reg dout_data_in_en;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			avalid <=1'b0;
			rready <= 1;
			wlast <= 1;
			wvalid <= 0;
      xstate<=CMD;
      xcmd<=0;
      xcount<=0;
      dout_data_in_en<=0;
      wstrb<=0;
      burst_count<=0;
		end
		else begin
			if(axi_atxn) avalid<=1'b0;
			if(axi_wtxn) wvalid<=1'b0;
			if (fe_csn)begin
				xstate<=CMD;
        xcmd<=0;
				xcount<=2;
				wlast <= 1;
				rready <= 1;
			end
			else begin
				dout_data_in_en<=0;
				case (xstate)
          CMD: begin
            if(cs_n==0)begin
              if(ddr_out_valid)begin
                case(xcount)
                  0: xcmd[15:0]<=ddr_out;
                  1: xcmd[31:16]<=ddr_out;
                  2: xcmd[47:32]<=ddr_out;
                endcase
                xcount <=xcount - 1;
              end
              if (xcount == 0)begin
                if (reg_txn) begin
                  xcount<=3;
                  if (write_txn) xstate<=WRITE;
                  if (read_txn) xstate<=READ;
                end else xstate <= LATENCY;
                wstrb<=0;
              avalid <= 1'b1;
              rready <= 0;
              if (reg_txn) burst_count <= 0;
              else burst_count <= axi_len;
            end
        end
      end
        LATENCY:begin
            xcount<=3;
            xstate<=state;
            // if (ddr_out_valid && write_txn) xstate <= WRITE;
            // else if (read_txn) xstate <= state;
      end
					WRITE:begin
						if(ddr_out_valid)begin
							case(xcount)
								0:begin wdata[63:48]<=ddr_out;wstrb[7:6]<= ddr_out_wstrb;end
								1:begin wdata[47:32]<=ddr_out;wstrb[5:4]<= ddr_out_wstrb;end
								2:begin wdata[31:16]<=ddr_out;wstrb[3:2]<= ddr_out_wstrb;end
								3:begin wdata[15:0]<=ddr_out;wstrb[1:0]<= ddr_out_wstrb;end
							endcase
              if(reg_txn) wstrb <='h0f;
							xcount <= xcount -1;
							if(xcount ==0)
							begin
								wvalid <= 1;
								xcount<= 3;
								wlast <= burst_count ==0;
								burst_count<= burst_count - 1;
								if(burst_count == 0) xstate <= CMD;
							end
						end else if(cs_n) begin
							if(xcount!=3)begin
							wvalid <= 1;
							wdata[63:32]<=wdata[31:0];
							if (awaddr[2])begin
								wstrb[7:4]<=wstrb[3:0];
								wstrb[3:0]<=0;
							end
							else
								wstrb[7:4]<=0;
							end
							xstate<=CMD;
						end
					end
					READ:begin
						rready<=0;
						if(rvalid &&state==READ)begin
							xcount <= xcount -1;

							case(xcount)
								3:dout_data_in=rdata_mux[15:0];
								2:dout_data_in=rdata_mux[31:16];
								1:dout_data_in=rdata_mux[47:32];
								0:dout_data_in=rdata_mux[63:48];
							endcase
							dout_data_in_en<=1;
							if(xcount ==1) rready <= 1;
							if(xcount ==0) xcount <= 3;
						end
						if(cs_n) begin
								rready <= 1;
								xstate<=CMD;
							end
						end
				endcase

			end
		end
	end
	ddr_out_cell dout(
		.data_in(dout_data_in),
		.en(dout_data_in_en),
		.d_out(dq_out),
		.rwds(ddr_rwds_out),
		.d_out_en(dq_oen),
		.clk(clk),
		.cs_(cs_n)
	);
		endmodule
		// vim: foldmethod=indent
