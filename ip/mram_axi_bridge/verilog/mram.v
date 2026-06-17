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

module mram #(
    parameter ADDR_WIDTH=18,
    parameter STRIPE_SEL_POW=2 // STRIPE_SEL_WIDTH = 1 << STRIPE_SEL_POW
) (
    input [78:0]                    din,
    input [78:0]                    bwe,
    input [ADDR_WIDTH-1:0]          add, // 2^21 = 2M addresses.
    input                           clk,
    input [(STRIPE_SEL_POW<<1)-1:0] stripe_sel,
    input                           we,
    input                           rst_b,
    ////////////////////////////////////////////////
    // Behavioral signals with incorrect behavior //
    ////////////////////////////////////////////////
    input [2:0]  anatest0_sel,
    input [2:0]  anatest1_sel,
    input cal_clk_en,
    input [1:0]  cal_clk_speed,
    input dma_en,
    input dsleep,
    input gbl_cfg_ovr_en,
    input [3:0]  nv_sram_en,
    input otp_wr_en,
    input [3:0]  powerup_trim_load_ovr,
    input prg_rd1_byp,
    input pwr_up_sel,
    input [6:0]  rca_ovr,
    input rca_ovr_en,
    input rd_en_ovr,
    input rd_pulse_meas_en,
    input ref_prg_en,
    input reg_logic_sup_sleep,
    input reg_logic_sup_sleep_b,
    input [3:0]  sa_cal_clk,
    input [3:0]  sa_cal_en,
    input sah_en,
    input scc_otp_en,
    input vblslx_gain_mode_ovr,
    input wr_en_ovr,
    output gen_sa_cal_clk,
    output [3:0]  nvsram_boot_err,
    output [1:0]  temp,
//    inout [1:0]  anatest,
    inout        ANATEST0,
    inout        ANATEST1,
    inout [3:0]  blk0_man_ccnt,
    inout [3:0]  blk0_man_cnfg,
    inout [1:0]  blk0_man_fcnt,
    inout [3:0]  blk1_man_ccnt,
    inout [3:0]  blk1_man_cnfg,
    inout [1:0]  blk1_man_fcnt,
    inout [3:0]  blk2_man_ccnt,
    inout [3:0]  blk2_man_cnfg,
    inout [1:0]  blk2_man_fcnt,
    inout [3:0]  blk3_man_ccnt,
    inout [3:0]  blk3_man_cnfg,
    inout [1:0]  blk3_man_fcnt,
    inout [3:0]  blk4_man_ccnt,
    inout [3:0]  blk4_man_cnfg,
    inout [1:0]  blk4_man_fcnt,
    inout [3:0]  blk5_man_ccnt,
    inout [3:0]  blk5_man_cnfg,
    inout [1:0]  blk5_man_fcnt,
    inout [3:0]  blk6_man_ccnt,
    inout [3:0]  blk6_man_cnfg,
    inout [1:0]  blk6_man_fcnt,
    inout [3:0]  blk7_man_ccnt,
    inout [3:0]  blk7_man_cnfg,
    inout [1:0]  blk7_man_fcnt,
    inout [3:0]  even_man_stripe_sel,   // this is more of an input.
    inout [3:0]  even_man_wr,           // this is really an input
    inout [42:0]  gbl_cfg,
    inout [3:0]  odd_man_stripe_sel,    // this is more of an input.
    inout [3:0]  odd_man_wr,            // this is more of an input.
    ////////////////////////////////////////////////
    output wire [78:0]              dout,
    output logic                    pwr_ok,
    output reg                      busy
);
    logic [78:0]                int_memory [2**(ADDR_WIDTH+STRIPE_SEL_POW)];
    logic [78:0]                int_din;
    logic [78:0]                int_bwe;
    logic [78:0]               int_wide_bwe;
    logic [ADDR_WIDTH+STRIPE_SEL_POW-1:0]    int_add;
    logic [78:0]                int_dout_pipe0;
    logic [78:0]                dout_driver;
    logic                       int_read_flag  = 0;
    logic                       int_write_flag = 0;
    logic [78:0]                int_mem_bwe_logic;
    logic [78:0]                int_din_bwe_logic;
    logic [1:0]                 stripe_add_bits;
    logic                       bank_sel;
    integer                     repulse_count = 0;

    // Not modeled Signals
    assign pwr_ok = 1;
    assign gen_sa_cal_clk = 0;
    assign nvsram_boot_err = 0;
    assign temp = 0;
    assign  blk0_man_ccnt    =   even_man_wr[0]  ?  4'bzzzz : 0  ;
    assign  blk0_man_cnfg    =   even_man_wr[0]  ?  4'bzzzz : 0  ;
    assign  blk0_man_fcnt    =   even_man_wr[0]  ?  2'bzz   : 0  ;
    assign  blk1_man_ccnt    =   even_man_wr[1]  ?  4'bzzzz : 0  ;
    assign  blk1_man_cnfg    =   even_man_wr[1]  ?  4'bzzzz : 0  ;
    assign  blk1_man_fcnt    =   even_man_wr[1]  ?  2'bzz   : 0  ;
    assign  blk2_man_ccnt    =   even_man_wr[2]  ?  4'bzzzz : 0  ;
    assign  blk2_man_cnfg    =   even_man_wr[2]  ?  4'bzzzz : 0  ;
    assign  blk2_man_fcnt    =   even_man_wr[2]  ?  2'bzz   : 0  ;
    assign  blk3_man_ccnt    =   even_man_wr[3]  ?  4'bzzzz : 0  ;
    assign  blk3_man_cnfg    =   even_man_wr[3]  ?  4'bzzzz : 0  ;
    assign  blk3_man_fcnt    =   even_man_wr[3]  ?  2'bzz   : 0  ;
    assign  blk4_man_ccnt    =   odd_man_wr[0]   ?  4'bzzzz : 0  ;
    assign  blk4_man_cnfg    =   odd_man_wr[0]   ?  4'bzzzz : 0  ;
    assign  blk4_man_fcnt    =   odd_man_wr[0]   ?  2'bzz   : 0  ;
    assign  blk5_man_ccnt    =   odd_man_wr[1]   ?  4'bzzzz : 0  ;
    assign  blk5_man_cnfg    =   odd_man_wr[1]   ?  4'bzzzz : 0  ;
    assign  blk5_man_fcnt    =   odd_man_wr[1]   ?  2'bzz   : 0  ;
    assign  blk6_man_ccnt    =   odd_man_wr[2]   ?  4'bzzzz : 0  ;
    assign  blk6_man_cnfg    =   odd_man_wr[2]   ?  4'bzzzz : 0  ;
    assign  blk6_man_fcnt    =   odd_man_wr[2]   ?  2'bzz   : 0  ;
    assign  blk7_man_ccnt    =   odd_man_wr[3]   ?  4'bzzzz : 0  ;
    assign  blk7_man_cnfg    =   odd_man_wr[3]   ?  4'bzzzz : 0  ;
    assign  blk7_man_fcnt    =   odd_man_wr[3]   ?  2'bzz   : 0  ;
    assign  gbl_cfg          = (gbl_cfg_ovr_en) ? 'hz : 'h0;

    always @* begin
        for (integer i = 0; i < (1 << STRIPE_SEL_POW); i = i + 1) begin
            if (stripe_sel[i]) begin
               stripe_add_bits = i;
                i = 1 << STRIPE_SEL_POW;
            end
        end
    end
    assign dout = dout_driver;
    assign int_wide_bwe = int_bwe;
    assign int_mem_bwe_logic = int_memory[int_add] & int_wide_bwe;
    assign int_din_bwe_logic = int_din & int_wide_bwe;
    assign bank_sel = |stripe_sel;
    initial begin
        for (integer i = 0; i < 2**(ADDR_WIDTH + STRIPE_SEL_POW); i = i + 1) begin
            int_memory[i] = 0;
        end
    end
    always @(rst_b) begin
        if (rst_b == 0) begin
            int_dout_pipe0 = 0;
            busy = 1;
            dout_driver = 0;
        end else begin
            busy = 0;
        end
    end

    always @(posedge clk) begin
        // Pipeline Behavior
        dout_driver <= int_dout_pipe0;

        // Write Behavior
        if (rst_b && ~busy && ~int_read_flag && ~int_write_flag && bank_sel &&  we) begin
            repulse_count        = 0;
            busy                <= 1'b1;
            int_write_flag      <= 1;
            int_din             <= din;
            int_bwe             <= bwe;
            int_add             <= {stripe_add_bits, add};
            #3ns;
            do begin
                for (integer i = 0; i < 79; i = i + 1) begin
                    if (int_wide_bwe[i]) begin
                        if (int_memory[int_add][i] != int_din[i]) begin
                            if (($urandom % 1000000) > 200) begin
                                int_memory[int_add][i] <= int_din[i];
                            end else begin
                                //$display("WARNING: Failed to write bit %d on count %d", i, repulse_count);
                            end
                        end
                    end
                end
                #15ns;              // Wait time.
                #3ns;
                repulse_count = repulse_count + 1;
            end while ((int_mem_bwe_logic != int_din_bwe_logic) && (repulse_count < 8));
            busy                <= 1'b0;
            int_write_flag      <= 0;
            //$display("INFO: Write(0x%x) @ 0x%x", int_memory[int_add], int_add);
        end

        // Read Behavior
        if (rst_b && ~busy && ~int_read_flag && ~int_write_flag && bank_sel && ~we) begin
            busy            <= 1'b1;
            int_read_flag   <= 1;
            int_add         <= {stripe_add_bits, add};
            #3ns;         // Wait time.
            int_dout_pipe0  <= int_memory[int_add];
            busy            <= 1'b0;
            int_read_flag   <= 0;
        end else begin
            int_dout_pipe0  <= 79'h0;
        end

    end
endmodule : mram
