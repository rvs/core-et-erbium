import cocotb
from cocotb.triggers import Timer

from tb import my_tb, seed_rng
from tests.bist_common import (
    MASK79,
    clear_bist_error_without_running,
    configure_bist,
    configure_bist_pattern,
    pulse_bist_reset_idle,
    pulse_bist_start,
    read_mem_word,
    read_status1,
    rtl_write_bist_data,
    wait_bist_done,
    wait_for_bank_access,
    wait_for_bank_access_complete,
    write_mem_word,
)


# WRITE BIST COVERAGE MATRIX
# - [x] Baseline completion + status readability.
# - [x] Start retrigger while active.
# - [x] `bist_data_inv` loop-parity behavior.
# - [x] `bist_add_inc` sweep (0..7).
# - [x] Address corners and boundary ranges across row/stripe/high-edge windows.
# - [x] `bist_loop_count` sweep.
# - [x] `bist_reset` while idle and while active, plus reset recovery.
# - [x] Active bank coverage across all instantiated wrappers.
# - [ ] Write-mode `bist_stop_on_error` exists in `bist.bsv`, but targeted IRAM fault-injection coverage is not implemented in this file yet.
# - [ ] `bist_stop_on_repl_of` / error counting / replacement are not supported on non-ET IRAM.
# - [ ] `bist_rst_b` is ET-only; non-ET does not expose it.
# - [ ] Clock-gate control is ET-only; non-ET does not expose it.
# - [ ] RTE-only controls (`bist_trim_mode`, `bist_rte_en`, `RH4margin`, `rh2_offset`) are excluded here.


@cocotb.test()
async def bist_write_basic(dut):
    """BIST write matrix for non-ET IRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("bist_write_basic")
    await my_tb.reset_sequence()
    seed_rng(778)

    active_wrappers = my_tb.num_wrappers()
    assert active_wrappers >= 1

    def mark_matrix(label):
        my_tb.set_wave_matrix_label(label)
        dut._log.info(label)

    def clear_range(bank, start_addr, stop_addr, value=0):
        for addr in range(start_addr, stop_addr + 1):
            write_mem_word(bank, addr, value)

    def expected_loop_pattern(pattern, data_inv, loop_idx):
        return rtl_write_bist_data(pattern, data_inv=data_inv, loop_count=loop_idx) & MASK79

    def assert_selected_addresses(
        label,
        *,
        bank,
        start_addr,
        stop_addr,
        expected_by_addr,
        default_value=0,
    ):
        for addr in range(start_addr, stop_addr + 1):
            observed = read_mem_word(bank, addr)
            expected = expected_by_addr.get(addr, default_value)
            assert observed == expected, (
                f"{label}: addr=0x{addr:05x} expected 0x{expected:020x}, "
                f"got 0x{observed:020x}"
            )

    async def run_write_bist(
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
        retrigger_while_busy=False,
        timeout_ns=40_000,
    ):
        apb = my_tb.apb_master(bank)
        await clear_bist_error_without_running(apb)
        await configure_bist_pattern(apb, din=pattern, bwe=bwe)
        await configure_bist(
            apb,
            wr_en=1,
            rd_en=0,
            rte_en=0,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=add_inc,
            loop_count=loop_count,
            data_inv=int(data_inv),
            stop_on_error=0,
            stop_on_repl_of=0,
            trim_mode=0,
            rh4_margin=0,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )

        dut._log.info(
            "%s bank=%d start=0x%05x stop=0x%05x add_inc=%d loop_count=%d data_inv=%d "
            "pattern=0x%020x bwe=0x%020x",
            label,
            bank,
            start_addr,
            stop_addr,
            add_inc,
            loop_count,
            int(data_inv),
            pattern,
            bwe,
        )

        await pulse_bist_start(apb)
        if retrigger_while_busy:
            await Timer(20, unit="ns")
            status = await read_status1(apb)
            if status["bist_busy"]:
                dut._log.info("%s retriggering start while busy", label)
                await pulse_bist_start(apb)

        status = await wait_bist_done(apb, timeout_ns=timeout_ns)
        return {
            "status1": status,
        }

    mark_matrix("BIST WRITE matrix: unsupported ET-only hooks")
    dut._log.warning("`bist_rst_b` and `disable_clock_gate` are ET-only and are not present on IRAM")
    dut._log.warning("`bist_stop_on_repl_of` / error counting / replacement are not present on IRAM")

    mark_matrix("BIST WRITE matrix: baseline bank coverage")
    for bank in range(active_wrappers):
        pattern = (0x0123_4567_89AB_CDEF_000 + bank) & MASK79
        start_addr = 0x00020 + (bank * 0x20)
        stop_addr = start_addr + 7
        clear_range(bank, start_addr, stop_addr, 0)
        result = await run_write_bist(
            f"baseline_bank{bank}",
            bank=bank,
            pattern=pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
            loop_count=0,
        )
        assert result["status1"]["bist_error"] == 0
        expected = {addr: pattern for addr in range(start_addr, stop_addr + 1)}
        assert_selected_addresses(
            f"baseline_bank{bank}",
            bank=bank,
            start_addr=start_addr,
            stop_addr=stop_addr,
            expected_by_addr=expected,
        )

    mark_matrix("BIST WRITE matrix: start retrigger while active")
    retrigger_pattern = 0x0555_3333_9999_AAAA_111 & MASK79
    retrigger_start = 0x00100
    retrigger_stop = retrigger_start + 0x3F
    clear_range(0, retrigger_start, retrigger_stop, 0)
    retrigger_result = await run_write_bist(
        "start_retrigger",
        bank=0,
        pattern=retrigger_pattern,
        start_addr=retrigger_start,
        stop_addr=retrigger_stop,
        retrigger_while_busy=True,
    )
    assert retrigger_result["status1"]["bist_error"] == 0

    mark_matrix("BIST WRITE matrix: data_inv loop parity")
    inv_pattern = 0x01C0_FFEE_CAFE_BABE_123 & MASK79
    inv_start = 0x00200
    inv_stop = inv_start + 3
    clear_range(0, inv_start, inv_stop, 0)
    inv_result = await run_write_bist(
        "data_inv_loop1",
        bank=0,
        pattern=inv_pattern,
        start_addr=inv_start,
        stop_addr=inv_stop,
        loop_count=1,
        data_inv=True,
    )
    assert inv_result["status1"]["bist_error"] == 0
    inv_expected = expected_loop_pattern(inv_pattern, True, 1)
    assert_selected_addresses(
        "data_inv_loop1",
        bank=0,
        start_addr=inv_start,
        stop_addr=inv_stop,
        expected_by_addr={addr: inv_expected for addr in range(inv_start, inv_stop + 1)},
    )

    mark_matrix("BIST WRITE matrix: add_inc sweep")
    add_inc_pattern = 0x0077_8888_9999_AAAA_555 & MASK79
    for add_inc in range(8):
        start_addr = 0x00300
        stop_addr = start_addr + max(4, (1 << add_inc) * 3)
        clear_range(0, start_addr, stop_addr, 0)
        result = await run_write_bist(
            f"add_inc_{add_inc}",
            bank=0,
            pattern=add_inc_pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
            add_inc=add_inc,
        )
        assert result["status1"]["bist_error"] == 0
        step = 1 << add_inc
        expected = {addr: add_inc_pattern for addr in range(start_addr, stop_addr + 1, step)}
        assert_selected_addresses(
            f"add_inc_{add_inc}",
            bank=0,
            start_addr=start_addr,
            stop_addr=stop_addr,
            expected_by_addr=expected,
        )

    mark_matrix("BIST WRITE matrix: loop_count sweep")
    loop_pattern_value = 0x0666_7777_8888_9999_123 & MASK79
    for loop_count in range(4):
        start_addr = 0x00400 + (loop_count * 0x10)
        stop_addr = start_addr + 3
        clear_range(0, start_addr, stop_addr, 0)
        result = await run_write_bist(
            f"loop_count_{loop_count}",
            bank=0,
            pattern=loop_pattern_value,
            start_addr=start_addr,
            stop_addr=stop_addr,
            loop_count=loop_count,
            data_inv=True,
        )
        assert result["status1"]["bist_error"] == 0
        expected = expected_loop_pattern(loop_pattern_value, True, loop_count)
        assert_selected_addresses(
            f"loop_count_{loop_count}",
            bank=0,
            start_addr=start_addr,
            stop_addr=stop_addr,
            expected_by_addr={addr: expected for addr in range(start_addr, stop_addr + 1)},
        )

    mark_matrix("BIST WRITE matrix: address corners and boundaries")
    boundary_pattern = 0x03A5_5A5A_0F0F_F0F0_155 & MASK79
    boundary_cases = (
        ("addr_low_edge", 0x00000, 0x00000),
        ("addr_row_boundary", 0x0000F, 0x00010),
        ("addr_mid_row_window", 0x001F0, 0x001FF),
        ("addr_stripe_boundary_0", 0x1FFFF, 0x20000),
        ("addr_stripe_boundary_1", 0x3FFFF, 0x40000),
        ("addr_high_edge", 0xFFFFF, 0xFFFFF),
    )
    for label, start_addr, stop_addr in boundary_cases:
        clear_range(0, start_addr, stop_addr, 0)
        result = await run_write_bist(
            label,
            bank=0,
            pattern=boundary_pattern,
            start_addr=start_addr,
            stop_addr=stop_addr,
        )
        assert result["status1"]["bist_error"] == 0
        assert_selected_addresses(
            label,
            bank=0,
            start_addr=start_addr,
            stop_addr=stop_addr,
            expected_by_addr={addr: boundary_pattern for addr in range(start_addr, stop_addr + 1)},
        )

    mark_matrix("BIST WRITE matrix: write stop_on_error coverage deferred")
    dut._log.warning("`bist.bsv` includes write-mode stop_on_error, but this IRAM test still needs targeted fault-injection coverage for that path")

    mark_matrix("BIST WRITE matrix: error counting / replacement unsupported")
    dut._log.warning("Skipping write-mode error counting and replacement checks because non-ET IRAM does not support them")

    mark_matrix("BIST WRITE matrix: bist_reset idle pulse")
    apb = my_tb.apb_master(0)
    await pulse_bist_reset_idle(apb)
    idle_reset_status = await read_status1(apb)
    assert idle_reset_status["bist_busy"] == 0

    mark_matrix("BIST WRITE matrix: bist_reset while active and recovery")
    reset_pattern = 0x0456_1234_5678_9ABC_DEF & MASK79
    reset_start = 0x00700
    reset_stop = 0x0073F
    clear_range(0, reset_start, reset_stop, 0)
    await clear_bist_error_without_running(apb)
    await configure_bist_pattern(apb, din=reset_pattern, bwe=MASK79)
    await configure_bist(
        apb,
        wr_en=1,
        rd_en=0,
        rte_en=0,
        bist_reset=0,
        start_add=reset_start,
        stop_add=reset_stop,
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
    await wait_for_bank_access(bank_u, is_write=True)
    await configure_bist(apb, bist_reset=1)
    await Timer(20, unit="ns")
    await configure_bist(apb, bist_reset=0, wr_en=0, rd_en=0, rte_en=0)
    await my_tb.reset_sequence()
    apb = my_tb.apb_master(0)
    clear_range(0, reset_start, reset_stop, 0)
    recovery_result = await run_write_bist(
        "post_reset_recovery",
        bank=0,
        pattern=reset_pattern,
        start_addr=reset_start,
        stop_addr=reset_stop,
    )
    assert recovery_result["status1"]["bist_error"] == 0
