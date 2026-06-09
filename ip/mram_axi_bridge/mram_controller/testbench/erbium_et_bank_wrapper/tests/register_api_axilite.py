import cocotb
from cocotb.triggers import RisingEdge

from tb import WrapperTB


def _resolve_path(root, path):
    obj = root
    for part in path.split("."):
        obj = getattr(obj, part)
    return obj


def _pattern_values(width):
    mask = (1 << width) - 1
    if width <= 1:
        return [0, 1]

    alt_a = 0
    alt_b = 0
    for bit in range(width):
        if bit % 2:
            alt_a |= 1 << bit
        else:
            alt_b |= 1 << bit

    candidates = [0, mask, alt_a & mask, alt_b & mask, (1 << (width - 1)) & mask]

    seen = set()
    values = []
    for value in candidates:
        value &= mask
        if value not in seen:
            seen.add(value)
            values.append(value)
    return values


def _append_mismatch(mismatches, name, expected, actual):
    mismatches.append(f"{name}: expected 0x{expected:x}, got {actual}")


def _format_mismatch_report(mismatches, limit=40):
    report = "\n".join(mismatches[:limit])
    extra = len(mismatches) - limit
    if extra > 0:
        report += f"\n... and {extra} more mismatches"
    return report


@cocotb.test()
async def register_api_axilite_field_rw(top):
    tb = WrapperTB(top)
    await tb.reset()

    block = tb.regs.block_tregs
    readback_mismatches = []
    probe_mismatches = []

    # Writable fields that are expected to reach erbium_et_bank controls.
    scalar_specs = [
        ("mram_control_0.rd_pulse_meas_en", "bank_u.rd_pulse_meas_en", 1),
        ("mram_control_0.rca_ovr", "bank_u.rca_ovr", 7),
        ("mram_control_0.rca_ovr_en", "bank_u.rca_ovr_en", 1),
        ("mram_control_0.gbl_cfg_ovr_en", "bank_u.gbl_cfg_ovr_en", 1),
        ("mram_control_0.rd_en_ovr", "bank_u.rd_en_ovr", 1),
        ("mram_control_0.ref_prg_en", "bank_u.ref_prg_en", 1),
        ("mram_control_0.reg_logic_sup_sleep_ovr", "bank_u.reg_logic_sup_sleep", 1),
        ("mram_control_0.prg_rd1_byp", "bank_u.prg_rd1_byp", 1),
        ("mram_control_0.wr_en_ovr", "bank_u.wr_en_ovr", 1),
        ("mram_control_0.dma_en", "bank_u.dma_en", 1),
        ("mram_control_0.vblslx_gain_mode_ovr", "bank_u.vblslx_gain_mode_ovr", 1),
        ("mram_control_0.test_cal_en", "bank_u.test_cal_en", 1),
        ("mram_control_0.anatest0_sel", "bank_u.anatest0_sel", 3),
        ("mram_control_0.anatest1_sel", "bank_u.anatest1_sel", 3),
        ("mram_control_2.otp_wr_en", "bank_u.otp_wr_en", 1),
        ("mram_control_4.even_man_stripe_sel", "bank_u.even_man_stripe_sel", 4),
        ("mram_control_4.odd_man_stripe_sel", "bank_u.odd_man_stripe_sel", 4),
        ("mram_control_4.sah_en", "bank_u.sah_en", 1),
        ("mram_control_4.scc_otp_en", "bank_u.scc_otp_en", 1),
    ]

    for field_path, probe_path, width in scalar_specs:
        field = _resolve_path(block, field_path)
        probe = _resolve_path(tb.dut, probe_path)
        mask = (1 << width) - 1

        for value in _pattern_values(width):
            expected = value & mask
            await field.write(expected)
            readback = int(await field.read()) & mask
            if readback != expected:
                _append_mismatch(readback_mismatches, f"readback {field_path}", expected, f"0x{readback:x}")

            await RisingEdge(tb.top.clk)
            probe_val = probe.value
            if not probe_val.is_resolvable:
                _append_mismatch(probe_mismatches, f"probe {probe_path}", expected, str(probe_val))
                continue

            probed = int(probe_val) & mask
            if probed != expected:
                _append_mismatch(probe_mismatches, f"probe {probe_path}", expected, f"0x{probed:x}")

    # Vector controls represented by multiple single-bit fields in the reg model.
    vector_bit_specs = [
        ("mram_control_4", "even_man_wr", "bank_u.even_man_wr", 4),
        ("mram_control_4", "odd_man_wr", "bank_u.odd_man_wr", 4),
    ]

    for reg_path, bit_prefix, probe_path, width in vector_bit_specs:
        reg = _resolve_path(block, reg_path)
        probe = _resolve_path(tb.dut, probe_path)
        mask = (1 << width) - 1

        for value in _pattern_values(width):
            expected = value & mask
            for bit in range(width):
                bit_field = getattr(reg, f"{bit_prefix}_{bit}")
                bit_value = (expected >> bit) & 1
                await bit_field.write(bit_value)
                bit_readback = int(await bit_field.read()) & 1
                if bit_readback != bit_value:
                    _append_mismatch(
                        readback_mismatches,
                        f"readback {reg_path}.{bit_prefix}_{bit}",
                        bit_value,
                        f"0x{bit_readback:x}",
                    )

            await RisingEdge(tb.top.clk)
            probe_val = probe.value
            if not probe_val.is_resolvable:
                _append_mismatch(probe_mismatches, f"probe {probe_path}", expected, str(probe_val))
                continue

            probed = int(probe_val) & mask
            if probed != expected:
                _append_mismatch(probe_mismatches, f"probe {probe_path}", expected, f"0x{probed:x}")

    if readback_mismatches or probe_mismatches:
        sections = []
        if readback_mismatches:
            sections.append("Readback mismatches:\n" + _format_mismatch_report(readback_mismatches))
        if probe_mismatches:
            sections.append("Probe mismatches:\n" + _format_mismatch_report(probe_mismatches))

        raise AssertionError("Register API field checks failed:\n" + "\n\n".join(sections))
