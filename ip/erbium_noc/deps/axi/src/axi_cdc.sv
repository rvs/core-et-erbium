// Copyright (c) 2019-2020 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Authors:
// - Andreas Kurth <akurth@iis.ee.ethz.ch>
// - Luca Valente <luca.valente@unibo.it>
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>

`include "axi/assign.svh"

/// A clock domain crossing on an AXI interface.
///
/// For each of the five AXI channels, this module instantiates a CDC FIFO, whose push and pop
/// ports are in separate clock domains.  IMPORTANT: For each AXI channel, you MUST properly
/// constrain three paths through the FIFO; see the header of `cdc_fifo_gray` for instructions.
module erbium_noc_axi_cdc #(
  parameter type aw_chan_t  = logic, // AW Channel Type
  parameter type w_chan_t   = logic, //  W Channel Type
  parameter type b_chan_t   = logic, //  B Channel Type
  parameter type ar_chan_t  = logic, // AR Channel Type
  parameter type r_chan_t   = logic, //  R Channel Type
  parameter type axi_req_t  = logic, // encapsulates request channels
  parameter type axi_resp_t = logic, // encapsulates request channels
  /// Depth of the FIFO crossing the clock domain, given as 2**LOG_DEPTH.
  parameter int unsigned  LogDepth   = 1,
  /// Number of synchronization registers to insert on the async pointers
  parameter int unsigned  SyncStages = 2
) (
  // slave side - clocked by `src_clk_i`
  input  logic      src_clk_i,
  input  logic      src_rst_ni,
  input  axi_req_t  src_req_i,
  output axi_resp_t src_resp_o,
  // master side - clocked by `dst_clk_i`
  input  logic      dst_clk_i,
  input  logic      dst_rst_ni,
  output axi_req_t  dst_req_o,
  input  axi_resp_t dst_resp_i
);

  // Reset-coordinated clearable CDC FIFOs (one per AXI channel).
  //
  // The plain `cdc_fifo_gray` (split src/dst halves) has NO cross-domain reset
  // coordination and requires both sides to be reset together. In this SoC the
  // two domains have independent resets (e.g. a SYSTEM-domain software soft-reset
  // asserts only one side): the gray pointers then desync (one side resets to 0,
  // the other keeps its value), and the un-reset side drains stale/phantom FIFO
  // entries — producing spurious B/R responses (and dropped/duplicated beats).
  // That phantom B underflowed the downsizer demux's AW id-counter and crashed
  // every peripheral test that issued a soft-reset.
  //
  // `cdc_fifo_gray_clearable` with CLEAR_ON_ASYNC_RESET=1 embeds a
  // `cdc_reset_ctrlr` that turns an async reset on EITHER side into a coordinated
  // cross-domain clear, keeping both pointer sets consistent. Each channel is a
  // single dual-clock instance (no external async-wire split needed).
  //
  // CLEAR_ON_ASYNC_RESET requires >=4 synchronizer stages (clear must beat the
  // async reset); deepen the FIFO so the extra sync latency does not throttle
  // throughput. Both are clamped locally so the public port interface is
  // unchanged.
  localparam int unsigned ClrSyncStages = (SyncStages < 4) ? 4 : SyncStages;
  localparam int unsigned ClrLogDepth   = (2**LogDepth < 2*ClrSyncStages)
                                            ? $clog2(2*ClrSyncStages) : LogDepth;

  // ---- request channels (src -> dst): AW, W, AR ----
  erbium_noc_cdc_fifo_gray_clearable #(
    .T(aw_chan_t), .LOG_DEPTH(ClrLogDepth), .SYNC_STAGES(ClrSyncStages),
    .CLEAR_ON_ASYNC_RESET(1)
  ) i_cdc_fifo_aw (
    .src_rst_ni(src_rst_ni), .src_clk_i(src_clk_i), .src_clear_i(1'b0),
    .src_clear_pending_o(/*unused*/),
    .src_data_i(src_req_i.aw), .src_valid_i(src_req_i.aw_valid), .src_ready_o(src_resp_o.aw_ready),
    .dst_rst_ni(dst_rst_ni), .dst_clk_i(dst_clk_i), .dst_clear_i(1'b0),
    .dst_clear_pending_o(/*unused*/),
    .dst_data_o(dst_req_o.aw), .dst_valid_o(dst_req_o.aw_valid), .dst_ready_i(dst_resp_i.aw_ready)
  );

  erbium_noc_cdc_fifo_gray_clearable #(
    .T(w_chan_t), .LOG_DEPTH(ClrLogDepth), .SYNC_STAGES(ClrSyncStages),
    .CLEAR_ON_ASYNC_RESET(1)
  ) i_cdc_fifo_w (
    .src_rst_ni(src_rst_ni), .src_clk_i(src_clk_i), .src_clear_i(1'b0),
    .src_clear_pending_o(/*unused*/),
    .src_data_i(src_req_i.w), .src_valid_i(src_req_i.w_valid), .src_ready_o(src_resp_o.w_ready),
    .dst_rst_ni(dst_rst_ni), .dst_clk_i(dst_clk_i), .dst_clear_i(1'b0),
    .dst_clear_pending_o(/*unused*/),
    .dst_data_o(dst_req_o.w), .dst_valid_o(dst_req_o.w_valid), .dst_ready_i(dst_resp_i.w_ready)
  );

  erbium_noc_cdc_fifo_gray_clearable #(
    .T(ar_chan_t), .LOG_DEPTH(ClrLogDepth), .SYNC_STAGES(ClrSyncStages),
    .CLEAR_ON_ASYNC_RESET(1)
  ) i_cdc_fifo_ar (
    .src_rst_ni(src_rst_ni), .src_clk_i(src_clk_i), .src_clear_i(1'b0),
    .src_clear_pending_o(/*unused*/),
    .src_data_i(src_req_i.ar), .src_valid_i(src_req_i.ar_valid), .src_ready_o(src_resp_o.ar_ready),
    .dst_rst_ni(dst_rst_ni), .dst_clk_i(dst_clk_i), .dst_clear_i(1'b0),
    .dst_clear_pending_o(/*unused*/),
    .dst_data_o(dst_req_o.ar), .dst_valid_o(dst_req_o.ar_valid), .dst_ready_i(dst_resp_i.ar_ready)
  );

  // ---- response channels (dst -> src): B, R ----
  // Producer is the dst (slave) domain, consumer is the src (master) domain, so
  // the FIFO's "src" side is wired to dst_clk/dst_rst and vice versa. The reset
  // coordination is symmetric, so independent reset of either domain still
  // clears both pointer sets consistently.
  erbium_noc_cdc_fifo_gray_clearable #(
    .T(b_chan_t), .LOG_DEPTH(ClrLogDepth), .SYNC_STAGES(ClrSyncStages),
    .CLEAR_ON_ASYNC_RESET(1)
  ) i_cdc_fifo_b (
    .src_rst_ni(dst_rst_ni), .src_clk_i(dst_clk_i), .src_clear_i(1'b0),
    .src_clear_pending_o(/*unused*/),
    .src_data_i(dst_resp_i.b), .src_valid_i(dst_resp_i.b_valid), .src_ready_o(dst_req_o.b_ready),
    .dst_rst_ni(src_rst_ni), .dst_clk_i(src_clk_i), .dst_clear_i(1'b0),
    .dst_clear_pending_o(/*unused*/),
    .dst_data_o(src_resp_o.b), .dst_valid_o(src_resp_o.b_valid), .dst_ready_i(src_req_i.b_ready)
  );

  erbium_noc_cdc_fifo_gray_clearable #(
    .T(r_chan_t), .LOG_DEPTH(ClrLogDepth), .SYNC_STAGES(ClrSyncStages),
    .CLEAR_ON_ASYNC_RESET(1)
  ) i_cdc_fifo_r (
    .src_rst_ni(dst_rst_ni), .src_clk_i(dst_clk_i), .src_clear_i(1'b0),
    .src_clear_pending_o(/*unused*/),
    .src_data_i(dst_resp_i.r), .src_valid_i(dst_resp_i.r_valid), .src_ready_o(dst_req_o.r_ready),
    .dst_rst_ni(src_rst_ni), .dst_clk_i(src_clk_i), .dst_clear_i(1'b0),
    .dst_clear_pending_o(/*unused*/),
    .dst_data_o(src_resp_o.r), .dst_valid_o(src_resp_o.r_valid), .dst_ready_i(src_req_i.r_ready)
  );

endmodule

`include "axi/assign.svh"
`include "axi/typedef.svh"

// interface wrapper
module erbium_noc_axi_cdc_intf #(
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_USER_WIDTH = 0,
  /// Depth of the FIFO crossing the clock domain, given as 2**LOG_DEPTH.
  parameter int unsigned LOG_DEPTH = 1,
  /// Number of synchronization registers to insert on the async pointers
  parameter int unsigned SYNC_STAGES = 2
) (
   // slave side - clocked by `src_clk_i`
  input  logic      src_clk_i,
  input  logic      src_rst_ni,
  erbium_noc_AXI_BUS.Slave     src,
  // master side - clocked by `dst_clk_i`
  input  logic      dst_clk_i,
  input  logic      dst_rst_ni,
  erbium_noc_AXI_BUS.Master    dst
);

  typedef logic [AXI_ID_WIDTH-1:0]     id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0]   user_t;
  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)

  req_t  src_req,  dst_req;
  resp_t src_resp, dst_resp;

  `AXI_ASSIGN_TO_REQ(src_req, src)
  `AXI_ASSIGN_FROM_RESP(src, src_resp)

  `AXI_ASSIGN_FROM_REQ(dst, dst_req)
  `AXI_ASSIGN_TO_RESP(dst_resp, dst)

  erbium_noc_axi_cdc #(
    .aw_chan_t  ( aw_chan_t ),
    .w_chan_t   ( w_chan_t  ),
    .b_chan_t   ( b_chan_t  ),
    .ar_chan_t  ( ar_chan_t ),
    .r_chan_t   ( r_chan_t  ),
    .axi_req_t  ( req_t     ),
    .axi_resp_t ( resp_t    ),
    .LogDepth   ( LOG_DEPTH ),
    .SyncStages ( SYNC_STAGES )
  ) i_axi_cdc (
    .src_clk_i,
    .src_rst_ni,
    .src_req_i  ( src_req  ),
    .src_resp_o ( src_resp ),
    .dst_clk_i,
    .dst_rst_ni,
    .dst_req_o  ( dst_req  ),
    .dst_resp_i ( dst_resp )
  );

endmodule

module erbium_noc_axi_lite_cdc_intf #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  /// Depth of the FIFO crossing the clock domain, given as 2**LOG_DEPTH.
  parameter int unsigned LOG_DEPTH = 1,
  /// Number of synchronization registers to insert on the async pointers
  parameter int unsigned SYNC_STAGES = 2
) (
   // slave side - clocked by `src_clk_i`
  input  logic      src_clk_i,
  input  logic      src_rst_ni,
  erbium_noc_AXI_LITE.Slave    src,
  // master side - clocked by `dst_clk_i`
  input  logic      dst_clk_i,
  input  logic      dst_rst_ni,
  erbium_noc_AXI_LITE.Master   dst
);

  typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_LITE_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)

  req_t  src_req,  dst_req;
  resp_t src_resp, dst_resp;

  `AXI_LITE_ASSIGN_TO_REQ(src_req, src)
  `AXI_LITE_ASSIGN_FROM_RESP(src, src_resp)

  `AXI_LITE_ASSIGN_FROM_REQ(dst, dst_req)
  `AXI_LITE_ASSIGN_TO_RESP(dst_resp, dst)

  erbium_noc_axi_cdc #(
    .aw_chan_t  ( aw_chan_t ),
    .w_chan_t   ( w_chan_t  ),
    .b_chan_t   ( b_chan_t  ),
    .ar_chan_t  ( ar_chan_t ),
    .r_chan_t   ( r_chan_t  ),
    .axi_req_t  ( req_t     ),
    .axi_resp_t ( resp_t    ),
    .LogDepth   ( LOG_DEPTH ),
    .SyncStages ( SYNC_STAGES )
  ) i_axi_cdc (
    .src_clk_i,
    .src_rst_ni,
    .src_req_i  ( src_req  ),
    .src_resp_o ( src_resp ),
    .dst_clk_i,
    .dst_rst_ni,
    .dst_req_o  ( dst_req  ),
    .dst_resp_i ( dst_resp )
  );

endmodule
