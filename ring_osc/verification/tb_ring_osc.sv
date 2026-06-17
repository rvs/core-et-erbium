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

`timescale 1ps/1ps

// Top-level cocotb testbench wrapper for ring_osc.
// cocotb drives and monitors all signals via VPI/DPI against this module.
module tb_ring_osc;

    logic        clk;
    logic [4:0]  trm;
    logic        divby2_sel;
    logic        en;
    logic        dbg_en;
    logic        dbg_anachip_en;
    logic        dbg_rohcip_en;
    logic        dbg_sah_en_b;

    ring_osc dut (
        .clk            (clk),
        .trm            (trm),
        .divby2_sel     (divby2_sel),
        .en             (en),
        .dbg_en         (dbg_en),
        .dbg_anachip_en (dbg_anachip_en),
        .dbg_rohcip_en  (dbg_rohcip_en),
        .dbg_sah_en_b   (dbg_sah_en_b)
    );

`ifdef DUMP_VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ring_osc);
    end
`endif

endmodule
