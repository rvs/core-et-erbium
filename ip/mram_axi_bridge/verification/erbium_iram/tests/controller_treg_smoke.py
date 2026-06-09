import cocotb
from cocotb.triggers import Timer

from tb import my_tb, sig_int


MRAM_CONTROL_REG = 0
RCA_OVR_LSB = 24
RCA_OVR_EN_BIT = 31
GBL_CFG_OVR_EN_BIT = 32
TEST_CAL_EN_BIT = 49
ANATEST0_SEL_LSB = 56
ANATEST1_SEL_LSB = 59


@cocotb.test()
async def controller_treg_smoke(dut):
    """Verify non-ET controller test registers can be driven over APB."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("controller_treg_smoke")
    await my_tb.reset_sequence()

    bank_settings = (
        {"rca_ovr": 0x15, "anatest0_sel": 0x3, "anatest1_sel": 0x5},
        {"rca_ovr": 0x2A, "anatest0_sel": 0x6, "anatest1_sel": 0x1},
    )

    active_wrappers = my_tb.num_wrappers()
    assert active_wrappers >= 1

    for bank, settings in enumerate(bank_settings[:active_wrappers]):
        reg_value = (
            (settings["rca_ovr"] << RCA_OVR_LSB)
            | (1 << RCA_OVR_EN_BIT)
            | (1 << GBL_CFG_OVR_EN_BIT)
            | (1 << TEST_CAL_EN_BIT)
            | (settings["anatest0_sel"] << ANATEST0_SEL_LSB)
            | (settings["anatest1_sel"] << ANATEST1_SEL_LSB)
        )

        apb = my_tb.apb_master(bank)
        await apb.write64(MRAM_CONTROL_REG, reg_value)
        await Timer(10, unit="ns")

        readback = await apb.read64(MRAM_CONTROL_REG)
        assert readback == reg_value

        wrapper = my_tb.get_wrapper(bank)
        ctrl_top = my_tb.get_ctrl_top(bank)

        assert sig_int(wrapper.rca_ovr) == settings["rca_ovr"]
        assert sig_int(wrapper.rca_ovr_en) == 1
        assert sig_int(wrapper.gbl_cfg_ovr_en) == 1
        assert sig_int(wrapper.test_cal_en) == 1
        assert sig_int(wrapper.anatest0_sel) == settings["anatest0_sel"]
        assert sig_int(wrapper.anatest1_sel) == settings["anatest1_sel"]

        assert sig_int(ctrl_top.treg_rca_ovr) == settings["rca_ovr"]
        assert sig_int(ctrl_top.treg_rca_ovr_en) == 1
        assert sig_int(ctrl_top.treg_gbl_cfg_ovr_en) == 1
        assert sig_int(ctrl_top.test_cal_en) == 1
