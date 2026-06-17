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

/*
 * AXI4 RAM
 */
module axi2mram #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 64,
    // Width of address bus in bits, for words.
    parameter ADDR_WIDTH = 23,
    // Width of wstrb (width of data bus in words)
    parameter unsigned STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 8,
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0
    // Number of MRAM wrappers to instantiate
) (
    input  wire                   clk,
    input  wire                   rst_b,

    input  wire [ID_WIDTH-1:0]    s_axi_awid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire [7:0]             s_axi_awlen,
    input  wire [2:0]             s_axi_awsize,
    input  wire [1:0]             s_axi_awburst,
    input  wire                   s_axi_awlock,
    input  wire [3:0]             s_axi_awcache,
    input  wire [2:0]             s_axi_awprot,
    input  wire                   s_axi_awvalid,
    output wire                   s_axi_awready,
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axi_wstrb,
    input  wire                   s_axi_wlast,
    input  wire                   s_axi_wvalid,
    output wire                   s_axi_wready,
    output wire [ID_WIDTH-1:0]    s_axi_bid,
    output wire [1:0]             s_axi_bresp,
    output wire                   s_axi_bvalid,
    input  wire                   s_axi_bready,
    input  wire [ID_WIDTH-1:0]    s_axi_arid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire unsigned [7:0]    s_axi_arlen,
    input  wire [2:0]             s_axi_arsize,
    input  wire [1:0]             s_axi_arburst,
    input  wire                   s_axi_arlock,
    input  wire [3:0]             s_axi_arcache,
    input  wire [2:0]             s_axi_arprot,
    input  wire                   s_axi_arvalid,
    output wire                   s_axi_arready,
    output wire [ID_WIDTH-1:0]    s_axi_rid,
    output logic[DATA_WIDTH-1:0]  s_axi_rdata,
    output wire [1:0]             s_axi_rresp,
    output logic                  s_axi_rlast,
    output wire                   s_axi_rvalid,
    input  wire                   s_axi_rready,

    output wire                   axi_busy,

    // MRAM Connections
    output wire [DATA_WIDTH-1:0]  mram_din,
    output wire [STRB_WIDTH-1:0]  mram_bwe,
    output wire [ADDR_WIDTH-1-3-2:0]  mram_add,
    input  wire [DATA_WIDTH-1:0]  mram_dout,
    output logic                  mram_clk,
    output wire [(1<<(ADDR_WIDTH-23+2))-1:0] mram_stripe_sel, // 23 = 4 stripes, 24 = 8 Stripes.
    output wire                   mram_we,
    output wire                   mram_rst_b,
    input  wire                   mram_busy

);

    parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
    parameter WORD_WIDTH = STRB_WIDTH;
    parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH;
    parameter MRAM_ADDR_WIDTH = ADDR_WIDTH - 3;
    localparam SIZE_WIDTH = $clog2($clog2(STRB_WIDTH));
    /* Backup code
    localparam [0:0]
        READ_STATE_IDLE = 1'd0,
        READ_STATE_BURST = 1'd1;

    reg [0:0] read_state_reg = READ_STATE_IDLE, read_state_next;
    localparam [1:0]
        WRITE_STATE_IDLE = 2'd0,
        WRITE_STATE_BURST = 2'd1,
        WRITE_STATE_RESP = 2'd2;

    reg [1:0] write_state_reg = WRITE_STATE_IDLE, write_state_next;
    */
    typedef enum { IDLE, READ_INIT, READ, RMW_READ, DOUT_CAPTURE, RMW_WRITE_SETUP, WRITE } fsm_t;
    fsm_t current_state, next_state;

    reg mem_wr_en;
    reg mem_rd_en;

    reg [ID_WIDTH-1:0] read_id_reg = {ID_WIDTH{1'b0}}, read_id_next;
    reg [ADDR_WIDTH-1:0] read_addr_reg = {ADDR_WIDTH{1'b0}}, read_addr_next;
    reg [7:0] read_count_reg = 8'd0, read_count_next;
    reg [SIZE_WIDTH-1:0] read_size_reg = 2'd0, read_size_next;
    reg [1:0] read_burst_reg = 2'd0, read_burst_next;
    reg [ID_WIDTH-1:0] write_id_reg = {ID_WIDTH{1'b0}}, write_id_next;
    reg [ADDR_WIDTH-1:0] write_addr_reg = {ADDR_WIDTH{1'b0}}, write_addr_next;
    reg [7:0] write_count_reg = 8'd0, write_count_next;
    reg [SIZE_WIDTH-1:0] write_size_reg = 3'd0, write_size_next;
    reg [1:0] write_burst_reg = 2'd0, write_burst_next;

    reg s_axi_awready_reg = 1'b0, s_axi_awready_next;
    reg s_axi_wready_reg = 1'b0, s_axi_wready_next;
    reg [ID_WIDTH-1:0] s_axi_bid_reg = {ID_WIDTH{1'b0}}, s_axi_bid_next;
    reg s_axi_bvalid_reg = 1'b0, s_axi_bvalid_next;
    reg s_axi_arready_reg = 1'b0, s_axi_arready_next;
    reg [ID_WIDTH-1:0] s_axi_rid_reg = {ID_WIDTH{1'b0}}, s_axi_rid_next, s_axi_rid_pipe0_reg, s_axi_rid_pipe0_next;
    reg [DATA_WIDTH-1:0] s_axi_rdata_reg = {DATA_WIDTH{1'b0}}, s_axi_rdata_next;
    reg s_axi_rlast_reg, s_axi_rlast_next;
    reg s_axi_rvalid_reg = 1'b0, s_axi_rvalid_next;
    reg [ID_WIDTH-1:0] s_axi_rid_pipe_reg = {ID_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] s_axi_rdata_pipe_reg = {DATA_WIDTH{1'b0}};
    reg s_axi_rlast_pipe_reg = 1'b0;
    reg s_axi_rvalid_pipe_reg = 1'b0;
    logic mram_ce_b;


    // MRAM Related Logic Signals
    logic mram_ce_reg, mram_ce_read_reg, mram_ce_write_reg, mram_ce_read_next, mram_ce_write_next;
    logic mram_we_reg, mram_we_next;
    logic [DATA_WIDTH-1:0] mram_din_reg, mram_din_prev, mram_din_rmw_cap_q, mram_din_rmw_cap_d;
    logic [MRAM_ADDR_WIDTH-1:0] mram_add_reg;
    logic unsigned [ADDR_WIDTH-1:0] mram_add_read_reg, mram_add_read_prev, mram_add_write_reg, mram_add_write_prev;
    logic [STRB_WIDTH-1:0] mram_bwe_reg, mram_bwe_prev;

    logic [1:0] write_flag_reg, write_flag_next;
    logic [ADDR_WIDTH-1-3:0] selected_mram_add;
    logic [16:0] mram_stripe_add_space;
    logic [ADDR_WIDTH-22:0] mram_stripe_sel_add;
    logic mram_otp_space;
    logic mram_clk_gate_en_d, mram_clk_gate_en_q;
    logic read_in_pipestage_q0, read_in_pipestage_d0;
    logic read_in_pipestage_q1, read_in_pipestage_d1;
    logic current_state_is_idle, next_state_is_idle;
    integer unsigned byte_count, remaining_bytes, byte_count_next, remaining_bytes_next;

    // (* RAM_STYLE="BLOCK" *)
    reg [DATA_WIDTH-1:0] mem[(2**VALID_ADDR_WIDTH)-1:0];

    // wire [VALID_ADDR_WIDTH-1:0] s_axi_awaddr_valid = s_axi_awaddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
    wire [VALID_ADDR_WIDTH-1:0] s_axi_awaddr_valid = s_axi_awaddr[ADDR_WIDTH-1:(ADDR_WIDTH - VALID_ADDR_WIDTH)];
    //wire [VALID_ADDR_WIDTH-1:0] s_axi_araddr_valid = s_axi_araddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
    wire [VALID_ADDR_WIDTH-1:0] s_axi_araddr_valid = s_axi_araddr[ADDR_WIDTH-1:(ADDR_WIDTH - VALID_ADDR_WIDTH)];
    //wire [VALID_ADDR_WIDTH-1:0] read_addr_valid = read_addr_reg >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
    wire [VALID_ADDR_WIDTH-1:0] read_addr_valid = read_addr_reg[ADDR_WIDTH-1:(ADDR_WIDTH - VALID_ADDR_WIDTH)];
    //wire [VALID_ADDR_WIDTH-1:0] write_addr_valid = write_addr_reg >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
    wire [VALID_ADDR_WIDTH-1:0] write_addr_valid = write_addr_reg[ADDR_WIDTH-1:(ADDR_WIDTH - VALID_ADDR_WIDTH)];
    logic rst;
    assign s_axi_awready = s_axi_awready_reg;
    assign s_axi_wready = s_axi_wready_reg;
    assign s_axi_bid = s_axi_bid_reg;
    assign s_axi_bresp = 2'b00;
    assign s_axi_bvalid = s_axi_bvalid_reg;
    assign s_axi_arready = s_axi_arready_reg;
    //assign s_axi_rid = PIPELINE_OUTPUT ? s_axi_rid_pipe_reg : s_axi_rid_reg;
    assign s_axi_rid = s_axi_rid_reg;
    //assign s_axi_rdata = PIPELINE_OUTPUT ? s_axi_rdata_pipe_reg : s_axi_rdata_reg;
    //assign s_axi_rdata = mram_dout;
    assign s_axi_rresp = 2'b00;
    //assign s_axi_rlast = PIPELINE_OUTPUT ? s_axi_rlast_pipe_reg : s_axi_rlast_reg;
    //assign s_axi_rvalid = PIPELINE_OUTPUT ? s_axi_rvalid_pipe_reg : s_axi_rvalid_reg;
    assign s_axi_rvalid = s_axi_rvalid_reg;
    assign rst = ~rst_b;
    assign mram_rst_b = rst_b;
    assign mram_ce_b = ~mram_ce_reg;
    assign mram_ce_reg = mram_ce_write_reg | mram_ce_read_reg;
    assign mram_we = mram_we_reg;
    //assign mram_add = mram_we? mram_add_write_reg[ADDR_WIDTH-1:3] : mram_add_read_reg[ADDR_WIDTH-1:3];
    assign selected_mram_add = mram_we? mram_add_write_reg[ADDR_WIDTH-1:3] : mram_add_read_reg[ADDR_WIDTH-1:3];
    assign mram_stripe_add_space = selected_mram_add[16:0];
    // TODO: Make it so that certain OTP addresses cannot be accessed, i.e. the trim addresses.
    assign mram_otp_space = selected_mram_add[ADDR_WIDTH-1-3];
    assign mram_stripe_sel_add = selected_mram_add[ADDR_WIDTH-1-3-1:17];
    assign mram_stripe_sel = ~mram_ce_b? (1 << mram_stripe_sel_add) : 0;
    assign mram_add = {mram_otp_space, mram_stripe_add_space};
    assign mram_din = mram_din_reg;
    assign mram_bwe = mram_bwe_reg;

    assign current_state_is_idle = current_state == IDLE;
    assign next_state_is_idle = next_state == IDLE;
    assign axi_busy = ~current_state_is_idle | ~next_state_is_idle;

    // Clock Gating
//    assign mram_clk = clk & mram_clk_gate_en_q;
//
    always_ff @(posedge clk or negedge rst_b) begin
        if (~rst_b) begin
            mram_clk_gate_en_q <= 1;
        end else begin
            mram_clk_gate_en_q <= mram_clk_gate_en_d;
        end
    end
    CKLNQD24BWP7D5T16P96CPD chipid_clk_gate (
        .CP(clk),
        .E(mram_clk_gate_en_d),
        .TE(1'b0),
        .Q(mram_clk)
    );
//    always @* begin : mram_clk_latch_gating
//        //mram_clk = clk & mram_clk_gate_en_q;
//        if (~clk)
//            mram_clk_gate_en_q <= mram_clk_gate_en_d;
//        else
//            mram_clk_gate_en_q <= mram_clk_gate_en_q;
//    end

//    logic ENL, TE;
//    assign mram_clk = mram_clk_gate_en_q & clk;
//    assign TE = 0;
//    always_latch begin
//        if (~clk)
//            mram_clk_gate_en_q <= mram_clk_gate_en_d | TE;
//    end
    //axi2mram_clk_gate clk_gate_u(.clk_in(clk), .en(mram_clk_gate_en_d), .clk_out(mram_clk));


    always @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            current_state <= IDLE;

            s_axi_awready_reg <= 1'b0;
            s_axi_wready_reg <= 1'b0;
            s_axi_bid_reg <= 8'b0;
            s_axi_bvalid_reg <= 1'b0;

            s_axi_arready_reg <= 1'b0;
            s_axi_rid_reg <= 8'b0;
            s_axi_rid_pipe0_reg <= 8'b0;
            s_axi_rdata_reg <= 64'b0;
            s_axi_rlast_reg <= 1'b0;
            s_axi_rvalid_reg <= 1'b0;
            //mram_add_write_reg <= 0;
            mram_add_write_prev <= {ADDR_WIDTH{1'b0}};
            mram_din_prev <= 64'b0;
            mram_bwe_prev <= 8'b0;
            write_id_reg <= 8'b0;
            write_count_reg <= 8'b0;
            write_size_reg <= 3'b0;
            write_burst_reg <= 2'b0;

            read_size_reg <= 3'b0;
            read_burst_reg <= 2'b0;
            read_count_reg <= 8'b0;
            mram_add_read_prev <= {ADDR_WIDTH{1'b1}};
            byte_count <= 0;
            remaining_bytes <= 0;
            read_in_pipestage_q0 <= 0;
            read_in_pipestage_q1 <= 0;
            write_flag_reg <= 0 ;
            mram_din_rmw_cap_q <= 0 ;
        end else begin
            current_state <= next_state;

            s_axi_awready_reg <= s_axi_awready_next;
            s_axi_wready_reg <= s_axi_wready_next;
            s_axi_bid_reg <= s_axi_bid_next;
            s_axi_bvalid_reg <= s_axi_bvalid_next;

            s_axi_arready_reg <= s_axi_arready_next;
            s_axi_rid_reg <= s_axi_rid_next;
            s_axi_rid_pipe0_reg <= s_axi_rid_pipe0_next;
            //s_axi_rdata_reg <= s_axi_rdata_next;
            s_axi_rlast_reg <= s_axi_rlast_next;
            s_axi_rvalid_reg <= s_axi_rvalid_next;

            //mram_add_write_reg <= mram_add_write_next;
            mram_add_write_prev <= mram_add_write_reg;
            mram_din_prev <= mram_din_reg;
            mram_bwe_prev <= mram_bwe_reg;
            write_flag_reg <= write_flag_next;
            write_id_reg <= write_id_next;
            read_size_reg <= read_size_next;
            read_burst_reg <= read_burst_next;
            read_count_reg <= read_count_next;
            write_count_reg <= write_count_next;
            write_size_reg <= write_size_next;
            write_burst_reg <= write_burst_next;

            mram_add_read_prev <= mram_add_read_reg;
            byte_count <= byte_count_next;
            remaining_bytes <= remaining_bytes_next;
            read_in_pipestage_q0 <= read_in_pipestage_d0;
            read_in_pipestage_q1 <= read_in_pipestage_d1;
            mram_din_rmw_cap_q <= mram_din_rmw_cap_d;
       end
    end

    always_comb begin
        s_axi_rlast = s_axi_rlast_reg;

        s_axi_awready_next = 1'b0;
        s_axi_wready_next = 1'b0;
        s_axi_bid_next = s_axi_bid_reg;
        s_axi_bvalid_next = s_axi_bvalid_reg && !s_axi_bready;
        s_axi_arready_next = s_axi_arready_reg;
        write_id_next = write_id_reg;
        next_state = current_state;

        s_axi_rid_next = s_axi_rid_reg;
        s_axi_rid_pipe0_next = s_axi_rid_pipe0_reg;
        s_axi_rlast_next = s_axi_rlast_reg;
        s_axi_rvalid_next = (s_axi_rvalid_reg & ~s_axi_rready);
        mram_din_reg = mram_din_prev;
        //mram_add_write_next = mram_add_write_reg;
        mram_add_write_reg = mram_add_write_prev;
        mram_ce_write_reg = 1'b0;
        mram_ce_read_reg = 1'b0;
        mram_we_reg = 1'b0;
        mram_add_read_reg = mram_add_read_prev;
        mram_clk_gate_en_d = 1;

        write_flag_next = write_flag_reg;
        read_size_next = read_size_reg;
        read_burst_next = read_burst_reg;
        read_count_next = read_count_reg;
        write_count_next = write_count_reg;
        write_size_next = write_size_reg;
        write_burst_next = write_burst_reg;
        mram_bwe_reg = mram_bwe_prev;
        remaining_bytes_next = remaining_bytes;
        mram_din_rmw_cap_d = mram_din_rmw_cap_q;
        if (s_axi_rvalid & s_axi_rready) begin
            remaining_bytes_next = remaining_bytes - unsigned'(1 << read_size_reg);
        end

        for (integer byte_i = 0; byte_i < WORD_SIZE; byte_i += 1) begin
            s_axi_rdata[8 * byte_i +: 8] = mram_dout[8 * (byte_i) +: 8];
        end

        case(current_state)
            IDLE: begin
                s_axi_arready_next = 1'b1;
                s_axi_awready_next = write_flag_reg[0]? 1'b0 : 1'b1;
                s_axi_wready_next = 1'b1;

                mram_ce_read_reg = 1'b0;
                mram_ce_write_reg = 1'b0;
                mram_we_reg = 1'b0;

                if (s_axi_arvalid & s_axi_arready) begin
                    // Grab information about the read.
                    next_state = READ_INIT;
                    mram_add_read_reg = s_axi_araddr;
                    mram_ce_read_reg = 1'b1;
                    mram_ce_write_reg = 1'b0;
                    mram_we_reg = 1'b0;
                    s_axi_rid_pipe0_next = s_axi_arid;
                    //read_size_next = s_axi_arsize < unsigned'($clog2(STRB_WIDTH)) ? s_axi_arsize : unsigned'($clog2(STRB_WIDTH));
                    read_size_next = s_axi_arsize < $clog2(STRB_WIDTH)? s_axi_arsize : $clog2(STRB_WIDTH);
                    read_burst_next = s_axi_arburst;
                    read_count_next = s_axi_arlen;
                    s_axi_awready_next = 1'b0;
                    s_axi_wready_next = 1'b0;
                    s_axi_rlast_next = 1'b0;
                    remaining_bytes_next = s_axi_arlen;

                end

                if (s_axi_awready & s_axi_awvalid) begin
                    // next_state <= WRITE;
                    mram_add_write_reg = s_axi_awaddr;
                    s_axi_awready_next = 1'b0;
                    write_flag_next[0] = 1'b1;
                    write_id_next = s_axi_awid;
                    write_count_next = s_axi_awlen;
                    write_burst_next = s_axi_awburst;
                    write_size_next = s_axi_awsize;

                end

                if (s_axi_wready & s_axi_wvalid) begin
                    write_flag_next[1] = 1'b1;
                    mram_din_reg = s_axi_wdata;
                    mram_bwe_reg = s_axi_wstrb;
                    s_axi_wready_next = 1'b0;
                end

                if (write_flag_next == 2'b11) begin
                    mram_ce_write_reg = 1'b1;
                    s_axi_arready_next = 0;
                    if (s_axi_wstrb == {STRB_WIDTH{1'b1}}) begin
                        next_state = WRITE;
                        mram_we_reg = 1'b1;
                    end else begin
                        mram_we_reg = 1'b0;
                        mram_add_read_reg = mram_add_write_reg;
                        next_state = RMW_READ;
                    end
                end
            end

            READ_INIT: begin
                // This is when we clock a read in, but it hasn't exited the pipeline yet.
                s_axi_rvalid_next = read_in_pipestage_d1;
                s_axi_rid_next = s_axi_rid_pipe0_reg;
                case (read_burst_reg)
                    2'b00: begin // Fixed
                        mram_add_read_reg = mram_add_read_prev;
                    end

                    2'b01: begin // Increment
                        if (mram_clk_gate_en_d & ~mram_ce_b)
                            mram_add_read_reg = unsigned'((mram_add_read_prev[2:0] + unsigned'(unsigned'(1 << read_size_reg) - 1))) < 8?
                                unsigned'(mram_add_read_prev + unsigned'(1 << read_size_reg)) :
                                unsigned'(mram_add_read_prev + (3'b111 ^ mram_add_read_prev[2:0]) + 1);
                        else
                            mram_add_read_reg = mram_add_read_prev;
                    end

                    2'b10: begin // Wrap


                    end

                    2'b11: begin // Reserved
                    end
                    default: begin
                    end
                endcase
                if (read_count_reg == 0)
                    s_axi_rlast = 1;
                else
                    s_axi_rlast = 0;

                mram_ce_read_reg = (read_count_reg != 0) & (~read_in_pipestage_q1 | (s_axi_rready & s_axi_rvalid));
                mram_clk_gate_en_d = ~read_in_pipestage_q1 | (s_axi_rready & s_axi_rvalid & ~s_axi_rlast);
                /*
                if ((read_count_reg <= 1 & read_in_pipestage_q1) |
                    (read_count_reg == 0 & read_in_pipestage_d1)) begin
                    s_axi_rlast_next = 1'b1;
                end else begin
                    s_axi_rlast_next = 1'b0;
                end
                */
                if (s_axi_rready & s_axi_rvalid) begin
                    // Get next read.
                    if (read_count_reg != 0) begin
                        mram_ce_read_reg = 1'b1;
                        read_count_next = read_count_reg - 1;
                    end else begin
                        // Get the last data out of the pipe.
                        mram_ce_read_reg = 1'b0;
                        s_axi_rlast_next = 1'b1;
                    end
                    if (s_axi_rlast) begin
                        next_state = IDLE;
                        s_axi_rlast_next = 1'b0;
                        s_axi_rvalid_next = 0;
                        s_axi_arready_next = 1;
                    end
                end
            end

            WRITE: begin
                write_flag_next = 1'b0;
                if (mram_busy) begin
                    //next_state = current_state;
                end else if (s_axi_bready & s_axi_bvalid) begin
                    s_axi_bvalid_next = 1'b0;
                    s_axi_wready_next = 1'b1;
                    s_axi_awready_next = 1'b1;
                    s_axi_arready_next = 1'b1;
                    next_state = IDLE;

                end else begin
                    if (!s_axi_wready && (write_count_reg != 0)) begin
                        s_axi_wready_next = 1'b1;
                    end else if (s_axi_wready & s_axi_wvalid) begin
                        write_count_next = write_count_reg - 1;
                        mram_ce_write_reg = 1'b1;
                        mram_din_reg = s_axi_wdata;
                        mram_bwe_reg = s_axi_wstrb;
                        // mram_we_reg = 1;
                        s_axi_wready_next = 1'b0;
                        //next_state = WRITE;
                        case (write_burst_reg)
                            2'b00 : begin // Fixed
                                mram_add_write_reg = mram_add_write_prev;
                            end
                            2'b01 : begin // Increment
                                mram_add_write_reg = unsigned'(unsigned'(mram_add_write_prev[2:0]) + unsigned'(unsigned'(1 << write_size_reg) - 1)) < 8?
                                    unsigned'(unsigned'(mram_add_write_prev) + unsigned'(1 << write_size_reg)) :
                                    unsigned'(unsigned'(mram_add_write_prev) + unsigned'((3'b111 ^ mram_add_write_prev[2:0])) + 1);
                            end
                            2'b10 : begin // Wrap

                            end
                            2'b11 : begin // Reserved

                            end

                        endcase
                        if (s_axi_wstrb == {STRB_WIDTH{1'b1}}) begin
                            next_state = WRITE;
                            mram_we_reg = 1'b1;
                        end else begin
                            mram_we_reg = 1'b0;
                            mram_add_read_reg = mram_add_write_reg;
                            //mram_add_read_reg = (mram_add_write_prev[2:0] + 2**write_size_reg - 1) < 8?
                            //        mram_add_write_prev + 2**write_size_reg :
                            //        mram_add_write_prev + (3'b111 ^ mram_add_write_prev[2:0]) + 1;
                            next_state = RMW_READ;
                        end
                    end else begin
                        s_axi_bid_next = write_id_reg;
                        s_axi_bvalid_next = 1'b1;
                    end
                end


            end
            RMW_READ : begin
                // Performs a single clock.
                next_state = DOUT_CAPTURE;
            end

            DOUT_CAPTURE : begin
                next_state = RMW_WRITE_SETUP;
                mram_din_rmw_cap_d = mram_dout;
            end

            RMW_WRITE_SETUP : begin
                mram_bwe_reg = {STRB_WIDTH{1'b1}};
                mram_ce_write_reg = 1'b1;
                mram_we_reg = 1'b1;
                next_state = WRITE;
                for (integer bit_i = 0; bit_i < STRB_WIDTH; bit_i += 1) begin
                    if (!mram_bwe_prev[bit_i])
                        mram_din_reg[8*bit_i +: 8] = mram_din_rmw_cap_q[bit_i*8 +: 8];

                end

            end
            default : begin
                next_state = IDLE;
            end
        endcase
//        read_in_pipestage_d0 = mram_clk_gate_en_q? ~mram_ce_b : read_in_pipestage_q0;
        read_in_pipestage_d0 = mram_clk_gate_en_d? ~mram_ce_b : read_in_pipestage_q0;
//        read_in_pipestage_d1 = mram_clk_gate_en_q? read_in_pipestage_q0 : read_in_pipestage_q1;
        read_in_pipestage_d1 = mram_clk_gate_en_d? read_in_pipestage_q0 : read_in_pipestage_q1;

    end

endmodule : axi2mram

module axi2mram_clk_gate(
    input logic clk_in,
    input logic en,
    output logic clk_out
);
    logic ENL;
    assign clk_out = ENL & clk_in;
    always_latch begin
        if (~clk_in)
            ENL = en;
    end
endmodule : axi2mram_clk_gate
