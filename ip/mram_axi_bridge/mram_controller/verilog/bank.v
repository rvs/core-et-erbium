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

module bank( addr_in, anatest0_sel, anatest1_sel, bwe, cal_clk_en, cal_clk_speed
    , clk, din, dma_en, dsleep, gbl_cfg_ovr_en, nv_sram_en, otp_wr_en,
    powerup_trim_load_ovr, prg_rd1_byp, rca_ovr, rca_ovr_en, rd_en_ovr, rd_pulse_meas_en, ref_prg_en,
    reg_logic_sup_sleep, reg_logic_sup_sleep_b, rst_b, sa_cal_clk, sa_cal_en,
    sah_en, scc_otp_en, stripe_sel, vblslx_gain_mode_ovr, we, wr_en_ovr, busy,
    dout, gen_sa_cal_clk, nvsram_boot_err, pwr_ok, temp, anatest, blk0_man_ccnt,
    blk0_man_cnfg, blk0_man_fcnt, blk1_man_ccnt, blk1_man_cnfg, blk1_man_fcnt,
    blk2_man_ccnt, blk2_man_cnfg, blk2_man_fcnt, blk3_man_ccnt, blk3_man_cnfg,
    blk3_man_fcnt, blk4_man_ccnt, blk4_man_cnfg, blk4_man_fcnt, blk5_man_ccnt,
    blk5_man_cnfg, blk5_man_fcnt, blk6_man_ccnt, blk6_man_cnfg, blk6_man_fcnt,
    blk7_man_ccnt, blk7_man_cnfg, blk7_man_fcnt, even_man_stripe_sel,
    even_man_wr, gbl_cfg, odd_man_stripe_sel, odd_man_wr, ANATEST0, ANATEST1,
    test_cal_en, pwr_up_sel, vdd, vdd18, vss );
    localparam STRIPE_SEL_POW = 2;
    localparam ADDR_WIDTH=18;
    // Port declarations
    input [17:0]  addr_in;
    input [2:0]  anatest0_sel;
    input [2:0]  anatest1_sel;
    input [78:0]  bwe;
    input cal_clk_en;
    input [1:0]  cal_clk_speed;
    input [3:0]  clk;
    input [78:0]  din;
    input dma_en;
    input dsleep;
    input gbl_cfg_ovr_en;
    input [3:0]  nv_sram_en;
    input otp_wr_en;
    input [3:0]  powerup_trim_load_ovr;
    input prg_rd1_byp;
    input [6:0]  rca_ovr;
    input rca_ovr_en;
    input rd_en_ovr;
    input rd_pulse_meas_en;
    input ref_prg_en;
    input reg_logic_sup_sleep;
    input reg_logic_sup_sleep_b;
    input rst_b;
    input [3:0]  sa_cal_clk;
    input [3:0]  sa_cal_en;
    input sah_en;
    input scc_otp_en;
    input [3:0]  stripe_sel;
    input vblslx_gain_mode_ovr;
    input we;
    input wr_en_ovr;
    output logic busy;
    output logic [78:0]  dout;
    output logic gen_sa_cal_clk;
    output logic [3:0]  nvsram_boot_err;
    output logic pwr_ok;
    output logic [1:0]  temp;
    inout [1:0]  anatest;
    inout [3:0]  blk0_man_ccnt;
    inout [3:0]  blk0_man_cnfg;
    inout [1:0]  blk0_man_fcnt;
    inout [3:0]  blk1_man_ccnt;
    inout [3:0]  blk1_man_cnfg;
    inout [1:0]  blk1_man_fcnt;
    inout [3:0]  blk2_man_ccnt;
    inout [3:0]  blk2_man_cnfg;
    inout [1:0]  blk2_man_fcnt;
    inout [3:0]  blk3_man_ccnt;
    inout [3:0]  blk3_man_cnfg;
    inout [1:0]  blk3_man_fcnt;
    inout [3:0]  blk4_man_ccnt;
    inout [3:0]  blk4_man_cnfg;
    inout [1:0]  blk4_man_fcnt;
    inout [3:0]  blk5_man_ccnt;
    inout [3:0]  blk5_man_cnfg;
    inout [1:0]  blk5_man_fcnt;
    inout [3:0]  blk6_man_ccnt;
    inout [3:0]  blk6_man_cnfg;
    inout [1:0]  blk6_man_fcnt;
    inout [3:0]  blk7_man_ccnt;
    inout [3:0]  blk7_man_cnfg;
    inout [1:0]  blk7_man_fcnt;
    inout [3:0]  even_man_stripe_sel;
    inout [3:0]  even_man_wr;
    inout [42:0]  gbl_cfg;
    inout [3:0]  odd_man_stripe_sel;
    inout [3:0]  odd_man_wr;
    input pwr_up_sel;
    input test_cal_en;
    inout ANATEST0;
    inout ANATEST1;
    inout vdd;
    inout vdd18;
    inout vss;
    logic [78:0]                int_memory [2**(ADDR_WIDTH+STRIPE_SEL_POW)];
    logic [78:0]                int_ref_memory [2**(ADDR_WIDTH+STRIPE_SEL_POW-4)];
    integer                     rh0 [2**(ADDR_WIDTH+STRIPE_SEL_POW-4)];
    integer                     rh1 [2**(ADDR_WIDTH+STRIPE_SEL_POW-4)];
    logic [78:0]                int_din;
    logic [78:0]                int_bwe;
    logic [78:0]                int_wide_bwe;
    logic [ADDR_WIDTH+STRIPE_SEL_POW-1:0]    int_add;
    logic [78:0]                int_dout_pipe0;
    logic [78:0]                dout_driver;
    logic                       int_read_flag  = 0;
    logic                       int_write_flag = 0;
    logic                       int_prg_ref_flag = 0;
    logic                       int_busy = 0;
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
    assign  blk0_man_ccnt    =   even_man_wr[0]  ?  4'b0000 : 0  ;
    assign  blk0_man_cnfg    =   even_man_wr[0]  ?  4'bzzzz : 0  ;
    assign  blk0_man_fcnt    =   even_man_wr[0]  ?  2'b00   : 0  ;
    assign  blk1_man_ccnt    =   even_man_wr[1]  ?  4'b0000 : 0  ;
    assign  blk1_man_cnfg    =   even_man_wr[1]  ?  4'bzzzz : 0  ;
    assign  blk1_man_fcnt    =   even_man_wr[1]  ?  2'b00   : 0  ;
    assign  blk2_man_ccnt    =   even_man_wr[2]  ?  4'b0000 : 0  ;
    assign  blk2_man_cnfg    =   even_man_wr[2]  ?  4'bzzzz : 0  ;
    assign  blk2_man_fcnt    =   even_man_wr[2]  ?  2'b00   : 0  ;
    assign  blk3_man_ccnt    =   even_man_wr[3]  ?  4'b0000 : 0  ;
    assign  blk3_man_cnfg    =   even_man_wr[3]  ?  4'bzzzz : 0  ;
    assign  blk3_man_fcnt    =   even_man_wr[3]  ?  2'b00   : 0  ;
    assign  blk4_man_ccnt    =   odd_man_wr[0]   ?  4'b0000 : 0  ;
    assign  blk4_man_cnfg    =   odd_man_wr[0]   ?  4'bzzzz : 0  ;
    assign  blk4_man_fcnt    =   odd_man_wr[0]   ?  2'b00   : 0  ;
    assign  blk5_man_ccnt    =   odd_man_wr[1]   ?  4'b0000 : 0  ;
    assign  blk5_man_cnfg    =   odd_man_wr[1]   ?  4'bzzzz : 0  ;
    assign  blk5_man_fcnt    =   odd_man_wr[1]   ?  2'b00   : 0  ;
    assign  blk6_man_ccnt    =   odd_man_wr[2]   ?  4'b0000 : 0  ;
    assign  blk6_man_cnfg    =   odd_man_wr[2]   ?  4'bzzzz : 0  ;
    assign  blk6_man_fcnt    =   odd_man_wr[2]   ?  2'b00   : 0  ;
    assign  blk7_man_ccnt    =   odd_man_wr[3]   ?  4'b0000 : 0  ;
    assign  blk7_man_cnfg    =   odd_man_wr[3]   ?  4'bzzzz : 0  ;
    assign  blk7_man_fcnt    =   odd_man_wr[3]   ?  2'b00   : 0  ;
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
    assign int_mem_bwe_logic = (int_prg_ref_flag? int_ref_memory[int_add>>4] : int_memory[int_add]) & int_wide_bwe;
    assign int_din_bwe_logic = int_din & int_wide_bwe;
    assign bank_sel = |stripe_sel;
    initial begin
        for (integer i = 0; i < 2**(ADDR_WIDTH + STRIPE_SEL_POW); i = i + 1) begin
            int_memory[i] = 0;
            if (i % 16 == 0) begin
                // {0x374e8076, 0x300f7788, 0x03f7}, /* 16, cnt:38 */
                // int_ref_memory[i >> 4] = 79'h55555555555555555555;
                int_ref_memory[i >> 4] = 79'h03f7300f7788374e8076;
                rh0[i >> 4] = $urandom_range(0, 34);
                // rh0[i >> 4] = 4;
                rh1[i >> 4] = $urandom_range(45, 79);
                // rh1[i >> 4] = 76;
            end
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
    always @(negedge clk) begin
        if (int_busy == 0) begin
            busy <= 0;
        end
    end
    always @(posedge clk) begin
        // Pipeline Behavior
        dout_driver <= int_dout_pipe0;

        // Write Behavior
        if (rst_b && ~int_busy && ~int_read_flag && ~int_write_flag && bank_sel &&  we) begin
            repulse_count        = 0;
            busy                <= 1'b1;
            int_busy            <= 1'b1;
            int_write_flag      <= 1;
            int_din             <= din;
            int_bwe             <= bwe;
            int_add             <= {stripe_add_bits, addr_in};
            int_prg_ref_flag    <= ref_prg_en;
            #3ns;
            do begin
                for (integer i = 0; i < 79; i = i + 1) begin
                    if (int_wide_bwe[i]) begin
                        if ((int_prg_ref_flag? int_ref_memory[int_add>>4][i] : int_memory[int_add][i]) != int_din[i]) begin
                            if (($urandom % 1000000) > 200) begin
                                if (int_prg_ref_flag == 0)
                                    int_memory[int_add][i] <= int_din[i];
                                else
                                    int_ref_memory[int_add>>4][i] <= int_din[i];
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
            if (int_prg_ref_flag == 0)
                int_dout_pipe0 <= int_memory[int_add];
            else
                int_dout_pipe0 <= int_ref_memory[int_add>>4];
            int_busy            <= 1'b0;
            int_write_flag      <= 0;
            //$display("INFO: Write(0x%x) @ 0x%x", int_memory[int_add], int_add);
        end

        else
        // Read Behavior
        if (rst_b && ~int_busy && ~int_read_flag && ~int_write_flag && bank_sel && ~we) begin
            busy            <= 1'b1;
            int_busy        <= 1'b1;

            int_read_flag   <= 1;
            int_add         <= {stripe_add_bits, addr_in};
            int_prg_ref_flag<= ref_prg_en;
            #3ns;         // Wait time.
            if (int_prg_ref_flag == 0) begin
                if (rh0[int_add >> 4] > $countones(int_ref_memory[int_add >> 4]))
                    int_dout_pipe0 <= 79'h7fffffffffffffffffff;
                else if (rh1[int_add >> 4] < $countones(int_ref_memory[int_add >> 4]))
                    int_dout_pipe0 <= 79'h00000000000000000000;
                else
                    int_dout_pipe0  <= int_memory[int_add];
            end else begin
                if (rh0[int_add >> 4] > $countones(int_ref_memory[int_add >> 4]))
                    int_dout_pipe0 <= 79'h7fffffffffffffffffff;
                else if (rh1[int_add >> 4] < $countones(int_ref_memory[int_add >> 4]))
                    int_dout_pipe0 <= 79'h00000000000000000000;
                else
                    int_dout_pipe0  <= int_ref_memory[(int_add >> 4) ^ (1 << 9)];
            end
            int_busy            <= 1'b0;
            busy                <= 1'b0;
            int_read_flag       <= 0;

        end else begin
            int_dout_pipe0  <= 79'h0;
        end

    end


endmodule //bank
