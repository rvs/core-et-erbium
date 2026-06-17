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

`timescale 1ns/1ps

module tbench();

    reg clk;
    reg[78:0] din;
    reg[19:0] add;
    reg[19:0] start_add;
    reg[19:0] stop_add;
    reg ce_b;
    reg we;
    reg rst_b;
    reg ref_prg_en;
    real x;
    reg [5:0] rom_add;
    reg [78:0] rom_data;
    reg [4:0] RH_margin;
    reg [2:0] RH_sigma;
    reg ref_trim_en;
    reg [6:0] RH;
    reg[78:0] dout;
    reg[78:0] dout1;
    reg[78:0] dout2;
    reg busy;
    reg [4:0] state;
    reg [19:0] replacement_add [23:0];
    reg [4:0] rep_add_cnt;
    reg [6:0] rca_ovr;
    reg rca_ovr_en;
    reg reg_ce_b;
    reg reg_we;
    reg reg_ref_prg_en;
    reg reg_rca_ovr_en;
    reg [78:0] reg_bwe;
    reg [78:0] reg_din;
    reg [19:0] reg_add;
    reg [6:0] reg_rca_ovr;
    reg [2:0] inc_addr;
    reg wr_en;
    reg rd_en;
    reg dinv;
    reg [1:0] mux_sel;
    reg bist_done;
    reg bist_err_rst;
    reg [2:0] ecc_en;
    reg stop_on_err;
    reg bist_err;
    reg [19:0] err_add;
    reg rst;
    reg mram_clk;
    reg clk_gate_q;
    reg clk_gate_d;
    reg clk_en;
    reg ecc_1bit;
    reg ecc_2bit;
    reg ecc_3bit;
    wire rom_ce;
    
    
    assign rst = ~rst_b;
    //gated clk
    assign mram_clk = clk & clk_gate_q;
    always_latch begin
        if (rst) begin
            clk_gate_q = 1;
        end else if (~clk) begin
            clk_gate_q = clk_en;
        end
    end
   //Instantiations
    mram u_mram(
        .din(din),
        .add(add),
        .clk(mram_clk),
        .ce_b(ce_b),
        .we(we),
        .rst_b(rst_b),
        .ref_prg_en(ref_prg_en),
        .dout(dout),
        .busy(busy)
   );
 
   rom u_rom(
        .clk(clk),
        .add(rom_add),
        .dout(rom_data)
   );
   
    bist_wrapper(
        .bist_mux_sel(mux_sel),                                             
        .clk(clk),
        .rst_b(rst_b),
        .busy(busy),
        .ref_trim_en(ref_trim_en),
        .bist_wr_en(wr_en),
        .bist_rd_en(rd_en),
        .bist_err_rst(bist_err_rst),
        .ecc_en(ecc_en),
        .ecc_1bit(ecc_1bit),
        .ecc_2bit(ecc_2bit),
        .ecc_3bit(ecc_3bit),
        .mram_dout(dout2),
        .rom_data(rom_data),
        .RH_margin(RH_margin),
        .RH_sigma(RH_sigma),
        .start_add(start_add),
        .stop_add(stop_add),
        .inc_addr(inc_addr),
        .stop_on_err(stop_on_err),
        .reg_ce_b(reg_ce_b),
        .reg_we(reg_we),
        .reg_ref_prg_en(reg_ref_prg_en),
        .reg_rca_ovr_en(reg_rca_ovr_en),
        .reg_rca_ovr(reg_rca_ovr),
        .reg_bwe(reg_bwe),
        .reg_add(reg_add),
        .reg_din(reg_din),
        .dinv(dinv),
        .bist_ce_b(ce_b),
        .bist_we(we),
        .bist_bwe(bwe),
        .bist_ref_prg_en(ref_prg_en),
        .bist_rca_ovr_en(rca_ovr_en),
        .bist_rca_ovr(rca_ovr),
        .bist_din(din),
        .bist_add(add),
        .rom_add(rom_add),
        .bist_done(bist_done),
        .bist_err(bist_err),
        .bist_err_add(err_add),
        .state(sate),
        .replacement_add(replacement_add),
        .rep_add_cnt_o(replacement_cnt) ,
        .clk_en(clk_en),
        .rom_ce(rom_ce)
    );
    /*ctrl_rte u_ctrl_rte(
        .clk(clk),
        .rst_b(rst_b),
        .busy(busy),
        .ref_trim_en(ref_trim_en),
        .mram_dout(dout),
        .rom_data(rom_data),
        .RH_margin(RH_margin),
        .RH_sigma(RH_sigma),
        .start_add(start_add),
        .stop_add(stop_add),
        .ce_b(ce_b),
        .we(we),
        .ref_prg_en(ref_prg_en),
        .rca_ovr_en(rca_ovr_en),
        .rca_ovr(rca_ovr),
        .mram_din(din),
        .mram_add(add),
        .rom_add(rom_add),
        .done(done),
        .state(state),
        .replacement_add_o(replacement_add),
        .rep_add_cnt_o(rep_add_cnt)
   );*/
    always_ff @(posedge mram_clk) begin
        dout1 <= dout;
        dout2 <= dout1;
    end
   //Initialize Inputs
    initial begin
    $timeformat(-9, 2, " ns", 20);
    $dumpfile("./tbench.vcd");
    $dumpvars;
        initialize_inputs;
        #5ns;
        rst_b <= 0;
        ref_trim_en <=0;
       
        
        #5ns;
        rst_b <= 1;
        #5ns;
        //ref_trim_en <= 1;
        
        run_bist_trim;
        run_bist_write;
        run_bist_read;
        $finish;
        #5ns;
        
    end
    
    /*always @(posedge bist_done) begin
            if (ref_trim_en) begin
                ref_trim_en <= 1'b0;
                wr_en <= 1'b1;
                mux_sel <= 2'b01;
            end else begin
                wr_en <= 0;
                rd_en <= 1;
                mux_sel <= 2'b10;
                reg_din <= 'h7ffffffffffffffffffe;
                #40ns;
                ecc_1bit <= 1;
                //ecc_3bit <= 1;
                #20ns;
                ecc_1bit <= 0;
                #20ns;
                ecc_1bit <= 1;
                #20ns;
                ecc_1bit <= 0;
                //reg_ref_prg_en <=1;
            end
        end */
    logic bist_err_trig = 0;
    always @(posedge clk) begin
        if (bist_err) begin
            bist_err_trig <= 1;
            #1.5ns;
            
            bist_err_rst <= 1;   
        end else if (bist_err_trig) begin
            bist_err_rst <= 0;
            bist_err_trig <= 0;
        end
    end
   
    initial begin
        forever begin
            #2ns clk <= ~clk;
        end
    end
    
    initial begin
        #400ms;
        $display("DEBUG: timeout!");
        $finish;
    end
    task initialize_inputs;
        clk <= 0;
        wr_en <= 0;
        rd_en <= 0;
        reg_ref_prg_en <= 0;
        ecc_en <= 0;
        bist_err_rst <=0;
        ecc_en <= 3'b000;
        ecc_1bit <= 0;
        ecc_2bit <= 0;
        ecc_3bit <= 0;
        stop_on_err <= 1;
        RH_sigma <= 1;
        RH_margin <= 20;
        rst_b <= 1;
    endtask
    task run_bist_trim;
    `ifdef RUN_BIST_TRIM
        `ifndef START_ADDR
        `define START_ADDR 0
        `endif
        `ifndef STOP_ADDR
        `define STOP_ADDR 'h0fffe
        `endif
        `ifndef RH_SIGMA
        `define RH_SIGMA 2
        `endif
        `ifndef RH_MARGIN
        `define RH_MARGIN 10
        `endif
        $display("Running BIST trim Test...");
        mux_sel <= 2'b00;
        RH_sigma <= `RH_SIGMA;
        RH_margin <= `RH_MARGIN;
        start_add <= `START_ADDR;
        stop_add <= `STOP_ADDR;
        ref_trim_en <= 1;
        @(posedge bist_done) begin
            ref_trim_en <= 1'b0;
        end
    `endif
    endtask
    task run_bist_write;
    `ifdef RUN_BIST_WRITE
        `ifndef START_ADDR
        `define START_ADDR 0
        `endif
        `ifndef STOP_ADDR
        `define STOP_ADDR 'h0fffe
        `endif
        `ifndef DINV
        `define DINV 0
        `endif
        `ifndef REG_DIN
        `define REG_DIN 'h55555555555555555555
        `endif
        `ifndef INC_ADDR
        `define INC_ADDR 3'b000
        `endif
        $display("Running BIST write Test...");
        mux_sel <= 2'b01;
        start_add <= `START_ADDR;
        stop_add <= `STOP_ADDR;
        inc_addr <= `INC_ADDR;
        dinv <= `DINV;
        reg_din <= `REG_DIN;
        wr_en <= 1;
        @(posedge bist_done) begin
            wr_en <= 1'b0;
        end
    `endif
    endtask
    task run_bist_read;
    `ifdef RUN_BIST_READ
        `ifndef START_ADDR
        `define START_ADDR 0
        `endif
        `ifndef STOP_ADDR
        `define STOP_ADDR 'h0fffe
        `endif
        `ifndef ECC_EN
        `define ECC_EN 3'b000
        `endif
        `ifndef STOP_ON_ERR
        `define STOP_ON_ERR 1
        `endif
        `ifndef REG_DIN_INV
        `define REG_DIN_INV 0
        `endif 
        `ifndef REG_DIN
        `define REG_DIN 'h55555555555555555555
        `endif
        `ifndef INC_ADDR
        `define INC_ADDR 3'b000
        `endif
        `ifndef DINV
        `define DINV 0
        `endif
        $display("Running BIST read Test...");
        mux_sel <= 2'b10;
        bist_err_rst <=0;
        ecc_en <= `ECC_EN;
        inc_addr <= `INC_ADDR;
        start_add <= `START_ADDR;
        stop_add <= `STOP_ADDR;
        dinv <= `DINV;
        ecc_1bit <= 0;
        ecc_2bit <= 0;
        ecc_3bit <= 0;
        stop_on_err <= `STOP_ON_ERR;
        rd_en <= 1;
        reg_din <= `REG_DIN ^ `REG_DIN_INV;
        @(posedge bist_done) begin
            rd_en <= 1'b0;
        end
    `endif
    endtask
endmodule
