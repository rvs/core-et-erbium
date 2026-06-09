/*
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>
Created on: 2026-02-06
Description: A brief description of the file's purpose.
 */
module rom#(parameter ADDRESS_WIDTH=10,parameter DATA_WIDTH=64)(
		input wire [ADDRESS_WIDTH-1:0] address,
		input wire enable,
		input wire clk,
		input wire deep_sleep,
		input wire rst_n,
		output wire [DATA_WIDTH -1 :0] dout
		);

`ifdef SIMULATION
initial $display("Using Simulation UPF model for bootrom");
supply1 vdd;
supply0 vss;
`else
initial $display("Using Device model for bootrom");
`endif

`ifdef SIMULATION
bootrom64_upf rom64b_0(
	.vdd(vdd),
	.vss(vss),
`else
rom_64kb_top rom64b_0(
`endif
	.addr(address[ADDRESS_WIDTH -1:0]),
	.ce(enable),
	.ds(deep_sleep),
	.clk(clk),
	.rd_out(dout),
	.rst_b(rst_n));

endmodule

