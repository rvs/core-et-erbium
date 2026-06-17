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

package MramBankTranslator;

import FIFOF        :: *;
import SpecialFIFOs :: *;
import Vector       :: *;
import Clocks       :: *;
import MramBankIfc  :: *;

typedef struct {
    Bit#(17) addr;
    Bit#(2)  pair;
} MramBankReadReq deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(17) addr;
    Bit#(2)  pair;
    Bit#(128) data;
    Bit#(2)   ecc;
} MramBankReadRsp deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(3)  inst;
    Bit#(17) addr;
    Bit#(64) data;
    Bit#(8)  strb;
} MramBankRmwReq deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(17)         addr;
    Vector#(8, Bool) ce;
    Bool             we;
    Bit#(64)         din;
    Bit#(64)         bwe;
} MramBankWriteCmd deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(2)  pair;
    Bool     is_rmw;
    Bit#(3)  inst;
    Bit#(17) addr;
    Bit#(64) data;
    Bit#(8)  strb;
} MramBankReadTxn deriving (Bits, Eq, FShow);

typedef 3 ReadBusyStages;
// Delay dout_en until the same cycle that the pair is eligible for the next CE.
// In steady state that lets the prior read return while the next read launches.
typedef TAdd#(ReadBusyStages, 1) ReadLaunchStages;
// Writes must stay blocked through the dout_en cycle and only release after it.
typedef ReadLaunchStages ReadBlocksWriteStages;
typedef 6 ReadCaptureStages;
typedef 7 RspQueueDepth;

interface MramBankTranslatorIfc;
    interface MRAM_Bank_IFC mram;

    method Bool readReqNotFull;
    method Bool readReqReady(Bit#(2) pair);
    method Action enqReadReq(MramBankReadReq req);

    method Bool rmwReqNotFull;
    method Bool rmwReqReady(Bit#(3) inst);
    method Action enqRmwReq(MramBankRmwReq req);

    method Bool writeReqReady(Vector#(8, Bool) ce);
    method Action issueWrite(MramBankWriteCmd cmd);

    method Bool rspNotEmpty;
    method MramBankReadRsp rspFirst;
    method Action rspDeq;

    method Bool ready;
    method Bool pwrOk;
    method Bool maintenance;
    method Vector#(8, Bool) busy;
    method Vector#(8, Bool) trackedBusy;
    method Bit#(4) outstandingReadPairs;
endinterface

function Bit#(4) pairBit(Bit#(2) pair);
    return 4'b0001 << pair;
endfunction

function Vector#(8, Bool) pairCe(Bit#(2) pair);
    return unpack(8'b00000011 << {pair, 1'b0});
endfunction

function Bool pairWriteBusy(Vector#(8, Reg#(Bool)) write_busy, Bit#(2) pair);
    Bit#(3) lo = {pair, 1'b0};
    Bit#(3) hi = {pair, 1'b1};
    return write_busy[lo] || write_busy[hi];
endfunction

function Bool pairWriteIssued(Bit#(4) issued_write_pairs, Bit#(2) pair);
    return (issued_write_pairs & pairBit(pair)) != 0;
endfunction

function Bool pairReadBusy(Bit#(4) read_busy_pairs, Bit#(2) pair);
    return (read_busy_pairs & pairBit(pair)) != 0;
endfunction

function Bool ceWriteBusy(Vector#(8, Reg#(Bool)) write_busy, Vector#(8, Bool) ce);
    Bool busy = False;
    for (Integer inst = 0; inst < 8; inst = inst + 1)
        busy = busy || (ce[inst] && write_busy[inst]);
    return busy;
endfunction

function Bit#(4) cePairMask(Vector#(8, Bool) ce);
    Bit#(4) mask = 0;
    for (Integer pair = 0; pair < 4; pair = pair + 1)
        if (ce[pair * 2] || ce[pair * 2 + 1])
            mask[pair] = 1;
    return mask;
endfunction

function Bool ceReadBusy(Bit#(4) read_busy_pairs, Vector#(8, Bool) ce);
    return (read_busy_pairs & cePairMask(ce)) != 0;
endfunction

function Bool pairRmwBusy(Bit#(4) rmw_busy_pairs, Bit#(2) pair);
    return (rmw_busy_pairs & pairBit(pair)) != 0;
endfunction

function Bool ceRmwBusy(Bit#(4) rmw_busy_pairs, Vector#(8, Bool) ce);
    return (rmw_busy_pairs & cePairMask(ce)) != 0;
endfunction

function Vector#(8, Bool) instCe(Bit#(3) inst);
    return unpack(8'b1 << inst);
endfunction

function Bit#(3) singleCeInst(Vector#(8, Bool) ce);
    Bit#(3) inst = 0;
    for (Integer i = 0; i < 8; i = i + 1)
        if (ce[i])
            inst = fromInteger(i);
    return inst;
endfunction

function Bit#(64) expandStrbToBitmask(Bit#(8) strb);
    Bit#(64) mask = 0;
    for (Integer i = 0; i < 8; i = i + 1)
        if (strb[i] == 1)
            mask[(i * 8 + 7):(i * 8)] = 8'hFF;
    return mask;
endfunction

function Bit#(64) mergeWriteBytes(Bit#(64) new_data, Bit#(64) old_data, Bit#(8) strb);
    Bit#(64) bitmask = expandStrbToBitmask(strb);
    return (new_data & bitmask) | (old_data & ~bitmask);
endfunction

function Bool readTxnIsRmw(MramBankReadTxn tx);
    return tx.is_rmw;
endfunction

function Bool readTxnIsReadOnly(MramBankReadTxn tx);
    return !tx.is_rmw;
endfunction

function Bool readTxnNeedsRspSlot(MramBankReadTxn tx);
    return readTxnIsReadOnly(tx);
endfunction

function Bool readTxnSinkReady(
    MramBankReadTxn tx,
    Bool rsp_not_full,
    Bool rmw_write_not_full
);
    if (readTxnIsRmw(tx))
        return rmw_write_not_full;
    else if (readTxnIsReadOnly(tx))
        return rsp_not_full;
    else
        return False;
endfunction

function Bit#(4) foldPairBusy(Vector#(n, Bit#(4)) busy_stages);
    Bit#(4) busy = 0;
    for (Integer stage = 0; stage < valueOf(n); stage = stage + 1)
        busy = busy | busy_stages[stage];
    return busy;
endfunction

function Vector#(8, Bool) trackedBusyWithRmw(Vector#(8, Bool) write_busy, Bit#(4) rmw_busy_pairs);
    Vector#(8, Bool) tracked = write_busy;
    for (Integer pair = 0; pair < 4; pair = pair + 1)
        if (rmw_busy_pairs[pair] == 1'b1) begin
            tracked[pair * 2] = True;
            tracked[pair * 2 + 1] = True;
        end
    return tracked;
endfunction

function Action driveWriteCmd(
    Wire#(Bit#(17)) addr_w,
    Wire#(Vector#(8, Bool)) ce_pulse_w,
    Wire#(Bool) we_w,
    Wire#(Bit#(64)) din_w,
    Wire#(Bit#(64)) bwe_w,
    Wire#(Bit#(8)) write_mask_w,
    MramBankWriteCmd cmd
);
    return action
        addr_w <= cmd.addr;
        ce_pulse_w <= cmd.ce;
        we_w <= cmd.we;
        din_w <= cmd.din;
        bwe_w <= cmd.bwe;
        if (cmd.we)
            write_mask_w <= pack(cmd.ce);
    endaction;
endfunction

import "BVI" MramBusyNegedgeReg =
module mkMramBusyNegedgeReg#(Clock clk, Reset rst)(Reg#(Bit#(8)));
    default_clock dflt();
    default_reset no_reset;
    input_clock bank_clk(BANK_CLK, BANK_CLK_GATE) = clk;
    input_reset bank_rst(RST_N) = rst;

    method Q_OUT _read clocked_by(no_clock) reset_by(no_reset);
    method _write(D_IN) enable(EN);

    schedule _write C _write;
endmodule

(* synthesize, gate_input_clocks = "bank_clk" *)
module mkMramBankTranslator#(Clock bank_clk, Reset bank_reset)(MramBankTranslatorIfc);
    FIFOF#(MramBankReadReq) read_req_q <- mkSizedBypassFIFOF(16);
    FIFOF#(MramBankRmwReq) rmw_req_q <- mkSizedBypassFIFOF(16);
    FIFOF#(MramBankWriteCmd) write_req_q <- mkSizedBypassFIFOF(16);
    FIFOF#(MramBankWriteCmd) rmw_write_q <- mkSizedBypassFIFOF(16);
    FIFOF#(MramBankReadRsp) rsp_q <- mkSizedBypassFIFOF(valueOf(RspQueueDepth) );

    Vector#(ReadLaunchStages, FIFOF#(MramBankReadTxn)) launch_pipe <- replicateM(mkPipelineFIFOF);
    Vector#(ReadCaptureStages, FIFOF#(MramBankReadTxn)) capture_pipe <- replicateM(mkPipelineFIFOF);

    Reg#(Bit#(17)) bank_addr_q <- mkReg(0);
    Vector#(8, Reg#(Bool)) launched_write_mask_q <- replicateM(mkReg(False));
    Vector#(8, Reg#(Bool)) bank_ce_q <- replicateM(mkReg(False));
    Vector#(8, Reg#(Bool)) bank_dout_en_q <- replicateM(mkReg(False));
    Reg#(Bool) bank_we_q <- mkReg(False);
    Reg#(Bit#(64)) bank_din_q <- mkReg(0);
    Reg#(Bit#(64)) bank_bwe_q <- mkReg(0);
    Wire#(Vector#(8, Bool)) bank_ce_pulse_w <- mkDWire(replicate(False));
    Wire#(Vector#(8, Bool)) bank_dout_en_pulse_w <- mkDWire(replicate(False));
    Wire#(Bit#(17)) bank_addr_w <- mkDWire(0);
    Wire#(Bool) bank_we_w <- mkDWire(False);
    Wire#(Bit#(64)) bank_din_w <- mkDWire(0);
    Wire#(Bit#(64)) bank_bwe_w <- mkDWire(0);

    Wire#(Bit#(128)) mram_dout_w <- mkDWire(0);
    Reg#(Bit#(8)) mram_busy_q <- mkMramBusyNegedgeReg(bank_clk, bank_reset);
    Wire#(Bool) mram_ready_w <- mkDWire(False);
    Wire#(Bool) mram_pwr_ok_w <- mkDWire(False);
    Wire#(Bool) mram_maintenance_w <- mkDWire(False);
    Wire#(Bit#(2)) mram_ecc_w <- mkDWire(0);

    Vector#(8, Reg#(Bool)) write_busy_buf <- replicateM(mkReg(False));
    Vector#(8, Reg#(Bool)) write_busy_hold_q <- replicateM(mkReg(False));
    Vector#(ReadBusyStages, Reg#(Bit#(4))) read_pair_busy_s <- replicateM(mkReg(0));
    Vector#(ReadBlocksWriteStages, Reg#(Bit#(4))) read_pair_blocks_write_s <- replicateM(mkReg(0));
    Reg#(Bit#(4)) rmw_pair_atomic_busy <- mkReg(0);
    Reg#(Bit#(4)) rmw_pair_write_phase <- mkReg(0);
    Wire#(Bit#(4)) launched_read_pair_busy_w <- mkDWire(0);
    Wire#(Bit#(4)) launched_rmw_pair_busy_w <- mkDWire(0);
    Wire#(Bit#(4)) issued_rmw_write_pair_busy_w <- mkDWire(0);
    Wire#(Bit#(4)) issued_write_pair_busy_w <- mkDWire(0);

    Wire#(Bool) rsp_deq_w <- mkDWire(False);
    Wire#(Bool) rsp_slot_reserve_w <- mkDWire(False);
    Reg#(UInt#(TLog#(TAdd#(RspQueueDepth, 1)))) rsp_slots_used <- mkReg(0);
    Wire#(Bit#(8)) launched_write_mask_w <- mkDWire(0);

    rule update_read_pair_busy;
        for (Integer stage = 1; stage < valueOf(ReadBusyStages); stage = stage + 1)
            read_pair_busy_s[stage] <= read_pair_busy_s[stage - 1];
        read_pair_busy_s[0] <= launched_read_pair_busy_w;

        for (Integer stage = 1; stage < valueOf(ReadBlocksWriteStages); stage = stage + 1)
            read_pair_blocks_write_s[stage] <= read_pair_blocks_write_s[stage - 1];
        read_pair_blocks_write_s[0] <= launched_read_pair_busy_w;
    endrule

    // Writes need an early busy sequence because the command is registered
    // before the MRAM sees CE, and MRAM busy rises after that launch and is
    // sampled on the bank clock's falling edge. Each launched write always
    // takes these ordered steps:
    //   1. assert local early busy when the translator issues the write
    //   2. keep local busy high while the registered CE reaches the MRAM
    //   3. hold local busy high for one more cycle after the MRAM CE cycle
    //   4. track the sampled MRAM busy signal
    // Reads do not use mram_busy_q at all; they are tracked by the fixed
    // read-pair stage counter above.
    rule update_write_busy;
        Vector#(8, Bool) mram_busy = unpack(mram_busy_q);
        for (Integer inst = 0; inst < 8; inst = inst + 1) begin
            Bool launched = launched_write_mask_w[inst] == 1'b1;
            Bool registered_ce = launched_write_mask_q[inst];
            Bool hold = write_busy_hold_q[inst];
            Bool raw_busy = mram_busy[inst];
            Bool busy = write_busy_buf[inst];
            Bool next_busy = False;
            Bool next_hold = False;

            if (launched) begin
                next_busy = True;
            end else if (registered_ce) begin
                next_busy = True;
                next_hold = True;
            end else if (hold) begin
                next_busy = True;
            end else if (busy) begin
                next_busy = raw_busy;
            end

            write_busy_buf[inst] <= next_busy;
            write_busy_hold_q[inst] <= next_hold;
        end
    endrule

    rule update_rmw_pair_atomic_busy;
        Bit#(4) next_busy = rmw_pair_atomic_busy;
        Bit#(4) next_write_phase = rmw_pair_write_phase;
        Vector#(8, Bool) mram_busy = unpack(mram_busy_q);

        if (launched_rmw_pair_busy_w != 0) begin
            next_busy = next_busy | launched_rmw_pair_busy_w;
            next_write_phase = next_write_phase & ~launched_rmw_pair_busy_w;
        end

        if (issued_rmw_write_pair_busy_w != 0) begin
            next_busy = next_busy | issued_rmw_write_pair_busy_w;
            next_write_phase = next_write_phase | issued_rmw_write_pair_busy_w;
        end

        for (Integer pair = 0; pair < 4; pair = pair + 1) begin
            if (next_write_phase[pair] == 1'b1) begin
                Integer lo = pair * 2;
                Integer hi = lo + 1;
                Bool write_active =
                    write_busy_buf[lo] ||
                    write_busy_buf[hi] ||
                    mram_busy[lo] ||
                    mram_busy[hi] ||
                    (launched_write_mask_w[lo] == 1'b1) ||
                    (launched_write_mask_w[hi] == 1'b1) ||
                    (launched_write_mask_q[lo]) ||
                    (launched_write_mask_q[hi]) ;
                if (!write_active) begin
                    next_busy[pair] = 1'b0;
                    next_write_phase[pair] = 1'b0;
                end
            end
        end

        rmw_pair_atomic_busy <= next_busy;
        rmw_pair_write_phase <= next_write_phase;
    endrule

    rule update_rsp_slots_used;
        UInt#(3) used = rsp_slots_used;

        if (rsp_slot_reserve_w)
            used = used + 1;

        if (rsp_deq_w)
            used = used - 1;

        rsp_slots_used <= used;
    endrule

    rule register_bank_pulses;
        writeVReg(bank_ce_q, bank_ce_pulse_w);
        writeVReg(bank_dout_en_q, bank_dout_en_pulse_w);
    endrule

    rule register_bank_command;
        bank_addr_q <= bank_addr_w;
        bank_we_q <= bank_we_w;
        bank_din_q <= bank_din_w;
        bank_bwe_q <= bank_bwe_w;
        writeVReg(launched_write_mask_q, unpack(launched_write_mask_w));
    endrule

    rule issue_write_cmd(
        write_req_q.notEmpty &&
        !ceWriteBusy(write_busy_buf, write_req_q.first.ce) &&
        !ceReadBusy(foldPairBusy(readVReg(read_pair_blocks_write_s)), write_req_q.first.ce) &&
        !ceRmwBusy(rmw_pair_atomic_busy, write_req_q.first.ce)
    );
        let cmd = write_req_q.first;
        write_req_q.deq;
        driveWriteCmd(
            bank_addr_w,
            bank_ce_pulse_w,
            bank_we_w,
            bank_din_w,
            bank_bwe_w,
            launched_write_mask_w,
            cmd
        );
        issued_write_pair_busy_w <= cePairMask(cmd.ce);
    endrule

    rule issue_rmw_write_cmd(
        !write_req_q.notEmpty &&
        rmw_write_q.notEmpty &&
        !ceWriteBusy(write_busy_buf, rmw_write_q.first.ce) &&
        !ceReadBusy(foldPairBusy(readVReg(read_pair_blocks_write_s)), rmw_write_q.first.ce)
    );
        let cmd = rmw_write_q.first;
        rmw_write_q.deq;
        driveWriteCmd(
            bank_addr_w,
            bank_ce_pulse_w,
            bank_we_w,
            bank_din_w,
            bank_bwe_w,
            launched_write_mask_w,
            cmd
        );
        issued_write_pair_busy_w <= cePairMask(cmd.ce);
        issued_rmw_write_pair_busy_w <= cePairMask(cmd.ce);
    endrule

    for (Integer stage = 0; stage < valueOf(ReadLaunchStages) - 1; stage = stage + 1) begin
        rule advance_launch_pipe(launch_pipe[stage].notEmpty && launch_pipe[stage + 1].notFull);
            let tx = launch_pipe[stage].first;
            launch_pipe[stage].deq;
            launch_pipe[stage + 1].enq(tx);
        endrule
    end

    for (Integer stage = 0; stage < valueOf(ReadCaptureStages) - 1; stage = stage + 1) begin
        rule advance_capture_pipe(capture_pipe[stage].notEmpty && capture_pipe[stage + 1].notFull);
            let tx = capture_pipe[stage].first;
            capture_pipe[stage].deq;
            capture_pipe[stage + 1].enq(tx);
        endrule
    end

    rule launch_rmw_read_cmd(
        !write_req_q.notEmpty &&
        !rmw_write_q.notEmpty &&
        rmw_req_q.notEmpty &&
        launch_pipe[0].notFull &&
        !pairReadBusy(foldPairBusy(readVReg(read_pair_busy_s)), rmw_req_q.first.inst[2:1]) &&
        !pairWriteBusy(write_busy_buf, rmw_req_q.first.inst[2:1]) &&
        !pairWriteIssued(issued_write_pair_busy_w, rmw_req_q.first.inst[2:1]) &&
        !pairRmwBusy(rmw_pair_atomic_busy, rmw_req_q.first.inst[2:1])
    );
        let req = rmw_req_q.first;
        rmw_req_q.deq;
        bank_addr_w <= req.addr;
        bank_ce_pulse_w <= pairCe(req.inst[2:1]);
        launched_read_pair_busy_w <= pairBit(req.inst[2:1]);
        launched_rmw_pair_busy_w <= pairBit(req.inst[2:1]);
        launch_pipe[0].enq(MramBankReadTxn {
            pair: req.inst[2:1],
            is_rmw: True,
            inst: req.inst,
            addr: req.addr,
            data: req.data,
            strb: req.strb
        });
    endrule

    rule launch_read_cmd(
        !write_req_q.notEmpty &&
        !rmw_write_q.notEmpty &&
        !rmw_req_q.notEmpty &&
        read_req_q.notEmpty &&
        launch_pipe[0].notFull &&
        !pairReadBusy(foldPairBusy(readVReg(read_pair_busy_s)), read_req_q.first.pair) &&
        !pairWriteBusy(write_busy_buf, read_req_q.first.pair) &&
        !pairWriteIssued(issued_write_pair_busy_w, read_req_q.first.pair) &&
        !pairRmwBusy(rmw_pair_atomic_busy, read_req_q.first.pair)
    );
        let req = read_req_q.first;
        read_req_q.deq;
        bank_addr_w <= req.addr;
        bank_ce_pulse_w <= pairCe(req.pair);
        launched_read_pair_busy_w <= pairBit(req.pair);
        launch_pipe[0].enq(MramBankReadTxn {
            pair: req.pair,
            is_rmw: False,
            inst: {req.pair, 1'b0},
            addr: req.addr,
            data: 0,
            strb: 0
        });
    endrule

    rule issue_dout_en(
        launch_pipe[valueOf(ReadLaunchStages) - 1].notEmpty &&
        capture_pipe[0].notFull &&
        (readTxnNeedsRspSlot(launch_pipe[valueOf(ReadLaunchStages) - 1].first)
            ? ((rsp_slots_used < fromInteger(valueOf(RspQueueDepth))) || rsp_deq_w)
            : True)
    );
        let tx = launch_pipe[valueOf(ReadLaunchStages) - 1].first;
        launch_pipe[valueOf(ReadLaunchStages) - 1].deq;
        bank_dout_en_pulse_w <= pairCe(tx.pair);
        if (readTxnNeedsRspSlot(tx))
            rsp_slot_reserve_w <= True;
        capture_pipe[0].enq(tx);
    endrule

    rule capture_read_rsp(
        capture_pipe[valueOf(ReadCaptureStages) - 1].notEmpty &&
        readTxnSinkReady(
            capture_pipe[valueOf(ReadCaptureStages) - 1].first,
            rsp_q.notFull,
            rmw_write_q.notFull
        )
    );
        let tx = capture_pipe[valueOf(ReadCaptureStages) - 1].first;
        capture_pipe[valueOf(ReadCaptureStages) - 1].deq;
        if (readTxnIsRmw(tx)) begin
            Bool upper = tx.inst[0] == 1;
            Bit#(64) old_data = upper ? mram_dout_w[127:64] : mram_dout_w[63:0];
            Bit#(64) merged = mergeWriteBytes(tx.data, old_data, tx.strb);
            rmw_write_q.enq(MramBankWriteCmd {
                addr: tx.addr,
                ce: instCe(tx.inst),
                we: True,
                din: merged,
                bwe: 64'hFFFF_FFFF_FFFF_FFFF
            });
        end else if (readTxnIsReadOnly(tx)) begin
            rsp_q.enq(MramBankReadRsp {
                addr: tx.addr,
                pair: tx.pair,
                data: mram_dout_w,
                ecc: mram_ecc_w
            });
        end
    endrule

    interface MRAM_Bank_IFC mram;
        method Action get_dout(Bit#(128) dout_i);
            mram_dout_w <= dout_i;
        endmethod
        method Action get_busy(Vector#(8, Bool) busy_i);
            mram_busy_q <= pack(busy_i);
        endmethod
        method Action get_ready(Bool ready_i);
            mram_ready_w <= ready_i;
        endmethod
        method Action get_pwr_ok(Bool pwr_ok_i);
            mram_pwr_ok_w <= pwr_ok_i;
        endmethod
        method Action get_maintenance(Bool maintenance_i);
            mram_maintenance_w <= maintenance_i;
        endmethod
        method Action get_ecc_triple_error(Bit#(2) ecc_triple_error_i);
            mram_ecc_w <= ecc_triple_error_i;
        endmethod
        method Reset rst_bo = bank_reset;
        method Clock clk_o = bank_clk;
        method Vector#(8, Bool) ce_o = readVReg(bank_ce_q);
        method Vector#(8, Bool) dout_en_o = readVReg(bank_dout_en_q);
        method Bool we_o = bank_we_q;
        method Bit#(17) addr_o = bank_addr_q;
        method Bit#(64) din_o = bank_din_q;
        method Bit#(64) bwe_o = bank_bwe_q;
    endinterface

    method Bool readReqNotFull = read_req_q.notFull;

    method Bool readReqReady(Bit#(2) pair) =
        read_req_q.notFull &&
        !pairReadBusy(foldPairBusy(readVReg(read_pair_busy_s)), pair) &&
        !pairWriteBusy(write_busy_buf, pair) &&
        !pairWriteIssued(issued_write_pair_busy_w, pair) &&
        !pairRmwBusy(rmw_pair_atomic_busy, pair);

    method Action enqReadReq(MramBankReadReq req) if (read_req_q.notFull);
        read_req_q.enq(req);
    endmethod

    method Bool rmwReqNotFull = rmw_req_q.notFull;

    method Bool rmwReqReady(Bit#(3) inst) =
        rmw_req_q.notFull &&
        !pairReadBusy(foldPairBusy(readVReg(read_pair_busy_s)), inst[2:1]) &&
        !pairWriteBusy(write_busy_buf, inst[2:1]) &&
        !pairWriteIssued(issued_write_pair_busy_w, inst[2:1]) &&
        !pairRmwBusy(rmw_pair_atomic_busy, inst[2:1]);

    method Action enqRmwReq(MramBankRmwReq req) if (rmw_req_q.notFull);
        rmw_req_q.enq(req);
    endmethod

    method Bool writeReqReady(Vector#(8, Bool) ce) =
        write_req_q.notFull &&
        !ceWriteBusy(write_busy_buf, ce) &&
        !ceReadBusy(foldPairBusy(readVReg(read_pair_blocks_write_s)), ce) &&
        !ceRmwBusy(rmw_pair_atomic_busy, ce);

    method Action issueWrite(MramBankWriteCmd cmd) if (write_req_q.notFull);
        write_req_q.enq(cmd);
    endmethod

    method Bool rspNotEmpty = rsp_q.notEmpty;
    method MramBankReadRsp rspFirst = rsp_q.first;
    method Action rspDeq if (rsp_q.notEmpty);
        rsp_deq_w <= True;
        rsp_q.deq;
    endmethod

    method Bool ready = mram_ready_w;
    method Bool pwrOk = mram_pwr_ok_w;
    method Bool maintenance = mram_maintenance_w;
    method Vector#(8, Bool) busy = unpack(mram_busy_q);
    method Vector#(8, Bool) trackedBusy = trackedBusyWithRmw(readVReg(write_busy_buf), rmw_pair_atomic_busy);
    method Bit#(4) outstandingReadPairs = foldPairBusy(readVReg(read_pair_busy_s));
endmodule

endpackage
