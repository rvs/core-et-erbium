// Copyright 2017 Gnarly Grey LLC

// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


module hbc
	(
		input 			    i_clk,
		input 			    i_rstn,
    (*mark_debug="true"*)
	  input           i_txn_32_64,	
    (*mark_debug="true"*)
		input 		  	  i_cfg_access,
    (*mark_debug="true"*)
    input [5:0]     i_burst_length,
    (*mark_debug="true"*)
    input           i_burst_type, //Burst:1, incremental:0
    (*mark_debug="true"*)
		input         	i_mem_valid,
    (*mark_debug="true"*)
		output        	o_mem_ready,
    (*mark_debug="true"*)
		input  [7:0]  	i_mem_wstrb,
    (*mark_debug="true"*)
		input  [31:0] 	i_mem_addr,
		input  [63:0] 	i_mem_wdata,
    (*mark_debug="true"*)
    input  [3:0]    i_initial_latency,
		output [63:0] 	o_mem_rdata,
		
		output     reg 	o_csn0,
		output		 	  o_csn1,
		output       	o_clk,
		output       	o_clkn,
		output [7:0] 	o_dq,
		input  [7:0] 	i_dq,
		output       	o_dq_de,
		output       	o_rwds,
		input        	i_rwds,
		output       	o_rwds_de,
		output       	o_resetn
	);
	
	// fsm states
	parameter IDLE 			       = 0;
	parameter CAs 			       = 1;
	parameter WR_LATENCY 	     = 2;
	parameter WRITE 		       = 3;
	parameter READ 			       = 4;
	parameter DONE 			       = 5;
	
	// write latency
	parameter WRITE_LATENCY = 6*2+10 - 1;
	
    (*mark_debug="true"*)
	reg 	[2:0] 	state;
	reg 	[47:0] 	ca;
	reg 	[63:0] 	wdata;
	reg 	[7:0]	wstrb;
  reg   txn_32_64;
  reg   [5:0] burst_length;
  reg   burst_type;
  reg   [4:0] initial_latency;
	integer 		counter;
  reg aligned_addr;

	reg 			mem_ready;
	reg 	[63:0] 	mem_rdata;
	reg 			rwds_d;
	wire 			rwds_valid;

	wire 	[7:0] 	ca_words[5:0];
	wire 	[7:0] 	wdata_words[7:0];
	wire 	[7:0] 	wstrb_words;
	
  always @(posedge i_clk or negedge i_rstn ) begin
		if(!i_rstn) begin
      initial_latency <= 5;
    end
    else begin
      case(i_initial_latency) 
		    4'b0000:  initial_latency <= 5;
		    4'b0001:  initial_latency <= 6;
		    4'b0010:  initial_latency <= 7;
		    4'b0011:  initial_latency <= 8;
		    4'b0100:  initial_latency <= 9;
		    4'b0101:  initial_latency <= 10;
		    4'b0110:  initial_latency <= 11;
		    4'b0111:  initial_latency <= 12;
		    4'b1000:  initial_latency <= 13;
		    4'b1001:  initial_latency <= 14;
		    4'b1010:  initial_latency <= 15;
		    4'b1011:  initial_latency <= 16;
		    4'b1100:  initial_latency <= 0;
		    4'b1101:  initial_latency <= 0;
		    4'b1110:  initial_latency <= 3;
		    4'b1111:  initial_latency <= 4;
        default: initial_latency <= 5;
      endcase
    end
  end
	// fsm
	always @(posedge i_clk or negedge i_rstn) begin
		if(!i_rstn) begin
			ca 			<= 48'h0;
			state 		<= IDLE;
			mem_ready 	<= 1'b0;
			mem_rdata 	<= 0;
			counter 	<= 0;
		end else begin
			rwds_d <= i_rwds;
			case (state)
				IDLE : begin// wait for mem transaction
					mem_ready 		 <= 1'b0;
					if(i_mem_valid && !mem_ready) begin
			      mem_rdata 	<= 0;
						ca[47] 		   <= ~(|i_mem_wstrb);
						ca[46] 		   <= i_cfg_access;
            txn_32_64    <= i_txn_32_64;
						ca[45] 		   <= ((|i_mem_wstrb) & i_cfg_access);
						ca[44:16] 	 <= i_mem_addr[31:3];
						ca[15:3] 	   <= 0;
						ca[2:0] 	   <= i_mem_addr[2:0];
						wdata 		   <= i_mem_wdata;
            burst_length <= (2**i_burst_length);
            burst_type   <= i_burst_type;
            if(!i_txn_32_64) begin
						  wstrb 		 <= i_mem_wstrb[3:0];
            end
            else begin
						  wstrb 		 <= i_mem_wstrb;
            end
						counter		   <= 5;
						state 		   <= CAs;
            if(i_mem_addr%8) begin
              aligned_addr <= 0;
            end
            else begin
              aligned_addr <= 1;
            end
					end
				end

				CAs: begin
					if(counter) begin
						counter 	<= counter - 1;
					end else if(ca[47]) begin // read
            if(!txn_32_64) begin
						  counter 	<= 3;
            end
            else begin
						  counter 	<= 7;
            end
						state   	<= READ;
					end else begin
						if (ca[46]) begin // write to register
							counter <= 3;// JVS: regwrites are also 32bit
							state 	<= WRITE;
						end else begin // write to memory
						  counter <= WRITE_LATENCY;
						  //counter <= initial_latency*2-1;
						  state   <= WR_LATENCY;
						end
					end
				end

				WR_LATENCY: begin
					if(counter) begin
						counter <= counter - 1;
					end else begin
            if(!txn_32_64) begin
						  counter <= 3;
            end
            else begin
						  counter <= 7;
            end
            if(!burst_type) begin
						  state 	<= WRITE;
            end
            else begin
              if(burst_length) begin
                burst_length <= burst_length - 1;
                //wdata <= i_mem_wdata;
                if(!txn_32_64) begin
                  counter <= 3;
                end
                else begin
                  counter <= 7;
                end
                state   <= WRITE;
              end
              else begin
                state 	<= DONE;
              end
            end
					end 
				end

				WRITE: begin
					if(counter) begin
						counter <= counter - 1;
					end else begin
            if(!burst_type) begin
						  state 	<= DONE;
            end
            else begin
              wdata <= i_mem_wdata;
              if(burst_length) begin
                burst_length <= burst_length - 1;
                wdata <= i_mem_wdata;
                if(!txn_32_64) begin
                  counter <= 3;
                end
                else begin
                  counter <= 7;
                end
                state   <= WRITE;
              end
              else begin
                state 	<= DONE;
              end
            end
					end 
				end 

				READ : begin
				  mem_ready 	<= 1'b0;
					if(rwds_valid) begin
            if(!txn_32_64) begin
						  case (counter) 
						  	  3: mem_rdata[15:8] 	<= i_dq;
						  	  2: mem_rdata[7:0] 	<= i_dq;
						  	  1: mem_rdata[31:24] <= i_dq;
						  	  0: mem_rdata[23:16] <= i_dq;
						  endcase	
            end
            else begin
						  case (counter) 
						  	  7: mem_rdata[15:8] 	<= i_dq;
						  	  6: mem_rdata[7:0] 	<= i_dq;
						  	  5: mem_rdata[31:24] <= i_dq;
						  	  4: mem_rdata[23:16] <= i_dq;
						  	  3: mem_rdata[47:40] <= i_dq;
						  	  2: mem_rdata[39:32] <= i_dq;
						  	  1: mem_rdata[63:56] <= i_dq;
						  	  0: mem_rdata[55:48] <= i_dq;
						  endcase	
            end
						if(counter) begin
							counter <= counter - 1;
						end else begin 
              if(!burst_type) begin
							  state 	<= DONE;
              end
              else begin
					     mem_ready 	<= 1'b1;
                if(burst_length) begin
                  burst_length <= burst_length - 1;
                  if(!txn_32_64) begin
                    counter <= 3;
                  end
                  else begin
                    counter <= 7;
                  end
                  state   <= READ;
                end
                else begin
                  counter <= 0;
                  state 	<= DONE;
                end
              end
						end
					end
          if(burst_type) begin
            if(burst_length==0) begin
              state <= DONE;       
            end
          end
				end

				DONE: begin
					mem_ready 	<= 1'b1;
					state 		  <= IDLE;
				end
			endcase 
		end 	
	end
	
	assign rwds_valid 		  = (rwds_d ===1'b1 | i_rwds === 1'b1 );
	assign ca_words[5] 		  = ca[47:40];
	assign ca_words[4] 		  = ca[39:32];
	assign ca_words[3] 		  = ca[31:24];
	assign ca_words[2] 		  = ca[23:16];
	assign ca_words[1] 		  = ca[15:8];
	assign ca_words[0] 		  = ca[7:0];
	assign wdata_words[7] 	= wdata[15:8];
	assign wdata_words[6] 	= wdata[7:0] ;
	assign wdata_words[5] 	= wdata[31:24];
	assign wdata_words[4] 	= wdata[23:16];
	//assign wdata_words[3] 	= aligned_addr ? (txn_32_64 ? wdata[47:40] : wdata[15:8] ) :wdata[47:40];
	//assign wdata_words[2] 	= aligned_addr ? (txn_32_64 ? wdata[39:32] : wdata[7:0]  ) :wdata[39:32];
	//assign wdata_words[1] 	= aligned_addr ? (txn_32_64 ? wdata[63:56] : wdata[31:24]) :wdata[63:56];
	//assign wdata_words[0] 	= aligned_addr ? (txn_32_64 ? wdata[55:48] : wdata[23:16]) :wdata[55:48];
	assign wdata_words[3] 	= txn_32_64 ? wdata[47:40] : wdata[15:8] ;
	assign wdata_words[2] 	= txn_32_64 ? wdata[39:32] : wdata[7:0]  ;
	assign wdata_words[1] 	= txn_32_64 ? wdata[63:56] : wdata[31:24];
	assign wdata_words[0] 	= txn_32_64 ? wdata[55:48] : wdata[23:16];
	// jvs:assign wdata_words[1] 	= ca[46]?wdata[15:8] : :wdata[31:24];
	// jvs:assign wdata_words[0] 	= ca[46]?wdata[7:0]:wdata[23:16];
	//assign wstrb_words 		= {wstrb[1], wstrb[0], wstrb[3], wstrb[2], wstrb[5], wstrb[4], wstrb[7], wstrb[6]};
	assign wstrb_words 		= (!txn_32_64)?{wstrb[1], wstrb[0], wstrb[3], wstrb[2]} : {wstrb[1], wstrb[0], wstrb[3], wstrb[2], wstrb[5], wstrb[4], wstrb[7], wstrb[6]} ;
	//assign wstrb_words 		=(aligned_addr) ? (!txn_32_64)?{wstrb[1], wstrb[0], wstrb[3], wstrb[2]} : {wstrb[1], wstrb[0], wstrb[3], wstrb[2], wstrb[5], wstrb[4], wstrb[7], wstrb[6]} : {wstrb[5], wstrb[4], wstrb[7], wstrb[6]};
	
	reg bus_clk;
  wire o_csn0_pre;
	always @(negedge i_clk or negedge i_rstn) begin
		if(!i_rstn)
			bus_clk <= 0;
		else
			//jvs: bus_clk <= o_csn0 ? 0 : ~bus_clk;
			// bus_clk <=  ~bus_clk;
      bus_clk <= o_csn0_pre ? 0 : ~bus_clk;
	end
	
	assign o_csn0_pre 		= 	(state == IDLE || state == DONE);
  always @(*)
	 o_csn0 		=#0.1 o_csn0_pre;
	assign o_csn1 		= 	1'b1;
	assign o_clk 		= 	state ==IDLE && !(i_mem_valid && !mem_ready) ? i_clk:bus_clk;
	assign o_clkn 		= 	~o_clk;
	assign o_resetn 	= 	i_rstn;
	assign o_dq 		= 	(state == CAs)?		ca_words[counter]:
							(state == WRITE)?	wdata_words[counter]:8'h0;
	assign o_rwds 		= 	(state == WRITE)?	~wstrb_words[counter]:1'b0;
	assign o_dq_de 		= 	(state == WRITE || state == CAs);
	assign o_rwds_de 	= 	(state == WRITE) && (~ca[46]);
	assign o_mem_ready 	=	mem_ready;
	assign o_mem_rdata 	= 	mem_rdata;

endmodule


