import cocotb
from tb import *


@cocotb.test()
async def cpu_interrupt_lane_matrix_verification(dut):
    """Verify CPU interrupt lane behavior for 0/1/2/3-bit errors across all 4 instance pairs."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(610)

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)

    # Keep this test focused and bounded in runtime: verify all instance pairs on bank0.
    bank = 0
    regs = reg_model.bank0_tregs
    bank_wrapper = my_tb.get_bank_wrapper(bank)

    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )
    await write_mram_control_fields(
        regs,
        test_reg_ovr_en=1,
        mram_clk_en=0,
        dout_en=0,
        rst_cpu_intr=0,
    )
    await write_mram_control_fields(
        regs,
        disable_cpu_intr=0
    )

    def expected_intr_error_addr(addr, pair_idx):
        return (((addr >> 16) & 0x1) << 18) | ((pair_idx & 0x3) << 16) | (addr & 0xFFFF)

    def matrix_addr_for_pair(pair_idx):
        # Keep rr/otp-selected addresses in-range for the behavioral model:
        # when addr[16] == 1, plane_addr = 0x2000 + low_bits and must stay <= 0x20cf.
        rr_sel = pair_idx & 0x1
        if rr_sel:
            low_bits = 0x0030 + ((pair_idx >> 1) << 5)   # pair1=0x30, pair3=0x50
        else:
            low_bits = 0x0120 + ((pair_idx >> 1) << 5)   # pair0=0x120, pair2=0x140

        addr = (rr_sel << 16) | low_bits
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        assert plane_idx < MRAM_NUM_PLANES, (
            f"Matrix address generated invalid plane index: pair={pair_idx} addr=0x{addr:05x} plane={plane_idx}"
        )
        assert plane_addr <= (MRAM_WORDS_PER_PLANE - 1), (
            f"Matrix address out of modeled plane range: pair={pair_idx} addr=0x{addr:05x} "
            f"plane_addr=0x{plane_addr:x} max=0x{(MRAM_WORDS_PER_PLANE - 1):x}"
        )
        return addr

    async def write_raw_codeword(inst_idx, addr, codeword):
        # Use TREG manual override path for raw 79b writes so injection is done
        # through RTL (not by direct VPI memory poke semantics).
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        assert plane_idx < MRAM_NUM_PLANES, (
            f"write_raw_codeword invalid plane index for addr=0x{addr:05x}: plane={plane_idx}"
        )
        assert plane_addr <= (MRAM_WORDS_PER_PLANE - 1), (
            f"write_raw_codeword out-of-range addr=0x{addr:05x}: "
            f"plane_addr=0x{plane_addr:x} max=0x{(MRAM_WORDS_PER_PLANE - 1):x}"
        )
        inst_sel = 1 << inst_idx
        await write_mram_control_fields(
            regs,
            we=1,
            ce=inst_sel,
            addr_in=addr,
        )
        await write_mram_control_fields(
            regs,
            bwe=0x7FFF_FFFF_FFFF_FFFF_FFFF,
            din=codeword,
        )
        await pulse_until_idle(inst_sel)
        await write_mram_control_fields(
            regs,
            ce=0,
        )

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
            f"Timed out waiting for bank{bank} instance mask 0x{inst_sel:02x} to go idle"
        )

    async def trigger_bank_read(addr, ce_mask, dout_en_mask):
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        assert plane_idx < MRAM_NUM_PLANES, (
            f"trigger_bank_read invalid plane index for addr=0x{addr:05x}: plane={plane_idx}"
        )
        assert plane_addr <= (MRAM_WORDS_PER_PLANE - 1), (
            f"trigger_bank_read out-of-range addr=0x{addr:05x}: "
            f"plane_addr=0x{plane_addr:x} max=0x{(MRAM_WORDS_PER_PLANE - 1):x}"
        )
        await write_mram_control_fields(
            regs,
            we=0,
            ce=ce_mask,
            addr_in=addr,
        )
        await pulse_until_idle(ce_mask)
        await write_mram_control_fields(
            regs,
            ce=0,
        )
        await write_mram_control_fields(
            regs,
            dout_en=dout_en_mask
        )
        # et_cpu_intr_logic uses two stages of q-delays on address/dout_en.
        await pulse_clock(2)
        await write_mram_control_fields(
            regs,
            dout_en=0
        )
        await pulse_clock(1)

    async def read_intr_state():
        flags = await regs.mram_status_0.cpu_intr_flag.read()
        lane0_addr = await regs.mram_status_1.intr_error_lane0_addr.read()
        lane1_addr = await regs.mram_status_1.intr_error_lane1_addr.read()
        return flags, lane0_addr, lane1_addr

    async def reset_intr_latch():
        await write_mram_control_fields(
            regs,
            rst_cpu_intr=1
        )
        await pulse_clock(2)
        await write_mram_control_fields(
            regs,
            rst_cpu_intr=0
        )
        await pulse_clock(1)
        flags, lane0_addr, lane1_addr = await read_intr_state()
        assert flags == 0, f"rst_cpu_intr did not clear cpu_intr_flag (got 0b{flags:02b})"
        assert lane0_addr == 0, f"rst_cpu_intr did not clear intr_error_lane0_addr (got 0x{lane0_addr:x})"
        assert lane1_addr == 0, f"rst_cpu_intr did not clear intr_error_lane1_addr (got 0x{lane1_addr:x})"

    # Build deterministic BCH masks that classify as 0/1/2/3-bit errors.
    def build_bch_masks():
        base_payload = 0x5A1C_93E7_2046_B8D1
        base_codeword = et_bch_encode_64_to_79(base_payload)
        masks = {0: 0}
        payload_mask = (1 << 64) - 1

        def touches_payload(mask):
            return (mask & payload_mask) != 0

        # 1-bit: any single flip should classify as single-bit.
        for prefer_payload in (True, False):
            for bit in range(79):
                mask = 1 << bit
                if prefer_payload and not touches_payload(mask):
                    continue
                dec = et_bch_decode_79_to_64(base_codeword ^ mask)
                if dec.single_bit_error and not dec.double_bit_error and not dec.triple_bit_error:
                    masks[1] = mask
                    break
            if 1 in masks:
                break
        if 1 not in masks:
            raise AssertionError("Could not find a valid 1-bit BCH error mask")

        # 2-bit: find a pair that classifies as double-bit.
        for prefer_payload in (True, False):
            found_double = False
            for bit0 in range(79):
                for bit1 in range(bit0 + 1, 79):
                    mask = (1 << bit0) | (1 << bit1)
                    if prefer_payload and not touches_payload(mask):
                        continue
                    dec = et_bch_decode_79_to_64(base_codeword ^ mask)
                    if dec.double_bit_error and not dec.triple_bit_error:
                        masks[2] = mask
                        found_double = True
                        break
                if found_double:
                    break
            if found_double:
                break
        if 2 not in masks:
            raise AssertionError("Could not find a valid 2-bit BCH error mask")

        # 3-bit: random search first, then bounded exhaustive fallback.
        local_rng = random.Random(0xC0FFEE)
        for prefer_payload in (True, False):
            for _ in range(5000):
                b0, b1, b2 = local_rng.sample(range(79), 3)
                mask = (1 << b0) | (1 << b1) | (1 << b2)
                if prefer_payload and not touches_payload(mask):
                    continue
                dec = et_bch_decode_79_to_64(base_codeword ^ mask)
                if dec.triple_bit_error:
                    masks[3] = mask
                    break
            if 3 in masks:
                break

            found_triple = False
            for bit0 in range(79):
                for bit1 in range(bit0 + 1, 79):
                    for bit2 in range(bit1 + 1, 79):
                        mask = (1 << bit0) | (1 << bit1) | (1 << bit2)
                        if prefer_payload and not touches_payload(mask):
                            continue
                        dec = et_bch_decode_79_to_64(base_codeword ^ mask)
                        if dec.triple_bit_error:
                            masks[3] = mask
                            found_triple = True
                            break
                    if found_triple:
                        break
                if found_triple:
                    break
            if 3 in masks:
                break
        if 3 not in masks:
            raise AssertionError("Could not find a valid 3-bit BCH error mask")

        return masks

    bch_masks = build_bch_masks()
    def mask_bits(mask):
        return [bit for bit in range(79) if (mask >> bit) & 0x1]

    my_tb.dut._log.info(
        "CPU interrupt test BCH masks: 1b=0x%x bits=%s 2b=0x%x bits=%s 3b=0x%x bits=%s",
        bch_masks[1], mask_bits(bch_masks[1]),
        bch_masks[2], mask_bits(bch_masks[2]),
        bch_masks[3], mask_bits(bch_masks[3]),
    )

    mask_handle = my_tb._resolve_dut_path(
        f"mram_bank[{bank}].bank_wrapper_u.ecc_disable_bit"
    )
    if mask_handle is None:
        raise AttributeError("Could not resolve bank wrapper ecc_disable_bit handle for mask testing")

    force_active = False

    async def set_ecc_intr_mask(mask_bits):
        nonlocal force_active
        mask_bits &= 0x7
        try:
            from cocotb.handle import Force
            mask_handle.value = Force(mask_bits)
            force_active = True
        except Exception:
            # Fallback (if Force API is unavailable): direct drive.
            mask_handle.value = mask_bits
        await Timer(1, unit="ns")

    async def release_ecc_intr_mask():
        nonlocal force_active
        if not force_active:
            return
        try:
            from cocotb.handle import Release
            mask_handle.value = Release()
        except Exception:
            pass
        force_active = False
        await Timer(1, unit="ns")

    lane_modes = (
        ("lower_only", True,  False),
        ("upper_only", False, True ),
        ("both",       True,  True ),
    )
    error_classes = (0, 1, 2, 3)
    # (label, bitmask where 1=masked/suppressed)
    mask_cases = (
        ("no_mask",   0b000),
        ("mask_1bit", 0b001),
        ("mask_2bit", 0b010),
        ("mask_3bit", 0b100),
        ("mask_3bit_2bit", 0b110),
        ("mask_3bit_1bit", 0b101),
        ("mask_2bit_1bit", 0b011),
    )

    def error_class_is_unmasked(error_class, mask_bits):
        if error_class == 0:
            return False
        return ((mask_bits >> (error_class - 1)) & 0x1) == 0

    try:
        # ------------------------------------------------------------------
        # Matrix check: mask x lane mode x error class x 4 instance pairs.
        # ------------------------------------------------------------------
        for mask_name, mask_bits in mask_cases:
            await set_ecc_intr_mask(mask_bits)

            for pair_idx in range(4):
                even_inst = pair_idx * 2
                odd_inst  = pair_idx * 2 + 1
                even_sel  = 1 << even_inst
                odd_sel   = 1 << odd_inst

                # Toggle bit[16] across pairs while keeping modeled plane_addr in-range.
                addr = matrix_addr_for_pair(pair_idx)
                expected_addr = expected_intr_error_addr(addr, pair_idx)

                for error_class in error_classes:
                    for mode_name, lower_active, upper_active in lane_modes:
                        await reset_intr_latch()

                        lower_payload = 0x1100_0000_0000_0000 | (pair_idx << 8) | error_class
                        upper_payload = 0x2200_0000_0000_0000 | (pair_idx << 8) | error_class
                        lower_codeword = et_bch_encode_64_to_79(lower_payload)
                        upper_codeword = et_bch_encode_64_to_79(upper_payload)

                        if lower_active:
                            lower_codeword ^= bch_masks[error_class]
                        if upper_active:
                            upper_codeword ^= bch_masks[error_class]

                        lower_decode = et_bch_decode_79_to_64(lower_codeword)
                        upper_decode = et_bch_decode_79_to_64(upper_codeword)
                        lower_uncorrected_word = lower_codeword & 0xFFFF_FFFF_FFFF_FFFF
                        upper_uncorrected_word = upper_codeword & 0xFFFF_FFFF_FFFF_FFFF
                        lower_corrected_word = lower_decode.corrected_data_64
                        upper_corrected_word = upper_decode.corrected_data_64
                        # Decoder result exposes corrected 78b BCH codeword (without overall parity bit).
                        # Reconstruct corrected 79b codeword for direct comparison with DUT/waveform values.
                        lower_corrected_cw79 = lower_decode.corrected_codeword_78 | (
                            ((lower_decode.corrected_codeword_78.bit_count() & 0x1) << 78)
                        )
                        upper_corrected_cw79 = upper_decode.corrected_codeword_78 | (
                            ((upper_decode.corrected_codeword_78.bit_count() & 0x1) << 78)
                        )

                        my_tb.dut._log.info(
                            "CPU intr matrix case: mask=%s(0b%s) pair=%d mode=%s error_class=%d lower=%d upper=%d \n"
                            "lower_cw_uncorr=0x%020x lower_cw_corr79=0x%020x lower_cw_corr78=0x%020x \n"
                            "upper_cw_uncorr=0x%020x upper_cw_corr79=0x%020x upper_cw_corr78=0x%020x \n"
                            "lower_word_corr=0x%016x lower_word_uncorr=0x%016x \n"
                            "upper_word_corr=0x%016x upper_word_uncorr=0x%016x",
                            mask_name,
                            format(mask_bits, "03b"),
                            pair_idx,
                            mode_name,
                            error_class,
                            1 if lower_active else 0,
                            1 if upper_active else 0,
                            lower_codeword,
                            lower_corrected_cw79,
                            lower_decode.corrected_codeword_78,
                            upper_codeword,
                            upper_corrected_cw79,
                            upper_decode.corrected_codeword_78,
                            lower_corrected_word,
                            lower_uncorrected_word,
                            upper_corrected_word,
                            upper_uncorrected_word,
                        )

                        await write_raw_codeword(even_inst, addr, lower_codeword)
                        await write_raw_codeword(odd_inst, addr, upper_codeword)

                        dout_en_mask = (even_sel if lower_active else 0) | (odd_sel if upper_active else 0)
                        ce_mask = dout_en_mask
                        await trigger_bank_read(addr, ce_mask, dout_en_mask)

                        flags, lane0_addr, lane1_addr = await read_intr_state()
                        should_interrupt = error_class_is_unmasked(error_class, mask_bits)

                        if should_interrupt:
                            expected_flags = (1 if lower_active else 0) | (2 if upper_active else 0)
                            assert flags == expected_flags, (
                                f"cpu_intr_flag mismatch for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                f"error_class={error_class}: expected 0b{expected_flags:02b}, got 0b{flags:02b}"
                            )
                            if lower_active:
                                assert lane0_addr == expected_addr, (
                                    f"intr_error_lane0_addr mismatch for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                    f"error_class={error_class}: expected 0x{expected_addr:x}, got 0x{lane0_addr:x}"
                                )
                            else:
                                assert lane0_addr == 0, (
                                    f"intr_error_lane0_addr should stay 0 when lower lane is inactive "
                                    f"(mask={mask_name} pair={pair_idx} mode={mode_name} error_class={error_class}), got 0x{lane0_addr:x}"
                                )
                            if upper_active:
                                assert lane1_addr == expected_addr, (
                                    f"intr_error_lane1_addr mismatch for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                    f"error_class={error_class}: expected 0x{expected_addr:x}, got 0x{lane1_addr:x}"
                                )
                            else:
                                assert lane1_addr == 0, (
                                    f"intr_error_lane1_addr should stay 0 when upper lane is inactive "
                                    f"(mask={mask_name} pair={pair_idx} mode={mode_name} error_class={error_class}), got 0x{lane1_addr:x}"
                                )
                        else:
                            assert flags == 0, (
                                f"cpu_intr_flag should be 0 for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                f"error_class={error_class}, got 0b{flags:02b}"
                            )
                            assert lane0_addr == 0, (
                                f"intr_error_lane0_addr should be 0 for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                f"error_class={error_class}, got 0x{lane0_addr:x}"
                            )
                            assert lane1_addr == 0, (
                                f"intr_error_lane1_addr should be 0 for mask={mask_name} pair={pair_idx} mode={mode_name} "
                                f"error_class={error_class}, got 0x{lane1_addr:x}"
                            )

                        # Bank wrapper output should always be the OR of the lane flags.
                        expected_cpu_intr = 1 if flags != 0 else 0
                        assert sig_int(bank_wrapper.cpu_intr) == expected_cpu_intr, (
                            f"bank_wrapper.cpu_intr mismatch for mask={mask_name} pair={pair_idx} mode={mode_name} "
                            f"error_class={error_class}: expected {expected_cpu_intr}, got {sig_int(bank_wrapper.cpu_intr)}"
                        )

        # ------------------------------------------------------------------
        # Latch behavior check: hold first error address until manual reset.
        # Keep all masks disabled so the error is visible.
        # ------------------------------------------------------------------
        await set_ecc_intr_mask(0)
        await reset_intr_latch()

        pair_idx = 0
        even_inst = 0
        even_sel = 1 << even_inst
        odd_inst = 1
        odd_sel = 1 << odd_inst

        addr_first  = 0x0030
        addr_second = 0x01F0
        expected_first = expected_intr_error_addr(addr_first, pair_idx)

        first_codeword = et_bch_encode_64_to_79(0x1234_5678_9ABC_DEF0) ^ bch_masks[2]
        second_codeword = et_bch_encode_64_to_79(0x0FED_CBA9_8765_4321) ^ bch_masks[3]
        clean_codeword = et_bch_encode_64_to_79(0xAAAA_BBBB_CCCC_DDDD)
        clean_codeword_odd = et_bch_encode_64_to_79(0x1111_2222_3333_4444)

        # First error establishes the latch.
        await write_raw_codeword(even_inst, addr_first, first_codeword)
        await write_raw_codeword(odd_inst, addr_first, clean_codeword_odd)
        await trigger_bank_read(addr_first, even_sel, even_sel)
        flags, lane0_addr, lane1_addr = await read_intr_state()
        assert flags == 0b01, f"Expected lane0 interrupt after first error, got flags=0b{flags:02b}"
        assert lane0_addr == expected_first, (
            f"First-error latch mismatch: expected 0x{expected_first:x}, got 0x{lane0_addr:x}"
        )
        assert lane1_addr == 0, f"lane1 should remain 0, got 0x{lane1_addr:x}"

        # Second error at a different address should NOT overwrite first-error latch.
        await write_raw_codeword(even_inst, addr_second, second_codeword)
        await write_raw_codeword(odd_inst, addr_second, clean_codeword_odd)
        await trigger_bank_read(addr_second, even_sel, even_sel)
        flags, lane0_addr, lane1_addr = await read_intr_state()
        assert flags == 0b01, f"Expected lane0 interrupt to remain asserted, got flags=0b{flags:02b}"
        assert lane0_addr == expected_first, (
            "First-error latch was overwritten before rst_cpu_intr: "
            f"expected 0x{expected_first:x}, got 0x{lane0_addr:x}"
        )

        # A clean read should also leave the latched first-error address intact.
        await write_raw_codeword(even_inst, addr_second, clean_codeword)
        await write_raw_codeword(odd_inst, addr_second, clean_codeword_odd)
        await trigger_bank_read(addr_second, even_sel, even_sel)
        flags, lane0_addr, _ = await read_intr_state()
        assert flags == 0b01, f"Expected lane0 interrupt to stay asserted until reset, got flags=0b{flags:02b}"
        assert lane0_addr == expected_first, (
            "First-error latch changed after clean read before rst_cpu_intr: "
            f"expected 0x{expected_first:x}, got 0x{lane0_addr:x}"
        )

        # Manual reset should clear both lane flags and error addresses.
        await reset_intr_latch()
    finally:
        await release_ecc_intr_mask()
