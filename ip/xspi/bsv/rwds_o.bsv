/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-09
 Description: A brief description of the file's purpose.
*/
interface RWDS_OIfc;
	method Action ena() ;
	method Action ddr_mode() ;
	method Action csn() ;	
	method Bit#(1) rwds_o();
endinterface
import "BVI" rwds_o = module mkrwds_o(RWDS_OIfc);
	method ena() enable(enable);
	method ddr_mode() enable (ddr_mode);
	method csn() enable (csn);	
	method rwds_o rwds_o();
	schedule ena CF ddr_mode;
	schedule ena CF csn;
	schedule ddr_mode CF ena;
	schedule ddr_mode CF csn;
	schedule csn CF ena;
	schedule csn CF ddr_mode;
	schedule csn C csn;
	schedule ddr_mode C ddr_mode;
	schedule ena C ena;
	schedule rwds_o CF rwds_o;

	schedule (ena,ddr_mode,csn) SB rwds_o;
	default_clock clk(clk, (*unused*) clk_gate);
	default_reset no_reset;
endmodule
