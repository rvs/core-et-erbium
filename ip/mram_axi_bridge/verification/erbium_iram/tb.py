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

import importlib
import logging
import os
import pkgutil
import random
from types import SimpleNamespace

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge, Timer, with_timeout
from cocotbext.axi import AxiBus, AxiMaster

try:
    from cocotb._decorators import Test as CocotbTest
except ImportError:
    from cocotb.decorators import test as CocotbTest


TEST_SEED = 42
_rng = random.Random(0)


def seed_rng(extra=0):
    base = int(os.environ.get("COCOTB_TEST_SEED", str(TEST_SEED)))
    _rng.seed(base + extra)


def rand_bytes(count):
    return bytearray(_rng.getrandbits(8) for _ in range(count))


def sig_int(signal):
    return int(signal.value)


class HierarchyPathProxy:
    def __init__(self, tb, path, label):
        self._tb = tb
        self._path = path
        self._label = label

    def __getattr__(self, name):
        handle = self._tb._resolve_required_path(f"{self._path}.{name}", f"{self._label}.{name}")
        return handle


class ApbMaster:
    def __init__(self, clock, signals):
        self.clock = clock
        self.signals = signals
        self.idle()

    def idle(self):
        self.signals.psel.value = 0
        self.signals.penable.value = 0
        self.signals.pwrite.value = 0
        self.signals.paddr.value = 0
        self.signals.pwdata.value = 0
        self.signals.pstrb.value = 0

    async def write32(self, address, data, strb=0xF):
        await FallingEdge(self.clock)
        self.signals.paddr.value = address & 0x1F
        self.signals.pwdata.value = data & 0xFFFF_FFFF
        self.signals.pstrb.value = strb & 0xF
        self.signals.pwrite.value = 1
        self.signals.psel.value = 1
        self.signals.penable.value = 0

        await FallingEdge(self.clock)
        self.signals.penable.value = 1

        while True:
            await ReadOnly()
            if sig_int(self.signals.pready):
                break
            await FallingEdge(self.clock)

        await FallingEdge(self.clock)
        self.idle()

    async def read32(self, address):
        await FallingEdge(self.clock)
        self.signals.paddr.value = address & 0x1F
        self.signals.pstrb.value = 0xF
        self.signals.pwrite.value = 0
        self.signals.psel.value = 1
        self.signals.penable.value = 0

        await FallingEdge(self.clock)
        self.signals.penable.value = 1

        while True:
            await ReadOnly()
            if sig_int(self.signals.pready):
                value = sig_int(self.signals.prdata)
                break
            await FallingEdge(self.clock)

        await FallingEdge(self.clock)
        self.idle()
        return value

    async def write64(self, reg_index, value):
        await self.write32((reg_index << 1) | 0, value & 0xFFFF_FFFF)
        await self.write32((reg_index << 1) | 1, (value >> 32) & 0xFFFF_FFFF)

    async def read64(self, reg_index):
        low = await self.read32((reg_index << 1) | 0)
        high = await self.read32((reg_index << 1) | 1)
        return low | (high << 32)


class TB:
    def __init__(self):
        self._matrix_step = 0

    def set_dut(self, dut):
        self.tb_top = dut
        self.dut = dut.dut

    def initialize_signals(self):
        self.tb_top.clk.value = 0
        self.tb_top.rst_b.value = 0
        self.tb_top.mram_rst_b.value = 0
        self.tb_top.dsleep.value = 0
        self.tb_top.nvsram_startup_bypass.value = 0

        for bank in range(self._visible_bank_ports()):
            getattr(self.tb_top, f"bank{bank}_paddr").value = 0
            getattr(self.tb_top, f"bank{bank}_penable").value = 0
            getattr(self.tb_top, f"bank{bank}_psel").value = 0
            getattr(self.tb_top, f"bank{bank}_pstrb").value = 0
            getattr(self.tb_top, f"bank{bank}_pwdata").value = 0
            getattr(self.tb_top, f"bank{bank}_pwrite").value = 0
            getattr(self.tb_top, f"bank{bank}_tp_add").value = 0
            getattr(self.tb_top, f"bank{bank}_tp_bwe").value = 0
            getattr(self.tb_top, f"bank{bank}_tp_ce").value = 0
            getattr(self.tb_top, f"bank{bank}_tp_din").value = 0
            getattr(self.tb_top, f"bank{bank}_tp_we").value = 0

    def initialize_clock(self):
        cocotb.start_soon(Clock(self.tb_top.clk, 4, unit="ns").start())

    def create_axi_master(self):
        self.axi_master = AxiMaster(
            AxiBus.from_prefix(self.tb_top, "s_axi"),
            self.tb_top.clk,
            self.tb_top.rst_b,
            reset_active_level=False,
        )
        self.axi_master.write_if.log.setLevel(logging.WARNING)
        self.axi_master.read_if.log.setLevel(logging.WARNING)

    def create_apb_masters(self):
        self.apb_masters = []
        for bank in range(self._visible_bank_ports()):
            self.apb_masters.append(
                ApbMaster(
                    self.tb_top.clk,
                    SimpleNamespace(
                        paddr=getattr(self.tb_top, f"bank{bank}_paddr"),
                        penable=getattr(self.tb_top, f"bank{bank}_penable"),
                        psel=getattr(self.tb_top, f"bank{bank}_psel"),
                        pstrb=getattr(self.tb_top, f"bank{bank}_pstrb"),
                        pwdata=getattr(self.tb_top, f"bank{bank}_pwdata"),
                        pwrite=getattr(self.tb_top, f"bank{bank}_pwrite"),
                        prdata=getattr(self.tb_top, f"bank{bank}_prdata"),
                        pready=getattr(self.tb_top, f"bank{bank}_pready"),
                    ),
                )
            )

    def setup_tb(self):
        self.initialize_signals()
        self.initialize_clock()
        self.create_axi_master()
        self.create_apb_masters()

    async def wait_clocks(self, cycles):
        for _ in range(cycles):
            await RisingEdge(self.tb_top.clk)

    async def wait_for_axi_idle(self, timeout_ns=2000):
        async def _wait():
            while sig_int(self.tb_top.axi_busy):
                await RisingEdge(self.tb_top.clk)

        await with_timeout(_wait(), timeout_ns, "ns")

    async def reset_sequence(self, bypass_startup=False):
        self.tb_top.nvsram_startup_bypass.value = 1 if bypass_startup else 0
        self.tb_top.rst_b.value = 1
        self.tb_top.mram_rst_b.value = 1
        await Timer(10, unit="ns")
        self.tb_top.rst_b.value = 0
        self.tb_top.mram_rst_b.value = 0
        await Timer(20, unit="ns")
        self.tb_top.rst_b.value = 1
        self.tb_top.mram_rst_b.value = 1
        await self.wait_clocks(10)
        await self.wait_for_axi_idle()

    async def axi_write(self, address, data, *, size=None, timeout_ns=4000):
        kwargs = {}
        if size is not None:
            kwargs["size"] = size
        await with_timeout(self.axi_master.write(address, data, **kwargs), timeout_ns, "ns")

    async def axi_read(self, address, length, *, size=None, timeout_ns=4000):
        kwargs = {}
        if size is not None:
            kwargs["size"] = size
        read_op = self.axi_master.init_read(address, length, **kwargs)
        await with_timeout(read_op.wait(), timeout_ns, "ns")
        if hasattr(read_op, "result"):
            return bytes(read_op.result.data)
        return bytes(read_op.data.data)

    def apb_master(self, bank=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"APB master requested for bank {bank}, but only {self.num_wrappers()} "
                "wrapper(s) are instantiated"
            )
        return self.apb_masters[bank]

    def _visible_bank_ports(self):
        bank = 0
        while hasattr(self.tb_top, f"bank{bank}_paddr"):
            bank += 1
        return bank

    def _unwrap_singleton_hierarchy(self, handle):
        current = handle

        while current.__class__.__name__ == "HierarchyArrayObject":
            try:
                if len(current) != 1:
                    break
                current = current[0]
            except Exception:
                break

        return current

    def _resolve_path_or_none(self, path):
        handle = self._resolve_dut_path(path)
        if handle is None:
            return None
        return self._unwrap_singleton_hierarchy(handle)

    def _resolve_required_path(self, path, label=None):
        handle = self._resolve_path_or_none(path)
        if handle is None:
            if label is None:
                label = path
            raise AttributeError(f"Could not resolve {label} at path {path}")
        return handle

    def num_wrappers(self):
        try:
            addr_width = len(self.tb_top.s_axi_awaddr)
        except Exception:
            return 1

        wrapper_count = 1 << max(addr_width - 23, 0)
        return max(1, min(wrapper_count, self._visible_bank_ports()))

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

    def _resolve_path_token(self, current, token):
        remainder = token

        while remainder:
            bracket_idx = remainder.find("[")
            if bracket_idx == -1:
                return self._resolve_child_handle(current, remainder)

            child_name = remainder[:bracket_idx]
            if child_name:
                current = self._resolve_child_handle(current, child_name)
                if current is None:
                    return None

            close_idx = remainder.find("]", bracket_idx)
            if close_idx == -1:
                return None

            index_text = remainder[bracket_idx + 1:close_idx]
            try:
                index = int(index_text)
            except ValueError:
                return None

            try:
                current = current[index]
            except Exception:
                return None

            remainder = remainder[close_idx + 1:]

        return current

    def _resolve_dut_path(self, path):
        current = self.dut
        tokens = path.split(".")
        token_idx = 0

        while token_idx < len(tokens):
            resolved = None

            for end_idx in range(len(tokens), token_idx, -1):
                candidate = ".".join(tokens[token_idx:end_idx])
                resolved = self._resolve_child_handle(current, candidate)
                if resolved is not None:
                    current = resolved
                    token_idx = end_idx
                    break

            if resolved is not None:
                continue

            current = self._resolve_path_token(current, tokens[token_idx])
            if current is None:
                return None
            token_idx += 1

        return current

    def get_wrapper(self, bank=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"Wrapper {bank} requested, but only {self.num_wrappers()} wrapper(s) exist"
            )
        return HierarchyPathProxy(
            self,
            f"mram_wrappers[{bank}].u_mram_wrapper",
            f"mram_wrapper[{bank}]",
        )

    def get_ctrl_top(self, bank=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"ctrl_top {bank} requested, but only {self.num_wrappers()} wrapper(s) exist"
            )
        return HierarchyPathProxy(
            self,
            f"mram_wrappers[{bank}].u_mram_wrapper.ctrl_wrapper_u.ctrl_top_u",
            f"ctrl_top[{bank}]",
        )

    def get_behavioral_bank(self, bank=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"behavioral bank {bank} requested, but only {self.num_wrappers()} wrapper(s) exist"
            )
        return HierarchyPathProxy(
            self,
            f"mram_wrappers[{bank}].u_mram_wrapper.bank_u",
            f"behavioral_bank[{bank}]",
        )

    def get_bist_core(self, bank=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"bist core {bank} requested, but only {self.num_wrappers()} wrapper(s) exist"
            )
        return HierarchyPathProxy(
            self,
            f"mram_wrappers[{bank}].u_mram_wrapper.ctrl_wrapper_u.ctrl_top_u.bist_wrapper_u.bist_u",
            f"bist_core[{bank}]",
        )

    def get_behavioral_array_elem(self, bank=0, array_name="int_memory", index=0):
        if bank >= self.num_wrappers():
            raise IndexError(
                f"behavioral array bank {bank} requested, but only {self.num_wrappers()} "
                "wrapper(s) exist"
            )
        return self._resolve_required_path(
            f"mram_wrappers[{bank}].u_mram_wrapper.bank_u.{array_name}[{index}]",
            f"behavioral_{array_name}[{bank}][{index}]",
        )

    def get_behavioral_mem_word(self, bank=0, word_index=0):
        return self.get_behavioral_array_elem(bank, "int_memory", word_index)

    def get_behavioral_ref_word(self, bank=0, row_index=0):
        return self.get_behavioral_array_elem(bank, "int_ref_memory", row_index)

    def set_wave_matrix_label(self, label):
        encoded = label.encode("ascii", errors="replace")[:128]
        packed = int.from_bytes(encoded.ljust(128, b"\x00"), byteorder="big")
        self._matrix_step = (self._matrix_step + 1) & 0xFFFF_FFFF
        self.tb_top.tb_matrix_label.value = packed
        self.tb_top.tb_matrix_step.value = self._matrix_step


my_tb = TB()

__all__ = [name for name in globals() if not name.startswith("__")]

_tests_pkg = importlib.import_module("tests")
for _mod_info in pkgutil.iter_modules(_tests_pkg.__path__):
    if _mod_info.name.startswith("_"):
        continue
    _mod = importlib.import_module(f"tests.{_mod_info.name}")
    for _name, _obj in vars(_mod).items():
        if isinstance(_obj, CocotbTest):
            globals()[_name] = _obj

for _sym in ("_tests_pkg", "_mod_info", "_mod", "_name", "_obj"):
    if _sym in globals():
        del globals()[_sym]
del _sym
