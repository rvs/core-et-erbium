// Copyright 2024
// Author: Vijayvithal
module erbium_digital_et  (
    // xSPI IO Signals
    input wire XSPI_CSN,
    input wire [7:0] XSPI_DQ_IN,
    output wire [7:0] XSPI_DQ_OUT,
    output wire XSPI_DQ_OEN,
    input wire XSPI_RWDS_IN,
    output wire XSPI_RWDS_OUT,
    output wire XSPI_RWDS_OEN,
    input wire [10:0] gpio_i,
    output wire [10:0] gpio_o,
    output wire [10:0] gpio_oe,
    input wire xspi_clk,
    input wire xspi_rst_n,
    input wire [1:0] xspi_mode,
    output wire use_xspi_clk,
    output wire [2:0] drive_strength,
    output wire xspi_pd_req,
    output wire xspi_rst_req, //TODO
    // CPU SS Signals
    input wire cpu_clock,
    input wire cpu_reset_cold,
    input wire cpu_reset_warm,
    output wire cpu_soft_reset, // cold reset
    output wire cpu_warm_reset_req,
    output wire cpu_pd_req, // TODO

    // I2C Signals
    input wire i2c_clk,
    input wire i2c_arst_n,
    // input wire i2c_scl_i,
    // output wire i2c_scl_o,
    // output wire i2c_scl_t,

    // input wire i2c_sda_i,
    // output wire i2c_sda_o,
    // output wire i2c_sda_t,
    //UART Signals
    input wire uart_clk,
    input wire uart_rst_n,
    input wire uart_domain_rst_n,
    // input wire UART_RX,
    // output wire UART_TX,
    // output wire UART_TX_ENA,
    // QSPI Signals
    input wire qspi_clk,
    input wire qspi_rst_n,
    input wire qspi_slow_clock,
    input wire qspi_slow_rst_n,
    // output wire qspi_sclk,
    // input wire [3:0] qspi_dq_in,
    // output wire [3:0] qspi_dq_out,
    // output wire [3:0] qspi_dq_out_ena,
    // output wire qspi_csn,
    //MRAM Signals
    input wire mram_clk,
    input wire mram_rst_b,
    output wire mram_pd_req,
    inout wire ANATEST0,
    inout wire ANATEST1,
    input wire TestMode,
    // System_registers
    input wire system_reg_clk,
    input wire system_reg_arst_n,
    //powerGood counter
    output wire [20:0] power_good_counter_out,
    output wire power_good_counter_out_valid,
    input wire [20:0] power_good_counter_in,
    //SRAM
    input wire sram_clk,
    input wire sram_rst_n,

    output wire brownout_clear,
    input wire brownout_cause,
    output wire por_clear,
    input wire por_cause,
    output wire watchdog_clear,
    input wire watchdog_cause,
    output wire soft_reset_clear,
    input wire soft_reset_cause,
    //
    output wire soft_reset,
    output wire watchdog_timeout,
    output wire power_off_req,

    input wire periph_clk,
    input wire periph_rst_n,
    input wire system_clk,
    input wire system_rst_n,
    output wire gpio_0_mode_n,
    output System_Reg_pkg::System_Reg__out_t system_reg_hwif_out,
// JTAG
    input wire TDI,
    input wire TMS,
    input wire TCK,
    input wire TRSTn,
    output wire TDO,
    output wire TDOEN

/*

    // Analog signals
//    inout [1:0] ana_test_io,
    // AON Ctrl Signals
    output wire sysreset_req,
    // UPF

    */
);

    wire i2c_scl_i;
    wire i2c_scl_o;
    wire i2c_scl_oe;
    wire i2c_sda_i;
    wire i2c_sda_o;
    wire i2c_sda_oe;
    wire UART_RX;
    wire UART_TX;
    wire UART_TX_ENA;
    wire qspi_sclk;
    wire [3:0] qspi_dq_in;
    wire [3:0] qspi_dq_out;
    wire [3:0] qspi_dq_out_ena;
    wire qspi_csn;

System_Reg_pkg::System_Reg__in_t system_reg_hwif_in;
// System_Reg_pkg::System_Reg__out_t system_reg_hwif_out;
assign soft_reset=system_reg_hwif_out.SoftReset.soft_reset.value;
assign cpu_soft_reset=system_reg_hwif_out.SoftReset.cpu_soft_reset.value;
assign brownout_clear=system_reg_hwif_out.ResetCause.brownout.swacc;
assign por_clear=system_reg_hwif_out.ResetCause.por.swacc;
assign watchdog_clear=system_reg_hwif_out.ResetCause.watchdog_timedout.swacc;
assign system_reg_hwif_in.ResetCause.por.next = por_cause;
assign system_reg_hwif_in.ResetCause.watchdog_timedout.next = watchdog_cause;
assign system_reg_hwif_in.ResetCause.brownout.next = brownout_cause;
assign system_reg_hwif_in.ResetCause.sysreset_req.next = 1'b0;
assign system_reg_hwif_in.ResetCause.softreset.next = soft_reset_cause;
assign system_reg_hwif_in.ResetCause.cpu_warm_reset.hwset = system_reg_hwif_out.SoftReset.cpu_warm_reset.value;
assign soft_reset_clear=system_reg_hwif_out.ResetCause.softreset.swacc;
assign power_off_req = system_reg_hwif_out.PowerDomainReq.system_poweroff.value;
assign xspi_pd_req = XSPI_CSN && system_reg_hwif_out.PowerDomainReq.xspi_pd.value;

 wire   [31:0]                   APB_MASTER_M_CPU_REG_PADDR; 
 wire                            APB_MASTER_M_CPU_REG_PENABLE; 
 wire   [2:0]                    APB_MASTER_M_CPU_REG_PPROT; //
 wire    [63:0]                   APB_MASTER_M_CPU_REG_PRDATA; 
 wire                             APB_MASTER_M_CPU_REG_PREADY; 
 wire                            APB_MASTER_M_CPU_REG_PSEL; 
 wire                             APB_MASTER_M_CPU_REG_PSLVERR; 
 wire   [3:0]                    APB_MASTER_M_CPU_REG_PSTRB; //
 wire   [63:0]                   APB_MASTER_M_CPU_REG_PWDATA; 
 wire                            APB_MASTER_M_CPU_REG_PWRITE; 
wire   [31:0]                   AXI_MASTER_M_MRAM_REG_ARADDR; 
wire   [1:0]                    AXI_MASTER_M_MRAM_REG_ARBURST; //
wire   [3:0]                    AXI_MASTER_M_MRAM_REG_ARCACHE; //
wire   [8:0]                    AXI_MASTER_M_MRAM_REG_ARID; //
wire   [7:0]                    AXI_MASTER_M_MRAM_REG_ARLEN; //
wire   [0:0]                    AXI_MASTER_M_MRAM_REG_ARLOCK; //
wire   [2:0]                    AXI_MASTER_M_MRAM_REG_ARPROT; 
wire   [3:0]                    AXI_MASTER_M_MRAM_REG_ARQOS; //
wire                             AXI_MASTER_M_MRAM_REG_ARREADY; 
wire   [2:0]                    AXI_MASTER_M_MRAM_REG_ARSIZE; //
wire                            AXI_MASTER_M_MRAM_REG_ARVALID; 
wire   [31:0]                   AXI_MASTER_M_MRAM_REG_AWADDR; 
wire                            AXI_MASTER_M_MRAM_REG_AWAKEUP; //
wire   [1:0]                    AXI_MASTER_M_MRAM_REG_AWBURST; //
wire   [3:0]                    AXI_MASTER_M_MRAM_REG_AWCACHE; //
wire   [8:0]                    AXI_MASTER_M_MRAM_REG_AWID; //
wire   [7:0]                    AXI_MASTER_M_MRAM_REG_AWLEN; //
wire   [0:0]                    AXI_MASTER_M_MRAM_REG_AWLOCK; //
wire   [2:0]                    AXI_MASTER_M_MRAM_REG_AWPROT; 
wire   [3:0]                    AXI_MASTER_M_MRAM_REG_AWQOS; //
wire                             AXI_MASTER_M_MRAM_REG_AWREADY; 
wire   [2:0]                    AXI_MASTER_M_MRAM_REG_AWSIZE; //
wire                            AXI_MASTER_M_MRAM_REG_AWVALID; 
wire    [8:0]                    AXI_MASTER_M_MRAM_REG_BID; //
wire                            AXI_MASTER_M_MRAM_REG_BREADY; 
wire    [1:0]                    AXI_MASTER_M_MRAM_REG_BRESP; 
wire                             AXI_MASTER_M_MRAM_REG_BVALID; 
wire    [63:0]                  AXI_MASTER_M_MRAM_REG_RDATA; 
wire    [8:0]                    AXI_MASTER_M_MRAM_REG_RID; //
wire                             AXI_MASTER_M_MRAM_REG_RLAST; //
wire                            AXI_MASTER_M_MRAM_REG_RREADY; 
wire    [1:0]                    AXI_MASTER_M_MRAM_REG_RRESP; 
wire                             AXI_MASTER_M_MRAM_REG_RVALID; 
wire   [63:0]                  AXI_MASTER_M_MRAM_REG_WDATA; 
wire                            AXI_MASTER_M_MRAM_REG_WLAST; //
wire                             AXI_MASTER_M_MRAM_REG_WREADY; 
wire   [7:0]                   AXI_MASTER_M_MRAM_REG_WSTRB; 
wire                            AXI_MASTER_M_MRAM_REG_WVALID; 

   wire   [31:0]                   AXI_MASTER_M_SYSTEM_REG_ARADDR; 
   wire   [1:0]                    AXI_MASTER_M_SYSTEM_REG_ARBURST; 
   wire   [3:0]                    AXI_MASTER_M_SYSTEM_REG_ARCACHE; 
   wire   [8:0]                    AXI_MASTER_M_SYSTEM_REG_ARID; 
   wire   [7:0]                    AXI_MASTER_M_SYSTEM_REG_ARLEN; 
   wire   [0:0]                    AXI_MASTER_M_SYSTEM_REG_ARLOCK; 
   wire   [2:0]                    AXI_MASTER_M_SYSTEM_REG_ARPROT; 
   wire   [3:0]                    AXI_MASTER_M_SYSTEM_REG_ARQOS; 
  wire                             AXI_MASTER_M_SYSTEM_REG_ARREADY; 
   wire   [2:0]                    AXI_MASTER_M_SYSTEM_REG_ARSIZE; 
   wire                            AXI_MASTER_M_SYSTEM_REG_ARVALID; 
   wire   [31:0]                   AXI_MASTER_M_SYSTEM_REG_AWADDR; 
   wire                            AXI_MASTER_M_SYSTEM_REG_AWAKEUP; 
   wire   [1:0]                    AXI_MASTER_M_SYSTEM_REG_AWBURST; 
   wire   [3:0]                    AXI_MASTER_M_SYSTEM_REG_AWCACHE; 
   wire   [8:0]                    AXI_MASTER_M_SYSTEM_REG_AWID; 
   wire   [7:0]                    AXI_MASTER_M_SYSTEM_REG_AWLEN; 
   wire   [0:0]                    AXI_MASTER_M_SYSTEM_REG_AWLOCK; 
   wire   [2:0]                    AXI_MASTER_M_SYSTEM_REG_AWPROT; 
   wire   [3:0]                    AXI_MASTER_M_SYSTEM_REG_AWQOS; 
  wire                             AXI_MASTER_M_SYSTEM_REG_AWREADY; 
   wire   [2:0]                    AXI_MASTER_M_SYSTEM_REG_AWSIZE; 
   wire                            AXI_MASTER_M_SYSTEM_REG_AWVALID; 
  wire    [8:0]                    AXI_MASTER_M_SYSTEM_REG_BID; 
   wire                            AXI_MASTER_M_SYSTEM_REG_BREADY; 
  wire    [1:0]                    AXI_MASTER_M_SYSTEM_REG_BRESP; 
  wire                             AXI_MASTER_M_SYSTEM_REG_BVALID; 
  wire    [63:0]                   AXI_MASTER_M_SYSTEM_REG_RDATA; 
  wire    [8:0]                    AXI_MASTER_M_SYSTEM_REG_RID; 
  wire                             AXI_MASTER_M_SYSTEM_REG_RLAST; 
   wire                            AXI_MASTER_M_SYSTEM_REG_RREADY; 
  wire    [1:0]                    AXI_MASTER_M_SYSTEM_REG_RRESP; 
  wire                             AXI_MASTER_M_SYSTEM_REG_RVALID; 
   wire   [63:0]                   AXI_MASTER_M_SYSTEM_REG_WDATA; 
   wire                            AXI_MASTER_M_SYSTEM_REG_WLAST; 
  wire                             AXI_MASTER_M_SYSTEM_REG_WREADY; 
   wire   [7:0]                    AXI_MASTER_M_SYSTEM_REG_WSTRB; 
   wire                            AXI_MASTER_M_SYSTEM_REG_WVALID; 

   wire   [31:0]                   AXI_MASTER_M_XSPI_ARADDR; 
   wire   [1:0]                    AXI_MASTER_M_XSPI_ARBURST; 
   wire   [3:0]                    AXI_MASTER_M_XSPI_ARCACHE; 
   wire   [8:0]                    AXI_MASTER_M_XSPI_ARID; 
   wire   [7:0]                    AXI_MASTER_M_XSPI_ARLEN; 
   wire   [0:0]                    AXI_MASTER_M_XSPI_ARLOCK; 
   wire   [2:0]                    AXI_MASTER_M_XSPI_ARPROT; 
   wire   [3:0]                    AXI_MASTER_M_XSPI_ARQOS; 
  wire                             AXI_MASTER_M_XSPI_ARREADY; 
   wire   [2:0]                    AXI_MASTER_M_XSPI_ARSIZE; 
   wire                            AXI_MASTER_M_XSPI_ARVALID; 
   wire   [31:0]                   AXI_MASTER_M_XSPI_AWADDR; 
   wire                            AXI_MASTER_M_XSPI_AWAKEUP; //
   wire   [1:0]                    AXI_MASTER_M_XSPI_AWBURST; 
   wire   [3:0]                    AXI_MASTER_M_XSPI_AWCACHE; 
   wire   [8:0]                    AXI_MASTER_M_XSPI_AWID; 
   wire   [7:0]                    AXI_MASTER_M_XSPI_AWLEN; 
   wire   [0:0]                    AXI_MASTER_M_XSPI_AWLOCK; 
   wire   [2:0]                    AXI_MASTER_M_XSPI_AWPROT; 
   wire   [3:0]                    AXI_MASTER_M_XSPI_AWQOS; 
  wire                             AXI_MASTER_M_XSPI_AWREADY; 
   wire   [2:0]                    AXI_MASTER_M_XSPI_AWSIZE; 
   wire                            AXI_MASTER_M_XSPI_AWVALID; 
  wire    [8:0]                    AXI_MASTER_M_XSPI_BID; 
   wire                            AXI_MASTER_M_XSPI_BREADY; 
  wire    [1:0]                    AXI_MASTER_M_XSPI_BRESP; 
  wire                             AXI_MASTER_M_XSPI_BVALID; 
  wire    [63:0]                   AXI_MASTER_M_XSPI_RDATA; 
  wire    [8:0]                    AXI_MASTER_M_XSPI_RID; 
  wire                             AXI_MASTER_M_XSPI_RLAST; 
   wire                            AXI_MASTER_M_XSPI_RREADY; 
  wire    [1:0]                    AXI_MASTER_M_XSPI_RRESP; 
  wire                             AXI_MASTER_M_XSPI_RVALID; 
   wire   [63:0]                   AXI_MASTER_M_XSPI_WDATA; 
   wire                            AXI_MASTER_M_XSPI_WLAST; 
  wire                             AXI_MASTER_M_XSPI_WREADY; 
   wire   [7:0]                    AXI_MASTER_M_XSPI_WSTRB; 
   wire                            AXI_MASTER_M_XSPI_WVALID; 
wire   [31:0]                   APB_MASTER_M_I2C_REG_PADDR;
wire                            APB_MASTER_M_I2C_REG_PENABLE;
wire   [2:0]                    APB_MASTER_M_I2C_REG_PPROT;
wire    [31:0]                   APB_MASTER_M_I2C_REG_PRDATA;
wire                             APB_MASTER_M_I2C_REG_PREADY;
wire                            APB_MASTER_M_I2C_REG_PSEL;
wire                             APB_MASTER_M_I2C_REG_PSLVERR; 
wire   [3:0]                    APB_MASTER_M_I2C_REG_PSTRB;
wire   [31:0]                   APB_MASTER_M_I2C_REG_PWDATA;
wire                            APB_MASTER_M_I2C_REG_PWRITE;
 wire   [31:0]                   AXI_MASTER_M_MRAM_ARADDR; 
 wire   [1:0]                    AXI_MASTER_M_MRAM_ARBURST; 
 wire   [3:0]                    AXI_MASTER_M_MRAM_ARCACHE; 
 wire   [8:0]                    AXI_MASTER_M_MRAM_ARID; 
 wire   [7:0]                    AXI_MASTER_M_MRAM_ARLEN; 
 wire   [0:0]                    AXI_MASTER_M_MRAM_ARLOCK; 
 wire   [2:0]                    AXI_MASTER_M_MRAM_ARPROT; 
 wire   [3:0]                    AXI_MASTER_M_MRAM_ARQOS; 
 wire                             AXI_MASTER_M_MRAM_ARREADY; 
 wire   [2:0]                    AXI_MASTER_M_MRAM_ARSIZE; 
 wire                            AXI_MASTER_M_MRAM_ARVALID; 
 wire   [31:0]                   AXI_MASTER_M_MRAM_AWADDR; 
 wire                            AXI_MASTER_M_MRAM_AWAKEUP; //
 wire   [1:0]                    AXI_MASTER_M_MRAM_AWBURST; 
 wire   [3:0]                    AXI_MASTER_M_MRAM_AWCACHE; 
 wire   [8:0]                    AXI_MASTER_M_MRAM_AWID; 
 wire   [7:0]                    AXI_MASTER_M_MRAM_AWLEN; 
 wire   [0:0]                    AXI_MASTER_M_MRAM_AWLOCK; 
 wire   [2:0]                    AXI_MASTER_M_MRAM_AWPROT; 
 wire   [3:0]                    AXI_MASTER_M_MRAM_AWQOS; 
 wire                             AXI_MASTER_M_MRAM_AWREADY; 
 wire   [2:0]                    AXI_MASTER_M_MRAM_AWSIZE; 
 wire                            AXI_MASTER_M_MRAM_AWVALID; 
 wire    [8:0]                    AXI_MASTER_M_MRAM_BID; 
 wire                            AXI_MASTER_M_MRAM_BREADY; 
 wire    [1:0]                    AXI_MASTER_M_MRAM_BRESP; 
 wire                             AXI_MASTER_M_MRAM_BVALID; 
 wire    [511:0]                  AXI_MASTER_M_MRAM_RDATA; 
 wire    [8:0]                    AXI_MASTER_M_MRAM_RID; 
 wire                             AXI_MASTER_M_MRAM_RLAST; 
 wire                            AXI_MASTER_M_MRAM_RREADY; 
 wire    [1:0]                    AXI_MASTER_M_MRAM_RRESP; 
 wire                             AXI_MASTER_M_MRAM_RVALID; 
 wire   [511:0]                  AXI_MASTER_M_MRAM_WDATA; 
 wire                            AXI_MASTER_M_MRAM_WLAST; 
 wire                             AXI_MASTER_M_MRAM_WREADY; 
 wire   [63:0]                   AXI_MASTER_M_MRAM_WSTRB; 
 wire                            AXI_MASTER_M_MRAM_WVALID; 
 wire   [31:0]                   AXI_MASTER_M_SPI_REG_ARADDR; 
 wire   [1:0]                    AXI_MASTER_M_SPI_REG_ARBURST; //
 wire   [3:0]                    AXI_MASTER_M_SPI_REG_ARCACHE; //
 wire   [8:0]                    AXI_MASTER_M_SPI_REG_ARID; //
 wire   [7:0]                    AXI_MASTER_M_SPI_REG_ARLEN; //
 wire   [0:0]                    AXI_MASTER_M_SPI_REG_ARLOCK; //
 wire   [2:0]                    AXI_MASTER_M_SPI_REG_ARPROT; 
 wire   [3:0]                    AXI_MASTER_M_SPI_REG_ARQOS; //
 wire                             AXI_MASTER_M_SPI_REG_ARREADY; 
 wire   [2:0]                    AXI_MASTER_M_SPI_REG_ARSIZE; 
 wire                            AXI_MASTER_M_SPI_REG_ARVALID; 
 wire   [31:0]                   AXI_MASTER_M_SPI_REG_AWADDR; 
 wire                            AXI_MASTER_M_SPI_REG_AWAKEUP; //
 wire   [1:0]                    AXI_MASTER_M_SPI_REG_AWBURST; //
 wire   [3:0]                    AXI_MASTER_M_SPI_REG_AWCACHE; //
 wire   [8:0]                    AXI_MASTER_M_SPI_REG_AWID; //
 wire   [7:0]                    AXI_MASTER_M_SPI_REG_AWLEN; //
 wire   [0:0]                    AXI_MASTER_M_SPI_REG_AWLOCK; //
 wire   [2:0]                    AXI_MASTER_M_SPI_REG_AWPROT; 
 wire   [3:0]                    AXI_MASTER_M_SPI_REG_AWQOS; //
 wire                             AXI_MASTER_M_SPI_REG_AWREADY; 
 wire   [2:0]                    AXI_MASTER_M_SPI_REG_AWSIZE; 
 wire                            AXI_MASTER_M_SPI_REG_AWVALID; 
 wire    [8:0]                    AXI_MASTER_M_SPI_REG_BID; //
 wire                            AXI_MASTER_M_SPI_REG_BREADY; 
 wire    [1:0]                    AXI_MASTER_M_SPI_REG_BRESP; 
 wire                             AXI_MASTER_M_SPI_REG_BVALID; 
 wire    [63:0]                   AXI_MASTER_M_SPI_REG_RDATA; 
 wire    [8:0]                    AXI_MASTER_M_SPI_REG_RID; //
 wire                             AXI_MASTER_M_SPI_REG_RLAST; //
 wire                            AXI_MASTER_M_SPI_REG_RREADY; 
 wire    [1:0]                    AXI_MASTER_M_SPI_REG_RRESP; 
 wire                             AXI_MASTER_M_SPI_REG_RVALID; 
 wire   [63:0]                   AXI_MASTER_M_SPI_REG_WDATA; 
 wire                            AXI_MASTER_M_SPI_REG_WLAST; //
 wire                             AXI_MASTER_M_SPI_REG_WREADY; 
 wire   [7:0]                    AXI_MASTER_M_SPI_REG_WSTRB; 
 wire                            AXI_MASTER_M_SPI_REG_WVALID; 
 wire   [31:0]                   AXI_MASTER_M_SRAM_ARADDR; 
 wire   [1:0]                    AXI_MASTER_M_SRAM_ARBURST; 
 wire   [3:0]                    AXI_MASTER_M_SRAM_ARCACHE; 
 wire   [8:0]                    AXI_MASTER_M_SRAM_ARID; 
 wire   [7:0]                    AXI_MASTER_M_SRAM_ARLEN; 
 wire   [0:0]                    AXI_MASTER_M_SRAM_ARLOCK; 
 wire   [2:0]                    AXI_MASTER_M_SRAM_ARPROT; 
 wire   [3:0]                    AXI_MASTER_M_SRAM_ARQOS; 
 wire                             AXI_MASTER_M_SRAM_ARREADY; 
 wire   [2:0]                    AXI_MASTER_M_SRAM_ARSIZE; 
 wire                            AXI_MASTER_M_SRAM_ARVALID; 
 wire   [31:0]                   AXI_MASTER_M_SRAM_AWADDR; 
 wire                            AXI_MASTER_M_SRAM_AWAKEUP; 
 wire   [1:0]                    AXI_MASTER_M_SRAM_AWBURST; 
 wire   [3:0]                    AXI_MASTER_M_SRAM_AWCACHE; 
 wire   [8:0]                    AXI_MASTER_M_SRAM_AWID; 
 wire   [7:0]                    AXI_MASTER_M_SRAM_AWLEN; 
 wire   [0:0]                    AXI_MASTER_M_SRAM_AWLOCK; 
 wire   [2:0]                    AXI_MASTER_M_SRAM_AWPROT; 
 wire   [3:0]                    AXI_MASTER_M_SRAM_AWQOS; 
 wire                             AXI_MASTER_M_SRAM_AWREADY; 
 wire   [2:0]                    AXI_MASTER_M_SRAM_AWSIZE; 
 wire                            AXI_MASTER_M_SRAM_AWVALID; 
 wire    [8:0]                    AXI_MASTER_M_SRAM_BID; 
 wire                            AXI_MASTER_M_SRAM_BREADY; 
 wire    [1:0]                    AXI_MASTER_M_SRAM_BRESP; 
 wire                             AXI_MASTER_M_SRAM_BVALID; 
 wire    [63:0]                   AXI_MASTER_M_SRAM_RDATA; 
 wire    [8:0]                    AXI_MASTER_M_SRAM_RID; 
 wire                             AXI_MASTER_M_SRAM_RLAST; 
 wire                            AXI_MASTER_M_SRAM_RREADY; 
 wire    [1:0]                    AXI_MASTER_M_SRAM_RRESP; 
 wire                             AXI_MASTER_M_SRAM_RVALID; 
 wire   [63:0]                   AXI_MASTER_M_SRAM_WDATA; 
 wire                            AXI_MASTER_M_SRAM_WLAST; 
 wire                             AXI_MASTER_M_SRAM_WREADY; 
 wire   [7:0]                    AXI_MASTER_M_SRAM_WSTRB; 
 wire                            AXI_MASTER_M_SRAM_WVALID; 
 wire   [31:0]                   AXI_MASTER_M_UART_REG_ARADDR; 
 wire   [1:0]                    AXI_MASTER_M_UART_REG_ARBURST; 
 wire   [3:0]                    AXI_MASTER_M_UART_REG_ARCACHE; //
 wire   [8:0]                    AXI_MASTER_M_UART_REG_ARID; 
 wire   [7:0]                    AXI_MASTER_M_UART_REG_ARLEN; 
 wire   [0:0]                    AXI_MASTER_M_UART_REG_ARLOCK; //
 wire   [2:0]                    AXI_MASTER_M_UART_REG_ARPROT; 
 wire   [3:0]                    AXI_MASTER_M_UART_REG_ARQOS; //
 wire                             AXI_MASTER_M_UART_REG_ARREADY; 
 wire   [2:0]                    AXI_MASTER_M_UART_REG_ARSIZE;
 wire                            AXI_MASTER_M_UART_REG_ARVALID; 
 wire   [31:0]                   AXI_MASTER_M_UART_REG_AWADDR; 
 wire                            AXI_MASTER_M_UART_REG_AWAKEUP; //
 wire   [1:0]                    AXI_MASTER_M_UART_REG_AWBURST;
 wire   [3:0]                    AXI_MASTER_M_UART_REG_AWCACHE; //
 wire   [8:0]                    AXI_MASTER_M_UART_REG_AWID; 
 wire   [7:0]                    AXI_MASTER_M_UART_REG_AWLEN;
 wire   [0:0]                    AXI_MASTER_M_UART_REG_AWLOCK; //
 wire   [2:0]                    AXI_MASTER_M_UART_REG_AWPROT; 
 wire   [3:0]                    AXI_MASTER_M_UART_REG_AWQOS; //
 wire                             AXI_MASTER_M_UART_REG_AWREADY; 
 wire   [2:0]                    AXI_MASTER_M_UART_REG_AWSIZE; 
 wire                            AXI_MASTER_M_UART_REG_AWVALID; 
 wire    [8:0]                    AXI_MASTER_M_UART_REG_BID;
 wire                            AXI_MASTER_M_UART_REG_BREADY; 
 wire    [1:0]                    AXI_MASTER_M_UART_REG_BRESP; 
 wire                             AXI_MASTER_M_UART_REG_BVALID; 
 wire    [63:0]                   AXI_MASTER_M_UART_REG_RDATA; 
 wire    [8:0]                    AXI_MASTER_M_UART_REG_RID;
 wire                             AXI_MASTER_M_UART_REG_RLAST;
 wire                            AXI_MASTER_M_UART_REG_RREADY; 
 wire    [1:0]                    AXI_MASTER_M_UART_REG_RRESP; 
 wire                             AXI_MASTER_M_UART_REG_RVALID; 
 wire   [63:0]                   AXI_MASTER_M_UART_REG_WDATA; 
 wire                            AXI_MASTER_M_UART_REG_WLAST;
 wire                             AXI_MASTER_M_UART_REG_WREADY; 
 wire   [7:0]                    AXI_MASTER_M_UART_REG_WSTRB; 
 wire                            AXI_MASTER_M_UART_REG_WVALID; 
 wire    [31:0]                   AXI_SLAVE_S_CPU_ARADDR; 
 wire    [1:0]                    AXI_SLAVE_S_CPU_ARBURST; 
 wire    [3:0]                    AXI_SLAVE_S_CPU_ARCACHE; 
 wire    [7:0]                    AXI_SLAVE_S_CPU_ARID; 
 wire    [7:0]                    AXI_SLAVE_S_CPU_ARLEN; 
 wire                             AXI_SLAVE_S_CPU_ARLOCK; 
 wire    [2:0]                    AXI_SLAVE_S_CPU_ARPROT; 
 wire    [3:0]                    AXI_SLAVE_S_CPU_ARQOS = 4'b0; 
 wire                            AXI_SLAVE_S_CPU_ARREADY; 
 wire    [2:0]                    AXI_SLAVE_S_CPU_ARSIZE; 
 wire                             AXI_SLAVE_S_CPU_ARVALID; 
 wire    [31:0]                   AXI_SLAVE_S_CPU_AWADDR; 
 wire                             AXI_SLAVE_S_CPU_AWAKEUP=1; 
 wire    [1:0]                    AXI_SLAVE_S_CPU_AWBURST; 
 wire    [3:0]                    AXI_SLAVE_S_CPU_AWCACHE; 
 wire    [7:0]                    AXI_SLAVE_S_CPU_AWID; 
 wire    [7:0]                    AXI_SLAVE_S_CPU_AWLEN; 
 wire                             AXI_SLAVE_S_CPU_AWLOCK; 
 wire    [2:0]                    AXI_SLAVE_S_CPU_AWPROT; 
 wire    [3:0]                    AXI_SLAVE_S_CPU_AWQOS=4'b0; 
 wire                            AXI_SLAVE_S_CPU_AWREADY; 
 wire    [2:0]                    AXI_SLAVE_S_CPU_AWSIZE; 
 wire                             AXI_SLAVE_S_CPU_AWVALID; 
 wire   [7:0]                    AXI_SLAVE_S_CPU_BID; 
 wire                             AXI_SLAVE_S_CPU_BREADY; 
 wire   [1:0]                    AXI_SLAVE_S_CPU_BRESP; 
 wire                            AXI_SLAVE_S_CPU_BVALID; 
 wire   [511:0]                  AXI_SLAVE_S_CPU_RDATA; 
 wire   [7:0]                    AXI_SLAVE_S_CPU_RID; 
 wire                            AXI_SLAVE_S_CPU_RLAST; 
 wire                             AXI_SLAVE_S_CPU_RREADY; 
 wire   [1:0]                    AXI_SLAVE_S_CPU_RRESP; 
 wire                            AXI_SLAVE_S_CPU_RVALID; 
 wire    [511:0]                  AXI_SLAVE_S_CPU_WDATA; 
 wire                             AXI_SLAVE_S_CPU_WLAST; 
 wire                            AXI_SLAVE_S_CPU_WREADY; 
 wire    [63:0]                   AXI_SLAVE_S_CPU_WSTRB; 
 wire                             AXI_SLAVE_S_CPU_WVALID; 
 wire    [31:0]                   AXI_SLAVE_S_XSPI_ARADDR; 
 wire    [1:0]                    AXI_SLAVE_S_XSPI_ARBURST; 
 wire    [3:0]                    AXI_SLAVE_S_XSPI_ARCACHE; 
 wire                             AXI_SLAVE_S_XSPI_ARID=0; //
 wire    [7:0]                    AXI_SLAVE_S_XSPI_ARLEN; 
 wire                             AXI_SLAVE_S_XSPI_ARLOCK; 
 wire    [2:0]                    AXI_SLAVE_S_XSPI_ARPROT; 
 wire    [3:0]                    AXI_SLAVE_S_XSPI_ARQOS; 
 wire                            AXI_SLAVE_S_XSPI_ARREADY; 
 wire    [2:0]                    AXI_SLAVE_S_XSPI_ARSIZE; 
 wire                             AXI_SLAVE_S_XSPI_ARVALID; 
 wire    [31:0]                   AXI_SLAVE_S_XSPI_AWADDR; 
 wire                             AXI_SLAVE_S_XSPI_AWAKEUP=1; // 
 wire    [1:0]                    AXI_SLAVE_S_XSPI_AWBURST; 
 wire    [3:0]                    AXI_SLAVE_S_XSPI_AWCACHE; 
 wire                             AXI_SLAVE_S_XSPI_AWID=0;  //
 wire    [7:0]                    AXI_SLAVE_S_XSPI_AWLEN; 
 wire                             AXI_SLAVE_S_XSPI_AWLOCK; 
 wire    [2:0]                    AXI_SLAVE_S_XSPI_AWPROT; 
 wire    [3:0]                    AXI_SLAVE_S_XSPI_AWQOS; 
 wire                            AXI_SLAVE_S_XSPI_AWREADY; 
 wire    [2:0]                    AXI_SLAVE_S_XSPI_AWSIZE; 
 wire                             AXI_SLAVE_S_XSPI_AWVALID; 
 wire                            AXI_SLAVE_S_XSPI_BID; //
 wire                             AXI_SLAVE_S_XSPI_BREADY; 
 wire   [1:0]                    AXI_SLAVE_S_XSPI_BRESP; 
 wire                            AXI_SLAVE_S_XSPI_BVALID; 
 wire   [63:0]                   AXI_SLAVE_S_XSPI_RDATA; 
 wire                            AXI_SLAVE_S_XSPI_RID; //
 wire                            AXI_SLAVE_S_XSPI_RLAST; 
 wire                             AXI_SLAVE_S_XSPI_RREADY; 
 wire   [1:0]                    AXI_SLAVE_S_XSPI_RRESP; 
 wire                            AXI_SLAVE_S_XSPI_RVALID; 
 wire    [63:0]                   AXI_SLAVE_S_XSPI_WDATA; 
 wire                             AXI_SLAVE_S_XSPI_WLAST; 
 wire                            AXI_SLAVE_S_XSPI_WREADY; 
 wire    [7:0]                    AXI_SLAVE_S_XSPI_WSTRB; 
 wire                             AXI_SLAVE_S_XSPI_WVALID; 
 wire                             CPU_CLK=cpu_clock; 
 wire                             CPU_DBGEN=1'b0; 
 wire                             CPU_NIDEN=1'b0; 
 wire                            CPU_PMUSNAPSHOTACK; 
 wire                             CPU_PMUSNAPSHOTREQ=1'b0; 
 wire                            CPU_QACCEPTn; 
 wire                            CPU_QACTIVE; 
 wire                            CPU_QDENY; 
 wire                             CPU_QREQn=1'b1; 
 wire                             CPU_RESETn=!cpu_reset_cold; 
 wire                             CPU_SPIDEN =1'b0; 
 wire                             CPU_SPNIDEN =1'b0; 
 wire                            CPU_nPMUINTERRUPT; 
 wire                             DFTCGEN=1'b0; 
 wire                             DFTCPUDISABLE=1'b0; 
 wire                             DFTPERIPHDISABLE=1'b0; 
 wire    [1:0]                    DFTRSTDISABLE=1'b0; 
 wire                             DFTSYSTEMDISABLE=1'b0; 
 wire                             DFTXSPIDISABLE=1'b0; 
 wire    [3:0]                    ECOREVNUM=4'b0; 
 wire                            PD_0_INTERRUPT; 
 wire                            PD_0_NS_INTERRUPT; 
 wire                            PD_0_PACCEPT; 
 wire   [16:0]                   PD_0_PACTIVE; 
 wire                            PD_0_PDENY; 
 reg                             PD_0_PREQ; // 
 wire    [7:0]                    PD_0_PSTATE=8'h08; 
 wire                             PERIPH_CLK=periph_clk; 
 wire                             PERIPH_DBGEN=1'b0; 
 wire                             PERIPH_NIDEN=1'b0; 
 wire                            PERIPH_PMUSNAPSHOTACK; 
 wire                             PERIPH_PMUSNAPSHOTREQ=1'b0; 
 wire                            PERIPH_QACCEPTn; 
 wire                            PERIPH_QACTIVE; 
 wire                            PERIPH_QDENY; 
 wire                             PERIPH_QREQn=1'b1; 
 wire                             PERIPH_RESETn=periph_rst_n; 
 wire                             PERIPH_SPIDEN =1'b0; 
 wire                             PERIPH_SPNIDEN =1'b0; 
 wire                            PERIPH_nPMUINTERRUPT; 
 wire                             SYSTEM_CLK=system_clk; 
 wire                             SYSTEM_DBGEN=1'b0; 
 wire                             SYSTEM_NIDEN=1'b0; 
 wire                            SYSTEM_PMUSNAPSHOTACK; 
 wire                             SYSTEM_PMUSNAPSHOTREQ=1'b0; 
 wire                            SYSTEM_QACCEPTn; 
 wire                            SYSTEM_QACTIVE; 
 wire                            SYSTEM_QDENY; 
 wire                             SYSTEM_QREQn=1'b1; 
 wire                             SYSTEM_RESETn=system_rst_n; 
 wire                             SYSTEM_SPIDEN =1'b0; 
 wire                             SYSTEM_SPNIDEN =1'b0; 
 wire                            SYSTEM_nPMUINTERRUPT; 
 wire                             S_CPU_CONFIG_ACCESS=0; 
 wire                             S_UART_CONFIG_ACCESS=0; 
 wire                             S_XSPI_CONFIG_ACCESS=0; 
 wire                             XSPI_CLK= xspi_clk; 
 wire                             XSPI_DBGEN=1'b0; 
 wire                             XSPI_NIDEN=1'b0; 
 wire                            XSPI_PMUSNAPSHOTACK; 
 wire                             XSPI_PMUSNAPSHOTREQ=1'b0; 
 wire                            XSPI_QACCEPTn; 
 wire                            XSPI_QACTIVE; 
 wire                            XSPI_QDENY; 
 wire                             XSPI_QREQn=1'b1; 
 wire                             XSPI_RESETn=xspi_rst_n; 
 wire                             XSPI_SPIDEN =1'b0; 
 wire                             XSPI_SPNIDEN =1'b0; 
 wire                            XSPI_nPMUINTERRUPT;

 wire xspi_interrupt, uart_interrupts,qspi_interrupts, qspi_interrupt_valid, mram_interrupt;
wire cpu_pd_ack;
wire [7:0] minion_pd_ack;
assign cpu_pd_req =system_reg_hwif_out.PowerDomainReq.cpu_pd.value && cpu_pd_ack;
wire [7:0] minion_pd_req = system_reg_hwif_out.PowerDomainReq.minion_pd.value & minion_pd_ack;
wire mram_axi_busy;
assign mram_pd_req=system_reg_hwif_out.PowerDomainReq.mram_pd.value & ~mram_axi_busy;

                                                                                                                               
assign power_good_counter_out =system_reg_hwif_out.PowerGood.counter.value;
assign power_good_counter_out_valid =system_reg_hwif_out.PowerGood.counter.swmod;
assign system_reg_hwif_in.PowerGood.counter.next=power_good_counter_in;

// GPIO Muxes.
assign gpio_0_mode_n=(TestMode || system_reg_hwif_out.SystemConfig.osc_out_enable.value);
wire [10:0] periph_enables={
	{2{system_reg_hwif_out.SystemConfig.uart_enable.value}},
	{2{system_reg_hwif_out.SystemConfig.qspi_enable.value}},
	{4{system_reg_hwif_out.SystemConfig.spi_enable.value}},
	{2{system_reg_hwif_out.SystemConfig.i2c_enable.value}},
	gpio_0_mode_n};
wire [10:0]oe_inv=~system_reg_hwif_out.GPIO_OE.gpio_oe.value;
wire [10:0] gpio_i_ena=(oe_inv) & ~periph_enables;
reg [10:0] gpio_i_d;
always@(posedge system_clk) gpio_i_d <= gpio_i;
assign system_reg_hwif_in.GPIO_I.gpio_i.next=gpio_i_ena & gpio_i_d;
wire  gpio_interrupt_int = |(
	system_reg_hwif_out.GPIO_Interrupt_Enable.gpio_interrupt_en.value &
       	gpio_i_ena &(gpio_i_d ^  gpio_i));
assign system_reg_hwif_in.SysInterrupt.gpio_interrupt.hwset=gpio_interrupt_int ;
wire gpio_interrupt= system_reg_hwif_out.SysInterrupt.gpio_interrupt.value;

assign gpio_o[0]=system_reg_hwif_out.GPIO_O.gpio_o.value[0];
assign gpio_oe[0]= gpio_0_mode_n ? 1'b1 :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[0];
wire i2c_enable =  system_reg_hwif_out.SystemConfig.i2c_enable.value;

reg testmode,testmode_d,re_testmode;
assign i2c_scl_i= i2c_enable ? gpio_i[1]:1'b0;
assign gpio_o[1]= i2c_enable ? i2c_scl_o :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[1];
assign gpio_oe[1]= i2c_enable? i2c_scl_oe :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[1];

assign i2c_sda_i= i2c_enable ? gpio_i[2]:1'b0;
assign gpio_o[2]= i2c_enable ? i2c_sda_o :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[2];
assign gpio_oe[2]= i2c_enable ? i2c_sda_oe :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[2];

wire spi_enable = system_reg_hwif_out.SystemConfig.spi_enable.value;
// assign = spi_enable ? gpio_i[3]:1'b1;
assign gpio_o[3]= spi_enable ? qspi_csn :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[3];
assign gpio_oe[3]= spi_enable ? 1'b1 :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[3];

// assign qspi_clk= spi_enable ? gpio_i[4]:1'b1;
assign gpio_o[4]= spi_enable ? qspi_sclk : 
	system_reg_hwif_out.GPIO_O.gpio_o.value[4];
assign gpio_oe[4]= spi_enable ? 1'b1 :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[4];

assign qspi_dq_in[1:0]= spi_enable ? gpio_i[6:5]:1'b1;
assign gpio_o[6:5]= spi_enable ? qspi_dq_out[1:0] :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[6:5];
assign gpio_oe[6:5]= spi_enable ? qspi_dq_out_ena[1:0] :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[6:5];

wire qspi_enable = system_reg_hwif_out.SystemConfig.qspi_enable.value;
assign qspi_dq_in[3:2]= qspi_enable ? gpio_i[8:7]:1'b1;
assign gpio_o[8:7]= qspi_enable ? qspi_dq_out[3:2] :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[8:7];
assign gpio_oe[8:7]= qspi_enable ? qspi_dq_out_ena[3:2] :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[8:7];

//assign qspi_dq_in[3:2]=qspi_enable ? gpio_i[8:7]:1'b1;
wire uart_enable = system_reg_hwif_out.SystemConfig.uart_enable.value;
assign gpio_o[9]= uart_enable ? UART_TX :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[9];

assign gpio_oe[9]= uart_enable ? UART_TX_ENA :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[9];

assign UART_RX=uart_enable ? gpio_i[10]:1'b1;
assign gpio_o[10]= uart_enable ? 1'b0 :
       	system_reg_hwif_out.GPIO_O.gpio_o.value[10];
assign gpio_oe[10]=uart_enable ? 1'b0 :
	system_reg_hwif_out.GPIO_OE.gpio_oe.value[10];

   wire   [31:0]                   AXI_MASTER_M_CPU_REG_ARADDR; 
   wire   [1:0]                    AXI_MASTER_M_CPU_REG_ARBURST; 
   wire   [3:0]                    AXI_MASTER_M_CPU_REG_ARCACHE; 
   wire   [8:0]                    AXI_MASTER_M_CPU_REG_ARID; 
   wire   [7:0]                    AXI_MASTER_M_CPU_REG_ARLEN; 
   wire   [0:0]                    AXI_MASTER_M_CPU_REG_ARLOCK; 
   wire   [2:0]                    AXI_MASTER_M_CPU_REG_ARPROT; 
   wire   [3:0]                    AXI_MASTER_M_CPU_REG_ARQOS; 
  wire                             AXI_MASTER_M_CPU_REG_ARREADY; 
   wire   [2:0]                    AXI_MASTER_M_CPU_REG_ARSIZE; 
   wire                            AXI_MASTER_M_CPU_REG_ARVALID; 
   wire   [31:0]                   AXI_MASTER_M_CPU_REG_AWADDR; 
   wire                            AXI_MASTER_M_CPU_REG_AWAKEUP; 
   wire   [1:0]                    AXI_MASTER_M_CPU_REG_AWBURST; 
   wire   [3:0]                    AXI_MASTER_M_CPU_REG_AWCACHE; 
   wire   [8:0]                    AXI_MASTER_M_CPU_REG_AWID; 
   wire   [7:0]                    AXI_MASTER_M_CPU_REG_AWLEN; 
   wire   [0:0]                    AXI_MASTER_M_CPU_REG_AWLOCK; 
   wire   [2:0]                    AXI_MASTER_M_CPU_REG_AWPROT; 
   wire   [3:0]                    AXI_MASTER_M_CPU_REG_AWQOS; 
  wire                             AXI_MASTER_M_CPU_REG_AWREADY; 
   wire   [2:0]                    AXI_MASTER_M_CPU_REG_AWSIZE; 
   wire                            AXI_MASTER_M_CPU_REG_AWVALID; 
  wire    [8:0]                    AXI_MASTER_M_CPU_REG_BID; 
   wire                            AXI_MASTER_M_CPU_REG_BREADY; 
  wire    [1:0]                    AXI_MASTER_M_CPU_REG_BRESP; 
  wire                             AXI_MASTER_M_CPU_REG_BVALID; 
  wire    [63:0]                   AXI_MASTER_M_CPU_REG_RDATA; 
  wire    [8:0]                    AXI_MASTER_M_CPU_REG_RID; 
  wire                             AXI_MASTER_M_CPU_REG_RLAST; 
   wire                            AXI_MASTER_M_CPU_REG_RREADY; 
  wire    [1:0]                    AXI_MASTER_M_CPU_REG_RRESP; 
  wire                             AXI_MASTER_M_CPU_REG_RVALID; 
   wire   [63:0]                   AXI_MASTER_M_CPU_REG_WDATA; 
   wire                            AXI_MASTER_M_CPU_REG_WLAST; 
  wire                             AXI_MASTER_M_CPU_REG_WREADY; 
   wire   [7:0]                    AXI_MASTER_M_CPU_REG_WSTRB; 
   wire                            AXI_MASTER_M_CPU_REG_WVALID; 

axi2apb_64 cpu_axi2apb(
	.CLK(cpu_clock),
	.RST_N(~cpu_reset_cold),
	.AXI4_awvalid(AXI_MASTER_M_CPU_REG_AWVALID),
	.AXI4_awid(AXI_MASTER_M_CPU_REG_AWID),
	.AXI4_awaddr(AXI_MASTER_M_CPU_REG_AWADDR),
	.AXI4_awlen(AXI_MASTER_M_CPU_REG_AWLEN),
	.AXI4_awsize(AXI_MASTER_M_CPU_REG_AWSIZE),
	.AXI4_awburst(AXI_MASTER_M_CPU_REG_AWBURST),
	.AXI4_awlock(AXI_MASTER_M_CPU_REG_AWLOCK),
	.AXI4_awcache(AXI_MASTER_M_CPU_REG_AWCACHE),
	.AXI4_awprot(AXI_MASTER_M_CPU_REG_AWPROT),
	.AXI4_awqos(AXI_MASTER_M_CPU_REG_AWQOS),
	.AXI4_awregion(4'b0),
	.AXI4_awready(AXI_MASTER_M_CPU_REG_AWREADY),
	.AXI4_wvalid(AXI_MASTER_M_CPU_REG_WVALID),
	.AXI4_wdata(AXI_MASTER_M_CPU_REG_WDATA),
	.AXI4_wstrb(AXI_MASTER_M_CPU_REG_WSTRB),
	.AXI4_wlast(AXI_MASTER_M_CPU_REG_WLAST),
	.AXI4_wready(AXI_MASTER_M_CPU_REG_WREADY),
	.AXI4_bvalid(AXI_MASTER_M_CPU_REG_BVALID),
	.AXI4_bid(AXI_MASTER_M_CPU_REG_BID),
	.AXI4_bresp(AXI_MASTER_M_CPU_REG_BRESP),
	.AXI4_bready(AXI_MASTER_M_CPU_REG_BREADY),
	.AXI4_arvalid(AXI_MASTER_M_CPU_REG_ARVALID),
	.AXI4_arid(AXI_MASTER_M_CPU_REG_ARID),
	.AXI4_araddr(AXI_MASTER_M_CPU_REG_ARADDR),
	.AXI4_arlen(AXI_MASTER_M_CPU_REG_ARLEN),
	.AXI4_arsize(AXI_MASTER_M_CPU_REG_ARSIZE),
	.AXI4_arburst(AXI_MASTER_M_CPU_REG_ARBURST),
	.AXI4_arlock(AXI_MASTER_M_CPU_REG_ARLOCK),
	.AXI4_arcache(AXI_MASTER_M_CPU_REG_ARCACHE),
	.AXI4_arprot(AXI_MASTER_M_CPU_REG_ARPROT),
	.AXI4_arqos(AXI_MASTER_M_CPU_REG_ARQOS),
	.AXI4_arregion(4'b0),
	.AXI4_arready(AXI_MASTER_M_CPU_REG_ARREADY),
	.AXI4_rvalid(AXI_MASTER_M_CPU_REG_RVALID),
	.AXI4_rid(AXI_MASTER_M_CPU_REG_RID),
	.AXI4_rdata(AXI_MASTER_M_CPU_REG_RDATA),
	.AXI4_rresp(AXI_MASTER_M_CPU_REG_RRESP),
	.AXI4_rlast(AXI_MASTER_M_CPU_REG_RLAST),
	.AXI4_rready(AXI_MASTER_M_CPU_REG_RREADY),
	.APB_PADDR(APB_MASTER_M_CPU_REG_PADDR),
	.APB_PROT(),
	.APB_PENABLE(APB_MASTER_M_CPU_REG_PENABLE),
	.APB_PWRITE(APB_MASTER_M_CPU_REG_PWRITE),
	.APB_PWDATA(APB_MASTER_M_CPU_REG_PWDATA),
	.APB_PSTRB(),
	.APB_PSEL(APB_MASTER_M_CPU_REG_PSEL),
	.APB_PREADY(APB_MASTER_M_CPU_REG_PREADY),
	.APB_PRDATA(APB_MASTER_M_CPU_REG_PRDATA),
	.APB_PSLVERR(APB_MASTER_M_CPU_REG_PSLVERR)
);
cpu_subsystem_top cpu_ss (
	  // System signals
	  .clock(cpu_clock),
	  .clock_ext(xspi_clk),
	  .reset_cold(cpu_reset_cold),
	  .reset_warm(cpu_reset_warm),

	  // Power control
	  .cpu_pd_req(system_reg_hwif_out.PowerDomainReq.cpu_pd.value),
	  .cpu_pd_ack(cpu_pd_ack),
	  .minion_pd_req(system_reg_hwif_out.PowerDomainReq.minion_pd.value),
	  .minion_pd_ack(minion_pd_ack),

	  // External configuration

	  // Interrupt requests
	  .plic_irq({gpio_interrupt,
		  xspi_interrupt,
		  system_reg_hwif_out.SystemConfig.sys_interrupt_enable.value &&
		                system_reg_hwif_out.SysInterrupt.interrupt.value,
		  uart_interrupts,
		  qspi_interrupt_valid && qspi_interrupts,
		  mram_interrupt
		  }), // MRAM Interrupt should be in LSB.
	  //Assumption that signals are level signals.

	  // AXI MASTER INTERFACE
	  // Read address channel
	  .axi_ARID(AXI_SLAVE_S_CPU_ARID),
	  .axi_ARADDR(AXI_SLAVE_S_CPU_ARADDR),
	  .axi_ARLEN(AXI_SLAVE_S_CPU_ARLEN),
	  .axi_ARSIZE(AXI_SLAVE_S_CPU_ARSIZE),
	  .axi_ARBURST(AXI_SLAVE_S_CPU_ARBURST),
	  .axi_ARLOCK(AXI_SLAVE_S_CPU_ARLOCK),
	  .axi_ARCACHE(AXI_SLAVE_S_CPU_ARCACHE),
	  .axi_ARPROT(AXI_SLAVE_S_CPU_ARPROT),
	  .axi_ARVALID(AXI_SLAVE_S_CPU_ARVALID),
	  .axi_ARREADY(AXI_SLAVE_S_CPU_ARREADY),
	  // Read data channel
	  .axi_RID(AXI_SLAVE_S_CPU_RID),
	  .axi_RDATA(AXI_SLAVE_S_CPU_RDATA),
	  .axi_RRESP(AXI_SLAVE_S_CPU_RRESP),
	  .axi_RLAST(AXI_SLAVE_S_CPU_RLAST),
	  .axi_RVALID(AXI_SLAVE_S_CPU_RVALID),
	  .axi_RREADY(AXI_SLAVE_S_CPU_RREADY),
	  // Write address channel
	  .axi_AWID(AXI_SLAVE_S_CPU_AWID),
	  .axi_AWADDR(AXI_SLAVE_S_CPU_AWADDR),
	  .axi_AWLEN(AXI_SLAVE_S_CPU_AWLEN),
	  .axi_AWSIZE(AXI_SLAVE_S_CPU_AWSIZE),
	  .axi_AWBURST(AXI_SLAVE_S_CPU_AWBURST),
	  .axi_AWLOCK(AXI_SLAVE_S_CPU_AWLOCK),
	  .axi_AWCACHE(AXI_SLAVE_S_CPU_AWCACHE),
	  .axi_AWPROT(AXI_SLAVE_S_CPU_AWPROT),
	  .axi_AWVALID(AXI_SLAVE_S_CPU_AWVALID),
	  .axi_AWREADY(AXI_SLAVE_S_CPU_AWREADY),
	  // Write data channel
	  .axi_WDATA(AXI_SLAVE_S_CPU_WDATA),
	  .axi_WSTRB(AXI_SLAVE_S_CPU_WSTRB),
	  .axi_WLAST(AXI_SLAVE_S_CPU_WLAST),
	  .axi_WVALID(AXI_SLAVE_S_CPU_WVALID),
	  .axi_WREADY(AXI_SLAVE_S_CPU_WREADY),
	  // Write response channel
	  .axi_BID(AXI_SLAVE_S_CPU_BID),
	  .axi_BRESP(AXI_SLAVE_S_CPU_BRESP),
	  .axi_BVALID(AXI_SLAVE_S_CPU_BVALID),
	  .axi_BREADY(AXI_SLAVE_S_CPU_BREADY),
	  // APB SLAVE INTERFACE
	  .apb_psel(APB_MASTER_M_CPU_REG_PSEL),
	  .apb_penable(APB_MASTER_M_CPU_REG_PENABLE),
	  .apb_pwrite(APB_MASTER_M_CPU_REG_PWRITE),
	  .apb_paddr(APB_MASTER_M_CPU_REG_PADDR),
	  .apb_pwdata(APB_MASTER_M_CPU_REG_PWDATA),
	  .apb_prdata(APB_MASTER_M_CPU_REG_PRDATA),
	  .apb_pready(APB_MASTER_M_CPU_REG_PREADY),
	  .apb_pslverr(APB_MASTER_M_CPU_REG_PSLVERR)
);


wire mram_m_awvalid_awvalid;
wire [31 : 0] mram_m_awvalid_awaddr;
wire [1 : 0] mram_m_awvalid_awsize;
wire [2 : 0] mram_m_awvalid_awprot;
wire mram_awready;
wire mram_m_wvalid_wvalid;
wire [63 : 0] mram_m_wvalid_wdata;
wire [7 : 0] mram_m_wvalid_wstrb;
wire mram_wready;
wire mram_bvalid;
wire [1 : 0] mram_bresp;
wire mram_m_bready_bready;
wire mram_m_arvalid_arvalid;
wire [31 : 0] mram_m_arvalid_araddr;
wire [1 : 0] mram_m_arvalid_arsize;
wire [2 : 0] mram_m_arvalid_arprot;
wire mram_arready;
wire mram_rvalid;
wire [1 : 0] mram_rresp;
wire [63 : 0] mram_rdata;
wire mram_m_rready_rready;

always@(posedge system_clk or negedge system_rst_n)
	if(!system_rst_n)begin 
		testmode <= TestMode;
		testmode_d <= 1'b0;
	end else begin
		testmode_d <= testmode;
	end
assign re_testmode = testmode & ~testmode_d;
assign system_reg_hwif_in.SoftReset.cpu_warm_reset.hwset = re_testmode;
assign cpu_warm_reset_req = system_reg_hwif_out.SoftReset.cpu_warm_reset.value || re_testmode;
axi2axil_64 axi4_to_axil4_mram(
.CLK(mram_clk),
.RST_N(mram_rst_b),
.AXI4_AWVALID(AXI_MASTER_M_MRAM_REG_AWVALID),
.AXI4_AWADDR(AXI_MASTER_M_MRAM_REG_AWADDR),
.AXI4_AWSIZE(AXI_MASTER_M_MRAM_REG_AWSIZE),
.AXI4_AWPROT(AXI_MASTER_M_MRAM_REG_AWPROT),
.AXI4_AWLEN(AXI_MASTER_M_MRAM_REG_AWLEN),
.AXI4_AWBURST(AXI_MASTER_M_MRAM_REG_AWBURST),
.AXI4_AWID(AXI_MASTER_M_MRAM_REG_AWID),
.AXI4_AWREADY(AXI_MASTER_M_MRAM_REG_AWREADY),
.AXI4_WVALID(AXI_MASTER_M_MRAM_REG_WVALID),
.AXI4_WDATA(AXI_MASTER_M_MRAM_REG_WDATA),
.AXI4_WSTRB(AXI_MASTER_M_MRAM_REG_WSTRB),
.AXI4_WLAST(AXI_MASTER_M_MRAM_REG_WLAST),
.AXI4_WID(AXI_MASTER_M_MRAM_REG_AWID),
.AXI4_WREADY(AXI_MASTER_M_MRAM_REG_WREADY),
.AXI4_BVALID(AXI_MASTER_M_MRAM_REG_BVALID),
.AXI4_BRESP(AXI_MASTER_M_MRAM_REG_BRESP),
.AXI4_BID(AXI_MASTER_M_MRAM_REG_BID),
.AXI4_BREADY(AXI_MASTER_M_MRAM_REG_BREADY),
.AXI4_ARVALID(AXI_MASTER_M_MRAM_REG_ARVALID),
.AXI4_ARADDR(AXI_MASTER_M_MRAM_REG_ARADDR),
.AXI4_ARSIZE(AXI_MASTER_M_MRAM_REG_ARSIZE),
.AXI4_ARPROT(AXI_MASTER_M_MRAM_REG_ARPROT),
.AXI4_ARLEN(AXI_MASTER_M_MRAM_REG_ARLEN),
.AXI4_ARBURST(AXI_MASTER_M_MRAM_REG_ARBURST),
.AXI4_ARID(AXI_MASTER_M_MRAM_REG_ARID),
.AXI4_ARREADY(AXI_MASTER_M_MRAM_REG_ARREADY),
.AXI4_RVALID(AXI_MASTER_M_MRAM_REG_RVALID),
.AXI4_RRESP(AXI_MASTER_M_MRAM_REG_RRESP),
.AXI4_RDATA(AXI_MASTER_M_MRAM_REG_RDATA),
.AXI4_RLAST(AXI_MASTER_M_MRAM_REG_RLAST),
.AXI4_RID(AXI_MASTER_M_MRAM_REG_RID),
.AXI4_RREADY(AXI_MASTER_M_MRAM_REG_RREADY),
.AXI4L_awvalid(mram_m_awvalid_awvalid),
.AXI4L_awaddr(mram_m_awvalid_awaddr),
.AXI4L_awprot(mram_m_awvalid_awprot),
.AXI4L_awsize(mram_m_awvalid_awsize), //
.AXI4L_m_awready_awready(mram_awready),
.AXI4L_wvalid(mram_m_wvalid_wvalid),
.AXI4L_wdata(mram_m_wvalid_wdata),
.AXI4L_wstrb(mram_m_wvalid_wstrb),
.AXI4L_m_wready_wready(mram_wready),
.AXI4L_m_bvalid_bvalid(mram_bvalid),
.AXI4L_m_bvalid_bresp(mram_bresp),
.AXI4L_bready(mram_m_bready_bready),
.AXI4L_arvalid(mram_m_arvalid_arvalid),
.AXI4L_araddr(mram_m_arvalid_araddr),
.AXI4L_arprot(mram_m_arvalid_arprot),
.AXI4L_arsize(mram_m_arvalid_arsize), //
.AXI4L_m_arready_arready(mram_arready),
.AXI4L_m_rvalid_rvalid(mram_rvalid),
.AXI4L_m_rvalid_rresp(mram_rresp),
.AXI4L_m_rvalid_rdata(mram_rdata),
.AXI4L_rready(mram_m_rready_rready)
);
axi2mram_et_wrapper   axi2mram_wrapper(
	.clk(mram_clk),
	.rst_b(mram_rst_b),
	.reg_clk(mram_clk),
	.reg_rst_b(mram_rst_b),
	.mram_rst_b(system_reg_hwif_out.SoftReset.mram_rst_b.value),//
	.dsleep(system_reg_hwif_out.PowerDomainReq.mram_dsleep_en.value),
	.nvsram_startup_bypass(system_reg_hwif_out.SystemConfig.mram_startup_bypass.value),
	.cpu_intr(mram_interrupt),
	.axi_busy(mram_axi_busy),

    // ---------------------------------------------------------------------
    .s_axil_treg_awready(mram_awready),
    .s_axil_treg_awvalid(mram_m_awvalid_awvalid),
    .s_axil_treg_awaddr(mram_m_awvalid_awaddr[10:0]),
    .s_axil_treg_awprot(mram_m_awvalid_awprot),
    .s_axil_treg_wready(mram_wready),
    .s_axil_treg_wvalid(mram_m_wvalid_wvalid),
    .s_axil_treg_wdata(mram_m_wvalid_wdata),
    .s_axil_treg_wstrb(mram_m_wvalid_wstrb),
    .s_axil_treg_bready(mram_m_bready_bready),
    .s_axil_treg_bvalid(mram_bvalid),
    .s_axil_treg_bresp(mram_bresp),
    .s_axil_treg_arready(mram_arready),
    .s_axil_treg_arvalid(mram_m_arvalid_arvalid),
    .s_axil_treg_araddr(mram_m_arvalid_araddr[10:0]),
    .s_axil_treg_arprot(mram_m_arvalid_arprot),
    .s_axil_treg_rready(mram_m_rready_rready),
    .s_axil_treg_rvalid(mram_rvalid),
    .s_axil_treg_rdata(mram_rdata),
    .s_axil_treg_rresp(mram_rresp),




	    // ---------------------------------------------------------------------
	    // Analog test pins are shared between all MRAM wrappers.  Each instance
	    // connects to the same ``ANATEST0`` and ``ANATEST1`` lines.
	.ANATEST0(ANATEST0),
	.ANATEST1(ANATEST1),

	    // ---------------------------------------------------------------------
	    // AXI slave interface
	.s_axi_awid(AXI_MASTER_M_MRAM_AWID),
	.s_axi_awaddr({2'b0,AXI_MASTER_M_MRAM_AWADDR[29:0]}),
	.s_axi_awlen(AXI_MASTER_M_MRAM_AWLEN),
	.s_axi_awsize(AXI_MASTER_M_MRAM_AWSIZE),
	.s_axi_awburst(AXI_MASTER_M_MRAM_AWBURST),
	.s_axi_awlock(AXI_MASTER_M_MRAM_AWLOCK),
	.s_axi_awcache(AXI_MASTER_M_MRAM_AWCACHE),
	.s_axi_awqos(AXI_MASTER_M_MRAM_AWQOS),
	.s_axi_awregion(4'b0), //TODO//
	.s_axi_awprot(AXI_MASTER_M_MRAM_AWPROT),
	.s_axi_awvalid(AXI_MASTER_M_MRAM_AWVALID),
	.s_axi_awready(AXI_MASTER_M_MRAM_AWREADY),
	.s_axi_wdata(AXI_MASTER_M_MRAM_WDATA),
	.s_axi_wstrb(AXI_MASTER_M_MRAM_WSTRB),
	.s_axi_wlast(AXI_MASTER_M_MRAM_WLAST),
	.s_axi_wvalid(AXI_MASTER_M_MRAM_WVALID),
	.s_axi_wready(AXI_MASTER_M_MRAM_WREADY),
	.s_axi_bid(AXI_MASTER_M_MRAM_BID),
	.s_axi_bresp(AXI_MASTER_M_MRAM_BRESP),
	.s_axi_bvalid(AXI_MASTER_M_MRAM_BVALID),
	.s_axi_bready(AXI_MASTER_M_MRAM_BREADY),
	.s_axi_arid(AXI_MASTER_M_MRAM_ARID),
	.s_axi_araddr({2'b0,AXI_MASTER_M_MRAM_ARADDR[29:0]}),
	.s_axi_arlen(AXI_MASTER_M_MRAM_ARLEN),
	.s_axi_arsize(AXI_MASTER_M_MRAM_ARSIZE),
	.s_axi_arburst(AXI_MASTER_M_MRAM_ARBURST),
	.s_axi_arlock(AXI_MASTER_M_MRAM_ARLOCK),
	.s_axi_arcache(AXI_MASTER_M_MRAM_ARCACHE),
	.s_axi_arqos(AXI_MASTER_M_MRAM_ARQOS),
	.s_axi_arregion(4'b0), // TODO

	.s_axi_arprot(AXI_MASTER_M_MRAM_ARPROT),
	.s_axi_arvalid(AXI_MASTER_M_MRAM_ARVALID),
	.s_axi_arready(AXI_MASTER_M_MRAM_ARREADY),
	.s_axi_rid(AXI_MASTER_M_MRAM_RID),
	.s_axi_rdata(AXI_MASTER_M_MRAM_RDATA),
	.s_axi_rresp(AXI_MASTER_M_MRAM_RRESP),
	.s_axi_rlast(AXI_MASTER_M_MRAM_RLAST),
	.s_axi_rvalid(AXI_MASTER_M_MRAM_RVALID),
	.s_axi_rready(AXI_MASTER_M_MRAM_RREADY)
);
wire s_axil_awready;
wire s_axil_awvalid;
wire [31:0] s_axil_awaddr;
wire [2:0] s_axil_awprot;
wire s_axil_wready;
wire s_axil_wvalid;
wire [63:0] s_axil_wdata;
wire [7:0]s_axil_wstrb;
wire s_axil_bready;
wire s_axil_bvalid;
wire [1:0] s_axil_bresp;
wire s_axil_arready;
wire s_axil_arvalid;
wire [31:0] s_axil_araddr;
wire [2:0] s_axil_arprot;
wire s_axil_rready;
wire s_axil_rvalid;
wire [63:0] s_axil_rdata;
wire [1:0] s_axil_rresp;

axi2axil_64 axi4_to_axil4_systemReg(
.CLK(system_clk),
.RST_N(system_rst_n),
.AXI4_AWVALID(AXI_MASTER_M_SYSTEM_REG_AWVALID),
.AXI4_AWADDR(AXI_MASTER_M_SYSTEM_REG_AWADDR),
.AXI4_AWSIZE(AXI_MASTER_M_SYSTEM_REG_AWSIZE),
.AXI4_AWPROT(AXI_MASTER_M_SYSTEM_REG_AWPROT),
.AXI4_AWLEN(AXI_MASTER_M_SYSTEM_REG_AWLEN),
.AXI4_AWBURST(AXI_MASTER_M_SYSTEM_REG_AWBURST),
.AXI4_AWID(AXI_MASTER_M_SYSTEM_REG_AWID),
.AXI4_AWREADY(AXI_MASTER_M_SYSTEM_REG_AWREADY),
.AXI4_WVALID(AXI_MASTER_M_SYSTEM_REG_WVALID),
.AXI4_WDATA(AXI_MASTER_M_SYSTEM_REG_WDATA),
.AXI4_WSTRB(AXI_MASTER_M_SYSTEM_REG_WSTRB),
.AXI4_WLAST(AXI_MASTER_M_SYSTEM_REG_WLAST),
.AXI4_WID(AXI_MASTER_M_SYSTEM_REG_AWID),
.AXI4_WREADY(AXI_MASTER_M_SYSTEM_REG_WREADY),
.AXI4_BVALID(AXI_MASTER_M_SYSTEM_REG_BVALID),
.AXI4_BRESP(AXI_MASTER_M_SYSTEM_REG_BRESP),
.AXI4_BID(AXI_MASTER_M_SYSTEM_REG_BID),
.AXI4_BREADY(AXI_MASTER_M_SYSTEM_REG_BREADY),
.AXI4_ARVALID(AXI_MASTER_M_SYSTEM_REG_ARVALID),
.AXI4_ARADDR(AXI_MASTER_M_SYSTEM_REG_ARADDR),
.AXI4_ARSIZE(AXI_MASTER_M_SYSTEM_REG_ARSIZE),
.AXI4_ARPROT(AXI_MASTER_M_SYSTEM_REG_ARPROT),
.AXI4_ARLEN(AXI_MASTER_M_SYSTEM_REG_ARLEN),
.AXI4_ARBURST(AXI_MASTER_M_SYSTEM_REG_ARBURST),
.AXI4_ARID(AXI_MASTER_M_SYSTEM_REG_ARID),
.AXI4_ARREADY(AXI_MASTER_M_SYSTEM_REG_ARREADY),
.AXI4_RVALID(AXI_MASTER_M_SYSTEM_REG_RVALID),
.AXI4_RRESP(AXI_MASTER_M_SYSTEM_REG_RRESP),
.AXI4_RDATA(AXI_MASTER_M_SYSTEM_REG_RDATA),
.AXI4_RLAST(AXI_MASTER_M_SYSTEM_REG_RLAST),
.AXI4_RID(AXI_MASTER_M_SYSTEM_REG_RID),
.AXI4_RREADY(AXI_MASTER_M_SYSTEM_REG_RREADY),
.AXI4L_awvalid(s_axil_awvalid),
.AXI4L_awaddr(s_axil_awaddr),
.AXI4L_awprot(s_axil_awprot),
.AXI4L_awsize(), //
.AXI4L_m_awready_awready(s_axil_awready),
.AXI4L_wvalid(s_axil_wvalid),
.AXI4L_wdata(s_axil_wdata),
.AXI4L_wstrb(s_axil_wstrb),
.AXI4L_m_wready_wready(s_axil_wready),
.AXI4L_m_bvalid_bvalid(s_axil_bvalid),
.AXI4L_m_bvalid_bresp(s_axil_bresp),
.AXI4L_bready(s_axil_bready),
.AXI4L_arvalid(s_axil_arvalid),
.AXI4L_araddr(s_axil_araddr),
.AXI4L_arprot(s_axil_arprot),
.AXI4L_arsize(), //
.AXI4L_m_arready_arready(s_axil_arready),
.AXI4L_m_rvalid_rvalid(s_axil_rvalid),
.AXI4L_m_rvalid_rresp(s_axil_rresp),
.AXI4L_m_rvalid_rdata({32'b0,s_axil_rdata[31:0]}),
.AXI4L_rready(s_axil_rready)
);

reg re_system_reset;
System_Reg system_registers (
	.clk(system_reg_clk),
	.arst_n(system_reg_arst_n),

.s_axil_awready(s_axil_awready),
.s_axil_awvalid(s_axil_awvalid),
.s_axil_awaddr(s_axil_awaddr[7:0]),
.s_axil_awprot(s_axil_awprot),
.s_axil_wready(s_axil_wready),
.s_axil_wvalid(s_axil_wvalid),
.s_axil_wdata(s_axil_wdata[31:0]),
.s_axil_wstrb(s_axil_wstrb[3:0]),
.s_axil_bready(s_axil_bready),
.s_axil_bvalid(s_axil_bvalid),
.s_axil_bresp(s_axil_bresp),
.s_axil_arready(s_axil_arready),
.s_axil_arvalid(s_axil_arvalid),
.s_axil_araddr(s_axil_araddr[7:0]),
.s_axil_arprot(s_axil_arprot),
.s_axil_rready(s_axil_rready),
.s_axil_rvalid(s_axil_rvalid),
.s_axil_rdata(s_axil_rdata[31:0]),
.s_axil_rresp(s_axil_rresp),

	.hwif_in(system_reg_hwif_in),
	.hwif_out(system_reg_hwif_out)
);

// Temperature sensor
tsense_wrap u_tsense (
	.sys_clk (system_reg_clk),
	.rst_n   (system_reg_arst_n),
	.conv    (system_reg_hwif_out.tsense_ctrl.conv.value),
	.sen_sel ({system_reg_hwif_out.tsense_ctrl.sen_en.value,
	           system_reg_hwif_out.tsense_ctrl.sen_sel.value}),
	.clk_div (system_reg_hwif_out.tsense_ctrl.clk_div.value),
	.data    (system_reg_hwif_in.tsense_status.data.next),
	.valid   (system_reg_hwif_in.tsense_status.valid.next),
	.conv_b  (system_reg_hwif_in.tsense_status.conv_b.next)
);

mkRomRam sram_wrapper(
	.axis_araddr(AXI_MASTER_M_SRAM_ARADDR), 
	.axis_arburst(AXI_MASTER_M_SRAM_ARBURST), 
	.axis_arcache(AXI_MASTER_M_SRAM_ARCACHE), 
	.axis_arid(AXI_MASTER_M_SRAM_ARID), 
	.axis_arlen(AXI_MASTER_M_SRAM_ARLEN), 
	.axis_arlock(AXI_MASTER_M_SRAM_ARLOCK), 
	.axis_arprot(AXI_MASTER_M_SRAM_ARPROT), 
	.axis_arqos(AXI_MASTER_M_SRAM_ARQOS), 
	.axis_arregion(4'd0),
	.axis_arready(AXI_MASTER_M_SRAM_ARREADY), 
	.axis_arsize(AXI_MASTER_M_SRAM_ARSIZE), 
	.axis_arvalid(AXI_MASTER_M_SRAM_ARVALID), 
	.axis_awaddr(AXI_MASTER_M_SRAM_AWADDR), 
	//.AXI_MASTER_M_SRAM_AWAKEUP(AXI_MASTER_M_SRAM_AWAKEUP), 
	.axis_awburst(AXI_MASTER_M_SRAM_AWBURST), 
	.axis_awcache(AXI_MASTER_M_SRAM_AWCACHE), 
	.axis_awid(AXI_MASTER_M_SRAM_AWID), 
	.axis_awlen(AXI_MASTER_M_SRAM_AWLEN), 
	.axis_awlock(AXI_MASTER_M_SRAM_AWLOCK), 
	.axis_awprot(AXI_MASTER_M_SRAM_AWPROT), 
	.axis_awqos(AXI_MASTER_M_SRAM_AWQOS), 
	.axis_awready(AXI_MASTER_M_SRAM_AWREADY), 
	.axis_awregion(4'b0),
	.axis_awsize(AXI_MASTER_M_SRAM_AWSIZE), 
	.axis_awvalid(AXI_MASTER_M_SRAM_AWVALID), 
	.axis_bid(AXI_MASTER_M_SRAM_BID), 
	.axis_bready(AXI_MASTER_M_SRAM_BREADY), 
	.axis_bresp(AXI_MASTER_M_SRAM_BRESP), 
	.axis_bvalid(AXI_MASTER_M_SRAM_BVALID), 
	.axis_rdata(AXI_MASTER_M_SRAM_RDATA), 
	.axis_rid(AXI_MASTER_M_SRAM_RID), 
	.axis_rlast(AXI_MASTER_M_SRAM_RLAST), 
	.axis_rready(AXI_MASTER_M_SRAM_RREADY), 
	.axis_rresp(AXI_MASTER_M_SRAM_RRESP), 
	.axis_rvalid(AXI_MASTER_M_SRAM_RVALID), 
	.axis_wdata(AXI_MASTER_M_SRAM_WDATA), 
	.axis_wlast(AXI_MASTER_M_SRAM_WLAST), 
	.axis_wready(AXI_MASTER_M_SRAM_WREADY), 
	.axis_wstrb(AXI_MASTER_M_SRAM_WSTRB), 
	.axis_wvalid(AXI_MASTER_M_SRAM_WVALID), 
	.ram_dsleep(system_reg_hwif_out.PowerDomainReq.cpu_ram_powerdown.value),
	.rom_dsleep(system_reg_hwif_out.PowerDomainReq.cpu_rom_powerdown.value),
	.CLK(sram_clk),
	.RST_N(sram_rst_n)
);



wire qspi_m_awvalid_awvalid;
wire [31 : 0] qspi_m_awvalid_awaddr;
wire [1 : 0] qspi_m_awvalid_awsize;
wire [2 : 0] qspi_m_awvalid_awprot;
wire qspi_awready;
wire qspi_m_wvalid_wvalid;
wire [63 : 0] qspi_m_wvalid_wdata;
wire [7 : 0] qspi_m_wvalid_wstrb;
wire qspi_wready;
wire qspi_bvalid;
wire [1 : 0] qspi_bresp;
wire qspi_m_bready_bready;
wire qspi_m_arvalid_arvalid;
wire [31 : 0] qspi_m_arvalid_araddr;
wire [1 : 0] qspi_m_arvalid_arsize;
wire [2 : 0] qspi_m_arvalid_arprot;
wire qspi_arready;
wire qspi_rvalid;
wire [1 : 0] qspi_rresp;
wire [63 : 0] qspi_rdata;
wire qspi_m_rready_rready;

axi2axil_64 axi4_to_axil4_qspi(
.CLK(qspi_clk),
.RST_N(qspi_rst_n),
.AXI4_AWVALID(AXI_MASTER_M_SPI_REG_AWVALID),
.AXI4_AWADDR(AXI_MASTER_M_SPI_REG_AWADDR),
.AXI4_AWSIZE(AXI_MASTER_M_SPI_REG_AWSIZE),
.AXI4_AWPROT(AXI_MASTER_M_SPI_REG_AWPROT),
.AXI4_AWLEN(AXI_MASTER_M_SPI_REG_AWLEN),
.AXI4_AWBURST(AXI_MASTER_M_SPI_REG_AWBURST),
.AXI4_AWID(AXI_MASTER_M_SPI_REG_AWID),
.AXI4_AWREADY(AXI_MASTER_M_SPI_REG_AWREADY),
.AXI4_WVALID(AXI_MASTER_M_SPI_REG_WVALID),
.AXI4_WDATA(AXI_MASTER_M_SPI_REG_WDATA),
.AXI4_WSTRB(AXI_MASTER_M_SPI_REG_WSTRB),
.AXI4_WLAST(AXI_MASTER_M_SPI_REG_WLAST),
.AXI4_WID(9'd0),
.AXI4_WREADY(AXI_MASTER_M_SPI_REG_WREADY),
.AXI4_BVALID(AXI_MASTER_M_SPI_REG_BVALID),
.AXI4_BRESP(AXI_MASTER_M_SPI_REG_BRESP),
.AXI4_BID(AXI_MASTER_M_SPI_REG_BID),
.AXI4_BREADY(AXI_MASTER_M_SPI_REG_BREADY),
.AXI4_ARVALID(AXI_MASTER_M_SPI_REG_ARVALID),
.AXI4_ARADDR(AXI_MASTER_M_SPI_REG_ARADDR),
.AXI4_ARSIZE(AXI_MASTER_M_SPI_REG_ARSIZE),
.AXI4_ARPROT(AXI_MASTER_M_SPI_REG_ARPROT),
.AXI4_ARLEN(AXI_MASTER_M_SPI_REG_ARLEN),
.AXI4_ARBURST(AXI_MASTER_M_SPI_REG_ARBURST),
.AXI4_ARID(AXI_MASTER_M_SPI_REG_ARID),
.AXI4_ARREADY(AXI_MASTER_M_SPI_REG_ARREADY),
.AXI4_RVALID(AXI_MASTER_M_SPI_REG_RVALID),
.AXI4_RRESP(AXI_MASTER_M_SPI_REG_RRESP),
.AXI4_RDATA(AXI_MASTER_M_SPI_REG_RDATA),
.AXI4_RLAST(AXI_MASTER_M_SPI_REG_RLAST),
.AXI4_RID(AXI_MASTER_M_SPI_REG_RID),
.AXI4_RREADY(AXI_MASTER_M_SPI_REG_RREADY),
.AXI4L_awvalid(qspi_m_awvalid_awvalid),
.AXI4L_awaddr(qspi_m_awvalid_awaddr),
.AXI4L_awprot(qspi_m_awvalid_awprot),
.AXI4L_awsize(qspi_m_awvalid_awsize),
.AXI4L_m_awready_awready(qspi_awready),
.AXI4L_wvalid(qspi_m_wvalid_wvalid),
.AXI4L_wdata(qspi_m_wvalid_wdata),
.AXI4L_wstrb(qspi_m_wvalid_wstrb),
.AXI4L_m_wready_wready(qspi_wready),
.AXI4L_m_bvalid_bvalid(qspi_bvalid),
.AXI4L_m_bvalid_bresp(qspi_bresp),
.AXI4L_bready(qspi_m_bready_bready),
.AXI4L_arvalid(qspi_m_arvalid_arvalid),
.AXI4L_araddr(qspi_m_arvalid_araddr),
.AXI4L_arprot(qspi_m_arvalid_arprot),
.AXI4L_arsize(qspi_m_arvalid_arsize),
.AXI4L_m_arready_arready(qspi_arready),
.AXI4L_m_rvalid_rvalid(qspi_rvalid),
.AXI4L_m_rvalid_rresp(qspi_rresp),
.AXI4L_m_rvalid_rdata(qspi_rdata),
.AXI4L_rready(qspi_m_rready_rready)
);
qspi_32_64_0 qspi(
	.CLK_slow_clock(qspi_slow_clock),
	.RST_N_slow_reset(qspi_slow_rst_n),
	.CLK(qspi_clk),
	.RST_N(qspi_rst_n),
	.io_clk_o(qspi_sclk),
	.io_io_o(qspi_dq_out),
	.io_io_enable(qspi_dq_out_ena),
	.io_io_i_io_i(qspi_dq_in),
	.io_ncs_o(qspi_csn),

	.slave_m_awvalid_awvalid(qspi_m_awvalid_awvalid),
	.slave_m_awvalid_awaddr({1'b1,qspi_m_awvalid_awaddr[31:1]}),
	.slave_m_awvalid_awsize(qspi_m_awvalid_awsize),
	.slave_m_awvalid_awprot(qspi_m_awvalid_awprot),
	.slave_awready(qspi_awready),
	.slave_m_wvalid_wvalid(qspi_m_wvalid_wvalid),
	.slave_m_wvalid_wdata(qspi_m_wvalid_wdata),
	.slave_m_wvalid_wstrb(qspi_m_wvalid_wstrb),
	.slave_wready(qspi_wready),
	.slave_bvalid(qspi_bvalid),
	.slave_bresp(qspi_bresp),
	.slave_m_bready_bready(qspi_m_bready_bready),
	.slave_m_arvalid_arvalid(qspi_m_arvalid_arvalid),
	.slave_m_arvalid_araddr({1'b1,qspi_m_arvalid_araddr[31:1]}),
	.slave_m_arvalid_arsize(qspi_m_arvalid_arsize),
	.slave_m_arvalid_arprot(qspi_m_arvalid_arprot),
	.slave_arready(qspi_arready),
	.slave_rvalid(qspi_rvalid),
	.slave_rresp(qspi_rresp),
	.slave_rdata(qspi_rdata),
	.slave_m_rready_rready(qspi_m_rready_rready),
	.interrupts(qspi_interrupts),
	.RDY_interrupts(qspi_interrupt_valid)
);

wire uart_m_awvalid_awvalid;
wire [31 : 0] uart_m_awvalid_awaddr;
wire [1 : 0] uart_m_awvalid_awsize;
wire [2 : 0] uart_m_awvalid_awprot;
wire uart_awready;
wire uart_m_wvalid_wvalid;
wire [63 : 0] uart_m_wvalid_wdata;
wire [7 : 0] uart_m_wvalid_wstrb;
wire uart_wready;
wire uart_bvalid;
wire [1 : 0] uart_bresp;
wire uart_m_bready_bready;
wire uart_m_arvalid_arvalid;
wire [31 : 0] uart_m_arvalid_araddr;
wire [1 : 0] uart_m_arvalid_arsize;
wire [2 : 0] uart_m_arvalid_arprot;
wire uart_arready;
wire uart_rvalid;
wire [1 : 0] uart_rresp;
wire [63 : 0] uart_rdata;
wire uart_m_rready_rready;

axi2axil_64 axi4_to_axil4_uart(
.CLK(uart_clk),
.RST_N(uart_rst_n),
.AXI4_AWVALID(AXI_MASTER_M_UART_REG_AWVALID),
.AXI4_AWADDR(AXI_MASTER_M_UART_REG_AWADDR),
.AXI4_AWSIZE(AXI_MASTER_M_UART_REG_AWSIZE),
.AXI4_AWPROT(AXI_MASTER_M_UART_REG_AWPROT),
.AXI4_AWLEN(AXI_MASTER_M_UART_REG_AWLEN),
.AXI4_AWBURST(AXI_MASTER_M_UART_REG_AWBURST),
.AXI4_AWID(AXI_MASTER_M_UART_REG_AWID),
.AXI4_AWREADY(AXI_MASTER_M_UART_REG_AWREADY),
.AXI4_WVALID(AXI_MASTER_M_UART_REG_WVALID),
.AXI4_WDATA(AXI_MASTER_M_UART_REG_WDATA),
.AXI4_WSTRB(AXI_MASTER_M_UART_REG_WSTRB),
.AXI4_WLAST(AXI_MASTER_M_UART_REG_WLAST),
.AXI4_WID(AXI_MASTER_M_UART_REG_AWID),
.AXI4_WREADY(AXI_MASTER_M_UART_REG_WREADY),
.AXI4_BVALID(AXI_MASTER_M_UART_REG_BVALID),
.AXI4_BRESP(AXI_MASTER_M_UART_REG_BRESP),
.AXI4_BID(AXI_MASTER_M_UART_REG_BID),
.AXI4_BREADY(AXI_MASTER_M_UART_REG_BREADY),
.AXI4_ARVALID(AXI_MASTER_M_UART_REG_ARVALID),
.AXI4_ARADDR(AXI_MASTER_M_UART_REG_ARADDR),
.AXI4_ARSIZE(AXI_MASTER_M_UART_REG_ARSIZE),
.AXI4_ARPROT(AXI_MASTER_M_UART_REG_ARPROT),
.AXI4_ARLEN(AXI_MASTER_M_UART_REG_ARLEN),
.AXI4_ARBURST(AXI_MASTER_M_UART_REG_ARBURST),
.AXI4_ARID(AXI_MASTER_M_UART_REG_ARID),
.AXI4_ARREADY(AXI_MASTER_M_UART_REG_ARREADY),
.AXI4_RVALID(AXI_MASTER_M_UART_REG_RVALID),
.AXI4_RRESP(AXI_MASTER_M_UART_REG_RRESP),
.AXI4_RDATA(AXI_MASTER_M_UART_REG_RDATA),
.AXI4_RLAST(AXI_MASTER_M_UART_REG_RLAST),
.AXI4_RID(AXI_MASTER_M_UART_REG_RID),
.AXI4_RREADY(AXI_MASTER_M_UART_REG_RREADY),
.AXI4L_awvalid(uart_m_awvalid_awvalid),
.AXI4L_awaddr(uart_m_awvalid_awaddr),
.AXI4L_awprot(uart_m_awvalid_awprot),
.AXI4L_awsize(uart_m_awvalid_awsize),
.AXI4L_m_awready_awready(uart_awready),
.AXI4L_wvalid(uart_m_wvalid_wvalid),
.AXI4L_wdata(uart_m_wvalid_wdata),
.AXI4L_wstrb(uart_m_wvalid_wstrb),
.AXI4L_m_wready_wready(uart_wready),
.AXI4L_m_bvalid_bvalid(uart_bvalid),
.AXI4L_m_bvalid_bresp(uart_bresp),
.AXI4L_bready(uart_m_bready_bready),
.AXI4L_arvalid(uart_m_arvalid_arvalid),
.AXI4L_araddr(uart_m_arvalid_araddr),
.AXI4L_arprot(uart_m_arvalid_arprot),
.AXI4L_arsize(uart_m_arvalid_arsize),
.AXI4L_m_arready_arready(uart_arready),
.AXI4L_m_rvalid_rvalid(uart_rvalid),
.AXI4L_m_rvalid_rresp(uart_rresp),
.AXI4L_m_rvalid_rdata(uart_rdata),
.AXI4L_rready(uart_m_rready_rready)
);
uart uart(
	.CLK(uart_clk),
	.RST_N(uart_rst_n),

	.axi_awvalid(uart_m_awvalid_awvalid),
	.axi_awaddr({1'b0,uart_m_awvalid_awaddr[31:1]}),
	.axi_awsize(uart_m_awvalid_awsize),
	.axi_awprot(uart_m_awvalid_awprot),

	.axi_awready(uart_awready),

	.axi_wvalid(uart_m_wvalid_wvalid),
	.axi_wdata(uart_m_wvalid_wdata),
	.axi_wstrb(uart_m_wvalid_wstrb),

	.axi_wready(uart_wready),
	.axi_bvalid(uart_bvalid),
	.axi_bresp(uart_bresp),
	.axi_bready(uart_m_bready_bready),
	.axi_arvalid(uart_m_arvalid_arvalid),
	.axi_araddr({1'b0,uart_m_arvalid_araddr[31:1]}),
	.axi_arsize(uart_m_arvalid_arsize),
	.axi_arprot(uart_m_arvalid_arprot),
	.axi_arready(uart_arready),
	.axi_rvalid(uart_rvalid),
	.axi_rresp(uart_rresp),
	.axi_rdata(uart_rdata),
	.axi_rready(uart_m_rready_rready),
	.SIN(UART_RX),
	.SOUT(UART_TX),
	.SOUT_EN(UART_TX_ENA),
	.interrupt(uart_interrupts)
);


i2c_apb i2c(
	.clk(i2c_clk),
	.arst_n(i2c_arst_n),
	/* * Host interface */
	.s_apb_psel    (APB_MASTER_M_I2C_REG_PSEL),
	.s_apb_penable (APB_MASTER_M_I2C_REG_PENABLE),
	.s_apb_pwrite  (APB_MASTER_M_I2C_REG_PWRITE),
	.s_apb_pprot   (APB_MASTER_M_I2C_REG_PPROT),
	.s_apb_paddr   (APB_MASTER_M_I2C_REG_PADDR[5:0]),
	.s_apb_pwdata  (APB_MASTER_M_I2C_REG_PWDATA),
	.s_apb_pstrb   (APB_MASTER_M_I2C_REG_PSTRB),
	.s_apb_pready  (APB_MASTER_M_I2C_REG_PREADY),
	.s_apb_prdata  (APB_MASTER_M_I2C_REG_PRDATA),
	.s_apb_pslverr (APB_MASTER_M_I2C_REG_PSLVERR),

	/* * I2C interface */

	.i2c_scl_i(i2c_scl_i),
	.i2c_scl_o(i2c_scl_o),
	.i2c_scl_oe(i2c_scl_oe),
	.i2c_sda_i(i2c_sda_i),
	.i2c_sda_o(i2c_sda_o),
	.i2c_sda_oe(i2c_sda_oe)
);

  wire  [31 : 0] xspi_apb_PADDR;
  wire  [2 : 0] xspi_apb_PROT;
  wire  xspi_apb_PENABLE;
  wire  xspi_apb_PWRITE;
  wire  [63 : 0] xspi_apb_PWDATA;
  wire  [7 : 0] xspi_apb_PSTRB;
  wire  xspi_apb_PSEL;

  // value method xspi_apb_s_pready
  wire xspi_apb_PREADY;

  // value method xspi_apb_s_prdata
  wire [63 : 0] xspi_apb_PRDATA;

  // value method apb_s_pslverr
  wire xspi_apb_PSLVERR;
axi2apb_64 xspi_axi2apb(
	.CLK(xspi_clk),
	.RST_N(xspi_rst_n),
	.AXI4_awvalid(AXI_MASTER_M_XSPI_AWVALID),
	.AXI4_awid(AXI_MASTER_M_XSPI_AWID),
	.AXI4_awaddr(AXI_MASTER_M_XSPI_AWADDR),
	.AXI4_awlen(AXI_MASTER_M_XSPI_AWLEN),
	.AXI4_awsize(AXI_MASTER_M_XSPI_AWSIZE),
	.AXI4_awburst(AXI_MASTER_M_XSPI_AWBURST),
	.AXI4_awlock(AXI_MASTER_M_XSPI_AWLOCK),
	.AXI4_awcache(AXI_MASTER_M_XSPI_AWCACHE),
	.AXI4_awprot(AXI_MASTER_M_XSPI_AWPROT),
	.AXI4_awqos(AXI_MASTER_M_XSPI_AWQOS),
	.AXI4_awregion(4'b0),
	.AXI4_awready(AXI_MASTER_M_XSPI_AWREADY),
	.AXI4_wvalid(AXI_MASTER_M_XSPI_WVALID),
	.AXI4_wdata(AXI_MASTER_M_XSPI_WDATA),
	.AXI4_wstrb(AXI_MASTER_M_XSPI_WSTRB),
	.AXI4_wlast(AXI_MASTER_M_XSPI_WLAST),
	.AXI4_wready(AXI_MASTER_M_XSPI_WREADY),
	.AXI4_bvalid(AXI_MASTER_M_XSPI_BVALID),
	.AXI4_bid(AXI_MASTER_M_XSPI_BID),
	.AXI4_bresp(AXI_MASTER_M_XSPI_BRESP),
	.AXI4_bready(AXI_MASTER_M_XSPI_BREADY),
	.AXI4_arvalid(AXI_MASTER_M_XSPI_ARVALID),
	.AXI4_arid(AXI_MASTER_M_XSPI_ARID),
	.AXI4_araddr(AXI_MASTER_M_XSPI_ARADDR),
	.AXI4_arlen(AXI_MASTER_M_XSPI_ARLEN),
	.AXI4_arsize(AXI_MASTER_M_XSPI_ARSIZE),
	.AXI4_arburst(AXI_MASTER_M_XSPI_ARBURST),
	.AXI4_arlock(AXI_MASTER_M_XSPI_ARLOCK),
	.AXI4_arcache(AXI_MASTER_M_XSPI_ARCACHE),
	.AXI4_arprot(AXI_MASTER_M_XSPI_ARPROT),
	.AXI4_arqos(AXI_MASTER_M_XSPI_ARQOS),
	.AXI4_arregion(4'b0),
	.AXI4_arready(AXI_MASTER_M_XSPI_ARREADY),
	.AXI4_rvalid(AXI_MASTER_M_XSPI_RVALID),
	.AXI4_rid(AXI_MASTER_M_XSPI_RID),
	.AXI4_rdata(AXI_MASTER_M_XSPI_RDATA),
	.AXI4_rresp(AXI_MASTER_M_XSPI_RRESP),
	.AXI4_rlast(AXI_MASTER_M_XSPI_RLAST),
	.AXI4_rready(AXI_MASTER_M_XSPI_RREADY),
	.APB_PADDR   (xspi_apb_PADDR ),
	.APB_PROT    (xspi_apb_PROT ),
	.APB_PENABLE (xspi_apb_PENABLE ),
	.APB_PWRITE  (xspi_apb_PWRITE ),
	.APB_PWDATA  (xspi_apb_PWDATA ),
	.APB_PSTRB   (xspi_apb_PSTRB ),
	.APB_PSEL    (xspi_apb_PSEL ),
	.APB_PREADY  (xspi_apb_PREADY ),
	.APB_PRDATA  (xspi_apb_PRDATA ),
	.APB_PSLVERR (xspi_apb_PSLVERR )
);
mkxspi xspi(
.CLK(xspi_clk),
.RST_N(xspi_rst_n),
.axi_awvalid(AXI_SLAVE_S_XSPI_AWVALID),
.axi_awaddr(AXI_SLAVE_S_XSPI_AWADDR),
.axi_awlen(AXI_SLAVE_S_XSPI_AWLEN),
.axi_awsize(AXI_SLAVE_S_XSPI_AWSIZE),
.axi_awburst(AXI_SLAVE_S_XSPI_AWBURST),
.axi_awlock(AXI_SLAVE_S_XSPI_AWLOCK),
.axi_awcache(AXI_SLAVE_S_XSPI_AWCACHE),
.axi_awprot(AXI_SLAVE_S_XSPI_AWPROT),
.axi_awqos(AXI_SLAVE_S_XSPI_AWQOS),
.axi_awregion(), //TODO
.axi_awready(AXI_SLAVE_S_XSPI_AWREADY),
.axi_wvalid(AXI_SLAVE_S_XSPI_WVALID),
.axi_wdata(AXI_SLAVE_S_XSPI_WDATA),
.axi_wstrb(AXI_SLAVE_S_XSPI_WSTRB),
.axi_wlast(AXI_SLAVE_S_XSPI_WLAST),
.axi_wready(AXI_SLAVE_S_XSPI_WREADY),
.axi_bvalid(AXI_SLAVE_S_XSPI_BVALID),
.axi_bresp(AXI_SLAVE_S_XSPI_BRESP),
.axi_bready(AXI_SLAVE_S_XSPI_BREADY),
.axi_arvalid(AXI_SLAVE_S_XSPI_ARVALID),
.axi_araddr(AXI_SLAVE_S_XSPI_ARADDR),
.axi_arlen(AXI_SLAVE_S_XSPI_ARLEN),
.axi_arsize(AXI_SLAVE_S_XSPI_ARSIZE),
.axi_arburst(AXI_SLAVE_S_XSPI_ARBURST),
.axi_arlock(AXI_SLAVE_S_XSPI_ARLOCK),
.axi_arcache(AXI_SLAVE_S_XSPI_ARCACHE),
.axi_arprot(AXI_SLAVE_S_XSPI_ARPROT),
.axi_arqos(AXI_SLAVE_S_XSPI_ARQOS),
.axi_arregion(), //TODO
.axi_arready(AXI_SLAVE_S_XSPI_ARREADY),
.axi_rvalid(AXI_SLAVE_S_XSPI_RVALID),
.axi_rdata(AXI_SLAVE_S_XSPI_RDATA),
.axi_rresp(AXI_SLAVE_S_XSPI_RRESP),
.axi_rlast(AXI_SLAVE_S_XSPI_RLAST),
.axi_rready(AXI_SLAVE_S_XSPI_RREADY),
.apb_PADDR   ( xspi_apb_PADDR),
.apb_PROT    ( xspi_apb_PROT),
.apb_PENABLE ( xspi_apb_PENABLE),
.apb_PWRITE  ( xspi_apb_PWRITE),
.apb_PWDATA  ( xspi_apb_PWDATA),
.apb_PSTRB   ( xspi_apb_PSTRB),
.apb_PSEL    ( xspi_apb_PSEL),
.apb_PREADY  ( xspi_apb_PREADY),
.apb_PRDATA  ( xspi_apb_PRDATA),
.apb_PSLVERR ( xspi_apb_PSLVERR),


.xspi_dq_in(XSPI_DQ_IN),
.xspi_rwds_in(XSPI_RWDS_IN),
.xspi_csn(XSPI_CSN),
.xspi_dq_out(XSPI_DQ_OUT),
.xspi_dq_out_ena(XSPI_DQ_OEN),
.xspi_rwds_out(XSPI_RWDS_OUT),
.xspi_rwds_out_ena(XSPI_RWDS_OEN),
.cfg_default_mode_m(xspi_mode),
.cfg_use_xspi_clk(use_xspi_clk),
.cfg_drive_strength(drive_strength),
.cfg_reset_device(xspi_rst_req),
.cfg_interrupt(xspi_interrupt)
);


ni700_ErbiumET nic( 

.AXI_MASTER_M_CPU_REG_ARADDR(AXI_MASTER_M_CPU_REG_ARADDR), 
.AXI_MASTER_M_CPU_REG_ARBURST(AXI_MASTER_M_CPU_REG_ARBURST), 
.AXI_MASTER_M_CPU_REG_ARCACHE(AXI_MASTER_M_CPU_REG_ARCACHE), 
.AXI_MASTER_M_CPU_REG_ARID(AXI_MASTER_M_CPU_REG_ARID), 
.AXI_MASTER_M_CPU_REG_ARLEN(AXI_MASTER_M_CPU_REG_ARLEN), 
.AXI_MASTER_M_CPU_REG_ARLOCK(AXI_MASTER_M_CPU_REG_ARLOCK), 
.AXI_MASTER_M_CPU_REG_ARPROT(AXI_MASTER_M_CPU_REG_ARPROT), 
.AXI_MASTER_M_CPU_REG_ARQOS(AXI_MASTER_M_CPU_REG_ARQOS), 
.AXI_MASTER_M_CPU_REG_ARREADY(AXI_MASTER_M_CPU_REG_ARREADY), 
.AXI_MASTER_M_CPU_REG_ARSIZE(AXI_MASTER_M_CPU_REG_ARSIZE), 
.AXI_MASTER_M_CPU_REG_ARVALID(AXI_MASTER_M_CPU_REG_ARVALID), 
.AXI_MASTER_M_CPU_REG_AWADDR(AXI_MASTER_M_CPU_REG_AWADDR), 
.AXI_MASTER_M_CPU_REG_AWAKEUP(AXI_MASTER_M_CPU_REG_AWAKEUP), 
.AXI_MASTER_M_CPU_REG_AWBURST(AXI_MASTER_M_CPU_REG_AWBURST), 
.AXI_MASTER_M_CPU_REG_AWCACHE(AXI_MASTER_M_CPU_REG_AWCACHE), 
.AXI_MASTER_M_CPU_REG_AWID(AXI_MASTER_M_CPU_REG_AWID), 
.AXI_MASTER_M_CPU_REG_AWLEN(AXI_MASTER_M_CPU_REG_AWLEN), 
.AXI_MASTER_M_CPU_REG_AWLOCK(AXI_MASTER_M_CPU_REG_AWLOCK), 
.AXI_MASTER_M_CPU_REG_AWPROT(AXI_MASTER_M_CPU_REG_AWPROT), 
.AXI_MASTER_M_CPU_REG_AWQOS(AXI_MASTER_M_CPU_REG_AWQOS), 
.AXI_MASTER_M_CPU_REG_AWREADY(AXI_MASTER_M_CPU_REG_AWREADY), 
.AXI_MASTER_M_CPU_REG_AWSIZE(AXI_MASTER_M_CPU_REG_AWSIZE), 
.AXI_MASTER_M_CPU_REG_AWVALID(AXI_MASTER_M_CPU_REG_AWVALID), 
.AXI_MASTER_M_CPU_REG_BID(AXI_MASTER_M_CPU_REG_BID), 
.AXI_MASTER_M_CPU_REG_BREADY(AXI_MASTER_M_CPU_REG_BREADY), 
.AXI_MASTER_M_CPU_REG_BRESP(AXI_MASTER_M_CPU_REG_BRESP), 
.AXI_MASTER_M_CPU_REG_BVALID(AXI_MASTER_M_CPU_REG_BVALID), 
.AXI_MASTER_M_CPU_REG_RDATA(AXI_MASTER_M_CPU_REG_RDATA), 
.AXI_MASTER_M_CPU_REG_RID(AXI_MASTER_M_CPU_REG_RID), 
.AXI_MASTER_M_CPU_REG_RLAST(AXI_MASTER_M_CPU_REG_RLAST), 
.AXI_MASTER_M_CPU_REG_RREADY(AXI_MASTER_M_CPU_REG_RREADY), 
.AXI_MASTER_M_CPU_REG_RRESP(AXI_MASTER_M_CPU_REG_RRESP), 
.AXI_MASTER_M_CPU_REG_RVALID(AXI_MASTER_M_CPU_REG_RVALID), 
.AXI_MASTER_M_CPU_REG_WDATA(AXI_MASTER_M_CPU_REG_WDATA), 
.AXI_MASTER_M_CPU_REG_WLAST(AXI_MASTER_M_CPU_REG_WLAST), 
.AXI_MASTER_M_CPU_REG_WREADY(AXI_MASTER_M_CPU_REG_WREADY), 
.AXI_MASTER_M_CPU_REG_WSTRB(AXI_MASTER_M_CPU_REG_WSTRB), 
.AXI_MASTER_M_CPU_REG_WVALID(AXI_MASTER_M_CPU_REG_WVALID), 
	.AXI_MASTER_M_MRAM_REG_ARADDR(AXI_MASTER_M_MRAM_REG_ARADDR), 
	.AXI_MASTER_M_MRAM_REG_ARBURST(AXI_MASTER_M_MRAM_REG_ARBURST), //
	.AXI_MASTER_M_MRAM_REG_ARCACHE(AXI_MASTER_M_MRAM_REG_ARCACHE), //
	.AXI_MASTER_M_MRAM_REG_ARID(AXI_MASTER_M_MRAM_REG_ARID), //
	.AXI_MASTER_M_MRAM_REG_ARLEN(AXI_MASTER_M_MRAM_REG_ARLEN), //
	.AXI_MASTER_M_MRAM_REG_ARLOCK(AXI_MASTER_M_MRAM_REG_ARLOCK), //
	.AXI_MASTER_M_MRAM_REG_ARPROT(AXI_MASTER_M_MRAM_REG_ARPROT), 
	.AXI_MASTER_M_MRAM_REG_ARQOS(AXI_MASTER_M_MRAM_REG_ARQOS), //
	.AXI_MASTER_M_MRAM_REG_ARREADY(AXI_MASTER_M_MRAM_REG_ARREADY), 
	.AXI_MASTER_M_MRAM_REG_ARSIZE(AXI_MASTER_M_MRAM_REG_ARSIZE), //
	.AXI_MASTER_M_MRAM_REG_ARVALID(AXI_MASTER_M_MRAM_REG_ARVALID), 
	.AXI_MASTER_M_MRAM_REG_AWADDR(AXI_MASTER_M_MRAM_REG_AWADDR), 
	.AXI_MASTER_M_MRAM_REG_AWAKEUP(AXI_MASTER_M_MRAM_REG_AWAKEUP), //
	.AXI_MASTER_M_MRAM_REG_AWBURST(AXI_MASTER_M_MRAM_REG_AWBURST), //
	.AXI_MASTER_M_MRAM_REG_AWCACHE(AXI_MASTER_M_MRAM_REG_AWCACHE), //
	.AXI_MASTER_M_MRAM_REG_AWID(AXI_MASTER_M_MRAM_REG_AWID), //
	.AXI_MASTER_M_MRAM_REG_AWLEN(AXI_MASTER_M_MRAM_REG_AWLEN), //
	.AXI_MASTER_M_MRAM_REG_AWLOCK(AXI_MASTER_M_MRAM_REG_AWLOCK), //
	.AXI_MASTER_M_MRAM_REG_AWPROT(AXI_MASTER_M_MRAM_REG_AWPROT), 
	.AXI_MASTER_M_MRAM_REG_AWQOS(AXI_MASTER_M_MRAM_REG_AWQOS), //
	.AXI_MASTER_M_MRAM_REG_AWREADY(AXI_MASTER_M_MRAM_REG_AWREADY), 
	.AXI_MASTER_M_MRAM_REG_AWSIZE(AXI_MASTER_M_MRAM_REG_AWSIZE), //
	.AXI_MASTER_M_MRAM_REG_AWVALID(AXI_MASTER_M_MRAM_REG_AWVALID), 
	.AXI_MASTER_M_MRAM_REG_BID(AXI_MASTER_M_MRAM_REG_BID), //
	.AXI_MASTER_M_MRAM_REG_BREADY(AXI_MASTER_M_MRAM_REG_BREADY), 
	.AXI_MASTER_M_MRAM_REG_BRESP(AXI_MASTER_M_MRAM_REG_BRESP), 
	.AXI_MASTER_M_MRAM_REG_BVALID(AXI_MASTER_M_MRAM_REG_BVALID), 
	.AXI_MASTER_M_MRAM_REG_RDATA(AXI_MASTER_M_MRAM_REG_RDATA), 
	.AXI_MASTER_M_MRAM_REG_RID(AXI_MASTER_M_MRAM_REG_RID), //
	.AXI_MASTER_M_MRAM_REG_RLAST(AXI_MASTER_M_MRAM_REG_RLAST), //
	.AXI_MASTER_M_MRAM_REG_RREADY(AXI_MASTER_M_MRAM_REG_RREADY), 
	.AXI_MASTER_M_MRAM_REG_RRESP(AXI_MASTER_M_MRAM_REG_RRESP), 
	.AXI_MASTER_M_MRAM_REG_RVALID(AXI_MASTER_M_MRAM_REG_RVALID), 
	.AXI_MASTER_M_MRAM_REG_WDATA(AXI_MASTER_M_MRAM_REG_WDATA), 
	.AXI_MASTER_M_MRAM_REG_WLAST(AXI_MASTER_M_MRAM_REG_WLAST), //
	.AXI_MASTER_M_MRAM_REG_WREADY(AXI_MASTER_M_MRAM_REG_WREADY), 
	.AXI_MASTER_M_MRAM_REG_WSTRB(AXI_MASTER_M_MRAM_REG_WSTRB), 
	.AXI_MASTER_M_MRAM_REG_WVALID(AXI_MASTER_M_MRAM_REG_WVALID ), 
  .AXI_MASTER_M_SYSTEM_REG_ARADDR(AXI_MASTER_M_SYSTEM_REG_ARADDR), 
  .AXI_MASTER_M_SYSTEM_REG_ARBURST(AXI_MASTER_M_SYSTEM_REG_ARBURST), 
  .AXI_MASTER_M_SYSTEM_REG_ARCACHE(AXI_MASTER_M_SYSTEM_REG_ARCACHE), 
  .AXI_MASTER_M_SYSTEM_REG_ARID(AXI_MASTER_M_SYSTEM_REG_ARID), 
  .AXI_MASTER_M_SYSTEM_REG_ARLEN(AXI_MASTER_M_SYSTEM_REG_ARLEN), 
  .AXI_MASTER_M_SYSTEM_REG_ARLOCK(AXI_MASTER_M_SYSTEM_REG_ARLOCK), 
  .AXI_MASTER_M_SYSTEM_REG_ARPROT(AXI_MASTER_M_SYSTEM_REG_ARPROT), 
  .AXI_MASTER_M_SYSTEM_REG_ARQOS(AXI_MASTER_M_SYSTEM_REG_ARQOS), 
  .AXI_MASTER_M_SYSTEM_REG_ARREADY(AXI_MASTER_M_SYSTEM_REG_ARREADY), 
  .AXI_MASTER_M_SYSTEM_REG_ARSIZE(AXI_MASTER_M_SYSTEM_REG_ARSIZE), 
  .AXI_MASTER_M_SYSTEM_REG_ARVALID(AXI_MASTER_M_SYSTEM_REG_ARVALID), 
  .AXI_MASTER_M_SYSTEM_REG_AWADDR(AXI_MASTER_M_SYSTEM_REG_AWADDR), 
  .AXI_MASTER_M_SYSTEM_REG_AWAKEUP(AXI_MASTER_M_SYSTEM_REG_AWAKEUP), 
  .AXI_MASTER_M_SYSTEM_REG_AWBURST(AXI_MASTER_M_SYSTEM_REG_AWBURST), 
  .AXI_MASTER_M_SYSTEM_REG_AWCACHE(AXI_MASTER_M_SYSTEM_REG_AWCACHE), 
  .AXI_MASTER_M_SYSTEM_REG_AWID(AXI_MASTER_M_SYSTEM_REG_AWID), 
  .AXI_MASTER_M_SYSTEM_REG_AWLEN(AXI_MASTER_M_SYSTEM_REG_AWLEN), 
  .AXI_MASTER_M_SYSTEM_REG_AWLOCK(AXI_MASTER_M_SYSTEM_REG_AWLOCK), 
  .AXI_MASTER_M_SYSTEM_REG_AWPROT(AXI_MASTER_M_SYSTEM_REG_AWPROT), 
  .AXI_MASTER_M_SYSTEM_REG_AWQOS(AXI_MASTER_M_SYSTEM_REG_AWQOS), 
  .AXI_MASTER_M_SYSTEM_REG_AWREADY(AXI_MASTER_M_SYSTEM_REG_AWREADY), 
  .AXI_MASTER_M_SYSTEM_REG_AWSIZE(AXI_MASTER_M_SYSTEM_REG_AWSIZE), 
  .AXI_MASTER_M_SYSTEM_REG_AWVALID(AXI_MASTER_M_SYSTEM_REG_AWVALID), 
  .AXI_MASTER_M_SYSTEM_REG_BID(AXI_MASTER_M_SYSTEM_REG_BID), 
  .AXI_MASTER_M_SYSTEM_REG_BREADY(AXI_MASTER_M_SYSTEM_REG_BREADY), 
  .AXI_MASTER_M_SYSTEM_REG_BRESP(AXI_MASTER_M_SYSTEM_REG_BRESP), 
  .AXI_MASTER_M_SYSTEM_REG_BVALID(AXI_MASTER_M_SYSTEM_REG_BVALID), 
  .AXI_MASTER_M_SYSTEM_REG_RDATA(AXI_MASTER_M_SYSTEM_REG_RDATA), 
  .AXI_MASTER_M_SYSTEM_REG_RID(AXI_MASTER_M_SYSTEM_REG_RID), 
  .AXI_MASTER_M_SYSTEM_REG_RLAST(AXI_MASTER_M_SYSTEM_REG_RLAST), 
  .AXI_MASTER_M_SYSTEM_REG_RREADY(AXI_MASTER_M_SYSTEM_REG_RREADY), 
  .AXI_MASTER_M_SYSTEM_REG_RRESP(AXI_MASTER_M_SYSTEM_REG_RRESP), 
  .AXI_MASTER_M_SYSTEM_REG_RVALID(AXI_MASTER_M_SYSTEM_REG_RVALID), 
  .AXI_MASTER_M_SYSTEM_REG_WDATA(AXI_MASTER_M_SYSTEM_REG_WDATA), 
  .AXI_MASTER_M_SYSTEM_REG_WLAST(AXI_MASTER_M_SYSTEM_REG_WLAST), 
  .AXI_MASTER_M_SYSTEM_REG_WREADY(AXI_MASTER_M_SYSTEM_REG_WREADY), 
  .AXI_MASTER_M_SYSTEM_REG_WSTRB(AXI_MASTER_M_SYSTEM_REG_WSTRB), 
  .AXI_MASTER_M_SYSTEM_REG_WVALID(AXI_MASTER_M_SYSTEM_REG_WVALID), 

         .APB_MASTER_M_I2C_REG_PADDR   ( APB_MASTER_M_I2C_REG_PADDR),
         .APB_MASTER_M_I2C_REG_PENABLE ( APB_MASTER_M_I2C_REG_PENABLE),
         .APB_MASTER_M_I2C_REG_PPROT   ( APB_MASTER_M_I2C_REG_PPROT),
         .APB_MASTER_M_I2C_REG_PRDATA  ( APB_MASTER_M_I2C_REG_PRDATA),
         .APB_MASTER_M_I2C_REG_PREADY  ( APB_MASTER_M_I2C_REG_PREADY),
         .APB_MASTER_M_I2C_REG_PSEL    ( APB_MASTER_M_I2C_REG_PSEL),
         .APB_MASTER_M_I2C_REG_PSLVERR ( APB_MASTER_M_I2C_REG_PSLVERR),
         .APB_MASTER_M_I2C_REG_PSTRB   ( APB_MASTER_M_I2C_REG_PSTRB),
         .APB_MASTER_M_I2C_REG_PWDATA  ( APB_MASTER_M_I2C_REG_PWDATA),
         .APB_MASTER_M_I2C_REG_PWRITE  ( APB_MASTER_M_I2C_REG_PWRITE),

	 .AXI_MASTER_M_MRAM_ARADDR          ( AXI_MASTER_M_MRAM_ARADDR          ) ,
	 .AXI_MASTER_M_MRAM_ARBURST         ( AXI_MASTER_M_MRAM_ARBURST         ) ,
	 .AXI_MASTER_M_MRAM_ARCACHE         ( AXI_MASTER_M_MRAM_ARCACHE         ) ,
	 .AXI_MASTER_M_MRAM_ARID            ( AXI_MASTER_M_MRAM_ARID            ) ,
	 .AXI_MASTER_M_MRAM_ARLEN           ( AXI_MASTER_M_MRAM_ARLEN           ) ,
	 .AXI_MASTER_M_MRAM_ARLOCK          ( AXI_MASTER_M_MRAM_ARLOCK          ) ,
	 .AXI_MASTER_M_MRAM_ARPROT          ( AXI_MASTER_M_MRAM_ARPROT          ) ,
	 .AXI_MASTER_M_MRAM_ARQOS           ( AXI_MASTER_M_MRAM_ARQOS           ) ,
	 .AXI_MASTER_M_MRAM_ARREADY         ( AXI_MASTER_M_MRAM_ARREADY         ) ,
	 .AXI_MASTER_M_MRAM_ARSIZE          ( AXI_MASTER_M_MRAM_ARSIZE          ) ,
	 .AXI_MASTER_M_MRAM_ARVALID         ( AXI_MASTER_M_MRAM_ARVALID         ) ,
	 .AXI_MASTER_M_MRAM_AWADDR          ( AXI_MASTER_M_MRAM_AWADDR          ) ,
	 .AXI_MASTER_M_MRAM_AWAKEUP         ( AXI_MASTER_M_MRAM_AWAKEUP         ) ,
	 .AXI_MASTER_M_MRAM_AWBURST         ( AXI_MASTER_M_MRAM_AWBURST         ) ,
	 .AXI_MASTER_M_MRAM_AWCACHE         ( AXI_MASTER_M_MRAM_AWCACHE         ) ,
	 .AXI_MASTER_M_MRAM_AWID            ( AXI_MASTER_M_MRAM_AWID            ) ,
	 .AXI_MASTER_M_MRAM_AWLEN           ( AXI_MASTER_M_MRAM_AWLEN           ) ,
	 .AXI_MASTER_M_MRAM_AWLOCK          ( AXI_MASTER_M_MRAM_AWLOCK          ) ,
	 .AXI_MASTER_M_MRAM_AWPROT          ( AXI_MASTER_M_MRAM_AWPROT          ) ,
	 .AXI_MASTER_M_MRAM_AWQOS           ( AXI_MASTER_M_MRAM_AWQOS           ) ,
	 .AXI_MASTER_M_MRAM_AWREADY         ( AXI_MASTER_M_MRAM_AWREADY         ) ,
	 .AXI_MASTER_M_MRAM_AWSIZE          ( AXI_MASTER_M_MRAM_AWSIZE          ) ,
	 .AXI_MASTER_M_MRAM_AWVALID         ( AXI_MASTER_M_MRAM_AWVALID         ) ,
	 .AXI_MASTER_M_MRAM_BID             ( AXI_MASTER_M_MRAM_BID             ) ,
	 .AXI_MASTER_M_MRAM_BREADY          ( AXI_MASTER_M_MRAM_BREADY          ) ,
	 .AXI_MASTER_M_MRAM_BRESP           ( AXI_MASTER_M_MRAM_BRESP           ) ,
	 .AXI_MASTER_M_MRAM_BVALID          ( AXI_MASTER_M_MRAM_BVALID          ) ,
	 .AXI_MASTER_M_MRAM_RDATA           ( AXI_MASTER_M_MRAM_RDATA           ) ,
	 .AXI_MASTER_M_MRAM_RID             ( AXI_MASTER_M_MRAM_RID             ) ,
	 .AXI_MASTER_M_MRAM_RLAST           ( AXI_MASTER_M_MRAM_RLAST           ) ,
	 .AXI_MASTER_M_MRAM_RREADY          ( AXI_MASTER_M_MRAM_RREADY          ) ,
	 .AXI_MASTER_M_MRAM_RRESP           ( AXI_MASTER_M_MRAM_RRESP           ) ,
	 .AXI_MASTER_M_MRAM_RVALID          ( AXI_MASTER_M_MRAM_RVALID          ) ,
	 .AXI_MASTER_M_MRAM_WDATA           ( AXI_MASTER_M_MRAM_WDATA           ) ,
	 .AXI_MASTER_M_MRAM_WLAST           ( AXI_MASTER_M_MRAM_WLAST           ) ,
	 .AXI_MASTER_M_MRAM_WREADY          ( AXI_MASTER_M_MRAM_WREADY          ) ,
	 .AXI_MASTER_M_MRAM_WSTRB           ( AXI_MASTER_M_MRAM_WSTRB           ) ,
	 .AXI_MASTER_M_MRAM_WVALID          ( AXI_MASTER_M_MRAM_WVALID          ) ,
	 .AXI_MASTER_M_SPI_REG_ARADDR       ( AXI_MASTER_M_SPI_REG_ARADDR       ) ,
	 .AXI_MASTER_M_SPI_REG_ARBURST      ( AXI_MASTER_M_SPI_REG_ARBURST      ) ,
	 .AXI_MASTER_M_SPI_REG_ARCACHE      ( AXI_MASTER_M_SPI_REG_ARCACHE      ) ,
	 .AXI_MASTER_M_SPI_REG_ARID         ( AXI_MASTER_M_SPI_REG_ARID         ) ,
	 .AXI_MASTER_M_SPI_REG_ARLEN        ( AXI_MASTER_M_SPI_REG_ARLEN        ) ,
	 .AXI_MASTER_M_SPI_REG_ARLOCK       ( AXI_MASTER_M_SPI_REG_ARLOCK       ) ,
	 .AXI_MASTER_M_SPI_REG_ARPROT       ( AXI_MASTER_M_SPI_REG_ARPROT       ) ,
	 .AXI_MASTER_M_SPI_REG_ARQOS        ( AXI_MASTER_M_SPI_REG_ARQOS        ) ,
	 .AXI_MASTER_M_SPI_REG_ARREADY      ( AXI_MASTER_M_SPI_REG_ARREADY      ) ,
	 .AXI_MASTER_M_SPI_REG_ARSIZE       ( AXI_MASTER_M_SPI_REG_ARSIZE       ) ,
	 .AXI_MASTER_M_SPI_REG_ARVALID      ( AXI_MASTER_M_SPI_REG_ARVALID      ) ,
	 .AXI_MASTER_M_SPI_REG_AWADDR       ( AXI_MASTER_M_SPI_REG_AWADDR       ) ,
	 .AXI_MASTER_M_SPI_REG_AWAKEUP      ( AXI_MASTER_M_SPI_REG_AWAKEUP      ) ,
	 .AXI_MASTER_M_SPI_REG_AWBURST      ( AXI_MASTER_M_SPI_REG_AWBURST      ) ,
	 .AXI_MASTER_M_SPI_REG_AWCACHE      ( AXI_MASTER_M_SPI_REG_AWCACHE      ) ,
	 .AXI_MASTER_M_SPI_REG_AWID         ( AXI_MASTER_M_SPI_REG_AWID         ) ,
	 .AXI_MASTER_M_SPI_REG_AWLEN        ( AXI_MASTER_M_SPI_REG_AWLEN        ) ,
	 .AXI_MASTER_M_SPI_REG_AWLOCK       ( AXI_MASTER_M_SPI_REG_AWLOCK       ) ,
	 .AXI_MASTER_M_SPI_REG_AWPROT       ( AXI_MASTER_M_SPI_REG_AWPROT       ) ,
	 .AXI_MASTER_M_SPI_REG_AWQOS        ( AXI_MASTER_M_SPI_REG_AWQOS        ) ,
	 .AXI_MASTER_M_SPI_REG_AWREADY      ( AXI_MASTER_M_SPI_REG_AWREADY      ) ,
	 .AXI_MASTER_M_SPI_REG_AWSIZE       ( AXI_MASTER_M_SPI_REG_AWSIZE       ) ,
	 .AXI_MASTER_M_SPI_REG_AWVALID      ( AXI_MASTER_M_SPI_REG_AWVALID      ) ,
	 .AXI_MASTER_M_SPI_REG_BID          ( AXI_MASTER_M_SPI_REG_BID          ) ,
	 .AXI_MASTER_M_SPI_REG_BREADY       ( AXI_MASTER_M_SPI_REG_BREADY       ) ,
	 .AXI_MASTER_M_SPI_REG_BRESP        ( AXI_MASTER_M_SPI_REG_BRESP        ) ,
	 .AXI_MASTER_M_SPI_REG_BVALID       ( AXI_MASTER_M_SPI_REG_BVALID       ) ,
	 .AXI_MASTER_M_SPI_REG_RDATA        ( AXI_MASTER_M_SPI_REG_RDATA        ) ,
	 .AXI_MASTER_M_SPI_REG_RID          ( AXI_MASTER_M_SPI_REG_RID          ) ,
	 .AXI_MASTER_M_SPI_REG_RLAST        ( AXI_MASTER_M_SPI_REG_RLAST        ) ,
	 .AXI_MASTER_M_SPI_REG_RREADY       ( AXI_MASTER_M_SPI_REG_RREADY       ) ,
	 .AXI_MASTER_M_SPI_REG_RRESP        ( AXI_MASTER_M_SPI_REG_RRESP        ) ,
	 .AXI_MASTER_M_SPI_REG_RVALID       ( AXI_MASTER_M_SPI_REG_RVALID       ) ,
	 .AXI_MASTER_M_SPI_REG_WDATA        ( AXI_MASTER_M_SPI_REG_WDATA        ) ,
	 .AXI_MASTER_M_SPI_REG_WLAST        ( AXI_MASTER_M_SPI_REG_WLAST        ) ,
	 .AXI_MASTER_M_SPI_REG_WREADY       ( AXI_MASTER_M_SPI_REG_WREADY       ) ,
	 .AXI_MASTER_M_SPI_REG_WSTRB        ( AXI_MASTER_M_SPI_REG_WSTRB        ) ,
	 .AXI_MASTER_M_SPI_REG_WVALID       ( AXI_MASTER_M_SPI_REG_WVALID       ) ,
	 .AXI_MASTER_M_SRAM_ARADDR          ( AXI_MASTER_M_SRAM_ARADDR          ) ,
	 .AXI_MASTER_M_SRAM_ARBURST         ( AXI_MASTER_M_SRAM_ARBURST         ) ,
	 .AXI_MASTER_M_SRAM_ARCACHE         ( AXI_MASTER_M_SRAM_ARCACHE         ) ,
	 .AXI_MASTER_M_SRAM_ARID            ( AXI_MASTER_M_SRAM_ARID            ) ,
	 .AXI_MASTER_M_SRAM_ARLEN           ( AXI_MASTER_M_SRAM_ARLEN           ) ,
	 .AXI_MASTER_M_SRAM_ARLOCK          ( AXI_MASTER_M_SRAM_ARLOCK          ) ,
	 .AXI_MASTER_M_SRAM_ARPROT          ( AXI_MASTER_M_SRAM_ARPROT          ) ,
	 .AXI_MASTER_M_SRAM_ARQOS           ( AXI_MASTER_M_SRAM_ARQOS           ) ,
	 .AXI_MASTER_M_SRAM_ARREADY         ( AXI_MASTER_M_SRAM_ARREADY         ) ,
	 .AXI_MASTER_M_SRAM_ARSIZE          ( AXI_MASTER_M_SRAM_ARSIZE          ) ,
	 .AXI_MASTER_M_SRAM_ARVALID         ( AXI_MASTER_M_SRAM_ARVALID         ) ,
	 .AXI_MASTER_M_SRAM_AWADDR          ( AXI_MASTER_M_SRAM_AWADDR          ) ,
	 .AXI_MASTER_M_SRAM_AWAKEUP         ( AXI_MASTER_M_SRAM_AWAKEUP         ) ,
	 .AXI_MASTER_M_SRAM_AWBURST         ( AXI_MASTER_M_SRAM_AWBURST         ) ,
	 .AXI_MASTER_M_SRAM_AWCACHE         ( AXI_MASTER_M_SRAM_AWCACHE         ) ,
	 .AXI_MASTER_M_SRAM_AWID            ( AXI_MASTER_M_SRAM_AWID            ) ,
	 .AXI_MASTER_M_SRAM_AWLEN           ( AXI_MASTER_M_SRAM_AWLEN           ) ,
	 .AXI_MASTER_M_SRAM_AWLOCK          ( AXI_MASTER_M_SRAM_AWLOCK          ) ,
	 .AXI_MASTER_M_SRAM_AWPROT          ( AXI_MASTER_M_SRAM_AWPROT          ) ,
	 .AXI_MASTER_M_SRAM_AWQOS           ( AXI_MASTER_M_SRAM_AWQOS           ) ,
	 .AXI_MASTER_M_SRAM_AWREADY         ( AXI_MASTER_M_SRAM_AWREADY         ) ,
	 .AXI_MASTER_M_SRAM_AWSIZE          ( AXI_MASTER_M_SRAM_AWSIZE          ) ,
	 .AXI_MASTER_M_SRAM_AWVALID         ( AXI_MASTER_M_SRAM_AWVALID         ) ,
	 .AXI_MASTER_M_SRAM_BID             ( AXI_MASTER_M_SRAM_BID             ) ,
	 .AXI_MASTER_M_SRAM_BREADY          ( AXI_MASTER_M_SRAM_BREADY          ) ,
	 .AXI_MASTER_M_SRAM_BRESP           ( AXI_MASTER_M_SRAM_BRESP           ) ,
	 .AXI_MASTER_M_SRAM_BVALID          ( AXI_MASTER_M_SRAM_BVALID          ) ,
	 .AXI_MASTER_M_SRAM_RDATA           ( AXI_MASTER_M_SRAM_RDATA           ) ,
	 .AXI_MASTER_M_SRAM_RID             ( AXI_MASTER_M_SRAM_RID             ) ,
	 .AXI_MASTER_M_SRAM_RLAST           ( AXI_MASTER_M_SRAM_RLAST           ) ,
	 .AXI_MASTER_M_SRAM_RREADY          ( AXI_MASTER_M_SRAM_RREADY          ) ,
	 .AXI_MASTER_M_SRAM_RRESP           ( AXI_MASTER_M_SRAM_RRESP           ) ,
	 .AXI_MASTER_M_SRAM_RVALID          ( AXI_MASTER_M_SRAM_RVALID          ) ,
	 .AXI_MASTER_M_SRAM_WDATA           ( AXI_MASTER_M_SRAM_WDATA           ) ,
	 .AXI_MASTER_M_SRAM_WLAST           ( AXI_MASTER_M_SRAM_WLAST           ) ,
	 .AXI_MASTER_M_SRAM_WREADY          ( AXI_MASTER_M_SRAM_WREADY          ) ,
	 .AXI_MASTER_M_SRAM_WSTRB           ( AXI_MASTER_M_SRAM_WSTRB           ) ,
	 .AXI_MASTER_M_SRAM_WVALID          ( AXI_MASTER_M_SRAM_WVALID          ) ,
	 .AXI_MASTER_M_UART_REG_ARADDR      ( AXI_MASTER_M_UART_REG_ARADDR      ) ,
	 .AXI_MASTER_M_UART_REG_ARBURST     ( AXI_MASTER_M_UART_REG_ARBURST     ) ,
	 .AXI_MASTER_M_UART_REG_ARCACHE     ( AXI_MASTER_M_UART_REG_ARCACHE     ) ,
	 .AXI_MASTER_M_UART_REG_ARID        ( AXI_MASTER_M_UART_REG_ARID        ) ,
	 .AXI_MASTER_M_UART_REG_ARLEN       ( AXI_MASTER_M_UART_REG_ARLEN       ) ,
	 .AXI_MASTER_M_UART_REG_ARLOCK      ( AXI_MASTER_M_UART_REG_ARLOCK      ) ,
	 .AXI_MASTER_M_UART_REG_ARPROT      ( AXI_MASTER_M_UART_REG_ARPROT      ) ,
	 .AXI_MASTER_M_UART_REG_ARQOS       ( AXI_MASTER_M_UART_REG_ARQOS       ) ,
	 .AXI_MASTER_M_UART_REG_ARREADY     ( AXI_MASTER_M_UART_REG_ARREADY     ) ,
	 .AXI_MASTER_M_UART_REG_ARSIZE      ( AXI_MASTER_M_UART_REG_ARSIZE      ) ,
	 .AXI_MASTER_M_UART_REG_ARVALID     ( AXI_MASTER_M_UART_REG_ARVALID     ) ,
	 .AXI_MASTER_M_UART_REG_AWADDR      ( AXI_MASTER_M_UART_REG_AWADDR      ) ,
	 .AXI_MASTER_M_UART_REG_AWAKEUP     ( AXI_MASTER_M_UART_REG_AWAKEUP     ) ,
	 .AXI_MASTER_M_UART_REG_AWBURST     ( AXI_MASTER_M_UART_REG_AWBURST     ) ,
	 .AXI_MASTER_M_UART_REG_AWCACHE     ( AXI_MASTER_M_UART_REG_AWCACHE     ) ,
	 .AXI_MASTER_M_UART_REG_AWID        ( AXI_MASTER_M_UART_REG_AWID        ) ,
	 .AXI_MASTER_M_UART_REG_AWLEN       ( AXI_MASTER_M_UART_REG_AWLEN       ) ,
	 .AXI_MASTER_M_UART_REG_AWLOCK      ( AXI_MASTER_M_UART_REG_AWLOCK      ) ,
	 .AXI_MASTER_M_UART_REG_AWPROT      ( AXI_MASTER_M_UART_REG_AWPROT      ) ,
	 .AXI_MASTER_M_UART_REG_AWQOS       ( AXI_MASTER_M_UART_REG_AWQOS       ) ,
	 .AXI_MASTER_M_UART_REG_AWREADY     ( AXI_MASTER_M_UART_REG_AWREADY     ) ,
	 .AXI_MASTER_M_UART_REG_AWSIZE      ( AXI_MASTER_M_UART_REG_AWSIZE      ) ,
	 .AXI_MASTER_M_UART_REG_AWVALID     ( AXI_MASTER_M_UART_REG_AWVALID     ) ,
	 .AXI_MASTER_M_UART_REG_BID         ( AXI_MASTER_M_UART_REG_BID         ) ,
	 .AXI_MASTER_M_UART_REG_BREADY      ( AXI_MASTER_M_UART_REG_BREADY      ) ,
	 .AXI_MASTER_M_UART_REG_BRESP       ( AXI_MASTER_M_UART_REG_BRESP       ) ,
	 .AXI_MASTER_M_UART_REG_BVALID      ( AXI_MASTER_M_UART_REG_BVALID      ) ,
	 .AXI_MASTER_M_UART_REG_RDATA       ( AXI_MASTER_M_UART_REG_RDATA       ) ,
	 .AXI_MASTER_M_UART_REG_RID         ( AXI_MASTER_M_UART_REG_RID         ) ,
	 .AXI_MASTER_M_UART_REG_RLAST       ( AXI_MASTER_M_UART_REG_RLAST       ) ,
	 .AXI_MASTER_M_UART_REG_RREADY      ( AXI_MASTER_M_UART_REG_RREADY      ) ,
	 .AXI_MASTER_M_UART_REG_RRESP       ( AXI_MASTER_M_UART_REG_RRESP       ) ,
	 .AXI_MASTER_M_UART_REG_RVALID      ( AXI_MASTER_M_UART_REG_RVALID      ) ,
	 .AXI_MASTER_M_UART_REG_WDATA       ( AXI_MASTER_M_UART_REG_WDATA       ) ,
	 .AXI_MASTER_M_UART_REG_WLAST       ( AXI_MASTER_M_UART_REG_WLAST       ) ,
	 .AXI_MASTER_M_UART_REG_WREADY      ( AXI_MASTER_M_UART_REG_WREADY      ) ,
	 .AXI_MASTER_M_UART_REG_WSTRB       ( AXI_MASTER_M_UART_REG_WSTRB       ) ,
	 .AXI_MASTER_M_UART_REG_WVALID      ( AXI_MASTER_M_UART_REG_WVALID      ) ,
.AXI_MASTER_M_XSPI_ARADDR(AXI_MASTER_M_XSPI_ARADDR), 
.AXI_MASTER_M_XSPI_ARBURST(AXI_MASTER_M_XSPI_ARBURST), 
.AXI_MASTER_M_XSPI_ARCACHE(AXI_MASTER_M_XSPI_ARCACHE), 
.AXI_MASTER_M_XSPI_ARID(AXI_MASTER_M_XSPI_ARID), 
.AXI_MASTER_M_XSPI_ARLEN(AXI_MASTER_M_XSPI_ARLEN), 
.AXI_MASTER_M_XSPI_ARLOCK(AXI_MASTER_M_XSPI_ARLOCK), 
.AXI_MASTER_M_XSPI_ARPROT(AXI_MASTER_M_XSPI_ARPROT), 
.AXI_MASTER_M_XSPI_ARQOS(AXI_MASTER_M_XSPI_ARQOS), 
.AXI_MASTER_M_XSPI_ARREADY(AXI_MASTER_M_XSPI_ARREADY), 
.AXI_MASTER_M_XSPI_ARSIZE(AXI_MASTER_M_XSPI_ARSIZE), 
.AXI_MASTER_M_XSPI_ARVALID(AXI_MASTER_M_XSPI_ARVALID), 
.AXI_MASTER_M_XSPI_AWADDR(AXI_MASTER_M_XSPI_AWADDR), 
.AXI_MASTER_M_XSPI_AWAKEUP(AXI_MASTER_M_XSPI_AWAKEUP), 
.AXI_MASTER_M_XSPI_AWBURST(AXI_MASTER_M_XSPI_AWBURST), 
.AXI_MASTER_M_XSPI_AWCACHE(AXI_MASTER_M_XSPI_AWCACHE), 
.AXI_MASTER_M_XSPI_AWID(AXI_MASTER_M_XSPI_AWID), 
.AXI_MASTER_M_XSPI_AWLEN(AXI_MASTER_M_XSPI_AWLEN), 
.AXI_MASTER_M_XSPI_AWLOCK(AXI_MASTER_M_XSPI_AWLOCK), 
.AXI_MASTER_M_XSPI_AWPROT(AXI_MASTER_M_XSPI_AWPROT), 
.AXI_MASTER_M_XSPI_AWQOS(AXI_MASTER_M_XSPI_AWQOS), 
.AXI_MASTER_M_XSPI_AWREADY(AXI_MASTER_M_XSPI_AWREADY), 
.AXI_MASTER_M_XSPI_AWSIZE(AXI_MASTER_M_XSPI_AWSIZE), 
.AXI_MASTER_M_XSPI_AWVALID(AXI_MASTER_M_XSPI_AWVALID), 
.AXI_MASTER_M_XSPI_BID(AXI_MASTER_M_XSPI_BID), 
.AXI_MASTER_M_XSPI_BREADY(AXI_MASTER_M_XSPI_BREADY), 
.AXI_MASTER_M_XSPI_BRESP(AXI_MASTER_M_XSPI_BRESP), 
.AXI_MASTER_M_XSPI_BVALID(AXI_MASTER_M_XSPI_BVALID), 
.AXI_MASTER_M_XSPI_RDATA(AXI_MASTER_M_XSPI_RDATA), 
.AXI_MASTER_M_XSPI_RID(AXI_MASTER_M_XSPI_RID), 
.AXI_MASTER_M_XSPI_RLAST(AXI_MASTER_M_XSPI_RLAST), 
.AXI_MASTER_M_XSPI_RREADY(AXI_MASTER_M_XSPI_RREADY), 
.AXI_MASTER_M_XSPI_RRESP(AXI_MASTER_M_XSPI_RRESP), 
.AXI_MASTER_M_XSPI_RVALID(AXI_MASTER_M_XSPI_RVALID), 
.AXI_MASTER_M_XSPI_WDATA(AXI_MASTER_M_XSPI_WDATA), 
.AXI_MASTER_M_XSPI_WLAST(AXI_MASTER_M_XSPI_WLAST), 
.AXI_MASTER_M_XSPI_WREADY(AXI_MASTER_M_XSPI_WREADY), 
.AXI_MASTER_M_XSPI_WSTRB(AXI_MASTER_M_XSPI_WSTRB), 
.AXI_MASTER_M_XSPI_WVALID(AXI_MASTER_M_XSPI_WVALID), 

 .AXI_SLAVE_S_CPU_ARADDR            ( AXI_SLAVE_S_CPU_ARADDR            ) ,
 .AXI_SLAVE_S_CPU_ARBURST           ( AXI_SLAVE_S_CPU_ARBURST           ) ,
 .AXI_SLAVE_S_CPU_ARCACHE           ( AXI_SLAVE_S_CPU_ARCACHE           ) ,
 .AXI_SLAVE_S_CPU_ARID              ( AXI_SLAVE_S_CPU_ARID              ) ,
 .AXI_SLAVE_S_CPU_ARLEN             ( AXI_SLAVE_S_CPU_ARLEN             ) ,
 .AXI_SLAVE_S_CPU_ARLOCK            ( AXI_SLAVE_S_CPU_ARLOCK            ) ,
 .AXI_SLAVE_S_CPU_ARPROT            ( AXI_SLAVE_S_CPU_ARPROT            ) ,
 .AXI_SLAVE_S_CPU_ARQOS             ( AXI_SLAVE_S_CPU_ARQOS             ) ,
 .AXI_SLAVE_S_CPU_ARREADY           ( AXI_SLAVE_S_CPU_ARREADY           ) ,
 .AXI_SLAVE_S_CPU_ARSIZE            ( AXI_SLAVE_S_CPU_ARSIZE            ) ,
 .AXI_SLAVE_S_CPU_ARVALID           ( AXI_SLAVE_S_CPU_ARVALID           ) ,
 .AXI_SLAVE_S_CPU_AWADDR            ( AXI_SLAVE_S_CPU_AWADDR            ) ,
 .AXI_SLAVE_S_CPU_AWAKEUP           ( AXI_SLAVE_S_CPU_AWAKEUP           ) ,
 .AXI_SLAVE_S_CPU_AWBURST           ( AXI_SLAVE_S_CPU_AWBURST           ) ,
 .AXI_SLAVE_S_CPU_AWCACHE           ( AXI_SLAVE_S_CPU_AWCACHE           ) ,
 .AXI_SLAVE_S_CPU_AWID              ( AXI_SLAVE_S_CPU_AWID              ) ,
 .AXI_SLAVE_S_CPU_AWLEN             ( AXI_SLAVE_S_CPU_AWLEN             ) ,
 .AXI_SLAVE_S_CPU_AWLOCK            ( AXI_SLAVE_S_CPU_AWLOCK            ) ,
 .AXI_SLAVE_S_CPU_AWPROT            ( AXI_SLAVE_S_CPU_AWPROT            ) ,
 .AXI_SLAVE_S_CPU_AWQOS             ( AXI_SLAVE_S_CPU_AWQOS             ) ,
 .AXI_SLAVE_S_CPU_AWREADY           ( AXI_SLAVE_S_CPU_AWREADY           ) ,
 .AXI_SLAVE_S_CPU_AWSIZE            ( AXI_SLAVE_S_CPU_AWSIZE            ) ,
 .AXI_SLAVE_S_CPU_AWVALID           ( AXI_SLAVE_S_CPU_AWVALID           ) ,
 .AXI_SLAVE_S_CPU_BID               ( AXI_SLAVE_S_CPU_BID               ) ,
 .AXI_SLAVE_S_CPU_BREADY            ( AXI_SLAVE_S_CPU_BREADY            ) ,
 .AXI_SLAVE_S_CPU_BRESP             ( AXI_SLAVE_S_CPU_BRESP             ) ,
 .AXI_SLAVE_S_CPU_BVALID            ( AXI_SLAVE_S_CPU_BVALID            ) ,
 .AXI_SLAVE_S_CPU_RDATA             ( AXI_SLAVE_S_CPU_RDATA             ) ,
 .AXI_SLAVE_S_CPU_RID               ( AXI_SLAVE_S_CPU_RID               ) ,
 .AXI_SLAVE_S_CPU_RLAST             ( AXI_SLAVE_S_CPU_RLAST             ) ,
 .AXI_SLAVE_S_CPU_RREADY            ( AXI_SLAVE_S_CPU_RREADY            ) ,
 .AXI_SLAVE_S_CPU_RRESP             ( AXI_SLAVE_S_CPU_RRESP             ) ,
 .AXI_SLAVE_S_CPU_RVALID            ( AXI_SLAVE_S_CPU_RVALID            ) ,
 .AXI_SLAVE_S_CPU_WDATA             ( AXI_SLAVE_S_CPU_WDATA             ) ,
 .AXI_SLAVE_S_CPU_WLAST             ( AXI_SLAVE_S_CPU_WLAST             ) ,
 .AXI_SLAVE_S_CPU_WREADY            ( AXI_SLAVE_S_CPU_WREADY            ) ,
 .AXI_SLAVE_S_CPU_WSTRB             ( AXI_SLAVE_S_CPU_WSTRB             ) ,
 .AXI_SLAVE_S_CPU_WVALID            ( AXI_SLAVE_S_CPU_WVALID            ) ,
 .AXI_SLAVE_S_XSPI_ARADDR           ( AXI_SLAVE_S_XSPI_ARADDR           ) ,
 .AXI_SLAVE_S_XSPI_ARBURST          ( AXI_SLAVE_S_XSPI_ARBURST          ) ,
 .AXI_SLAVE_S_XSPI_ARCACHE          ( AXI_SLAVE_S_XSPI_ARCACHE          ) ,
 .AXI_SLAVE_S_XSPI_ARID             ( AXI_SLAVE_S_XSPI_ARID             ) ,
 .AXI_SLAVE_S_XSPI_ARLEN            ( AXI_SLAVE_S_XSPI_ARLEN            ) ,
 .AXI_SLAVE_S_XSPI_ARLOCK           ( AXI_SLAVE_S_XSPI_ARLOCK           ) ,
 .AXI_SLAVE_S_XSPI_ARPROT           ( AXI_SLAVE_S_XSPI_ARPROT           ) ,
 .AXI_SLAVE_S_XSPI_ARQOS            ( AXI_SLAVE_S_XSPI_ARQOS            ) ,
 .AXI_SLAVE_S_XSPI_ARREADY          ( AXI_SLAVE_S_XSPI_ARREADY          ) ,
 .AXI_SLAVE_S_XSPI_ARSIZE           ( AXI_SLAVE_S_XSPI_ARSIZE           ) ,
 .AXI_SLAVE_S_XSPI_ARVALID          ( AXI_SLAVE_S_XSPI_ARVALID          ) ,
 .AXI_SLAVE_S_XSPI_AWADDR           ( AXI_SLAVE_S_XSPI_AWADDR           ) ,
 .AXI_SLAVE_S_XSPI_AWAKEUP          ( AXI_SLAVE_S_XSPI_AWAKEUP          ) ,
 .AXI_SLAVE_S_XSPI_AWBURST          ( AXI_SLAVE_S_XSPI_AWBURST          ) ,
 .AXI_SLAVE_S_XSPI_AWCACHE          ( AXI_SLAVE_S_XSPI_AWCACHE          ) ,
 .AXI_SLAVE_S_XSPI_AWID             ( AXI_SLAVE_S_XSPI_AWID             ) ,
 .AXI_SLAVE_S_XSPI_AWLEN            ( AXI_SLAVE_S_XSPI_AWLEN            ) ,
 .AXI_SLAVE_S_XSPI_AWLOCK           ( AXI_SLAVE_S_XSPI_AWLOCK           ) ,
 .AXI_SLAVE_S_XSPI_AWPROT           ( AXI_SLAVE_S_XSPI_AWPROT           ) ,
 .AXI_SLAVE_S_XSPI_AWQOS            ( AXI_SLAVE_S_XSPI_AWQOS            ) ,
 .AXI_SLAVE_S_XSPI_AWREADY          ( AXI_SLAVE_S_XSPI_AWREADY          ) ,
 .AXI_SLAVE_S_XSPI_AWSIZE           ( AXI_SLAVE_S_XSPI_AWSIZE           ) ,
 .AXI_SLAVE_S_XSPI_AWVALID          ( AXI_SLAVE_S_XSPI_AWVALID          ) ,
 .AXI_SLAVE_S_XSPI_BID              ( AXI_SLAVE_S_XSPI_BID              ) ,
 .AXI_SLAVE_S_XSPI_BREADY           ( AXI_SLAVE_S_XSPI_BREADY           ) ,
 .AXI_SLAVE_S_XSPI_BRESP            ( AXI_SLAVE_S_XSPI_BRESP            ) ,
 .AXI_SLAVE_S_XSPI_BVALID           ( AXI_SLAVE_S_XSPI_BVALID           ) ,
 .AXI_SLAVE_S_XSPI_RDATA            ( AXI_SLAVE_S_XSPI_RDATA            ) ,
 .AXI_SLAVE_S_XSPI_RID              ( AXI_SLAVE_S_XSPI_RID              ) ,
 .AXI_SLAVE_S_XSPI_RLAST            ( AXI_SLAVE_S_XSPI_RLAST            ) ,
 .AXI_SLAVE_S_XSPI_RREADY           ( AXI_SLAVE_S_XSPI_RREADY           ) ,
 .AXI_SLAVE_S_XSPI_RRESP            ( AXI_SLAVE_S_XSPI_RRESP            ) ,
 .AXI_SLAVE_S_XSPI_RVALID           ( AXI_SLAVE_S_XSPI_RVALID           ) ,
 .AXI_SLAVE_S_XSPI_WDATA            ( AXI_SLAVE_S_XSPI_WDATA            ) ,
 .AXI_SLAVE_S_XSPI_WLAST            ( AXI_SLAVE_S_XSPI_WLAST            ) ,
 .AXI_SLAVE_S_XSPI_WREADY           ( AXI_SLAVE_S_XSPI_WREADY           ) ,
 .AXI_SLAVE_S_XSPI_WSTRB            ( AXI_SLAVE_S_XSPI_WSTRB            ) ,
 .AXI_SLAVE_S_XSPI_WVALID           ( AXI_SLAVE_S_XSPI_WVALID           ) ,
 .CPU_CLK                           ( CPU_CLK                           ) ,// Review from here.
 .CPU_DBGEN                         ( CPU_DBGEN                         ) ,
 .CPU_NIDEN                         ( CPU_NIDEN                         ) ,
 .CPU_PMUSNAPSHOTACK                ( CPU_PMUSNAPSHOTACK                ) ,
 .CPU_PMUSNAPSHOTREQ                ( CPU_PMUSNAPSHOTREQ                ) ,
 .CPU_QACCEPTn                      ( CPU_QACCEPTn                      ) ,
 .CPU_QACTIVE                       ( CPU_QACTIVE                       ) ,
 .CPU_QDENY                         ( CPU_QDENY                         ) ,
 .CPU_QREQn                         ( CPU_QREQn                         ) ,
 .CPU_RESETn                        ( CPU_RESETn                        ) ,
 .CPU_SPIDEN                        ( CPU_SPIDEN                        ) ,
 .CPU_SPNIDEN                       ( CPU_SPNIDEN                       ) ,
 .CPU_nPMUINTERRUPT                 ( CPU_nPMUINTERRUPT                 ) ,
 .DFTCGEN                           ( DFTCGEN                           ) ,
 .DFTCPUDISABLE                     ( DFTCPUDISABLE                     ) ,
 .DFTPERIPHDISABLE                  ( DFTPERIPHDISABLE                  ) ,
 .DFTRSTDISABLE                     ( DFTRSTDISABLE                     ) ,
 .DFTSYSTEMDISABLE                  ( DFTSYSTEMDISABLE                  ) ,
 .DFTXSPIDISABLE                    ( DFTXSPIDISABLE                    ) ,
 .ECOREVNUM                         ( ECOREVNUM                         ) ,
 .PD_0_INTERRUPT                    ( PD_0_INTERRUPT                    ) ,
 .PD_0_NS_INTERRUPT                 ( PD_0_NS_INTERRUPT                 ) ,
 .PD_0_PACCEPT                      ( PD_0_PACCEPT                      ) ,
 .PD_0_PACTIVE                      ( PD_0_PACTIVE                      ) ,
 .PD_0_PDENY                        ( PD_0_PDENY                        ) ,
 .PD_0_PREQ                         ( PD_0_PREQ                         ) ,
 .PD_0_PSTATE                       ( PD_0_PSTATE                       ) ,
 .PERIPH_CLK                        ( PERIPH_CLK                        ) ,
 .PERIPH_DBGEN                      ( PERIPH_DBGEN                      ) ,
 .PERIPH_NIDEN                      ( PERIPH_NIDEN                      ) ,
 .PERIPH_PMUSNAPSHOTACK             ( PERIPH_PMUSNAPSHOTACK             ) ,
 .PERIPH_PMUSNAPSHOTREQ             ( PERIPH_PMUSNAPSHOTREQ             ) ,
 .PERIPH_QACCEPTn                   ( PERIPH_QACCEPTn                   ) ,
 .PERIPH_QACTIVE                    ( PERIPH_QACTIVE                    ) ,
 .PERIPH_QDENY                      ( PERIPH_QDENY                      ) ,
 .PERIPH_QREQn                      ( PERIPH_QREQn                      ) ,
 .PERIPH_RESETn                     ( PERIPH_RESETn                     ) ,
 .PERIPH_SPIDEN                     ( PERIPH_SPIDEN                     ) ,
 .PERIPH_SPNIDEN                    ( PERIPH_SPNIDEN                    ) ,
 .PERIPH_nPMUINTERRUPT              ( PERIPH_nPMUINTERRUPT              ) ,
 .SYSTEM_CLK                        ( SYSTEM_CLK                        ) ,
 .SYSTEM_DBGEN                      ( SYSTEM_DBGEN                      ) ,
 .SYSTEM_NIDEN                      ( SYSTEM_NIDEN                      ) ,
 .SYSTEM_PMUSNAPSHOTACK             ( SYSTEM_PMUSNAPSHOTACK             ) ,
 .SYSTEM_PMUSNAPSHOTREQ             ( SYSTEM_PMUSNAPSHOTREQ             ) ,
 .SYSTEM_QACCEPTn                   ( SYSTEM_QACCEPTn                   ) ,
 .SYSTEM_QACTIVE                    ( SYSTEM_QACTIVE                    ) ,
 .SYSTEM_QDENY                      ( SYSTEM_QDENY                      ) ,
 .SYSTEM_QREQn                      ( SYSTEM_QREQn                      ) ,
 .SYSTEM_RESETn                     ( SYSTEM_RESETn                     ) ,
 .SYSTEM_SPIDEN                     ( SYSTEM_SPIDEN                     ) ,
 .SYSTEM_SPNIDEN                    ( SYSTEM_SPNIDEN                    ) ,
 .SYSTEM_nPMUINTERRUPT              ( SYSTEM_nPMUINTERRUPT              ) ,
 .S_CPU_CONFIG_ACCESS               ( S_CPU_CONFIG_ACCESS               ) ,
 .S_XSPI_CONFIG_ACCESS              ( S_XSPI_CONFIG_ACCESS              ) ,
 .XSPI_CLK                          ( XSPI_CLK                          ) ,
 .XSPI_DBGEN                        ( XSPI_DBGEN                        ) ,
 .XSPI_NIDEN                        ( XSPI_NIDEN                        ) ,
 .XSPI_PMUSNAPSHOTACK               ( XSPI_PMUSNAPSHOTACK               ) ,
 .XSPI_PMUSNAPSHOTREQ               ( XSPI_PMUSNAPSHOTREQ               ) ,
 .XSPI_QACCEPTn                     ( XSPI_QACCEPTn                     ) ,
 .XSPI_QACTIVE                      ( XSPI_QACTIVE                      ) ,
 .XSPI_QDENY                        ( XSPI_QDENY                        ) ,
 .XSPI_QREQn                        ( XSPI_QREQn                        ) ,
 .XSPI_RESETn                       ( XSPI_RESETn                       ) ,
 .XSPI_SPIDEN                       ( XSPI_SPIDEN                       ) ,
 .XSPI_SPNIDEN                      ( XSPI_SPNIDEN                      ) ,
 .XSPI_nPMUINTERRUPT                ( XSPI_nPMUINTERRUPT                ) 
); 

reg pmu_sm;

always @(posedge system_clk or negedge system_rst_n)begin
	if(!system_rst_n)begin
		pmu_sm <=1'b1;
		PD_0_PREQ <=1'b0;
	end
	else if(pmu_sm)begin
		PD_0_PREQ <=1'b1;
		if(PD_0_PACCEPT)begin
		PD_0_PREQ <=1'b0;
		pmu_sm <=1'b0;
		end
	end

end

reg [31:0] watchdog_count;
assign watchdog_timeout = (
	watchdog_count == 0 &&
	system_reg_hwif_out.SystemConfig.wdog_disable.value == 0
);
always@(posedge system_clk or negedge system_rst_n) begin 
	if(!system_rst_n) watchdog_count <= system_reg_hwif_out.watchdog_count.watchdog_count.value;
	else begin 
		if(system_reg_hwif_out.Watchdog.kick.value) watchdog_count <= system_reg_hwif_out.watchdog_count.watchdog_count.value;
		else if(system_reg_hwif_out.SystemConfig.wdog_disable.swmod) watchdog_count <= system_reg_hwif_out.watchdog_count.watchdog_count.value;
		else if(!system_reg_hwif_out.SystemConfig.wdog_disable.value) begin
			if( watchdog_count == 0) watchdog_count <= system_reg_hwif_out.watchdog_count.watchdog_count.value;
			else watchdog_count<=watchdog_count - 1;
		end
end
end
assign system_reg_hwif_in.PowerDomainAck.cpu_pd_ack.next = cpu_pd_ack;
assign system_reg_hwif_in.PowerDomainAck.sram_pd_ack.next = 1'b0;
assign system_reg_hwif_in.PowerDomainAck.chiplet_pd_ack.next = 1'b0;
assign system_reg_hwif_in.PowerDomainAck.mram_pd_ack.next =  ~ mram_axi_busy;
assign system_reg_hwif_in.PowerDomainAck.system_pd_ack.next =  1'b0;
assign system_reg_hwif_in.PowerDomainAck.hyperbus_pd_ack.next =  1'b0;
assign system_reg_hwif_in.PowerDomainAck.minion_pd_ack.next =  minion_pd_ack;
assign system_reg_hwif_in.ChipMode.chip_mode.next =  0; // hyperbus
assign system_reg_hwif_in.ChipMode.ifc_width.next =  0; // hyperbus

endmodule: erbium_digital_et
// vim: foldmethod=indent
