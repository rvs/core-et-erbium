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

module tb_mram_wrapper;

    reg clk;
    reg psel, pwrite, penable, pready;
    reg [31:0]  prdata, pwdata;
    reg [4:0]   paddr;
    reg         preset_n;

    reg [17:0]  axi_add;
    reg [7:0]   axi_bwe;
    reg [63:0]  axi_din;
    reg         axi_we;
    reg [3:0]   axi_stripe_sel;
    wire        axi_busy;
    wire [63:0] axi_dout;
    mram_wrapper dut (
        .PADDR(paddr),
        .PENABLE(penable),
        .PSEL(psel),
        .PSTRB(4'b1111),
        .PWDATA(pwdata),
        .PWRITE(pwrite),
        .axi_add(axi_add),
        .axi_bwe(axi_bwe),
        .axi_din(axi_din),
        .axi_stripe_sel(axi_stripe_sel),
        .axi_we(axi_we),
        .clk(clk),
        .dsleep(1'b1),
        .nvsram_startup_bypass(1'b0),
        .rst_b(preset_n),
        .tp_add('b0),
        .tp_bwe('b0),
        .tp_ce('b0),
        .tp_din('b0),
        .tp_we(1'b0),
        .vdd(1'b1),
        .vdd18(1'b1),
        .vss(1'b0),

        .PRDATA(prdata),
        .PREADY(pready),
        .axi_busy(axi_busy),
        .axi_dout(axi_dout),
        .cpu_intr(),
        .tp_busy(),
        .tp_reg_out(),
        .tp_valid(),
        .ANATEST0(),
        .ANATEST1()
      );

      initial begin
        `ifndef VERILATOR
          if(`WAVES==1) $vcdpluson();
      `endif
          clk = 0;
          #1;
          forever clk = #3 ~clk;
        end

endmodule