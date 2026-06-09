// SPDX-License-Identifier: Apache-2.0
// Reset synchronizer: asynchronous assert, synchronous de-assert.
// Standard two/three-flop CDC practice.
module erbium_noc_reset_sync #(
  parameter int unsigned Stages = 3
) (
  input  logic clk_i,
  input  logic rst_n_async_i,   // async active-low reset in
  output logic rst_n_sync_o     // de-asserts synchronously to clk_i
);
  (* async_reg = "true" *) logic [Stages-1:0] sync_q;
  always_ff @(posedge clk_i or negedge rst_n_async_i)
    if (!rst_n_async_i) sync_q <= '0;
    else                sync_q <= {sync_q[Stages-2:0], 1'b1};
  assign rst_n_sync_o = sync_q[Stages-1];
endmodule
