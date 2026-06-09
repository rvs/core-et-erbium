# Makefile

# defaults
SIM ?= icarus
#SIM ?= vcs
#COMPILE_ARGS = -sverilog -full64 -R +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait
# SIM_ARGS = +vcs+lic+wait
TOPLEVEL_LANG ?= verilog

# use VHDL_SOURCES for VHDL files
VERILOG_SOURCES += $(PWD)/../../verilog/ste.sv
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ste

# MODULE is the basename of the Python test file
#
MODULE=tbench
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
