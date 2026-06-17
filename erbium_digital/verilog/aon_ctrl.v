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

module aon_ctrl(
	input wire power_off_req,
	input wire cs_n,
	input wire tms,
	output reg chip_pd_req,
	input wire clk,
	input wire rst_n
);
parameter ON_STATE=0;
parameter OFF_STATE=1;
parameter WAKEUP_STATE=2;
reg [1:0] state;
always @(posedge clk or negedge rst_n)
	if(!rst_n)begin
		state <= ON_STATE;
		chip_pd_req <=1'b0;
	end
	else begin
		case(state)
			ON_STATE:begin
				chip_pd_req <=1'b0;
				if(power_off_req && cs_n == 1'b1) state <=OFF_STATE;
			end
			OFF_STATE:begin
					chip_pd_req <= 1'b1;
					if(tms==0) state <= WAKEUP_STATE;
			end
			WAKEUP_STATE:begin
				chip_pd_req <= 1'b0;
				state <= ON_STATE;
			end
			default:
				state <= ON_STATE;
		endcase
	end
endmodule
