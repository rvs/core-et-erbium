"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-01-28
 Description: A brief description of the file's purpose.
"""
import os
import random
import cocotb
from cocotbext.dyulib.reset import clock_in_reset_start, reset_end, reset_n
from cocotbext.uart import UartSink, UartSource
from cocotbext.i2c import I2cMemory
from cocotbext.xspi.bus import XspiBus
from cocotbext.xspi.commands import XspiCommands
from ral.xspi_mm.ErbiumxSPI_MemoryMap.reg_model.ErbiumxSPI_MemoryMap import ErbiumxSPI_MemoryMap_cls
from ral.xspi_mm.ErbiumxSPI_MemoryMap.lib.callbacks import AsyncCallbackSet
from typing import TYPE_CHECKING, Any
from cocotb.triggers import RisingEdge, Timer
from cocotbext.xspi.types import Mode
# from ral.xspi_mm.ErbiumxSPI_MemoryMap.reg_model.ErbiumxSPI_MemoryMap import ErbiumxSPI_MemoryMap_cls
# from ral.xspi_mm.ErbiumxSPI_MemoryMap.lib.callbacks import AsyncCallbackSet
from mem_loader.mem_loader import MemLoader
if TYPE_CHECKING:
    from copra_stubs import Tb as DUT
else:
    DUT = Any

class ETEnv:
    def __init__(self, dut: DUT, baud=115200,safe_callback=False):
        self.uart_tx = UartSource(dut.UART_RX, baud=baud, bits=8)
        self.uart_rx = UartSink(dut.UART_TX, baud=baud, bits=8)
        self.i2c = I2cMemory(dut.i2c_sda_o, dut.i2c_sda_i,
                             dut.i2c_scl_o, dut.i2c_scl_i, 0x50, 256, run_now=False)
        bus = XspiBus(dut, "XSPI")
        # print(bus.__dict__)

        self.xspi_cmd = XspiCommands(bus, dut=dut, free_running_clk=True)
        self.dut = dut
        if safe_callback:
            cb=AsyncCallbackSet(read_callback=self.read, write_callback=self.write)
        else:
            cb=AsyncCallbackSet(read_callback=self._read, write_callback=self._write)
        self.reg = ErbiumxSPI_MemoryMap_cls(callbacks=cb)
        default_ifc = os.getenv("DEFAULT_INTERFACE", "xspi")
        if default_ifc == "xspi":
            self.ifc = self.xspi_cmd
        self.drive_default_value()

        self.mem = MemLoader(dut)

    def start(self):
        self.i2c.start()

    async def _randomize_mode(self,allowed_modes= (
           (Mode.S4, Mode.D4, Mode.D4),
           (Mode.D4, Mode.D4, Mode.D4),
           (Mode.S8, Mode.S8, Mode.S8),
           (Mode.D8, Mode.D8, Mode.D8),
           )):
        mode =random.choice(allowed_modes)
        await self.xspi_cmd.setRate(*mode)

    async def _read(self, addr: int, width: int, accesswidth: int):
        rv = await self.ifc.read(addr.to_bytes(4, "big"))
        return int.from_bytes(rv, "little")

    async def read(self, addr: int, width: int, accesswidth: int):
        rv= await self._read(addr,width,accesswidth)
        await self.assert_no_xspi_errors()
        return rv
    async def write(self, addr: int, width: int, accesswidth: int, data: int):
        await self._write(addr, width, accesswidth, data)
        await self.assert_no_xspi_errors()

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
        #print(
        #    f"IFC writing addr=0x{addr:x} data=0x{data:x} "
        #    f"width={width} accesswidth={accesswidth}"
        #)
        ifc_accesswidth = max(64, accesswidth) >> 3
        await self.ifc.write(addr.to_bytes(4, "big"), data.to_bytes(ifc_accesswidth, "little"))
        
    async def clk_in_reset(self):
       """Wrapper over the reset_end event."""
       await clock_in_reset_start.wait()

    async def reset_done(self):
       """Wrapper over the reset_end event."""
       await reset_end.wait()

    def drive_default_value(self):
        self.dut.TestMode.value = 1
        self.dut.brownout_b.value = 1
        self.dut.TMS.value = 1
        self.dut.TDI.value = 1
        self.dut.xspi_mode.value = 3
        pass

    async def warm_reset(self, value):
        await self.reg.system_registers.SoftReset.write(4 | (value << 1))
        await self._wait_wip()

    async def reset(self,program="Random", randomize_mode=True):
        await reset_n(self.dut.ring_osc_clk, self.dut.TRSTn)
        await RisingEdge(self.dut.et.prcm_et.verification_reset_done)
        if program:
            await self.program_prcm(program)
        if randomize_mode:
            await self._randomize_mode()

    async def set_test_mode(self, test_mode):
        cocotb.log.info(f"Setting TestMode to {test_mode}...")
        self.dut.TestMode.value = test_mode
        await Timer(10, unit="ns")

    async def _program_div(self,program,reg):
        en = 1
        count = 1
        if program== "Random":
            en=random.choice([0,1])
            count =random.randint(0,0x10)
        if program== "Max":
            en =0
            count =random.randint(0,0x10)
        if program== "Min":
            en = 1
            count = 0xf
        await reg.write((en<<4)|count)
        await self._wait_wip()
    async def program_prcm(self,program):
        await Timer(100,'us')
        # Always trim RO for 1GHz.
        en =1
        divby2_sel=0
        trm=27
        await self.reg.system_registers.ring_osc.write( (trm<<2)| (divby2_sel<<1)| en)
        await Timer(100,'us')
        await self._program_div(program,
        self.reg.system_registers.cpu_divider
                                  )
        await self._program_div(program,
        self.reg.system_registers.system_divider
                                  )
        await self._program_div(program,
        self.reg.system_registers.periph_divider
                                  )

    async def _wait_wip(self):
        rv_int = 1
        # print(dir(self))
        while rv_int:
            rv = await self.ifc.read_Reg(0x18)  # Status
            rv_int = int.from_bytes(rv, "little")

    async def assert_no_xspi_errors(self, slvError=False,
                                decodeError=False,
                                read_underflow=False,
                                write_overflow=False,msg=""):
        expected = (0 |
                    2 if slvError else 0 |
                    3 if decodeError else 0 |
                    4 if read_underflow else 0 |
                    8 if write_overflow else 0
                    )
        rv_int = 1
        # print(dir(self))
        await self._wait_wip()
        int_status = await self.ifc.read_Reg(0x30)  # Interrupt
        assert int.from_bytes(int_status, "little") == expected,msg

    async def load_elf(self, elf_path: str):
        boot_addr = await self.mem.load_elf(elf_path)
        return boot_addr

    async def read_byte(self, addr: int) -> int:
        return await self.mem.read_byte(addr)

    async def write_byte(self, addr: int, data: int) -> int:
        await self.mem.write_byte(addr, data)

    async def set_minion_features(self,
        disable_lock_unlock    : bool = False,
        disable_multithreading : bool = False,
        trap_on_u_scp          : bool = False,
        trap_on_u_cacheops     : bool = False,
        trap_on_ml             : bool = False,
        trap_on_gfx            : bool = True,
        backdoor               : bool = True,
    ):
        # Set the minion_feature bit
        minion_feature = 0
        if disable_lock_unlock:
            minion_feature |= 0b100000   # bit 5
        if disable_multithreading:
            minion_feature |= 0b010000   # bit 4
        if trap_on_u_scp:
            minion_feature |= 0b001000   # bit 3
        if trap_on_u_cacheops:
            minion_feature |= 0b000100   # bit 2
        if trap_on_ml:
            minion_feature |= 0b000010   # bit 1
        if trap_on_gfx:
            minion_feature |= 0b000001   # bit 0

        # Assign it to the DUT
        if backdoor:
            dut_minion_feature = self.dut.et.erbium_digital.cpu_ss.i_esr.reg_minion_feature
            dut_minion_feature.value = minion_feature
        else:
            await self.reg.cpu_registers.Machine_cpu.minion_feature.write(minion_feature)
            await self._wait_wip()

    async def set_minion_bootpc(self, bootpc: int, backdoor: bool = True):
        if backdoor:
            self.dut.et.erbium_digital.cpu_ss.i_neigh.channel.esrs.reg_minion_boot.value = bootpc
        else:
            await self.reg.cpu_registers.Machine_neigh.minion_boot.write(bootpc)
            await self._wait_wip()

    async def disable_minions(self, minion_mask: int = 0xFF, thread_mask: int = 0x3, backdoor: bool = True):
        if thread_mask & 1:
            if backdoor:
                self.dut.et.erbium_digital.cpu_ss.i_esr.reg_thread0_disable.value = minion_mask
            else:
                await self.reg.cpu_registers.Machine_cpu.thread0_disable.write(minion_mask)
                await self._wait_wip()
        if thread_mask & 2:
            if backdoor:
                self.dut.et.erbium_digital.cpu_ss.i_esr.reg_thread1_disable.value = minion_mask
            else:
                await self.reg.cpu_registers.Machine_cpu.thread1_disable.write(minion_mask)
                await self._wait_wip()

    async def enable_minions(self, minion_mask: int = 0xFF, thread_mask: int = 0x3, backdoor: bool = True):
        minion_mask = 0xFF & (~minion_mask)
        if thread_mask & 1:
            if backdoor:
                self.dut.et.erbium_digital.cpu_ss.i_esr.reg_thread0_disable.value = minion_mask
            else:
                await self.reg.cpu_registers.Machine_cpu.thread0_disable.write(minion_mask)
                await self._wait_wip()
        if thread_mask & 2:
            if backdoor:
                self.dut.et.erbium_digital.cpu_ss.i_esr.reg_thread1_disable.value = minion_mask
            else:
                await self.reg.cpu_registers.Machine_cpu.thread1_disable.write(minion_mask)
                await self._wait_wip()

    async def read_mailbox0(self):
        # TODO: frontdoor
        mbox0 = self.dut.et.erbium_digital.system_registers.field_storage.Mailbox0.mbox0.value
        return int(mbox0.value)
