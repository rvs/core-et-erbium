"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

QSPI unit-test environment.

Exports
-------
QSPIEnv        – RAL-based env (used by ai/test_qspi_suite.py)
Env            – higher-level env with indirect_read/write helpers
                 (interface expected by test_qspi.py)
QspiRegs       – register byte-offset constants
SpiFlashModel  – cocotb coroutine SPI flash behavioural model
ccr_encode     – build a CCR register value from named fields
Constants      – FMODE_*, DATA_MODE_*, ADDR_MODE_*, ADDR_SIZE_*,
                 INSTR_MODE_*, SR_*
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, First
from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotbext.dyulib.reset import reset_n
from typing import TYPE_CHECKING, Any

from ral.QSPI_Reg.reg_model.QSPI_Reg import QSPI_Reg_cls
from ral.QSPI_Reg.lib import AsyncCallbackSet

if TYPE_CHECKING:
    from copra_stubs import Tb as DUT
else:
    DUT = Any


# ===========================================================================
#  Register byte-offset constants (match RAL model addresses)
# ===========================================================================
class QspiRegs:
    CR    = 0x00
    DCR   = 0x08
    SR    = 0x10
    FCR   = 0x18
    DLR   = 0x20
    CCR   = 0x28
    AR    = 0x30
    ABR   = 0x38
    DR    = 0x40
    PSMKR = 0x48
    PSMAR = 0x50
    PIR   = 0x58
    LPTR  = 0x60


# ===========================================================================
#  Field encoding constants
# ===========================================================================
FMODE_INDIRECT_WRITE = 0
FMODE_INDIRECT_READ  = 1
FMODE_AUTO_POLL      = 2

DATA_MODE_NONE = 0
DATA_MODE_1BIT = 1
DATA_MODE_2BIT = 2
DATA_MODE_4BIT = 3

ADDR_MODE_NONE = 0
ADDR_MODE_1BIT = 1
ADDR_MODE_2BIT = 2
ADDR_MODE_4BIT = 3

ADDR_SIZE_8B  = 0
ADDR_SIZE_16B = 1
ADDR_SIZE_24B = 2
ADDR_SIZE_32B = 3

INSTR_MODE_NONE = 0
INSTR_MODE_1BIT = 1
INSTR_MODE_2BIT = 2
INSTR_MODE_4BIT = 3

# SR bit positions
SR_TEF  = 0   # Transfer error flag
SR_TCF  = 1   # Transfer complete flag
SR_FTF  = 2   # FIFO threshold flag
SR_SMF  = 3   # Status match flag
SR_TOF  = 4   # Timeout flag
SR_BUSY = 5   # Busy flag

# CR bit positions (useful for direct bitmask operations)
CR_EN     = 0
CR_ABORT  = 1
CR_DMAEN  = 2
CR_TCEN   = 3
CR_SSHIFT = 4
CR_TEIE   = 16
CR_TCIE   = 17
CR_FTIE   = 18
CR_SMIE   = 19
CR_TOIE   = 20
CR_APMS   = 22


# ===========================================================================
#  CCR encode helper
#
#  CCR field layout (from RAL):
#    [7:0]  instr   – instruction opcode
#    [9:8]  imode   – instruction mode (0=none,1=1b,2=2b,3=4b)
#    [11:10] admode – address mode
#    [13:12] adsize – address size (0=8b,1=16b,2=24b,3=32b)
#    [15:14] abmode – alternate-byte mode
#    [17:16] absize – alternate-byte size
#    [22:18] dcyc   – dummy cycles (0..31)
#    [23]    d_conf – dummy confirmation
#    [25:24] dmode  – data mode
#    [27:26] fmode  – functional mode (0=IndW,1=IndR,2=Poll,3=MM)
#    [28]    sioo   – send instruction only once
#    [30]    dhhc   – DDR hold quarter cycle
#    [31]    ddrm   – DDR mode enable
# ===========================================================================
def ccr_encode(*, fmode=0, dmode=0, dcyc=0, admode=0, adsize=0,
               abmode=0, absize=0, imode=0, instr=0,
               sioo=0, dhhc=0, ddrm=0, d_conf=0):
    """Build a CCR value from named fields."""
    return (
        (ddrm   << 31) |
        (dhhc   << 30) |
        (sioo   << 28) |
        (fmode  << 26) |
        (dmode  << 24) |
        (d_conf << 23) |
        (dcyc   << 18) |
        (absize << 16) |
        (abmode << 14) |
        (adsize << 12) |
        (admode << 10) |
        (imode  <<  8) |
        (instr  <<  0)
    )


# ===========================================================================
#  SPI Flash behavioural model
#
#  Expects the tb_qspi.v wrapper to expose:
#    dut.qspi_sck    – SPI clock (output from DUT)
#    dut.qspi_cs_n   – Chip select active-low (output from DUT)
#    dut.qspi_dq_o   – 4-bit data output from DUT (MOSI in 1-bit mode = [0])
#    dut.qspi_dq_oe  – 4-bit output-enable from DUT
#    dut.qspi_dq_i   – 4-bit data input to DUT  (MISO in 1-bit mode = [1])
#
#  Supported SPI commands (1-bit SPI mode only):
#    0x06  WREN           – set write-enable latch
#    0x04  WRDI           – clear write-enable latch
#    0x05  RDSR           – read status register (returns 0x00 = ready)
#    0x03  READ           – sequential read at 24-bit address
#    0x02  PP (page prog) – sequential write at 24-bit address (requires WREN)
# ===========================================================================
class SpiFlashModel:
    def __init__(self, dut, size: int = 256 * 1024):
        self.dut   = dut
        self.mem   = bytearray(b'\xFF' * size)
        self._wren = False
        self._task = None

    def start(self):
        self._task = cocotb.start_soon(self._run())

    # ── helpers ──────────────────────────────────────────────────────────

    def _cs_high(self) -> bool:
        try:
            return int(self.dut.qspi_cs_n.value) == 1
        except Exception:
            return False

    async def _recv_bit(self) -> int:
        # Sample MOSI on SCK falling edge: BSV updates rg_output (MOSI) in the
        # same delta that SCK falls, so rising-edge sampling reads one bit late.
        # Abort detection: if CS_N rises first the flash model must stop.
        trigger = await First(FallingEdge(self.dut.qspi_sck), RisingEdge(self.dut.qspi_cs_n))
        if self._cs_high():
            raise RuntimeError("CS_N deasserted mid-transaction")
        dq = int(self.dut.qspi_dq_o.value)
        bit = (dq >> 0) & 1
        cocotb.log.debug(f"SpiFlash: SCK↓ dq_o=0x{dq:X} mosi={bit}")
        return bit

    async def _send_bit(self, bit: int):
        # Mirror _recv_bit: if CS_N rises before the next SCK fall, the DUT has
        # deasserted CS after its last data bit — abort so _run can reset state.
        trigger = await First(FallingEdge(self.dut.qspi_sck), RisingEdge(self.dut.qspi_cs_n))
        if self._cs_high():
            raise RuntimeError("CS_N deasserted mid-send")
        # Drive MISO on io[1]; keep io[3:2,0] pulled high
        self.dut.qspi_dq_i.value = ((bit & 1) << 1) | 0xD

    async def _recv_byte(self) -> int:
        val = 0
        for _ in range(8):
            val = (val << 1) | await self._recv_bit()
        return val

    async def _send_byte(self, val: int):
        for i in range(7, -1, -1):
            await self._send_bit((val >> i) & 1)

    async def _recv_addr24(self) -> int:
        b2 = await self._recv_byte()
        b1 = await self._recv_byte()
        b0 = await self._recv_byte()
        return (b2 << 16) | (b1 << 8) | b0

    # ── transaction dispatcher ────────────────────────────────────────────

    async def _handle_transaction(self):
        cmd = await self._recv_byte()

        if cmd == 0x06:   # WREN
            self._wren = True
            cocotb.log.info("SpiFlash: WREN")

        elif cmd == 0x04:  # WRDI
            self._wren = False
            cocotb.log.info("SpiFlash: WRDI")

        elif cmd == 0x05:  # RDSR – return ready (WIP=0)
            while not self._cs_high():
                await self._send_byte(0x00)

        elif cmd == 0x03:  # READ
            addr = await self._recv_addr24()
            cocotb.log.info(f"SpiFlash: READ 0x{addr:06X}")
            while not self._cs_high():
                await self._send_byte(self.mem[addr % len(self.mem)])
                addr += 1

        elif cmd == 0x02:  # PAGE PROGRAM
            addr = await self._recv_addr24()
            cocotb.log.info(f"SpiFlash: PP 0x{addr:06X} wren={self._wren}")
            if self._wren:
                while not self._cs_high():
                    b = await self._recv_byte()
                    self.mem[addr % len(self.mem)] = b
                    addr += 1
                self._wren = False
        else:
            cocotb.log.warning(f"SpiFlash: unknown cmd=0x{cmd:02X}")

    async def _run(self):
        self.dut.qspi_dq_i.value = 0xF   # idle: all lines high
        while True:
            await FallingEdge(self.dut.qspi_cs_n)
            cocotb.log.info(f"SpiFlash: CS_N asserted (cs_n fell)")
            try:
                await self._handle_transaction()
            except Exception as exc:
                cocotb.log.warning(f"SpiFlash: exception: {exc}")
            finally:
                self.dut.qspi_dq_i.value = 0xF
            # If CS_N is already high (fast transaction), RisingEdge won't fire;
            # check current state and skip the wait if deasserted.
            if int(self.dut.qspi_cs_n.value) == 0:
                await RisingEdge(self.dut.qspi_cs_n)
            cocotb.log.info("SpiFlash: CS_N deasserted")


# ===========================================================================
#  Low-level AXI helper (raw-offset read/write for test_qspi.py)
# ===========================================================================
class _AxiHelper:
    def __init__(self, axim: AxiLiteMaster, base: int = 0x02003000):
        self._axim = axim
        self._base = base

    async def read(self, offset: int) -> int:
        data = await self._axim.read(self._base + offset, 8)
        return int.from_bytes(data, "little") & 0xFFFFFFFF  # 32-bit registers on 64-bit bus: {2{reg}} → mask upper copy

    async def write(self, offset: int, val: int):
        await self._axim.write(self._base + offset, val.to_bytes(8, "little"))


# ===========================================================================
#  QSPIEnv – RAL-based environment (used by ai/test_qspi_suite.py)
# ===========================================================================
class QSPIEnv:
    def __init__(self, dut: DUT, base: int = 0x02003000):
        self.dut   = dut
        self._base = base
        self.flash = SpiFlashModel(dut)
        self.axim  = AxiLiteMaster(
            AxiLiteBus.from_prefix(dut, 'axim'), dut.CLK, dut.RST_N,
            reset_active_level=False,
        )
        self.reg = QSPI_Reg_cls(callbacks=AsyncCallbackSet(
            read_callback=self._read,
            write_callback=self._write,
        ))
        cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    async def _read(self, addr: int, width: int, accesswidth: int) -> int:
        rv = await self.axim.read(self._base + addr, 8)
        return int.from_bytes(rv, "little") & ((1 << accesswidth) - 1)

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
        await self.axim.write(self._base + addr, data.to_bytes(8, "little"))

    async def reset(self):
        await reset_n(self.dut.CLK, self.dut.RST_N)

    def start(self):
        pass   # flash.start() called explicitly in tests that need it

    async def poll_not_busy(self, timeout_cycles: int = 2000) -> bool:
        for _ in range(timeout_cycles):
            sr = await self.reg.SR.read()
            if not ((sr >> SR_BUSY) & 1):
                return True
            await RisingEdge(self.dut.CLK)
        cocotb.log.warning("QSPIEnv.poll_not_busy: TIMEOUT")
        return False

    async def enable(self):
        # Direct write: reading CR before cr_en=1 hangs (if_abort preempts all reads when cr_en=0)
        await self.axim.write(self._base + QspiRegs.CR, (1 << CR_EN).to_bytes(8, "little"))

    async def indirect_write(self, addr: int, data: bytes, *,
                              instr: int = 0x02,
                              admode: int = ADDR_MODE_1BIT,
                              adsize: int = ADDR_SIZE_24B,
                              dmode:  int = DATA_MODE_1BIT):
        # Clear TCF+TEF from previous transaction BEFORE starting this one.
        # rl_reset_busy_signal fires every cycle while sr_busy=1 and kills the new
        # transaction in its first cycle if sr_tcf=1 is still set (Bug 5 secondary
        # effect). Clearing at START preserves this transaction's TCF for callers.
        await self.reg.FCR.write(0x3)
        if len(data) > 0:
            await self.reg.DLR.write(len(data))  # Shakti: DLR=N → N bytes (not N+1)
        ccr = ccr_encode(fmode=FMODE_INDIRECT_WRITE, imode=INSTR_MODE_1BIT,
                          instr=instr, admode=admode, adsize=adsize, dmode=dmode)
        await self.reg.CCR.write(ccr)
        await self.reg.AR.write(addr)          # AR last – triggers transfer
        for i, b in enumerate(data):
            if i >= 16:
                # Transaction is running; wait until FIFO has space before writing.
                # In write mode FTF=1 means free_space >= 1 (fifo_count < 16).
                # Without backpressure the enqReadyN(1) guard silently drops bytes.
                while not ((await self.reg.SR.read() >> SR_FTF) & 1):
                    await RisingEdge(self.dut.CLK)
            await self.reg.DR.write(b)
        # rl_data_wait starts the transaction only when fifo.count >= 16 (FIFO full).
        # Pad to 16 bytes so the SPI engine fires; DLR controls actual byte count.
        # Guard: no-data transactions (dmode=0, data=b'') must not pad — zeros would
        # persist in the TX FIFO and corrupt the next transaction's first bytes.
        if len(data) > 0:
            for _ in range(max(0, 16 - len(data))):
                await self.reg.DR.write(0x00)
        await self.poll_not_busy()

    async def indirect_read(self, addr: int, nbytes: int, *,
                             instr: int = 0x03,
                             admode: int = ADDR_MODE_1BIT,
                             adsize: int = ADDR_SIZE_24B,
                             dmode:  int = DATA_MODE_1BIT) -> bytes:
        # Bug 9: rl_data_read_phase enqueues without checking enqReadyN; with
        # a 16-deep FIFO, DLR>16 overflows the circular count back to 0, making
        # all DR reads return stale data. Split into ≤16-byte chunks.
        if nbytes > 16:
            result = bytearray()
            offset = 0
            while offset < nbytes:
                chunk = min(16, nbytes - offset)
                part = await self.indirect_read(addr + offset, chunk,
                                                 instr=instr, admode=admode,
                                                 adsize=adsize, dmode=dmode)
                result.extend(part)
                offset += chunk
            return bytes(result)
        await self.reg.FCR.write(0x3)          # clear TCF+TEF from previous transaction
        await self.reg.DLR.write(nbytes)       # Shakti: DLR=N → N bytes (not N+1)
        ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, imode=INSTR_MODE_1BIT,
                          instr=instr, admode=admode, adsize=adsize, dmode=dmode)
        await self.reg.CCR.write(ccr)
        await self.reg.AR.write(addr)          # AR last – triggers transfer
        await self.poll_not_busy()             # wait for all bytes in FIFO before reading
        result = bytearray()
        for _ in range(nbytes):
            val = await self.reg.DR.read()
            result.append(val & 0xFF)
        return bytes(result)


# ===========================================================================
#  Env – interface compatible with test_qspi.py
# ===========================================================================
class Env:
    """
    Higher-level environment wrapping raw AXI access.
    Provides env.axi.read/write, env.flash, env.indirect_read/write,
    env.poll_not_busy, env.enable – as expected by test_qspi.py.
    """

    def __init__(self, dut: DUT, base: int = 0x02003000):
        self.dut   = dut
        self._base = base
        self.flash = SpiFlashModel(dut)
        _axim = AxiLiteMaster(
            AxiLiteBus.from_prefix(dut, 'axim'), dut.CLK, dut.RST_N,
            reset_active_level=False,
        )
        self._axim = _axim
        self.axi   = _AxiHelper(_axim, base)
        # RAL also available for convenience
        self.reg = QSPI_Reg_cls(callbacks=AsyncCallbackSet(
            read_callback=self._read,
            write_callback=self._write,
        ))
        cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    async def _read(self, addr: int, width: int, accesswidth: int) -> int:
        rv = await self._axim.read(self._base + addr, 8)
        return int.from_bytes(rv, "little") & ((1 << accesswidth) - 1)

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
        await self._axim.write(self._base + addr, data.to_bytes(8, "little"))

    async def reset(self):
        await reset_n(self.dut.CLK, self.dut.RST_N)

    async def enable(self):
        # Direct write: reading CR before cr_en=1 hangs (if_abort preempts all reads when cr_en=0)
        await self.axi.write(QspiRegs.CR, 1 << CR_EN)

    async def poll_not_busy(self, timeout_cycles: int = 2000) -> bool:
        for _ in range(timeout_cycles):
            sr = await self.axi.read(QspiRegs.SR)
            if not ((sr >> SR_BUSY) & 1):
                return True
            await RisingEdge(self.dut.CLK)
        cocotb.log.warning("Env.poll_not_busy: TIMEOUT")
        return False

    async def indirect_write(self, addr: int, data: bytes, *,
                              instr: int = 0x02,
                              admode: int = ADDR_MODE_1BIT,
                              adsize: int = ADDR_SIZE_24B,
                              dmode:  int = DATA_MODE_1BIT):
        await self.axi.write(QspiRegs.FCR, 0x3)   # clear TCF+TEF from previous transaction
        if len(data) > 0:
            await self.axi.write(QspiRegs.DLR, len(data))  # Shakti: DLR=N → N bytes
        ccr = ccr_encode(fmode=FMODE_INDIRECT_WRITE, imode=INSTR_MODE_1BIT,
                          instr=instr, admode=admode, adsize=adsize, dmode=dmode)
        await self.axi.write(QspiRegs.CCR, ccr)
        await self.axi.write(QspiRegs.AR, addr)   # AR last – triggers transfer
        for i, b in enumerate(data):
            if i >= 16:
                # Wait for FIFO space; FTF=1 in write mode means count < 16.
                while not ((await self.axi.read(QspiRegs.SR) >> SR_FTF) & 1):
                    await RisingEdge(self.dut.CLK)
            await self.axi.write(QspiRegs.DR, b)
        # rl_data_wait starts the transaction only when fifo.count >= 16 (FIFO full).
        # Pad to 16 bytes so the SPI engine fires; DLR controls actual byte count.
        # Guard: no-data transactions (dmode=0, data=b'') must not pad.
        if len(data) > 0:
            for _ in range(max(0, 16 - len(data))):
                await self.axi.write(QspiRegs.DR, 0x00)
        await self.poll_not_busy()

    async def indirect_read(self, addr: int, nbytes: int, *,
                             instr: int = 0x03,
                             admode: int = ADDR_MODE_1BIT,
                             adsize: int = ADDR_SIZE_24B,
                             dmode:  int = DATA_MODE_1BIT) -> bytes:
        # Bug 9: RX FIFO overflow wraps count to 0 for DLR > 16.  Split.
        if nbytes > 16:
            result = bytearray()
            offset = 0
            while offset < nbytes:
                chunk = min(16, nbytes - offset)
                part = await self.indirect_read(addr + offset, chunk,
                                                 instr=instr, admode=admode,
                                                 adsize=adsize, dmode=dmode)
                result.extend(part)
                offset += chunk
            return bytes(result)
        await self.axi.write(QspiRegs.FCR, 0x3)   # clear TCF+TEF from previous transaction
        await self.axi.write(QspiRegs.DLR, nbytes)  # Shakti: DLR=N → N bytes
        ccr = ccr_encode(fmode=FMODE_INDIRECT_READ, imode=INSTR_MODE_1BIT,
                          instr=instr, admode=admode, adsize=adsize, dmode=dmode)
        await self.axi.write(QspiRegs.CCR, ccr)
        await self.axi.write(QspiRegs.AR, addr)   # AR last – triggers transfer
        await self.poll_not_busy()                 # wait for all bytes in FIFO
        result = bytearray()
        for _ in range(nbytes):
            val = await self.axi.read(QspiRegs.DR)
            result.append(val & 0xFF)
        return bytes(result)
