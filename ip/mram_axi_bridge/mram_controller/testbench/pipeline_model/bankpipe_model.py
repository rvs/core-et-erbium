import cocotb
import random

from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
from cocotbext.axi import AxiBus, AxiMaster
from cocotb.binary import BinaryValue
from cocotb.handle import Force

import math

import secrets

class ErbiumBank:
    def __init__(self, dut):
        self.dut  =  dut

    def set_rst(self, value:int):
        self.dut.rst_b_i.value  =  value & 0x1

    def set_ce(self, addr:int=None, pipelined:bool=True):
        if addr is None:
            ce_indx      =  0
        elif pipelined:
            shift_amnt   =  addr & 0x6
            ce_indx      =  0b1  <<  shift_amnt
            ce_indx     |=  0b1  << (shift_amnt + 1)
        else:
            shift_amnt   =  addr & 0x7
            ce_indx      =  0b1  <<  shift_amnt
        self.dut.ce_i.value  =  ce_indx

    def set_we(self, value:int):
        self.dut.we_i.value     =  value & 0x1

    ##def set_stripe_sel(self, value:int, stripe_index_mode:bool=True):
    ##    if stripe_index_mode:
    ##        self.dut.stripe_sel_i.value  =  value & 0xF
    ##    else:
    ##        self.dut.stripe_sel_i.value  =  0x1 << (value & 0x3)

    def set_addr(self, addr:int):
        self.dut.addr_i.value  =  (addr & 0xF_FFF8) >> 3

    def set_din(self, value:int):
        self.dut.din_i.value      =  value & 0xFFFF_FFFF_FFFF_FFFF

    def set_bwe(self, value:int):
        self.dut.bwe_i.value      =  value & 0xFFFF_FFFF_FFFF_FFFF

    ##def set_legacy_access_enable(self, value:int):
    ##    self.dut.legacy_access_enable_i.value  =  value & 0b1

    def set_dout_en(self, addr:int=None, pipelined:bool=True):
        if addr is None:
            dout_en_indx   =  0
        elif pipelined:
            shift_amnt     =  addr & 0x6
            dout_en_indx   =  0b1  <<  shift_amnt
            dout_en_indx  |=  0b1  << (shift_amnt + 1)
        else:
            shift_amnt     =  addr & 0x7
            dout_en_indx   =  0b1  <<  shift_amnt
        self.dut.dout_en_i.value  =  dout_en_indx
        
    def get_dout(self) -> int:
        ret_value  =  self.dut.dout_o.value & 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
        return ret_value 
    
    def get_busy(self) -> int:
        return(self.dut.busy_o.value & 0xFF)
    
    def initialize_clock(self):
        print("INFO : Initializing clock.", flush=True)
        cocotb.start_soon(Clock(self.dut.clk_i, 1, units="ns").start())

    async def clk_rising(self, value:int=1, clk_margin:int=250):
        for _ in range(value):
            await RisingEdge(self.dut.clk_i)
        await Timer(clk_margin, units='ps')

    async def clk_falling(self, value:int=1, clk_margin:int=250):
        for _ in range(value):
            await FallingEdge(self.dut.clk_i)
        await Timer(clk_margin, units='ps')

    async def busy_rising(self, value:int=1):
        for _ in range(value):
            await RisingEdge(self.dut.busy_o)

    def poll_busy(self, addr:int, pipelined:bool=True) -> bool:
        if pipelined:
            shift_amnt  =  addr  &  0x6
            busy_mask   =  0b1 << shift_amnt
            busy_mask  |=  0b1 << (shift_amnt + 1)
        else:
            shift_amnt  =  addr  &  0x7
            busy_mask   =  0b1 <<  shift_amnt
        busy  =  self.get_busy()
        #print(f"POLL : ADDR:{addr:06x} | BUSY:{busy:08b} | MASK:{busy_mask:08b}")
        return  False if ((busy & busy_mask) == 0) else True

    async def busy_falling(self, addr:int, timeout:int=50, pipelined:bool=True) -> int:
        timeout_count = 0
        while (self.poll_busy(addr, pipelined) and (timeout_count < timeout)):
            await self.clk_falling()
            timeout_count += 1
            if timeout_count == timeout:
                print("Waiting for busy :  Timed out.")
        return timeout_count

    async def no_op(self, value:int, position_at_falling:bool=True):
        self.set_ce()
        await self.clk_rising(value)
        if position_at_falling:
            await self.clk_falling(1)
        await Timer(250, units="ps")

    def set_mem_clk_en(self, value:int):
        self.dut.mem_clk_en_i.value  =  value & 0b1

    async def write(self, addr:int, data:int, bwe:int=0xFFFF_FFFF_FFFF_FFFF):
        self.set_mem_clk_en(0b1)
        await  self.clk_falling()
        self.set_addr(addr)
        self.set_ce(addr, pipelined=False)
        self.set_we(0b1)
        self.set_din(data)
        self.set_bwe(bwe)
        await self.clk_rising()
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        self.set_ce()
        self.set_we(0b0)
        timeout_count = await self.busy_falling(addr, pipelined=False)
        await self.clk_falling()
        #print(f"WRITE : BUSY_COUNT = {timeout_count}")
    
    async def get_data(self, address:int) -> int:
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        self.set_dout_en(address)
        await self.clk_rising(2)
        return_data  =  self.get_dout()
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        self.set_dout_en()
        return  return_data
  
    
    # async def read(self, stripe_sel:int, addr:int) -> int:
    #     self.set_addr(addr)
    #     self.set_ce(0b1)
    #     self.set_we(0b0)
    #     await self.clk_rising()
    #     await Timer(250, units="ps")
    #     self.set_ce(0b0)
    #     await self.busy_falling()
    #     await Timer(250, units="ps")
    #     return_value  =  self.get_dout()
    #     return(return_value)

    async def pipe_read(self, addr:int, dout_addr:int=None) -> int:
        self.set_mem_clk_en(0b1)
        await self.clk_falling()
        self.set_addr(addr)
        self.set_ce(addr)
        self.set_we(0b0)
        if dout_addr is not None:
            self.set_dout_en(dout_addr)
            await self.clk_falling()
            self.set_dout_en()
            self.set_ce()
            self.set_addr(0x0)
            self.set_we(0b0)
            await self.clk_rising()
            return_data = self.get_dout()
        else:
            self.set_dout_en()
            await self.clk_rising()
            return_data = None
        self.set_mem_clk_en(0b0)
        await self.clk_falling()
        self.set_ce()
        self.set_addr(0x0)
        self.set_we(0b0)
        timeout_count = await self.busy_falling(addr)
        await self.clk_falling()
        #print(f"READ : BUSY_COUNT = {timeout_count}")
        return(return_data)

class TB:
    def __init__(self, dut):
        self.set_dut(dut)
        self.bank           =  ErbiumBank(self.dut)
        self.reset_cycles   =  5

    def set_dut(self, dut):
        print("INFO : Setting DUT.", flush=True)
        self.dut = dut

    def initialize_clock(self):
        self.bank.initialize_clock()

    async def reset_sequence(self):
        print("INFO : Performing reset.", flush=True)
        self.bank.set_rst(0)
        await Timer(10, units="ns")
        self.bank.set_mem_clk_en(0b1)
        self.bank.set_rst(0)
        self.bank.set_dout_en()
        self.bank.set_ce()
        self.bank.set_we(0)
        self.bank.set_addr(0x0)
        self.bank.set_din(0x0)
        self.bank.set_bwe(0xFFFF_FFFF_FFFF_FFFF)
        await self.bank.clk_rising(self.reset_cycles+1)
        self.bank.set_rst(1)
        self.bank.set_mem_clk_en(0b0)
        await self.bank.clk_falling(2)

    async def setup_tb(self):
        print("INFO : Setting up testbench.", flush=True)
        self.bank.set_rst(0)
        self.initialize_clock()
        await self.bank.clk_rising()
        await self.bank.clk_falling()

@cocotb.test()
async def test_instance(dut):

    my_tb  =  TB(dut)
    await my_tb.setup_tb()
    await my_tb.reset_sequence()

    for reserve in range(2):
        if reserve == 1:
            max_rows = 13
        else:
            max_rows = 512
        for stripe in range(4):
            for instance in range(2):
                for plane in range(8):
                    print(f"Initializing Stripe:{stripe:01X}|INST:{instance:01b}|plane {plane:01X}")
                    for row in range(max_rows):
                        for column in range(16):
                            reserve_addr  =  (reserve  & 0b1   ) << 19
                            plane_addr    =  (plane    & 0b111 ) << 16
                            row_addr      =  (row      & 0x1FF ) <<  7
                            col_addr      =  (column   & 0xF   ) <<  3
                            inst_addr     =  (instance & 0b1   ) <<  2
                            stripe_addr   =  (stripe   & 0b11  ) <<  0
                            addr  =  reserve_addr | plane_addr | row_addr | col_addr | inst_addr | stripe_addr
                            #print(f"Writing --> STRIPE:{stripe:01X}|INST:{instance:01X}|PLANE{plane:01X}|RESERVE:{reserve:01b}|ROW:{row:03X}|COL:{column:01X}")
                            data  =  (0xFACE_ABCD_0000_0000 | (stripe  << 28) | (instance << 24) | (plane << 20) | (reserve << 16) | (row << 4) | column)
                            await my_tb.bank.write(addr, data)


    prev_address   =  None
    prev_reserve    = None
    prev_stripe     = None
    prev_instance   = None
    prev_plane      = None
    prev_row        = None
    prev_column     = None
    test_pass  =  True
    for read_index in range(1000):
        reserve       =  random.randint(0, 1)
        stripe        =  random.randint(0, 3)
        instance      =  random.randint(0, 1)
        plane         =  random.randint(0, 7)
        if reserve == 1:
            row       =  random.randint(0, 12)
        else:
            row           =  random.randint(0, 511)
        column        =  random.randint(0, 15)
        reserve_addr  =  (reserve  & 0b1   ) << 19
        plane_addr    =  (plane    & 0b111 ) << 16
        row_addr      =  (row      & 0x1FF ) <<  7
        col_addr      =  (column   & 0xF   ) <<  3
        inst_addr     =  (instance & 0b1   ) <<  2
        stripe_addr   =  (stripe   & 0b10  ) <<  0
        address       =  reserve_addr | plane_addr | row_addr | col_addr | inst_addr | stripe_addr
        result  =  await my_tb.bank.pipe_read(address, prev_address)
        if result is not None:
            exp_data_low    =  0xFACE_ABCD_0000_0000 | ((prev_stripe & 0b10) << 28) | (prev_instance << 24)
            exp_data_low   |=  (prev_plane << 20)    | (prev_reserve << 16)         | (prev_row << 4)       | prev_column
            exp_data_high   =  0xFACE_ABCD_0000_0000 | ((prev_stripe | 0b1)  << 28) | (prev_instance << 24)
            exp_data_high  |=  (prev_plane << 20)    | (prev_reserve << 16)         | (prev_row << 4)       | prev_column
            exp_data        =  exp_data_low | (exp_data_high << 64)
            compare_expect  =  result ^ exp_data
            if compare_expect == 0:
                pass_fail   =  "P"
            else:
                pass_fail   =  "F"
                test_pass   =  False
            print(f"Reading --> STRIPE:{prev_stripe:01X}", end="")
            print(f"|INST:{prev_instance:01X}",            end="")
            print(f"|PLANE:{prev_plane:01X}",              end="")
            print(f"|RESERVE:{prev_reserve:01b}",          end="")
            print(f"|ROW:{prev_row:03X}",                  end="")
            print(f"|COL:{prev_column:01X}",               end="")
            print(f"|ADDR:{prev_address:05_X}",            end="")
            print(f"|VALUE:{result:032_X}:",               end="")
            print(f":{exp_data:032_X}:",                   end="")
            print(f":{compare_expect:032_X}:",             end="")
            print(f":{pass_fail}")
        prev_address   = address
        prev_reserve   =  reserve
        prev_stripe    =  stripe
        prev_instance  =  instance
        prev_plane     =  plane
        prev_row       =  row
        prev_column    =  column

    result  =  await my_tb.bank.get_data(prev_address)
    if result is not None:
        exp_data_low    =  0xFACE_ABCD_0000_0000 | ((prev_stripe & 0b10) << 28) | (prev_instance << 24)
        exp_data_low   |=  (prev_plane << 20)    | (prev_reserve << 16)         | (prev_row << 4)       | prev_column
        exp_data_high   =  0xFACE_ABCD_0000_0000 | ((prev_stripe | 0b1) << 28)  | (prev_instance << 24)
        exp_data_high  |=  (prev_plane << 20)    | (prev_reserve << 16)         | (prev_row << 4)       | prev_column
        exp_data        =  exp_data_low | (exp_data_high << 64)
        compare_expect  =  result ^ exp_data
        if compare_expect == 0:
            pass_fail  =  "P"
        else:
            pass_fail  =  "F"
            test_pass  =  False
        print(f"Reading --> STRIPE:{prev_stripe:01X}", end="")
        print(f"|INST:{prev_instance:01X}",            end="")
        print(f"|PLANE:{prev_plane:01X}",              end="")
        print(f"|RESERVE:{prev_reserve:01b}",          end="")
        print(f"|ROW:{prev_row:03X}",                  end="")
        print(f"|COL:{prev_column:01X}",               end="")
        print(f"|ADDR:{prev_address:05_X}",            end="")
        print(f":{exp_data:032_X}:",                   end="")
        print(f":{compare_expect:032_X}:",             end="")
        print(f":{pass_fail}")

    await my_tb.bank.no_op(5)

    print(f"TEST {'PASSED' if test_pass else 'FAILED'}")

