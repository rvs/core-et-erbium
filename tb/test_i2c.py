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
from cocotb.triggers import Timer
from env import ETEnv
import random

@cocotb.test(timeout_time=1990000, timeout_unit="ns")
async def default_test(dut):
    cocotb.log.info("Starting Test")
    tb = ETEnv(dut)
    cocotb.log.info("Starting Test")
    await tb.reset()
    tb.start()
    await Timer(500,'us')
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    id = await tb.reg.system_registers.Version.read_fields()
    assert id == {'chipid': 60264, 'respin': 0, 'variation': 0}, "Error chip id match failed"
    await tb.reg.system_registers.SystemConfig.write(0x1c)

    for i in range(20):
        await tb.reg.i2c_registers.Commands.write(0x5035)
        await tb.reg.i2c_registers.Cfg.write(0x0)
        await tb.reg.i2c_registers.Wdata.write(0x100 |i)
        ff_full =1
        while ff_full:
            rv = await tb.reg.i2c_registers.Status.read_fields()
            ff_full =  rv["tx_ff_n_full"] == 0

    await Timer(1,'ms')
