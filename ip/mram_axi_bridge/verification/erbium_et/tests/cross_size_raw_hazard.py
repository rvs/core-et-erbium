import cocotb
from tb import *


@cocotb.test()
async def cross_size_raw_hazard(dut):
    """Exact replay of the failing transaction sequence from foo.out (1200–1297 ns).

    Original failure at 1297 ns:
      SIZE_64B write to 0x0 (BRESP at 1274 ns) immediately followed by a
      SIZE_1B read at 0x2B that returned all-zeros instead of byte 0x5E.

    Concurrent traffic from the 1200–1268 ns window is reproduced in the
    same AXI-channel order to replicate the microarchitectural conditions:
      1210 ns: SIZE_64B write to 0xED1740   (AW channel)
      1211 ns: SIZE_64B read  from 0x0      (AR channel — in-flight with critical write)
      1212 ns: SIZE_1B  read  from 0xD876B9 (AR channel)
      1213 ns: SIZE_8B  write to  0x200000  (AW channel)
      1241 ns: SIZE_1B  write to  0x30      (AW channel — same cache-line as 0x0)
      1268 ns: SIZE_64B write to  0x0       (AW channel — critical; byte[0x2B]=0x5E)
      1274 ns: BRESP for critical write
      1281 ns: SIZE_1B  read  from 0x2B     (AR channel — FAILS in original log)

    All WDATA values are taken verbatim from the log.  They are displayed
    MSB-first (bit 511 = leftmost hex char).  In AXI the data bus is
    little-endian (byte 0 = bits[7:0]), so .to_bytes(N, 'little') converts
    each value into address-ordered bytes suitable for the AXI master.
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    # ----------------------------------------------------------------
    # @1210 ns  SIZE_64B write to 0xED1740  (WSTRB=0xFFFFFFFFFFFFFFFF)
    # WDATA MSB-first:
    #   af009c07a6cd02fdd5a2954e4be0eda5_ee7a1445030939d0ab4aff6417d01f4c
    #   _53290b050c7c074a313064b8899f2d13_075175087dbfc6b2d2fb2a3c708e2b64
    # ----------------------------------------------------------------
    axi_master.init_write(
        0xED1740,
        int("af009c07a6cd02fdd5a2954e4be0eda5"
            "ee7a1445030939d0ab4aff6417d01f4c"
            "53290b050c7c074a313064b8899f2d13"
            "075175087dbfc6b2d2fb2a3c708e2b64", 16).to_bytes(64, 'little'),
        size=6,
    )

    # ----------------------------------------------------------------
    # @1211 ns  SIZE_64B read from 0x0
    # Issued via the independent AR channel — concurrent with the AW
    # channel writes above and below.  This read is in-flight when the
    # critical write to 0x0 is dispatched and may contribute to the hazard.
    # ----------------------------------------------------------------
    axi_master.init_read(0x0, 64, size=6)

    # ----------------------------------------------------------------
    # @1212 ns  SIZE_1B read from 0xD876B9
    # ----------------------------------------------------------------
    axi_master.init_read(0xD876B9, 1, size=0)

    # ----------------------------------------------------------------
    # @1213 ns  SIZE_8B write to 0x200000  (WSTRB=0xFF)
    # Bytes being written (lanes 0-7, addr 0x200000..0x200007):
    #   WDATA bits[63:0] = cd80dbc6bbb46535 → LE bytes = 3565b446bbc6db80
    # ----------------------------------------------------------------
    axi_master.init_write(
        0x200000,
        int("cd80dbc6bbb46535", 16).to_bytes(8, 'little'),
        size=3,
    )

    # ----------------------------------------------------------------
    # @1241 ns  SIZE_1B write to 0x30  (WSTRB=0x1000000000000, byte lane 48)
    # Byte at lane 48: seg1 chars[30-31] of
    #   890bf28db21287e4c88db81dc54e88e4 → 0xe4
    # Address 0x30 is in the same 64-byte cache-line as 0x0 (offsets 0x00–0x3F).
    # ----------------------------------------------------------------
    axi_master.init_write(0x30, bytes([0xe4]), size=0)

    # ----------------------------------------------------------------
    # @1268 ns  SIZE_64B write to 0x0  — the critical write
    # BRESP arrived at 1274 ns (6-cycle latency in the original log).
    # WDATA MSB-first (512-bit):
    #   ed83eeb15dcb9c6ccbc83247a120f43e_
    #   51393ba65e450395721cf542dad479ac_  ← byte[0x2B]=0x5E (seg2 chars[8:10])
    #   3d7c96e446e7c7cc268890357f16422c_
    #   60573819702ff6ce1c82953bcd500a2f
    # Byte 0x2B derivation:
    #   seg2 = bits[383:256] = bytes[47:32]; byte 43 → chars[8:10] = '5e' ✓
    # ----------------------------------------------------------------
    _d_critical = int(
        "ed83eeb15dcb9c6ccbc83247a120f43e"
        "51393ba65e450395721cf542dad479ac"
        "3d7c96e446e7c7cc268890357f16422c"
        "60573819702ff6ce1c82953bcd500a2f",
        16,
    ).to_bytes(64, 'little')
    assert _d_critical[0x2B] == 0x5E, "sanity: byte 0x2B of critical WDATA must be 0x5E"

    await cocotb.triggers.with_timeout(
        axi_master.write(0x0, _d_critical, size=6), 2000, 'ns'
    )

    # ----------------------------------------------------------------
    # @1281 ns  SIZE_1B read from 0x2B  — the failing read
    # In the log the AR was dispatched in the same cycle as BRESP (1274 ns)
    # and appeared on the bus 7 ns later.  No delay is added here.
    # Expected: RDATA byte[0x2B] = 0x5E
    # Actual in original log: 0x00  →  FAIL
    # ----------------------------------------------------------------
    r_op = axi_master.init_read(0x2B, 1, size=0)
    await cocotb.triggers.with_timeout(r_op.wait(), 500, 'ns')

    assert axi_resp(r_op) == AxiResp.OKAY, (
        f"Read at 0x2B: unexpected RESP={axi_resp(r_op)} (expected OKAY)"
    )
    got = axi_data(r_op)
    assert got == bytes([0x5E]), (
        f"cross-size RAW hazard: expected 0x5E at 0x002B, got 0x{got.hex()}\n"
        f"  Replay: 1268ns AXI-W AWADDR=0x0 AWSIZE=SIZE_64B BRESP@1274ns "
        f"→ AR ARADDR=0x2B ARSIZE=SIZE_1B dispatched@1274ns "
        f"seen@1281ns → RDATA@1297ns=0x00 (expected 0x5E)"
    )
    my_tb.dut._log.info("cross_size_raw_hazard passed")
    await Timer(1000, unit="ns")
