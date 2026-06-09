"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-04-06
 Description: A brief description of the file's purpose.
"""
from cocotbext.apb import ApbMaster, ApbBus
from cocotbext.i2c import I2cMemory
from cocotbext.dyulib.reset import clock_in_reset_start, reset_end, reset_n
from typing import TYPE_CHECKING, Any 
from cocotb.triggers import RisingEdge, Timer
from ral.I2C_Reg.reg_model.I2C_Reg import I2C_Reg_cls
from ral.I2C_Reg.lib.callbacks import AsyncCallbackSet
if TYPE_CHECKING:
     from copra_stubs import Tb as DUT
else:
     DUT = Any


class Env:
    def __init__(self,dut,clk,rst_n):
        bus = ApbBus.from_prefix(dut, "s_apb")
        self.dut=dut
        self.apb_driver = ApbMaster(bus, dut.clk)
        self.i2c_mem = I2cMemory(dut.i2c_sda_o, dut.i2c_sda_i, dut.i2c_scl_o, dut.i2c_scl_i, 0x50, 256)
        self.reg = I2C_Reg_cls(callbacks=AsyncCallbackSet(
            read_callback=self._read,
            write_callback=self._write
            ))
        self.ifc=self.apb_driver

    def start(self):
        self.i2c_mem.start()

    def drive_default_values(self,dut):
        pass
    async def _read(self, addr: int, width: int, accesswidth: int):
       rv = await self.ifc.read(addr)
       return int.from_bytes(rv, "little")

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
       print(f"writing {addr=} {data=}")
       await self.ifc.write(addr, data.to_bytes(8, "little"))

    async def clk_in_reset(self):
      """Wrapper over the reset_end event."""
      await clock_in_reset_start.wait()

    async def reset_done(self):
      """Wrapper over the reset_end event."""
      await reset_end.wait()

    async def reset(self,program="Random", randomize_mode=True):
        await reset_n(self.dut.clk, self.dut.arst_n)

