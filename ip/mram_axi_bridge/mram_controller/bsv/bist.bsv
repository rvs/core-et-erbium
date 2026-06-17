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

import Vector :: *;
import Semi_FIFOF :: *;
import StmtFSM::*;
import Cntrs::*;
import FIFO::*;
import FIFOF::*;

interface Rom_Ifc;
endinterface
// input [7:0]  addr;
// input ce;
// output [63:0]  rd_out;

interface Bist_Ifc;
	method Action cfg(Bist_Cfg_Regs regs);
	method Bist_Status_Regs status();

	method Bit#(18) address;
	method Bit#(4) stripe_sel;
	method Bool clk_en;
	method Bit#(79) wdata;
	method Bool wen;
	method Bool ref_prg_en;
	method Bit#(8) rom_addr;
	method Bool rom_ce;

	(* always_ready, always_enabled, prefix="" *)
	method Action mram_dout(Bit#(79) rdata_i);
	(* always_ready, always_enabled, prefix="" *)
	method Action mbusy(Bit#(1) busy_i);
	(* always_ready, always_enabled, prefix="" *)
	method Action rom_dout (Bit#(79) rom_dout_i);
	//interface Rom_Ifc rom;
endinterface

typedef struct{
	Bool start;
	Bool bist_wr_en;
	Bool bist_rd_en;
	Bool bist_rte_en;
	Bool bist_reset;
	Bit#(20) start_addr;
	Bit#(20) stop_addr;
	Bit#(3)  addr_inc;
	Bit#(16) loop_cnt; // TODO Max loop value

	Bool stop_on_error;
	Bool data_inv;
	Bool trim_mode;
	Bit#(5) rh4_margin;
	Bool stop_on_repl_of;
	///
	Bit#(79) din;
	Bit#(79) bwe;
}Bist_Cfg_Regs deriving(Bits, Eq, FShow);

typedef struct {
	Bool busy;
	Bool bist_error;
	Bit#(20) error_address;
	Bit#(16) error_loop;
	Bit#(7) rh0;
	Bit#(7) rh1;
	Bit#(7) rh2;
	Bit#(16) error_count;
	Bit#(79) error_value;
} Bist_Status_Regs deriving(Bits, Eq, FShow);

(*synthesize,
always_ready,
always_enabled,
default_clock_osc="CLK",
default_reset="RST_B"
*)
module mkBist(Bist_Ifc);
	Wire#(Bist_Cfg_Regs) csr <- mkWire();
	Wire#(Bist_Status_Regs) wr_csr_status <- mkDWire(unpack(0));
	Wire#(Bit#(18)) mram_address <- mkDWire(0);
	Wire#(Bit#(8)) rom_addr_o <- mkDWire(0);
	Wire#(Bool) mram_we <- mkDWire(False);
	Wire#(Bool) mram_ref_prg_en <- mkDWire(False);
	Wire#(Bool) rom_ce_o <- mkDWire(False);
	Wire#(Bit#(79)) mram_wdata <- mkDWire(0);
	Wire#(Bit#(79)) mram_rdata <- mkDWire(0);
	Wire#(Bit#(79)) rom_rdata <- mkDWire(0);
	Wire#(Bit#(1)) mram_busy <- mkDWire(0);
	Wire#(Bit#(4)) mram_stripe_sel <- mkDWire(0);
	Wire#(Bool) mram_clk_en <- mkDWire(False);
	Wire#(Bool) rte_read_error <- mkDWire(False);
	Reg#(Bool) rte_read_error_result <- mkRegA(False);
	Count#(Bit#(32)) timeout_ctr <- mkCount(0);
	// Bist_Status_Regs csr_status=unpack(0);
	// Define a default value for csr_status
	Bist_Status_Regs default_status = unpack(0); // Initialize with default values

	// Declare csr_status as a register
	Reg#(Bist_Status_Regs) csr_status <- mkRegA(default_status);
	Reg#(Bit#(21)) current_address <- mkRegA(0);
	Reg#(Bit#(17)) loop_count <- mkRegA(0);
	Reg#(Bit#(5)) read_cnt <- mkRegA(0);
	// Wire#(Bit#(5)) read_cnt <- mkDWire(0);
	Reg#(Bool) bist_started <- mkRegA(False);
	Reg#(Bit#(79)) reg_rom_rdata <- mkRegA(0);

	// Reference trim registers used in find_rh algorithm.
	Reg#(Bit#(7)) rh_upper <- mkRegA(79);
	Reg#(Bit#(7)) rh_lower <- mkRegA(0);
	Reg#(Bit#(7)) rh_set <- mkRegA(39);
	Reg#(Bit#(8)) rh_set_ovrflow <- mkRegA(39);
	 // Register to hold the value for the sibling rh value
	Reg#(Bit#(7)) rh2_sibling <- mkRegA(39);
	Reg#(Bit#(7)) rh3<- mkRegA(39);
	Reg#(Bit#(7)) rh4<- mkRegA(39);
	Reg#(Bit#(2)) sibling_loop <- mkRegA(0);
	PulseWire pwError <- mkPulseWire();
	// Reg#(Bool) busy <- mkRegA(False);
	// ConCreditCounter_IFC#(2) outgoing_reads <- mkConCreditCounter();
	FIFOF#(Bit#(1)) outgoing_reads 	<- mkUGSizedFIFOF(2);
	FIFOF#(Bit#(20)) fifo_addr 		<- mkUGSizedFIFOF(2);
	FIFOF#(Bit#(17)) fifo_loop_cnt 	<- mkUGSizedFIFOF(2);
	// address is 21:0
	// 17 is otp/redundancy. so set it to 0
	// let address={csr.addr_in
	function Action read_word(Bit#(20) target_addr);
		return action
			Bit#(18) addr=0;
			addr[16:0] =target_addr[16:0];
			addr[17] =target_addr[19];
			mram_stripe_sel <= 1<<target_addr[18:17];
			mram_address <=addr;
			mram_clk_en <= True;
			// if (outgoing_reads.value < 2)
			// 	outgoing_reads.incr();
			outgoing_reads.deq();
			outgoing_reads.enq(1);
			fifo_loop_cnt.enq(loop_count);
			fifo_addr.enq(target_addr);
		endaction;
	endfunction
	function Action write_word(Bit#(20) target_addr, Bit#(79) din);
		return action
			Bit#(18) addr=0;
			addr[16:0] =target_addr[16:0];
			addr[17] =target_addr[19];
			mram_stripe_sel <= 1<<target_addr[18:17];
			mram_address <=addr;
			mram_we <= True;
			mram_clk_en <= True;
			mram_wdata <= din;
			// if (outgoing_reads.value < 2)
			// 	outgoing_reads.incr();
			outgoing_reads.deq();
			outgoing_reads.enq(1);
			fifo_loop_cnt.enq(loop_count);
			fifo_addr.enq(target_addr);
		endaction;
	endfunction
	function Bit#(n) vectorToBits(Vector#(n, Bit#(1)) v);
		Bit#(n) result = 0;
		for (Integer i = 0; i < valueOf(n); i = i + 1) begin
			Bit#(1) tbit = v[valueOf(n) - i - 1];
			result = (result << 1) | (tbit == 1'b1 ? fromInteger(1) : fromInteger(0));
		end
		return result;
	endfunction

	let check_error=action
		//csr_status.dout = mram_dout;
		Vector#(79, Bit#(1)) m = replicate((csr.data_inv? 1 : 0) & fifo_addr.first[0]);
		Bit#(79) data_inv = vectorToBits(m);
		let comparison_data = mram_rdata ^ data_inv;
		let ok = (csr.din & csr.bwe) == (comparison_data & csr.bwe);
		if (!ok) begin
			let update_status = csr_status;
			update_status.error_loop = fifo_loop_cnt.first[15:0];
			update_status.error_address = fifo_addr.first;
			update_status.bist_error = True;
			update_status.error_value = mram_rdata;
			csr_status <= update_status;
		end
	endaction;
	let count_bit_errors=action
		//csr_status.dout = mram_dout;
		Vector#(79, Bit#(1)) m = replicate((csr.data_inv? 1 : 0) & fifo_addr.first[0]);
		Bit#(79) data_inv = vectorToBits(m);
		let comparison_data = mram_rdata ^ data_inv;
		let errors_in_word = countOnes(((comparison_data ^ csr.din) & csr.bwe));
		let update_status = csr_status;
		update_status.error_count = update_status.error_count + zeroExtend(pack(errors_in_word));
		if (update_status.error_count[15:7] == 9'h1ff) begin
			update_status.error_loop = fifo_loop_cnt.first[15:0];
			update_status.error_address = fifo_addr.first;
			update_status.bist_error = True;
		end
		csr_status <= update_status;
	endaction;
	let mram_nop = action
		mram_clk_en <= True;
		if (outgoing_reads.first == 1) begin
			if (csr.stop_on_error)
				check_error;
			else if (csr.stop_on_repl_of)
				count_bit_errors;
			outgoing_reads.deq();
			outgoing_reads.enq(0);
			fifo_loop_cnt.deq();
			fifo_addr.deq();
			end else begin
				outgoing_reads.enq(0);
				outgoing_reads.deq();
			end
	endaction;

	let set_address =action
		Bit#(18) addr=0;
		addr[16:0] =current_address[16:0];
		addr[17] =current_address[19];
		mram_stripe_sel <= 1<<current_address[18:17];
		mram_address <=addr;
		mram_clk_en <= True;
		current_address <= current_address + 1;
	endaction;

	let initialize_read_bist=action
		current_address[19:0] <= csr.start_addr;
		loop_count <= 0;
		csr_status.error_count <= 0;
	endaction;
	Stmt read_bist=seq
		// If we had a bist error coming into the state machine, reset it. otherwise, initalize the bist.
		if (csr_status.bist_error) seq
			csr_status.bist_error <= False;
		endseq else seq
			initialize_read_bist;
			// Fill the outgoing reads with 0.
			action
				fifo_loop_cnt.clear();
				fifo_addr.clear();
				outgoing_reads.clear();
			endaction
			outgoing_reads.enq(0);
			outgoing_reads.enq(0);
		endseq
		while(True) seq
			if (csr_status.bist_error && csr.stop_on_error)
				break;
			if (((current_address <= {0, csr.stop_addr}) && (loop_count <= {0, csr.loop_cnt}))) seq
				action
					read_word(current_address[19:0]);
					let next_address = current_address + (1 << csr.addr_inc);
					if (next_address <=  {0, csr.stop_addr}) begin
						current_address <= next_address;
					end else begin
						current_address[19:0] <= csr.start_addr;
						loop_count <= loop_count + 1;
					end
					// If there have been 2 outgoing reads, then we can check for errors.
					if (outgoing_reads.first == 1) begin
						if (csr.stop_on_error)
							check_error;
						else if (csr.stop_on_repl_of)
							count_bit_errors;
						fifo_loop_cnt.deq();
						fifo_addr.deq();
					end
				endaction
				continue;
			// endseq else if (outgoing_reads.value != 0) seq
			endseq else if (fifo_addr.notEmpty) seq
				// Final clocks for the pipeline.
				mram_nop;
				continue;
			endseq
			break;
		endseq
	endseq;
	function Action read_word_nop();
		return action
			mram_clk_en <= True;
			outgoing_reads.enq(0);
			outgoing_reads.deq();
			if (outgoing_reads.first == 1) begin
				fifo_loop_cnt.deq();
				fifo_addr.deq();
			end
		endaction;
	endfunction

	let initialize_write_bist=action
		current_address[19:0] <= csr.start_addr;
		loop_count <= 0;
		csr_status.error_count <= 0;
	endaction;

	Stmt write_bist=seq
		// If we had a bist error coming into the state machine, reset it. otherwise, initalize the bist.
		if (csr_status.bist_error) seq
			csr_status.bist_error <= False;
		endseq else seq
			initialize_write_bist;
			// Fill the outgoing reads with 0.
			action
				fifo_loop_cnt.clear();
				fifo_addr.clear();
				outgoing_reads.clear();
			endaction
			outgoing_reads.enq(0);
			outgoing_reads.enq(0);
		endseq
		while(True) seq
			if (csr_status.bist_error && csr.stop_on_error)
				break;
			if (((current_address <= {0, csr.stop_addr}) && (loop_count <= {0, csr.loop_cnt}))) seq
				action
					Vector#(79, Bit#(1)) m = replicate((csr.data_inv? 1 : 0) & loop_count[0]);
					Bit#(79) data_inv = vectorToBits(m) ^ csr.din;

					write_word(current_address[19:0], data_inv);
					let next_address = current_address + (1 << csr.addr_inc);
					if (next_address <=  {0, csr.stop_addr}) begin
						current_address <= next_address;
					end else begin
						current_address[19:0] <= csr.start_addr;
						loop_count <= loop_count + 1;
					end
					// If there have been 2 outgoing reads, then we can check for errors.
					// if (outgoing_reads.value == 2) begin
					if (outgoing_reads.first == 1) begin
						if (csr.stop_on_error)
							check_error;
						fifo_loop_cnt.deq();
						fifo_addr.deq();
					end
				endaction
				mram_nop; // Additional clock
				while (mram_busy == 1) mram_clk_en <= True;
				mram_nop;
				//mram_nop; // Additional clock
				continue;
			// endseq else if (outgoing_reads.value != 0) seq
			endseq else if (fifo_addr.notEmpty) seq
				// Final clocks for the pipeline.
				mram_nop;
				continue;
			endseq
			break;
		endseq
	endseq;
	function Stmt get_rh_din(Bit#(8) rh);
		let rs = seq
			action
				rom_ce_o <= True;
				rom_addr_o <= rh;
			endaction
			action
			reg_rom_rdata <= rom_rdata;
			endaction
		endseq;
		return rs;
	endfunction
	function Stmt write_ref_pattern(Bit#(79) ref_data, Bit#(20) ref_addr);
		let rs = seq
			action
				Bit#(18) addr=0;
				addr[16:0] = ref_addr[16:0];
				addr[17] = ref_addr[19];
				mram_stripe_sel <= 1 << ref_addr[18:17];
				mram_wdata <= ref_data;
				mram_address <= addr;
				mram_clk_en <= True;
				mram_we <= True;
				mram_ref_prg_en <= True;
			endaction
			while (mram_busy == 1) action
				mram_clk_en <= True;
				mram_ref_prg_en <= True;
			endaction
			noAction; // Additional clock
		endseq;
		return rs;
	endfunction
	function Stmt initialize_wordline(Bit#(79) init_din, Reg#(Bit#(21)) init_addr);
		let rs =  seq
			for (init_addr[3:0] <= 0; init_addr[3:0] < 15; init_addr[3:0] <= init_addr[3:0] + 1) seq
				action
					Bit#(18) addr=0;
					addr[16:0] = init_addr[16:0];
					addr[17] = init_addr[19];
					mram_stripe_sel <= 1 << init_addr[18:17];
					mram_wdata <= init_din;
					mram_address <= addr;
					mram_clk_en <= True;
					mram_we <= True;
					mram_ref_prg_en <= False;
				endaction
				while (mram_busy == 1) action
					mram_clk_en <= True;
					mram_ref_prg_en <= False;
				endaction
				noAction; // Additional clock
			endseq
			// For init_addr = 15
			action
				Bit#(18) addr=0;
				addr[16:0] = init_addr[16:0];
				addr[17] = init_addr[19];
				mram_stripe_sel <= 1 << init_addr[18:17];
				mram_wdata <= init_din;
				mram_address <= addr;
				mram_clk_en <= True;
				mram_we <= True;
				mram_ref_prg_en <= False;
			endaction
			while (mram_busy == 1) action
				mram_clk_en <= True;
				mram_ref_prg_en <= False;
			endaction
			noAction; // Additional clock
			// Program ref on sibling plane.
			if (csr.trim_mode) action
				Bit#(18) addr=0;
				addr[16:0] = init_addr[16:0] ^ (1 << 13);
				addr[17] = init_addr[19];
				mram_stripe_sel <= 1 << init_addr[18:17];
				mram_wdata <= init_din;
				mram_address <= addr;
				mram_clk_en <= True;
				mram_we <= True;
				mram_ref_prg_en <= True;
			endaction
			while (mram_busy == 1) action
				mram_clk_en <= True;
				mram_ref_prg_en <= True;
			endaction
			noAction; // Additional clock
		endseq;
		return rs;
	endfunction

	function Action check_rte_error(Bit#(1) xor_factor);
		return action
			//csr_status.dout = mram_dout;
			Vector#(79, Bit#(1)) m = replicate(xor_factor);
			Bit#(79) data_inv = vectorToBits(m);
			let comparison_data = mram_rdata ^ data_inv;
			if (comparison_data == 79'h0)
				rte_read_error_result <= False;
			else
				rte_read_error_result <= True;
		endaction;
	endfunction

	function Stmt check_wordline_for_error(Bit#(1) xor_factor, Reg#(Bit#(21)) init_addr);
		let rs =  seq
			action
				rte_read_error_result <= False;
				read_cnt <= 0;
			endaction
			while (True) seq
				action
					if (read_cnt < 16) begin
						read_cnt <= read_cnt + 1;
						read_word({init_addr[19:4], read_cnt[3:0]});
						if (outgoing_reads.first == 1) begin
							check_rte_error(xor_factor);
							fifo_loop_cnt.deq();
							fifo_addr.deq();
						end
					end else if (csr.trim_mode && read_cnt == 16) begin
						read_cnt <= read_cnt + 1;
						action
							mram_ref_prg_en <= True;
							read_word({init_addr[19:4], read_cnt[3:0]});
						endaction
						if (outgoing_reads.first == 1) begin
							check_rte_error(xor_factor);
							fifo_loop_cnt.deq();
							fifo_addr.deq();
						end
					end else if (read_cnt < 19) begin
						read_cnt <= read_cnt + 1;
						read_word_nop();
						if (outgoing_reads.first == 1)
							check_rte_error(xor_factor);
					end
				endaction
				if (!csr.trim_mode && (read_cnt == 18)) 	break;
				else if (csr.trim_mode && (read_cnt == 19)) break;

				if (rte_read_error_result && (outgoing_reads.first == 1)) read_word_nop();
				if (rte_read_error_result && (outgoing_reads.first == 1)) read_word_nop();
				if (rte_read_error_result) break;

			endseq
		endseq;
		return rs;
	endfunction

	function Stmt find_rh(Bit#(1) xor_factor, Reg#(Bit#(21)) init_addr);
		let rs =  seq
			action // Initialize things.
				rh_upper <= 79;
				rh_lower <= 0;
			endaction
			while(True) seq
				rh_set_ovrflow <= ({0,rh_upper} + {0,rh_lower}) >> 1;
				rh_set <= rh_set_ovrflow[6:0];
				if ((rh_set == rh_lower) || (rh_set == rh_upper))
					break;
				get_rh_din({0, rh_set});
				write_ref_pattern(reg_rom_rdata, init_addr[19:0]);
				check_wordline_for_error(xor_factor, init_addr);
				if (xor_factor == 0)
					if (rte_read_error_result)
						rh_lower <= rh_set;
					else
						rh_upper <= rh_set;
				else
					if (rte_read_error_result)
						rh_upper <= rh_set;
					else
						rh_lower <= rh_set;

			endseq
		endseq;
		return rs;
	endfunction

	let rtrim_bist = seq
		// If we had a bist error coming into the state machine, reset it. otherwise, initalize the bist.
		if (csr_status.bist_error) seq
			csr_status.bist_error <= False;
		endseq else seq
			initialize_read_bist;
			// Fill the outgoing reads with 0.
			action
				fifo_loop_cnt.clear();
				fifo_addr.clear();
				outgoing_reads.clear();
			endaction
			outgoing_reads.enq(0);
			outgoing_reads.enq(0);
		endseq
		while(True) seq
			if (csr_status.bist_error && csr.stop_on_error)
				break;
			if (csr.start_addr > csr.stop_addr)
				break;
			for (current_address[20:4] <= {0,csr.start_addr[19:4]}; current_address[19:4] <= csr.stop_addr[19:4]; current_address[20:4] <= current_address[20:4] + 1) seq
				sibling_loop <= 0;
				// if (csr.trim_mode)
				// 	if (current_address[13] == 1)

				while (True) seq
					get_rh_din(39); // rom_rdata <= get_rh_din(...)
					write_ref_pattern(reg_rom_rdata, current_address[19:0]);
					initialize_wordline(79'h00000000000000000000, current_address);
					// find_rh
					find_rh(0, current_address);
					csr_status.rh0 <= rh_set;

					get_rh_din(39); // rom_rdata <= get_rh_din(...)
					write_ref_pattern(reg_rom_rdata, current_address[19:0]);
					initialize_wordline(79'h7fffffffffffffffffff, current_address);
					// find_rh
					find_rh(1, current_address);
					csr_status.rh1 <= rh_set;

					// rh2 = (rh0 + rh1) >> 1
					rh_set_ovrflow <= ({0,csr_status.rh1} + {0,csr_status.rh0}) >> 1;
					action
						csr_status.rh2 <= rh_set_ovrflow[6:0];
						rh3 <= csr_status.rh1 - csr_status.rh0;
						rh4 <= (csr_status.rh1 - csr_status.rh0) >> 1;
					endaction
					//get_rh_din(rh2); // rom_rdata <= get_rh_din(...)
					get_rh_din({0,csr_status.rh2}); // rom_rdata <= get_rh_din(...)
					write_ref_pattern(reg_rom_rdata, current_address[19:0]);
					if (csr.stop_on_error && (rh4 <= {2'b00, csr.rh4_margin})) action
						let csr_update = csr_status;
						csr_update.error_address = {current_address[19:4], 4'b0000};
						csr_update.bist_error = True;
						csr_status <= csr_update;
					endaction

					if (csr_status.bist_error)
						break;
					if (csr.trim_mode && (sibling_loop == 0)) action
						sibling_loop <= sibling_loop + 1;
						current_address[13] <= current_address[13] ^ 1;
						rh2_sibling <= csr_status.rh2;
					endaction else if (csr.trim_mode && (sibling_loop == 1)) action
						sibling_loop <= sibling_loop + 1;
						current_address[13] <= current_address[13] ^ 1;
					endaction
					if (sibling_loop == 2) seq
						get_rh_din({0, rh2_sibling}); // rom_rdata <= get_rh_din(...)
						write_ref_pattern(reg_rom_rdata, current_address[19:0]);
						if (current_address[12:4] == 9'h1ff)
							current_address[13] <= current_address[13] ^ 1;
					endseq
					if (sibling_loop == 2)
						break;
					if (!csr.trim_mode)
						break;
				endseq
				if (csr_status.bist_error)
					break;

			endseq
			break;
		endseq
	endseq;


	Stmt fsm_main=seq
		action
			let update_status = csr_status;
			update_status.busy = True;
			if (csr.bist_reset && csr_status.bist_error)
				update_status.bist_error = False;
			csr_status <= update_status;
		endaction
		if(csr.bist_wr_en) write_bist;
		else if(csr.bist_rd_en) read_bist;
		else if(csr.bist_rte_en) rtrim_bist;
		csr_status.busy<=False;
	endseq;
	FSM fsm <- mkFSM(fsm_main);

	rule start(csr.start && !bist_started);
		bist_started <= True;
		fsm.start();
	endrule
	rule prime_bist(!csr.start && bist_started);
		bist_started <= False;
	endrule

	method Action cfg(Bist_Cfg_Regs regs);
		csr <=regs;
	endmethod
        method Bist_Status_Regs status();
		return csr_status;
	endmethod
	method Bit#(18) address;
		return mram_address;
	endmethod
	method Bit#(4) stripe_sel;
		return mram_stripe_sel;
	endmethod
	method Bool clk_en;
		return mram_clk_en;
	endmethod
	method Bit#(79) wdata;
		return mram_wdata;
	endmethod
	method Bool wen;
		return mram_we;
	endmethod
	method Bool ref_prg_en;
		return mram_ref_prg_en;
	endmethod
	method Bit#(8) rom_addr;
		return rom_addr_o;
	endmethod

	method Bool rom_ce;
		return rom_ce_o;
	endmethod

	method Action mram_dout(Bit#(79) rdata_i);
		mram_rdata <= rdata_i;
	endmethod
	method Action mbusy(Bit#(1) busy_i);
		mram_busy <= busy_i;
	endmethod
	method Action rom_dout (Bit#(79) rom_dout_i);
		rom_rdata <= rom_dout_i;
	endmethod

endmodule
