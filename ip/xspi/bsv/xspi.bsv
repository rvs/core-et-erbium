/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2025-08-20
 Description:
   The actual DDR IO is handled by a verilog module.
   The Main FSM keeps track of timing of each phase.
   The Data path is handled via separate rule/fsm's
           Mem/Reg Writes via rules which execute individual transactions.
*/
import Semi_FIFOF :: *;
import Probe :: * ;
import FIFOF :: * ;
import Vector :: *;
import DReg::*;
import StmtFSM::*;
import RWire::*;
import axi4_types::*;
import apb_types::*;
import ddr_i::*;
import mkddr_o::*;
import SFDP_Reg_csr::*;
import SFDP_Reg_reg::*;
import SFDP_Reg_signal::*;
import SCCR_Reg_csr::*;
import SCCR_Reg_reg::*;
import SCCR_Reg_signal::*;
import Vector::*;
import xSPITypes ::*;
import rwds_o::*;

module [Module] namedCallstmt#(String seqName, Stmt s)(Stmt);
    let tmp <- unS(s);
    let stmts = tpl_2(tmp);
    return _s__(SNamed(seqName, seqName, stmts));
endmodule

function Stmt namedCall(String seqName, Action act);
    return _s__(SNamed(seqName, seqName, Cons(SAction(seqName, act, Nothing), Nil)));
endfunction
(*synthesize*)
module mkxspi(XSPI_Ifc);

	      QueueSize q_size=QueueSize{ wr_req_depth:  2,
                wr_resp_depth: 2,
                rd_req_depth:  2,
        rd_resp_depth: 2};

	      XSPI_I#(Bit#(8)) io_din <- mkddr_i();
	      XSPI_o#(Bit#(8)) io_dout <- mkddr_o();
	      Reg#(Bool) io_dout_oe <- mkRegA(False);
	      Reg#(Bool) io_rwds_oe <- mkRegA(True);
        RWDS_OIfc        io_rwds_o <-mkrwds_o();

	      PulseWire io_rwds_i <- mkPulseWire();
	      Wire#(Bool) io_csn_i <- mkDWire(False);
	      Reg#(Bool) io_csn_i_d1 <-mkRegA(False);
	      Reg#(Bool) io_csn_i_d2 <-mkRegA(False);
	      ConfigCSR_SFDP_Reg sfdp <- mkConfigCSR_SFDP_Reg();
	      ConfigCSR_SCCR_Reg csr <- mkConfigCSR_SCCR_Reg();
	      Ifc_axi4_master_xactor#(0,32,64,0) axi4 <- mkaxi4_master_xactor(q_size);
	      Reg#(Rates) current_rate <- mkRegA(S1);
	      Reg#(Bool) set_rate_mode <- mkRegA(False);
	      RWire#(Bit#(16)) bytes <- mkRWire();
	      Wire#(Rates) cmd_rate <-mkWire();
	      Wire#(Rates) address_rate <-mkWire();
	      Wire#(Rates) data_rate <-mkWire();
	      Reg#(Bit#(4)) byte_counter <-mkRegA(0);
	      Reg#(Bit#(5)) latency_count <-mkRegA(8);
	      Reg#(Bit#(3)) rd_byte_counter <-mkRegA(0);
	      Reg#(Bit#(3)) rd_slice_counter <-mkRegA(7);
	      Reg#(Bit#(3)) wr_counter <-mkRegA(0);
	      Reg#(Bit#(8)) cmd<-mkRegA(0);
	      Reg#(Bit#(8)) modifier<-mkRegA(0);
	      Reg#(Bool) mode32bit <- mkRegA(False);
	      Reg#(Bit#(8)) dummy <-mkRegU();
	      Vector#(4,Reg#(Bit#(8))) address<-replicateM(mkRegA(0));
	      Vector#(3,Reg#(Bit#(8))) rate<-replicateM(mkRegA(unpack(0)));
	      Vector#(8,Reg#(Bit#(8))) wr_vec<-replicateM(mkRegA(0));
	      Vector#(8,Reg#(Bool)) wr_byteen<-replicateM(mkRegA(False));
	      FIFOF#(Bit#(64)) out_ff <-mkFIFOF();
	      Reg#(Format_st) current_format <- mkRegA(unpack(0));
	      PulseWire pw_writeFlag <-mkPulseWire;
	      PulseWire pw_mode32bit <-mkPulseWire;
        PulseWire pw_writeDone <- mkPulseWire;
	      Reg#(Bool) r_read <- mkRegA(False);
	      Reg#(Bit#(12)) i<-mkRegA(0);
	      Reg#(Bool) read_done <-mkRegA(False);
			  Probe#(Tuple3#(Rates,Rates,Rates)) pb_rates <-mkProbe();
			  Probe#(Bit#(8)) dout_re_probe <-mkProbe();
			  Probe#(Bit#(8)) dout_fe_probe <-mkProbe();
			  Probe#(Bool) pb_cmd <-mkProbe();
			  Probe#(Bool) pb_ext <-mkProbe();
			  Probe#(Bool) pb_address <-mkProbe();
			  Probe#(Bool) pb_latency <-mkProbe();
			  Probe#(Bool) pb_data <-mkProbe();
        Probe#(HB_Cmd_st) pb_hb_cmd <- mkProbe();
        Ifc_apb_slave_xactor#(32,64,0) apbif <- mkapb_slave_xactor();
        RWire#(Tuple3#(Bit#(6),Bit#(32),Bit#(8))) csr_write <-mkRWire();
        RWire#(Bit#(32)) apb_read <-mkRWire();
        RWire#(Bit#(32)) apb_rdata <-mkRWire();
	      Commands cmd_e=unpack(cmd);
	      Bool ddr_mode = (current_rate== D1) || (current_rate ==D4) || (current_rate == D8)|| (current_rate ==HB);
        Wire#(DefaultMode) wr_default_mode_pins <- mkWire;
        Reg#(Bool) out_of_reset <-mkRegA(True);
        Wire#(Bit#(8)) dw_out_data_re <- mkDWire(0);
        Wire#(Bit#(8)) dw_out_data_fe <- mkDWire(0);

        HB_Cmd_st hb_cmd=unpack({cmd,modifier,address[3],address[2],address[1],address[0]});
        let addr = cmd_rate==HB ? {hb_cmd.uca,hb_cmd.lca}:pack(readVReg(address));
        let command_table = cmd_rate == S1 ? command_table_s1 : command_table_s8;
        let isRdReg=(cmd_rate == HB) ? mode32bit && hb_cmd.isRegAccess && hb_cmd.isReadTxn: cmd_e==ReadRegister && mode32bit;
        let isWrReg=(cmd_rate == HB)? hb_cmd.isRegAccess && !hb_cmd.isReadTxn: cmd_e ==WriteRegister && mode32bit;
	      Bit#(8) numHdr = sfdp.reg6_2_2.snumHdr;

        function Bit#(8) fn_hb_decode_len;
                let rv=0;
                if(csr.cfg.sBurstEnable == 0 )
                        rv= 0;
                else begin
                        rv = case(csr.cfg.sBurstLength  )
                                0: return 15;
                                1: return 7;
                                2: return 1;
                                3: return 3;
                        endcase;
                end
                return rv;
        endfunction

        function Bit#(5) hb_decode_latency(Bit#(4) hblat);
                return 8+zeroExtend(hblat);
        endfunction
        function Bit#(2) fn_hb_decode_burst ;
                return 1; // Incr mode
        endfunction
	      function Bit#(3) init_slice();
		            let rv= case(data_rate)
			                  S1: return 7;
			                  D1: return 3;
			                  S4: return 1;
			                  default: return 0;
		            endcase;
		            return rv;
	      endfunction

	      function Maybe#(Format_st) fn_decode_cmd();
		            let rv=tagged Invalid;
		            let b=bytes.wget();
		            Bit#(16) varcmd=fromMaybe(0,b);
		            if(isValid(b)) rv=find(match_cmd(unpack(varcmd[15:8])),command_table);
		            return rv;
	      endfunction

	      function Action setCurrentRate(Rates r);
		            return (action
				                        current_rate <= r;
				                        byte_counter<=init_count(r);
		            endaction);
	      endfunction

	      function Stmt get_byte(Reg#(Bit#(8)) dataMSB,Reg#(Bit#(8)) dataLSB,Action a,String s);
		            return(seq
				                        while(!isValid(bytes.wget())) noAction;
				                        namedCall(s,action
					                              Bit#(16) d=fromMaybe(0,bytes.wget());
					                              dataMSB <= d[15:8];
					                              if (current_rate ==D8||current_rate == HB)
						                                    dataLSB<=d[7:0];
					                              a;
				                endaction);
		            endseq);
	      endfunction


        rule setWIP;
                if (pw_writeFlag && !mode32bit)  csr.xspi_status.swip <=1;
                else if (pw_writeDone) csr.xspi_status.swip <=0;
        endrule
        rule accept_btxn if(axi4.fifo_side.o_wr_resp.notEmpty());
                pw_writeDone.send();
                let bresp= axi4.fifo_side.o_wr_resp.first();
                if(bresp.bresp!=0 &&  bresp.bresp !=1)
                        csr.interrupt_status.saxi_resp<=bresp.bresp;
                axi4.fifo_side.o_wr_resp.deq();
        endrule
	      rule r_iocsn;
		            io_csn_i_d1 <= io_csn_i;
		            io_csn_i_d2 <= io_csn_i_d1;
	      endrule
	      rule _io_enable if(!io_csn_i);
		            io_din.ena();
	      endrule
	      rule r_alwaysenable;
		            io_din.cmd_data_rate(pack(cmd_rate));
		            io_din.addr_data_rate(pack(address_rate));
		            if (ddr_mode ) io_din.ddr_mode();
                io_dout.data_re(dw_out_data_re);
                io_dout.data_fe(dw_out_data_fe);
	      endrule



        /////////////////////////////
        // Set Rate
        /////////////////////////////

	      rule setRate;
		            cmd_rate <= toRate(csr.xspi_rates.scmd_rate);
		            address_rate <= toRate(csr.xspi_rates.saddr_rate);
		            data_rate <= toRate(csr.xspi_rates.sdata_rate);
                pb_hb_cmd <=hb_cmd;
	      endrule
	      rule rl_set_rate(bytes.wget matches tagged Valid .b &&& set_rate_mode && !(current_rate ==D8) && !out_of_reset );
		            rate[wr_counter]<=b[15:8];
		            let nrwc=wr_counter+1;
		            if (wr_counter ==2) begin
			                  set_rate_mode <=False;
			                  csr.xspi_rates.scmd_rate <= rate[0];
			                  csr.xspi_rates.saddr_rate <= rate[1];
			                  csr.xspi_rates.sdata_rate <= b[15:8];
		            end
		            wr_counter<=nrwc;
	      endrule

	      rule rl_set_rate_8ddr(bytes.wget matches tagged Valid .b &&& set_rate_mode && (current_rate ==D8) && !out_of_reset  );
		            if (wr_counter ==0)begin
			                  rate[0]<=b[15:8];
			                  rate[1] <= b[7:0];
		            end
		            else
			                  rate[2] <= b[15:8];
		            let nrwc=wr_counter+1;
		            if (wr_counter ==1) begin
                        set_rate_mode <=False;
			                  csr.xspi_rates.scmd_rate <= rate[0];
			                  csr.xspi_rates.saddr_rate <= rate[1];
			                  csr.xspi_rates.sdata_rate <= b[15:8];
                end
		            wr_counter<=nrwc;

	      endrule

	      Stmt setRate_s <- namedCallstmt("setRate",seq
		                    if (current_rate ==D8) seq
			                          get_byte(rate[0],rate[1],noAction,"D8_rate_0");
			                          get_byte(rate[2],dummy,noAction,"D8_rate_2");
		                    endseq else seq
			                          get_byte(rate[0],dummy,noAction,"S_rate_0");
			                          get_byte(rate[1],dummy,noAction,"S_rate_1");
			                          get_byte(rate[2],dummy,noAction,"S_rate_2");
		                    endseq
        endseq);
        /////////////////////////////
        // Read Reg/Mem
        /////////////////////////////

        rule r_readReg (isRdReg);
                let x <- csr.read(addr[5:0]);
                out_ff.enq(x);
        endrule

			  rule rd_mem_addr(r_read);
				        r_read<=False;
				        let a =addr;
				        axi4.fifo_side.i_rd_addr.enq(Axi4_rd_addr{
						                    arid:0,
						                    araddr:a,
						                    arlen:fn_hb_decode_len(),
						                    arsize:3,
						                    arburst:fn_hb_decode_burst(),
						                    arlock:0,
						                    arcache:0,
						                    arprot:0,
						                    arqos:0,
						                    arregion:0,
						                    aruser:0
				        });
			  endrule

        (*mutually_exclusive="r_readReg,rd_mem_data" *)
			  rule rd_mem_data;
				        let d = axi4.fifo_side.o_rd_data.first();
				        axi4.fifo_side.o_rd_data.deq();
                if (d.rresp != 0) csr.interrupt_status.saxi_resp<=d.rresp;
				        out_ff.enq(d.rdata);
			  endrule

        Stmt outMux_s=seq
				while(!io_csn_i)action 
        if (out_ff.notEmpty()) begin
                        io_rwds_o.ena();
                        if(ddr_mode) io_rwds_o.ddr_mode();
				                Vector#(8,Bit#(8)) d =unpack(out_ff.first());
				                Bit#(3) nxt_cnt=rd_byte_counter+1;
				                let current_byte = d[rd_byte_counter];
				                let next_byte = d[nxt_cnt];
				                Bit#(8) dout_re=0;
				                Bit#(8) dout_fe=0;
				                case(current_rate)
								                D1:begin
												                dout_re =case(rd_slice_counter)
																                3: return {6'd0,current_byte[7],1'b0};
																                2: return {6'd0,current_byte[5],1'b0};
																                1: return {6'd0,current_byte[3],1'b0};
																                0: return {6'd0,current_byte[1],1'b0};
												                endcase;
												                dout_fe =case(rd_slice_counter)
																                3: return {6'd0,current_byte[6] ,1'b0} ;
																                2: return {6'd0,current_byte[4] ,1'b0} ;
																                1: return {6'd0,current_byte[2] ,1'b0} ;
																                0: return {6'd0,current_byte[0] ,1'b0} ;
												                endcase;
									              end
 						 			              S1:	begin
													              dout_re= case(rd_slice_counter)
																	              7: return {6'd0,current_byte[7] ,1'b0} ;
																	              6: return {6'd0,current_byte[6] ,1'b0} ;
																	              5: return {6'd0,current_byte[5] ,1'b0} ;
																	              4: return {6'd0,current_byte[4] ,1'b0} ;
																	              3: return {6'd0,current_byte[3] ,1'b0} ;
																	              2: return {6'd0,current_byte[2] ,1'b0} ;
																	              1: return {6'd0,current_byte[1] ,1'b0} ;
																	              0: return {6'd0,current_byte[0] ,1'b0} ;
													              endcase;
									              end
									              D4:begin
													              dout_re =  zeroExtend(current_byte[7:4]) ;
													              dout_fe =  zeroExtend(current_byte[3:0]) ;

									              end
									              S4: begin
													              dout_re =case(rd_slice_counter)
																	              1: return {4'd0,current_byte[7:4]};
																	              0: return {4'd0,current_byte[3:0]};
													              endcase;
									              end
									              HB,D8:begin
													              dout_re =  current_byte[7:0] ;
													              dout_fe =  next_byte[7:0];
									              end
 						 			              S8:	 begin
													              dout_re=current_byte[7:0];
									              end
					              endcase
					              io_dout_oe <=True;
					              dw_out_data_re <= dout_re;
					              dw_out_data_fe <= dout_fe;
					              if(ddr_mode) io_dout.ddr_mode();
					              Bit#(3) next_rbc =rd_byte_counter;
					              if(rd_slice_counter==0) begin
						                    rd_slice_counter<= init_slice();
                                let doDeq = case (current_rate)
                                        S1,D1,S4,D4,S8:return mode32bit ? rd_byte_counter == 3 : rd_byte_counter == 7;
                                        D8,HB: return mode32bit ? rd_byte_counter == 2 : rd_byte_counter == 6 ;
                                endcase;
						                    if(doDeq)begin
							                          out_ff.deq();
							                          next_rbc =0;
						                    end else begin 
                                        if(current_rate == HB || current_rate == D8) next_rbc = rd_byte_counter + 2;
                                        else next_rbc =rd_byte_counter+1;
                                end
					              end
					              else rd_slice_counter <=rd_slice_counter -1;
					              rd_byte_counter <= next_rbc;
				        end else csr.interrupt_status.sread_underflow<=1;
        endaction
        endseq;
        FSM outmux_fsm <-mkFSM(outMux_s);


        /////////////////////////////
        // Writes Reg/Mem
        /////////////////////////////
			  let  ac_wr_mem_addr=action
				        let a =addr;
				        axi4.fifo_side.i_wr_addr.enq(Axi4_wr_addr{
						                    awid:0,
						                    // awaddr:{addr[4],addr[3],addr[2],addr[1],addr[0]},
						                    awaddr:a,
						                    awlen:0,
						                    awsize:3,
						                    awburst:1,
						                    awlock:0,
						                    awcache:0,
						                    awprot:0,
						                    awqos:0,
						                    awregion:0,
						                    awuser:0
				        });
				        a[11:0]=a[11:0]+8;
                // TODO Fix this for hyperbus case, i.e write to UCA and LCA
                if(cmd_rate == HB)begin
                        // tmp={cmd,modifier,address[3],address[2],address[1],address[0]}
                        address[0]<={address[0][7:3],a[2:0]};
                        address[2]<=a[10:3];
                        address[3]<=a[18:11];
                end
                else writeVReg(address,unpack(zeroExtend(a)));
			  endaction;

	      rule rl_write_d8(pw_writeFlag && (data_rate ==D8 || data_rate == HB));
			          if(bytes.wget() matches tagged Valid .b) begin
			                  let wrc = wr_counter;
				                case (wrc)
					                      0:begin
						                            wr_vec[1]<=b[7:0];
						                            wr_vec[0]<=b[15:8];
                                        wr_byteen[1] <= ! io_din.rwds_fe();
                                        wr_byteen[0] <= ! io_din.rwds_re();
					                      end
					                      1:begin
						                            wr_vec[3]<=b[7:0];
						                            wr_vec[2]<=b[15:8];
                                        wr_byteen[3] <= ! io_din.rwds_fe();
                                        wr_byteen[2] <= ! io_din.rwds_re();
					                      end
					                      2:begin
						                            wr_vec[5]<=b[7:0];
						                            wr_vec[4]<=b[15:8];
                                        wr_byteen[5] <= ! io_din.rwds_fe();
                                        wr_byteen[4] <= ! io_din.rwds_re();
					                      end
					                      3:begin
						                            wr_vec[7]<=b[7:0];
						                            wr_vec[6]<=b[15:8];
                                        wr_byteen[7] <= ! io_din.rwds_fe();
                                        wr_byteen[6] <= ! io_din.rwds_re();
					                      end
				                endcase
				                wrc = wr_counter + 1;
				                if(mode32bit && wr_counter == 1 || !mode32bit && wr_counter == 3 )begin
					                      Bit#(64) wdata;
					                      Bit#(8) byte_en;
					                      if(mode32bit)begin //RegWrite
						                            wdata = {32'b0,b[7:0],b[15:8],wr_vec[1],wr_vec[0]};
                                        byte_en ={4'b0,~pack( io_din.rwds_fe),~pack(io_din.rwds_re()), pack(wr_byteen[1]), pack(wr_byteen[0])};
                                        csr_write.wset(tuple3(addr[5:0],wdata[31:0],byte_en));
                                end else begin //MeMWrite
					                              ac_wr_mem_addr;
						                            wdata = {b[7:0],b[15:8],wr_vec[5],wr_vec[4],wr_vec[3],wr_vec[2],wr_vec[1],wr_vec[0]};
                                        byte_en ={~pack( io_din.rwds_fe),~pack(io_din.rwds_re()), pack(wr_byteen[5]), pack(wr_byteen[4]), pack(wr_byteen[3]), pack(wr_byteen[2]), pack(wr_byteen[1]), pack(wr_byteen[0])};

                                        if(axi4.fifo_side.i_wr_data.notFull())
					                              axi4.fifo_side.i_wr_data.enq(Axi4_wr_data{
							                                          wdata:wdata,
							                                          wstrb:byte_en,
							                                          wlast:True,
							                                          wuser:0
					                              });
                                        else csr.interrupt_status.swrite_overflow <=1;
                                end
					                      wrc = 0;
				                end
			                  wr_counter <= wrc;
			          end
		    endrule


        (* mutually_exclusive="rl_set_rate,rl_set_rate_8ddr,rl_write_d8,rl_write" *)
		    rule rl_write(pw_writeFlag && data_rate !=D8 && data_rate !=HB);
				        if(bytes.wget() matches tagged Valid .b) begin
				                let wrc = wr_counter;
					              wr_vec[wr_counter]<=b[15:8];
                        wr_byteen[wr_counter] <= ! io_din.rwds_re();
					              wrc = wr_counter + 1;
					              if(mode32bit && wr_counter == 3 || !mode32bit && wr_counter == 7 )begin
						                    wrc =0;
						                    Bit#(64) wdata;
						                    Bit#(8) byte_en;
						                    if(mode32bit)begin
						                            wdata = {32'b0,b[15:8], wr_vec[2],  wr_vec[1],  wr_vec[0]};
                                        byte_en ={4'b0, ~pack(io_din.rwds_re()), pack(wr_byteen[2]), pack(wr_byteen[1]), pack(wr_byteen[0])};
                                        csr_write.wset(tuple3(addr[5:0],wdata[31:0],byte_en));
						                    end else begin
						                            ac_wr_mem_addr;
                                        wdata = {b[15:8], wr_vec[6],  wr_vec[5],  wr_vec[4], wr_vec[3], wr_vec[2], wr_vec[1],  wr_vec[0]};
                                        byte_en ={~pack(io_din.rwds_re()), pack(wr_byteen[6]), pack(wr_byteen[5]), pack(wr_byteen[4]), pack(wr_byteen[3]),     pack(wr_byteen[2]), pack(wr_byteen[1]), pack(wr_byteen[0])};
                                        if(axi4.fifo_side.i_wr_data.notFull())
						                            axi4.fifo_side.i_wr_data.enq(Axi4_wr_data{
								                                        wdata:wdata,
								                                        wstrb: byte_en,
								                                        wlast:True,
								                                        wuser:0
						                            });
                                        else csr.interrupt_status.swrite_overflow <=1;
                                end
					              end
				                wr_counter <= wrc;
				        end
			  endrule


        Wire#(APB_request#(32,64,0)) wr_apb_req_first <-mkWire();
        rule apb_request_first;
                wr_apb_req_first <= apbif.fifo_side.o_request.first();
        endrule
        rule rl_csr_read if(!wr_apb_req_first.pwrite);
                let x=wr_apb_req_first;
                apbif.fifo_side.o_request.deq();
                Bit#(32) a = x.paddr;
                let rv <- csr.read(a[5:0]);
                apbif.fifo_side.i_response.enq(
                        APB_response{prdata:rv,pslverr:False,puser:0});
        endrule

        (* descending_urgency = "rl_csr_write_xspi,rl_csr_write_apb" *)
        rule rl_csr_write_xspi(csr_write.wget() matches tagged Valid .x);
                Bit#(6) a = tpl_1(x);
                Bit#(32) d = tpl_2(x);
                csr.write(a[5:0],{32'b0,d[31:0]},8'h0f);
        endrule
        rule rl_csr_write_apb (apbif.fifo_side.o_request.notEmpty());
                let x=apbif.fifo_side.o_request.first();
                if(x.pwrite) begin
                        apbif.fifo_side.o_request.deq();
                        Bit#(32) a = x.paddr;
                        Bit#(64) d = x.pwdata;
                        csr.write(a[5:0],{32'b0,d[31:0]},x.pstrb);
                        apbif.fifo_side.i_response.enq(APB_response{prdata:0,pslverr:False,puser:0});
                end
        endrule

        /////////////////////////////
        // Misc Stuff
        /////////////////////////////
        function Action fn_modifier(Format_st x);
                return (action 
			                          let next_rate=data_rate;
                                if(x.iswrite)begin 
                                        io_dout_oe <= False;
                                        io_rwds_oe <= False;
                                end
			                          if(x.address !=None)begin
				                                next_rate=address_rate;
			                          end
			                          setCurrentRate(next_rate);
			                          case(x.cmd)
				                                SetRate: begin
					                                      set_rate_mode<=True;
					                                      wr_counter <=0;
				                                end
			                          endcase
                endaction);
        endfunction
	      let ac_decode_cmd=action
		            if(fn_decode_cmd() matches tagged Valid .x) begin

                        if(cmd_rate ==D8||cmd_rate==S1 ||cmd_rate==D1)begin // No seperate Modifier cycle
                                fn_modifier(x);
                        end
			                  current_format <=x;
			                  // if(x.ismem) mode32bit <=False;
			                  // else mode32bit <=True;
			                  if(x.isread)
				                        latency_count<=hb_decode_latency(csr.cfg.sInitialLatency)-1;
			                  else
				                        latency_count<=hb_decode_latency(csr.cfg.sInitialLatency);
		            end
	      endaction;

	      rule rl_byte_counter;
		            let b=byte_counter;
		            if(io_csn_i_d1|| b ==0 )begin
			                  b=init_count(current_rate);
		            end else b = b-1;
		            byte_counter <= b;
	      endrule

	      rule rl_mkbyte;
		            bytes.wset(demangle(io_din.data_re,io_din.data_fe,current_rate));
	      endrule


			                  Stmt read_sfdp_s=seq
				                        read_done<=False;
                                while(!io_csn_i)seq
					                              action
                                                let addr={address[2],address[1],address[0]};
						                                    let x<-sfdp.read(addr[11:0]);
						                                    out_ff.enq(zeroExtend(x));
                                                addr =addr +4;
				                                        writeVReg(address,unpack(zeroExtend(addr)));
					                              endaction
                                endseq
				                        read_done<=True;
			                  endseq;
			                  FSM read_sfdp_fsm <-mkFSM(read_sfdp_s);

			                  rule debug_always;
				                        pb_rates <=tuple3(cmd_rate,address_rate,data_rate);

			                  endrule


			                  Action acInit=action:init
                                io_dout_oe <= False;
                                io_rwds_oe <= True;
				                        rd_slice_counter<=init_slice;
				                        rd_byte_counter<=0;
				                        latency_count <= hb_decode_latency(csr.cfg.sInitialLatency);
				                        setCurrentRate(cmd_rate);
				                        wr_counter <= 0;
                                mode32bit<=False;
                                out_ff.clear();
			                  endaction:init;
			                  let seqCmd=seq
				                        get_byte(cmd,modifier,action
						                                    pb_cmd<=True;
						                                    ac_decode_cmd;
				                        endaction,"seqCmd");
                                if (cmd_rate == S4 || cmd_rate == D4 || cmd_rate == S8 )
				                                get_byte( modifier,dummy, fn_modifier(current_format),"seqModifier");
			                  endseq;
			                  let ac_address=action
				                        pb_address<=True;
			                  endaction;
                        let ac_address_end=action 
                                ac_address;
																setCurrentRate(data_rate);
                                case(cmd_e)
                                        ReadRegister: mode32bit <=True;
                                        WriteRegister:mode32bit <=True;
                                endcase
                        endaction;

			                  let seqAddress4 = seq // TODO handle 16b input
							                          if (address_rate == D8)seq
											                          get_byte(address[3],address[2],ac_address,"D8_Addr4_3_2");
											                          get_byte(address[1],address[0],action 
                                                                ac_address; 
																			                          setCurrentRate(data_rate);
                                                                let m32=False;
                                                                case(cmd_e)
                                                                        ReadRegister:begin 
                                                                                m32 = True;
                                                                        end
                                                                        WriteRegister:begin 
                                                                                m32 = True;
                                                                        end
                                                                endcase
                                                                pw_mode32bit.send();
                                                                //mode32bit <= m32;
                                        endaction,"D8_Addr4_1_0");
							                          endseq
							                          else seq
											                          get_byte(address[3],dummy,ac_address,"S_Addr4_3");
											                          get_byte(address[2],dummy,ac_address,"S_Addr4_2");
											                          get_byte(address[1],dummy,ac_address,"S_Addr4_1");
											                          get_byte(address[0],dummy,
															                          action
                                                                ac_address_end;
											                          endaction,"S_Addr4_0");
							                          endseq
			                  endseq;
			                  let seqAddress3=seq // TODO handle 16b input
                                if( address_rate == D8)seq
				                                get_byte(address[2],address[1],ac_address,"D8_Addr3_2_1");
				                                get_byte(address[0],dummy,action
						                                            ac_address_end;
				                                endaction,"D8_Addr3_0x");
                                endseq
                                else seq
				                                get_byte(address[2],dummy,ac_address,"S_Addr3_2");
				                                get_byte(address[1],dummy,ac_address,"S_Addr3_1");
				                                get_byte(address[0],dummy,action
						                                            ac_address_end;
				                                endaction,"S_Addr3_0");
                                endseq
			                  endseq;

			                  let seqLatency=par
				                        action
					                              pb_latency<=True;
					                              case(cmd_e)
						                                    SetRate:begin
							                                          set_rate_mode<=True;
							                                          wr_counter <=0;
						                                    end
						                                    ReadSFDP:read_sfdp_fsm.start();
						                                    ReadMEM:begin
							                                          r_read<=True;
							                                          rd_slice_counter<=init_slice;
							                                          rd_byte_counter<=0;
						                                    end
					                              endcase
				                        endaction
                                seq
				                                while(latency_count !=1) latency_count <= latency_count -1;
                                        action 
                                                latency_count <=latency_count -1;
                                                Bool doe = io_dout_oe;
                                                Bool roe = io_rwds_oe;
                                                if(current_format.isread) begin
                                                        doe = True;
                                                        roe = True;
                                                end
                                                if(current_format.iswrite) begin
                                                        doe = False;
                                                        roe = False;
                                                end
                                                io_dout_oe <= doe;
                                                io_rwds_oe <= roe;
                                        endaction
                                endseq
			                  endpar;

			                  let seqRData= seq
				                        while(!out_ff.notEmpty()) noAction;
				                        outmux_fsm.start();
				                        while(!io_csn_i) noAction; // TODO This should abort the fsm.
				                        endseq;

			                  let seqWData= seq: seqWdata
				                        while(!io_csn_i_d1)  pw_writeFlag.send();
			                  endseq:seqWdata;


                        // let ac_hb_rw=action
                        //                 if(hb_cmd.isReadTxn)begin
                        //                         r_read<=True;
                        //                 end
                        //                 else begin 
                        //                         pw_writeFlag.send();
                        //                 end
                        // endaction;
                        let ac_hyperbus_cmd_decode =action
                                if(hb_cmd.isRegAccess) mode32bit<=True;
                                if(hb_cmd.isReadTxn)begin 
                                        r_read <=True;
                                        io_rwds_oe <= True;
                                        io_dout_oe <= True;
                                end else begin 
                                        io_rwds_oe <= False;
                                        io_dout_oe <= False;
                                end
                        endaction;


                        Stmt seqHBLatency=seq
                                par
                                        // if(!hb_cmd.isReadTxn && !hb_cmd.isRegAccess) ac_wr_mem_addr;
                                        while(latency_count != 1) latency_count <= latency_count - 1;
                                endpar
                                par
                                        if(hb_cmd.isReadTxn) outmux_fsm.start();
                                        else noAction;

                                endpar
                        endseq;

                        Stmt s_Hyperbus=seq
                                get_byte(cmd,modifier,noAction,"HB_cmd_mod");
                                get_byte(address[3],address[2],noAction,"HB_addr32");
                                get_byte(address[1],address[0],ac_hyperbus_cmd_decode,"HB_addr10");
                                if(hb_cmd.isReadTxn || !hb_cmd.isRegAccess) seqHBLatency;
                                while (!io_csn_i_d1)if(!hb_cmd.isReadTxn && !hb_cmd.isRegAccess) namedCall("HB_Write",pw_writeFlag.send()); else namedCall("HB_Read",noAction);
                        endseq;


			                  Stmt s_SPI =seq
				                        while(io_csn_i_d1) acInit;
                                if(cmd_rate == HB) s_Hyperbus;
                                else seq
				                                seqCmd;
				                                // if(current_format.address == A5) seqAddress5;
				                                if(current_format.address == A4 ) seqAddress4;
				                                else if(current_format.address == A3) seqAddress3;
				                                if(current_format.latency) seqLatency;
				                                if(current_format.iswrite) seqWData;
				                                if(current_format.isread) seqRData;
                                endseq
			                  endseq;


			                  FSM decoder_fsm <- mkFSM(s_SPI);
			                  rule decoder_fsm_rl(!out_of_reset);
				                        decoder_fsm.start();
			                  endrule
                        rule reset_decoder_fsm(io_csn_i_d1 && !io_csn_i_d2);
                                decoder_fsm.abort();
                        endrule
                        rule driveio_rwds;
                                if(io_csn_i) io_rwds_o.csn();
                        endrule

                        rule mode32bit_set_rl(pw_mode32bit);
                                mode32bit<= ((cmd_e == ReadRegister) || ( cmd_e == WriteRegister));
                        endrule
        rule handlePostReset(out_of_reset);
                out_of_reset<=False;
                // outmux_fsm.abort();
                // read_sfdp_fsm.abort();
                // decoder_fsm.abort();
                case(wr_default_mode_pins)
                        HB_DEFAULT:begin
                                csr.xspi_rates.scmd_rate <= fromRate(HB);
                                csr.xspi_rates.saddr_rate <= fromRate(HB);
                                csr.xspi_rates.sdata_rate <= fromRate(HB);
                                current_rate <= HB;
                        end
                        SPI_DEFAULT:begin
                                csr.xspi_rates.scmd_rate <= fromRate(S1);
                                csr.xspi_rates.saddr_rate <= fromRate(S1);
                                csr.xspi_rates.sdata_rate <= fromRate(S1);
                                current_rate <= S1;
                        end
                        QSPI_DEFAULT:begin
                                csr.xspi_rates.scmd_rate <= fromRate(S4);
                                csr.xspi_rates.saddr_rate <= fromRate(S4);
                                csr.xspi_rates.sdata_rate <= fromRate(S4);
                                current_rate <= S4;
                        end
                        OSPI_DEFAULT:begin
                                csr.xspi_rates.scmd_rate <= fromRate(D8);
                                csr.xspi_rates.saddr_rate <= fromRate(D8);
                                csr.xspi_rates.sdata_rate <= fromRate(D8);
                                current_rate <= D8;
                        end
                endcase

        endrule
        rule r_rwds_in;
                let r = False;
                if(io_rwds_i) r = True;
                io_din.rwds_in(r);
        endrule
			  interface axi=axi4.axi4_side;

				interface XSPI xspi;
					      method Action dq(Bit#(8) data);
						            io_din.din(data);
					      endmethod
					      method Action rwds();
						            io_rwds_i.send();
					      endmethod
					      method Action csn();
						            io_csn_i <= True;
					      endmethod
					      method Bit#(8) dq_out();
						            return io_dout.dout();
					      endmethod
					      method Bool dq_out_ena();
						            return io_dout_oe;
					      endmethod
					      method Bool rwds_out;
						            return io_rwds_o.rwds_o()==1;
					      endmethod
					      method Bool rwds_out_ena();
						            return io_rwds_oe;
					      endmethod
				endinterface
        interface Ifc_apb_slave apb = apbif.apb_side;
        interface Xspi_config cfg;
                method Action default_mode(DefaultMode d);
                        wr_default_mode_pins <=d;
                endmethod
                method Bool deep_power_down();
                        return unpack(csr.cfg.sDeepPowerDown);
                endmethod
                method Bool ultra_deep_power_down();
                        return unpack(csr.cfg.sUltraDeepPowerDown);
                endmethod
                method Bool use_xspi_clk();
                        return unpack(csr.xspi_control.suse_xspi_clk);
                endmethod
                method Bit#(3) drive_strength();
                        return csr.cfg.sDriveStrength;
                endmethod
                method Bool reset_device();
                        return cmd_e == ResetDevice && current_rate !=HB;
                endmethod
                method Bool interrupt();
                        return csr.interrupt_status.value !=0;
                endmethod

        endinterface
endmodule
// vim: foldmethod=indent ts=2 expandtab
