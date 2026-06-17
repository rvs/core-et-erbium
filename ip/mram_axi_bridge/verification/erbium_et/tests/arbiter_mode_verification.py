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
async def arbiter_mode_verification(dut):
    """Verify all four arbiter modes behave correctly under contention.

    For each mode, we create a simultaneous read+write scenario and verify
    that the arbiter resolves the conflict according to the selected policy.
    We confirm the expected behavior (positive case) and also check that the
    opposite priority behavior does NOT occur (negative case).
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(8)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master
    treg_master = my_tb.axi_treg_master

    # ----------------------------------------------------------------
    # Section 1: Write Priority (mode=0)
    # When both read and write are pending simultaneously, write wins.
    # The read is serviced after the write, so the read sees the NEW data.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Arbiter Section 1: Write Priority ===")
    await set_arbiter_mode(treg_master, ARBITER_WRITE_PRIORITY)
    await Timer(10, unit="ns")

    for trial in range(4):
        addr = 0x1000 + trial * 0x10
        old_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))

        # Ensure old_data != new_data
        while new_data == old_data:
            new_data = bytearray(rand_bytes(8))

        # Pre-seed with old_data
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(old_data), size=3), 500, 'ns'
        )

        # Fire simultaneous write (new_data) and read — write should win
        w_op = axi_master.init_write(addr, bytes(new_data), size=3)
        r_op = axi_master.init_read(addr, 8, size=3)

        await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

        # Positive: read returns NEW data (write was prioritized, completed first)
        assert axi_data(r_op) == bytes(new_data), (
            f"WritePriority trial {trial}: read should see new_data "
            f"(write won arbitration). "
            f"Expected {new_data.hex()}, got {axi_data(r_op).hex()}"
        )

        # Negative: read did NOT return old_data (that would mean read raced ahead)
        assert axi_data(r_op) != bytes(old_data), (
            f"WritePriority trial {trial}: read returned stale old_data — "
            f"indicates read was incorrectly prioritized over write"
        )

        my_tb.dut._log.info(
            f"  WritePriority OK: addr=0x{addr:04x}, trial={trial}"
        )

    # ----------------------------------------------------------------
    # Section 2: Read Priority (mode=1)
    # When both read and write are pending simultaneously, read wins.
    # The read is serviced before the write, so the read sees the OLD data.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Arbiter Section 2: Read Priority ===")
    await set_arbiter_mode(treg_master, ARBITER_READ_PRIORITY)
    await Timer(10, unit="ns")

    for trial in range(4):
        addr = 0x1100 + trial * 0x10
        old_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))

        while new_data == old_data:
            new_data = bytearray(rand_bytes(8))

        # Pre-seed with old_data
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(old_data), size=3), 500, 'ns'
        )

        # Fire simultaneous write (new_data) and read — read should win
        w_op = axi_master.init_write(addr, bytes(new_data), size=3)
        r_op = axi_master.init_read(addr, 8, size=3)

        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
        await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')

        # Positive: read returns OLD data (read was prioritized, serviced first)
        assert axi_data(r_op) == bytes(old_data), (
            f"ReadPriority trial {trial}: read should see old_data "
            f"(read won arbitration, serviced before write). "
            f"Expected {old_data.hex()}, got {axi_data(r_op).hex()}"
        )

        # Negative: read did NOT return new_data (that would mean write raced ahead)
        assert axi_data(r_op) != bytes(new_data), (
            f"ReadPriority trial {trial}: read returned new_data — "
            f"indicates write was incorrectly prioritized over read"
        )

        # Verify write still completed: read back should now show new_data
        verify_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
        assert axi_data(verify_op) == bytes(new_data), (
            f"ReadPriority trial {trial}: post-write readback failed. "
            f"Expected {new_data.hex()}, got {axi_data(verify_op).hex()}"
        )

        my_tb.dut._log.info(
            f"  ReadPriority OK: addr=0x{addr:04x}, trial={trial}"
        )

    # ----------------------------------------------------------------
    # Section 3: Round Robin (mode=2)
    # Priority is sticky — starts at Rd_Priority and stays there until a
    # simultaneous conflict occurs, which toggles it. Non-simultaneous
    # transactions do NOT change the priority.
    #
    # Sub-test A: Several non-simultaneous reads/writes — priority stays
    #   at Rd_Priority throughout (no conflicts to trigger a toggle).
    # Sub-test B: A simultaneous conflict — read wins (Rd_Priority), then
    #   priority toggles to Wr_Priority.
    # Sub-test C: More non-simultaneous transactions — priority stays at
    #   Wr_Priority (sticky, no conflict).
    # Sub-test D: Another simultaneous conflict — write wins (Wr_Priority),
    #   then priority toggles back to Rd_Priority.
    # Sub-test E: Final simultaneous conflict — read wins again, confirming
    #   we're back to Rd_Priority.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Arbiter Section 3: Round Robin ===")
    await set_arbiter_mode(treg_master, ARBITER_ROUND_ROBIN)
    await Timer(10, unit="ns")

    # --- Sub-test A: Non-simultaneous transactions (priority stays Rd) ---
    my_tb.dut._log.info("  RoundRobin sub-test A: non-simultaneous (Rd stays)")
    for i in range(4):
        addr = 0x1200 + i * 0x10
        data = bytearray(rand_bytes(8))
        # Blocking write, then blocking read — never simultaneous
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=3), 500, 'ns'
        )
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
        assert axi_data(r_op) == bytes(data), (
            f"RoundRobin sub-A write/read {i} data mismatch"
        )
    my_tb.dut._log.info("    Sub-test A OK: non-simultaneous ops completed")

    # --- Sub-test B: First simultaneous conflict (Rd_Priority → read wins) ---
    my_tb.dut._log.info("  RoundRobin sub-test B: first conflict (read wins)")
    addr_b = 0x1240
    old_data_b = bytearray(rand_bytes(8))
    new_data_b = bytearray(rand_bytes(8))
    while new_data_b == old_data_b:
        new_data_b = bytearray(rand_bytes(8))

    await cocotb.triggers.with_timeout(
        axi_master.write(addr_b, bytes(old_data_b), size=3), 500, 'ns'
    )
    # Simultaneous write + read
    w_op = axi_master.init_write(addr_b, bytes(new_data_b), size=3)
    r_op = axi_master.init_read(addr_b, 8, size=3)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')

    # Read wins (Rd_Priority) → read sees old data
    assert axi_data(r_op) == bytes(old_data_b), (
        f"RoundRobin sub-B: read should win (Rd_Priority), see old_data. "
        f"Expected {old_data_b.hex()}, got {axi_data(r_op).hex()}"
    )
    # Priority has now toggled to Wr_Priority
    my_tb.dut._log.info("    Sub-test B OK: read won, priority → Wr")

    # --- Sub-test C: Non-simultaneous transactions (priority stays Wr) ---
    my_tb.dut._log.info("  RoundRobin sub-test C: non-simultaneous (Wr stays)")
    for i in range(3):
        addr = 0x1280 + i * 0x10
        data = bytearray(rand_bytes(8))
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=3), 500, 'ns'
        )
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
        assert axi_data(r_op) == bytes(data), (
            f"RoundRobin sub-C write/read {i} data mismatch"
        )
    my_tb.dut._log.info("    Sub-test C OK: non-simultaneous ops completed")

    # --- Sub-test D: Second conflict (Wr_Priority → write wins) ---
    my_tb.dut._log.info("  RoundRobin sub-test D: second conflict (write wins)")
    addr_d = 0x12B0
    old_data_d = bytearray(rand_bytes(8))
    new_data_d = bytearray(rand_bytes(8))
    while new_data_d == old_data_d:
        new_data_d = bytearray(rand_bytes(8))

    await cocotb.triggers.with_timeout(
        axi_master.write(addr_d, bytes(old_data_d), size=3), 500, 'ns'
    )
    # Simultaneous write + read
    w_op = axi_master.init_write(addr_d, bytes(new_data_d), size=3)
    r_op = axi_master.init_read(addr_d, 8, size=3)
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

    # Write wins (Wr_Priority) → read sees new data
    assert axi_data(r_op) == bytes(new_data_d), (
        f"RoundRobin sub-D: write should win (Wr_Priority), read sees new_data. "
        f"Expected {new_data_d.hex()}, got {axi_data(r_op).hex()}"
    )
    # Priority has now toggled back to Rd_Priority
    my_tb.dut._log.info("    Sub-test D OK: write won, priority → Rd")

    # --- Sub-test E: Third conflict (Rd_Priority again → read wins) ---
    my_tb.dut._log.info("  RoundRobin sub-test E: third conflict (read wins)")
    addr_e = 0x12C0
    old_data_e = bytearray(rand_bytes(8))
    new_data_e = bytearray(rand_bytes(8))
    while new_data_e == old_data_e:
        new_data_e = bytearray(rand_bytes(8))

    await cocotb.triggers.with_timeout(
        axi_master.write(addr_e, bytes(old_data_e), size=3), 500, 'ns'
    )
    # Simultaneous write + read
    w_op = axi_master.init_write(addr_e, bytes(new_data_e), size=3)
    r_op = axi_master.init_read(addr_e, 8, size=3)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
    await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')

    # Read wins (Rd_Priority) → read sees old data
    assert axi_data(r_op) == bytes(old_data_e), (
        f"RoundRobin sub-E: read should win (Rd_Priority again), see old_data. "
        f"Expected {old_data_e.hex()}, got {axi_data(r_op).hex()}"
    )
    my_tb.dut._log.info("    Sub-test E OK: read won again, confirming toggle")

    # ----------------------------------------------------------------
    # Section 4: Oldest First (mode=3)
    # The track_oldest_request rule latches which channel was most recently
    # the sole requester.  When a simultaneous conflict later occurs, the
    # latched value is the tiebreaker.
    #
    # Sub-test A: Issue a solo write (latches Wr_Priority), then a
    #   simultaneous write+read conflict → write should win.
    # Sub-test B: Issue a solo read (latches Rd_Priority), then a
    #   simultaneous write+read conflict → read should win.
    # ----------------------------------------------------------------
    my_tb.dut._log.info("=== Arbiter Section 4: Oldest First ===")
    await set_arbiter_mode(treg_master, ARBITER_OLDEST_FIRST)
    await Timer(10, unit="ns")

    # Sub-test A: Latch write as oldest, then simultaneous conflict
    # Write should win → read sees new data
    my_tb.dut._log.info("  OldestFirst sub-test A: latch write, then conflict")
    for trial in range(3):
        addr_seed = 0x1300 + trial * 0x40
        addr_conflict = 0x1310 + trial * 0x40
        old_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))

        while new_data == old_data:
            new_data = bytearray(rand_bytes(8))

        # Solo write to a different address — latches oldest_request = Wr_Priority
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_seed, bytes(rand_bytes(8)), size=3),
            500, 'ns'
        )

        # Pre-seed the conflict address with old_data
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_conflict, bytes(old_data), size=3), 500, 'ns'
        )

        # Now simultaneous write+read to the conflict address
        w_op = axi_master.init_write(addr_conflict, bytes(new_data), size=3)
        r_op = axi_master.init_read(addr_conflict, 8, size=3)

        await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')
        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

        # Write was oldest → write wins → read sees new data
        assert axi_data(r_op) == bytes(new_data), (
            f"OldestFirst-A trial {trial}: write was oldest, "
            f"read should see new_data. "
            f"Expected {new_data.hex()}, got {axi_data(r_op).hex()}"
        )
        my_tb.dut._log.info(
            f"    OldestFirst-A OK: addr=0x{addr_conflict:04x}, trial={trial}"
        )

    # Sub-test B: Latch read as oldest, then simultaneous conflict
    # Read should win → read sees old data
    my_tb.dut._log.info("  OldestFirst sub-test B: latch read, then conflict")
    for trial in range(3):
        addr_seed = 0x1400 + trial * 0x40
        addr_conflict = 0x1410 + trial * 0x40
        old_data = bytearray(rand_bytes(8))
        new_data = bytearray(rand_bytes(8))

        while new_data == old_data:
            new_data = bytearray(rand_bytes(8))

        # Pre-seed both addresses so the solo read has valid data
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_seed, bytes(rand_bytes(8)), size=3),
            500, 'ns'
        )
        await cocotb.triggers.with_timeout(
            axi_master.write(addr_conflict, bytes(old_data), size=3), 500, 'ns'
        )

        # Solo read from a different address — latches oldest_request = Rd_Priority
        solo_r = axi_master.init_read(addr_seed, 8, size=3)
        await cocotb.triggers.with_timeout(solo_r.wait(), 500, 'ns')

        # Now simultaneous write+read to the conflict address
        w_op = axi_master.init_write(addr_conflict, bytes(new_data), size=3)
        r_op = axi_master.init_read(addr_conflict, 8, size=3)

        await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')
        await cocotb.triggers.with_timeout(w_op.wait(), 500, 'ns')

        # Read was oldest → read wins → read sees old data
        assert axi_data(r_op) == bytes(old_data), (
            f"OldestFirst-B trial {trial}: read was oldest, "
            f"read should see old_data. "
            f"Expected {old_data.hex()}, got {axi_data(r_op).hex()}"
        )

        # Verify write still completed
        verify_op = axi_master.init_read(addr_conflict, 8, size=3)
        await cocotb.triggers.with_timeout(verify_op.wait(), 500, 'ns')
        assert axi_data(verify_op) == bytes(new_data), (
            f"OldestFirst-B trial {trial}: post-write readback failed. "
            f"Expected {new_data.hex()}, got {axi_data(verify_op).hex()}"
        )
        my_tb.dut._log.info(
            f"    OldestFirst-B OK: addr=0x{addr_conflict:04x}, trial={trial}"
        )

    my_tb.dut._log.info("=== All arbiter mode verification tests passed ===")
    await Timer(1000, unit="ns")
