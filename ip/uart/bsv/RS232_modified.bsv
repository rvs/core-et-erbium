/*Copyright (c) 2018, IIT Madras All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of IIT Madras nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------------------------
*/
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2010  Bluespec, Inc.   ALL RIGHTS RESERVED.
////////////////////////////////////////////////////////////////////////////////
//  Filename      : RS232.bsv
//  Description   : Simple UART BFM   RS232 <-> Bit#(8)
////////////////////////////////////////////////////////////////////////////////
package RS232_modified;

// Notes :

////////////////////////////////////////////////////////////////////////////////
/// Imports
////////////////////////////////////////////////////////////////////////////////
import Clocks ::*;
import GetPut ::*;
import Connectable ::*;
`ifdef async_rst
   import FIFOLevel_Modified ::*;
`else
   import FIFOLevel ::*;
`endif
import Vector ::*;
import BUtils ::*;
import Counter ::*;
import ConcatReg ::*;
import ConfigReg ::*;

////////////////////////////////////////////////////////////////////////////////
/// Exports
////////////////////////////////////////////////////////////////////////////////
export RS232 (..);
export UART (..);
export BaudGenerator (..);
export Parity (..);
export StopBits (..);
export InputFilter (..);
export Synchronizer (..);
export EdgeDetector (..);
export InputMovingFilter (..);
export mkUART;
export mkBaudGenerator;
export mkInputFilter;
export mkSynchronizer;
export mkEdgeDetector;
export mkInputMovingFilter;

////////////////////////////////////////////////////////////////////////////////
/// Types
////////////////////////////////////////////////////////////////////////////////
typedef union tagged {
void Start;
void Center;
void Wait;
void Sample;
void Parity;
void StopFirst;
void StopLast;
} RecvState deriving (Bits, Eq);

typedef union tagged {
void Idle;
void Delay;
void Start;
void Wait;
void Shift;
void Stop;
void Stop5;
void Stop2;
void Parity;
} XmitState deriving (Bits, Eq, FShow);

typedef enum {
NONE,
ODD,
EVEN
} Parity deriving (Bits, Eq);

typedef enum {
STOP_1,
STOP_1_5,
STOP_2
} StopBits deriving (Bits, Eq);

////////////////////////////////////////////////////////////////////////////////
/// Interfaces
////////////////////////////////////////////////////////////////////////////////
`ifndef uart_clk_gate_en
   (*always_ready,always_enabled*)
`endif
/* Contains the definitions of all physical pins expected from our implementation */
interface RS232;
   // Inputs
   (* prefix = "" *)
   method Action sin((* port = "SIN" *)Bit#(1) x);
   `ifdef uart_modem
      (* prefix = "" *)
      method Action cts((* port = "CTS" *)Bit#(1) x);
      (* prefix = "" *)
      method Action dsr((* port = "DSR" *)Bit#(1) x);
      (* prefix = "" *)
      method Action ri((* port = "RI" *)Bit#(1) x);
      (* prefix = "" *)
      method Action dcd((* port = "DCD" *)Bit#(1) x);
   `endif
   // Outputs
   (* prefix = "", result = "SOUT" *)
   method Bit#(1) sout();
   (* prefix = "", result = "SOUT_EN" *)
   method Bit#(1) sout_en();
   `ifdef uart_modem
      (* prefix = "", result = "DTR" *)
      method Bit#(1) dtr();
      (* prefix = "", result = "RTS" *)
      method Bit#(1) rts();
      (* prefix = "", result = "OUT1" *)
      method Bit#(1) out1();
      (* prefix = "", result = "OUT2" *)
      method Bit#(1) out2();
   `endif
   (* prefix = "", result = "DMA_RDY" *)
   method Bit#(2) dma_ready;
endinterface
/* Contains the definitions of all methods for the workin of a Baud genarator. */
interface BaudGenerator;
   method Action clock_enable();
   method Action clear();
   method Bool baud_tick_16x();
   method Bool baud_tick_2x();
endinterface

interface InputFilter#(numeric type size, type a);
   method Action clock_enable();
   method a _read();
endinterface

(* always_ready, always_enabled *)
interface EdgeDetector#(type a);
   method Bool rising();
   method Bool falling();
endinterface

(* always_ready, always_enabled *)
interface Synchronizer#(type a);
   method Action _write(a x);
   method a _read();
endinterface

interface InputMovingFilter#(numeric type width, numeric type threshold, type a);
   method Action sample();
   method Action clear();
   method a _read();
endinterface
/*Contains the methods for various UART functionality used in UART Top Module */
interface UART#(numeric type depth);
   (* prefix = "" *)
   interface RS232 rs232;
   interface Get#(Bit#(32)) tx;
   interface Put#(Bit#(32)) rx;
   `ifdef uart_modem
      (* always_ready, always_enabled *)
      method Action transmittor_clear;
      (* always_ready, always_enabled *)
      method Action receiver_clear;
   `endif
   (* always_ready, always_enabled *)
   method Bool receiver_not_empty;
   (* always_ready, always_enabled *)
   method Bool receiver_full;
   (* always_ready, always_enabled *)
   method Bool transmittor_full;
   (* always_ready, always_enabled *)
   method Bool transmittor_empty;
   (* always_ready, always_enabled *)
   method Bit#(1) error_status;
   (* always_ready, always_enabled *)
   method Maybe#(Bit#(4)) new_error_bits;
   (* always_ready, always_enabled *)
   `ifdef uart_modem
      method Bit#(8) modem_status;
   `endif
   `ifdef uart_modem
      method Action clear_status(Bit#(12) clear_bits);
   `else
      method Action clear_status(Bit#(5) clear_bits);
   `endif
   (* always_ready, always_enabled *)
   method Action rx_threshold (UInt#((TLog#(TAdd#(depth,1)))) val);
endinterface

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of Baud Generator
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module mkBaudGenerator#(Bit#(16) divider)(BaudGenerator);

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   Counter#(16) rBaudCounter <- mkCounter(0);
   PulseWire pwBaudTick16x <- mkPulseWire;

   Counter#(3) rBaudTickCounter <- mkCounter(0);
   PulseWire pwBaudTick2x <- mkPulseWire;

   Wire#(Bit#(16)) wBaudCount <- mkWire;
   /* Keeps track of the Baud Generator Count */
   rule baud_count_wire;
      wBaudCount <= rBaudCounter.value;
   endrule
   Wire#(Bit#(3)) wBaudTickCount <- mkWire;
   /* Keeps track of the Baud Generator Tick Count */
   rule baud_tick_count_wire;
      wBaudTickCount <= rBaudTickCounter.value;
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Rules
   ////////////////////////////////////////////////////////////////////////////////
   /* Increments the Baud Generator Tick Count */
   rule count_baudtick_16x(pwBaudTick16x);
      rBaudTickCounter.up;
   endrule
   rule assert_2x_baud_tick(rBaudTickCounter.value() == 0 && pwBaudTick16x);
      pwBaudTick2x.send;
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   method Action clock_enable();
   if (rBaudCounter.value() + 1 >= divider) begin
         pwBaudTick16x.send;
         rBaudCounter.clear;
      end
      else begin
         rBaudCounter.up;
      end
endmethod

   method Action clear();
   rBaudCounter.clear;
endmethod

   method Bool baud_tick_16x();
   return pwBaudTick16x;
endmethod

   method Bool baud_tick_2x();
   return pwBaudTick2x;
endmethod

endmodule: mkBaudGenerator

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of Input Filter
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module mkInputFilter#(a initval, a din)(InputFilter#(size, a))
   provisos( Bits#(a, sa)
   , Eq#(a)
   , Add#(0, sa, 1)
   , Log#(size, logsize)
   , Add#(logsize, 1, csize)
);

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   Counter#(csize) counter <- mkCounter(0);
   Reg#(a) rOut <- mkRegA(initval);

   ////////////////////////////////////////////////////////////////////////////////
   /// Rules
   ////////////////////////////////////////////////////////////////////////////////

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   method Action clock_enable();
   if (din == unpack(1) && counter.value() != fromInteger(valueof(size)))
      counter.up;
      else if (din == unpack(0) && counter.value() != 0)
         counter.down;

   if (counter.value() == fromInteger(valueof(size)))
      rOut <= unpack(1);
      else if (counter.value() == 0)
         rOut <= unpack(0);
endmethod

   method a _read;
   return rOut;
endmethod

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module mkEdgeDetector#(a initval, a din)(EdgeDetector#(a))
   provisos( Bits#(a, sa)
   , Eq#(a)
   , Add#(0, sa, 1)
);

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   Reg#(a) rDinD1 <- mkRegA(initval);

   ////////////////////////////////////////////////////////////////////////////////
   /// Rules
   ////////////////////////////////////////////////////////////////////////////////
   (* fire_when_enabled *)
   (* no_implicit_conditions *)
   rule pipeline;
      rDinD1 <= din;
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   method Bool rising();
   return (din == unpack(1) && rDinD1 == unpack(0));
endmethod

   method Bool falling();
   return (din == unpack(0) && rDinD1 == unpack(1));
endmethod

endmodule: mkEdgeDetector

////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////
function Bool getRising(EdgeDetector#(a) ifc);
   return ifc.rising;
endfunction

function Bool getFalling(EdgeDetector#(a) ifc);
   return ifc.falling;
endfunction

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of Synchronizer
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module mkSynchronizer#(a initval)(Synchronizer#(a))
   provisos( Bits#(a, sa)
   , Add#(0, sa, 1)
);

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   Reg#(a) d1 <- mkRegA(initval);
   Reg#(a) d2 <- mkRegA(initval);

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   method Action _write(x);
   d1 <= x;
   d2 <= d1;
endmethod

   method a _read();
   return d2;
endmethod

endmodule: mkSynchronizer

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of Input Filter
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module mkInputMovingFilter#(a din)(InputMovingFilter#(width, threshold, a))
   provisos( Bits#(a, sa)
   , Eq#(a)
   , Add#(0, sa, 1)
);

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   Counter#(width) counter <- mkCounter(0);
   Reg#(a) rOut <- mkRegA(unpack(0));
   PulseWire pwSample <- mkPulseWire;

   ////////////////////////////////////////////////////////////////////////////////
   /// Rules
   ////////////////////////////////////////////////////////////////////////////////
   (* preempts = "threshold_compare, take_sample" *)
   rule threshold_compare(counter.value() >= fromInteger(valueof(threshold)));
      rOut <= unpack(1);
   endrule

   rule take_sample(pwSample && din == unpack(1));
      counter.up;
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   method Action sample();
   pwSample.send;
endmethod

   method Action clear();
   counter.clear();
   rOut <= unpack(0);
endmethod

   method a _read;
   return rOut;
endmethod

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of UART
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/* Takes care of all the functionality of an UART */
module mkUART( `ifdef uart_modem Reg#(Bit#(1)) auto_rts
      , Reg#(Bit#(5)) modemctrl
      , `endif
   Bit#(6) charsize
   , Parity paritysel
   , StopBits stopbits
   , Bit#(16) divider
   , Bit#(16) delay_control
   `ifdef uart_modem , Bit#(1) stickparity `endif
   , UART#(d) ifc)
   provisos(Add#(2, _1, d));

   Integer fifodepth = valueof(d);
   //Integer fifoCount = fifodepth*4/5;
   Wire#(UInt#(TLog#(TAdd#(d,1)))) wr_fifoRTSCount <- mkWire();

   ////////////////////////////////////////////////////////////////////////////////
   /// Design Elements
   ////////////////////////////////////////////////////////////////////////////////
   let baudGen <- mkBaudGenerator( divider );

   ////////////////////////////////////////////////////////////////////////////////
   /// Receive UART
   ////////////////////////////////////////////////////////////////////////////////
   FIFOCountIfc#(Bit#(32), d) fifoRecv <- mkGFIFOCount(True, True, True);

   Vector#(32, Reg#(Bit#(1))) vrRecvBuffer <- replicateM(mkRegA(0));

   RWire#(Bit#(4)) rw_new_error_bits <- mkRWire;
   Reg#(Bit#(1)) fifo_almost_full <- mkRegA(0);
   Reg#(Bit#(1)) rRecvData <- mkConfigRegA(1);

   Reg#(RecvState) rRecvState <- mkRegA(Start);
   Reg#(Bit#(4)) rRecvCellCount <- mkRegA(0);
   Reg#(Bit#(6)) rRecvBitCount <- mkRegA(0);
   Reg#(Bit#(1)) rRecvParity <- mkRegA(0);
   Reg#(Bit#(16)) rg_delay_count <- mkRegA('d0);
   Reg#(Bit#(1)) out_enable <- mkRegA(0);

   PulseWire pwRecvShiftBuffer <- mkPulseWire;
   PulseWire pwRecvCellCountReset <- mkPulseWire;
   PulseWire pwRecvResetBitCount <- mkPulseWire;
   PulseWire pwRecvEnableBitCount <- mkPulseWire;

   ////////////////////////////////////////////////////////////////////////////////
   /// Transmit UART
   ////////////////////////////////////////////////////////////////////////////////
   FIFOCountIfc#(Bit#(32), d) fifoXmit <- mkGFIFOCount(True, False, True);

   Vector#(32, Reg#(Bit#(1))) vrXmitBuffer <- replicateM(mkRegU);

   Reg#(XmitState) rXmitState <- mkRegA(Idle);
   Reg#(Bit#(4)) rXmitCellCount <- mkRegA(0);
   Reg#(Bit#(6)) rXmitBitCount <- mkRegA(0);
   Reg#(Bit#(1)) rXmitDataOut <- mkRegA(1);
   Reg#(Bit#(1)) rXmitParity <- mkRegA(0);

   PulseWire pwXmitCellCountReset <- mkPulseWire;
   PulseWire pwXmitResetBitCount <- mkPulseWire;
   PulseWire pwXmitEnableBitCount <- mkPulseWire;
   PulseWire pwXmitLoadBuffer <- mkPulseWire;
   PulseWire pwXmitShiftBuffer <- mkPulseWire;
   `ifdef uart_modem
      Vector#(4,Reg#(Bit#(1))) vrModemBuffer_pins <- replicateM(mkRegA(1));
      Vector#(4,Reg#(Bit#(1))) vrModemBuffer_delta <- replicateM(mkRegA(0));
      Vector#(8, Reg#(Bit#(1))) vrModemBuffer <- replicateM(mkRegA(1));
      vrModemBuffer = append(vrModemBuffer_pins,vrModemBuffer_delta);
   `endif
   ////////////////////////////////////////////////////////////////////////////////
   /// Definitions
   ////////////////////////////////////////////////////////////////////////////////

   /* Creates a tick variable which gives the baud generator in 16x time speed for Receiver Timing */
   let tick = baudGen.baud_tick_16x;

   ////////////////////////////////////////////////////////////////////////////////
   /// Baud Clock Enable
   ////////////////////////////////////////////////////////////////////////////////
   // (* no_implicit_conditions, fire_when_enabled *)
   (* fire_when_enabled *)
   (* conflict_free = "receive_buffer_shift, receive_wait_for_start_bit" *)
   /* Enables the clock of the baud generator */
   rule baud_generator_clock_enable;
      baudGen.clock_enable;
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Receive Rules
   ////////////////////////////////////////////////////////////////////////////////
   /* Gets the Receiver Cell Count (16x the Baud Generator Clock value) reset and used to correctly sync all
   te bits to a perfect reception */
   rule receive_bit_cell_time_counter(tick);
      if (pwRecvCellCountReset)
         rRecvCellCount <= 0;
         else
         rRecvCellCount <= rRecvCellCount + 1;
   endrule
   /* Whenever this rule is called the bit currently in rRecvData (which has the receiver data through the method sin)
   and shifts it into a Vector Register called vrRecvBuffer */
   rule receive_buffer_shift(pwRecvShiftBuffer);
      let v = shiftInAtN(readVReg(vrRecvBuffer), rRecvData);
      writeVReg(vrRecvBuffer, v);
   endrule
   /* Counts the bits each time the rule was called, gets reset after stop bit is reached. */
   rule receive_bit_counter;
      if (pwRecvResetBitCount)
         rRecvBitCount <= 0;
         else if (pwRecvEnableBitCount)
            rRecvBitCount <= rRecvBitCount + 1;
   endrule
   /*Checks if the received bit is active low (since the start bit should be LOW) if yes proceeds further otherwise waits
   for a active low bit. It also executes only if CTS is active */
   rule receive_wait_for_start_bit(rRecvState == Start && tick `ifdef uart_modem && vrModemBuffer[3] == 1'b1 `endif );
      pwRecvCellCountReset.send();
      if (rRecvData == 1'b0) begin
            rRecvState <= Center;
            writeVReg(vrRecvBuffer, replicate(0));
         end
         else begin
            rRecvState <= Start;
            pwRecvResetBitCount.send();
         end
   endrule
   /* We start checking the Center the Bit from the Start Bit and thus in all the following bits
   This is done so that we can be sure if we are reading the right bit and not any noise/disturbance */
   rule receive_find_center_of_bit_cell(rRecvState == Center && tick);
      if (rRecvCellCount == 4'h4) begin
            pwRecvCellCountReset.send();
            if (rRecvData == 1'b0)
               rRecvState <= Wait;
               else
               rRecvState <= Start;
         end
         else begin
            rRecvState <= Center;
         end
   endrule
   /* After a bit is received as expected it is checked if the upcoming bit is the Stop Bit/Parity Bit. If yes
   then it is sent to the appropriate stage based on the bit count if no the data is shifted into the buffer.*/
   rule receive_wait_bit_cell_time_for_sample(rRecvState == Wait && rRecvCellCount == 4'hF && tick);
      pwRecvCellCountReset.send;

      if (rRecvBitCount == charsize) begin
            if (paritysel != NONE)
               rRecvState <= Parity;
               else if (stopbits != STOP_1)
                  rRecvState <= StopFirst;
                  else
                  rRecvState <= StopLast;
         end
         else if (rRecvBitCount == charsize + 1) begin
               if (paritysel == NONE || stopbits == STOP_1)
                  rRecvState <= StopLast;
                  else
                  rRecvState <= StopFirst;
            end
            else if (rRecvBitCount == charsize + 2) begin
                  rRecvState <= StopLast;
               end
               else begin
                  rRecvState <= Sample;
               end
   endrule
   /* Calls the rules expected to shift the bit data for vector register and incrementing the bit count. */
   rule receive_sample_pin(rRecvState == Sample && tick);
      pwRecvShiftBuffer.send;
      pwRecvEnableBitCount.send;
      //pwRecvCellCountReset.send;                   ///////////////////////////////
      rRecvState <= Wait;
   endrule
   /* Get the Parity bit and store it into rRecvParity for future purpose, also increment the bit count */
   rule receive_parity_bit(rRecvState == Parity && tick);
      rRecvParity <= rRecvData;
      pwRecvEnableBitCount.send;
      //pwRecvCellCountReset.send;                   ///////////////////////////
      rRecvState <= Wait;
   endrule
   /* If the Stop bit is 1 bits and if it is not correct then move to Start otherwise go to the StopLast through Wait*/
   rule receive_stop_first_bit(rRecvState == StopFirst && tick);
      pwRecvEnableBitCount.send;
      //pwRecvCellCountReset.send;                  /////////////////////////
      if (rRecvData == 1)
         rRecvState <= Wait;
         else
         rRecvState <= Start;
   endrule
   /* This rule is fired if 2 bits StopBits are chosen or 1 bit Stop Bit is completed
   The Parity is checked, all the errors are checked and in case any error is present it is updated to the status
   register */
   rule receive_stop_last_bit(rRecvState == StopLast && tick);
      Vector#(32, Bit#(1)) data = take(readVReg(vrRecvBuffer));
      Bit#(32) bitdata = pack(data);

      Bit#(1) data_parity= ^({rRecvParity, bitdata});
      Bit#(1) parity_error= 0;
      Bit#(1) overrun= 0;
      Bit#(1) break_error= 0;
      Bit#(1) frame_error= 0;

      if (paritysel==ODD && data_parity==0)
         parity_error= 1;
         else if (paritysel==EVEN && data_parity==1)
            parity_error= 1;

      if (!fifoRecv.notFull)
         overrun= 1;

      if (bitdata==0 && rRecvData==0)  //data is 0, and STOP_BIT is also 0
         break_error= 1;

      if (rRecvData==0)  //If STOP bit is 0
         frame_error= 1;

      fifoRecv.enq(bitdata);
      rRecvState <= Start;
      //pwRecvCellCountReset.send;                ///////////////////////////

      rw_new_error_bits.wset({break_error, frame_error, overrun, parity_error});
   endrule
   /* Checks if the FIFO reached threshold and updates in the Status Register */
   (*fire_when_enabled*)
   rule rl_update_fifo_almost_full;
      let curr_fifo_elements= fifoRecv.count;
      if (curr_fifo_elements>=wr_fifoRTSCount) begin
            fifo_almost_full <= 1;
         end
   endrule
   `ifdef uart_modem
      /* If Auto RTS is active and FIFO reached threshold then deactivate the RTS */
      rule rl_auto_rts(fifo_almost_full == 1'b1 && auto_rts ==1'b1);
         modemctrl[3] <= 1'b0;
      endrule
   `endif
   ////////////////////////////////////////////////////////////////////////////////
   /// Transmit Rules
   ////////////////////////////////////////////////////////////////////////////////
   /* */
   rule transmit_bit_cell_time_counter(tick);
      if (pwXmitCellCountReset)
         rXmitCellCount <= 0;
         else
         rXmitCellCount <= rXmitCellCount + 1;
   endrule
   /* Counts the bits each time the rule was called, gets reset after stop bit is reached. */
   rule transmit_bit_counter;
      if (pwXmitResetBitCount)
         rXmitBitCount <= 0;
         else if (pwXmitEnableBitCount)
            rXmitBitCount <= rXmitBitCount + 1;
   endrule
   /* Whenever this rule is called the data in XmitFIFO is read and put into a Vector Register called vrXmitBuffer also sets the Parity to a variable called rXmitParity*/
   rule transmit_buffer_load(pwXmitLoadBuffer);
      Bit#(32) data = pack(fifoXmit.first);
      fifoXmit.deq;
      writeVReg(vrXmitBuffer, unpack(data));
      rXmitParity <= parity(data);
   endrule
   /* Whenever this rule is called the vrXmitBuffer is shifted and the specific bit is stored in a variable called v */
   rule transmit_buffer_shift(!pwXmitLoadBuffer && pwXmitShiftBuffer);
      let v = shiftInAtN(readVReg(vrXmitBuffer), 1);
      writeVReg(vrXmitBuffer, v);
   endrule
   /* Sets the transmitted bit as active high and runs the rule to count the cells and to send the Start Bit It also
   executes only if RTS is active */
   rule transmit_wait_for_start_command(rXmitState == Idle && tick `ifdef uart_modem && modemctrl[3] == 1'b1 `endif );
      rXmitDataOut <= 1'b1;
      pwXmitResetBitCount.send;
      if (fifoXmit.notEmpty) begin
            if (out_enable==1) begin
                  rXmitState <= Start;
                  pwXmitCellCountReset.send;
                  pwXmitLoadBuffer.send;
               end
               else begin
                  rXmitState <= Delay;
               end
            rg_delay_count <= 0;
         end
         else begin
            rXmitState <= Idle;
            if (rg_delay_count == delay_control) begin
                  rg_delay_count <= 0;
                  out_enable <= 0;
               end
               else if (out_enable == 1) begin
                     rg_delay_count <= rg_delay_count + 1;
                  end
         end
   endrule
   /* If Delay Register has some value hold the transmission for some time */
   rule rl_delay_control(rXmitState == Delay && tick);
      out_enable <= 1;
      pwXmitResetBitCount.send;
      if (rg_delay_count == delay_control) begin
            pwXmitCellCountReset.send;
            pwXmitLoadBuffer.send;
            rXmitState <= Start;
            //rg_delay_count<= 0;
         end
         else begin
            rg_delay_count <= rg_delay_count + 1;
         end
   endrule
   /* Sends te start bit for one full duration of a bit. */
   rule transmit_send_start_bit(rXmitState == Start && tick);
      rXmitDataOut <= 1'b0;
      rg_delay_count <= 0;
      if (rXmitCellCount == 4'hF) begin
            rXmitState <= Wait;
            pwXmitCellCountReset.send;
         end
         else begin
            rXmitState <= Start;
         end
   endrule
   /* After a bit is sent it is checked if the upcoming bit is the Stop Bit/Parity Bit. If yes
   then it is sent to the appropriate stage based on the bit count if no the data in the buffer is shifted out. */
   rule transmit_wait_1_bit_cell_time(rXmitState == Wait && tick);
      rXmitDataOut <= head(readVReg(vrXmitBuffer));
      if (rXmitCellCount == 4'hF) begin
            pwXmitCellCountReset.send;
            if (rXmitBitCount == (charsize - 1) && (paritysel == NONE)) begin
                  rXmitState <= Stop;
               end
               else if (rXmitBitCount == (charsize - 1) && (paritysel != NONE)) begin
                     rXmitState <= Parity;
                  end
                  else begin
                     rXmitState <= Shift;
                     pwXmitEnableBitCount.send;
                  end
         end
         else begin
            rXmitState <= Wait;
         end
   endrule
   /* Shifts out the data in the buffer bit by bit */
   rule transmit_shift_next_bit(rXmitState == Shift && tick);
      rXmitDataOut <= head(readVReg(vrXmitBuffer));
      rXmitState <= Wait;
      pwXmitShiftBuffer.send;
   endrule
   /* Sends out the parity bit if stick parity is disabled else sends out the default bit.*/
   rule transmit_send_parity_bit(rXmitState == Parity && tick);
      case (paritysel) matches
            `ifdef uart_modem
               ODD: rXmitDataOut <= (stickparity == 1'b1) ? 1'b1 : ~rXmitParity;  //////////////////////
            EVEN: rXmitDataOut <= (stickparity == 1'b1) ? 1'b0 : rXmitParity;  ///////////////////////
         `else
            ODD: rXmitDataOut <= ~rXmitParity;  //////////////////////
            EVEN: rXmitDataOut <= rXmitParity;  ///////////////////////
         `endif
         default: rXmitDataOut <= 1'b0;
      endcase

      if (rXmitCellCount == 4'hF) begin
            rXmitState <= Stop;
            pwXmitCellCountReset.send;
         end
         else begin
            rXmitState <= Parity;
         end
   endrule
   /* Sends out the 1 bit duration stop bit if 1 bit requested otherwise trigger 1.5 bits or 2 bits */
   rule transmit_send_stop_bit(rXmitState == Stop && tick);
      rXmitDataOut <= 1'b1;
      if (rXmitCellCount == 4'hF && (stopbits == STOP_1)) begin
            rXmitState <= Idle;
            pwXmitCellCountReset.send;
         end
         else if (rXmitCellCount == 4'hF && (stopbits == STOP_2)) begin
               rXmitState <= Stop2;
               pwXmitCellCountReset.send;
            end
            else if (rXmitCellCount == 4'hF && (stopbits == STOP_1_5)) begin
                  rXmitState <= Stop5;
                  pwXmitCellCountReset.send;
               end
               else begin
                  rXmitState <= Stop;
               end
   endrule
   /* Sends out the 1.5 bit duration stop bit */
   rule transmit_send_stop_bit1_5(rXmitState == Stop5 && tick);
      rXmitDataOut <= 1'b1;
      if (rXmitCellCount == 4'h7) begin
            rXmitState <= Idle;
            pwXmitCellCountReset.send;
         end
         else begin
            rXmitState <= Stop5;
         end
   endrule
   /* Sends out the 2 bit duration stop bit */
   rule transmit_send_stop_bit2(rXmitState == Stop2 && tick);
      rXmitDataOut <= 1'b1;
      if (rXmitCellCount == 4'hF) begin
            rXmitState <= Idle;
            pwXmitCellCountReset.send;
         end
         else begin
            rXmitState <= Stop2;
         end
   endrule

   ////////////////////////////////////////////////////////////////////////////////
   /// Interface Connections / Methods
   ////////////////////////////////////////////////////////////////////////////////
   interface RS232 rs232;
      /* Puts the transmitted bit (rXmitDataOut) to sout (port) */
      method sout = rXmitDataOut;
      /* Writes the received port (sin) to rRecvData */
      method sin = rRecvData._write;
      /* Puts the out_enable value to sout_en */
      method sout_en = out_enable;
      `ifdef uart_modem
         /* Incase CTS value changes update it to status register and updates the DCTS to 1 (In Vector Form) */
         method Action cts(Bit#(1) x);
         if (x != ~vrModemBuffer[3])
            begin
               vrModemBuffer[3] <= ~x;
               vrModemBuffer[7] <= 1'b1;
            end
      endmethod
         /* Incase DSR value changes update it to status register and updates te DDSR to 1 */
         method Action dsr(Bit#(1) x);
         if (x != ~vrModemBuffer[2])
            begin
               vrModemBuffer[2] <= ~x;
               vrModemBuffer[6] <= 1'b1;
            end
      endmethod
         /* Incase RI value chanes update it to status register and updates the TERI to 1 */
         method Action ri(Bit#(1) x);
         if (x != ~vrModemBuffer[1])
            begin
               vrModemBuffer[1] <= ~x;
               if (~vrModemBuffer[1] == 1 && x == 0)  //Trailing Edge
                  vrModemBuffer[5] <= 1'b1;
            end
      endmethod
         /* Incase DCD value changes update it to status register and updates the DDCD to 1 */
         method Action dcd(Bit#(1) x);
         if (x != ~vrModemBuffer[0])
            begin
               vrModemBuffer[0] <= ~x;
               vrModemBuffer[4] <= 1'b1;
            end
      endmethod
         /* Outputs DTR value from Control Register */
         method dtr = ~modemctrl[4];
         /* Outputs RTS value from Control Register */
         method rts = ~modemctrl[3];
         /* Outputs OUT1 value from Control Register */
         method out1 = ~modemctrl[2];
         /* Outputs OUT2 value from Control Register */
         method out2 = ~modemctrl[1];
      `endif
      method Bit#(2) dma_ready;
      return {pack(fifoRecv.count > 0), pack(fifoXmit.count <= 14)};
      //return {pack(fifoRecv.notEmpty), pack(fifoXmit.notFull)};
   endmethod
   endinterface
   /* If this method is called then the data from Receiver FIFO is returned. Thus,it is expected that the receiver FIFO as
   data by the time it is called(i.e., all the receiver rules are executed.) */
   interface Get tx;
      method ActionValue#(Bit#(32)) get;
      let data = pack(fifoRecv.first);
      fifoRecv.deq;
      return data;
   endmethod
   endinterface
   /* If this method is called then the data passed through the method is added to the Transmitter FIFO. After this is
   done all the transmitter rules is executed. */
   interface Put rx;
      method Action put(x);
      fifoXmit.enq(x);
   endmethod
   endinterface
   `ifdef uart_modem
      /* If this method is called then the data in the Transmitter FIFO is cleared. */
      method Action transmittor_clear();
      fifoXmit.clear;
   endmethod
      /* If this method is called then the data in the Receiver FIFO is cleared. */
      method Action receiver_clear();
      fifoRecv.clear;
   endmethod
   `endif
   /* If this metod is called it returns if te Receiver FIFO as data or not . */
   method Bool receiver_not_empty;
   return fifoRecv.notEmpty();
endmethod
   /* If this method is called it returns if the Receiver FIFO is FULL or not . */
   method Bool receiver_full;
   return !fifoRecv.notFull();
endmethod
   /* If this method is called it returns if the Transmitter FIFO is FULL or not . */
   method Bool transmittor_full;
   return !fifoXmit.notFull();
endmethod
   /* If this method is called it returns if the Transmitter FIFO as data or not . */
   method Bool transmittor_empty;
   if (!fifoXmit.notEmpty && rXmitState==Idle)
      return True;
      else
      return False;
endmethod
   /* Combines the status from various places and presents it as one returnable method for read/write */
   method Bit#(1) error_status;
   return fifo_almost_full;
endmethod
   method Maybe#(Bit#(4)) new_error_bits;
   return rw_new_error_bits.wget;
endmethod
   `ifdef uart_modem
      /* Clears the status register */
      method Action clear_status(Bit#(12) clear_bits);
      int i;
      fifo_almost_full <= fifo_almost_full & clear_bits[4];
      for (i = 5; i <= 11; i = i+1)
         vrModemBuffer[i-4] <= vrModemBuffer[i-4] & clear_bits[i];
   endmethod
   `else
      method Action clear_status(Bit#(5) clear_bits);
      fifo_almost_full <= fifo_almost_full & clear_bits[4];
   endmethod
   `endif
   /* Sets the threshold register with te value passed*/
   method Action rx_threshold (UInt#(TLog#(TAdd#(d,1))) val);
   wr_fifoRTSCount <= val;
endmethod
   `ifdef uart_modem
      /* Returns the modem part of status register*/
      method Bit#(8) modem_status;
      Vector#(8, Bit#(1)) m_status = take(readVReg(vrModemBuffer));
      Bit#(8) modemstatus = pack(m_status);
      return modemstatus;
   endmethod
   `endif

endmodule

endpackage
