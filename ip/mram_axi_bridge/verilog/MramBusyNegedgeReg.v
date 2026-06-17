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

module MramBusyNegedgeReg (
    input  wire       RST_N,
    input  wire       BANK_CLK,
    input  wire       BANK_CLK_GATE,
    input  wire [7:0] D_IN,
    input  wire       EN,
    output reg  [7:0] Q_OUT
);
    always @(negedge BANK_CLK or negedge RST_N) begin
        if (!RST_N) begin
            Q_OUT <= 8'b0;
        end else if (EN) begin
            Q_OUT <= D_IN;
        end
    end
endmodule
