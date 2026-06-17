# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb.triggers import Timer, RisingEdge
from Uart.reg_model.Uart import Uart_cls
from Uart.lib import AsyncCallbackSet

class Env:
   def __init__(self,dut,timeout):
      self.dut=dut
      self.reg=Uart_cls(
             callbacks=AsyncCallbackSet(
                  read_callback=self.regRead,
                  write_callback=self.regWrite))
      ifc=None # TODO set this to a default config IFC.
      self.timeout = timeout

   def test(self, override_initialization=None):
      if override_initialization is not None:
	      self.init_config=override_initialization
      self.start()
      self.initialize()
      self.run()
      self.check()

   def start(self):
      pass

   def initialize(self):
      pass

   def run(self):
      pass

   def check(self):
      pass
   async def regRead(self, addr: int, width: int, accesswidth: int):
      rv = await self.ifc.read(addr)
      cocotb.log.info(f"RegRead addr={addr:x} rdata={hex(rv.integer)}")
      return rv.integer
      pass

   async def regWrite(self, addr: int, width: int, accesswidth: int, data: int):
        cocotb.log.info(f"RegWrite, addr={hex(addr)} data={hex(data)}")
        return await self.ifc.write(addr, data)
        pass
