// SPDX-License-Identifier: Apache-2.0
// GENERATED — see flow/gen_top.py. Do not edit by hand.
// Configurable open-source AXI4/APB4 network-on-chip.
`include "axi/typedef.svh"

module erbium_noc_top (
  input  logic CPU_CLK,
  input  logic SYSTEM_CLK,
  input  logic XSPI_CLK,
  input  logic PERIPH_CLK,
  input  logic CPU_RESETn,
  input  logic SYSTEM_RESETn,
  input  logic XSPI_RESETn,
  input  logic PERIPH_RESETn,
  input  logic [8-1:0] AXI_SLAVE_S_CPU_AWID,
  input  logic [32-1:0] AXI_SLAVE_S_CPU_AWADDR,
  input  logic [8-1:0] AXI_SLAVE_S_CPU_AWLEN,
  input  logic [3-1:0] AXI_SLAVE_S_CPU_AWSIZE,
  input  logic [2-1:0] AXI_SLAVE_S_CPU_AWBURST,
  input  logic AXI_SLAVE_S_CPU_AWLOCK,
  input  logic [4-1:0] AXI_SLAVE_S_CPU_AWCACHE,
  input  logic [3-1:0] AXI_SLAVE_S_CPU_AWPROT,
  input  logic [4-1:0] AXI_SLAVE_S_CPU_AWQOS,
  input  logic AXI_SLAVE_S_CPU_AWVALID,
  input  logic [512-1:0] AXI_SLAVE_S_CPU_WDATA,
  input  logic [64-1:0] AXI_SLAVE_S_CPU_WSTRB,
  input  logic AXI_SLAVE_S_CPU_WLAST,
  input  logic AXI_SLAVE_S_CPU_WVALID,
  input  logic AXI_SLAVE_S_CPU_BREADY,
  input  logic [8-1:0] AXI_SLAVE_S_CPU_ARID,
  input  logic [32-1:0] AXI_SLAVE_S_CPU_ARADDR,
  input  logic [8-1:0] AXI_SLAVE_S_CPU_ARLEN,
  input  logic [3-1:0] AXI_SLAVE_S_CPU_ARSIZE,
  input  logic [2-1:0] AXI_SLAVE_S_CPU_ARBURST,
  input  logic AXI_SLAVE_S_CPU_ARLOCK,
  input  logic [4-1:0] AXI_SLAVE_S_CPU_ARCACHE,
  input  logic [3-1:0] AXI_SLAVE_S_CPU_ARPROT,
  input  logic [4-1:0] AXI_SLAVE_S_CPU_ARQOS,
  input  logic AXI_SLAVE_S_CPU_ARVALID,
  input  logic AXI_SLAVE_S_CPU_RREADY,
  output logic AXI_SLAVE_S_CPU_AWREADY,
  output logic AXI_SLAVE_S_CPU_WREADY,
  output logic [8-1:0] AXI_SLAVE_S_CPU_BID,
  output logic [2-1:0] AXI_SLAVE_S_CPU_BRESP,
  output logic AXI_SLAVE_S_CPU_BVALID,
  output logic AXI_SLAVE_S_CPU_ARREADY,
  output logic [8-1:0] AXI_SLAVE_S_CPU_RID,
  output logic [512-1:0] AXI_SLAVE_S_CPU_RDATA,
  output logic [2-1:0] AXI_SLAVE_S_CPU_RRESP,
  output logic AXI_SLAVE_S_CPU_RLAST,
  output logic AXI_SLAVE_S_CPU_RVALID,
  input  logic AXI_SLAVE_S_XSPI_AWID,
  input  logic [32-1:0] AXI_SLAVE_S_XSPI_AWADDR,
  input  logic [8-1:0] AXI_SLAVE_S_XSPI_AWLEN,
  input  logic [3-1:0] AXI_SLAVE_S_XSPI_AWSIZE,
  input  logic [2-1:0] AXI_SLAVE_S_XSPI_AWBURST,
  input  logic AXI_SLAVE_S_XSPI_AWLOCK,
  input  logic [4-1:0] AXI_SLAVE_S_XSPI_AWCACHE,
  input  logic [3-1:0] AXI_SLAVE_S_XSPI_AWPROT,
  input  logic [4-1:0] AXI_SLAVE_S_XSPI_AWQOS,
  input  logic AXI_SLAVE_S_XSPI_AWVALID,
  input  logic [64-1:0] AXI_SLAVE_S_XSPI_WDATA,
  input  logic [8-1:0] AXI_SLAVE_S_XSPI_WSTRB,
  input  logic AXI_SLAVE_S_XSPI_WLAST,
  input  logic AXI_SLAVE_S_XSPI_WVALID,
  input  logic AXI_SLAVE_S_XSPI_BREADY,
  input  logic AXI_SLAVE_S_XSPI_ARID,
  input  logic [32-1:0] AXI_SLAVE_S_XSPI_ARADDR,
  input  logic [8-1:0] AXI_SLAVE_S_XSPI_ARLEN,
  input  logic [3-1:0] AXI_SLAVE_S_XSPI_ARSIZE,
  input  logic [2-1:0] AXI_SLAVE_S_XSPI_ARBURST,
  input  logic AXI_SLAVE_S_XSPI_ARLOCK,
  input  logic [4-1:0] AXI_SLAVE_S_XSPI_ARCACHE,
  input  logic [3-1:0] AXI_SLAVE_S_XSPI_ARPROT,
  input  logic [4-1:0] AXI_SLAVE_S_XSPI_ARQOS,
  input  logic AXI_SLAVE_S_XSPI_ARVALID,
  input  logic AXI_SLAVE_S_XSPI_RREADY,
  output logic AXI_SLAVE_S_XSPI_AWREADY,
  output logic AXI_SLAVE_S_XSPI_WREADY,
  output logic AXI_SLAVE_S_XSPI_BID,
  output logic [2-1:0] AXI_SLAVE_S_XSPI_BRESP,
  output logic AXI_SLAVE_S_XSPI_BVALID,
  output logic AXI_SLAVE_S_XSPI_ARREADY,
  output logic AXI_SLAVE_S_XSPI_RID,
  output logic [64-1:0] AXI_SLAVE_S_XSPI_RDATA,
  output logic [2-1:0] AXI_SLAVE_S_XSPI_RRESP,
  output logic AXI_SLAVE_S_XSPI_RLAST,
  output logic AXI_SLAVE_S_XSPI_RVALID,
  output logic [9-1:0] AXI_MASTER_M_MRAM_AWID,
  output logic [32-1:0] AXI_MASTER_M_MRAM_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_MRAM_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_MRAM_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_MRAM_AWBURST,
  output logic AXI_MASTER_M_MRAM_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_MRAM_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_MRAM_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_MRAM_AWQOS,
  output logic AXI_MASTER_M_MRAM_AWVALID,
  output logic [512-1:0] AXI_MASTER_M_MRAM_WDATA,
  output logic [64-1:0] AXI_MASTER_M_MRAM_WSTRB,
  output logic AXI_MASTER_M_MRAM_WLAST,
  output logic AXI_MASTER_M_MRAM_WVALID,
  output logic AXI_MASTER_M_MRAM_BREADY,
  output logic [9-1:0] AXI_MASTER_M_MRAM_ARID,
  output logic [32-1:0] AXI_MASTER_M_MRAM_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_MRAM_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_MRAM_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_MRAM_ARBURST,
  output logic AXI_MASTER_M_MRAM_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_MRAM_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_MRAM_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_MRAM_ARQOS,
  output logic AXI_MASTER_M_MRAM_ARVALID,
  output logic AXI_MASTER_M_MRAM_RREADY,
  input  logic AXI_MASTER_M_MRAM_AWREADY,
  input  logic AXI_MASTER_M_MRAM_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_MRAM_BID,
  input  logic [2-1:0] AXI_MASTER_M_MRAM_BRESP,
  input  logic AXI_MASTER_M_MRAM_BVALID,
  input  logic AXI_MASTER_M_MRAM_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_MRAM_RID,
  input  logic [512-1:0] AXI_MASTER_M_MRAM_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_MRAM_RRESP,
  input  logic AXI_MASTER_M_MRAM_RLAST,
  input  logic AXI_MASTER_M_MRAM_RVALID,
  output logic [9-1:0] AXI_MASTER_M_CPU_REG_AWID,
  output logic [32-1:0] AXI_MASTER_M_CPU_REG_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_CPU_REG_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_CPU_REG_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_CPU_REG_AWBURST,
  output logic AXI_MASTER_M_CPU_REG_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_CPU_REG_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_CPU_REG_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_CPU_REG_AWQOS,
  output logic AXI_MASTER_M_CPU_REG_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_CPU_REG_WDATA,
  output logic [8-1:0] AXI_MASTER_M_CPU_REG_WSTRB,
  output logic AXI_MASTER_M_CPU_REG_WLAST,
  output logic AXI_MASTER_M_CPU_REG_WVALID,
  output logic AXI_MASTER_M_CPU_REG_BREADY,
  output logic [9-1:0] AXI_MASTER_M_CPU_REG_ARID,
  output logic [32-1:0] AXI_MASTER_M_CPU_REG_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_CPU_REG_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_CPU_REG_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_CPU_REG_ARBURST,
  output logic AXI_MASTER_M_CPU_REG_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_CPU_REG_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_CPU_REG_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_CPU_REG_ARQOS,
  output logic AXI_MASTER_M_CPU_REG_ARVALID,
  output logic AXI_MASTER_M_CPU_REG_RREADY,
  input  logic AXI_MASTER_M_CPU_REG_AWREADY,
  input  logic AXI_MASTER_M_CPU_REG_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_CPU_REG_BID,
  input  logic [2-1:0] AXI_MASTER_M_CPU_REG_BRESP,
  input  logic AXI_MASTER_M_CPU_REG_BVALID,
  input  logic AXI_MASTER_M_CPU_REG_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_CPU_REG_RID,
  input  logic [64-1:0] AXI_MASTER_M_CPU_REG_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_CPU_REG_RRESP,
  input  logic AXI_MASTER_M_CPU_REG_RLAST,
  input  logic AXI_MASTER_M_CPU_REG_RVALID,
  output logic [9-1:0] AXI_MASTER_M_SYSTEM_REG_AWID,
  output logic [32-1:0] AXI_MASTER_M_SYSTEM_REG_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_SYSTEM_REG_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_SYSTEM_REG_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_SYSTEM_REG_AWBURST,
  output logic AXI_MASTER_M_SYSTEM_REG_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_SYSTEM_REG_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_SYSTEM_REG_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_SYSTEM_REG_AWQOS,
  output logic AXI_MASTER_M_SYSTEM_REG_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_SYSTEM_REG_WDATA,
  output logic [8-1:0] AXI_MASTER_M_SYSTEM_REG_WSTRB,
  output logic AXI_MASTER_M_SYSTEM_REG_WLAST,
  output logic AXI_MASTER_M_SYSTEM_REG_WVALID,
  output logic AXI_MASTER_M_SYSTEM_REG_BREADY,
  output logic [9-1:0] AXI_MASTER_M_SYSTEM_REG_ARID,
  output logic [32-1:0] AXI_MASTER_M_SYSTEM_REG_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_SYSTEM_REG_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_SYSTEM_REG_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_SYSTEM_REG_ARBURST,
  output logic AXI_MASTER_M_SYSTEM_REG_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_SYSTEM_REG_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_SYSTEM_REG_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_SYSTEM_REG_ARQOS,
  output logic AXI_MASTER_M_SYSTEM_REG_ARVALID,
  output logic AXI_MASTER_M_SYSTEM_REG_RREADY,
  input  logic AXI_MASTER_M_SYSTEM_REG_AWREADY,
  input  logic AXI_MASTER_M_SYSTEM_REG_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_SYSTEM_REG_BID,
  input  logic [2-1:0] AXI_MASTER_M_SYSTEM_REG_BRESP,
  input  logic AXI_MASTER_M_SYSTEM_REG_BVALID,
  input  logic AXI_MASTER_M_SYSTEM_REG_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_SYSTEM_REG_RID,
  input  logic [64-1:0] AXI_MASTER_M_SYSTEM_REG_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_SYSTEM_REG_RRESP,
  input  logic AXI_MASTER_M_SYSTEM_REG_RLAST,
  input  logic AXI_MASTER_M_SYSTEM_REG_RVALID,
  output logic [9-1:0] AXI_MASTER_M_MRAM_REG_AWID,
  output logic [32-1:0] AXI_MASTER_M_MRAM_REG_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_MRAM_REG_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_MRAM_REG_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_MRAM_REG_AWBURST,
  output logic AXI_MASTER_M_MRAM_REG_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_MRAM_REG_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_MRAM_REG_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_MRAM_REG_AWQOS,
  output logic AXI_MASTER_M_MRAM_REG_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_MRAM_REG_WDATA,
  output logic [8-1:0] AXI_MASTER_M_MRAM_REG_WSTRB,
  output logic AXI_MASTER_M_MRAM_REG_WLAST,
  output logic AXI_MASTER_M_MRAM_REG_WVALID,
  output logic AXI_MASTER_M_MRAM_REG_BREADY,
  output logic [9-1:0] AXI_MASTER_M_MRAM_REG_ARID,
  output logic [32-1:0] AXI_MASTER_M_MRAM_REG_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_MRAM_REG_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_MRAM_REG_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_MRAM_REG_ARBURST,
  output logic AXI_MASTER_M_MRAM_REG_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_MRAM_REG_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_MRAM_REG_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_MRAM_REG_ARQOS,
  output logic AXI_MASTER_M_MRAM_REG_ARVALID,
  output logic AXI_MASTER_M_MRAM_REG_RREADY,
  input  logic AXI_MASTER_M_MRAM_REG_AWREADY,
  input  logic AXI_MASTER_M_MRAM_REG_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_MRAM_REG_BID,
  input  logic [2-1:0] AXI_MASTER_M_MRAM_REG_BRESP,
  input  logic AXI_MASTER_M_MRAM_REG_BVALID,
  input  logic AXI_MASTER_M_MRAM_REG_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_MRAM_REG_RID,
  input  logic [64-1:0] AXI_MASTER_M_MRAM_REG_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_MRAM_REG_RRESP,
  input  logic AXI_MASTER_M_MRAM_REG_RLAST,
  input  logic AXI_MASTER_M_MRAM_REG_RVALID,
  output logic [9-1:0] AXI_MASTER_M_SPI_REG_AWID,
  output logic [32-1:0] AXI_MASTER_M_SPI_REG_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_SPI_REG_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_SPI_REG_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_SPI_REG_AWBURST,
  output logic AXI_MASTER_M_SPI_REG_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_SPI_REG_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_SPI_REG_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_SPI_REG_AWQOS,
  output logic AXI_MASTER_M_SPI_REG_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_SPI_REG_WDATA,
  output logic [8-1:0] AXI_MASTER_M_SPI_REG_WSTRB,
  output logic AXI_MASTER_M_SPI_REG_WLAST,
  output logic AXI_MASTER_M_SPI_REG_WVALID,
  output logic AXI_MASTER_M_SPI_REG_BREADY,
  output logic [9-1:0] AXI_MASTER_M_SPI_REG_ARID,
  output logic [32-1:0] AXI_MASTER_M_SPI_REG_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_SPI_REG_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_SPI_REG_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_SPI_REG_ARBURST,
  output logic AXI_MASTER_M_SPI_REG_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_SPI_REG_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_SPI_REG_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_SPI_REG_ARQOS,
  output logic AXI_MASTER_M_SPI_REG_ARVALID,
  output logic AXI_MASTER_M_SPI_REG_RREADY,
  input  logic AXI_MASTER_M_SPI_REG_AWREADY,
  input  logic AXI_MASTER_M_SPI_REG_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_SPI_REG_BID,
  input  logic [2-1:0] AXI_MASTER_M_SPI_REG_BRESP,
  input  logic AXI_MASTER_M_SPI_REG_BVALID,
  input  logic AXI_MASTER_M_SPI_REG_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_SPI_REG_RID,
  input  logic [64-1:0] AXI_MASTER_M_SPI_REG_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_SPI_REG_RRESP,
  input  logic AXI_MASTER_M_SPI_REG_RLAST,
  input  logic AXI_MASTER_M_SPI_REG_RVALID,
  output logic [9-1:0] AXI_MASTER_M_UART_REG_AWID,
  output logic [32-1:0] AXI_MASTER_M_UART_REG_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_UART_REG_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_UART_REG_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_UART_REG_AWBURST,
  output logic AXI_MASTER_M_UART_REG_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_UART_REG_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_UART_REG_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_UART_REG_AWQOS,
  output logic AXI_MASTER_M_UART_REG_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_UART_REG_WDATA,
  output logic [8-1:0] AXI_MASTER_M_UART_REG_WSTRB,
  output logic AXI_MASTER_M_UART_REG_WLAST,
  output logic AXI_MASTER_M_UART_REG_WVALID,
  output logic AXI_MASTER_M_UART_REG_BREADY,
  output logic [9-1:0] AXI_MASTER_M_UART_REG_ARID,
  output logic [32-1:0] AXI_MASTER_M_UART_REG_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_UART_REG_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_UART_REG_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_UART_REG_ARBURST,
  output logic AXI_MASTER_M_UART_REG_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_UART_REG_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_UART_REG_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_UART_REG_ARQOS,
  output logic AXI_MASTER_M_UART_REG_ARVALID,
  output logic AXI_MASTER_M_UART_REG_RREADY,
  input  logic AXI_MASTER_M_UART_REG_AWREADY,
  input  logic AXI_MASTER_M_UART_REG_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_UART_REG_BID,
  input  logic [2-1:0] AXI_MASTER_M_UART_REG_BRESP,
  input  logic AXI_MASTER_M_UART_REG_BVALID,
  input  logic AXI_MASTER_M_UART_REG_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_UART_REG_RID,
  input  logic [64-1:0] AXI_MASTER_M_UART_REG_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_UART_REG_RRESP,
  input  logic AXI_MASTER_M_UART_REG_RLAST,
  input  logic AXI_MASTER_M_UART_REG_RVALID,
  output logic [9-1:0] AXI_MASTER_M_SRAM_AWID,
  output logic [32-1:0] AXI_MASTER_M_SRAM_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_SRAM_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_SRAM_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_SRAM_AWBURST,
  output logic AXI_MASTER_M_SRAM_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_SRAM_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_SRAM_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_SRAM_AWQOS,
  output logic AXI_MASTER_M_SRAM_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_SRAM_WDATA,
  output logic [8-1:0] AXI_MASTER_M_SRAM_WSTRB,
  output logic AXI_MASTER_M_SRAM_WLAST,
  output logic AXI_MASTER_M_SRAM_WVALID,
  output logic AXI_MASTER_M_SRAM_BREADY,
  output logic [9-1:0] AXI_MASTER_M_SRAM_ARID,
  output logic [32-1:0] AXI_MASTER_M_SRAM_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_SRAM_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_SRAM_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_SRAM_ARBURST,
  output logic AXI_MASTER_M_SRAM_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_SRAM_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_SRAM_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_SRAM_ARQOS,
  output logic AXI_MASTER_M_SRAM_ARVALID,
  output logic AXI_MASTER_M_SRAM_RREADY,
  input  logic AXI_MASTER_M_SRAM_AWREADY,
  input  logic AXI_MASTER_M_SRAM_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_SRAM_BID,
  input  logic [2-1:0] AXI_MASTER_M_SRAM_BRESP,
  input  logic AXI_MASTER_M_SRAM_BVALID,
  input  logic AXI_MASTER_M_SRAM_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_SRAM_RID,
  input  logic [64-1:0] AXI_MASTER_M_SRAM_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_SRAM_RRESP,
  input  logic AXI_MASTER_M_SRAM_RLAST,
  input  logic AXI_MASTER_M_SRAM_RVALID,
  output logic [9-1:0] AXI_MASTER_M_XSPI_AWID,
  output logic [32-1:0] AXI_MASTER_M_XSPI_AWADDR,
  output logic [8-1:0] AXI_MASTER_M_XSPI_AWLEN,
  output logic [3-1:0] AXI_MASTER_M_XSPI_AWSIZE,
  output logic [2-1:0] AXI_MASTER_M_XSPI_AWBURST,
  output logic AXI_MASTER_M_XSPI_AWLOCK,
  output logic [4-1:0] AXI_MASTER_M_XSPI_AWCACHE,
  output logic [3-1:0] AXI_MASTER_M_XSPI_AWPROT,
  output logic [4-1:0] AXI_MASTER_M_XSPI_AWQOS,
  output logic AXI_MASTER_M_XSPI_AWVALID,
  output logic [64-1:0] AXI_MASTER_M_XSPI_WDATA,
  output logic [8-1:0] AXI_MASTER_M_XSPI_WSTRB,
  output logic AXI_MASTER_M_XSPI_WLAST,
  output logic AXI_MASTER_M_XSPI_WVALID,
  output logic AXI_MASTER_M_XSPI_BREADY,
  output logic [9-1:0] AXI_MASTER_M_XSPI_ARID,
  output logic [32-1:0] AXI_MASTER_M_XSPI_ARADDR,
  output logic [8-1:0] AXI_MASTER_M_XSPI_ARLEN,
  output logic [3-1:0] AXI_MASTER_M_XSPI_ARSIZE,
  output logic [2-1:0] AXI_MASTER_M_XSPI_ARBURST,
  output logic AXI_MASTER_M_XSPI_ARLOCK,
  output logic [4-1:0] AXI_MASTER_M_XSPI_ARCACHE,
  output logic [3-1:0] AXI_MASTER_M_XSPI_ARPROT,
  output logic [4-1:0] AXI_MASTER_M_XSPI_ARQOS,
  output logic AXI_MASTER_M_XSPI_ARVALID,
  output logic AXI_MASTER_M_XSPI_RREADY,
  input  logic AXI_MASTER_M_XSPI_AWREADY,
  input  logic AXI_MASTER_M_XSPI_WREADY,
  input  logic [9-1:0] AXI_MASTER_M_XSPI_BID,
  input  logic [2-1:0] AXI_MASTER_M_XSPI_BRESP,
  input  logic AXI_MASTER_M_XSPI_BVALID,
  input  logic AXI_MASTER_M_XSPI_ARREADY,
  input  logic [9-1:0] AXI_MASTER_M_XSPI_RID,
  input  logic [64-1:0] AXI_MASTER_M_XSPI_RDATA,
  input  logic [2-1:0] AXI_MASTER_M_XSPI_RRESP,
  input  logic AXI_MASTER_M_XSPI_RLAST,
  input  logic AXI_MASTER_M_XSPI_RVALID,
  output logic [31:0] APB_MASTER_M_I2C_REG_PADDR,
  output logic [2:0]  APB_MASTER_M_I2C_REG_PPROT,
  output logic        APB_MASTER_M_I2C_REG_PSEL,
  output logic        APB_MASTER_M_I2C_REG_PENABLE,
  output logic        APB_MASTER_M_I2C_REG_PWRITE,
  output logic [31:0] APB_MASTER_M_I2C_REG_PWDATA,
  output logic [3:0]  APB_MASTER_M_I2C_REG_PSTRB,
  input  logic        APB_MASTER_M_I2C_REG_PREADY,
  input  logic [31:0] APB_MASTER_M_I2C_REG_PRDATA,
  input  logic        APB_MASTER_M_I2C_REG_PSLVERR,
  output logic CPU_QACTIVE,
  input  logic CPU_QREQn,
  output logic CPU_QACCEPTn,
  output logic CPU_QDENY,
  input  logic CPU_SPIDEN,
  input  logic CPU_NIDEN,
  input  logic CPU_DBGEN,
  input  logic CPU_SPNIDEN,
  input  logic CPU_PMUSNAPSHOTREQ,
  output logic CPU_PMUSNAPSHOTACK,
  output logic CPU_nPMUINTERRUPT,
  input  logic DFTCPUDISABLE,
  output logic SYSTEM_QACTIVE,
  input  logic SYSTEM_QREQn,
  output logic SYSTEM_QACCEPTn,
  output logic SYSTEM_QDENY,
  input  logic SYSTEM_SPIDEN,
  input  logic SYSTEM_NIDEN,
  input  logic SYSTEM_DBGEN,
  input  logic SYSTEM_SPNIDEN,
  input  logic SYSTEM_PMUSNAPSHOTREQ,
  output logic SYSTEM_PMUSNAPSHOTACK,
  output logic SYSTEM_nPMUINTERRUPT,
  input  logic DFTSYSTEMDISABLE,
  output logic XSPI_QACTIVE,
  input  logic XSPI_QREQn,
  output logic XSPI_QACCEPTn,
  output logic XSPI_QDENY,
  input  logic XSPI_SPIDEN,
  input  logic XSPI_NIDEN,
  input  logic XSPI_DBGEN,
  input  logic XSPI_SPNIDEN,
  input  logic XSPI_PMUSNAPSHOTREQ,
  output logic XSPI_PMUSNAPSHOTACK,
  output logic XSPI_nPMUINTERRUPT,
  input  logic DFTXSPIDISABLE,
  output logic PERIPH_QACTIVE,
  input  logic PERIPH_QREQn,
  output logic PERIPH_QACCEPTn,
  output logic PERIPH_QDENY,
  input  logic PERIPH_SPIDEN,
  input  logic PERIPH_NIDEN,
  input  logic PERIPH_DBGEN,
  input  logic PERIPH_SPNIDEN,
  input  logic PERIPH_PMUSNAPSHOTREQ,
  output logic PERIPH_PMUSNAPSHOTACK,
  output logic PERIPH_nPMUINTERRUPT,
  input  logic DFTPERIPHDISABLE,
  output logic       PD_0_PACTIVE,
  input  logic       PD_0_PREQ,
  input  logic [3:0] PD_0_PSTATE,
  output logic       PD_0_PACCEPT,
  output logic       PD_0_PDENY,
  output logic       PD_0_INTERRUPT,
  output logic       PD_0_NS_INTERRUPT,
  input  logic AXI_SLAVE_S_CPU_AWAKEUP,
  input  logic AXI_SLAVE_S_XSPI_AWAKEUP,
  output logic AXI_MASTER_M_MRAM_AWAKEUP,
  output logic AXI_MASTER_M_CPU_REG_AWAKEUP,
  output logic AXI_MASTER_M_SYSTEM_REG_AWAKEUP,
  output logic AXI_MASTER_M_MRAM_REG_AWAKEUP,
  output logic AXI_MASTER_M_SPI_REG_AWAKEUP,
  output logic AXI_MASTER_M_UART_REG_AWAKEUP,
  output logic AXI_MASTER_M_SRAM_AWAKEUP,
  output logic AXI_MASTER_M_XSPI_AWAKEUP,
  input  logic [31:0] ECOREVNUM,
  input  logic S_CPU_CONFIG_ACCESS,
  input  logic S_XSPI_CONFIG_ACCESS,
  input  logic DFTCGEN,
  input  logic DFTRSTDISABLE
);

  // ---- per-domain clocks + synchronized resets ----
  logic clk_cpu, clk_sys, clk_xspi, clk_periph;
  assign clk_cpu=CPU_CLK; assign clk_sys=SYSTEM_CLK; assign clk_xspi=XSPI_CLK; assign clk_periph=PERIPH_CLK;
  logic rstn_cpu, rstn_sys, rstn_xspi, rstn_periph;
  erbium_noc_reset_sync i_rstsync_cpu (.clk_i(clk_cpu), .rst_n_async_i(CPU_RESETn), .rst_n_sync_o(rstn_cpu));
  erbium_noc_reset_sync i_rstsync_sys (.clk_i(clk_sys), .rst_n_async_i(SYSTEM_RESETn), .rst_n_sync_o(rstn_sys));
  erbium_noc_reset_sync i_rstsync_xspi (.clk_i(clk_xspi), .rst_n_async_i(XSPI_RESETn), .rst_n_sync_o(rstn_xspi));
  erbium_noc_reset_sync i_rstsync_periph (.clk_i(clk_periph), .rst_n_async_i(PERIPH_RESETn), .rst_n_sync_o(rstn_periph));
  wire clk = clk_cpu; wire rst_n = rstn_cpu;  // fabric domain

  // ---- type sets ----
  typedef logic [32-1:0]   axs_addr_t;
  typedef logic [8-1:0]   axs_id_t;
  typedef logic [512-1:0]  axs_data_t;
  typedef logic [512/8-1:0] axs_strb_t;
  typedef logic [0:0]   axs_user_t;
  `AXI_TYPEDEF_ALL(axs, axs_addr_t, axs_id_t, axs_data_t, axs_strb_t, axs_user_t)

  typedef logic [32-1:0]   xs_addr_t;
  typedef logic [8-1:0]   xs_id_t;
  typedef logic [64-1:0]  xs_data_t;
  typedef logic [64/8-1:0] xs_strb_t;
  typedef logic [0:0]   xs_user_t;
  `AXI_TYPEDEF_ALL(xs, xs_addr_t, xs_id_t, xs_data_t, xs_strb_t, xs_user_t)

  typedef logic [32-1:0]   axm_addr_t;
  typedef logic [9-1:0]   axm_id_t;
  typedef logic [512-1:0]  axm_data_t;
  typedef logic [512/8-1:0] axm_strb_t;
  typedef logic [0:0]   axm_user_t;
  `AXI_TYPEDEF_ALL(axm, axm_addr_t, axm_id_t, axm_data_t, axm_strb_t, axm_user_t)

  typedef logic [32-1:0]   d64_addr_t;
  typedef logic [9-1:0]   d64_id_t;
  typedef logic [64-1:0]  d64_data_t;
  typedef logic [64/8-1:0] d64_strb_t;
  typedef logic [0:0]   d64_user_t;
  `AXI_TYPEDEF_ALL(d64, d64_addr_t, d64_id_t, d64_data_t, d64_strb_t, d64_user_t)

  typedef logic [32-1:0]   d32_addr_t;
  typedef logic [9-1:0]   d32_id_t;
  typedef logic [32-1:0]  d32_data_t;
  typedef logic [32/8-1:0] d32_strb_t;
  typedef logic [0:0]   d32_user_t;
  `AXI_TYPEDEF_ALL(d32, d32_addr_t, d32_id_t, d32_data_t, d32_strb_t, d32_user_t)

  `AXI_LITE_TYPEDEF_ALL(lite, logic [31:0], logic [31:0], logic [3:0])
  typedef struct packed { logic [31:0] paddr; logic [2:0] pprot; logic psel;
                          logic penable; logic pwrite; logic [31:0] pwdata; logic [3:0] pstrb; } apb_req_t;
  typedef struct packed { logic pready; logic [31:0] prdata; logic pslverr; } apb_resp_t;

  typedef struct packed { int unsigned idx; logic [31:0] start_addr; logic [31:0] end_addr; } rule_t;

  axs_req_t  cpu_req;  axs_resp_t cpu_resp;
  xs_req_t   xspi_req_raw; xs_resp_t xspi_resp;        // XSPI domain (boundary)
  xs_req_t   xspi_req_cpu; xs_resp_t xspi_resp_cpu;    // after XSPI->CPU cdc
  axs_req_t  xspi_req_up;  axs_resp_t xspi_resp_up;  // after 64->512 upsize
  axs_req_t  xspi_req;     // after address remap
  axs_req_t  [1:0] slv_req; axs_resp_t [1:0] slv_resp;
  axm_req_t  [9:0] mst_req; axm_resp_t [9:0] mst_resp;  // 9 targets + GPV (idx 9)
  rule_t [9:0] addr_map;

  assign cpu_req.aw.id = AXI_SLAVE_S_CPU_AWID;
  assign cpu_req.aw.addr = AXI_SLAVE_S_CPU_AWADDR;
  assign cpu_req.aw.len = AXI_SLAVE_S_CPU_AWLEN;
  assign cpu_req.aw.size = AXI_SLAVE_S_CPU_AWSIZE;
  assign cpu_req.aw.burst = AXI_SLAVE_S_CPU_AWBURST;
  assign cpu_req.aw.lock = AXI_SLAVE_S_CPU_AWLOCK;
  assign cpu_req.aw.cache = AXI_SLAVE_S_CPU_AWCACHE;
  assign cpu_req.aw.prot = AXI_SLAVE_S_CPU_AWPROT;
  assign cpu_req.aw.qos = AXI_SLAVE_S_CPU_AWQOS;
  assign cpu_req.aw.region = '0;
  assign cpu_req.aw.atop   = '0;
  assign cpu_req.aw.user   = '0;
  assign cpu_req.aw_valid  = AXI_SLAVE_S_CPU_AWVALID;
  assign cpu_req.w.data = AXI_SLAVE_S_CPU_WDATA;
  assign cpu_req.w.strb = AXI_SLAVE_S_CPU_WSTRB;
  assign cpu_req.w.last = AXI_SLAVE_S_CPU_WLAST;
  assign cpu_req.w.user   = '0;
  assign cpu_req.w_valid  = AXI_SLAVE_S_CPU_WVALID;
  assign cpu_req.b_ready  = AXI_SLAVE_S_CPU_BREADY;
  assign cpu_req.ar.id = AXI_SLAVE_S_CPU_ARID;
  assign cpu_req.ar.addr = AXI_SLAVE_S_CPU_ARADDR;
  assign cpu_req.ar.len = AXI_SLAVE_S_CPU_ARLEN;
  assign cpu_req.ar.size = AXI_SLAVE_S_CPU_ARSIZE;
  assign cpu_req.ar.burst = AXI_SLAVE_S_CPU_ARBURST;
  assign cpu_req.ar.lock = AXI_SLAVE_S_CPU_ARLOCK;
  assign cpu_req.ar.cache = AXI_SLAVE_S_CPU_ARCACHE;
  assign cpu_req.ar.prot = AXI_SLAVE_S_CPU_ARPROT;
  assign cpu_req.ar.qos = AXI_SLAVE_S_CPU_ARQOS;
  assign cpu_req.ar.region = '0;
  assign cpu_req.ar.user   = '0;
  assign cpu_req.ar_valid  = AXI_SLAVE_S_CPU_ARVALID;
  assign cpu_req.r_ready   = AXI_SLAVE_S_CPU_RREADY;
  assign AXI_SLAVE_S_CPU_AWREADY = cpu_resp.aw_ready;
  assign AXI_SLAVE_S_CPU_WREADY  = cpu_resp.w_ready;
  assign AXI_SLAVE_S_CPU_BID     = cpu_resp.b.id[8-1:0];
  assign AXI_SLAVE_S_CPU_BRESP   = cpu_resp.b.resp;
  assign AXI_SLAVE_S_CPU_BVALID  = cpu_resp.b_valid;
  assign AXI_SLAVE_S_CPU_ARREADY = cpu_resp.ar_ready;
  assign AXI_SLAVE_S_CPU_RID     = cpu_resp.r.id[8-1:0];
  assign AXI_SLAVE_S_CPU_RDATA   = cpu_resp.r.data;
  assign AXI_SLAVE_S_CPU_RRESP   = cpu_resp.r.resp;
  assign AXI_SLAVE_S_CPU_RLAST   = cpu_resp.r.last;
  assign AXI_SLAVE_S_CPU_RVALID  = cpu_resp.r_valid;

  assign xspi_req_raw.aw.id = {7'b0, AXI_SLAVE_S_XSPI_AWID};
  assign xspi_req_raw.aw.addr = AXI_SLAVE_S_XSPI_AWADDR;
  assign xspi_req_raw.aw.len = AXI_SLAVE_S_XSPI_AWLEN;
  assign xspi_req_raw.aw.size = AXI_SLAVE_S_XSPI_AWSIZE;
  assign xspi_req_raw.aw.burst = AXI_SLAVE_S_XSPI_AWBURST;
  assign xspi_req_raw.aw.lock = AXI_SLAVE_S_XSPI_AWLOCK;
  assign xspi_req_raw.aw.cache = AXI_SLAVE_S_XSPI_AWCACHE;
  assign xspi_req_raw.aw.prot = AXI_SLAVE_S_XSPI_AWPROT;
  assign xspi_req_raw.aw.qos = AXI_SLAVE_S_XSPI_AWQOS;
  assign xspi_req_raw.aw.region = '0;
  assign xspi_req_raw.aw.atop   = '0;
  assign xspi_req_raw.aw.user   = '0;
  assign xspi_req_raw.aw_valid  = AXI_SLAVE_S_XSPI_AWVALID;
  assign xspi_req_raw.w.data = AXI_SLAVE_S_XSPI_WDATA;
  assign xspi_req_raw.w.strb = AXI_SLAVE_S_XSPI_WSTRB;
  assign xspi_req_raw.w.last = AXI_SLAVE_S_XSPI_WLAST;
  assign xspi_req_raw.w.user   = '0;
  assign xspi_req_raw.w_valid  = AXI_SLAVE_S_XSPI_WVALID;
  assign xspi_req_raw.b_ready  = AXI_SLAVE_S_XSPI_BREADY;
  assign xspi_req_raw.ar.id = {7'b0, AXI_SLAVE_S_XSPI_ARID};
  assign xspi_req_raw.ar.addr = AXI_SLAVE_S_XSPI_ARADDR;
  assign xspi_req_raw.ar.len = AXI_SLAVE_S_XSPI_ARLEN;
  assign xspi_req_raw.ar.size = AXI_SLAVE_S_XSPI_ARSIZE;
  assign xspi_req_raw.ar.burst = AXI_SLAVE_S_XSPI_ARBURST;
  assign xspi_req_raw.ar.lock = AXI_SLAVE_S_XSPI_ARLOCK;
  assign xspi_req_raw.ar.cache = AXI_SLAVE_S_XSPI_ARCACHE;
  assign xspi_req_raw.ar.prot = AXI_SLAVE_S_XSPI_ARPROT;
  assign xspi_req_raw.ar.qos = AXI_SLAVE_S_XSPI_ARQOS;
  assign xspi_req_raw.ar.region = '0;
  assign xspi_req_raw.ar.user   = '0;
  assign xspi_req_raw.ar_valid  = AXI_SLAVE_S_XSPI_ARVALID;
  assign xspi_req_raw.r_ready   = AXI_SLAVE_S_XSPI_RREADY;
  assign AXI_SLAVE_S_XSPI_AWREADY = xspi_resp.aw_ready;
  assign AXI_SLAVE_S_XSPI_WREADY  = xspi_resp.w_ready;
  assign AXI_SLAVE_S_XSPI_BID     = xspi_resp.b.id[1-1:0];
  assign AXI_SLAVE_S_XSPI_BRESP   = xspi_resp.b.resp;
  assign AXI_SLAVE_S_XSPI_BVALID  = xspi_resp.b_valid;
  assign AXI_SLAVE_S_XSPI_ARREADY = xspi_resp.ar_ready;
  assign AXI_SLAVE_S_XSPI_RID     = xspi_resp.r.id[1-1:0];
  assign AXI_SLAVE_S_XSPI_RDATA   = xspi_resp.r.data;
  assign AXI_SLAVE_S_XSPI_RRESP   = xspi_resp.r.resp;
  assign AXI_SLAVE_S_XSPI_RLAST   = xspi_resp.r.last;
  assign AXI_SLAVE_S_XSPI_RVALID  = xspi_resp.r_valid;

  erbium_noc_axi_cdc #(
    .aw_chan_t(xs_aw_chan_t), .w_chan_t(xs_w_chan_t), .b_chan_t(xs_b_chan_t),
    .ar_chan_t(xs_ar_chan_t), .r_chan_t(xs_r_chan_t),
    .axi_req_t(xs_req_t), .axi_resp_t(xs_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_xspi_cdc (
    .src_clk_i(clk_xspi), .src_rst_ni(rstn_xspi), .src_req_i(xspi_req_raw), .src_resp_o(xspi_resp),
    .dst_clk_i(clk_cpu), .dst_rst_ni(rstn_cpu), .dst_req_o(xspi_req_cpu), .dst_resp_i(xspi_resp_cpu)
  );

  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(64), .AxiMstPortDataWidth(512),
    .AxiAddrWidth(32), .AxiIdWidth(8),
    .aw_chan_t(axs_aw_chan_t), .mst_w_chan_t(axs_w_chan_t), .slv_w_chan_t(xs_w_chan_t),
    .b_chan_t(axs_b_chan_t), .ar_chan_t(axs_ar_chan_t),
    .mst_r_chan_t(axs_r_chan_t), .slv_r_chan_t(xs_r_chan_t),
    .axi_mst_req_t(axs_req_t), .axi_mst_resp_t(axs_resp_t),
    .axi_slv_req_t(xs_req_t), .axi_slv_resp_t(xs_resp_t)
  ) i_xspi_upsize (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(xspi_req_cpu), .slv_resp_o(xspi_resp_cpu),
    .mst_req_o(xspi_req_up), .mst_resp_i(xspi_resp_up)
  );

  function automatic logic [31:0] xspi_remap(logic [31:0] a);
    if (a < 32'h4000_0000)            xspi_remap = a + 32'h4000_0000; // MRAM
    else if (a < 32'h8000_0000)       xspi_remap = a - 32'h3E00_0000; // periph window
    else                              xspi_remap = a;                 // cpu_reg / cfg
  endfunction
  always_comb begin
    xspi_req = xspi_req_up;
    xspi_req.aw.addr = xspi_remap(xspi_req_up.aw.addr);
    xspi_req.ar.addr = xspi_remap(xspi_req_up.ar.addr);
  end
  assign xspi_resp_up = slv_resp[1];
  assign cpu_resp     = slv_resp[0];
  assign slv_req[0]   = cpu_req;
  assign slv_req[1]   = xspi_req;

  assign addr_map[0] = '{idx:32'd0, start_addr:32'h40000000, end_addr:32'h80000000}; // M_MRAM
  assign addr_map[1] = '{idx:32'd1, start_addr:32'h80000000, end_addr:32'hC0000000}; // M_CPU_REG
  assign addr_map[2] = '{idx:32'd2, start_addr:32'h02000000, end_addr:32'h02001000}; // M_SYSTEM_REG
  assign addr_map[3] = '{idx:32'd3, start_addr:32'h02001000, end_addr:32'h02002000}; // M_MRAM_REG
  assign addr_map[4] = '{idx:32'd4, start_addr:32'h02003000, end_addr:32'h02004000}; // M_SPI_REG
  assign addr_map[5] = '{idx:32'd5, start_addr:32'h02004000, end_addr:32'h02005000}; // M_UART_REG
  assign addr_map[6] = '{idx:32'd6, start_addr:32'h02008000, end_addr:32'h0200D000}; // M_SRAM
  assign addr_map[7] = '{idx:32'd7, start_addr:32'h0200F000, end_addr:32'h02010000}; // M_XSPI
  assign addr_map[8] = '{idx:32'd8, start_addr:32'h02002000, end_addr:32'h02003000}; // M_I2C_REG
  assign addr_map[9] = '{idx:32'd9, start_addr:32'hFE00_0000, end_addr:32'hFE01_6000}; // GPV cfg

  localparam erbium_noc_axi_pkg::xbar_cfg_t Cfg = '{
    NoSlvPorts:32'd2, NoMstPorts:32'd10, MaxMstTrans:32'd8, MaxSlvTrans:32'd8,
    FallThrough:1'b0, LatencyMode:erbium_noc_axi_pkg::CUT_ALL_AX, PipelineStages:32'd0,
    AxiIdWidthSlvPorts:32'd8, AxiIdUsedSlvPorts:32'd8, UniqueIds:1'b0,
    AxiAddrWidth:32'd32, AxiDataWidth:32'd512, NoAddrRules:32'd10};
  erbium_noc_axi_xbar #(
    .Cfg(Cfg), .ATOPs(1'b0),
    .slv_aw_chan_t(axs_aw_chan_t), .mst_aw_chan_t(axm_aw_chan_t),
    .w_chan_t(axs_w_chan_t),
    .slv_b_chan_t(axs_b_chan_t), .mst_b_chan_t(axm_b_chan_t),
    .slv_ar_chan_t(axs_ar_chan_t), .mst_ar_chan_t(axm_ar_chan_t),
    .slv_r_chan_t(axs_r_chan_t), .mst_r_chan_t(axm_r_chan_t),
    .slv_req_t(axs_req_t), .slv_resp_t(axs_resp_t),
    .mst_req_t(axm_req_t), .mst_resp_t(axm_resp_t),
    .rule_t(rule_t)
  ) i_xbar (
    .clk_i(clk), .rst_ni(rst_n), .test_i(1'b0),
    .slv_ports_req_i(slv_req), .slv_ports_resp_o(slv_resp),
    .mst_ports_req_o(mst_req), .mst_ports_resp_i(mst_resp),
    .addr_map_i(addr_map), .en_default_mst_port_i('0), .default_mst_port_i('0)
  );

  // ---- leg 0: M_MRAM (axi, 512b, CPU domain) ----
  axm_req_t  m0_mon_req; axm_resp_t m0_mon_resp;
  erbium_noc_excl_monitor #(.req_t(axm_req_t), .resp_t(axm_resp_t), .AW(32)) i_excl_0 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[0]), .slv_resp_o(mst_resp[0]),
    .mst_req_o(m0_mon_req), .mst_resp_i(m0_mon_resp)
  );
  assign AXI_MASTER_M_MRAM_AWID = m0_mon_req.aw.id;
  assign AXI_MASTER_M_MRAM_AWADDR = m0_mon_req.aw.addr;
  assign AXI_MASTER_M_MRAM_AWLEN = m0_mon_req.aw.len;
  assign AXI_MASTER_M_MRAM_AWSIZE = m0_mon_req.aw.size;
  assign AXI_MASTER_M_MRAM_AWBURST = m0_mon_req.aw.burst;
  assign AXI_MASTER_M_MRAM_AWLOCK = m0_mon_req.aw.lock;
  assign AXI_MASTER_M_MRAM_AWCACHE = m0_mon_req.aw.cache;
  assign AXI_MASTER_M_MRAM_AWPROT = m0_mon_req.aw.prot;
  assign AXI_MASTER_M_MRAM_AWQOS = m0_mon_req.aw.qos;
  assign AXI_MASTER_M_MRAM_AWVALID = m0_mon_req.aw_valid;
  assign AXI_MASTER_M_MRAM_WDATA = m0_mon_req.w.data;
  assign AXI_MASTER_M_MRAM_WSTRB = m0_mon_req.w.strb;
  assign AXI_MASTER_M_MRAM_WLAST = m0_mon_req.w.last;
  assign AXI_MASTER_M_MRAM_WVALID = m0_mon_req.w_valid;
  assign AXI_MASTER_M_MRAM_BREADY = m0_mon_req.b_ready;
  assign AXI_MASTER_M_MRAM_ARID = m0_mon_req.ar.id;
  assign AXI_MASTER_M_MRAM_ARADDR = m0_mon_req.ar.addr;
  assign AXI_MASTER_M_MRAM_ARLEN = m0_mon_req.ar.len;
  assign AXI_MASTER_M_MRAM_ARSIZE = m0_mon_req.ar.size;
  assign AXI_MASTER_M_MRAM_ARBURST = m0_mon_req.ar.burst;
  assign AXI_MASTER_M_MRAM_ARLOCK = m0_mon_req.ar.lock;
  assign AXI_MASTER_M_MRAM_ARCACHE = m0_mon_req.ar.cache;
  assign AXI_MASTER_M_MRAM_ARPROT = m0_mon_req.ar.prot;
  assign AXI_MASTER_M_MRAM_ARQOS = m0_mon_req.ar.qos;
  assign AXI_MASTER_M_MRAM_ARVALID = m0_mon_req.ar_valid;
  assign AXI_MASTER_M_MRAM_RREADY = m0_mon_req.r_ready;
  assign m0_mon_resp.aw_ready = AXI_MASTER_M_MRAM_AWREADY;
  assign m0_mon_resp.w_ready  = AXI_MASTER_M_MRAM_WREADY;
  assign m0_mon_resp.b.id     = AXI_MASTER_M_MRAM_BID;
  assign m0_mon_resp.b.resp   = AXI_MASTER_M_MRAM_BRESP;
  assign m0_mon_resp.b.user   = '0;
  assign m0_mon_resp.b_valid  = AXI_MASTER_M_MRAM_BVALID;
  assign m0_mon_resp.ar_ready = AXI_MASTER_M_MRAM_ARREADY;
  assign m0_mon_resp.r.id     = AXI_MASTER_M_MRAM_RID;
  assign m0_mon_resp.r.data   = AXI_MASTER_M_MRAM_RDATA;
  assign m0_mon_resp.r.resp   = AXI_MASTER_M_MRAM_RRESP;
  assign m0_mon_resp.r.last   = AXI_MASTER_M_MRAM_RLAST;
  assign m0_mon_resp.r.user   = '0;
  assign m0_mon_resp.r_valid  = AXI_MASTER_M_MRAM_RVALID;

  // ---- leg 1: M_CPU_REG (axi, 64b, CPU domain) ----
  d64_req_t  m1_req; d64_resp_t m1_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_1 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[1]), .slv_resp_o(mst_resp[1]),
    .mst_req_o(m1_req), .mst_resp_i(m1_resp)
  );
  assign AXI_MASTER_M_CPU_REG_AWID = m1_req.aw.id;
  assign AXI_MASTER_M_CPU_REG_AWADDR = m1_req.aw.addr;
  assign AXI_MASTER_M_CPU_REG_AWLEN = m1_req.aw.len;
  assign AXI_MASTER_M_CPU_REG_AWSIZE = m1_req.aw.size;
  assign AXI_MASTER_M_CPU_REG_AWBURST = m1_req.aw.burst;
  assign AXI_MASTER_M_CPU_REG_AWLOCK = m1_req.aw.lock;
  assign AXI_MASTER_M_CPU_REG_AWCACHE = m1_req.aw.cache;
  assign AXI_MASTER_M_CPU_REG_AWPROT = m1_req.aw.prot;
  assign AXI_MASTER_M_CPU_REG_AWQOS = m1_req.aw.qos;
  assign AXI_MASTER_M_CPU_REG_AWVALID = m1_req.aw_valid;
  assign AXI_MASTER_M_CPU_REG_WDATA = m1_req.w.data;
  assign AXI_MASTER_M_CPU_REG_WSTRB = m1_req.w.strb;
  assign AXI_MASTER_M_CPU_REG_WLAST = m1_req.w.last;
  assign AXI_MASTER_M_CPU_REG_WVALID = m1_req.w_valid;
  assign AXI_MASTER_M_CPU_REG_BREADY = m1_req.b_ready;
  assign AXI_MASTER_M_CPU_REG_ARID = m1_req.ar.id;
  assign AXI_MASTER_M_CPU_REG_ARADDR = m1_req.ar.addr;
  assign AXI_MASTER_M_CPU_REG_ARLEN = m1_req.ar.len;
  assign AXI_MASTER_M_CPU_REG_ARSIZE = m1_req.ar.size;
  assign AXI_MASTER_M_CPU_REG_ARBURST = m1_req.ar.burst;
  assign AXI_MASTER_M_CPU_REG_ARLOCK = m1_req.ar.lock;
  assign AXI_MASTER_M_CPU_REG_ARCACHE = m1_req.ar.cache;
  assign AXI_MASTER_M_CPU_REG_ARPROT = m1_req.ar.prot;
  assign AXI_MASTER_M_CPU_REG_ARQOS = m1_req.ar.qos;
  assign AXI_MASTER_M_CPU_REG_ARVALID = m1_req.ar_valid;
  assign AXI_MASTER_M_CPU_REG_RREADY = m1_req.r_ready;
  assign m1_resp.aw_ready = AXI_MASTER_M_CPU_REG_AWREADY;
  assign m1_resp.w_ready  = AXI_MASTER_M_CPU_REG_WREADY;
  assign m1_resp.b.id     = AXI_MASTER_M_CPU_REG_BID;
  assign m1_resp.b.resp   = AXI_MASTER_M_CPU_REG_BRESP;
  assign m1_resp.b.user   = '0;
  assign m1_resp.b_valid  = AXI_MASTER_M_CPU_REG_BVALID;
  assign m1_resp.ar_ready = AXI_MASTER_M_CPU_REG_ARREADY;
  assign m1_resp.r.id     = AXI_MASTER_M_CPU_REG_RID;
  assign m1_resp.r.data   = AXI_MASTER_M_CPU_REG_RDATA;
  assign m1_resp.r.resp   = AXI_MASTER_M_CPU_REG_RRESP;
  assign m1_resp.r.last   = AXI_MASTER_M_CPU_REG_RLAST;
  assign m1_resp.r.user   = '0;
  assign m1_resp.r_valid  = AXI_MASTER_M_CPU_REG_RVALID;

  // ---- leg 2: M_SYSTEM_REG (axi, 64b, SYSTEM domain) ----
  d64_req_t  m2_req; d64_resp_t m2_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_2 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[2]), .slv_resp_o(mst_resp[2]),
    .mst_req_o(m2_req), .mst_resp_i(m2_resp)
  );
  d64_req_t  m2_cdc_req; d64_resp_t m2_cdc_resp;
  erbium_noc_axi_cdc #(
    .aw_chan_t(d64_aw_chan_t), .w_chan_t(d64_w_chan_t), .b_chan_t(d64_b_chan_t),
    .ar_chan_t(d64_ar_chan_t), .r_chan_t(d64_r_chan_t),
    .axi_req_t(d64_req_t), .axi_resp_t(d64_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_2 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m2_req), .src_resp_o(m2_resp),
    .dst_clk_i(clk_sys), .dst_rst_ni(rstn_sys), .dst_req_o(m2_cdc_req), .dst_resp_i(m2_cdc_resp)
  );
  assign AXI_MASTER_M_SYSTEM_REG_AWID = m2_cdc_req.aw.id;
  assign AXI_MASTER_M_SYSTEM_REG_AWADDR = m2_cdc_req.aw.addr;
  assign AXI_MASTER_M_SYSTEM_REG_AWLEN = m2_cdc_req.aw.len;
  assign AXI_MASTER_M_SYSTEM_REG_AWSIZE = m2_cdc_req.aw.size;
  assign AXI_MASTER_M_SYSTEM_REG_AWBURST = m2_cdc_req.aw.burst;
  assign AXI_MASTER_M_SYSTEM_REG_AWLOCK = m2_cdc_req.aw.lock;
  assign AXI_MASTER_M_SYSTEM_REG_AWCACHE = m2_cdc_req.aw.cache;
  assign AXI_MASTER_M_SYSTEM_REG_AWPROT = m2_cdc_req.aw.prot;
  assign AXI_MASTER_M_SYSTEM_REG_AWQOS = m2_cdc_req.aw.qos;
  assign AXI_MASTER_M_SYSTEM_REG_AWVALID = m2_cdc_req.aw_valid;
  assign AXI_MASTER_M_SYSTEM_REG_WDATA = m2_cdc_req.w.data;
  assign AXI_MASTER_M_SYSTEM_REG_WSTRB = m2_cdc_req.w.strb;
  assign AXI_MASTER_M_SYSTEM_REG_WLAST = m2_cdc_req.w.last;
  assign AXI_MASTER_M_SYSTEM_REG_WVALID = m2_cdc_req.w_valid;
  assign AXI_MASTER_M_SYSTEM_REG_BREADY = m2_cdc_req.b_ready;
  assign AXI_MASTER_M_SYSTEM_REG_ARID = m2_cdc_req.ar.id;
  assign AXI_MASTER_M_SYSTEM_REG_ARADDR = m2_cdc_req.ar.addr;
  assign AXI_MASTER_M_SYSTEM_REG_ARLEN = m2_cdc_req.ar.len;
  assign AXI_MASTER_M_SYSTEM_REG_ARSIZE = m2_cdc_req.ar.size;
  assign AXI_MASTER_M_SYSTEM_REG_ARBURST = m2_cdc_req.ar.burst;
  assign AXI_MASTER_M_SYSTEM_REG_ARLOCK = m2_cdc_req.ar.lock;
  assign AXI_MASTER_M_SYSTEM_REG_ARCACHE = m2_cdc_req.ar.cache;
  assign AXI_MASTER_M_SYSTEM_REG_ARPROT = m2_cdc_req.ar.prot;
  assign AXI_MASTER_M_SYSTEM_REG_ARQOS = m2_cdc_req.ar.qos;
  assign AXI_MASTER_M_SYSTEM_REG_ARVALID = m2_cdc_req.ar_valid;
  assign AXI_MASTER_M_SYSTEM_REG_RREADY = m2_cdc_req.r_ready;
  assign m2_cdc_resp.aw_ready = AXI_MASTER_M_SYSTEM_REG_AWREADY;
  assign m2_cdc_resp.w_ready  = AXI_MASTER_M_SYSTEM_REG_WREADY;
  assign m2_cdc_resp.b.id     = AXI_MASTER_M_SYSTEM_REG_BID;
  assign m2_cdc_resp.b.resp   = AXI_MASTER_M_SYSTEM_REG_BRESP;
  assign m2_cdc_resp.b.user   = '0;
  assign m2_cdc_resp.b_valid  = AXI_MASTER_M_SYSTEM_REG_BVALID;
  assign m2_cdc_resp.ar_ready = AXI_MASTER_M_SYSTEM_REG_ARREADY;
  assign m2_cdc_resp.r.id     = AXI_MASTER_M_SYSTEM_REG_RID;
  assign m2_cdc_resp.r.data   = AXI_MASTER_M_SYSTEM_REG_RDATA;
  assign m2_cdc_resp.r.resp   = AXI_MASTER_M_SYSTEM_REG_RRESP;
  assign m2_cdc_resp.r.last   = AXI_MASTER_M_SYSTEM_REG_RLAST;
  assign m2_cdc_resp.r.user   = '0;
  assign m2_cdc_resp.r_valid  = AXI_MASTER_M_SYSTEM_REG_RVALID;

  // ---- leg 3: M_MRAM_REG (axi, 64b, CPU domain) ----
  d64_req_t  m3_req; d64_resp_t m3_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_3 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[3]), .slv_resp_o(mst_resp[3]),
    .mst_req_o(m3_req), .mst_resp_i(m3_resp)
  );
  assign AXI_MASTER_M_MRAM_REG_AWID = m3_req.aw.id;
  assign AXI_MASTER_M_MRAM_REG_AWADDR = m3_req.aw.addr;
  assign AXI_MASTER_M_MRAM_REG_AWLEN = m3_req.aw.len;
  assign AXI_MASTER_M_MRAM_REG_AWSIZE = m3_req.aw.size;
  assign AXI_MASTER_M_MRAM_REG_AWBURST = m3_req.aw.burst;
  assign AXI_MASTER_M_MRAM_REG_AWLOCK = m3_req.aw.lock;
  assign AXI_MASTER_M_MRAM_REG_AWCACHE = m3_req.aw.cache;
  assign AXI_MASTER_M_MRAM_REG_AWPROT = m3_req.aw.prot;
  assign AXI_MASTER_M_MRAM_REG_AWQOS = m3_req.aw.qos;
  assign AXI_MASTER_M_MRAM_REG_AWVALID = m3_req.aw_valid;
  assign AXI_MASTER_M_MRAM_REG_WDATA = m3_req.w.data;
  assign AXI_MASTER_M_MRAM_REG_WSTRB = m3_req.w.strb;
  assign AXI_MASTER_M_MRAM_REG_WLAST = m3_req.w.last;
  assign AXI_MASTER_M_MRAM_REG_WVALID = m3_req.w_valid;
  assign AXI_MASTER_M_MRAM_REG_BREADY = m3_req.b_ready;
  assign AXI_MASTER_M_MRAM_REG_ARID = m3_req.ar.id;
  assign AXI_MASTER_M_MRAM_REG_ARADDR = m3_req.ar.addr;
  assign AXI_MASTER_M_MRAM_REG_ARLEN = m3_req.ar.len;
  assign AXI_MASTER_M_MRAM_REG_ARSIZE = m3_req.ar.size;
  assign AXI_MASTER_M_MRAM_REG_ARBURST = m3_req.ar.burst;
  assign AXI_MASTER_M_MRAM_REG_ARLOCK = m3_req.ar.lock;
  assign AXI_MASTER_M_MRAM_REG_ARCACHE = m3_req.ar.cache;
  assign AXI_MASTER_M_MRAM_REG_ARPROT = m3_req.ar.prot;
  assign AXI_MASTER_M_MRAM_REG_ARQOS = m3_req.ar.qos;
  assign AXI_MASTER_M_MRAM_REG_ARVALID = m3_req.ar_valid;
  assign AXI_MASTER_M_MRAM_REG_RREADY = m3_req.r_ready;
  assign m3_resp.aw_ready = AXI_MASTER_M_MRAM_REG_AWREADY;
  assign m3_resp.w_ready  = AXI_MASTER_M_MRAM_REG_WREADY;
  assign m3_resp.b.id     = AXI_MASTER_M_MRAM_REG_BID;
  assign m3_resp.b.resp   = AXI_MASTER_M_MRAM_REG_BRESP;
  assign m3_resp.b.user   = '0;
  assign m3_resp.b_valid  = AXI_MASTER_M_MRAM_REG_BVALID;
  assign m3_resp.ar_ready = AXI_MASTER_M_MRAM_REG_ARREADY;
  assign m3_resp.r.id     = AXI_MASTER_M_MRAM_REG_RID;
  assign m3_resp.r.data   = AXI_MASTER_M_MRAM_REG_RDATA;
  assign m3_resp.r.resp   = AXI_MASTER_M_MRAM_REG_RRESP;
  assign m3_resp.r.last   = AXI_MASTER_M_MRAM_REG_RLAST;
  assign m3_resp.r.user   = '0;
  assign m3_resp.r_valid  = AXI_MASTER_M_MRAM_REG_RVALID;

  // ---- leg 4: M_SPI_REG (axi, 64b, PERIPH domain) ----
  d64_req_t  m4_req; d64_resp_t m4_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_4 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[4]), .slv_resp_o(mst_resp[4]),
    .mst_req_o(m4_req), .mst_resp_i(m4_resp)
  );
  d64_req_t  m4_cdc_req; d64_resp_t m4_cdc_resp;
  erbium_noc_axi_cdc #(
    .aw_chan_t(d64_aw_chan_t), .w_chan_t(d64_w_chan_t), .b_chan_t(d64_b_chan_t),
    .ar_chan_t(d64_ar_chan_t), .r_chan_t(d64_r_chan_t),
    .axi_req_t(d64_req_t), .axi_resp_t(d64_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_4 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m4_req), .src_resp_o(m4_resp),
    .dst_clk_i(clk_periph), .dst_rst_ni(rstn_periph), .dst_req_o(m4_cdc_req), .dst_resp_i(m4_cdc_resp)
  );
  assign AXI_MASTER_M_SPI_REG_AWID = m4_cdc_req.aw.id;
  assign AXI_MASTER_M_SPI_REG_AWADDR = m4_cdc_req.aw.addr;
  assign AXI_MASTER_M_SPI_REG_AWLEN = m4_cdc_req.aw.len;
  assign AXI_MASTER_M_SPI_REG_AWSIZE = m4_cdc_req.aw.size;
  assign AXI_MASTER_M_SPI_REG_AWBURST = m4_cdc_req.aw.burst;
  assign AXI_MASTER_M_SPI_REG_AWLOCK = m4_cdc_req.aw.lock;
  assign AXI_MASTER_M_SPI_REG_AWCACHE = m4_cdc_req.aw.cache;
  assign AXI_MASTER_M_SPI_REG_AWPROT = m4_cdc_req.aw.prot;
  assign AXI_MASTER_M_SPI_REG_AWQOS = m4_cdc_req.aw.qos;
  assign AXI_MASTER_M_SPI_REG_AWVALID = m4_cdc_req.aw_valid;
  assign AXI_MASTER_M_SPI_REG_WDATA = m4_cdc_req.w.data;
  assign AXI_MASTER_M_SPI_REG_WSTRB = m4_cdc_req.w.strb;
  assign AXI_MASTER_M_SPI_REG_WLAST = m4_cdc_req.w.last;
  assign AXI_MASTER_M_SPI_REG_WVALID = m4_cdc_req.w_valid;
  assign AXI_MASTER_M_SPI_REG_BREADY = m4_cdc_req.b_ready;
  assign AXI_MASTER_M_SPI_REG_ARID = m4_cdc_req.ar.id;
  assign AXI_MASTER_M_SPI_REG_ARADDR = m4_cdc_req.ar.addr;
  assign AXI_MASTER_M_SPI_REG_ARLEN = m4_cdc_req.ar.len;
  assign AXI_MASTER_M_SPI_REG_ARSIZE = m4_cdc_req.ar.size;
  assign AXI_MASTER_M_SPI_REG_ARBURST = m4_cdc_req.ar.burst;
  assign AXI_MASTER_M_SPI_REG_ARLOCK = m4_cdc_req.ar.lock;
  assign AXI_MASTER_M_SPI_REG_ARCACHE = m4_cdc_req.ar.cache;
  assign AXI_MASTER_M_SPI_REG_ARPROT = m4_cdc_req.ar.prot;
  assign AXI_MASTER_M_SPI_REG_ARQOS = m4_cdc_req.ar.qos;
  assign AXI_MASTER_M_SPI_REG_ARVALID = m4_cdc_req.ar_valid;
  assign AXI_MASTER_M_SPI_REG_RREADY = m4_cdc_req.r_ready;
  assign m4_cdc_resp.aw_ready = AXI_MASTER_M_SPI_REG_AWREADY;
  assign m4_cdc_resp.w_ready  = AXI_MASTER_M_SPI_REG_WREADY;
  assign m4_cdc_resp.b.id     = AXI_MASTER_M_SPI_REG_BID;
  assign m4_cdc_resp.b.resp   = AXI_MASTER_M_SPI_REG_BRESP;
  assign m4_cdc_resp.b.user   = '0;
  assign m4_cdc_resp.b_valid  = AXI_MASTER_M_SPI_REG_BVALID;
  assign m4_cdc_resp.ar_ready = AXI_MASTER_M_SPI_REG_ARREADY;
  assign m4_cdc_resp.r.id     = AXI_MASTER_M_SPI_REG_RID;
  assign m4_cdc_resp.r.data   = AXI_MASTER_M_SPI_REG_RDATA;
  assign m4_cdc_resp.r.resp   = AXI_MASTER_M_SPI_REG_RRESP;
  assign m4_cdc_resp.r.last   = AXI_MASTER_M_SPI_REG_RLAST;
  assign m4_cdc_resp.r.user   = '0;
  assign m4_cdc_resp.r_valid  = AXI_MASTER_M_SPI_REG_RVALID;

  // ---- leg 5: M_UART_REG (axi, 64b, PERIPH domain) ----
  d64_req_t  m5_req; d64_resp_t m5_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_5 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[5]), .slv_resp_o(mst_resp[5]),
    .mst_req_o(m5_req), .mst_resp_i(m5_resp)
  );
  d64_req_t  m5_cdc_req; d64_resp_t m5_cdc_resp;
  erbium_noc_axi_cdc #(
    .aw_chan_t(d64_aw_chan_t), .w_chan_t(d64_w_chan_t), .b_chan_t(d64_b_chan_t),
    .ar_chan_t(d64_ar_chan_t), .r_chan_t(d64_r_chan_t),
    .axi_req_t(d64_req_t), .axi_resp_t(d64_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_5 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m5_req), .src_resp_o(m5_resp),
    .dst_clk_i(clk_periph), .dst_rst_ni(rstn_periph), .dst_req_o(m5_cdc_req), .dst_resp_i(m5_cdc_resp)
  );
  assign AXI_MASTER_M_UART_REG_AWID = m5_cdc_req.aw.id;
  assign AXI_MASTER_M_UART_REG_AWADDR = m5_cdc_req.aw.addr;
  assign AXI_MASTER_M_UART_REG_AWLEN = m5_cdc_req.aw.len;
  assign AXI_MASTER_M_UART_REG_AWSIZE = m5_cdc_req.aw.size;
  assign AXI_MASTER_M_UART_REG_AWBURST = m5_cdc_req.aw.burst;
  assign AXI_MASTER_M_UART_REG_AWLOCK = m5_cdc_req.aw.lock;
  assign AXI_MASTER_M_UART_REG_AWCACHE = m5_cdc_req.aw.cache;
  assign AXI_MASTER_M_UART_REG_AWPROT = m5_cdc_req.aw.prot;
  assign AXI_MASTER_M_UART_REG_AWQOS = m5_cdc_req.aw.qos;
  assign AXI_MASTER_M_UART_REG_AWVALID = m5_cdc_req.aw_valid;
  assign AXI_MASTER_M_UART_REG_WDATA = m5_cdc_req.w.data;
  assign AXI_MASTER_M_UART_REG_WSTRB = m5_cdc_req.w.strb;
  assign AXI_MASTER_M_UART_REG_WLAST = m5_cdc_req.w.last;
  assign AXI_MASTER_M_UART_REG_WVALID = m5_cdc_req.w_valid;
  assign AXI_MASTER_M_UART_REG_BREADY = m5_cdc_req.b_ready;
  assign AXI_MASTER_M_UART_REG_ARID = m5_cdc_req.ar.id;
  assign AXI_MASTER_M_UART_REG_ARADDR = m5_cdc_req.ar.addr;
  assign AXI_MASTER_M_UART_REG_ARLEN = m5_cdc_req.ar.len;
  assign AXI_MASTER_M_UART_REG_ARSIZE = m5_cdc_req.ar.size;
  assign AXI_MASTER_M_UART_REG_ARBURST = m5_cdc_req.ar.burst;
  assign AXI_MASTER_M_UART_REG_ARLOCK = m5_cdc_req.ar.lock;
  assign AXI_MASTER_M_UART_REG_ARCACHE = m5_cdc_req.ar.cache;
  assign AXI_MASTER_M_UART_REG_ARPROT = m5_cdc_req.ar.prot;
  assign AXI_MASTER_M_UART_REG_ARQOS = m5_cdc_req.ar.qos;
  assign AXI_MASTER_M_UART_REG_ARVALID = m5_cdc_req.ar_valid;
  assign AXI_MASTER_M_UART_REG_RREADY = m5_cdc_req.r_ready;
  assign m5_cdc_resp.aw_ready = AXI_MASTER_M_UART_REG_AWREADY;
  assign m5_cdc_resp.w_ready  = AXI_MASTER_M_UART_REG_WREADY;
  assign m5_cdc_resp.b.id     = AXI_MASTER_M_UART_REG_BID;
  assign m5_cdc_resp.b.resp   = AXI_MASTER_M_UART_REG_BRESP;
  assign m5_cdc_resp.b.user   = '0;
  assign m5_cdc_resp.b_valid  = AXI_MASTER_M_UART_REG_BVALID;
  assign m5_cdc_resp.ar_ready = AXI_MASTER_M_UART_REG_ARREADY;
  assign m5_cdc_resp.r.id     = AXI_MASTER_M_UART_REG_RID;
  assign m5_cdc_resp.r.data   = AXI_MASTER_M_UART_REG_RDATA;
  assign m5_cdc_resp.r.resp   = AXI_MASTER_M_UART_REG_RRESP;
  assign m5_cdc_resp.r.last   = AXI_MASTER_M_UART_REG_RLAST;
  assign m5_cdc_resp.r.user   = '0;
  assign m5_cdc_resp.r_valid  = AXI_MASTER_M_UART_REG_RVALID;

  // ---- leg 6: M_SRAM (axi, 64b, SYSTEM domain) ----
  axm_req_t  m6_mon_req; axm_resp_t m6_mon_resp;
  erbium_noc_excl_monitor #(.req_t(axm_req_t), .resp_t(axm_resp_t), .AW(32)) i_excl_6 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[6]), .slv_resp_o(mst_resp[6]),
    .mst_req_o(m6_mon_req), .mst_resp_i(m6_mon_resp)
  );
  d64_req_t  m6_req; d64_resp_t m6_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_6 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(m6_mon_req), .slv_resp_o(m6_mon_resp),
    .mst_req_o(m6_req), .mst_resp_i(m6_resp)
  );
  d64_req_t  m6_cdc_req; d64_resp_t m6_cdc_resp;
  erbium_noc_axi_cdc #(
    .aw_chan_t(d64_aw_chan_t), .w_chan_t(d64_w_chan_t), .b_chan_t(d64_b_chan_t),
    .ar_chan_t(d64_ar_chan_t), .r_chan_t(d64_r_chan_t),
    .axi_req_t(d64_req_t), .axi_resp_t(d64_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_6 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m6_req), .src_resp_o(m6_resp),
    .dst_clk_i(clk_sys), .dst_rst_ni(rstn_sys), .dst_req_o(m6_cdc_req), .dst_resp_i(m6_cdc_resp)
  );
  assign AXI_MASTER_M_SRAM_AWID = m6_cdc_req.aw.id;
  assign AXI_MASTER_M_SRAM_AWADDR = m6_cdc_req.aw.addr;
  assign AXI_MASTER_M_SRAM_AWLEN = m6_cdc_req.aw.len;
  assign AXI_MASTER_M_SRAM_AWSIZE = m6_cdc_req.aw.size;
  assign AXI_MASTER_M_SRAM_AWBURST = m6_cdc_req.aw.burst;
  assign AXI_MASTER_M_SRAM_AWLOCK = m6_cdc_req.aw.lock;
  assign AXI_MASTER_M_SRAM_AWCACHE = m6_cdc_req.aw.cache;
  assign AXI_MASTER_M_SRAM_AWPROT = m6_cdc_req.aw.prot;
  assign AXI_MASTER_M_SRAM_AWQOS = m6_cdc_req.aw.qos;
  assign AXI_MASTER_M_SRAM_AWVALID = m6_cdc_req.aw_valid;
  assign AXI_MASTER_M_SRAM_WDATA = m6_cdc_req.w.data;
  assign AXI_MASTER_M_SRAM_WSTRB = m6_cdc_req.w.strb;
  assign AXI_MASTER_M_SRAM_WLAST = m6_cdc_req.w.last;
  assign AXI_MASTER_M_SRAM_WVALID = m6_cdc_req.w_valid;
  assign AXI_MASTER_M_SRAM_BREADY = m6_cdc_req.b_ready;
  assign AXI_MASTER_M_SRAM_ARID = m6_cdc_req.ar.id;
  assign AXI_MASTER_M_SRAM_ARADDR = m6_cdc_req.ar.addr;
  assign AXI_MASTER_M_SRAM_ARLEN = m6_cdc_req.ar.len;
  assign AXI_MASTER_M_SRAM_ARSIZE = m6_cdc_req.ar.size;
  assign AXI_MASTER_M_SRAM_ARBURST = m6_cdc_req.ar.burst;
  assign AXI_MASTER_M_SRAM_ARLOCK = m6_cdc_req.ar.lock;
  assign AXI_MASTER_M_SRAM_ARCACHE = m6_cdc_req.ar.cache;
  assign AXI_MASTER_M_SRAM_ARPROT = m6_cdc_req.ar.prot;
  assign AXI_MASTER_M_SRAM_ARQOS = m6_cdc_req.ar.qos;
  assign AXI_MASTER_M_SRAM_ARVALID = m6_cdc_req.ar_valid;
  assign AXI_MASTER_M_SRAM_RREADY = m6_cdc_req.r_ready;
  assign m6_cdc_resp.aw_ready = AXI_MASTER_M_SRAM_AWREADY;
  assign m6_cdc_resp.w_ready  = AXI_MASTER_M_SRAM_WREADY;
  assign m6_cdc_resp.b.id     = AXI_MASTER_M_SRAM_BID;
  assign m6_cdc_resp.b.resp   = AXI_MASTER_M_SRAM_BRESP;
  assign m6_cdc_resp.b.user   = '0;
  assign m6_cdc_resp.b_valid  = AXI_MASTER_M_SRAM_BVALID;
  assign m6_cdc_resp.ar_ready = AXI_MASTER_M_SRAM_ARREADY;
  assign m6_cdc_resp.r.id     = AXI_MASTER_M_SRAM_RID;
  assign m6_cdc_resp.r.data   = AXI_MASTER_M_SRAM_RDATA;
  assign m6_cdc_resp.r.resp   = AXI_MASTER_M_SRAM_RRESP;
  assign m6_cdc_resp.r.last   = AXI_MASTER_M_SRAM_RLAST;
  assign m6_cdc_resp.r.user   = '0;
  assign m6_cdc_resp.r_valid  = AXI_MASTER_M_SRAM_RVALID;

  // ---- leg 7: M_XSPI (axi, 64b, XSPI domain) ----
  d64_req_t  m7_req; d64_resp_t m7_resp;
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(64),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d64_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d64_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d64_req_t), .axi_mst_resp_t(d64_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_7 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[7]), .slv_resp_o(mst_resp[7]),
    .mst_req_o(m7_req), .mst_resp_i(m7_resp)
  );
  d64_req_t  m7_cdc_req; d64_resp_t m7_cdc_resp;
  erbium_noc_axi_cdc #(
    .aw_chan_t(d64_aw_chan_t), .w_chan_t(d64_w_chan_t), .b_chan_t(d64_b_chan_t),
    .ar_chan_t(d64_ar_chan_t), .r_chan_t(d64_r_chan_t),
    .axi_req_t(d64_req_t), .axi_resp_t(d64_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_7 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m7_req), .src_resp_o(m7_resp),
    .dst_clk_i(clk_xspi), .dst_rst_ni(rstn_xspi), .dst_req_o(m7_cdc_req), .dst_resp_i(m7_cdc_resp)
  );
  assign AXI_MASTER_M_XSPI_AWID = m7_cdc_req.aw.id;
  assign AXI_MASTER_M_XSPI_AWADDR = m7_cdc_req.aw.addr;
  assign AXI_MASTER_M_XSPI_AWLEN = m7_cdc_req.aw.len;
  assign AXI_MASTER_M_XSPI_AWSIZE = m7_cdc_req.aw.size;
  assign AXI_MASTER_M_XSPI_AWBURST = m7_cdc_req.aw.burst;
  assign AXI_MASTER_M_XSPI_AWLOCK = m7_cdc_req.aw.lock;
  assign AXI_MASTER_M_XSPI_AWCACHE = m7_cdc_req.aw.cache;
  assign AXI_MASTER_M_XSPI_AWPROT = m7_cdc_req.aw.prot;
  assign AXI_MASTER_M_XSPI_AWQOS = m7_cdc_req.aw.qos;
  assign AXI_MASTER_M_XSPI_AWVALID = m7_cdc_req.aw_valid;
  assign AXI_MASTER_M_XSPI_WDATA = m7_cdc_req.w.data;
  assign AXI_MASTER_M_XSPI_WSTRB = m7_cdc_req.w.strb;
  assign AXI_MASTER_M_XSPI_WLAST = m7_cdc_req.w.last;
  assign AXI_MASTER_M_XSPI_WVALID = m7_cdc_req.w_valid;
  assign AXI_MASTER_M_XSPI_BREADY = m7_cdc_req.b_ready;
  assign AXI_MASTER_M_XSPI_ARID = m7_cdc_req.ar.id;
  assign AXI_MASTER_M_XSPI_ARADDR = m7_cdc_req.ar.addr;
  assign AXI_MASTER_M_XSPI_ARLEN = m7_cdc_req.ar.len;
  assign AXI_MASTER_M_XSPI_ARSIZE = m7_cdc_req.ar.size;
  assign AXI_MASTER_M_XSPI_ARBURST = m7_cdc_req.ar.burst;
  assign AXI_MASTER_M_XSPI_ARLOCK = m7_cdc_req.ar.lock;
  assign AXI_MASTER_M_XSPI_ARCACHE = m7_cdc_req.ar.cache;
  assign AXI_MASTER_M_XSPI_ARPROT = m7_cdc_req.ar.prot;
  assign AXI_MASTER_M_XSPI_ARQOS = m7_cdc_req.ar.qos;
  assign AXI_MASTER_M_XSPI_ARVALID = m7_cdc_req.ar_valid;
  assign AXI_MASTER_M_XSPI_RREADY = m7_cdc_req.r_ready;
  assign m7_cdc_resp.aw_ready = AXI_MASTER_M_XSPI_AWREADY;
  assign m7_cdc_resp.w_ready  = AXI_MASTER_M_XSPI_WREADY;
  assign m7_cdc_resp.b.id     = AXI_MASTER_M_XSPI_BID;
  assign m7_cdc_resp.b.resp   = AXI_MASTER_M_XSPI_BRESP;
  assign m7_cdc_resp.b.user   = '0;
  assign m7_cdc_resp.b_valid  = AXI_MASTER_M_XSPI_BVALID;
  assign m7_cdc_resp.ar_ready = AXI_MASTER_M_XSPI_ARREADY;
  assign m7_cdc_resp.r.id     = AXI_MASTER_M_XSPI_RID;
  assign m7_cdc_resp.r.data   = AXI_MASTER_M_XSPI_RDATA;
  assign m7_cdc_resp.r.resp   = AXI_MASTER_M_XSPI_RRESP;
  assign m7_cdc_resp.r.last   = AXI_MASTER_M_XSPI_RLAST;
  assign m7_cdc_resp.r.user   = '0;
  assign m7_cdc_resp.r_valid  = AXI_MASTER_M_XSPI_RVALID;

  // ---- leg 8: M_I2C_REG (apb, 32b, PERIPH domain) ----
  d32_req_t  m8_req; d32_resp_t m8_resp;
  d32_req_t  m8_cdc_req; d32_resp_t m8_cdc_resp;
  lite_req_t i2c_lite_req; lite_resp_t i2c_lite_resp;
  apb_req_t  i2c_apb_req;  apb_resp_t  i2c_apb_resp;
  rule_t i2c_rule;
  assign i2c_rule = '{idx:32'd0, start_addr:32'h0200_2000, end_addr:32'h0200_3000};
  erbium_noc_axi_dw_converter #(
    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth(32),
    .AxiAddrWidth(32), .AxiIdWidth(9),
    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t(d32_w_chan_t), .slv_w_chan_t(axm_w_chan_t),
    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),
    .mst_r_chan_t(d32_r_chan_t), .slv_r_chan_t(axm_r_chan_t),
    .axi_mst_req_t(d32_req_t), .axi_mst_resp_t(d32_resp_t),
    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)
  ) i_dw_8 (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[8]), .slv_resp_o(mst_resp[8]),
    .mst_req_o(m8_req), .mst_resp_i(m8_resp)
  );
  erbium_noc_axi_cdc #(
    .aw_chan_t(d32_aw_chan_t), .w_chan_t(d32_w_chan_t), .b_chan_t(d32_b_chan_t),
    .ar_chan_t(d32_ar_chan_t), .r_chan_t(d32_r_chan_t),
    .axi_req_t(d32_req_t), .axi_resp_t(d32_resp_t),
    .LogDepth(2), .SyncStages(2)
  ) i_cdc_8 (
    .src_clk_i(clk_cpu), .src_rst_ni(rstn_cpu), .src_req_i(m8_req), .src_resp_o(m8_resp),
    .dst_clk_i(clk_periph), .dst_rst_ni(rstn_periph), .dst_req_o(m8_cdc_req), .dst_resp_i(m8_cdc_resp)
  );
  erbium_noc_axi_to_axi_lite #(
    .AxiAddrWidth(32), .AxiDataWidth(32), .AxiIdWidth(9), .AxiUserWidth(1),
    .AxiMaxWriteTxns(1), .AxiMaxReadTxns(1), .FallThrough(1'b1),
    .full_req_t(d32_req_t), .full_resp_t(d32_resp_t),
    .lite_req_t(lite_req_t), .lite_resp_t(lite_resp_t)
  ) i_axi2lite_8 (
    .clk_i(clk_periph), .rst_ni(rstn_periph), .test_i(1'b0),
    .slv_req_i(m8_cdc_req), .slv_resp_o(m8_cdc_resp),
    .mst_req_o(i2c_lite_req), .mst_resp_i(i2c_lite_resp)
  );
  erbium_noc_axi_lite_to_apb #(
    .NoApbSlaves(1), .NoRules(1), .AddrWidth(32), .DataWidth(32),
    .axi_lite_req_t(lite_req_t), .axi_lite_resp_t(lite_resp_t),
    .apb_req_t(apb_req_t), .apb_resp_t(apb_resp_t), .rule_t(rule_t)
  ) i_lite2apb_8 (
    .clk_i(clk_periph), .rst_ni(rstn_periph),
    .axi_lite_req_i(i2c_lite_req), .axi_lite_resp_o(i2c_lite_resp),
    .apb_req_o(i2c_apb_req), .apb_resp_i(i2c_apb_resp), .addr_map_i(i2c_rule)
  );
  assign APB_MASTER_M_I2C_REG_PADDR   = i2c_apb_req.paddr;
  assign APB_MASTER_M_I2C_REG_PPROT   = i2c_apb_req.pprot;
  assign APB_MASTER_M_I2C_REG_PSEL    = i2c_apb_req.psel;
  assign APB_MASTER_M_I2C_REG_PENABLE = i2c_apb_req.penable;
  assign APB_MASTER_M_I2C_REG_PWRITE  = i2c_apb_req.pwrite;
  assign APB_MASTER_M_I2C_REG_PWDATA  = i2c_apb_req.pwdata;
  assign APB_MASTER_M_I2C_REG_PSTRB   = i2c_apb_req.pstrb;
  assign i2c_apb_resp.pready  = APB_MASTER_M_I2C_REG_PREADY;
  assign i2c_apb_resp.prdata  = APB_MASTER_M_I2C_REG_PRDATA;
  assign i2c_apb_resp.pslverr = APB_MASTER_M_I2C_REG_PSLVERR;

  // ---- GPV discovery @0xFE00_0000 (read-only, CPU domain) ----
  erbium_noc_gpv #(.req_t(axm_req_t), .resp_t(axm_resp_t), .DW(512)) i_gpv (
    .clk_i(clk), .rst_ni(rst_n),
    .slv_req_i(mst_req[9]), .slv_resp_o(mst_resp[9])
  );

  // ---- low-power Q-Channel clock controllers (one per domain) ----
  erbium_noc_qchannel i_qch_cpu (.clk_i(clk_cpu), .rst_ni(rstn_cpu), .busy_i(1'b0),
    .qactive_o(CPU_QACTIVE), .qreqn_i(CPU_QREQn),
    .qacceptn_o(CPU_QACCEPTn), .qdeny_o(CPU_QDENY));
  assign CPU_PMUSNAPSHOTACK = CPU_PMUSNAPSHOTREQ;  // immediate snapshot ack
  assign CPU_nPMUINTERRUPT  = 1'b1;                // active-low: no PMU irq
  erbium_noc_qchannel i_qch_system (.clk_i(clk_sys), .rst_ni(rstn_sys), .busy_i(1'b0),
    .qactive_o(SYSTEM_QACTIVE), .qreqn_i(SYSTEM_QREQn),
    .qacceptn_o(SYSTEM_QACCEPTn), .qdeny_o(SYSTEM_QDENY));
  assign SYSTEM_PMUSNAPSHOTACK = SYSTEM_PMUSNAPSHOTREQ;  // immediate snapshot ack
  assign SYSTEM_nPMUINTERRUPT  = 1'b1;                // active-low: no PMU irq
  erbium_noc_qchannel i_qch_xspi (.clk_i(clk_xspi), .rst_ni(rstn_xspi), .busy_i(1'b0),
    .qactive_o(XSPI_QACTIVE), .qreqn_i(XSPI_QREQn),
    .qacceptn_o(XSPI_QACCEPTn), .qdeny_o(XSPI_QDENY));
  assign XSPI_PMUSNAPSHOTACK = XSPI_PMUSNAPSHOTREQ;  // immediate snapshot ack
  assign XSPI_nPMUINTERRUPT  = 1'b1;                // active-low: no PMU irq
  erbium_noc_qchannel i_qch_periph (.clk_i(clk_periph), .rst_ni(rstn_periph), .busy_i(1'b0),
    .qactive_o(PERIPH_QACTIVE), .qreqn_i(PERIPH_QREQn),
    .qacceptn_o(PERIPH_QACCEPTn), .qdeny_o(PERIPH_QDENY));
  assign PERIPH_PMUSNAPSHOTACK = PERIPH_PMUSNAPSHOTREQ;  // immediate snapshot ack
  assign PERIPH_nPMUINTERRUPT  = 1'b1;                // active-low: no PMU irq
  // ---- P-Channel power controller (pd_0, CPU domain) ----
  erbium_noc_pchannel #(.PSTATE_W(4), .TINIT(37)) i_pch_pd0 (
    .clk_i(clk_cpu), .rst_ni(rstn_cpu),
    .pactive_o(PD_0_PACTIVE), .preq_i(PD_0_PREQ), .pstate_i(PD_0_PSTATE),
    .paccept_o(PD_0_PACCEPT), .pdeny_o(PD_0_PDENY));
  assign PD_0_INTERRUPT = 1'b0; assign PD_0_NS_INTERRUPT = 1'b0;
  // ---- AWAKEUP: each target leg requests downstream wake while issuing ----
  assign AXI_MASTER_M_MRAM_AWAKEUP = AXI_MASTER_M_MRAM_AWVALID | AXI_MASTER_M_MRAM_ARVALID;
  assign AXI_MASTER_M_CPU_REG_AWAKEUP = AXI_MASTER_M_CPU_REG_AWVALID | AXI_MASTER_M_CPU_REG_ARVALID;
  assign AXI_MASTER_M_SYSTEM_REG_AWAKEUP = AXI_MASTER_M_SYSTEM_REG_AWVALID | AXI_MASTER_M_SYSTEM_REG_ARVALID;
  assign AXI_MASTER_M_MRAM_REG_AWAKEUP = AXI_MASTER_M_MRAM_REG_AWVALID | AXI_MASTER_M_MRAM_REG_ARVALID;
  assign AXI_MASTER_M_SPI_REG_AWAKEUP = AXI_MASTER_M_SPI_REG_AWVALID | AXI_MASTER_M_SPI_REG_ARVALID;
  assign AXI_MASTER_M_UART_REG_AWAKEUP = AXI_MASTER_M_UART_REG_AWVALID | AXI_MASTER_M_UART_REG_ARVALID;
  assign AXI_MASTER_M_SRAM_AWAKEUP = AXI_MASTER_M_SRAM_AWVALID | AXI_MASTER_M_SRAM_ARVALID;
  assign AXI_MASTER_M_XSPI_AWAKEUP = AXI_MASTER_M_XSPI_AWVALID | AXI_MASTER_M_XSPI_ARVALID;
  // debug-auth / DFT / config-access / slave-AWAKEUP: observability inputs (v1)
  wire _unused_ok = ^{1'b0, ECOREVNUM, CPU_SPIDEN, CPU_NIDEN, CPU_DBGEN, CPU_SPNIDEN, DFTCPUDISABLE, SYSTEM_SPIDEN, SYSTEM_NIDEN, SYSTEM_DBGEN, SYSTEM_SPNIDEN, DFTSYSTEMDISABLE, XSPI_SPIDEN, XSPI_NIDEN, XSPI_DBGEN, XSPI_SPNIDEN, DFTXSPIDISABLE, PERIPH_SPIDEN, PERIPH_NIDEN, PERIPH_DBGEN, PERIPH_SPNIDEN, DFTPERIPHDISABLE, S_CPU_CONFIG_ACCESS, S_XSPI_CONFIG_ACCESS, DFTCGEN, DFTRSTDISABLE, AXI_SLAVE_S_CPU_AWAKEUP, AXI_SLAVE_S_XSPI_AWAKEUP};
endmodule
