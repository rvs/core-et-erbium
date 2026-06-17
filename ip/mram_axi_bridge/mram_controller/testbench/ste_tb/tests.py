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
from cocotb.triggers import Timer, Edge
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
import tbench

@cocotb.test()
async def power_up_test(dut):
    my_tb = tbench.TB(dut)
    my_tb.setup_tb()
    cocotb.start_soon(my_tb.gen_sa_cal_clk_i(3))
    cocotb.start_soon(my_tb.gen_nvsram_busy())
    for stripe in range(4):
        cocotb.start_soon(my_tb.gen_stripe_sa_cal(stripe))
    await my_tb.power_up()
    await Timer(1000, units="ns")
    for (channel, result) in enumerate(my_tb.nvsram_complete):
        if my_tb.nvsram_complete[channel] is not True:
            my_tb.dut._log.info(f"TEST RESULT: nvsram stripe {channel} is not complete.")
        assert my_tb.nvsram_complete[channel] is True
    for (channel, result) in enumerate(my_tb.sa_cal_complete):
        if my_tb.sa_cal_complete[channel] is not True:
            my_tb.dut._log.info(f"TEST RESULT: sa_cal stripe {channel} is not complete.")
        assert my_tb.sa_cal_complete[channel] is True

@cocotb.test()
async def override_test(dut):
    my_tb = tbench.TB(dut)
    my_tb.setup_tb()
    for sel_value in range(1, 16):
        my_tb.dut.ste_ovr_sel_i.value = sel_value
        await Timer(10, units="ns")
        for pin_value in range(16):
            my_tb.dut.sa_cal_en_ovr_i.value = pin_value
            await Timer(10, units="ns")
            assert my_tb.dut.sa_cal_en_o.value == my_tb.dut.sa_cal_en_ovr_i.value & sel_value
            assert my_tb.dut.sa_cal_en_o.value == pin_value & sel_value
            my_tb.dut.sa_cal_en_ovr_i.value = 0
        for pin_value in range(16):
            my_tb.dut.sa_cal_clk_ovr_i.value = pin_value
            await Timer(10, units="ns")
            assert my_tb.dut.sa_cal_en_o.value == 0
            assert my_tb.dut.sa_cal_clk_o.value == my_tb.dut.sa_cal_clk_ovr_i.value & sel_value
            assert my_tb.dut.sa_cal_clk_o.value == pin_value & sel_value
            my_tb.dut.sa_cal_clk_ovr_i.value = 0
        for pin_value in range(16):
            my_tb.dut.nvsram_en_ovr_i.value = pin_value
            await Timer(10, units="ns")
            assert my_tb.dut.sa_cal_clk_o.value == 0
            assert my_tb.dut.nvsram_en_o.value == my_tb.dut.nvsram_en_ovr_i.value & sel_value
            assert my_tb.dut.nvsram_en_o.value == pin_value & sel_value
            my_tb.dut.nvsram_en_ovr_i.value = 0

        my_tb.dut.reg_logic_sup_sleep_ovr_i.value = 1
        await Timer(10, units="ns")
        assert my_tb.dut.nvsram_en_o.value == my_tb.dut.nvsram_en_ovr_i.value
        assert my_tb.dut.reg_logic_sup_sleep_o.value == my_tb.dut.reg_logic_sup_sleep_ovr_i.value
        assert my_tb.dut.reg_logic_sup_sleep_bo.value == (my_tb.dut.reg_logic_sup_sleep_ovr_i.value.integer + 1) % 2
        my_tb.dut.reg_logic_sup_sleep_ovr_i.value = 0
        await Timer(10, units="ns")
        assert my_tb.dut.reg_logic_sup_sleep_o.value == my_tb.dut.reg_logic_sup_sleep_ovr_i.value
        assert my_tb.dut.reg_logic_sup_sleep_bo.value == (my_tb.dut.reg_logic_sup_sleep_ovr_i.value.integer + 1) % 2
        my_tb.dut.ste_ovr_sel_i.value = 0
        await Timer(10, units="ns")
