module erbium_digital_et_aon #(
) (
// Test Signals
    inout       ANATEST0,
    inout       ANATEST1,
    input wire  TestMode,
    input wire brownout_b,

    // xSPI IO Signals
    input wire XSPI_CSN,
    input wire [7:0] XSPI_DQ_IN,
    output wire [7:0] XSPI_DQ_OUT,
    output wire XSPI_DQ_OEN,
    input wire XSPI_RWDS_IN,
    output wire XSPI_RWDS_OUT,
    output wire XSPI_RWDS_OEN,
    input wire [1:0] xspi_mode,
    // GPIO
    input wire [10:0] gpio_in,
    output wire [10:0] gpio_out,
    output wire [10:0] gpio_out_ena,
    output wire [2:0] drive_strength,

    // Analog signals
// JTAG
    input wire TDI,
    input wire TMS,
    input wire TCK,
    input wire TRSTn,
    output wire TDO,
    output wire TDOEN

);

System_Reg_pkg::System_Reg__out_t system_reg_hwif_out;
  wire cpu_power_good=1'b1;
  wire cpu_warm_reset_req;
  wire mram_power_good=1'b1;
  wire chip_power_good=1'b1;
  wire xspi_power_good=1'b1;
  wire power_off_req;
  wire chip_power_on;
  wire chip_iso;
  wire chip_reset_req;
  wire sysreset_req;
  wire soft_reset;
  wire cpu_soft_reset;
  wire fclk;
  wire mram_clk;
  wire mram_rst_n;
  wire cpu_csr_clk;
  wire ring_osc_clk;
  wire cpu_csr_rst_n;
  wire hyperbus_csr_clk;
  wire hyperbus_csr_rst_n;
  wire tcm_clk;
  wire nic_clk;
  wire nic_rst_n;
  wire hrst_n;
  wire arm_hclk;
  wire aon_sysclk;
  wire aon_rst_n;
  wire mram_pd_req;
  wire cpu_pd_req;
  wire cpu_por_rst_n;
  reg [20:0] counter;
  wire [20:0] power_good_counter_out;
  wire  power_good_counter_out_valid;
  reg  power_good_counter_out_valid_d;

    wire periph_clk;
    wire periph_rst_n;
    wire system_clk;
    wire system_rst_n;

wire brownout_clear;
wire brownout_cause;

wire por_clear;
wire por_cause;

wire watchdog_clear;
wire watchdog_cause;

wire soft_reset_clear;
wire soft_reset_cause;

  wire [20:0] power_good_counter_in;
wire [10:0] gpio_i;
wire [10:0] gpio_o;
wire [10:0] gpio_oe;
wire gpio_0_mode_n;

wire OSC_CLK_OUT;

assign gpio_out[0] =gpio_0_mode_n ? OSC_CLK_OUT : gpio_o[0];
assign gpio_out[10:1] = gpio_o[10:1];
assign gpio_out_ena = gpio_oe;
assign gpio_i[10:0] = gpio_in[10:0];
ring_osc ring_osc (
.en             (system_reg_hwif_out.ring_osc.en.value),
.divby2_sel     (system_reg_hwif_out.ring_osc.divby2_sel.value),
.trm            (system_reg_hwif_out.ring_osc.trm.value),
.dbg_en         (system_reg_hwif_out.ring_osc.dbg_en.value),
.dbg_anachip_en (system_reg_hwif_out.ring_osc.dbg_anachip_en.value),
.dbg_rohcip_en  (system_reg_hwif_out.ring_osc.dbg_rohcip_en.value),
.dbg_sah_en_b   (system_reg_hwif_out.ring_osc.dbg_sah_en_b.value),
.clk            (ring_osc_clk)
);
  always@(posedge aon_sysclk or negedge aon_rst_n)
  if(! aon_rst_n)begin
    counter<='hfffff;
    power_good_counter_out_valid_d<=1'b0;
  end else begin
    power_good_counter_out_valid_d <= power_good_counter_out_valid;
    if(power_good_counter_out_valid_d) counter<=power_good_counter_out;
  end
  assign power_good_counter_in=counter;

  erbium_digital_et erbium_digital(
.*
  );

  aon_ctrl aon_ctrl(
    .power_off_req(power_off_req),
    .cs_n(XSPI_CSN),
    .tms(TMS),
    .chip_pd_req(chip_pd_req),
    .clk(aon_sysclk),
    .rst_n(aon_rst_n)
  );

  wire mram_power_on;
  wire mram_rst_b;
  wire cpu_power_on;

  prcm_et prcm_et (
    .TCK(TCK),
    .OSC_CLK_IN(ring_osc_clk),
    .OSC_CLK_OUT(OSC_CLK_OUT),
    .cpu_clk_div_count(system_reg_hwif_out.cpu_divider.count.value),
    .cpu_clk_div_enable(system_reg_hwif_out.cpu_divider.div_enable.value),
    .sys_clk_div_count(system_reg_hwif_out.system_divider.count.value),
    .sys_clk_div_enable(system_reg_hwif_out.system_divider.div_enable.value),
    .periph_clk_div_count(system_reg_hwif_out.periph_divider.count.value),
    .periph_clk_div_enable(system_reg_hwif_out.periph_divider.div_enable.value),

    .brownout_clear(system_reg_hwif_out.ResetCause.brownout.swacc),
    .brownout_cause(brownout_cause),
    .por_clear(system_reg_hwif_out.ResetCause.por.swacc),
    .por_cause(por_cause),
    .watchdog_clear(system_reg_hwif_out.ResetCause.watchdog_timedout.swacc),
    .watchdog_cause(watchdog_cause),
    .soft_reset_clear(system_reg_hwif_out.ResetCause.softreset.swacc),
    .soft_reset_cause(soft_reset_cause),
/////
    .TRSTn(TRSTn),
    .brownout_n(brownout_b),
    .counter(counter),
    .use_xspi_clk(use_xspi_clk),
    .soft_reset(soft_reset),
    .watchdog_timeout(watchdog_timeout),
    //XSPI
    .xspi_pd_req(xspi_pd_req),
    .xspi_power_good(xspi_power_good),
    .xspi_power_on(xspi_power_on),
    .xspi_iso(xspi_iso),
    .xspi_clk(xspi_clk),
    .xspi_rst_n(xspi_rst_n),
    .xspi_soft_reset(xspi_rst_req),
    // CPU Signals
    .cpu_clk(cpu_clock),
    .cpu_rst_cold(cpu_reset_cold),
    .cpu_rst_warm(cpu_reset_warm),
    .cpu_pd_req(cpu_pd_req),
    .cpu_power_good(cpu_power_good),
    .cpu_warm_reset_req(cpu_warm_reset_req),
    .cpu_power_on(cpu_power_on),
    .cpu_iso(cpu_iso),
    .cpu_soft_reset(cpu_soft_reset),// cold reset
    .chip_pd_req(chip_pd_req),
    .chip_power_on(chip_power_on),
    .chip_power_good(chip_power_good),
    .chip_iso(chip_iso),
    // I2C
    .i2c_clk(i2c_clk),
    .i2c_arst_n(i2c_arst_n),
    // UART
    .uart_clk(uart_clk),
    .uart_rst_n(uart_rst_n),
    .uart_domain_rst_n(uart_domain_rst_n),
    .periph_pd_req(1'b0),
    .periph_power_good(1'b1),
    .periph_power_on(),
    .periph_iso(),
    .periph_soft_reset(1'b0),
    .periph_clk(periph_clk),
    .periph_rst_n(periph_rst_n),
    //QSPI
    .qspi_clk(qspi_clk),
    .qspi_rst_n(qspi_rst_n),
    .qspi_slow_clock(qspi_slow_clock),
    .qspi_slow_rst_n(qspi_slow_rst_n),

    // MRAM
    .mram_power_on(mram_power_on),
    .mram_iso(mram_iso),
    .mram_pd_req(mram_pd_req),
    .mram_power_good(mram_power_good),
    .mram_clk(mram_clk),
    .mram_rst_n(mram_rst_b),
    .mram_soft_reset(1'b0),
    // Default System
    .system_reg_clk(system_reg_clk),
    .system_reg_rst_n(system_reg_arst_n),
    .sram_clk(sram_clk),
    .sram_rst_n(sram_rst_n),
    .system_clk(system_clk),
    .system_rst_n(system_rst_n),
    //Reset Cause
    .aon_sysclk(aon_sysclk),
    .aon_rst_n(aon_rst_n)
  );

endmodule


module keep_cell(
	input wire in,
	output wire out);
assign out=in;
endmodule
// vim: foldmethod=indent
