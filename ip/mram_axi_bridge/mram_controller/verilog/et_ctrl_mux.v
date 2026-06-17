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

module et_ctrl_mux (
    input  logic         sel,
    input  logic [16:0]  bist_add,
    input  logic [7:0]   bist_dout_en,
    input  logic [7:0]   bist_ce,
    input  logic         bist_we,
    input  logic [78:0]  bist_din,
    input  logic [78:0]  bist_bwe,
    input  logic [16:0]  axi_add,
    input  logic [7:0]   axi_ce,
    input  logic [7:0]   axi_dout_en,
    input  logic         axi_we,
    input  logic [78:0]  axi_din,
    input  logic [78:0]  axi_bwe,
    output logic [16:0]  mram_add,
    output logic [7:0]   mram_ce,
    output logic [7:0]   mram_dout_en,
    output logic         mram_we,
    output logic [78:0]  mram_bwe,
    output logic [78:0]  mram_din
);
    always_comb begin
        unique casez (sel)
            1'b0 : begin //axi signals
                mram_add = axi_add;
                mram_ce  = axi_ce;
                mram_dout_en = axi_dout_en;
                mram_we  = axi_we;
                mram_bwe = axi_bwe;
                mram_din = axi_din;
            end 
            1'b1 : begin //bist signals
                mram_add = bist_add;
                mram_ce  = bist_ce;
                mram_dout_en = bist_dout_en;
                mram_we  = bist_we;
                mram_bwe = bist_bwe;
                mram_din = bist_din;
            end
            default : begin //axi signals
                mram_add = axi_add;
                mram_ce  = axi_ce;
                mram_dout_en = axi_dout_en;
                mram_we  = axi_we;
                mram_bwe = axi_bwe;
                mram_din = axi_din;
            end
        endcase
    end
endmodule
