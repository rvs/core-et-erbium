# Makefile
#VERILOG_SOURCES += $(PWD)/../verilog/mram.v
# use VHDL_SOURCES for VHDL files
VERILOG_SOURCES += $(PWD)/tb.sv
VERILOG_SOURCES += $(PWD)/../verilog/axi2mram.v
VERILOG_SOURCES += $(PWD)/../verilog/mram.v
VERILOG_SOURCES += $(PWD)/../verilog/axi2mram_wrapper.sv
VERILOG_SOURCES += $(PWD)/../mram_controller/verilog/ecc_wrapper.sv
VERILOG_SOURCES += $(PWD)/../mram_controller/verilog/*.v
VERILOG_SOURCES += $(PWD)/../mram_controller/verilog/*.sv
VERILOG_SOURCES += /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/verilog/tcbn16ffcllbwp7d5t16p96cpd_100b/tcbn16ffcllbwp7d5t16p96cpd.v
VERILOG_INCLUDE_DIRS += $(PWD)/../mram_controller/verilog/

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
#TOPLEVEL = mram

# MODULE is the basename of the Python test file
#
TOPLEVEL=tb
MODULE=mram_axi_wrapper_tbench

# defaults
SIM ?= vcs
COV_EN=0
ifeq ($(COV_EN),1)
PLUS_ARGS = -debug_access+all +vcs+dumpvars +vcs+dumpon
COMPILE_ARGS = -sverilog -cm line+cond+fsm+tgl+branch+assert -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait +define+BEHAVIORAL_BANK $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
SIM_ARGS= -cm line+cond+fsm+tgl+branch+assert
else
PLUS_ARGS = -debug_access+all +vcs+dumpvars +vcs+dumpon
COMPILE_ARGS = -sverilog -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait +define+BEHAVIORAL_BANK $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
endif
#SIM_ARGS = +lint=all
TOPLEVEL_LANG ?= verilog

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
