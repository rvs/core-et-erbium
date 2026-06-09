// Bluespec wrapper, created by Import BVI Wizard
// Created on: Thu Jun 13 15:26:52 IST 2024
// Created by: vijayvithal
// BDW version: {} {} 75bb68c


interface HBC;
	interface HB hb;
	(*always_enabled*)
	method Action mem_addr_write (Bit#(32) i_mem_addr, Bit#(8) i_mem_wstrb, Bit#(64) i_mem_wdata);
	method Bit#(64) mem_read_data ();
	(*always_ready*)
	method Action cfg (Bool i_txn_32_64, Bool i_cfg_access, Bit#(6) i_burst_length, Bool i_burst_type, Bit#(4) i_initial_latency);
endinterface

interface HB;
	(*always_enabled*)
	method Bool csn ();
	(*always_enabled*)
	method Bool clk ();
	method Bit#(8) dq_o ();
	(*always_enabled*)
	method Bool resetn ();
	method Bool rwds_o ();
	(*always_ready , always_enabled*)
	method Action in (Bit#(8) i_dq, Bool i_rwds);
endinterface

import "BVI" hbc =
module mkhbc  (HBC);

	default_clock clk_i_clk;
	default_reset rst_i_rstn;

	input_clock clk_i_clk (i_clk)  <- exposeCurrentClock;
	input_reset rst_i_rstn (i_rstn) clocked_by(clk_i_clk)  <- exposeCurrentReset;


	method mem_addr_write (i_mem_addr /*31:0*/, i_mem_wstrb /*7:0*/, i_mem_wdata /*63:0*/)
		 enable(i_mem_valid) clocked_by(clk_i_clk) reset_by(rst_i_rstn);
	method o_mem_rdata /* 63:0 */ mem_read_data ()
		 ready(o_mem_ready) clocked_by(clk_i_clk) reset_by(rst_i_rstn);
	method cfg (i_txn_32_64 /*0:0*/, i_cfg_access /*0:0*/, i_burst_length /*5:0*/, i_burst_type /*0:0*/, i_initial_latency /*3:0*/)
		 enable((*inhigh*)cfg_enable) clocked_by(clk_i_clk) reset_by(rst_i_rstn);

	interface HB hb;
		method o_csn0 csn ()
		 clocked_by(clk_i_clk) reset_by(rst_i_rstn);
		method o_clk clk ()
		 clocked_by(clk_i_clk) reset_by(rst_i_rstn);
		method o_dq /* 7:0 */ dq_o ()
		 ready(o_dq_de) clocked_by(clk_i_clk) reset_by(rst_i_rstn);
		method o_resetn resetn ()
		 clocked_by(clk_i_clk) reset_by(rst_i_rstn);
		method o_rwds rwds_o ()
		 ready(o_rwds_de) clocked_by(clk_i_clk) reset_by(rst_i_rstn);
		method in (i_dq /*7:0*/, i_rwds /*0:0*/)
		 enable((*inhigh*)in_enable) clocked_by(clk_i_clk) reset_by(rst_i_rstn);
	endinterface

	schedule mem_addr_write C mem_addr_write;
	schedule hb_csn SB mem_addr_write;
	schedule hb_clk SB mem_addr_write;
	schedule hb_dq_o SB mem_addr_write;
	schedule hb_resetn SB mem_addr_write;
	schedule hb_rwds_o SB mem_addr_write;
	schedule mem_addr_write CF hb_in;
	schedule mem_read_data SB mem_addr_write;
	schedule mem_addr_write CF cfg;
	schedule hb_csn CF hb_csn;
	schedule hb_csn CF hb_clk;
	schedule hb_csn CF hb_dq_o;
	schedule hb_csn CF hb_resetn;
	schedule hb_csn CF hb_rwds_o;
	schedule hb_csn SB hb_in;
	schedule hb_csn CF mem_read_data;
	schedule hb_csn SB cfg;
	schedule hb_clk CF hb_clk;
	schedule hb_clk CF hb_dq_o;
	schedule hb_clk CF hb_resetn;
	schedule hb_clk CF hb_rwds_o;
	schedule hb_clk SB hb_in;
	schedule hb_clk CF mem_read_data;
	schedule hb_clk SB cfg;
	schedule hb_dq_o CF hb_dq_o;
	schedule hb_dq_o CF hb_resetn;
	schedule hb_dq_o CF hb_rwds_o;
	schedule hb_dq_o SB hb_in;
	schedule hb_dq_o CF mem_read_data;
	schedule hb_dq_o SB cfg;
	schedule hb_resetn CF hb_resetn;
	schedule hb_resetn CF hb_rwds_o;
	schedule hb_resetn SB hb_in;
	schedule hb_resetn CF mem_read_data;
	schedule hb_resetn SB cfg;
	schedule hb_rwds_o CF hb_rwds_o;
	schedule hb_rwds_o SB hb_in;
	schedule hb_rwds_o CF mem_read_data;
	schedule hb_rwds_o SB cfg;
	schedule hb_in C hb_in;
	schedule mem_read_data SB hb_in;
	schedule hb_in CF cfg;
	schedule mem_read_data CF mem_read_data;
	schedule mem_read_data SB cfg;
	schedule cfg C cfg;
endmodule


