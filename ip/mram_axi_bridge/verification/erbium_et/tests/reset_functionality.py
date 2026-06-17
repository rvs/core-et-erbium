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
from tb import *


@cocotb.test()
async def reset_functionality(dut):
    """Working through the different reset combinations to verify their intention."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()

    my_tb.dut.rst_b.value = 1
    my_tb.dut.mram_rst_b.value = 1

    # First, master reset only
    my_tb.dut._log.info(f"# Condition 1: Master reset only")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 0
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)

    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 1

    # now, MRAM reset only
    my_tb.dut._log.info(f"# Condition 2: MRAM reset only")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.mram_rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 1
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)

    await Timer(10, unit="ns")
    my_tb.dut.mram_rst_b.value = 1

    # now, both resets
    my_tb.dut._log.info(f"# Condition 3: Both Resets")
    await RisingEdge(my_tb.dut.clk)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 0
    my_tb.dut.mram_rst_b.value = 0
    await Timer(1, unit="step")
    assert my_tb.dut.axi2mram.RST_N.value == 0
    assert all(v == 0 for v in my_tb.dut.axi2mram_rst_b.value)
    await Timer(10, unit="ns")
    my_tb.dut.rst_b.value = 1
    my_tb.dut.mram_rst_b.value = 1
    await Timer(100, unit="ns")
