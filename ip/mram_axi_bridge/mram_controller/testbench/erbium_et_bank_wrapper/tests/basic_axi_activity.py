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

from tb import WrapperTB


@cocotb.test()
async def basic_axi_activity(top):
    tb = WrapperTB(top)
    await tb.reset()

    random.seed(11)
    for i in range(8):
        addr = i * 4
        data = random.getrandbits(64)
        await tb.issue_axi_write(addr=addr, data=data, stripe=0x1, byte_en=0xFF)

    await tb.wait_axi_idle()

    for i in range(8):
        _ = await tb.issue_axi_read(addr=i * 4, stripe=0x1)
