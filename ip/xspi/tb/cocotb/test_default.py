"""
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-03-04
 Description: A brief description of the file's purpose.
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

#addresses=[]
data=[]

def hb_burst_to_bytes(burstlen):
    return {
        0: 128,
        1: 64,
        2: 16,
        3: 32
    }[burstlen]

def get_safe_addr(addr, burstlen):
    hb_bytes = hb_burst_to_bytes(burstlen)

    # align to burst size (CRITICAL FIX)
    addr = addr & ~(hb_bytes - 1)

    offset = addr & 0xFFF
    remaining = 0x1000 - offset

    if hb_bytes > remaining:
        addr = addr & ~0xFFF   # align to 4KB boundary

    return addr #& 0xfffffff8

#for _ in range(50):
#    #addresses.append(random.randint(0,2**32)&0xfffffff8)
#    raw_addr = random.randint(0, 2**32)
#    safe_addr = get_safe_addr(raw_addr, burstlen=random.randint(0,2))
#    addresses.append(safe_addr)
#    data.append(random.randint(0,2**64))
data = [random.randint(0, 2**64) for _ in range(50)]

#data[0]=0xaaaaaaaaaaaaaaaa
#data[1]=0
#data[2]=0x12345678abcdef5a
#data[3]=0xaa55aa55aa55aa55
#data[4]=0xffffffffffffffff
modes=(
        (Mode.S1, Mode.S1, Mode.S1),
        (Mode.S1, Mode.D1, Mode.D1),
        (Mode.S4, Mode.D4, Mode.D4),
        (Mode.D4, Mode.D4, Mode.D4),
        (Mode.S8, Mode.S8, Mode.S8),
        (Mode.D8, Mode.D8, Mode.D8),
        )
#@cocotb.parametrize(latency=[random.randint(8,16) for _ in range(50)])
@cocotb.test(timeout_time=70110,timeout_unit="ns")
@cocotb.parametrize(mode=modes,latency=list(range(8,16)),burstlen=range(0,4),default_mode_pin=[1,2,3])
async def default_test(dut, mode, latency, burstlen,default_mode_pin):
    cocotb.log.info("Starting default test")
    dut.cfg_default_mode_m.value=default_mode_pin
    env=Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()


    # latency=random.randint(8,16)
    env.cmd.check_enables = False
    cocotb.log.info(f"setting latency to {latency}")
    await env.cmd.setLatency(latency)
    await env.cmd.setBurst(burstlen)
    assert int(dut.dut.latency_count.value) == latency
    #for mode in modes:
    await env.cmd.setRate(*mode)
    await regress(env, burstlen)

async def regress(env, burstlen):
    for i in range(5):
        cocotb.log.info(f"Iteration {i}")

        #data_bytes = data[i].to_bytes(8, "little")

        #  FIX: generate address per burstlen
        raw_addr = random.randint(0, 2**32)
        address = get_safe_addr(raw_addr, burstlen)

        cocotb.log.info(f"{address=:x}")

        hb_bytes = hb_burst_to_bytes(burstlen)

        num_beats = hb_bytes // 8
        
        # generate random data per beat
        beat_data_list = [random.getrandbits(64) for _ in range(num_beats)]
        
        # convert to bytes
        full_data = b''.join(d.to_bytes(8, "little") for d in beat_data_list)
        
        #  alignment check
        assert address % hb_bytes == 0, \
            f"Address not aligned: {hex(address)} size={hb_bytes}"

        cocotb.log.info("=" * 60)
        cocotb.log.info(f"BackDoor Write Read Test Iteration {i}")
        cocotb.log.info("=" * 60)
        #  write full burst data
        #full_data = data_bytes * (hb_bytes // 8)
        #env.axi_ram.write(address, list(full_data))

        # write full burst
        #full_data = data_bytes * (hb_bytes // 8)
        
        cocotb.log.info(f"AXI BACKDOOR WRITE addr={hex(address)} size={len(full_data)}")
        
        env.axi_ram.write(address, full_data)
        
        # debug check
        mem_check = env.axi_ram.read(address, len(full_data))
        cocotb.log.info(f"MEM CHECK FIRST BEAT = {hex(int.from_bytes(mem_check[:8], 'little'))}")
        
        # small delay (CRITICAL)
        #await Timer(1, units="ns")

        #  read
        rdata = await env.cmd.read_Mem(address)

        assert len(rdata) >= hb_bytes, \
            f"Read too small: {len(rdata)}" 

        #rdata_first = rdata[:8]
        #assert int.from_bytes(rdata_first, "little") == data[i]
        # Split burst into 8-byte beats
        rdata_beats = [rdata[j:j+8] for j in range(0, len(rdata), 8)]
        

        for idx, beat in enumerate(rdata_beats):
            val = int.from_bytes(beat, "little")
            exp = beat_data_list[idx]
        
            cocotb.log.info(f"READ BEAT[{idx}] = {hex(val)} EXPECTED = {hex(exp)}")
        
            assert val == exp, f"Mismatch at beat {idx}: got {hex(val)} expected {hex(exp)}" 
        
