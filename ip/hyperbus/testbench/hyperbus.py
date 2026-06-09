import cocotb
import os
from cocotbext.axi import AxiBus, AxiSlave, MemoryRegion
from cocotb.handle import Force, Release
from cocotb.triggers import Timer, Lock, RisingEdge, Event
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db
import random


def match_rd_sb(actual, rd_sb):
    cocotb.log.info("match_rd_sb called")
    expected = rd_sb.pop(0)
    assert hex(actual) == hex(
        expected), f"Error: Expected Data {hex(expected)} did not match data from axi {hex(actual)}"


@cocotb.test()
async def test_hyperbu(dut):
    cocotb.log.info("Hyperbus test env")
    sb = []
    rd_sb = []
    mmio = MMIO(rd_sb)
    hc = HyperCtrlDriver(dut, "", dut.i_clk,
                         callback=lambda x: match_rd_sb(x, rd_sb))
    axi_slave = AxiSlave(AxiBus.from_prefix(dut.hyperram, ""), clock=dut.o_clk,
                         reset=dut.o_resetn, target=mmio, reset_active_level=False)
    cocotb.start_soon(check_sb(mmio.ev_axi, sb))
    # dut.o_csn0.value=Force(0)
    await Timer(1, "us")
    for i in range(100):
        txn = {}
        txn['isCfg'] = random.choice([True, False])
        txn['isWrite'] = random.choice([True, False])
        txn['address'] = ((random.randint(0, 0xffffffff)//8)*8)
        txn['wdata'] = random.randint(0, 0xfffffff0)
        cocotb.log.info(f"Appending Transaction {txn}")
        sb.append(txn.copy())
        await hc.send(txn)
        cover(txn)
    await Timer(100, "us")
    assert len(sb) == 0, "Error Scoreboard not Empty"
    assert len(rd_sb) == 0, "Error Read Scoreboard not Empty"
    coverage_db.report_coverage(cocotb.log.info, bins=True)
    coverage_file = os.path.join(
        os.getenv('RESULT_PATH', "./"), 'coverage.xml')
    coverage_db.export_to_xml(filename=coverage_file)
    # dut.o_csn0.value=Release()


async def check_sb(mmio_ev, sb):
    while (1):
        await mmio_ev.wait()
        txn = mmio_ev.data
        cocotb.log.info(f"sb_match {txn} sb={sb}")
        expected = sb.pop(0)
        if expected['isCfg']:
            expected['address'] = expected['address'] | 0x5000
        assert hex(txn['address']) == hex(
            expected['address']), f"Error: Address Mismatch actual={hex(txn['address'])} == {hex(expected['address'])}"
        cocotb.log.info("sb_match 2")
        if not txn['isWrite']:
            assert expected['isWrite'] == False, "Error: Not expecting a write Transaction"
        cocotb.log.info("sb_match Done")
        mmio_ev.clear()


class MMIO:
    def __init__(self, rd_sb):
        self.rd_sb = rd_sb
        self.ev_axi = Event()

    def sb_match(self, address, length, data, isWrite):
        txn = {'address': address, 'length': length,
               'data': data, 'isWrite': isWrite}
        cocotb.log.info(f"MMIO:sb_match {txn}")
        self.ev_axi.set(txn)

    async def read(self, address, length):
        cocotb.log.info(f"MMIO:Reading {address}, {length}")
        rv = random.randint(0, 0xffffffff)
        self.sb_match(address, length, rv, False)
        self.rd_sb.append(rv)
        cocotb.log.info(f"MMIO:rdsb is now {self.rd_sb}")
        return rv.to_bytes(4, "little")

    async def write(self, address, data):
        self.sb_match(address, 4, data, True)
        cocotb.log.info(f"MMIO: Writing {address} {data}")
        pass


class HyperCtrlDriver(BusDriver):
    _signals = 'i_cfg_access i_mem_wstrb i_mem_addr i_mem_wdata i_mem_valid o_mem_ready o_mem_rdata'.split()

    def __init__(self, dut, prefix, clock, callback=None, generator=None):
        BusDriver.__init__(self, dut, prefix, clock)
        self.bus_lock = Lock("%s_txn" % prefix)
        self.callback = callback
        # TODO Initialize input signals self.bus.tag.setimmediatevalue(1)
        self.bus.i_cfg_access.setimmediatevalue(0)
        self.bus.i_mem_wstrb.setimmediatevalue(0)
        self.bus.i_mem_addr.setimmediatevalue(0)
        self.bus.i_mem_wdata.setimmediatevalue(0)
        self.bus.i_mem_valid.setimmediatevalue(0)

    def start(self, generator=None):
        pass

    def stop(self):
        pass

    async def _driver_send(self, txn, sync=True):
        await self.bus_lock.acquire()
        self.log.info(f"HyperCtrlDriver: Driving Transaction {txn}")
        # TODO Wait for some gate keeper signal before driving values.
        self.bus.i_cfg_access.value = txn['isCfg']
        self.bus.i_mem_wstrb.value = 0xf if txn['isWrite'] else 0
        self.bus.i_mem_addr.value = txn['address']
        if txn['isWrite']:
            self.bus.i_mem_wdata.value = txn['wdata']
        self.bus.i_mem_valid.value = 1
        await RisingEdge(self.clock)
        self.bus.i_mem_valid.value = 0
        self.log.debug("HyperCtrlDriver: Checking Grant ")
        if not self.bus.o_mem_ready.value:
            await RisingEdge(self.bus.o_mem_ready)
        await RisingEdge(self.clock)
        if not txn['isWrite']:
            cocotb.log.info("Calling callback")
            self.callback(self.bus.o_mem_rdata.value.integer)
        await RisingEdge(self.clock)
        self.bus_lock.release()


@CoverPoint("txn.Reg", bins=[True, False], xf=lambda txn: txn['isCfg'])
@CoverPoint("txn.Write", bins=[True, False], xf=lambda txn: txn['isWrite'])
@CoverCross("txn.Reg_vs_Write", items=["txn.Reg", "txn.Write"])
def cover(txn):
    pass
