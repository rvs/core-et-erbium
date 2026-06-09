/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-05
 Description: A brief description of the file's purpose.
*/
module prcm_clk_divider(
input wire clk_in,
input wire [3:0] count,
input wire div_enable,
output wire clk_out
);

reg [3:0] counter=$urandom();
reg divclk=$urandom();

always@(posedge clk_in)begin
	if( counter == 0 )begin
		counter <= count;
		divclk <= ! divclk;
	end
	else counter <= counter - 1;

end

prcm_clk_mux clkmux(
	.a_clk(divclk),
	.b_clk(clk_in),
	.out_clk(clk_out),
	.sel_a(div_enable)
);

endmodule
