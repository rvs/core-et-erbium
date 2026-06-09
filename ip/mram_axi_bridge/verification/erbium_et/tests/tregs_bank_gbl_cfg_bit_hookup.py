import cocotb
from tb import *


@cocotb.test()
async def tregs_bank_gbl_cfg_bit_hookup(dut):
    """Per-bit hookup check for bank test-register gbl_cfg path (bank0_tregs)."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)
    bank_tregs = reg_model.bank0_tregs
    bank_wrapper = my_tb.get_bank_wrapper(0)

    # (field_name, width, flat_lsb, connected_to_treg_override_path)
    # flat bit positions map the contiguous 41-bit gbl_cfg payload.
    field_specs = [
        ("sa_equal_trim",      2,  0, True),
        ("vblslx_boost_trim",  3,  2, True),
        ("wr_en_msb_trim",     4,  5, True),
        ("wr_en_lsb_trim",     3,  9, True),
        ("vblslx_gain_mode",   1, 12, True),
        ("repulse_trim",       4, 13, True),
        ("repulse_en",         1, 17, True),
        ("rd_en_trim",         3, 18, True),
        ("osc_wr_div_trim",    4, 21, True),
        ("vblsl_trim",         4, 25, False),  # currently forced to 0 in et_ctrl_top
        ("tcsel_trim",         4, 29, True),
        ("vwlwr_trim",         4, 33, True),
        ("vcr_gate_trim",      4, 37, True),
    ]
    zero_overrides = {name: 0 for name, _, _, _ in field_specs}

    def bus_to_flat_gbl_cfg(gbl_cfg_bus_value):
        # gbl_cfg bus has holes at bit positions 21 and 42.
        return ((gbl_cfg_bus_value >> 22) << 21) | (gbl_cfg_bus_value & ((1 << 21) - 1))

    # ------------------------------------------------------------------
    # Section 1: Bank-driven mode (gbl_cfg_ovr_en=0)
    # ------------------------------------------------------------------
    await write_mram_control_fields(
        bank_tregs,
        gbl_cfg_ovr_en=0,
        test_cal_en=0,
    )
    await Timer(10, unit="ns")

    gbl_cfg_bus = sig_int(bank_wrapper.gbl_cfg)
    gbl_cfg_flat = bus_to_flat_gbl_cfg(gbl_cfg_bus)
    gbl_cfg_readback = await bank_tregs.gbl_cfg_0.read_fields()

    for field_name, width, flat_lsb, _ in field_specs:
        mask = (1 << width) - 1
        expected = (gbl_cfg_flat >> flat_lsb) & mask
        assert gbl_cfg_readback[field_name] == expected, (
            f"Bank-driven gbl_cfg_0 mismatch for {field_name}: "
            f"expected 0x{expected:x}, got 0x{gbl_cfg_readback[field_name]:x}"
        )

    # ------------------------------------------------------------------
    # Section 2: Override-driven mode (gbl_cfg_ovr_en=1), bit-walk each field
    # ------------------------------------------------------------------
    await write_mram_control_fields(
        bank_tregs,
        gbl_cfg_ovr_en=1,
        test_cal_en=0,
    )
    await bank_tregs.gbl_cfg_ovr_0.write_fields(**zero_overrides)
    await Timer(10, unit="ns")

    for field_name, width, flat_lsb, connected in field_specs:
        mask = (1 << width) - 1
        for bit_idx in range(width):
            field_value = 1 << bit_idx

            # Clear all, then toggle only one bit in one field.
            await bank_tregs.gbl_cfg_ovr_0.write_fields(**zero_overrides)
            await bank_tregs.gbl_cfg_ovr_0.write_fields(**{field_name: field_value})
            await Timer(5, unit="ns")

            gbl_cfg_bus = sig_int(bank_wrapper.gbl_cfg)
            gbl_cfg_flat = bus_to_flat_gbl_cfg(gbl_cfg_bus)
            bus_field_value = (gbl_cfg_flat >> flat_lsb) & mask
            expected = field_value if connected else 0
            assert bus_field_value == expected, (
                f"Override bus mismatch for {field_name}[{bit_idx}] "
                f"(connected={connected}): expected 0x{expected:x}, got 0x{bus_field_value:x}"
            )

            gbl_cfg_readback = await bank_tregs.gbl_cfg_0.read_fields()
            assert gbl_cfg_readback[field_name] == expected, (
                f"gbl_cfg_0 readback mismatch for {field_name}[{bit_idx}] "
                f"(connected={connected}): expected 0x{expected:x}, got 0x{gbl_cfg_readback[field_name]:x}"
            )
