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

// Behavioral stand-ins for foundry cells required by the wrapper RTL.
// These are used for simulation-only flows in this testbench directory.

module CKLNQD24BWP7D5T16P96CPD (
    input  logic CP,
    input  logic E,
    input  logic TE,
    output logic Q
);
    logic gate_latched;

    always_latch begin
        if (!CP) begin
            gate_latched <= (E | TE);
        end
    end

    assign Q = CP & gate_latched;
endmodule
module CKLNQD24BWP7D5T16P96CPDLVT (
    input  logic CP,
    input  logic E,
    input  logic TE,
    output logic Q
);
    logic gate_latched;

    always_latch begin
        if (!CP) begin
            gate_latched <= (E | TE);
        end
    end

    assign Q = CP & gate_latched;
endmodule
