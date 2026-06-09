import cocotb

from tb import my_tb, seed_rng
from tests.bist_common import (
    MASK79,
    clear_bist_error_without_running,
    configure_bist,
    configure_bist_pattern,
    pulse_bist_reset_idle,
    pulse_bist_start,
    read_bist_error_value,
    read_status0,
    read_status1,
    rtl_write_bist_data,
    wait_bist_done,
    wait_for_bank_access,
    wait_for_bank_access_complete,
    write_mem_word,
)


# READ BIST COVERAGE MATRIX
# - [x] Baseline completion + status readability.
# - [x] Start retrigger while active.
# - [x] `bist_data_inv` loop-0 pass and loop-1 targeted failure model.
# - [x] `bist_add_inc` sweep (0..7).
# - [x] Address corners and boundary ranges across row/stripe/high-edge windows.
# - [x] `bist_loop_count` sweep.
# - [x] `bist_stop_on_error` first/middle/last fault positions across loops 0/1/2.
# - [x] `bist_stop_on_error` with `bist_data_inv=1` on loops 0 and 1.
# - [x] Continue/resume behavior after stop-on-error.
# - [x] `bist_stop_on_repl_of` accumulation and per-bit BWE mask-off sweep.
# - [x] `bist_stop_on_repl_of` overflow latching/count saturation on loop 0 and loop 1.
# - [x] `bist_reset` while idle and while active, plus reset recovery.
# - [ ] `bist_rst_b` and clock-gate control are ET-only and not present on IRAM.
# - [ ] RTE-only controls (`bist_trim_mode`, `bist_rte_en`, `RH4margin`, `rh2_offset`) are excluded here.


@cocotb.test()
async def bist_read_basic(dut):
    """BIST read matrix for non-ET IRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("bist_read_basic")
    await my_tb.reset_sequence()
    seed_rng(779)

    active_wrappers = my_tb.num_wrappers()
    assert active_wrappers >= 1

    def mark_matrix(label):
        my_tb.set_wave_matrix_label(label)
        dut._log.info(label)

    def fill_range(bank, start_addr, stop_addr, value):
        for addr in range(start_addr, stop_addr + 1):
            write_mem_word(bank, addr, value)

    def expected_loop_pattern(pattern, data_inv, loop_idx):
        return rtl_write_bist_data(pattern, data_inv=data_inv, loop_count=loop_idx) & MASK79

    def force_bist_error_count(bank, value):
        bist_core = my_tb.get_bist_core(bank)
        csr_status = int(bist_core.csr_status.value)
        error_count_lsb = 79
        error_count_width = 17
        error_count_mask = ((1 << error_count_width) - 1) << error_count_lsb
        bist_core.csr_status.value = (
            (csr_status & ~error_count_mask)
            | ((int(value) & ((1 << error_count_width) - 1)) << error_count_lsb)
        )

    async def maintain_loop_images(bank, bank_u, *, start_addr, stop_addr, pattern, loop_count, data_inv, timeout_ns):
        words_per_loop = stop_addr - start_addr + 1
        completed_reads = 0
        prepared_loops = {0}
        total_reads = (loop_count + 1) * words_per_loop
        synced_to_run = False

        while completed_reads < total_reads:
            addr_value = await wait_for_bank_access(bank_u, is_write=False, timeout_ns=timeout_ns)
            await wait_for_bank_access_complete(bank_u, timeout_ns=timeout_ns)

            if not synced_to_run:
                if addr_value != start_addr:
                    dut._log.info(
                        "maintain_loop_images skipping stale read addr=0x%05x while waiting for start=0x%05x",
                        addr_value,
                        start_addr,
                    )
                    continue
                synced_to_run = True

            expected_addr = start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"maintain_loop_images: expected read addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )
            completed_reads += 1

            next_loop = completed_reads // words_per_loop
            if next_loop <= loop_count and next_loop not in prepared_loops:
                fill_range(
                    bank,
                    start_addr,
                    stop_addr,
                    expected_loop_pattern(pattern, data_inv, next_loop),
                )
                prepared_loops.add(next_loop)

    async def run_read_bist(
        label,
        *,
        bank=0,
        pattern,
        bwe=MASK79,
        start_addr,
        stop_addr,
        add_inc=0,
        loop_count=0,
        data_inv=False,
        stop_on_error=False,
        retrigger_while_busy=False,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        bank_u = my_tb.get_behavioral_bank(bank)
        loop_image_task = None
        await clear_bist_error_without_running(apb)
        await configure_bist_pattern(apb, din=pattern, bwe=bwe)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=1,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=add_inc,
            loop_count=loop_count,
            data_inv=int(data_inv),
            stop_on_error=int(stop_on_error),
            stop_on_repl_of=0,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )

        if data_inv:
            fill_range(bank, start_addr, stop_addr, expected_loop_pattern(pattern, True, 0))
            loop_image_task = cocotb.start_soon(
                maintain_loop_images(
                    bank,
                    bank_u,
                    start_addr=start_addr,
                    stop_addr=stop_addr,
                    pattern=pattern,
                    loop_count=loop_count,
                    data_inv=True,
                    timeout_ns=timeout_ns,
                )
            )

        dut._log.info(
            "%s bank=%d start=0x%05x stop=0x%05x add_inc=%d loop_count=%d data_inv=%d "
            "stop_on_error=%d pattern=0x%020x bwe=0x%020x",
            label,
            bank,
            start_addr,
            stop_addr,
            add_inc,
            loop_count,
            int(data_inv),
            int(stop_on_error),
            pattern,
            bwe,
        )

        await pulse_bist_start(apb)
        if retrigger_while_busy:
            status = await read_status1(apb)
            if status["bist_busy"]:
                await pulse_bist_start(apb)

        try:
            status1 = await wait_bist_done(apb, timeout_ns=timeout_ns)
            if loop_image_task is not None:
                await loop_image_task
            return {
                "status1": status1,
                "status0": await read_status0(apb),
                "error_value": await read_bist_error_value(apb),
            }
        finally:
            if loop_image_task is not None and not loop_image_task.done():
                loop_image_task.cancel()

    async def run_stop_on_error_case(
        label,
        *,
        bank=0,
        target_loop=0,
        data_inv=False,
        start_addr,
        stop_addr,
        error_addr,
        pattern,
        corrupt_mask=0x1,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        bank_u = my_tb.get_behavioral_bank(bank)
        words_per_loop = stop_addr - start_addr + 1
        target_read_index = error_addr - start_addr
        target_inject_after = target_loop * words_per_loop + target_read_index
        corrupt_value = expected_loop_pattern(pattern, data_inv, target_loop) ^ (corrupt_mask & MASK79)

        fill_range(bank, start_addr, stop_addr, expected_loop_pattern(pattern, data_inv, 0))
        await clear_bist_error_without_running(apb)
        await configure_bist_pattern(apb, din=pattern, bwe=MASK79)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=1,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=0,
            loop_count=target_loop,
            data_inv=int(data_inv),
            stop_on_error=1,
            stop_on_repl_of=0,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )
        await pulse_bist_start(apb)

        completed_reads = 0
        prepared_loops = {0}
        if target_loop == 0 and target_read_index == 0:
            write_mem_word(bank, error_addr, corrupt_value)
            injected = True
        else:
            injected = False

        while not injected:
            addr_value = await wait_for_bank_access(bank_u, is_write=False, timeout_ns=timeout_ns)
            expected_addr = start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"{label}: expected read addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )
            await wait_for_bank_access_complete(bank_u, timeout_ns=timeout_ns)
            completed_reads += 1

            next_loop = completed_reads // words_per_loop
            if data_inv and next_loop <= target_loop and next_loop not in prepared_loops:
                fill_range(bank, start_addr, stop_addr, expected_loop_pattern(pattern, True, next_loop))
                prepared_loops.add(next_loop)

            if completed_reads == target_inject_after:
                write_mem_word(bank, error_addr, corrupt_value)
                injected = True

        result = {
            "status1": await wait_bist_done(apb, timeout_ns=timeout_ns),
            "status0": await read_status0(apb),
            "error_value": await read_bist_error_value(apb),
        }
        assert result["status1"]["bist_error"] == 1, f"{label}: expected bist_error=1"
        assert result["status1"]["bist_err_add"] == error_addr, (
            f"{label}: expected err_add=0x{error_addr:05x}, got 0x{result['status1']['bist_err_add']:05x}"
        )
        assert result["status0"]["error_loop"] == target_loop, (
            f"{label}: expected error_loop={target_loop}, got {result['status0']['error_loop']}"
        )
        assert result["error_value"] == corrupt_value, (
            f"{label}: expected error_value=0x{corrupt_value:020x}, got 0x{result['error_value']:020x}"
        )
        await clear_bist_error_without_running(apb)

    async def pulse_continue(apb):
        await pulse_bist_start(apb)

    async def run_continue_case(
        label,
        *,
        bank=0,
        loop_count,
        data_inv,
        start_addr,
        stop_addr,
        error_plan_by_loop,
        pattern,
        corrupt_mask=0x1,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        bank_u = my_tb.get_behavioral_bank(bank)
        words_per_loop = stop_addr - start_addr + 1

        def apply_loop_image(loop_idx):
            fill_range(bank, start_addr, stop_addr, expected_loop_pattern(pattern, data_inv, loop_idx))
            for raw_addr in sorted(error_plan_by_loop.get(loop_idx, ())):
                write_mem_word(
                    bank,
                    raw_addr,
                    expected_loop_pattern(pattern, data_inv, loop_idx) ^ (corrupt_mask & MASK79),
                )

        expected_events = []
        for plan_loop, addrs in sorted(error_plan_by_loop.items()):
            for raw_addr in sorted(addrs):
                expected_events.append({
                    "loop": plan_loop,
                    "addr": raw_addr,
                    "value": expected_loop_pattern(pattern, data_inv, plan_loop) ^ (corrupt_mask & MASK79),
                })

        apply_loop_image(0)
        await clear_bist_error_without_running(apb)
        await configure_bist_pattern(apb, din=pattern, bwe=MASK79)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=1,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=0,
            loop_count=loop_count,
            data_inv=int(data_inv),
            stop_on_error=1,
            stop_on_repl_of=0,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )
        await pulse_bist_start(apb)

        completed_reads = 0
        prepared_loops = {0}
        service_idx = 0

        while service_idx < len(expected_events):
            addr_value = await wait_for_bank_access(bank_u, is_write=False, timeout_ns=timeout_ns)
            expected_addr = start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"{label}: expected read addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )
            await wait_for_bank_access_complete(bank_u, timeout_ns=timeout_ns)
            completed_reads += 1

            next_loop = completed_reads // words_per_loop
            if data_inv and next_loop <= loop_count and next_loop not in prepared_loops:
                apply_loop_image(next_loop)
                prepared_loops.add(next_loop)

            event = expected_events[service_idx]
            if addr_value == event["addr"]:
                status1 = await read_status1(apb)
                assert status1["bist_error"] == 1, f"{label}: expected stop-on-error at 0x{event['addr']:05x}"
                assert status1["bist_err_add"] == event["addr"], (
                    f"{label}: expected err_add=0x{event['addr']:05x}, got 0x{status1['bist_err_add']:05x}"
                )
                error_value = await read_bist_error_value(apb)
                assert error_value == event["value"], (
                    f"{label}: expected error_value=0x{event['value']:020x}, got 0x{error_value:020x}"
                )
                write_mem_word(
                    bank,
                    event["addr"],
                    expected_loop_pattern(pattern, data_inv, event["loop"]),
                )
                await pulse_continue(apb)
                service_idx += 1

        final_status = await wait_bist_done(apb, timeout_ns=timeout_ns)
        assert final_status["bist_error"] == 0, f"{label}: expected clean completion after continue flow"

    async def run_stop_on_repl_of_case(
        label,
        *,
        bank=0,
        start_addr,
        stop_addr,
        injected_errors,
        bwe,
        pattern,
        expected_error_count=None,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        await clear_bist_error_without_running(apb)

        fill_range(bank, start_addr, stop_addr, pattern)

        computed_error_count = 0
        for error_addr, corrupt_mask in injected_errors.items():
            masked_corrupt = corrupt_mask & MASK79
            write_mem_word(bank, error_addr, pattern ^ masked_corrupt)
            computed_error_count += (masked_corrupt & bwe).bit_count()

        if expected_error_count is None:
            expected_error_count = computed_error_count

        await configure_bist_pattern(apb, din=pattern, bwe=bwe)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=1,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=0,
            loop_count=0,
            data_inv=0,
            stop_on_error=0,
            stop_on_repl_of=1,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )

        dut._log.info(
            "%s bank=%d start=0x%05x stop=0x%05x bwe=0x%020x expected_error_count=%d",
            label,
            bank,
            start_addr,
            stop_addr,
            bwe,
            expected_error_count,
        )

        await pulse_bist_start(apb)
        status1 = await wait_bist_done(apb, timeout_ns=timeout_ns)
        status0 = await read_status0(apb)
        assert status1["bist_error"] == 0, (
            f"{label}: expected bist_error=0 for non-overflow replacement counting"
        )
        assert status0["error_count"] == expected_error_count, (
            f"{label}: expected error_count={expected_error_count}, got {status0['error_count']}"
        )
        await clear_bist_error_without_running(apb)

    async def run_stop_on_repl_of_overflow_case(
        label,
        *,
        bank=0,
        start_addr,
        stop_addr,
        target_loop=0,
        pattern,
        force_after_completed_reads=1,
        overflow_in_reads=10,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        bank_u = my_tb.get_behavioral_bank(bank)
        await clear_bist_error_without_running(apb)

        words_per_loop = stop_addr - start_addr + 1
        assert words_per_loop > force_after_completed_reads + overflow_in_reads, (
            f"{label}: need at least {force_after_completed_reads + overflow_in_reads + 1} "
            "words in range to test overflow cleanly"
        )

        errors_per_read = MASK79.bit_count()
        forced_error_count = (1 << 16) - (overflow_in_reads * errors_per_read)
        reads_before_force = target_loop * words_per_loop + force_after_completed_reads
        first_overflow_read_ordinal = reads_before_force + overflow_in_reads
        expected_err_add = start_addr + force_after_completed_reads + overflow_in_reads - 1

        fill_range(bank, start_addr, stop_addr, pattern)

        await configure_bist_pattern(apb, din=pattern, bwe=MASK79)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=1,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=0,
            loop_count=target_loop,
            data_inv=0,
            stop_on_error=0,
            stop_on_repl_of=1,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )

        dut._log.info(
            "%s bank=%d start=0x%05x stop=0x%05x target_loop=%d "
            "force_after=%d overflow_reads=%d",
            label,
            bank,
            start_addr,
            stop_addr,
            target_loop,
            force_after_completed_reads,
            overflow_in_reads,
        )

        await pulse_bist_start(apb)

        completed_reads = 0
        counter_forced = False
        while completed_reads < first_overflow_read_ordinal:
            addr_value = await wait_for_bank_access(bank_u, is_write=False, timeout_ns=timeout_ns)
            expected_addr = start_addr + (completed_reads % words_per_loop)
            assert addr_value == expected_addr, (
                f"{label}: read sequence mismatch before overflow forcing: "
                f"expected addr=0x{expected_addr:05x}, got 0x{addr_value:05x}"
            )

            await wait_for_bank_access_complete(bank_u, timeout_ns=timeout_ns)
            completed_reads += 1

            if (not counter_forced) and (completed_reads == reads_before_force):
                force_bist_error_count(bank, forced_error_count)
                for offset in range(overflow_in_reads):
                    write_mem_word(bank, start_addr + force_after_completed_reads + offset, pattern ^ MASK79)
                counter_forced = True

        status1 = await wait_bist_done(apb, timeout_ns=timeout_ns)
        status0 = await read_status0(apb)
        assert status1["bist_error"] == 1, (
            f"{label}: expected bist_error=1 after stop_on_repl_of overflow, "
            f"got {status1['bist_error']}"
        )
        assert status1["bist_err_add"] == expected_err_add, (
            f"{label}: expected err_add=0x{expected_err_add:05x}, "
            f"got 0x{status1['bist_err_add']:05x}"
        )
        assert status0["error_loop"] == target_loop, (
            f"{label}: expected error_loop={target_loop}, got {status0['error_loop']}"
        )
        assert status0["error_count"] == (1 << 16), (
            f"{label}: expected error_count overflow sentinel 0x10000, "
            f"got 0x{status0['error_count']:05x}"
        )
        await clear_bist_error_without_running(apb)

    mark_matrix("BIST READ matrix: unsupported ET-only hooks")
    dut._log.warning("`bist_rst_b` and `disable_clock_gate` are ET-only and are not present on IRAM")
    dut._log.info("Per bist.bsv, read mode selects stop_on_error or stop_on_repl_of; combined-mode overflow checks are excluded")

    mark_matrix("BIST READ matrix: baseline bank coverage")
    for bank in range(active_wrappers):
        pattern = (0x0345_6789_ABCD_EF01_111 + bank) & MASK79
        start_addr = 0x00100 + (bank * 0x20)
        stop_addr = start_addr + 7
        fill_range(bank, start_addr, stop_addr, pattern)
        result = await run_read_bist(
            f"baseline_bank{bank}",
            bank=bank,
            pattern=pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: start retrigger while active")
    retrigger_pattern = 0x0123_4567_89AB_CDEF_210 & MASK79
    fill_range(0, 0x00180, 0x001BF, retrigger_pattern)
    retrigger_result = await run_read_bist(
        "start_retrigger",
        bank=0,
        pattern=retrigger_pattern,
        start_addr=0x00180,
        stop_addr=0x001BF,
        retrigger_while_busy=True,
    )
    assert retrigger_result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: data_inv loop parity")
    inv_pattern = 0x01C0_FFEE_CAFE_BABE_234 & MASK79
    data_inv_result = await run_read_bist(
        "data_inv_loop1",
        bank=0,
        pattern=inv_pattern,
        start_addr=0x00200,
        stop_addr=0x00203,
        loop_count=1,
        data_inv=True,
    )
    assert data_inv_result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: add_inc sweep")
    add_inc_pattern = 0x0077_8888_9999_AAAA_666 & MASK79
    for add_inc in range(8):
        start_addr = 0x00240
        stop_addr = start_addr + max(4, (1 << add_inc) * 3)
        fill_range(0, start_addr, stop_addr, add_inc_pattern)
        result = await run_read_bist(
            f"add_inc_{add_inc}",
            bank=0,
            pattern=add_inc_pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
            add_inc=add_inc,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: loop_count sweep")
    loop_pattern_value = 0x0555_6666_7777_8888_111 & MASK79
    for loop_count in range(4):
        result = await run_read_bist(
            f"loop_count_{loop_count}",
            bank=0,
            pattern=loop_pattern_value,
            start_addr=0x002C0 + (loop_count * 0x10),
            stop_addr=0x002C3 + (loop_count * 0x10),
            loop_count=loop_count,
            data_inv=True,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: address corners and boundaries")
    boundary_pattern = 0x03A5_5A5A_0F0F_F0F0_244 & MASK79
    boundary_cases = (
        ("addr_low_edge", 0x00000, 0x00000),
        ("addr_row_boundary", 0x0000F, 0x00010),
        ("addr_stripe_boundary_0", 0x1FFFF, 0x20000),
        ("addr_stripe_boundary_1", 0x3FFFF, 0x40000),
        ("addr_high_edge", 0xFFFFF, 0xFFFFF),
    )
    for label, start_addr, stop_addr in boundary_cases:
        fill_range(0, start_addr, stop_addr, boundary_pattern)
        result = await run_read_bist(
            label,
            bank=0,
            pattern=boundary_pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST READ matrix: stop_on_error first/middle/last across loops 0/1/2")
    error_pattern = 0x0444_2222_1111_9999_666 & MASK79
    for target_loop in range(3):
        for suffix, error_addr in (
            ("first", 0x00320),
            ("middle", 0x00323),
            ("last", 0x00327),
        ):
            await run_stop_on_error_case(
                f"stop_on_error_loop{target_loop}_{suffix}",
                bank=0,
                target_loop=target_loop,
                data_inv=False,
                start_addr=0x00320,
                stop_addr=0x00327,
                error_addr=error_addr,
                pattern=error_pattern,
            )

    mark_matrix("BIST READ matrix: stop_on_error with data_inv")
    for target_loop in (0, 1):
        await run_stop_on_error_case(
            f"stop_on_error_datainv_loop{target_loop}",
            bank=0,
            target_loop=target_loop,
            data_inv=True,
            start_addr=0x00360,
            stop_addr=0x00365,
            error_addr=0x00362,
            pattern=0x0123_0000_4444_8888_211 & MASK79,
            corrupt_mask=0x3,
        )

    mark_matrix("BIST READ matrix: continue after stop_on_error")
    await run_continue_case(
        "continue_loop0_clustered",
        bank=0,
        loop_count=0,
        data_inv=False,
        start_addr=0x003A0,
        stop_addr=0x003A7,
        error_plan_by_loop={0: (0x003A1, 0x003A4, 0x003A6)},
        pattern=0x01AA_BBCC_DDEE_F001_211 & MASK79,
    )
    await run_continue_case(
        "continue_loop1_sparse_datainv",
        bank=0,
        loop_count=1,
        data_inv=True,
        start_addr=0x003C0,
        stop_addr=0x003C7,
        error_plan_by_loop={0: (0x003C2,), 1: (0x003C5,)},
        pattern=0x01AA_BBCC_DDEE_F001_212 & MASK79,
    )

    mark_matrix("BIST READ matrix: bist_stop_on_repl_of accumulation")
    await run_stop_on_repl_of_case(
        "stop_on_repl_of_accumulates_multiple_errors",
        bank=0,
        start_addr=0x00420,
        stop_addr=0x00427,
        injected_errors={
            0x00420: 0x1,
            0x00422: 0x3,
            0x00425: 0x7F,
        },
        bwe=MASK79,
        pattern=0x0123_4567_89AB_CDEF_123 & MASK79,
    )

    mark_matrix("BIST READ matrix: per-bit BWE mask-off sweep")
    mask_sweep_pattern = 0x0234_5678_9ABC_DEF0_456 & MASK79
    for bit_idx in range(79):
        await run_stop_on_repl_of_case(
            f"stop_on_repl_of_bwe_masks_bit_{bit_idx}",
            bank=0,
            start_addr=0x00440,
            stop_addr=0x00440,
            injected_errors={0x00440: 1 << bit_idx},
            bwe=MASK79 ^ (1 << bit_idx),
            pattern=mask_sweep_pattern,
            expected_error_count=0,
        )

    mark_matrix("BIST READ matrix: stop_on_repl_of overflow")
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_latches_loop0",
        bank=0,
        start_addr=0x00460,
        stop_addr=0x00477,
        target_loop=0,
        pattern=0x0555_AAAA_1234_5678_111 & MASK79,
    )
    await run_stop_on_repl_of_overflow_case(
        "stop_on_repl_of_overflow_latches_loop1",
        bank=0,
        start_addr=0x004A0,
        stop_addr=0x004B7,
        target_loop=1,
        pattern=0x0777_CCCC_3456_789A_333 & MASK79,
    )

    mark_matrix("BIST READ matrix: bist_reset idle pulse")
    apb = my_tb.apb_master(0)
    await pulse_bist_reset_idle(apb)
    idle_status = await read_status1(apb)
    assert idle_status["bist_busy"] == 0

    mark_matrix("BIST READ matrix: bist_reset while active and recovery")
    reset_pattern = 0x0456_1234_5678_9ABC_111 & MASK79
    fill_range(0, 0x004C0, 0x004FF, reset_pattern)
    await clear_bist_error_without_running(apb)
    await configure_bist_pattern(apb, din=reset_pattern, bwe=MASK79)
    await configure_bist(
        apb,
        wr_en=0,
        rd_en=1,
        rte_en=0,
        bist_reset=0,
        start_add=0x004C0,
        stop_add=0x004FF,
        add_inc=0,
        loop_count=0,
        data_inv=0,
        stop_on_error=0,
        stop_on_repl_of=0,
        trim_mode=0,
        rh4_margin=0,
        ref_prg_en=0,
        test_reg_ovr_en=0,
    )
    await pulse_bist_start(apb)
    bank_u = my_tb.get_behavioral_bank(0)
    await wait_for_bank_access(bank_u, is_write=False)
    await configure_bist(apb, bist_reset=1)
    await configure_bist(apb, bist_reset=0, wr_en=0, rd_en=0, rte_en=0)
    await my_tb.reset_sequence()
    fill_range(0, 0x004C0, 0x004FF, reset_pattern)
    recovery = await run_read_bist(
        "post_reset_recovery",
        bank=0,
        pattern=reset_pattern,
        start_addr=0x004C0,
        stop_addr=0x004FF,
    )
    assert recovery["status1"]["bist_error"] == 0
