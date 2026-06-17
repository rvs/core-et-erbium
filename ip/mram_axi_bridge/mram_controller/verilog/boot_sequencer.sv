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

module boot_sequencer (
    input   logic             clk_i,
    input   logic             rst_bi,
    input   logic             pwr_ok_i,
    input   logic             nvsram_startup_bypass_i,
    input   logic             mram_busy_i,
    input   logic             reg_logic_sup_sleep_ovr_i,

    output  logic             mram_rst_bo,
    output  logic             pwr_up_sel_o,
    output  logic             reg_logic_sup_sleep_o,
    output  logic             axi_busy_o,
    output  logic             mram_ready_o
  );
  logic             pwr_ok_q;
  logic             pwr_ok_q1;
  logic             pwr_ok_syncd;
  logic             mram_rst_b;
  logic             kickstart_ena0;
  logic             kickstart_ena1;
  logic             state_0_d;
  logic             state_0_q;
  logic             done_d;
  logic             done_q;
  logic             stop_d;
  logic             stop_q;
  logic             busy_rise_detect;
  logic             busy_fall_detect;
  wire              busy_wait;
  wire              busy_not_fallen;
  //
  // Let's calculate the axi_busy_o output ...
  //
  assign pwr_ok_syncd = pwr_ok_q & pwr_ok_q1;
  assign axi_busy_o       = mram_busy_i | ~pwr_ok_syncd & ~nvsram_startup_bypass_i & ~stop_q;
  assign mram_ready_o     = nvsram_startup_bypass_i ? pwr_ok_syncd  : pwr_ok_syncd & stop_q;
  //
  // Bootup process will start at pwr_ok_i, unless nvsram_startup_bypass
  // is enabled. It should not restart once bootup process has started
  // or is completed.
  //
  assign  mram_rst_b      =  pwr_ok_q & pwr_ok_q1  &  rst_bi;
  assign  mram_rst_bo     =  mram_rst_b;
  assign  kickstart_ena0  =  pwr_ok_q1  &  ~nvsram_startup_bypass_i;
  //
  // As I believe that pwr_ok_i has no particular synchronization to clk_i, it
  // should be synchronized here before use.
  //
  boot_seq_ff#(1'b0)  ipwr_ok_q       (
                                        .clk(clk_i),
                                        .rst_b(rst_bi),
                                        .ena(1'b1),
                                        .d(pwr_ok_i),
                                        .q(pwr_ok_q)
  );
  //
  // Let's wait one full cycle after pwr_ok to release mram_rst_b ...
  //
  boot_seq_ff#(1'b0)  ipwr_ok_q1      (
                                        .clk(clk_i),
                                        .rst_b(rst_bi),
                                        .ena(1'b1),
                                        .d(pwr_ok_q),
                                        .q(pwr_ok_q1)
  );
  //
  // ... and we'll wait another cycle before starting the boot sequence ...
  //
  boot_seq_ff#(1'b0)  ikickstart      (
                                        .clk(clk_i),
                                        .rst_b(mram_rst_b),
                                        .ena(~kickstart_ena1),
                                        .d(kickstart_ena0),
                                        .q(kickstart_ena1)
  );
  //
  // Let's detect the falling edge of mram_busy_i ...
  //
  //boot_seq_ff#(1'b0)  isbusy0         (
  //                                      .clk(clk_i),
  //                                      .rst_b(mram_rst_b),
  //                                      .ena(~stop_q),
  //                                      .d(mram_busy_i),
  //                                      .q(sync_mram_busy0)
  //);
  //boot_seq_ff#(1'b0)  isbusy1         (
  //                                      .clk(clk_i),
  //                                      .rst_b(mram_rst_b),
  //                                      .ena(~stop_q),
  //                                      .d(sync_mram_busy0),
  //                                      .q(sync_mram_busy1)
  //);
  assign busy_rise_detect  =  mram_rst_b & (~state_0_q  | ~mram_busy_i);

  boot_seq_ff#(1'b0)  ibusy_detect   (                                   // NOTE :  This is the same logic as generates pwr_up_sel_o, which is also the same as state_0_q.
                                        .clk(clk_i),
                                        .rst_b(busy_rise_detect),        //
                                        .ena(~stop_q),
                                        .d(state_0_d),
                                        .q(busy_wait)
  );

  assign busy_fall_detect  =  mram_rst_b & (busy_wait  |  mram_busy_i  |  ~state_0_q);
  boot_seq_ff#(1'b0)  ibusy_fall_detect (
                                        .clk(clk_i),
                                        .rst_b(busy_fall_detect),
                                        .ena(~stop_q),
                                        .d(state_0_d),
                                        .q(busy_not_fallen)
  );
  //assign mram_busy_fall = ~sync_mram_busy0 & sync_mram_busy1;
  //assign state_0_d  = (~done_q & kickstart_ena1) | (done_q & ~mram_busy_fall);
  assign state_0_d  = (~done_q & kickstart_ena1) | (done_q & busy_not_fallen);
  boot_seq_ff#(1'b0)  state_reg_0     (
                                        .clk(clk_i),
                                        .rst_b(mram_rst_b),
                                        .ena(~stop_q),
                                        .d(state_0_d),
                                        .q(state_0_q)
  );
  assign done_d = state_0_q;
  boot_seq_ff#(1'b0)  done_reg_4     (
                                        .clk(clk_i),
                                        .rst_b(mram_rst_b),
                                        .ena(~stop_q),
                                        .d(done_d),
                                        .q(done_q)
  );
  //assign stop_d = done_q & mram_busy_fall;
  assign stop_d = done_q & ~busy_not_fallen;
  boot_seq_ff#(1'b0)  fin_reg_4     (
                                        .clk(clk_i),
                                        .rst_b(mram_rst_b),
                                        .ena(~stop_q),
                                        .d(stop_d),
                                        .q(stop_q)
  );
assign  pwr_up_sel_o  =  state_0_q;
assign  reg_logic_sup_sleep_o  =  reg_logic_sup_sleep_ovr_i & (~pwr_ok_i | stop_q);

endmodule : boot_sequencer

module boot_seq_ff #(
    RST_VALUE=0
)(
    input logic clk,
    input logic rst_b,
    input logic ena,
    input logic d,
    output logic q
);
    always @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            q <= RST_VALUE;
        end else if (ena) begin
            q <= d;
        end
    end

endmodule : boot_seq_ff
