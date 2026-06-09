/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-06
 Description: Bluespec wrapper over RAM/ROM
 RAM is 9bits i.e. 8:0
 ROM is 10 bits i.e. 9:0
New Base 0x8000 
Fixing address
0x1000 Bootrom 0x13FF
0x1800 RAM     0x19ff

ROM 'b 0001_00xx_xxxx_xxxx
RAM 'b 0001_100x_xxxx_xxxx
if address[12:10]='b100 ROM slverr on write
elif address[12:9]='b1100 RAM
	else: decode err
 

*/
import Vector::*;
import axi4_types::*;
import ram::*;
import Semi_FIFOF::*;
import FIFO::*;
import DReg::*;
typedef enum {
	ROM,
	RAM,
	None
} MemType deriving(Bits, Eq, FShow);

function MemType fnDecodeAddress(Bit#(32) address);
	let rv=None;
	if (address[12:10] == 3'b100) rv= ROM;
	else if (address[12:9] == 4'b1100) rv= RAM;
	return rv;
endfunction

interface RomRam;
	(*always_ready, enable="rom_dsleep" *)
method Action rom_sleep;
	(*always_ready, enable="ram_dsleep" *)
method Action ram_sleep;
interface Ifc_axi4_slave#(9,32,64,0) axis;
endinterface

(*synthesize*)
module mkRomRam(RomRam);
	QueueSize q_size=QueueSize{wr_req_depth:2,wr_resp_depth:2,rd_req_depth:2,rd_resp_depth:3};
	ROM#(10,64) rom<-mkRom();
	RAM#(9,64) ram<-mkRam();
	Reg#(Bit#(12)) wroffset <-mkRegA(0);
	Reg#(Bit#(8)) rdoffset <-mkRegA(0);
	Reg#(Bool) delayedRespEmpty <-mkRegA(False);
	FIFO#(Tuple3#(MemType,Bit#(9),Bool)) rd_inProgress <- mkFIFO();
	Ifc_axi4_slave_xactor_thresh#(9,32,64,0,3) axi <-mkaxi4_slave_xactor_thresh(q_size);

	rule write;
		let resp=axi4_resp_okay;
		let aw=axi.fifo_side.o_wr_addr.first();
		let wd=axi.fifo_side.o_wr_data.first();
		let wro = wroffset;
		axi.fifo_side.o_wr_data.deq();
		let addr =(aw.awaddr>>3)+zeroExtend(wroffset);
		let region=fnDecodeAddress(addr);
		if(region == RAM)begin
     			Vector#(8,Bit#(1)) wstrb_bin= unpack(wd.wstrb);
     			Vector#(64,Bit#(1)) wstrb_bin_64= concat(map(replicate,wstrb_bin));
			ram.request(addr[8:0],wd.wdata,pack(wstrb_bin_64),False);
		end else if (region == ROM) resp=axi4_resp_slverr;
		else resp=axi4_resp_decerr;
		if(wd.wlast) begin 
			axi.fifo_side.o_wr_addr.deq();
			wro=0;
		end else wro = wro +1;
		wroffset<=wro;
		axi.fifo_side.i_wr_resp.enq(Axi4_wr_resp{bid:aw.awid,bresp:resp,buser:0});
	endrule

	rule read(axi.rd_data_isLessThan(2));
		let ar=axi.fifo_side.o_rd_addr.first();
		let rro = rdoffset;
		let last =False;
		let addr=(ar.araddr>>3)+zeroExtend(rro);
		let region=fnDecodeAddress(addr) ;
		if (region == RAM)begin
			ram.request(addr[8:0],0,0,True);
		end
		else if(region == ROM) begin 
			rom.request(addr[9:0]);
		end
			if(rdoffset == ar.arlen) begin 
				last = True;
				axi.fifo_side.o_rd_addr.deq();
				rro=0;
			end else rro = rro +1;
			rdoffset<=rro;
			rd_inProgress.enq(tuple3(region,ar.arid,last));
	endrule


	rule read_response;
		let ar = rd_inProgress.first();
		rd_inProgress.deq();
		let resp = axi4_resp_okay;
		Bit#(64) rdata = 0;
		let addr_highbit = tpl_1(ar);
		let rid=tpl_2(ar);
		let last=tpl_3(ar);
		if(addr_highbit == RAM) rdata = ram.read_response();
		else if(addr_highbit == ROM) rdata = rom.read_response();
		else resp = axi4_resp_decerr;
		axi.fifo_side.i_rd_data.enq(Axi4_rd_data{ rid:rid, rdata:rdata, rresp:resp, rlast:last, ruser:0 });
	endrule

	interface Ifc_axi4_slave axis = axi.axi4_side;
        method Action ram_sleep= ram.dsleep;
        method Action rom_sleep= rom.dsleep;
endmodule
