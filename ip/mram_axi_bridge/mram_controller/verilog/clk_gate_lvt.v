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

module clk_gate_lvt (
        input    clk_in,
        input    gate0,
        input    gate1,
        input    rst_b,
        output   clk_out
    );

    reg    gate_q;
    logic  gate;

    assign gate  =  gate0  &  gate1;

    CKLNQD24BWP7D5T16P96CPDLVT stdcell_clk_gate (
        .CP(clk_in),
        .E(gate),
        .TE(1'b0),
        .Q(clk_out)
    );

endmodule : clk_gate_lvt
