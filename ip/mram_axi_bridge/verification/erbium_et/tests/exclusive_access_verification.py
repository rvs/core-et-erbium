# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb
from tb import *


@cocotb.test()
async def exclusive_access_verification(dut):
    """Verify AXI4 exclusive access (ARLOCK/AWLOCK) behavior.

    Per the AXI4 spec, exclusive access provides an atomic read-modify-write
    mechanism:
      1. Exclusive read  (ARLOCK=1) → slave returns EXOKAY if it can monitor
      2. Exclusive write (AWLOCK=1) → slave returns EXOKAY if no other master
         wrote to that address since the exclusive read; OKAY if it failed
      3. A normal write between exclusive read and exclusive write should
         invalidate the exclusive monitor, causing the exclusive write to fail

    This test is expected to FAIL until the exclusive access feature is
    implemented (the bridge currently ignores lock signals and always
    returns OKAY).
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(9)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # ----------------------------------------------------------------
    # Section 1: Basic exclusive read should return EXOKAY
    # The slave acknowledges it can track this exclusive access.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 1: Basic exclusive read ===")

    addr = 0x2000
    seed_data = bytearray(rand_bytes(8))

    # Pre-seed the address with known data
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(seed_data), size=3), 500, 'ns'
    )

    # Exclusive read (use explicit arid so we can match it later)
    excl_id = 0x10
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

    assert axi_resp(r_op) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr:04x}: expected EXOKAY (1), "
        f"got {axi_resp(r_op)} ({axi_resp(r_op).value})"
    )
    assert axi_data(r_op) == bytes(seed_data), (
        f"Exclusive read data mismatch at 0x{addr:04x}"
    )
    my_tb.dut._log.info("  Section 1 OK: exclusive read returned EXOKAY")

    # ----------------------------------------------------------------
    # Section 2: Successful exclusive write (no intervening write)
    # Exclusive read → exclusive write to same address → EXOKAY
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 2: Successful exclusive write ===")

    addr = 0x2010
    old_data = bytearray(rand_bytes(8))
    new_data = bytearray(rand_bytes(8))
    while new_data == old_data:
        new_data = bytearray(rand_bytes(8))

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(old_data), size=3), 500, 'ns'
    )

    # Exclusive read (explicit ID for matching)
    excl_id = 0x10
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr:04x}: expected EXOKAY"
    )
    assert axi_data(r_op) == bytes(old_data), (
        f"Exclusive read data mismatch at 0x{addr:04x}"
    )

    # Exclusive write (same ID, no intervening writes) → should succeed with EXOKAY
    w_op = axi_master.init_write(addr, bytes(new_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr:04x}: expected EXOKAY (exclusive "
        f"should succeed, no intervening write), got {axi_resp(w_op)}"
    )

    # Verify the data was actually written
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(new_data), (
        f"Post-exclusive-write readback at 0x{addr:04x}: "
        f"expected {new_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 2 OK: exclusive read-write sequence succeeded")

    # ----------------------------------------------------------------
    # Section 3: Failed exclusive write (intervening normal write)
    # Exclusive read → normal write to same address → exclusive write
    # The normal write invalidates the exclusive monitor, so the
    # exclusive write should fail (BRESP = OKAY, not EXOKAY) and the
    # exclusive write's data should NOT be committed to memory.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 3: Failed exclusive write ===")

    addr = 0x2020
    original_data = bytearray(rand_bytes(8))
    interloper_data = bytearray(rand_bytes(8))
    excl_write_data = bytearray(rand_bytes(8))

    # Ensure all three are distinct
    while interloper_data == original_data:
        interloper_data = bytearray(rand_bytes(8))
    while excl_write_data == original_data or excl_write_data == interloper_data:
        excl_write_data = bytearray(rand_bytes(8))

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(original_data), size=3), 500, 'ns'
    )

    # Exclusive read — sets up the exclusive monitor
    excl_id = 0x10
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr:04x}: expected EXOKAY"
    )

    # Normal write to the SAME address — invalidates the exclusive monitor
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(interloper_data), size=3), 500, 'ns'
    )

    # Exclusive write (same ID) — should FAIL (BRESP = OKAY, not EXOKAY)
    w_op = axi_master.init_write(addr, bytes(excl_write_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.OKAY, (
        f"Exclusive write at 0x{addr:04x} after intervening write: "
        f"expected OKAY (exclusive failed), got {axi_resp(w_op)}"
    )

    # Memory should contain the interloper's data, NOT the exclusive write's data
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(interloper_data), (
        f"After failed exclusive write at 0x{addr:04x}: memory should contain "
        f"interloper data {interloper_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 3 OK: exclusive write correctly failed")

    # ----------------------------------------------------------------
    # Section 4: Write to different address does NOT invalidate monitor
    # Exclusive read to addr A → normal write to addr B → exclusive
    # write to addr A → should succeed (EXOKAY) since B != A
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 4: Different-address write ===")

    addr_a = 0x2030
    addr_b = 0x2040  # different address (different bank too)
    old_data_a = bytearray(rand_bytes(8))
    new_data_a = bytearray(rand_bytes(8))

    while new_data_a == old_data_a:
        new_data_a = bytearray(rand_bytes(8))

    # Pre-seed addr A
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_a, bytes(old_data_a), size=3), 500, 'ns'
    )

    # Exclusive read to addr A
    excl_id = 0x10
    r_op = axi_master.init_read(addr_a, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr_a:04x}: expected EXOKAY"
    )

    # Normal write to addr B — should NOT invalidate A's exclusive monitor
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_b, bytes(rand_bytes(8)), size=3),
        500, 'ns'
    )

    # Exclusive write to addr A (same ID) — should succeed (EXOKAY)
    w_op = axi_master.init_write(addr_a, bytes(new_data_a), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr_a:04x} (no write to same addr): "
        f"expected EXOKAY, got {axi_resp(w_op)}"
    )

    # Verify data was written
    verify_op = axi_master.init_read(addr_a, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(new_data_a), (
        f"Post-exclusive-write readback at 0x{addr_a:04x}: "
        f"expected {new_data_a.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 4 OK: different-address write didn't invalidate")

    # ----------------------------------------------------------------
    # Section 5: Multiple addresses per ID
    # The monitor holds up to n_entries_per_id addresses per unique ID,
    # so a second exclusive read on the same ID to a different address
    # adds a second reservation rather than overwriting the first.
    # Both subsequent exclusive writes must therefore succeed (EXOKAY).
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 5: Multiple addresses per ID ===")

    addr_a = 0x2050
    addr_b = 0x2060
    old_data_a = bytearray(rand_bytes(8))
    old_data_b = bytearray(rand_bytes(8))
    new_data_a = bytearray(rand_bytes(8))
    new_data_b = bytearray(rand_bytes(8))

    while new_data_a == old_data_a:
        new_data_a = bytearray(rand_bytes(8))
    while new_data_b == old_data_b:
        new_data_b = bytearray(rand_bytes(8))

    # Pre-seed both addresses
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_a, bytes(old_data_a), size=3), 500, 'ns'
    )
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_b, bytes(old_data_b), size=3), 500, 'ns'
    )

    # Exclusive read to A — creates reservation (ID, A)
    excl_id = 0x10
    r_op = axi_master.init_read(addr_a, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr_a:04x}: expected EXOKAY"
    )

    # Exclusive read to B with SAME ID — adds reservation (ID, B), does not evict A
    r_op_b = axi_master.init_read(addr_b, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op_b.wait(), 500, 'ns')
    assert axi_resp(r_op_b) == AxiResp.EXOKAY, (
        f"Exclusive read at 0x{addr_b:04x}: expected EXOKAY"
    )

    # Exclusive write to A — should SUCCEED (reservation (ID, A) still held)
    w_op = axi_master.init_write(addr_a, bytes(new_data_a), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr_a:04x}: expected EXOKAY "
        f"(reservation for A should still be held), got {axi_resp(w_op)}"
    )

    verify_op = axi_master.init_read(addr_a, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(new_data_a), (
        f"After exclusive write to 0x{addr_a:04x}: expected {new_data_a.hex()}, "
        f"got {axi_data(verify_op).hex()}"
    )

    # Exclusive write to B — should SUCCEED (reservation (ID, B) still held)
    w_op_b = axi_master.init_write(addr_b, bytes(new_data_b), awid=excl_id, size=3,
                                    lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op_b.wait(), 500, 'ns')
    assert axi_resp(w_op_b) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr_b:04x}: expected EXOKAY "
        f"(reservation for B should still be held), got {axi_resp(w_op_b)}"
    )

    verify_op_b = axi_master.init_read(addr_b, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op_b.wait(), 500, 'ns')
    assert axi_data(verify_op_b) == bytes(new_data_b), (
        f"After exclusive write to 0x{addr_b:04x}: expected {new_data_b.hex()}, "
        f"got {axi_data(verify_op_b).hex()}"
    )
    my_tb.dut._log.info("  Section 5 OK: both per-ID reservations held and committed")

    # ----------------------------------------------------------------
    # Section 6: Exclusive write without prior exclusive read
    # No reservation exists for this ID, so the exclusive write must
    # fail (BRESP = OKAY) and data must NOT be committed.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 6: No prior reservation ===")

    addr = 0x2070
    seed_data = bytearray(rand_bytes(8))
    excl_data = bytearray(rand_bytes(8))
    while excl_data == seed_data:
        excl_data = bytearray(rand_bytes(8))

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(seed_data), size=3), 500, 'ns'
    )

    # Exclusive write with no preceding exclusive read — should fail
    excl_id = 0x15  # fresh ID with no reservation
    w_op = axi_master.init_write(addr, bytes(excl_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.OKAY, (
        f"Exclusive write at 0x{addr:04x} without prior read: "
        f"expected OKAY (failed), got {axi_resp(w_op)}"
    )

    # Memory should still contain seed_data
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(seed_data), (
        f"After no-reservation exclusive write at 0x{addr:04x}: expected seed "
        f"{seed_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 6 OK: exclusive write without reservation correctly failed")

    # ----------------------------------------------------------------
    # Section 7: Different ID isolation
    # ID 0x10 reserves addr A, ID 0x11 reserves addr B.  Exclusive
    # write from ID 0x10 to addr A should still succeed — the other
    # ID's reservation must not interfere.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 7: Different ID isolation ===")

    addr_a = 0x2080
    addr_b = 0x2090
    old_data_a = bytearray(rand_bytes(8))
    new_data_a = bytearray(rand_bytes(8))
    while new_data_a == old_data_a:
        new_data_a = bytearray(rand_bytes(8))

    id_a = 0x10
    id_b = 0x11

    # Pre-seed addr A
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_a, bytes(old_data_a), size=3), 500, 'ns'
    )

    # Exclusive read to addr A with ID 0x10
    r_op = axi_master.init_read(addr_a, 8, arid=id_a, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    # Exclusive read to addr B with ID 0x11 — different ID, should NOT affect ID 0x10
    r_op_b = axi_master.init_read(addr_b, 8, arid=id_b, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op_b.wait(), 500, 'ns')
    assert axi_resp(r_op_b) == AxiResp.EXOKAY

    # Exclusive write to addr A with ID 0x10 — should succeed (reservation intact)
    w_op = axi_master.init_write(addr_a, bytes(new_data_a), awid=id_a, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr_a:04x} with ID 0x{id_a:02x}: "
        f"expected EXOKAY (other ID shouldn't interfere), got {axi_resp(w_op)}"
    )

    # Verify data was written
    verify_op = axi_master.init_read(addr_a, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(new_data_a), (
        f"Post-exclusive-write readback at 0x{addr_a:04x}: "
        f"expected {new_data_a.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 7 OK: different IDs are isolated")

    # ----------------------------------------------------------------
    # Section 8: Double exclusive write (reservation consumed)
    # After a successful exclusive write clears the reservation, a
    # second exclusive write (same ID, same addr, no new exclusive
    # read) should fail because the reservation was already consumed.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 8: Double exclusive write ===")

    addr = 0x20a0
    seed_data = bytearray(rand_bytes(8))
    write1_data = bytearray(rand_bytes(8))
    write2_data = bytearray(rand_bytes(8))
    # Ensure all distinct
    while write1_data == seed_data:
        write1_data = bytearray(rand_bytes(8))
    while write2_data == seed_data or write2_data == write1_data:
        write2_data = bytearray(rand_bytes(8))

    excl_id = 0x10

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(seed_data), size=3), 500, 'ns'
    )

    # Exclusive read — create reservation
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    # First exclusive write — should succeed and consume reservation
    w_op = axi_master.init_write(addr, bytes(write1_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"First exclusive write at 0x{addr:04x}: expected EXOKAY, got {axi_resp(w_op)}"
    )

    # Second exclusive write (no new exclusive read) — should fail
    w_op2 = axi_master.init_write(addr, bytes(write2_data), awid=excl_id, size=3,
                                   lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op2.wait(), 500, 'ns')
    assert axi_resp(w_op2) == AxiResp.OKAY, (
        f"Second exclusive write at 0x{addr:04x}: expected OKAY (reservation "
        f"consumed), got {axi_resp(w_op2)}"
    )

    # Memory should contain write1_data (first succeeded), not write2_data
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(write1_data), (
        f"After double exclusive write at 0x{addr:04x}: expected write1 "
        f"{write1_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 8 OK: second exclusive write correctly failed")

    # ----------------------------------------------------------------
    # Section 9: Re-reservation after successful exclusive write
    # Full cycle: excl read → excl write (success) → excl read again
    # → excl write again (success).  Verifies the monitor correctly
    # allows a new reservation after the previous one was consumed.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 9: Re-reservation cycle ===")

    addr = 0x20b0
    data_v1 = bytearray(rand_bytes(8))
    data_v2 = bytearray(rand_bytes(8))
    data_v3 = bytearray(rand_bytes(8))
    # Ensure distinct
    while data_v2 == data_v1:
        data_v2 = bytearray(rand_bytes(8))
    while data_v3 == data_v1 or data_v3 == data_v2:
        data_v3 = bytearray(rand_bytes(8))

    excl_id = 0x10

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(data_v1), size=3), 500, 'ns'
    )

    # Cycle 1: exclusive read → exclusive write
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    w_op = axi_master.init_write(addr, bytes(data_v2), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Cycle 1 exclusive write: expected EXOKAY, got {axi_resp(w_op)}"
    )

    # Cycle 2: exclusive read → exclusive write (re-reservation)
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    w_op = axi_master.init_write(addr, bytes(data_v3), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Cycle 2 exclusive write: expected EXOKAY, got {axi_resp(w_op)}"
    )

    # Verify final data is data_v3
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(data_v3), (
        f"After re-reservation cycle at 0x{addr:04x}: expected {data_v3.hex()}, "
        f"got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 9 OK: re-reservation cycle works")

    # ----------------------------------------------------------------
    # Section 10: Size mismatch
    # Exclusive read with size=3 (8 bytes), exclusive write with
    # size=2 (4 bytes).  Per AXI4 spec the exclusive write must use
    # the same size as the exclusive read.  The monitor stores size
    # in the reservation and requires an exact match, so a mismatch
    # correctly causes the exclusive write to fail.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 10: Size mismatch ===")

    addr = 0x20c0
    seed_data = bytearray(rand_bytes(8))
    excl_data = bytearray(rand_bytes(4))  # 4 bytes for size=2

    excl_id = 0x10

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(seed_data), size=3), 500, 'ns'
    )

    # Exclusive read with size=3 (8 bytes)
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    # Exclusive write with size=2 (4 bytes) — size mismatch → should fail
    w_op = axi_master.init_write(addr, bytes(excl_data), awid=excl_id, size=2,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.OKAY, (
        f"Size-mismatched exclusive write at 0x{addr:04x}: expected OKAY "
        f"(failed due to size mismatch), got {axi_resp(w_op)}"
    )

    # Memory should still contain seed_data (exclusive write not committed)
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(seed_data), (
        f"After size-mismatched exclusive write at 0x{addr:04x}: expected seed "
        f"{seed_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 10 OK: size mismatch correctly failed")

    # ----------------------------------------------------------------
    # Section 11: Normal read does not affect reservations
    # Exclusive read → normal read to same address → exclusive write
    # should still succeed.  Normal reads must be transparent to the
    # exclusive monitor.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 11: Normal read doesn't affect reservation ===")

    addr = 0x20d0
    old_data = bytearray(rand_bytes(8))
    new_data = bytearray(rand_bytes(8))
    while new_data == old_data:
        new_data = bytearray(rand_bytes(8))

    excl_id = 0x10

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(old_data), size=3), 500, 'ns'
    )

    # Exclusive read — create reservation
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    # Normal read to the same address — should NOT invalidate
    normal_r = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(normal_r.wait(), 500, 'ns')
    assert axi_resp(normal_r) == AxiResp.OKAY, (
        f"Normal read should return OKAY, got {axi_resp(normal_r)}"
    )

    # Exclusive write — should still succeed (normal read is transparent)
    w_op = axi_master.init_write(addr, bytes(new_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.EXOKAY, (
        f"Exclusive write at 0x{addr:04x} after normal read: expected EXOKAY "
        f"(normal read shouldn't invalidate), got {axi_resp(w_op)}"
    )

    # Verify data was written
    verify_op = axi_master.init_read(addr, 8, size=3)
    await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
    assert axi_data(verify_op) == bytes(new_data), (
        f"Post-exclusive-write readback at 0x{addr:04x}: "
        f"expected {new_data.hex()}, got {axi_data(verify_op).hex()}"
    )
    my_tb.dut._log.info("  Section 11 OK: normal read didn't affect reservation")

    # ----------------------------------------------------------------
    # Section 12: Overlapping snoop invalidation
    # Reserve 8 bytes at addr.  Normal write of 4 bytes that overlaps
    # part of the reserved range.  The snoop_write range overlap check
    # should invalidate the reservation even though the write is smaller.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Exclusive Section 12: Overlapping snoop invalidation ===")

    addr = 0x20e0          # 8-byte aligned
    addr_overlap = addr + 4  # overlaps upper 4 bytes of the 8-byte reservation
    seed_data = bytearray(rand_bytes(8))
    excl_data = bytearray(rand_bytes(8))
    while excl_data == seed_data:
        excl_data = bytearray(rand_bytes(8))

    excl_id = 0x10

    # Pre-seed
    await cocotb.triggers.with_timeout(
        axi_master.write(addr, bytes(seed_data), size=3), 500, 'ns'
    )

    # Exclusive read with size=3 (8 bytes at addr)
    r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3, lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    assert axi_resp(r_op) == AxiResp.EXOKAY

    # Normal write of 4 bytes at addr+4 — overlaps the reserved range
    await cocotb.triggers.with_timeout(
        axi_master.write(addr_overlap, bytes(rand_bytes(4)), size=2),
        500, 'ns'
    )

    # Exclusive write to addr — should FAIL (snoop invalidated by overlap)
    w_op = axi_master.init_write(addr, bytes(excl_data), awid=excl_id, size=3,
                                  lock=AxiLockType.EXCLUSIVE)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    assert axi_resp(w_op) == AxiResp.OKAY, (
        f"Exclusive write at 0x{addr:04x} after overlapping snoop: expected OKAY "
        f"(failed), got {axi_resp(w_op)}"
    )
    my_tb.dut._log.info("  Section 12 OK: overlapping snoop correctly invalidated")

    my_tb.dut._log.info("=== All exclusive access tests passed ===")
    await Timer(1000, unit="ns")
