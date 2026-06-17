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

module ddr_out_cell(
	data_in,
	en,
	d_out,
	rwds,
	d_out_en,
	clk,
	cs_
);
input wire [15:0] data_in;
	input wire en;
	output wire [7:0] d_out;
	output wire rwds;
	output wire d_out_en;
	input wire clk;
	input wire cs_;
	reg count;

  wire en_and_clk;
  notAClockGate selgen(
    .a(en)
  ,.b(clk)
  ,.a_and_b(en_and_clk));
//assign d_out=en&&clk?data_in[15:8]:data_in[7:0];
assign d_out=en_and_clk?data_in[15:8]:data_in[7:0];
assign d_out_en=en && !cs_;
// assign rwds=en?clk:0;
rwds_mux rwds_mux(
  .en(en)
  ,.ck(clk)
  ,.rwds(rwds)
);
endmodule
module rwds_mux (
  input wire en,
  input wire ck,
  output wire rwds
);
assign rwds=en?ck:0;
endmodule
  module notAClockGate(input wire a, input wire b, output wire a_and_b);
  assign a_and_b = a && b;
  endmodule
