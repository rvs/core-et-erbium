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
from cocotb.triggers import FallingEdge, NextTimeStep, ReadOnly, RisingEdge, Timer, with_timeout
from tb import *

# READ BIST USAGE GUIDE
# - Bring-up requirements:
#   - Assert `bist_rst_b=1` on every bank before using mkEtBist through the
#     test-register path.
#   - Keep bridge clock gating disabled (`disable_clock_gate=0xF`) while using
#     MRAM test registers.
#   - If a prior run latched `bist_error`, clear it before the next run with:
#       1. `bist_wr_en=0`, `bist_rd_en=0`, `bist_rte_en=0`
#       2. assert `bist_reset=1`
#       3. pulse `bist_start=1`
#       4. deassert `bist_start` and `bist_reset`
# - Programming model:
#   - Preload the target raw MRAM words before starting read BIST.
#   - Program `din` and `bwe` through `mram_control`:
#     - `din` is the 79-bit expected compare value.
#     - `bwe` masks which bits participate in compare/count logic.
#   - For read BIST, use `bist_wr_en=0`, `bist_rd_en=1`, `bist_rte_en=0`.
#   - `bist_start` is a pulse, not a level.
# - Addressing model:
#   - `bist_start_add` / `bist_stop_add` are 20-bit BIST word addresses.
#   - In this TB a raw MRAM word address maps to a BIST address as:
#     `(((raw_addr >> 16) & 0x1) << 19) | ((inst_idx & 0x7) << 16) |
#      (raw_addr & 0xFFFF)`.
#   - `bist_add_inc` is a power-of-two step: `1 << bist_add_inc`.
# - Data pattern model:
#   - Intended `bist_data_inv` compare behavior is loop-based:
#     - even loops compare against plain `din`
#     - odd loops compare against `~din`
#   - Because read BIST is non-destructive, later-loop `data_inv` tests in this
#     file rewrite the backing memory between loops so only the targeted loop
#     fails.
#   - In BIST mode, OTP rows are treated as fully readable across all 16
#     columns.
# - `bist_stop_on_error` behavior:
#   - On the first mismatching read, `bist_error` latches, `bist_err_add`
#     records the failing BIST address, `bist_error_loop` records the loop, and
#     `bist_error_value` captures the 79-bit readback value.
#   - Read BIST does not modify memory; targeted failures are created by
#     directly patching the hierarchy word before the target read occurs.
#   - To continue after a stop-on-error pause, pulse `bist_start` low then high
#     again without reinitializing the BIST state. The RTL clears
#     `csr_status.bist_error` on re-entry and continues from the already
#     advanced `current_address`, which means the next read should be the next
#     address after the one that just failed.
# - `bist_stop_on_repl_of` behavior:
#   - This mode accumulates masked bit mismatches into `bist_error_count`.
#   - `bist_error_count` is 17 bits wide:
#     - `[15:0]` running count
#     - `[16]` overflow sentinel
#   - With `bist_stop_on_repl_of=1` and `bist_stop_on_error=0`, overflow
#     saturates the count to `17'h1_0000` and leaves `bist_error=0`.
#   - With `bist_stop_on_repl_of=1` and `bist_stop_on_error=1`, overflow also
#     latches `bist_error`, `bist_err_add`, and `bist_error_loop`.
#   - The overflow tests in this file force the internal count near the
#     threshold after BIST starts, then inject about 10 bad reads to trigger the
#     overflow deterministically.
# - BWE masking expectations:
#   - Masked-off bits must not trigger `bist_error`.
#   - Masked-off bits must not contribute to `bist_error_count`.
#
# BIST READ COVERAGE MATRIX (executed in this test)
# - [x] Baseline completion + status readability on all 4 banks.
# - [x] Start retrigger while active.
# - [x] `bist_data_inv` loop-0 pass and loop-1 targeted failure.
# - [x] `bist_add_inc` sweep (0..7) using selected-address preloads.
# - [x] Address corners plus plane/block/column/redundant/OTP boundary ranges.
# - [x] `bist_loop_count` sweep.
# - [x] `bist_stop_on_error` first/middle/last across loops 0/1/2.
# - [x] `bist_stop_on_error` with `bist_data_inv=1` on loops 0 and 1.
# - [x] `bist_stop_on_error` continue/resume behavior for clustered and sparse
#       failures at start/middle/end, both within loop 0 and within loop 1.
# - [x] `bist_stop_on_repl_of` accumulation and per-bit BWE mask-off sweep.
# - [x] `bist_stop_on_repl_of` overflow without stop and with stop-on-error.
# - [x] `bist_stop_on_repl_of` stop-on-error overflow on loop 1.
# - [x] `bist_rst_b` pulse before start and while idle (if present).
# - [x] `bist_reset` while idle and while active.
# - [ ] Reference-trim-only controls are intentionally excluded from read-BIST:
#       `bist_trim_mode`, `bist_rte_en`, `RH4margin`, `rh2_offset`.
# - [ ] Cross-instance contiguous ranges are deferred. The flat BIST address
#       space crosses large unused holes between instance windows, so the exact
#       read-BIST spec there needs to be nailed down before turning that into a
#       pass/fail matrix.
# - [ ] `bist_stop_on_repl_of` overflow with `bist_data_inv=1` is deferred.


@cocotb.test()
async def bist_read_basic(dut):
    """BIST read matrix: cover read-related controls and compare/count scenarios."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(779)

    context = {"reg_model": build_treg_reg_model(my_tb.axi_treg_master)}
    regs0 = context["reg_model"].bank0_tregs

    bist_control_fields = await regs0.bist_control.read_fields()
    bist_status_0_fields = await regs0.bist_status_0.read_fields()
    bist_status_1_fields = await regs0.bist_status_1.read_fields()
    dut._log.info(
        "BIST options: bist_control=%s",
        ", ".join(sorted(bist_control_fields.keys())),
    )
    dut._log.info(
        "BIST options: bist_status_0=%s",
        ", ".join(sorted(bist_status_0_fields.keys())),
    )
    dut._log.info(
        "BIST options: bist_status_1=%s",
        ", ".join(sorted(bist_status_1_fields.keys())),
    )

    def mark_matrix(label):
        my_tb.set_wave_matrix_label(label)
        dut._log.info(label)

    has_bist_rst_b = "bist_rst_b" in bist_control_fields

    def bank_tregs(bank):
        return getattr(context["reg_model"], f"bank{bank}_tregs")

    def read_raw_word(bank_idx, inst_idx, addr):
        my_tb.warn_direct_mram_access(
            "read",
            "bist_read_basic hierarchy spot-check",
            tag="bist_read_basic.direct_read",
        )
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        return int(my_tb._memory_word_handle(instance, plane_idx, plane_addr).value)

    def write_raw_word(bank_idx, inst_idx, addr, value):
        my_tb.warn_direct_mram_access(
            "write",
            "bist_read_basic direct raw-word setup",
            tag="bist_read_basic.direct_write",
        )
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        my_tb._memory_word_handle(instance, plane_idx, plane_addr).value = int(value)

    def initialize_raw_word_range(bank_idx, inst_idx, start_addr, stop_addr, value=0):
        for addr in range(start_addr, stop_addr + 1):
            write_raw_word(bank_idx, inst_idx, addr, value)

    def raw_addr_to_bist_target(inst_idx, raw_addr):
        return (((raw_addr >> 16) & 0x1) << 19) | ((inst_idx & 0x7) << 16) | (raw_addr & 0xFFFF)

    def raw_normal_addr(plane_idx, row_idx, col_idx):
        plane_addr = (row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    def raw_redundant_addr(plane_idx, redundant_row_idx, col_idx):
        plane_addr = (1 << (MRAM_NORM_ROW_ADDR_WIDTH + MRAM_COL_ADDR_WIDTH))
        plane_addr |= (redundant_row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    max_plane_addr = (
        (1 << (MRAM_NORM_ROW_ADDR_WIDTH + MRAM_COL_ADDR_WIDTH))
        + (MRAM_NUM_RESERVED_ROWS << MRAM_COL_ADDR_WIDTH)
        - 1
    )

    def raw_addr_is_valid(raw_addr):
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(raw_addr)
        return 0 <= plane_idx < MRAM_NUM_PLANES and 0 <= plane_addr <= max_plane_addr

    def get_mram_instance_signal(bank_idx, inst_idx, signal_name):
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        resolved = my_tb._resolve_dut_path(f"{instance._path}.{signal_name}")
        if resolved is not None:
            return resolved

        instance_handle = my_tb._resolve_dut_path(instance._path)
        if instance_handle is not None:
            child = my_tb._resolve_child_handle(instance_handle, signal_name)
            if child is not None:
                return child

        raise AttributeError(
            f"Could not resolve {signal_name} for bank={bank_idx} inst={inst_idx}"
        )

    def get_bist_core(bank_idx):
        ctrl_top = my_tb.get_controller_top(bank_idx)
        candidates = []

        bist_wrapper = my_tb._resolve_child_handle(ctrl_top, "bist_wrapper_u")
        if bist_wrapper is not None:
            candidates.extend((
                my_tb._resolve_child_handle(bist_wrapper, "et_bist_u"),
                my_tb._resolve_child_handle(bist_wrapper, "et_bist_u[0]"),
            ))

        candidates.extend((
            my_tb._resolve_dut_path(
                f"mram_bank[{bank_idx}].bank_wrapper_u.et_ctrl_wrapper_u."
                f"et_ctrl_top_u.bist_wrapper_u.et_bist_u"
            ),
            my_tb._resolve_dut_path(
                f"mram_bank[{bank_idx}].bank_wrapper_u.et_ctrl_wrapper_u."
                f"et_ctrl_top_u[0].bist_wrapper_u.et_bist_u"
            ),
        ))

        for candidate in candidates:
            if candidate is not None and hasattr(candidate, "loop_count") and hasattr(candidate, "current_address"):
                return candidate

        raise AttributeError(
            f"Could not resolve mkEtBist core for mram_bank[{bank_idx}]"
        )

    def force_bist_error_count(bank_idx, value):
        bist_core = get_bist_core(bank_idx)
        csr_status = int(bist_core.csr_status.value)
        error_count_lsb = 79
        error_count_width = 17
        error_count_mask = ((1 << error_count_width) - 1) << error_count_lsb
        bist_core.csr_status.value = (
            (csr_status & ~error_count_mask)
            | ((int(value) & ((1 << error_count_width) - 1)) << error_count_lsb)
        )

    async def assert_status_resolvable(regs, label):
        status_0 = await regs.bist_status_0.read_fields()
        status_1 = await regs.bist_status_1.read_fields()
        for field_name, field_val in status_0.items():
            try:
                int(field_val)
            except Exception as exc:
                raise AssertionError(
                    f"{label}: bist_status_0.{field_name} is not int-convertible"
                ) from exc
        for field_name, field_val in status_1.items():
            try:
                int(field_val)
            except Exception as exc:
                raise AssertionError(
                    f"{label}: bist_status_1.{field_name} is not int-convertible"
                ) from exc

    async def read_bist_error_value(regs):
        lower = int(await regs.bist_status_0.bist_error_value.read())
        upper = int(await regs.bist_control.bist_error_value.read())
        return (upper << 64) | lower

    async def wait_bist_done(regs, label, timeout_ns=10_000):
        poll_step_ns = 20
        max_polls = max(1, timeout_ns // poll_step_ns)
        await Timer(poll_step_ns, unit="ns")
        for _ in range(max_polls):
            busy = int(await regs.bist_status_1.bist_busy.read())
            if busy == 0:
                return
            await Timer(poll_step_ns, unit="ns")
        raise AssertionError(f"{label}: timed out waiting for BIST completion")

    async def pulse_bist_rst(regs):
        if not has_bist_rst_b:
            return
        await regs.bist_control.write_fields(
            bist_loop_count=0,
            bist_trim_mode=0,
            bist_stop_on_repl_of=0,
            bist_reset=0,
            bist_rd_en=0,
            bist_wr_en=0,
            bist_start=0,
            bist_rst_b=0,
        )
        await Timer(20, unit="ns")
        await regs.bist_control.write_fields(bist_rst_b=1)
        await Timer(20, unit="ns")

    async def assert_bist_rst_all_banks():
        if not has_bist_rst_b:
            return
        for bank in range(4):
            await bank_tregs(bank).bist_control.write_fields(bist_rst_b=0)
            await bank_tregs(bank).bist_control.write_fields(bist_rst_b=1)
        dut._log.info("Asserted bist_rst_b=1 on all banks")

    async def clear_bist_error_without_running(regs, label):
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_reset=1,
            bist_rd_en=0,
            bist_wr_en=0,
            bist_start=0,
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
        )
        await Timer(20, unit="ns")
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_reset=1,
            bist_rd_en=0,
            bist_wr_en=0,
            bist_start=1,
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
        )
        await Timer(20, unit="ns")
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_reset=0,
            bist_rd_en=0,
            bist_wr_en=0,
            bist_start=0,
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
        )
        await Timer(20, unit="ns")
        cleared_error = int(await regs.bist_status_1.bist_error.read())
        assert cleared_error == 0, (
            f"{label}: bist_error did not clear after bist_reset/start idle pulse"
        )

    def loop_pattern(pattern, data_inv, loop_idx, full_bwe):
        return (pattern ^ full_bwe) if (data_inv and (loop_idx & 1)) else pattern

    def program_selected_addrs(bank_idx, inst_idx, raw_start, raw_stop, selected_addrs, good_value, bad_value):
        initialize_raw_word_range(bank_idx, inst_idx, raw_start, raw_stop, bad_value)
        for addr in selected_addrs:
            write_raw_word(bank_idx, inst_idx, addr, good_value)

    def set_guard_words(bank_idx, inst_idx, raw_start, raw_stop, guard_value):
        if raw_start > 0 and raw_addr_is_valid(raw_start - 1):
            write_raw_word(bank_idx, inst_idx, raw_start - 1, guard_value)
        if raw_addr_is_valid(raw_stop + 1):
            write_raw_word(bank_idx, inst_idx, raw_stop + 1, guard_value)

    async def run_read_case(
        label,
        *,
        bank=0,
        cfg_overrides=None,
        ctrl_overrides=None,
        pattern=None,
        retrigger_start=False,
        pulse_reset_while_running=False,
        timeout_ns=10_000,
    ):
        cfg_overrides = cfg_overrides or {}
        ctrl_overrides = ctrl_overrides or {}
        regs = bank_tregs(bank)

        full_bwe = (1 << 79) - 1
        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe

        await write_mram_control_fields(
            regs,
            bwe=full_bwe,
            din=pattern,
        )

        cfg = {
            "bist_rte_en": 0,
            "bist_data_inv": 0,
            "bist_add_inc": 0,
            "bist_stop_on_error": 1,
            "bist_start_add": 0x20,
            "bist_stop_add": 0x2F,
            "RH4margin": 10,
            "rh2_offset": 0,
        }
        cfg.update(cfg_overrides)
        await regs.bist_control.write_fields(**cfg)

        ctrl = {
            "bist_loop_count": 0,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 0,
            "bist_reset": 0,
            "bist_rd_en": 1,
            "bist_wr_en": 0,
            "bist_start": 0,
        }
        ctrl.update(ctrl_overrides)
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = int(ctrl_overrides.get("bist_rst_b", 1))
        await regs.bist_control.write_fields(**ctrl)

        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )
        if retrigger_start:
            await regs.bist_control.write_fields(
                **({"bist_rst_b": 1} if has_bist_rst_b else {}),
                bist_start=1,
            )

        if pulse_reset_while_running:
            await Timer(40, unit="ns")
            await regs.bist_control.write_fields(
                **({"bist_rst_b": 1} if has_bist_rst_b else {}),
                bist_reset=1,
            )
            await Timer(20, unit="ns")
            await regs.bist_control.write_fields(
                **({"bist_rst_b": 1} if has_bist_rst_b else {}),
                bist_reset=0,
            )

        await wait_bist_done(regs, label, timeout_ns=timeout_ns)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_wr_en=0,
            bist_rd_en=0,
        )

        await assert_status_resolvable(regs, label)
        return {
            "bist_error": int(await regs.bist_status_1.bist_error.read()),
            "bist_err_add": int(await regs.bist_status_1.bist_err_add.read()),
            "bist_error_loop": int(await regs.mram_status_0.bist_error_loop.read()),
            "bist_error_count": int(await regs.mram_status_0.bist_error_count.read()),
            "bist_error_value": await read_bist_error_value(regs),
        }

    async def run_raw_range_case(label, raw_start, raw_stop, *, bank=0, inst=0, pattern=None):
        full_bwe = (1 << 79) - 1
        if pattern is None:
            pattern = _rng.getrandbits(79) & full_bwe
        bad_value = pattern ^ 0x1
        initialize_raw_word_range(bank, inst, raw_start, raw_stop, pattern)
        set_guard_words(bank, inst, raw_start, raw_stop, bad_value)
        status = await run_read_case(
            label,
            bank=bank,
            pattern=pattern,
            cfg_overrides={
                "bist_start_add": raw_addr_to_bist_target(inst, raw_start),
                "bist_stop_add": raw_addr_to_bist_target(inst, raw_stop),
            },
        )
        assert status["bist_error"] == 0, (
            f"{label}: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
        )

    async def run_stop_on_error_case(
        label,
        *,
        bank=0,
        inst=0,
        target_loop=0,
        data_inv=False,
        raw_start_addr,
        raw_stop_addr,
        raw_error_addr,
        pattern=None,
        corrupt_mask=0x1,
        timeout_ns=10_000,
    ):
        regs = bank_tregs(bank)
        await clear_bist_error_without_running(regs, f"{label} pre_clear")
        instance_we = get_mram_instance_signal(bank, inst, "we_i")
        instance_ce = get_mram_instance_signal(bank, inst, "ce_i")
        instance_addr = get_mram_instance_signal(bank, inst, "addr_i")
        instance_busy = get_mram_instance_signal(bank, inst, "busy_o")
        full_bwe = (1 << 79) - 1

        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        target_word_index = raw_error_addr - raw_start_addr
        assert words_per_loop > 0, f"{label}: invalid address range"
        assert 0 <= target_word_index < words_per_loop, (
            f"{label}: raw_error_addr=0x{raw_error_addr:05x} is outside "
            f"raw_start_addr=0x{raw_start_addr:05x}..raw_stop_addr=0x{raw_stop_addr:05x}"
        )

        expected_err_add = raw_addr_to_bist_target(inst, raw_error_addr)
        initialize_raw_word_range(
            bank,
            inst,
            raw_start_addr,
            raw_stop_addr,
            loop_pattern(pattern, data_inv, 0, full_bwe),
        )

        corrupt_value = loop_pattern(pattern, data_inv, target_loop, full_bwe) ^ (corrupt_mask & full_bwe)
        if target_loop == 0 and target_word_index == 0:
            write_raw_word(bank, inst, raw_error_addr, corrupt_value)
            injected = True
        else:
            injected = False

        await write_mram_control_fields(
            regs,
            bwe=full_bwe,
            din=pattern,
        )
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_data_inv=int(data_inv),
            bist_add_inc=0,
            bist_stop_on_error=1,
            bist_start_add=raw_addr_to_bist_target(inst, raw_start_addr),
            bist_stop_add=raw_addr_to_bist_target(inst, raw_stop_addr),
            RH4margin=10,
            rh2_offset=0,
        )

        ctrl = {
            "bist_loop_count": target_loop,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 0,
            "bist_reset": 0,
            "bist_rd_en": 1,
            "bist_wr_en": 0,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        completed_reads = 0
        prepared_loops = {0}
        target_inject_after = target_loop * words_per_loop + target_word_index
        while not injected:
            await ReadOnly()
            read_active = (int(instance_ce.value) == 1) and (int(instance_we.value) == 0)
            if not read_active:
                await with_timeout(RisingEdge(instance_ce), timeout_ns, "ns")
                await ReadOnly()
                if int(instance_ce.value) != 1 or int(instance_we.value) != 0:
                    continue

            addr_value = int(instance_addr.value)
            expected_addr = raw_start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"{label}: read sequence mismatch before injection: "
                f"expected addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )

            await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
            completed_reads += 1

            next_loop = completed_reads // words_per_loop
            if data_inv and next_loop <= target_loop and next_loop not in prepared_loops:
                await NextTimeStep()
                initialize_raw_word_range(
                    bank,
                    inst,
                    raw_start_addr,
                    raw_stop_addr,
                    loop_pattern(pattern, data_inv, next_loop, full_bwe),
                )
                prepared_loops.add(next_loop)

            if completed_reads == target_inject_after:
                await NextTimeStep()
                write_raw_word(bank, inst, raw_error_addr, corrupt_value)
                injected = True

        await wait_bist_done(regs, label, timeout_ns=timeout_ns)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_wr_en=0,
            bist_rd_en=0,
        )

        await assert_status_resolvable(regs, label)
        bist_error = int(await regs.bist_status_1.bist_error.read())
        bist_err_add = int(await regs.bist_status_1.bist_err_add.read())
        bist_error_loop = int(await regs.mram_status_0.bist_error_loop.read())
        bist_error_value = await read_bist_error_value(regs)
        assert bist_error == 1, f"{label}: expected bist_error=1"
        assert bist_err_add == expected_err_add, (
            f"{label}: expected bist_err_add=0x{expected_err_add:05x}, got 0x{bist_err_add:05x}"
        )
        assert bist_error_loop == target_loop, (
            f"{label}: expected bist_error_loop={target_loop}, got {bist_error_loop}"
        )
        assert bist_error_value == corrupt_value, (
            f"{label}: expected bist_error_value=0x{corrupt_value:020x}, "
            f"got 0x{bist_error_value:020x}"
        )
        await clear_bist_error_without_running(regs, f"{label} post_clear")

    async def pulse_bist_start_for_continue(regs):
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_rd_en=1,
            bist_wr_en=0,
        )
        await Timer(20, unit="ns")
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
            bist_rd_en=1,
            bist_wr_en=0,
        )

    async def run_stop_on_error_continue_case(
        label,
        *,
        bank=0,
        inst=0,
        loop_count=0,
        data_inv=False,
        raw_start_addr,
        raw_stop_addr,
        error_plan_by_loop,
        pattern=None,
        corrupt_mask=0x1,
        timeout_ns=10_000,
    ):
        regs = bank_tregs(bank)
        await clear_bist_error_without_running(regs, f"{label} pre_clear")
        instance_we = get_mram_instance_signal(bank, inst, "we_i")
        instance_ce = get_mram_instance_signal(bank, inst, "ce_i")
        instance_addr = get_mram_instance_signal(bank, inst, "addr_i")
        instance_busy = get_mram_instance_signal(bank, inst, "busy_o")
        full_bwe = (1 << 79) - 1

        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        assert words_per_loop > 0, f"{label}: invalid address range"

        normalized_plan = {}
        for plan_loop, raw_addrs in error_plan_by_loop.items():
            assert 0 <= plan_loop <= loop_count, (
                f"{label}: plan loop {plan_loop} exceeds loop_count={loop_count}"
            )
            normalized_addrs = sorted(set(raw_addrs))
            for raw_addr in normalized_addrs:
                assert raw_start_addr <= raw_addr <= raw_stop_addr, (
                    f"{label}: raw_error_addr=0x{raw_addr:05x} is outside "
                    f"raw_start_addr=0x{raw_start_addr:05x}..raw_stop_addr=0x{raw_stop_addr:05x}"
                )
            normalized_plan[plan_loop] = normalized_addrs

        def apply_loop_image(loop_idx):
            expected_value = loop_pattern(pattern, data_inv, loop_idx, full_bwe)
            initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, expected_value)
            for raw_addr in normalized_plan.get(loop_idx, []):
                write_raw_word(bank, inst, raw_addr, expected_value ^ (corrupt_mask & full_bwe))

        expected_events = []
        for plan_loop in range(loop_count + 1):
            expected_value = loop_pattern(pattern, data_inv, plan_loop, full_bwe)
            for raw_addr in normalized_plan.get(plan_loop, []):
                expected_events.append({
                    "loop": plan_loop,
                    "raw_addr": raw_addr,
                    "bist_addr": raw_addr_to_bist_target(inst, raw_addr),
                    "error_value": expected_value ^ (corrupt_mask & full_bwe),
                })

        apply_loop_image(0)

        async def maintain_loop_images():
            completed_reads = 0
            prepared_loops = {0}
            total_reads = (loop_count + 1) * words_per_loop
            while completed_reads < total_reads:
                await ReadOnly()
                read_active = (int(instance_ce.value) == 1) and (int(instance_we.value) == 0)
                if not read_active:
                    await with_timeout(RisingEdge(instance_ce), timeout_ns, "ns")
                    await ReadOnly()
                    if int(instance_ce.value) != 1 or int(instance_we.value) != 0:
                        continue

                addr_value = int(instance_addr.value)
                expected_addr = raw_start_addr + (completed_reads % words_per_loop)
                assert addr_value == expected_addr, (
                    f"{label}: read sequence mismatch while preparing continue image: "
                    f"expected addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
                )

                await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
                completed_reads += 1

                next_loop = completed_reads // words_per_loop
                if next_loop <= loop_count and next_loop not in prepared_loops:
                    await NextTimeStep()
                    apply_loop_image(next_loop)
                    prepared_loops.add(next_loop)

        await write_mram_control_fields(
            regs,
            bwe=full_bwe,
            din=pattern,
        )
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_data_inv=int(data_inv),
            bist_add_inc=0,
            bist_stop_on_error=1,
            bist_start_add=raw_addr_to_bist_target(inst, raw_start_addr),
            bist_stop_add=raw_addr_to_bist_target(inst, raw_stop_addr),
            RH4margin=10,
            rh2_offset=0,
        )

        ctrl = {
            "bist_loop_count": loop_count,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 0,
            "bist_reset": 0,
            "bist_rd_en": 1,
            "bist_wr_en": 0,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        loop_image_task = cocotb.start_soon(maintain_loop_images())
        try:
            for event in expected_events:
                await wait_bist_done(regs, label, timeout_ns=timeout_ns)
                await assert_status_resolvable(regs, label)

                bist_error = int(await regs.bist_status_1.bist_error.read())
                bist_err_add = int(await regs.bist_status_1.bist_err_add.read())
                bist_error_loop = int(await regs.mram_status_0.bist_error_loop.read())
                bist_error_value = await read_bist_error_value(regs)

                assert bist_error == 1, (
                    f"{label}: expected bist_error=1 while pausing on loop={event['loop']} "
                    f"addr=0x{event['raw_addr']:05x}"
                )
                assert bist_err_add == event["bist_addr"], (
                    f"{label}: expected bist_err_add=0x{event['bist_addr']:05x}, "
                    f"got 0x{bist_err_add:05x}"
                )
                assert bist_error_loop == event["loop"], (
                    f"{label}: expected bist_error_loop={event['loop']}, got {bist_error_loop}"
                )
                assert bist_error_value == event["error_value"], (
                    f"{label}: expected bist_error_value=0x{event['error_value']:020x}, "
                    f"got 0x{bist_error_value:020x}"
                )

                await pulse_bist_start_for_continue(regs)

            await wait_bist_done(regs, f"{label} final_complete", timeout_ns=timeout_ns)
            await regs.bist_control.write_fields(
                **({"bist_rst_b": 1} if has_bist_rst_b else {}),
                bist_start=0,
                bist_wr_en=0,
                bist_rd_en=0,
            )

            final_bist_error = int(await regs.bist_status_1.bist_error.read())
            assert final_bist_error == 0, (
                f"{label}: expected final bist_error=0 after last continue pulse"
            )
        finally:
            if not loop_image_task.done():
                loop_image_task.cancel()
        await clear_bist_error_without_running(regs, f"{label} post_clear")

    async def run_stop_on_repl_of_case(
        label,
        *,
        bank=0,
        inst=0,
        raw_start_addr,
        raw_stop_addr,
        injected_errors,
        bwe,
        pattern=None,
        expected_error_count=None,
        timeout_ns=10_000,
    ):
        regs = bank_tregs(bank)
        await clear_bist_error_without_running(regs, f"{label} pre_clear")
        full_bwe = (1 << 79) - 1

        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe
        bwe &= full_bwe

        initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, pattern)

        computed_error_count = 0
        for raw_error_addr, corrupt_mask in injected_errors.items():
            masked_corrupt = corrupt_mask & full_bwe
            write_raw_word(bank, inst, raw_error_addr, pattern ^ masked_corrupt)
            computed_error_count += (masked_corrupt & bwe).bit_count()

        if expected_error_count is None:
            expected_error_count = computed_error_count

        await write_mram_control_fields(
            regs,
            bwe=bwe,
            din=pattern,
        )
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_data_inv=0,
            bist_add_inc=0,
            bist_stop_on_error=0,
            bist_start_add=raw_addr_to_bist_target(inst, raw_start_addr),
            bist_stop_add=raw_addr_to_bist_target(inst, raw_stop_addr),
            RH4margin=10,
            rh2_offset=0,
        )

        ctrl = {
            "bist_loop_count": 0,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 1,
            "bist_reset": 0,
            "bist_rd_en": 1,
            "bist_wr_en": 0,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )
        await wait_bist_done(regs, label, timeout_ns=timeout_ns)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_wr_en=0,
            bist_rd_en=0,
        )

        await assert_status_resolvable(regs, label)
        bist_error = int(await regs.bist_status_1.bist_error.read())
        bist_error_count = int(await regs.mram_status_0.bist_error_count.read())
        assert bist_error == 0, (
            f"{label}: expected bist_error=0 for non-overflow replacement counting"
        )
        assert bist_error_count == expected_error_count, (
            f"{label}: expected bist_error_count={expected_error_count}, got {bist_error_count}"
        )
        await clear_bist_error_without_running(regs, label)

    async def run_stop_on_repl_of_overflow_case(
        label,
        *,
        bank=0,
        inst=0,
        raw_start_addr,
        raw_stop_addr,
        stop_on_error=False,
        target_loop=0,
        pattern=None,
        force_after_completed_reads=1,
        overflow_in_reads=10,
        timeout_ns=10_000,
    ):
        regs = bank_tregs(bank)
        await clear_bist_error_without_running(regs, f"{label} pre_clear")
        instance_we = get_mram_instance_signal(bank, inst, "we_i")
        instance_ce = get_mram_instance_signal(bank, inst, "ce_i")
        instance_addr = get_mram_instance_signal(bank, inst, "addr_i")
        instance_busy = get_mram_instance_signal(bank, inst, "busy_o")
        full_bwe = (1 << 79) - 1

        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        assert words_per_loop > force_after_completed_reads + overflow_in_reads, (
            f"{label}: need at least {force_after_completed_reads + overflow_in_reads + 1} "
            f"words in range to test overflow cleanly"
        )

        errors_per_read = full_bwe.bit_count()
        forced_error_count = (1 << 16) - (overflow_in_reads * errors_per_read)
        reads_before_force = target_loop * words_per_loop + force_after_completed_reads
        first_overflow_read_ordinal = reads_before_force + overflow_in_reads
        overflow_raw_error_addr = raw_start_addr + force_after_completed_reads + overflow_in_reads - 1
        expected_err_add = raw_addr_to_bist_target(inst, overflow_raw_error_addr)

        initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, pattern)

        await write_mram_control_fields(
            regs,
            bwe=full_bwe,
            din=pattern,
        )
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_data_inv=0,
            bist_add_inc=0,
            bist_stop_on_error=int(stop_on_error),
            bist_start_add=raw_addr_to_bist_target(inst, raw_start_addr),
            bist_stop_add=raw_addr_to_bist_target(inst, raw_stop_addr),
            RH4margin=10,
            rh2_offset=0,
        )

        ctrl = {
            "bist_loop_count": target_loop,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 1,
            "bist_reset": 0,
            "bist_rd_en": 1,
            "bist_wr_en": 0,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        completed_reads = 0
        counter_forced = False
        while completed_reads < first_overflow_read_ordinal:
            await ReadOnly()
            read_active = (int(instance_ce.value) == 1) and (int(instance_we.value) == 0)
            if not read_active:
                await with_timeout(RisingEdge(instance_ce), timeout_ns, "ns")
                await ReadOnly()
                if int(instance_ce.value) != 1 or int(instance_we.value) != 0:
                    continue

            addr_value = int(instance_addr.value)
            expected_addr = raw_start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"{label}: read sequence mismatch before overflow forcing: "
                f"expected addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )

            await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
            completed_reads += 1

            if (not counter_forced) and (completed_reads == reads_before_force):
                await NextTimeStep()
                force_bist_error_count(bank, forced_error_count)
                for offset in range(overflow_in_reads):
                    raw_addr = raw_start_addr + force_after_completed_reads + offset
                    write_raw_word(bank, inst, raw_addr, pattern ^ full_bwe)
                counter_forced = True

        await wait_bist_done(regs, label, timeout_ns=timeout_ns)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_wr_en=0,
            bist_rd_en=0,
        )

        await assert_status_resolvable(regs, label)
        bist_error = int(await regs.bist_status_1.bist_error.read())
        bist_err_add = int(await regs.bist_status_1.bist_err_add.read())
        bist_error_loop = int(await regs.mram_status_0.bist_error_loop.read())
        bist_error_count = int(await regs.mram_status_0.bist_error_count.read())
        assert bist_error == int(stop_on_error), (
            f"{label}: expected bist_error={int(stop_on_error)} after overflow, got {bist_error}"
        )
        if stop_on_error:
            assert bist_err_add == expected_err_add, (
                f"{label}: expected bist_err_add=0x{expected_err_add:05x}, got 0x{bist_err_add:05x}"
            )
            assert bist_error_loop == target_loop, (
                f"{label}: expected bist_error_loop={target_loop}, got {bist_error_loop}"
            )
        assert bist_error_count == (1 << 16), (
            f"{label}: expected bist_error_count overflow sentinel 0x10000, "
            f"got 0x{bist_error_count:05x}"
        )
        await clear_bist_error_without_running(regs, label)

    # Deterministic bring-up for mkEtBist FSM reset handling.
    if has_bist_rst_b:
        await assert_bist_rst_all_banks()
        await pulse_bist_rst(regs0)
        await assert_bist_rst_all_banks()
    else:
        dut._log.warning("bist_rst_b field not present; reset-specific checks skipped")

    await context["reg_model"].bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)

    # ------------------------------------------------------------------
    # Matrix execution
    # ------------------------------------------------------------------
    mark_matrix("BIST READ matrix: baseline across banks")
    baseline_pattern = 0x0123_4567_89AB_CDEF_123 & ((1 << 79) - 1)
    for bank in range(4):
        initialize_raw_word_range(bank, 0, 0x20, 0x2F, baseline_pattern)
        status = await run_read_case(
            f"baseline_bank{bank}",
            bank=bank,
            pattern=baseline_pattern,
            cfg_overrides={"bist_start_add": 0x20, "bist_stop_add": 0x2F},
        )
        assert status["bist_error"] == 0, (
            f"baseline_bank{bank}: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
        )

    mark_matrix("BIST READ matrix: start retrigger")
    initialize_raw_word_range(0, 0, 0x20, 0x2F, baseline_pattern)
    status = await run_read_case(
        "start_retrigger",
        bank=0,
        pattern=baseline_pattern,
        cfg_overrides={"bist_start_add": 0x20, "bist_stop_add": 0x2F},
        retrigger_start=True,
    )
    assert status["bist_error"] == 0, (
        f"start_retrigger: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
    )

    mark_matrix("BIST READ matrix: bist_data_inv")
    data_inv_start = 0x20
    data_inv_stop = 0x27
    data_inv_pattern = 0x0456_789A_BCDE_F012_345 & ((1 << 79) - 1)
    initialize_raw_word_range(0, 0, data_inv_start, data_inv_stop, data_inv_pattern)
    status = await run_read_case(
        "data_inv_loop0_pass",
        bank=0,
        pattern=data_inv_pattern,
        cfg_overrides={
            "bist_data_inv": 1,
            "bist_start_add": data_inv_start,
            "bist_stop_add": data_inv_stop,
        },
    )
    assert status["bist_error"] == 0, (
        f"data_inv_loop0_pass: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
    )
    await run_stop_on_error_case(
        "data_inv_loop1_targeted_error",
        bank=0,
        inst=0,
        target_loop=1,
        data_inv=True,
        raw_start_addr=data_inv_start,
        raw_stop_addr=data_inv_stop,
        raw_error_addr=data_inv_start + 2,
        pattern=data_inv_pattern,
        corrupt_mask=0x1,
    )

    mark_matrix("BIST READ matrix: bist_add_inc")
    add_inc_start = 0x100
    add_inc_stop = 0x1FF
    bad_value = baseline_pattern ^ 0x1
    for inc in range(8):
        step = 1 << inc
        selected_addrs = list(range(add_inc_start, add_inc_stop + 1, step))
        program_selected_addrs(0, 0, add_inc_start, add_inc_stop, selected_addrs, baseline_pattern, bad_value)
        status = await run_read_case(
            f"add_inc_{inc}",
            bank=0,
            pattern=baseline_pattern,
            cfg_overrides={
                "bist_add_inc": inc,
                "bist_start_add": add_inc_start,
                "bist_stop_add": add_inc_stop,
            },
        )
        assert status["bist_error"] == 0, (
            f"add_inc_{inc}: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
        )

    mark_matrix("BIST READ matrix: address corners and structural boundaries")
    max_normal_row = (1 << MRAM_NORM_ROW_ADDR_WIDTH) - 1
    max_redundant_row = MRAM_NUM_RESERVED_ROWS - 1
    base_addr_cases = (
        ("addr_single_word", raw_normal_addr(0, 2, 0), raw_normal_addr(0, 2, 0)),
        ("addr_low_edge", raw_normal_addr(0, 0, 0), raw_normal_addr(0, 0, 1)),
        ("addr_plane0_high_edge", raw_redundant_addr(0, max_redundant_row, 15), raw_redundant_addr(0, max_redundant_row, 15)),
        ("addr_global_high_edge", raw_redundant_addr(MRAM_NUM_PLANES - 1, max_redundant_row, 15), raw_redundant_addr(MRAM_NUM_PLANES - 1, max_redundant_row, 15)),
    )
    for label, raw_start, raw_stop in base_addr_cases:
        await run_raw_range_case(label, raw_start, raw_stop)

    mark_matrix("BIST READ matrix: plane boundaries")
    for plane_idx in range(MRAM_NUM_PLANES - 1):
        raw_start = raw_normal_addr(plane_idx, max_normal_row, 15)
        raw_stop = raw_normal_addr(plane_idx + 1, 0, 0)
        await run_raw_range_case(
            f"plane_boundary_{plane_idx}_to_{plane_idx + 1}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST READ matrix: block boundaries")
    for plane_idx in range(1, MRAM_NUM_PLANES - 1, 2):
        raw_start = raw_normal_addr(plane_idx, max_normal_row, 15)
        raw_stop = raw_normal_addr(plane_idx + 1, 0, 0)
        await run_raw_range_case(
            f"block_boundary_{plane_idx // 2}_to_{(plane_idx // 2) + 1}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST READ matrix: column-boundary crossings")
    column_boundary_cases = (
        ("col_boundary_row0", raw_normal_addr(0, 0, 15), raw_normal_addr(0, 1, 0)),
        ("col_boundary_row255", raw_normal_addr(0, 255, 15), raw_normal_addr(0, 256, 0)),
        ("col_boundary_row510", raw_normal_addr(0, 510, 15), raw_normal_addr(0, 511, 0)),
        ("col_boundary_red0", raw_redundant_addr(0, 0, 15), raw_redundant_addr(0, 1, 0)),
        ("col_boundary_red11", raw_redundant_addr(0, 11, 15), raw_redundant_addr(0, 12, 0)),
    )
    for label, raw_start, raw_stop in column_boundary_cases:
        await run_raw_range_case(label, raw_start, raw_stop)

    mark_matrix("BIST READ matrix: full redundant rows")
    for redundant_row_idx in range(OTP_FIXED_ROW):
        raw_start = raw_redundant_addr(0, redundant_row_idx, 0)
        raw_stop = raw_redundant_addr(0, redundant_row_idx, 15)
        await run_raw_range_case(f"redundant_row_{redundant_row_idx}", raw_start, raw_stop)

    mark_matrix("BIST READ matrix: full OTP rows in BIST mode")
    for plane_idx in range(MRAM_NUM_PLANES):
        raw_start = raw_redundant_addr(plane_idx, OTP_FIXED_ROW, 0)
        raw_stop = raw_redundant_addr(plane_idx, OTP_FIXED_ROW, 15)
        await run_raw_range_case(f"otp_row_plane_{plane_idx}", raw_start, raw_stop)

    mark_matrix("BIST READ matrix: bist_loop_count")
    for loop_count in range(5):
        initialize_raw_word_range(0, 0, 0x20, 0x27, baseline_pattern)
        status = await run_read_case(
            f"loop_count_{loop_count}",
            bank=0,
            pattern=baseline_pattern,
            cfg_overrides={"bist_start_add": 0x20, "bist_stop_add": 0x27},
            ctrl_overrides={"bist_loop_count": loop_count},
            timeout_ns=15_000,
        )
        assert status["bist_error"] == 0, (
            f"loop_count_{loop_count}: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
        )

    mark_matrix("BIST READ matrix: bist_stop_on_error first/middle/last fault positions across loops")
    stop_start = 0x60
    stop_stop = 0x67
    stop_positions = (
        ("first_addr", stop_start),
        ("middle_addr", stop_start + ((stop_stop - stop_start) // 2)),
        ("last_addr", stop_stop),
    )
    for target_loop in range(3):
        for suffix, raw_error_addr in stop_positions:
            await run_stop_on_error_case(
                f"stop_on_error_loop{target_loop}_{suffix}",
                bank=0,
                inst=0,
                target_loop=target_loop,
                raw_start_addr=stop_start,
                raw_stop_addr=stop_stop,
                raw_error_addr=raw_error_addr,
                pattern=0x0123_4567_89AB_CDEF_321 & ((1 << 79) - 1),
                corrupt_mask=0x1,
            )

    mark_matrix("BIST READ matrix: bist_stop_on_error with bist_data_inv")
    await run_stop_on_error_case(
        "stop_on_error_dinv_loop0",
        bank=0,
        inst=0,
        target_loop=0,
        data_inv=True,
        raw_start_addr=stop_start,
        raw_stop_addr=stop_stop,
        raw_error_addr=stop_start + 1,
        pattern=0x07AA_BBCC_DDEE_F011_223 & ((1 << 79) - 1),
        corrupt_mask=0x1,
    )
    await run_stop_on_error_case(
        "stop_on_error_dinv_loop1",
        bank=0,
        inst=0,
        target_loop=1,
        data_inv=True,
        raw_start_addr=stop_start,
        raw_stop_addr=stop_stop,
        raw_error_addr=stop_start + 2,
        pattern=0x07AA_BBCC_DDEE_F011_223 & ((1 << 79) - 1),
        corrupt_mask=0x1,
    )

    mark_matrix("BIST READ matrix: bist_stop_on_error continue/resume")
    continue_start = 0x140
    continue_stop = 0x14F
    middle_base = continue_start + 4
    continue_cases = (
        ("continue_first_single", 0, {0: [continue_start]}),
        ("continue_first_double", 0, {0: [continue_start, continue_start + 1]}),
        ("continue_first_eight", 0, {0: list(range(continue_start, continue_start + 8))}),
        ("continue_middle_single", 0, {0: [middle_base]}),
        ("continue_middle_double", 0, {0: [middle_base, middle_base + 1]}),
        ("continue_middle_eight", 0, {0: list(range(middle_base, middle_base + 8))}),
        ("continue_last_single", 0, {0: [continue_stop]}),
        ("continue_last_double", 0, {0: [continue_stop - 1, continue_stop]}),
        ("continue_last_eight", 0, {0: list(range(continue_stop - 7, continue_stop + 1))}),
        ("continue_random_sparse", 0, {0: [continue_start + 2, continue_start + 5, continue_start + 9, continue_start + 13]}),
        ("continue_start_and_end", 0, {0: [continue_start, continue_stop]}),
        ("continue_loop1_first_single", 1, {1: [continue_start]}),
        ("continue_loop1_first_double", 1, {1: [continue_start, continue_start + 1]}),
        ("continue_loop1_first_eight", 1, {1: list(range(continue_start, continue_start + 8))}),
        ("continue_loop1_middle_single", 1, {1: [middle_base]}),
        ("continue_loop1_middle_double", 1, {1: [middle_base, middle_base + 1]}),
        ("continue_loop1_middle_eight", 1, {1: list(range(middle_base, middle_base + 8))}),
        ("continue_loop1_last_single", 1, {1: [continue_stop]}),
        ("continue_loop1_last_double", 1, {1: [continue_stop - 1, continue_stop]}),
        ("continue_loop1_last_eight", 1, {1: list(range(continue_stop - 7, continue_stop + 1))}),
        ("continue_loop1_random_sparse", 1, {1: [continue_start + 2, continue_start + 5, continue_start + 9, continue_start + 13]}),
        ("continue_loop0_start_loop1_end", 1, {0: [continue_start], 1: [continue_stop]}),
    )
    continue_pattern = 0x0333_DDDD_4567_89AB_444 & ((1 << 79) - 1)
    for label, case_loop_count, error_plan in continue_cases:
        await run_stop_on_error_continue_case(
            label,
            bank=0,
            inst=0,
            loop_count=case_loop_count,
            raw_start_addr=continue_start,
            raw_stop_addr=continue_stop,
            error_plan_by_loop=error_plan,
            pattern=continue_pattern,
            corrupt_mask=0x1,
            timeout_ns=20_000,
        )

    mark_matrix("BIST READ matrix: bist_stop_on_repl_of accumulation")
    await run_stop_on_repl_of_case(
        "stop_on_repl_of_accumulates_multiple_errors",
        bank=0,
        inst=0,
        raw_start_addr=0x70,
        raw_stop_addr=0x77,
        injected_errors={
            0x70: 0x1,
            0x72: 0x3,
            0x75: 0x7F,
        },
        bwe=(1 << 79) - 1,
        pattern=0x0123_4567_89AB_CDEF_123 & ((1 << 79) - 1),
    )

    mark_matrix("BIST READ matrix: per-bit BWE mask-off sweep")
    mask_sweep_pattern = 0x0234_5678_9ABC_DEF0_456 & ((1 << 79) - 1)
    full_bwe_79 = (1 << 79) - 1
    for bit_idx in range(79):
        await run_stop_on_repl_of_case(
            f"stop_on_repl_of_bwe_masks_bit_{bit_idx}",
            bank=0,
            inst=0,
            raw_start_addr=0x80,
            raw_stop_addr=0x80,
            injected_errors={0x80: 1 << bit_idx},
            bwe=full_bwe_79 ^ (1 << bit_idx),
            pattern=mask_sweep_pattern,
            expected_error_count=0,
        )

    mark_matrix("BIST READ matrix: stop_on_repl_of overflow")
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_continues",
        bank=0,
        inst=0,
        raw_start_addr=0x90,
        raw_stop_addr=0xA7,
        stop_on_error=False,
        target_loop=0,
        pattern=0x0555_AAAA_1234_5678_111 & ((1 << 79) - 1),
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_with_stop_on_error",
        bank=0,
        inst=0,
        raw_start_addr=0xB0,
        raw_stop_addr=0xC7,
        stop_on_error=True,
        target_loop=0,
        pattern=0x0666_BBBB_2345_6789_222 & ((1 << 79) - 1),
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_on_loop1",
        bank=0,
        inst=0,
        raw_start_addr=0xD0,
        raw_stop_addr=0xE7,
        stop_on_error=True,
        target_loop=1,
        pattern=0x0777_CCCC_3456_789A_333 & ((1 << 79) - 1),
    )

    if has_bist_rst_b:
        mark_matrix("BIST READ matrix: bist_rst_b idle pulse")
        await pulse_bist_rst(bank_tregs(0))
        await assert_bist_rst_all_banks()

    mark_matrix("BIST READ matrix: bist_reset while idle")
    await clear_bist_error_without_running(bank_tregs(0), "idle_bist_reset_clear")

    mark_matrix("BIST READ matrix: bist_reset while active, then rerun")
    initialize_raw_word_range(0, 0, 0x20, 0x2F, baseline_pattern)
    status = await run_read_case(
        "reset_while_running",
        bank=0,
        pattern=baseline_pattern,
        cfg_overrides={"bist_start_add": 0x20, "bist_stop_add": 0x2F},
        pulse_reset_while_running=True,
    )
    assert status["bist_error"] == 0, (
        f"reset_while_running: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
    )
    initialize_raw_word_range(0, 0, 0x20, 0x2F, baseline_pattern)
    status = await run_read_case(
        "post_reset_recovery",
        bank=0,
        pattern=baseline_pattern,
        cfg_overrides={"bist_start_add": 0x20, "bist_stop_add": 0x2F},
    )
    assert status["bist_error"] == 0, (
        f"post_reset_recovery: unexpected bist_error=1 (bist_err_add=0x{status['bist_err_add']:05x})"
    )
