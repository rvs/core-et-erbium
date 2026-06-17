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

package Axi2Mram;

import Fabric_Defs   :: *;
import FIFOF         :: *;
import SpecialFIFOs  :: *;
import Semi_FIFOF    :: *;
import AXI4_Types    :: *;
import AXI4_Fabric   :: *;
import Vector        :: *;
import Clocks        :: *;
import StmtFSM       :: *;
import ConfigReg     :: *;
import Axi2MramUtils    :: *;
import ExclusiveMonitor :: *;
import MramBankIfc      :: *;
import MramBankTranslator :: *;

`define BANK_LANES 4

typedef enum {
    Wr_Priority,
    Rd_Priority
} ArbiterPriority deriving (Bits, Eq);

typedef enum {
    Arbiter_WritePriority,   // Always prioritize writes over reads
    Arbiter_ReadPriority,    // Always prioritize reads over writes
    Arbiter_RoundRobin,      // Alternate after each simultaneous conflict
    Arbiter_OldestFirst      // Whichever request arrived first wins
} ArbiterMode deriving (Bits, Eq);

typedef struct {
    Bit#(64) byte_select;
    Bit#(`BANK_LANES) retire_bank_select;
    Bool rlast;
} AxiReadBeatPlan deriving (Bits, Eq);

typedef struct {
    Vector#(`BANK_LANES, Bit#(20)) bank_addr;
    Bit#(`BANK_LANES) issue_bank_select;
    Bool rlast;
} MramReadIssuePlan deriving (Bits, Eq);

export mkAxi2Mram, AXI2MRAM_IFC(..), MRAM_Bank_IFC(..), Axi2MramRegs_IFC(..), ArbiterMode(..);
interface Axi2MramRegs_IFC;
    (* always_ready, always_enabled, prefix = "" *)
    method Action set_arbiter_mode (Bit#(2) arbiter_mode);
    (* always_ready, always_enabled, prefix = "" *)
    method Action set_disable_clock_gate (Bit#(4) disable_clock_gate);
    (* always_ready *) method Bool   axi_busy_o;
    (* always_ready *) method Bit#(4) cmd_queue_active_o;
    (* always_ready *) method Bool   oor_write_hwset_o;
    (* always_ready *) method Bool   oor_read_hwset_o;
    (* always_ready *) method Bool   mram_not_ready_hwset_o;
    (* always_ready *) method Bool   mram_unpowered_hwset_o;
    (* always_ready *) method Bool   maintenance_hwset_o;
    (* always_ready *) method Bool   unrecoverable_error_hwset_o;
endinterface: Axi2MramRegs_IFC

interface AXI2MRAM_IFC;
    (* always_ready, always_enabled, prefix = "mram" *)
    method Action mram_reset_bi (Bool reset_bi);
    (* always_ready, always_enabled, prefix = "mram" *)
    method Action mram_legacy_mode (Bool legacy_mode);
    interface Axi2MramRegs_IFC regs;
    interface AXI4_Slave_IFC #(Wd_Id, Wd_Addr, Wd_Data, Wd_User) axi_slave;
    interface Vector #(`BANK_LANES, MRAM_Bank_IFC) mram;
endinterface

(* synthesize *)
module mkAxi2Mram (AXI2MRAM_IFC);
    Clock c <- exposeCurrentClock;
    MakeResetIfc mram_reset <- mkReset(0, True, c);
    AXI4_Slave_Xactor_IFC #(Wd_Id, Wd_Addr, Wd_Data, Wd_User) axi_xtactor <- mkAXI4_Slave_Xactor();
    ExclusiveMonitor #(32, 4, Wd_Id, Wd_Addr) excl_mon <- mkExclusiveMonitor;
    Reg #(AXI4_Resp)  excl_rd_resp <- mkReg(axi4_resp_okay);
    Reg #(AXI4_Resp)  excl_wr_resp <- mkReg(axi4_resp_okay);
    Wire #(Bool)      oor_rd_req   <- mkDWire(False);
    Wire #(Bool)      rd_not_ready_req_w <- mkDWire(False);
    Wire #(Bool)      rd_unpowered_req_w <- mkDWire(False);
    Wire #(Bool)      rd_maintenance_req_w <- mkDWire(False);
    Wire #(Bool)      rd_slverr_now_w <- mkDWire(False);
    Reg #(Bool)       rd_slverr_req <- mkReg(False);   // True when current read is rejected with SLVERR
    Reg #(Bool)       oor_wr_req   <- mkReg(False);  // True when current write is rejected with SLVERR
    Reg #(Bit #(9)) write_beat <- mkReg(0);
    Wire #(Bool)   axi_busy_w <- mkDWire(False);
    Wire #(Bool)   axi_read_request_w <- mkDWire(False);
    Wire #(Bool)   axi_write_request_w <- mkDWire(False);
    Wire #(Bool)   axi_simultaneous_request_w <- mkDWire(False);
    Wire #(Bool)   stall_mram_read_cycle <- mkDWire(False);
    Wire #(Bit #(4)) disable_clock_gate_w <- mkDWire(0);
    Wire #(Bool)   deq_o_rd_addr <- mkDWire(False);
    Wire #(Bool)   deq_o_wr_addr <- mkDWire(False);
    Reg #(ArbiterPriority)   arbiter_priority <- mkReg(Rd_Priority);
    Wire #(ArbiterMode)      arbiter_mode_w <- mkDWire(Arbiter_RoundRobin);
    Wire #(Bool)             oor_wr_hwset_w <- mkDWire(False);
    Wire #(Bool)             oor_rd_hwset_w <- mkDWire(False);
    Wire #(Bool)             mram_not_ready_rd_hwset_w <- mkDWire(False);
    Wire #(Bool)             mram_not_ready_wr_hwset_w <- mkDWire(False);
    Wire #(Bool)             mram_unpowered_rd_hwset_w <- mkDWire(False);
    Wire #(Bool)             mram_unpowered_wr_hwset_w <- mkDWire(False);
    Wire #(Bool)             maintenance_rd_hwset_w <- mkDWire(False);
    Wire #(Bool)             maintenance_wr_hwset_w <- mkDWire(False);
    Wire #(Bool)             unrecoverable_error_rd_hwset_w <- mkDWire(False);
    Reg #(ArbiterPriority)   oldest_request <- mkReg(Rd_Priority);
    Reg #(Bool)   mram_read_loop <- mkReg(True);
    Reg #(Bool)   axi_write_loop <- mkReg(True);
    Reg #(Bool)   axi_read_resp_loop <- mkReg(True);
    Reg #(Bool)   axi_read_bank_xlator_owned <- mkReg(False);
    Reg #(Bool)   mram_read_packet_captured <- mkReg(False);
    PulseWire     set_mram_read_packet_captured_pw <- mkPulseWire();
    PulseWire     clr_mram_read_packet_captured_pw <- mkPulseWire();
    Reg #(Bool)   ship_it <- mkReg(False);
    Reg #(Bit#(9))   axi_read_pkt_cnt <- mkReg(9'b0);
    FIFOF #(AxiReadBeatPlan) axi_read_beat_plan_q <- mkSizedBypassFIFOF(8);
    FIFOF #(MramReadIssuePlan) mram_read_issue_plan_q <- mkSizedBypassFIFOF(8);
    Reg #(Bit #(Wd_Addr)) current_rbeat_bank_address <- mkReg(0);
    Reg #(Bit #(Wd_Addr)) current_rmram_bank_address <- mkReg(0);
    Reg #(UInt #(9)) current_rbeat_bank_beat <- mkReg(0);
    Reg #(UInt #(9)) current_rmram_bank_beat <- mkReg(0);
    Vector#(`BANK_LANES, Wire#(Bool))                  wr_cmd_active <- replicateM(mkDWire(False));
    Vector#(`BANK_LANES, Wire#(Bool))                  cmd_que_running <- replicateM(mkDWire(False));

    Reg #(Bit #(64))        axi_running_strb <- mkReg(0);
    Reg #(Bit #(512))       axi_running_data <- mkReg(0);
    Reg #(Bool)             axi_running_wlast <- mkReg(False);
    Vector#(`BANK_LANES, FIFOF#(MemoryOperation)) bank_cmd_queue <- replicateM(mkSizedFIFOF(2));
    Vector#(`BANK_LANES, Wire #(Bool)) bank_cmd_queue_notempty_w <- replicateM(mkDWire(False));
    Vector#(`BANK_LANES, Wire #(Bool)) bank_cmd_queue_deq_w <- replicateM(mkDWire(False));
    Vector#(`BANK_LANES, Wire #(MemoryOperation)) bank_cmd_queue_first_w <- replicateM(mkDWire(?));
    Vector#(`BANK_LANES, Vector#(2, Reg#(Bit #(13))))  shipped_lsb_addr <- replicateM(replicateM(mkConfigReg(0)));
    Wire #(Bool) startup_clk_gate_byp_w    <- mkDWire(False);
    Vector#(`BANK_LANES, GatedClockIfc)       mram_clk_gate <- replicateM(mkGatedClockFromCC(False));
    MramBankTranslatorIfc bank_xlator_0 <- mkMramBankTranslator(mram_clk_gate[0].new_clk, mram_reset.new_rst);
    MramBankTranslatorIfc bank_xlator_1 <- mkMramBankTranslator(mram_clk_gate[1].new_clk, mram_reset.new_rst);
    MramBankTranslatorIfc bank_xlator_2 <- mkMramBankTranslator(mram_clk_gate[2].new_clk, mram_reset.new_rst);
    MramBankTranslatorIfc bank_xlator_3 <- mkMramBankTranslator(mram_clk_gate[3].new_clk, mram_reset.new_rst);
    Vector#(`BANK_LANES, MramBankTranslatorIfc) bank_xlator = vec4(
        bank_xlator_0,
        bank_xlator_1,
        bank_xlator_2,
        bank_xlator_3
    );
    Wire #(Bool)                                          mram_ready_all_w <- mkDWire(True);
    Wire #(Bool)                                          mram_pwr_ok_all_w <- mkDWire(True);
    Wire #(Bool)                                          mram_maintenance_any_w <- mkDWire(False);
    Vector#(`BANK_LANES, MRAM_Bank_IFC) banks = vec4(
        bank_xlator_0.mram,
        bank_xlator_1.mram,
        bank_xlator_2.mram,
        bank_xlator_3.mram
    );

    function Action mram_write_segment (
        Bit#(3)        inst,
        Bit#(2)        bank_i,
        Bit#(64)       data,
        Bit#(64)       bwe,
        Bit#(17)       wl_addr
    );
        return action
            wr_cmd_active[bank_i] <= True;
            bank_xlator[bank_i].issueWrite(MramBankWriteCmd {
                addr: wl_addr,
                ce: unpack(8'b1 << inst),
                we: True,
                din: data,
                bwe: bwe
            });
        endaction;
    endfunction

    rule aggregate_bank_status;
        Bool ready_all = True;
        Bool pwr_ok_all = True;
        Bool maintenance_any = False;
        for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
            let bank_ready = bank_xlator[i].ready;
            let bank_pwr_ok = bank_xlator[i].pwrOk;
            let bank_maintenance = bank_xlator[i].maintenance;
            ready_all = ready_all && bank_ready;
            pwr_ok_all = pwr_ok_all && bank_pwr_ok;
            maintenance_any = maintenance_any || bank_maintenance;
        end
        mram_ready_all_w <= ready_all;
        mram_pwr_ok_all_w <= pwr_ok_all;
        mram_maintenance_any_w <= maintenance_any;
    endrule
    Wire #(Bool) axi_rdata_if_value <- mkDWire(False);
    Wire #(Bool) axi_wdata_if_value <- mkDWire(False);
    Reg #(Bool) axi_write_in_progress <- mkReg(False);
    Wire #(Bool) axi_write_complete <- mkDWire(False);
    Reg #(Bool) axi_read_in_progress <- mkReg(False);
    Wire #(Bool) axi_read_complete <- mkDWire(False);
    Wire #(Bool) operation_in_progress <- mkDWire(False);

    rule read_operation_status(axi_rdata_if_value || axi_read_complete);
        axi_read_in_progress <= axi_rdata_if_value? True : False;
    endrule
    rule write_operation_status(axi_wdata_if_value || axi_write_complete);
        axi_write_in_progress <= axi_wdata_if_value? True : False;
    endrule
    rule is_operation_in_progress;
        operation_in_progress <= axi_read_in_progress || axi_write_in_progress;
    endrule

    rule axi_data_if_value;
        axi_rdata_if_value <= (
                !(bank_cmd_queue[0].notEmpty || bank_cmd_queue[1].notEmpty ||
                  bank_cmd_queue[2].notEmpty || bank_cmd_queue[3].notEmpty) &&
                axi_read_request_w &&
                (!axi_simultaneous_request_w ||
                axi_simultaneous_request_w && (arbiter_priority == Rd_Priority)) &&
                !operation_in_progress &&
                !mram_read_packet_captured
            );
        axi_wdata_if_value <= (
                axi_write_request_w &&
                (!axi_simultaneous_request_w ||
                axi_simultaneous_request_w && (arbiter_priority == Wr_Priority)) &&
                !operation_in_progress
            );
    endrule


    Stmt axi_rdata_to_mram_reads = seq
        action
            let araddr = axi_xtactor.o_rd_addr.first.araddr;
            current_rbeat_bank_address <= araddr;
            current_rmram_bank_address <= araddr;
            current_rbeat_bank_beat <= 0;
            current_rmram_bank_beat <= 0;
        endaction
        while (
            !(pack(current_rmram_bank_beat) > zeroExtend(axi_xtactor.o_rd_addr.first.arlen)) ||
            !(pack(current_rbeat_bank_beat) > zeroExtend(axi_xtactor.o_rd_addr.first.arlen))
        ) seq
            action
                let arsize = axi_xtactor.o_rd_addr.first.arsize;
                Bit #(12) addr_inc = 1 << arsize;
                Bit #(12) beat_mask = zeroExtend(addr_inc) - 12'd1;
                let arlen = axi_xtactor.o_rd_addr.first.arlen;
                Bool unaligned_start =
                    ((axi_xtactor.o_rd_addr.first.araddr[11:0] & beat_mask) != 0);
                Bool stop_counting_rmram_beats = pack(current_rmram_bank_beat) > zeroExtend(arlen);
                Bool stop_counting_rbeat_beats = pack(current_rbeat_bank_beat) > zeroExtend(arlen);
                Bool proceed_with_rmram_beat = !stop_counting_rmram_beats && mram_read_issue_plan_q.notFull;
                Bool proceed_with_rbeat_beat = !stop_counting_rbeat_beats && axi_read_beat_plan_q.notFull;
                Bit #(64) select_bit_mask = masked_byte_size_selection(arsize);

                if (proceed_with_rmram_beat) action
                    current_rmram_bank_beat <= current_rmram_bank_beat + 1;
                    Bit #(12) curr_rmram_addr_lsb = current_rmram_bank_address[11:0];
                    Bit #(12) next_rmram_addr_lsb =
                        (unaligned_start && (current_rmram_bank_beat == 0)) ?
                            ((curr_rmram_addr_lsb + beat_mask) & ~beat_mask) :
                            (curr_rmram_addr_lsb + zeroExtend(addr_inc));
                    current_rmram_bank_address <= {current_rmram_bank_address[31:12], next_rmram_addr_lsb};
                    Bit #(6)  byte_offset = current_rmram_bank_address[5:0];
                    Bit #(128) shifted_mask = zeroExtend(select_bit_mask) << byte_offset;
                    Bit #(64) curr_mask  = shifted_mask[63:0];
                    Bit #(1) first_mram_beat = pack(current_rmram_bank_beat == 0);
                    Bit #(12) prev_rmram_addr_lsb =
                        (current_rmram_bank_beat == 0) ? current_rmram_bank_address[11:0] :
                        ((unaligned_start && (current_rmram_bank_beat == 1)) ? axi_xtactor.o_rd_addr.first.araddr[11:0] :
                         (current_rmram_bank_address[11:0] - zeroExtend(addr_inc)));
                    Bit #(6) prev_byte_offset = prev_rmram_addr_lsb[5:0];
                    Bit #(128) prev_shifted_mask = zeroExtend(select_bit_mask) << prev_byte_offset;
                    Bit #(64) prev_curr_mask = prev_shifted_mask[63:0];
                    Bit #(32) curr_rmram_addr_full = current_rmram_bank_address;
                    Bit #(32) prev_rmram_addr_full = {current_rmram_bank_address[31:12], prev_rmram_addr_lsb};
                    Bool prev_group_changes = (curr_rmram_addr_full[31:6] != prev_rmram_addr_full[31:6]);
                    Bit #(4) current_issue_lane_select = {
                        pack(curr_mask[63:48] != 0),
                        pack(curr_mask[47:32] != 0),
                        pack(curr_mask[31:16] != 0),
                        pack(curr_mask[15:0]  != 0)
                    };
                    Bit #(4) prev_issue_lane_select = {
                        pack(prev_curr_mask[63:48] != 0),
                        pack(prev_curr_mask[47:32] != 0),
                        pack(prev_curr_mask[31:16] != 0),
                        pack(prev_curr_mask[15:0]  != 0)
                    };
                    Bit #(4) issue_bank_select = {
                        current_issue_lane_select[3] & (first_mram_beat | pack(prev_group_changes) | ~prev_issue_lane_select[3]),
                        current_issue_lane_select[2] & (first_mram_beat | pack(prev_group_changes) | ~prev_issue_lane_select[2]),
                        current_issue_lane_select[1] & (first_mram_beat | pack(prev_group_changes) | ~prev_issue_lane_select[1]),
                        current_issue_lane_select[0] & (first_mram_beat | pack(prev_group_changes) | ~prev_issue_lane_select[0])
                    };
                    let translated_addr = translate_addr(current_rmram_bank_address);
                    let sliced_addr = {translated_addr[24:6], translated_addr[3]};
                    Bit #(20) issue_bank_addr3 = (issue_bank_select[3] == 1'b1) ? sliced_addr : 20'd0;
                    Bit #(20) issue_bank_addr2 = (issue_bank_select[2] == 1'b1) ? sliced_addr : 20'd0;
                    Bit #(20) issue_bank_addr1 = (issue_bank_select[1] == 1'b1) ? sliced_addr : 20'd0;
                    Bit #(20) issue_bank_addr0 = (issue_bank_select[0] == 1'b1) ? sliced_addr : 20'd0;
                    Bool rmram_rlast = (zeroExtend(arlen) == pack(current_rmram_bank_beat));
                    if (issue_bank_select != 0 || rmram_rlast) action
                        mram_read_issue_plan_q.enq(
                            MramReadIssuePlan {
                                bank_addr : vec4(
                                    issue_bank_addr0,
                                    issue_bank_addr1,
                                    issue_bank_addr2,
                                    issue_bank_addr3
                                ),
                                issue_bank_select: issue_bank_select,
                                rlast: rmram_rlast
                            }
                        );
                    endaction
                endaction

                if (proceed_with_rbeat_beat) action
                    current_rbeat_bank_beat <= current_rbeat_bank_beat + 1;
                    Bit #(12) curr_rbeat_addr_lsb = current_rbeat_bank_address[11:0];
                    Bit #(12) next_rbeat_addr_lsb =
                        (unaligned_start && (current_rbeat_bank_beat == 0)) ?
                            ((curr_rbeat_addr_lsb + beat_mask) & ~beat_mask) :
                            (curr_rbeat_addr_lsb + zeroExtend(addr_inc));
                    current_rbeat_bank_address <= {current_rbeat_bank_address[31:12], next_rbeat_addr_lsb};

                    Bit #(6) rbeat_rotate_offset = current_rbeat_bank_address[5:0];
                    Bit #(128) rbeat_shifted_mask = zeroExtend(select_bit_mask) << rbeat_rotate_offset;
                    Bit #(64) planned_byte_select = rbeat_shifted_mask[63:0];
                    Bit #(1) last_rbeat = pack(zeroExtend(arlen) == pack(current_rbeat_bank_beat));
                    Bit #(6) next_rbeat_rotate_offset = next_rbeat_addr_lsb[5:0];
                    Bit #(128) next_rbeat_shifted_mask = zeroExtend(select_bit_mask) << next_rbeat_rotate_offset;
                    Bit #(64) next_planned_byte_select = next_rbeat_shifted_mask[63:0];
                    Bit #(32) curr_rbeat_addr_full = {current_rbeat_bank_address[31:12], curr_rbeat_addr_lsb};
                    Bit #(32) next_rbeat_addr_full = {current_rbeat_bank_address[31:12], next_rbeat_addr_lsb};
                    Bool next_group_changes =
                        (curr_rbeat_addr_full[31:6] != next_rbeat_addr_full[31:6]);
                    Bit #(4) current_lane_select = {
                        pack(planned_byte_select[63:48] != 0),
                        pack(planned_byte_select[47:32] != 0),
                        pack(planned_byte_select[31:16] != 0),
                        pack(planned_byte_select[15:0]  != 0)
                    };
                    Bit #(4) next_lane_select = {
                        pack(next_planned_byte_select[63:48] != 0),
                        pack(next_planned_byte_select[47:32] != 0),
                        pack(next_planned_byte_select[31:16] != 0),
                        pack(next_planned_byte_select[15:0]  != 0)
                    };
                    Bit #(4) retire_bank_select = {
                        current_lane_select[3] & (last_rbeat | pack(next_group_changes) | ~next_lane_select[3]),
                        current_lane_select[2] & (last_rbeat | pack(next_group_changes) | ~next_lane_select[2]),
                        current_lane_select[1] & (last_rbeat | pack(next_group_changes) | ~next_lane_select[1]),
                        current_lane_select[0] & (last_rbeat | pack(next_group_changes) | ~next_lane_select[0])
                    };
                    axi_read_beat_plan_q.enq(
                        AxiReadBeatPlan {
                            byte_select : planned_byte_select,
                            retire_bank_select : retire_bank_select,
                            rlast : unpack(last_rbeat)
                        }
                    );
                endaction
            endaction
        endseq

    endseq;
    FSM axi_rdata_to_mram_reads_fsm <- mkFSM(axi_rdata_to_mram_reads);

    Stmt mram_read_seq = seq
        if (axi_rdata_if_value && !mram_read_packet_captured) seq
            if (!rd_slverr_now_w) axi_rdata_to_mram_reads_fsm.start();
            if (rd_slverr_now_w) action
                mram_read_loop        <= False;
                set_mram_read_packet_captured_pw.send();
            endaction else while (mram_read_loop) seq
                if (stall_mram_read_cycle)
                    noAction;
                else if (mram_read_issue_plan_q.notEmpty)
                    action
                        let plan = mram_read_issue_plan_q.first;
                        for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
                            if (plan.issue_bank_select[i] == 1'b1) begin
                                bank_xlator[i].enqReadReq(MramBankReadReq {
                                    addr: plan.bank_addr[i][19:3],
                                    pair: plan.bank_addr[i][2:1]
                                });
                            end
                        end
                        if (plan.rlast) action
                            set_mram_read_packet_captured_pw.send();
                            mram_read_loop <= False;
                        endaction
                        mram_read_issue_plan_q.deq();
                    endaction
                else
                    noAction;
            endseq
            action
                mram_read_loop <= True;
                axi_read_complete <= True;
            endaction

        endseq
    endseq;

    Stmt axi_rdata_seq = seq
        if (axi_rdata_if_value) seq
            action
                axi_read_bank_xlator_owned <= True;
                let rd_addr = axi_xtactor.o_rd_addr.first;
                if (rd_slverr_now_w) begin
                    excl_rd_resp <= axi4_resp_slverr;
                    rd_slverr_req   <= True;
                    if (oor_rd_req)
                        oor_rd_hwset_w  <= True;
                    if (rd_not_ready_req_w)
                    mram_not_ready_rd_hwset_w <= True;
                    if (rd_unpowered_req_w)
                    mram_unpowered_rd_hwset_w <= True;
                    if (rd_maintenance_req_w)
                    maintenance_rd_hwset_w <= True;
                end else if (rd_addr.arlock == axlock_exclusive) begin
                    let resp <- excl_mon.check_read(rd_addr.arid, rd_addr.araddr,
                                                    rd_addr.arsize, rd_addr.arlock);
                    excl_rd_resp <= resp;
                end else begin
                    excl_rd_resp <= axi4_resp_okay;
                    rd_slverr_req <= False;
                end
            endaction
            while (axi_read_resp_loop) seq
                action
                    if (rd_slverr_req) action
                        let arlen = axi_xtactor.o_rd_addr.first.arlen;
                        let rlast = (axi_read_pkt_cnt[7:0] == arlen);
                        axi_xtactor.i_rd_data.enq(AXI4_Rd_Data {
                            rid   : axi_xtactor.o_rd_addr.first.arid,
                            rdata : 0,
                            rresp : axi4_resp_slverr,
                            rlast : rlast,
                            ruser : axi_xtactor.o_rd_addr.first.aruser
                        });
                        if (rlast)
                            axi_read_resp_loop <= False;
                        else
                            axi_read_pkt_cnt <= axi_read_pkt_cnt + 1;
                    endaction else if (
                        axi_read_beat_plan_q.notEmpty &&
                        axi_xtactor.i_rd_data.notFull
                    ) action
                        let plan                = axi_read_beat_plan_q.first;
                        let byte_select         = plan.byte_select;
                        let retire_bank_select  = plan.retire_bank_select;
                        let rlast               = plan.rlast;
                        Bit#(`BANK_LANES) data_enq_lane_select = {
                            pack(byte_select[63:48] != 0),
                            pack(byte_select[47:32] != 0),
                            pack(byte_select[31:16] != 0),
                            pack(byte_select[15:0]  != 0)
                        };
                        Bit#(512) byte_mask = expand_wstrb_to_bitmask(byte_select);
                        Bool data_enq_ready = True;
                        for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
                            if (data_enq_lane_select[i] == 1'b1 && !bank_xlator[i].rspNotEmpty)
                                data_enq_ready = False;
                        end
                        Bool unrecoverable_ecc  = False;
                        Vector#(`BANK_LANES, Bit#(128)) lane_data = replicate(0);
                        for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
                            if (bank_xlator[i].rspNotEmpty)
                                lane_data[i] = bank_xlator[i].rspFirst.data;
                        end
                        let full_mram_dout = { lane_data[3], lane_data[2], lane_data[1], lane_data[0] };

                        if (data_enq_ready) action
                            if (unrecoverable_ecc)
                                unrecoverable_error_rd_hwset_w <= True;
                            axi_xtactor.i_rd_data.enq(AXI4_Rd_Data {
                                rid    : axi_xtactor.o_rd_addr.first.arid,
                                rdata  : full_mram_dout & byte_mask,
                                rresp  : (unrecoverable_ecc ? axi4_resp_slverr : excl_rd_resp),
                                rlast  : rlast,
                                ruser  : axi_xtactor.o_rd_addr.first.aruser
                            });
                            axi_read_beat_plan_q.deq();
                            if (rlast) axi_read_resp_loop <= False;
                            for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
                                if (bank_xlator[i].rspNotEmpty && unpack(retire_bank_select[i]))
                                    bank_xlator[i].rspDeq;
                            end
                        endaction
                    endaction
                endaction
            endseq
            action
                deq_o_rd_addr <= True;
                axi_read_resp_loop <= True;
                axi_read_pkt_cnt <= 0;
                rd_slverr_req <= False;
                axi_read_bank_xlator_owned <= False;
            endaction
        endseq
    endseq;
    function Stmt collect_wdata_and_submit_to_mram_cmd_queue();
        return seq
            action
                let wr_addr = axi_xtactor.o_wr_addr.first;
                if (!addr_in_range(wr_addr.awaddr)) begin
                    excl_wr_resp <= axi4_resp_slverr;
                    oor_wr_req      <= True;
                    oor_wr_hwset_w  <= True;
                end else if (wr_addr.awlock == axlock_exclusive) begin
                    let resp <- excl_mon.check_write(wr_addr.awid, wr_addr.awaddr,
                                                      wr_addr.awsize, wr_addr.awlock);
                    excl_wr_resp <= resp;
                end else if (!mram_ready_all_w || !mram_pwr_ok_all_w || mram_maintenance_any_w) begin
                    excl_wr_resp <= axi4_resp_slverr;
                    oor_wr_req <= True;
                    if (!mram_ready_all_w)
                        mram_not_ready_wr_hwset_w <= True;
                    if (!mram_pwr_ok_all_w)
                        mram_unpowered_wr_hwset_w <= True;
                    if (mram_maintenance_any_w)
                        maintenance_wr_hwset_w <= True;
                end else
                    excl_wr_resp <= axi4_resp_okay;
            endaction
            while(axi_write_loop) seq
                if (oor_wr_req) action
                    let wlast = axi_xtactor.o_wr_data.first.wlast;
                    axi_xtactor.o_wr_data.deq();
                    if (wlast)
                        axi_write_loop <= False;
                endaction else seq
                    while (True) seq
                        if (!ship_it && !axi_running_wlast) action
                            let wlast  = axi_xtactor.o_wr_data.first.wlast;
                            let wstrb  = axi_xtactor.o_wr_data.first.wstrb;
                            let wdata  = axi_xtactor.o_wr_data.first.wdata & expand_wstrb_to_bitmask(wstrb);
                            let awsize = axi_xtactor.o_wr_addr.first.awsize;
                            let awaddr = axi_xtactor.o_wr_addr.first.awaddr;
                            Bit #(13) addr_inc = {4'b0000, write_beat} << awsize;
                            Bit #(13) lsb_addr =  {1'b0, awaddr[11:0]} + addr_inc;
                            axi_running_strb <= axi_running_strb | wstrb;
                            axi_running_data <= axi_running_data | wdata;
                            axi_running_wlast <= wlast;
                            for (Integer bank_i = 0; bank_i < 4; bank_i = bank_i + 1) begin
                                for (Integer inst_i = 0; inst_i < 2; inst_i = inst_i + 1) begin
                                    Bit#(8) inst_new_wstrb = wstrb[(bank_i * 16) + (inst_i * 8) + 7: (bank_i * 16) + (inst_i * 8)];
                                    Bit#(8) inst_sel = inst_new_wstrb;
                                    if ((|inst_sel) == 1'b1) begin
                                        shipped_lsb_addr[bank_i][inst_i] <= lsb_addr;
                                    end
                                end
                                end
                            Bool last_packet = wlast;
                            Bool last_bytes_of_line = wstrb[63] == 1;
                            ship_it <=  last_packet || last_bytes_of_line;
                            write_beat <= write_beat + 1;
                            axi_xtactor.o_wr_data.deq();
                        endaction else break;
                    endseq
                    while (ship_it) action
                        Bit #(64)  accum_wstrb = axi_running_strb;
                        Bit #(512) accum_data  = axi_running_data;
                        let awaddr = axi_xtactor.o_wr_addr.first.awaddr;
                        Bool excl_suppress = oor_wr_req ||
                                             ((axi_xtactor.o_wr_addr.first.awlock == axlock_exclusive)
                                              && (excl_wr_resp == axi4_resp_okay));
                        for (Integer bank_i = 0; bank_i < 4; bank_i = bank_i + 1) begin
                            if (bank_has_write_data(axi_running_strb, bank_i)) begin
                                Bit #(128) bank_data = axi_running_data[127 + bank_i * 128:bank_i * 128];
                                Bit #(16)  bank_strb = axi_running_strb[16 * bank_i + 15:16 * bank_i];
                                if (bank_strb[7:0] != 0) begin
                                    Bit #(13) inst_lsb_addr0 = shipped_lsb_addr[bank_i][0];
                                    let translated_addr0 = translate_addr({awaddr[31:12],inst_lsb_addr0[11:0]});
                                    Bit #(17) inst_wl_addr0 = translated_addr0[24:8];
                                    if (bank_strb[7:0] == 8'hff) begin
                                        if (!excl_suppress)
                                        bank_cmd_queue[bank_i].enq(tagged Write
                                            WriteRequest {
                                                inst: {inst_lsb_addr0[7:6], 1'b0},
                                                addr: inst_wl_addr0,
                                                data: bank_data[63:0],
                                                strb: bank_strb[7:0]
                                            }
                                        );
                                    end else begin
                                        if (!excl_suppress)
                                        bank_cmd_queue[bank_i].enq(tagged RMW
                                            ReadModifyWriteRequest {
                                                inst: {inst_lsb_addr0[7:6], 1'b0},
                                                addr: inst_wl_addr0,
                                                data: bank_data[63:0],
                                                strb: bank_strb[7:0]
                                            }
                                        );
                                    end
                                    accum_wstrb[16 * bank_i + 15:16 * bank_i] = bank_strb & 16'hff00;
                                    accum_data[127 + bank_i * 128:bank_i * 128] =
                                        bank_data & 128'hffffffffffffffff0000000000000000;
                                end else if (bank_strb[15:8] != 0) begin
                                    Bit #(13) inst_lsb_addr1 = shipped_lsb_addr[bank_i][1];
                                    let translated_addr1 = translate_addr({awaddr[31:12],inst_lsb_addr1[11:0]});
                                    Bit #(17) inst_wl_addr1 = translated_addr1[24:8];

                                    if (bank_strb[15:8] == 8'hff) begin
                                        if (!excl_suppress)
                                        bank_cmd_queue[bank_i].enq(tagged Write
                                            WriteRequest {
                                                inst: {inst_lsb_addr1[7:6], 1'b1},
                                                addr: inst_wl_addr1,
                                                data: bank_data[127:64],
                                                strb: bank_strb[15:8]
                                            }
                                        );
                                    end else begin
                                        if (!excl_suppress)
                                        bank_cmd_queue[bank_i].enq(tagged RMW
                                            ReadModifyWriteRequest {
                                                inst: {inst_lsb_addr1[7:6], 1'b1},
                                                addr: inst_wl_addr1,
                                                data: bank_data[127:64],
                                                strb: bank_strb[15:8]
                                            }
                                        );
                                    end
                                    accum_wstrb[16 * bank_i + 15:16 * bank_i] = bank_strb & 16'h00ff;
                                    accum_data[127 + bank_i * 128:bank_i * 128] =
                                        bank_data & 128'h0000000000000000ffffffffffffffff;
                                end
                            end
                        end
                        axi_running_strb <= accum_wstrb;
                        axi_running_data <= accum_data;
                        ship_it <= accum_wstrb != 0? True : False;
                        if (axi_running_wlast) axi_write_loop <= False;
                    endaction
                endseq
            endseq
            action
                let wr_addr_first = axi_xtactor.o_wr_addr.first;
                axi_xtactor.i_wr_resp.enq(AXI4_Wr_Resp {
                    bid   : wr_addr_first.awid,
                    bresp : excl_wr_resp,
                    buser : wr_addr_first.awuser
                });
                if (wr_addr_first.awlock == axlock_normal && !oor_wr_req)
                    excl_mon.snoop_write(wr_addr_first.awaddr, wr_addr_first.awsize);
                write_beat <= 0;
                oor_wr_req <= False;
                deq_o_wr_addr  <= True;
                axi_write_loop <= True;
                axi_running_strb <= 0;
                axi_running_data <= 0;
                axi_running_wlast <= False;
                ship_it<= False;
                axi_write_complete <= True;
                for (Integer bank_i = 0; bank_i < 4; bank_i = bank_i + 1)
                    for (Integer inst_i = 0; inst_i < 2; inst_i = inst_i + 1)
                        shipped_lsb_addr[bank_i][inst_i] <= 0;

            endaction
        endseq;
    endfunction

    Stmt axi_wdata_seq = seq
        if (axi_wdata_if_value)
            collect_wdata_and_submit_to_mram_cmd_queue();
    endseq;
    Stmt always_running0 = seq
        while(True)
            axi_rdata_seq;
    endseq;
    Stmt always_running1 = seq
        while(True)
            axi_wdata_seq;
    endseq;
    Stmt always_running2 = seq
        while(True)
            mram_read_seq;
    endseq;
    FSM axi_fsm0 <- mkFSM(always_running0);
    FSM axi_fsm1 <- mkFSM(always_running1);
    FSM axi_fsm2 <- mkFSM(always_running2);
    rule run_axi_fsm (True);
        axi_fsm0.start;
        axi_fsm1.start;
        axi_fsm2.start;
    endrule

    Stmt arbiter_running = seq
        while(True) seq
            action
                case (arbiter_mode_w)
                    Arbiter_WritePriority: begin
                        arbiter_priority <= Wr_Priority;
                    end
                    Arbiter_ReadPriority: begin
                        arbiter_priority <= Rd_Priority;
                    end
                    Arbiter_RoundRobin: begin
                        if (arbiter_priority == Rd_Priority) begin
                            if (axi_simultaneous_request_w && deq_o_rd_addr)
                                arbiter_priority <= Wr_Priority;
                        end else begin
                            if (axi_simultaneous_request_w && deq_o_wr_addr)
                                arbiter_priority <= Rd_Priority;
                        end
                    end
                    Arbiter_OldestFirst: begin
                        arbiter_priority <= oldest_request;
                    end
                endcase
            endaction
        endseq
    endseq;
    FSM axi_arbiter <- mkFSM(arbiter_running);
    rule run_axi_arbiter_fsm (True);
        axi_arbiter.start;
    endrule
    Stmt clk_gate_bypass_on_startup = seq
        repeat(1000) action
            startup_clk_gate_byp_w <= True;
        endaction
        while (True) noAction;
    endseq;
    FSM mram_startup_conditions <- mkFSM(clk_gate_bypass_on_startup);
    rule run_mram_startup_conditionsr_fsm (True);
        mram_startup_conditions.start;
    endrule
    rule track_oldest_request;
        if (axi_read_request_w && !axi_write_request_w)
            oldest_request <= Rd_Priority;
        else if (axi_write_request_w && !axi_read_request_w)
            oldest_request <= Wr_Priority;
    endrule

    rule axi_busy_operation (
        axi_xtactor.o_rd_addr.notEmpty ||
        axi_xtactor.o_wr_addr.notEmpty
    );
        axi_busy_w <= True;
    endrule
    rule axi_dequeue_rd_addr (deq_o_rd_addr);
        axi_xtactor.o_rd_addr.deq();
        clr_mram_read_packet_captured_pw.send();
    endrule
    rule axi_dequeue_wr_addr (deq_o_wr_addr);
        axi_xtactor.o_wr_addr.deq();
    endrule
    rule axi_read_request (axi_xtactor.o_rd_addr.notEmpty && axi_xtactor.i_rd_data.notFull);
        axi_read_request_w <= True;
    endrule

    rule axi_read_slverr_request (axi_xtactor.o_rd_addr.notEmpty);
        Bool rd_oor = !addr_in_range(axi_xtactor.o_rd_addr.first.araddr);
        Bool rd_not_ready = !mram_ready_all_w;
        Bool rd_unpowered = !mram_pwr_ok_all_w;
        Bool rd_maintenance = mram_maintenance_any_w;
        oor_rd_req <= rd_oor;
        rd_not_ready_req_w <= rd_not_ready;
        rd_unpowered_req_w <= rd_unpowered;
        rd_maintenance_req_w <= rd_maintenance;
        rd_slverr_now_w <= rd_oor || rd_not_ready || rd_unpowered || rd_maintenance;
    endrule

    rule axi_write_request (axi_xtactor.o_wr_addr.notEmpty && axi_xtactor.i_wr_resp.notFull);
        axi_write_request_w <= True;
    endrule

    rule axi_simultaneous_request (axi_read_request_w && axi_write_request_w);
        axi_simultaneous_request_w <= True;
    endrule

    rule update_mram_read_packet_captured;
        if (clr_mram_read_packet_captured_pw)
            mram_read_packet_captured <= False;
        else if (set_mram_read_packet_captured_pw)
            mram_read_packet_captured <= True;
    endrule

    rule forward_wr_stall;
        Bool any_wr_active = False;
        for (Integer i = 0; i < `BANK_LANES; i = i + 1)
            any_wr_active = any_wr_active || wr_cmd_active[i] || cmd_que_running[i];
        stall_mram_read_cycle <= any_wr_active;
    endrule

    for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
        rule run_mram_clocks;
            mram_clk_gate[i].setGateCond(
                    startup_clk_gate_byp_w ||
                    disable_clock_gate_w[i] == 1'b1 ||
                    axi_busy_w ||
                    unpack(reduceOr(pack(bank_xlator[i].busy))) ||
                    unpack(reduceOr(pack(bank_xlator[i].trackedBusy))) ||
                    cmd_que_running[i]
                );
        endrule
    end
    for (Integer i = 0; i < `BANK_LANES; i = i + 1) begin
        rule bank_cmd_wire_assignment;
            bank_cmd_queue_notempty_w[i] <= bank_cmd_queue[i].notEmpty;
            bank_cmd_queue_first_w[i] <= bank_cmd_queue[i].first;
            cmd_que_running[i] <= bank_cmd_queue[i].notEmpty;
        endrule
        rule bank_cmd_wire_deq(bank_cmd_queue_deq_w[i]);
            bank_cmd_queue[i].deq();
        endrule
        Stmt bank_write_cmd_qstmt = seq
            while(True) seq
                if (!axi_rdata_if_value && !axi_read_bank_xlator_owned && bank_cmd_queue_notempty_w[i]) seq
                    if (isWrite(bank_cmd_queue_first_w[i])) seq
                        action
                            let req = getWriteReq(bank_cmd_queue_first_w[i]);
                            await(bank_xlator[i].writeReqReady(unpack(8'b1 << req.inst)));
                            mram_write_segment(
                                req.inst,              // Bit#(Wd_Addr)
                                fromInteger(i),                    // Bit#(2)
                                req.data,                          // Bit#(64)
                                expand_strb_to_bitmask(req.strb),
                                req.addr
                            );
                            bank_cmd_queue_deq_w[i] <= True;
                        endaction
                    endseq else if (isRMW(bank_cmd_queue_first_w[i])) seq
                        action
                            let req = getRMWReq(bank_cmd_queue_first_w[i]);
                            await(bank_xlator[i].rmwReqReady(req.inst));
                            bank_xlator[i].enqRmwReq(MramBankRmwReq {
                                inst: req.inst,
                                addr: req.addr,
                                data: req.data,
                                strb: req.strb
                            });
                        endaction
                        action
                            bank_cmd_queue_deq_w[i] <= True;
                        endaction

                    endseq

                endseq else seq
                    noAction;
                endseq
            endseq
        endseq;
        FSM bank_write_cmd_qfsm <- mkFSM(bank_write_cmd_qstmt);
        rule start_bank_qfsm;
            bank_write_cmd_qfsm.start;
        endrule
    end
    interface mram = banks;

    interface AXI4_Slave_IFC axi_slave = axi_xtactor.axi_side;
    interface Axi2MramRegs_IFC regs;
        method Action set_arbiter_mode (Bit#(2) val);
            arbiter_mode_w <= unpack(val);
        endmethod
        method Action set_disable_clock_gate (Bit#(4) disable_clock_gate);
            disable_clock_gate_w <= disable_clock_gate;
        endmethod
        method Bool   axi_busy_o        = axi_busy_w;
        method Bit#(4) cmd_queue_active_o = {
            pack(bank_cmd_queue_notempty_w[3]),
            pack(bank_cmd_queue_notempty_w[2]),
            pack(bank_cmd_queue_notempty_w[1]),
            pack(bank_cmd_queue_notempty_w[0])
        };
        method Bool   oor_write_hwset_o = oor_wr_hwset_w;
        method Bool   oor_read_hwset_o  = oor_rd_hwset_w;
        method Bool   mram_not_ready_hwset_o = mram_not_ready_rd_hwset_w || mram_not_ready_wr_hwset_w;
        method Bool   mram_unpowered_hwset_o = mram_unpowered_rd_hwset_w || mram_unpowered_wr_hwset_w;
        method Bool   maintenance_hwset_o = maintenance_rd_hwset_w || maintenance_wr_hwset_w;
        method Bool   unrecoverable_error_hwset_o = unrecoverable_error_rd_hwset_w;
    endinterface

    method Action mram_legacy_mode (Bool legacy_mode);
        noAction;
    endmethod
    method Action mram_reset_bi (Bool reset_b);
        if (reset_b == False)
            mram_reset.assertReset();
    endmethod

endmodule
endpackage
