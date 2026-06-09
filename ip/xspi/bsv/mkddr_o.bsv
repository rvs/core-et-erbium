/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-05
 Description: A brief description of the file's purpose.
*/
// Bluespec wrapper, created by Import BVI Wizard
// Created on: Sun Sep 14 22:19:49 IST 2025
// Created by: vijayvithal
// BDW version: {} {} 882349b


interface XSPI_o#(type bus_t);
	(*always_ready , always_enabled*)
	method Action data_re (bus_t data_re);
	(*always_ready , always_enabled*)
	method Action data_fe (bus_t data_fe);
	method Action ddr_mode ();
	(*always_enabled*)
	method bus_t dout ();
endinterface

import "BVI" ddr_o =
module mkddr_o  (XSPI_o#(bus_t))provisos (
	Bits#(bus_t,bus_width));

	parameter BUS_WIDTH = valueOf(bus_width);

	default_clock clk_clk;
	default_reset rst;

	input_clock clk_clk (clk)  <- exposeCurrentClock;
	input_reset rst (/* empty */) clocked_by(clk_clk)  <- exposeCurrentReset;


	method data_re (data_re /*BUS_WIDTH-1:0*/)
		 enable((*inhigh*)data_re_enable) clocked_by(clk_clk) reset_by(rst);
	method data_fe (data_fe /*BUS_WIDTH-1:0*/)
		 enable((*inhigh,unused*)data_fe_enable) clocked_by(clk_clk) reset_by(rst);
	method ddr_mode ()
		 enable(ddr_mode) clocked_by(clk_clk) reset_by(rst);
	method dout /* BUS_WIDTH-1:0 */ dout ()
		 clocked_by(clk_clk) reset_by(rst);

	schedule data_re C data_re;
	schedule data_re CF data_fe;
	schedule data_re CF ddr_mode;
	schedule dout SB data_re;
	schedule data_fe C data_fe;
	schedule data_fe CF ddr_mode;
	schedule dout SB data_fe;
	schedule ddr_mode C ddr_mode;
	schedule dout SB ddr_mode;
	schedule dout CF dout;
endmodule


