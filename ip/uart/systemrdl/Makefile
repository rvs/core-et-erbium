all: rtl doc html python
rtl: uart.rdl 
	peakrdl bsv uart.rdl -o ../bsv
doc:uart.rdl
	peakrdl markdown uart.rdl  -o ../doc/registers.md
	sed -ie 's/## Uart_Reg address map/# Uart_Reg address map/'  ../doc/registers.md
html:
	mkdir -p html
	peakrdl html uart.rdl  -o html
python:
	peakrdl python uart.rdl -o ../tb/ral --async
