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
from cocotb.triggers import RisingEdge
from tb import *


def any_bank_signal(dut, signal_name):
    bridge = dut.axi2mram
    for bank in range(4):
        if int(getattr(bridge, f"mram_{bank}_{signal_name}_o").value) != 0:
            return True
    return False


async def collect_read_pipeline_cycles(dut, expected_internal_beats):
    cycle = 0
    ce_cycles = []
    dout_en_cycles = []

    while len(ce_cycles) < expected_internal_beats or len(dout_en_cycles) < expected_internal_beats:
        await RisingEdge(dut.clk)
        cycle += 1

        if any_bank_signal(dut, "ce"):
            ce_cycles.append(cycle)
        if any_bank_signal(dut, "dout_en"):
            dout_en_cycles.append(cycle)

    return ce_cycles, dout_en_cycles


def gaps(values):
    return [curr - prev for prev, curr in zip(values, values[1:])]


async def collect_per_bank_read_cycles(dut, expected_internal_beats):
    bridge = dut.axi2mram
    cycle = 0
    ce_cycles = {bank: [] for bank in range(4)}
    dout_en_cycles = {bank: [] for bank in range(4)}

    while any(len(cycles) < expected_internal_beats for cycles in ce_cycles.values()) or \
            any(len(cycles) < expected_internal_beats for cycles in dout_en_cycles.values()):
        await RisingEdge(dut.clk)
        cycle += 1

        for bank in range(4):
            if int(getattr(bridge, f"mram_{bank}_ce_o").value) != 0:
                ce_cycles[bank].append(cycle)
            if int(getattr(bridge, f"mram_{bank}_dout_en_o").value) != 0:
                dout_en_cycles[bank].append(cycle)

    return ce_cycles, dout_en_cycles


async def collect_axi_read_handshake_cycles(dut, expected_beats):
    cycle = 0
    beat_cycles = []

    while len(beat_cycles) < expected_beats:
        await RisingEdge(dut.clk)
        cycle += 1

        if int(dut.s_axi_rvalid.value) and int(dut.s_axi_rready.value):
            beat_cycles.append(cycle)

    return beat_cycles


async def collect_axi_rvalid_cycles(dut, expected_beats):
    cycle = 0
    rvalid_cycles = []

    while len(rvalid_cycles) < expected_beats:
        await RisingEdge(dut.clk)
        cycle += 1

        if int(dut.s_axi_rvalid.value):
            rvalid_cycles.append(cycle)

    return rvalid_cycles


@cocotb.test()
async def read_pipeline_cadence(dut):
    """Verify AXI rvalid stays asserted on consecutive cycles for a read burst."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(8)

    address = 0x0
    length = 256
    size = 3
    expected_beats = length >> size

    my_tb.initialize_memory_region(address, 4096, value=0)
    axi_master = my_tb.axi_master

    cadence_task = cocotb.start_soon(
        collect_axi_rvalid_cycles(my_tb.dut, expected_beats)
    )

    read_op = axi_master.init_read(address, length, size=size)
    await cocotb.triggers.with_timeout(read_op.wait(), 2000, "ns")
    rvalid_cycles = await cocotb.triggers.with_timeout(cadence_task, 200, "ns")

    rvalid_gaps = gaps(rvalid_cycles)

    assert all(gap == 1 for gap in rvalid_gaps), (
        f"AXI rvalid bubbles detected: cycles={rvalid_cycles}, gaps={rvalid_gaps}"
    )

    expected_data = my_tb.get_expected_bytes(address, length)
    assert axi_data(read_op) == expected_data


@cocotb.test()
async def axi_read_response_cadence(dut):
    """Verify AXI read beats are returned on consecutive cycles once they start."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(10)

    cases = [
        (0x0000, 64, 3),
        (0x0000, 512, 6),
    ]

    my_tb.initialize_memory_region(0, 4096, value=0)
    axi_master = my_tb.axi_master

    for address, length, size in cases:
        expected_beats = length >> size
        cadence_task = cocotb.start_soon(
            collect_axi_read_handshake_cycles(my_tb.dut, expected_beats)
        )

        read_op = axi_master.init_read(address, length, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), 2000, "ns")
        beat_cycles = await cocotb.triggers.with_timeout(cadence_task, 200, "ns")

        beat_gaps = gaps(beat_cycles)
        assert all(gap == 1 for gap in beat_gaps), (
            f"AXI read response bubbles detected for size={size}: "
            f"cycles={beat_cycles}, gaps={beat_gaps}"
        )

        expected_data = my_tb.get_expected_bytes(address, length)
        assert axi_data(read_op) == expected_data


@cocotb.test()
async def all_size_read_pipeline_cadence(dut):
    """Verify aggregate MRAM read launch and retire cadence across AXI sizes."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(11)

    my_tb.initialize_memory_region(0, 4096, value=0)
    axi_master = my_tb.axi_master

    for size in range(4, 7):
        address = 0x0
        length = 8 << size
        expected_internal_beats = 8

        cadence_task = cocotb.start_soon(
            collect_read_pipeline_cycles(my_tb.dut, expected_internal_beats)
        )

        read_op = axi_master.init_read(address, length, size=size)
        await cocotb.triggers.with_timeout(read_op.wait(), 2000, "ns")
        ce_cycles, dout_en_cycles = await cocotb.triggers.with_timeout(cadence_task, 200, "ns")

        ce_gaps = gaps(ce_cycles)
        dout_en_gaps = gaps(dout_en_cycles)

        assert all(gap == 1 for gap in ce_gaps), (
            f"MRAM CE launch bubbles detected for size={size}: "
            f"cycles={ce_cycles}, gaps={ce_gaps}"
        )
        assert all(gap == 1 for gap in dout_en_gaps), (
            f"MRAM dout_en bubbles detected for size={size}: "
            f"cycles={dout_en_cycles}, gaps={dout_en_gaps}"
        )

        expected_data = my_tb.get_expected_bytes(address, length)
        assert axi_data(read_op) == expected_data


@cocotb.test()
async def wide_read_pipeline_cadence(dut):
    """Verify that all banks can launch and retire reads on consecutive cycles."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(9)

    address = 0x0
    length = 512
    size = 6
    expected_internal_beats = 8

    my_tb.initialize_memory_region(address, 4096, value=0)
    axi_master = my_tb.axi_master

    cadence_task = cocotb.start_soon(
        collect_per_bank_read_cycles(my_tb.dut, expected_internal_beats)
    )

    read_op = axi_master.init_read(address, length, size=size)
    await cocotb.triggers.with_timeout(read_op.wait(), 2000, "ns")
    ce_cycles, dout_en_cycles = await cocotb.triggers.with_timeout(cadence_task, 200, "ns")

    for bank in range(4):
        ce_gaps = gaps(ce_cycles[bank])
        dout_en_gaps = gaps(dout_en_cycles[bank])
        assert all(gap == 1 for gap in ce_gaps), (
            f"Bank {bank} MRAM CE launch bubbles detected: cycles={ce_cycles[bank]}, gaps={ce_gaps}"
        )
        assert all(gap == 1 for gap in dout_en_gaps), (
            f"Bank {bank} MRAM dout_en bubbles detected: cycles={dout_en_cycles[bank]}, gaps={dout_en_gaps}"
        )

    expected_data = my_tb.get_expected_bytes(address, length)
    assert axi_data(read_op) == expected_data
