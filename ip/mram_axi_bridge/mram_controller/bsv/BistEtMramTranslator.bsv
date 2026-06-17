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

package BistEtMramTranslator;

import FIFOF  :: *;
import StmtFSM :: *;
import Vector :: *;

export mkBistEtMramTranslator;
export BistEtMramTranslatorIfc(..);
export BistEtMramPipeIfc(..);
export BistEtMramTranslatorResp(..);
export BistEtMramRespStatus(..);

typedef struct {
    Bool      is_write;
    Bool      ref_prg_en;
    Bit#(20)  addr;
    Bit#(79)  data;
} BistEtMramTranslatorCmd deriving (Bits, Eq, FShow);

typedef struct {
    Bool      is_write_ack;
    Bool      is_read_ack;
    Bit#(79)  data;
} BistEtMramTranslatorResp deriving (Bits, Eq, FShow);

typedef enum {
    NoResponseInFlight,
    WaitingForResponse,
    ResponseReady
} BistEtMramRespStatus deriving (Bits, Eq, FShow);

interface BistEtMramPipeIfc;
    (* always_ready, prefix = "" *)
    method Action mram_dout(Bit#(158) rdata_i);
    (* always_ready, prefix = "" *)
    method Action mram_busy(Vector#(8, Bool) busy_i);

    (* always_ready *) method Bit#(17)           addr_o;
    (* always_ready *) method Vector#(8, Bool)   ce_o;
    (* always_ready *) method Vector#(8, Bool)   dout_en_o;
    (* always_ready *) method Bool               we_o;
    (* always_ready *) method Bit#(79)           din_o;
    (* always_ready *) method Bit#(79)           bwe_o;
    (* always_ready *) method Bool               ref_prg_en_o;
    (* always_ready *) method Bool               clk_en_o;
endinterface

interface BistEtMramTranslatorIfc;
    method Bool command_ready;
    method Bool response_valid;
    method Bool op_inflight;
    method Action read_word(Bit#(20) target_addr);
    method Action read_ref_word(Bit#(20) target_addr);
    method Action write_word(Bit#(20) target_addr, Bit#(79) din);
    method Action write_ref_word(Bit#(20) target_addr, Bit#(79) din);
    method ActionValue#(Tuple2#(BistEtMramRespStatus, BistEtMramTranslatorResp)) response;
    method ActionValue#(BistEtMramTranslatorResp) response_blocking;
    interface BistEtMramPipeIfc mram;
endinterface

(* synthesize *)
module mkBistEtMramTranslator(BistEtMramTranslatorIfc);
    Reg#(Bit#(20)) pending_addr <- mkReg(0);
    Reg#(Bit#(79)) pending_din <- mkReg(0);
    Reg#(Bool) pending_write <- mkReg(False);
    Reg#(Bool) pending_ref_prg <- mkReg(False);
    Reg#(Bool) op_active <- mkReg(False);
    Reg#(Bool) issue_cmd <- mkReg(False);
    Reg#(Bool) get_dout <- mkReg(False);
    Reg#(Bit#(158)) mram_dout_q <- mkReg(0);
    Reg#(Vector#(8, Bool)) mram_busy_q <- mkReg(replicate(False));
    FIFOF#(BistEtMramTranslatorCmd) cmd_q <- mkFIFOF;
    FIFOF#(BistEtMramTranslatorCmd) cmd_in_flight_q <- mkFIFOF;
    FIFOF#(BistEtMramTranslatorResp) resp_q <- mkFIFOF;

    function Bit#(17) legacy_mram_addr(Bit#(20) target_addr);
        return {target_addr[19], target_addr[15:0]};
    endfunction
    function Bit#(3) decode_ce_bits(Bit#(20) addr);
        return addr[18:16];
    endfunction
    function Vector#(8, Bool) addr_to_ce_sel(Bit#(3) ce);
        return unpack(8'b1 << ce);
    endfunction

    function Bool selected_busy(Vector#(8, Bool) selected_ce, Vector#(8, Bool) busy_vec);
        Bool any_busy = False;
        for (Integer i = 0; i < 8; i = i + 1)
            any_busy = any_busy || (selected_ce[i] && busy_vec[i]);
        return any_busy;
    endfunction

    function Bool odd_instance_ce();
        return pending_addr[16] == 1;
    endfunction
    function Bit#(79) legacy_read_data(Bit#(158) bank_dout);
        // Match the current MRAM legacy compatibility path, which consumes
        // only lower or lower 79-bit codeword from the paired ET-bank output.
        return odd_instance_ce()? bank_dout[157:79] : bank_dout[78:0];
    endfunction

    function Vector#(8, Bool) active_ce();
        return addr_to_ce_sel(decode_ce_bits(pending_addr));
    endfunction

    function Stmt wait_for_transaction_done();
        return seq
            action
                op_active <= True;
                issue_cmd <= True;
            endaction
            noAction;
            action
                issue_cmd <= False;
            endaction
            if (cmd_in_flight_q.first.is_write) seq
                await(!selected_busy(active_ce(), mram_busy_q));
            endseq else seq
                repeat(4) noAction;
                get_dout <= True;
                get_dout <= False;
                noAction;
                noAction;
            endseq
        endseq;
    endfunction

    Stmt do_read_word = seq
        wait_for_transaction_done();
        action
            cmd_in_flight_q.deq;
            resp_q.enq(BistEtMramTranslatorResp {
                is_write_ack: False,
                is_read_ack: True,
                data: legacy_read_data(mram_dout_q)
            });
            op_active <= False;
        endaction
    endseq;

    Stmt do_write_word = seq
        wait_for_transaction_done();
        action
            cmd_in_flight_q.deq;
            resp_q.enq(BistEtMramTranslatorResp {
                is_write_ack: True,
                is_read_ack: False,
                data: 0
            });
            op_active <= False;
        endaction
    endseq;

    FSM read_word_fsm <- mkFSM(do_read_word);
    FSM write_word_fsm <- mkFSM(do_write_word);

    rule launch_read_word (
        cmd_q.notEmpty &&
        !cmd_q.first.is_write &&
        !op_active &&
        resp_q.notFull &&
        read_word_fsm.done &&
        write_word_fsm.done
    );
        pending_addr  <= cmd_q.first.addr;
        pending_din   <= 0;
        pending_write <= False;
        pending_ref_prg <= cmd_q.first.ref_prg_en;
        cmd_q.deq;
        cmd_in_flight_q.enq(cmd_q.first);
        read_word_fsm.start;
    endrule

    rule launch_write_word (
        cmd_q.notEmpty &&
        cmd_q.first.is_write &&
        !op_active &&
        resp_q.notFull &&
        read_word_fsm.done &&
        write_word_fsm.done
    );
        pending_addr  <= cmd_q.first.addr;
        pending_din   <= cmd_q.first.data;
        pending_write <= True;
        // pending_ref_prg <= cmd_q.first.ref_prg_en;
        cmd_q.deq;
        cmd_in_flight_q.enq(cmd_q.first);
        write_word_fsm.start;
    endrule
    rule assign_pending_ref_prg;
        pending_ref_prg <= cmd_in_flight_q.notEmpty?  cmd_in_flight_q.first.ref_prg_en :  False;
    endrule
    function Bool command_ready_fn();
        return cmd_q.notFull;
    endfunction

    method Bool command_ready;
        return command_ready_fn();
    endmethod

    method Bool response_valid;
        return resp_q.notEmpty;
    endmethod

    method Bool op_inflight;
        return op_active || !read_word_fsm.done || !write_word_fsm.done;
    endmethod

    method Action read_word(Bit#(20) target_addr) if (command_ready_fn());
        cmd_q.enq(BistEtMramTranslatorCmd {
            is_write: False,
            ref_prg_en: False,
            addr: target_addr,
            data: 0
        });
    endmethod

    method Action read_ref_word(Bit#(20) target_addr) if (command_ready_fn());
        cmd_q.enq(BistEtMramTranslatorCmd {
            is_write: False,
            ref_prg_en: True,
            addr: target_addr,
            data: 0
        });
    endmethod

    method Action write_word(Bit#(20) target_addr, Bit#(79) din) if (command_ready_fn());
        cmd_q.enq(BistEtMramTranslatorCmd {
            is_write: True,
            ref_prg_en: False,
            addr: target_addr,
            data: din
        });
    endmethod

    method Action write_ref_word(Bit#(20) target_addr, Bit#(79) din) if (command_ready_fn());
        cmd_q.enq(BistEtMramTranslatorCmd {
            is_write: True,
            ref_prg_en: True,
            addr: target_addr,
            data: din
        });
    endmethod

    method ActionValue#(Tuple2#(BistEtMramRespStatus, BistEtMramTranslatorResp)) response;
        let default_resp = BistEtMramTranslatorResp {
            is_read_ack: False,
            is_write_ack: False,
            data: 0
        };
        let anything_inflight =
            cmd_q.notEmpty || op_active || !read_word_fsm.done || !write_word_fsm.done;
        let ready = resp_q.notEmpty;
        let status =
            ready ? ResponseReady :
            (anything_inflight ? WaitingForResponse : NoResponseInFlight);
        let selected_resp = ready ? resp_q.first : default_resp;

        if (ready)
            resp_q.deq;

        return tuple2(status, selected_resp);
    endmethod

    method ActionValue#(BistEtMramTranslatorResp) response_blocking if (resp_q.notEmpty);
        let resp = resp_q.first;
        resp_q.deq;
        return resp;
    endmethod

    interface BistEtMramPipeIfc mram;
        method Action mram_dout(Bit#(158) rdata_i);
            mram_dout_q <= rdata_i;
        endmethod

        method Action mram_busy(Vector#(8, Bool) busy_i);
            mram_busy_q <= busy_i;
        endmethod

        method Bit#(17) addr_o;
            return legacy_mram_addr(pending_addr);
        endmethod

        method Vector#(8, Bool) ce_o;
            return issue_cmd ? active_ce() : replicate(False);
        endmethod

        method Vector#(8, Bool) dout_en_o;
            return (get_dout && !pending_write) ? active_ce() : replicate(False);
        endmethod

        method Bool we_o;
            return issue_cmd && pending_write;
        endmethod

        method Bit#(79) din_o;
            return pending_din;
        endmethod

        method Bit#(79) bwe_o;
            return pending_write ? '1 : 0;
        endmethod

        method Bool ref_prg_en_o;
            return  pending_ref_prg;
            // return issue_cmd && pending_ref_prg;
        endmethod

        method Bool clk_en_o;
            return issue_cmd || op_active;
        endmethod
    endinterface
endmodule

endpackage
