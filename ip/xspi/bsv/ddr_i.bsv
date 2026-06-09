/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-05
 Description: A brief description of the file's purpose.
*/
// Bluespec wrapper, created by Import BVI Wizard
// Created on: Wed Oct 15 18:35:24 IST 2025
// Created by: vijayvithal
// BDW version: {} {} 882349b


interface XSPI_I#(type bus_t);
	(*always_ready , always_enabled*)
	method Action din (bus_t din);
	(*always_ready , always_enabled*)
	method Action rwds_in (Bool rwds_in);
	(*always_ready , always_enabled*)
	method Action cmd_data_rate (Bit#(4) data_rate);
	method Action addr_data_rate (Bit#(4) data_rate);
	method Action ena ();
	method Action ddr_mode ();
	(*always_enabled*)
	method bus_t data_re ();
	(*always_enabled*)
	method bus_t data_fe ();
	(*always_enabled*)
	method Bool rwds_re ();
	(*always_enabled*)
	method Bool rwds_fe ();
endinterface

import "BVI" ddr_i =
module mkddr_i  (XSPI_I#(bus_t))
	provisos(Bits#(bus_t,sa));

	parameter BUS_WIDTH = valueOf(sa);

	default_clock clk_clk;
	default_reset rst;

	input_clock clk_clk (clk)  <- exposeCurrentClock;
	input_reset rst (/* empty */) clocked_by(clk_clk)  <- exposeCurrentReset;


	method din (din /*BUS_WIDTH-1:0*/)
		 enable((*inhigh*)din_enable) clocked_by(clk_clk) reset_by(rst);
	method rwds_in (rwds_in )
		 enable((*inhigh*)rwds_in_enable) clocked_by(clk_clk) reset_by(rst);
	method cmd_data_rate (cmd_data_rate /*1:0*/)
		 enable((*inhigh*)cmd_data_rate_enable) clocked_by(clk_clk) reset_by(rst);
	method addr_data_rate (addr_data_rate /*1:0*/)
		 enable((*inhigh*)addr_data_rate_enable) clocked_by(clk_clk) reset_by(rst);
	method ena ()
		 enable(ena) clocked_by(clk_clk) reset_by(rst);
	method ddr_mode ()
		 enable(ddr_mode) clocked_by(clk_clk) reset_by(rst);
	method data_re /* BUS_WIDTH-1:0 */ data_re ()
	ready(data_valid) clocked_by(clk_clk) reset_by(rst);
	method data_fe /* BUS_WIDTH-1:0 */ data_fe ()
	ready(data_valid) clocked_by(clk_clk) reset_by(rst);

	method rwds_re /* BUS_WIDTH-1:0 */ rwds_re ()
	ready(data_valid) clocked_by(clk_clk) reset_by(rst);
	method rwds_fe /* BUS_WIDTH-1:0 */ rwds_fe ()
	ready(data_valid) clocked_by(clk_clk) reset_by(rst);

	schedule rwds_re CF rwds_fe;
	schedule rwds_in C rwds_in;
	schedule rwds_in CF (din,data_fe, data_re, din,cmd_data_rate,addr_data_rate,ena,ddr_mode);
	schedule rwds_fe CF (din,data_re, data_fe,rwds_fe, rwds_re, cmd_data_rate, addr_data_rate, ena,ddr_mode);
	schedule rwds_re CF (din,data_re, data_fe,rwds_fe, rwds_re, cmd_data_rate, addr_data_rate, ena,ddr_mode);
	schedule din C din;
	schedule din CF cmd_data_rate;
	schedule din CF addr_data_rate;
	schedule din CF ena;
	schedule din CF ddr_mode;
	schedule rwds_re SB rwds_in;
	schedule rwds_fe SB rwds_in;
	schedule data_re SB din;
	schedule data_fe SB din;
	schedule cmd_data_rate C cmd_data_rate;
	schedule addr_data_rate C addr_data_rate;
	schedule cmd_data_rate CF ena;
	schedule cmd_data_rate CF addr_data_rate;
	schedule addr_data_rate CF ena;
	schedule cmd_data_rate CF ddr_mode;
	schedule addr_data_rate CF ddr_mode;
	schedule data_re SB cmd_data_rate;
	schedule data_re SB addr_data_rate;
	schedule data_fe SB cmd_data_rate;
	schedule data_fe SB addr_data_rate;
	schedule ena C ena;
	schedule ena CF ddr_mode;
	schedule data_re SB ena;
	schedule data_fe SB ena;
	schedule ddr_mode C ddr_mode;
	schedule data_re SB ddr_mode;
	schedule data_fe SB ddr_mode;
	schedule data_re CF data_re;
	schedule data_re CF data_fe;
	schedule data_fe CF data_fe;
endmodule


