UART_ROOT=$(shell git rev-parse --show-toplevel)
VERILOG_SOURCES +=$(UART_ROOT)/verilog/uart.v
VERILOG_SOURCES +=$(UART_ROOT)/tb/tb_uart.v
MODULE=mkUart
SIM_BUILD=$(MODULE)_build
TOPLEVEL=tb_uart
COMPILE_ARGS= -f $(UART_ROOT)/tb/flags.f
COCOTB_RESULTS_FILE=$(MODULE)_results.xml
default:uart matrix
include $(shell cocotb-config --makefiles)/Makefile.sim
uart:
	echo $(UART_ROOT)
	$(MAKE) sim MODULE=test_uart TOPLEVEL=tb_uart 
	$(MAKE) sim MODULE=ai.test_uart_suite TOPLEVEL=tb_uart
matrix:
	$(MAKE) sim MODULE=ai.test_uart_freq_matrix TOPLEVEL=tb_uart
