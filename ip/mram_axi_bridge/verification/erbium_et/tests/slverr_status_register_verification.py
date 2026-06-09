import cocotb
from tb import *


@cocotb.test()
async def slverr_status_register_verification(dut):
    """Verify the sticky SLVERR status register (slverr_status_reg @ 0x10).

    The register captures hardware-set sticky bits whenever the bridge
    rejects an AXI transaction with SLVERR due to an out-of-range address.
    Both bits are clear-on-read (the act of reading clears them).

    Sections:
        0  Pre-condition   — register reads 0 immediately after reset.
        1  OOR read        — read to addr >= 0x100_0000 returns SLVERR and
                             sets oor_read (bit 0) in the status register.
        2  OOR write       — write to addr >= 0x100_0000 returns SLVERR and
                             sets oor_write (bit 1) in the status register.
        3  First status read  — both bits are 1 (sticky, not yet read).
        4  Second status read — both bits are 0 (clear-on-read fired).
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(500)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master  = my_tb.axi_master
    treg_master = my_tb.axi_treg_master

    OOR_READ_ADDR  = 0x100_0000           # first byte past 16 MB MRAM window
    OOR_WRITE_ADDR = 0x200_0000           # a different OOR address for the write
    OP_TIMEOUT     = 1000                 # ns per AXI operation

    async def read_slverr_reg():
        """Read the 64-bit slverr_status_reg and return the two lsbs."""
        result = await treg_master.read(SLVERR_STATUS_REG_ADDR, 8)
        return int.from_bytes(result.data, 'little') & 0x3

    # ------------------------------------------------------------------
    # Section 0: Pre-condition — register must be 0 after reset
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== SLVERR Reg Section 0: Pre-condition (reset value = 0) ===")
    val = await read_slverr_reg()
    assert val == 0, (
        f"Pre-condition: slverr_status_reg should be 0 after reset, got {val:#x}"
    )
    my_tb.dut._log.info("  Section 0 OK: register reads 0 after reset")

    # ------------------------------------------------------------------
    # Section 1: OOR read — bridge returns SLVERR, oor_read bit gets set
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== SLVERR Reg Section 1: OOR read → SLVERR + oor_read set ===")
    r_result = await cocotb.triggers.with_timeout(
        axi_master.read(OOR_READ_ADDR, 8, size=3), OP_TIMEOUT, 'ns'
    )
    assert r_result.resp == AxiResp.SLVERR, (
        f"OOR read at 0x{OOR_READ_ADDR:08x}: expected SLVERR, got {r_result.resp}"
    )
    my_tb.dut._log.info(f"  OOR read at 0x{OOR_READ_ADDR:08x} returned SLVERR")

    # ------------------------------------------------------------------
    # Section 2: OOR write — bridge returns SLVERR, oor_write bit gets set
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== SLVERR Reg Section 2: OOR write → SLVERR + oor_write set ===")
    w_result = await cocotb.triggers.with_timeout(
        axi_master.write(OOR_WRITE_ADDR, bytes(8), size=3), OP_TIMEOUT, 'ns'
    )
    assert w_result.resp == AxiResp.SLVERR, (
        f"OOR write at 0x{OOR_WRITE_ADDR:08x}: expected SLVERR, got {w_result.resp}"
    )
    my_tb.dut._log.info(f"  OOR write at 0x{OOR_WRITE_ADDR:08x} returned SLVERR")

    # Give the hwset pulses a clock or two to settle into the register
    await Timer(10, unit="ns")

    # ------------------------------------------------------------------
    # Section 3: First status-register read — both sticky bits must be set
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== SLVERR Reg Section 3: Both sticky bits set ===")
    val = await read_slverr_reg()
    assert val & 0x1, (
        f"oor_read (bit 0) should be set after OOR read; slverr_status = {val:#x}"
    )
    assert val & 0x2, (
        f"oor_write (bit 1) should be set after OOR write; slverr_status = {val:#x}"
    )
    my_tb.dut._log.info(f"  Section 3 OK: slverr_status = {val:#x} (oor_read=1, oor_write=1)")

    # ------------------------------------------------------------------
    # Section 4: Second status-register read — clear-on-read must fire
    # ------------------------------------------------------------------
    my_tb.dut._log.info("=== SLVERR Reg Section 4: Clear-on-read ===")
    val = await read_slverr_reg()
    assert val == 0, (
        f"Clear-on-read: slverr_status_reg should read 0 on second access, got {val:#x}"
    )
    my_tb.dut._log.info("  Section 4 OK: register cleared to 0 on second read")

    my_tb.dut._log.info("=== SLVERR status register verification passed ===")
    await Timer(100, unit="ns")
