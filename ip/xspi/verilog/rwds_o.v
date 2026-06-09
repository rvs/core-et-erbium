/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-09
 Description:
	 Implements the RWDS output logic,
	 encapsulates clock muxing for better handling in PNR
*/
module rwds_o(
input wire enable,
output wire rwds_o,
input wire clk,
input wire ddr_mode,
input wire csn);
// If in SDR mode toggle every clock cycle.
// If in DDR mode send the clk out.
//
reg ff_rwds;
always@(posedge clk)
	if (csn) ff_rwds <= 1'b1;
	else if(enable) ff_rwds <= !ff_rwds;

	// rwds_mux rwds_mux(
	// 	.ck(clk),
	// 	.ena(enable),
	// 	.ck_and_ena(ck_and_ena)
	// );

assign rwds_o = enable && (ddr_mode? clk :  ff_rwds);
endmodule

module rwds_mux(
	input ck,
	input ena,
	output ck_and_ena
);
assign ck_and_ena = ck & ena;
endmodule
