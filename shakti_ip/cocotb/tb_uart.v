/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-08
 Description: A brief description of the file's purpose.
*/
module tb_uart(
  input  CLK,
  input  RST_N,
  input  axim_awvalid,
  input  [31 : 0] axim_awaddr,
  input  [1 : 0] axim_awsize,
  input  [2 : 0] axim_awprot,
  output axim_awready,
  input  axim_wvalid,
  input  [63 : 0] axim_wdata,
  input  [7 : 0] axim_wstrb,
  output axim_wready,
  output axim_bvalid,
  output [1 : 0] axim_bresp,
  input  axim_bready,
  input  axim_arvalid,
  input  [31 : 0] axim_araddr,
  input  [1 : 0] axim_arsize,
  input  [2 : 0] axim_arprot,
  output axim_arready,
  output axim_rvalid,
  output [1 : 0] axim_rresp,
  output [63 : 0] axim_rdata,
  input  axim_rready,
  input  UART_RX,
  output UART_TX,
  output SOUT_EN,
  output [1 : 0] DMA_RDY,
  output interrupt
);
;
uart uart(
   .CLK_uart_clock(CLK),
   .RST_N_uart_reset(RST_N),
   .CLK(CLK),
   .RST_N(RST_N),
   .m_awvalid_awvalid(axim_awvalid),
   .m_awvalid_awaddr(axim_awaddr>>1),
   .m_awvalid_awsize(2'd2/*axim_awsize*/),
   .m_awvalid_awprot(axim_awprot),
   .awready(axim_awready),
   .m_wvalid_wvalid(axim_wvalid),
   .m_wvalid_wdata(axim_wdata),
   .m_wvalid_wstrb(axim_wstrb),
   .wready(axim_wready),
   .bvalid(axim_bvalid),
   .bresp(axim_bresp),
   .m_bready_bready(axim_bready),
   .m_arvalid_arvalid(axim_arvalid),
   .m_arvalid_araddr(axim_araddr>>1),
   .m_arvalid_arsize(axim_arsize),
   .m_arvalid_arprot(axim_arprot),
   .arready(axim_arready),
   .rvalid(axim_rvalid),
   .rresp(axim_rresp),
   .rdata(axim_rdata),
   .m_rready_rready(axim_rready),
   .SIN(UART_RX),
   .SOUT(UART_TX),
   .SOUT_EN(SOUT_EN),
   .DMA_RDY(DMA_RDY),
   .interrupt(interrupt)
);
endmodule
