/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>

 Testbench wrapper for qspi_32_64_0.
 Normalises signal names for cocotb:
   slave_*          → axim_*       (AXI-Lite slave)
   io_clk_o         → qspi_sck    (SPI clock output)
   io_ncs_o         → qspi_cs_n   (chip select, active low)
   io_io_o[3:0]     → qspi_dq_o   (data output from DUT)
   io_io_enable[3:0]→ qspi_dq_oe  (output enable per line)
   io_io_i_io_i[3:0]← qspi_dq_i   (data input to DUT, driven by flash model)
   interrupts       → interrupts
*/
module qspi (
    input           CLK,
    input           RST_N,

    // AXI-Lite slave – normalised prefix 'axim_' for cocotbext.axi
    input           axim_awvalid,
    input  [31:0]   axim_awaddr,
    input  [1:0]    axim_awsize,
    input  [2:0]    axim_awprot,
    output          axim_awready,
    input           axim_wvalid,
    input  [63:0]   axim_wdata,
    input  [7:0]    axim_wstrb,
    output          axim_wready,
    output          axim_bvalid,
    output [1:0]    axim_bresp,
    input           axim_bready,
    input           axim_arvalid,
    input  [31:0]   axim_araddr,
    input  [1:0]    axim_arsize,
    input  [2:0]    axim_arprot,
    output          axim_arready,
    output          axim_rvalid,
    output [1:0]    axim_rresp,
    output [63:0]   axim_rdata,
    input           axim_rready,

    // SPI flash physical interface (for SpiFlashModel in cocotb)
    output          qspi_sck,
    output          qspi_cs_n,
    output [3:0]    qspi_dq_o,
    output [3:0]    qspi_dq_oe,
    input  [3:0]    qspi_dq_i,

    // Interrupt
    output          interrupts
);

qspi_32_64_0 dut (
    // Clocks / resets – tie slow clock to main clock for simulation
    .CLK_slow_clock          (CLK),
    .RST_N_slow_reset        (RST_N),
    .CLK                     (CLK),
    .RST_N                   (RST_N),

    // AXI-Lite slave
    // BSV uses half-byte word addressing internally; shift by 1 to convert
    // from cocotb byte addresses to the DUT's word-index space.
    .slave_m_awvalid_awvalid (axim_awvalid),
    .slave_m_awvalid_awaddr  (axim_awaddr >> 1),
    .slave_m_awvalid_awsize  (2'd0),
    .slave_m_awvalid_awprot  (axim_awprot),
    .slave_awready           (axim_awready),
    .slave_m_wvalid_wvalid   (axim_wvalid),
    .slave_m_wvalid_wdata    (axim_wdata),
    .slave_m_wvalid_wstrb    (axim_wstrb),
    .slave_wready            (axim_wready),
    .slave_bvalid            (axim_bvalid),
    .slave_bresp             (axim_bresp),
    .slave_m_bready_bready   (axim_bready),
    .slave_m_arvalid_arvalid (axim_arvalid),
    .slave_m_arvalid_araddr  (axim_araddr >> 1),
    .slave_m_arvalid_arsize  (2'd0),
    .slave_m_arvalid_arprot  (axim_arprot),
    .slave_arready           (axim_arready),
    .slave_rvalid            (axim_rvalid),
    .slave_rresp             (axim_rresp),
    .slave_rdata             (axim_rdata),
    .slave_m_rready_rready   (axim_rready),

    // SPI flash IO
    .io_clk_o                (qspi_sck),
    .io_ncs_o                (qspi_cs_n),
    .io_io_o                 (qspi_dq_o),
    .io_io_enable            (qspi_dq_oe),
    .io_io_i_io_i            (qspi_dq_i),

    // Interrupt
    .interrupts              (interrupts)
);

endmodule
