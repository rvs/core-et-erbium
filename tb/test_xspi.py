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

import random
import cocotb
from cocotbext.xspi.types import Mode
from cocotb.triggers import Timer, RisingEdge
from env import ETEnv as Env
valid_rates = [
    (Mode.S1, Mode.S1, Mode.S1),
    (Mode.D8, Mode.D8, Mode.D8),
    (Mode.S8, Mode.S8, Mode.S8),
    (Mode.S4, Mode.D4, Mode.D4),
    (Mode.S4, Mode.S4, Mode.S4),
    (Mode.D4, Mode.D4, Mode.D4),
    # (Mode.S1,Mode.S4,Mode.S4),
    # (Mode.S4,Mode.S8,Mode.S8),
    # (Mode.S1,Mode.S8,Mode.S8),
]


def get_random_rate():
    r = Mode.HB
    while r in [Mode.HB, Mode.D2, Mode.S2]:
        r = random.choice(list(Mode))
    return r


@cocotb.test(timeout_time=50000, timeout_unit="ns")
async def test(dut):
    env = Env(dut)
    await env.reset()
    cocotb.log.info("1")
    for _ in range(10):
        await RisingEdge(dut.OSC_CLK_IN)
    cocotb.log.info("1")
    await env.xspi_cmd.Reset()
    cocotb.log.info("1")

    async def est():
        cocotb.log.info("2")
        cocotb.log.info("Reading SFDP")
        cocotb.log.info("2")
        data = await env.xspi_cmd.read_SFDP(0x0)
        cocotb.log.info("2")
        assert data[0:4] == b'SFDP'
        cocotb.log.info(data)
        await Timer(500, 'ns')
        data = await env.xspi_cmd.write_Mem(0x40000060, b'hello world!!!!!')
        await Timer(500, 'ns')
        data = await env.xspi_cmd.read_Mem(0x40000060)
        cocotb.log.info(data)
        assert data == b'hello wo'
        await Timer(500, 'ns')
    cocotb.log.info("1")
    await est()
    cocotb.log.info("1")
    await Timer(500, 'ns')
    cocotb.log.info("1")
    await env.xspi_cmd.setRate(Mode.S4, Mode.D4, Mode.D4)
    cocotb.log.info("1")
    await Timer(500, 'ns')
    await est()
    for i in range(100):
        # xspi_cmd= get_random_rate()
        # data= get_random_rate()
        # addr= get_random_rate()
        r = random.choice(valid_rates)
        xspi_cmd = r[0]
        data = r[1]
        addr = r[2]

        cocotb.log.info(f"Rate is {xspi_cmd=} {addr=} {data=}")
        await env.xspi_cmd.setRate(
            xspi_cmd, addr, data
        )
        await Timer(500, 'ns')
        assert dut.dut.cmd_rate_wget.value.to_unsigned() == xspi_cmd.value
        assert dut.dut.data_rate_wget.value.to_unsigned() == data.value
        assert dut.dut.address_rate_wget.value.to_unsigned() == addr.value
        # await est()
