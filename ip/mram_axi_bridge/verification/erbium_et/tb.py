import os
import sys
import logging
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock

import random
from concurrent.futures import ThreadPoolExecutor

from et_bch import et_bch_decode_79_to_64, et_bch_encode_64_to_79

from cocotbext.axi import AddressSpace, SparseMemoryRegion
from cocotbext.axi import AxiBus, AxiLiteMaster, AxiSlave, AxiLiteBus, AxiMaster
from cocotbext.axi import AxiLockType, AxiResp

import random

# Deterministic RNG for reproducible test data.
# Each test re-seeds via seed_rng() so failures reproduce across runs.
_rng = random.Random(0)
TEST_SEED = 42  # Global base seed; override via COCOTB_TEST_SEED env var if desired
REPO_ROOT = Path(__file__).resolve().parents[2]
REGBLOCK_PYTHON_DIR = REPO_ROOT / "regblocks" / "python"

if str(REGBLOCK_PYTHON_DIR) not in sys.path:
    sys.path.insert(0, str(REGBLOCK_PYTHON_DIR))

if TYPE_CHECKING:
    from regblocks.python.axi2mram_bridge_registers.reg_model.axi2mram_bridge_registers import (
        axi2mram_bridge_registers_cls as TregRegModel,
    )

try:
    from axi2mram_bridge_registers.lib import AsyncCallbackSet
    from axi2mram_bridge_registers.reg_model.axi2mram_bridge_registers import (
        axi2mram_bridge_registers_cls,
    )
    REGBLOCK_IMPORT_ERROR = None
except ImportError as exc:
    AsyncCallbackSet = None
    axi2mram_bridge_registers_cls = None
    REGBLOCK_IMPORT_ERROR = exc

def env_flag(name, default="0"):
    """Parse a make-exported flag from the cocotb environment."""
    value = os.environ.get(name, str(default)).strip().lower()
    return value not in ("", "0", "false", "no", "off")

CONTROLLER_BYPASS = env_flag(
    "CONTROLLER_BYPASS",
    os.environ.get("BYPASS_CONTROLLER", "0"),
)
MRAM_ADDR_WIDTH = 17
MRAM_COL_ADDR_WIDTH = 4
MRAM_PLANE_ADDR_WIDTH = 3
MRAM_RESERVE_ADDR_WIDTH = 1
MRAM_NUM_PLANES = 1 << MRAM_PLANE_ADDR_WIDTH
MRAM_NUM_RESERVED_ROWS = 13
MRAM_NORM_ROW_ADDR_WIDTH = (
    MRAM_ADDR_WIDTH - MRAM_RESERVE_ADDR_WIDTH - MRAM_PLANE_ADDR_WIDTH - MRAM_COL_ADDR_WIDTH
)
MRAM_WORDS_PER_ROW = 1 << MRAM_COL_ADDR_WIDTH
MRAM_WORDS_PER_PLANE = MRAM_WORDS_PER_ROW * (
    (1 << MRAM_NORM_ROW_ADDR_WIDTH) + MRAM_NUM_RESERVED_ROWS
)
OTP_BASE_ADDR = 0x3FFF_D000
OTP_SIZE_BYTES = 12 * 1024
OTP_VALID_COLS = (0, 3, 4, 9, 10, 15)
OTP_FIXED_ROW = 12


class _ResetEdgeDedupFilter(logging.Filter):
    """Keep one log line per reset edge even if multiple subinterfaces emit it."""

    def __init__(self):
        super().__init__()
        self._last_reset_edge = None

    def filter(self, record):
        message = record.getMessage()
        if message in ("Reset asserted", "Reset de-asserted"):
            if message == self._last_reset_edge:
                return False
            self._last_reset_edge = message
        return True

def seed_rng(extra=0):
    """Re-seed the test RNG. Call at the start of each test with a unique extra value."""
    base = int(os.environ.get("COCOTB_TEST_SEED", str(TEST_SEED)))
    _rng.seed(base + extra)

def rand_bytes(n):
    """Return a bytearray of n random bytes from the seeded RNG."""
    return bytearray(_rng.getrandbits(8) for _ in range(n))


class AxiLiteRegModelCallbacks:
    """Bridge PeakRDL async callbacks onto cocotbext-axi's AxiLiteMaster."""

    def __init__(self, treg_master):
        self._treg_master = treg_master

    async def read(self, addr, width, accesswidth):
        if width % 8 != 0 or accesswidth % 8 != 0:
            raise ValueError(f"Unsupported register width/accesswidth: {width}/{accesswidth}")
        result = await self._treg_master.read(addr, width // 8)
        return int.from_bytes(result.data, "little")

    async def write(self, addr, width, accesswidth, data):
        if width % 8 != 0 or accesswidth % 8 != 0:
            raise ValueError(f"Unsupported register width/accesswidth: {width}/{accesswidth}")
        await self._treg_master.write(addr, int(data).to_bytes(width // 8, "little"))


def build_treg_reg_model(treg_master) -> "TregRegModel":
    if axi2mram_bridge_registers_cls is None or AsyncCallbackSet is None:
        raise RuntimeError(f"Generated regblock Python package unavailable: {REGBLOCK_IMPORT_ERROR}")

    callbacks = AxiLiteRegModelCallbacks(treg_master)
    return cast(
        "TregRegModel",
        axi2mram_bridge_registers_cls(
            callbacks=AsyncCallbackSet(
                read_callback=callbacks.read,
                write_callback=callbacks.write,
            )
        )
    )


def sig_int(signal):
    return int(signal.value)


def axi_event_result(op):
    """Return the AXI response object across cocotbext-axi event API variants."""
    if hasattr(op, "result"):
        return op.result
    if hasattr(op, "data"):
        return op.data
    raise AttributeError(f"AXI operation object {type(op).__name__} has no result payload")


def axi_data(op):
    return axi_event_result(op).data


def axi_resp(op):
    return axi_event_result(op).resp


async def write_mram_control_fields(tregs, *, mram_clk_single_pulse=0, **kwargs):
    """Write buffered mram_control fields, then commit via mram_control_pulse.

    Args:
        tregs: bank*_tregs object from the generated register model.
        mram_clk_single_pulse: 0 commits without pulsing MRAM clock; 1 commits and pulses.
        **kwargs: fields for mram_control.write_fields().
    """
    if kwargs:
        await tregs.mram_control.write_fields(**kwargs)
    await tregs.mram_control_pulse.write_fields(
        mram_clk_single_pulse=1 if mram_clk_single_pulse else 0
    )


class TB:
    def __init__(self):
        self._direct_mram_warning_tags = set()
        self._reset_log_filters = {}
        self._matrix_step = 0
        self._clock_task = None
        self._clock_period_ps = 1_000
        self._dynamic_clock = False

    def set_dut(self, dut):
        self.tb_top = dut
        self.dut = dut.dut

    @staticmethod
    def frequency_to_period_ps(frequency_hz):
        if frequency_hz <= 0:
            raise ValueError(f"Clock frequency must be positive, got {frequency_hz}")
        return max(2, int(round(1_000_000_000_000 / float(frequency_hz))))

    def get_clock_period_ps(self):
        return int(self._clock_period_ps)

    def set_clock_frequency_hz(self, frequency_hz):
        self._clock_period_ps = self.frequency_to_period_ps(frequency_hz)

    def set_clock_period_ns(self, clock_period_ns):
        if clock_period_ns <= 0:
            raise ValueError(f"Clock period must be positive, got {clock_period_ns}")
        self._clock_period_ps = max(2, int(round(float(clock_period_ns) * 1_000)))

    async def _run_dynamic_clock(self):
        self.dut.clk.value = 0
        while True:
            period_ps = max(2, int(self._clock_period_ps))
            low_ps = max(1, period_ps // 2)
            high_ps = max(1, period_ps - low_ps)
            await Timer(low_ps, unit="ps")
            self.dut.clk.value = 1
            await Timer(high_ps, unit="ps")
            self.dut.clk.value = 0

    def initialize_clock(self, *, frequency_hz=None, clock_period_ns=None, dynamic=False):
        if frequency_hz is not None and clock_period_ns is not None:
            raise ValueError("Specify either frequency_hz or clock_period_ns, not both")

        if clock_period_ns is not None:
            self.set_clock_period_ns(clock_period_ns)
        elif frequency_hz is None:
            self._clock_period_ps = 1_000  # 1 GHz default
        else:
            self.set_clock_frequency_hz(frequency_hz)

        self._dynamic_clock = dynamic
        if dynamic:
            self._clock_task = cocotb.start_soon(self._run_dynamic_clock())
        else:
            self._clock_task = cocotb.start_soon(
                Clock(self.dut.clk, self._clock_period_ps, unit="ps").start()
            )

    def _install_reset_log_dedup_filter(self, logger):
        if logger.name in self._reset_log_filters:
            return
        dedup_filter = _ResetEdgeDedupFilter()
        logger.addFilter(dedup_filter)
        self._reset_log_filters[logger.name] = dedup_filter

    def create_axi_master(self, enable_axi_master=True):
        self.dut.rst_b.set(0)
        if enable_axi_master:
            self.axi_master = AxiMaster(
                AxiBus.from_prefix(self.dut, "s_axi"),
                self.dut.clk,
                self.dut.rst_b,
                reset_active_level=False,
            )
            self._install_reset_log_dedup_filter(self.axi_master.write_if.log)
            self._install_reset_log_dedup_filter(self.axi_master.read_if.log)
        else:
            self.axi_master = None
        for signal in self.dut:
            if signal._name.startswith("s_axil_treg"):
                if not signal.value.is_resolvable:
                    signal.value = 0
        self.axi_treg_master = AxiLiteMaster(AxiLiteBus.from_prefix(self.dut, "s_axil_treg"), self.dut.clk, None, reset_active_level=False)
        # Reclassify AXI-Lite treg bus transactions as DEBUG while leaving
        # unrelated INFO-level cocotb/testbench logs intact.
        self.axi_treg_master.write_if.log.info = self.axi_treg_master.write_if.log.debug
        self.axi_treg_master.read_if.log.info = self.axi_treg_master.read_if.log.debug

    async def reset_sequence(self, *, reset_low_cycles=0, reset_release_cycles=0):
        treg_reg = build_treg_reg_model(self.axi_treg_master)
        self.dut.rst_b.value = 1
        self.dut.mram_rst_b.value = 1
        await Timer(10, unit="ns")
        self.dut.rst_b.value = 0
        for _ in range(int(reset_low_cycles)):
            await RisingEdge(self.dut.clk)
        await Timer(10, unit="ns")
        self.dut.rst_b.value = 1
        for _ in range(int(reset_release_cycles)):
            await RisingEdge(self.dut.clk)
        await Timer(10, unit="ns")
        while True:
            value = await treg_reg.bridge_regs.bridge_status_reg.mram_ready.read()
            if value == 0xf:
                break

    def setup_tb(self, enable_axi_master=True, *, dynamic_clock=False, frequency_hz=None, clock_period_ns=None):
        self.dut._log.info("CONTROLLER_BYPASS=%d", int(CONTROLLER_BYPASS))
        self.initialize_clock(
            frequency_hz=frequency_hz,
            clock_period_ns=clock_period_ns,
            dynamic=dynamic_clock,
        )
        self.create_axi_master(enable_axi_master=enable_axi_master)
        self.initialize_signals()

    def initialize_signals(self):
        self.dut.clk.value = 0
        self.dut.rst_b.value = 0
        self.dut.mram_rst_b.value = 0
        self.dut.dsleep.value = 0
        self.dut.nvsram_startup_bypass.value = 0

    def _resolve_dut_path(self, path):
        """Resolve a full Verilog hierarchical path from the DUT root."""
        current = self.dut
        tokens = path.split(".")
        token_idx = 0

        while token_idx < len(tokens):
            resolved = None

            for end_idx in range(len(tokens), token_idx, -1):
                candidate = ".".join(tokens[token_idx:end_idx])
                for resolver in (
                    lambda obj, name: getattr(obj, name),
                    lambda obj, name: obj[name],
                ):
                    try:
                        resolved = resolver(current, candidate)
                        token_idx = end_idx
                        current = resolved
                        break
                    except Exception:
                        continue

                if resolved is not None:
                    break

            if resolved is None:
                return None

        return current

    def _resolve_child_handle(self, parent, name):
        for resolver in (
            lambda obj, child_name: getattr(obj, child_name),
            lambda obj, child_name: obj[child_name],
        ):
            try:
                return resolver(parent, name)
            except Exception:
                continue
        return None

    def warn_direct_mram_access(self, action, detail, tag=None):
        warning_tag = tag if tag is not None else detail
        if warning_tag in self._direct_mram_warning_tags:
            return
        self._direct_mram_warning_tags.add(warning_tag)
        self.dut._log.warning(
            "Direct MRAM hierarchy %s is about to occur: %s",
            action,
            detail,
        )

    def set_wave_matrix_label(self, label):
        if not hasattr(self, "tb_top"):
            return
        if not hasattr(self.tb_top, "tb_matrix_label") or not hasattr(self.tb_top, "tb_matrix_step"):
            return

        label_bytes = 128
        encoded = label.encode("ascii", errors="replace")[:label_bytes]
        packed = int.from_bytes(encoded.ljust(label_bytes, b"\x00"), byteorder="big")

        self._matrix_step = (self._matrix_step + 1) & 0xFFFF_FFFF
        self.tb_top.tb_matrix_label.value = packed
        self.tb_top.tb_matrix_step.value = self._matrix_step

    def _bank_model_paths(self, bank_idx):
        bypass_path = f"mram_bank[{bank_idx}].u_bank"
        controller_path = f"mram_bank[{bank_idx}].bank_wrapper_u.bank_u"
        if CONTROLLER_BYPASS:
            return (bypass_path, controller_path)
        return (controller_path, bypass_path)

    def _get_bank_array_entry(self, bank_idx):
        try:
            return self.dut.mram_bank[bank_idx]
        except Exception:
            return None

    def _is_et_instance_handle(self, handle):
        return (
            handle is not None
            and hasattr(handle, "memory_q")
        )

    def get_bank_model(self, bank_idx):
        """Get a reference to the behavioral bank model for a bank."""
        bank_scope = self._get_bank_array_entry(bank_idx)
        if bank_scope is not None:
            if CONTROLLER_BYPASS:
                for child_name in (
                    f"mram_bank[{bank_idx}].u_bank",
                    "u_bank",
                ):
                    resolved = self._resolve_child_handle(bank_scope, child_name)
                    if resolved is not None:
                        return resolved
            else:
                bank_wrapper = None
                for child_name in (
                    f"mram_bank[{bank_idx}].bank_wrapper_u",
                    "bank_wrapper_u",
                ):
                    bank_wrapper = self._resolve_child_handle(bank_scope, child_name)
                    if bank_wrapper is not None:
                        break

                if bank_wrapper is not None:
                    resolved = self._resolve_child_handle(bank_wrapper, "bank_u")
                    if resolved is not None:
                        return resolved

        for path in self._bank_model_paths(bank_idx):
            resolved = self._resolve_dut_path(path)
            if resolved is not None:
                return resolved

        raise AttributeError(
            f"Could not resolve bank model for mram_bank[{bank_idx}] "
            f"(CONTROLLER_BYPASS={int(CONTROLLER_BYPASS)})"
        )

    def get_mram_instance(self, bank_idx, instance_idx):
        """Get a reference to an erbium_et_instance."""
        candidate_paths = []
        for bank_model_path in self._bank_model_paths(bank_idx):
            candidate_paths.extend((
                f"{bank_model_path}.mram_inst[{instance_idx}].mram_inst",
                f"{bank_model_path}.mram_inst[{instance_idx}]",
            ))

        for instance_path in candidate_paths:
            din_i = self._resolve_dut_path(f"{instance_path}.din_i")
            if din_i is not None:
                return SimpleNamespace(
                    din_i=din_i,
                    _path=instance_path,
                )

        raise AttributeError(
            f"Could not resolve erbium_et_instance for mram_bank[{bank_idx}] "
            f"instance {instance_idx} (CONTROLLER_BYPASS={int(CONTROLLER_BYPASS)})"
        )

    def get_bank_wrapper(self, bank_idx):
        """Get a reference to an erbium_et_bank_wrapper instance."""
        resolved = self._resolve_dut_path(f"mram_bank[{bank_idx}].bank_wrapper_u")
        if resolved is None:
            raise AttributeError(
                f"Could not resolve bank wrapper for mram_bank[{bank_idx}]"
            )
        return resolved

    def get_controller_top(self, bank_idx):
        """Get a reference to the et_ctrl_top instance for a bank."""
        bank_wrapper = self.get_bank_wrapper(bank_idx)

        candidates = []
        ctrl_wrapper = self._resolve_child_handle(bank_wrapper, "et_ctrl_wrapper_u")
        if ctrl_wrapper is not None:
            candidates.extend((
                self._resolve_child_handle(ctrl_wrapper, "et_ctrl_top_u"),
                self._resolve_child_handle(ctrl_wrapper, "et_ctrl_top_u[0]"),
            ))

        candidates.extend((
            self._resolve_child_handle(bank_wrapper, "et_ctrl_wrapper_u.et_ctrl_top_u"),
            self._resolve_child_handle(bank_wrapper, "et_ctrl_wrapper_u.et_ctrl_top_u[0]"),
            self._resolve_dut_path(
                f"mram_bank[{bank_idx}].bank_wrapper_u.et_ctrl_wrapper_u.et_ctrl_top_u"
            ),
            self._resolve_dut_path(
                f"mram_bank[{bank_idx}].bank_wrapper_u.et_ctrl_wrapper_u.et_ctrl_top_u[0]"
            ),
        ))

        for candidate in candidates:
            if candidate is None:
                continue
            if hasattr(candidate, "treg_rca_ovr"):
                return candidate
            try:
                child0 = candidate[0]
            except Exception:
                child0 = None
            if child0 is not None and hasattr(child0, "treg_rca_ovr"):
                return child0

        raise AttributeError(
            f"Could not resolve et_ctrl_top leaf instance for mram_bank[{bank_idx}]"
        )

    def debug_hierarchy(self, dut):
        """Print available hierarchy for debugging."""
        print("=== DUT children ===")
        for child in dut:
            print(f"  {child._name}")

    def _instance_storage_width(self, instance):
        try:
            return len(instance.din_i)
        except Exception:
            return 64 if CONTROLLER_BYPASS else 79

    def _instance_addr_geometry(self):
        return (
            MRAM_ADDR_WIDTH,
            MRAM_COL_ADDR_WIDTH,
            MRAM_PLANE_ADDR_WIDTH,
            MRAM_RESERVE_ADDR_WIDTH,
        )

    def decode_mram_word_addr(self, addr):
        """Decode a 17-bit MRAM word address into (plane_idx, plane_addr)."""
        addr_w, col_w, plane_w, reserve_w = self._instance_addr_geometry()
        row_w = addr_w - reserve_w - plane_w - col_w
        pshift = row_w + col_w
        pmask = (1 << plane_w) - 1
        nmask = (1 << pshift) - 1
        rr_shift = plane_w + row_w + col_w
        rr_mask = (1 << reserve_w) - 1

        plane_idx = (addr >> pshift) & pmask
        rr_sel = (addr >> rr_shift) & rr_mask
        plane_addr = (rr_sel << pshift) | (addr & nmask)
        return plane_idx, plane_addr

    def encode_mram_word_addr(self, plane_idx, plane_addr):
        """Encode (plane_idx, plane_addr) into a 17-bit MRAM word address."""
        addr_w, col_w, plane_w, reserve_w = self._instance_addr_geometry()
        row_w = addr_w - reserve_w - plane_w - col_w
        pshift = row_w + col_w
        nmask = (1 << pshift) - 1
        rr_shift = plane_w + row_w + col_w

        rr_sel = plane_addr >> pshift
        return (rr_sel << rr_shift) | (plane_idx << pshift) | (plane_addr & nmask)

    def _memory_word_handle(self, instance, plane_idx, plane_addr):
        if not hasattr(instance, "_path"):
            raise AttributeError("MRAM instance adapter is missing _path")

        instance_handle = self._resolve_dut_path(instance._path)
        if instance_handle is not None:
            # Preferred: walk memory_q as an unpacked array handle and index it.
            # This is more robust than resolving "memory_q[a][b]" as one string.
            mem_q = self._resolve_child_handle(instance_handle, "memory_q")
            if mem_q is not None:
                try:
                    plane_h = mem_q[plane_idx]
                    word_h = plane_h[plane_addr]
                    return word_h
                except Exception:
                    pass

            # Some simulators expose one unpacked dimension in the name.
            plane_h = self._resolve_child_handle(instance_handle, f"memory_q[{plane_idx}]")
            if plane_h is not None:
                try:
                    return plane_h[plane_addr]
                except Exception:
                    pass

            # Fallbacks for simulators that only accept fully-qualified names.
            for child_name in (
                f"memory_q[{plane_idx}][{plane_addr}]",
                f"memory_q[{plane_idx}].[{plane_addr}]",
            ):
                resolved = self._resolve_child_handle(instance_handle, child_name)
                if resolved is not None:
                    return resolved

        # Last resort: full hierarchical path lookup.
        resolved = self._resolve_dut_path(instance._path + f".memory_q[{plane_idx}][{plane_addr}]")
        if resolved is not None:
            return resolved

        raise IndexError(
            f"{instance._path}.memory_q[{plane_idx}][{plane_addr}] could not be resolved"
        )

    def _encode_instance_payload_word(self, instance, payload_word):
        storage_width = self._instance_storage_width(instance)
        payload_word &= (1 << 64) - 1
        if storage_width == 64:
            return payload_word
        if storage_width == 79:
            return et_bch_encode_64_to_79(payload_word)
        raise ValueError(f"Unsupported instance storage width: {storage_width}")

    def _decode_instance_payload_word(self, instance, stored_word):
        storage_width = self._instance_storage_width(instance)
        if storage_width == 64:
            return stored_word & ((1 << 64) - 1)
        if storage_width == 79:
            return et_bch_decode_79_to_64(stored_word).corrected_data_64
        raise ValueError(f"Unsupported instance storage width: {storage_width}")

    def _read_instance_payload_word(self, instance, plane_idx, plane_addr, default=None):
        try:
            stored_word = int(self._memory_word_handle(instance, plane_idx, plane_addr).value)
        except ValueError:
            if default is None:
                raise
            return default & ((1 << 64) - 1)
        return self._decode_instance_payload_word(instance, stored_word)

    def _write_instance_payload_word(self, instance, plane_idx, plane_addr, payload_word):
        self._memory_word_handle(instance, plane_idx, plane_addr).value = self._encode_instance_payload_word(
            instance,
            payload_word,
        )

    def set_memory_value(self, instance, addr, value):
        """Set a single memory location in an erbium_et_instance."""
        instance.memory_q[addr].value = value

    def set_memory_range(self, instance, start_addr, values):
        """Set a range of memory values starting at start_addr.

        Args:
            instance: The erbium_et_instance handle
            start_addr: Starting address
            values: List of integer values to write
        """
        for i, val in enumerate(values):
            instance.memory_q[start_addr + i].value = val

    def initialize_all_memory(self, value=0):
        """Initialize all memory in all instances to a value.

        Args:
            value: Value to initialize (0 for zeros, or use random)
        """
        self.warn_direct_mram_access(
            "write",
            f"initialize_all_memory value=0x{int(value):x}",
            tag="initialize_all_memory",
        )
        n_banks = int(4)
        for bank in range(n_banks):
            for instance in range(8):  # 8 instances per bank
                instance = self.get_mram_instance(bank, instance)
                for plane in range(MRAM_NUM_PLANES):
                    for word in range(MRAM_WORDS_PER_PLANE):
                        self._write_instance_payload_word(instance, plane, word, value)

    def randomize_all_memory(self, seed=None):
        """Fill all memory with random values using 8 parallel threads.

        Args:
            seed: Optional random seed for reproducibility
        """
        self.warn_direct_mram_access(
            "write",
            f"randomize_all_memory seed={seed}",
            tag="randomize_all_memory",
        )
        n_banks = 4
        n_instances = 8
        master_seed = seed if seed is not None else random.randint(0, 2**32-1)

        # Get memory dimensions from first instance
        num_planes = MRAM_NUM_PLANES
        words_per_plane = MRAM_WORDS_PER_PLANE

        def randomize_instance_across_banks(inst_idx):
            """One thread per instance - handles that instance across all banks."""
            rng = random.Random(master_seed + inst_idx)
            for bank in range(n_banks):
                instance = self.get_mram_instance(bank, inst_idx)
                self.dut._log.info(f"Thread {inst_idx}: Randomizing bank {bank}, instance {inst_idx}")
                for plane in range(num_planes):
                    for word in range(words_per_plane):
                        self._write_instance_payload_word(instance, plane, word, rng.getrandbits(64))

        # 8 threads, one per instance
        self.dut._log.info(f"Randomizing memory with {n_instances} threads...")
        with ThreadPoolExecutor(max_workers=n_instances) as executor:
            list(executor.map(randomize_instance_across_banks, range(n_instances)))

    def fill_memory_with_debug_pattern(self):
        """Fill memory with a debug pattern encoding bank and instance info.

        Each 64-bit word is filled with a pattern where:
        - Even bytes: 0xBI where B=bank, I=instance (e.g., 0x25 = bank 2, instance 5)
        - Odd bytes: inverted (0xFF ^ 0xBI)

        This makes it easy to identify which bank/instance data came from.
        """
        self.warn_direct_mram_access(
            "write",
            "fill_memory_with_debug_pattern across all banks and instances",
            tag="fill_memory_with_debug_pattern",
        )
        n_banks = 4
        n_instances = 8
        for bank in range(n_banks):
            for inst in range(n_instances):
                instance = self.get_mram_instance(bank, inst)
                # Pattern byte: high nibble = bank, low nibble = instance
                pattern_byte = (bank << 4) | inst
                inverted_byte = 0xFF ^ pattern_byte

                # Build 64-bit word: alternating pattern and inverted
                # Bytes 0,2,4,6 = pattern, bytes 1,3,5,7 = inverted
                word = 0
                for byte_idx in range(8):
                    if byte_idx % 2 == 0:
                        word |= pattern_byte << (byte_idx * 8)
                    else:
                        word |= inverted_byte << (byte_idx * 8)

                self.dut._log.info(f"Filling bank {bank}, instance {inst} with pattern 0x{word:016x}")
                for plane in range(MRAM_NUM_PLANES):
                    for w_idx in range(MRAM_WORDS_PER_PLANE):
                        self._write_instance_payload_word(instance, plane, w_idx, word)

    def translate_axi_addr(self, axi_byte_addr):
        """Translate an AXI byte address into the MRAM-visible byte address."""
        if OTP_BASE_ADDR <= axi_byte_addr < (OTP_BASE_ADDR + OTP_SIZE_BYTES):
            otp_offset = axi_byte_addr - OTP_BASE_ADDR
            otp_page = otp_offset >> 8
            block_plane = otp_page // len(OTP_VALID_COLS)
            block = block_plane >> 1
            plane = block_plane & 0x1
            col = OTP_VALID_COLS[otp_page % len(OTP_VALID_COLS)]
            mram_addr = (
                (1 << 16)
                | (block << 14)
                | (plane << 13)
                | (OTP_FIXED_ROW << 4)
                | col
            )
            return (mram_addr << 8) | (axi_byte_addr & 0xFF)

        return axi_byte_addr

    def axi_addr_to_mram_location(self, axi_byte_addr):
        """Decode an AXI byte address to bank, instance, and memory offset.

        The memory is organized as:
        - 4 banks, each with 8 instances (64-bit wide each)
        - Banks are interleaved every 16 bytes (translated_axi_addr[5:4] selects bank)
        - mram_addr = translated_axi_addr[24:8] (17-bit MRAM word address)
        - mram_addr[2:1] selects instance pair: 0→(0,1), 1→(2,3), 2→(4,5), 3→(6,7)
        - Instance pairs provide lower/upper 64 bits of 128-bit bank word

        Returns:
            tuple: (bank_idx, instance_pair, mem_addr, byte_offset_in_word)
        """
        translated_addr = self.translate_axi_addr(axi_byte_addr)

        # Bank selection: bits [5:4] of the translated byte address (16-byte interleave)
        bank_idx = (translated_addr >> 4) & 0x3

        # mram_addr = translated_axi_addr[24:8] (17-bit word address, 16-byte aligned)
        # Instance pair selection: translated_axi_addr[7:6] determines which instance pair
        mem_addr = (translated_addr >> 8) & 0x1FFFF
        instance_pair = (translated_addr >> 6) & 0x3

        # Memory address within instance: full mram_addr (lower 13 bits)
        # Each instance sees the same address, CE selects which one responds

        # Byte offset within the 16-byte bank word
        byte_offset = translated_addr & 0xF

        return bank_idx, instance_pair, mem_addr, byte_offset

    def initialize_memory_region(self, axi_byte_addr, length, value=0):
        """Initialize a byte region in the behavioral MRAM hierarchy."""
        self.warn_direct_mram_access(
            "write",
            f"initialize_memory_region addr=0x{axi_byte_addr:x} length={length} value=0x{int(value) & 0xff:02x}",
            tag="initialize_memory_region",
        )
        fill_byte = int(value) & 0xFF
        fill_word = int.from_bytes(bytes([fill_byte]) * 8, "little")

        touched_words = {}

        for offset in range(length):
            addr = axi_byte_addr + offset
            bank_idx, instance_pair, mem_addr, byte_offset = self.axi_addr_to_mram_location(addr)

            if byte_offset < 8:
                instance_idx = instance_pair * 2
                word_byte_offset = byte_offset
            else:
                instance_idx = instance_pair * 2 + 1
                word_byte_offset = byte_offset - 8

            plane_idx, plane_addr = self.decode_mram_word_addr(mem_addr)
            word_key = (bank_idx, instance_idx, plane_idx, plane_addr)

            if word_key not in touched_words:
                touched_words[word_key] = fill_word

            shift = word_byte_offset * 8
            word_mask = 0xFF << shift
            touched_words[word_key] = (touched_words[word_key] & ~word_mask) | (fill_byte << shift)

        for (bank_idx, instance_idx, plane_idx, plane_addr), word_value in touched_words.items():
            instance = self.get_mram_instance(bank_idx, instance_idx)
            self._write_instance_payload_word(instance, plane_idx, plane_addr, word_value)

    def write_memory_bytes(self, axi_byte_addr, data):
        """Write byte data directly into the behavioral MRAM hierarchy."""
        self.warn_direct_mram_access(
            "write",
            f"write_memory_bytes addr=0x{axi_byte_addr:x} length={len(data)}",
            tag="write_memory_bytes",
        )
        touched_words = {}

        for offset, byte_value in enumerate(data):
            addr = axi_byte_addr + offset
            bank_idx, instance_pair, mem_addr, byte_offset = self.axi_addr_to_mram_location(addr)

            if byte_offset < 8:
                instance_idx = instance_pair * 2
                word_byte_offset = byte_offset
            else:
                instance_idx = instance_pair * 2 + 1
                word_byte_offset = byte_offset - 8

            plane_idx, plane_addr = self.decode_mram_word_addr(mem_addr)
            word_key = (bank_idx, instance_idx, plane_idx, plane_addr)

            if word_key not in touched_words:
                instance = self.get_mram_instance(bank_idx, instance_idx)
                try:
                    touched_words[word_key] = self._read_instance_payload_word(
                        instance,
                        plane_idx,
                        plane_addr,
                    )
                except ValueError:
                    touched_words[word_key] = 0

            word_value = touched_words[word_key]
            shift = word_byte_offset * 8
            word_mask = 0xFF << shift
            touched_words[word_key] = (word_value & ~word_mask) | (int(byte_value) << shift)

        for (bank_idx, instance_idx, plane_idx, plane_addr), word_value in touched_words.items():
            instance = self.get_mram_instance(bank_idx, instance_idx)
            self._write_instance_payload_word(instance, plane_idx, plane_addr, word_value)

    def get_expected_bytes(self, axi_byte_addr, length):
        """Get expected data bytes from MRAM instances for a given AXI address range.

        Args:
            axi_byte_addr: Starting AXI byte address
            length: Number of bytes to read

        Returns:
            bytes: Expected data
        """
        self.warn_direct_mram_access(
            "read",
            f"get_expected_bytes addr=0x{axi_byte_addr:x} length={length}",
            tag="get_expected_bytes",
        )

        result = bytearray()

        for offset in range(length):
            addr = axi_byte_addr + offset
            bank_idx, instance_pair, mem_addr, byte_offset = self.axi_addr_to_mram_location(addr)

            # Instance pairs are sequential: (0,1), (2,3), (4,5), (6,7)
            # Bytes 0-7 come from even instance (instance_pair * 2)
            # Bytes 8-15 come from odd instance (instance_pair * 2 + 1)
            if byte_offset < 8:
                instance_idx = instance_pair * 2      # 0, 2, 4, or 6
                word_byte_offset = byte_offset
            else:
                instance_idx = instance_pair * 2 + 1  # 1, 3, 5, or 7
                word_byte_offset = byte_offset - 8

            # Read the 64-bit word from the instance — memory_q is now 2D
            instance = self.get_mram_instance(bank_idx, instance_idx)
            plane_idx, plane_addr = self.decode_mram_word_addr(mem_addr)
            word_value = self._read_instance_payload_word(instance, plane_idx, plane_addr)

            # Extract the specific byte (little-endian)
            byte_value = (word_value >> (word_byte_offset * 8)) & 0xFF
            result.append(byte_value)

        return bytes(result)

    def verify_mram_contents(self, axi_byte_addr, expected_data):
        """Verify that expected_data was written to the correct MRAM locations.

        Reads each byte directly from the MRAM instance memory and compares
        against what should have been written.

        Args:
            axi_byte_addr: Starting AXI byte address of the write
            expected_data: bytes/bytearray that was written

        Returns:
            list: List of mismatch dicts, empty if all match
        """
        self.warn_direct_mram_access(
            "read",
            f"verify_mram_contents addr=0x{axi_byte_addr:x} length={len(expected_data)}",
            tag="verify_mram_contents",
        )

        mismatches = []
        for offset in range(len(expected_data)):
            addr = axi_byte_addr + offset
            bank_idx, instance_pair, mem_addr, byte_offset = self.axi_addr_to_mram_location(addr)

            if byte_offset < 8:
                instance_idx = instance_pair * 2
                word_byte_offset = byte_offset
            else:
                instance_idx = instance_pair * 2 + 1
                word_byte_offset = byte_offset - 8

            instance = self.get_mram_instance(bank_idx, instance_idx)
            plane_idx, plane_addr = self.decode_mram_word_addr(mem_addr)
            word_value = self._read_instance_payload_word(instance, plane_idx, plane_addr)
            actual_byte = (word_value >> (word_byte_offset * 8)) & 0xFF
            expected_byte = expected_data[offset]

            if actual_byte != expected_byte:
                mismatches.append({
                    'offset': offset,
                    'axi_addr': addr,
                    'bank': bank_idx,
                    'instance': instance_idx,
                    'mem_addr': mem_addr,
                    'byte_offset': word_byte_offset,
                    'expected': expected_byte,
                    'actual': actual_byte,
                })
        return mismatches


my_tb = TB()


    # await write_op.wait()












# --------------------------------------------------------------------------
# Cross-size RAW hazard regression
#
# Reproduces the failure pattern observed in foo.out:
#   A SIZE_64B write to 0x0 commits (BRESP received), then a SIZE_1B read
#   at byte offset 0x2B within that same 64-byte line returns stale zeros
#   instead of the just-written value.
#
# The existing read_after_write_hazard test covers same-size pairs
# (SIZE_64B write → SIZE_64B read).  This test specifically exercises
# cross-size pairs where the write granularity is larger than the read,
# hitting sub-byte-lane routing through the bank pipeline.
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# Arbiter Mode Verification
# --------------------------------------------------------------------------
ARBITER_WRITE_PRIORITY = 0
ARBITER_READ_PRIORITY  = 1
ARBITER_ROUND_ROBIN    = 2
ARBITER_OLDEST_FIRST   = 3
ARBITER_MODE_REG_ADDR  = 0x00  # AXI-lite offset for arbiter_mode_reg


async def set_arbiter_mode(treg_master, mode):
    """Write the arbiter mode register via AXI-Lite."""
    await treg_master.write(ARBITER_MODE_REG_ADDR, mode.to_bytes(8, 'little'))


def controller_reg_model_ready(dut):
    if CONTROLLER_BYPASS:
        dut._log.info("Skipping generated register-model test because CONTROLLER_BYPASS=1")
        return False
    if axi2mram_bridge_registers_cls is None or AsyncCallbackSet is None:
        raise RuntimeError(f"Generated regblock Python package unavailable: {REGBLOCK_IMPORT_ERROR}")
    return True


























# --------------------------------------------------------------------------
# SLVERR Status Register Verification
# --------------------------------------------------------------------------
SLVERR_STATUS_REG_ADDR = 0x10   # bridge_regs.slverr_status_reg @ AXI-Lite offset 0x10
#   bit 0 = oor_read  (set when ARADDR is out of range)
#   bit 1 = oor_write (set when AWADDR is out of range)
#   both bits are sticky and clear-on-read

# Export shared testbench symbols to split test modules.
# This intentionally includes underscore-prefixed globals (e.g. `_rng`) so
# `from tb import *` works for legacy test code without per-file edits.
__all__ = [name for name in globals() if not name.startswith("__")]









# Split-test registration:
# Import all modules in tests/ and re-export cocotb test objects into tb module
# scope so MODULE=tb discovery finds them.
import importlib
import pkgutil
from cocotb._decorators import Test

_tests_pkg = importlib.import_module("tests")
for _mod_info in pkgutil.iter_modules(_tests_pkg.__path__):
    if _mod_info.name.startswith("_"):
        continue
    _mod = importlib.import_module(f"tests.{_mod_info.name}")
    for _name, _obj in vars(_mod).items():
        if isinstance(_obj, Test):
            globals()[_name] = _obj

for _sym in ("_tests_pkg", "_mod_info", "_mod", "_name", "_obj"):
    if _sym in globals():
        del globals()[_sym]
del _sym
