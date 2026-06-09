import cocotb
from cocotb_bus.drivers import BusDriver
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, NextTimeStep, Lock


class VAPB(BusDriver):
    _signals = "psel,paddr,pwrite,penable,prdata,pwdata,pready".split(",")

    def __init__(self, entity, name, clock, generator=None):
        BusDriver.__init__(self, entity, name, clock)
        self.bus_lock = Lock("%s_txn" % name)
        self.dut = entity
        self.name = name
        self.clock = clock
        # TODO Initialize input signals self.bus.tag.setimmediatevalue(1)
        self.bus.psel.setimmediatevalue(0)
        self.bus.paddr.setimmediatevalue(0)
        self.bus.pwrite.setimmediatevalue(0)
        self.bus.penable.setimmediatevalue(0)
        self.bus.pwdata.setimmediatevalue(0)

    def start(self, generator=None):
        pass

    def stop(self):
        pass

    async def access_phase(self):
        self.log.debug("VAPB: Access State")
        self.dut.penable.value = 1
        await ReadOnly()
        while self.dut.pready.value != 1:
            self.log.debug("VAPB: Delay Phase")
            await FallingEdge(self.clock)
            await ReadOnly()
        rv = self.bus.prdata.value
        await FallingEdge(self.clock)
        self.dut.penable.value = 0
        self.dut.psel.value = 0
        return rv

    async def setup_phase(self, address):
        self.log.debug("VAPB: Setup State")
        self.dut.psel.value = 1
        self.dut.paddr.value = address
        await FallingEdge(self.clock)

    async def idle_phase(self, method, wdata):
        self.log.debug("VAPB:IDLE %s", method)
        self.bus.pwrite.value = method == "write"
        self.bus.pwdata.value = wdata
        await FallingEdge(self.clock)

    async def write(self, address, data):
        await self.bus_lock.acquire()
        await self.idle_phase("write", data)
        await self.setup_phase(address)
        await self.access_phase()
        self.bus_lock.release()
        return None

    async def read(self, address):
        await self.bus_lock.acquire()
        await self.idle_phase("Read", 0)
        await self.setup_phase(address)
        rv = await self.access_phase()
        self.bus_lock.release()
        return rv
