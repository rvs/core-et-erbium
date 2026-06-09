import importlib
import os
import sys
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiResp


_TB_DIR = Path(__file__).resolve().parent
_REGBLOCK_PY_DIR = _TB_DIR.parents[1] / "regblocks" / "python"
if str(_REGBLOCK_PY_DIR) not in sys.path:
    sys.path.insert(0, str(_REGBLOCK_PY_DIR))


def _discover_reg_model_pkg_name():
    override = os.environ.get("TREGS_REGMODEL_PKG")
    if override:
        return override

    candidates = []
    if _REGBLOCK_PY_DIR.exists():
        for entry in sorted(_REGBLOCK_PY_DIR.iterdir()):
            if not entry.is_dir():
                continue
            if (entry / "reg_model" / "__init__.py").exists() and (entry / "lib" / "__init__.py").exists():
                candidates.append(entry.name)

    if not candidates:
        raise ModuleNotFoundError(
            f"No generated PeakRDL python package found under {_REGBLOCK_PY_DIR}. "
            "Run `make -C mram_controller/regblocks python` first."
        )

    if len(candidates) == 1:
        return candidates[0]

    for preferred in ("mram_tregs", "mram_test_registers", "erbium_test_registers"):
        if preferred in candidates:
            return preferred

    return candidates[0]


class _AxiLiteRegCallbacks:
    def __init__(self, axil_master):
        self._axil_master = axil_master

    @staticmethod
    def _word_nbytes(accesswidth):
        if accesswidth <= 0 or (accesswidth % 8) != 0:
            raise ValueError(f"Unsupported accesswidth {accesswidth}")
        return accesswidth // 8

    @staticmethod
    def _mask(width):
        if width <= 0:
            return 0
        return (1 << width) - 1

    async def read_callback(self, addr, width, accesswidth):
        nbytes = self._word_nbytes(accesswidth)
        resp = await self._axil_master.read(addr, nbytes)
        if resp.resp != AxiResp.OKAY:
            raise RuntimeError(f"AXI-Lite read failed at 0x{addr:x} (resp={resp.resp})")
        value = int.from_bytes(bytes(resp.data), "little")
        return value & self._mask(width)

    async def write_callback(self, addr, width, accesswidth, data):
        nbytes = self._word_nbytes(accesswidth)
        masked = int(data) & self._mask(width)
        payload = masked.to_bytes(nbytes, "little", signed=False)
        resp = await self._axil_master.write(addr, payload)
        if resp.resp != AxiResp.OKAY:
            raise RuntimeError(f"AXI-Lite write failed at 0x{addr:x} (resp={resp.resp})")

    async def read_block_callback(self, addr, width, accesswidth, length):
        nbytes = self._word_nbytes(accesswidth)
        if length <= 0:
            return []
        resp = await self._axil_master.read(addr, nbytes * length)
        if resp.resp != AxiResp.OKAY:
            raise RuntimeError(f"AXI-Lite block read failed at 0x{addr:x} (resp={resp.resp})")

        data = bytes(resp.data)
        word_mask = self._mask(width)
        words = []
        for idx in range(length):
            chunk = data[idx * nbytes:(idx + 1) * nbytes]
            words.append(int.from_bytes(chunk, "little") & word_mask)
        return words

    async def write_block_callback(self, addr, width, accesswidth, data):
        nbytes = self._word_nbytes(accesswidth)
        word_mask = self._mask(width)
        payload = bytearray()
        for word in data:
            payload.extend((int(word) & word_mask).to_bytes(nbytes, "little", signed=False))
        resp = await self._axil_master.write(addr, bytes(payload))
        if resp.resp != AxiResp.OKAY:
            raise RuntimeError(f"AXI-Lite block write failed at 0x{addr:x} (resp={resp.resp})")


class WrapperTB:
    def __init__(self, top):
        self.top = top
        self.dut = top.dut
        cocotb.start_soon(Clock(self.top.clk, 2, units="ns").start())
        self.tregs_axil_master = AxiLiteMaster(
            AxiLiteBus.from_prefix(self.top, "tregs_s_axil"),
            self.top.clk,
            self.top.rst_b,
            reset_active_level=False,
        )
        self.tregs_regs = None
        self._tregs_reg_model_error = None
        self._create_tregs_reg_model()

    def _create_tregs_reg_model(self):
        try:
            pkg_name = _discover_reg_model_pkg_name()
            reg_model_mod = importlib.import_module(f"{pkg_name}.reg_model")
            lib_mod = importlib.import_module(f"{pkg_name}.lib")
            reg_model_cls = getattr(reg_model_mod, "RegModel")
            async_cb_cls = getattr(lib_mod, "AsyncCallbackSet")
            callbacks = _AxiLiteRegCallbacks(self.tregs_axil_master)
            self.tregs_regs = reg_model_cls(
                callbacks=async_cb_cls(
                    read_callback=callbacks.read_callback,
                    write_callback=callbacks.write_callback,
                    read_block_callback=callbacks.read_block_callback,
                    write_block_callback=callbacks.write_block_callback,
                )
            )
        except Exception as exc:  # Keep base tests runnable if model package is absent.
            self._tregs_reg_model_error = exc
            self.tregs_regs = None

    def get_tregs_reg_model(self):
        if self.tregs_regs is None:
            raise RuntimeError(
                "Unable to initialize generated PeakRDL register model. "
                "Run `make -C mram_controller/regblocks python` and ensure the model "
                "is generated in mram_controller/regblocks/python."
            ) from self._tregs_reg_model_error
        return self.tregs_regs

    @property
    def regs(self):
        return self.get_tregs_reg_model()

    def _init_inputs(self):
        self.top.axi_add.value = 0
        self.top.axi_bwe.value = 0
        self.top.axi_din.value = 0
        self.top.axi_ce.value = 0x1
        self.top.axi_dout_en.value = 0
        self.top.axi_we.value = 0

        self.top.dsleep.value = 0
        self.top.nvsram_startup_bypass.value = 1

        self.top.vdd.value = 1
        self.top.vdd18.value = 1
        self.top.vss.value = 0
        self.top.rst_b.value = 0

    async def reset(self, cycles=8):
        self._init_inputs()
        for _ in range(cycles):
            await RisingEdge(self.top.clk)
        self.top.rst_b.value = 1
        for _ in range(cycles):
            await RisingEdge(self.top.clk)

    async def issue_axi_write(self, addr, data, stripe=0x1, byte_en=0xFFFF_FFFF_FFFF_FFFF):
        self.top.axi_add.value = addr
        self.top.axi_din.value = data
        self.top.axi_bwe.value = byte_en
        self.top.axi_stripe_sel.value = stripe
        self.top.axi_we.value = 1
        await RisingEdge(self.top.clk)
        self.top.axi_we.value = 0

    async def issue_axi_read(self, addr, stripe=0x1):
        self.top.axi_add.value = addr
        self.top.axi_stripe_sel.value = stripe
        self.top.axi_we.value = 0
        await RisingEdge(self.top.clk)
        await self.wait_axi_idle()
        return int(self.top.axi_dout.value)

    async def wait_axi_idle(self, timeout_cycles=400):
        for _ in range(timeout_cycles):
            await RisingEdge(self.top.clk)
            busy = self.top.axi_busy.value
            if busy.is_resolvable and int(busy) == 0:
                return
        raise AssertionError("Timed out waiting for axi_busy to deassert")


# Import test modules — cocotb discovers @cocotb.test() from these.
# Adding a new .py file under tests/ automatically includes it in the regression.
from tests import *  # noqa: E402, F401, F403
