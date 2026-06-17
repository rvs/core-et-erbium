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


from mem_loader.loaders.loader import Loader
from cocotb.triggers import Timer

class ROMLoader(Loader):

    # Bit index
    # 12                            3 2             0
    # ↓                             ↓ ↓             ↓
    # ┌──────────────────────────────┬──────────────┐
    # │            ROW               │ BYTE_OFFSET  │
    # │         (10 bits)            │  (3 bits)    │
    # └──────────────────────────────┴──────────────┘

    # Field ranges:
    #     ROW         = address[12:3]
    #     BYTE_OFFSET = address[2:0]

    NUM_ROWS = 1024

    def __init__(self, dut, base_addr, size):
        self.BASE_ADDR = base_addr
        self.MAX_SIZE = size
        self.dut = dut
        assert size == 8*1024, "Current implementation only supports 4KB, found size {size}"

        self.rom = {
            row_idx: self.dut.rom.rom64b_0.rom[row_idx]
            for row_idx in range(self.NUM_ROWS)
        }

    def map_address(self, bus_addr):
        byte_offset = bus_addr & 0b111
        bus_addr >>= 3
        row = bus_addr & 0b1111111111
        return row, byte_offset

    async def write_row(self, addr: int, row_data: bytes):
        assert (addr & 0b111111) == 0, f"Address must be aligned to 64B, found {hex(addr)}."
        chunk_addr = addr
        for i in range(8):
            chunk = int.from_bytes(row_data[i*8:(i+1)*8], byteorder="little")
            row, _ = self.map_address(chunk_addr)
            self.rom[row].value = chunk
            chunk_addr = chunk_addr + 8
        await Timer(1, units="step")

    async def write_byte(self, addr: int, row_data: bytes):
        assert len(row_data) == 1, f"Row data must be less than 1 Byte. Found {hex(row_data)}."
        row, row_offset = self.map_address(addr)

        # Get DUT signal
        sig = self.rom[row]

        # Convert to integer
        val = sig.value.to_unsigned()

        # Modify slice
        msb = (row_offset*8) + 7
        lsb = row_offset*8
        width = msb - lsb + 1
        mask = ((1 << width) - 1) << lsb
        val = (val & ~mask) | ((row_data[0] << lsb) & mask)

        # Write back
        sig.value = val
        await Timer(1, units="step")

    async def read_byte(self, addr: int):
        row, row_offset = self.map_address(addr)
        msb = (row_offset*8) + 7
        lsb = row_offset*8
        return int(self.rom[row].value[msb:lsb])
