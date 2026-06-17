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

import cocotb
from cocotb.triggers import Timer, RisingEdge, with_timeout
import cocotb.result
import random

'''
Signal Reference
----------------
  dut.gpio_in[10:0]                          TB drives  -> DUT input pins
  dut.gpio_out[10:0]                         TB samples <- DUT output values (pad-level after mux)
  dut.gpio_out_ena[10:0]                         TB samples <- DUT output-enable (pad-level after mux)
  dut.et.erbium_digital.gpio_interrupt    TB samples <- aggregated 1-bit interrupt
  dut.TestMode                               TB samples <- HW mux select for GPIO[0]/OSC_CLK_OUT

'''
# --- Patch for float precision issue in cocotb ---
orig_timer_init = Timer.__init__
def patched_timer_init(self, time, *args, **kwargs):
    kwargs["round_mode"] = "round"
    orig_timer_init(self, time, *args, **kwargs)
Timer.__init__ = patched_timer_init
# -------------------------------------------------

from env import ETEnv

GPIO_MASK = 0x7FF
# Pin groups by controlling peripheral (from signals.md / system.rdl)
PINS_HW_MUX = [0]        # GPIO[0] -- OSC_CLK_OUT muxed by TestMode HW pin
PINS_I2C = [1, 2]        # SCL, SDA -- muxed by i2c_enable
PINS_SPI = [3, 4, 5, 6]  # CS, CLK, DQ[1:0] -- muxed by spi_enable (active at boot)
PINS_QSPI = [7, 8]       # SPI_DQ[3:2] -- muxed by qspi_enable
PINS_UART = [9, 10]      # TX, RX -- muxed by uart_enable

# def (val, num_bytes=4):
#     res = 0
#     for i in range(num_bytes):
#         b = (val >> (i * 8)) & 0xFF
#         res |= ((b << 1) & 0xFF) << (i * 8)
#     return res

def safe_int(logic_array):
    try:
        return logic_array.integer
    except ValueError:
        bin_str = logic_array.binstr.lower().replace('x', '0').replace('z', '0')
        return int(bin_str, 2)
        
async def wait_for_interrupt(dut, timeout_ns=500):
    try:
        await with_timeout(RisingEdge(dut.et.erbium_digital.gpio_interrupt), timeout_ns, "ns")
        return True
    except cocotb.result.SimTimeoutError:
        return False

async def _tb_init(dut) -> ETEnv:
    cocotb.log.info(f"RANDOM_SEED = {cocotb.RANDOM_SEED:#010x}")
    tb = ETEnv(dut, safe_callback=True)
    await tb.reset()
    tb.start()
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    return tb

@cocotb.test(timeout_time=5, timeout_unit="ms")
async def default_test(dut):
    tb = await _tb_init(dut)
    
    cocotb.log.info("Starting High-Level Robust GPIO & Interrupt Verification")

    # Wipe configurations, setting SystemConfig peripheral modes back to 0.
    # This gives us pure GPIO control over all 11 pins.
    await tb.reg.system_registers.SystemConfig.write(0x0)
    sys_config = await tb.reg.system_registers.SystemConfig.read()   
    cocotb.log.info(f"SystemConfig = {hex(sys_config)}")    
    
    # ---------------------------------------------------------
    # TEST: GPIO OUTPUTS
    # ---------------------------------------------------------
    cocotb.log.info("--- Testing GPIO as Output ---")
    
    # Enable all GPIOs as output 
    target_oe = 0x7FF 
    await tb.reg.system_registers.GPIO_OE.write((target_oe))
    await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
    # We clear interrupts while testing raw IO
    await tb.reg.system_registers.GPIO_Interrupt_Enable.write((0x0))
    await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Write")
    await RisingEdge(dut.et.system_clk)
    
    for i in range(0,11):
        target_out = 1 << i
        await tb.reg.system_registers.GPIO_O.write(target_out)
        await tb.assert_no_xspi_errors(msg="GPIO_O Write")
        await RisingEdge(dut.et.system_clk)
        await RisingEdge(dut.et.system_clk)
        
        gpio_o_read = await tb.reg.system_registers.GPIO_O.read()
        await tb.assert_no_xspi_errors(msg="GPIO_O Read")
        dut_gpio_out = safe_int(dut.et.gpio_o.value)
        
        assert gpio_o_read == target_out, f"GPIO_O Register mismatch for pin {i}: expected {hex(target_out)}, got {hex(gpio_o_read)}"
        assert (dut_gpio_out & target_out) == target_out, f"DUT gpio_o mismatch for pin {i}: expected 1 for pin. Full dut_gpio_out={hex(dut_gpio_out)}"
            
        cocotb.log.info(f"Verified GPIO {i} output = 1 successfully.")
        
        # Reset pin back to 0
        await tb.reg.system_registers.GPIO_O.write((0x0))
        await tb.assert_no_xspi_errors(msg="GPIO_O Write")
        await RisingEdge(dut.et.system_clk)
        await RisingEdge(dut.et.system_clk)
        
    print("\n" + "="*80)
    print("\n****************************GPIO Output Test Passed*******************************")
    print("\n" + "="*80)
    
    # ---------------------------------------------------------
    # TEST: GPIO INPUTS
    # ---------------------------------------------------------
    cocotb.log.info("\n--- Testing GPIO as Input ---")
    
    # Disable outputs for input test
    await tb.reg.system_registers.GPIO_OE.write((0x0))
    await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
    await Timer(1, 'us')
    
    # Check input function globally (11 pins)
    for i in range(11):
        drive_val = 1 << i
        dut.et.gpio_in.value = drive_val
        await RisingEdge(dut.et.system_clk)
        await RisingEdge(dut.et.system_clk)
        
        gpio_i_read = await tb.reg.system_registers.GPIO_I.read()
        await tb.assert_no_xspi_errors(msg="GPIO_I Read")
        gpio_i_masked = gpio_i_read & 0x7FF
        
        assert gpio_i_masked == drive_val, f"GPIO_I Register mismatch for pin {i}: expected {hex(drive_val)}, got {hex(gpio_i_masked)}"
        cocotb.log.info(f"Verified GPIO {i} input = 1 successfully. Read {hex(gpio_i_masked)}.")
            
        # Reset
        dut.et.gpio_in.value = 0
        await RisingEdge(dut.et.system_clk)
        await RisingEdge(dut.et.system_clk)

    print("\n" + "="*80)
    print("\n****************************GPIO Input Test Passed*******************************")
    print("\n" + "="*80)
    
    # ---------------------------------------------------------
    # TEST: ROBUST INTERRUPTS
    # ---------------------------------------------------------
    cocotb.log.info("\n--- Testing GPIO Interrupt Boundaries ---")
    
    await tb.reg.system_registers.GPIO_OE.write((0x0))
    await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
    await RisingEdge(dut.et.system_clk)

    for i in range(11):
        # Only enable interrupt on specific pin
        mask = 1 << i
        await tb.reg.system_registers.GPIO_Interrupt_Enable.write((mask))
        await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Write")
        await RisingEdge(dut.et.system_clk)
        
        dut.et.gpio_in.value = 0
        await Timer(20, 'ns')
        assert dut.et.erbium_digital.gpio_interrupt.value == 0, f"Interrupt incorrectly set high on pin {i} before edge"

        gpio_intr_read = await tb.reg.system_registers.GPIO_Interrupt_Enable.read()
        await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Read")
        gpio_intr_masked = gpio_intr_read & mask
        assert gpio_intr_masked == mask, f"GPIO_Interrupt_Enable Register mismatch for pin {i}: expected {hex(mask)}, got {hex(gpio_intr_masked)}"
        # Drive rising edge
        intr_task = cocotb.start_soon(wait_for_interrupt(dut, timeout_ns=500))
        await Timer(5, 'ns')
        dut.et.gpio_in.value = mask
        
        fired = await intr_task
        assert fired, f"gpio_interrupt did not fire on rising edge for pin {i}"
        
        cocotb.log.info(f"Verified GPIO {i} interrupt triggers correctly.")
        dut.et.gpio_in.value = 0
        await Timer(20, 'ns')

    await tb.reg.system_registers.GPIO_Interrupt_Enable.write((0x0))
    await tb.assert_no_xspi_errors(msg="GPIO_Interrupt_Enable Write")
    print("\n" + "="*80)
    print("\n**************************GPIO Interrupt Test Passed*****************************")
    print("\n" + "="*80)
    
    
    # ---------------------------------------------------------
    # TEST: MUX/ISOLATION ASSERTIONS
    # ---------------------------------------------------------
    async def verify_isolation(name, pins, config_kwargs):
        cocotb.log.info(f"\n--- Testing {name} Pad Mux Isolation ---")
        if name == "HW_MUX":
            dut.TestMode.value = 1
            
        await tb.reg.system_registers.SystemConfig.write_fields(**config_kwargs)
        await tb.assert_no_xspi_errors(msg="SystemConfig Write")
        await Timer(50, 'ns')
        
        # Input isolation: GPIO_I must not capture values driven on gpio_in
        await tb.reg.system_registers.GPIO_OE.write(0x000)
        await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
        await RisingEdge(dut.et.system_clk)
        await RisingEdge(dut.et.system_clk)
        
        for pin in pins:
            dut.et.gpio_in.value = 1 << pin
            await Timer(20, "ns")
            gpio_i_val = await tb.reg.system_registers.GPIO_I.read()
            await tb.assert_no_xspi_errors(msg="GPIO_I Read")
            assert not (gpio_i_val & (1 << pin)), f"GPIO_I incorrectly captured {name}-owned pin {pin}!"
            
        dut.et.gpio_in.value = 0
        await Timer(20, 'ns')
        
        # Output isolation: gpio_out must not track GPIO_O on peripheral-owned pins
        for pin in pins:
            await tb.reg.system_registers.GPIO_OE.write(1 << pin)
            await tb.assert_no_xspi_errors(msg="GPIO_OE Write")
            await RisingEdge(dut.et.system_clk)
            await RisingEdge(dut.et.system_clk)
            
            # Write 0 then 1 to GPIO_O and confirm pad does not follow
            await tb.reg.system_registers.GPIO_O.write(0x000)
            await tb.assert_no_xspi_errors(msg="GPIO_O Write")
            await RisingEdge(dut.et.system_clk)
            await RisingEdge(dut.et.system_clk)
            out_at_zero = safe_int(dut.gpio_out.value) & (1 << pin)

            await tb.reg.system_registers.GPIO_O.write(0x7FF)
            await tb.assert_no_xspi_errors(msg="GPIO_O Write")
            await RisingEdge(dut.et.system_clk)
            await RisingEdge(dut.et.system_clk)
            
            samples = []
            for _ in range(10):
                out_at_ones = safe_int(dut.gpio_out.value) & (1 << pin)
                samples.append(out_at_ones)
                await Timer(7, "ns")

            if len(set(samples)) == 1:
                assert out_at_zero == out_at_ones, (
                     f"gpio_out[{pin}] tracked GPIO_O on {name}-owned pin "
                     f"(at_zero={out_at_zero} at_ones={out_at_ones}) -- mux isolation failure")
                     
        if name == "HW_MUX":
            dut.TestMode.value = 0
            
        print("\n" + "="*80)
        print(f"\n*************************{name} Pad Isolation Test Passed*****************************")
        print("\n" + "="*80)

    await verify_isolation("SPI", PINS_SPI, dict(spi_enable=1, i2c_enable=0, qspi_enable=0, uart_enable=0))
    await verify_isolation("QSPI", PINS_QSPI, dict(spi_enable=1, i2c_enable=0, qspi_enable=1, uart_enable=0))
    await verify_isolation("I2C", PINS_I2C, dict(spi_enable=1, i2c_enable=1, qspi_enable=0, uart_enable=0))
    await verify_isolation("UART", PINS_UART, dict(spi_enable=1, i2c_enable=0, qspi_enable=0, uart_enable=1))
    await verify_isolation("HW_MUX", PINS_HW_MUX, dict(spi_enable=1, i2c_enable=0, qspi_enable=0, uart_enable=0))
    print("\n" + "="*80)
    
    await Timer(3, 'us')
