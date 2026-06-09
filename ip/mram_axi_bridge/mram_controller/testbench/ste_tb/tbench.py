import random

import cocotb
from cocotb.triggers import Timer, Edge, First, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
from tests import *
#import pydevd_pycharm
# https://blog.patfarley.org/pages/cocotb-pycharm.html
#pydevd_pycharm.settrace('localhost', port=9090, stdoutToServer=True, stderrToServer=True)

class func_holder:
    def __init__(self):
        pass

class TB:
    def __init__(self, dut=None):
        if dut is None:
            pass
        else:
            self.set_dut(dut)
        self.nvsram_complete = [False, False, False, False]
        self.sa_cal_complete = [False, False, False, False]

    def set_dut(self, dut):
        self.dut = dut

    def initialize_clock(self):
        cocotb.start_soon(Clock(self.dut.clk, 4, units="ns").start())

    def init_signals(self):
        self.dut.sa_cal_clk_i.value = 0
        self.dut.busy_sync_i.value = 0
        self.dut.dsleep_i.value = 1
        self.dut.pwr_ok_i.value = 0
        self.dut.rst_b.value = 0
        self.dut.mram_startup_bypass_i.value = 0
        self.dut.ste_ovr_sel_i.value = 0
        self.dut.sa_cal_en_ovr_i.value = 0
        self.dut.sa_cal_clk_ovr_i.value = 0
        self.dut.nvsram_en_ovr_i.value = 0
        self.dut.reg_logic_sup_sleep_ovr_i.value = 0

    async def reset_sequence(self):
        self.dut.rst_b.value = 0
        await Timer(10, units="ns")
        self.dut.rst_b.value = 1
        await Timer(10, units="ns")

    async def gen_sa_cal_clk_i(self, period, units='ns'):
        self.dut.sa_cal_clk_i.value = 0
        while True:
            await Timer(period / 2, units=units)
            if self.dut.cal_clk_en_o.value == 1:
                self.dut.sa_cal_clk_i.value = (self.dut.sa_cal_clk_i.value.integer + 1) % 2
            else:
                self.dut.sa_cal_clk_i.value = 0

    async def gen_nvsram_busy(self, def_start_time=None, def_busy_time=None, units="ps"):
        self.dut.busy_sync_i.value = 0
        while True:
            while True:
                await Edge(self.dut.nvsram_en_o)
                if ((self.dut.nvsram_en_o.value.binstr[0] == '1') |
                    (self.dut.nvsram_en_o.value.binstr[1] == '1') |
                    (self.dut.nvsram_en_o.value.binstr[2] == '1') |
                    (self.dut.nvsram_en_o.value.binstr[3] == '1')
                ):
                    for i in range(4):
                        if self.dut.nvsram_en_o.value.binstr[::-1][i] == '1':
                            self.dut._log.info(f"NVSRAM: Stripe {i} nvsram sequence started.")
                    break

            if def_start_time is None:
                start_time = random.randint(1000, 6000)
            else:
                start_time = def_start_time
            await Timer(start_time, units=units)
            self.dut.busy_sync_i.value = 1
            if def_busy_time is None:
                busy_time = random.randint(10000, 60000)
            else:
                busy_time = def_busy_time
            await Timer(busy_time, units=units)
            self.dut.busy_sync_i.value = 0
            if self.dut.nvsram_en_o.value.binstr[::-1][0] == '1':
                self.nvsram_complete[0] = True
                self.dut._log.info(f"NVSRAM: Stripe 0 nvsram sequence completed.")
            elif self.dut.nvsram_en_o.value.binstr[::-1][1] == '1':
                self.nvsram_complete[1] = True
                self.dut._log.info(f"NVSRAM: Stripe 1 nvsram sequence completed.")
            elif self.dut.nvsram_en_o.value.binstr[::-1][2] == '1':
                self.nvsram_complete[2] = True
                self.dut._log.info(f"NVSRAM: Stripe 2 nvsram sequence completed.")
            elif self.dut.nvsram_en_o.value.binstr[::-1][3] == '1':
                self.nvsram_complete[3] = True
                self.dut._log.info(f"NVSRAM: Stripe 3 nvsram sequence completed.")

    async def gen_stripe_sa_cal(self, stripe):
        while True:
            await Edge(self.dut.sa_cal_en_o)
            if ((self.dut.sa_cal_en_o.value.binstr[::-1][stripe] == '1')):
                self.dut._log.info(f"SA_CAL: Stripe {stripe} sa_cal_en started.")
                break
        # Await either the first clock or 3ns for the restq circuit to work.
        t1 = Edge(self.dut.sa_cal_clk_o)
        t2 = Timer(random.randint(2000, 5500), units='ps')
        await First(t1, t2)
        if ((self.dut.sa_cal_clk_o.value.binstr[::-1][stripe] == '1')):
            self.sa_cal_complete[stripe] = False
            self.dut._log.info(f"SA_CAL: sa_cal_clk came before qlatch could finish.")
            return
        cycle = 0
        while True:
            # Rising edge
            while True:
                await Edge(self.dut.sa_cal_clk_o)
                if ((self.dut.sa_cal_clk_o.value.binstr[::-1][stripe] == '1')):
                    break
            # Falling Edge
            while True:
                await Edge(self.dut.sa_cal_clk_o)
                if ((self.dut.sa_cal_clk_o.value.binstr[::-1][stripe] == '0')):
                    break
            cycle += 1
            self.dut._log.info(f"SA_CAL: Stripe {stripe} cycle {cycle} complete.")

            if cycle == 6:
                break
        self.sa_cal_complete[stripe] = True

    async def power_up(self):
        await Timer(10, units="ns")
        self.dut.dsleep_i.value = 0
        self.dut.rst_b.value = 1
        await Timer(100, units="ns")
        self.dut.pwr_ok_i.value = 1

    def setup_tb(self):
        self.init_signals()

