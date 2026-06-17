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

module ctrl_mux #(
    parameter ADD_WIDTH = 20,
    parameter DATA_WIDTH = 79,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
) (
    input logic                      sel,
    // bist signals
    //input [ADD_WIDTH-1:0]       bist_add,
    //input                       bist_ce_b,
    input logic [ADD_WIDTH-3:0]       bist_add,
    input logic [3:0]                 bist_stripe_sel,
    input logic                       bist_we,
    input logic [DATA_WIDTH-1:0]      bist_din,
    input logic [DATA_WIDTH-1:0]      bist_bwe,
    //axi signals
    //input [ADD_WIDTH-1:0]       axi_add,
    //input                       axi_ce_b,
    input logic [ADD_WIDTH-3:0]       axi_add,
    input logic [3:0]                 axi_stripe_sel,
    input logic                       axi_we,
    input logic [DATA_WIDTH-1:0]      axi_din,
    input logic [DATA_WIDTH-1:0]      axi_bwe,
    
    //output [ADD_WIDTH-1:0]      mram_add,
    //output                      mram_ce_b,
    output logic [ADD_WIDTH-3:0]      mram_add,
    output logic [3:0]                mram_stripe_sel,
    output logic                      mram_we,
    output logic [DATA_WIDTH-1:0]     mram_bwe,
    output logic [DATA_WIDTH-1:0]     mram_din
);
    always_comb begin
        unique casez (sel)
            1'b0 : begin //axi signals
                mram_add        =  axi_add;
                //mram_ce_b       =  axi_ce_b;
                mram_stripe_sel =  axi_stripe_sel;
                mram_we         =  axi_we;
                mram_bwe        =  axi_bwe;
                mram_din        =  axi_din;
            end 
            1'b1 : begin //bist signals
                mram_add        =  bist_add;
                //mram_ce_b       =  bist_ce_b;
                mram_stripe_sel =  bist_stripe_sel;
                mram_we         =  bist_we;
                mram_bwe        =  bist_bwe;
                mram_din        =  bist_din;
            end
            default : begin //axi signals
                mram_add        =  axi_add;
                //mram_ce_b       =  axi_ce_b;
                mram_stripe_sel =  axi_stripe_sel;
                mram_we         =  axi_we;
                mram_bwe        =  axi_bwe;
                mram_din        =  axi_din;
            end
        endcase
    end
endmodule
