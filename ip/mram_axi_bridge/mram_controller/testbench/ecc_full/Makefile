# Makefile
#SRC_DIR := $(PWD)/../../verilog/
# defaults
#SIM ?= icarus
#COMPILE_ARGS = -I ../../verilog/
SIM ?= vcs
COMPILE_ARGS = -sverilog -full64 +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait +incdir+$(PWD)/../../verilog/
# SIM_ARGS = +vcs+lic+wait

TOPLEVEL_LANG ?= verilog

# use VHDL_SOURCES for VHDL files
VERILOG_SOURCES += $(PWD)/../../verilog/ecc_wrapper.sv
#~ VERILOG_SOURCES += $(PWD)/../../verilog/log2.vh

#~ VERILOG_SOURCES += $(PWD)/../../verilog/config.vh

VERILOG_SOURCES += $(PWD)/../../verilog/ref_ecc_repair.sv
VERILOG_SOURCES += $(PWD)/../../verilog/ref_ecc_encoder.sv
VERILOG_SOURCES += $(PWD)/../../verilog/hamming_encoder.sv
VERILOG_SOURCES += $(PWD)/../../verilog/hamming_corrector.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL=ecc_wrapper

# MODULE is the basename of the Python test file
#
MODULE=tbench
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
