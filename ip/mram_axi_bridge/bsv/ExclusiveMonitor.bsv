// Copyright (c) 2026, All rights reserved.
// AXI4 Exclusive Access Monitor
//
// Tracks exclusive read reservations in a two-level CAM:
//   - Outer level: up to n_ids distinct AXI IDs (parameterizable)
//   - Inner level: up to n_entries_per_id address reservations per ID
//
// Architecture: Methods only set RWire request signals; a single internal
// rule (apply_updates) is the sole writer to all CAM registers.  This
// eliminates multi-writer scheduling conflicts and shadowing warnings.
//
// Parameters:
//   n_ids             — number of unique AXI IDs that can be tracked
//                       simultaneously (must be a power of 2)
//   n_entries_per_id  — number of concurrent address reservations per ID
//                       (must be a power of 2)
//   wd_id             — AXI ID bit-width
//   wd_addr           — AXI address bit-width
//
// Eviction policy:
//   Both levels use round-robin replacement.  The ID slot pointer
//   advances when a new, previously-unseen ID arrives and all n_ids
//   slots are occupied.  The per-ID address pointer advances each time
//   a new address is added to an ID whose n_entries_per_id slots are all
//   occupied.  An exclusive read always returns EXOKAY regardless of
//   whether eviction occurred; the eviction only manifests as a
//   subsequent exclusive-write failure for the displaced reservation.

package ExclusiveMonitor;

import Vector       :: *;
import ConfigReg    :: *;
import AXI4_Types   :: *;

// ================================================================
// Interface
// ================================================================

interface ExclusiveMonitor #(numeric type n_ids,
                             numeric type n_entries_per_id,
                             numeric type wd_id,
                             numeric type wd_addr);

    // Called on every AXI read.  If arlock == exclusive, a reservation is
    // created (or updated) for the given ID and aligned address.
    // Returns EXOKAY for exclusive reads, OKAY for normal reads.
    method ActionValue #(AXI4_Resp) check_read (Bit #(wd_id)   arid,
                                                 Bit #(wd_addr)  araddr,
                                                 AXI4_Size       arsize,
                                                 AXI4_Lock       arlock);

    // Called on every AXI write.  If awlock == exclusive, checks for a
    // matching reservation.  Returns EXOKAY on match (reservation cleared),
    // OKAY otherwise.  For normal writes, always returns OKAY.
    method ActionValue #(AXI4_Resp) check_write (Bit #(wd_id)   awid,
                                                  Bit #(wd_addr)  awaddr,
                                                  AXI4_Size       awsize,
                                                  AXI4_Lock       awlock);

    // Called after any normal (non-exclusive) write commits.  Invalidates
    // any reservation whose address range overlaps the write.
    method Action snoop_write (Bit #(wd_addr) awaddr, AXI4_Size awsize);

    // Invalidate all reservations (e.g., on reset).
    method Action clear_all;

endinterface

// ================================================================
// Helper: align an address to a power-of-2 size
//   aligned = addr & ~((1 << size) - 1)
// ================================================================

function Bit #(wd_addr) align_addr (Bit #(wd_addr) addr, AXI4_Size size);
    Bit #(wd_addr) mask = (1 << size) - 1;
    return addr & ~mask;
endfunction

// ================================================================
// Helper: check if two aligned ranges overlap
//   Range A: [aligned_a, aligned_a + (1 << size_a))
//   Range B: [aligned_b, aligned_b + (1 << size_b))
//   They overlap if neither is entirely before the other.
// ================================================================

function Bool ranges_overlap (Bit #(wd_addr) addr_a, AXI4_Size size_a,
                              Bit #(wd_addr) addr_b, AXI4_Size size_b);
    Bit #(wd_addr) aligned_a = align_addr(addr_a, size_a);
    Bit #(wd_addr) aligned_b = align_addr(addr_b, size_b);
    Bit #(wd_addr) end_a = aligned_a + (1 << size_a);
    Bit #(wd_addr) end_b = aligned_b + (1 << size_b);
    return (aligned_a < end_b) && (aligned_b < end_a);
endfunction

// ================================================================
// Internal types for deferred update requests
// ================================================================

typedef struct {
    Bit #(wd_id)   id;
    Bit #(wd_addr) addr;   // pre-aligned by caller
    AXI4_Size      sz;
} CreateReq #(numeric type wd_id, numeric type wd_addr)
    deriving (Bits);

// Carries enough information for apply_updates to clear a single
// (id_slot, addr_slot) pair.  clear_id is pre-computed by check_write
// (which can read registers) so that apply_updates does not need a
// second read-modify-write pass to decide whether to evict the ID slot.
typedef struct {
    Bit #(log_n_ids)          id_slot;
    Bit #(log_entries_per_id) addr_slot;
    Bool                      clear_id;  // True when this was the last addr for the ID
} ClearReq #(numeric type log_n_ids, numeric type log_entries_per_id)
    deriving (Bits);

typedef struct {
    Bit #(wd_addr) addr;
    AXI4_Size      sz;
} SnoopReq #(numeric type wd_addr)
    deriving (Bits);

// ================================================================
// Module implementation
// ================================================================

module mkExclusiveMonitor (ExclusiveMonitor #(n_ids, n_entries_per_id, wd_id, wd_addr))
    provisos (
        Log #(n_ids,            log_n_ids),
        Log #(n_entries_per_id, log_entries_per_id),
        Add #(1, _any1, n_ids),            // n_ids >= 1
        Add #(1, _any2, n_entries_per_id)  // n_entries_per_id >= 1
    );

    // ------------------------------------------------------------------
    // Outer CAM — up to n_ids distinct AXI IDs.
    // Only apply_updates writes these.
    // ------------------------------------------------------------------
    Vector #(n_ids, Reg #(Bool))         id_valid <- replicateM(mkConfigReg(False));
    Vector #(n_ids, Reg #(Bit #(wd_id))) id_value <- replicateM(mkConfigRegU);

    // ------------------------------------------------------------------
    // Per-ID address storage — n_entries_per_id slots per ID slot.
    // ------------------------------------------------------------------
    Vector #(n_ids, Vector #(n_entries_per_id, Reg #(Bool)))
        addr_valid <- replicateM(replicateM(mkConfigReg(False)));

    Vector #(n_ids, Vector #(n_entries_per_id, Reg #(Bit #(wd_addr))))
        addr_value <- replicateM(replicateM(mkConfigRegU));

    Vector #(n_ids, Vector #(n_entries_per_id, Reg #(AXI4_Size)))
        addr_size <- replicateM(replicateM(mkConfigRegU));

    // ------------------------------------------------------------------
    // Round-robin replacement pointers.
    // ------------------------------------------------------------------
    // Which ID slot gets the next brand-new ID.
    Reg #(Bit #(log_n_ids)) next_id_slot <- mkConfigReg(0);

    // Per-ID: which address slot gets the next new address for that ID.
    Vector #(n_ids, Reg #(Bit #(log_entries_per_id)))
        next_addr_slot <- replicateM(mkConfigReg(0));

    // ------------------------------------------------------------------
    // Deferred-update request wires (set by methods, read by rule).
    // At most one of these is valid per cycle since the callers are
    // mutually exclusive FSM actions.
    // ------------------------------------------------------------------
    RWire #(CreateReq #(wd_id, wd_addr))                  rw_create    <- mkRWire;
    RWire #(ClearReq  #(log_n_ids, log_entries_per_id))   rw_clear     <- mkRWire;
    RWire #(SnoopReq  #(wd_addr))                         rw_snoop     <- mkRWire;
    PulseWire                                             pw_clear_all <- mkPulseWire;

    // ----------------------------------------------------------------
    // Internal: find the ID slot for a given AXI ID.
    // Returns the index of the matching id_valid/id_value entry, or
    // Invalid if the ID is not currently tracked.
    // ----------------------------------------------------------------
    function Maybe #(Bit #(log_n_ids)) find_id_slot (Bit #(wd_id) target_id);
        Maybe #(Bit #(log_n_ids)) result = tagged Invalid;
        for (Integer i = 0; i < valueOf(n_ids); i = i + 1)
            if (id_valid[i] && id_value[i] == target_id)
                result = tagged Valid fromInteger(i);
        return result;
    endfunction

    // ----------------------------------------------------------------
    // Internal: find an address slot within a known ID slot.
    // Returns the index of the matching (addr, size) entry, or Invalid.
    // ----------------------------------------------------------------
    function Maybe #(Bit #(log_entries_per_id)) find_addr_slot (
        Bit #(log_n_ids) id_slot,
        Bit #(wd_addr)   target_addr,
        AXI4_Size        target_size);

        Maybe #(Bit #(log_entries_per_id)) result = tagged Invalid;
        Bit #(wd_addr) aligned = align_addr(target_addr, target_size);
        for (Integer j = 0; j < valueOf(n_entries_per_id); j = j + 1)
            if (addr_valid[id_slot][j] &&
                addr_value[id_slot][j] == aligned &&
                addr_size[id_slot][j]  == target_size)
                result = tagged Valid fromInteger(j);
        return result;
    endfunction

    // ----------------------------------------------------------------
    // Internal: round-robin increment helpers.
    // ----------------------------------------------------------------
    function Bit #(log_n_ids) incr_id (Bit #(log_n_ids) s);
        return (s == fromInteger(valueOf(n_ids) - 1)) ? 0 : s + 1;
    endfunction

    function Bit #(log_entries_per_id) incr_addr (Bit #(log_entries_per_id) s);
        return (s == fromInteger(valueOf(n_entries_per_id) - 1)) ? 0 : s + 1;
    endfunction

    // ================================================================
    // Single rule: the ONLY writer to all CAM registers.
    // Reads the deferred-update wires and applies the requested
    // operation.  Since callers are mutually exclusive, at most one
    // wire is valid per cycle.
    // ================================================================
    (* fire_when_enabled, no_implicit_conditions *)
    rule apply_updates;

        if (pw_clear_all) begin
            // ---- Reset: invalidate everything ---------------------------
            for (Integer i = 0; i < valueOf(n_ids); i = i + 1) begin
                id_valid[i] <= False;
                for (Integer j = 0; j < valueOf(n_entries_per_id); j = j + 1)
                    addr_valid[i][j] <= False;
            end
        end

        else if (rw_create.wget matches tagged Valid .req) begin
            // ---- Exclusive read: create or update a reservation ---------
            let id_slot_m = find_id_slot(req.id);
            case (id_slot_m) matches

                tagged Valid .id_slot: begin
                    // ID already tracked — find or allocate an address slot.
                    let addr_slot_m = find_addr_slot(id_slot, req.addr, req.sz);
                    case (addr_slot_m) matches
                        tagged Valid .*:
                            // (id, addr, size) already in CAM — no-op.
                            noAction;
                        tagged Invalid: begin
                            // New address for existing ID — round-robin evict.
                            let aslot = next_addr_slot[id_slot];
                            addr_valid[id_slot][aslot] <= True;
                            addr_value[id_slot][aslot] <= req.addr;
                            addr_size[id_slot][aslot]  <= req.sz;
                            next_addr_slot[id_slot]    <= incr_addr(aslot);
                        end
                    endcase
                end

                tagged Invalid: begin
                    // Brand-new ID — allocate an ID slot (round-robin evict).
                    let islot = next_id_slot;
                    id_valid[islot] <= True;
                    id_value[islot] <= req.id;
                    // Initialise addr slots: set only slot 0, clear the rest.
                    // (j == 0) is a compile-time constant per loop iteration,
                    // so each register gets a distinct static assignment.
                    for (Integer j = 0; j < valueOf(n_entries_per_id); j = j + 1)
                        addr_valid[islot][j] <= (j == 0);
                    addr_value[islot][0] <= req.addr;
                    addr_size[islot][0]  <= req.sz;
                    next_addr_slot[islot] <= incr_addr(fromInteger(0));
                    next_id_slot          <= incr_id(islot);
                end

            endcase
        end

        else if (rw_clear.wget matches tagged Valid .req) begin
            // ---- Exclusive write success: clear the matched slot ---------
            addr_valid[req.id_slot][req.addr_slot] <= False;
            if (req.clear_id)
                id_valid[req.id_slot] <= False;
        end

        else if (rw_snoop.wget matches tagged Valid .req) begin
            // ---- Normal write: snoop-invalidate overlapping entries ------
            for (Integer i = 0; i < valueOf(n_ids); i = i + 1) begin
                if (id_valid[i]) begin
                    Bool any_snooped   = False;
                    Bool any_surviving = False;
                    for (Integer j = 0; j < valueOf(n_entries_per_id); j = j + 1) begin
                        if (addr_valid[i][j]) begin
                            if (ranges_overlap(addr_value[i][j], addr_size[i][j],
                                               req.addr, req.sz)) begin
                                any_snooped      = True;
                                addr_valid[i][j] <= False;
                            end else begin
                                any_surviving = True;
                            end
                        end
                    end
                    // If every address for this ID was snooped away, retire
                    // the ID slot so it can be reused.
                    if (any_snooped && !any_surviving)
                        id_valid[i] <= False;
                end
            end
        end

    endrule

    // ================================================================
    // Interface methods
    //
    // These methods only READ registers (for lookups) and WRITE to
    // RWires (to request deferred updates).  They never write
    // registers directly, so there are no multi-method write conflicts.
    // ================================================================

    method ActionValue #(AXI4_Resp) check_read (Bit #(wd_id) arid, Bit #(wd_addr) araddr,
                                                 AXI4_Size arsize, AXI4_Lock arlock);
        if (arlock == axlock_normal)
            return axi4_resp_okay;
        else begin
            Bit #(wd_addr) aligned = align_addr(araddr, arsize);
            rw_create.wset(CreateReq { id: arid, addr: aligned, sz: arsize });
            return axi4_resp_exokay;
        end
    endmethod

    method ActionValue #(AXI4_Resp) check_write (Bit #(wd_id) awid,
                                                   Bit #(wd_addr) awaddr,
                                                   AXI4_Size awsize,
                                                   AXI4_Lock awlock);
        if (awlock == axlock_normal)
            return axi4_resp_okay;
        else begin
            let id_slot_m = find_id_slot(awid);
            case (id_slot_m) matches
                tagged Valid .id_slot: begin
                    let addr_slot_m = find_addr_slot(id_slot, awaddr, awsize);
                    case (addr_slot_m) matches
                        tagged Valid .addr_slot: begin
                            // Pre-compute whether this is the last valid address
                            // for the ID, so apply_updates can retire the ID
                            // slot without a second register scan.
                            Bool other_valid = False;
                            for (Integer j = 0; j < valueOf(n_entries_per_id); j = j + 1)
                                if (fromInteger(j) != addr_slot && addr_valid[id_slot][j])
                                    other_valid = True;
                            rw_clear.wset(ClearReq {
                                id_slot:   id_slot,
                                addr_slot: addr_slot,
                                clear_id:  !other_valid
                            });
                            return axi4_resp_exokay;
                        end
                        tagged Invalid: return axi4_resp_okay;
                    endcase
                end
                tagged Invalid: return axi4_resp_okay;
            endcase
        end
    endmethod

    method Action snoop_write (Bit #(wd_addr) awaddr, AXI4_Size awsize);
        rw_snoop.wset(SnoopReq { addr: awaddr, sz: awsize });
    endmethod

    method Action clear_all;
        pw_clear_all.send();
    endmethod

endmodule

endpackage
