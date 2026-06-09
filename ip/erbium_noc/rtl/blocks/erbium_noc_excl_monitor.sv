// SPDX-License-Identifier: Apache-2.0
// AXI exclusive-access monitor (single reservation).
// Inline on a target leg: passes AXI through transparently, tracks one
// exclusive reservation (id + cacheline-granule address), and provides
// single-copy atomicity for LL/SC:
//   - exclusive read  -> records reservation, returns EXOKAY
//   - exclusive write  : reservation hit -> performs write, returns EXOKAY
//                        reservation miss -> squashes write (WSTRB=0), OKAY
//   - any normal write to the reserved line clears the reservation
// Scope (v1, documented): one reservation, one outstanding exclusive write at a
// time. W beats may arrive before their AW (W-leads-AW) — handled by gating the
// W channel on `w_active` so a beat is never classified before its own AW is
// accepted. Sufficient for typical load-linked/store-conditional.
module erbium_noc_excl_monitor #(
  parameter type         req_t   = logic,
  parameter type         resp_t  = logic,
  parameter int unsigned AW       = 32,
  parameter int unsigned GRAN_LSB = 6      // 64-byte reservation granule
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  req_t  slv_req_i,   // from interconnect
  output resp_t slv_resp_o,  // to interconnect
  output req_t  mst_req_o,   // to memory endpoint
  input  resp_t mst_resp_i   // from memory endpoint
);
  localparam logic [1:0] OKAY = 2'b00, EXOKAY = 2'b01;
  typedef logic [AW-1-GRAN_LSB:0] line_t;

  logic  rsv_valid;
  logic [8:0] rsv_id;           // id field is <=9b in this design
  line_t rsv_line;

  logic  er_pending;            // exclusive read response outstanding
  logic [8:0] er_id;

  logic  w_active, w_excl_ok, w_excl_fail;
  logic [8:0] w_id;

  // passthrough handshakes (ready/valid come straight from the endpoint/master)
  // Exception: AW handshake is GATED on `~w_active` (see fix note below) so a
  // new AW cannot clobber the in-flight burst's squash classification.
  wire ar_hs = slv_req_i.ar_valid && mst_resp_i.ar_ready;
  wire aw_hs = slv_req_i.aw_valid && mst_resp_i.aw_ready && !w_active;
  wire r_hs  = mst_resp_i.r_valid  && slv_req_i.r_ready;
  wire b_hs  = mst_resp_i.b_valid  && slv_req_i.b_ready;
  wire w_hs  = slv_req_i.w_valid   && mst_resp_i.w_ready;

  wire        aw_lock = slv_req_i.aw.lock;
  wire line_t aw_line = slv_req_i.aw.addr[AW-1:GRAN_LSB];
  wire        aw_hit  = rsv_valid && (slv_req_i.aw.id == rsv_id) && (aw_line == rsv_line);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rsv_valid<=0; rsv_id<=0; rsv_line<=0;
      er_pending<=0; er_id<=0;
      w_active<=0; w_excl_ok<=0; w_excl_fail<=0; w_id<=0;
    end else begin
      // exclusive read -> set reservation + mark read for EXOKAY upgrade
      if (ar_hs && slv_req_i.ar.lock) begin
        rsv_valid<=1; rsv_id<=slv_req_i.ar.id;
        rsv_line<=slv_req_i.ar.addr[AW-1:GRAN_LSB];
        er_pending<=1; er_id<=slv_req_i.ar.id;
      end
      if (r_hs && er_pending && (mst_resp_i.r.id==er_id) && mst_resp_i.r.last)
        er_pending<=0;

      // write address decision
      if (aw_hs) begin
        w_active<=1; w_id<=slv_req_i.aw.id;
        if (aw_lock) begin
          w_excl_ok   <=  aw_hit;
          w_excl_fail <= ~aw_hit;
          if (aw_hit) rsv_valid<=0;            // consumed by successful SC
        end else begin
          w_excl_ok<=0; w_excl_fail<=0;
          if (rsv_valid && (aw_line==rsv_line)) rsv_valid<=0;  // store breaks reservation
        end
      end
      if (w_active && w_hs && slv_req_i.w.last) w_active<=0;
      if (b_hs) begin w_excl_ok<=0; w_excl_fail<=0; end
    end
  end

  // ---- response / request overrides ----
  always_comb begin
    slv_resp_o = mst_resp_i;
    // exclusive read returns EXOKAY
    if (er_pending && mst_resp_i.r_valid && (mst_resp_i.r.id==er_id))
      slv_resp_o.r.resp = EXOKAY;
    // successful exclusive write returns EXOKAY (failed stays OKAY)
    if (w_excl_ok && mst_resp_i.b_valid && (mst_resp_i.b.id==w_id))
      slv_resp_o.b.resp = EXOKAY;
    // Gate AW upward: producer must not see aw_ready while we're holding
    // the new AW from the slave (see request always_comb below + the
    // gated `aw_hs` wire). Otherwise the producer thinks the AW was
    // accepted while the slave never saw it.
    if (w_active) slv_resp_o.aw_ready = 1'b0;
    // Gate W upward: do not accept a W beat until its own AW has been
    // accepted and classified (w_active set). This makes the squash robust
    // to W-leading-AW (see request block). Without it, a W beat that
    // arrives before its AW is associated with whatever burst happens to be
    // `w_active` at the time — i.e. the *previous* (possibly failed
    // exclusive) burst's classification — and gets wrongly squashed.
    if (!w_active) slv_resp_o.w_ready = 1'b0;
  end

  always_comb begin
    mst_req_o = slv_req_i;
    // squash a failed exclusive write so memory is not updated
    if (w_active && w_excl_fail) mst_req_o.w.strb = '0;
    // Gate AW downstream: do not present a new AW to the slave (and do not
    // accept the slave's aw_ready upward) while the previous burst's
    // squash classification (w_excl_ok/w_excl_fail) is still live. See
    // docs/INVESTIGATION_2026-05-31_excl_monitor_w_race.md for the race
    // this fixes: a new failed-exclusive AW arriving mid-W-burst of a
    // normal store would clobber w_excl_fail and squash beats of the
    // previous (normal) store, leaving bytes unwritten at the slave.
    if (w_active) mst_req_o.aw_valid = 1'b0;
    // Gate W downstream in lockstep with the upward w_ready mask: a W beat
    // may only reach the slave once its own AW is accepted/classified
    // (w_active=1). Combined with the single-outstanding AW gating above
    // and AXI's per-port W-ordering guarantee, the W beats that flow while
    // w_active=1 provably belong to that one classified AW — so the squash
    // can never hit a following (normal) store's beats. This is the fix for
    // the mtg_16t_rand stale-load failure where a normal store's W beat,
    // arriving ahead of its AW, was squashed under a prior failed-exclusive
    // store's stale w_excl_fail (WSTRB forced to 0, store silently dropped).
    if (!w_active) mst_req_o.w_valid = 1'b0;
  end
  // Mirror the upward aw_ready gating so the producer doesn't see ready.
  // (slv_resp_o.aw_ready comes from mst_resp_i.aw_ready in the default
  // passthrough; we already masked it via the gated `aw_hs` above so no
  // separate combinational mask is needed on the response side — but we
  // explicitly null it for safety when w_active is high.)
endmodule
