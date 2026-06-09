# xspi COCOTB VIP for xspi protocol
cocotb XSPI 1s,4s,4d,8s,8d and hyperbus protocol, driver and monitor

# install
`pip3 install cocotbext_xspi`

#Usage

```
from cocotbext.xspi import XspiBus,XspiDriver,XspiConfig

....
class Env:
   def __init__(self,dut):
	xspi_bus = XspiBus(from_prefix='...',dut=....)
	xspi_config = XspiConfig()
	xspi_config.<key>=<value>
	xspi_driver = xspiDriver(xspi_bus, xspi_config)
   async def xyz(self):
 	xspi_driver.write(address,byteArray)
 	rv =xspi_driver.read(address,numbytes)
	assert rv=byteArray, "Data mismatch at %X"%(address)
