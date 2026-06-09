/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-05
 Description: A brief description of the file's purpose.
*/

module prcm_clk_mux(
	input wire a_clk,
	input wire b_clk,
	input wire sel_a,
	output wire out_clk);
assign out_clk = sel_a ? a_clk : b_clk;
endmodule

module prcm_clk_mux_gf(
	input wire a_clk,
	input wire b_clk,
	input wire sel_a,
  input wire rst_n,
	output wire out_clk);

wire a_q,b_q;
et_reset_sync_2ff#(

  .RESET_VALUE(1'b1)
) a_sync(
  .rst_in_n(rst_n),
  .clk(a_clk),
    .d(sel_a&!b_q),
    .q(a_q)

);
et_reset_sync_2ff b_sync (
  .rst_in_n(rst_n),
  .clk(b_clk),
    .d(!sel_a & !a_q),
    .q(b_q)

);
assign out_clk = (a_clk && a_q) || (b_clk && b_q);
endmodule
