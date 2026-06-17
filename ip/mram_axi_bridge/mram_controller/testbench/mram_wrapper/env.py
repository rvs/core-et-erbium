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

from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
import os
import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from driver.vapb import VAPB
from testlist import TestMode
from driver.DRAMMonitor import DRAMMonitor
from bist_model import BistModel


def printio(func):
    async def inner(*args, **kwargs):
        cocotb.log.info(f"Enter {func.__name__}")
        await func(*args, **kwargs)
        cocotb.log.info(f"Exit {func.__name__}")

    return inner


class TestEnv:
    def __init__(self, dut, mode=TestMode.LiveCheck, testname=None, timeout=500):
        self.intf = VAPB(dut, "", dut.clk)
        self.test_mode = mode
        if testname:
            self.testname = f'{self.test_mode.name }_{testname}'
        else:
            self.testname = self.test_mode.name
        self.dut = dut
        self.timeout = timeout
        self.initialize_inputs()


        cocotb.start_soon(self.watchdog())


    def dram_cb(self, txn):
        ''' Even if no transaction is initiated the CS will be asserted.
        This will trigger false txn from DRAMMonitor.
        We will detect and ignore these false transaction and report them at the end
        '''
        def to_hex_if_int(value):
            if isinstance(value, int):
                return hex(value)
            return value
        self.kicked = True
        if os.getenv("SKIP_SCOREBOARD"):
            return
        if self.testname in ['LiveCheck']:
            return
        txn_hex = {key: to_hex_if_int(value) for key, value in txn.items()}
        # cocotb.log.info(f"accepted {txn_hex}")
        # cocotb.log.info(f"accepted {txn}")
        self.txn_count += 1
        self.prev_txn = txn
        expected = next(self.expectedGen)

        hex_test = {key: to_hex_if_int(value)
                    for key, value in expected.items()}
        # cocotb.log.info(f'Checker txn={txn_hex}\nexpected={hex_test}')
        testing = {'actual': txn_hex, 'expected': hex_test}
        if self.disable_write:
            assert txn['write'] == False, f"{self.testname} Not expecting a write transaction {testing}"
        if self.disable_read:
            assert txn['read'] == False, f"{self.testname} Not expecting a read transaction {testing}"
        assert hex(expected['addr']) == hex(
            txn['addr']), f"{self.testname} Error Address mismatch {testing}"
        assert expected['cs'] == txn['cs'], f"{self.testname}: Error cs mismatch {testing}"
        assert expected['write'] == txn['write'], f" {self.testname} Error write mismatch {testing}"
        if expected['write']:
            assert expected['wdata'] == txn['wdata'], f"{self.testname} Error wdata {testing}"
        if not self.fakeRead:
            assert expected['read'] == txn['read'], f"{self.testname} Error read mismatch {testing}"
            if expected['read'] and not self.disable_write:
                assert expected['rdata'] == txn['rdata'], f"Error Rdata Mismatch {testing}"
        # assert expected == txn, f"{self.testname} Error: Transaction mismatch {expected} {txn}"
        cover_txn(txn)

    def initialize_inputs(self):
        pass

    async def start(self):
        pass

    async def resetSequence(self):
        await Timer(1, "ns")
        self.dut.preset_n.value = 0
        await Timer(100, "ns")
        await RisingEdge(self.dut.clk)
        self.dut.preset_n.value = 1
        for _ in range(10):
            await RisingEdge(self.dut.clk)

    @printio
    async def default_run(self, override_init=None):
        self.override_init = override_init
        await self.start()
        await self.initialize()
        await self.run()
        await self.check()

    async def initialize(self):
        self.addr_mode = random.randint(0, 1)
        self.data_mode = random.randint(0, 1)
        self.stop_on_error = random.randint(0, 1)
        self.flipOdd = random.randint(0, 1)
        self.disable_read = random.randint(0, 1)
        self.disable_write = random.randint(0, 1)
        # self.endurance_mode = self.test_mode == TestMode.Endurance
        # self.walking = self.test_mode in [TestMode.Walking0, TestMode.Walking1]
        self.walking_bit = random.randint(0, 1)
        self.data_shift_dir = random.randint(0, 1)
        # self.neighbor_noise = self.test_mode == TestMode.NeighborNoise
        self.retention = 0
        self.data = 0x55aa_55aa
        self.address_mask = 0x1ffff
        self.cs = random.choice([0x1, 0x2, 0x4])
        self.loop_repeat = 0
        self.address_repeat = 0
        self.read_delay = 0
        # if self.cs == 1:
        max_addr = 0x2ffff
        if self.cs == 2:
            max_addr = 0x6ffff
        if self.cs == 4:
            max_addr = 0x2ffff
        address = (random.randint(0, max_addr), random.randint(0, max_addr))
        cocotb.log.info(f"Address={address}")
        self.start_address = min(address)
        self.stop_address = max(address)
        self.incr_count = random.randint(1, 4)

        await self.resetSequence()
        # await self.reg.system_registers.ClockControl.write_fields(
        #     creg_bist_ro_en=1, creg_bist_ro_trim=8
        # )
        fn = getattr(self, self.test_mode.name + "_initialize")
        await Timer(100, 'ns')
        cocotb.log.info(f"HERE IAM")
        await fn()

    @printio
    async def run(self):
        cocotb.log.info("run: " + self.test_mode.name)
        print("Writing registers")
        # await self.reg.system_registers.CHIPID.read()
        # await self.reg.bist_registers.INCR_COUNT.write(self.incr_count)
        # a = self.get_start_address()
        # await self.reg.bist_registers.START_ADDRESS.write(a)
        # cocotb.log.info(
        #     f"ADDRESS_LENGTH {self.start_address}, {self.stop_address}, {self.incr_count}, {(self.stop_address - self.start_address)//self.incr_count}")
        # await self.reg.bist_registers.ADDRESS_LENGTH.write(self.stop_address)
        # await self.reg.bist_registers.ADDRESS_Mask.write(self.address_mask)
        # if not self.walking:
        #     await self.reg.bist_registers.DATA.write(self.data)
        # await self.reg.bist_registers.Address_Repeat.write(self.address_repeat)
        # await self.reg.bist_registers.Loop_Repeat.write(self.loop_repeat)
        # await self.reg.bist_registers.Read_Delay.write(self.read_delay)
        # await self.reg.bist_registers.BIST_CTRL.write_fields(
        #     addr_mode=self.addr_mode,
        #     data_mode=self.data_mode,
        #     stop_on_error=self.stop_on_error,
        #     checkerboard=self.flipOdd,
        #     endurance_mode=self.endurance_mode,
        #     disable_read=self.disable_read,
        #     disable_write=self.disable_write,
        #     walking=self.walking,
        #     walking_bit=self.walking_bit,
        #     data_shift_dir=self.data_shift_dir,
        #     neighbor_noise=self.neighbor_noise,
        #     cs=self.cs,
        #     retention_mode=self.retention,
        #     start=0,
        # )
        # await self.bistmodel.start()
        # await self.reg.bist_registers.BIST_CTRL.write_fields(
        #     start=1
        # )
        cocotb.log.info("run")
        fn = getattr(self, self.test_mode.name + "_run")
        cocotb.log.info(f"running {fn.__name__}")
        await fn()
        await Timer(270, 'ns')  # Give time for busy CDC to propogate.

    async def check(self):
        fn = getattr(self, self.test_mode.name + "_check")
        await fn()

        cover({
            'name': self.test_mode.name,
            'address_mode': self.addr_mode,
            'data_mode': self.data_mode,
            'stop_on_error': self.stop_on_error,
            'checkerboard': self.flipOdd,
            'disable_read': self.disable_read,
            'disable_write': self.disable_write,
            'walking_bit': self.walking_bit,
            'data_shift_dir': self.data_shift_dir
        })
        fname = f'{self.testname }_coverage.xml'
        coverage_db.report_coverage(cocotb.log.info, bins=True)
        coverage_file = os.path.join(
            os.getenv('REPORTS_PATH', "./"), fname)
        cocotb.log.info(coverage_file)
        coverage_db.export_to_xml(filename=coverage_file)
        # cocotb.log.info(
        #     f"Valid Txn {self.txn_count}, Dummy Txn {self.rejected_txn}")
        # if self.test_mode not in [TestMode.LiveCheck]:
        #     assert self.txn_count == self.bistmodel.total_txn_count(
        #     ), f"{self.testname} Error TXN count mismatch"

    async def regRead(self, addr: int, width: int=0, accesswidth: int=0):
        rv = await self.intf.read(addr)
        cocotb.log.info(f"RegRead addr={addr:x} rdata={hex(rv.integer)}")
        return rv.integer
        pass

    async def regWrite(self, addr: int, width: int=0, accesswidth: int=0, data: int=0):
        cocotb.log.info(f"RegWrite, addr={hex(addr)} data={hex(data)}")
        return await self.intf.write(addr, data)
        pass

    async def watchdog(self):
        while 1:
            self.kicked = False
            await Timer(self.timeout, "ns")
            assert self.kicked, f"{self.testname} Testcase timeout"

    async def BistHasError(self, expected_error_count=0):
        # self.error_insertion['cs1'].value = 1
        busy = await self.reg.bist_registers.BIST_STATUS.busy.read()
        while (busy):
            busy = await self.reg.bist_registers.BIST_STATUS.busy.read()
        rd = await self.reg.bist_registers.Error.read_fields()
        cocotb.log.info(rd)
        assert (
            rd["error_count"] == expected_error_count
        ), f"{self.testname} There were {rd['error_count'] -expected_error_count} unexpected error(s), the last error was on address {rd['last_error_addr']}"

    def cs_or(self):
        rv = {1: 0x0, 2: 0x20000, 4: 0x40000}
        return rv[self.cs]

    def get_start_address(self):
        if not self.addr_mode:
            return self.cs_or() | (self.start_address & (self.bistmodel.addr_mod[self.cs] - 1))
        else:
            self.address_mask &= (self.bistmodel.addr_mod[self.cs] - 1)
            return self.cs_or() | (self.start_address & self.address_mask)

    ############################
    # Individual Tests
    ############################

    # Directed Test Setup

    async def Directed_initialize(self):
        for k, v in self.override_init.items():
            print(k, v)
            if hasattr(self, k):
                setattr(self, k, v)
            else:
                cocotb.log.info(f" Key not found {k} {v}")

        pass

    @printio
    async def Directed_run(self):
        pass

    async def Directed_check(self):
        await self.BistHasError(0)
        while True:
            await Timer(10, "ns")
            rd = await self.reg.bist_registers.BIST_STATUS.read_fields()
            if rd["busy"] == 0:
                break

        await self.BistHasError(0)
        await Timer(1, "us")

        pass
    # LiveCheck Test Setup

    async def LiveCheck_initialize(self):
        self.dut.axi_add = 0
        self.dut.axi_bwe = 0
        self.dut.axi_din = 0
        self.dut.axi_we = 0
        self.dut.axi_stripe_sel = 0

    async def modifyRegBits(self, addr, data, offset, bit_num):
        await self.modifyReg(addr, data << offset, ((1 << bit_num) - 1) << offset)

    async def modifyReg(self, addr, data, bwe):
        upper_bwe_bits = (bwe & 0xffffffff00000000) >> 32
        lower_bwe_bits = (bwe & 0x00000000ffffffff)
        upper_data_bits = (data & 0xffffffff00000000) >> 32
        lower_data_bits = (data & 0x00000000ffffffff)
        upper_reg = addr * 2 + 1
        lower_reg = addr * 2
        if lower_bwe_bits != 0:
            lower_rv = await self.regRead(lower_reg)
        if upper_bwe_bits != 0:
            upper_rv = await self.regRead(upper_reg)
        if lower_bwe_bits != 0:
            await self.regWrite(lower_reg, data = (lower_data_bits & lower_bwe_bits) | (lower_rv & ~lower_bwe_bits))
        if upper_bwe_bits != 0:
            await self.regWrite(upper_reg, data = (upper_data_bits & upper_bwe_bits) | (upper_rv & ~upper_bwe_bits))

    async def readReg(self, addr):
        upper_reg = addr * 2 + 1
        lower_reg = addr * 2
        lower_rv = await self.regRead(lower_reg)
        upper_rv = await self.regRead(upper_reg)
        return lower_rv | (upper_rv << 32)

    async def get_busy(self):
        rv = await self.readReg(10)
        return (rv >> 60) & 1

    @printio
    async def LiveCheck_run(self):
        # rv = await self.reg.system_registers.CHIPID.read()
        # cocotb.log.info(f"rv={type(rv)}")
        # assert rv == 0xcab0, f"{self.testname} LiveCheck Failed"
        # mram_clk_en = 0
        await self.modifyRegBits(2, 0x0, 15, 1)

        # Set start address
        # await self.regWrite(5, data = 0x00000 << (44-32))
        await self.modifyRegBits(2, 0x0, 44, 20)
        # Set Stop Address
        # await self.regWrite(9, data = 0x00010 << (32-32))
        await self.modifyRegBits(4, 0x10, 32, 20)

        # bist_rd_en = 1
        # await self.regWrite(1, data = 0x1 << (54 - 32))
        await self.modifyRegBits(0, 1, 54, 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)

        # Wait for busy = 0
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_rd_en = 0
        # await self.regWrite(1, data = 0x1 << (54 - 32))
        await self.modifyRegBits(0, 0, 54, 1)
        # bist_start = 1
        await self.modifyRegBits(12, 0, 31, 1)

        # bist_rd_en = 1
        # await self.regWrite(1, data = 0x1 << (54 - 32))
        await self.modifyRegBits(0, 1, 54, 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)

        # Wait for busy = 0
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_rd_en = 0
        await self.modifyRegBits(0, 0, 54, 1)
        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        # BWE
        await self.modifyRegBits(1, 0xffffffffffffffff, 0, 64)
        await self.modifyRegBits(addr = 2, data = 1, offset = 43, bit_num = 1)

        # DIN
        await self.modifyRegBits(3, 0xaaaaaaaa55555555, 0, 64)
        # bist_we_en = 1
        await self.modifyRegBits(addr = 0, data = 1, offset = 55, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        # Wait for busy = 0
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break
        await self.modifyRegBits(addr = 0, data = 0, offset = 55, bit_num = 1)

        await self.modifyRegBits(addr = 0, data = 1, offset = 54, bit_num = 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break
        await self.modifyRegBits(addr = 0, data = 0, offset = 54, bit_num = 1)
        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(addr = 2, data = 1, offset = 43, bit_num = 1)
        await self.modifyRegBits(3, 0xaaaaaaaa55555550, 0, 64)
        await self.modifyRegBits(1, 0xffffffffffffffff, 0, 64)

        await self.modifyRegBits(addr = 0, data = 1, offset = 54, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break
        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(addr = 0, data = 0, offset = 54, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 1, offset = 53, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 0, offset = 53, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 1, offset = 54, bit_num = 1)
        await self.modifyRegBits(12, 1, 31, 1)

        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break
        await self.modifyRegBits(addr = 0, data = 0, offset = 54, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 1, offset = 53, bit_num = 1)
        await self.modifyRegBits(2, 0x7fff, 0, 15)
        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)

        await self.modifyRegBits(addr = 2, data = 1, offset = 32, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(12, 1, 32, 1)

        await self.modifyRegBits(addr = 2, data = 1, offset = 32, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(12, 1, 32, 1)
        # Set start address
        # await self.regWrite(5, data = 0x00000 << (44-32))
        await self.modifyRegBits(2, 0x1fe0, 44, 20)
        # Set Stop Address
        # await self.regWrite(9, data = 0x00010 << (32-32))
        await self.modifyRegBits(4, 0x4020, 32, 20)

        await self.modifyRegBits(addr = 2, data = 1, offset = 32, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(12, 0, 32, 1)
        await self.modifyRegBits(12, 1, 33, 1)
            # Set start address
        await self.modifyRegBits(2, 0x1fe0, 44, 20)
        # Set Stop Address
        await self.modifyRegBits(4, 0x1fff, 32, 20)

        await self.modifyRegBits(addr = 2, data = 0, offset = 32, bit_num = 1)
        await self.modifyRegBits(addr = 2, data = 0, offset = 43, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 1, offset = 54, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break

        # bist_start = 0
        await self.modifyRegBits(12, 0, 31, 1)
        await self.modifyRegBits(12, 0, 32, 1)
        await self.modifyRegBits(12, 1, 33, 1)
            # Set start address
        await self.modifyRegBits(2, 0x1fe0, 44, 20)
        # Set Stop Address
        await self.modifyRegBits(4, 0x1fff, 32, 20)
        await self.modifyRegBits(3, 0xffffffffffffffff, 0, 64)
        await self.modifyRegBits(2, 0x7fff, 16, 15)

        await self.modifyRegBits(addr = 2, data = 0, offset = 32, bit_num = 1)
        await self.modifyRegBits(addr = 2, data = 0, offset = 43, bit_num = 1)
        await self.modifyRegBits(addr = 0, data = 1, offset = 54, bit_num = 1)
        # bist_start = 1
        await self.modifyRegBits(12, 1, 31, 1)
        while True:
            busy_signal = await self.get_busy()
            if busy_signal == 0:
                break


    async def LiveCheck_check(self):
        pass

    # Basic Test Setup
    async def BasicReadWrite_initialize(self):
        self.disable_write = 0
        self.disable_read = 0
        self.addr_mode = 0
        self.data_mode = 0
        self.flipOdd = 0
        await self.reg.bist_registers.INCR_COUNT.write(self.incr_count)
        await self.reg.bist_registers.START_ADDRESS.write(self.get_start_address())
        await self.reg.bist_registers.ADDRESS_LENGTH.write(
            (self.stop_address - self.start_address)//self.incr_count
        )
        pass

    @printio
    async def BasicReadWrite_run(self):
        print("Running this test now")
        pass
        # rv = await self.reg.bist_registers.CHIPID.read()
        # cocotb.log.info(f"rv={rv}")
        # assert rv == 0xcab0, f"{self.testname}: BasicReadWrite Failed"

    async def BasicReadWrite_check(self):
        while True:
            await Timer(100, "ns")
            rd = await self.reg.bist_registers.BIST_STATUS.read_fields()
            if rd["busy"] == 0:
                break

        await self.BistHasError(0)
        await Timer(1, "us")

    # Retention Test Setup

    async def Retention_initialize(self):
        self.walking = 0
        self.endurance_mode = 0
        self.flipOdd = 0
        self.disable_read = 0
        self.disable_write = 0
        self.neighbor_noise = 0
        self.reg.bist_registers.Read_Delay.count.write(random.randint(1, 50))

    @printio
    async def Retention_run(self):
        rd = await self.reg.bist_registers.BIST_STATUS.read_fields()
        cocotb.log.info(rd)
        while rd["busy"]:
            await Timer(100, "ns")
            rd = await self.reg.bist_registers.BIST_STATUS.read_fields()

    async def Retention_check(self):
        await self.BistHasError(0)
        pass

    # Reliability Test Setup

    async def Reliability_initialize(self):
        self.disable_read = 0
        self.disable_write = 0
        self.endurance_mode = 0
        self.walking = 0
        self.neighbor_noise = 0
        self.retention_mode=0
        self.flipOdd=0
        await self.reg.bist_registers.Loop_Repeat.count.write(random.randint(100, 1000))
        await self.reg.bist_registers.Address_Repeat.count.write(
            random.randint(100, 1000)
        )
        await self.reg.bist_registers.ADDRESS_LENGTH.write(1)

    @printio
    async def Reliability_run(self):
        pass

    async def Reliability_check(self):
        await self.BistHasError(0)
        pass

    # Walking Test Setup

    @printio
    async def Walking_initialize(self):
        self.walking = 1
        self.endurance_mode = 0
        self.flipOdd = 0
        self.addr_mode = 0
        self.data_mode = 0
        if self.walking_bit and self.data_shift_dir:  # Walking 1 shift right
            await self.reg.bist_registers.DATA.write(1 << 31)
        elif not self.walking_bit and self.data_shift_dir:  # Walking 0 shift right
            await self.reg.bist_registers.DATA.write(0x7FFFFFFF)
        elif self.walking_bit and not self.data_shift_dir:  # Walking 1 shift left
            await self.reg.bist_registers.DATA.write(0x1)
        elif not self.walking_bit and not self.data_shift_dir:  # Walking 0 shift left
            await self.reg.bist_registers.DATA.write(0xFFFFFFFE)
        else:
            assert 0, f"{self.testname}: WALKING Init Failed"

        pass

    @printio
    async def Walking_run(self):
        pass

    async def Walking_check(self):
        await self.BistHasError(0)
        pass

    # Template Test Setup

    async def template_initialize(self):
        pass

    @printio
    async def template_run(self):
        pass

    async def template_check(self):

        await self.BistHasError(0)
        pass


@CoverPoint('top.txn.write', xf=lambda txn: txn['write'],
            bins=[True, False])
@CoverPoint('top.txn.read', xf=lambda txn: txn['read'],
            bins=[True, False])
@CoverCross('top.txn.rdwr', items=['top.txn.read', 'top.txn.write'])
def cover_txn(txn):
    pass


@CoverPoint('top.name', xf=lambda test: test['name'],
            bins=TestMode._member_names_)
@CoverPoint('top.address_mode', xf=lambda test: test['address_mode'],
            bins=[0, 1]
            )
@CoverPoint('top.data_mode', xf=lambda test: test['address_mode'],
            bins=[0, 1]
            )
@CoverCross('top.testcfg',
            items=['top.name', 'top.address_mode', 'top.data_mode'])
def cover(test):
    pass
