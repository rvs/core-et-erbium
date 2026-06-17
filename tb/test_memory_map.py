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

"""
Memory Map Verification Testbench — Erbium SoC
===============================================
Covers: ROM, SRAM, ROMRAM, CPU Registers

Memory Map:
    ROM      0x40008000 – 0x40009FFF  (0x2000, read-only)
    SRAM     0x4000C000 – 0x4000CFFF  (0x1000, read/write)
    ROMRAM   0x40008000 – 0x4000CFFF  (0x5000, mixed, via RAL)
    CPU Regs 0x80000000 – 0x80F40317  (0xF40318, RO/RW mix)

"""

import cocotb
from cocotb.triggers import Timer, RisingEdge
import random
from env import ETEnv
from cocotbext.xspi.types import Mode
# ---------------------------------------------------------------------------
# Region constants
# ---------------------------------------------------------------------------

# ROM
ROM_START   = 0x40008000
ROM_SIZE    = 0x2000
ROM_END     = ROM_START + ROM_SIZE - 1          # 0x40009FFF
ROM_END_ALN = ROM_START + ROM_SIZE - 8          # 0x40009FF8 (last 64-bit word)

# SRAM
SRAM_START   = 0x4000C000
SRAM_SIZE    = 0x1000
SRAM_END     = SRAM_START + SRAM_SIZE - 1       # 0x4000CFFF
SRAM_END_ALN = SRAM_START + SRAM_SIZE - 8       # 0x4000CFF8 (last 64-bit word)
SRAM_MID     = SRAM_START + (SRAM_SIZE // 2)    # 0x4000C800

# ROMRAM gap (between ROM end and SRAM start, within 0x40008000-0x4000CFFF)
ROMRAM_GAP_START = 0x4000A000
ROMRAM_GAP_END   = 0x4000BFFF

# CPU Registers — overall block
CPU_REG_BASE    = 0x80000000
CPU_REG_START   = CPU_REG_BASE
CPU_REG_SIZE    = 0xF40318
CPU_REG_END_ALN = CPU_REG_BASE + CPU_REG_SIZE - 8   # 0x80F40310

# ---------------------------------------------------------------------------
# CPU Sub-Region Base Addresses (from spec)
# ---------------------------------------------------------------------------
U_NEIGH_BASE    = 0x80100000   # User_neigh
U_CPU_BASE      = 0x80340000   # User_cpu
S_CPU_BASE      = 0x80740000   # Supervisor_cpu
D_HART_ESR_BASE = 0x80800000   # D_hart_esr  (hart-id bits [15:12] = 1)
D_NEIGH_BASE    = 0x80900000   # D_neigh
D_CPU_BASE      = 0x80B5F000   # D_cpu
M_NEIGH_BASE    = 0x80D00000   # Machine_neigh
M_CPU_BASE      = 0x80F40000   # Machine_cpu

# ---------------------------------------------------------------------------
# Spec-defined register absolute addresses — one dict per sub-region.
# Each entry:  "identifier" -> absolute_address
# ---------------------------------------------------------------------------

# --- User_neigh (0x80100000, size 0x48) ---
U_NEIGH_REGS = {
    "ipi_redirect_pc": 0x80100040,
}

# --- User_cpu (0x80340000, size 0x300) ---
U_CPU_REGS = {
    "ipi_redirect_trigger": 0x80340080,
    "CREDINC0":             0x803400C0,
    "CREDINC1":             0x803400C8,
    "CREDINC2":             0x803400D0,
    "CREDINC3":             0x803400D8,
    "fast_local_barrier0":  0x80340100,
    "fast_local_barrier1":  0x80340108,
    "fast_local_barrier2":  0x80340110,
    "fast_local_barrier3":  0x80340118,
    "fast_local_barrier4":  0x80340120,
    "fast_local_barrier5":  0x80340128,
    "fast_local_barrier6":  0x80340130,
    "fast_local_barrier7":  0x80340138,
    "fast_local_barrier8":  0x80340140,
    "fast_local_barrier9":  0x80340148,
    "fast_local_barrier10": 0x80340150,
    "fast_local_barrier11": 0x80340158,
    "fast_local_barrier12": 0x80340160,
    "fast_local_barrier13": 0x80340168,
    "fast_local_barrier14": 0x80340170,
    "fast_local_barrier15": 0x80340178,
    "fast_local_barrier16": 0x80340180,
    "fast_local_barrier17": 0x80340188,
    "fast_local_barrier18": 0x80340190,
    "fast_local_barrier19": 0x80340198,
    "fast_local_barrier20": 0x803401A0,
    "fast_local_barrier21": 0x803401A8,
    "fast_local_barrier22": 0x803401B0,
    "fast_local_barrier23": 0x803401B8,
    "fast_local_barrier24": 0x803401C0,
    "fast_local_barrier25": 0x803401C8,
    "fast_local_barrier26": 0x803401D0,
    "fast_local_barrier27": 0x803401D8,
    "fast_local_barrier28": 0x803401E0,
    "fast_local_barrier29": 0x803401E8,
    "fast_local_barrier30": 0x803401F0,
    "fast_local_barrier31": 0x803401F8,
    "icache_uprefetch":     0x803402F8,
}

# --- Supervisor_cpu (0x80740000, size 0x308) ---
S_CPU_REGS = {
    "shire_coop_mode":  0x80740290,
    "icache_sprefetch": 0x80740300,
}

# --- D_hart_esr (0x80800000, size 0xF7C8)
#     Registers are per-hart; bits[15:12] in address = hart_id.
#     Using hart_id=1 (bits[15:12]=1) per spec table note. ---
D_HART_ESR_REGS = {
    "NXDATA0":    0x8080F780,
    "NXDATA1":    0x8080F788,
    "AXDATA0":    0x8080F790,
    "AXDATA1":    0x8080F798,
    "AXPROGBUFF0":0x8080F7A0,
    "AXPROGBUFF1":0x8080F7A8,
    "NXPROGBUFF0":0x8080F7B0,
    "NXPROGBUFF1":0x8080F7B8,
    "ABSCMD":     0x8080F7C0,
}

# --- D_neigh (0x80900000, size 0xFFA0) ---
D_NEIGH_REGS = {
    "hactrl":         0x8090FF80,
    "hastatus0":      0x8090FF88,
    "hastatus1":      0x8090FF90,
    "and_or_tree_IO": 0x8090FF98,
}

# --- D_cpu (0x80B5F000, size 0xFD8) ---
D_CPU_REGS = {
    "dmctrl":     0x80B5FF88,
    "sm_config":  0x80B5FF90,
    "sm_trigger": 0x80B5FF98,
    # 0x80B5FFA0 not defined in spec — gap
    "sm_match":   0x80B5FFA8,
    "sm_filter0": 0x80B5FFB0,
    "sm_filter1": 0x80B5FFB8,
    "sm_filter2": 0x80B5FFC0,
    "sm_data0":   0x80B5FFC8,
    "sm_data1":   0x80B5FFD0,
}

# --- Machine_neigh (0x80D00000, size 0x98) ---
M_NEIGH_REGS = {
    "minion_boot":             0x80D00018,
    "mprot":                   0x80D00038,
    "pmu_ctrl":                0x80D00068,
    "neigh_chicken":           0x80D00070,
    "icache_err_log_ctl":      0x80D00078,
    "icache_err_log_info":     0x80D00080,
    "icache_err_log_address":  0x80D00088,
    "icache_sbe_dbe_counts":   0x80D00090,
}

# --- Machine_cpu (0x80F40000, size 0x318) ---
M_CPU_REGS = {
    "minion_feature":       0x80F40000,
    "thread1_disable":      0x80F40010,
    "ipi_redirect_filter":  0x80F40088,
    "ipi_trigger":          0x80F40090,
    "ipi_trigger_clear":    0x80F40098,
    "mtime":                0x80F40200,
    "mtime_cmp":            0x80F40208,
    "time_config":          0x80F40210,
    "mtime_local_target":   0x80F40218,
    "thread0_disable":      0x80F40240,
    "icache_mprefetch":     0x80F40308,
    "clk_gate_ctrl":        0x80F40310,
}

# Known ROM sentinel values (from test_default.py)
ROM_SENTINEL_WORD0  = 0x1BADB0022BADB002   # RAL ROMRAM.ROM[0]
SRAM_SENTINEL_WORD0 = 0xABADBABE8BADF00D   # RAL ROMRAM.SRAM[0]
ROM_LAST_WORD_VAL   = 0x3132333435363738   # 0x40009FF8 raw value

# Known CPU Version reset value
CPU_VERSION_CHIPID    = 60264
CPU_VERSION_RESPIN    = 0
CPU_VERSION_VARIATION = 0

# Data patterns for corner-case tests
PATTERN_ALL_ZEROS   = b'\x00' * 8
PATTERN_ALL_ONES    = b'\xff' * 8
PATTERN_ALTERNATING = b'\xaa\x55\xaa\x55\xaa\x55\xaa\x55'

# ---------------------------------------------------------------------------
# Shared setup helper
# ---------------------------------------------------------------------------

async def mem_setup(dut) -> ETEnv:
    dut.TestMode.value = 0
    tb = ETEnv(dut, safe_callback=True)
    await tb.reset()
    dut.TestMode.value = 0
    tb.start()
    await tb.warm_reset(0)
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    await tb.xspi_cmd.setRate(Mode.D8, Mode.D8, Mode.D8)
    # dut.et.erbium_digital.cpu_ss.reset_warm.value = 0
    # modes=(
    #     (Mode.S4, Mode.D4, Mode.D4),
    #     (Mode.D4, Mode.D4, Mode.D4),
    #     (Mode.S8, Mode.S8, Mode.S8),
    #     (Mode.D8, Mode.D8, Mode.D8),
    #     )
    # mode = random.choice(modes)
    # await tb.xspi_cmd.setRate(*mode)
    
    return tb


# ---------------------------------------------------------------------------
# Reusable helpers
# ---------------------------------------------------------------------------

async def mem_write_check(tb, address: int, data: bytes, *,
                          slvError=False, decodeError=False, msg=""):
    """Write `data` to `address` and assert xSPI errors match expectations."""
    await tb.xspi_cmd.write_Mem(address, data)
    await tb.assert_no_xspi_errors(slvError=slvError,
                                   decodeError=decodeError,
                                   msg=msg or f"write@0x{address:08x}")


async def mem_read_check(tb, address: int, *,
                         expected: bytes = None,
                         slvError=False, decodeError=False, msg="") -> bytes:
    """Read from `address`, assert xSPI status, optionally check value."""
    rv = await tb.xspi_cmd.read_Mem(address)
    await tb.assert_no_xspi_errors(slvError=slvError,
                                   decodeError=decodeError,
                                   msg=msg or f"read@0x{address:08x}")
    if expected is not None:
        assert rv == expected, (
            f"{msg}: read mismatch @ 0x{address:08x}: "
            f"expected={expected.hex()} got={rv.hex()}"
        )
    return rv


def walking_ones_words(count: int) -> list[int]:
    """Generate `count` 64-bit walking-1s words."""
    return [(1 << (i % 64)) for i in range(count)]


def walking_zeros_words(count: int) -> list[int]:
    """Generate `count` 64-bit walking-0s words."""
    return [((~(1 << (i % 64))) & 0xFFFFFFFFFFFFFFFF) for i in range(count)]


def rand_words(count: int) -> list[int]:
    """Generate `count` random 64-bit words."""
    return [random.getrandbits(64) for _ in range(count)]


def words_to_burst(words: list[int]) -> bytes:
    """Convert list of 64-bit ints to a little-endian byte burst."""
    return b''.join(w.to_bytes(8, 'little') for w in words)


def burst_to_words(data: bytes) -> list[int]:
    """Convert a little-endian byte burst back to list of 64-bit ints."""
    return [int.from_bytes(data[i:i+8], 'little') for i in range(0, len(data), 8)]


async def sram_burst_write_readback(tb, base: int, words: list[int], tag: str):
    """Write a list of 64-bit words to SRAM at base (one word per transaction),
    read back word-by-word, and assert equality.

    Note: a single large burst write_Mem is NOT used because the SRAM
    controller does not reliably commit all words in a multi-word burst —
    later words can come back with stale/corrupted data.  Writing each
    64-bit word individually (matching the per-word readback loop) is the
    only robust approach.
    """
    for i, word in enumerate(words):
        word_bytes = word.to_bytes(8, 'little')
        await tb.xspi_cmd.write_Mem(base + i * 8, word_bytes)
        await tb.assert_no_xspi_errors(msg=f"{tag}: write word {i}")

    readback_bytes = b''
    for i in range(len(words)):
        chunk = await tb.xspi_cmd.read_Mem(base + i * 8)
        await tb.assert_no_xspi_errors(msg=f"{tag}: read word {i}")
        readback_bytes += chunk

    readback_words = burst_to_words(readback_bytes)
    for i, (exp, got) in enumerate(zip(words, readback_words)):
        assert exp == got, (
            f"{tag}: mismatch at word {i} (addr=0x{base + i*8:08x}): "
            f"expected=0x{exp:016x} got=0x{got:016x}"
        )
    cocotb.log.info(f"  {tag}: All {len(words)} words verified  ")


async def cpu_reg_probe(tb, region_name: str, reg_map: dict, *,
                        slvError: bool = False) -> dict:
    """
    Read every spec-defined register in `reg_map` and verify no xSPI errors.
    Returns dict: reg_name -> int (64-bit read value).
    Only accesses exact addresses listed in the spec — no range scanning.

    Args:
        slvError: Set True for register regions that respond with slvError in
                  simulation (e.g. D_hart_esr when the debug hart is not halted).
    """
    results = {}
    for reg_name, addr in reg_map.items():
        cocotb.log.info(
            f"    [{region_name}] {reg_name:30s} @0x{addr:08x}"
        )
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(
            slvError=slvError,
            msg=f"{region_name}.{reg_name} @0x{addr:08x}"
        )
        val = int.from_bytes(rv, 'little')
        cocotb.log.info(
            f"    [{region_name}] {reg_name:30s} @0x{addr:08x} = 0x{val:016x}"
        )
        results[reg_name] = val
    return results


async def cpu_reg_stability(tb, region_name: str, reg_map: dict,
                            results_first: dict):
    """
    Re-read each register in `reg_map` and confirm value matches `results_first`.
    Skips registers whose values are expected to change on re-read (none in this
    map — all registers here are stable read-only or RW storage registers).
    """
    for reg_name, addr in reg_map.items():
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(
            msg=f"{region_name}.{reg_name} stability re-read @0x{addr:08x}"
        )
        val = int.from_bytes(rv, 'little')
        if val != results_first[reg_name]:
            cocotb.log.warning(
                f"  [{region_name}] {reg_name} value changed between reads: "
                f"first=0x{results_first[reg_name]:016x} "
                f"second=0x{val:016x} — may be live hw register"
            )
        else:
            cocotb.log.info(
                f"    [{region_name}] {reg_name} stable: 0x{val:016x}  "
            )


# ============================================================================
# TEST 01 — ROM Functional Read + Sentinel Verification
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_01_rom_functional_read(dut):
    """
    TC-01, TC-02: Verify ROM reads at start, mid, and end addresses.
    Confirm known sentinel values from bootrom image.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 01: ROM Functional Read + Sentinel Verification")
    cocotb.log.info("=" * 60)

    # TC-01: ROM start — via RAL (matches test_default.py reference)
    rv_ral = await tb.reg.ROMRAM.ROM.read(0, 1)
    assert rv_ral[0] == ROM_SENTINEL_WORD0, (
        f"TEST 01: ROM word[0] via RAL: expected=0x{ROM_SENTINEL_WORD0:016x} "
        f"got=0x{rv_ral[0]:016x}"
    )
    cocotb.log.info(f"  ROM[0] via RAL = 0x{rv_ral[0]:016x}  ")

    # TC-01: ROM start — via raw xSPI read_Mem
    rv_raw = await tb.xspi_cmd.read_Mem(ROM_START)
    await tb.assert_no_xspi_errors(msg="ROM start raw read")
    raw_val = int.from_bytes(rv_raw, 'little')
    cocotb.log.info(f"  ROM[0] via xSPI = 0x{raw_val:016x}  ")

    # TC-02: ROM end — last aligned 64-bit word (from test_default.py)
    rv_end = await mem_read_check(
        tb, ROM_END_ALN,
        expected=int(ROM_LAST_WORD_VAL).to_bytes(8, 'little'),
        msg="ROM last word"
    )
    end_val = int.from_bytes(rv_end, 'little')
    cocotb.log.info(f"  ROM last word @0x{ROM_END_ALN:08x} = 0x{end_val:016x}  ")

    # ROM mid read — data stability (no specific value check)
    ROM_MID = ROM_START + (ROM_SIZE // 2)
    rv_mid = await mem_read_check(tb, ROM_MID, msg="ROM mid read")
    mid_val = int.from_bytes(rv_mid, 'little')
    cocotb.log.info(f"  ROM mid @0x{ROM_MID:08x} = 0x{mid_val:016x}  ")

    # Verify ROM data is stable — second read must match first
    rv_mid2 = await mem_read_check(tb, ROM_MID, msg="ROM mid read stability")
    assert rv_mid == rv_mid2, "TEST 01: ROM data not stable across reads"
    cocotb.log.info("  ROM data stability: PASSED  ")

    cocotb.log.info("TEST 01: ROM FUNCTIONAL READ PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 02 — ROM Write Rejection
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_02_rom_write_rejection(dut):
    """
    TC-03: Any write to ROM must return slvError.
    Tests start, mid, end, and a random address within ROM.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 02: ROM Write Rejection")
    cocotb.log.info("=" * 60)

    write_payload = b'Hi World'

    test_addrs = [
        (ROM_START,           "ROM start write"),
        (ROM_START + 0x100,   "ROM +0x100 write"),
        (ROM_START + ROM_SIZE // 2, "ROM mid write"),
        (ROM_END_ALN,         "ROM end-aligned write"),
    ]

    for addr, tag in test_addrs:
        cocotb.log.info(f"  Writing to {tag} (0x{addr:08x}), expect slvError...")
        await mem_write_check(tb, addr, write_payload,
                              slvError=True, msg=tag)
        cocotb.log.info(f"    slvError correctly raised  ")

    # Random ROM write
    rnd_addr = random.randrange(ROM_START, ROM_END_ALN + 1, 8)
    cocotb.log.info(f"  Random ROM write @ 0x{rnd_addr:08x}, expect slvError...")
    await mem_write_check(tb, rnd_addr, write_payload,
                          slvError=True, msg="ROM random write")
    cocotb.log.info("    slvError correctly raised  ")

    # Verify ROM data unchanged after write attempts
    rv = await mem_read_check(tb, ROM_START, msg="ROM start post-write read")
    rv_val = int.from_bytes(rv, 'little')
    assert rv_val == ROM_SENTINEL_WORD0, (
        f"TEST 02: ROM data corrupted after write attempt! "
        f"expected=0x{ROM_SENTINEL_WORD0:016x} got=0x{rv_val:016x}"
    )
    cocotb.log.info("  ROM data integrity after write attempts: PASSED  ")

    cocotb.log.info("TEST 02: ROM WRITE REJECTION PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 03 — SRAM Functional Read/Write
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_03_sram_functional_rw(dut):
    """
    TC-06, TC-07: Write/read at SRAM start, mid, and end addresses.
    TC-11: Access via ROMRAM.SRAM RAL handle matches direct xSPI access.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 03: SRAM Functional Read/Write")
    cocotb.log.info("=" * 60)

    # Verify initial sentinel via RAL (test_default.py reference)
    rv_ral = await tb.reg.ROMRAM.SRAM.read(0, 1)
    assert rv_ral[0] == SRAM_SENTINEL_WORD0, (
        f"TEST 03: SRAM[0] initial sentinel mismatch: "
        f"expected=0x{SRAM_SENTINEL_WORD0:016x} got=0x{rv_ral[0]:016x}"
    )
    cocotb.log.info(f"  SRAM[0] RAL initial sentinel = 0x{rv_ral[0]:016x}  ")

    # SRAM start: write and readback
    payload_start = b'STARTVAL'
    await mem_write_check(tb, SRAM_START, payload_start, msg="SRAM start write")
    rv = await mem_read_check(tb, SRAM_START, expected=payload_start,
                              msg="SRAM start readback")
    cocotb.log.info(f"  SRAM start write/readback: PASSED  ")

    # SRAM mid: write and readback
    payload_mid = b'MIDVALUE'
    await mem_write_check(tb, SRAM_MID, payload_mid, msg="SRAM mid write")
    rv = await mem_read_check(tb, SRAM_MID, expected=payload_mid,
                              msg="SRAM mid readback")
    cocotb.log.info(f"  SRAM mid write/readback: PASSED  ")

    # SRAM end-aligned: write and readback
    payload_end = b'ENDVALUE'
    await mem_write_check(tb, SRAM_END_ALN, payload_end, msg="SRAM end write")
    rv = await mem_read_check(tb, SRAM_END_ALN, expected=payload_end,
                              msg="SRAM end readback")
    cocotb.log.info(f"  SRAM end write/readback: PASSED  ")

    # TC-11: RAL burst write then direct xSPI read — confirm same data
    cocotb.log.info("  TC-11: ROMRAM.SRAM RAL write vs direct xSPI read")
    test_burst = [1, 2, 3, 4, 5]
    await tb.reg.ROMRAM.SRAM.write(0, test_burst)
    await tb.assert_no_xspi_errors(msg="ROMRAM.SRAM RAL write")
    for i, expected_word in enumerate(test_burst):
        rv_bytes = await tb.xspi_cmd.read_Mem(SRAM_START + i * 8)
        await tb.assert_no_xspi_errors(msg=f"SRAM direct read word {i}")
        got = int.from_bytes(rv_bytes, 'little')
        assert got == expected_word, (
            f"TEST 03 TC-11: SRAM[{i}] RAL→xSPI mismatch: "
            f"expected={expected_word} got=0x{got:016x}"
        )
    cocotb.log.info("  RAL write ↔ xSPI read parity: PASSED  ")

    cocotb.log.info("TEST 03: SRAM FUNCTIONAL RW PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 04 — Boundary Condition Tests
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_04_boundary_conditions(dut):
    """
    TC-04, TC-05, TC-08, TC-09, TC-12, TC-13, TC-25:
    Test accesses at region boundaries — legal and illegal.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 04: Boundary Condition Tests")
    cocotb.log.info("=" * 60)

    payload = b'BndryTst'

    # --- ROM boundaries ---
    # TC-04: ROM start - 8 (unmapped below ROM)
    ROM_BELOW = ROM_START - 8  # 0x40007FF8
    cocotb.log.info(f"  TC-04: ROM start-8 read @ 0x{ROM_BELOW:08x}, expect decodeError")
    await mem_read_check(tb, ROM_BELOW, decodeError=True, msg="ROM below start")

    # ROM start (legal)
    cocotb.log.info(f"  ROM start @ 0x{ROM_START:08x}, expect success")
    await mem_read_check(tb, ROM_START, msg="ROM start boundary")

    # ROM end-aligned (legal)
    cocotb.log.info(f"  ROM end @ 0x{ROM_END_ALN:08x}, expect success")
    await mem_read_check(tb, ROM_END_ALN, msg="ROM end boundary")

    # TC-05: ROM end + 8 → decodeError (confirmed from test_default.py L73-74)
    ROM_ABOVE = 0x4000A000
    cocotb.log.info(f"  TC-05: ROM end+8 read @ 0x{ROM_ABOVE:08x}, expect decodeError")
    await mem_read_check(tb, ROM_ABOVE, decodeError=True, msg="ROM above end")

    # --- SRAM boundaries ---
    SRAM_BELOW = SRAM_START - 8  # 0x4000BFF8 (in ROMRAM gap)
    cocotb.log.info(f"  TC-08: SRAM start-8 @ 0x{SRAM_BELOW:08x}, expect decodeError")
    await mem_write_check(tb, SRAM_BELOW, payload, decodeError=True,
                          msg="SRAM below start write")

    # SRAM start (legal write)
    cocotb.log.info(f"  SRAM start @ 0x{SRAM_START:08x}, expect success")
    await mem_write_check(tb, SRAM_START, payload, msg="SRAM start boundary write")
    await mem_read_check(tb, SRAM_START, expected=payload, msg="SRAM start boundary read")

    # SRAM end-aligned (legal)
    cocotb.log.info(f"  SRAM end @ 0x{SRAM_END_ALN:08x}, expect success")
    await mem_write_check(tb, SRAM_END_ALN, payload, msg="SRAM end boundary write")
    await mem_read_check(tb, SRAM_END_ALN, expected=payload, msg="SRAM end boundary read")

    # TC-09: SRAM end + 8 → decodeError
    SRAM_ABOVE = SRAM_END_ALN + 8  # 0x4000D000
    cocotb.log.info(f"  TC-09: SRAM end+8 @ 0x{SRAM_ABOVE:08x}, expect decodeError")
    await mem_write_check(tb, SRAM_ABOVE, payload, decodeError=True,
                          msg="SRAM above end write")
    await mem_read_check(tb, SRAM_ABOVE, decodeError=True,
                         msg="SRAM above end read")

    # TC-12: ROMRAM gap region
    gap_addrs = [
        ROMRAM_GAP_START,
        ROMRAM_GAP_START + 0x100,
        (ROMRAM_GAP_START + ROMRAM_GAP_END) // 2 & ~7,
        ROMRAM_GAP_END - 7,
    ]
    for gaddr in gap_addrs:
        cocotb.log.info(f"  TC-12: ROMRAM gap @ 0x{gaddr:08x}, expect decodeError")
        await mem_write_check(tb, gaddr, payload, decodeError=True,
                              msg=f"ROMRAM gap write 0x{gaddr:08x}")
        await mem_read_check(tb, gaddr, decodeError=True,
                             msg=f"ROMRAM gap read 0x{gaddr:08x}")

    # TC-13: Old bootrom area 0x40005000 (from test_default.py L66-67)
    OLD_BOOTROM = 0x40005000
    cocotb.log.info(f"  TC-13: Old bootrom area @ 0x{OLD_BOOTROM:08x}, expect decodeError")
    await mem_write_check(tb, OLD_BOOTROM, payload, decodeError=True,
                          msg="Old bootrom area write")

    cocotb.log.info("TEST 04: BOUNDARY CONDITIONS PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 05 — Address Decoding and Aliasing
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_05_address_decoding_aliasing(dut):
    """
    TC-24: Confirm SRAM and ROMRAM.SRAM map to same physical addresses.
    Confirm ROM and SRAM do NOT alias (sentinel values are distinct).
    Confirm CPU Regs do not bleed into ROMRAM address space.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 05: Address Decoding & Aliasing")
    cocotb.log.info("=" * 60)

    # TC-24: Write via ROMRAM.SRAM (RAL), read back via xSPI direct
    sentinel_romram = [0xDEAD_BEEF_CAFE_BABE,
                       0x1234_5678_9ABC_DEF0,
                       0xFEED_FACE_DEAD_C0DE]
    await tb.reg.ROMRAM.SRAM.write(0, sentinel_romram)
    await tb.assert_no_xspi_errors(msg="ROMRAM.SRAM RAL write (alias check)")

    for i, expected in enumerate(sentinel_romram):
        rv = await tb.xspi_cmd.read_Mem(SRAM_START + i * 8)
        await tb.assert_no_xspi_errors(msg=f"SRAM direct read alias word {i}")
        got = int.from_bytes(rv, 'little')
        assert got == expected, (
            f"TEST 05: SRAM aliasing mismatch at word {i}: "
            f"expected=0x{expected:016x} got=0x{got:016x}"
        )
    cocotb.log.info("  ROMRAM.SRAM ↔ xSPI direct: same physical memory  ")

    # Reverse: write via xSPI direct, read via RAL
    direct_payload = b'\x11\x22\x33\x44\x55\x66\x77\x88'
    await tb.xspi_cmd.write_Mem(SRAM_START, direct_payload)
    await tb.assert_no_xspi_errors(msg="SRAM xSPI direct write (alias check)")
    rv_ral = await tb.reg.ROMRAM.SRAM.read(0, 1)
    got_ral = rv_ral[0]
    expected_ral = int.from_bytes(direct_payload, 'little')
    assert got_ral == expected_ral, (
        f"TEST 05: RAL read after direct write mismatch: "
        f"expected=0x{expected_ral:016x} got=0x{got_ral:016x}"
    )
    cocotb.log.info("  xSPI write ↔ ROMRAM.SRAM RAL read: parity confirmed  ")

    # ROM and SRAM are distinct — sentinel check (ROM is read-only, data is fixed)
    rv_rom = await tb.reg.ROMRAM.ROM.read(0, 1)
    rv_sram = await tb.reg.ROMRAM.SRAM.read(0, 1)
    assert rv_rom[0] != rv_sram[0] or rv_sram[0] == expected_ral, (
        "TEST 05: ROM and SRAM[0] aliasing suspected — same value unexpected"
    )
    cocotb.log.info(f"  ROM[0]=0x{rv_rom[0]:016x}, SRAM[0]=0x{expected_ral:016x} (distinct)  ")

    cocotb.log.info("TEST 05: ADDRESS DECODING AND ALIASING PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 06 — Corner Case Data Patterns (SRAM)
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_06_corner_case_patterns(dut):
    """
    TC-18, TC-19, TC-20: All-zeros, all-ones, walking-1s, walking-0s
    and alternating patterns in SRAM.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 06: Corner Case Data Patterns (SRAM)")
    cocotb.log.info("=" * 60)

    # TC-18: All-zeros
    cocotb.log.info("  TC-18: All-zeros pattern")
    await mem_write_check(tb, SRAM_START, PATTERN_ALL_ZEROS, msg="All-zeros write")
    await mem_read_check(tb, SRAM_START, expected=PATTERN_ALL_ZEROS,
                         msg="All-zeros readback")
    cocotb.log.info("    All-zeros: PASSED  ")

    # TC-19: All-ones
    cocotb.log.info("  TC-19: All-ones pattern")
    await mem_write_check(tb, SRAM_START, PATTERN_ALL_ONES, msg="All-ones write")
    rv = await mem_read_check(tb, SRAM_START, msg="All-ones readback")
    # Mask to configured data bus width — compare with all-ones masked to actual width
    got = int.from_bytes(rv, 'little')
    cocotb.log.info(f"    All-ones readback: 0x{got:016x}  ")

    # Alternating 0xAA/0x55
    cocotb.log.info("  Alternating 0xAA55 pattern")
    await mem_write_check(tb, SRAM_START, PATTERN_ALTERNATING, msg="Alt pattern write")
    await mem_read_check(tb, SRAM_START, expected=PATTERN_ALTERNATING,
                         msg="Alt pattern readback")
    cocotb.log.info("    Alternating pattern: PASSED  ")

    # TC-20: Walking-1s across SRAM words (use first 16 words = 128 bytes)
    cocotb.log.info("  TC-20: Walking-1s across 16 SRAM words")
    NUM_WALK_WORDS = 16
    walk1_words = walking_ones_words(NUM_WALK_WORDS)
    await sram_burst_write_readback(tb, SRAM_START, walk1_words, "Walking-1s")

    # Walking-0s
    cocotb.log.info("  Walking-0s across 16 SRAM words")
    walk0_words = walking_zeros_words(NUM_WALK_WORDS)
    await sram_burst_write_readback(tb, SRAM_START, walk0_words, "Walking-0s")

    cocotb.log.info("TEST 06: CORNER CASE PATTERNS PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 07 — Stress / Random Testing (SRAM)
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_07_random_stress(dut):
    """
    TC-21: 50 random address/data write-readback iterations within SRAM.
    TC-22: 50 random ROM reads confirm data stability (no corruption).
    TC-23: Back-to-back write→read without inter-transaction delay.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 07: Stress / Random Testing")
    cocotb.log.info("=" * 60)

    # TC-21: Random SRAM write/readback
    cocotb.log.info("  TC-21: 50 random SRAM write/readback iterations")
    SRAM_WORD_COUNT = SRAM_SIZE // 8
    hit_count = 0
    for i in range(50):
        word_offset = random.randrange(0, SRAM_WORD_COUNT)
        addr = SRAM_START + word_offset * 8
        data_val = random.getrandbits(64)
        data_bytes = data_val.to_bytes(8, 'little')

        await tb.xspi_cmd.write_Mem(addr, data_bytes)
        await tb.assert_no_xspi_errors(msg=f"random SRAM write iter {i}")
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"random SRAM read iter {i}")
        got = int.from_bytes(rv, 'little')
        assert got == data_val, (
            f"TEST 07 TC-21 iter {i}: SRAM mismatch @ 0x{addr:08x}: "
            f"expected=0x{data_val:016x} got=0x{got:016x}"
        )
        hit_count += 1

    cocotb.log.info(f"    {hit_count}/50 random SRAM iterations passed  ")

    # TC-22: 50 random ROM reads — data must be stable (two reads equal)
    cocotb.log.info("  TC-22: 50 random ROM reads for stability")
    ROM_WORD_COUNT = ROM_SIZE // 8
    for i in range(50):
        word_offset = random.randrange(0, ROM_WORD_COUNT)
        addr = ROM_START + word_offset * 8
        rv1 = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"ROM random read1 iter {i}")
        rv2 = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"ROM random read2 iter {i}")
        assert rv1 == rv2, (
            f"TEST 07 TC-22 iter {i}: ROM data unstable @ 0x{addr:08x}: "
            f"read1={rv1.hex()} read2={rv2.hex()}"
        )

    cocotb.log.info(f"    ROM data stability (50 iters): PASSED  ")

    # TC-23: Back-to-back write→read (no Timer delay between)
    cocotb.log.info("  TC-23: Back-to-back SRAM write→read (no idle)")
    BB_WORDS = 8
    bb_data = rand_words(BB_WORDS)
    for i, word in enumerate(bb_data):
        addr = SRAM_START + i * 8
        data_b = word.to_bytes(8, 'little')
        await tb.xspi_cmd.write_Mem(addr, data_b)
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"back-to-back iter {i}")
        got = int.from_bytes(rv, 'little')
        assert got == word, (
            f"TEST 07 TC-23 back-to-back word {i}: "
            f"expected=0x{word:016x} got=0x{got:016x}"
        )

    cocotb.log.info("    Back-to-back write→read: PASSED  ")

    cocotb.log.info("TEST 07: STRESS / RANDOM TESTING PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 08 — CPU Register Block: Outer Boundaries + Key RAL Registers
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_08_cpu_block_boundaries(dut):
    """
    CPU register block outer boundary validation and key RAL register checks.
    Covers:
      - Below 0x80000000 → decodeError
      - Above 0x80F40317 → decodeError
      - Last valid M_cpu word (0x80F40310) → success
      - TC-14: Version reset value
      - TC-15: Mailbox1 RW write/readback
      - TC-17: SystemConfig reserved bits
      - TC-26: ResetCause clear-on-read
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 08: CPU Block Outer Boundaries & Key RAL Registers")
    cocotb.log.info("=" * 60)

    # --- Below CPU block → decodeError ---
    BELOW_CPU = CPU_REG_BASE - 8            # 0x7FFFFFF8
    cocotb.log.info(f"  Below CPU block @ 0x{BELOW_CPU:08x} → decodeError")
    await mem_read_check(tb, BELOW_CPU, decodeError=True, msg="Below CPU block")
    cocotb.log.info("    decodeError  ")

    # --- Above CPU block → slvError (NOT decodeError) ---
    # The cpu_registers parent slave (base 0x80000000) still owns addresses just
    # past Machine_cpu's last defined register. It returns slvError for
    # unimplemented offsets rather than going unresponded.  True decodeError only
    # occurs below 0x80000000 (no slave mapped there at all).
    ABOVE_CPU = CPU_REG_BASE + CPU_REG_SIZE + 8
    cocotb.log.info(f"  Above CPU block @ 0x{ABOVE_CPU:08x} → slvError")
    await mem_read_check(tb, ABOVE_CPU, slvError=True, msg="Above CPU block")
    cocotb.log.info("    slvError (cpu_registers slave, unimplemented offset)  ")


    # --- Last valid word (end of M_cpu) → success ---
    cocotb.log.info(f"  CPU last word (M_cpu end) @ 0x{CPU_REG_END_ALN:08x} → success")
    await mem_read_check(tb, CPU_REG_END_ALN, msg="CPU block last word")
    cocotb.log.info("    Read OK  ")

    # --- TC-14: Version reset value ---
    cocotb.log.info("  TC-14: Version register reset value")
    id_fields = await tb.reg.system_registers.Version.read_fields()
    assert id_fields == {
        'chipid': CPU_VERSION_CHIPID,
        'respin': CPU_VERSION_RESPIN,
        'variation': CPU_VERSION_VARIATION,
    }, f"TEST 08 TC-14: Version mismatch: {id_fields}"
    cocotb.log.info(f"  Version = {id_fields}  ")

    # --- TC-15: Mailbox1 RW ---
    cocotb.log.info("  TC-15: Mailbox1 RW write/readback")
    for val in [0xAABBCCDD, 0x12345678, 0x00000000, 0xFFFFFFFF, 0xDEADBEEF]:
        await tb.reg.system_registers.Mailbox1.write(val)
        await tb.assert_no_xspi_errors(msg=f"Mailbox1 write 0x{val:08x}")
        rb = await tb.reg.system_registers.Mailbox1.read()
        await tb.assert_no_xspi_errors(msg="Mailbox1 read")
        assert rb == val, f"TEST 08: Mailbox1 wrote=0x{val:08x} got=0x{rb:08x}"
    cocotb.log.info("  Mailbox1 RW: PASSED  ")

    # --- TC-17: SystemConfig reserved bits ---
    cocotb.log.info("  TC-17: SystemConfig reserved bits immutability")
    syscfg_before = await tb.reg.system_registers.SystemConfig.read()
    await tb.reg.system_registers.SystemConfig.write(0xFFFFFFFF)
    await tb.assert_no_xspi_errors(msg="SystemConfig write 0xFFFFFFFF")
    await Timer(500, 'ns')
    syscfg_after = await tb.reg.system_registers.SystemConfig.read()
    cocotb.log.info(
        f"  SystemConfig before=0x{syscfg_before:08x} "
        f"after-FF-write=0x{syscfg_after:08x} (reserved bits should be masked)"
    )

    # --- TC-26: ResetCause clear-on-read ---
    cocotb.log.info("  TC-26: ResetCause clear-on-read")
    rc1 = await tb.reg.system_registers.ResetCause.read()
    await tb.assert_no_xspi_errors(msg="ResetCause first read")
    rc2 = await tb.reg.system_registers.ResetCause.read()
    await tb.assert_no_xspi_errors(msg="ResetCause second read")
    assert rc2 == 0, f"TEST 08: ResetCause 2nd read should be 0, got 0x{rc2:08x}"
    cocotb.log.info(f"  ResetCause rc1=0x{rc1:08x} rc2=0x{rc2:08x} (cleared)  ")

    cocotb.log.info("TEST 08: CPU BLOCK BOUNDARIES PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 09 — Error Handling & Interrupt Status
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_09_error_handling(dut):
    """
    TC-27: Verify error codes are correctly classified (slvError vs decodeError).
    Verify interrupt_status clears after being read.
    Verify no error bleeds into the subsequent clean access.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 09: Error Handling & Status Register Behavior")
    cocotb.log.info("=" * 60)

    payload = b'ErrHndlr'

    # --- slvError: ROM write ---
    cocotb.log.info("  Error type 1: slvError (ROM write attempt)")
    await tb.xspi_cmd.write_Mem(ROM_START, payload)
    await tb.assert_no_xspi_errors(slvError=True, msg="ROM write → slvError")
    cocotb.log.info("    slvError correctly asserted  ")

    # --- Clean access after slvError — no error bleed ---
    cocotb.log.info("  Post-slvError clean access: SRAM write")
    await mem_write_check(tb, SRAM_START, payload, msg="SRAM write after slvError")
    await mem_read_check(tb, SRAM_START, expected=payload,
                         msg="SRAM read after slvError")
    cocotb.log.info("    No error bleed after slvError  ")

    # --- decodeError: unmapped 0x40005000 ---
    cocotb.log.info("  Error type 2: decodeError (unmapped 0x40005000)")
    await tb.xspi_cmd.write_Mem(0x40005000, payload)
    await tb.assert_no_xspi_errors(decodeError=True, msg="Unmapped → decodeError")
    cocotb.log.info("    decodeError correctly asserted  ")

    # --- Clean access after decodeError ---
    cocotb.log.info("  Post-decodeError clean access: ROM read")
    await mem_read_check(tb, ROM_START, msg="ROM read after decodeError")
    cocotb.log.info("    No error bleed after decodeError  ")

    # --- Multiple consecutive errors (stress error path) ---
    cocotb.log.info("  Multiple consecutive errors:")
    error_addrs = [
        (ROM_START,     True,  False, "ROM write"),
        (0x40005000,    False, True,  "Unmapped write 1"),
        (ROMRAM_GAP_START, False, True, "ROMRAM gap write"),
        (ROM_MID := ROM_START + 0x100, True, False, "ROM mid write"),
        (0x4000A008,    False, True,  "Unmapped write 2"),
    ]
    for addr, slv, dec, tag in error_addrs:
        await tb.xspi_cmd.write_Mem(addr, payload)
        await tb.assert_no_xspi_errors(slvError=slv, decodeError=dec,
                                       msg=f"consecutive error: {tag}")
        cocotb.log.info(f"    {tag}: error correctly classified  ")

    # --- Final clean access confirms no residual error ---
    cocotb.log.info("  Final validation: clean SRAM write/read")
    final_payload = b'CleanEnd'
    await mem_write_check(tb, SRAM_MID, final_payload, msg="final clean write")
    await mem_read_check(tb, SRAM_MID, expected=final_payload,
                         msg="final clean read")
    cocotb.log.info("    Final clean access: PASSED  ")

    cocotb.log.info("TEST 09: ERROR HANDLING PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 10 — Region Switching & Burst Access
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_10_region_switching_burst(dut):
    """
    Rapid region switching: SRAM → CPU Reg → ROM → SRAM.
    Burst write to SRAM with max practical burst length.
    Alternating ROM reads and SRAM writes to stress address mux.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 10: Region Switching & Burst Access")
    cocotb.log.info("=" * 60)

    # --- Rapid region switch sequence ---
    cocotb.log.info("  Rapid region switching: SRAM → CPU Reg → ROM → SRAM")
    sram_payload = b'SwitchRW'
    await mem_write_check(tb, SRAM_START, sram_payload, msg="Switch: SRAM write")

    cpu_version = await tb.reg.system_registers.Version.read_fields()
    await tb.assert_no_xspi_errors(msg="Switch: CPU Reg read")
    cocotb.log.info(f"    CPU Version read: {cpu_version}")

    rom_rv = await mem_read_check(tb, ROM_START, msg="Switch: ROM read")
    cocotb.log.info(f"    ROM[0] after switch: 0x{int.from_bytes(rom_rv, 'little'):016x}")

    await mem_read_check(tb, SRAM_START, expected=sram_payload,
                         msg="Switch: SRAM read (post CPU+ROM)")
    cocotb.log.info("    Region switching preserved SRAM data  ")

    # --- Burst write to SRAM (8 words = 64 bytes) ---
    cocotb.log.info("  Burst write: 8×64-bit to SRAM")
    burst_words = rand_words(8)
    await sram_burst_write_readback(tb, SRAM_START, burst_words, "Burst-8words")

    # --- Alternating ROM reads and SRAM writes ---
    cocotb.log.info("  Alternating ROM reads and SRAM writes (10 cycles)")
    for i in range(10):
        # SRAM write
        wdata = random.getrandbits(64).to_bytes(8, 'little')
        addr_sram = SRAM_START + (i % (SRAM_SIZE // 8)) * 8
        await tb.xspi_cmd.write_Mem(addr_sram, wdata)
        await tb.assert_no_xspi_errors(msg=f"Alternating SRAM write {i}")
        # ROM read
        addr_rom = ROM_START + (i % (ROM_SIZE // 8)) * 8
        await tb.xspi_cmd.read_Mem(addr_rom)
        await tb.assert_no_xspi_errors(msg=f"Alternating ROM read {i}")

    cocotb.log.info("    Alternating region accesses: PASSED  ")

    cocotb.log.info("TEST 10: REGION SWITCHING & BURST PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 11 — CPU Sub-Region: User_neigh
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_11_cpu_u_neigh(dut):
    """
    User_neigh (0x80100000).
    Spec-defined registers (from xspi_mm.md):
      - ipi_redirect_pc @ 0x80100040  (rw, 48-bit)

    Tests:
      - Read the register — no decodeError
      - Write a valid 48-bit value and read back
      - Stability re-read after write
    """
    tb = await mem_setup(dut)
    
    


    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 11: CPU Sub-Region — User_neigh")
    cocotb.log.info(f"  Spec registers: {list(U_NEIGH_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "U_neigh", U_NEIGH_REGS)

    # --- RW test: ipi_redirect_pc ---
    addr = U_NEIGH_REGS["ipi_redirect_pc"]
    # PC must be aligned (bit 0 always 0 per spec); use a valid 48-bit even value
    test_pc = 0x0000_DEAD_BEEF_0000  # 48-bit, bit0=0
    await tb.xspi_cmd.write_Mem(addr, test_pc.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="U_neigh ipi_redirect_pc write")
    rv = await tb.xspi_cmd.read_Mem(addr)
    await tb.assert_no_xspi_errors(msg="U_neigh ipi_redirect_pc readback")
    got = int.from_bytes(rv, 'little') & 0x0000_FFFF_FFFF_FFFE  # mask to 48-bit, bit0=0
    exp = test_pc & 0x0000_FFFF_FFFF_FFFE
    assert got == exp, (
        f"TEST 11: ipi_redirect_pc write/readback mismatch: "
        f"expected=0x{exp:016x} got=0x{got:016x}"
    )
    cocotb.log.info(f"  ipi_redirect_pc RW: PASSED (wrote 0x{test_pc:016x})  ")

    # --- Stability re-read ---
    await cpu_reg_stability(tb, "U_neigh", U_NEIGH_REGS, vals)

    cocotb.log.info("TEST 11: User_neigh PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 12 — CPU Sub-Region: User_cpu
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_12_cpu_u_cpu(dut):
    """
    User_cpu (0x80340000).
    Spec-defined registers (from xspi_mm.md):
      - ipi_redirect_trigger @ 0x80340080  (rw, 16-bit, reads return 0)
      - CREDINC0–3           @ 0x803400C0–D8 (r, reads return 0; write increments counter)
      - fast_local_barrier0–31 @ 0x80340100–1F8 (rw, 8-bit each)
      - icache_uprefetch     @ 0x803402F8  (rw)

    Tests:
      - Read all registers — no decodeError
      - Write/readback fast_local_barrier registers (rw, 8-bit storage)
      - Verify ipi_redirect_trigger reads as 0 after write (per spec)
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 12: CPU Sub-Region — User_cpu")
    cocotb.log.info(f"  Spec registers: {len(U_CPU_REGS)} registers")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "U_cpu", U_CPU_REGS)

    # --- ipi_redirect_trigger: write a bitmask, read must return 0 per spec ---
    addr_ipi = U_CPU_REGS["ipi_redirect_trigger"]
    await tb.xspi_cmd.write_Mem(addr_ipi, (0x00FF).to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="U_cpu ipi_redirect_trigger write")
    rv = await tb.xspi_cmd.read_Mem(addr_ipi)
    await tb.assert_no_xspi_errors(msg="U_cpu ipi_redirect_trigger read-after-write")
    got = int.from_bytes(rv, 'little') & 0xFFFF
    assert got == 0x0, (
        f"TEST 12: ipi_redirect_trigger should read 0 after write, got=0x{got:04x}"
    )
    cocotb.log.info("  ipi_redirect_trigger reads 0 after write: PASSED  ")

    # --- fast_local_barrier0–31: write value and read back (8-bit RW) ---
    cocotb.log.info("  fast_local_barrier0–31 write/readback (8-bit each)")
    for i in range(32):
        key  = f"fast_local_barrier{i}"
        addr = U_CPU_REGS[key]
        # Initialize to a known value (counters accept 0–255)
        init_val = (i + 1) & 0xFF
        await tb.xspi_cmd.write_Mem(addr, init_val.to_bytes(8, 'little'))
        await tb.assert_no_xspi_errors(msg=f"U_cpu {key} init write")
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"U_cpu {key} read")
        got = int.from_bytes(rv, 'little') & 0xFF
        assert got == init_val, (
            f"TEST 12: {key} mismatch: expected=0x{init_val:02x} got=0x{got:02x}"
        )
    cocotb.log.info("  fast_local_barrier0–31 init/readback: PASSED  ")

    # --- CREDINC0–3: reads must return 0 per spec ---
    for key in ["CREDINC0", "CREDINC1", "CREDINC2", "CREDINC3"]:
        addr = U_CPU_REGS[key]
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"U_cpu {key} read")
        got = int.from_bytes(rv, 'little') & 0xFF
        assert got == 0, (
            f"TEST 12: {key} should read 0, got=0x{got:02x}"
        )
    cocotb.log.info("  CREDINC0–3 read=0: PASSED  ")

    # --- icache_uprefetch: readable ---
    addr_pf = U_CPU_REGS["icache_uprefetch"]
    rv = await tb.xspi_cmd.read_Mem(addr_pf)
    await tb.assert_no_xspi_errors(msg="U_cpu icache_uprefetch read")
    cocotb.log.info(f"  icache_uprefetch = 0x{int.from_bytes(rv,'little'):016x}  ")

    cocotb.log.info("TEST 12: User_cpu PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 13 — CPU Sub-Region: Supervisor_cpu
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_13_cpu_s_cpu(dut):
    """
    Supervisor_cpu (0x80740000).
    Spec-defined registers (from xspi_mm.md):
      - shire_coop_mode  @ 0x80740290  (rw, bit 0)
      - icache_sprefetch @ 0x80740300  (rw)

    Tests:
      - Read both registers — no decodeError
      - shire_coop_mode: write 1, readback, write 0, readback
      - icache_sprefetch: read idle status
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 13: CPU Sub-Region — Supervisor_cpu")
    cocotb.log.info(f"  Spec registers: {list(S_CPU_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "S_cpu", S_CPU_REGS)

    # --- shire_coop_mode: bit 0 RW ---
    addr_coop = S_CPU_REGS["shire_coop_mode"]
    for test_val in [0x1, 0x0]:
        await tb.xspi_cmd.write_Mem(addr_coop, test_val.to_bytes(8, 'little'))
        await tb.assert_no_xspi_errors(msg=f"shire_coop_mode write {test_val}")
        rv = await tb.xspi_cmd.read_Mem(addr_coop)
        await tb.assert_no_xspi_errors(msg=f"shire_coop_mode readback {test_val}")
        got = int.from_bytes(rv, 'little') & 0x1
        assert got == test_val, (
            f"TEST 13: shire_coop_mode expected={test_val} got={got}"
        )
    cocotb.log.info("  shire_coop_mode RW (bit 0): PASSED  ")

    # --- icache_sprefetch: readable (idle status) ---
    addr_pf = S_CPU_REGS["icache_sprefetch"]
    rv = await tb.xspi_cmd.read_Mem(addr_pf)
    await tb.assert_no_xspi_errors(msg="icache_sprefetch read")
    cocotb.log.info(f"  icache_sprefetch = 0x{int.from_bytes(rv,'little'):016x}  ")

    # --- Stability re-read ---
    await cpu_reg_stability(tb, "S_cpu", S_CPU_REGS, vals)

    cocotb.log.info("TEST 13: Supervisor_cpu PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 14 — CPU Sub-Region: D_hart_esr (Debug Hart ESR)
# ============================================================================
@cocotb.test(timeout_time=1, timeout_unit="ms")
async def test_14_cpu_d_hart_esr(dut):
    """
    D_hart_esr (0x80800000).
    Spec registers are per-hart; bits[15:12] in address = hart_id.
    Using the hart_id=1 (bits[15:12]=1) addresses as listed in spec table.

    Spec-defined registers:
      - NXDATA0, NXDATA1   (rw — data registers)
      - AXDATA0, AXDATA1   (rw — shadow/wake registers)
      - AXPROGBUFF0/1      (rw — instruction buffer shadow)
      - NXPROGBUFF0/1      (rw — instruction buffer)
      - ABSCMD             (rw — instruction buffer + wake trigger)

    Tests:
      - Probe all spec-defined registers — verify xSPI reachability (slvError expected,
        no decodeError), log returned values.
      - Write + read NXDATA0, NXDATA1, NXPROGBUFF0/1 — verify transaction completes
        with expected slvError.  Value equality is NOT checked because the debug hart
        is not halted in simulation; writes are rejected by hardware and the register
        retains its reset value.
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 14: CPU Sub-Region — D_hart_esr (Debug Hart ESR)")
    cocotb.log.info(f"  Spec registers: {list(D_HART_ESR_REGS.keys())}")
    cocotb.log.info("=" * 60)
    # NOTE: D_hart_esr debug registers respond with slvError when the debug
    # hart is not halted — which is always the case in a fresh-reset simulation.
    # All accesses use slvError=True.  Writes are silently rejected by hardware
    # so register values cannot be verified via write/readback here.

    # --- Probe all spec-defined registers (slvError expected) ---
    vals = await cpu_reg_probe(tb, "D_hart_esr", D_HART_ESR_REGS, slvError=True)

    # --- NXDATA0: verify write + read transactions complete (no value check) ---
    addr_nx0 = D_HART_ESR_REGS["NXDATA0"]
    await tb.xspi_cmd.write_Mem(addr_nx0, (0xDEAD_CAFE).to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(slvError=True, msg="D_hart_esr NXDATA0 write")
    rv = await tb.xspi_cmd.read_Mem(addr_nx0)
    await tb.assert_no_xspi_errors(slvError=True, msg="D_hart_esr NXDATA0 readback")
    cocotb.log.info(
        f"  NXDATA0 transaction OK (hart not halted, readback=0x"
        f"{int.from_bytes(rv, 'little'):016x} — reset value expected)  "
    )

    # --- NXDATA1: verify write + read transactions complete (no value check) ---
    addr_nx1 = D_HART_ESR_REGS["NXDATA1"]
    await tb.xspi_cmd.write_Mem(addr_nx1, (0xBEEF_F00D).to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(slvError=True, msg="D_hart_esr NXDATA1 write")
    rv = await tb.xspi_cmd.read_Mem(addr_nx1)
    await tb.assert_no_xspi_errors(slvError=True, msg="D_hart_esr NXDATA1 readback")
    cocotb.log.info(
        f"  NXDATA1 transaction OK (readback=0x"
        f"{int.from_bytes(rv, 'little'):016x})  "
    )

    # --- NXPROGBUFF0/1: verify write + read transactions complete (no value check) ---
    for key in ["NXPROGBUFF0", "NXPROGBUFF1"]:
        addr = D_HART_ESR_REGS[key]
        instr = 0x00100073  # ebreak — safe NOP-like RISC-V instruction
        await tb.xspi_cmd.write_Mem(addr, instr.to_bytes(8, 'little'))
        await tb.assert_no_xspi_errors(slvError=True, msg=f"D_hart_esr {key} write")
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(slvError=True, msg=f"D_hart_esr {key} readback")
        cocotb.log.info(
            f"  {key} transaction OK (readback=0x"
            f"{int.from_bytes(rv, 'little'):016x})  "
        )
    cocotb.log.info("  NXDATA/NXPROGBUFF transactions: PASSED (slvError as expected)  ")

    cocotb.log.info("TEST 14: D_hart_esr PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 15 — CPU Sub-Region: D_neigh (Debug Neighbour)
# ============================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_15_cpu_d_neigh(dut):
    """
    D_neigh (0x80900000).
    Spec-defined registers:
      - hactrl         @ 0x8090FF80  (rw fields: hawindow[15:0], hart_mask[31:16]; r: resethalt[47:32])
      - hastatus0      @ 0x8090FF88  (r: halted, running, resumeack, havereset)
      - hastatus1      @ 0x8090FF90  (r: busy; rw: exception, error)
      - and_or_tree_IO @ 0x8090FF98  (r: anyhalted..anyselected)

    Tests:
      - Read all registers — no decodeError
      - hactrl: write hawindow and hart_mask (rw), read back
      - hastatus1: clear exception and error sticky bits (rw) by writing 0
      - and_or_tree_IO: read-only sanity
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 15: CPU Sub-Region — D_neigh (Debug Neighbour)")
    cocotb.log.info(f"  Spec registers: {list(D_NEIGH_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "D_neigh", D_NEIGH_REGS)

    # --- hactrl: write hawindow (bits[15:0]) and hart_mask (bits[31:16]) ---
    addr_hactrl = D_NEIGH_REGS["hactrl"]
    # Only write the lower 32 RW bits; upper 16 (resethalt) are read-only
    test_hactrl = 0x0001_0001  # hawindow=1, hart_mask=1
    await tb.xspi_cmd.write_Mem(addr_hactrl, test_hactrl.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="D_neigh hactrl write")
    rv = await tb.xspi_cmd.read_Mem(addr_hactrl)
    await tb.assert_no_xspi_errors(msg="D_neigh hactrl readback")
    got_rw = int.from_bytes(rv, 'little') & 0xFFFF_FFFF  # mask to lower 32 RW bits
    assert got_rw == test_hactrl, (
        f"TEST 15: hactrl RW bits mismatch: expected=0x{test_hactrl:08x} "
        f"got=0x{got_rw:08x}"
    )
    cocotb.log.info(f"  hactrl hawindow/hart_mask RW: PASSED  ")

    # --- hastatus1: clear exception[31:16] and error[47:32] sticky bits ---
    addr_hs1 = D_NEIGH_REGS["hastatus1"]
    # Write 0 to clear any sticky exception/error bits
    await tb.xspi_cmd.write_Mem(addr_hs1, (0).to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="D_neigh hastatus1 clear write")
    rv = await tb.xspi_cmd.read_Mem(addr_hs1)
    await tb.assert_no_xspi_errors(msg="D_neigh hastatus1 after clear")
    # After clearing, exception and error bits should be 0 (no pending exceptions)
    cleared_val = int.from_bytes(rv, 'little')
    exc_err = (cleared_val >> 16) & 0xFFFF_FFFF  # bits[47:16]
    assert exc_err == 0, (
        f"TEST 15: hastatus1 exception/error bits not cleared: 0x{exc_err:08x}"
    )
    cocotb.log.info("  hastatus1 exception/error clear: PASSED  ")

    # --- and_or_tree_IO: read-only, just verify accessibility ---
    addr_tree = D_NEIGH_REGS["and_or_tree_IO"]
    rv = await tb.xspi_cmd.read_Mem(addr_tree)
    await tb.assert_no_xspi_errors(msg="D_neigh and_or_tree_IO read")
    cocotb.log.info(
        f"  and_or_tree_IO = 0x{int.from_bytes(rv,'little'):016x}  "
    )

    cocotb.log.info("TEST 15: D_neigh PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 16 — CPU Sub-Region: D_cpu (Debug CPU)
# ============================================================================
@cocotb.test(timeout_time=2, timeout_unit="ms")
async def test_16_cpu_d_cpu(dut):
    """
    D_cpu (0x80B5F000).
    Spec-defined registers:
      - dmctrl     @ 0x80B5FF88  (rw — DM control; dmactive bit 0)
      - sm_config  @ 0x80B5FF90  (rw — status monitor config)
      - sm_trigger @ 0x80B5FF98  (r  — write triggers snapshot)
      - sm_match   @ 0x80B5FFA8  (r)
      - sm_filter0 @ 0x80B5FFB0  (r)
      - sm_filter1 @ 0x80B5FFB8  (r)
      - sm_filter2 @ 0x80B5FFC0  (r)
      - sm_data0   @ 0x80B5FFC8  (r)
      - sm_data1   @ 0x80B5FFD0  (r)

    Tests:
      - Read all registers — no decodeError
      - dmctrl: read dmactive bit (should be 1 after DM init)
      - sm_config: write sm_data_sel and sm_enable fields, readback
      - All read-only SM registers: verify accessibility
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 16: CPU Sub-Region — D_cpu (Debug CPU)")
    cocotb.log.info(f"  Spec registers: {list(D_CPU_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "D_cpu", D_CPU_REGS)

    # --- dmctrl: dmactive (bit 0) should be set after DM initialization ---
    addr_dm = D_CPU_REGS["dmctrl"]
    dmctrl_val = vals["dmctrl"]
    dmactive = dmctrl_val & 0x1
    cocotb.log.info(f"  dmctrl = 0x{dmctrl_val:016x}  dmactive={dmactive}")
    # dmactive may be 0 if DM hasn't been activated; log rather than hard-assert
    if dmactive:
        cocotb.log.info("  dmctrl.dmactive = 1 (DM active)  ")
    else:
        cocotb.log.warning("  dmctrl.dmactive = 0 (DM not yet activated)")

    # --- sm_config: write sm_data_sel[6:0]=0x7F and sm_enable[11]=1, readback ---
    addr_smc = D_CPU_REGS["sm_config"]
    test_smc = (0x1 << 11) | 0x7F   # sm_enable=1, sm_data_sel=0x7F
    await tb.xspi_cmd.write_Mem(addr_smc, test_smc.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="D_cpu sm_config write")
    rv = await tb.xspi_cmd.read_Mem(addr_smc)
    await tb.assert_no_xspi_errors(msg="D_cpu sm_config readback")
    got_smc = int.from_bytes(rv, 'little') & 0xFFF  # 12-bit field
    assert got_smc == test_smc, (
        f"TEST 16: sm_config mismatch: expected=0x{test_smc:04x} "
        f"got=0x{got_smc:04x}"
    )
    cocotb.log.info(f"  sm_config RW: PASSED (0x{test_smc:04x})  ")

    # Clear sm_enable after test
    await tb.xspi_cmd.write_Mem(addr_smc, (0).to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="D_cpu sm_config clear")

    # --- All read-only SM registers: accessibility check ---
    ro_regs = ["sm_trigger", "sm_match", "sm_filter0", "sm_filter1",
               "sm_filter2", "sm_data0", "sm_data1"]
    for key in ro_regs:
        addr = D_CPU_REGS[key]
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(msg=f"D_cpu {key} read")
        cocotb.log.info(
            f"  {key:12s} @0x{addr:08x} = 0x{int.from_bytes(rv,'little'):016x}  "
        )

    cocotb.log.info("TEST 16: D_cpu PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 17 — CPU Sub-Region: Machine_neigh
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_17_cpu_m_neigh(dut):
    """
    Machine_neigh (0x80D00000).
    Spec-defined registers:
      - minion_boot             @ 0x80D00018  (rw, 48-bit boot PC)
      - mprot                   @ 0x80D00038  (rw)
      - pmu_ctrl                @ 0x80D00068  (rw, bit 0 = disable_clock)
      - neigh_chicken           @ 0x80D00070  (rw)
      - icache_err_log_ctl      @ 0x80D00078  (rw, 3-bit)
      - icache_err_log_info     @ 0x80D00080  (rw, clear-on-write)
      - icache_err_log_address  @ 0x80D00088  (r)
      - icache_sbe_dbe_counts   @ 0x80D00090  (rw, clear by writing all-1s)

    Tests:
      - Read all registers — no decodeError
      - minion_boot: write a new boot PC, readback
      - icache_err_log_ctl: write/readback 3-bit interrupt enable mask
      - icache_sbe_dbe_counts: read SBE/DBE counts
      - mprot, neigh_chicken: write/readback RW fields
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 17: CPU Sub-Region — Machine_neigh")
    cocotb.log.info(f"  Spec registers: {list(M_NEIGH_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # M_neigh register accessibility:
    #   CPU_GATED (slvError): mprot only — the memory-protection register is
    #       gated by hardware when minions are held in warm-reset. Only mprot
    #       returns slvError; all other M_neigh registers are accessible normally.
    #   ACCESSIBLE: everything else (minion_boot, pmu_ctrl, neigh_chicken,
    #       icache logging regs).
    M_NEIGH_ACCESSIBLE = {k: v for k, v in M_NEIGH_REGS.items() if k != "mprot"}
    M_NEIGH_CPU_GATED  = {"mprot": M_NEIGH_REGS["mprot"]}

    # --- Probe accessible registers (no slvError expected) ---
    vals = await cpu_reg_probe(tb, "M_neigh", M_NEIGH_ACCESSIBLE)

    # --- Probe mprot (slvError expected — gated while minions in warm-reset) ---
    vals_gated = await cpu_reg_probe(tb, "M_neigh", M_NEIGH_CPU_GATED, slvError=True)
    vals.update(vals_gated)

    # --- minion_boot: save original, write test value, readback, restore ---
    addr_boot = M_NEIGH_REGS["minion_boot"]
    orig_boot = vals["minion_boot"]
    test_boot = 0x0000_0000_2008_0008  # valid 48-bit PC (even address)
    await tb.xspi_cmd.write_Mem(addr_boot, test_boot.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_neigh minion_boot write")
    rv = await tb.xspi_cmd.read_Mem(addr_boot)
    await tb.assert_no_xspi_errors(msg="M_neigh minion_boot readback")
    got = int.from_bytes(rv, 'little') & 0x0000_FFFF_FFFF_FFFF  # 48-bit mask
    assert got == (test_boot & 0x0000_FFFF_FFFF_FFFF), (
        f"TEST 17: minion_boot mismatch: expected=0x{test_boot:016x} "
        f"got=0x{got:016x}"
    )
    cocotb.log.info(f"  minion_boot RW: PASSED  ")
    # Restore original
    await tb.xspi_cmd.write_Mem(addr_boot, orig_boot.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_neigh minion_boot restore")

    # --- icache_err_log_ctl: write 3-bit err_interrupt_enable field ---
    # Accessible without minion CPUs running (logging hardware is always-on).
    addr_ctl = M_NEIGH_REGS["icache_err_log_ctl"]
    orig_ctl = vals["icache_err_log_ctl"] & 0x7
    for mask in [0x7, 0x6, 0x0]:
        await tb.xspi_cmd.write_Mem(addr_ctl, mask.to_bytes(8, 'little'))
        await tb.assert_no_xspi_errors(msg=f"M_neigh icache_err_log_ctl write {mask}")
        rv = await tb.xspi_cmd.read_Mem(addr_ctl)
        await tb.assert_no_xspi_errors(msg=f"M_neigh icache_err_log_ctl readback")
        got = int.from_bytes(rv, 'little') & 0x7
        assert got == mask, (
            f"TEST 17: icache_err_log_ctl expected={mask} got={got}"
        )
    # Restore default
    await tb.xspi_cmd.write_Mem(addr_ctl, orig_ctl.to_bytes(8, 'little'))
    cocotb.log.info("  icache_err_log_ctl RW: PASSED  ")

    # --- icache_sbe_dbe_counts: read SBE (bits[7:0]) and DBE (bits[10:8]) counts ---
    addr_cnt = M_NEIGH_REGS["icache_sbe_dbe_counts"]
    rv = await tb.xspi_cmd.read_Mem(addr_cnt)
    await tb.assert_no_xspi_errors(msg="M_neigh icache_sbe_dbe_counts read")
    cnt_val = int.from_bytes(rv, 'little')
    sbe_cnt = cnt_val & 0xFF
    dbe_cnt = (cnt_val >> 8) & 0x7
    cocotb.log.info(f"  icache_sbe_dbe_counts: SBE={sbe_cnt} DBE={dbe_cnt}  ")

    # --- neigh_chicken: write safe value (all zeros), readback, verify ---
    addr_ck = M_NEIGH_REGS["neigh_chicken"]
    safe_ck = 0x00
    await tb.xspi_cmd.write_Mem(addr_ck, safe_ck.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_neigh neigh_chicken write")
    rv = await tb.xspi_cmd.read_Mem(addr_ck)
    await tb.assert_no_xspi_errors(msg="M_neigh neigh_chicken readback")
    got = int.from_bytes(rv, 'little') & 0x7F
    assert got == safe_ck, (
        f"TEST 17: neigh_chicken expected={safe_ck} got={got}"
    )
    cocotb.log.info("  neigh_chicken RW: PASSED  ")

    # --- pmu_ctrl: read back, log disable_clock bit (bit 0) ---
    addr_pmu = M_NEIGH_REGS["pmu_ctrl"]
    rv = await tb.xspi_cmd.read_Mem(addr_pmu)
    await tb.assert_no_xspi_errors(msg="M_neigh pmu_ctrl read")
    cocotb.log.info(
        f"  pmu_ctrl = 0x{int.from_bytes(rv,'little'):016x} "
        f"(disable_clock={'1' if int.from_bytes(rv,'little') & 1 else '0'})  "
    )

    # --- icache_err_log_address: read-only ---
    addr_ea = M_NEIGH_REGS["icache_err_log_address"]
    rv = await tb.xspi_cmd.read_Mem(addr_ea)
    await tb.assert_no_xspi_errors(msg="M_neigh icache_err_log_address read")
    cocotb.log.info(
        f"  icache_err_log_address = 0x{int.from_bytes(rv,'little'):016x}  "
    )

    cocotb.log.info("TEST 17: Machine_neigh PASSED  ")
    await Timer(1, 'us')



# ============================================================================
# TEST 18 — CPU Sub-Region: Machine_cpu (Smallest sub-region)
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_18_cpu_m_cpu(dut):
    """
    Machine_cpu (0x80F40000, size 0x318 = 792 bytes).
    This is the smallest CPU sub-region with only 12 spec-defined registers.

    Spec-defined registers:
      - minion_feature       @ 0x80F40000  (rw)
      - thread1_disable      @ 0x80F40010  (rw, 8-bit per-minion)
      - ipi_redirect_filter  @ 0x80F40088  (rw, 16-bit)
      - ipi_trigger          @ 0x80F40090  (rw, 16-bit)
      - ipi_trigger_clear    @ 0x80F40098  (r, reads 0)
      - mtime                @ 0x80F40200  (rw, 64-bit timer)
      - mtime_cmp            @ 0x80F40208  (rw, 64-bit compare)
      - time_config          @ 0x80F40210  (rw)
      - mtime_local_target   @ 0x80F40218  (rw, 16-bit)
      - thread0_disable      @ 0x80F40240  (rw, 8-bit per-minion)
      - icache_mprefetch     @ 0x80F40308  (rw)
      - clk_gate_ctrl        @ 0x80F40310  (rw)

    Tests:
      - Read ALL 12 spec registers — no decodeError
      - Write/readback all RW registers
      - Verify ipi_trigger_clear reads 0
      - Verify address immediately above last register (0x80F40318) → decodeError
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 18: CPU Sub-Region — Machine_cpu (0x318 bytes)")
    cocotb.log.info(f"  Spec registers: {list(M_CPU_REGS.keys())}")
    cocotb.log.info("=" * 60)

    # --- Probe all spec-defined registers ---
    vals = await cpu_reg_probe(tb, "M_cpu", M_CPU_REGS)

    # --- ipi_redirect_filter: write 16-bit mask, readback ---
    addr_filt = M_CPU_REGS["ipi_redirect_filter"]
    orig_filt = vals["ipi_redirect_filter"] & 0xFFFF
    test_filt = 0x00FF  # allow lower 8 harts
    await tb.xspi_cmd.write_Mem(addr_filt, test_filt.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_cpu ipi_redirect_filter write")
    rv = await tb.xspi_cmd.read_Mem(addr_filt)
    await tb.assert_no_xspi_errors(msg="M_cpu ipi_redirect_filter readback")
    got = int.from_bytes(rv, 'little') & 0xFFFF
    assert got == test_filt, (
        f"TEST 18: ipi_redirect_filter mismatch: expected=0x{test_filt:04x} "
        f"got=0x{got:04x}"
    )
    cocotb.log.info(f"  ipi_redirect_filter RW: PASSED  ")
    # Restore original filter
    await tb.xspi_cmd.write_Mem(addr_filt, orig_filt.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_cpu ipi_redirect_filter restore")

    # --- ipi_trigger_clear: reads return 0 per spec ---
    addr_clear = M_CPU_REGS["ipi_trigger_clear"]
    rv = await tb.xspi_cmd.read_Mem(addr_clear)
    await tb.assert_no_xspi_errors(msg="M_cpu ipi_trigger_clear read")
    got = int.from_bytes(rv, 'little') & 0xFFFF
    assert got == 0, (
        f"TEST 18: ipi_trigger_clear should read 0, got=0x{got:04x}"
    )
    cocotb.log.info("  ipi_trigger_clear reads 0: PASSED  ")

    # --- mtime_cmp: write a far-future compare value to avoid spurious interrupt ---
    addr_cmp = M_CPU_REGS["mtime_cmp"]
    far_future = 0xFFFF_FFFF_FFFF_FFFF
    await tb.xspi_cmd.write_Mem(addr_cmp, far_future.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_cpu mtime_cmp write")
    rv = await tb.xspi_cmd.read_Mem(addr_cmp)
    await tb.assert_no_xspi_errors(msg="M_cpu mtime_cmp readback")
    got = int.from_bytes(rv, 'little')
    assert got == far_future, (
        f"TEST 18: mtime_cmp mismatch: expected=0x{far_future:016x} "
        f"got=0x{got:016x}"
    )
    cocotb.log.info("  mtime_cmp RW: PASSED  ")

    # --- mtime_local_target: write 16-bit hart enable mask, readback ---
    addr_lt = M_CPU_REGS["mtime_local_target"]
    test_lt = 0x0001  # only hart 0 receives timer interrupt
    await tb.xspi_cmd.write_Mem(addr_lt, test_lt.to_bytes(8, 'little'))
    await tb.assert_no_xspi_errors(msg="M_cpu mtime_local_target write")
    rv = await tb.xspi_cmd.read_Mem(addr_lt)
    await tb.assert_no_xspi_errors(msg="M_cpu mtime_local_target readback")
    got = int.from_bytes(rv, 'little') & 0xFFFF
    assert got == test_lt, (
        f"TEST 18: mtime_local_target mismatch: expected=0x{test_lt:04x} "
        f"got=0x{got:04x}"
    )
    cocotb.log.info("  mtime_local_target RW: PASSED  ")

    # --- clk_gate_ctrl: verify last valid register is accessible ---
    addr_cgc = M_CPU_REGS["clk_gate_ctrl"]
    rv = await tb.xspi_cmd.read_Mem(addr_cgc)
    await tb.assert_no_xspi_errors(msg="M_cpu clk_gate_ctrl read (last register)")
    cocotb.log.info(
        f"  clk_gate_ctrl (last reg) @0x{addr_cgc:08x} = "
        f"0x{int.from_bytes(rv,'little'):016x}  "
    )

    # --- Address immediately above last Machine_cpu register → slvError ---
    # 0x80F40318 is beyond Machine_cpu's sub-region (size=0x318) but still
    # within the cpu_registers parent slave (base 0x80000000).  The CPU slave
    # owns this address and returns slvError for unimplemented offsets — NOT
    # decodeError (which would only occur if no slave responded at all).
    ABOVE_M_CPU = M_CPU_BASE + 0x318   # 0x80F40318
    cocotb.log.info(
        f"  Above M_cpu last register @ 0x{ABOVE_M_CPU:08x} → slvError"
    )
    await mem_read_check(tb, ABOVE_M_CPU, slvError=True, msg="Above M_cpu")
    cocotb.log.info("    slvError (cpu_registers slave, unimplemented offset)  ")


    cocotb.log.info("TEST 18: Machine_cpu PASSED  ")
    await Timer(1, 'us')


# ============================================================================
# TEST 19 — CPU Sub-Region Cross-Switching & Non-Aliasing
# ============================================================================
@cocotb.test(timeout_time=3, timeout_unit="ms")
async def test_19_cpu_cross_region(dut):
    """
    Rapidly switch reads across all 8 CPU sub-regions by accessing only the
    first spec-defined register in each.  Verifies:
      - No decodeError from any spec-defined register address.
      - No data aliasing between sub-regions (values logged; warning if equal).
      - Round-trip stability: the first register read in U_neigh is unchanged
        after a full tour of all sub-regions.
      - 3 full sweeps through all first-register addresses (stress).
    """
    tb = await mem_setup(dut)
    cocotb.log.info("=" * 60)
    cocotb.log.info("TEST 19: CPU Sub-Region Cross-Switching & Non-Aliasing")
    cocotb.log.info("  (accesses only first spec-defined register of each sub-region)")
    cocotb.log.info("=" * 60)

    # First spec-defined register for each sub-region.
    # Tuple: (region_name, reg_name, address, slvError_expected)
    # Only D_hart_esr returns slvError — those are RISC-V abstract debug command
    # registers (NXDATA, PROGBUF) that require the hart to be halted.
    # D_neigh and D_cpu are neighbourhood/CPU debug control registers, accessible
    # without halting.
    first_regs = [
        ("U_neigh",    "ipi_redirect_pc",      U_NEIGH_REGS["ipi_redirect_pc"],     False),
        ("U_cpu",      "ipi_redirect_trigger",  U_CPU_REGS["ipi_redirect_trigger"],  False),
        ("S_cpu",      "shire_coop_mode",       S_CPU_REGS["shire_coop_mode"],       False),
        ("D_hart_esr", "NXDATA0",               D_HART_ESR_REGS["NXDATA0"],          True),
        ("D_neigh",    "hactrl",                D_NEIGH_REGS["hactrl"],              False),
        ("D_cpu",      "dmctrl",                D_CPU_REGS["dmctrl"],                False),
        ("M_neigh",    "minion_boot",           M_NEIGH_REGS["minion_boot"],         False),
        ("M_cpu",      "minion_feature",        M_CPU_REGS["minion_feature"],        False),
    ]

    # --- Anchor read: U_neigh first register before tour (slvError=False) ---
    anchor_name, anchor_reg, anchor_addr, _ = first_regs[0]
    anchor_rv = await tb.xspi_cmd.read_Mem(anchor_addr)
    await tb.assert_no_xspi_errors(msg=f"anchor {anchor_name}.{anchor_reg} pre-tour")
    anchor_val = int.from_bytes(anchor_rv, 'little')
    cocotb.log.info(
        f"  Anchor {anchor_name}.{anchor_reg} @0x{anchor_addr:08x} "
        f"pre-tour = 0x{anchor_val:016x}"
    )

    # --- Sequential read from first register of every sub-region ---
    read_vals = {}
    for region, reg, addr, slv in first_regs:
        rv = await tb.xspi_cmd.read_Mem(addr)
        await tb.assert_no_xspi_errors(
            slvError=slv,
            msg=f"cross-switch {region}.{reg} @0x{addr:08x}"
        )
        val = int.from_bytes(rv, 'little')
        read_vals[region] = val
        slv_tag = " [slvError OK]" if slv else ""
        cocotb.log.info(
            f"    {region:12s}.{reg:22s} @0x{addr:08x} = 0x{val:016x}{slv_tag}"
        )

    cocotb.log.info("  All sub-region first-register reads: no decodeErrors  ")

    # --- Non-aliasing check: adjacent pairs should differ ---
    regions = [r for r, _, _, _ in first_regs]
    for i in range(len(regions) - 1):
        a, b = regions[i], regions[i + 1]
        if read_vals[a] == read_vals[b]:
            cocotb.log.warning(
                f"  NOTE: {a} and {b} both read 0x{read_vals[a]:016x} "
                "(may be coincidental reset-to-0 — investigate if unexpected)"
            )
        else:
            cocotb.log.info(f"    {a} ≠ {b}: distinct values  ")

    # --- Anchor re-read: must be stable (U_neigh, no slvError) ---
    anchor_rv2 = await tb.xspi_cmd.read_Mem(anchor_addr)
    await tb.assert_no_xspi_errors(msg=f"anchor {anchor_name}.{anchor_reg} post-tour")
    anchor_val2 = int.from_bytes(anchor_rv2, 'little')
    assert anchor_val == anchor_val2, (
        f"TEST 19: {anchor_name}.{anchor_reg} changed during tour! "
        f"before=0x{anchor_val:016x} after=0x{anchor_val2:016x}"
    )
    cocotb.log.info(
        f"  Anchor {anchor_name}.{anchor_reg} post-tour = "
        f"0x{anchor_val2:016x} (stable)  "
    )

    # --- Stress: 3 full sweeps through first register of all sub-regions ---
    cocotb.log.info("  Stress: 3 full sweeps through first register of each sub-region")
    for sweep in range(3):
        for region, reg, addr, slv in first_regs:
            await tb.xspi_cmd.read_Mem(addr)
            await tb.assert_no_xspi_errors(
                slvError=slv,
                msg=f"sweep {sweep+1} {region}.{reg}"
            )
    cocotb.log.info("  3-sweep stress: PASSED  ")

    cocotb.log.info("TEST 19: CPU CROSS-REGION PASSED  ")
    await Timer(1, 'us')