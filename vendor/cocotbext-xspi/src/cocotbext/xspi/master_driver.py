"""Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.

Author: Vijayvithal <jvs@nekko.ai>
Created on: 2025-12-09
Description: The low level driver for xspi master.
"""

import cocotb
from cocotb.types import LogicArray
from cocotb.handle import Immediate
from .config import default_config
from cocotb.triggers import RisingEdge, FallingEdge, Edge, Timer, ReadOnly
from typing import Optional, Tuple
from .types import Format, format_table, Mode
from enum import IntEnum
from .hb_commands import HB


class XspiMasterDriver:
    """Low level driver functions for the xSPI master interface (JESD251C)."""

    def __init__(
        self, bus, config=default_config, dut=None, free_running_clk=False, period=5
    ):
        """Initialise the driver and drive all outputs to their idle state."""
        self.check_enables = False
        self.hb = HB(self.txn)
        self.bus = bus
        self.dut = dut
        self.config = config
        bus.clk.value = Immediate(0)
        bus.dq_in.value = Immediate(0)
        bus.rwds_in.value = Immediate(0)
        bus.csn.value = Immediate(1)
        self.cmd_mode = Mode.S1
        self.modifier_mode = Mode.S1
        self.data_mode = Mode.S1
        self.period = period
        self.latency = 16  # TODO populate this from config.
        self.free_running_clk = free_running_clk
        self.last_txn_end_time = None
        self.clk_freq_mhz: float = 200.0
        if free_running_clk:
            self.dut.xspi_clk_en.value = True
        else:
            self.dut.xspi_clk_en.value = False

    def set_mode(self, mode: Tuple[Mode, Mode, Mode] = (Mode.S1, Mode.S1, Mode.S1)):
        """Set the operating protocol mode (cmd, addr/modifier, data)."""
        cocotb.log.info(f"Setting Mode {mode}")
        self.cmd_mode = mode[0]
        self.modifier_mode = mode[1]
        self.data_mode = mode[2]

    def set_latency(self, latency):
        self.latency = latency

    def _setfsm(self, s):
        if hasattr(self.bus, "fsm"):
            self.bus.fsm.value = int.from_bytes(s, "big")

    async def write(self, address: bytes, data: bytes, fmt: Format = Format.K0):
        """Write function for peakrdl python module."""
        if isinstance(address, int):
            address = address.to_bytes(4, "big")
        cmd = 0x02.to_bytes(1, "little")
        await self.txn(cmd, None, address, data, fmt, data_cycles=0)

    async def txn(
        self,
        cmd: bytes,
        extension: bytes = None,
        address: bytes = None,
        data: bytes = None,
        fmt: Format = None,
        data_cycles: int = 0,
        mask=None,
    ):
        """This function does all the heavylifting of translating the command in the cycle accurate transactions of the protocol."""

        if self.last_txn_end_time is not None:
            elapsed = cocotb.utils.get_sim_time("ns") - self.last_txn_end_time
            if elapsed < self.config.tCS_high:
                await Timer(
                    self.config.tCS_high - elapsed, unit="ns", round_mode="round"
                )

        cur_fmt = format_table[fmt]
        cmdstr = (cmd,)
        if isinstance(cmd, IntEnum):
            cmdstr = cmd.name
            cmd = cmd.to_bytes(1, "little")

        if cur_fmt["extension"] and extension is None:
            extension = cmd
        cocotb.log.info(
            f"Starting TXN {cmdstr} {extension=} fmt={fmt.name} {cur_fmt=} {data_cycles=} {self.cmd_mode=} {address=} {data=} ",
        )
        await FallingEdge(self.bus.clk)
        self.bus.csn.value = 0
        await Timer(self.config.tCS_setup, unit="ns", round_mode="round")
        self.dut.xspi_clk_en.value = True
        byte = b""
        self._setfsm(b"idle")
        if self.dut is not None:
            self.dut.flag.value = 0
        # self._setfsm(b"cmd")
        await self._write_byte(cmd, self.cmd_mode, b"cmd", rwds_ena=1)
        if self.cmd_mode not in [Mode.S1, Mode.D1] and extension is None:
            e = int.from_bytes(cmd, "little") ^ 0xFF
            extension = e.to_bytes(1, "little")
        cocotb.log.debug(f"Sent {cmd=}")
        if cur_fmt["extension"]:
            await self._write_byte(extension, self.cmd_mode, b"ext", rwds_ena=1)

        # Address
        rng = cur_fmt["address"]
        for i in range(rng):
            # self._setfsm(f"addr {rng}".encode("utf-8"))
            await self._write_byte(
                address[i : i + 1],
                self.modifier_mode,
                f"addr {rng}".encode(),
                rwds_ena=None,
            )
        # Latency

        if cur_fmt["latency"]:
            await self._latency()
        if cur_fmt["iswrite"]:
            for idx, i in enumerate(data):
                if mask is not None:
                    msk = mask[idx]
                else:
                    msk = False
                # cocotb.log.info(f"Writing data {data=} {i=} i.e. {i.to_bytes(1,"little")}, {data[i:i+1]=}")
                # self._setfsm(b"wdata")
                await self._write_byte(
                    i.to_bytes(1, "little"),
                    self.data_mode,
                    b"wdata",
                    masked=msk,
                    rwds_ena=0,
                )
        if self.dut is not None:
            self.dut.flag.value = not self.dut.flag.value
        if cur_fmt["isread"]:
            for _ in range(data_cycles):

                self._setfsm(b"rdata")
                if self.data_mode == Mode.S1:
                    byte += await self._read_byte(self.data_mode)
                else:
                    byte += await self._read_byte_ds(self.data_mode)
        # await FallingEdge(self.bus.clk)
        await Timer(self.config.tCS_hold, unit="ns", round_mode="round")
        self.bus.csn.value = 1
        self._setfsm(b"idle")
        self.last_txn_end_time = cocotb.utils.get_sim_time("ns")
        for _ in range(10):
            await RisingEdge(self.bus.clk)
        if not self.free_running_clk:
            self.dut.xspi_clk_en.value = False
        return byte

    async def _read_byte(self, mode: Mode):
        """Helper Function to read a byte from dut."""
        cocotb.log.debug(f"Reading byte in mode {mode}")
        clk = self.bus.clk
        read_bv = LogicArray(0, 8)
        value = 0
        b = LogicArray(0, 8)
        if mode == Mode.S1:
            for i in range(8):
                if self.check_enables:
                    assert self.bus.dq_out_ena.value == 1
                self.dut.probe_data_start.value = 1
                await RisingEdge(clk)
                await Timer(self.period / 4, "ns", round_mode="round")
                bit = int(self.bus.dq_out.value) & 0x02  # bit 1
                bit = 1 if bit else 0
                value = (value << 1) | bit
        if mode == Mode.D1:
            for _i in range(4):
                if self.check_enables:
                    assert self.bus.dq_out_ena.value == 1
                self.dut.probe_data_start.value = 1
                await RisingEdge(clk)
                await Timer(self.period / 4, "ns", round_mode="round")
                bit = (int(self.bus.dq_out.value) >> 1) & 1
                value = (value << 1) | bit
                await ReadOnly()
                await FallingEdge(clk)
                await Timer(self.period / 4, "ns", round_mode="round")
                bit = (int(self.bus.dq_out.value) >> 1) & 1
                value = (value << 1) | bit
                cocotb.log.debug(f"{value=}")
        if mode == Mode.S4:
            for i in range(2):
                if self.check_enables:
                    assert self.bus.dq_out_ena.value == 1
                await RisingEdge(clk)
                await Timer(self.period / 4, "ns", round_mode="round")
                nibble = int(self.bus.dq_out.value) & 0x0F
                if i == 0:
                    value = nibble << 4  # high nibble
                else:
                    value |= nibble  # low nibble
        if mode == Mode.D4:
            if self.check_enables:
                assert self.bus.dq_out_ena.value == 1
            await RisingEdge(clk)
            if self.check_enables:
                assert self.bus.dq_out_ena.value == 1
            await Timer(self.period / 4, "ns", round_mode="round")
            value = (int(self.bus.dq_out.value) & 0x0F) << 4
            await FallingEdge(clk)
            await Timer(self.period / 4, "ns", round_mode="round")
            value |= int(self.bus.dq_out.value) & 0x0F
            cocotb.log.debug(f"D4 read byte: 0x{value:02X}")
        if mode == Mode.S8:
            if self.check_enables:
                assert self.bus.dq_out_ena.value == 1
            await RisingEdge(clk)
            await Timer(self.period / 4, "ns", round_mode="round")
            value = int(self.bus.dq_out.value) & 0xFF
        if mode == Mode.D8:
            if self.check_enables:
                assert self.bus.dq_out_ena.value == 1
            await clk.value_change
            await Timer(self.period / 4, "ns", round_mode="round")
            value = int(self.bus.dq_out.value) & 0xFF
        result = value.to_bytes(1, "big")
        cocotb.log.debug(f"READ byte 0x{value:02X} mode={mode}")
        if self.check_enables:
            assert self.bus.dq_out_ena.value == 1
        return result

    def _check_oe(self, rwds, dq):
        if self.check_enables:
            if dq is not None:
                assert self.bus.dq_out_ena.value == dq
            if rwds is not None:
                assert self.bus.rwds_out_ena.value == rwds

    async def _read_byte_ds(self, mode: Mode):
        """Helper Function to read a byte from dut.
        The read data is launched along with teh clock edge.
        We always sample it 1/4th clock cycle after the launch edge."""
        cocotb.log.debug(f"Reading byte in mode {mode}")
        clk = self.bus.rwds_out
        value = 0

        if mode in [Mode.D1]:
            for i in range(8):
                self._check_oe(1, 1)
                await clk.value_change
                await Timer(self.period / 4, "ns", round_mode="round")
                bit = int(self.bus.dq_out.value) & 0x02  # bit 1
                bit = 1 if bit else 0
                value = (value << 1) | bit
                cocotb.log.debug(f"S1/D1 READ byte 0x{value:02X} mode={mode}")
        if mode in [Mode.S4, Mode.D4]:
            for i in range(2):
                self._check_oe(1, 1)
                await clk.value_change
                await Timer(self.period / 4, "ns", round_mode="round")
                nibble = int(self.bus.dq_out.value) & 0x0F
                if i == 0:
                    value = nibble << 4  # high nibble
                else:
                    value |= nibble  # low nibble
        if mode in [Mode.S8, Mode.D8, Mode.HB]:
            self._check_oe(1, 1)
            await clk.value_change
            await Timer(self.period / 4, "ns", round_mode="round")
            value = int(self.bus.dq_out.value) & 0xFF
        result = value.to_bytes(1, "big")
        cocotb.log.debug(f"READ byte 0x{value:02X} mode={mode}")
        return result

    async def _latency(self) -> None:
        """Helper Function for latency."""
        for i in range(self.latency):
            await RisingEdge(self.bus.clk)
            cocotb.log.debug(i)
            self._setfsm(f"latency {self.latency-i}".encode())
            await FallingEdge(self.bus.clk)

    async def _write_byte(
        self, b: bytes, mode: Mode, msg=None, masked=False, rwds_ena=0
    ) -> None:
        """Helper Function to write a byte to the DUT.
        The controller sends data with some setup and hold time such that the clock appears in the middle of the data.
        Since we do not control the clock we will
        1. Send the data asap.
        2. Wait for clock edge
        3. Wait for half the time to the next valid clock edge.

        in case of xS mode this means wait for falling edge of clock
        in case of xD mode this means wait for 1/4 clock period.
        b: Byte to send.
        mode: The data rate
        msg: String to print on xspi_fsm while sending this byte
        masked: The rwds value to drive while sending this byte.
        rwds_ena: Check the value on rwds_ena matches this value.
        """
        bv = LogicArray.from_bytes(b, 8, byteorder="little")
        # bv_final=LogicArray(random.randint(0,255),8)
        bv_final = LogicArray(0, 8)
        cocotb.log.debug(f"write_byte {b=} {bv=} {mode=}")
        self.bus.rwds_in.value = masked
        self._check_oe(rwds_ena, 0)
        if mode == Mode.S1:
            for i in reversed(range(8)):
                self._check_oe(rwds_ena, 0)
                bv_final[0] = bv[i]
                self.bus.dq_in.value = bv_final
                await Timer(self.config.tdata_setup, "ns", round_mode="round")
                self._setfsm(msg)
                await RisingEdge(self.bus.clk)
                await FallingEdge(self.bus.clk)
        if mode == Mode.D1:
            for i in reversed(range(4)):
                self._check_oe(rwds_ena, 0)
                j = i * 2 + 1
                bv_final[0] = bv[j]
                self.bus.dq_in.value = bv_final
                self._setfsm(msg)
                await RisingEdge(self.bus.clk)
                await Timer(self.period / 4, "ns", round_mode="round")
                bv_final[0] = bv[j - 1]
                self.bus.dq_in.value = bv_final
                await FallingEdge(self.bus.clk)
                await Timer(self.period / 4, "ns", round_mode="round")
        if mode == Mode.S4:
            for i in reversed(range(2)):
                self._check_oe(rwds_ena, 0)
                if i:
                    bv_final[3:0] = bv[7:4]
                else:
                    bv_final[3:0] = bv[3:0]
                cocotb.log.debug(f"{bv_final=}")
                self.bus.dq_in.value = bv_final
                cocotb.log.debug(
                    f"DQ {b=} {bv=} {bv_final=} {int(self.bus.dq_in.value)}"
                )
                await Timer(self.config.tdata_setup, "ns", round_mode="round")
                self._setfsm(msg)
                await RisingEdge(self.bus.clk)
                await FallingEdge(self.bus.clk)
        if mode == Mode.D4:
            self._check_oe(rwds_ena, 0)
            bv_final[3:0] = bv[7:4]
            self.bus.dq_in.value = bv_final
            await Timer(self.config.tdata_setup, "ns", round_mode="round")
            self._setfsm(msg)
            await RisingEdge(self.bus.clk)
            await Timer(self.period / 4, "ns", round_mode="round")
            bv_final[3:0] = bv[3:0]
            self.bus.dq_in.value = bv_final
            await FallingEdge(self.bus.clk)
            await Timer(self.period / 4, "ns", round_mode="round")
        if mode == Mode.S8:
            self._check_oe(rwds_ena, 0)
            self.bus.dq_in.value = bv
            await Timer(self.config.tdata_setup, "ns", round_mode="round")
            self._setfsm(msg)
            await RisingEdge(self.bus.clk)
            await FallingEdge(self.bus.clk)
        if mode in [Mode.HB, Mode.D8]:
            self._check_oe(rwds_ena, 0)
            self.bus.dq_in.value = bv
            self._setfsm(msg)
            await Edge(self.bus.clk)
            await Timer(self.period / 4, "ns", round_mode="round")

    def add_callback(self, compare_fn) -> None:
        """Callback into scoreboard."""
