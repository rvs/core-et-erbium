/* Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
*  Author: Vijayvithal <jvs@nekko.ai>
*  Created on: 2026-01-27
*  Description: PRCM for ET isotope.
    * Each domain requires the following signals
    * input pd_req
    * input power_good
    * output power_on
    * output iso
    * input soft_reset
    * output clk
    * output rst_n
*/

`timescale 1ns/1ps
module prcm_et(
    // System Signals
    input wire OSC_CLK_IN,
    input   wire        TCK,
    input   wire        use_xspi_clk,
    input wire [3:0] cpu_clk_div_count,
    input wire cpu_clk_div_enable,
    output cpu_clk,

    output wire OSC_CLK_OUT,
    input wire [3:0] sys_clk_div_count,
    input wire sys_clk_div_enable,
    input wire [3:0] periph_clk_div_count,
    input wire periph_clk_div_enable,

    input   wire        TRSTn,
    input   wire        brownout_n,
    input wire [20:0] counter,
    input   wire        soft_reset,
    input wire watchdog_timeout,
    // XSPI
    input  xspi_pd_req,
    input  xspi_power_good,
    output xspi_power_on,
    output xspi_iso,
    input  xspi_soft_reset,
    output xspi_clk,
    output xspi_rst_n,
    //CPU Signals
    input  cpu_pd_req,
    input  cpu_power_good,
    input wire cpu_warm_reset_req,
    output cpu_power_on,
    output cpu_iso,
    input  cpu_soft_reset, // cold reset
    output cpu_rst_cold,
    output cpu_rst_warm,
    //Chip Domain Signals
    input wire chip_pd_req,
    output wire chip_power_on,
    input wire chip_power_good,
    output wire chip_iso,
    // MRAM
    input  mram_pd_req,
    input  mram_power_good,
    output mram_power_on,
    output mram_iso,
    input  mram_soft_reset,
    output mram_clk,
    output mram_rst_n,
    // I2C
    output wire i2c_arst_n,
    output wire i2c_clk,
    // UART
    output wire uart_rst_n,
    output wire uart_clk,
    // Periph
    input  periph_pd_req,
    input  periph_power_good,
    output periph_power_on,
    output periph_iso,
    input  periph_soft_reset,
    output periph_clk,
    output periph_rst_n,
    output wire uart_domain_rst_n,
    // QSPI
    output wire qspi_clk,
    output wire qspi_rst_n,
    output wire qspi_slow_clock,
    output wire qspi_slow_rst_n,
    // SRAM
    output wire sram_clk,
    output wire sram_rst_n,
    //
    output wire system_reg_clk,
    output wire system_reg_rst_n,
    // Reset Cause
    input wire brownout_clear,
    output wire brownout_cause,
    
    input wire por_clear,
    output wire por_cause,
    
    input wire watchdog_clear,
    output wire watchdog_cause,
    
    input wire soft_reset_clear,
    output wire soft_reset_cause,
    //misc
    output wire system_clk,
    output wire system_rst_n,
    output  wire        aon_sysclk,
    output  wire        aon_rst_n

);
// Wire declaration

wire sys_clk1ghz;
prcm_clk_mux_gf clk_mux_sysclk(
	.a_clk(OSC_CLK_IN),
	.b_clk(TCK),
	.sel_a(!use_xspi_clk),
  .rst_n(synced_por_n),
	.out_clk(sys_clk1ghz)
);

prcm_clk_divider clk_div_cpu(
	.clk_in(sys_clk1ghz),
	.count(cpu_clk_div_count),
	.div_enable(cpu_clk_div_enable),
	.clk_out(cpu_clk)
);

prcm_clk_divider clk_div_sys(
	.clk_in(cpu_clk),
	.count(sys_clk_div_count),
	.div_enable(sys_clk_div_enable),
	.clk_out(system_clk)
);
prcm_clk_divider clk_div_periph(
	.clk_in(system_clk),
	.count(periph_clk_div_count),
	.div_enable(periph_clk_div_enable),
	.clk_out(periph_clk)
);

// ------------------------------------

prcm_reset_cause Ubrownout_cause(
	.set(!brownout_n),
	.clk(system_clk),
	.clear(brownout_clear),
	.cause(brownout_cause));
prcm_reset_cause Upor_cause(.set(!TRSTn),
	.clk(system_clk),
	.clear(por_clear),
	.cause(por_cause));
prcm_reset_cause Uwatchdog(.set(watchdog_timeout),
	.clk(system_clk),
	.clear(watchdog_clear),
	.cause(watchdog_cause));
prcm_reset_cause Usoft_reset(.set(soft_reset),
	.clk(system_clk),
	.clear(soft_reset_clear),
	.cause(soft_reset_cause));

assign OSC_CLK_OUT = periph_clk;
wire por_n = brownout_n && TRSTn;

prcm_reset_extender#(.RESET_DURATION(32)) por_n_sync(
	.clk(system_clk),
	.rst_in_n(por_n),
	.soft_rst(soft_reset || watchdog_timeout || xspi_soft_reset),
	.rst_out_n(synced_por_n)
);

// Reset Chain
reg [3:0] async_rst_chain;

always @(posedge system_clk or negedge synced_por_n) begin
	if(!synced_por_n) async_rst_chain <= 'b1110;
	else async_rst_chain <= {async_rst_chain[2:0],1'b1};
end

wire async_sys_rst_n = async_rst_chain[0];
wire async_mram_rst_n = async_rst_chain[1];
wire async_periph_rst_n = async_rst_chain[2];
wire async_cpu_rst_n = async_rst_chain[3];

prcm_reset_extender aon_reset_extender(
	.clk(system_clk),
	.rst_in_n(async_sys_rst_n),
	.soft_rst(1'b0),
	.rst_out_n(aon_rst_n)
);
power_aware_reset_ctrl chip_reset_ctrl(
    .rst_in_n(async_sys_rst_n),
    .power_down_in(chip_pd_req),
    .power_on(chip_power_on),
    .power_good(chip_power_good),
    .iso(chip_iso),
    .rst_out_n(chip_rst_n),
    .soft_rst(1'b0),
    .counter(counter),
    .clk(system_clk)
);

power_aware_reset_ctrl mram_reset_ctrl(
    .rst_in_n(async_mram_rst_n),
    .power_down_in(chip_pd_req||mram_pd_req),
    .power_on(mram_power_on),
    .power_good(mram_power_good),
    .iso(mram_iso),
    .rst_out_n(mram_rst_n),
    .soft_rst(1'b0),
    .counter(counter),
    .clk(system_clk)
);

power_aware_reset_ctrl xspi_reset_ctrl(
    .rst_in_n(async_sys_rst_n),
    .power_down_in(chip_pd_req),
    .power_on(xspi_power_on),
    .power_good(xspi_power_good),
    .iso(xspi_iso),
    .rst_out_n(xspi_rst_n),
    .soft_rst(1'b0),
    .counter(counter),
    .clk(xspi_clk)
);
wire cpu_por_rst_n;
power_aware_reset_ctrl cpu_reset_ctrl(
    .rst_in_n(async_cpu_rst_n),
    .power_down_in(chip_pd_req||cpu_pd_req),
    .power_on(cpu_power_on),
    .power_good(cpu_power_good),
    .iso(cpu_iso),
    .rst_out_n(cpu_por_rst_n),
    .soft_rst(cpu_soft_reset),
    .counter(counter),
    .clk(system_clk)
);
prcm_reset_extender cpu_warm_rst_extender(
	.clk(system_clk),
	.rst_in_n(cpu_por_rst_n),
	.soft_rst(cpu_warm_reset_req),
	.rst_out_n(cpu_rst_warm_n)
);
assign system_rst_n = chip_rst_n;
assign system_reg_rst_n =chip_rst_n;
assign sram_rst_n =chip_rst_n;
assign periph_rst_n = chip_rst_n;
assign i2c_arst_n= periph_rst_n;
assign qspi_rst_n =  periph_rst_n;
assign qspi_slow_rst_n = periph_rst_n;
assign uart_rst_n = periph_rst_n;
assign uart_domain_rst_n = periph_rst_n;

assign xspi_clk = TCK;
//-------- TODO Hacks
assign cpu_rst_cold =!cpu_por_rst_n;
assign cpu_rst_warm=!cpu_rst_warm_n;
assign i2c_clk= periph_clk;
assign uart_clk=periph_clk;
assign uart_domain_rst_n=periph_rst_n;
assign qspi_clk = periph_clk;
assign qspi_slow_clock= periph_clk;
assign system_reg_clk = system_clk;
assign sram_clk = system_clk;
assign  mram_clk             = cpu_clk;

//--------

assign aon_sysclk = system_clk;

wire verification_reset_done = aon_rst_n && chip_rst_n && mram_rst_n && xspi_rst_n && cpu_por_rst_n ;
endmodule : prcm_et
