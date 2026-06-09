# Makefile

# defaults
#SIM ?= icarus
SIM ?= vcs
COMPILE_ARGS = -sverilog -full64 +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait
COMPILE_ARGS += -override_timescale=1ns/1ps
COMPILE_ARGS += +define+UNIT_DELAY_FOR_NETLIST
# SIM_ARGS = +vcs+lic+wait
TOPLEVEL_LANG ?= verilog

# use VHDL_SOURCES for VHDL files
git_root         = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES  = $(git_root)/verilog/boot_sequencer.sv
VERILOG_SOURCES += $(git_root)/testbench/boot_sequencer/boot_sequencer_tbench.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = boot_sequencer_tbench

# MODULE is the basename of the Python test file
#
MODULE=boot_sequencer_tbench
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
