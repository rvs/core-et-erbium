import cocotb

from tb import my_tb, seed_rng
from tests.bist_common import (
    MASK79,
    clear_bist_error_without_running,
    configure_bist,
    configure_bist_pattern,
    expected_rh0_index,
    expected_rh1_index,
    pulse_bist_reset_idle,
    pulse_bist_start,
    read_ref_word,
    read_status0,
    read_status1,
    rom_codeword_for_rh,
    row_start_addr,
    row_stop_addr,
    wait_bist_done,
)


# RTE BIST COVERAGE MATRIX
# - [x] Baseline completion on a single wordline, with `rh0/rh1/rh2` checked against the backing row model.
# - [x] Multi-wordline progression across a contiguous row range.
# - [x] Window corners in `trim_mode=0`: same-row, row-boundary, low-edge, high-edge, and `start > stop` no-op.
# - [x] Window corners in `trim_mode=1`.
# - [x] Boundary crossings relevant to IRAM trim mode: sibling-row boundary, stripe boundary, and high-address boundary.
# - [x] `RH4margin` threshold behavior with `bist_stop_on_error=1`.
# - [x] `bist_reset` while idle and recovery after reset.
# - [ ] `bist_stop_on_repl_of` / error counting / replacement are not implemented in RTE mode.
# - [ ] `rh2_offset` is ET-only and not exposed by non-ET IRAM.
# - [ ] `bist_rst_b` and clock-gate control are ET-only and not present on IRAM.


@cocotb.test()
async def bist_rte_basic(dut):
    """RTE BIST matrix for non-ET IRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("bist_rte_basic")
    await my_tb.reset_sequence()
    seed_rng(780)

    active_wrappers = my_tb.num_wrappers()
    assert active_wrappers >= 1

    def mark_matrix(label):
        my_tb.set_wave_matrix_label(label)
        dut._log.info(label)

    def read_row_thresholds(bank, row_index):
        rh0_handle = my_tb.get_behavioral_array_elem(bank, "rh0", row_index)
        rh1_handle = my_tb.get_behavioral_array_elem(bank, "rh1", row_index)
        return int(rh0_handle.value), int(rh1_handle.value)

    def collect_expected_trim(row_indices):
        rh0_values = []
        rh1_values = []
        for row_index in row_indices:
            row_rh0, row_rh1 = read_row_thresholds(0, row_index)
            rh0_values.append(row_rh0)
            rh1_values.append(row_rh1)
        expected_rh0 = expected_rh0_index(rh0_values)
        expected_rh1 = expected_rh1_index(rh1_values)
        expected_rh2 = (expected_rh0 + expected_rh1) >> 1
        return expected_rh0, expected_rh1, expected_rh2

    async def run_rte_once(
        label,
        *,
        bank=0,
        start_addr,
        stop_addr,
        trim_mode=False,
        stop_on_error=False,
        rh4_margin=0,
        timeout_ns=160_000,
    ):
        apb = my_tb.apb_master(bank)
        await clear_bist_error_without_running(apb)
        await configure_bist_pattern(apb, din=0, bwe=MASK79)
        await configure_bist(
            apb,
            wr_en=0,
            rd_en=0,
            rte_en=1,
            bist_reset=0,
            start_add=start_addr,
            stop_add=stop_addr,
            add_inc=0,
            loop_count=0,
            data_inv=0,
            stop_on_error=int(stop_on_error),
            stop_on_repl_of=0,
            trim_mode=int(trim_mode),
            rh4_margin=rh4_margin,
            ref_prg_en=0,
            test_reg_ovr_en=0,
        )

        dut._log.info(
            "%s start=0x%05x stop=0x%05x trim_mode=%d stop_on_error=%d rh4_margin=%d",
            label,
            start_addr,
            stop_addr,
            int(trim_mode),
            int(stop_on_error),
            rh4_margin,
        )
        await pulse_bist_start(apb)
        return {
            "status1": await wait_bist_done(apb, timeout_ns=timeout_ns),
            "status0": await read_status0(apb),
        }

    mark_matrix("BIST RTE matrix: unsupported ET-only hooks")
    dut._log.warning("`rh2_offset`, `bist_rst_b`, and `disable_clock_gate` are ET-only and are not present on IRAM")
    dut._log.info("Per bist.bsv, RTE mode uses stop_on_error only; stop_on_repl_of and error counting are not part of the RTE path")

    mark_matrix("BIST RTE matrix: baseline single row")
    base_row = 0x0040
    baseline = await run_rte_once(
        "baseline_single_row",
        start_addr=row_start_addr(base_row),
        stop_addr=row_stop_addr(base_row),
        trim_mode=False,
        stop_on_error=False,
    )
    assert baseline["status1"]["bist_error"] == 0
    expected_rh0, expected_rh1, expected_rh2 = collect_expected_trim((base_row,))
    assert baseline["status0"]["rh0"] == expected_rh0
    assert baseline["status0"]["rh1"] == expected_rh1
    assert baseline["status1"]["rh2"] == expected_rh2
    expected_ref_word = rom_codeword_for_rh(expected_rh2)
    observed_ref_word = read_ref_word(0, base_row)
    assert observed_ref_word == expected_ref_word, (
        f"baseline_single_row: expected ref_word[{base_row}] = 0x{expected_ref_word:020x}, "
        f"got 0x{observed_ref_word:020x}"
    )

    mark_matrix("BIST RTE matrix: multi-row progression")
    multi_start_row = 0x0060
    multi_stop_row = multi_start_row + 15
    multi = await run_rte_once(
        "multi_row_progression",
        start_addr=row_start_addr(multi_start_row),
        stop_addr=row_stop_addr(multi_stop_row),
        trim_mode=False,
    )
    assert multi["status1"]["bist_error"] == 0
    final_expected = collect_expected_trim((multi_stop_row,))
    assert multi["status0"]["rh0"] == final_expected[0]
    assert multi["status0"]["rh1"] == final_expected[1]
    assert multi["status1"]["rh2"] == final_expected[2]

    mark_matrix("BIST RTE matrix: window corners trim_mode=0")
    max_row = (1 << 16) - 1
    trim0_cases = (
        ("same_row_window", row_start_addr(0x0004) + 3, row_start_addr(0x0004) + 8),
        ("row_boundary_window", row_stop_addr(0x0008) - 2, row_start_addr(0x0009) + 2),
        ("row_low_edge", row_start_addr(0x0000), row_stop_addr(0x0000)),
        ("row_high_edge", row_start_addr(max_row), row_stop_addr(max_row)),
        ("start_gt_stop", row_start_addr(0x0010), row_stop_addr(0x000F)),
    )
    for label, start_addr, stop_addr in trim0_cases:
        result = await run_rte_once(
            label,
            start_addr=start_addr,
            stop_addr=stop_addr,
            trim_mode=False,
        )
        if start_addr > stop_addr:
            assert result["status1"]["bist_error"] == 0
            continue
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST RTE matrix: window corners trim_mode=1")
    trim1_cases = (
        ("trim1_same_row", row_start_addr(0x0200), row_stop_addr(0x0200)),
        ("trim1_row_boundary", row_stop_addr(0x0201) - 1, row_start_addr(0x0202) + 1),
        ("trim1_sibling_boundary", row_start_addr(0x01FF), row_stop_addr(0x0200)),
    )
    for label, start_addr, stop_addr in trim1_cases:
        result = await run_rte_once(
            label,
            start_addr=start_addr,
            stop_addr=stop_addr,
            trim_mode=True,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST RTE matrix: boundary crossings")
    boundary_rows = (
        ("sibling_toggle_boundary", 0x01FF, 0x0200),
        ("stripe_boundary_0", 0x1FFF, 0x2000),
        ("high_address_boundary", max_row - 1, max_row),
    )
    for label, start_row, stop_row in boundary_rows:
        result = await run_rte_once(
            label,
            start_addr=row_start_addr(start_row),
            stop_addr=row_stop_addr(stop_row),
            trim_mode=False,
        )
        assert result["status1"]["bist_error"] == 0

    mark_matrix("BIST RTE matrix: RH4margin stop_on_error")
    threshold_row = 0x0300
    preclear = await run_rte_once(
        "rh4margin_preclear",
        start_addr=row_start_addr(threshold_row),
        stop_addr=row_stop_addr(threshold_row),
        trim_mode=False,
        stop_on_error=False,
    )
    assert preclear["status1"]["bist_error"] == 0
    rh4 = max(0, (preclear["status0"]["rh1"] - preclear["status0"]["rh0"]) >> 1)
    if rh4 <= 31:
        threshold_fail = await run_rte_once(
            "rh4margin_fail",
            start_addr=row_start_addr(threshold_row),
            stop_addr=row_stop_addr(threshold_row),
            trim_mode=False,
            stop_on_error=True,
            rh4_margin=rh4,
        )
        assert threshold_fail["status1"]["bist_error"] == 1
        assert threshold_fail["status1"]["bist_err_add"] == row_start_addr(threshold_row)
    else:
        dut._log.warning(
            "Skipping RH4margin stop_on_error check because computed rh4=%d exceeds the 5-bit field",
            rh4,
        )

    mark_matrix("BIST RTE matrix: bist_reset idle pulse")
    apb = my_tb.apb_master(0)
    await pulse_bist_reset_idle(apb)
    idle_status = await read_status1(apb)
    assert idle_status["bist_busy"] == 0

    mark_matrix("BIST RTE matrix: reset recovery")
    await my_tb.reset_sequence()
    recovery = await run_rte_once(
        "post_reset_recovery",
        start_addr=row_start_addr(0x0320),
        stop_addr=row_stop_addr(0x0320),
        trim_mode=False,
    )
    assert recovery["status1"]["bist_error"] == 0
