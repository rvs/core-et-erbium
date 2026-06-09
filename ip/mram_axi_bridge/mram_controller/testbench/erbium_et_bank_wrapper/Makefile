ROOT := $(shell git rev-parse --show-toplevel)
.DEFAULT_GOAL := sim

# -----------------------------------------------------------------------------
# Testbench config
# -----------------------------------------------------------------------------
SIM ?= vcs
TOPLEVEL_LANG ?= verilog
TOPLEVEL ?= tb
MODULE ?= tb

TB_DIR := $(ROOT)/testbench/erbium_et_bank_wrapper
RTL_DIR := $(ROOT)/verilog
REGBLOCK_DIR := $(ROOT)/regblocks/verilog
REGBLOCK_PY_DIR := $(ROOT)/regblocks/python
export PYTHONPATH := $(TB_DIR):$(REGBLOCK_PY_DIR):$(PYTHONPATH)

VERILOG_INCLUDE_DIRS += $(RTL_DIR)

# -----------------------------------------------------------------------------
# Testbench + DUT sources
# -----------------------------------------------------------------------------
VERILOG_SOURCES += $(REGBLOCK_DIR)/external_test_regs_pkg.sv
VERILOG_SOURCES += $(REGBLOCK_DIR)/external_test_regs.sv
VERILOG_SOURCES += $(REGBLOCK_DIR)/controller_regs_pkg.sv
VERILOG_SOURCES += $(REGBLOCK_DIR)/controller_regs.sv
VERILOG_SOURCES += $(TB_DIR)/tb.sv
VERILOG_SOURCES += $(TB_DIR)/stdcell_stubs.sv
VERILOG_SOURCES += $(RTL_DIR)/erbium_et_bank_wrapper.sv
VERILOG_SOURCES += $(RTL_DIR)/et_ctrl_wrapper.sv
VERILOG_SOURCES += $(RTL_DIR)/et_ctrl_top.sv
VERILOG_SOURCES += $(RTL_DIR)/ctrl_cnfg_ovr_logic.v
VERILOG_SOURCES += $(RTL_DIR)/clk_gate.v
VERILOG_SOURCES += $(RTL_DIR)/cpu_intr_logic.sv
VERILOG_SOURCES += $(RTL_DIR)/bwe_convert.v
VERILOG_SOURCES += $(RTL_DIR)/et_bwe_convert.v
VERILOG_SOURCES += $(RTL_DIR)/test_regs.v
VERILOG_SOURCES += $(RTL_DIR)/ctrl_mux.v
VERILOG_SOURCES += $(RTL_DIR)/bist_wrapper.v
VERILOG_SOURCES += $(RTL_DIR)/bist_mux.v
VERILOG_SOURCES += $(RTL_DIR)/mkBist.v
VERILOG_SOURCES += $(RTL_DIR)/FIFO2.v
VERILOG_SOURCES += $(RTL_DIR)/Counter.v
VERILOG_SOURCES += $(RTL_DIR)/ecc_rom_wrapper.sv
VERILOG_SOURCES += $(RTL_DIR)/rom_16kb_top.v
VERILOG_SOURCES += $(RTL_DIR)/boot_sequencer.sv
VERILOG_SOURCES += $(RTL_DIR)/et_bch_encoder.sv
VERILOG_SOURCES += $(RTL_DIR)/et_bch_decoder.sv
VERILOG_SOURCES += $(RTL_DIR)/et_ecc_wrapper.sv
VERILOG_SOURCES += $(RTL_DIR)/ref_ecc_encoder.sv
VERILOG_SOURCES += $(RTL_DIR)/ref_ecc_repair.sv
VERILOG_SOURCES += $(RTL_DIR)/hamming_encoder.sv
VERILOG_SOURCES += $(RTL_DIR)/hamming_corrector.sv
VERILOG_SOURCES += $(RTL_DIR)/erbium_et_bank.sv
VERILOG_SOURCES += $(RTL_DIR)/erbium_et_instance.sv

# Keep build in this testbench directory.
SIM_BUILD ?= $(TB_DIR)/sim_build

ifeq ($(SIM),vcs)
PLUSARGS += -debug_access+all +vcs+dumpvars+dump.vcd +vcs+dumpon
COMPILE_ARGS += -sverilog -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait
COMPILE_ARGS += +define+BEHAVIORAL_BANK
COMPILE_ARGS += $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
else ifeq ($(SIM),verilator)
COMPILE_ARGS += -Wall --timing --trace -Wno-fatal
COMPILE_ARGS += -Wno-INITIALDLY -Wno-WIDTH -Wno-UNOPTFLAT
COMPILE_ARGS += -DBEHAVIORAL_BANK
COMPILE_ARGS += $(addprefix -I, $(VERILOG_INCLUDE_DIRS))
endif

clean::
	rm -rf sim_build __pycache__ *.xml *.vcd *.fst *.wlf *.log

include $(shell cocotb-config --makefiles)/Makefile.sim
