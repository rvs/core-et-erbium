
import cocotb
from cocotbext.axi import AxiMaster,AxiBus,AxiLiteRam, AddressSpace, PeripheralRegion, SparseMemoryRegion, AxiLiteSlave, AxiLiteMaster, AxiLiteBus
from cocotb.triggers import RisingEdge,Timer, NextTimeStep
from cocotb.clock import Clock
from HB_Reg.reg_model.HB_Reg import HB_Reg_cls
from HB_Reg.lib import AsyncCallbackSet
class Checker():
    exp=[]
    ram=SparseMemoryRegion(2**32)
    async def write(self,address,data):
        exp=self.exp.pop(0)
        cocotb.log.info(f"Checker {(address)}, {(data)},exp {exp}")
        await self.ram.write(address,data)
        assert data==exp,"Write data {data} does not match expected"
    async def read(self,address,length):
        cocotb.log.info(f"Checker {type(address)}, {type(length)}")
        return await self.ram.read(address,length)


class Env:
    def __init__(self,dut):
        cocotb.start_soon(Clock(dut.CLK_hb_clk,1,'ns').start())
        cocotb.start_soon(timeout(1,'ms'))
        bus=AxiBus.from_prefix(dut,"axi")
        self.axi=AxiMaster(bus,dut.clk,dut.rst_n,False)
        bus=AxiLiteBus.from_prefix(dut,"s_axil")
        self.axil=AxiLiteMaster(bus,dut.clk,dut.rst_n,False)
        addr_space=AddressSpace(size=2**32)
        self.reg = HB_Reg_cls(                                                                                                                                                                                                                                                                                                                                                          
          callbacks=AsyncCallbackSet(                                                                                                                                                                                                                                                                                                                                                 
             read_callback=self.regRead, write_callback=self.regWrite                                                                                                                                                                                                                                                                                                                
          )                                                                                                                                                                                                                                                                                                                                                                           
         )
        self.checker=Checker()
        pr=PeripheralRegion(obj=self.checker,size=2**32)
        addr_space.register_region(pr,0)
        rambus=AxiBus.from_prefix(dut,"hbslv")
        AxiLiteSlave(rambus, dut.hb_out_clk, dut.hb_out_resetn, target=addr_space,reset_active_level=False)
        self.intf=self.axil

    async def regRead(self, addr: int, width: int, accesswidth: int):                                                                                                                                                                                                                                                                                                                   
       cocotb.log.info(f"RegRead addr={addr:x} width={hex(width)}")                                                                                                                                                                                                                                                                                                             
       rv = await self.intf.read(addr,width//8)                                                                                                                                                                                                                                                                                                                                                 
       # cocotb.log.info(f"RegRead addr={addr:x} rdata={hex(rv.integer)}")                                                                                                                                                                                                                                                                                                             
       #return rv.integer                                                                                                                                                                                                                                                                                                                                                              
       return int.from_bytes(rv.data,"little")                                                                                                                                                                                                                                                                                                                                                                       
       pass                                                                                                                                                                                                                                                                                                                                                                            

    async def regWrite(self, addr: int, width: int, accesswidth: int, data: int):                                                                                                                                                                                                                                                                                                       
       cocotb.log.info(f"RegWrite, addr={hex(addr)} data={hex(data)}")                                                                                                                                                                                                                                                                                                               
       return await self.intf.write(addr, int.to_bytes(data,4,"little"))                                                                                                                                                                                                                                                                                                                                        
async def timeout(t,unit):
    await Timer(t,unit)
    assert 0, "Timeout error"
