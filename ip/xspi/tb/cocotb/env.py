"""Extended verification environment that uses XspiExtCommands.

Drop-in replacement for env.Env that wires in the extended command set
(read_Reg, write_Reg, OTP, EnterPD, ExitPD) plus a Scoreboard.
"""

import cocotb
from cocotbext.xspi.bus import XspiBus
from cocotbext.xspi.config import default_config
from cocotb.triggers import RisingEdge, Timer
from cocotbext.axi import AxiBus, AxiRam

from extended_commands import XspiExtCommands


class Env:
    """Extended Env with scoreboard and full command set."""

    def __init__(self, dut):
        bus = XspiBus(dut, "xspi")
        self.cmd = XspiExtCommands(bus, dut=dut, free_running_clk=True)
        self.dut = dut
        self.axi_ram = AxiRam(
            AxiBus.from_prefix(dut, "axi"),
            dut.CLK,
            dut.RST_N,
            reset_active_level=False,
            size=2 ** 32,
        )
        self.ifc = self.cmd

    async def reset(self):
        """Assert RST_N for 10 clock cycles then release."""
        for _ in range(10):
            await RisingEdge(self.dut.xspi_clk)
            self.dut.RST_N.value = 0
        self.dut.RST_N.value = 1

    async def boot(self):
        """Full boot sequence: reset + issue Reset command + idle clocks."""
        await self.reset()
        for _ in range(10):
            await RisingEdge(self.dut.xspi_clk)
        await self.cmd.Reset()
        for _ in range(10):
            await RisingEdge(self.dut.xspi_clk)
        await Timer(10,'ns')
        cocotb.log.info("Reset Done")

    async def _wait_wip(self):
        rv_int = 1
        while rv_int:
            rv = await self.ifc.read_Reg(0x18)  # Status
            rv_int = int.from_bytes(rv, "little")

    async def assert_no_xspi_errors(self, slvError=False,
                                decodeError=False,
                                read_underflow=False,
                                write_overflow=False,msg=""):
        expected = (0 |
                    2 if slvError else 0 |
                    3 if decodeError else 0 |
                    4 if read_underflow else 0 |
                    8 if write_overflow else 0
                    )
        rv_int = 1
        await self._wait_wip()
        int_status = await self.ifc.read_Reg(0x30)  # Interrupt
        assert int.from_bytes(int_status, "little") == expected,msg
