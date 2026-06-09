import cocotb
from tb import *


@cocotb.test()
async def wstrb_masks_unused_wdata_bytes(dut):
    """Verify non-strobed WDATA bytes are ignored on narrow writes.

    Each transaction is a 2-beat INCR burst with 32B beats (awsize=5, awlen=1).
    We intentionally drive dirty bytes on non-strobed lanes of each 64B WDATA beat
    and verify only strobed lanes update memory.
    """
    from cocotbext.axi.axi_channels import AxiAWSource, AxiWSource, AxiBSink
    from cocotbext.axi.axi_master import AxiMasterRead

    my_tb.set_dut(dut)
    # This test drives AW/W/B manually, so disable the default AxiMaster to
    # avoid a competing B-channel consumer ("unexpected burst ID").
    my_tb.setup_tb(enable_axi_master=False)
    axi_bus = AxiBus.from_prefix(my_tb.dut, "s_axi")
    aw_source = AxiAWSource(axi_bus.write.aw, my_tb.dut.clk, my_tb.dut.rst_b, reset_active_level=False)
    w_source = AxiWSource(axi_bus.write.w, my_tb.dut.clk, my_tb.dut.rst_b, reset_active_level=False)
    b_sink = AxiBSink(axi_bus.write.b, my_tb.dut.clk, my_tb.dut.rst_b, reset_active_level=False)
    read_if = AxiMasterRead(axi_bus.read, my_tb.dut.clk, my_tb.dut.rst_b, reset_active_level=False)

    await my_tb.reset_sequence()
    seed_rng(350)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)

    SHADOW_SIZE = 64 * 1024
    BYTE_LANES = 64
    shadow = bytearray(SHADOW_SIZE)

    async def raw_two_beat_32b_write(addr, beat0_bytes, beat1_bytes, awid):
        """Issue a raw 2-beat burst: 32B + 32B with explicit WSTRB/WDATA control."""
        assert (addr & (BYTE_LANES - 1)) == 0, "Expected 64-byte aligned address"
        assert len(beat0_bytes) == BYTE_LANES, "Expected 64-byte WDATA for beat 0"
        assert len(beat1_bytes) == BYTE_LANES, "Expected 64-byte WDATA for beat 1"

        aw = aw_source._transaction_obj()
        aw.awid = awid
        aw.awaddr = addr
        aw.awlen = 1          # 2 beats
        aw.awsize = 5         # 32 bytes / beat
        aw.awburst = 1  # INCR
        aw.awlock = 0
        aw.awcache = 0b0011
        aw.awprot = 0b010
        aw.awqos = 0
        aw.awregion = 0
        aw.awuser = 0

        w0 = w_source._transaction_obj()
        w0.wdata = int.from_bytes(bytes(beat0_bytes), byteorder="little")
        w0.wstrb = (1 << 32) - 1           # lower 32B valid
        w0.wlast = 0
        if hasattr(w0, "wuser"):
            w0.wuser = 0

        w1 = w_source._transaction_obj()
        w1.wdata = int.from_bytes(bytes(beat1_bytes), byteorder="little")
        w1.wstrb = ((1 << 32) - 1) << 32   # upper 32B valid
        w1.wlast = 1
        if hasattr(w1, "wuser"):
            w1.wuser = 0

        await aw_source.send(aw)
        await w_source.send(w0)
        await w_source.send(w1)

        b = await cocotb.triggers.with_timeout(b_sink.recv(), 1500, "ns")
        bresp = int(getattr(b, "bresp", 0))
        assert bresp == int(AxiResp.OKAY), (
            f"Raw masked write bresp mismatch at 0x{addr:06x}: got {bresp}"
        )

    trials = 96
    for trial in range(trials):
        # Pick one 64-byte aligned line per trial.
        line_base = (_rng.randrange(0, SHADOW_SIZE - BYTE_LANES) // BYTE_LANES) * BYTE_LANES

        payload_lo = bytearray(rand_bytes(32))
        payload_hi = bytearray(rand_bytes(32))

        # Fill with deterministic garbage, then place valid payload only where
        # WSTRB is asserted for each beat.
        beat0_bytes = bytearray(((0xA5 + trial + i) & 0xFF) for i in range(BYTE_LANES))
        beat1_bytes = bytearray(((0x5A + trial + i) & 0xFF) for i in range(BYTE_LANES))
        beat0_bytes[0:32] = payload_lo
        beat1_bytes[32:64] = payload_hi

        await raw_two_beat_32b_write(line_base, beat0_bytes, beat1_bytes, awid=(trial & 0xF))

        # Only strobed bytes update shadow.
        shadow[line_base:line_base + 32] = payload_lo
        shadow[line_base + 32:line_base + 64] = payload_hi

        # Read back full line and compare.
        r_op = read_if.init_read(line_base, BYTE_LANES, size=6)
        await cocotb.triggers.with_timeout(r_op.wait(), 2000, "ns")
        actual = axi_data(r_op)
        expected = bytes(shadow[line_base:line_base + BYTE_LANES])
        assert actual == expected, (
            f"[trial={trial}] masked 2x32B burst mismatch line=0x{line_base:06x}: "
            f"expected {expected.hex()}, got {actual.hex()}"
        )

        # Periodic direct MRAM check to ensure only intended bytes changed.
        if (trial % 16) == 0:
            mismatches = my_tb.verify_mram_contents(line_base, expected)
            assert len(mismatches) == 0, (
                f"[trial={trial}] MRAM mismatch after masked write. First: {mismatches[0]}"
            )

    my_tb.dut._log.info(f"Masked WDATA lane-ignore test passed ({trials} raw 2x32B bursts)")
    await Timer(1000, unit="ns")
