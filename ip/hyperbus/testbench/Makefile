HB_ROOT=$(shell git rev-parse --show-toplevel)
SIM=vcs
MODULE=test
TOPLEVEL=tb_hyperbus
VERILOG_SOURCES=$(HB_ROOT)/fpga/verilog/mkHB_Wrapper.v
VERILOG_SOURCES+=$(HB_ROOT)/verilog/hyperbus.v
VERILOG_SOURCES+=$(HB_ROOT)/verilog/ddr_out_cell.v
VERILOG_SOURCES+=$(HB_ROOT)/verilog/ddr_in_cell.v
VERILOG_SOURCES+=$(HB_ROOT)/fpga/verilog/HB_Reg_pkg.sv
VERILOG_SOURCES+=$(HB_ROOT)/fpga/verilog/HB_Reg.sv
VERILOG_SOURCES+=$(HB_ROOT)/testbench/tb_hyperbus.v
VERILOG_SOURCES+=$(BLUESPEC_HOME)/lib/Verilog/FIFO2.v
VERILOG_SOURCES+=$(BLUESPEC_HOME)/lib/Verilog/SyncFIFO1.v
VERILOG_SOURCES+=$(BLUESPEC_HOME)/lib/Verilog/Counter.v
VERILOG_SOURCES+=$(HB_ROOT)/testbench/Hyperbus/standalone/hbc.v
# VERILOG_SOURCES+=$(HB_ROOT)/../../hyperbus/verilog/hyperbus.v

ifeq ($(SIM),icarus)
COMPILE_ARGS+=-g2012
else
COMPILE_ARGS+='-sverilog'
COMPILE_ARGS+='+lint=TFIPC-L'
endif
run:
	echo $(SIM)
	$(MAKE) sim

include $(shell cocotb-config --makefiles)/Makefile.sim
