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
async def test_reg_manual_controls_otp_columns(dut):
    """Manual-controls OTP sanity: write/read all valid OTP columns on bank0."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(501)
    rng = random.Random(501)

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)
    regs = reg_model.bank0_tregs
    full_bwe = (1 << 79) - 1

    def otp_word_addr(block, plane, col):
        return (
            (1 << 16)
            | ((block & 0x3) << 14)
            | ((plane & 0x1) << 13)
            | (OTP_FIXED_ROW << 4)
            | (col & 0xF)
        )

    def read_word_direct(inst, addr):
        my_tb.warn_direct_mram_access(
            "read",
            "test_reg_manual_controls_otp_columns direct hierarchy OTP readback checks",
            tag="test_reg_manual_controls_otp_columns.direct_readback",
        )
        instance = my_tb.get_mram_instance(0, inst)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        return int(my_tb._memory_word_handle(instance, plane_idx, plane_addr).value)

    async def pulse_clock(count=1):
        for _ in range(count):
            await write_mram_control_fields(regs, mram_clk_single_pulse=1)

    async def pulse_until_idle(inst_sel, max_pulses=32):
        for _ in range(max_pulses):
            await pulse_clock(1)
            busy = await regs.mram_status_1.busy.read()
            if (busy & inst_sel) == 0:
                return
        raise AssertionError(
            f"Timed out waiting for instance select 0x{inst_sel:02x} to go idle"
        )

    async def write_word(inst, addr, bwe, data):
        inst_sel = 1 << inst
        await write_mram_control_fields(
            regs,
            we=1,
            ce=inst_sel,
            addr_in=addr,
        )
        await write_mram_control_fields(
            regs,
            bwe=bwe & ((1 << 79) - 1),
            din=data & ((1 << 79) - 1),
        )
        await pulse_until_idle(inst_sel)
        await write_mram_control_fields(
            regs,
            ce=0,
        )

    async def read_word(inst, addr):
        inst_sel = 1 << inst
        await write_mram_control_fields(
            regs,
            we=0,
            ce=inst_sel,
            addr_in=addr,
        )
        await pulse_until_idle(inst_sel)
        await write_mram_control_fields(
            regs,
            we=0,
            ce=0,
        )
        await write_mram_control_fields(
            regs,
            dout_en=inst_sel
        )
        await pulse_clock(2)
        if inst % 2 == 0:
            dout = await regs.mram_dout_even_lower.dout.read()
            dout_upper = await regs.mram_dout_uppers.dout_even_msb.read()
        else:
            dout = await regs.mram_dout_odd_lower.dout.read()
            dout_upper = await regs.mram_dout_uppers.dout_odd_msb.read()
        await write_mram_control_fields(
            regs,
            dout_en=0
        )
        return (dout_upper << 64) | dout

    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )
    await write_mram_control_fields(
        regs,
        test_reg_ovr_en=1,
        mram_clk_en=0,
        dout_en=0,
        otp_wr_en=1,
    )

    transactions = []
    for inst in range(8):
        for block in range(4):
            for plane in range(2):
                for col in OTP_VALID_COLS:
                    addr = otp_word_addr(block, plane, col)
                    transactions.append(
                        {
                            "inst": inst,
                            "block": block,
                            "plane": plane,
                            "col": col,
                            "addr": addr,
                            "data": rng.getrandbits(79),
                        }
                    )

    for txn in transactions:
        await write_word(txn["inst"], txn["addr"], full_bwe, txn["data"])
        direct_word = read_word_direct(txn["inst"], txn["addr"])
        assert direct_word == txn["data"], (
            "OTP hierarchy write mismatch: "
            f"inst={txn['inst']} block={txn['block']} plane={txn['plane']} col={txn['col']} "
            f"addr=0x{txn['addr']:05x} expected=0x{txn['data']:020x} got=0x{direct_word:020x}"
        )

    rng.shuffle(transactions)
    for txn in transactions:
        readout = await read_word(txn["inst"], txn["addr"])
        direct_word = read_word_direct(txn["inst"], txn["addr"])
        assert direct_word == txn["data"], (
            "OTP hierarchy readback mismatch: "
            f"inst={txn['inst']} block={txn['block']} plane={txn['plane']} col={txn['col']} "
            f"addr=0x{txn['addr']:05x} expected=0x{txn['data']:020x} got=0x{direct_word:020x}"
        )
        assert readout == txn["data"], (
            "OTP manual register read mismatch: "
            f"inst={txn['inst']} block={txn['block']} plane={txn['plane']} col={txn['col']} "
            f"addr=0x{txn['addr']:05x} expected=0x{txn['data']:020x} got=0x{readout:020x}"
        )

    await Timer(100, unit="ns")
