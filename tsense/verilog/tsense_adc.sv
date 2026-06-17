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


module tsense_adc (
  input  logic       clk,
  input  logic       en,
  output logic [3:0] d,
  output logic       drdy,
  output logic       conv_b,
  input  logic       hc_tsense_vctat,
  input  logic       hc_tsense_vref
`ifdef GLS
  ,inout vdd, 
  inout vss 
`endif
);
  parameter int unsigned CONV_CYCLES = 8;

  typedef enum logic [1:0] {
    IDLE = 2'b00,
    CONV = 2'b01,
    DRDY = 2'b10,
    GAP  = 2'b11
  } state_e;

  state_e      state;
  int unsigned cycles_left;
  logic [3:0]  sampled_d;

  initial begin
    state       = IDLE;
    d           = 4'h0;
    drdy        = 1'b0;
    conv_b      = 1'b1;
    cycles_left = '0;
    sampled_d   = 4'h0;
  end

  always @(posedge clk) begin
    if (en !== 1'b1) begin
      state       <= IDLE;
      d           <= 4'h0;
      drdy        <= 1'b0;
      conv_b      <= 1'b1;
      cycles_left <= '0;
      sampled_d   <= 4'h0;
    end else begin
      case (state)
        IDLE: begin
          if (hc_tsense_vctat === 1'b1 && hc_tsense_vref === 1'b1) begin
            state       <= CONV;
            conv_b      <= 1'b0;
            cycles_left <= (CONV_CYCLES > 1) ? (CONV_CYCLES - 1) : '0;
            sampled_d   <= $urandom;
          end
        end

        CONV: begin
          if (cycles_left == 0) begin
            state  <= DRDY;
            d      <= sampled_d;
            drdy   <= 1'b1;
            conv_b <= 1'b1;
          end else begin
            cycles_left <= cycles_left - 1;
          end
        end

        DRDY: begin
          state <= GAP;
          drdy  <= 1'b0;
        end

        GAP: begin
          if (hc_tsense_vctat === 1'b1 && hc_tsense_vref === 1'b1) begin
            state       <= CONV;
            conv_b      <= 1'b0;
            cycles_left <= (CONV_CYCLES > 1) ? (CONV_CYCLES - 1) : '0;
            sampled_d   <= $urandom;
          end else begin
            state <= IDLE;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
