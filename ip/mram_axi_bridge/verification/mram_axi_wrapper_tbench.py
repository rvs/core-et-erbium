import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
from cocotbext.axi import AxiBus, AxiMaster

import random

from cocotbext.axi import AddressSpace, SparseMemoryRegion
from cocotbext.axi import AxiBus, AxiLiteMaster, AxiSlave, AxiLiteBus
import random
import secrets

class TB:
    def __init__(self):
        pass

    def set_dut(self, dut):
        self.dut = dut.dut

    def initialize_clock(self):
        cocotb.start_soon(Clock(self.dut.clk, 4, units="ns").start())

    def create_axi_master(self):
        self.axi_master = AxiMaster(AxiBus.from_prefix(self.dut, "s_axi"), self.dut.clk, self.dut.rst_b, reset_active_level=False)

    async def reset_sequence(self):
        self.dut.rst_b.value = 1
        self.dut.mram_rst_b.value = 1
        await Timer(10, units="ns")
        self.dut.mram_rst_b.value = 0
        self.dut.rst_b.value = 0
        await Timer(10, units="ns")
        self.dut.mram_rst_b.value = 1
        self.dut.rst_b.value = 1
        await Timer(10, units="ns")

    def setup_tb(self):
        self.initialize_clock()
        self.create_axi_master()
        self.initialize_signals()

    def initialize_signals(self):
        self.dut.clk.value = 0
        self.dut.rst_b.value = 0
        self.dut.mram_rst_b.value = 0
        self.dut.dsleep.value = 0
        self.dut.nvsram_startup_bypass.value = 1

        self.dut.MRAM_PADDR.value = 0
        self.dut.MRAM_PENABLE.value = 0
        self.dut.MRAM_PSEL.value = 0
        self.dut.MRAM_PSTRB.value = 0
        self.dut.MRAM_PWDATA.value = 0
        self.dut.MRAM_PWRITE.value = 0

        self.dut.tp_add.value = 0
        self.dut.tp_bwe.value = 0
        self.dut.tp_ce.value = 0
        self.dut.tp_din.value = 0
        self.dut.tp_we.value = 0

    async def read_mram(self, address, bytes):
        await cocotb.triggers.with_timeout(self.axi_master.read(address, bytes), 100, 'ns')

my_tb = TB()
@cocotb.test()
async def basic_read_write(dut):
    """Performing a set of AXI reads and writes to the MRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    axi_master = my_tb.axi_master
    saved_values = bytes()
    max_address_range = 2 ** 10
    size_list = [0, 1, 2, 3]
    for addr in range(max_address_range):
        value = random.randrange(2 ** 64)
        await cocotb.triggers.with_timeout(axi_master.write(addr << 3, value.to_bytes(8, 'little')), 100, 'ns')
        saved_values += value.to_bytes(8, 'little')

    for reads in range(100):
        address = random.randrange(max_address_range)
        length = random.randrange(8) + 1
        read_op = axi_master.init_read(address, length, size=random.choice(size_list))
        await read_op.wait()
        assert read_op.data.data == saved_values[address:address+length]

    await Timer(1000, units="ns")

    # await write_op.wait()
@cocotb.test()
async def read_write_each_stripe(dut):
    """Performing a set of AXI reads and writes to the MRAM."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    n_wrappers = int(dut.dut.NUM_MRAM_WRAPPERS.value)

    stripe_start_stop = []
    for stripe in range(n_wrappers * 4):
        start_addr = stripe * 1024 * 8 * 16 * 8
        stop_addr = (stripe + 1) * 1024 * 8 * 16 * 8 - 1
        stripe_start_stop.append([start_addr, stop_addr])
    await my_tb.reset_sequence()
    axi_master = my_tb.axi_master

    for i, [start, stop] in enumerate(stripe_start_stop):
        print(f"Running on stripe: {i},start-{start}")
        saved_values = bytes()
        max_address_range = 2 ** 10
        size_list = [0, 1, 2, 3]
        for addr in range(max_address_range):
            value = random.randrange(2 ** 64)
            await cocotb.triggers.with_timeout(axi_master.write((addr << 3) + start, value.to_bytes(8, 'little')), 100, 'ns')
            saved_values += value.to_bytes(8, 'little')

        for reads in range(100):
            address = random.randrange(max_address_range)
            length = random.randrange(8) + 1
            read_op = axi_master.init_read(address + start, length, size=random.choice(size_list))
            await read_op.wait()
            assert read_op.data.data == saved_values[address:address+length]

    await Timer(1000, units="ns")

@cocotb.test()
async def basic_read_write_burst(dut):
    """Verifying the BURST feature on AXI reads and writes. Also employing different word write sizes."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    axi_master = my_tb.axi_master
    saved_values = bytes()
    max_address_range = 2 ** 10
    size_list = [0, 1, 2, 3]
    for addr in range(max_address_range):
        value = random.randrange(2 ** 64)
        saved_values += value.to_bytes(8, 'little')

    start_address = 0
    while start_address < max_address_range << 3:
        number_of_bytes = random.randrange(0, 256) + 1
        if number_of_bytes + start_address > (max_address_range << 3):
            number_of_bytes = (max_address_range << 3) - start_address
        word_size = random.choice(size_list)

        await axi_master.write(start_address, saved_values[start_address:start_address+number_of_bytes], size=word_size)
        start_address += number_of_bytes

    for reads in range(1000):
        length = random.randrange(8, 256) + 1
        address = random.randrange(max_address_range - length)
        read_op = axi_master.init_read(address, length, size=random.choice(size_list))
        await read_op.wait()
        assert read_op.data.data == saved_values[address:address+length]
    await cocotb.triggers.with_timeout(axi_master.read(0x0000, 8), 100, 'ns')

    # await write_op.wait()

@cocotb.test()
async def random_read_write_accesses(dut):
    """Performing a random sequence of read and write accesses of varying burst lengths and sizes."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    axi_master = my_tb.axi_master
    saved_values = bytearray()
    max_address_range = 2 ** 10
    size_list = [0, 1, 2, 3]

    # Initializing the range.
    for addr in range(max_address_range):
        read_op = axi_master.init_read(addr << 3, 8, size=3)
        await read_op.wait()
        saved_values += bytearray(read_op.data.data)

    num_of_ops = 2000
    for op in range(num_of_ops):
        length = random.randrange(8, 256) + 1
        address = random.randrange((max_address_range << 3) - length - 1)
        op_choice = random.randrange(0, 2)
        if op_choice == 0:  # perform a read
            size_choice = random.choice(size_list)
            if (address % 4096) + length > 4095:
                # Cannot cross 4k boundary in burst mode.
                print(address, length)
                length = 4095 - address
                print(address, length)
            read_op = axi_master.init_read(address, length, size=size_choice)
            await cocotb.triggers.with_timeout(read_op.wait(), 10000, 'ns')
            if read_op.data.data != saved_values[address:address + length]:
                print(read_op.data.data.hex())
                print(saved_values[address:address + length].hex())

            assert read_op.data.data == saved_values[address:address+length]
        elif op_choice == 1:  # perform a write
            random_bytes = secrets.token_bytes(length)
            await axi_master.write(address, random_bytes)
            saved_values[address:address+length] = random_bytes

    # await write_op.wait()
