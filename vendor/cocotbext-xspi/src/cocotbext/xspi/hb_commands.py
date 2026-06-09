"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-14
 Description: A brief description of the file's purpose.
"""

import cocotb
from cocotb.types import LogicArray
from .types import Format


class HB:
    CA = LogicArray(0, 48)

    def __init__(self, txn):
        self.txn = txn
        self.burstlength = 1

    def set_burstlength(self, length):
        self.burstlength = length

    async def write_Reg(self, address, data):
        cmd, addr = self._makeCA(
            isRead=False, isReg=True, isLinearBurst=True, address=address
        )
        await self.txn(cmd=cmd, address=addr, data=data, fmt=Format.B2)

    async def write_Mem(self, address, data):
        cmd, addr = self._makeCA(
            isRead=False, isReg=False, isLinearBurst=True, address=address
        )
        await self.txn(cmd=cmd, address=addr, data=data, fmt=Format.B2)
        pass

    async def read_Reg(self, address):
        cmd, addr = self._makeCA(
            isRead=True, isReg=True, isLinearBurst=True, address=address
        )
        rv = await self.txn(cmd=cmd, address=addr, fmt=Format.A2, data_cycles=4)
        return rv

    async def read_Mem(self, address):
        cmd, addr = self._makeCA(
            isRead=True, isReg=False, isLinearBurst=True, address=address
        )
        cocotb.log.info(f"{cmd}, {addr}")
        rv = await self.txn(
            cmd=cmd, address=addr, fmt=Format.A2, data_cycles=8 * self.burstlength
        )
        return rv
        pass

    def _makeCA(self, isRead, isReg, isLinearBurst, address):
        ca = LogicArray(0, 48)
        if isinstance(address, bytes):
            address = int.from_bytes(address, "big")

        address = LogicArray(address, 32)
        ca[47] = 1 if isRead else 0
        ca[46] = 1 if isReg else 0
        ca[45] = 1 if isLinearBurst else 0
        ca[44:16] = address[31:3]
        ca[15:0] = 0
        ca[2:0] = address[2:0]
        # return ca
        ca_bytes = int(ca).to_bytes(6, "big")
        cocotb.log.info(f"CA values are {ca_bytes[0:1]} {ca_bytes[1:]}")
        return ca_bytes[0:1], ca_bytes[1:]
