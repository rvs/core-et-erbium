QSPI_ROOT=$(shell git rev-parse --show-toplevel)

VERILOG_SOURCES +=$(QSPI_ROOT)/verilog/qspi_32_64_0.v
VERILOG_SOURCES +=$(QSPI_ROOT)/tb/tb_qspi.v
MODULE=test_qspi
TOPLEVEL=qspi
COMPILE_ARGS= -f $(QSPI_ROOT)/tb/flags.f
COCOTB_RESULTS_FILE=$(MODULE)_results.xml
include $(shell cocotb-config --makefiles)/Makefile.sim
qspi:
	$(MAKE) sim MODULE=test_qspi TOPLEVEL=qspi
qspi_suite:
	$(MAKE) sim MODULE=test_qspi_suite TOPLEVEL=qspi
qspi_suite_bug1:
	$(MAKE) sim MODULE=test_qspi_suite_bug1 TOPLEVEL=qspi COCOTB_RESULTS_FILE=test_qspi_suite_bug1_results.xml
