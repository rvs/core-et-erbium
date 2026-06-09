export ARGON_HDL_ROOT=$(shell git rev-parse --show-toplevel)
MODULE=test
TOPLEVEL=tb_hyperbus
COMPILE_ARGS='-sverilog'
COMPILE_ARGS+='+lint=TFIPC-L'
VERILOG_SOURCES=$(ARGON_HDL_ROOT)/fpga/verilog/mkHB_Wrapper.v
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/hyperbus/verilog/hyperbus.v
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/hyperbus/verilog/ddr_cell.v
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/fpga/verilog/HB_Reg_pkg.sv
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/fpga/verilog/HB_Reg.sv
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/fpga/testbench/tb_hyperbus.v
VERILOG_SOURCES+=/tools/bluespec/2024/lib/Verilog/FIFO2.v
VERILOG_SOURCES+=/tools/bluespec/2024/lib/Verilog/SyncFIFO1.v
VERILOG_SOURCES+=/tools/bluespec/2024/lib/Verilog/Counter.v
VERILOG_SOURCES+=$(ARGON_HDL_ROOT)/hyperbus/testbench/Hyperbus/standalone/hbc.v
 

include $(shell cocotb-config --makefiles)/Makefile.sim
