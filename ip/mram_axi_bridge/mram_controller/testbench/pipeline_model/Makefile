# Makefile

# defaults
#SIM ?= icarus
SIM ?= vcs
# COMPILE_ARGS = -sverilog -full64 -R +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait
COMPILE_ARGS  = -sverilog -full64 +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait
COMPILE_ARGS += -override_timescale=1ns/1ps
COMPILE_ARGS += +define+UNIT_DELAY_FOR_NETLIST
# SIM_ARGS = +vcs+lic+wait
TOPLEVEL_LANG ?= verilog

# use VHDL_SOURCES for VHDL files
git_root = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES  =  $(git_root)/verilog/erbium_et_instance.sv
VERILOG_SOURCES +=  $(git_root)/verilog/erbium_et_bank.sv
VERILOG_SOURCES +=  $(git_root)/testbench/pipeline_model/bankpipe_model_tbench.sv
#VERILOG_SOURCES +=  $(git_root)/testbench/pipeline_model/instpipe_model_tbench.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = bankpipe_model_tbench
#TOPLEVEL = instpipe_model_tbench

# MODULE is the basename of the Python test file
#
MODULE=bankpipe_model
#MODULE=instpipe_model

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
