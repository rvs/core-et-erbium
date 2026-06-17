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

import os
import cocotb
from cocotb.triggers import Timer, RisingEdge, First, SimTimeoutError
from env import ETEnv as Env

@cocotb.test(timeout_time=9000, timeout_unit="ms")
async def test_elf(dut):

    env = Env(dut)

    # Disable Test Mode
    test_mode = int(os.environ["TEST_MODE"])
    cocotb.log.info(f"Setting TestMode to {test_mode}...")
    dut.TestMode.value = test_mode
    await Timer(10, unit="ns")

    # Load Bootrom is required
    boot_mode = None
    bootrom = os.environ["BOOTROM"]
    if bootrom:
        assert bootrom, "ELF Path not found. Make sure to pass it using TEST_ELF=..."
        cocotb.log.info(f"Going to load ELF ({bootrom}) ...")
        await env.load_elf(bootrom)
        await Timer(10, unit="ns")

        boot_mode = BootCfg.MRAM
        cocotb.log.info(f"Setting Boot mode... ({boot_mode.name})")
        await env.reset(program=False)
        await env.set_boot_mode(boot_mode, backdoor=False)
        await Timer(10, unit="ns")

    # Load the ELF
    elf_path = os.environ["TEST_ELF"]
    if not bootrom:
        assert elf_path, "ELF Path not found. Make sure to pass it using TEST_ELF=..."

    if elf_path:
        cocotb.log.info(f"Going to load ELF ({elf_path}) ...")
        await env.load_elf(elf_path)
        await Timer(10, unit="ns")

    cocotb.log.info("Waiting for reset...")
    await env.reset(program=False)

    if test_mode:
        cocotb.log.info("Disable all the Minions...")
        await env.disable_minions(backdoor=False)

        boot_addr = int( os.environ["BOOT_PC"], 16)
        cocotb.log.info(f"Overwriting Minion Boot PC to {hex(boot_addr)}")
        await env.set_minion_bootpc(boot_addr, backdoor=False)

        minion_mask = int( os.environ["MINION_MASK"], 16)
        thread_mask = int( os.environ["THREAD_MASK"], 16)
        cocotb.log.info(f"Enable Minions... (minion_mask={hex(minion_mask)}, thread_mask={hex(thread_mask)})")
        await env.enable_minions(minion_mask=minion_mask, thread_mask=thread_mask, backdoor=False)

        # Pull down warm reset
        await env.warm_reset(0)

    timeout = int(os.environ["TIMEOUT"])
    cocotb.log.info(f"Wait for minions to be done... (timeout={timeout}ns)")
    timer = Timer(timeout, unit="ns")
    cpu_done = RisingEdge(dut.cpu_done)

    finished = await First(cpu_done, timer)
    if finished is timer:
        raise SimTimeoutError(f"DUT Error: Test exceeded {timeout}ns without finishing")

    assert dut.cpu_done.value == 1 and dut.cpu_num_errors.value == 0

    if bootrom:
        mbox0 = await env.read_mailbox0()
        cocotb.log.info(f"MailBox0 value is {hex(mbox0)}")
        assert int(mbox0) == int(boot_mode.value), f"MailBox0 mismatch. Expected {hex(boot_mode.value)}, found {hex(mbox0)}."

    cocotb.log.info("*** TEST HAS PASSED *** \\    /\\ ")
    cocotb.log.info("*** TEST HAS PASSED ***  )  ( ')")
    cocotb.log.info("*** TEST HAS PASSED *** (  /  ) ")
    cocotb.log.info("*** TEST HAS PASSED ***  \\(__)| ")
    cocotb.log.info("***   PURRRRRFECT!   ***        ")
