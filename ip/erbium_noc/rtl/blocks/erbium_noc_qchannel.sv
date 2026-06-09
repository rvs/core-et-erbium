// SPDX-License-Identifier: Apache-2.0
// Q-Channel clock-quiescence handshake device.
// Per clock domain. Accepts a clock-stop request (QREQn low) only when the
// domain is idle; denies (QDENY) while busy. QACTIVE indicates wanted-clock.
// Per clock domain.
module erbium_noc_qchannel (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic busy_i,        // 1 = outstanding activity in this domain
  // Q-Channel (device side)
  output logic qactive_o,     // request the clock to be running
  input  logic qreqn_i,       // low = request to stop the clock
  output logic qacceptn_o,    // low = accept the stop request
  output logic qdeny_o        // high = deny the stop request
);
  typedef enum logic [1:0] {Q_RUN, Q_STOPPED, Q_DENIED} state_e;
  state_e st_q, st_d;

  assign qactive_o = busy_i;  // assert whenever there is work to do

  always_comb begin
    st_d       = st_q;
    qacceptn_o = 1'b1;        // Q_RUN: clock running, not accepting
    qdeny_o    = 1'b0;
    unique case (st_q)
      Q_RUN: if (!qreqn_i) begin              // clock-stop requested
               if (busy_i) st_d = Q_DENIED;   // can't stop while busy
               else        st_d = Q_STOPPED;
             end
      Q_STOPPED: begin
        qacceptn_o = 1'b0;                     // accepted: clock may stop
        if (qreqn_i) st_d = Q_RUN;             // exit low-power
      end
      Q_DENIED: begin
        qdeny_o = 1'b1;                        // denied: controller must release
        if (qreqn_i) st_d = Q_RUN;
      end
      default: st_d = Q_RUN;
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni)
    if (!rst_ni) st_q <= Q_RUN; else st_q <= st_d;
endmodule
