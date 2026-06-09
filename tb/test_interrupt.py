import cocotb
from cocotb.triggers import Timer
from env import ETEnv
from enum import IntEnum
from typing import TYPE_CHECKING, Any
if TYPE_CHECKING:
    from copra_stubs import Tb as DUT
else:
    DUT=Any

interrupts_mask=IntEnum("Interrupt",[
    ("MRAM",1 ),
    ("QSPI",2 ),
    ("UART",4 ),
    ("SYS", 8),
    ("XSPI", 0x10),
    ("GPIO", 0x20),
    ])
interrupt_set={
        "MRAM":0,
        "QSPI":1,
        "UART":0,
        "SYS":0,
        "XSPI":0,
        "GPIO":0,
        }

async def check_interrupt(dut):
    inter=dut.et.erbium_digital.cpu_ss.plic_irq
    while(True):
        intval=dut.et.erbium_digital.cpu_ss.plic_irq.value
        expected_val=( interrupt_set["GPIO"]<<5 |
                interrupt_set["XSPI"]<<4 |
                interrupt_set["SYS"]<<3 |
                interrupt_set["UART"]<<2 |
                interrupt_set["QSPI"]<<1 |
                interrupt_set["MRAM"]
                      )
        assert expected_val == intval
        await inter.valuechange
                
@cocotb.test()
async def interrupt_test(dut:DUT):
    tb = ETEnv(dut, safe_callback=True)
    await tb.reset()
    tb.start()
    # cocotb.start_soon(check_interrupt(dut))
    await tb.reg.system_registers.SysInterrupt.write(1)
    await Timer(10,'us')
    # assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value) & 0x4 ==0, "SysInterrupt set when disabled"
    await Timer(10,'us')
    await tb.reg.system_registers.SystemConfig.write(1)
    cocotb.log.info(int(dut.et.erbium_digital.cpu_ss.plic_irq.value) )
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value)  & 0x8 !=0, "SysInterrupt not set"
    dut.gpio_i.value = 0x0
    await tb.reg.system_registers.GPIO_Interrupt_Enable.write(0x3ff)
    await Timer(10,'us')
    dut.gpio_i.value = 0x3ff
    await Timer(10,'us')
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value) & 0x20 !=0, "GPIO not set"
    dut.gpio_i.value = 0x0
    await Timer(10,'us')
    await tb.reg.system_registers.SysInterrupt.read()
    await Timer(10,'us')
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value)  & 0x28 == 0 ,"GPIO and SysInterrupt Cleared"
    dut.gpio_i.value = 0x3ff
    await Timer(10,'us')
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value)  &0x20 !=0, "GPIO Interrupt Set"

    # xspi Interrupt
    await tb.xspi_cmd.write_Reg(0x20,0x2.to_bytes(4,"little"))
    await tb.xspi_cmd.write_Mem(0x40007fff,0x0.to_bytes(8,"little"))
    await Timer(10,"ns")
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value) &0x10 != 0, "XSPI Interrupt not set"
    await Timer(10,"ns")
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value) &0x10 != 0, "XSPI Interrupt not set"
    
    rv = await tb.xspi_cmd.read_Reg(0x30)
    assert int(dut.et.erbium_digital.cpu_ss.plic_irq.value) &0x10 == 0, "XSPI Interrupt not Cleared"
    
