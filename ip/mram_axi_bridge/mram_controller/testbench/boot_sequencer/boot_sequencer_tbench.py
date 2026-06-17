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
import random

from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
from cocotbext.axi import AxiBus, AxiMaster
from cocotb.binary import BinaryValue

import random

import secrets

DEFAULT_CLK_PERIOD_NS = 4
LONG_CYCLE_CLK_PERIOD_NS = 40
SHORT_CYCLE_CLK_PERIOD_NS = 1
STARTUP_SETTLE_CYCLES = 4
MRAM_BUSY_HIGH_CYCLES = 14
MRAM_BUSY_RECOVERY_CYCLES = 5
LONG_CYCLE_MRAM_BUSY_HIGH_NS = DEFAULT_CLK_PERIOD_NS
LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_RISING_EDGES = 4
LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_DELAY_PS = 500
LONG_CYCLE_MRAM_BUSY_START_DELAY_NS = (
    LONG_CYCLE_CLK_PERIOD_NS // 2
) - (LONG_CYCLE_MRAM_BUSY_HIGH_NS // 2)
SHORT_CYCLE_MRAM_BUSY_HIGH_NS = SHORT_CYCLE_CLK_PERIOD_NS * 3
SHORT_CYCLE_MRAM_BUSY_AFTER_PWR_OK_RISING_EDGES = (
    LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_RISING_EDGES
)
SHORT_CYCLE_MRAM_BUSY_AFTER_PWR_OK_DELAY_PS = (
    LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_DELAY_PS
)

class TB:

    def __init__(self):
        pass

    def set_dut(self, dut):
        self.dut = dut

    def initialize_clock(self, period_ns=DEFAULT_CLK_PERIOD_NS):
        cocotb.start_soon(Clock(self.dut.clk_i, period_ns, units="ns").start())

    async def reset_sequence(self):
        self.dut.rst_bi.value = 0
        await Timer(10, units="ns")
        self.dut.rst_bi.value = 0
        self.set_pwr_ok_i(0)
        self.set_nvsram_startup_bypass_i(0)
        self.set_mram_busy_i(0)
        self.set_reg_logic_sup_sleep_ovr_i(1)
        await Timer(10, units="ns")
        await FallingEdge(self.dut.clk_i)
        self.dut.rst_bi.value = 1
    async def setup_tb(self, clock_period_ns=DEFAULT_CLK_PERIOD_NS):
        self.set_rst_bi(0)
        self.initialize_clock(clock_period_ns)

    def set_rst_bi(self, value):
        self.dut.rst_bi.value = value

    def set_pwr_ok_i(self, value):
        self.dut.pwr_ok_i.value = value

    def set_nvsram_startup_bypass_i(self, value):
        self.dut.nvsram_startup_bypass_i.value = value

    def set_mram_busy_i(self, value):
        self.dut.mram_busy_i.value = value

    def set_reg_logic_sup_sleep_ovr_i(self, value):
        self.dut.reg_logic_sup_sleep_ovr_i.value = value

    def get_mram_rst_bo (self):
        ret_val  =  self.dut.mram_rst_bo.value
        return ret_val

    def get_pwr_up_sel_o (self):
        ret_val  =  self.dut.pwr_up_sel_o.value
        return ret_val


    def get_axi_busy_o (self):
        ret_val  =  self.dut.axi_busy_o.value
        return ret_val


my_tb = TB()

async def wait_clk_falling_edges(dut, cycles):
    for _ in range(cycles):
        await FallingEdge(dut.clk_i)


async def wait_clk_rising_edges(dut, cycles):
    for _ in range(cycles):
        await RisingEdge(dut.clk_i)


async def run_startup_window(
    dut,
    use_busy=True,
    busy_high_ns=None,
    busy_start_delay_ns=0,
):
    await wait_clk_falling_edges(dut, STARTUP_SETTLE_CYCLES)

    if use_busy:
        if busy_high_ns is None:
            my_tb.set_mram_busy_i(1)
            await wait_clk_falling_edges(dut, MRAM_BUSY_HIGH_CYCLES)
            my_tb.set_mram_busy_i(0)
        else:
            if busy_start_delay_ns:
                await Timer(busy_start_delay_ns, units="ns")
            my_tb.set_mram_busy_i(1)
            await Timer(busy_high_ns, units="ns")
            my_tb.set_mram_busy_i(0)
    else:
        await wait_clk_falling_edges(dut, MRAM_BUSY_HIGH_CYCLES)

    await wait_clk_falling_edges(dut, MRAM_BUSY_RECOVERY_CYCLES)


async def run_busy_after_pwr_ok_window(
    dut,
    busy_high_ns=None,
    busy_rising_edges_after_pwr_ok=STARTUP_SETTLE_CYCLES,
    busy_start_delay_ps=0,
):
    await wait_clk_rising_edges(dut, busy_rising_edges_after_pwr_ok)

    if busy_start_delay_ps:
        await Timer(busy_start_delay_ps, units="ps")

    my_tb.set_mram_busy_i(1)
    if busy_high_ns is None:
        await wait_clk_falling_edges(dut, MRAM_BUSY_HIGH_CYCLES)
    else:
        await Timer(busy_high_ns, units="ns")
    my_tb.set_mram_busy_i(0)

    await wait_clk_falling_edges(dut, MRAM_BUSY_RECOVERY_CYCLES)


async def run_initial_setup_sequence(
    dut,
    clock_period_ns=DEFAULT_CLK_PERIOD_NS,
    busy_high_ns=None,
    busy_start_delay_ns=0,
    pwr_ok_busy_rising_edges_after_assert=None,
    pwr_ok_busy_start_delay_ps=0,
):
    my_tb.set_dut(dut)
    await my_tb.setup_tb(clock_period_ns=clock_period_ns)
    ##
    ## Checking reset sequence ...
    ##
    await my_tb.reset_sequence()
    ##
    ## Align signal delivery with clk_i falling edge ...
    ##
    await FallingEdge(dut.clk_i)
    ##
    ## Let's power it up and see what happens ...
    ##
    my_tb.set_nvsram_startup_bypass_i(0)
    ##
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await run_busy_after_pwr_ok_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
            busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
        )
    ##
    ##
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    await run_startup_window(
        dut,
        busy_high_ns=busy_high_ns,
        busy_start_delay_ns=busy_start_delay_ns,
    )
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await run_busy_after_pwr_ok_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
            busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
        )
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is not None:
        busy_task = cocotb.start_soon(
            run_busy_after_pwr_ok_window(
                dut,
                busy_high_ns=busy_high_ns,
                busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
                busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
            )
        )
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await busy_task
    ##
    ##
    my_tb.set_nvsram_startup_bypass_i(1)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    await run_startup_window(dut, use_busy=False)
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    await run_startup_window(dut, use_busy=False)
    ##
    ##
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    await run_startup_window(dut, use_busy=False)
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    await run_startup_window(dut, use_busy=False)
    ##
    ##
    my_tb.set_nvsram_startup_bypass_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await run_busy_after_pwr_ok_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
            busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
        )
    ##
    ##
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    await run_startup_window(
        dut,
        busy_high_ns=busy_high_ns,
        busy_start_delay_ns=busy_start_delay_ns,
    )
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await run_busy_after_pwr_ok_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
            busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
        )
    ##
    ##
    my_tb.set_pwr_ok_i(0)
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(0)
    await Timer(20, units="ns")
    await FallingEdge(dut.clk_i)
    my_tb.set_pwr_ok_i(1)
    if pwr_ok_busy_rising_edges_after_assert is not None:
        busy_task = cocotb.start_soon(
            run_busy_after_pwr_ok_window(
                dut,
                busy_high_ns=busy_high_ns,
                busy_rising_edges_after_pwr_ok=pwr_ok_busy_rising_edges_after_assert,
                busy_start_delay_ps=pwr_ok_busy_start_delay_ps,
            )
        )
    await FallingEdge(dut.clk_i)
    my_tb.set_rst_bi(1)
    if pwr_ok_busy_rising_edges_after_assert is None:
        await run_startup_window(
            dut,
            busy_high_ns=busy_high_ns,
            busy_start_delay_ns=busy_start_delay_ns,
        )
    else:
        await busy_task

##
##
    my_tb.set_reg_logic_sup_sleep_ovr_i(0)
    await wait_clk_falling_edges(dut, 5)
    my_tb.set_reg_logic_sup_sleep_ovr_i(1)
    await wait_clk_falling_edges(dut, 5)

    ##
    ##
    ##my_tb.set_powerup_trim_load_ovr_i(1)
    ##for _ in range(4):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(1)
    ##for _ in range(14):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(0)
    ##for _ in range(5):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_powerup_trim_load_ovr_i(2)
    ##for _ in range(4):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(1)
    ##for _ in range(14):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(0)
    ##for _ in range(5):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_powerup_trim_load_ovr_i(4)
    ##for _ in range(4):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(1)
    ##for _ in range(14):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(0)
    ##for _ in range(5):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_powerup_trim_load_ovr_i(8)
    ##for _ in range(4):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(1)
    ##for _ in range(14):
    ##    await FallingEdge(dut.clk_i)
    ##my_tb.set_mram_busy_i(0)
    ##for _ in range(5):
    ##    await FallingEdge(dut.clk_i)


@cocotb.test()
async def initial_setup(dut):
    """Performing system startup test."""
    await run_initial_setup_sequence(dut)


@cocotb.test()
async def long_cycle(dut):
    """Run the startup sequence with a much slower clk_i than mram_busy_i."""
    await run_initial_setup_sequence(
        dut,
        clock_period_ns=LONG_CYCLE_CLK_PERIOD_NS,
        busy_high_ns=LONG_CYCLE_MRAM_BUSY_HIGH_NS,
        busy_start_delay_ns=LONG_CYCLE_MRAM_BUSY_START_DELAY_NS,
        pwr_ok_busy_rising_edges_after_assert=(
            LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_RISING_EDGES
        ),
        pwr_ok_busy_start_delay_ps=LONG_CYCLE_MRAM_BUSY_AFTER_PWR_OK_DELAY_PS,
    )


@cocotb.test()
async def short_cycle(dut):
    """Run the startup sequence with a 1 ns clk_i and a 3 ns mram_busy_i pulse."""
    await run_initial_setup_sequence(
        dut,
        clock_period_ns=SHORT_CYCLE_CLK_PERIOD_NS,
        busy_high_ns=SHORT_CYCLE_MRAM_BUSY_HIGH_NS,
        pwr_ok_busy_rising_edges_after_assert=(
            SHORT_CYCLE_MRAM_BUSY_AFTER_PWR_OK_RISING_EDGES
        ),
        pwr_ok_busy_start_delay_ps=SHORT_CYCLE_MRAM_BUSY_AFTER_PWR_OK_DELAY_PS,
    )
