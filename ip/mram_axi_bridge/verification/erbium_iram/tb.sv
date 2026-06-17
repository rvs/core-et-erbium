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

module tb;
    localparam int DATA_WIDTH = 64;
    localparam int ADDR_WIDTH = 23;
    localparam int ID_WIDTH = 8;
    localparam int NUM_MRAM_WRAPPERS = 1 << (ADDR_WIDTH - 23);

    logic [1023:0] tb_matrix_label;
    logic [31:0]   tb_matrix_step;

    logic clk;
    logic rst_b;
    logic mram_rst_b;
    logic dsleep;
    logic nvsram_startup_bypass;
    logic cpu_intr;
    logic axi_busy;

    logic [NUM_MRAM_WRAPPERS-1:0][4:0]  MRAM_PADDR;
    logic [NUM_MRAM_WRAPPERS-1:0]       MRAM_PENABLE;
    logic [NUM_MRAM_WRAPPERS-1:0]       MRAM_PSEL;
    logic [NUM_MRAM_WRAPPERS-1:0][3:0]  MRAM_PSTRB;
    logic [NUM_MRAM_WRAPPERS-1:0][31:0] MRAM_PWDATA;
    logic [NUM_MRAM_WRAPPERS-1:0]       MRAM_PWRITE;
    logic [NUM_MRAM_WRAPPERS-1:0][31:0] MRAM_PRDATA;
    logic [NUM_MRAM_WRAPPERS-1:0]       MRAM_PREADY;

    logic [NUM_MRAM_WRAPPERS-1:0][3:0]  tp_add;
    logic [NUM_MRAM_WRAPPERS-1:0][63:0] tp_bwe;
    logic [NUM_MRAM_WRAPPERS-1:0]       tp_ce;
    logic [NUM_MRAM_WRAPPERS-1:0][63:0] tp_din;
    logic [NUM_MRAM_WRAPPERS-1:0]       tp_we;
    logic [NUM_MRAM_WRAPPERS-1:0]       tp_busy;
    logic [NUM_MRAM_WRAPPERS-1:0][63:0] tp_reg_out;
    logic [NUM_MRAM_WRAPPERS-1:0]       tp_valid;

    logic [4:0]  bank0_paddr;
    logic        bank0_penable;
    logic        bank0_psel;
    logic [3:0]  bank0_pstrb;
    logic [31:0] bank0_pwdata;
    logic        bank0_pwrite;
    logic [31:0] bank0_prdata;
    logic        bank0_pready;
    logic [3:0]  bank0_tp_add;
    logic [63:0] bank0_tp_bwe;
    logic        bank0_tp_ce;
    logic [63:0] bank0_tp_din;
    logic        bank0_tp_we;
    logic        bank0_tp_busy;
    logic [63:0] bank0_tp_reg_out;
    logic        bank0_tp_valid;

    logic [4:0]  bank1_paddr;
    logic        bank1_penable;
    logic        bank1_psel;
    logic [3:0]  bank1_pstrb;
    logic [31:0] bank1_pwdata;
    logic        bank1_pwrite;
    logic [31:0] bank1_prdata;
    logic        bank1_pready;
    logic [3:0]  bank1_tp_add;
    logic [63:0] bank1_tp_bwe;
    logic        bank1_tp_ce;
    logic [63:0] bank1_tp_din;
    logic        bank1_tp_we;
    logic        bank1_tp_busy;
    logic [63:0] bank1_tp_reg_out;
    logic        bank1_tp_valid;

    tri ANATEST0;
    tri ANATEST1;

    logic [ID_WIDTH-1:0]   s_axi_awid;
    logic [ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [7:0]            s_axi_awlen;
    logic [2:0]            s_axi_awsize;
    logic [1:0]            s_axi_awburst;
    logic                  s_axi_awlock;
    logic [3:0]            s_axi_awcache;
    logic [2:0]            s_axi_awprot;
    logic                  s_axi_awvalid;
    logic                  s_axi_awready;
    logic [DATA_WIDTH-1:0] s_axi_wdata;
    logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb;
    logic                  s_axi_wlast;
    logic                  s_axi_wvalid;
    logic                  s_axi_wready;
    logic [ID_WIDTH-1:0]   s_axi_bid;
    logic [1:0]            s_axi_bresp;
    logic                  s_axi_bvalid;
    logic                  s_axi_bready;
    logic [ID_WIDTH-1:0]   s_axi_arid;
    logic [ADDR_WIDTH-1:0] s_axi_araddr;
    logic [7:0]            s_axi_arlen;
    logic [2:0]            s_axi_arsize;
    logic [1:0]            s_axi_arburst;
    logic                  s_axi_arlock;
    logic [3:0]            s_axi_arcache;
    logic [2:0]            s_axi_arprot;
    logic                  s_axi_arvalid;
    logic                  s_axi_arready;
    logic [ID_WIDTH-1:0]   s_axi_rid;
    logic [DATA_WIDTH-1:0] s_axi_rdata;
    logic [1:0]            s_axi_rresp;
    logic                  s_axi_rlast;
    logic                  s_axi_rvalid;
    logic                  s_axi_rready;

    initial begin
        tb_matrix_label = '0;
        tb_matrix_step = '0;
    end

    always_comb begin
        MRAM_PADDR = '0;
        MRAM_PENABLE = '0;
        MRAM_PSEL = '0;
        MRAM_PSTRB = '0;
        MRAM_PWDATA = '0;
        MRAM_PWRITE = '0;
        tp_add = '0;
        tp_bwe = '0;
        tp_ce = '0;
        tp_din = '0;
        tp_we = '0;

        MRAM_PADDR[0] = bank0_paddr;
        MRAM_PENABLE[0] = bank0_penable;
        MRAM_PSEL[0] = bank0_psel;
        MRAM_PSTRB[0] = bank0_pstrb;
        MRAM_PWDATA[0] = bank0_pwdata;
        MRAM_PWRITE[0] = bank0_pwrite;
        tp_add[0] = bank0_tp_add;
        tp_bwe[0] = bank0_tp_bwe;
        tp_ce[0] = bank0_tp_ce;
        tp_din[0] = bank0_tp_din;
        tp_we[0] = bank0_tp_we;

        if (NUM_MRAM_WRAPPERS > 1) begin
            MRAM_PADDR[1] = bank1_paddr;
            MRAM_PENABLE[1] = bank1_penable;
            MRAM_PSEL[1] = bank1_psel;
            MRAM_PSTRB[1] = bank1_pstrb;
            MRAM_PWDATA[1] = bank1_pwdata;
            MRAM_PWRITE[1] = bank1_pwrite;
            tp_add[1] = bank1_tp_add;
            tp_bwe[1] = bank1_tp_bwe;
            tp_ce[1] = bank1_tp_ce;
            tp_din[1] = bank1_tp_din;
            tp_we[1] = bank1_tp_we;
        end
    end

    always_comb begin
        bank0_prdata = MRAM_PRDATA[0];
        bank0_pready = MRAM_PREADY[0];
        bank0_tp_busy = tp_busy[0];
        bank0_tp_reg_out = tp_reg_out[0];
        bank0_tp_valid = tp_valid[0];

        bank1_prdata = '0;
        bank1_pready = '0;
        bank1_tp_busy = '0;
        bank1_tp_reg_out = '0;
        bank1_tp_valid = '0;

        if (NUM_MRAM_WRAPPERS > 1) begin
            bank1_prdata = MRAM_PRDATA[1];
            bank1_pready = MRAM_PREADY[1];
            bank1_tp_busy = tp_busy[1];
            bank1_tp_reg_out = tp_reg_out[1];
            bank1_tp_valid = tp_valid[1];
        end
    end

    `ifdef DUMP_WAVES
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end
    `endif

    axi2mram_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) dut (
        .clk(clk),
        .rst_b(rst_b),
        .mram_rst_b(mram_rst_b),
        .dsleep(dsleep),
        .nvsram_startup_bypass(nvsram_startup_bypass),
        .cpu_intr(cpu_intr),
        .axi_busy(axi_busy),
        .MRAM_PADDR(MRAM_PADDR),
        .MRAM_PENABLE(MRAM_PENABLE),
        .MRAM_PSEL(MRAM_PSEL),
        .MRAM_PSTRB(MRAM_PSTRB),
        .MRAM_PWDATA(MRAM_PWDATA),
        .MRAM_PWRITE(MRAM_PWRITE),
        .MRAM_PRDATA(MRAM_PRDATA),
        .MRAM_PREADY(MRAM_PREADY),
        .tp_add(tp_add),
        .tp_bwe(tp_bwe),
        .tp_ce(tp_ce),
        .tp_din(tp_din),
        .tp_we(tp_we),
        .tp_busy(tp_busy),
        .tp_reg_out(tp_reg_out),
        .tp_valid(tp_valid),
        .ANATEST0(ANATEST0),
        .ANATEST1(ANATEST1),
        .s_axi_awid(s_axi_awid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bid(s_axi_bid),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_arid(s_axi_arid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arcache(s_axi_arcache),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rid(s_axi_rid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );
endmodule : tb
