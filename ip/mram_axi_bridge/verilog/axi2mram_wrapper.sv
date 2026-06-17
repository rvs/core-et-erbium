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

module axi2mram_wrapper #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 64,
    // Width of address bus in bits
    // ADDR_WIDTH = 23 -> 1 MRAM_WRAPPER
    // ADDR_WIDTH = 24 -> 2 MRAM_WRAPPERS
    // ADDR_WIDTH = 25 -> 4 MRAM_WRAPPERS
    parameter ADDR_WIDTH = 23,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 8,
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0,
    // Number of MRAM wrappers to instantiate
    parameter int NUM_MRAM_WRAPPERS = 1 << (ADDR_WIDTH - 23)
) (
    input  wire                     clk,
    input  wire                     rst_b,
    input  wire                     mram_rst_b,
    input  logic                    dsleep,
    input  logic                    nvsram_startup_bypass,
    output logic                    cpu_intr,
    output logic                    axi_busy,

    // ---------------------------------------------------------------------
    // APB bus signals.  Each wrapper has its own set of APB inputs and
    // outputs.  These packed arrays are indexed by wrapper number [0:N-1].
    input  logic [NUM_MRAM_WRAPPERS-1:0][4:0]   MRAM_PADDR,
    input  logic [NUM_MRAM_WRAPPERS-1:0]        MRAM_PENABLE,
    input  logic [NUM_MRAM_WRAPPERS-1:0]        MRAM_PSEL,
    input  logic [NUM_MRAM_WRAPPERS-1:0][3:0]   MRAM_PSTRB,
    input  logic [NUM_MRAM_WRAPPERS-1:0][31:0]  MRAM_PWDATA,
    input  logic [NUM_MRAM_WRAPPERS-1:0]        MRAM_PWRITE,
    output logic [NUM_MRAM_WRAPPERS-1:0][31:0]  MRAM_PRDATA,
    output logic [NUM_MRAM_WRAPPERS-1:0]        MRAM_PREADY,

    // ---------------------------------------------------------------------
    // Test port signals.  Like the APB ports, these are per‑wrapper and
    // therefore provided as packed arrays indexed by wrapper number.
    input  logic [NUM_MRAM_WRAPPERS-1:0][3:0]   tp_add,
    input  logic [NUM_MRAM_WRAPPERS-1:0][63:0]  tp_bwe,
    input  logic [NUM_MRAM_WRAPPERS-1:0]        tp_ce,
    input  logic [NUM_MRAM_WRAPPERS-1:0][63:0]  tp_din,
    input  logic [NUM_MRAM_WRAPPERS-1:0]        tp_we,
    output logic [NUM_MRAM_WRAPPERS-1:0]        tp_busy,
    output logic [NUM_MRAM_WRAPPERS-1:0][63:0]  tp_reg_out,
    output logic [NUM_MRAM_WRAPPERS-1:0]        tp_valid,

    // ---------------------------------------------------------------------
    // Analog test pins are shared between all MRAM wrappers.  Each instance
    // connects to the same ``ANATEST0`` and ``ANATEST1`` lines.
    inout  wire                     ANATEST0,
    inout  wire                     ANATEST1,

    // ---------------------------------------------------------------------
    // AXI slave interface
    input  wire [ID_WIDTH-1:0]      s_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire [7:0]               s_axi_awlen,
    input  wire [2:0]               s_axi_awsize,
    input  wire [1:0]               s_axi_awburst,
    input  wire                     s_axi_awlock,
    input  wire [3:0]               s_axi_awcache,
    input  wire [2:0]               s_axi_awprot,
    input  wire                     s_axi_awvalid,
    output wire                     s_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axi_wstrb,
    input  wire                     s_axi_wlast,
    input  wire                     s_axi_wvalid,
    output wire                     s_axi_wready,
    output wire [ID_WIDTH-1:0]      s_axi_bid,
    output wire [1:0]               s_axi_bresp,
    output wire                     s_axi_bvalid,
    input  wire                     s_axi_bready,
    input  wire [ID_WIDTH-1:0]      s_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire [7:0]               s_axi_arlen,
    input  wire [2:0]               s_axi_arsize,
    input  wire [1:0]               s_axi_arburst,
    input  wire                     s_axi_arlock,
    input  wire [3:0]               s_axi_arcache,
    input  wire [2:0]               s_axi_arprot,
    input  wire                     s_axi_arvalid,
    output wire                     s_axi_arready,
    output wire [ID_WIDTH-1:0]      s_axi_rid,
    output wire [DATA_WIDTH-1:0]    s_axi_rdata,
    output wire [1:0]               s_axi_rresp,
    output wire                     s_axi_rlast,
    output wire                     s_axi_rvalid,
    input  wire                     s_axi_rready
);

    // ---------------------------------------------------------------------
    // Local parameter definitions.  ``NUM_STRIPES`` reflects the original
    // ``mram_stripe_sel`` width used by ``axi2mram``.  The stripes are
    // divided evenly among the wrappers; users must ensure that
    // ``NUM_MRAM_WRAPPERS`` divides ``NUM_STRIPES`` for correct behaviour.
    localparam int STRIPES_PER_WRAPPER = 4;
    localparam int NUM_STRIPES = (NUM_MRAM_WRAPPERS * STRIPES_PER_WRAPPER);

    // ---------------------------------------------------------------------
    // Signals to/from the AXI2MRAM front end.

    logic [DATA_WIDTH-1:0]              mram_din;
    logic [STRB_WIDTH-1:0]              mram_bwe;
    logic [17:0]                        mram_add;
    logic [NUM_STRIPES-1:0]  mram_stripe_sel;
    logic [DATA_WIDTH-1:0]              mram_dout;
    logic                               mram_clk;
    logic                               mram_we;
    logic                               axi2mram_rst_b;
    logic                               mram_busy;

    // Per‑wrapper signals for read data, busy flags and interrupts.  The
    // top‑level outputs are reduced across these arrays.
    logic [NUM_MRAM_WRAPPERS-1:0][DATA_WIDTH-1:0] mram_dout_array;
    logic [NUM_MRAM_WRAPPERS-1:0]                  mram_busy_array;
    logic [NUM_MRAM_WRAPPERS-1:0]                  mram_cpu_intr_array;

    // Combine interrupt requests from all wrappers.
    assign cpu_intr = |mram_cpu_intr_array;
    // Combine busy flags from all wrappers.
    assign mram_busy = |mram_busy_array;

    // ---------------------------------------------------------------------
    // Generate logic to OR all read data buses from the wrappers into
    // ``mram_dout``.  SystemVerilog does not provide a direct reduction
    // operator across an array of vectors, so an ``always_comb`` block
    // performs the bitwise OR over the outer dimension.
    always_comb begin
        mram_dout = '0;
        for (int j = 0; j < NUM_MRAM_WRAPPERS; j = j + 1) begin
            mram_dout |= mram_dout_array[j];
        end
    end

    `ifdef DUMP_WAVES
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, axi2mram_wrapper);
    end
    `endif
    axi2mram #(
        .DATA_WIDTH(DATA_WIDTH),
    // Width of address bus in bits, for words.
        .ADDR_WIDTH(ADDR_WIDTH),
    // Width of wstrb (width of data bus in words)
        .STRB_WIDTH(DATA_WIDTH/8),
    // Width of ID signal
        .ID_WIDTH(ID_WIDTH),
    // Extra pipeline register on output
        .PIPELINE_OUTPUT(PIPELINE_OUTPUT)
    ) axi2mram (
        .clk(clk),
        .rst_b(rst_b),
        .axi_busy(axi_busy),

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
        .s_axi_rready(s_axi_rready),

        .mram_din(mram_din),
        .mram_bwe(mram_bwe),
        .mram_add(mram_add),
        .mram_dout(mram_dout),
        .mram_clk(mram_clk),
        .mram_stripe_sel(mram_stripe_sel),
        .mram_we(mram_we),
        .mram_rst_b(axi2mram_rst_b),
        .mram_busy(mram_busy)
    );

    // ---------------------------------------------------------------------
    // Generate ``NUM_MRAM_WRAPPERS`` instances of ``mram_wrapper``.  Each
    // wrapper is allocated a slice of the ``mram_stripe_sel`` bus.  The
    // per‑wrapper APB and test‑port signals are wired to their respective
    // array elements.
    generate
        genvar i;
        for (i = 0; i < NUM_MRAM_WRAPPERS; i = i + 1) begin : mram_wrappers
            mram_wrapper #(
                .BANK_ID(i)
            ) u_mram_wrapper (
                .clk           (mram_clk),
                .rst_b         (axi2mram_rst_b & mram_rst_b),
                .dsleep        (dsleep),
                .nvsram_startup_bypass(nvsram_startup_bypass),

                // APB signals for wrapper i
                .PADDR         (MRAM_PADDR[i]),
                .PENABLE       (MRAM_PENABLE[i]),
                .PSEL          (MRAM_PSEL[i]),
                .PSTRB         (MRAM_PSTRB[i]),
                .PWDATA        (MRAM_PWDATA[i]),
                .PWRITE        (MRAM_PWRITE[i]),
                .PRDATA        (MRAM_PRDATA[i]),
                .PREADY        (MRAM_PREADY[i]),

                // AXI‑side signals shared across wrappers
                .axi_add       (mram_add),
                .axi_stripe_sel(mram_stripe_sel[(i+1)*STRIPES_PER_WRAPPER - 1 -: STRIPES_PER_WRAPPER]),
                .axi_bwe       (mram_bwe),
                .axi_din       (mram_din),
                .axi_we        (mram_we),
                .axi_dout      (mram_dout_array[i]),
                .axi_busy      (mram_busy_array[i]),

                // Test port signals for wrapper i
                .tp_add        (tp_add[i]),
                .tp_bwe        (tp_bwe[i]),
                .tp_ce         (tp_ce[i]),
                .tp_din        (tp_din[i]),
                .tp_we         (tp_we[i]),
                .tp_busy       (tp_busy[i]),
                .tp_reg_out    (tp_reg_out[i]),
                .tp_valid      (tp_valid[i]),

                // Interrupt output for wrapper i
                .cpu_intr      (mram_cpu_intr_array[i]),

                // Shared analog test pins
                .vdd           (1'b1),
                .vdd18         (1'b1),
                .vss           (1'b0),
                .ANATEST0      (ANATEST0),
                .ANATEST1      (ANATEST1)
            );
        end
    endgenerate


endmodule : axi2mram_wrapper
