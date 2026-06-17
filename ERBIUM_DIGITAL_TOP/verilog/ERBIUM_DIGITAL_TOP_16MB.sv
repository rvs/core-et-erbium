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

`define BANK_1 1
`define BANK_1_MODULE bank
module ERBIUM_DIGITAL_TOP_16MB(
    inout            ANATEST0,
    inout            ANATEST1,
    // Test signals
    input            TestMode,
    // xSPI IO signals (mapped to HyperBus pad naming)
    input    [1:0]   xspi_mode,
    // GPIO
    input    [10:0]  gpio_in,
    output   [10:0]  gpio_out,
    output   [10:0]  gpio_ena,
    output   [2:0]   drive_strength,
    // inout            VDD,
    // inout            VDD18,
    // inout            VDDO,
    // inout            VSS,
    input            hb_c_clk_jtag_tck,
    input            hb_c_cs,
    input            hb_c_resetn_jtag_trstn,
    input            hb_c_rwds,
    output   [7:0]   hb_i,
    output           hb_i_clk_jtag_tck,                      //**** No connection
    output           hb_i_cs,                                //**** No connection
    output           hb_i_resetn_jtag_trstn,                 //**** No Connection
    output           hb_i_rwds,
    output   [11:0]  hb_ie,
    output   [11:0]  hb_oen,
    input    [7:0]   hb_out,
    output   [11:0]  hb_sl,
    output   [11:0]  hb_st,
    input            jt_c_tdi,
    input            jt_c_tdo,                               //**** No Connection
    input            jt_c_tms,                               //**** No Connection
    output           jt_i_tdi,                               //**** No Connection
    output           jt_i_tdo,
    output           jt_i_tms,
    output   [2:0]   jt_ie,
    output   [2:0]   jt_oen,
    output   [2:0]   jt_sl,
    output   [2:0]   jt_st
  );
    logic          hb_oen_dq;
    logic          hb_oen_rwds;
    logic          jtag_tdoen;
    logic          brownout_b;
    assign hb_oen                = { 1'b1, ~hb_oen_rwds, 1'b1, 1'b1, {8{~hb_oen_dq}}};
    assign hb_ie                 = { 1'b1, ~hb_oen_rwds, 1'b1, 1'b1, {8{~hb_oen_dq}}};
    assign hb_st                 = {12{1'b0}};
    assign hb_sl                 = {12{1'b0}};
    assign jt_oen                = {1'b1, jtag_tdoen, 1'b1};
    assign jt_ie                 = {1'b1, 1'b0,       1'b1};
    assign jt_st                 = {3{1'b0}};
    assign jt_sl                 = {3{1'b0}};
    pwr_uvdetect_et pwr_uvdetect_et_u (
            .pwr_uv_b       (brownout_b)
    );
    //
    //  Erbium Digital
    //
    erbium_digital_et_aon erbium_digital_et_aon_u (
            // Analog / test signals
            .ANATEST0,
            .ANATEST1,
            .TestMode,
            .brownout_b,
            // xSPI IO (pad naming: hb_c_cs = XSPI_CSN, hb_out = XSPI_DQ_IN, etc.)
            .XSPI_CSN        (hb_c_cs),                    //  input
            .XSPI_DQ_IN      (hb_out),                     //  input  [7:0]
            .XSPI_DQ_OUT     (hb_i),                       //  output [7:0]
            .XSPI_DQ_OEN     (hb_oen_dq),                  //  output
            .XSPI_RWDS_IN    (hb_c_rwds),                  //  input
            .XSPI_RWDS_OUT   (hb_i_rwds),                  //  output
            .XSPI_RWDS_OEN   (hb_oen_rwds),                //  output
            .xspi_mode,
            // GPIO
            .gpio_in,
            .gpio_out,
            .gpio_out_ena    (gpio_ena),
            .drive_strength  (drive_strength),
            // JTAG
            .TDI             (jt_c_tdi),                   //  input
            .TMS             (jt_c_tms),                   //  input
            .TCK             (hb_c_clk_jtag_tck),          //  input
            .TRSTn           (hb_c_resetn_jtag_trstn),     //  input
            .TDO             (jt_i_tdo),                   //  output
            .TDOEN           (jtag_tdoen)                  //  output
    );
endmodule : ERBIUM_DIGITAL_TOP_16MB

