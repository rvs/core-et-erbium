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

module et_reset_sync_2ff (input wire rst_in_n,
input wire clk,
input wire d,
output reg q);
parameter RESET_VALUE=0;
reg d0;
always@(posedge clk or negedge rst_in_n)begin
	if(!rst_in_n) begin
		d0<=RESET_VALUE;
		q<=RESET_VALUE;
	end else begin
		d0<=d;
		q<=d0;
	end
end
endmodule

