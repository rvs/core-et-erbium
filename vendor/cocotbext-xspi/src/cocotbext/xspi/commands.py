"""Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.

Author: Vijayvithal <jvs@nekko.ai>
Created on: 2026-02-09
Description:
Commands (Inspired from EverSpin xSPI MRAM devices.

Ref: EMxxLX Datasheet v3.2.pdf
# Read
- 0x05: Read Status Register
- 0x70: Read Flag Status Register
- 0x85: Read Configuration Register
- 0x96: Read GP Register.

# Write
- 0x01: Write Status Register
- 0x02: Write Memory
- 0x81: Write Configuration Register
- 0x50: Clear Flag Status Register
- 0x66: Reset Enable
- 0x99: Reset Device
- 0x03: Read
- 0x0B: Read XIP
- 0xB9: Enter deep power down
- 0xAB: Exit deep power down

# Veevx Custom
- 0x52: Set Mode  Format.G0, A1
     - 0: S1
     - 1: D1
     - 2: S2
     - 3: D2
     - 4: S4
     - 5: D4
     - 6: S8
     - 7: D8
     - 8: Hyperbus

"""

import cocotb
from .types import Format, Mode, format_table, Cmd, command_table
from .master_driver import XspiMasterDriver


class XspiCommands(XspiMasterDriver):
    """Wrapper over master_driver to suppport different commands.

    Eventually There will be multiple files like this  to accomodate different Vendors custom implementations
    """

    burstlength = 1
    _default_mode = 3

    def _decode_cmd(self, cmd: Cmd, address: int = None):
        if self.cmd_mode in [Mode.S1, Mode.D1]:
            fmt = command_table[cmd]["fmt_1s"]
        else:
            fmt = command_table[cmd]["fmt_8s"]

        addrlen = format_table[fmt]["address"]
        cocotb.log.debug(f"{cmd=} {addrlen=} {address} {fmt=}")
        if isinstance(address, int) and address is not None:
            address = address.to_bytes(addrlen, "big")
        return fmt, address

    async def Reset(self):
        """Send the xspi Softreset command."""
        fmt, address = self._decode_cmd(Cmd.ResetDevice)
        if self.cmd_mode == Mode.HB:
            pass
        else:
            await self.txn(
                cmd=Cmd.ResetDevice,
                address=address,
                data=None,
                fmt=fmt,
                data_cycles=0,
            )
        self.set_Default_Mode(self._default_mode)
        self.set_latency(16)

    async def set_Latency(self, latency: int):
        self.setLatency(latency)

    async def setLatency(self, latency: int):
        assert latency >= 8
        prg_latency = latency - 8
        reg = await self.read_Reg(0x10)
        reg = (int.from_bytes(reg, "little") & 0xFFFFFF0F) | ((0xF & prg_latency) << 4)
        cocotb.log.info(f"new {reg=:x} {prg_latency=:x} {latency=:x}")
        # await self.write_Reg(0x10, reg.to_bytes(4,"little"))
        await self.write_Reg(0x10, reg.to_bytes(4, "little"))
        self.set_latency(latency)

    async def setRate(self, cmd: Mode, addr: Mode, datamode: Mode):
        """Veevx Custom command to set the operating rate."""
        cocotb.log.info(
            f"SETRATE changing rate from {self.cmd_mode=} {self.modifier_mode=} {self.data_mode=}",
        )
        d = (((cmd.value << 8) | addr.value) << 8) | datamode.value
        if self.cmd_mode == Mode.HB:
            await self.write_Reg(0x28, d)
        else:
            fmt, address = self._decode_cmd(Cmd.SetRate)
            await self.txn(
                cmd=Cmd.SetRate,
                address=None,
                data=d.to_bytes(3, "big"),
                fmt=fmt,
                data_cycles=0,
            )
        self.cmd_mode = cmd
        self.modifier_mode = addr
        self.data_mode = datamode
        cocotb.log.info(
            f"SETRATE set rate to {self.cmd_mode=} {self.modifier_mode=} {self.data_mode=}",
        )

    async def read(self, address):
        return await self.read_Mem(address)

    async def write(self, address, data):
        return await self.write_Mem(address, data)

    def set_Default_Mode(self, mode):
        if mode == 0:
            defm = Mode.HB
        elif mode == 1:
            defm = Mode.D8
        elif mode == 2:
            defm = Mode.S4
        elif mode == 3:
            defm = Mode.S1
        else:
            cocotb.log.error(f"Illegal mode {mode}")

        self.cmd_mode = defm
        self.modifier_mode = defm
        self.data_mode = defm
        self._default_mode = mode

    async def read_Reg(self, address):
        if self.cmd_mode == Mode.HB:
            return await self.hb.read_Reg(address)
        else:
            fmt, address = self._decode_cmd(Cmd.ReadReg, address)
            data = await self.txn(
                cmd=Cmd.ReadReg,
                address=address,
                data=None,
                fmt=fmt,
                data_cycles=4,
            )
            return data

    async def write_Reg(self, address, data):
        assert len(data) % 4 == 0
        if self.cmd_mode == Mode.HB:
            return await self.hb.write_Reg(address, data)
        else:
            fmt, address = self._decode_cmd(Cmd.WriteReg, address)
            await self.txn(
                cmd=Cmd.WriteReg,
                address=address,
                data=data,
                fmt=fmt,
                data_cycles=0,
            )

    async def read_Mem(self, address):
        """Read memory."""
        if self.cmd_mode == Mode.HB:
            return await self.hb.read_Mem(address)
        else:
            fmt, address = self._decode_cmd(Cmd.ReadMEM, address)
            data = await self.txn(
                cmd=Cmd.ReadMEM,
                address=address,
                data=None,
                fmt=fmt,
                data_cycles=8 * self.burstlength,
            )
            return data

    async def set_BurstLength(self, length: int, enabled: bool = True):
        address = 0x10
        regval = await self.read_Reg(address)
        regval = (regval & 0x2FFFC) | (enabled << 16 | (length - 8))
        await self.write_Reg(address, regval)
        self.burstlength = length
        self.hb.set_burstlength(length)

    async def write_Mem(self, address, data, mask=None):
        """Write Memory."""

        if self.cmd_mode == Mode.HB:
            return await self.hb.write_Mem(address, data)
            pass
        else:
            fmt, address = self._decode_cmd(Cmd.WriteMEM, address)
            assert len(data) % 8 == 0

            data = await self.txn(
                cmd=Cmd.WriteMEM,
                address=address,
                data=data,
                fmt=fmt,
                data_cycles=0,
                mask=mask,
            )

    async def read_SFDP(self, address):
        """Read SFDP."""
        """Read SFDP Command.
        returns An entire section of words,
        Address = 0 returns SFDP Header and parameter headers.
        Address = 0xY00 Y is the section number, it returns the entire section db. excluding the header.


        """
        if self.cmd_mode == Mode.HB:
            pass
        else:
            self.clk_freq_mhz = 50
            cocotb.log.debug("Executing read SFDP")
            fmt, address = self._decode_cmd(Cmd.ReadReg, address)
            data = await self.txn(
                cmd=Cmd.ReadSFDP,
                address=address,
                data=None,
                fmt=fmt,
                data_cycles=256,
            )
            return data
