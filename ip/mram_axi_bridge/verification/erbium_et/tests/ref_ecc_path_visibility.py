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
from tb import *


def ref_hamming_encode_15_to_20(data_15):
    m = [(data_15 >> idx) & 1 for idx in range(15)]
    p0 = m[0] ^ m[1] ^ m[3] ^ m[4] ^ m[6] ^ m[8] ^ m[10] ^ m[11] ^ m[13]
    p1 = m[0] ^ m[2] ^ m[3] ^ m[5] ^ m[6] ^ m[9] ^ m[10] ^ m[12] ^ m[13]
    p2 = m[1] ^ m[2] ^ m[3] ^ m[7] ^ m[8] ^ m[9] ^ m[10] ^ m[14]
    p3 = m[4] ^ m[5] ^ m[6] ^ m[7] ^ m[8] ^ m[9] ^ m[10]
    p4 = m[11] ^ m[12] ^ m[13] ^ m[14]

    codeword = 0
    bit_map = {
        0: p0,
        1: p1,
        2: m[0],
        3: p2,
        4: m[1],
        5: m[2],
        6: m[3],
        7: p3,
        8: m[4],
        9: m[5],
        10: m[6],
        11: m[7],
        12: m[8],
        13: m[9],
        14: m[10],
        15: p4,
        16: m[11],
        17: m[12],
        18: m[13],
        19: m[14],
    }
    for bit_idx, bit_val in bit_map.items():
        codeword |= (bit_val & 1) << bit_idx
    return codeword


def ref_ecc_encode_64_to_79(data_64):
    data_64 &= (1 << 64) - 1
    encoded_word = 0
    for section_idx in range(4):
        section_data = (data_64 >> (15 * section_idx)) & ((1 << 15) - 1)
        section_codeword = ref_hamming_encode_15_to_20(section_data)
        encoded_word |= section_codeword << (20 * section_idx)

    codeword_out = 0
    codeword_out |= encoded_word & ((1 << 75) - 1)
    codeword_out |= ((encoded_word >> 76) & 0xF) << 75
    return codeword_out


@cocotb.test()
async def ref_ecc_path_visibility(dut):
    """Exercise the ET reference-ECC encode/decode path selected by ref_ecc_sel."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)
    axi_master = my_tb.axi_master
    bank = 0
    regs = reg_model.bank0_tregs
    full_bwe_79 = (1 << 79) - 1

    async def read_bridge_ecc_counters():
        c1 = await reg_model.bridge_regs.ecc_1bit_error_count_reg.count.read()
        c2 = await reg_model.bridge_regs.ecc_2bit_error_count_reg.count.read()
        c3 = await reg_model.bridge_regs.ecc_3bit_error_count_reg.count.read()
        return int(c1), int(c2), int(c3)

    async def pulse_clock(count=1):
        for _ in range(count):
            await write_mram_control_fields(regs, mram_clk_single_pulse=1)

    async def pulse_until_idle(inst_sel, max_pulses=64):
        for _ in range(max_pulses):
            await pulse_clock()
            busy = await regs.mram_status_1.busy.read()
            if (busy & inst_sel) == 0:
                return
        raise AssertionError(
            f"Timed out waiting for bank0 instance select 0x{inst_sel:02x} to go idle"
        )

    async def write_raw_codeword(inst_idx, mram_addr, codeword79):
        inst_sel = 1 << inst_idx
        await write_mram_control_fields(
            regs,
            we=1,
            ce=inst_sel,
            addr_in=mram_addr,
        )
        await write_mram_control_fields(
            regs,
            bwe=full_bwe_79,
            din=codeword79 & full_bwe_79,
        )
        await pulse_until_idle(inst_sel)
        await write_mram_control_fields(
            regs,
            we=0,
            ce=0,
        )

    async def read_raw_codeword(inst_idx, mram_addr):
        inst_sel = 1 << inst_idx
        await write_mram_control_fields(
            regs,
            we=0,
            ce=inst_sel,
            addr_in=mram_addr,
        )
        await pulse_until_idle(inst_sel)
        await write_mram_control_fields(
            regs,
            we=0,
            ce=0,
        )
        await write_mram_control_fields(
            regs,
            dout_en=inst_sel,
        )
        await pulse_clock(count=2)

        if inst_idx % 2 == 0:
            dout_lo = await regs.mram_dout_even_lower.dout.read()
            dout_hi = await regs.mram_dout_uppers.dout_even_msb.read()
        else:
            dout_lo = await regs.mram_dout_odd_lower.dout.read()
            dout_hi = await regs.mram_dout_uppers.dout_odd_msb.read()

        await write_mram_control_fields(
            regs,
            dout_en=0,
        )
        return (dout_hi << 64) | dout_lo

    async def enter_manual_mram_mode():
        await write_mram_control_fields(
            regs,
            ref_ecc_sel=1,
            ecc_bypass_en=0,
            test_reg_ovr_en=1,
            mram_clk_en=0,
            dout_en=0,
            we=0,
            ce=0,
        )

    async def exit_manual_mram_mode():
        await write_mram_control_fields(
            regs,
            ref_ecc_sel=1,
            ecc_bypass_en=0,
            test_reg_ovr_en=0,
            mram_clk_en=1,
            dout_en=0,
            we=0,
            ce=0,
        )

    def axi_addr_to_inst_and_mram_word(addr):
        bank_idx, instance_pair, mram_addr, byte_offset = my_tb.axi_addr_to_mram_location(addr)
        assert bank_idx == bank, (
            f"Test address 0x{addr:08x} mapped to bank {bank_idx}, expected bank0"
        )
        if byte_offset < 8:
            inst_idx = instance_pair * 2
        else:
            inst_idx = instance_pair * 2 + 1
        return inst_idx, mram_addr

    test_words = (
        {
            "label": "lower",
            "addr": 0x0000,
            "payload": 0x0123_4567_89AB_CDEF,
            "flip_bit": 2,
        },
        {
            "label": "upper",
            "addr": 0x0008,
            "payload": 0x0FED_CBA9_8765_4321,
            "flip_bit": 42,
        },
    )
    # Reference ECC carries four 15-bit sections, so keep payload bits [63:60] clear.

    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )
    await write_mram_control_fields(
        regs,
        ref_ecc_sel=1,
        ecc_bypass_en=0,
        test_reg_ovr_en=0,
        mram_clk_en=1,
        dout_en=0,
        we=0,
        ce=0,
    )
    await Timer(10, unit="ns")

    mram_control_fields = await regs.mram_control.read_fields()
    assert mram_control_fields["ref_ecc_sel"] == 1
    assert sig_int(my_tb.get_controller_top(bank).treg_ref_ecc_sel) == 1

    for word in test_words:
        payload_bytes = word["payload"].to_bytes(8, "little")
        write_op = axi_master.init_write(word["addr"], payload_bytes, size=3)
        await cocotb.triggers.with_timeout(write_op.wait(), 8000, "ns")
        assert int(axi_resp(write_op)) == int(AxiResp.OKAY), (
            f"{word['label']} ref-ECC AXI write failed: resp={axi_resp(write_op)}"
        )

    await enter_manual_mram_mode()
    for word in test_words:
        inst_idx, mram_addr = axi_addr_to_inst_and_mram_word(word["addr"])
        word["inst_idx"] = inst_idx
        word["mram_addr"] = mram_addr
        raw_codeword = await read_raw_codeword(inst_idx, mram_addr)
        expected_codeword = ref_ecc_encode_64_to_79(word["payload"])
        word["expected_codeword"] = expected_codeword
        assert raw_codeword == expected_codeword, (
            f"{word['label']} raw ref-ECC encode mismatch: "
            f"expected 0x{expected_codeword:020x}, got 0x{raw_codeword:020x}"
        )

    for word in test_words:
        corrupted_codeword = word["expected_codeword"] ^ (1 << word["flip_bit"])
        await write_raw_codeword(word["inst_idx"], word["mram_addr"], corrupted_codeword)

        await exit_manual_mram_mode()
        counters_before_ref_read = await read_bridge_ecc_counters()

        read_op = axi_master.init_read(word["addr"], 8, size=3)
        await cocotb.triggers.with_timeout(read_op.wait(), 8000, "ns")
        assert int(axi_resp(read_op)) == int(AxiResp.OKAY), (
            f"{word['label']} ref-ECC AXI read failed: resp={axi_resp(read_op)}"
        )
        actual = int.from_bytes(bytes(axi_data(read_op)), "little")
        assert actual == word["payload"], (
            f"{word['label']} ref-ECC repair failed: "
            f"expected 0x{word['payload']:016x}, got 0x{actual:016x}"
        )

        counters_after_ref_read = await read_bridge_ecc_counters()
        delta_counters = tuple(
            after - before
            for before, after in zip(counters_before_ref_read, counters_after_ref_read)
        )
        assert delta_counters[0] >= 1 and delta_counters[1:] == (0, 0), (
            f"{word['label']} reference-ECC counter delta mismatch: "
            f"expected at least one 1-bit event and no 2/3-bit events, got {delta_counters}"
        )
        assert int(await regs.mram_status_1.ecc_2bit.read()) == 0
        assert int(await regs.mram_status_1.ecc_3bit.read()) == 0

        await enter_manual_mram_mode()
        await write_raw_codeword(word["inst_idx"], word["mram_addr"], word["expected_codeword"])

    word = test_words[0]
    corrupted_codeword = word["expected_codeword"] ^ (1 << word["flip_bit"])
    await write_raw_codeword(word["inst_idx"], word["mram_addr"], corrupted_codeword)
    await exit_manual_mram_mode()
    await write_mram_control_fields(regs, ref_ecc_sel=0)
    read_op = axi_master.init_read(word["addr"], 8, size=3)
    await cocotb.triggers.with_timeout(read_op.wait(), 8000, "ns")
    actual = int.from_bytes(bytes(axi_data(read_op)), "little")
    assert actual != word["payload"], (
        f"{word['label']} read still matched clean payload after ref_ecc_sel=0; "
        "the test did not distinguish the reference path from BCH"
    )

    await write_mram_control_fields(regs, ref_ecc_sel=1)
    await enter_manual_mram_mode()
    await write_raw_codeword(word["inst_idx"], word["mram_addr"], word["expected_codeword"])
    await exit_manual_mram_mode()

    await Timer(100, unit="ns")
