/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-09
 Description: A brief description of the file's purpose.
*/
`include "qspi.defines"
`include "Logger.bsv"       // for logging display statements.
import AXI4_Lite_Types   :: *;
import AXI4_Lite_Fabric  :: *;
import Clocks::*;
import qspi::*;
import qspi_controller::*;
// ==================================================
 import AXI4_Lite_Types   :: *;
 import AXI4_Lite_Fabric  :: *;
 import BUtils::*;

 import Semi_FIFOF        :: *;
// ==================================================


interface Ifc_qspi_axi4lite#(numeric type addr_width,
	numeric type data_width,
numeric type user_width); 
interface QSPI_out io;
interface AXI4_Lite_Slave_IFC#(addr_width, data_width, user_width) slave;
method Bit#(1) interrupts; // 0=TOF, 1=SMF, 2=Threshold, 3=TCF, 4=TEF 5 = request_ready
endinterface

module mkqspi_axi4lite#(Clock slow_clk, Reset slow_rst, Bit#(32) start_mm_addr, Bit#(32) end_mm_addr `ifdef testmode ,Bool test_mode `endif )(Ifc_qspi_axi4lite#(addr_width,
		data_width,
user_width))
provisos(Add#(a__, 28, addr_width),Mul#(32, b__, data_width),Add#(c__,addr_width,32));

Reg#(bit) rg_req_en <- mkRegA(0);
AXI4_Lite_Slave_Xactor_IFC #(addr_width, data_width, user_width)  s_xactor <- mkAXI4_Lite_Slave_Xactor;

SyncFIFOIfc#(Maybe#(Write_req#(addr_width,data_width))) ff_wr_req <- mkSyncFIFOFromCC(1, slow_clk);
SyncFIFOIfc#(AXI4_Lite_Resp) 	ff_sync_wr_resp <- mkSyncFIFOToCC(1, slow_clk, slow_rst);
SyncFIFOIfc#(Maybe#(Read_req#(addr_width)))	ff_rd_req <- mkSyncFIFOFromCC(1, slow_clk);
SyncFIFOIfc#(Rd_resp#(data_width))			ff_sync_rd_resp <- mkSyncFIFOToCC(1, slow_clk, slow_rst);

Ifc_qspi_controller#(addr_width, data_width, user_width)	qspi <- mkqspi_controller(start_mm_addr,end_mm_addr,clocked_by slow_clk, reset_by slow_rst);
(*preempts="rl_write_request, rl_read_request"*)	
rule rl_write_request(rg_req_en == 0); // this Rule is running at fast_clk (i.e 166MHz)
	let aw <- pop_o (s_xactor.o_wr_addr);
   	let w <- pop_o (s_xactor.o_wr_data);
	ff_wr_req.enq(tagged Valid (Write_req {
				addr : truncate(aw.awaddr),
				burst_size : extend(aw.awsize),
	wdata : truncate(w.wdata) }));
	rg_req_en <= 1;
	`logLevel(qspicontrol, 0, $format(" QSPI: Received  Write request addr %x data %x ", aw.awaddr, w.wdata))
endrule

rule rl_write_req_send_to_controller; // this Rule is running at slow_clk (i.e less than or equal to 166MHz)
	let w = ff_wr_req.first;
	ff_wr_req.deq;
	qspi.write_req(w);
endrule

rule rl_write_response(isValid(qspi.write_resp)); // this Rule is running at slow_clk (i.e less than or equal to 166MHz)
	ff_sync_wr_resp.enq(fromMaybe(?, qspi.write_resp));
	`logLevel(qspicontrol, 0, $format(" QSPI: Sending Write response"))
endrule

rule rl_write_response_sent_to_host; // this Rule is running at fast_clk (i.e 166MHz)
	let w = ff_sync_wr_resp.first;
	ff_sync_wr_resp.deq;
	rg_req_en <= 0;
	let b = AXI4_Lite_Wr_Resp {bresp : w, buser : 0};
	s_xactor.i_wr_resp.enq (b);
endrule

rule rl_read_request(rg_req_en == 0); // this Rule is running at fast_clk (i.e 166MHz)
	let ar <- pop_o(s_xactor.o_rd_addr);
	ff_rd_req.enq(tagged Valid (Read_req{
				addr : truncate(ar.araddr),
	burst_size : extend(ar.arsize)}));
	rg_req_en <= 1;
	`logLevel(qspicontrol, 0, $format("QSPI: qspi received read request"))
endrule

rule rl_read_request_send_to_controller;// this Rule is running at slow_clk (i.e less than or equal to 166MHz)
	let r = ff_rd_req.first;
	ff_rd_req.deq;
	`logLevel(qspicontrol, 0, $format("QSPI: qspi sent read request"))
	qspi.rd_req(r);
endrule

rule rl_read_response(isValid(qspi.rd_resp));// this Rule is running at slow_clk (i.e less than or equal to 166MHz)
	ff_sync_rd_resp.enq(fromMaybe(?, qspi.rd_resp));
endrule

rule rl_read_response_send_to_host;// this Rule is running at fast_clk (i.e 166MHz)
	let r = ff_sync_rd_resp.first;
	ff_sync_rd_resp.deq;
	rg_req_en <= 0;
	let rsp = AXI4_Lite_Rd_Data {rresp: r.rsp, rdata: duplicate(r.rdata) , ruser: 0};
	s_xactor.i_rd_data.enq(rsp);
	`logLevel(qspicontrol, 0, $format("QSPI: Sending Read Response"))
endrule


interface io = qspi.io;

interface slave = s_xactor.axi_side;

method Bit#(1) interrupts;
	return qspi.interrupts;
endmethod

endmodule
