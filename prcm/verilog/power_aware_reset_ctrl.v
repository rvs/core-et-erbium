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

module prcm_reset_extender(
    input   wire    rst_in_n,
    output  wire    rst_out_n,
    input   wire    soft_rst,
    input   wire    clk
);
    parameter   RESET_DURATION = 5;
    reg [5:0] count = $urandom();
    reg d_2ff;

    et_reset_sync_2ff reset_sync_2ff(
	     .rst_in_n(rst_in_n)
	    ,.clk(clk)
	    ,.d(d_2ff)
	    ,.q(rst_out_n)
	    );
	    always@(posedge clk or negedge rst_in_n)
        if(!rst_in_n) begin 
          d_2ff<=1'b0;
          count<= RESET_DURATION;
        end else begin
			    if(soft_rst)begin
				    d_2ff<=1'b0;
				    count<= RESET_DURATION;
			    end else if(count!=0) count <= count -1;
			    else d_2ff<=1'b1;
		    end
endmodule : prcm_reset_extender
module power_aware_reset_ctrl (
    input wire [20:0] counter,
    input   wire    rst_in_n,
    input wire power_down_in,
    output reg power_on,
    input wire power_good,
    output reg iso,
    // output wire ret, retention cells should not be reset during UPF flow
    output  wire    rst_out_n,
    input   wire    soft_rst,
    input   wire    clk
);
    parameter   RESET_DURATION = 5;
    parameter   POWER_DOWN_DURATION = 0;
    reg [20:0]   duration=$urandom();

    reg [2:0]reset_fsm;
    parameter RESET=3'd0;
    parameter NORMAL=3'd1;
    parameter ISO_ON=3'd2;
    parameter POWER_OFF=3'd3;
    parameter WAIT_POWER_GOOD=3'd4;
    parameter ISO_OFF=3'd5;

reg soft_rst_local;
prcm_reset_extender reset_extender(
    .rst_in_n(rst_in_n),
    .rst_out_n(rst_out_n),
    .soft_rst(soft_rst_local),
    .clk(clk)
);
    always@(posedge clk or negedge rst_in_n)begin
	    if(!rst_in_n) begin
		    reset_fsm <=NORMAL;
		    duration<=RESET_DURATION;
		    iso <=1'b0;
		    power_on <= 1'b1;
		    soft_rst_local<=1'b0;
	    end else begin
        power_on <= 1'b1;
		    case(reset_fsm)
			    NORMAL:begin
				    iso <=1'b0;
				    soft_rst_local<=soft_rst;
				    if(power_down_in)begin
					    reset_fsm <=ISO_ON;
				    end
			    end
			    ISO_ON: begin
				    iso <=1'b1;
					    reset_fsm <=POWER_OFF;
			    end
			    POWER_OFF:begin
				    power_on<=1'b0;
				    if(!power_down_in)begin
					    reset_fsm <= WAIT_POWER_GOOD;
					    duration <=counter;
				    end
			    end
			    WAIT_POWER_GOOD:begin
				    if(power_down_in) reset_fsm <=ISO_ON;
				    else if(power_good)begin
					    soft_rst_local<=1'b1;
					    if(duration ==0) reset_fsm<=ISO_OFF;
					    else duration<=duration - 1;
				    end
			    end
			    ISO_OFF:begin
				    if(power_down_in) reset_fsm <=ISO_ON;
            else begin
				    iso <=1'b0;
				    reset_fsm <=RESET;
				    duration<=RESET_DURATION;
          end
			    end
			    RESET: begin
				    if(power_down_in) reset_fsm <=ISO_ON;
				    else if(duration==0) reset_fsm<=NORMAL;
				    else duration <= duration -1;
			    end
			    default begin
				    reset_fsm<=WAIT_POWER_GOOD;
				    duration<=RESET_DURATION;
			    end

		    endcase
	    end
    end
endmodule : power_aware_reset_ctrl
