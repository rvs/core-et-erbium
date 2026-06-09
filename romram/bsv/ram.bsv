/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-06
 Description: A brief description of the file's purpose.
*/
interface RAM#(numeric type a,numeric type d);
	method Action request(Bit#(a) addr,Bit#(d) din,Bit#(d) ena_n,Bool isRead);
	method Bit#(d) read_response();
	method Action dsleep();
endinterface
import "BVI" ram=
module mkRam (RAM#(a,d));
	parameter ADDRESS_WIDTH=valueOf(a);
	parameter DATA_WIDTH=valueOf(d);
	method request(address,din,bit_enable,isRead) enable(enable);
	method dout read_response;
  	method dsleep() enable(deep_sleep);
	default_clock clk(clk, (*unused*) clk_gate);
	default_reset no_reset;
	schedule (read_response) SB (request);
	schedule request C request;
	schedule read_response CF read_response;
	schedule dsleep CF request;
	schedule dsleep CF read_response;
	schedule dsleep CF dsleep;

endmodule

interface ROM#(numeric type a,numeric type d);
	method Action request(Bit#(a) addr);
	method Bit#(d) read_response();
	method Action dsleep();
endinterface
import "BVI" rom=
module mkRom (ROM#(a,d));
	parameter ADDRESS_WIDTH=valueOf(a);
	parameter DATA_WIDTH=valueOf(d);
	method request(address) enable(enable);
	method dout read_response;
 	method dsleep() enable(deep_sleep);
	default_clock clk(clk, (*unused*) clk_gate);
	default_reset rst_n(rst_n) clocked_by (clk);
	schedule (read_response) SB (request);
	schedule request C request;
	schedule read_response CF read_response;
	schedule dsleep CF request;
	schedule dsleep CF read_response;
	schedule dsleep CF dsleep;


endmodule
