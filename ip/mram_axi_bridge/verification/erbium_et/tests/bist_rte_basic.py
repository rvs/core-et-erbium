import cocotb
from functools import lru_cache
from pathlib import Path
import re
from cocotb.triggers import Timer
from tb import *


_REPO_ROOT = Path(__file__).resolve().parents[3]
_ECC_ROM_WRAPPER_PATH = _REPO_ROOT / "mram_controller" / "verilog" / "ecc_rom_wrapper.sv"
_ROM_16KB_TOP_PATH = _REPO_ROOT / "mram_controller" / "verilog" / "rom_16kb_top.v"

# RTE BIST USAGE GUIDE
# - Bring-up requirements:
#   - Assert `bist_rst_b=1` on every bank before using mkEtBist through the
#     test-register path.
#   - Keep bridge clock gating disabled (`disable_clock_gate=0xF`) while using
#     MRAM test registers.
#   - Program full BWE before starting RTE. The current model expects the trim
#     flow to operate with all 79 bits enabled.
#   - If a prior run latched `bist_error`, clear it before the next run with:
#       1. `bist_wr_en=0`, `bist_rd_en=0`, `bist_rte_en=0`
#       2. assert `bist_reset=1`
#       3. pulse `bist_start=1`
#       4. deassert `bist_start` and `bist_reset`
# - Programming model:
#   - RTE BIST is selected with `bist_rte_en=1`, `bist_rd_en=0`, `bist_wr_en=0`.
#   - Address iteration is row-based. The BSV walks `start_addr[19:4]` through
#     `stop_addr[19:4]`, so lower column bits only affect window endpoints, not
#     the per-row progression step.
#   - Current RTE controls exercised here:
#     - `bist_trim_mode`
#     - `RH4margin`
#     - `rh2_offset`
#     - `bist_stop_on_error`
#     - `bist_start_add` / `bist_stop_add`
#   - `bist_trim_mode=0` trims the directly addressed rows.
#   - `bist_trim_mode=1` also evaluates the sibling plane. The current BSV
#     stepping intentionally skips every second plane at the outer-loop level,
#     so block crossings are the meaningful trim-mode boundary case. Plane-by-
#     plane crossings are intentionally not expected in trim mode.
# - Comparison model used by this test:
#   - The reference trim path is not BCH-based. Expected RH behavior is derived
#     from the actual reference encoding path:
#       - `hamming_encoder.sv`
#       - `ref_ecc_encoder.sv`
#       - `ecc_rom_wrapper.sv`
#   - Expected `rh0`/`rh1` are based on ROM codeword one-counts, matching the
#     design intent that the chosen RH sits one codeword step below fully clear.
#   - In `trim_mode=0`:
#       - `rh0` is checked against the max per-word threshold in the row.
#       - `rh1` is checked against the min per-word threshold in the row.
#   - In `trim_mode=1`:
#       - the same row-local thresholds are combined with `ref_rh0/ref_rh1`
#         before computing the expected status values.
#   - `rh2` is checked both at the status-register level and against the
#     instance model's stored row RH value.
# - Stop-on-error semantics currently covered here:
#   - `bist_stop_on_error=1` is used for RH4-threshold failure detection.
#   - Resume/continue-after-stop behavior is not yet covered in this file.
#
# BIST RTE COVERAGE MATRIX
# - [x] Baseline completion on a single wordline, with `rh0/rh1/rh2` compared
#       against the backing MRAM instance hierarchy.
# - [x] Multi-wordline progression across a 16-row contiguous range.
# - [x] Window corners in `trim_mode=0`:
#       same-row windows, row-boundary windows, first/last normal row, first
#       redundant row, OTP row, and `start > stop` no-op.
# - [x] Window corners in `trim_mode=1`.
# - [x] Plane crossings in `trim_mode=0`.
# - [x] Block crossings in `trim_mode=0`.
# - [x] Instance crossings in `trim_mode=0`, using contiguous regular-space
#       addressing from the last normal row of instance N to the first normal
#       row of instance N+1.
# - [x] Block crossings in `trim_mode=1`, matching the sibling-plane stepping
#       behavior in the BSV.
# - [x] `RH4margin` threshold behavior with `bist_stop_on_error=1`, including
#       a retry at the default margin after the failure point is found.
# - [x] `rh2_offset` sweep from `-10` to `+10` in steps of `2`.
# - [ ] `bist_stop_on_error` resume/continue semantics.
# - [ ] Additional status-field sanity (`rh3`, `rh4`, etc.).
# - [ ] Reset and recovery behavior beyond the standard sticky-error clear.


@lru_cache(maxsize=1)
def rom_64_words():
    text = _ROM_16KB_TOP_PATH.read_text()
    match = re.search(r"reg \[63:0\] rom_memory \[256\] = \{(.*?)\};", text, re.S)
    if match is None:
        raise RuntimeError(f"Could not parse ROM contents from {_ROM_16KB_TOP_PATH}")
    words = [
        int(token.replace("_", ""), 16)
        for token in re.findall(r"64'h([0-9a-fA-F_]+)", match.group(1))
    ]
    if len(words) != 256:
        raise RuntimeError(
            f"Expected 256 ROM words in {_ROM_16KB_TOP_PATH}, found {len(words)}"
        )
    return tuple(words)


@lru_cache(maxsize=1)
def rom_79_overrides():
    text = _ECC_ROM_WRAPPER_PATH.read_text()
    overrides = {
        int(addr): int(value.replace("_", ""), 16)
        for addr, value in re.findall(r"(\d+):\s*rom_data\s*=\s*79'h([0-9a-fA-F_]+);", text)
    }
    if not overrides:
        raise RuntimeError(f"Could not parse ROM overrides from {_ECC_ROM_WRAPPER_PATH}")
    return overrides


def ref_hamming_encode_15_to_20(data_15):
    m = [(data_15 >> idx) & 1 for idx in range(15)]
    p0 = m[0] ^ m[1] ^ m[3] ^ m[4] ^ m[6] ^ m[8] ^ m[10] ^ m[11] ^ m[13]
    p1 = m[0] ^ m[2] ^ m[3] ^ m[5] ^ m[6] ^ m[9] ^ m[10] ^ m[12] ^ m[13]
    p2 = m[1] ^ m[2] ^ m[3] ^ m[7] ^ m[8] ^ m[9] ^ m[10] ^ m[14]
    p3 = m[4] ^ m[5] ^ m[6] ^ m[7] ^ m[8] ^ m[9] ^ m[10]
    p4 = m[11] ^ m[12] ^ m[13] ^ m[14]

    codeword = 0
    bit_map = {
        0: p0,
        1: p1,
        2: m[0],
        3: p2,
        4: m[1],
        5: m[2],
        6: m[3],
        7: p3,
        8: m[4],
        9: m[5],
        10: m[6],
        11: m[7],
        12: m[8],
        13: m[9],
        14: m[10],
        15: p4,
        16: m[11],
        17: m[12],
        18: m[13],
        19: m[14],
    }
    for bit_idx, bit_val in bit_map.items():
        codeword |= (bit_val & 1) << bit_idx
    return codeword


def ref_ecc_encode_64_to_79(data_64):
    data_64 &= (1 << 64) - 1
    encoded_word = 0
    for section_idx in range(4):
        section_data = (data_64 >> (15 * section_idx)) & ((1 << 15) - 1)
        section_codeword = ref_hamming_encode_15_to_20(section_data)
        encoded_word |= section_codeword << (20 * section_idx)

    codeword_out = 0
    codeword_out |= encoded_word & ((1 << 75) - 1)
    codeword_out |= ((encoded_word >> 76) & 0xF) << 75
    return codeword_out


def rom_codeword_for_rh(rh_idx):
    if not 0 <= rh_idx <= 79:
        raise ValueError(f"RH index out of range: {rh_idx}")
    overrides = rom_79_overrides()
    if rh_idx in overrides:
        return overrides[rh_idx]
    return ref_ecc_encode_64_to_79(rom_64_words()[rh_idx])


def rom_ones_for_rh(rh_idx):
    return rom_codeword_for_rh(rh_idx).bit_count()


def expected_rh0_index(row_rh0_values):
    row_threshold = max(row_rh0_values)
    for rh_idx in range(80):
        if rom_ones_for_rh(rh_idx) >= row_threshold:
            return max(rh_idx - 1, 0)
    raise AssertionError(f"No RH index reached clear threshold for rh0={row_threshold}")


def expected_rh1_index(row_rh1_values):
    row_threshold = min(row_rh1_values)
    candidates = [rh_idx for rh_idx in range(80) if rom_ones_for_rh(rh_idx) <= row_threshold]
    if not candidates:
        raise AssertionError(f"No RH index stayed at-or-below clear threshold for rh1={row_threshold}")
    return candidates[-1]


@cocotb.test()
async def bist_rte_basic(dut):
    """RTE BIST scaffold: bring-up, helpers, and matrix placeholder."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(780)

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

    def raw_addr_to_bist_target(inst_idx, raw_addr):
        return (((raw_addr >> 16) & 0x1) << 19) | ((inst_idx & 0x7) << 16) | (raw_addr & 0xFFFF)

    def raw_normal_addr(plane_idx, row_idx, col_idx):
        plane_addr = (row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    def raw_redundant_addr(plane_idx, redundant_row_idx, col_idx):
        plane_addr = (1 << (MRAM_NORM_ROW_ADDR_WIDTH + MRAM_COL_ADDR_WIDTH))
        plane_addr |= (redundant_row_idx << MRAM_COL_ADDR_WIDTH) | col_idx
        return my_tb.encode_mram_word_addr(plane_idx, plane_addr)

    def read_instance_rh_value(bank_idx, inst_idx, array_name, plane_idx, entry_idx):
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        instance_handle = my_tb._resolve_dut_path(instance._path)
        candidate_names = (f"{array_name}_dbg",)
        if instance_handle is not None:
            for candidate_name in candidate_names:
                array_h = my_tb._resolve_child_handle(instance_handle, candidate_name)
                if array_h is not None:
                    try:
                        plane_h = array_h[plane_idx]
                        return int(plane_h[entry_idx].value)
                    except Exception:
                        pass
                    try:
                        plane_h = array_h[plane_idx]
                        entry_h = my_tb._resolve_child_handle(plane_h, f"[{entry_idx}]")
                        if entry_h is not None:
                            return int(entry_h.value)
                    except Exception:
                        pass

                plane_h = my_tb._resolve_child_handle(instance_handle, f"{candidate_name}[{plane_idx}]")
                if plane_h is not None:
                    try:
                        return int(plane_h[entry_idx].value)
                    except Exception:
                        pass
                    entry_h = my_tb._resolve_child_handle(plane_h, f"[{entry_idx}]")
                    if entry_h is not None:
                        return int(entry_h.value)

                for child_name in (
                    f"{candidate_name}[{plane_idx}][{entry_idx}]",
                    f"{candidate_name}[{plane_idx}].[{entry_idx}]",
                ):
                    resolved = my_tb._resolve_child_handle(instance_handle, child_name)
                    if resolved is not None:
                        return int(resolved.value)

        for candidate_name in candidate_names:
            for path in (
                f"{instance._path}.{candidate_name}[{plane_idx}][{entry_idx}]",
                f"{instance._path}.{candidate_name}[{plane_idx}].[{entry_idx}]",
            ):
                resolved = my_tb._resolve_dut_path(path)
                if resolved is not None:
                    return int(resolved.value)

        raise IndexError(
            f"{instance._path}.{array_name}_dbg[{plane_idx}][{entry_idx}] could not be resolved"
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

    async def run_rte_case(
        label,
        *,
        bank=0,
        cfg_overrides=None,
        ctrl_overrides=None,
        timeout_ns=10_000,
    ):
        cfg_overrides = cfg_overrides or {}
        ctrl_overrides = ctrl_overrides or {}
        regs = bank_tregs(bank)
        full_bwe = (1 << 79) - 1

        # RTE BIST relies on the test-register BWE path being fully enabled.
        await write_mram_control_fields(regs, bwe=full_bwe)

        cfg = {
            "bist_rte_en": 1,
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
        await wait_bist_done(regs, label, timeout_ns=timeout_ns)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
            bist_rte_en=0,
            bist_wr_en=0,
            bist_rd_en=0,
        )
        await assert_status_resolvable(regs, label)

    def collect_row_trim_expectation(bank_idx, inst_idx, raw_row_start, *, rh2_offset=0, trim_mode=False):
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(raw_row_start)
        row_start_word = plane_addr
        row_stop_word = plane_addr + ((1 << MRAM_COL_ADDR_WIDTH) - 1)
        row_idx = plane_addr >> MRAM_COL_ADDR_WIDTH
        row_rh0_values = [
            read_instance_rh_value(bank_idx, inst_idx, "rh0", plane_idx, word_idx)
            for word_idx in range(row_start_word, row_stop_word + 1)
        ]
        row_rh1_values = [
            read_instance_rh_value(bank_idx, inst_idx, "rh1", plane_idx, word_idx)
            for word_idx in range(row_start_word, row_stop_word + 1)
        ]
        ref_rh0_value = read_instance_rh_value(bank_idx, inst_idx, "ref_rh0", plane_idx, row_idx)
        ref_rh1_value = read_instance_rh_value(bank_idx, inst_idx, "ref_rh1", plane_idx, row_idx)
        rh0_threshold_values = list(row_rh0_values)
        rh1_threshold_values = list(row_rh1_values)
        if trim_mode:
            rh0_threshold_values.append(ref_rh0_value)
            rh1_threshold_values.append(ref_rh1_value)
        expected_rh0 = expected_rh0_index(rh0_threshold_values)
        expected_rh1 = expected_rh1_index(rh1_threshold_values)
        expected_rh2 = ((expected_rh0 + expected_rh1) >> 1) + rh2_offset
        instance_rh2 = read_instance_rh_value(bank_idx, inst_idx, "rh2", plane_idx, row_idx)
        expected_instance_rh2 = rom_ones_for_rh(expected_rh2)
        return {
            "plane_idx": plane_idx,
            "row_idx": row_idx,
            "row_rh0_values": row_rh0_values,
            "row_rh1_values": row_rh1_values,
            "ref_rh0_value": ref_rh0_value,
            "ref_rh1_value": ref_rh1_value,
            "expected_rh0": expected_rh0,
            "expected_rh1": expected_rh1,
            "expected_rh2": expected_rh2,
            "expected_rh4": (expected_rh1 - expected_rh0) >> 1,
            "instance_rh2": instance_rh2,
            "expected_instance_rh2": expected_instance_rh2,
            "trim_mode": trim_mode,
        }

    async def assert_row_trim_status(
        regs,
        bank_idx,
        inst_idx,
        raw_row_start,
        label,
        *,
        rh2_offset=0,
        trim_mode=False,
    ):
        status_rh0 = int(await regs.mram_status_0.bist_rh0.read())
        status_rh1 = int(await regs.mram_status_0.bist_rh1.read())
        status_rh2 = int(await regs.mram_status_0.bist_rh2.read())
        row_expect = collect_row_trim_expectation(
            bank_idx,
            inst_idx,
            raw_row_start,
            rh2_offset=rh2_offset,
            trim_mode=trim_mode,
        )
        if trim_mode:
            dut._log.info(
                "RTE row RH snapshot: bank=%d inst=%d plane=%d row=%d trim_mode=1 rh0=%s rh1=%s ref_rh0=%d ref_rh1=%d",
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["row_rh0_values"],
                row_expect["row_rh1_values"],
                row_expect["ref_rh0_value"],
                row_expect["ref_rh1_value"],
            )
        else:
            dut._log.info(
                "RTE row RH snapshot: bank=%d inst=%d plane=%d row=%d rh0=%s",
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["row_rh0_values"],
            )
            dut._log.info(
                "RTE row RH snapshot: bank=%d inst=%d plane=%d row=%d rh1=%s",
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["row_rh1_values"],
            )
        dut._log.info(
            "RTE trim compare: bank=%d inst=%d plane=%d row=%d trim_mode=%d status_rh0=%d status_rh1=%d status_rh2=%d expected_rh0=%d expected_rh1=%d expected_rh2=%d instance_rh2=%d expected_instance_rh2=%d rom_ones(status_rh0)=%d rom_ones(status_rh1)=%d rom_ones(status_rh2)=%d",
            bank_idx,
            inst_idx,
            row_expect["plane_idx"],
            row_expect["row_idx"],
            1 if trim_mode else 0,
            status_rh0,
            status_rh1,
            status_rh2,
            row_expect["expected_rh0"],
            row_expect["expected_rh1"],
            row_expect["expected_rh2"],
            row_expect["instance_rh2"],
            row_expect["expected_instance_rh2"],
            rom_ones_for_rh(status_rh0),
            rom_ones_for_rh(status_rh1),
            rom_ones_for_rh(status_rh2),
        )

        assert status_rh0 == row_expect["expected_rh0"], (
            f"{label}: expected bist_rh0={row_expect['expected_rh0']}, got {status_rh0}"
        )
        assert status_rh1 == row_expect["expected_rh1"], (
            f"{label}: expected bist_rh1={row_expect['expected_rh1']}, got {status_rh1}"
        )
        assert status_rh2 == row_expect["expected_rh2"], (
            f"{label}: expected bist_rh2={row_expect['expected_rh2']}, got {status_rh2}"
        )
        assert row_expect["instance_rh2"] == row_expect["expected_instance_rh2"], (
            f"{label}: expected instance rh2={row_expect['expected_instance_rh2']}, "
            f"got {row_expect['instance_rh2']}"
        )
        return row_expect

    async def read_rte_status(regs):
        return {
            "bist_error": int(await regs.bist_status_1.bist_error.read()),
            "bist_err_add": int(await regs.bist_status_1.bist_err_add.read()),
            "bist_error_loop": int(await regs.mram_status_0.bist_error_loop.read()),
            "status_rh0": int(await regs.mram_status_0.bist_rh0.read()),
            "status_rh1": int(await regs.mram_status_0.bist_rh1.read()),
            "status_rh2": int(await regs.mram_status_0.bist_rh2.read()),
        }

    def encode_rh2_offset(offset):
        if not -16 <= offset <= 15:
            raise ValueError(f"rh2_offset out of 5-bit signed range: {offset}")
        return offset & 0x1F

    def find_candidate_row(bank_idx, inst_idx, plane_idx):
        for row_idx in range(1 << MRAM_NORM_ROW_ADDR_WIDTH):
            raw_row_start = raw_normal_addr(plane_idx, row_idx, 0)
            row_expect = collect_row_trim_expectation(bank_idx, inst_idx, raw_row_start)
            if (10 < row_expect["expected_rh4"] <= 30) and (10 <= row_expect["expected_rh2"] <= 69):
                row_expect["raw_row_start"] = raw_row_start
                row_expect["raw_row_stop"] = raw_normal_addr(plane_idx, row_idx, 15)
                return row_expect
        raise AssertionError(
            f"Could not find a candidate row for RH4margin/rh2_offset sweep in inst={inst_idx} plane={plane_idx}"
        )

    async def assert_rte_range_rows(bank_idx, start_target, stop_target, label):
        row_wordline_start = start_target >> MRAM_COL_ADDR_WIDTH
        row_wordline_stop = stop_target >> MRAM_COL_ADDR_WIDTH
        for row_wordline in range(row_wordline_start, row_wordline_stop + 1):
            target_row_start = row_wordline << MRAM_COL_ADDR_WIDTH
            inst_idx = (target_row_start >> 16) & 0x7
            raw_row_start = (((target_row_start >> 19) & 0x1) << 16) | (target_row_start & 0xFFFF)
            row_expect = collect_row_trim_expectation(bank_idx, inst_idx, raw_row_start)
            dut._log.info(
                "RTE range summary: label=%s bank=%d inst=%d plane=%d row=%d expected_rh0=%d expected_rh1=%d expected_rh2=%d instance_rh2=%d expected_instance_rh2=%d",
                label,
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["expected_rh0"],
                row_expect["expected_rh1"],
                row_expect["expected_rh2"],
                row_expect["instance_rh2"],
                row_expect["expected_instance_rh2"],
            )
            assert row_expect["instance_rh2"] == row_expect["expected_instance_rh2"], (
                f"{label}: inst={inst_idx} plane={row_expect['plane_idx']} row={row_expect['row_idx']} "
                f"expected instance rh2={row_expect['expected_instance_rh2']}, "
                f"got {row_expect['instance_rh2']}"
            )

        final_target_row_start = row_wordline_stop << MRAM_COL_ADDR_WIDTH
        final_inst = (final_target_row_start >> 16) & 0x7
        final_raw_row_start = (((final_target_row_start >> 19) & 0x1) << 16) | (
            final_target_row_start & 0xFFFF
        )
        await assert_row_trim_status(
            bank_tregs(bank_idx),
            bank_idx,
            final_inst,
            final_raw_row_start,
            f"{label}_final_row",
        )

    async def run_and_assert_rte_window(
        label,
        *,
        bank_idx,
        start_target,
        stop_target,
        timeout_ns=120_000,
    ):
        await clear_bist_error_without_running(
            bank_tregs(bank_idx),
            f"{label}_preclear",
        )
        await run_rte_case(
            label,
            bank=bank_idx,
            cfg_overrides={
                "bist_start_add": start_target,
                "bist_stop_add": stop_target,
                "bist_stop_on_error": 0,
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=timeout_ns,
        )
        await assert_rte_range_rows(bank_idx, start_target, stop_target, label)

    def iter_trim_mode_row_targets(start_target, stop_target):
        current_target = start_target & ~((1 << MRAM_COL_ADDR_WIDTH) - 1)
        stop_target = stop_target & ~((1 << MRAM_COL_ADDR_WIDTH) - 1)
        while current_target <= stop_target:
            yield current_target
            yield current_target ^ (1 << 13)

            row_idx = (current_target >> MRAM_COL_ADDR_WIDTH) & ((1 << MRAM_NORM_ROW_ADDR_WIDTH) - 1)
            if row_idx == ((1 << MRAM_NORM_ROW_ADDR_WIDTH) - 1):
                current_target = (current_target ^ (1 << 13)) + (1 << MRAM_COL_ADDR_WIDTH)
            else:
                current_target = current_target + (1 << MRAM_COL_ADDR_WIDTH)

    async def assert_rte_trim_mode_rows(bank_idx, start_target, stop_target, label):
        last_target = None
        for target_row_start in iter_trim_mode_row_targets(start_target, stop_target):
            last_target = target_row_start
            inst_idx = (target_row_start >> 16) & 0x7
            raw_row_start = (((target_row_start >> 19) & 0x1) << 16) | (target_row_start & 0xFFFF)
            row_expect = collect_row_trim_expectation(bank_idx, inst_idx, raw_row_start, trim_mode=True)
            dut._log.info(
                "RTE row RH snapshot: bank=%d inst=%d plane=%d row=%d trim_mode=1 rh0=%s rh1=%s ref_rh0=%d ref_rh1=%d",
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["row_rh0_values"],
                row_expect["row_rh1_values"],
                row_expect["ref_rh0_value"],
                row_expect["ref_rh1_value"],
            )
            dut._log.info(
                "RTE trim-mode summary: label=%s bank=%d inst=%d plane=%d row=%d ref_rh0=%d ref_rh1=%d expected_rh0=%d expected_rh1=%d expected_rh2=%d instance_rh2=%d expected_instance_rh2=%d",
                label,
                bank_idx,
                inst_idx,
                row_expect["plane_idx"],
                row_expect["row_idx"],
                row_expect["ref_rh0_value"],
                row_expect["ref_rh1_value"],
                row_expect["expected_rh0"],
                row_expect["expected_rh1"],
                row_expect["expected_rh2"],
                row_expect["instance_rh2"],
                row_expect["expected_instance_rh2"],
            )
            assert row_expect["instance_rh2"] == row_expect["expected_instance_rh2"], (
                f"{label}: inst={inst_idx} plane={row_expect['plane_idx']} row={row_expect['row_idx']} "
                f"expected instance rh2={row_expect['expected_instance_rh2']}, "
                f"got {row_expect['instance_rh2']}"
            )

        assert last_target is not None, f"{label}: trim-mode row iterator produced no rows"
        final_inst = (last_target >> 16) & 0x7
        final_raw_row_start = (((last_target >> 19) & 0x1) << 16) | (last_target & 0xFFFF)
        await assert_row_trim_status(
            bank_tregs(bank_idx),
            bank_idx,
            final_inst,
            final_raw_row_start,
            f"{label}_final_row",
            trim_mode=True,
        )

    async def run_and_assert_rte_trim_window(
        label,
        *,
        bank_idx,
        start_target,
        stop_target,
        timeout_ns=120_000,
    ):
        await clear_bist_error_without_running(
            bank_tregs(bank_idx),
            f"{label}_preclear",
        )
        await run_rte_case(
            label,
            bank=bank_idx,
            cfg_overrides={
                "bist_start_add": start_target,
                "bist_stop_add": stop_target,
                "bist_stop_on_error": 0,
            },
            ctrl_overrides={
                "bist_trim_mode": 1,
            },
            timeout_ns=timeout_ns,
        )
        await assert_rte_trim_mode_rows(bank_idx, start_target, stop_target, label)

    # Deterministic bring-up for mkEtBist FSM reset handling.
    if has_bist_rst_b:
        await assert_bist_rst_all_banks()
        await pulse_bist_rst(regs0)
        await assert_bist_rst_all_banks()
    else:
        dut._log.warning("bist_rst_b field not present; reset-specific checks skipped")

    # Keep MRAM clocks ungated during RTE BIST debug.
    await context["reg_model"].bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)

    # Clear any sticky error state before the future matrix cases get added.
    await clear_bist_error_without_running(regs0, "rte_scaffold_idle_clear")

    # ------------------------------------------------------------------
    # Matrix execution
    # ------------------------------------------------------------------
    mark_matrix("BIST RTE matrix: single-row RH status sanity")
    bank = 0
    inst = 0
    plane = 0
    row = 2
    raw_start = raw_normal_addr(plane, row, 0)
    raw_stop = raw_normal_addr(plane, row, 15)
    await run_rte_case(
        "single_row_rh_status",
        bank=bank,
        cfg_overrides={
            "bist_start_add": raw_addr_to_bist_target(inst, raw_start),
            "bist_stop_add": raw_addr_to_bist_target(inst, raw_stop),
            "bist_stop_on_error": 0,
        },
        ctrl_overrides={
            "bist_trim_mode": 0,
        },
        timeout_ns=50_000,
    )

    regs = bank_tregs(bank)
    await assert_row_trim_status(regs, bank, inst, raw_start, "single_row_rh_status")

    mark_matrix("BIST RTE matrix: sixteen-row contiguous range")
    await clear_bist_error_without_running(regs, "sixteen_row_rh_status_preclear")
    multi_row_start = 0
    multi_row_stop = multi_row_start + 15
    raw_start = raw_normal_addr(plane, multi_row_start, 0)
    raw_stop = raw_normal_addr(plane, multi_row_stop, 15)
    await run_rte_case(
        "sixteen_row_rh_status",
        bank=bank,
        cfg_overrides={
            "bist_start_add": raw_addr_to_bist_target(inst, raw_start),
            "bist_stop_add": raw_addr_to_bist_target(inst, raw_stop),
            "bist_stop_on_error": 0,
        },
        ctrl_overrides={
            "bist_trim_mode": 0,
        },
        timeout_ns=400_000,
    )

    for row in range(multi_row_start, multi_row_stop + 1):
        row_raw_start = raw_normal_addr(plane, row, 0)
        row_expect = collect_row_trim_expectation(bank, inst, row_raw_start)
        dut._log.info(
            "RTE multi-row summary: bank=%d inst=%d plane=%d row=%d expected_rh0=%d expected_rh1=%d expected_rh2=%d instance_rh2=%d expected_instance_rh2=%d",
            bank,
            inst,
            row_expect["plane_idx"],
            row_expect["row_idx"],
            row_expect["expected_rh0"],
            row_expect["expected_rh1"],
            row_expect["expected_rh2"],
            row_expect["instance_rh2"],
            row_expect["expected_instance_rh2"],
        )
        assert row_expect["instance_rh2"] == row_expect["expected_instance_rh2"], (
            f"sixteen_row_rh_status: row {row} expected instance rh2="
            f"{row_expect['expected_instance_rh2']}, got {row_expect['instance_rh2']}"
        )

    await assert_row_trim_status(
        regs,
        bank,
        inst,
        raw_normal_addr(plane, multi_row_stop, 0),
        "sixteen_row_rh_status_final_row",
    )

    max_normal_row = (1 << MRAM_NORM_ROW_ADDR_WIDTH) - 1
    max_redundant_row = MRAM_NUM_RESERVED_ROWS - 1

    mark_matrix("BIST RTE matrix: window corners trim_mode_0")
    window_corner_cases = (
        (
            "window_same_row_col0_to_col0",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 0)),
            80_000,
        ),
        (
            "window_same_row_col15_to_col15",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 15)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 15)),
            80_000,
        ),
        (
            "window_same_row_col3_to_col11",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 3)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 11)),
            80_000,
        ),
        (
            "window_row_boundary_col15_to_col0",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 8, 15)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 9, 0)),
            100_000,
        ),
        (
            "window_row_boundary_col1_to_col14",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 10, 1)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 11, 14)),
            100_000,
        ),
        (
            "window_first_normal_row",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 0, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 0, 15)),
            80_000,
        ),
        (
            "window_last_normal_row",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, max_normal_row, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, max_normal_row, 15)),
            80_000,
        ),
        (
            "window_first_redundant_row",
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, 0, 0)),
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, 0, 15)),
            80_000,
        ),
        (
            "window_otp_row",
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, max_redundant_row, 0)),
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, max_redundant_row, 15)),
            80_000,
        ),
    )
    for label, start_target, stop_target, timeout_ns in window_corner_cases:
        await run_and_assert_rte_window(
            label,
            bank_idx=bank,
            start_target=start_target,
            stop_target=stop_target,
            timeout_ns=timeout_ns,
        )

    await clear_bist_error_without_running(regs, "window_start_gt_stop_preclear")
    status_before = await read_rte_status(regs)
    await run_rte_case(
        "window_start_gt_stop_noop",
        bank=bank,
        cfg_overrides={
            "bist_start_add": raw_addr_to_bist_target(inst, raw_normal_addr(plane, 12, 15)),
            "bist_stop_add": raw_addr_to_bist_target(inst, raw_normal_addr(plane, 12, 0)),
            "bist_stop_on_error": 0,
        },
        ctrl_overrides={
            "bist_trim_mode": 0,
        },
        timeout_ns=40_000,
    )
    status_after = await read_rte_status(regs)
    dut._log.info(
        "RTE window no-op compare: before=%s after=%s",
        status_before,
        status_after,
    )
    assert status_after == status_before, (
        "window_start_gt_stop_noop: expected no-op when start > stop, "
        f"got status change before={status_before} after={status_after}"
    )

    mark_matrix("BIST RTE matrix: window corners trim_mode_1")
    trim_window_corner_cases = (
        (
            "trim_window_same_row_col0_to_col0",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 0)),
            80_000,
        ),
        (
            "trim_window_same_row_col15_to_col15",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 15)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 15)),
            80_000,
        ),
        (
            "trim_window_same_row_col3_to_col11",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 3)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 4, 11)),
            80_000,
        ),
        (
            "trim_window_row_boundary_col15_to_col0",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 8, 15)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 9, 0)),
            100_000,
        ),
        (
            "trim_window_row_boundary_col1_to_col14",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 10, 1)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 11, 14)),
            100_000,
        ),
        (
            "trim_window_first_normal_row",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 0, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, 0, 15)),
            80_000,
        ),
        (
            "trim_window_last_normal_row",
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, max_normal_row, 0)),
            raw_addr_to_bist_target(inst, raw_normal_addr(plane, max_normal_row, 15)),
            80_000,
        ),
        (
            "trim_window_first_redundant_row",
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, 0, 0)),
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, 0, 15)),
            80_000,
        ),
        (
            "trim_window_otp_row",
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, max_redundant_row, 0)),
            raw_addr_to_bist_target(inst, raw_redundant_addr(plane, max_redundant_row, 15)),
            80_000,
        ),
    )
    for label, start_target, stop_target, timeout_ns in trim_window_corner_cases:
        await run_and_assert_rte_trim_window(
            label,
            bank_idx=bank,
            start_target=start_target,
            stop_target=stop_target,
            timeout_ns=timeout_ns,
        )

    await clear_bist_error_without_running(regs, "trim_window_start_gt_stop_preclear")
    status_before = await read_rte_status(regs)
    await run_rte_case(
        "trim_window_start_gt_stop_noop",
        bank=bank,
        cfg_overrides={
            "bist_start_add": raw_addr_to_bist_target(inst, raw_normal_addr(plane, 12, 15)),
            "bist_stop_add": raw_addr_to_bist_target(inst, raw_normal_addr(plane, 12, 0)),
            "bist_stop_on_error": 0,
        },
        ctrl_overrides={
            "bist_trim_mode": 1,
        },
        timeout_ns=40_000,
    )
    status_after = await read_rte_status(regs)
    dut._log.info(
        "RTE trim-mode window no-op compare: before=%s after=%s",
        status_before,
        status_after,
    )
    assert status_after == status_before, (
        "trim_window_start_gt_stop_noop: expected no-op when start > stop, "
        f"got status change before={status_before} after={status_after}"
    )

    mark_matrix("BIST RTE matrix: block crossings trim_mode_1")
    for plane_idx in range(0, MRAM_NUM_PLANES - 2, 2):
        await run_and_assert_rte_trim_window(
            f"trim_block_crossing_{plane_idx}_to_{plane_idx + 2}",
            bank_idx=bank,
            start_target=raw_addr_to_bist_target(inst, raw_normal_addr(plane_idx, max_normal_row, 15)),
            stop_target=raw_addr_to_bist_target(inst, raw_normal_addr(plane_idx + 2, 0, 0)),
            timeout_ns=140_000,
        )

    mark_matrix("BIST RTE matrix: plane crossings trim_mode_0")
    for plane_idx in range(MRAM_NUM_PLANES - 1):
        await clear_bist_error_without_running(
            regs,
            f"rte_plane_crossing_{plane_idx}_to_{plane_idx + 1}_preclear",
        )
        start_raw = raw_normal_addr(plane_idx, max_normal_row, 0)
        stop_raw = raw_normal_addr(plane_idx + 1, 0, 15)
        start_target = raw_addr_to_bist_target(inst, start_raw)
        stop_target = raw_addr_to_bist_target(inst, stop_raw)
        await run_rte_case(
            f"plane_crossing_{plane_idx}_to_{plane_idx + 1}",
            bank=bank,
            cfg_overrides={
                "bist_start_add": start_target,
                "bist_stop_add": stop_target,
                "bist_stop_on_error": 0,
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=120_000,
        )
        await assert_rte_range_rows(
            bank,
            start_target,
            stop_target,
            f"plane_crossing_{plane_idx}_to_{plane_idx + 1}",
        )

    mark_matrix("BIST RTE matrix: block crossings trim_mode_0")
    for plane_idx in range(1, MRAM_NUM_PLANES - 1, 2):
        await clear_bist_error_without_running(
            regs,
            f"rte_block_crossing_{plane_idx}_to_{plane_idx + 1}_preclear",
        )
        start_raw = raw_normal_addr(plane_idx, max_normal_row, 0)
        stop_raw = raw_normal_addr(plane_idx + 1, 0, 15)
        start_target = raw_addr_to_bist_target(inst, start_raw)
        stop_target = raw_addr_to_bist_target(inst, stop_raw)
        await run_rte_case(
            f"block_crossing_{plane_idx}_to_{plane_idx + 1}",
            bank=bank,
            cfg_overrides={
                "bist_start_add": start_target,
                "bist_stop_add": stop_target,
                "bist_stop_on_error": 0,
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=120_000,
        )
        await assert_rte_range_rows(
            bank,
            start_target,
            stop_target,
            f"block_crossing_{plane_idx}_to_{plane_idx + 1}",
        )

    mark_matrix("BIST RTE matrix: instance crossings trim_mode_0")
    for inst_idx in range(7):
        await clear_bist_error_without_running(
            regs,
            f"rte_instance_crossing_{inst_idx}_to_{inst_idx + 1}_preclear",
        )
        start_raw = raw_normal_addr(MRAM_NUM_PLANES - 1, max_normal_row, 0)
        stop_raw = raw_normal_addr(0, 0, 15)
        start_target = raw_addr_to_bist_target(inst_idx, start_raw)
        stop_target = raw_addr_to_bist_target(inst_idx + 1, stop_raw)
        await run_rte_case(
            f"instance_crossing_{inst_idx}_to_{inst_idx + 1}",
            bank=bank,
            cfg_overrides={
                "bist_start_add": start_target,
                "bist_stop_add": stop_target,
                "bist_stop_on_error": 0,
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=160_000,
        )
        await assert_rte_range_rows(
            bank,
            start_target,
            stop_target,
            f"instance_crossing_{inst_idx}_to_{inst_idx + 1}",
        )

    mark_matrix("BIST RTE matrix: stop_on_error RH4margin sweep")
    margin_default = 10
    candidate_row = find_candidate_row(bank, inst, plane)
    default_target = raw_addr_to_bist_target(inst, candidate_row["raw_row_start"])
    failed_margin = None
    for margin in range(margin_default, 32, 2):
        await clear_bist_error_without_running(
            regs,
            f"rte_stop_on_error_margin_{margin}_preclear",
        )
        await run_rte_case(
            f"rte_stop_on_error_margin_{margin}",
            bank=bank,
            cfg_overrides={
                "bist_start_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_start"]),
                "bist_stop_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_stop"]),
                "bist_stop_on_error": 1,
                "RH4margin": margin,
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=80_000,
        )
        status = await read_rte_status(regs)
        dut._log.info(
            "RTE RH4margin sweep: row=%d margin=%d expected_rh4=%d bist_error=%d bist_err_add=0x%05x",
            candidate_row["row_idx"],
            margin,
            candidate_row["expected_rh4"],
            status["bist_error"],
            status["bist_err_add"],
        )
        if margin < candidate_row["expected_rh4"]:
            assert status["bist_error"] == 0, (
                f"rte_stop_on_error_margin_{margin}: expected pass before RH4 threshold "
                f"{candidate_row['expected_rh4']}, got bist_error=1"
            )
        else:
            assert status["bist_error"] == 1, (
                f"rte_stop_on_error_margin_{margin}: expected failure at-or-above RH4 threshold "
                f"{candidate_row['expected_rh4']}, got bist_error=0"
            )
            assert status["bist_err_add"] == default_target, (
                f"rte_stop_on_error_margin_{margin}: expected bist_err_add=0x{default_target:05x}, "
                f"got 0x{status['bist_err_add']:05x}"
            )
            failed_margin = margin
            break
    assert failed_margin is not None, "RTE RH4margin sweep never reached a failing point"

    await clear_bist_error_without_running(
        regs,
        "rte_stop_on_error_margin_default_retry_preclear",
    )
    await run_rte_case(
        "rte_stop_on_error_margin_default_retry",
        bank=bank,
        cfg_overrides={
            "bist_start_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_start"]),
            "bist_stop_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_stop"]),
            "bist_stop_on_error": 1,
            "RH4margin": margin_default,
        },
        ctrl_overrides={
            "bist_trim_mode": 0,
        },
        timeout_ns=80_000,
    )
    status = await read_rte_status(regs)
    assert status["bist_error"] == 0, (
        f"rte_stop_on_error_margin_default_retry: expected default margin {margin_default} to pass, "
        "got bist_error=1"
    )
    await assert_row_trim_status(
        regs,
        bank,
        inst,
        candidate_row["raw_row_start"],
        "rte_stop_on_error_margin_default_retry",
    )

    mark_matrix("BIST RTE matrix: rh2_offset sweep")
    for rh2_offset in range(-10, 12, 2):
        await clear_bist_error_without_running(
            regs,
            f"rte_rh2_offset_{rh2_offset}_preclear",
        )
        await run_rte_case(
            f"rte_rh2_offset_{rh2_offset}",
            bank=bank,
            cfg_overrides={
                "bist_start_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_start"]),
                "bist_stop_add": raw_addr_to_bist_target(inst, candidate_row["raw_row_stop"]),
                "bist_stop_on_error": 0,
                "rh2_offset": encode_rh2_offset(rh2_offset),
            },
            ctrl_overrides={
                "bist_trim_mode": 0,
            },
            timeout_ns=80_000,
        )
        await assert_row_trim_status(
            regs,
            bank,
            inst,
            candidate_row["raw_row_start"],
            f"rte_rh2_offset_{rh2_offset}",
            rh2_offset=rh2_offset,
        )

    await Timer(100, unit="ns")
