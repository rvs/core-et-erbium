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

//`timescale 1ns/1ps
module instpipe_model_tbench #(

        parameter  ADDR_WIDTH  =  16,
        parameter  DATA_WIDTH  =  64
    )
    (
        input  logic                      mem_clk_en_i,
        input  logic                      rst_b_i,
        input  logic                      clk_i,
        input  logic                      ce_i,
        input  logic                      we_i,
        input  logic  [(ADDR_WIDTH-1):0]  addr_i,
        input  logic  [(DATA_WIDTH-1):0]  din_i,
        input  logic  [(DATA_WIDTH-1):0]  bwe_i, 
        output        [(DATA_WIDTH-1):0]  dout_o,
        output                            busy_o
    );

    logic  mem_clk_en;

    always @(negedge rst_b_i or negedge clk_i) begin
      if (!rst_b_i) begin
        mem_clk_en  =  1'b0;
      end else begin
        mem_clk_en  =  mem_clk_en_i;
      end
    end

    assign mem_clk  =  mem_clk_en ? clk_i  :  1'b0;


    erbium_et_instance #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
        )  i0 (
        .rst_b_i(rst_b_i),
        .clk_i(mem_clk),
        .ce_i(ce_i),
        .we_i(we_i),
        .addr_i(addr_i),
        .din_i(din_i),
        .bwe_i(bwe_i),
        .dout_en_i(dout_en_i),
        .dout_o(dout_o),
        .busy_o(busy_o)
    );
    
`ifdef COCOTB_SIM
  initial begin
    $vcdpluson();
    //$dumpfile("dump.vcd");
    $dumpvars();
  end
`endif

endmodule  :  instpipe_model_tbench
