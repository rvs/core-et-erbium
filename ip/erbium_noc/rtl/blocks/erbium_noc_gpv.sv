// SPDX-License-Identifier: Apache-2.0
// Read-only discovery block.
// Read-only AXI4 slave at the configuration base. Returns a fixed discovery
// word (magic + version + interface count) so software can identify the fabric;
// the address map is static, so there are no writable region registers.
// Returns a fixed discovery word so software can identify the fabric.
module erbium_noc_gpv #(
  parameter type        req_t   = logic,
  parameter type        resp_t  = logic,
  parameter int unsigned DW      = 512,
  parameter logic [31:0] MAGIC   = 32'h4E49_3730, // "NI70"
  parameter logic [31:0] VERSION = 32'h0002_0003, // r2p3-equivalent
  parameter logic [31:0] NUM_IF  = 32'd11
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  req_t  slv_req_i,
  output resp_t slv_resp_o
);
  // discovery word replicated across all lanes (any aligned read returns it)
  localparam logic [127:0] WORD = {NUM_IF, 32'h0, VERSION, MAGIC};
  logic [DW-1:0] rdata;
  always_comb for (int i = 0; i < DW/128; i++) rdata[i*128 +: 128] = WORD;

  // read channel
  logic        rb;        // read busy
  logic [8:0]  rid;       // captured id (width tolerant; trimmed on assign)
  logic [7:0]  rbeat, rlen;
  // write channel (read-only: accept and drop, respond OKAY)
  logic        wb, bv;
  logic [8:0]  bid;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rb<=0; rid<=0; rbeat<=0; rlen<=0; wb<=0; bv<=0; bid<=0;
    end else begin
      if (!rb && slv_req_i.ar_valid) begin
        rb<=1; rid<=slv_req_i.ar.id; rlen<=slv_req_i.ar.len; rbeat<=0;
      end else if (rb && slv_req_i.r_ready) begin
        if (rbeat==rlen) rb<=0; else rbeat<=rbeat+1;
      end
      if (!wb && !bv && slv_req_i.aw_valid) begin
        wb<=1; bid<=slv_req_i.aw.id;
      end else if (wb && slv_req_i.w_valid && slv_req_i.w.last) begin
        wb<=0; bv<=1;
      end
      if (bv && slv_req_i.b_ready) bv<=0;
    end
  end

  always_comb begin
    slv_resp_o            = '0;
    slv_resp_o.ar_ready   = !rb;
    slv_resp_o.r_valid    = rb;
    slv_resp_o.r.id       = rid;
    slv_resp_o.r.data     = rdata;
    slv_resp_o.r.resp     = 2'b00;
    slv_resp_o.r.last     = (rbeat == rlen);
    slv_resp_o.aw_ready   = !wb && !bv;
    slv_resp_o.w_ready    = wb;
    slv_resp_o.b_valid    = bv;
    slv_resp_o.b.id       = bid;
    slv_resp_o.b.resp     = 2'b00; // read-only: silently OK writes
  end
endmodule
