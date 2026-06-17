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

module ddr_in_cell(
	d_in,
	d_out,
	d_out_valid,
	rwds_in,
	wstrb,
	en,
	cs_n,
	clk,
	rst_n
);
parameter WIDTH=1;
input wire [WIDTH-1:0] d_in;
output reg [2*WIDTH-1:0] d_out;
output reg [1:0] wstrb;
input wire en;
input wire clk;
input wire cs_n;
input wire rwds_in;
input wire rst_n;
output reg d_out_valid;
wire [WIDTH-1:0] d_in_low;
reg [WIDTH-1:0] d_in_high;
wire wstrb_low;
reg wstrb_high;
//assign d_out={d_in_high,d_in_low};
always@(posedge clk)begin
	if(~cs_n)begin
		if(en ) begin
			d_in_high<=d_in;
			wstrb_high<=~rwds_in;
		end
	end
end
assign d_in_low= cs_n ? 0 : d_in;
assign wstrb_low= cs_n ? 0 : ~rwds_in;
always@(negedge clk)begin
	if(!rst_n) d_out_valid<=0;
	else begin
		d_out_valid<=0;
	if(en) begin
		d_out<= {d_in_high,d_in};
		wstrb<={wstrb_high,wstrb_low};
		d_out_valid<=1;
		end
	end
end
endmodule
