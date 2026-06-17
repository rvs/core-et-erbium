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

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
import re


_REPO_ROOT = Path(__file__).resolve().parents[2]
_ENCODER_PATH = _REPO_ROOT / "mram_controller" / "verilog" / "et_bch_encoder.sv"

_DATA_MASK_64 = (1 << 64) - 1
_CODEWORD_MASK_78 = (1 << 78) - 1
_CODEWORD_MASK_79 = (1 << 79) - 1
_PRIMITIVE_POLY = 0x89  # x^7 + x^3 + 1


@dataclass(frozen=True)
class EtBchDecodeResult:
    corrected_codeword_78: int
    corrected_data_64: int
    no_error: bool
    single_bit_error: bool
    double_bit_error: bool
    triple_bit_error: bool
    uncorrectable: bool
    parity_error: bool


def _check_u64(value: int) -> int:
    if not 0 <= value <= _DATA_MASK_64:
        raise ValueError(f"value out of 64-bit range: {value}")
    return value


def _check_u79(value: int) -> int:
    if not 0 <= value <= _CODEWORD_MASK_79:
        raise ValueError(f"value out of 79-bit range: {value}")
    return value


def _bit(value: int, index: int) -> int:
    return (value >> index) & 1


def _parity(value: int) -> int:
    return value.bit_count() & 1


@lru_cache(maxsize=1)
def _encoder_taps() -> tuple[tuple[int, ...], ...]:
    text = _ENCODER_PATH.read_text()
    pattern = re.compile(r"assign\s+bch_parity\[\s*(\d+)\s*\]\s*=\s*(.*?);")
    taps: list[list[int] | None] = [None] * 14

    for parity_idx_str, expr in pattern.findall(text):
        parity_idx = int(parity_idx_str)
        taps[parity_idx] = [int(bit_idx) for bit_idx in re.findall(r"data_in\[(\d+)\]", expr)]

    if any(entry is None for entry in taps):
        raise RuntimeError(f"Failed to parse all BCH parity taps from {_ENCODER_PATH}")

    return tuple(tuple(entry) for entry in taps if entry is not None)


@lru_cache(maxsize=1)
def _gf_tables() -> tuple[tuple[int, ...], tuple[int, ...]]:
    exp = [0] * 127
    log = [127] * 128
    value = 1

    for idx in range(127):
        exp[idx] = value
        log[value] = idx
        value <<= 1
        if value & 0x80:
            value ^= _PRIMITIVE_POLY
        value &= 0x7F

    return tuple(exp), tuple(log)


def _gf_pow(power: int) -> int:
    exp, _ = _gf_tables()
    return exp[power % 127]


def _bus_to_poly(bus_idx: int) -> int:
    if not 0 <= bus_idx < 78:
        raise ValueError(f"bus index out of range: {bus_idx}")
    return bus_idx + 14 if bus_idx < 64 else bus_idx - 64


def _syndrome(received_78: int) -> tuple[int, int]:
    s1 = 0
    s3 = 0

    for bus_idx in range(78):
        if _bit(received_78, bus_idx):
            poly_idx = _bus_to_poly(bus_idx)
            s1 ^= _gf_pow(poly_idx)
            s3 ^= _gf_pow(3 * poly_idx)

    return s1, s3


@lru_cache(maxsize=1)
def _error_maps() -> tuple[dict[tuple[int, int], int], dict[tuple[int, int], int]]:
    single_error_map: dict[tuple[int, int], int] = {}
    double_error_map: dict[tuple[int, int], int] = {}

    for bit_idx in range(78):
        mask = 1 << bit_idx
        key = _syndrome(mask)
        if key in single_error_map:
            raise RuntimeError(f"Duplicate single-bit syndrome for bit {bit_idx}")
        single_error_map[key] = mask

    for bit_idx_a in range(78):
        for bit_idx_b in range(bit_idx_a + 1, 78):
            mask = (1 << bit_idx_a) | (1 << bit_idx_b)
            key = _syndrome(mask)
            previous = double_error_map.get(key)
            if previous is not None and previous != mask:
                raise RuntimeError(
                    "Duplicate double-bit syndrome for masks "
                    f"0x{previous:x} and 0x{mask:x}"
                )
            double_error_map[key] = mask

    return single_error_map, double_error_map


def et_bch_encode_64_to_79(data_64: int) -> int:
    data_64 = _check_u64(data_64)
    parity_bits = 0

    for parity_idx, tap_indices in enumerate(_encoder_taps()):
        parity_bit = 0
        for data_idx in tap_indices:
            parity_bit ^= _bit(data_64, data_idx)
        parity_bits |= parity_bit << parity_idx

    codeword_78 = data_64 | (parity_bits << 64)
    overall_parity = _parity(codeword_78)
    return codeword_78 | (overall_parity << 78)


def et_bch_decode_79_to_64(received_79: int, ecc_bypass_en: bool = False) -> EtBchDecodeResult:
    received_79 = _check_u79(received_79)
    received_78 = received_79 & _CODEWORD_MASK_78
    overall_parity = _bit(received_79, 78)
    parity_error = _parity(received_78) ^ overall_parity

    syndrome_key = _syndrome(received_78)
    single_error_map, double_error_map = _error_maps()

    no_error = syndrome_key == (0, 0) and not parity_error
    single_hit = syndrome_key in single_error_map
    double_hit = syndrome_key in double_error_map

    single_bit_error = (single_hit and bool(parity_error)) or (syndrome_key == (0, 0) and bool(parity_error))
    double_bit_error = (double_hit and not parity_error) or (single_hit and not parity_error)
    triple_bit_error = (
        (double_hit and bool(parity_error))
        or (syndrome_key != (0, 0) and not single_hit and not double_hit and bool(parity_error))
    )
    uncorrectable = syndrome_key != (0, 0) and not single_hit and not double_hit and not parity_error

    error_pattern = 0
    if single_hit:
        error_pattern = single_error_map[syndrome_key]
    elif double_hit and not parity_error:
        error_pattern = double_error_map[syndrome_key]

    corrected_codeword_78 = received_78 if ecc_bypass_en else (received_78 ^ error_pattern)

    return EtBchDecodeResult(
        corrected_codeword_78=corrected_codeword_78,
        corrected_data_64=corrected_codeword_78 & _DATA_MASK_64,
        no_error=no_error,
        single_bit_error=single_bit_error,
        double_bit_error=double_bit_error,
        triple_bit_error=triple_bit_error,
        uncorrectable=uncorrectable,
        parity_error=bool(parity_error),
    )


def et_bch_encode_bytes(data_8: bytes) -> int:
    if len(data_8) != 8:
        raise ValueError(f"Expected 8 input bytes, got {len(data_8)}")
    return et_bch_encode_64_to_79(int.from_bytes(data_8, "little"))


def et_bch_decode_to_bytes(received_79: int, ecc_bypass_en: bool = False) -> tuple[bytes, EtBchDecodeResult]:
    result = et_bch_decode_79_to_64(received_79, ecc_bypass_en=ecc_bypass_en)
    return result.corrected_data_64.to_bytes(8, "little"), result
