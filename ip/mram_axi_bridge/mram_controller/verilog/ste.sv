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

module ste (
    output logic [3:0]  sa_cal_en_o,
    output logic [3:0]  sa_cal_clk_o,
    output logic        cal_clk_en_o,
    output logic [3:0]  nvsram_en_o,
    output logic        reg_logic_sup_sleep_o,
    output logic        reg_logic_sup_sleep_bo,
    output logic        mram_rst_bo,

    input  logic        sa_cal_clk_i,// This is the sa_cal_clk that is generated and is used
                              //   to run the Startup Engine state machine.
    input  logic        busy_sync_i, // comes from MRAM. During nvsram startup sequence logic
                              //   looks like this: busy_sync = nvsram_en & nvsram_busy
    input  logic        dsleep_i,
    input  logic        pwr_ok_i,
    input  logic        rst_b,

    // Override signals
    input  logic        mram_startup_bypass_i,
    input  logic [3:0]  ste_ovr_sel_i,
    input  logic [3:0]  sa_cal_en_ovr_i,
    input  logic [3:0]  sa_cal_clk_ovr_i,
    input  logic [3:0]  nvsram_en_ovr_i,
    input  logic        reg_logic_sup_sleep_ovr_i
);
    localparam logic [2:0] number_of_nvsram_startup_delay_clocks = 3'h5;
    localparam logic [2:0] number_of_sa_cal_clocks = 3'h6;
    typedef enum logic [2:0] {
        StIdle,
        StStart,
        StRunning,
        StNextStripe,
        StFinished
    } stm_states_e;

    stm_states_e state_q, state_d;
    logic [2:0] nvsram_delay_counter_q, nvsram_delay_counter_d;
    logic [2:0] sa_cal_clock_counter_q, sa_cal_clock_counter_d;
    logic       gated_rst_b;
    logic       nvsram_counter_en_q, nvsram_counter_en_d;
    logic       startup_finished_q, startup_finished_d;
    logic       clk_en_q0, clk_en_d0, clk_en_q1, clk_en_d1;
    logic       sa_cal_clk;
    logic [3:0] sa_cal_en_d, sa_cal_en_q;
    logic [3:0] nvsram_en_d, nvsram_en_q;
    logic       nvsram_busy_rise_d, nvsram_busy_rise_q, nvsram_busy_fall_d, nvsram_busy_fall_q;
    logic       reg_logic_sup_sleep_d, reg_logic_sup_sleep_q;
    logic [3:0] sa_cal_clk_gated, sa_cal_clk_en;
    logic       busy_sync_q0, busy_sync_d0, busy_sync_q1, busy_sync_d1;
    logic [1:0] nvsram_stripe_q, nvsram_stripe_d;
    logic [3:0] nvsram_stripe_finished_q, nvsram_stripe_finished_d;
    logic [1:0] sa_cal_stripe_q, sa_cal_stripe_d;
    logic [3:0] sa_cal_stripe_finished_q, sa_cal_stripe_finished_d;

    //  Clean up our clock so that there aren't any glitches on startup. sa_cal_clk is our clean clock.
    ste_ff#(1'b0) startup_filter_ff0           (.clk(sa_cal_clk_i), .rst_b(gated_rst_b), .d(clk_en_d0),                 .q(clk_en_q0));
    ste_ff#(1'b0) startup_filter_ff1           (.clk(sa_cal_clk_i), .rst_b(gated_rst_b), .d(clk_en_d1),                 .q(clk_en_q1));
    ste_clk_gate startup_clk_gate              (.clk(sa_cal_clk_i), .rst_b(gated_rst_b), .en_i(clk_en_q1),              .clk_o(sa_cal_clk));
    ste_ff#(1'b0) busy_sync_filter_ff0         (.clk(sa_cal_clk),   .rst_b(gated_rst_b), .d(busy_sync_d0),              .q(busy_sync_q0));
    ste_ff#(1'b0) busy_sync_filter_ff1         (.clk(sa_cal_clk),   .rst_b(gated_rst_b), .d(busy_sync_d1),              .q(busy_sync_q1));
    ste_clk_gate sa_cal_clk_gate[4]            (.clk(sa_cal_clk),   .rst_b(gated_rst_b), .en_i(sa_cal_clk_en),          .clk_o(sa_cal_clk_gated));
    // flip flops have a clean clock now.
    ste_ff#(StIdle) state_ff[3]                (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(state_d),                   .q(state_q));
    ste_ff#(3'h0) nvsram_delay_counter_ff[3]   (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_delay_counter_d),    .q(nvsram_delay_counter_q));
    ste_ff#(3'h0) sa_cal_clock_counter_ff[3]   (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(sa_cal_clock_counter_d),    .q(sa_cal_clock_counter_q));
    ste_ff#(4'h0) sa_cal_en_ff[4]              (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(sa_cal_en_d),               .q(sa_cal_en_q));
    ste_ff#(4'h0) nvsram_en_ff[4]              (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_en_d),               .q(nvsram_en_q));
    ste_ff#(1'b0) reg_logic_sup_sleep_ff       (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(reg_logic_sup_sleep_d),     .q(reg_logic_sup_sleep_q));
    ste_ff#(1'b0) startup_finished_ff          (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(startup_finished_d),        .q(startup_finished_q));
    ste_ff#(1'b0) nvsram_counter_en_ff         (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_counter_en_d),       .q(nvsram_counter_en_q));
    ste_ff#(1'b0) nvsram_busy_rise_ff          (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_busy_rise_d),        .q(nvsram_busy_rise_q));
    ste_ff#(1'b0) nvsram_busy_fall_ff          (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_busy_fall_d),        .q(nvsram_busy_fall_q));

    ste_ff#(2'h0) nvsram_stripe_ff[2]          (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_stripe_d),           .q(nvsram_stripe_q));
    ste_ff#(4'h0) nvsram_stripe_finished_ff[4] (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(nvsram_stripe_finished_d),  .q(nvsram_stripe_finished_q));
    ste_ff#(2'h0) sa_cal_stripe_ff[2]          (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(sa_cal_stripe_d),           .q(sa_cal_stripe_q));
    ste_ff#(4'h0) sa_cal_stripe_finished_ff[4] (.clk(sa_cal_clk  ), .rst_b(gated_rst_b), .d(sa_cal_stripe_finished_d),  .q(sa_cal_stripe_finished_q));

    /*
        Desired SA Calibration Waveform....
     sa_cal_clk             |   _____/-----\_____/-----\_____/-----\_____/-----\_____/-----\_____/-----\_____/-----\_____/-----\______/-----\______
     sa_cal_en_o            |   ______/------------------------------------------------------------------------------------------------\___________
     sa_cal_clk_o           |   _____________________________/-----\_____/-----\_____/-----\_____/-----\_____/-----\_____/-----\___________________
    */
    `ifdef COCOTB_SIM
    `ifndef GITLAB_CI
    initial begin
        $dumpfile("lscratch/ste_tb.vcd");
        $dumpvars(0, ste);
    end
    `endif
    `endif

    always_comb begin
        gated_rst_b             = rst_b & pwr_ok_i & ~dsleep_i;
        mram_rst_bo             = gated_rst_b;
        clk_en_d0               = 1'b1;
        clk_en_d1               = clk_en_q0;
        busy_sync_d0            = busy_sync_i;
        busy_sync_d1            = busy_sync_q0;
        // I want this signal to be high at startup or reset, but low after calibration.
        cal_clk_en_o            = gated_rst_b & ~startup_finished_q;
        nvsram_stripe_d         = nvsram_stripe_q;
        sa_cal_stripe_d         = sa_cal_stripe_q;

        nvsram_stripe_finished_d= nvsram_stripe_finished_q;
        sa_cal_stripe_finished_d= sa_cal_stripe_finished_q;
        for (integer i = 0; i < 4; i = i + 1) begin
            sa_cal_en_o[i]             = ste_ovr_sel_i[i]? sa_cal_en_ovr_i[i]           : sa_cal_en_q[i];
            sa_cal_clk_o[i]            = ste_ovr_sel_i[i]? sa_cal_clk_ovr_i[i]          : sa_cal_clk_gated[i];
            nvsram_en_o[i]             = ste_ovr_sel_i[i]? nvsram_en_ovr_i[i]           : nvsram_en_q[i];
        end
        reg_logic_sup_sleep_o   = |ste_ovr_sel_i? reg_logic_sup_sleep_ovr_i : reg_logic_sup_sleep_q;
        reg_logic_sup_sleep_bo  = ~reg_logic_sup_sleep_o;

        state_d                 = StIdle;
        startup_finished_d      = 1'b0;
        reg_logic_sup_sleep_d   = 1'b0;
        nvsram_en_d             = 1'b0;
        sa_cal_en_d             = 4'b0000;
        sa_cal_clk_en           = 4'b0000;
        nvsram_counter_en_d     = 1'b0;
        nvsram_busy_rise_d      = ~nvsram_busy_rise_q? busy_sync_q1 : 1'b1;
        nvsram_busy_fall_d      = ~nvsram_busy_fall_q? ~busy_sync_q1 & nvsram_busy_rise_q : 1'b1;

        unique case (state_q)
            // Waiting for clock to start up
            StIdle: begin
                nvsram_stripe_d = 2'h2;
                if (mram_startup_bypass_i) begin
                    startup_finished_d              = 1'b1;
                    reg_logic_sup_sleep_d           = 1'b1;
                    sa_cal_en_d                     = 4'b0000;
                    nvsram_en_d                     = 4'b0000;
                    state_d                         = StFinished;
                end else begin
                    sa_cal_en_d[sa_cal_stripe_q]    = 1'b1;
                    nvsram_counter_en_d             = 1'b1;
                    state_d                         = StStart;
                end
            end

            StStart: begin
                sa_cal_en_d[sa_cal_stripe_q]    = 1'b1;
                nvsram_counter_en_d             = 1'b1;
                nvsram_en_d[nvsram_stripe_q]    = (nvsram_delay_counter_q == number_of_nvsram_startup_delay_clocks);
                state_d                         = StRunning;
            end

            StRunning: begin
                nvsram_counter_en_d             = 1'b1;
                nvsram_en_d[nvsram_stripe_q]    = (nvsram_delay_counter_q == number_of_nvsram_startup_delay_clocks);
                sa_cal_en_d[sa_cal_stripe_q]    = ~(sa_cal_clock_counter_q == number_of_sa_cal_clocks);;
                sa_cal_clk_en[sa_cal_stripe_q]  = ~(sa_cal_clock_counter_q == number_of_sa_cal_clocks);
                if (nvsram_busy_rise_q && nvsram_busy_fall_q && (sa_cal_clock_counter_q == number_of_sa_cal_clocks))
                    state_d             = StNextStripe;
                else
                    state_d             = StRunning;
            end

            StNextStripe: begin
                nvsram_busy_rise_d = 0;
                nvsram_busy_fall_d = 0;
                nvsram_counter_en_d = 1;
                sa_cal_en_d[sa_cal_stripe_q] = 0;
                nvsram_stripe_d = nvsram_stripe_q + 1;
                sa_cal_stripe_d = sa_cal_stripe_q + 1;
                nvsram_stripe_finished_d[nvsram_stripe_q] = 1;
                sa_cal_stripe_finished_d[sa_cal_stripe_q] = 1;
                if (sa_cal_stripe_finished_d == 4'hf && nvsram_stripe_finished_d == 4'hf) begin
                    state_d = StFinished;
                end else begin
                    state_d = StStart;
                    sa_cal_en_d[sa_cal_stripe_d] = 1;
                end
            end

            StFinished: begin
                startup_finished_d      = 1'b1;
                reg_logic_sup_sleep_d   = 1'b1;
                sa_cal_en_d             = 4'b0;
                nvsram_en_d             = 4'b0;
                state_d                 = state_q;
            end

            default: begin

            end

        endcase

        nvsram_delay_counter_d  =   nvsram_counter_en_q == 1?
                                        (nvsram_delay_counter_q == number_of_nvsram_startup_delay_clocks)?
                                            nvsram_delay_counter_q     :
                                            nvsram_delay_counter_q + 1 :
                                        0;
        sa_cal_clock_counter_d =    (|sa_cal_clk_en) | (state_q == StRunning) ?
                                        (sa_cal_clock_counter_q == number_of_sa_cal_clocks)?
                                            sa_cal_clock_counter_q     :
                                            sa_cal_clock_counter_q + 1 :
                                        0;
    end
endmodule : ste

module ste_ff #(
    RST_VALUE=0
)(
    input logic clk,
    input logic rst_b,
    input logic d,
    output logic q
);
    always @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            q <= RST_VALUE;
        end else begin
            q <= d;
        end
    end

endmodule : ste_ff

module ste_clk_gate (
    input logic clk,
    input logic en_i,
    input logic rst_b,
    output logic clk_o
);
    logic en_q;
    assign clk_o = clk & en_q;
    always_latch begin
        if (~rst_b) begin
            en_q = 0;
        end else if (~clk) begin
            en_q = en_i;
        end
    end

endmodule : ste_clk_gate
