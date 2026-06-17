#!/usr/bin/python3
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

from elftools.elf.elffile import ELFFile

from mem_loader.loaders.mram import MRAMLoader
from mem_loader.loaders.sram import SRAMLoader
from mem_loader.loaders.rom import ROMLoader
from mem_loader.region_lookup import RegionLookup, MemMap

class MemLoader:

    def __init__(self, dut):
        self.region_lookup = RegionLookup()
        self.region_loaders = {}

        # ROM
        rom_dut = dut.et.erbium_digital.sram_wrapper
        rom_base, rom_size = self.region_lookup.by_name("ROM")

        # SRAM
        sram_dut = dut.et.erbium_digital.sram_wrapper
        sram_base, sram_size = self.region_lookup.by_name("SRAM")

        # MRAM
        mram_dut = dut.et.erbium_digital.axi2mram_wrapper
        mram_base, mram_size = self.region_lookup.by_name("MRAM")

        self.region_loaders = {
            MemMap.MRAM: MRAMLoader(mram_dut, mram_base, mram_size),
            MemMap.SRAM: SRAMLoader(sram_dut, sram_base, sram_size),
            MemMap.ROM:  ROMLoader(rom_dut, rom_base, rom_size),
        }

    def align64_with_padding(self, base, data):
        # round down to 64B boundary
        aligned_base = base & ~0x3F

        # pad the front if needed
        front_pad = base - aligned_base
        padded = b"\x00" * front_pad + data

        # pad the tail to a multiple of 64
        if len(padded) % 64 != 0:
            padded += b"\x00" * (64 - (len(padded) % 64))
        return aligned_base, padded

    def _get_loader(self, addr):
        # Identify segment region
        region_info = self.region_lookup.find(addr)
        if region_info is None:
            raise KeyError(f"Address {hex(addr)} does not fall into any known region")

        _, _, region = region_info

        # Look up the correct loader for this region
        try:
            return self.region_loaders[region]
        except KeyError as exc:
            raise KeyError(
                f"Unexpected Memory Region {region} for segment at {hex(addr)}"
            ) from exc

    async def load_elf(self, path: str):
        # Workaround to avoid XPROP: init sram to 0
        await self.region_loaders[MemMap.SRAM].zero_all_mem()

        bootrom_addr = None
        with open(path, "rb") as f:
            elf = ELFFile(f)

            # Find .bootrom section address
            for section in elf.iter_sections():
                if section.name == ".bootrom":
                    bootrom_addr = section['sh_addr']
                    break

            for section in elf.iter_sections():
                if section['sh_type'] == 'SHT_NULL':
                    continue
                if section['sh_flags'] & 0x2 == 0:  # SHF_ALLOC flag - skip non-loadable sections
                    continue

                data = section.data()
                addr = section['sh_addr']
                size = len(data)

                if size == 0:
                    continue

                loader = self._get_loader(addr)
                i = 0

                # Phase 1: write bytes until aligned to 64
                while (addr + i) % 64 != 0 and i < size:
                    await loader.write_byte(addr + i, bytes([data[i]]))
                    i += 1

                # Phase 2: write full 64‑byte chunks
                while i + 64 <= size:
                    chunk = data[i:i+64]
                    await loader.write_row(addr + i, chunk)
                    i += 64

                # Phase 3: write remaining bytes
                for b in data[i:]:
                    await loader.write_byte(addr + i, bytes([b]))
                    i += 1

        return bootrom_addr

    async def read_byte(self, addr: int) -> int:
        loader = self._get_loader(addr)
        return await loader.read_byte(addr)

    async def write_byte(self, addr: int, data: int):
        loader = self._get_loader(addr)
        await loader.write_byte(addr, data.to_bytes())

    async def write_data(self, addr: int, num_bytes: int, data: int):
        loader = self._get_loader(addr)
        for offset in range(0, num_bytes):
            await loader.write_byte(addr+offset, (data&0xff).to_bytes())
            data = data >> 8

    async def read_data(self, addr: int, num_bytes: int) -> int:
        loader = self._get_loader(addr)
        value = 0
        shift = 0

        for offset in range(0, num_bytes):
            byte = await loader.read_byte(addr + offset)
            value |= (byte & 0xff) << shift
            shift += 8

        return value
