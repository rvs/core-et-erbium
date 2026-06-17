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

`timescale 1ns/1ps

module erbium_et_instance  #(
        parameter  ADDR_WIDTH          =    17,      //
        parameter  COL_ADDR_WIDTH      =     4,
        //parameter  ROW_ADDR_WIDTH      =     9,
        parameter  PLANE_ADDR_WIDTH    =     3,
        parameter  RESERVE_ADDR_WIDTH  =     1,
        parameter  NUM_RESERVED_ROWS   =    13,
        parameter  DATA_WIDTH          =    64,
        parameter  READ_DELAY          =     3.000,  // in nanoseconds
        parameter  READ_JITTER         =    50,      // in picoseconds
        parameter  WRITE_DELAY         =    15.000,  // in nanoseconds
        parameter  WRITE_JITTER        =  2000.0     // in picoseconds
    )
    (
        input   logic                      rst_b_i,
        input   logic                      clk_i,
        input   logic                      ce_i,
        input   logic                      we_i,
        input   logic  [(ADDR_WIDTH-1):0]  addr_i,
        input   logic  [(DATA_WIDTH-1):0]  din_i,
        input   logic  [(DATA_WIDTH-1):0]  bwe_i,
        input   logic                      dout_en_i,
        input   logic                      ref_prg_en,
        output  logic  [(DATA_WIDTH-1):0]  dout_o,
        output  logic                      busy_o
    );

    localparam  NORM_ROW_ADDR_WIDTH  =  ADDR_WIDTH - RESERVE_ADDR_WIDTH - PLANE_ADDR_WIDTH - COL_ADDR_WIDTH;  //      9
    localparam  WORDS_PER_ROW        =  2 ** COL_ADDR_WIDTH;                                                  //     16
    localparam  ROWS_PER_PLANE       =  (2 ** NORM_ROW_ADDR_WIDTH) + NUM_RESERVED_ROWS;                       //    525
    localparam  NUM_RESERVED_WORDS   =  NUM_RESERVED_ROWS * WORDS_PER_ROW;                                    //    208
    localparam  WORDS_PER_PLANE      =  (WORDS_PER_ROW * ROWS_PER_PLANE);                                     //   8400

    localparam  PLANE_ADD_SHIFT      =  NORM_ROW_ADDR_WIDTH + COL_ADDR_WIDTH;                                 //     13
    localparam  PLANE_ADD_MASK       =  (2 ** PLANE_ADDR_WIDTH) - 1;                                          //      7
    localparam  ROW_ADDR_WIDTH       =  RESERVE_ADDR_WIDTH  +  NORM_ROW_ADDR_WIDTH  +  COL_ADDR_WIDTH;        //     14
    localparam  NORMAL_ADD_MASK      =  (2 ** PLANE_ADD_SHIFT) - 1;                                           // 0x1FFF
    localparam  RR_OTP_SEL_SHIFT     =  PLANE_ADDR_WIDTH + NORM_ROW_ADDR_WIDTH + COL_ADDR_WIDTH;              //     16
    localparam  RR_OTP_SEL_MASK      =  (2 ** RESERVE_ADDR_WIDTH) - 1;                                        //      1

    localparam  MAX_PLANE_ADDR       =  WORDS_PER_PLANE - 1;                                                  //   8399

    localparam  NUM_PLANES           =  2 ** PLANE_ADDR_WIDTH;                                                //      8
    localparam  READ_JITTER_I        =  READ_JITTER;
    localparam  WRITE_JITTER_I       =  int'(WRITE_JITTER);

    realtime  read_busy_delay        =  READ_DELAY * 1ns;
    int       read_busy_jitter;
    realtime  read_busy_latency;
    realtime  write_busy_delay       =  WRITE_DELAY * 1ns;
    int       write_busy_jitter;
    realtime  write_busy_latency;

    // Simulation-only knob: delay only the visible write busy rise by this
    // many picoseconds after write launch. Default is 0 (original behavior).
    // Set via plusarg, e.g. +mram_write_busy_rise_delay_ps=800, or by
    // cocotb through this VPI-visible logic signal at runtime.
    logic [31:0]                        write_busy_rise_delay_ps = 32'd0;
    int                                 write_busy_rise_delay_plusarg_ps;

    typedef  enum {
        memReady,
        ReadBusyWait
    }  mem_state_e;

    mem_state_e  mem_state_d;
    mem_state_e  mem_state_q;

    logic                               read_busy_trigger_d;
    logic                               read_busy;
    logic                               write_busy_trigger_d;
    logic                               write_busy;
    logic                               write_busy_out;

    logic                               input_reg_en;

    logic   [(DATA_WIDTH-1):0]          memory_q         [(NUM_PLANES-1):0][MAX_PLANE_ADDR:0] = '{
        default: '0
    };
    logic   [(DATA_WIDTH-1):0]          reference_q      [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0] = '{
        default: 'h5555_5555_5555_5555_5555
    };
    byte unsigned                       ref_rh0          [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0];
    byte unsigned                       ref_rh1          [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0];
    byte unsigned                       rh0              [(NUM_PLANES-1):0][MAX_PLANE_ADDR:0];
    byte unsigned                       rh1              [(NUM_PLANES-1):0][MAX_PLANE_ADDR:0];
    byte unsigned                       rh2              [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0] = '{
        default: 'd39
    };

    // VPI-visible mirrors for cocotb/debug. Keep behavioral storage on
    // `byte unsigned` so the model behavior remains unchanged.
    logic   [7:0]                       ref_rh0_dbg      [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0];
    logic   [7:0]                       ref_rh1_dbg      [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0];
    logic   [7:0]                       rh0_dbg          [(NUM_PLANES-1):0][MAX_PLANE_ADDR:0];
    logic   [7:0]                       rh1_dbg          [(NUM_PLANES-1):0][MAX_PLANE_ADDR:0];
    logic   [7:0]                       rh2_dbg          [(NUM_PLANES-1):0][ROWS_PER_PLANE-1:0] = '{
        default: 'd39
    };

    logic   [(DATA_WIDTH-1):0]          read_value;
    logic   [(DATA_WIDTH-1):0]          dout_st1;

    logic   [(ADDR_WIDTH-1):0]          addr_q;

    logic   [(PLANE_ADDR_WIDTH-1):0]    plane_address;
    logic   [(ROW_ADDR_WIDTH-1):0]      row_address;

    logic   [(PLANE_ADDR_WIDTH-1):0]    plane_address_q;
    logic   [(ROW_ADDR_WIDTH-1):0]      row_address_q;

    logic                               dout_drv_rst;

    logic                               dout_drv_en_d;
    logic                               dout_drv_en_q;
    logic                               dout_drv_en;

    logic                               write_enable;
    logic   [(DATA_WIDTH-1):0]          reference_word_next;
    int unsigned                        target_wordline;

    initial begin : init_write_busy_rise_delay
        // Pick up the optional plusarg before any clocked activity so the
        // first write sees the configured visible busy delay.
        if ($value$plusargs("mram_write_busy_rise_delay_ps=%0d", write_busy_rise_delay_plusarg_ps)) begin
            if (write_busy_rise_delay_plusarg_ps < 0) begin
                $display("[WARN] mram_write_busy_rise_delay_ps=%0d < 0, clamping to 0", write_busy_rise_delay_plusarg_ps);
                write_busy_rise_delay_ps = 32'd0;
            end else begin
                write_busy_rise_delay_ps = write_busy_rise_delay_plusarg_ps[31:0];
            end
        end
    end

    initial begin : init_rh_arrays
        int plane_idx;
        int row_idx;
        int col_idx;

        for (plane_idx = 0; plane_idx < NUM_PLANES; plane_idx++) begin
            // Include MAX_PLANE_ADDR so the top OTP word (e.g. row_address=0x20cf)
            // gets initialized too.
            for (row_idx = 0; row_idx < ROWS_PER_PLANE; row_idx++) begin
                ref_rh0[plane_idx][row_idx] = $urandom_range(30, 10);
                ref_rh1[plane_idx][row_idx] = $urandom_range(68, 48);
                ref_rh0_dbg[plane_idx][row_idx] = ref_rh0[plane_idx][row_idx];
                ref_rh1_dbg[plane_idx][row_idx] = ref_rh1[plane_idx][row_idx];
                for (col_idx = 0; col_idx < WORDS_PER_ROW; col_idx++) begin
                    rh0[plane_idx][(row_idx << 4) + col_idx] = $urandom_range(30, 10);
                    rh1[plane_idx][(row_idx << 4) + col_idx] = $urandom_range(68, 48);
                    rh0_dbg[plane_idx][(row_idx << 4) + col_idx] = rh0[plane_idx][(row_idx << 4) + col_idx];
                    rh1_dbg[plane_idx][(row_idx << 4) + col_idx] = rh1[plane_idx][(row_idx << 4) + col_idx];
                end
            end
        end
    end

    function automatic byte unsigned count_ones(input logic [(DATA_WIDTH-1):0] value);
        int i;
        byte unsigned count;
        begin
            count = '0;
            for (i = 0; i < DATA_WIDTH; i++) begin
                if (value[i]) begin
                    count = count + 1;
                end
            end
            return count;
        end
    endfunction

    always_comb begin
        mem_state_d           =  memReady;
        input_reg_en          =  1'b0;
        read_busy_trigger_d   =  1'b0;
        write_busy_trigger_d  =  1'b0;
        write_enable          =  1'b0;
        dout_drv_en_d         =  1'b0;

        case (mem_state_q)
            memReady  :  begin
                if ((!busy_o) && (ce_i)) begin
                    if (we_i) begin
                        mem_state_d           =  memReady;
                        write_busy_trigger_d  =  1'b1;
                        write_enable          =  1'b1;
                    end else begin
                        mem_state_d           =  ReadBusyWait;
                        input_reg_en          =  1'b1;
                        read_busy_trigger_d   =  1'b1;
                    end
                end
            end
            ReadBusyWait  :  begin
                if (!busy_o) begin
                    if (dout_en_i) begin
                        dout_drv_en_d  =  1'b1;
                        if (ce_i) begin
                            if (we_i) begin
                                mem_state_d           =  memReady;
                                write_busy_trigger_d  =  1'b1;
                                write_enable          =  1'b1;
                            end else begin
                                mem_state_d           =  ReadBusyWait;
                                input_reg_en          =  1'b1;
                                read_busy_trigger_d   =  1'b1;
                            end
                        end else begin
                            mem_state_d    =  memReady;
                        end
                    end else begin
                        mem_state_d    =  ReadBusyWait;
                    end
                end else begin
                    mem_state_d    =  ReadBusyWait;
                    dout_drv_en_d  =  1'b0;
                end
            end
            default       :  begin
                mem_state_d  =  memReady;
            end
        endcase
    end

    always_ff @(negedge rst_b_i or posedge clk_i) begin
        if (!rst_b_i) begin
            mem_state_q           <=  memReady;
            addr_q                <=  {ADDR_WIDTH{1'b0}};
        end else begin
            mem_state_q           <=  mem_state_d;
            if (input_reg_en == 1'b1) begin
                addr_q            <=  addr_i;
            end
        end
    end

    always @(negedge rst_b_i or posedge clk_i) begin
        if (!rst_b_i) begin
            read_busy   <=  1'b0;
        end else if (read_busy_trigger_d == 1'b1) begin
            read_busy_jitter     =  int'($urandom_range(0, 2 * READ_JITTER_I)) - READ_JITTER_I;
            read_busy_latency    =  read_busy_delay + read_busy_jitter * 1ps;
            read_busy                       <=  1'b1;
            #read_busy_latency  read_busy   <=  1'b0;
            //
        end
    end

    always @(negedge rst_b_i or posedge clk_i) begin
        if (!rst_b_i) begin
            write_busy   <=  1'b0;
        end else if (write_busy_trigger_d == 1'b1) begin
            write_busy_jitter     =  int'($urandom_range(0, 2 * WRITE_JITTER_I)) - WRITE_JITTER_I;
            write_busy_latency    =  write_busy_delay + write_busy_jitter * 1ps;
            //write_busy_latency    =  15.020;
            write_busy                        <=  1'b1;
            #write_busy_latency  write_busy   <=  1'b0;
            //
        end
    end

    always @(negedge rst_b_i or clk_i) begin
        if (!rst_b_i) begin
            write_busy_out  <=  1'b0;
        end else begin
            if (clk_i == 1) begin
                if (write_busy_trigger_d) begin
                    if (write_busy_rise_delay_ps != 32'd0) begin
                        #(int'(write_busy_rise_delay_ps) * 1ps) write_busy_out  <=  1'b1;
                    end else begin
                        write_busy_out  <=  1'b1;
                    end
                end else if (!write_busy) begin
                end
            end else if (clk_i == 0) begin
                if (write_busy_trigger_d) begin
                end else if (!write_busy) begin
                    write_busy_out  <=  1'b0;
                end
            end
        end
    end


    assign  busy_o         =  write_busy_out  |  read_busy;

    assign  plane_address  =  (addr_i >> PLANE_ADD_SHIFT)  & PLANE_ADD_MASK;
    assign  row_address    =  (((addr_i >> RR_OTP_SEL_SHIFT) & RR_OTP_SEL_MASK) << PLANE_ADD_SHIFT) | (addr_i & NORMAL_ADD_MASK);

    always @(posedge clk_i) begin
        //
        //  Write operation
        //
        if (write_enable == 1'b1) begin
            assert (row_address <= MAX_PLANE_ADDR)
            else $error("FAILED : Access to reserved address space out of range :: Address 0x%0h > MAX Value 0x%0h at time %0t.", row_address, MAX_PLANE_ADDR, $time);
            if (ref_prg_en) begin
                target_wordline = row_address >> COL_ADDR_WIDTH;
                reference_word_next = (reference_q[plane_address][target_wordline] & ~bwe_i) | (din_i & bwe_i);

                reference_q[plane_address][target_wordline] <= reference_word_next;
                rh2[plane_address][target_wordline] <= count_ones(reference_word_next);
                rh2_dbg[plane_address][target_wordline] <= count_ones(reference_word_next);
            end else begin
                memory_q[plane_address][row_address]  <=  (memory_q[plane_address][row_address] & ~bwe_i) | (din_i & bwe_i);
            end
        end
    end

    assign  plane_address_q  =  (addr_q >> PLANE_ADD_SHIFT)  & PLANE_ADD_MASK;
    assign  row_address_q    =  (((addr_q >> RR_OTP_SEL_SHIFT) & RR_OTP_SEL_MASK) << PLANE_ADD_SHIFT) | (addr_q & NORMAL_ADD_MASK);

    always_ff @(negedge rst_b_i or negedge read_busy) begin
        //
        //  Read Operation
        //
        if (!rst_b_i) begin
            read_value  <=  {DATA_WIDTH{1'b0}};
        end else begin
            assert (row_address_q <= MAX_PLANE_ADDR)
            else $error("FAILED : Access to reserved address space out of range :: Address 0x%0h > MAX Value 0x%0h at time %0t.", row_address_q, MAX_PLANE_ADDR, $time);
            if (ref_prg_en && (rh2[plane_address_q][row_address_q >> COL_ADDR_WIDTH] < ref_rh0[plane_address_q][row_address_q >> COL_ADDR_WIDTH])) begin
                read_value <= {DATA_WIDTH{1'b1}};
            end else if (ref_prg_en && (rh2[plane_address_q][row_address_q >> COL_ADDR_WIDTH] > ref_rh1[plane_address_q][row_address_q >> COL_ADDR_WIDTH])) begin
                read_value <= {DATA_WIDTH{1'b0}};
            end else if (!ref_prg_en && (rh2[plane_address_q][row_address_q >> COL_ADDR_WIDTH] < rh0[plane_address_q][row_address_q])) begin
                read_value <= {DATA_WIDTH{1'b1}};
            end else if (!ref_prg_en && (rh2[plane_address_q][row_address_q >> COL_ADDR_WIDTH] > rh1[plane_address_q][row_address_q]) ) begin
                read_value <= {DATA_WIDTH{1'b0}};
            end else if (ref_prg_en) begin
                    read_value <= reference_q[plane_address_q ^ 1][row_address_q >> COL_ADDR_WIDTH];
            end else begin
                read_value  <=  memory_q[plane_address_q][row_address_q];
            end
        end
    end

    assign  dout_drv_rst  =  ~rst_b_i  |  ~clk_i;

    always_ff @(posedge dout_drv_rst or posedge clk_i) begin
        if (dout_drv_rst) begin
            dout_drv_en_q   <=  1'b0;
            dout_st1        <=  {DATA_WIDTH{1'b0}};
        end else begin
            dout_drv_en_q   <=  dout_drv_en_d;
            dout_st1        <=  read_value;
        end
    end

    always @(*) begin
        //
        //  Output operation
        //
        if (dout_drv_en_q == 1'b1) begin
            dout_o  =  dout_st1;
        end else begin
            dout_o  =  {DATA_WIDTH{1'b0}};
        end

    end

endmodule : erbium_et_instance
