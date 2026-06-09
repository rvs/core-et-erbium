# =============================================================================
# tsense cocotb verification Makefile
#
# Usage:
#   make              - run with VCS (default)
#   make WAVES=1      - enable VCD waveform dump
#   make setup        - install uv and sync dependencies
#   make waves        - open VPD in Verdi (VCS only)
#   make clean        - remove build artefacts
# =============================================================================

SIM            ?= vcs
TOPLEVEL_LANG   = verilog
TOPLEVEL        = tb_tsense
MODULE          = test_tsense

# --------------------------------------------------------------------------- #
# Paths
# --------------------------------------------------------------------------- #
GIT_ROOT  := $(shell git rev-parse --show-toplevel)
VERIF_DIR  = $(GIT_ROOT)/tsense/verification
RTL_DIR    = $(GIT_ROOT)/tsense/verilog

# --------------------------------------------------------------------------- #
# Sources: RTL via filelist, testbench explicit
# --------------------------------------------------------------------------- #
VERILOG_SOURCES = $(VERIF_DIR)/tb_tsense.sv

# --------------------------------------------------------------------------- #
# Simulator-specific arguments
# --------------------------------------------------------------------------- #
COMPILE_ARGS  = -sverilog
COMPILE_ARGS += +vcs+lic+wait
COMPILE_ARGS += -timescale=1ps/1ps
COMPILE_ARGS += -F $(RTL_DIR)/rtl_sim.f
SIM_ARGS      = +vcs+flush+all

# --------------------------------------------------------------------------- #
# Waveform dumping  (WAVES=1 to enable)
# --------------------------------------------------------------------------- #
WAVES ?= 0
ifeq ($(WAVES),1)
    COMPILE_ARGS += +define+DUMP_VCD
endif

# --------------------------------------------------------------------------- #
# cocotb environment
# --------------------------------------------------------------------------- #
export COCOTB_RESULTS_FILE = results.xml

include $(shell cocotb-config --makefiles)/Makefile.sim

# --------------------------------------------------------------------------- #
# Setup
# --------------------------------------------------------------------------- #
.PHONY: setup
setup:
	curl -LsSf https://astral.sh/uv/install.sh | sh
	cd $(GIT_ROOT) && uv sync

# --------------------------------------------------------------------------- #
# Convenience: open waveform
# --------------------------------------------------------------------------- #
.PHONY: waves
waves:
	verdi -ssf sim_build/dump.vpd &

# --------------------------------------------------------------------------- #
# Clean
# --------------------------------------------------------------------------- #
.PHONY: clean
clean::
	rm -rf __pycache__ results.xml *.log *.vpd *.vcd ucli.key
