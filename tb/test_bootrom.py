
from enum import Enum
import os
import cocotb
from cocotb.triggers import Timer, RisingEdge, First, SimTimeoutError
from env import ETEnv as Env

class BootCfg(Enum):
    DEEP_SLEEP     = 0x17C79F
    FW_UPDATE_SKIP = 0xFEF9F
    FW_UPDATE      = 0x1F9F
    PAYL_MRAM      = 0xFC79F
    EJMP_SRAM      = 0x3F
    EJMP_MRAM      = 0x35F
    FW_UPDATE_PC0  = 0x17EF9F

async def run_test(env, boot_mode, cold_reset=True, program_prcm=False):

    if cold_reset:
        await env.set_test_mode(0)
        await do_reset(env, program_prcm=program_prcm)
    else:
        await env.warm_reset(0)

    # Configure a TIMEOUT
    timeout = int(os.environ["TIMEOUT"])
    cocotb.log.info(f"Wait for minions to be done... (timeout={timeout}ns)")
    timer = Timer(timeout, unit="ns")
    cpu_done = RisingEdge(env.dut.cpu_done)

    finished = await First(cpu_done, timer)
    if finished is timer:
        raise SimTimeoutError(f"DUT Error: Test exceeded {timeout}ns without finishing")

    # Check or COSIM errors
    assert env.dut.cpu_done.value == 1 and env.dut.cpu_num_errors.value == 0

    # Check Mailbox0 value
    mbox0 = await env.read_mailbox0()
    cocotb.log.info(f"MailBox0 value is {hex(mbox0)}")
    assert int(mbox0) == int(boot_mode.value), f"MailBox0 mismatch. Expected {hex(boot_mode.value)}, found {hex(mbox0)}."

    # Print TEST PASS message
    cocotb.log.info("*** TEST HAS PASSED *** \\    /\\ ")
    cocotb.log.info("*** TEST HAS PASSED ***  )  ( ')")
    cocotb.log.info("*** TEST HAS PASSED *** (  /  ) ")
    cocotb.log.info("*** TEST HAS PASSED ***  \\(__)| ")
    cocotb.log.info("***   PURRRRRFECT!   ***        ")

async def load_bootrom(env):
    bootrom = os.environ["BOOTROM"]
    assert bootrom, "ELF Path not found. Make sure to pass it using TEST_ELF=..."
    cocotb.log.info(f"Going to load ELF ({bootrom}) ...")
    await env.load_elf(bootrom)
    await Timer(10, unit="ns")

async def load_payload(env):
    payload = os.environ["TEST_ELF"]
    assert payload, "ELF Path not found. Make sure to pass it using TEST_ELF=..."
    cocotb.log.info(f"Going to load ELF ({payload}) ...")
    await env.load_elf(payload)
    await Timer(10, unit="ns")

async def do_reset(env, program_prcm=False):
    cocotb.log.info("Waiting for reset...")
    await env.reset(program=program_prcm)

async def write_otp(env, addr, value, num_copies=5):
    MRAM_BASE = 0x40000000
    xspi_addr = addr - MRAM_BASE
    for i in range(0, num_copies):
        await env.write(xspi_addr + (i*8), 64, 64, value)

async def write_mram(env, addr, value, backdoor=False):

    if backdoor:
        await env.mem.write_data(addr, 8, value)
    else:
        MRAM_BASE = 0x40000000
        xspi_addr = addr - MRAM_BASE
        await env.write(xspi_addr, 64, 64, value)

    await Timer(10, unit="ns")

    read_val = await env.mem.read_data(addr, 8)
    assert read_val == value, f"Error: Backdoor read failed. For MEM[{hex(addr)}] expected is {hex(value)} but found {hex(read_val)}"

async def write_sram(env, addr, value):
    SRAM_BASE = 0x200C000
    xspi_addr = (addr - SRAM_BASE) + 0x4000C000
    await env.write(xspi_addr, 64, 64, value)
    await Timer(10, unit="ns")

WFI = 0x10500073

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test1(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # Normal cold boot
    await do_reset(env, program_prcm=True)
    await write_otp(env, 0x7FFFD000, 0) # no FW update
    await write_otp(env, 0x7FFFD028, 0) # osc=0 pmode=0

    await run_test(env, BootCfg.DEEP_SLEEP)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test2(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)
    await load_payload(env)

    # Firmware update skip → payload
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD000, 1) # FW update
    await write_otp(env,  0x7FFFD028, 0x80000000001FFFC0) # pmode=1
    await write_mram(env, 0x40000020, 0x40FFFFF0) # MRAM PAYLOAD SP
    await write_mram(env, 0x40000028, 0x40000200) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.FW_UPDATE_SKIP, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test3(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # Firmware update jump → payload
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD000, 1)          # FW update
    await write_mram(env, 0x40000010, 0x40FFFFF0) # MRAM FW SP
    await write_mram(env, 0x40000018, 0x40000200) # MRAM FW PC
    await write_mram(env, 0x40000200,        WFI) # MRAM PAYLOAD

    await run_test(env, BootCfg.FW_UPDATE, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test4(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)
    await load_payload(env)

    # Payload mode
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD028, 0x80000000001FFFC0) # pmode=1
    await write_mram(env, 0x40000020, 0x40FFFFF0) # MRAM PAYLOAD SP
    await write_mram(env, 0x40000028, 0x40000200) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.PAYL_MRAM, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test5(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # Early jump SRAM → payload
    await do_reset(env, program_prcm=True)
    await env.reg.system_registers.ChipMode.write(0x08) # bootload=01 (SRAM)
    await write_sram(env, 0x0200CFF0, 0x40FFFFF0) # SRAM PAYLOAD SP
    await write_sram(env, 0x0200CFF8, 0x0200C000) # SRAM PAYLOAD PC
    await write_sram(env, 0x0200C000,        WFI) # SRAM PAYLOAD

    await run_test(env, BootCfg.EJMP_SRAM, cold_reset=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test6(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)
    await load_payload(env)

    # Early jump MRAM → payload
    await do_reset(env, program_prcm=True)
    await env.reg.system_registers.ChipMode.write(0x10) # bootload=10 (MRAM)
    await write_mram(env, 0x40000000, 0x40FFFFF0) # MRAM PAYLOAD SP
    await write_mram(env, 0x40000008, 0x40000200) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.EJMP_MRAM, cold_reset=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test7(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)
    await load_payload(env)

    # Payload with 1 corrupt OTP_CFGR copy
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD028, 0x80000000001FFFC0, num_copies=4) # pmode=1
    await write_otp(env,  0x7FFFD048,                  0, num_copies=1) # CORRUPT
    await write_mram(env, 0x40000020, 0x40FFFFF0) # MRAM PAYLOAD SP
    await write_mram(env, 0x40000028, 0x40000200) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.PAYL_MRAM, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test8(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)
    await load_payload(env)

    # Payload with 2 corrupt OTP_CFGR copies
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD028, 0x80000000001FFFC0, num_copies=3) # pmode=1
    await write_otp(env,  0x7FFFD040,                  0, num_copies=1) # CORRUPT
    await write_otp(env,  0x7FFFD048,                  0, num_copies=1) # CORRUPT
    await write_mram(env, 0x40000020, 0x40FFFFF0) # MRAM PAYLOAD SP
    await write_mram(env, 0x40000028, 0x40000200) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.PAYL_MRAM, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test9(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # FWUP with 1 corrupt OTP_FWUP copy
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD000, 1, num_copies=4) # FW update
    await write_otp(env,  0x7FFFD020, 0, num_copies=1) # CORRUPT
    await write_mram(env, 0x40000010, 0x40FFFFF0) # MRAM FW SP
    await write_mram(env, 0x40000018, 0x40000200) # MRAM FW PC
    await write_mram(env, 0x40000200,        WFI) # MRAM PAYLOAD

    await run_test(env, BootCfg.FW_UPDATE, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test10(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # FWUP with 2 corrupt OTP_FWUP copies
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD000, 1, num_copies=3) # FW update
    await write_otp(env,  0x7FFFD018, 0, num_copies=1) # CORRUPT
    await write_otp(env,  0x7FFFD020, 0, num_copies=1) # CORRUPT
    await write_mram(env, 0x40000010, 0x40FFFFF0) # MRAM FW SP
    await write_mram(env, 0x40000018, 0x40000200) # MRAM FW PC
    await write_mram(env, 0x40000200,        WFI) # MRAM PAYLOAD

    await run_test(env, BootCfg.FW_UPDATE, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test11(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # Payload with 3 corrupt OTP_CFGR
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD028, 0x80000000001FFFC0, num_copies=2)
    await write_otp(env,  0x7FFFD038,                  0, num_copies=1) # CORRUPT
    await write_otp(env,  0x7FFFD040,                  0, num_copies=1) # CORRUPT
    await write_otp(env,  0x7FFFD048,                  0, num_copies=1) # CORRUPT

    await run_test(env, BootCfg.DEEP_SLEEP, program_prcm=False)

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def bootrom_test12(dut):
    env = Env(dut)
    await env.set_test_mode(1)
    await load_bootrom(env)

    # Firmware update skip → payload
    await do_reset(env, program_prcm=True)
    await write_otp(env,  0x7FFFD000, 1) # FW update
    await write_mram(env, 0x40000018, 0) # MRAM PAYLOAD PC

    await run_test(env, BootCfg.FW_UPDATE_PC0, program_prcm=False)
