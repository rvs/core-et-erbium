import cocotb
from tb import *


@cocotb.test()
async def out_of_range_address_slverr(dut):
    """Verify that accesses to addresses outside the 16 MB MRAM range
    (i.e. address >= 0x100_0000) return SLVERR on both the read and
    write channels.  In-range accesses must still return OKAY so that
    the error response is not a blanket fault.

    Address map:
        Valid   : 0x000_0000 – 0x0FF_FFFF  (24-bit, 16 MB)
        Invalid : 0x100_0000 – 0xFFF_FFFF  (bits [31:24] non-zero)
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(400)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    MRAM_SIZE  = 0x100_0000   # 16 MB — first out-of-range byte
    OP_TIMEOUT = 1000         # ns per operation

    # Out-of-range addresses to probe (all 8-byte aligned).
    out_of_range_addrs = [
        0x100_0000,   # first byte past 16 MB
        0x100_0008,   # a few bytes in
        0x200_0000,   # 32 MB
        0x800_0000,   # 128 MB
        0xFFF_FFF8,   # near top of 32-bit space
    ]

    # ------------------------------------------------------------------
    # Section 1: Sanity — in-range accesses must still return OKAY.
    # Includes the last valid 8-byte-aligned address (0x0FF_FFF8) to
    # confirm the top of the valid window is correctly accepted.
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== OOR Section 1: In-range sanity check ===")

    in_range_addrs = [
        0x000_0000,   # bottom of range
        0x080_0000,   # mid-range
        0x0FF_FFF8,   # last valid 8-byte-aligned address (top of range)
    ]
    in_range_data = {}
    for addr in in_range_addrs:
        seed = bytearray(rand_bytes(8))
        in_range_data[addr] = seed
        w_op = axi_master.init_write(addr, bytes(seed), size=3)
        await cocotb.triggers.with_timeout(w_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(w_op) == AxiResp.OKAY, (
            f"In-range write at 0x{addr:08x}: expected OKAY, got {axi_resp(w_op)}"
        )
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(r_op) == AxiResp.OKAY, (
            f"In-range read at 0x{addr:08x}: expected OKAY, got {axi_resp(r_op)}"
        )
        assert axi_data(r_op) == bytes(seed), (
            f"In-range readback at 0x{addr:08x}: data mismatch"
        )
        my_tb.dut._log.info(f"  0x{addr:08x} in-range OK")
    my_tb.dut._log.info("  Section 1 OK: in-range accesses (incl. top of range) return OKAY")

    # ------------------------------------------------------------------
    # Section 2: Out-of-range reads must return SLVERR
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== OOR Section 2: Out-of-range reads → SLVERR ===")

    for addr in out_of_range_addrs:
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(r_op) == AxiResp.SLVERR, (
            f"OOR read at 0x{addr:08x}: expected SLVERR (2), got {axi_resp(r_op)}"
        )
        my_tb.dut._log.info(f"  0x{addr:08x} read → SLVERR OK")

    my_tb.dut._log.info("  Section 2 OK: all out-of-range reads returned SLVERR")

    # ------------------------------------------------------------------
    # Section 3: Out-of-range writes must return SLVERR and must NOT
    #            commit any data (in-range memory stays untouched).
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== OOR Section 3: Out-of-range writes → SLVERR ===")

    for addr in out_of_range_addrs:
        poison = bytearray(rand_bytes(8))
        w_op = axi_master.init_write(addr, bytes(poison), size=3)
        await cocotb.triggers.with_timeout(w_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(w_op) == AxiResp.SLVERR, (
            f"OOR write at 0x{addr:08x}: expected SLVERR (2), got {axi_resp(w_op)}"
        )
        my_tb.dut._log.info(f"  0x{addr:08x} write → SLVERR OK")

    my_tb.dut._log.info("  Section 3 OK: all out-of-range writes returned SLVERR")

    # ------------------------------------------------------------------
    # Section 4: Various transfer sizes at the first out-of-range address
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== OOR Section 4: Various sizes at boundary ===")

    for size in range(7):   # size 0 (1 B) through size 6 (64 B)
        byte_width = 1 << size
        # Align the boundary address up to the required size alignment
        boundary = (MRAM_SIZE + byte_width - 1) & ~(byte_width - 1)

        r_op = axi_master.init_read(boundary, byte_width, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(r_op) == AxiResp.SLVERR, (
            f"OOR read size={size} ({byte_width}B) at 0x{boundary:08x}: "
            f"expected SLVERR, got {axi_resp(r_op)}"
        )

        poison = bytearray(rand_bytes(byte_width))
        w_op = axi_master.init_write(boundary, bytes(poison), size=size)
        await cocotb.triggers.with_timeout(w_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(w_op) == AxiResp.SLVERR, (
            f"OOR write size={size} ({byte_width}B) at 0x{boundary:08x}: "
            f"expected SLVERR, got {axi_resp(w_op)}"
        )
        my_tb.dut._log.info(f"  size={size} ({byte_width}B) → SLVERR OK")

    my_tb.dut._log.info("  Section 4 OK: boundary accesses at all sizes returned SLVERR")

    # ------------------------------------------------------------------
    # Section 5: In-range memory is unaffected after all OOR accesses
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== OOR Section 5: In-range memory intact after OOR writes ===")

    for addr in in_range_addrs:
        r_op = axi_master.init_read(addr, 8, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), OP_TIMEOUT, 'ns')
        assert axi_resp(r_op) == AxiResp.OKAY, (
            f"Post-OOR in-range read at 0x{addr:08x}: expected OKAY, got {axi_resp(r_op)}"
        )
        assert axi_data(r_op) == bytes(in_range_data[addr]), (
            f"Post-OOR in-range readback at 0x{addr:08x}: data was corrupted"
        )
    my_tb.dut._log.info("  Section 5 OK: in-range memory intact after OOR accesses")

    my_tb.dut._log.info("=== Out-of-range address SLVERR tests passed ===")
    await Timer(1000, unit="ns")
