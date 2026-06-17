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
from cocotb_bus.monitors import BusMonitor
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly


class DRAMMonitor(BusMonitor):
    _signals = "rst_bi clk_i cs_i we_i addr_i wdata_i rdata_o busy_o".split(
        " ")
    _optional_signals = []

    def __init__(self, dut, name, clock, cs_id, callback=None,read_valid=None):
        self.cs_id = cs_id
        self.read_valid=read_valid
        super().__init__(dut, name, clock, callback=callback)

    async def _monitor_recv(self):
        prev_read = False
        prev_addr = 0
        write = False
        fallingedge = FallingEdge(self.bus.clk_i)
        rdonly = ReadOnly()
        await RisingEdge(self.bus.rst_bi)
        mon = f"DRAMMonitor {self.cs_id}"
        txn={}
        while True:
            # cocotb.log.info(f'{mon} Bools {write}, {prev_read}')
            if self.bus.cs_i.value != 1:
                cocotb.log.info(f"{mon} no cs")
                await RisingEdge(self.bus.cs_i)
                cocotb.log.info(f'{mon} got cs')
            await fallingedge
            await rdonly
            if prev_read:
                cocotb.log.info(f"{mon} pending read")
                txn['rdata']= self.bus.rdata_o.value.integer
                txn['addr']=prev_addr
                txn['read']=True
                txn['write']=False
                txn['cs']=self.cs_id
                self._recv(txn)
                prev_read = False
            prev_addr = self.bus.addr_i.value.integer
            write = self.bus.we_i.value.integer == 1
            if write:
                txn = {
                    'addr': self.bus.addr_i.value.integer,
                    "cs": self.cs_id,
                    "write": write,
                    "read": False,
                    "wdata": self.bus.wdata_i.value.integer,
                    "rdata": self.bus.rdata_o.value.integer,
                }
                self._recv(txn)
            prev_read = self.read_valid.value
