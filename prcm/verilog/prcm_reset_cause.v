/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-05
 Description: A brief description of the file's purpose.
*/

module prcm_reset_cause(
	input wire set,
	input wire clk,
	input wire clear,
	output reg cause
);
always @(posedge clk or posedge set)
	if(set) cause <=1'b1;
	else if(clear) cause <=1'b0;


endmodule
