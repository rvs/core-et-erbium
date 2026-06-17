// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AXI4_Types::*;
import Semi_FIFOF::*;
import bsvmkhbc::*;
import Cntrs::*;
import Clocks::*;

interface HBIFC;
	interface AXI4_Slave_IFC#(2,32,64,0) axi;
	interface HB hb_out;
	(*always_enabled, always_ready*)
	method Action cfg(Bit#(4) i_initial_latency, Bit#(6) i_burst_length, Bool i_burst_type,Bool i_txn_32_64, Bool i_cfg_access);
	(*always_enabled, always_ready*)
	method Bool reset_req();
endinterface

(*synthesize*)
module mkHB_Wrapper#(Clock hb_clk, Reset hb_rstn)(HBIFC);
	HBC hbc <- mkhbc( clocked_by hb_clk, reset_by hb_rstn);
	Reg#(Bool) reading <- mkRegA(False, clocked_by hb_clk, reset_by hb_rstn);
	Reg#(Bool) busy <- mkRegA(False, clocked_by hb_clk, reset_by hb_rstn);
	Count#(Bit#(10)) timeout_counter <- mkCount(1023, clocked_by hb_clk, reset_by hb_rstn);
	PulseWire pwTimeout <- mkPulseWire(clocked_by hb_clk, reset_by hb_rstn);
	PulseWire pwResetReq <- mkPulseWire(clocked_by hb_clk, reset_by hb_rstn);

	AXI4_Slave_Xactor_IFC#(2,32,64,0) axi_data <- mkAXI4_Slave_Xactor();
   	SyncFIFOIfc#(AXI4_Wr_Addr #(2, 32, 0))  o_wr_addr_cdc <- mkSyncFIFOFromCC(1,hb_clk);
   	SyncFIFOIfc#(AXI4_Wr_Data #(64, 0))     o_wr_data_cdc <- mkSyncFIFOFromCC(1,hb_clk);
   	SyncFIFOIfc#(AXI4_Wr_Resp #(2, 0))      i_wr_resp_cdc <- mkSyncFIFOToCC(1,hb_clk,hb_rstn);

   	SyncFIFOIfc#(AXI4_Rd_Addr #(2, 32, 0))  o_rd_addr_cdc <- mkSyncFIFOFromCC(1,hb_clk);
   	SyncFIFOIfc#(AXI4_Rd_Data #(2, 64, 0))  i_rd_data_cdc <- mkSyncFIFOToCC(1,hb_clk,hb_rstn);


	rule cdc1;
		let x = axi_data.o_wr_addr.first();
		o_wr_addr_cdc.enq(x);
		axi_data.o_wr_addr.deq();
	endrule
	rule cdc2;
		let x = axi_data.o_wr_data.first();
		o_wr_data_cdc.enq(x);
		axi_data.o_wr_data.deq();
	endrule
	rule cdc3;
		let x = axi_data.o_rd_addr.first();
		o_rd_addr_cdc.enq(x);
		axi_data.o_rd_addr.deq();
	endrule
	rule cdc4;
		let x = i_wr_resp_cdc.first();
		axi_data.i_wr_resp.enq(x);
		i_wr_resp_cdc.deq();
	endrule
	rule cdc5;
		let x = i_rd_data_cdc.first();
		axi_data.i_rd_data.enq(x);
		i_rd_data_cdc.deq();
	endrule
	(*descending_urgency="wr,rd_addr"*)
	rule wr(!reading);
		let addr=o_wr_addr_cdc.first();
		let data=o_wr_data_cdc.first();
		hbc.mem_addr_write({8'b0,addr.awaddr[23:0]},data.wstrb,data.wdata);
		//busy <= True;
		// timeout_counter.update(1023);
		if(data.wlast)begin
			o_wr_addr_cdc.deq();
			i_wr_resp_cdc.enq(AXI4_Wr_Resp{bid:addr.awid,bresp:0,buser:addr.awuser});
		end
		o_wr_data_cdc.deq();
	endrule
	rule timeout(busy);
		timeout_counter.decr(1);
		if(timeout_counter == 0)
			pwTimeout.send();
	endrule

	// rule wr_done(busy && !reading);
	// 	let addr=o_wr_addr_cdc.first();
	// 	let data=o_wr_data_cdc.first();
	// 	busy<= False;

	// endrule

	rule rd_addr(!reading && !busy);
		let addr=o_rd_addr_cdc.first();
		hbc.mem_addr_write({8'b0,addr.araddr[23:0]},0,0);
		reading <= True;
		busy <= True;
		timeout_counter.update(1023);
	endrule

	(*descending_urgency = "errorTxn,rd_data"*)
	rule errorTxn(pwTimeout);
		let addr=o_rd_addr_cdc.first();
		i_rd_data_cdc.enq(AXI4_Rd_Data{rid:addr.arid,rdata:64'hdeadc0de,rresp:0,rlast:True,ruser:0});
		o_rd_addr_cdc.deq();
		reading <= False;
		busy <= False;
		pwResetReq.send();
	endrule

	rule rd_data(reading);
		let data=hbc.mem_read_data();
		let addr=o_rd_addr_cdc.first();
		i_rd_data_cdc.enq(AXI4_Rd_Data{rid:addr.arid,rdata:data,rresp:0,rlast:True,ruser:0});
		o_rd_addr_cdc.deq();
		reading <= False;
		busy <= False;
	endrule

	interface axi=axi_data.axi_side;
	interface hb_out=hbc.hb;
	method Action cfg(Bit#(4) i_initial_latency, Bit#(6) i_burst_length, Bool i_burst_type,Bool i_txn_32_64, Bool i_cfg_access);
		hbc.cfg(i_txn_32_64,i_cfg_access,i_burst_length,i_burst_type, i_initial_latency);
	endmethod
	method Bool reset_req();
		return pwResetReq;
	endmethod
endmodule
