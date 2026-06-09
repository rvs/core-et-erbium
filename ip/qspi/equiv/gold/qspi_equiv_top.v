// qspi_equiv_top.v (gold) — for equivalence checking only, not for synthesis
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
        .io_clk_o                 (qspi_clk_o),
        .io_io_o                  (qspi_io_o),
        .io_io_enable             (qspi_io_enable),
        .io_io_i_io_i             (qspi_io_i),
        .io_ncs_o                 (qspi_ncs_o),
        .slave_m_awvalid_awvalid  (axi_awvalid),
        .slave_m_awvalid_awaddr   (axi_awaddr),
        .slave_m_awvalid_awsize   (axi_awsize),
        .slave_m_awvalid_awprot   (axi_awprot),
        .slave_awready            (axi_awready),
        .slave_m_wvalid_wvalid    (axi_wvalid),
        .slave_m_wvalid_wdata     (axi_wdata),
        .slave_m_wvalid_wstrb     (axi_wstrb),
        .slave_wready             (axi_wready),
        .slave_bvalid             (axi_bvalid),
        .slave_bresp              (axi_bresp),
        .slave_m_bready_bready    (axi_bready),
        .slave_m_arvalid_arvalid  (axi_arvalid),
        .slave_m_arvalid_araddr   (axi_araddr),
        .slave_m_arvalid_arsize   (axi_arsize),
        .slave_m_arvalid_arprot   (axi_arprot),
        .slave_arready            (axi_arready),
        .slave_rvalid             (axi_rvalid),
        .slave_rresp              (axi_rresp),
        .slave_rdata              (axi_rdata),
        .slave_m_rready_rready    (axi_rready),
        .interrupts               (interrupts),
        .RDY_interrupts           ()
    );
endmodule
