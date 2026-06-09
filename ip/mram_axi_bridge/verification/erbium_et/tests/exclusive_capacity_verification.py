import cocotb
from tb import *


@cocotb.test()
async def exclusive_capacity_verification(dut):
    """Verify exclusive monitor capacity with 32 IDs and multiple addresses.

    Pass 1: 32 IDs × 1 address  — hold all, verify, release+reread, re-hold,
            break one ID at a time.
    Pass 2: 32 IDs × 2 addresses — same sequence.
    Pass 3: 32 IDs × 3 addresses — same sequence.
    Pass 4: 32 IDs × 4 addresses — same sequence.
    Pass 5: Try 5 addresses per ID — should fail (monitor can only hold 4
            per ID, so the earliest reservation gets evicted).
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(300)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    NUM_IDS = 32
    OP_TIMEOUT = 1000  # ns per AXI operation

    def make_addr(excl_id, addr_slot):
        """Unique 8-byte-aligned address for a given (id, slot) pair."""
        return 0x4000 + excl_id * 0x100 + addr_slot * 0x10

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    async def excl_read(excl_id, addr):
        """Exclusive read; asserts EXOKAY and returns read data."""
        r_op = axi_master.init_read(addr, 8, arid=excl_id, size=3,
                                     lock=AxiLockType.EXCLUSIVE)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(r_op) == AxiResp.EXOKAY, (
            f"Exclusive read ID={excl_id} addr=0x{addr:06x}: "
            f"expected EXOKAY, got {axi_resp(r_op)}"
        )
        return axi_data(r_op)

    async def excl_write(excl_id, addr, data):
        """Exclusive write; returns the response (caller checks)."""
        w_op = axi_master.init_write(addr, bytes(data), awid=excl_id, size=3,
                                      lock=AxiLockType.EXCLUSIVE)
        await cocotb.triggers.with_timeout(w_op.wait(), OP_TIMEOUT, 'ns')
        return axi_resp(w_op)

    async def normal_write(addr, data):
        """Normal (non-exclusive) 8-byte write."""
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=3), OP_TIMEOUT, 'ns'
        )

    async def normal_read(addr):
        """Normal 8-byte read; returns data bytes."""
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        return axi_data(r_op)

    # ==================================================================
    # Passes 1–4: N addresses per ID  (N = 1, 2, 3, 4)
    # ==================================================================
    for addrs_per_id in range(1, 5):
        pass_label = f"Pass {addrs_per_id}"
        total_reservations = NUM_IDS * addrs_per_id
        my_tb.dut._log.info(
            f"=== Exclusive Capacity {pass_label}: "
            f"{NUM_IDS} IDs × {addrs_per_id} address(es) "
            f"({total_reservations} total) ==="
        )

        # --------------------------------------------------------------
        # Pre-seed every address with known data
        # --------------------------------------------------------------
        seed_data = {}
        for eid in range(NUM_IDS):
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                data = bytearray(rand_bytes(8))
                seed_data[(eid, slot)] = data
                await normal_write(addr, data)

        # --------------------------------------------------------------
        # Step A: Establish exclusive reservations on all IDs/addresses
        # --------------------------------------------------------------
        my_tb.dut._log.info(
            f"  {pass_label} Step A: Establishing {total_reservations} reservations"
        )
        for eid in range(NUM_IDS):
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                read_back = await excl_read(eid, addr)
                assert read_back == bytes(seed_data[(eid, slot)]), (
                    f"{pass_label} Step A: ID={eid} slot={slot} "
                    f"addr=0x{addr:06x}: data mismatch on exclusive read"
                )

        # --------------------------------------------------------------
        # Step B: Verify all are held — exclusive write → EXOKAY
        #         This also releases (consumes) each reservation and
        #         commits new data.
        # --------------------------------------------------------------
        my_tb.dut._log.info(
            f"  {pass_label} Step B: Verifying all held via exclusive write"
        )
        write_data = {}
        for eid in range(NUM_IDS):
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                data = bytearray(rand_bytes(8))
                while data == seed_data[(eid, slot)]:
                    data = bytearray(rand_bytes(8))
                write_data[(eid, slot)] = data
                resp = await excl_write(eid, addr, data)
                assert resp == AxiResp.EXOKAY, (
                    f"{pass_label} Step B: ID={eid} slot={slot} "
                    f"addr=0x{addr:06x}: expected EXOKAY, got {resp}"
                )

        # --------------------------------------------------------------
        # Step C: Re-read all addresses (normal reads) to confirm the
        #         exclusive writes actually committed data.
        # --------------------------------------------------------------
        my_tb.dut._log.info(
            f"  {pass_label} Step C: Re-reading to verify committed data"
        )
        for eid in range(NUM_IDS):
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                read_back = await normal_read(addr)
                expected = bytes(write_data[(eid, slot)])
                assert read_back == expected, (
                    f"{pass_label} Step C: ID={eid} slot={slot} "
                    f"addr=0x{addr:06x}: expected {expected.hex()}, "
                    f"got {read_back.hex()}"
                )

        # --------------------------------------------------------------
        # Step D: Re-establish all reservations
        # --------------------------------------------------------------
        my_tb.dut._log.info(
            f"  {pass_label} Step D: Re-establishing {total_reservations} reservations"
        )
        for eid in range(NUM_IDS):
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                await excl_read(eid, addr)

        # --------------------------------------------------------------
        # Step E: Break exclusivity one ID at a time.
        #   For each ID:
        #     1. Normal write to each of its addresses (snoop invalidates)
        #     2. Exclusive write to each address → must fail (OKAY)
        #     3. Normal read to confirm memory has the interloper data
        # --------------------------------------------------------------
        my_tb.dut._log.info(
            f"  {pass_label} Step E: Breaking exclusivity one ID at a time"
        )
        for eid in range(NUM_IDS):
            interloper_data = {}
            excl_fail_data = {}

            # 1. Normal writes break all reservations for this ID
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                idata = bytearray(rand_bytes(8))
                interloper_data[slot] = idata
                await normal_write(addr, idata)

            # 2. Exclusive writes must all fail
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                fdata = bytearray(rand_bytes(8))
                excl_fail_data[slot] = fdata
                resp = await excl_write(eid, addr, fdata)
                assert resp == AxiResp.OKAY, (
                    f"{pass_label} Step E: ID={eid} slot={slot} "
                    f"addr=0x{addr:06x}: expected OKAY (broken), got {resp}"
                )

            # 3. Memory should contain the interloper data
            for slot in range(addrs_per_id):
                addr = make_addr(eid, slot)
                read_back = await normal_read(addr)
                expected = bytes(interloper_data[slot])
                assert read_back == expected, (
                    f"{pass_label} Step E verify: ID={eid} slot={slot} "
                    f"addr=0x{addr:06x}: expected interloper {expected.hex()}, "
                    f"got {read_back.hex()}"
                )

        my_tb.dut._log.info(f"  {pass_label} PASSED")

    # ==================================================================
    # Pass 5: 5 addresses per ID — should FAIL
    # The monitor can hold at most 4 addresses per ID, so the 5th
    # exclusive read evicts the 1st reservation.  An exclusive write
    # to the 1st address must therefore return OKAY (not EXOKAY).
    # ==================================================================
    my_tb.dut._log.info(
        "=== Exclusive Capacity Pass 5: 5 addresses per ID (expect eviction) ==="
    )

    # Pre-seed 5 addresses for each ID
    for eid in range(NUM_IDS):
        for slot in range(5):
            addr = make_addr(eid, slot)
            data = bytearray(rand_bytes(8))
            await normal_write(addr, data)

    # Establish 5 exclusive reservations per ID (the 5th should evict
    # the 1st since the monitor only has 4 slots per ID).
    for eid in range(NUM_IDS):
        for slot in range(5):
            addr = make_addr(eid, slot)
            await excl_read(eid, addr)

    # Exclusive write to the FIRST address of each ID — should fail
    # because that reservation was evicted when the 5th was added.
    my_tb.dut._log.info("  Verifying 1st address evicted for each ID")
    for eid in range(NUM_IDS):
        addr_first = make_addr(eid, 0)
        data = bytearray(rand_bytes(8))
        resp = await excl_write(eid, addr_first, data)
        assert resp == AxiResp.OKAY, (
            f"Pass 5: ID={eid} addr=0x{addr_first:06x}: expected OKAY "
            f"(1st address evicted by 5th), got {resp}"
        )

    # Sanity: exclusive write to the LAST (5th) address should succeed
    # since it's the most recently reserved.
    my_tb.dut._log.info("  Verifying 5th address still held for each ID")
    for eid in range(NUM_IDS):
        addr_last = make_addr(eid, 4)
        data = bytearray(rand_bytes(8))
        resp = await excl_write(eid, addr_last, data)
        assert resp == AxiResp.EXOKAY, (
            f"Pass 5 sanity: ID={eid} addr=0x{addr_last:06x}: expected EXOKAY "
            f"(5th address should still be held), got {resp}"
        )

    my_tb.dut._log.info("  Pass 5 PASSED: 5th address correctly evicts 1st")
    my_tb.dut._log.info("=== All exclusive capacity tests passed ===")
    await Timer(1000, unit="ns")
