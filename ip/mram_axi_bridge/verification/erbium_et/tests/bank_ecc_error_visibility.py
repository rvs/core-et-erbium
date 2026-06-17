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
async def bank_ecc_error_visibility(dut):
    """Write/read a contiguous 4KB region across all 4 banks and check ECC visibility.

    Requirements covered:
    - AXI writes a single 4KB region.
    - Inject 40 random word errors (1b/2b/3b mix) spread across the same 4KB.
    - Read back using exactly two AXI bursts:
      - each burst is 256 beats of 8B (size=3, len=256 beats => arlen=255)
      - total 4096B.
    - Verify:
      - 1b/2b corrupted words read back corrected (same as original).
      - 3b corrupted words read back different from original.
    """
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(620)
    rng = random.Random(620)

    axi_master = my_tb.axi_master
    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)

    def bank_tregs(bank):
        return getattr(reg_model, f"bank{bank}_tregs")

    async def read_bridge_ecc_counters():
        c1 = await reg_model.bridge_regs.ecc_1bit_error_count_reg.count.read()
        c2 = await reg_model.bridge_regs.ecc_2bit_error_count_reg.count.read()
        c3 = await reg_model.bridge_regs.ecc_3bit_error_count_reg.count.read()
        return int(c1), int(c2), int(c3)

    # Keep bridge clocks ungated and deterministic.
    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )

    # One contiguous 4KB section across all banks.
    start_addr = 0x0000
    total_bytes = 4096
    burst_bytes = 2048
    burst_count = 2
    bytes_per_word = 8
    size_8b = 3
    assert burst_bytes // (1 << size_8b) == 256

    # Clean golden payload per AXI address.
    golden_payload_64 = {}
    word_addrs = list(range(start_addr, start_addr + total_bytes, bytes_per_word))
    assert len(word_addrs) == (total_bytes // bytes_per_word)

    initial_bytes = bytes(rand_bytes(total_bytes))
    for word_idx, addr in enumerate(word_addrs):
        lo = word_idx * bytes_per_word
        hi = lo + bytes_per_word
        golden_payload_64[addr] = int.from_bytes(initial_bytes[lo:hi], "little")

    my_tb.dut._log.info(
        "Writing 4KB as two AXI bursts (2048B each, size=8B beats) across all banks"
    )
    for burst_idx in range(burst_count):
        addr = start_addr + (burst_idx * burst_bytes)
        lo = burst_idx * burst_bytes
        hi = lo + burst_bytes
        burst_data = initial_bytes[lo:hi]
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, burst_data, size=size_8b),
            8000,
            "ns",
        )

    # Helpers for manual mram_control error injection.
    full_bwe_79 = (1 << 79) - 1

    async def pulse_clock(bank, count=1):
        regs = bank_tregs(bank)
        for _ in range(count):
            await write_mram_control_fields(regs, mram_clk_single_pulse=1)

    async def pulse_until_idle(bank, inst_sel, max_pulses=64):
        regs = bank_tregs(bank)
        for _ in range(max_pulses):
            await pulse_clock(bank, 1)
            busy = await regs.mram_status_1.busy.read()
            if (busy & inst_sel) == 0:
                return
        raise AssertionError(
            f"Timed out waiting for bank={bank} inst_sel=0x{inst_sel:02x} to go idle"
        )

    async def write_raw_codeword(bank, inst_idx, mram_addr, codeword79):
        regs = bank_tregs(bank)
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
        await pulse_until_idle(bank, inst_sel)
        await write_mram_control_fields(
            regs,
            we=0,
            ce=0,
        )

    async def read_raw_codeword(bank, inst_idx, mram_addr):
        regs = bank_tregs(bank)
        inst_sel = 1 << inst_idx
        await write_mram_control_fields(
            regs,
            we=0,
            ce=inst_sel,
            addr_in=mram_addr,
        )
        await pulse_until_idle(bank, inst_sel)
        await write_mram_control_fields(
            regs,
            we=0,
            ce=0,
        )
        await write_mram_control_fields(
            regs,
            dout_en=inst_sel,
        )
        await pulse_clock(bank, count=2)

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

    def axi_addr_to_inst_and_mram_word(addr):
        bank_idx, instance_pair, mram_addr, byte_offset = my_tb.axi_addr_to_mram_location(addr)
        if byte_offset < 8:
            inst_idx = instance_pair * 2
        else:
            inst_idx = instance_pair * 2 + 1
        return bank_idx, inst_idx, mram_addr

    def classify_masks():
        """Return one working 1b mask, one 2b mask, and a pool of 3b masks."""
        base_payload = 0x4B1D_2C3E_5A79_8F06
        base_codeword = et_bch_encode_64_to_79(base_payload)

        one_bit_mask = None
        for bit in range(79):
            mask = 1 << bit
            dec = et_bch_decode_79_to_64(base_codeword ^ mask)
            if dec.single_bit_error and not dec.double_bit_error and not dec.triple_bit_error:
                one_bit_mask = mask
                break
        if one_bit_mask is None:
            raise AssertionError("Failed to find a valid 1-bit BCH mask")

        two_bit_mask = None
        for b0 in range(79):
            for b1 in range(b0 + 1, 79):
                mask = (1 << b0) | (1 << b1)
                dec = et_bch_decode_79_to_64(base_codeword ^ mask)
                if dec.double_bit_error and not dec.triple_bit_error:
                    two_bit_mask = mask
                    break
            if two_bit_mask is not None:
                break
        if two_bit_mask is None:
            raise AssertionError("Failed to find a valid 2-bit BCH mask")

        triple_masks = []
        local_rng = random.Random(0xECCE620)
        attempts = 0
        # Build a pool of diverse triple-error masks to choose per word.
        while len(triple_masks) < 32 and attempts < 20000:
            b0, b1, b2 = local_rng.sample(range(79), 3)
            mask = (1 << b0) | (1 << b1) | (1 << b2)
            if mask in triple_masks:
                attempts += 1
                continue
            dec = et_bch_decode_79_to_64(base_codeword ^ mask)
            if dec.triple_bit_error:
                triple_masks.append(mask)
            attempts += 1

        if not triple_masks:
            raise AssertionError("Failed to find any valid 3-bit BCH masks")

        return one_bit_mask, two_bit_mask, triple_masks

    one_bit_mask, two_bit_mask, triple_masks = classify_masks()
    my_tb.dut._log.info(
        "Using BCH masks: 1b=0x%x 2b=0x%x triple_pool=%d",
        one_bit_mask,
        two_bit_mask,
        len(triple_masks),
    )

    # Enter manual mode on all banks (injected words map across bank interleave).
    for bank in range(4):
        await write_mram_control_fields(
            bank_tregs(bank),
            test_reg_ovr_en=1,
            mram_clk_en=0,
            dout_en=0,
            we=0,
            ce=0,
        )

    # Tracks per-address injected class (0=clean,1/2/3=corrupted class).
    error_class_by_addr = {}
    c1 = 0
    c2 = 0
    c3 = 0

    try:
        # Random class composition for 40 injected words.
        c1 = rng.randrange(0, 41)
        c2 = rng.randrange(0, 41 - c1)
        c3 = 40 - c1 - c2
        classes = ([1] * c1) + ([2] * c2) + ([3] * c3)
        rng.shuffle(classes)

        # Spread injections across both 2KB bursts: 20 in first + 20 in second.
        first_half = [a for a in word_addrs if a < (start_addr + burst_bytes)]
        second_half = [a for a in word_addrs if a >= (start_addr + burst_bytes)]
        rng.shuffle(first_half)
        rng.shuffle(second_half)
        selected_addrs = first_half[:20] + second_half[:20]
        rng.shuffle(selected_addrs)

        my_tb.dut._log.info(
            "4KB error injection counts: 1b=%d 2b=%d 3b=%d",
            c1, c2, c3
        )

        for addr, err_class in zip(selected_addrs, classes):
            bank_idx, inst_idx, mram_addr = axi_addr_to_inst_and_mram_word(addr)

            payload = golden_payload_64[addr]
            codeword = await read_raw_codeword(bank_idx, inst_idx, mram_addr)
            pre_dec = et_bch_decode_79_to_64(codeword)
            assert pre_dec.corrected_data_64 == payload, (
                f"Pre-injection raw read mismatch at bank={bank_idx} addr=0x{addr:08x}: "
                f"expected payload 0x{payload:016x}, got corrected 0x{pre_dec.corrected_data_64:016x}"
            )

            if err_class == 1:
                mask = one_bit_mask
            elif err_class == 2:
                mask = two_bit_mask
            else:
                # Pick a 3-bit mask that produces data different from original.
                mask = None
                for candidate in triple_masks:
                    dec = et_bch_decode_79_to_64(codeword ^ candidate)
                    if dec.triple_bit_error and (dec.corrected_data_64 != payload):
                        mask = candidate
                        break
                if mask is None:
                    raise AssertionError(
                        f"Could not find a visible 3-bit corruption mask for payload 0x{payload:016x}"
                    )

            corrupted = codeword ^ mask
            dec = et_bch_decode_79_to_64(corrupted)

            if err_class in (1, 2):
                assert dec.corrected_data_64 == payload, (
                    f"{err_class}-bit corruption unexpectedly changed corrected payload "
                    f"for bank={bank_idx} addr=0x{addr:08x}"
                )
            else:
                assert dec.corrected_data_64 != payload, (
                    f"3-bit corruption did not change corrected payload for bank={bank_idx} addr=0x{addr:08x}"
                )

            await write_raw_codeword(bank_idx, inst_idx, mram_addr, corrupted)
            error_class_by_addr[addr] = err_class
    finally:
        # Return all banks to normal AXI-controlled mode.
        for bank in range(4):
            await write_mram_control_fields(
                bank_tregs(bank),
                test_reg_ovr_en=0,
                mram_clk_en=1,
                dout_en=0,
                we=0,
                ce=0,
            )

    counter_before_readback = await read_bridge_ecc_counters()

    # Read back 4KB using exactly two 2KB bursts.
    my_tb.dut._log.info(
        "Reading back 4KB as two AXI bursts (2048B each, size=8B beats) across all banks"
    )
    def burst_has_triple_error(addr, length_bytes):
        for probe_addr in range(addr, addr + length_bytes, bytes_per_word):
            if error_class_by_addr.get(probe_addr, 0) == 3:
                return True
        return False

    readback = bytearray()
    for burst_idx in range(burst_count):
        addr = start_addr + (burst_idx * burst_bytes)
        read_op = axi_master.init_read(addr, burst_bytes, size=size_8b)
        await cocotb.triggers.with_timeout(read_op.wait(), 8000, "ns")
        resp_val = int(axi_resp(read_op))
        has_triple = burst_has_triple_error(addr, burst_bytes)
        if has_triple:
            assert resp_val in (int(AxiResp.OKAY), int(AxiResp.SLVERR)), (
                f"AXI burst read returned unexpected resp at addr=0x{addr:08x}: "
                f"resp={axi_resp(read_op)} (expected OKAY or SLVERR due to 3-bit injection)"
            )
            if resp_val == int(AxiResp.SLVERR):
                my_tb.dut._log.info(
                    "Observed expected SLVERR on burst addr=0x%08x with injected 3-bit errors",
                    addr,
                )
        else:
            assert resp_val == int(AxiResp.OKAY), (
                f"AXI burst read failed at addr=0x{addr:08x}, resp={axi_resp(read_op)}"
            )
        readback.extend(bytes(axi_data(read_op)))

    assert len(readback) == total_bytes

    for word_idx, addr in enumerate(word_addrs):
        lo = word_idx * bytes_per_word
        hi = lo + bytes_per_word
        actual = int.from_bytes(readback[lo:hi], "little")
        expected_clean = golden_payload_64[addr]
        err_class = error_class_by_addr.get(addr, 0)

        if err_class in (0, 1, 2):
            assert actual == expected_clean, (
                f"Unexpected visible error at addr=0x{addr:08x} class={err_class}: "
                f"expected 0x{expected_clean:016x}, got 0x{actual:016x}"
            )
        else:
            assert actual != expected_clean, (
                f"3-bit corruption did not surface at addr=0x{addr:08x}: "
                f"value stayed 0x{actual:016x}"
            )

    counter_after_readback = await read_bridge_ecc_counters()
    delta_counters = (
        counter_after_readback[0] - counter_before_readback[0],
        counter_after_readback[1] - counter_before_readback[1],
        counter_after_readback[2] - counter_before_readback[2],
    )
    assert delta_counters == (c1, c2, c3), (
        "ECC counter accumulation mismatch: "
        f"expected delta (1b,2b,3b)=({c1},{c2},{c3}), "
        f"got {delta_counters} "
        f"(before={counter_before_readback}, after={counter_after_readback})"
    )

    my_tb.dut._log.info("bank_ecc_error_visibility passed")
    await Timer(100, unit="ns")
