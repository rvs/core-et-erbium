from dataclasses import dataclass
from typing import Optional
import logging
from cocotb_bus.bus import Bus
from collections import deque
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Event, Edge


class QspiBus(Bus):

    def __init__(
        self,
        entity=None,
        prefix=None,
        sclk_name="sclk",
        io_i_name="io_i",
        io_o_name="io_o",
        cs_name="cs",
        **kwargs,
    ):
        signals = {
            "sclk": sclk_name,
            "io_i": io_i_name,
            "io_o": io_o_name,
            "cs": cs_name,
        }
        super().__init__(entity, prefix, signals, **kwargs)

    @classmethod
    def from_entity(cls, entity, **kwargs):
        return cls(entity, **kwargs)

    @classmethod
    def from_prefix(cls, entity, prefix, **kwargs):
        return cls(entity, prefix, **kwargs)


@dataclass
class QspiConfig:
    ADMODE: int = 3
    IMODE: int = 0
    DMODE: int = 3
    FMODE: int = 1
    ADSIZE: int = 0
    DCYC: int = 5
    DLEN: int = 2


class QspiFlash:

    def __init__(self, bus: QspiBus, config: QspiConfig):
        self.log = logging.getLogger(f"cocotb.{bus.sclk._path}")
        self._config = config
        self._sclk = bus.sclk
        self._io_i = bus.io_i
        self._io_o = bus.io_o
        self._cs = bus.cs
        self.queue_addr = deque()
        self.queue_instr = deque()
        self.queue_data = deque()
        self.idle = Event()
        self.done = Event()
        self.idle.clear()
        self.done.clear()
        self._run_coroutine_obj = None
        self._restart()

    def _restart(self):
        if self._run_coroutine_obj is not None:
            self._run_coroutine_obj.kill()
        self._run_coroutine_obj = cocotb.start_soon(self._run())

    # ── QspiFlash._run() 
    async def _run(self):
        while True:
            instr = 0
            addr = 0
            data = 0
            shift_data = 0

            # Compute cycle counts from config
            instr_cycles = 8                              # always SPI (1-wire)
            addr_cycles  = 2 * (self._config.ADSIZE + 1) # nibbles in QSPI
            dummy_cycles = self._config.DCYC
            data_cycles  = self._config.DLEN * 2         # nibbles

            self.idle.set()
            await FallingEdge(self._cs)
            self.idle.clear()

            print("\n" + "=" * 80)
            print("*" * 20 + " QSPI extn started " + "*" * 20)
            print("=" * 80)

            # ── Instruction phase — 8 bits, SPI (single wire), sample on rising ──
            for _ in range(instr_cycles):
                await RisingEdge(self._sclk)
                instr = (instr << 1) | (int(self._io_o.value) & 1)
            self.queue_instr.append(instr)
            self.log.info(f"INSTR: {hex(instr)}")

            # BUG 1 REMOVED: no spurious 2-edge skip here
            for k in range(2):
                await RisingEdge(self._sclk)
            # ── Address phase — QSPI (4-wire), sample on rising edge only ─────────
            for k in range(addr_cycles):
                await RisingEdge(self._sclk)                          
                nibble = int(self._io_o.value) & 0xF
                addr = addr | (nibble << ((addr_cycles - 1 - k) * 4))
            self.queue_addr.append(addr)
            self.log.info(f"ADDR: {hex(addr)}")

            # ── Dummy cycles — just burn rising edges ─────────────────────────────
            for _ in range(dummy_cycles):                             
                await RisingEdge(self._sclk)

            # ── Data phase ────────────────────────────────────────────────────────
            if self._config.FMODE == 1:  # indirect read → model drives io_i
                
                data = self.queue_data.pop()
                self.log.critical(f"DATA LEN (nibbles): {data_cycles}")
                self.log.critical(f"DATA: {hex(data)}")

                for k in range(data_cycles):
                    
                    await FallingEdge(self._sclk)                     # output changes on falling
                    shift = (data_cycles - 1 - k) * 4
                    shift_data = (data & (0xF << shift)) >> shift
                    self.log.critical(f"  nibble[{k}] = {hex(shift_data)}")
                    self._io_i.value = shift_data

                # Let the last nibble settle after final rising edge
                await RisingEdge(self._sclk)

            elif self._config.FMODE == 0:  # indirect write → DUT drives io_o
                for k in range(data_cycles):
                    await RisingEdge(self._sclk)                      # sample on rising
                    shift = (data_cycles - 1 - k) * 4
                    nibble = int(self._io_o.value) & 0xF
                    shift_data |= nibble << shift
                    self.log.critical(f"  nibble[{k}] = {hex(nibble)}")
                self.log.critical(f"Appending RX data: {hex(shift_data)}")
                self.queue_data.append(shift_data)
            self.done.set()