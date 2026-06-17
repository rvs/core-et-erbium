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

"""Extended xSPI commands missing from cocotbext/xspi/commands.py.

These should ultimately be upstreamed into the cocotbext package.
They are kept here as a mixin so tests can use them via EnvExt without
modifying the installed package.

Commands implemented:
    read_Reg    (cmd 0x65)  – Register Read     [Format B1 / E0 in SPI]
    write_Reg   (cmd 0x71)  – Register Write    [Format D1 / K0 in SPI]
    read_OTP    (cmd 0x4B)  – OTP Read          [Format B1]
    write_OTP   (cmd 0x42)  – OTP Write         [Format D1]
    enter_PD    (cmd 0xB9)  – Enter Powerdown   [Format A0 / A1]
    exit_PD     (cmd 0xAB)  – Exit  Powerdown   [Format A0 / A1]

Proposed cocotbext changes (see end of file):
    1. commands.py – add the six methods above.
    2. types.py    – fix Format.A1 duplicate definition (keep isread=False, iswrite=False).
    3. types.py    – add Format.D1 latency=False.
    4. master_driver.py – extension inversion for all DDR modes, not just D8.
"""

import cocotb
from cocotbext.xspi.types import Format, Mode
from cocotbext.xspi.commands import XspiCommands
from cocotbext.xspi.types import Cmd

burst_decode={
        0:16,
        1:8,
        2:2,
        3:4
        }


class XspiExtCommands(XspiCommands):
    """Extends base XspiCommands with missing register / OTP / power commands."""

    # -----------------------------------------------------------------
    # Register access  (3-byte address, 32-bit data)
    # -----------------------------------------------------------------
    # -----------------------------------------------------------------
    # OTP access
    # -----------------------------------------------------------------
    async def setBurst(self, burstLength: int):
        fmt, address = self._decode_cmd(Cmd.ReadReg, 0x10)
        assert burstLength <= 3, "refer to the documentation for valid values."
        rv = await self.read_Reg(address)
        rv = (int.from_bytes(rv, "little") & 0xFFFC) | (0x3 & burstLength) | (1<<16)
        await self.write_Reg(address, rv.to_bytes(4,"little"))

        self.burstlength=burst_decode[burstLength]
        return self.burstlength

    async def read_OTP(self, address: int, length: int = 8) -> bytes:
        """Read *length* bytes from the OTP region (cmd 0x4B)."""
        addr_bytes = address.to_bytes(4, "big") if isinstance(address, int) else address
        if self.cmd_mode in (Mode.D8, Mode.S8):
            fmt = Format.B1
        else:
            fmt = Format.F0

        raw = await self.txn(
            cmd=b"\x4b",
            address=addr_bytes,
            data=None,
            fmt=fmt,
            data_cycles=length,
        )
        return raw

    async def write_OTP(self, address: int, data: bytes) -> None:
        """Write *data* bytes to the OTP region (cmd 0x42)."""
        addr_bytes = address.to_bytes(4, "big") if isinstance(address, int) else address
        if self.cmd_mode in (Mode.D8, Mode.S8):
            fmt = Format.D1
        else:
            fmt = Format.K0

        await self.txn(
            cmd=b"\x42",
            address=addr_bytes,
            data=data,
            fmt=fmt,
            data_cycles=0,
        )

    # -----------------------------------------------------------------
    # Power management
    # -----------------------------------------------------------------
    async def enter_PD(self) -> None:
        """Send Enter Deep Powerdown command (0xB9)."""
        fmt = Format.A1 if self.cmd_mode not in (Mode.S1, Mode.D1) else Format.A0
        await self.txn(
            cmd=b"\xb9",
            address=(0).to_bytes(4, "big"),
            data=b"",
            fmt=fmt,
            data_cycles=0,
        )
        cocotb.log.info("Sent EnterPowerDown")

    async def exit_PD(self) -> None:
        """Send Exit Deep Powerdown command (0xAB)."""
        fmt = Format.A1 if self.cmd_mode not in (Mode.S1, Mode.D1) else Format.A0
        await self.txn(
            cmd=b"\xab",
            address=(0).to_bytes(4, "big"),
            data=b"",
            fmt=fmt,
            data_cycles=0,
        )
        cocotb.log.info("Sent ExitPowerDown")


# =============================================================================
# Proposed changes to cocotbext package
# =============================================================================
"""
FILE: cocotbext/xspi/types.py
CHANGES:
  1. Format.A1 duplicate definition (currently two definitions exist; the
     second one (isread=True, iswrite=True) overwrites the first correct one).
     FIX: Remove second definition entirely.

  2. Format.D1 currently has latency=True.
     JESD251C Figure 14 (1.D Write) shows no latency phase.
     FIX: Set latency=False in Format.D1.

  3. Missing format entries needed by register tests:
     Format.E0 should reference 3-byte address.  Currently address=True
     maps to rng=3 which is correct for 3-byte address (good).

FILE: cocotbext/xspi/master_driver.py
CHANGES:
  1. Line ~104 – Extension (RI = Repeat/Invert) is only applied for Mode.D8:
        if self.cmd_mode == Mode.D8 and extension is None:
     This misses Mode.D4, Mode.S8, Mode.D1 DDR modes.  In all DDR modes with
     Profile 1.0 an extension byte equal to bitwise-NOT of the command must
     be sent.
     FIX:
        DDR_MODES = {Mode.D1, Mode.D4, Mode.S8, Mode.D8}
        if self.cmd_mode in DDR_MODES and extension is None:
            e = int.from_bytes(cmd, "little") ^ 0xFF
            extension = e.to_bytes(1, "little")

  2. _write_byte mask argument: `self.bus.rwds_in.value = masked` assigns a
     Python bool/None to a LogicArray.  This raises a TypeError at runtime.
     FIX: `self.bus.rwds_in.value = 1 if masked else 0`

  3. _read_byte Mode.D1 bit accumulation is missing the shift for the second
     (falling-edge) bit, causing the high bits to be corrupted.
     FIX: accumulate properly (see below):
        for _i in range(4):
            await RisingEdge(self.bus.clk)
            bit = (int(self.bus.dq_out.value) >> 1) & 1
            value = (value << 1) | bit
            await FallingEdge(self.bus.clk)
            bit = (int(self.bus.dq_out.value) >> 1) & 1
            value = (value << 1) | bit     # ← this shift was missing

  4. commands.py read_SFDP uses 3-byte address but xspi.md mandates 4B.
     FIX: address.to_bytes(4, "big") and use Format.F0 style (address4=True).

  5. commands.py setRate passes `address=None` but format_table[Format.G0]
     still enters the address loop (rng stays 0 which is fine), however the
     3-byte data should be packed as (cmd<<16)|(addr<<8)|data, which it does
     correctly – this is OK.  However address=None when rng>0 would crash.
     Defensive fix: guard address loop with `if address is not None`.
"""
