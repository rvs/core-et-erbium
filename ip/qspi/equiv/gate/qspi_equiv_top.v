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

// qspi_equiv_top.v (gate) — for equivalence checking only, not for synthesis
module qspi_equiv_top (
    input         CLK,
    input         RST_N,
    // QSPI IO
    output        qspi_clk_o,
    output [3:0]  qspi_io_o,
    output [3:0]  qspi_io_enable,
    input  [3:0]  qspi_io_i,
    output        qspi_ncs_o,
    // AXI4-Lite write-address channel
    input         axi_awvalid,
    input  [31:0] axi_awaddr,
    input  [1:0]  axi_awsize,
    input  [2:0]  axi_awprot,
    output        axi_awready,
    // AXI4-Lite write-data channel
    input         axi_wvalid,
    input  [63:0] axi_wdata,
    input  [7:0]  axi_wstrb,
    output        axi_wready,
    // AXI4-Lite write-response channel
    output        axi_bvalid,
    output [1:0]  axi_bresp,
    input         axi_bready,
    // AXI4-Lite read-address channel
    input         axi_arvalid,
    input  [31:0] axi_araddr,
    input  [1:0]  axi_arsize,
    input  [2:0]  axi_arprot,
    output        axi_arready,
    // AXI4-Lite read-data channel
    output        axi_rvalid,
    output [1:0]  axi_rresp,
    output [63:0] axi_rdata,
    input         axi_rready,
    output        interrupts
);
    qspi_32_64_0 dut (
        .CLK                      (CLK),
        .RST_N                    (RST_N),
        .CLK_slow_clock           (CLK),
        .RST_N_slow_reset         (RST_N),
        .qspi_clk_o               (qspi_clk_o),
        .qspi_io_o                (qspi_io_o),
        .qspi_io_enable           (qspi_io_enable),
        .qspi_io_i                (qspi_io_i),
        .qspi_ncs_o               (qspi_ncs_o),
        .axi_awvalid              (axi_awvalid),
        .axi_awaddr               (axi_awaddr),
        .axi_awsize               (axi_awsize),
        .axi_awprot               (axi_awprot),
        .axi_awready              (axi_awready),
        .axi_wvalid               (axi_wvalid),
        .axi_wdata                (axi_wdata),
        .axi_wstrb                (axi_wstrb),
        .axi_wready               (axi_wready),
        .axi_bvalid               (axi_bvalid),
        .axi_bresp                (axi_bresp),
        .axi_bready               (axi_bready),
        .axi_arvalid              (axi_arvalid),
        .axi_araddr               (axi_araddr),
        .axi_arsize               (axi_arsize),
        .axi_arprot               (axi_arprot),
        .axi_arready              (axi_arready),
        .axi_rvalid               (axi_rvalid),
        .axi_rresp                (axi_rresp),
        .axi_rdata                (axi_rdata),
        .axi_rready               (axi_rready),
        .interrupts               (interrupts)
    );
endmodule
