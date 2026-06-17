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
async def generated_controller_treg_smoke(dut):
    """Use the generated async register model to verify controller test-register wiring."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)
    bank_wrapper = my_tb.get_bank_wrapper(0)
    ctrl_top = my_tb.get_controller_top(0)

    await write_mram_control_fields(
        reg_model.bank0_tregs,
        rca_ovr=0x55,
        gbl_cfg_ovr_en=1,
        test_cal_en=1,
        anatest0_sel=0x5,
        anatest1_sel=0x2,
    )
    await Timer(10, unit="ns")

    mram_control_fields = await reg_model.bank0_tregs.mram_control.read_fields()
    assert mram_control_fields["rca_ovr"] == 0x55
    assert mram_control_fields["gbl_cfg_ovr_en"] == 1
    assert mram_control_fields["test_cal_en"] == 1
    assert mram_control_fields["anatest0_sel"] == 0x5
    assert mram_control_fields["anatest1_sel"] == 0x2

    assert sig_int(bank_wrapper.rca_ovr) == 0x55
    assert sig_int(bank_wrapper.gbl_cfg_ovr_en) == 1
    assert sig_int(bank_wrapper.test_cal_en) == 1
    assert sig_int(bank_wrapper.anatest0_sel) == 0x5
    assert sig_int(bank_wrapper.anatest1_sel) == 0x2
    assert sig_int(ctrl_top.treg_rca_ovr) == 0x55
    assert sig_int(ctrl_top.treg_gbl_cfg_ovr_en) == 1
    assert sig_int(ctrl_top.test_cal_en) == 1

    await reg_model.bank0_tregs.gbl_cfg_ovr_0.write_fields(
        osc_wr_div_trim=0xA,
        tcsel_trim=0x5,
        vwlwr_trim=0xC,
        vcr_gate_trim=0x3,
    )
    await Timer(10, unit="ns")

    gbl_cfg_fields = await reg_model.bank0_tregs.gbl_cfg_ovr_0.read_fields()
    assert gbl_cfg_fields["osc_wr_div_trim"] == 0xA
    assert gbl_cfg_fields["tcsel_trim"] == 0x5
    assert gbl_cfg_fields["vwlwr_trim"] == 0xC
    assert gbl_cfg_fields["vcr_gate_trim"] == 0x3

    assert sig_int(ctrl_top.osc_wr_div_trim) == 0xA
    assert sig_int(ctrl_top.tcsel_trm) == 0x5
    assert sig_int(ctrl_top.vwlwr_trm) == 0xC
    assert sig_int(ctrl_top.vcr_gate_trm) == 0x3
