from cocotbext.i2c import I2cMaster, I2cMemory
from cocotbext.axi import AxiLiteBus, AxiLiteSlave, MemoryRegion
import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock


async def reset(pin, clk):
    pin.value = 0
    await Timer(100, "ns")
    pin.value = 1
    await Timer(100, "ns")
    await RisingEdge(clk)
    pin.value = 0


@cocotb.test()
async def i2c_slv_test(dut):
    mmio = MMIO()
    i2c_master = I2cMaster(
        sda=dut.i2c_sda_o, sda_o=dut.i2c_sda_i,
        scl=dut.i2c_scl_o, scl_o=dut.i2c_scl_i, speed=400e3)
    AxiLiteSlave(AxiLiteBus.from_prefix(dut, "m_axil"),
                 dut.clk, dut.rst, target=mmio)

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    cocotb.start_soon(reset(dut.rst, dut.clk))
    await Timer(1, 'us')
    test_addr = b'\xaa\xbb\xcc\xdd'
    test_data = b'\xe1\xf1\xe2\xa2'
    await i2c_master.write(0x40, test_addr + test_data)
    await i2c_master.send_stop()
    await Timer(1, 'us')


class MMIO:
    async def write(self, address, data):
        assert hex(address) == hex(int.from_bytes(
            b'\xaa\xbb\xcc\xdd', byteorder="big")), "Address Mismatch"
        assert data == b'\xe1\xf1\xe2\xa2', "Data Mismatch"

    async def read(self, address, length):
        assert address == b'\xaa\xbb\xcc\xdc', "Address Mismatch"
        assert length == 4, "Length Mismatch"
