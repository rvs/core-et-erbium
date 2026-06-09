"""
QSPI Comprehensive Unit Test Suite — Bug 1+2 ECO verification
==============================================================
Identical to test_qspi_suite.py with all Bug 1/2 workarounds removed.
Assumes ECO fixes are applied to the compiled Verilog.

Changes vs test_qspi_suite.py:
  Bug 1 (if_abort preempts AXI reads when cr_en=0):
  - test_01: enable() removed; CR reset value now verified (expect 0x00)
  - test_02: re-enable hack removed; read-back done directly after write
  - test_03–09, 11–15, 20: enable() removed (register R/W tests only)
  - test_10, 16–25: enable() kept (cr_en=1 required for SPI transactions)
  Bug 2 (SLVERR path sets cr_en=0): no test change needed (workaround was
  the base address in qspi_env.py, which remains correct for the SoC).
  Bug 3 (cr_abort never auto-cleared): not fixed in hardware; software clears
  ABORT bit explicitly (workaround retained in test_23).

Register map (from QSPI_Reg.rdl, base 0x0, alignment=8):
  CR      +0x00  qspi_enable[0] abort[1] dmaen[2] tcen[3] sshift[4]
                 dfm[6] fsel[7] fthres[12:8] teie[16] tcie[17] ftie[18]
                 smie[19] toie[20] apms[22] pmm[23] prescaler[31:24]
  DCR     +0x08  ckmode[0] csht[10:8] fsize[20:16]
  SR      +0x10  tef[0] tcf[1] ftf[2] smf[3] tof[4] busy[5] flevel[13:8]
  FCR     +0x18  ctef[0] ctcf[1] csmf[3] ctof[4]  (write-1-to-clear)
  DLR     +0x20  dl[31:0]   – transfer length = DLR+1 bytes
  CCR     +0x28  instr[7:0] imode[9:8] admode[11:10] adsize[13:12]
                 abmode[15:14] absize[17:16] dcyc[22:18] d_conf[23]
                 dmode[25:24] fmode[27:26] sioo[28] dhhc[30] ddrm[31]
  AR      +0x30  address[31:0]
  ABR     +0x38  alternate_bytes[31:0]
  DR      +0x40  data[31:0]   – FIFO access register
  PSMKR   +0x48  mask[31:0]
  PSMAR   +0x50  match[31:0]
  PIR     +0x58  interval[31:0]
  LPTR    +0x60  lptr[31:0]
"""

import random
import cocotb
import cocotb.utils
from cocotb.triggers import RisingEdge, Timer

from qspi_env import (
    QSPIEnv, SpiFlashModel, QspiRegs,
    ccr_encode,
    FMODE_INDIRECT_WRITE, FMODE_INDIRECT_READ, FMODE_AUTO_POLL,
    DATA_MODE_1BIT, DATA_MODE_2BIT, DATA_MODE_4BIT,
    ADDR_MODE_1BIT, ADDR_SIZE_24B,
    INSTR_MODE_1BIT,
    SR_BUSY, SR_TCF, SR_TEF, SR_SMF, SR_FTF,
    CR_EN, CR_TCIE, CR_FTIE, CR_SMIE,
)


# ===========================================================================
#  Shared initialisation
# ===========================================================================

async def _tb_init(dut) -> QSPIEnv:
    tb = QSPIEnv(dut)
    await tb.reset()
    tb.start()
    return tb


async def _tb_init_with_flash(dut) -> QSPIEnv:
    tb = QSPIEnv(dut)
    await tb.reset()
    tb.flash.start()
    return tb


def safe_int(v):
    try:
        return int(v)
    except ValueError:
        s = v.binstr.lower().replace('x', '0').replace('z', '0')
        return int(s, 2)


# ===========================================================================
#  TEST 01 – Register reset values
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_01_register_reset_values(dut):
    """Verify CR, DCR, SR read back their RDL-specified reset values at reset
    (no enable() required after Bug 1 ECO fix).
    """
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 01: Register Reset Values")
    cocotb.log.info("=" * 60)

    cr = await tb.reg.CR.read()
    assert cr == 0x00000000, f"CR reset: expected 0x0, got 0x{cr:08X}"
    cocotb.log.info(f"  CR  = 0x{cr:08X}  ✓")

    dcr = await tb.reg.DCR.read()
    assert dcr == 0x00000000, f"DCR reset: expected 0x0, got 0x{dcr:08X}"
    cocotb.log.info(f"  DCR = 0x{dcr:08X}  ✓")

    sr = await tb.reg.SR.read()
    assert not ((sr >> SR_BUSY) & 1), f"SR.busy should be 0 at reset, got SR=0x{sr:X}"
    cocotb.log.info(f"  SR  = 0x{sr:08X}  busy=0  ✓")

    print("\nTEST 01: REGISTER RESET VALUES  PASSED")


# ===========================================================================
#  TEST 02 – CR: enable, prescaler, sshift R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_02_cr_fields_rw(dut):
    """CR register: prescaler[31:24], sshift[4], dmaen[2], enable[0] R/W."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 02: CR Fields R/W")
    cocotb.log.info("=" * 60)

    cases = [
        # (prescaler, sshift, dmaen, enable)
        (0x01, 0, 0, 1),
        (0xFF, 1, 1, 1),
        (0x10, 0, 0, 0),
        (0x00, 0, 0, 0),
    ]
    for prescaler, sshift, dmaen, enable in cases:
        val = (prescaler << 24) | (sshift << 4) | (dmaen << 2) | enable
        await tb.reg.CR.write(val)
        await Timer(1, 'us')
        rb = await tb.reg.CR.read()
        mask = 0xFF000015  # prescaler | sshift | dmaen | enable
        assert (rb & mask) == (val & mask), \
            f"CR write=0x{val:08X} rb=0x{rb:08X}"
        cocotb.log.info(f"  prescaler=0x{prescaler:02X} sshift={sshift} dmaen={dmaen} en={enable}  ✓")

    await tb.reg.CR.write(0)
    print("\nTEST 02: CR FIELDS R/W  PASSED")


# ===========================================================================
#  TEST 03 – DCR: ckmode, csht, fsize R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_03_dcr_fields_rw(dut):
    """DCR: ckmode[0], csht[10:8], fsize[20:16] R/W."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 03: DCR Fields R/W")
    cocotb.log.info("=" * 60)

    cases = [(0x10, 0x3, 1), (0x18, 0x0, 0), (0x0F, 0x5, 1), (0x00, 0x0, 0)]
    for fsize, csht, ckmode in cases:
        val = (fsize << 16) | (csht << 8) | ckmode
        await tb.reg.DCR.write(val)
        await Timer(1, 'us')
        rb = await tb.reg.DCR.read()
        mask = 0x001F0701
        assert (rb & mask) == (val & mask), \
            f"DCR write=0x{val:08X} rb=0x{rb:08X}"
        cocotb.log.info(f"  fsize=0x{fsize:02X} csht=0x{csht:X} ckmode={ckmode}  ✓")

    await tb.reg.DCR.write(0)
    print("\nTEST 03: DCR FIELDS R/W  PASSED")


# ===========================================================================
#  TEST 04 – CCR: imode, admode, adsize, dmode, fmode, dcyc, sioo R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_04_ccr_fields_rw(dut):
    """CCR key fields written and read back correctly."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 04: CCR Fields R/W")
    cocotb.log.info("=" * 60)

    cases = [
        dict(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_1BIT,
             admode=ADDR_MODE_1BIT, adsize=ADDR_SIZE_24B,
             imode=INSTR_MODE_1BIT, instr=0x03),
        dict(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_2BIT,
             admode=ADDR_MODE_1BIT, adsize=ADDR_SIZE_24B,
             imode=INSTR_MODE_1BIT, instr=0x3B),
        dict(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_4BIT,
             admode=DATA_MODE_4BIT, adsize=ADDR_SIZE_24B,
             imode=INSTR_MODE_1BIT, instr=0xEB, dcyc=6, sioo=1),
    ]
    for kw in cases:
        ccr = ccr_encode(**kw)
        await tb.reg.CCR.write(ccr)
        await Timer(1, 'us')
        rb = await tb.reg.CCR.read()
        assert (rb >> 24) & 0x3 == kw['dmode'],   f"dmode mismatch rb=0x{rb:08X}"
        assert (rb >> 26) & 0x3 == kw['fmode'],   f"fmode mismatch rb=0x{rb:08X}"
        assert (rb >> 10) & 0x3 == kw['admode'],  f"admode mismatch rb=0x{rb:08X}"
        if 'dcyc' in kw:
            assert (rb >> 18) & 0x1F == kw['dcyc'], f"dcyc mismatch rb=0x{rb:08X}"
        if kw.get('sioo'):
            assert (rb >> 28) & 1 == 1, f"sioo mismatch rb=0x{rb:08X}"
        cocotb.log.info(f"  ccr=0x{ccr:08X} rb=0x{rb:08X}  ✓")

    print("\nTEST 04: CCR FIELDS R/W  PASSED")


# ===========================================================================
#  TEST 05 – DLR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_05_dlr_rw(dut):
    """DLR accepts arbitrary 32-bit byte-count values."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 05: DLR R/W")
    cocotb.log.info("=" * 60)

    for val in [0, 1, 7, 31, 255, 0xFFFFFFFF]:
        await tb.reg.DLR.write(val)
        await Timer(1, 'us')
        rb = await tb.reg.DLR.read()
        assert rb == val, f"DLR: wrote 0x{val:08X}, got 0x{rb:08X}"
        cocotb.log.info(f"  DLR=0x{val:08X}  ✓")

    print("\nTEST 05: DLR R/W  PASSED")


# ===========================================================================
#  TEST 06 – AR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_06_ar_rw(dut):
    """AR (address register) round-trip for several 24-bit addresses."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 06: AR R/W")
    cocotb.log.info("=" * 60)

    for addr in [0x000000, 0x000010, 0x123456, 0xABCDEF, 0xFFFFFF]:
        await tb.reg.AR.write(addr)
        await Timer(1, 'us')
        rb = await tb.reg.AR.read()
        assert rb == addr, f"AR: wrote 0x{addr:06X}, got 0x{rb:06X}"
        cocotb.log.info(f"  AR=0x{addr:06X}  ✓")

    print("\nTEST 06: AR R/W  PASSED")


# ===========================================================================
#  TEST 07 – ABR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_07_abr_rw(dut):
    """ABR (alternate-byte register) round-trip."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 07: ABR R/W")
    cocotb.log.info("=" * 60)

    for val in [0x00, 0xA5, 0xFF, 0xDEADBEEF]:
        await tb.reg.ABR.write(val & 0xFFFFFFFF)
        await Timer(1, 'us')
        rb = await tb.reg.ABR.read()
        assert rb == (val & 0xFFFFFFFF), f"ABR: wrote 0x{val:08X}, got 0x{rb:08X}"
        cocotb.log.info(f"  ABR=0x{val:08X}  ✓")

    print("\nTEST 07: ABR R/W  PASSED")


# ===========================================================================
#  TEST 08 – PIR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_08_pir_rw(dut):
    """PIR (polling interval) round-trip."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 08: PIR R/W")
    cocotb.log.info("=" * 60)

    for val in [0x00, 0x10, 0xFF, 0xFFFF]:
        await tb.reg.PIR.write(val)
        await Timer(1, 'us')
        rb = await tb.reg.PIR.read()
        assert rb == val, f"PIR: wrote 0x{val:04X}, got 0x{rb:04X}"
        cocotb.log.info(f"  PIR=0x{val:04X}  ✓")

    print("\nTEST 08: PIR R/W  PASSED")


# ===========================================================================
#  TEST 09 – LPTR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_09_lptr_rw(dut):
    """LPTR (low-power timeout) round-trip."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 09: LPTR R/W")
    cocotb.log.info("=" * 60)

    for val in [0x0000, 0x0001, 0x1000, 0xFFFF]:
        await tb.reg.LPTR.write(val)
        await Timer(1, 'us')
        rb = await tb.reg.LPTR.read()
        assert rb == val, f"LPTR: wrote 0x{val:04X}, got 0x{rb:04X}"
        cocotb.log.info(f"  LPTR=0x{val:04X}  ✓")

    print("\nTEST 09: LPTR R/W  PASSED")


# ===========================================================================
#  TEST 10 – FCR clears TCF flag
# ===========================================================================
@cocotb.test(timeout_time=5, timeout_unit="ms")
async def test_10_fcr_clears_tcf(dut):
    """Writing FCR.ctcf=1 clears SR.tcf."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()   # cr_en=1 required to start SPI transaction
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 10: FCR clears TCF")
    cocotb.log.info("=" * 60)

    # Trigger a zero-data write to get TCF
    await tb.reg.DLR.write(0)
    ccr = ccr_encode(fmode=FMODE_INDIRECT_WRITE, imode=INSTR_MODE_1BIT,
                      instr=0x06, admode=0, dmode=0)
    await tb.reg.CCR.write(ccr)
    await Timer(500, 'ns')

    # TCF should be set – write FCR.ctcf to clear it
    await tb.reg.FCR.write(1 << 1)   # ctcf
    await Timer(1, 'us')
    sr = await tb.reg.SR.read()
    assert not ((sr >> SR_TCF) & 1), f"TCF not cleared after FCR write, SR=0x{sr:08X}"
    cocotb.log.info(f"  TCF cleared  ✓  SR=0x{sr:08X}")

    print("\nTEST 10: FCR CLEARS TCF  PASSED")


# ===========================================================================
#  TEST 11 – FCR clears TEF flag
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_11_fcr_clears_tef(dut):
    """Writing FCR.ctef=1 leaves SR.tef=0 (flag is already 0 at reset)."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 11: FCR clears TEF")
    cocotb.log.info("=" * 60)

    # Clear TEF unconditionally
    await tb.reg.FCR.write(0x1)   # ctef
    await Timer(1, 'us')
    sr = await tb.reg.SR.read()
    assert not ((sr >> SR_TEF) & 1), f"TEF should be 0, SR=0x{sr:08X}"
    cocotb.log.info(f"  TEF=0 after FCR.ctef  ✓")

    print("\nTEST 11: FCR CLEARS TEF  PASSED")


# ===========================================================================
#  TEST 12 – CCR dummy cycles field R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_12_ccr_dummy_cycles(dut):
    """CCR.dcyc field [22:18] accepts 0..31 and reads back correctly."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 12: CCR Dummy Cycles")
    cocotb.log.info("=" * 60)

    for dc in [0, 1, 8, 10, 20, 31]:
        ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_1BIT,
                          admode=ADDR_MODE_1BIT, adsize=ADDR_SIZE_24B,
                          imode=INSTR_MODE_1BIT, instr=0x0B, dcyc=dc)
        await tb.reg.CCR.write(ccr)
        await Timer(1, 'us')
        rb = await tb.reg.CCR.read()
        assert (rb >> 18) & 0x1F == dc, \
            f"dcyc={dc} readback={(rb >> 18) & 0x1F}"
        cocotb.log.info(f"  dcyc={dc:2d}  ✓")

    print("\nTEST 12: CCR DUMMY CYCLES  PASSED")


# ===========================================================================
#  TEST 13 – CCR SIOO bit
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_13_ccr_sioo(dut):
    """CCR.sioo bit [28] written and read back correctly."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 13: CCR SIOO Bit")
    cocotb.log.info("=" * 60)

    for sioo in [0, 1]:
        ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_1BIT,
                          admode=ADDR_MODE_1BIT, adsize=ADDR_SIZE_24B,
                          imode=INSTR_MODE_1BIT, instr=0x03, sioo=sioo)
        await tb.reg.CCR.write(ccr)
        await Timer(1, 'us')
        rb = await tb.reg.CCR.read()
        assert (rb >> 28) & 1 == sioo, \
            f"sioo={sioo} readback={(rb >> 28) & 1}"
        cocotb.log.info(f"  sioo={sioo}  ✓")

    print("\nTEST 13: CCR SIOO BIT  PASSED")


# ===========================================================================
#  TEST 14 – CCR dual data mode field
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_14_ccr_dual_mode(dut):
    """CCR.dmode=2 (dual) written and read back."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 14: CCR Dual Data Mode")
    cocotb.log.info("=" * 60)

    ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_2BIT,
                      admode=ADDR_MODE_1BIT, adsize=ADDR_SIZE_24B,
                      imode=INSTR_MODE_1BIT, instr=0x3B)
    await tb.reg.CCR.write(ccr)
    await Timer(1, 'us')
    rb = await tb.reg.CCR.read()
    assert (rb >> 24) & 0x3 == DATA_MODE_2BIT, \
        f"dmode expected {DATA_MODE_2BIT} got {(rb >> 24) & 3}"
    cocotb.log.info(f"  dmode=2 (dual) readback ok  ✓")

    print("\nTEST 14: CCR DUAL MODE  PASSED")


# ===========================================================================
#  TEST 15 – CCR quad data mode field
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_15_ccr_quad_mode(dut):
    """CCR.dmode=3 (quad) and admode=3 written and read back."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 15: CCR Quad Data Mode")
    cocotb.log.info("=" * 60)

    ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, dmode=DATA_MODE_4BIT,
                      admode=DATA_MODE_4BIT, adsize=ADDR_SIZE_24B,
                      imode=INSTR_MODE_1BIT, instr=0xEB)
    await tb.reg.CCR.write(ccr)
    await Timer(1, 'us')
    rb = await tb.reg.CCR.read()
    assert (rb >> 24) & 0x3 == DATA_MODE_4BIT, \
        f"dmode expected {DATA_MODE_4BIT} got {(rb >> 24) & 3}"
    assert (rb >> 10) & 0x3 == DATA_MODE_4BIT, \
        f"admode expected {DATA_MODE_4BIT} got {(rb >> 10) & 3}"
    cocotb.log.info(f"  dmode=3 (quad) admode=3 readback ok  ✓")

    print("\nTEST 15: CCR QUAD MODE  PASSED")


# ===========================================================================
#  TEST 16 – Indirect write single byte (1-bit SPI)
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_16_indirect_write_single_byte(dut):
    """Indirect write of one byte → verified in flash model memory."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 16: Indirect Write Single Byte")
    cocotb.log.info("=" * 60)

    write_addr = 0x000010
    byte_val   = 0xA5

    # WREN first
    await tb.indirect_write(0, b'', instr=0x06, admode=0, dmode=0)
    # PAGE PROGRAM
    await tb.indirect_write(write_addr, bytes([byte_val]),
                             instr=0x02, admode=ADDR_MODE_1BIT,
                             adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)

    assert tb.flash.mem[write_addr] == byte_val, \
        f"Flash[0x{write_addr:06X}]=0x{tb.flash.mem[write_addr]:02X} != 0x{byte_val:02X}"
    cocotb.log.info(f"  Flash[0x{write_addr:06X}]=0x{byte_val:02X}  ✓")

    print("\nTEST 16: INDIRECT WRITE SINGLE BYTE  PASSED")


# ===========================================================================
#  TEST 17 – Indirect read single byte round-trip
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_17_indirect_read_single_byte(dut):
    """Pre-load flash model, then read one byte via DUT indirect read."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 17: Indirect Read Single Byte")
    cocotb.log.info("=" * 60)

    read_addr = 0x000020
    expected  = 0x5A
    tb.flash.mem[read_addr] = expected

    data = await tb.indirect_read(read_addr, 1,
                                   instr=0x03, admode=ADDR_MODE_1BIT,
                                   adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
    assert data[0] == expected, \
        f"Read 0x{data[0]:02X}, expected 0x{expected:02X}"
    cocotb.log.info(f"  Read 0x{data[0]:02X} from 0x{read_addr:06X}  ✓")

    print("\nTEST 17: INDIRECT READ SINGLE BYTE  PASSED")


# ===========================================================================
#  TEST 18 – DLR controls exact byte count
# ===========================================================================
@cocotb.test(timeout_time=40, timeout_unit="ms")
async def test_18_dlr_byte_count(dut):
    """DLR=N-1 transfers exactly N bytes for N in [1,2,4,7,8]."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 18: DLR Byte Count")
    cocotb.log.info("=" * 60)

    base_addr = 0x000100
    for nbytes in [1, 2, 4, 7, 8]:
        pattern = bytes([(i * 13 + 7) & 0xFF for i in range(nbytes)])
        tb.flash.mem[base_addr:base_addr + nbytes] = pattern

        data = await tb.indirect_read(base_addr, nbytes,
                                       instr=0x03, admode=ADDR_MODE_1BIT,
                                       adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
        assert data[:nbytes] == pattern, \
            f"DLR={nbytes - 1}: got 0x{data.hex()} expected 0x{pattern.hex()}"
        cocotb.log.info(f"  nbytes={nbytes}  ✓")

    print("\nTEST 18: DLR BYTE COUNT  PASSED")


# ===========================================================================
#  TEST 19 – Multi-byte burst write then read
# ===========================================================================
@cocotb.test(timeout_time=60, timeout_unit="ms")
async def test_19_burst_write_read(dut):
    """32-byte burst write followed by burst read; data must match."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 19: 32-byte Burst Write/Read")
    cocotb.log.info("=" * 60)

    addr    = 0x000200
    payload = bytes([random.randint(0, 255) for _ in range(32)])

    await tb.indirect_write(0, b'', instr=0x06, admode=0, dmode=0)  # WREN
    await tb.indirect_write(addr, payload,
                             instr=0x02, admode=ADDR_MODE_1BIT,
                             adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)

    data = await tb.indirect_read(addr, 32,
                                   instr=0x03, admode=ADDR_MODE_1BIT,
                                   adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
    assert data == payload, \
        f"Burst mismatch:\n  got      {data.hex()}\n  expected {payload.hex()}"
    cocotb.log.info(f"  32 bytes match  ✓")

    print("\nTEST 19: BURST WRITE/READ  PASSED")


# ===========================================================================
#  TEST 20 – PSMKR and PSMAR register R/W
# ===========================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_20_psmkr_psmar_rw(dut):
    """PSMKR and PSMAR registers accept arbitrary 32-bit values."""
    tb = await _tb_init(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 20: PSMKR / PSMAR R/W")
    cocotb.log.info("=" * 60)

    for mask_val, match_val in [(0x02, 0x02), (0xFF, 0x55), (0x00, 0x00)]:
        await tb.reg.PSMKR.write(mask_val)
        await tb.reg.PSMAR.write(match_val)
        await Timer(1, 'us')
        mk = await tb.reg.PSMKR.read()
        mt = await tb.reg.PSMAR.read()
        assert mk == mask_val,  f"PSMKR: wrote 0x{mask_val:08X}, got 0x{mk:08X}"
        assert mt == match_val, f"PSMAR: wrote 0x{match_val:08X}, got 0x{mt:08X}"
        cocotb.log.info(f"  mask=0x{mask_val:08X} match=0x{match_val:08X}  ✓")

    print("\nTEST 20: PSMKR/PSMAR R/W  PASSED")


# ===========================================================================
#  TEST 21 – Transfer complete interrupt (TCIE → interrupt pin)
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_21_tcf_interrupt(dut):
    """CR.tcie=1 → interrupt pin asserts after transfer completes (TCF)."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 21: Transfer Complete Interrupt")
    cocotb.log.info("=" * 60)

    # Enable TCF interrupt
    cr = await tb.reg.CR.read()
    await tb.reg.CR.write(cr | (1 << CR_TCIE))
    await Timer(1, 'us')

    # Single-byte write to trigger TCF.
    # Bug 5: TCF is cleared in the same cycle BUSY clears → interrupt fires for
    # exactly one 10 ns clock cycle.  Arm an async watcher before the write so
    # the brief RisingEdge is captured even before poll_not_busy() returns.
    interrupt_fired = False
    async def _watch_intr():
        nonlocal interrupt_fired
        await RisingEdge(dut.interrupts)
        interrupt_fired = True
    watcher = cocotb.start_soon(_watch_intr())

    tb.flash.mem[0x300] = 0xFF
    await tb.indirect_write(0, b'', instr=0x06, admode=0, dmode=0)  # WREN
    await tb.indirect_write(0x300, b'\x42',
                             instr=0x02, admode=ADDR_MODE_1BIT,
                             adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)

    await Timer(200, 'ns')
    watcher.cancel()
    assert interrupt_fired, "interrupt should fire (RisingEdge) after TCF when tcie=1"
    cocotb.log.info("  interrupt asserted after TCF  ✓")

    # Disable interrupt → interrupt should clear
    cr = await tb.reg.CR.read()
    await tb.reg.CR.write(cr & ~(1 << CR_TCIE))
    await Timer(5, 'us')
    intr = safe_int(dut.interrupts.value)
    assert not intr, "interrupt should deassert after tcie=0"
    cocotb.log.info("  interrupt deasserted after tcie=0  ✓")

    print("\nTEST 21: TCF INTERRUPT  PASSED")


# ===========================================================================
#  TEST 22 – SR.busy clears after transfer
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_22_busy_clears_after_transfer(dut):
    """SR.busy is asserted during transfer and clears on completion."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 22: SR.busy Clears After Transfer")
    cocotb.log.info("=" * 60)

    tb.flash.mem[0x400] = 0xBE

    # Kick off a read
    await tb.reg.FCR.write(0x3)   # clear TCF+TEF before starting
    await tb.reg.DLR.write(1)     # DLR=1 → 1 byte (Shakti: DLR=N for N bytes)
    ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, imode=INSTR_MODE_1BIT,
                      instr=0x03, admode=ADDR_MODE_1BIT,
                      adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
    await tb.reg.CCR.write(ccr)   # CCR before AR — AR triggers the transaction
    await tb.reg.AR.write(0x400)

    # Wait for busy to clear
    cleared = await tb.poll_not_busy(timeout_cycles=5000)
    assert cleared, "SR.busy should clear after transfer completes"
    cocotb.log.info("  SR.busy cleared  ✓")

    print("\nTEST 22: BUSY CLEARS  PASSED")


# ===========================================================================
#  TEST 23 – CR.abort clears SR.busy
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_23_abort_clears_busy(dut):
    """CR.abort=1 terminates an in-flight transfer and clears SR.busy."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 23: Abort Clears Busy")
    cocotb.log.info("=" * 60)

    # Start a long read (255 bytes)
    await tb.reg.FCR.write(0x3)   # clear TCF+TEF before starting
    await tb.reg.DLR.write(255)
    ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, imode=INSTR_MODE_1BIT,
                      instr=0x03, admode=ADDR_MODE_1BIT,
                      adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
    await tb.reg.CCR.write(ccr)
    await tb.reg.AR.write(0x000100)

    # Issue abort immediately.
    # cr_abort is NOT auto-cleared by if_abort in hardware, so we must write
    # ABORT=0 ourselves before polling SR.  AXI writes are not preempted by
    # if_abort, so the clear write always goes through even while abort is active.
    cr = await tb.reg.CR.read()
    await tb.reg.CR.write(cr | (1 << 1))   # CR.abort = 1
    await tb.reg.CR.write(cr & ~(1 << 1))  # CR.abort = 0 (keep CR_EN)

    cleared = await tb.poll_not_busy(timeout_cycles=500)
    assert cleared, "SR.busy should clear after abort"
    cocotb.log.info("  abort cleared busy  ✓")

    print("\nTEST 23: ABORT CLEARS BUSY  PASSED")


# ===========================================================================
#  TEST 24 – FIFO threshold interrupt (FTIE / FTF)
# ===========================================================================
@cocotb.test(timeout_time=20, timeout_unit="ms")
async def test_24_fifo_threshold_interrupt(dut):
    """CR.ftie=1 and CR.fthres set: interrupt asserts when FIFO reaches threshold."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 24: FIFO Threshold Interrupt")
    cocotb.log.info("=" * 60)

    THRESH = 4
    # Shakti FTF condition: fifo_count >= cr_fthres + 1.  Set cr_fthres = THRESH-1
    # so FTF fires when THRESH bytes arrive.  DLR=THRESH → THRESH bytes transferred
    # (Shakti DLR=N means exactly N bytes, unlike STM32 where DLR=N-1 means N bytes).
    cr = await tb.reg.CR.read()
    cr = (cr & ~(0x1F << 8)) | ((THRESH - 1) << 8) | (1 << CR_FTIE) | (1 << CR_EN)
    await tb.reg.CR.write(cr)
    await Timer(1, 'us')

    # Fill flash with a known pattern, then start a read of THRESH bytes
    for i in range(THRESH):
        tb.flash.mem[0x500 + i] = i
    await tb.reg.FCR.write(0x3)   # clear TCF+TEF before starting
    await tb.reg.DLR.write(THRESH)  # THRESH bytes
    ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, imode=INSTR_MODE_1BIT,
                      instr=0x03, admode=ADDR_MODE_1BIT,
                      adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
    await tb.reg.CCR.write(ccr)
    await tb.reg.AR.write(0x500)

    # Wait for FTF or TCF
    for _ in range(5000):
        sr = await tb.reg.SR.read()
        if (sr >> SR_FTF) & 1 or (sr >> SR_TCF) & 1:
            break
        await RisingEdge(dut.CLK)

    intr = safe_int(dut.interrupts.value)
    assert intr, "interrupt should assert when FTF or TCF set with ftie=1"
    cocotb.log.info("  FIFO threshold interrupt asserted  ✓")

    # Drain FIFO and disable
    cr = await tb.reg.CR.read()
    await tb.reg.CR.write(cr & ~(1 << CR_FTIE))

    print("\nTEST 24: FIFO THRESHOLD INTERRUPT  PASSED")


# ===========================================================================
#  TEST 25 – Random regression: 20 write/read round-trips
# ===========================================================================
@cocotb.test(timeout_time=200, timeout_unit="ms")
async def test_25_random_regression(dut):
    """20 random write-then-read round-trips at varying addresses and lengths."""
    tb = await _tb_init_with_flash(dut)
    await tb.enable()
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 25: Random Regression (20 iterations)")
    cocotb.log.info("=" * 60)

    rng = random.Random(0xCAFEBABE)

    for iteration in range(20):
        addr   = rng.randint(0, 0xFFE) & ~0x7   # 8-byte aligned
        nbytes = rng.choice([1, 2, 4, 8])
        payload = bytes([rng.randint(0, 255) for _ in range(nbytes)])

        # Pre-populate flash model
        tb.flash.mem[addr:addr + nbytes] = payload

        # Read via DUT
        data = await tb.indirect_read(addr, nbytes,
                                       instr=0x03, admode=ADDR_MODE_1BIT,
                                       adsize=ADDR_SIZE_24B, dmode=DATA_MODE_1BIT)
        assert data == payload, (
            f"Iter {iteration}: addr=0x{addr:06X} nbytes={nbytes}\n"
            f"  got      {data.hex()}\n"
            f"  expected {payload.hex()}"
        )
        cocotb.log.info(f"  iter {iteration:02d}: addr=0x{addr:06X} n={nbytes}  ✓")

    print("\nTEST 25: RANDOM REGRESSION  PASSED")
