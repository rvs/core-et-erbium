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

from functools import lru_cache
from pathlib import Path
import re

from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge, Timer, with_timeout

from tb import my_tb, sig_int


MASK79 = (1 << 79) - 1

REG_MRAM_CONTROL = 0
REG_BWE_LOW = 1
REG_BIST_CFG = 2
REG_DIN_LOW = 3
REG_BIST_MISC = 4
REG_STATUS0 = 9
REG_STATUS1 = 10
REG_ERROR_VALUE_LOW = 11
REG_BIST_START = 12

MRAM_CONTROL_REF_PRG_EN_BIT = 34
MRAM_CONTROL_BIST_RESET_BIT = 53
MRAM_CONTROL_BIST_RD_EN_BIT = 54
MRAM_CONTROL_BIST_WR_EN_BIT = 55

BIST_CFG_BWE_MSB_LSB = 0
BIST_CFG_BWE_MSB_WIDTH = 15
BIST_CFG_DIN_MSB_LSB = 16
BIST_CFG_DIN_MSB_WIDTH = 15
BIST_CFG_TEST_REG_OVR_EN_BIT = 31
BIST_CFG_RTE_EN_BIT = 32
BIST_CFG_RH4MARGIN_LSB = 38
BIST_CFG_RH4MARGIN_WIDTH = 5
BIST_CFG_STOP_ON_ERROR_BIT = 43
BIST_CFG_START_ADD_LSB = 44
BIST_CFG_START_ADD_WIDTH = 20

BIST_MISC_DATA_INV_BIT = 0
BIST_MISC_ADD_INC_LSB = 15
BIST_MISC_ADD_INC_WIDTH = 3
BIST_MISC_STOP_ADD_LSB = 32
BIST_MISC_STOP_ADD_WIDTH = 20

BIST_START_LOOP_COUNT_LSB = 15
BIST_START_LOOP_COUNT_WIDTH = 16
BIST_START_START_BIT = 31
BIST_START_TRIM_MODE_BIT = 32
BIST_START_STOP_ON_REPL_OF_BIT = 33

STATUS1_TEMP_LSB = 0
STATUS1_TEMP_WIDTH = 2
STATUS1_RH2_LSB = 2
STATUS1_RH2_WIDTH = 7
STATUS1_PWR_OK_BIT = 9
STATUS1_ECCROM_PWR_OK_BIT = 10
STATUS1_INTR_ERROR_ADDR_LSB = 12
STATUS1_INTR_ERROR_ADDR_WIDTH = 20
STATUS1_CPU_INTR_FLAG_BIT = 32
STATUS1_TREG_BUSY_BIT = 33
STATUS1_BIST_ERR_ADD_LSB = 39
STATUS1_BIST_ERR_ADD_WIDTH = 20
STATUS1_BIST_ERROR_BIT = 59
STATUS1_BIST_BUSY_BIT = 60

STATUS0_DOUT_MSB_LSB = 0
STATUS0_DOUT_MSB_WIDTH = 15
STATUS0_ERROR_LOOP_LSB = 15
STATUS0_ERROR_LOOP_WIDTH = 16
STATUS0_ERROR_COUNT_LSB = 31
STATUS0_ERROR_COUNT_WIDTH = 17
STATUS0_RH0_LSB = 48
STATUS0_RH0_WIDTH = 7
STATUS0_RH1_LSB = 55
STATUS0_RH1_WIDTH = 7

_REPO_ROOT = Path(__file__).resolve().parents[3]
_ECC_ROM_WRAPPER_PATH = _REPO_ROOT / "mram_controller" / "verilog" / "ecc_rom_wrapper.sv"
_ROM_16KB_TOP_PATH = _REPO_ROOT / "mram_controller" / "verilog" / "rom_16kb_top.v"


def _field_mask(lsb, width):
    return ((1 << width) - 1) << lsb


def set_field(word, lsb, width, value):
    mask = _field_mask(lsb, width)
    return (word & ~mask) | ((int(value) & ((1 << width) - 1)) << lsb)


def get_field(word, lsb, width):
    return (int(word) >> lsb) & ((1 << width) - 1)


async def rmw_reg(apb, reg_index, *updates):
    value = await apb.read64(reg_index)
    for lsb, width, field_value in updates:
        value = set_field(value, lsb, width, field_value)
    await apb.write64(reg_index, value)
    return value


async def configure_bist_pattern(apb, *, din, bwe):
    await apb.write64(REG_BWE_LOW, int(bwe) & ((1 << 64) - 1))
    await apb.write64(REG_DIN_LOW, int(din) & ((1 << 64) - 1))
    await rmw_reg(
        apb,
        REG_BIST_CFG,
        (BIST_CFG_BWE_MSB_LSB, BIST_CFG_BWE_MSB_WIDTH, int(bwe) >> 64),
        (BIST_CFG_DIN_MSB_LSB, BIST_CFG_DIN_MSB_WIDTH, int(din) >> 64),
    )


async def configure_bist(
    apb,
    *,
    wr_en=None,
    rd_en=None,
    rte_en=None,
    bist_reset=None,
    start_add=None,
    stop_add=None,
    add_inc=None,
    loop_count=None,
    data_inv=None,
    stop_on_error=None,
    stop_on_repl_of=None,
    trim_mode=None,
    rh4_margin=None,
    ref_prg_en=None,
    test_reg_ovr_en=0,
):
    reg0_updates = []
    reg2_updates = [(BIST_CFG_TEST_REG_OVR_EN_BIT, 1, test_reg_ovr_en)]
    reg4_updates = []
    reg12_updates = []

    if ref_prg_en is not None:
        reg0_updates.append((MRAM_CONTROL_REF_PRG_EN_BIT, 1, ref_prg_en))
    if bist_reset is not None:
        reg0_updates.append((MRAM_CONTROL_BIST_RESET_BIT, 1, bist_reset))
    if rd_en is not None:
        reg0_updates.append((MRAM_CONTROL_BIST_RD_EN_BIT, 1, rd_en))
    if wr_en is not None:
        reg0_updates.append((MRAM_CONTROL_BIST_WR_EN_BIT, 1, wr_en))

    if rte_en is not None:
        reg2_updates.append((BIST_CFG_RTE_EN_BIT, 1, rte_en))
    if rh4_margin is not None:
        reg2_updates.append((BIST_CFG_RH4MARGIN_LSB, BIST_CFG_RH4MARGIN_WIDTH, rh4_margin))
    if stop_on_error is not None:
        reg2_updates.append((BIST_CFG_STOP_ON_ERROR_BIT, 1, stop_on_error))
    if start_add is not None:
        reg2_updates.append((BIST_CFG_START_ADD_LSB, BIST_CFG_START_ADD_WIDTH, start_add))

    if data_inv is not None:
        reg4_updates.append((BIST_MISC_DATA_INV_BIT, 1, data_inv))
    if add_inc is not None:
        reg4_updates.append((BIST_MISC_ADD_INC_LSB, BIST_MISC_ADD_INC_WIDTH, add_inc))
    if stop_add is not None:
        reg4_updates.append((BIST_MISC_STOP_ADD_LSB, BIST_MISC_STOP_ADD_WIDTH, stop_add))

    if loop_count is not None:
        reg12_updates.append((BIST_START_LOOP_COUNT_LSB, BIST_START_LOOP_COUNT_WIDTH, loop_count))
    if trim_mode is not None:
        reg12_updates.append((BIST_START_TRIM_MODE_BIT, 1, trim_mode))
    if stop_on_repl_of is not None:
        reg12_updates.append((BIST_START_STOP_ON_REPL_OF_BIT, 1, stop_on_repl_of))

    if reg0_updates:
        await rmw_reg(apb, REG_MRAM_CONTROL, *reg0_updates)
    if reg2_updates:
        await rmw_reg(apb, REG_BIST_CFG, *reg2_updates)
    if reg4_updates:
        await rmw_reg(apb, REG_BIST_MISC, *reg4_updates)
    if reg12_updates:
        await rmw_reg(apb, REG_BIST_START, *reg12_updates)


async def pulse_bist_start(apb):
    current = await apb.read64(REG_BIST_START)
    await apb.write64(REG_BIST_START, set_field(current, BIST_START_START_BIT, 1, 1))
    await apb.write64(REG_BIST_START, set_field(current, BIST_START_START_BIT, 1, 0))


async def pulse_bist_reset(apb):
    current = await apb.read64(REG_MRAM_CONTROL)
    await apb.write64(REG_MRAM_CONTROL, set_field(current, MRAM_CONTROL_BIST_RESET_BIT, 1, 1))
    await apb.write64(REG_MRAM_CONTROL, set_field(current, MRAM_CONTROL_BIST_RESET_BIT, 1, 0))


def decode_status1(status_word):
    status_word = int(status_word)
    return {
        "temp": get_field(status_word, STATUS1_TEMP_LSB, STATUS1_TEMP_WIDTH),
        "rh2": get_field(status_word, STATUS1_RH2_LSB, STATUS1_RH2_WIDTH),
        "pwr_ok": get_field(status_word, STATUS1_PWR_OK_BIT, 1),
        "eccrom_pwr_ok": get_field(status_word, STATUS1_ECCROM_PWR_OK_BIT, 1),
        "intr_error_addr": get_field(
            status_word, STATUS1_INTR_ERROR_ADDR_LSB, STATUS1_INTR_ERROR_ADDR_WIDTH
        ),
        "cpu_intr_flag": get_field(status_word, STATUS1_CPU_INTR_FLAG_BIT, 1),
        "treg_busy": get_field(status_word, STATUS1_TREG_BUSY_BIT, 1),
        "bist_err_add": get_field(status_word, STATUS1_BIST_ERR_ADD_LSB, STATUS1_BIST_ERR_ADD_WIDTH),
        "bist_error": get_field(status_word, STATUS1_BIST_ERROR_BIT, 1),
        "bist_busy": get_field(status_word, STATUS1_BIST_BUSY_BIT, 1),
    }


async def read_status1(apb):
    return decode_status1(await apb.read64(REG_STATUS1))


def decode_status0(status_word):
    status_word = int(status_word)
    return {
        "dout_msb": get_field(status_word, STATUS0_DOUT_MSB_LSB, STATUS0_DOUT_MSB_WIDTH),
        "error_loop": get_field(status_word, STATUS0_ERROR_LOOP_LSB, STATUS0_ERROR_LOOP_WIDTH),
        "error_count": get_field(status_word, STATUS0_ERROR_COUNT_LSB, STATUS0_ERROR_COUNT_WIDTH),
        "rh0": get_field(status_word, STATUS0_RH0_LSB, STATUS0_RH0_WIDTH),
        "rh1": get_field(status_word, STATUS0_RH1_LSB, STATUS0_RH1_WIDTH),
    }


async def read_status0(apb):
    return decode_status0(await apb.read64(REG_STATUS0))


async def wait_bist_done(apb, *, timeout_ns=40_000, poll_ns=20):
    polls = max(1, timeout_ns // poll_ns)
    saw_busy = False
    status = None

    for _ in range(polls):
        status = await read_status1(apb)
        if status["bist_busy"]:
            saw_busy = True
        elif saw_busy:
            return status
        await Timer(poll_ns, unit="ns")

    if status is None:
        status = await read_status1(apb)

    if not status["bist_busy"]:
        return status

    raise AssertionError("Timed out waiting for BIST completion")


async def read_bist_error_value(apb):
    lower = await apb.read64(REG_ERROR_VALUE_LOW)
    upper_reg = await apb.read64(REG_BIST_START)
    return int(lower) | ((int(upper_reg) & 0x7FFF) << 64)


def rtl_write_bist_data(base_pattern, *, data_inv, loop_count):
    if data_inv and (loop_count & 0x1):
        return int(base_pattern) ^ MASK79
    return int(base_pattern)


def bist_addr_to_mem_index(bist_addr):
    bist_addr = int(bist_addr) & ((1 << 20) - 1)
    stripe_sel = (bist_addr >> 17) & 0x3
    high_addr_bit = (bist_addr >> 19) & 0x1
    low_addr = bist_addr & 0x1FFFF
    return (stripe_sel << 18) | (high_addr_bit << 17) | low_addr


def mem_index_to_bist_addr(mem_index):
    mem_index = int(mem_index) & ((1 << 20) - 1)
    stripe_sel = (mem_index >> 18) & 0x3
    high_addr_bit = (mem_index >> 17) & 0x1
    low_addr = mem_index & 0x1FFFF
    return (high_addr_bit << 19) | (stripe_sel << 17) | low_addr


def bist_addr_to_ref_row_index(bist_addr):
    return bist_addr_to_mem_index(bist_addr) >> 4


def bist_row_to_ref_row_index(row_index):
    return bist_addr_to_ref_row_index(int(row_index) << 4)


def read_mem_word(bank, bist_addr):
    mem_index = bist_addr_to_mem_index(bist_addr)
    return int(my_tb.get_behavioral_mem_word(bank, mem_index).value)


def write_mem_word(bank, bist_addr, value):
    mem_index = bist_addr_to_mem_index(bist_addr)
    my_tb.get_behavioral_mem_word(bank, mem_index).value = int(value) & MASK79


def read_ref_word(bank, row_index):
    ref_index = bist_row_to_ref_row_index(row_index)
    return int(my_tb.get_behavioral_ref_word(bank, ref_index).value)


async def clear_bist_error_without_running(apb, *, timeout_ns=20_000):
    await configure_bist(
        apb,
        wr_en=0,
        rd_en=0,
        rte_en=0,
        bist_reset=1,
        stop_on_repl_of=0,
        stop_on_error=0,
        trim_mode=0,
        test_reg_ovr_en=0,
    )
    await pulse_bist_start(apb)
    await wait_bist_done(apb, timeout_ns=timeout_ns)
    await configure_bist(apb, bist_reset=0, wr_en=0, rd_en=0, rte_en=0)


async def pulse_bist_reset_idle(apb):
    await configure_bist(apb, bist_reset=1)
    await Timer(20, unit="ns")
    await configure_bist(apb, bist_reset=0)


async def wait_for_bank_access(bank_handle, *, is_write, timeout_ns=20_000):
    async def _wait():
        while True:
            await ReadOnly()
            active = (
                sig_int(bank_handle.bank_sel) == 1
                and sig_int(bank_handle.we) == int(is_write)
                and sig_int(bank_handle.busy) == 1
            )
            if active:
                return mem_index_to_bist_addr(int(bank_handle.int_add.value))
            await RisingEdge(my_tb.tb_top.clk)

    return await with_timeout(_wait(), timeout_ns, "ns")


async def wait_for_bank_access_complete(bank_handle, *, timeout_ns=20_000):
    async def _wait():
        if sig_int(bank_handle.busy) == 0:
            await RisingEdge(bank_handle.busy)
        await FallingEdge(bank_handle.busy)

    await with_timeout(_wait(), timeout_ns, "ns")


def row_start_addr(row_index):
    return int(row_index) << 4


def row_stop_addr(row_index):
    return (int(row_index) << 4) | 0xF


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
    data_bits = [(data_15 >> idx) & 1 for idx in range(15)]
    p0 = (
        data_bits[0]
        ^ data_bits[1]
        ^ data_bits[3]
        ^ data_bits[4]
        ^ data_bits[6]
        ^ data_bits[8]
        ^ data_bits[10]
        ^ data_bits[11]
        ^ data_bits[13]
    )
    p1 = (
        data_bits[0]
        ^ data_bits[2]
        ^ data_bits[3]
        ^ data_bits[5]
        ^ data_bits[6]
        ^ data_bits[9]
        ^ data_bits[10]
        ^ data_bits[12]
        ^ data_bits[13]
    )
    p2 = (
        data_bits[1]
        ^ data_bits[2]
        ^ data_bits[3]
        ^ data_bits[7]
        ^ data_bits[8]
        ^ data_bits[9]
        ^ data_bits[10]
        ^ data_bits[14]
    )
    p3 = (
        data_bits[4]
        ^ data_bits[5]
        ^ data_bits[6]
        ^ data_bits[7]
        ^ data_bits[8]
        ^ data_bits[9]
        ^ data_bits[10]
    )
    p4 = data_bits[11] ^ data_bits[12] ^ data_bits[13] ^ data_bits[14]

    codeword = 0
    bit_map = {
        0: p0,
        1: p1,
        2: data_bits[0],
        3: p2,
        4: data_bits[1],
        5: data_bits[2],
        6: data_bits[3],
        7: p3,
        8: data_bits[4],
        9: data_bits[5],
        10: data_bits[6],
        11: data_bits[7],
        12: data_bits[8],
        13: data_bits[9],
        14: data_bits[10],
        15: p4,
        16: data_bits[11],
        17: data_bits[12],
        18: data_bits[13],
        19: data_bits[14],
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
    row_threshold = max(int(value) for value in row_rh0_values)
    for rh_idx in range(80):
        if rom_ones_for_rh(rh_idx) >= row_threshold:
            return max(rh_idx - 1, 0)
    raise AssertionError(f"No RH index reached threshold for rh0={row_threshold}")


def expected_rh1_index(row_rh1_values):
    row_threshold = min(int(value) for value in row_rh1_values)
    candidates = [rh_idx for rh_idx in range(80) if rom_ones_for_rh(rh_idx) <= row_threshold]
    if not candidates:
        raise AssertionError(f"No RH index stayed below threshold for rh1={row_threshold}")
    return candidates[-1]
