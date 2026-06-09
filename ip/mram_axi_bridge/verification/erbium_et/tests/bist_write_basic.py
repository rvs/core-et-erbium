import cocotb
from cocotb.triggers import with_timeout
from tb import *

# WRITE BIST USAGE GUIDE
# - Bring-up requirements:
#   - Assert `bist_rst_b=1` on every bank before using mkEtBist. The BIST FSM
#     does not reliably come up in a clean state for test-register use unless
#     the explicit BIST reset input has been exercised.
#   - Keep bridge clock gating disabled (`disable_clock_gate=0xF`) when using
#     the MRAM test-register path. This flow is not intended to operate with
#     gated MRAM clocks.
#   - If a previous run latched `bist_error`, clear it before starting the next
#     run. The safe sequence is:
#       1. `bist_wr_en=0`, `bist_rd_en=0`, `bist_rte_en=0`
#       2. assert `bist_reset=1`
#       3. pulse `bist_start=1`
#       4. deassert `bist_start` and `bist_reset`
#     A plain `bist_reset` pulse is not sufficient, because the FSM can resume
#     from stale internal address state instead of restarting from
#     `bist_start_add`.
# - Programming model:
#   - Program the payload through `mram_control` before arming BIST:
#     `din` is the 79-bit compare/write pattern and `bwe` is the 79-bit mask
#     used by compare/count logic.
#   - For write BIST, use `bist_wr_en=1`, `bist_rd_en=0`, `bist_rte_en=0`.
#   - `bist_start` is a pulse, not a level. It must go high and then return low
#     before the next run, or the FSM will not re-arm cleanly.
# - Addressing model:
#   - `bist_start_add` / `bist_stop_add` are 20-bit BIST addresses, not AXI
#     byte addresses.
#   - In this testbench a raw MRAM word address is mapped to a BIST address as:
#     `(((raw_addr >> 16) & 0x1) << 19) | ((inst_idx & 0x7) << 16) |
#      (raw_addr & 0xFFFF)`.
#   - `bist_add_inc` is a power-of-two step. The actual word increment is
#     `1 << bist_add_inc`, so `0..7` means `1, 2, 4, ... 128`.
#   - The matrix below explicitly covers:
#     instance crossings (`0->1` through `6->7`), plane boundaries, 2-plane
#     block boundaries, row/column boundaries, redundant rows, and OTP rows.
# - Data pattern model:
#   - The intended write-BIST `bist_data_inv` behavior is loop-based:
#     even loops write plain `din`, odd loops write `~din`.
#   - The tests intentionally compute expected results from loop parity, not
#     from any accidental address-parity implementation detail. If the RTL
#     compare side regresses to an address-based inversion model, the `data_inv`
#     BIST tests should fail.
#   - In BIST mode, OTP rows are treated as fully writable across all 16
#     columns. Product-mode user restrictions on OTP columns do not apply here.
# - `bist_stop_on_error` behavior:
#   - Write BIST writes a word, then performs a readback/compare on the prior
#     written address.
#   - Compare uses `din` and `bwe`, so masked-off bits do not participate.
#   - On the first failing compare, `bist_error` latches, `bist_err_add`
#     records the failing BIST address, `bist_error_loop` records the loop, and
#     `bist_error_value` captures the 79-bit readback value.
#   - If the failure happens on loop 0, addresses after the stop point remain
#     unwritten. If the failure happens on a later loop, addresses after the
#     stop point retain the value from the previous completed loop.
# - `bist_stop_on_repl_of` behavior:
#   - This mode is a bit-error accumulator, not a stop-on-first-fail mode.
#   - The masked mismatch count added each compare is:
#     `countOnes(((comparison_data ^ din) & bwe))`.
#   - `bist_error_count` is 17 bits wide:
#     - bits `[15:0]` are the running count
#     - bit `[16]` is the overflow sentinel
#   - When the count would exceed `2^16 - 1`, the design saturates to
#     `17'h1_0000` and stops accumulating further.
#   - With `bist_stop_on_repl_of=1` and `bist_stop_on_error=0`, overflow is
#     count-only: `bist_error_count` saturates, but `bist_error` is expected to
#     remain low.
#   - With `bist_stop_on_repl_of=1` and `bist_stop_on_error=1`, overflow also
#     latches `bist_error`, `bist_err_add`, and `bist_error_loop`, and the FSM
#     should stop on that overflow event.
#   - The overflow tests in this file do not wait for a natural 64k-count
#     buildup. They intentionally force the internal `error_count` near the
#     overflow threshold after BIST has started, then inject enough bad writes
#     to make overflow happen in about 10 writes.
# - BWE masking expectations:
#   - For stop-on-error, masked-off bits should not trigger compare failure.
#   - For stop-on-repl-of, masked-off bits should not contribute to
#     `bist_error_count`.
#   - The matrix below sweeps every one of the 79 BWE bits to verify that
#     masking is honored per bit.
#
# BIST WRITE COVERAGE MATRIX (executed in this test)
# - [x] Baseline completion + status readability.
# - [x] Start retrigger while active.
# - [x] bist_data_inv toggle and loop-parity behavior.
# - [x] bist_add_inc sweep (0..7).
# - [x] start/stop address corners, instance boundaries, plane boundaries,
#       block boundaries, column-boundary crossings, redundant rows, and full
#       OTP rows (BIST mode can access all 16 OTP columns).
# - [x] bist_loop_count sweep.
# - [x] bist_stop_on_error with targeted first/middle/last fault positions
#       across loops 0/1/2, including error address/loop/value checks.
# - [x] bist_stop_on_error with `bist_data_inv=1` on loops 0 and 1.
# - [x] bist_stop_on_repl_of mismatch accumulation, per-bit BWE masking, and
#       overflow behavior with/without stop_on_error.
# - [x] bist_stop_on_repl_of overflow with `bist_data_inv=1` on loops 0 and 1.
# - [x] bist_rst_b pulse before start and mid-idle (if field exists).
# - [x] bist_reset while idle and while running.
# - [x] reset recovery: reset during active BIST, then rerun.
# - [x] bank coverage (0..3 baseline pass).
# - [ ] Reference-trim-only controls are intentionally excluded from write-BIST:
#       bist_trim_mode, bist_rte_en, RH4margin, rh2_offset.
# - [ ] clock-gating matrix is intentionally excluded: test-mode register flow
#       does not support clock-gated operation.
# - [ ] Forced-error accounting is deferred; write-only BIST path does not
#       naturally create compare mismatches without extra fault injection.
# - [ ] Reserved/invalid window behavior is deferred until error handling spec
#       is finalized for out-of-range BIST addresses.
#
@cocotb.test()
async def bist_write_basic(dut):
    """BIST write matrix: cover write-related controls and corner scenarios."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(778)

    context = {"reg_model": build_treg_reg_model(my_tb.axi_treg_master)}

    # List all currently available BIST options at test start.
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
            "bist_write_basic hierarchy spot-check",
            tag="bist_write_basic.direct_readback",
        )
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        return int(my_tb._memory_word_handle(instance, plane_idx, plane_addr).value)

    def write_raw_word(bank_idx, inst_idx, addr, value):
        my_tb.warn_direct_mram_access(
            "write",
            "bist_write_basic direct raw-word setup",
            tag="bist_write_basic.direct_write",
        )
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        my_tb._memory_word_handle(instance, plane_idx, plane_addr).value = int(value)

    def initialize_raw_word_range(bank_idx, inst_idx, start_addr, stop_addr, value=0):
        for addr in range(start_addr, stop_addr + 1):
            write_raw_word(bank_idx, inst_idx, addr, value)

    def assert_written_address_pattern(label, *, bank_idx, inst_idx, start_addr, stop_addr, step, expected_raw):
        expected_addrs = set(range(start_addr, stop_addr + 1, step))
        for addr in range(start_addr, stop_addr + 1):
            actual_raw = read_raw_word(bank_idx, inst_idx, addr)
            if addr in expected_addrs:
                assert actual_raw == expected_raw, (
                    f"{label}: expected write at addr=0x{addr:05x} "
                    f"to be 0x{expected_raw:020x}, got 0x{actual_raw:020x}"
                )
            else:
                assert actual_raw == 0, (
                    f"{label}: expected untouched addr=0x{addr:05x} to remain 0, "
                    f"got 0x{actual_raw:020x}"
                )

    def raw_addr_to_bist_target(inst_idx, raw_addr):
        return (((raw_addr >> 16) & 0x1) << 19) | ((inst_idx & 0x7) << 16) | (raw_addr & 0xFFFF)

    def raw_normal_addr(plane_idx, row_idx, col_idx):
        plane_addr = (row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    def raw_redundant_addr(plane_idx, redundant_row_idx, col_idx):
        plane_addr = (1 << (MRAM_NORM_ROW_ADDR_WIDTH + MRAM_COL_ADDR_WIDTH))
        plane_addr |= (redundant_row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    def get_mram_instance_signal(bank_idx, inst_idx, signal_name):
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)

        # Prefer full-path resolution. This is how `get_mram_instance()` proves
        # the instance exists today (`din_i`), and it is more reliable than
        # walking child handles on some simulator object models.
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

    async def run_raw_range_case(label, raw_start, raw_stop, *, bank=0, inst=0, pattern=None):
        if pattern is None:
            pattern = _rng.getrandbits(79) & ((1 << 79) - 1)
        initialize_raw_word_range(bank, inst, raw_start, raw_stop, value=0)
        await run_write_case(
            label,
            bank=bank,
            pattern=pattern,
            cfg_overrides={
                "bist_start_add": raw_addr_to_bist_target(inst, raw_start),
                "bist_stop_add": raw_addr_to_bist_target(inst, raw_stop),
            },
        )
        for addr in range(raw_start, raw_stop + 1):
            actual = read_raw_word(bank, inst, addr)
            assert actual == pattern, (
                f"{label}: expected addr=0x{addr:05x} to be 0x{pattern:020x}, "
                f"got 0x{actual:020x}"
            )

    async def run_cross_instance_range_case(
        label,
        *,
        start_inst,
        stop_inst,
        raw_start,
        raw_stop,
        bank=0,
        pattern=None,
    ):
        if pattern is None:
            pattern = _rng.getrandbits(79) & ((1 << 79) - 1)

        write_raw_word(bank, start_inst, raw_start, 0)
        write_raw_word(bank, stop_inst, raw_stop, 0)

        await run_write_case(
            label,
            bank=bank,
            pattern=pattern,
            cfg_overrides={
                "bist_start_add": raw_addr_to_bist_target(start_inst, raw_start),
                "bist_stop_add": raw_addr_to_bist_target(stop_inst, raw_stop),
            },
        )

        actual_start = read_raw_word(bank, start_inst, raw_start)
        actual_stop = read_raw_word(bank, stop_inst, raw_stop)
        assert actual_start == pattern, (
            f"{label}: expected inst={start_inst} addr=0x{raw_start:05x} "
            f"to be 0x{pattern:020x}, got 0x{actual_start:020x}"
        )
        assert actual_stop == pattern, (
            f"{label}: expected inst={stop_inst} addr=0x{raw_stop:05x} "
            f"to be 0x{pattern:020x}, got 0x{actual_stop:020x}"
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

    async def run_write_case(
        label,
        *,
        bank=0,
        cfg_overrides=None,
        ctrl_overrides=None,
        pattern=None,
        verify_addr=None,
        expect_exact_pattern=False,
        expect_pattern_change=False,
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
            "bist_stop_on_error": 0,
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
            "bist_rd_en": 0,
            "bist_wr_en": 1,
            "bist_start": 0,
        }
        ctrl.update(ctrl_overrides)
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = int(ctrl_overrides.get("bist_rst_b", 1))
        await regs.bist_control.write_fields(**ctrl)

        before = None
        if verify_addr is not None:
            before = read_raw_word(bank, 0, verify_addr)

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

        bist_error = int(await regs.bist_status_1.bist_error.read())
        bist_err_add = int(await regs.bist_status_1.bist_err_add.read())
        assert bist_error == 0, (
            f"{label}: bist_error asserted (bist_err_add=0x{bist_err_add:x})"
        )

        after = None
        if verify_addr is not None:
            after = read_raw_word(bank, 0, verify_addr)
            if expect_exact_pattern:
                assert after == pattern, (
                    f"{label}: pattern mismatch at addr=0x{verify_addr:05x}: "
                    f"expected 0x{pattern:020x}, got 0x{after:020x}"
                )
            if expect_pattern_change:
                assert before is not None and after != before, (
                    f"{label}: value did not change at addr=0x{verify_addr:05x} "
                    f"(before=0x{int(before):020x}, after=0x{int(after):020x})"
                )
        return after

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
        expected_loop_pattern = (
            pattern ^ full_bwe if (data_inv and (target_loop & 1)) else pattern
        )
        corrupt_value = expected_loop_pattern ^ (corrupt_mask & full_bwe)
        expected_err_add = raw_addr_to_bist_target(inst, raw_error_addr)

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        target_word_index = raw_error_addr - raw_start_addr
        assert words_per_loop > 0, f"{label}: invalid address range"
        assert 0 <= target_word_index < words_per_loop, (
            f"{label}: raw_error_addr=0x{raw_error_addr:05x} is outside "
            f"raw_start_addr=0x{raw_start_addr:05x}..raw_stop_addr=0x{raw_stop_addr:05x}"
        )
        target_write_ordinal = target_loop * words_per_loop + target_word_index + 1

        initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, value=0)

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
            "bist_rd_en": 0,
            "bist_wr_en": 1,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)

        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        completed_writes = 0
        injected = False
        while completed_writes < target_write_ordinal:
            await ReadOnly()
            write_active = int(instance_we.value)
            ce_value = int(instance_ce.value)
            if not (write_active == 1 and ce_value == 1):
                await with_timeout(RisingEdge(instance_we), timeout_ns, "ns")
                await ReadOnly()
                if int(instance_ce.value) != 1:
                    continue

            addr_value = int(instance_addr.value)
            expected_addr_for_write = raw_start_addr + (completed_writes % words_per_loop)
            assert addr_value == expected_addr_for_write, (
                f"{label}: write sequence mismatch before injection: "
                f"expected addr=0x{expected_addr_for_write:05x}, got 0x{addr_value:05x}"
            )

            await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
            completed_writes += 1

            if completed_writes == target_write_ordinal:
                write_raw_word(bank, inst, raw_error_addr, corrupt_value)
                injected = True
                break

        assert injected, (
            f"{label}: failed to inject fault at loop={target_loop} "
            f"addr=0x{raw_error_addr:05x} before timeout "
            f"(saw {completed_writes} completed writes, needed {target_write_ordinal})"
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
        bist_err_add = int(await regs.bist_status_1.bist_err_add.read())
        bist_error_loop = int(await regs.mram_status_0.bist_error_loop.read())
        bist_error_value = await read_bist_error_value(regs)
        assert bist_error == 1, f"{label}: expected bist_error=1"
        assert bist_err_add == expected_err_add, (
            f"{label}: expected bist_err_add=0x{expected_err_add:05x}, "
            f"got 0x{bist_err_add:05x}"
        )
        assert bist_error_loop == target_loop, (
            f"{label}: expected bist_error_loop={target_loop}, "
            f"got {bist_error_loop}"
        )
        assert bist_error_value == corrupt_value, (
            f"{label}: expected bist_error_value=0x{corrupt_value:020x}, "
            f"got 0x{bist_error_value:020x}"
        )
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
        instance_we = get_mram_instance_signal(bank, inst, "we_i")
        instance_ce = get_mram_instance_signal(bank, inst, "ce_i")
        instance_addr = get_mram_instance_signal(bank, inst, "addr_i")
        instance_busy = get_mram_instance_signal(bank, inst, "busy_o")
        full_bwe = (1 << 79) - 1

        if pattern is None:
            pattern = _rng.getrandbits(79)
        pattern &= full_bwe
        bwe &= full_bwe

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        assert words_per_loop > 0, f"{label}: invalid address range"

        injections_by_ordinal = {}
        injected_values_by_addr = {}
        computed_error_count = 0
        for raw_error_addr, corrupt_mask in injected_errors.items():
            target_word_index = raw_error_addr - raw_start_addr
            assert 0 <= target_word_index < words_per_loop, (
                f"{label}: raw_error_addr=0x{raw_error_addr:05x} is outside "
                f"raw_start_addr=0x{raw_start_addr:05x}..raw_stop_addr=0x{raw_stop_addr:05x}"
            )
            ordinal = target_word_index + 1
            assert ordinal not in injections_by_ordinal, (
                f"{label}: duplicate injection ordinal {ordinal} for addr=0x{raw_error_addr:05x}"
            )

            masked_corrupt = corrupt_mask & full_bwe
            injections_by_ordinal[ordinal] = (
                raw_error_addr,
                pattern ^ masked_corrupt,
            )
            injected_values_by_addr[raw_error_addr] = pattern ^ masked_corrupt
            computed_error_count += (masked_corrupt & bwe).bit_count()

        if expected_error_count is None:
            expected_error_count = computed_error_count

        initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, value=0)

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
            "bist_rd_en": 0,
            "bist_wr_en": 1,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)

        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        completed_writes = 0
        max_injection_ordinal = max(injections_by_ordinal) if injections_by_ordinal else 0
        while completed_writes < max_injection_ordinal:
            await ReadOnly()
            write_active = int(instance_we.value)
            ce_value = int(instance_ce.value)
            if not (write_active == 1 and ce_value == 1):
                await with_timeout(RisingEdge(instance_we), timeout_ns, "ns")
                await ReadOnly()
                if int(instance_ce.value) != 1:
                    continue

            addr_value = int(instance_addr.value)
            expected_addr_for_write = raw_start_addr + (completed_writes % words_per_loop)
            assert addr_value == expected_addr_for_write, (
                f"{label}: write sequence mismatch before injection: "
                f"expected addr=0x{expected_addr_for_write:05x}, got 0x{addr_value:05x}"
            )

            await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
            completed_writes += 1

            injection = injections_by_ordinal.get(completed_writes)
            if injection is not None:
                raw_error_addr, corrupt_value = injection
                write_raw_word(bank, inst, raw_error_addr, corrupt_value)

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
            f"{label}: expected bist_error_count={expected_error_count}, "
            f"got {bist_error_count}"
        )

        for addr in range(raw_start_addr, raw_stop_addr + 1):
            expected = injected_values_by_addr.get(addr, pattern)
            actual = read_raw_word(bank, inst, addr)
            assert actual == expected, (
                f"{label}: expected addr=0x{addr:05x} to be 0x{expected:020x}, "
                f"got 0x{actual:020x}"
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
        data_inv=False,
        force_after_completed_writes=1,
        overflow_in_writes=10,
        pattern=None,
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
        errors_per_write = full_bwe.bit_count()
        forced_error_count = (1 << 16) - (overflow_in_writes * errors_per_write)

        def loop_pattern(loop_idx):
            return (pattern ^ full_bwe) if (data_inv and (loop_idx & 1)) else pattern

        words_per_loop = raw_stop_addr - raw_start_addr + 1
        writes_before_force = target_loop * words_per_loop + force_after_completed_writes
        assert words_per_loop > force_after_completed_writes + overflow_in_writes, (
            f"{label}: need at least {force_after_completed_writes + overflow_in_writes + 1} "
            f"words in range to test overflow cleanly"
        )
        assert forced_error_count > 0, f"{label}: invalid forced_error_count"

        overflow_raw_error_addr = (
            raw_start_addr + force_after_completed_writes + overflow_in_writes - 1
        )
        expected_err_add = raw_addr_to_bist_target(inst, overflow_raw_error_addr)

        initialize_raw_word_range(bank, inst, raw_start_addr, raw_stop_addr, value=0)

        await write_mram_control_fields(
            regs,
            bwe=full_bwe,
            din=pattern,
        )
        await regs.bist_control.write_fields(
            bist_rte_en=0,
            bist_data_inv=int(data_inv),
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
            "bist_rd_en": 0,
            "bist_wr_en": 1,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl)

        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )

        completed_writes = 0
        counter_forced = False
        max_injection_ordinal = writes_before_force + overflow_in_writes
        injected_values_by_write_ordinal = {}
        while completed_writes < max_injection_ordinal:
            await ReadOnly()
            write_active = int(instance_we.value)
            ce_value = int(instance_ce.value)
            if not (write_active == 1 and ce_value == 1):
                await with_timeout(RisingEdge(instance_we), timeout_ns, "ns")
                await ReadOnly()
                if int(instance_ce.value) != 1:
                    continue

            addr_value = int(instance_addr.value)
            expected_addr_for_write = raw_start_addr + (completed_writes % words_per_loop)
            assert addr_value == expected_addr_for_write, (
                f"{label}: write sequence mismatch before overflow forcing: "
                f"expected addr=0x{expected_addr_for_write:05x}, got 0x{addr_value:05x}"
            )

            await with_timeout(FallingEdge(instance_busy), timeout_ns, "ns")
            completed_writes += 1

            if (not counter_forced) and (completed_writes == writes_before_force):
                force_bist_error_count(bank, forced_error_count)
                counter_forced = True

            if writes_before_force < completed_writes <= max_injection_ordinal:
                current_loop = (completed_writes - 1) // words_per_loop
                corrupt_value = loop_pattern(current_loop) ^ full_bwe
                write_raw_word(bank, inst, addr_value, corrupt_value)
                injected_values_by_write_ordinal[completed_writes] = (addr_value, corrupt_value)

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
            f"{label}: expected bist_error={int(stop_on_error)} after overflow, "
            f"got {bist_error}"
        )
        if stop_on_error:
            assert bist_err_add == expected_err_add, (
                f"{label}: expected bist_err_add=0x{expected_err_add:05x}, "
                f"got 0x{bist_err_add:05x}"
            )
            assert bist_error_loop == target_loop, (
                f"{label}: expected bist_error_loop={target_loop}, got {bist_error_loop}"
            )
        assert bist_error_count == (1 << 16), (
            f"{label}: expected bist_error_count overflow sentinel 0x10000, "
            f"got 0x{bist_error_count:05x}"
        )

        injected_values_by_addr = {}
        for addr, corrupt in injected_values_by_write_ordinal.values():
            injected_values_by_addr[addr] = corrupt

        for addr in range(raw_start_addr, raw_stop_addr + 1):
            if addr in injected_values_by_addr:
                expected = injected_values_by_addr[addr]
            elif stop_on_error and addr > overflow_raw_error_addr:
                expected = 0 if target_loop == 0 else loop_pattern(target_loop - 1)
            else:
                expected = loop_pattern(target_loop)
            actual = read_raw_word(bank, inst, addr)
            assert actual == expected, (
                f"{label}: expected addr=0x{addr:05x} to be 0x{expected:020x}, "
                f"got 0x{actual:020x}"
            )

        await clear_bist_error_without_running(regs, label)

    # Deterministic bring-up for mkEtBist FSM reset handling.
    if has_bist_rst_b:
        await assert_bist_rst_all_banks()
        await pulse_bist_rst(regs0)
        await assert_bist_rst_all_banks()
    else:
        dut._log.warning("bist_rst_b field not present; reset-specific checks skipped")

    # Keep MRAM clocks ungated during most matrix runs.
    await context["reg_model"].bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)

    # ------------------------------------------------------------------
    # Matrix execution
    # ------------------------------------------------------------------
    mark_matrix("BIST WRITE matrix: baseline across banks")
    for bank in range(4):
        await run_write_case(
            f"baseline_bank{bank}",
            bank=bank,
            verify_addr=0x20,
            expect_pattern_change=True,
        )

    mark_matrix("BIST WRITE matrix: start retrigger")
    await run_write_case(
        "start_retrigger",
        bank=0,
        retrigger_start=True,
        verify_addr=0x21,
        expect_pattern_change=True,
    )

    mark_matrix("BIST WRITE matrix: bist_data_inv")
    data_inv_start = 0x20
    data_inv_stop = 0x27
    data_inv_inst = 0
    data_inv_pattern = 0x0123_4567_89AB_CDEF_123 & ((1 << 79) - 1)
    full_bwe_79 = (1 << 79) - 1

    initialize_raw_word_range(0, data_inv_inst, data_inv_start, data_inv_stop, value=0)
    await run_write_case(
        "data_inv_off",
        bank=0,
        pattern=data_inv_pattern,
        cfg_overrides={
            "bist_data_inv": 0,
            "bist_start_add": data_inv_start,
            "bist_stop_add": data_inv_stop,
        },
        verify_addr=data_inv_start,
        expect_exact_pattern=True,
    )
    for addr in range(data_inv_start, data_inv_stop + 1):
        actual = read_raw_word(0, data_inv_inst, addr)
        assert actual == data_inv_pattern, (
            f"data_inv_off: expected addr=0x{addr:05x} to be 0x{data_inv_pattern:020x}, "
            f"got 0x{actual:020x}"
        )

    for loop_count in range(5):
        label = f"data_inv_on_loop_count_{loop_count}"
        initialize_raw_word_range(0, data_inv_inst, data_inv_start, data_inv_stop, value=0)
        await run_write_case(
            label,
            bank=0,
            pattern=data_inv_pattern,
            cfg_overrides={
                "bist_data_inv": 1,
                "bist_start_add": data_inv_start,
                "bist_stop_add": data_inv_stop,
            },
            ctrl_overrides={"bist_loop_count": loop_count},
        )
        for addr in range(data_inv_start, data_inv_stop + 1):
            expected = data_inv_pattern ^ full_bwe_79 if (loop_count & 1) else data_inv_pattern
            actual = read_raw_word(0, data_inv_inst, addr)
            assert actual == expected, (
                f"{label}: addr=0x{addr:05x} expected 0x{expected:020x}, "
                f"got 0x{actual:020x}"
            )

    mark_matrix("BIST WRITE matrix: bist_add_inc sweep")
    add_inc_start = 0x100
    add_inc_stop = 0x1FF
    add_inc_inst = 0
    for inc in range(8):
        pattern = (0x0123_4567_89AB_CDEF_123 ^ (inc << 12)) & ((1 << 79) - 1)
        initialize_raw_word_range(0, add_inc_inst, add_inc_start, add_inc_stop, value=0)
        await run_write_case(
            f"add_inc_{inc}",
            bank=0,
            pattern=pattern,
            cfg_overrides={
                "bist_add_inc": inc,
                "bist_start_add": add_inc_start,
                "bist_stop_add": add_inc_stop,
            },
        )
        assert_written_address_pattern(
            f"add_inc_{inc}",
            bank_idx=0,
            inst_idx=add_inc_inst,
            start_addr=add_inc_start,
            stop_addr=add_inc_stop,
            step=(1 << inc),
            expected_raw=pattern,
        )

    mark_matrix("BIST WRITE matrix: address corners and structural boundaries")
    max_normal_row = (1 << MRAM_NORM_ROW_ADDR_WIDTH) - 1
    max_redundant_row = MRAM_NUM_RESERVED_ROWS - 1
    max_non_otp_redundant_row = OTP_FIXED_ROW - 1

    base_addr_cases = (
        ("addr_single_word", raw_normal_addr(0, 2, 0), raw_normal_addr(0, 2, 0)),
        ("addr_low_edge", raw_normal_addr(0, 0, 0), raw_normal_addr(0, 0, 1)),
        ("addr_plane0_high_edge", raw_redundant_addr(0, max_redundant_row, 15), raw_redundant_addr(0, max_redundant_row, 15)),
        ("addr_global_high_edge", raw_redundant_addr(MRAM_NUM_PLANES - 1, max_redundant_row, 15), raw_redundant_addr(MRAM_NUM_PLANES - 1, max_redundant_row, 15)),
    )
    for label, raw_start, raw_stop in base_addr_cases:
        await run_raw_range_case(label, raw_start, raw_stop)

    mark_matrix("BIST WRITE matrix: instance boundaries")
    max_normal_raw = raw_normal_addr(MRAM_NUM_PLANES - 1, max_normal_row, 15)
    min_normal_raw = raw_normal_addr(0, 0, 0)
    for inst_idx in range(7):
        await run_cross_instance_range_case(
            f"instance_boundary_{inst_idx}_to_{inst_idx + 1}",
            start_inst=inst_idx,
            stop_inst=inst_idx + 1,
            raw_start=max_normal_raw,
            raw_stop=min_normal_raw,
        )

    mark_matrix("BIST WRITE matrix: plane boundaries")
    for plane_idx in range(MRAM_NUM_PLANES - 1):
        raw_start = raw_normal_addr(plane_idx, max_normal_row, 15)
        raw_stop = raw_normal_addr(plane_idx + 1, 0, 0)
        await run_raw_range_case(
            f"plane_boundary_{plane_idx}_to_{plane_idx + 1}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST WRITE matrix: block boundaries")
    for plane_idx in range(1, MRAM_NUM_PLANES - 1, 2):
        raw_start = raw_normal_addr(plane_idx, max_normal_row, 15)
        raw_stop = raw_normal_addr(plane_idx + 1, 0, 0)
        await run_raw_range_case(
            f"block_boundary_{plane_idx // 2}_to_{(plane_idx // 2) + 1}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST WRITE matrix: column-boundary crossings")
    column_boundary_cases = (
        ("col_boundary_row0", raw_normal_addr(0, 0, 15), raw_normal_addr(0, 1, 0)),
        ("col_boundary_row255", raw_normal_addr(0, 255, 15), raw_normal_addr(0, 256, 0)),
        ("col_boundary_row510", raw_normal_addr(0, 510, 15), raw_normal_addr(0, 511, 0)),
        ("col_boundary_red0", raw_redundant_addr(0, 0, 15), raw_redundant_addr(0, 1, 0)),
        ("col_boundary_red11", raw_redundant_addr(0, 11, 15), raw_redundant_addr(0, 12, 0)),
    )
    for label, raw_start, raw_stop in column_boundary_cases:
        await run_raw_range_case(label, raw_start, raw_stop)

    mark_matrix("BIST WRITE matrix: all valid non-OTP redundant rows")
    for plane_idx in range(MRAM_NUM_PLANES):
        raw_start = raw_redundant_addr(plane_idx, 0, 0)
        raw_stop = raw_redundant_addr(plane_idx, max_non_otp_redundant_row, 15)
        await run_raw_range_case(
            f"redundant_rows_p{plane_idx}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST WRITE matrix: full OTP rows in BIST mode")
    for plane_idx in range(MRAM_NUM_PLANES):
        raw_start = raw_redundant_addr(plane_idx, OTP_FIXED_ROW, 0)
        raw_stop = raw_redundant_addr(plane_idx, OTP_FIXED_ROW, 15)
        await run_raw_range_case(
            f"otp_row_full_p{plane_idx}",
            raw_start,
            raw_stop,
        )

    mark_matrix("BIST WRITE matrix: bist_loop_count sweep")
    for loop_count in (0, 1, 3):
        await run_write_case(
            f"loop_count_{loop_count}",
            bank=0,
            ctrl_overrides={"bist_loop_count": loop_count},
        )

    mark_matrix("BIST WRITE matrix: bist_stop_on_error first/middle/last fault positions across loops")
    await run_write_case(
        "stop_on_error_0_no_fault",
        bank=0,
        cfg_overrides={"bist_stop_on_error": 0},
    )

    stop_on_error_start = raw_normal_addr(0, 6, 0)
    stop_on_error_stop = raw_normal_addr(0, 6, 7)
    stop_on_error_positions = (
        ("first_addr", stop_on_error_start),
        ("middle_addr", raw_normal_addr(0, 6, 3)),
        ("last_addr", stop_on_error_stop),
    )
    for target_loop in (0, 1, 2):
        for pos_idx, (pos_label, raw_error_addr) in enumerate(stop_on_error_positions):
            await run_stop_on_error_case(
                f"stop_on_error_loop{target_loop}_{pos_label}",
                bank=0,
                inst=0,
                target_loop=target_loop,
                raw_start_addr=stop_on_error_start,
                raw_stop_addr=stop_on_error_stop,
                raw_error_addr=raw_error_addr,
                pattern=(
                    0x0456_789A_BCDE_F012_345
                    ^ (target_loop << 12)
                    ^ (pos_idx << 8)
                ) & ((1 << 79) - 1),
            )

    mark_matrix("BIST WRITE matrix: bist_stop_on_error with data_inv across loops 0/1")
    stop_on_error_dinv_addr = raw_normal_addr(0, 6, 3)
    for target_loop in (0, 1):
        await run_stop_on_error_case(
            f"stop_on_error_dinv_loop{target_loop}",
            bank=0,
            inst=0,
            target_loop=target_loop,
            data_inv=True,
            raw_start_addr=stop_on_error_start,
            raw_stop_addr=stop_on_error_stop,
            raw_error_addr=stop_on_error_dinv_addr,
            pattern=(0x0234_5678_9ABC_DEF0_123 ^ (target_loop << 10)) & ((1 << 79) - 1),
        )

    mark_matrix("BIST WRITE matrix: bist_stop_on_repl_of accumulation")
    stop_on_repl_of_start = raw_normal_addr(0, 7, 0)
    stop_on_repl_of_stop = raw_normal_addr(0, 7, 7)
    await run_stop_on_repl_of_case(
        "stop_on_repl_of_accumulates_multiple_errors",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_start,
        raw_stop_addr=stop_on_repl_of_stop,
        bwe=full_bwe_79,
        pattern=0x0123_4567_89AB_CDEF_1234 & full_bwe_79,
        injected_errors={
            raw_normal_addr(0, 7, 0): 0x1,
            raw_normal_addr(0, 7, 2): 0x3,
            raw_normal_addr(0, 7, 4): 0x7,
            raw_normal_addr(0, 7, 7): 0xF,
        },
        expected_error_count=10,
    )

    mark_matrix("BIST WRITE matrix: bist_stop_on_repl_of BWE masking sweep")
    stop_on_repl_of_mask_addr = raw_normal_addr(0, 8, 0)
    for bit_idx in range(79):
        await run_stop_on_repl_of_case(
            f"stop_on_repl_of_bwe_masks_bit_{bit_idx}",
            bank=0,
            inst=0,
            raw_start_addr=stop_on_repl_of_mask_addr,
            raw_stop_addr=stop_on_repl_of_mask_addr,
            bwe=full_bwe_79 & ~(1 << bit_idx),
            pattern=(0x01ED_CBA9_8765_4321_0FED ^ (bit_idx << 3)) & full_bwe_79,
            injected_errors={
                stop_on_repl_of_mask_addr: (1 << bit_idx),
            },
            expected_error_count=0,
        )

    mark_matrix("BIST WRITE matrix: bist_stop_on_repl_of overflow behavior")
    stop_on_repl_of_overflow_start = raw_normal_addr(0, 9, 0)
    stop_on_repl_of_overflow_stop = raw_normal_addr(0, 9, 15)
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_continues",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=False,
        pattern=0x0456_789A_BCDE_F012_345 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_with_stop_on_error",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=True,
        pattern=0x0123_4567_89AB_CDEF_123 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_continues_dinv",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=False,
        data_inv=True,
        pattern=0x0678_9ABC_DEF0_1234_567 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_with_stop_on_error_dinv",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=True,
        data_inv=True,
        pattern=0x0345_6789_ABCD_EF01_234 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_continues_dinv_loop1",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=False,
        target_loop=1,
        data_inv=True,
        pattern=0x0567_89AB_CDEF_0123_456 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_with_stop_on_error_dinv_loop1",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=True,
        target_loop=1,
        data_inv=True,
        pattern=0x0789_ABCD_EF01_2345_678 & full_bwe_79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_stops_on_loop1",
        bank=0,
        inst=0,
        raw_start_addr=stop_on_repl_of_overflow_start,
        raw_stop_addr=stop_on_repl_of_overflow_stop,
        stop_on_error=True,
        target_loop=1,
        pattern=0x00AB_CDEF_0123_4567_89A & full_bwe_79,
    )
    mark_matrix("BIST WRITE matrix: bist_rst_b pulse mid-idle")
    if has_bist_rst_b:
        await pulse_bist_rst(bank_tregs(0))
        await run_write_case("post_mid_idle_bist_rst_pulse", bank=0)

    mark_matrix("BIST WRITE matrix: bist_reset while idle")
    await clear_bist_error_without_running(bank_tregs(0), "idle_bist_reset_clear")
    await run_write_case("post_idle_bist_reset", bank=0)

    mark_matrix("BIST WRITE matrix: bist_reset while running")
    await run_write_case(
        "reset_while_running",
        bank=0,
        cfg_overrides={"bist_start_add": 0x40, "bist_stop_add": 0x6F},
        pulse_reset_while_running=True,
        timeout_ns=20_000,
    )

    mark_matrix("BIST WRITE matrix: reset recovery during active BIST")
    regs = bank_tregs(0)
    await regs.bist_control.write_fields(
        bist_rte_en=0,
        bist_data_inv=0,
        bist_add_inc=1,
        bist_stop_on_error=0,
        bist_start_add=0x80,
        bist_stop_add=0xFF,
        RH4margin=10,
        rh2_offset=0,
        bist_loop_count=0,
        bist_trim_mode=0,
        bist_stop_on_repl_of=0,
        bist_reset=0,
        bist_rd_en=0,
        bist_wr_en=1,
        bist_start=0,
        **({"bist_rst_b": 1} if has_bist_rst_b else {}),
    )
    await regs.bist_control.write_fields(
        **({"bist_rst_b": 1} if has_bist_rst_b else {}),
        bist_start=1,
    )
    await my_tb.reset_sequence()
    context["reg_model"] = build_treg_reg_model(my_tb.axi_treg_master)
    await context["reg_model"].bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)
    if has_bist_rst_b:
        await assert_bist_rst_all_banks()
        await pulse_bist_rst(bank_tregs(0))
        await assert_bist_rst_all_banks()
    await run_write_case("post_global_reset_recovery", bank=0)

    dut._log.info("bist_write_basic matrix passed")
    await Timer(100, unit="ns")
