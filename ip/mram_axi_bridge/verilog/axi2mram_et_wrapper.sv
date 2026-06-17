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

module axi2mram_et_wrapper #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 512,
    // Width of address bus in bits
    // ADDR_WIDTH = 23 -> 1 MRAM_WRAPPER
    // ADDR_WIDTH = 24 -> 2 MRAM_WRAPPERS
    // ADDR_WIDTH = 25 -> 4 MRAM_WRAPPERS
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 9,
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0,
    // Number of MRAM banks to instantiate
    parameter int NUM_MRAM_BANKS = 4
) (
    input  wire                     reg_clk,
    input  wire                     reg_rst_b,
    input  wire                     clk,
    input  wire                     rst_b,
    input  wire                     mram_rst_b,
    input  logic                    dsleep,
    input  logic                    nvsram_startup_bypass,
    output logic                    cpu_intr,
    output logic                    axi_busy,
    output logic [NUM_MRAM_BANKS-1:0] mram_ready,

    // ---------------------------------------------------------------------
    // The AXI4 Lite Interface that is being used to access all the test
    //  registers for each of the banks. This address space is only 0x1000
    //  in size, and is addressed in the following way:
    //    - MRAM_Controller_Test_Regs block0_tregs @ 0x0000
    //    - MRAM_Controller_Test_Regs block1_tregs @ 0x0100
    //    - MRAM_Controller_Test_Regs block2_tregs @ 0x0200
    //    - MRAM_Controller_Test_Regs block3_tregs @ 0x0300

    output logic            s_axil_treg_awready,
    input  wire             s_axil_treg_awvalid,
    input  wire  [10:0]     s_axil_treg_awaddr,
    input  wire  [2:0]      s_axil_treg_awprot,
    output logic            s_axil_treg_wready,
    input  wire             s_axil_treg_wvalid,
    input  wire  [63:0]     s_axil_treg_wdata,
    input  wire  [7:0]      s_axil_treg_wstrb,
    input  wire             s_axil_treg_bready,
    output logic            s_axil_treg_bvalid,
    output logic [1:0]      s_axil_treg_bresp,
    output logic            s_axil_treg_arready,
    input  wire             s_axil_treg_arvalid,
    input  wire  [10:0]      s_axil_treg_araddr,
    input  wire  [2:0]      s_axil_treg_arprot,
    input  wire             s_axil_treg_rready,
    output logic            s_axil_treg_rvalid,
    output logic [63:0]     s_axil_treg_rdata,
    output logic [1:0]      s_axil_treg_rresp,


    // ---------------------------------------------------------------------
    // Analog test pins are shared between all MRAM wrappers.  Each instance
    // connects to the same ``ANATEST0`` and ``ANATEST1`` lines.
    // TODO: This wrapper is currently only observing these pins, so VCS coerces
    // them to inputs. Either keep them as plain inputs here or hook up a real
    // bidirectional analog/test path at the parent level.
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
    input  wire [3:0]               s_axi_awqos,
    input  wire [3:0]               s_axi_awregion,
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
    input  wire [3:0]               s_axi_arqos,
    input  wire [3:0]               s_axi_arregion,

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
    // Signals to/from the AXI2MRAM front end.
    localparam MRAM_DATA_WIDTH = 64;
    localparam MRAM_DOUT_WIDTH = 128;
    logic [MRAM_DATA_WIDTH-1:0] mram_din            [NUM_MRAM_BANKS];
    logic [MRAM_DATA_WIDTH-1:0] mram_bwe            [NUM_MRAM_BANKS];
    logic [16:0]                mram_addr           [NUM_MRAM_BANKS];
    logic [MRAM_DOUT_WIDTH-1:0] mram_dout           [NUM_MRAM_BANKS];
    logic                       mram_clk            [NUM_MRAM_BANKS];
    logic                       mram_we             [NUM_MRAM_BANKS];
    logic [7:0]                 mram_ce             [NUM_MRAM_BANKS];
    logic                       mram_pwr_ok         [NUM_MRAM_BANKS];
    logic                       mram_maintenance    [NUM_MRAM_BANKS];
    logic [1:0]                 mram_ecc_single_error [NUM_MRAM_BANKS];
    logic [1:0]                 mram_ecc_double_error [NUM_MRAM_BANKS];
    logic [1:0]                 mram_ecc_triple_error [NUM_MRAM_BANKS];
    logic                       axi2mram_rst_b      [NUM_MRAM_BANKS];
    logic [7:0]                 mram_busy           [NUM_MRAM_BANKS];
    logic [7:0]                 mram_dout_en        [NUM_MRAM_BANKS];
    logic                       mram_cpu_intr       [NUM_MRAM_BANKS];
    // Per-wrapper signals for interrupts (unused for banks 1-N; bank 0 uses wrapper directly).
    import axi2mram_bridge_registers_pkg::*;
    axi2mram_bridge_registers_pkg::axi2mram_bridge_registers__in_t bridge_reg_in;
    axi2mram_bridge_registers_pkg::axi2mram_bridge_registers__out_t bridge_reg_out;

    logic [1:0] axi2mram_arbiter_mode;
    logic [3:0] axi2mram_disable_clock_gate;
    logic [2:0] axi2mram_ecc_disable_bit;
    assign cpu_intr = mram_cpu_intr[0] |  mram_cpu_intr[1] |  mram_cpu_intr[2] |  mram_cpu_intr[3];
    assign axi2mram_arbiter_mode       = bridge_reg_out.bridge_regs.arbiter_mode_reg.arbiter_mode.value;
    assign axi2mram_disable_clock_gate = bridge_reg_out.bridge_regs.control_reg.disable_clock_gate.value;
    assign axi2mram_ecc_disable_bit    = {
        bridge_reg_out.bridge_regs.control_reg.ecc_3bit_intr_mask.value,
        bridge_reg_out.bridge_regs.control_reg.ecc_2bit_intr_mask.value,
        bridge_reg_out.bridge_regs.control_reg.ecc_1bit_intr_mask.value
    };
    // Intermediate wires for the mkAxi2Mram regs sub-interface outputs.
    logic        regs_axi_busy;
    logic [3:0]  regs_cmd_queue_active;
    logic        regs_oor_write_hwset;
    logic        regs_oor_read_hwset;
    logic        regs_mram_not_ready_hwset;
    logic        regs_mram_unpowered_hwset;
    logic        regs_maintenance_hwset;
    logic        regs_unrecoverable_error_hwset;
    logic [7:0]  ecc_1bit_lane_bits;
    logic [7:0]  ecc_2bit_lane_bits;
    logic [7:0]  ecc_3bit_lane_bits;
    logic [3:0]  ecc_1bit_inc;
    logic [3:0]  ecc_2bit_inc;
    logic [3:0]  ecc_3bit_inc;

    function automatic [3:0] popcount8(input logic [7:0] bits);
        integer i;
        begin
            popcount8 = 4'd0;
            for (i = 0; i < 8; i = i + 1) begin
                popcount8 = popcount8 + {3'b000, bits[i]};
            end
        end
    endfunction

    always_ff @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            ecc_1bit_lane_bits <= '0;
            ecc_2bit_lane_bits <= '0;
            ecc_3bit_lane_bits <= '0;
        end else begin
            ecc_1bit_lane_bits <= {
                mram_ecc_single_error[3][1], mram_ecc_single_error[3][0],
                mram_ecc_single_error[2][1], mram_ecc_single_error[2][0],
                mram_ecc_single_error[1][1], mram_ecc_single_error[1][0],
                mram_ecc_single_error[0][1], mram_ecc_single_error[0][0]
            };
            ecc_2bit_lane_bits <= {
                mram_ecc_double_error[3][1], mram_ecc_double_error[3][0],
                mram_ecc_double_error[2][1], mram_ecc_double_error[2][0],
                mram_ecc_double_error[1][1], mram_ecc_double_error[1][0],
                mram_ecc_double_error[0][1], mram_ecc_double_error[0][0]
            };
            ecc_3bit_lane_bits <= {
                mram_ecc_triple_error[3][1], mram_ecc_triple_error[3][0],
                mram_ecc_triple_error[2][1], mram_ecc_triple_error[2][0],
                mram_ecc_triple_error[1][1], mram_ecc_triple_error[1][0],
                mram_ecc_triple_error[0][1], mram_ecc_triple_error[0][0]
            };
        end
    end

    always_comb begin
        ecc_1bit_inc = popcount8(ecc_1bit_lane_bits);
        ecc_2bit_inc = popcount8(ecc_2bit_lane_bits);
        ecc_3bit_inc = popcount8(ecc_3bit_lane_bits);
    end

    axi2mram_bridge_registers axi2mram_bridge_registers (
        .clk                (clk),
        .arst_n             (rst_b),
        .s_axil_awready     (s_axil_treg_awready),
        .s_axil_awvalid     (s_axil_treg_awvalid),
        .s_axil_awaddr      (s_axil_treg_awaddr),
        .s_axil_awprot      (s_axil_treg_awprot),
        .s_axil_wready      (s_axil_treg_wready),
        .s_axil_wvalid      (s_axil_treg_wvalid),
        .s_axil_wdata       (s_axil_treg_wdata),
        .s_axil_wstrb       (s_axil_treg_wstrb),
        .s_axil_bready      (s_axil_treg_bready),
        .s_axil_bvalid      (s_axil_treg_bvalid),
        .s_axil_bresp       (s_axil_treg_bresp),
        .s_axil_arready     (s_axil_treg_arready),
        .s_axil_arvalid     (s_axil_treg_arvalid),
        .s_axil_araddr      (s_axil_treg_araddr),
        .s_axil_arprot      (s_axil_treg_arprot),
        .s_axil_rready      (s_axil_treg_rready),
        .s_axil_rvalid      (s_axil_treg_rvalid),
        .s_axil_rdata       (s_axil_treg_rdata),
        .s_axil_rresp       (s_axil_treg_rresp),
        .hwif_in            (bridge_reg_in),
        .hwif_out           (bridge_reg_out)
    );

    // Connect bridge regs sub-interface outputs to the wrapper output and hwif_in struct.
    // axi_busy and cmd_queue_active are hw=w with no write-enable: always-update from .next.
    assign axi_busy = regs_axi_busy;
    assign bridge_reg_in.bridge_regs.bridge_status_reg.axi_busy.next         = regs_axi_busy;
    assign bridge_reg_in.bridge_regs.bridge_status_reg.cmd_queue_active.next = regs_cmd_queue_active;
    assign bridge_reg_in.bridge_regs.bridge_status_reg.mram_ready.next       = mram_ready;
    // RDL counters: preserve current value on .next and drive variable increment
    // amount (0..8 events/cycle) through .incr/.incrvalue.
    assign bridge_reg_in.bridge_regs.ecc_1bit_error_count_reg.count.next      =
        bridge_reg_out.bridge_regs.ecc_1bit_error_count_reg.count.value;
    assign bridge_reg_in.bridge_regs.ecc_1bit_error_count_reg.count.incr      = (ecc_1bit_inc != 4'd0);
    assign bridge_reg_in.bridge_regs.ecc_1bit_error_count_reg.count.incrvalue = ecc_1bit_inc;

    assign bridge_reg_in.bridge_regs.ecc_2bit_error_count_reg.count.next      =
        bridge_reg_out.bridge_regs.ecc_2bit_error_count_reg.count.value;
    assign bridge_reg_in.bridge_regs.ecc_2bit_error_count_reg.count.incr      = (ecc_2bit_inc != 4'd0);
    assign bridge_reg_in.bridge_regs.ecc_2bit_error_count_reg.count.incrvalue = ecc_2bit_inc;

    assign bridge_reg_in.bridge_regs.ecc_3bit_error_count_reg.count.next      =
        bridge_reg_out.bridge_regs.ecc_3bit_error_count_reg.count.value;
    assign bridge_reg_in.bridge_regs.ecc_3bit_error_count_reg.count.incr      = (ecc_3bit_inc != 4'd0);
    assign bridge_reg_in.bridge_regs.ecc_3bit_error_count_reg.count.incrvalue = ecc_3bit_inc;
    // oor_write / oor_read use hw=r; hwset — no .next in input struct.
    // Generated logic holds by default; hwset sets, SW clear-on-read clears.
    assign bridge_reg_in.bridge_regs.slverr_status_reg.oor_write.hwset = regs_oor_write_hwset;
    assign bridge_reg_in.bridge_regs.slverr_status_reg.oor_read.hwset  = regs_oor_read_hwset;
    assign bridge_reg_in.bridge_regs.slverr_status_reg.mram_not_ready.hwset = regs_mram_not_ready_hwset;
    assign bridge_reg_in.bridge_regs.slverr_status_reg.mram_unpowered.hwset = regs_mram_unpowered_hwset;
    assign bridge_reg_in.bridge_regs.slverr_status_reg.maintenance.hwset = regs_maintenance_hwset;
    assign bridge_reg_in.bridge_regs.slverr_status_reg.unrecoverable_error.hwset = regs_unrecoverable_error_hwset;

    mkAxi2Mram axi2mram (
        .regs_axi_busy_o                (regs_axi_busy                  ), // O     1
        .regs_cmd_queue_active_o        (regs_cmd_queue_active          ), // O     4
        .regs_oor_write_hwset_o         (regs_oor_write_hwset           ), // O     1 pulse
        .regs_oor_read_hwset_o          (regs_oor_read_hwset            ), // O     1 pulse
        .regs_mram_not_ready_hwset_o    (regs_mram_not_ready_hwset      ), // O     1 pulse
        .regs_mram_unpowered_hwset_o    (regs_mram_unpowered_hwset      ), // O     1 pulse
        .regs_maintenance_hwset_o       (regs_maintenance_hwset         ), // O     1 pulse
        .regs_unrecoverable_error_hwset_o(regs_unrecoverable_error_hwset), // O     1 pulse
        .axi_slave_awready              (s_axi_awready                  ), // O     1 reg
        .axi_slave_wready               (s_axi_wready                   ), // O     1 reg
        .axi_slave_bvalid               (s_axi_bvalid                   ), // O     1 reg
        .axi_slave_bid                  (s_axi_bid                      ), // O     4 reg
        .axi_slave_bresp                (s_axi_bresp                    ), // O     2 reg
        .axi_slave_arready              (s_axi_arready                  ), // O     1 reg
        .axi_slave_rvalid               (s_axi_rvalid                   ), // O     1 reg
        .axi_slave_rid                  (s_axi_rid                      ), // O     4 reg
        .axi_slave_rdata                (s_axi_rdata                    ), // O   512 reg
        .axi_slave_rresp                (s_axi_rresp                    ), // O     2 reg
        .axi_slave_rlast                (s_axi_rlast                    ), // O     1 reg
        .mram_0_ce_o                    (mram_ce[0]                     ), // O     8 const
        .mram_0_dout_en_o               (mram_dout_en[0]                ), // O     8 const
        .mram_0_we_o                    (mram_we[0]                     ), // O     1 const
        .mram_0_addr_o                  (mram_addr[0]                   ), // O    19 const
        .mram_0_din_o                   (mram_din[0]                    ), // O   128 const
        .mram_0_bwe_o                   (mram_bwe[0]                    ), // O   128 const
        .mram_1_ce_o                    (mram_ce[1]                     ), // O     8 const
        .mram_1_dout_en_o               (mram_dout_en[1]                ), // O     8 const
        .mram_1_we_o                    (mram_we[1]                     ), // O     1 const
        .mram_1_addr_o                  (mram_addr[1]                   ), // O    19 const
        .mram_1_din_o                   (mram_din[1]                    ), // O   128 const
        .mram_1_bwe_o                   (mram_bwe[1]                    ), // O   128 const
        .mram_2_ce_o                    (mram_ce[2]                     ), // O     8 const
        .mram_2_dout_en_o               (mram_dout_en[2]                ), // O     8 const
        .mram_2_we_o                    (mram_we[2]                     ), // O     1 const
        .mram_2_addr_o                  (mram_addr[2]                   ), // O    19 const
        .mram_2_din_o                   (mram_din[2]                    ), // O   128 const
        .mram_2_bwe_o                   (mram_bwe[2]                    ), // O   128 const
        .mram_3_ce_o                    (mram_ce[3]                     ), // O     8 const
        .mram_3_dout_en_o               (mram_dout_en[3]                ), // O     8 const
        .mram_3_we_o                    (mram_we[3]                     ), // O     1 const
        .mram_3_addr_o                  (mram_addr[3]                   ), // O    19 const
        .mram_3_din_o                   (mram_din[3]                    ), // O   128 const
        .mram_3_bwe_o                   (mram_bwe[3]                    ), // O   128 const
        .CLK_mram_0_clk_o               (mram_clk[0]                    ), // O     1 clock
        .CLK_GATE_mram_0_clk_o          ( /* Left intentionally Blank */), // O     1 clock gate
        .CLK_mram_1_clk_o               (mram_clk[1]                    ), // O     1 clock
        .CLK_GATE_mram_1_clk_o          ( /* Left intentionally Blank */), // O     1 clock gate
        .CLK_mram_2_clk_o               (mram_clk[2]                    ), // O     1 clock
        .CLK_GATE_mram_2_clk_o          ( /* Left intentionally Blank */), // O     1 clock gate
        .CLK_mram_3_clk_o               (mram_clk[3]                    ), // O     1 clock
        .CLK_GATE_mram_3_clk_o          ( /* Left intentionally Blank */), // O     1 clock gate
        .RST_N_mram_0_rst_bo            (axi2mram_rst_b[0]              ), // O     1
        .RST_N_mram_1_rst_bo            (axi2mram_rst_b[1]              ), // O     1
        .RST_N_mram_2_rst_bo            (axi2mram_rst_b[2]              ), // O     1
        .RST_N_mram_3_rst_bo            (axi2mram_rst_b[3]              ), // O     1
        .CLK                            (clk                            ), // I     1 clock
        .RST_N                          (rst_b                          ), // I     1
        .mram_reset_bi                  (mram_rst_b                     ), // I     1
        .mram_legacy_mode               (1'b0                           ), // I     1
        .regs_arbiter_mode              (axi2mram_arbiter_mode          ), // I     2  (0=WrPri, 1=RdPri, 2=RoundRobin, 3=OldestFirst)
        .regs_disable_clock_gate        (axi2mram_disable_clock_gate    ), //

        .axi_slave_awvalid              (s_axi_awvalid                  ), // I     1
        .axi_slave_awid                 (s_axi_awid                     ), // I     4 reg
        .axi_slave_awaddr               (s_axi_awaddr                   ), // I    32 reg
        .axi_slave_awlen                (s_axi_awlen                    ), // I     8 reg
        .axi_slave_awsize               (s_axi_awsize                   ), // I     3 reg
        .axi_slave_awburst              (s_axi_awburst                  ), // I     2 reg
        .axi_slave_awlock               (s_axi_awlock                   ), // I     1 reg
        .axi_slave_awcache              (s_axi_awcache                  ), // I     4 reg
        .axi_slave_awprot               (s_axi_awprot                   ), // I     3 reg
        .axi_slave_awqos                (s_axi_awqos                    ), // I     4 reg
        .axi_slave_awregion             (s_axi_awregion                 ), // I     4 reg
        .axi_slave_wvalid               (s_axi_wvalid                   ), // I     1
        .axi_slave_wdata                (s_axi_wdata                    ), // I   512 reg
        .axi_slave_wstrb                (s_axi_wstrb                    ), // I    64 reg
        .axi_slave_wlast                (s_axi_wlast                    ), // I     1 reg
        .axi_slave_bready               (s_axi_bready                   ), // I     1
        .axi_slave_arvalid              (s_axi_arvalid                  ), // I     1
        .axi_slave_arid                 (s_axi_arid                     ), // I     4 reg
        .axi_slave_araddr               (s_axi_araddr                   ), // I    32 reg
        .axi_slave_arlen                (s_axi_arlen                    ), // I     8 reg
        .axi_slave_arsize               (s_axi_arsize                   ), // I     3 reg
        .axi_slave_arburst              (s_axi_arburst                  ), // I     2 reg
        .axi_slave_arlock               (s_axi_arlock                   ), // I     1 reg
        .axi_slave_arcache              (s_axi_arcache                  ), // I     4 reg
        .axi_slave_arprot               (s_axi_arprot                   ), // I     3 reg
        .axi_slave_arqos                (s_axi_arqos                    ), // I     4 reg
        .axi_slave_arregion             (s_axi_arregion                 ), // I     4 reg
        .axi_slave_rready               (s_axi_rready                   ), // I     1
        .mram_0_dout_i                  (mram_dout[0]                   ), // I   128 unused
        .mram_0_ready_i                 (mram_ready[0]                  ), // I     1
        .mram_0_pwr_ok_i                (mram_pwr_ok[0]                 ), // I     1
        .mram_0_maintenance_i           (mram_maintenance[0]            ), // I     1
        .mram_0_ecc_triple_error_i      (mram_ecc_triple_error[0]       ), // I     2
        .mram_0_busy_i                  (mram_busy[0]                   ), // I     1 unused
        .mram_1_dout_i                  (mram_dout[1]                   ), // I   128 unused
        .mram_1_ready_i                 (mram_ready[1]                  ), // I     1
        .mram_1_pwr_ok_i                (mram_pwr_ok[1]                 ), // I     1
        .mram_1_maintenance_i           (mram_maintenance[1]            ), // I     1
        .mram_1_ecc_triple_error_i      (mram_ecc_triple_error[1]       ), // I     2
        .mram_1_busy_i                  (mram_busy[1]                   ), // I     1 unused
        .mram_2_dout_i                  (mram_dout[2]                   ), // I   128 unused
        .mram_2_ready_i                 (mram_ready[2]                  ), // I     1
        .mram_2_pwr_ok_i                (mram_pwr_ok[2]                 ), // I     1
        .mram_2_maintenance_i           (mram_maintenance[2]            ), // I     1
        .mram_2_ecc_triple_error_i      (mram_ecc_triple_error[2]       ), // I     2
        .mram_2_busy_i                  (mram_busy[2]                   ), // I     1 unused
        .mram_3_dout_i                  (mram_dout[3]                   ), // I   128 unused
        .mram_3_ready_i                 (mram_ready[3]                  ), // I     1
        .mram_3_pwr_ok_i                (mram_pwr_ok[3]                 ), // I     1
        .mram_3_maintenance_i           (mram_maintenance[3]            ), // I     1
        .mram_3_ecc_triple_error_i      (mram_ecc_triple_error[3]       ), // I     2
        .mram_3_busy_i                  (mram_busy[3]                   )  // I     1 unused



    );

    // ---------------------------------------------------------------------
`ifdef BYPASS_CONTROLLER
    // The behavioral bank model does not implement the external per-bank
    // test-register interface, so keep the regblock return channels quiescent.
    assign bridge_reg_in.bank0_tregs = '{default:'0};
    assign bridge_reg_in.bank1_tregs = '{default:'0};
    assign bridge_reg_in.bank2_tregs = '{default:'0};
    assign bridge_reg_in.bank3_tregs = '{default:'0};

    // Generate ``NUM_MRAM_BANKS`` instances of ``erbium_et_bank``.
    generate
        genvar i;
        for (i = 0; i < NUM_MRAM_BANKS; i = i + 1) begin : mram_bank
            assign mram_ready[i]       = 1'b1;
            assign mram_pwr_ok[i]      = 1'b1;
            assign mram_maintenance[i] = 1'b0;
            assign mram_ecc_single_error[i] = 2'b00;
            assign mram_ecc_double_error[i] = 2'b00;
            assign mram_ecc_triple_error[i] = 2'b00;
            erbium_et_bank u_bank (
                .rst_b_i                (axi2mram_rst_b[i]          ),
                .clk_i                  ({mram_clk[i],mram_clk[i],mram_clk[i],mram_clk[i]}),
                .ce_i                   (mram_ce[i]                 ),
                .dout_en_i              (mram_dout_en[i]            ),
                .we_i                   (mram_we[i]                 ),
                .addr_i                 (mram_addr[i]               ),
                .din_i                  (mram_din[i]                ),
                .bwe_i                  (mram_bwe[i]                ),
                .dout_o                 (mram_dout[i]               ),
                .busy_o                 (mram_busy[i]               )

            );
        end
    endgenerate
`endif // BEHAVIORAL_BANK

`ifndef BYPASS_CONTROLLER
    axi2mram_bridge_registers_pkg::MRAM_Controller_Test_Regs__external__in_t  wrapper_hwif_in  [NUM_MRAM_BANKS];
    axi2mram_bridge_registers_pkg::MRAM_Controller_Test_Regs__external__out_t wrapper_hwif_out [NUM_MRAM_BANKS];
    assign bridge_reg_in.bank0_tregs = wrapper_hwif_in[0];
    assign bridge_reg_in.bank1_tregs = wrapper_hwif_in[1];
    assign bridge_reg_in.bank2_tregs = wrapper_hwif_in[2];
    assign bridge_reg_in.bank3_tregs = wrapper_hwif_in[3];
    assign wrapper_hwif_out[0] = bridge_reg_out.bank0_tregs;
    assign wrapper_hwif_out[1] = bridge_reg_out.bank1_tregs;
    assign wrapper_hwif_out[2] = bridge_reg_out.bank2_tregs;
    assign wrapper_hwif_out[3] = bridge_reg_out.bank3_tregs;



    generate
        genvar i;
        for (i = 0; i < NUM_MRAM_BANKS; i = i + 1) begin : mram_bank
            // Lint waiver (intentional): `erbium_et_bank_wrapper` has supply
            // pins (`vdd`, `vdd18`, `vss`) used for gate-level power
            // simulation. This RTL wrapper intentionally leaves them
            // unconnected in logic-level/behavioral simulation flows.
            // See top-level README "Known lint waivers" section.
            erbium_et_bank_wrapper bank_wrapper_u (

                .reg_clk(clk),
                .reg_rst_b(rst_b),
                .reg_req(wrapper_hwif_out[i].req),
                .reg_req_is_wr(wrapper_hwif_out[i].req_is_wr),
                .reg_addr(wrapper_hwif_out[i].addr),
                .reg_wr_data(wrapper_hwif_out[i].wr_data),
                .reg_wr_biten(wrapper_hwif_out[i].wr_biten),
                .reg_req_stall_wr(),
                .reg_req_stall_rd(),
                .reg_rd_ack(wrapper_hwif_in[i].rd_ack),
                .reg_rd_err(),
                .reg_rd_data(wrapper_hwif_in[i].rd_data),
                .reg_wr_ack(wrapper_hwif_in[i].wr_ack),
                .reg_wr_err(),

                .axi_add              (mram_addr[i]             ),
                .axi_bwe              (mram_bwe[i]              ),
                .axi_din              (mram_din[i]              ),
                .axi_ce               (mram_ce[i]               ),
                .axi_dout_en          (mram_dout_en[i]          ),
                .axi_we               (mram_we[i]               ),
                .clk                  (mram_clk[i]              ),
                .dsleep               (dsleep                   ),
                .nvsram_startup_bypass(nvsram_startup_bypass    ),
                .rst_b                (axi2mram_rst_b[i]        ),
                .axi_busy             (mram_busy[i]             ),
                .axi_dout             (mram_dout[i]             ),
                .ecc_disable_bit      (axi2mram_ecc_disable_bit ),
                .ecc_single_error     (mram_ecc_single_error[i] ),
                .ecc_double_error     (mram_ecc_double_error[i] ),
                .ecc_triple_error     (mram_ecc_triple_error[i] ),
                .cpu_intr             (mram_cpu_intr[i]         ),
                .mram_ready           (mram_ready[i]            ),
                .mram_pwr_ok          (mram_pwr_ok[i]           ),
                .mram_maintenance     (mram_maintenance[i]      ),
                .ANATEST0             (ANATEST0                 ),
                .ANATEST1             (ANATEST1                 )
            );
        end
    endgenerate
`endif // !BEHAVIORAL_BANK

endmodule : axi2mram_et_wrapper
