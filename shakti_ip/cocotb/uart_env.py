
"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-08
 Description: A brief description of the file's purpose.
"""
import cocotb
from cocotbext.dyulib.reset import clock_in_reset_start, reset_end, reset_n
from cocotbext.uart import UartSink, UartSource
from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotb.clock import Clock
from typing import TYPE_CHECKING, Any
from ral.UART_Reg.reg_model.UART_Reg import UART_Reg_cls
from ral.UART_Reg.lib import AsyncCallbackSet
if TYPE_CHECKING:
    from copra_stubs import Tb as DUT
else:
    DUT = Any


class UARTEnv:
    def __init__(self, dut: DUT, baud=115200):
        self.uart_tx = UartSource(dut.UART_RX, baud=baud, bits=8)
        self.uart_rx = UartSink(dut.UART_TX, baud=baud, bits=8)
        self.axim = AxiLiteMaster(AxiLiteBus.from_prefix(dut,'axim'),dut.CLK,dut.RST_N,reset_active_level=False)
        self.dut = dut
        self.reg = UART_Reg_cls(callbacks=AsyncCallbackSet(
            read_callback=self._read,
            write_callback=self._write 
            ))
        self.ifc=self.axim
        cocotb.start_soon(Clock(dut.CLK,10,"ns").start())

    async def _read(self, addr: int, width: int, accesswidth: int):
        rv = await self.ifc.read(addr,4)
        return int.from_bytes(rv, "little")

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
        # print(f"writing {addr=} {data=}")
        await self.ifc.write(addr, data.to_bytes(8, "little"))

    def start(self):
        pass
    async def reset(self):
        await reset_n(self.dut.CLK, self.dut.RST_N)
