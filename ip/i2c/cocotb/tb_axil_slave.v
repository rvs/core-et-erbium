module tb;
    parameter FILTER_LEN = 4;
    parameter DATA_WIDTH = 32;  // width of data bus in bits
    parameter ADDR_WIDTH = 32;  // width of address bus in bits
    parameter STRB_WIDTH = (DATA_WIDTH/8);
    wire                    clk;
    wire                    rst;

    /*
     * I2C interface
     */
    wire                   i2c_scl_i;
    wire                   i2c_scl_o;
    wire                   i2c_scl_t;
    wire                   i2c_sda_i;
    wire                   i2c_sda_o;
    wire                   i2c_sda_t;

    /*
     * AXI lite master interface
     */
    wire [ADDR_WIDTH-1:0]  m_axil_awaddr;
    wire [2:0]             m_axil_awprot;
    wire                   m_axil_awvalid;
    wire                   m_axil_awready;
    wire [DATA_WIDTH-1:0]  m_axil_wdata;
    wire [STRB_WIDTH-1:0]  m_axil_wstrb;
    wire                   m_axil_wvalid;
    wire                   m_axil_wready;
    wire [1:0]             m_axil_bresp;
    wire                   m_axil_bvalid;
    wire                   m_axil_bready;
    wire [ADDR_WIDTH-1:0]  m_axil_araddr;
    wire [2:0]             m_axil_arprot;
    wire                   m_axil_arvalid;
    wire                   m_axil_arready;
    wire [DATA_WIDTH-1:0]  m_axil_rdata;
    wire [1:0]             m_axil_rresp;
    wire                   m_axil_rvalid;
    wire                   m_axil_rready;

    /*
     * Status
     */
    wire                   busy;
    wire                   bus_addressed;
    wire                   bus_active;

    /*
     * Configuration
     */
    wire                   enable;
    wire [6:0]             device_address;



  assign device_address='h40;
  assign enable=!rst;
  // assign m_axil_awready=1'b1;
  // assign m_axil_wready=1'b1;
  // assign m_axil_bresp=2'b1;
  // assign m_axil_bvalid=1'b1;
  // assign m_axil_arready=1'b1;
  // assign m_axil_rdata=32'b1;
  // assign m_axil_rresp=1'b1;
  // assign m_axil_rvalid=1'b1;

i2c_slave_axil_master #(
    .ADDR_WIDTH(32)  // width of address bus in bits
) i2c_slv (
	.*
);
endmodule
