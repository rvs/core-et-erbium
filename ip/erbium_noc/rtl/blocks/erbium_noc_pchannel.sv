// SPDX-License-Identifier: Apache-2.0
// P-Channel power-state handshake device.
// For the single power domain pd_0. Accepts a requested power state after a
// programmable settling delay (TINIT-style); never denies (this fabric has no
// retention constraints of its own).
module erbium_noc_pchannel #(
  parameter int unsigned PSTATE_W = 4,
  parameter int unsigned TINIT    = 37   // accept latency in clk cycles
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  output logic                 pactive_o,        // 1 = domain active
  input  logic                 preq_i,           // request a new power state
  input  logic [PSTATE_W-1:0]  pstate_i,
  output logic                 paccept_o,         // pulse: state accepted
  output logic                 pdeny_o            // never asserted here
);
  typedef enum logic [1:0] {P_IDLE, P_SETTLE, P_ACK} state_e;
  state_e st_q, st_d;
  logic [$clog2(TINIT+1)-1:0] cnt_q, cnt_d;
  logic [PSTATE_W-1:0]        pstate_q, pstate_d;

  assign pdeny_o   = 1'b0;
  assign pactive_o = (pstate_q != '0);          // non-zero state = active

  always_comb begin
    st_d = st_q; cnt_d = cnt_q; pstate_d = pstate_q;
    paccept_o = 1'b0;
    unique case (st_q)
      P_IDLE:   if (preq_i) begin pstate_d = pstate_i; cnt_d = TINIT[$bits(cnt_q)-1:0]; st_d = P_SETTLE; end
      P_SETTLE: if (cnt_q == '0) st_d = P_ACK; else cnt_d = cnt_q - 1'b1;
      P_ACK: begin paccept_o = 1'b1; if (!preq_i) st_d = P_IDLE; end
      default: st_d = P_IDLE;
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni)
    if (!rst_ni) begin st_q<=P_IDLE; cnt_q<='0; pstate_q<='0; end
    else         begin st_q<=st_d;   cnt_q<=cnt_d; pstate_q<=pstate_d; end
endmodule
