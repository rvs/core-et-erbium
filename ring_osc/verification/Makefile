# =============================================================================
# ring_osc cocotb verification Makefile
#
# Usage:
#   make              - run with VCS (default)
#   make SIM=vcs      - explicitly select VCS
#   make SIM=verilator - run with Verilator
#   make setup        - create the local Python venv and install cocotb
#   make waves        - open VPD in Verdi (VCS only)
#   make clean        - remove build artefacts
#
# NOTE (Verilator): rochip.sv uses 'real'/'realtime' types and #delay inside
# initial/forever blocks, which requires Verilator >= 5.x and --timing.
# Some advanced real-type constructs may still produce lint warnings.
# =============================================================================

SIM           ?= vcs
TOPLEVEL_LANG  = verilog
TOPLEVEL       = tb_ring_osc
MODULE         = test_ring_osc

# --------------------------------------------------------------------------- #
# Paths — all rooted at the git repository root
# --------------------------------------------------------------------------- #
GIT_ROOT := $(shell git rev-parse --show-toplevel)
VERIF_DIR = $(GIT_ROOT)/ring_osc/verification
VENV_DIR  = $(VERIF_DIR)/venv
RTL_DIR   = $(GIT_ROOT)/ring_osc/verilog
BUILD_DIR = sim_build

# --------------------------------------------------------------------------- #
# RTL source list (dependency order: leaves first, top last)
# --------------------------------------------------------------------------- #
VERILOG_SOURCES  = $(RTL_DIR)/anachip.v
VERILOG_SOURCES += $(RTL_DIR)/rochip.sv
VERILOG_SOURCES += $(RTL_DIR)/ring_osc.sv
VERILOG_SOURCES += $(VERIF_DIR)/tb_ring_osc.sv

# --------------------------------------------------------------------------- #
# Simulator-specific arguments
# --------------------------------------------------------------------------- #
ifeq ($(SIM),vcs)
    COMPILE_ARGS  = -sverilog
    COMPILE_ARGS += -full64
    COMPILE_ARGS += -notice
    COMPILE_ARGS += +lint=TFIPC-L
    COMPILE_ARGS += +vcs+lic+wait
    COMPILE_ARGS += -timescale=1ps/1ps

    SIM_ARGS      = +vcs+flush+all

    # Uncomment for waveform capture (Verdi FSDB):
    #COMPILE_ARGS += -debug_access+all
    #SIM_ARGS     += -ucli -do dump.tcl
endif

ifeq ($(SIM),verilator)
    # --timing is required for #delay and @(signal) inside initial blocks
    COMPILE_ARGS  = --timing
    COMPILE_ARGS += --sv
    COMPILE_ARGS += -Wno-lint
    COMPILE_ARGS += -Wno-fatal
endif

# --------------------------------------------------------------------------- #
# Waveform dumping  (WAVES=1 to enable, default off)
# Use: make SIM=vcs WAVES=1  or  make SIM=verilator WAVES=1
# Output: sim_build/dump.vcd
#
# VCS:       defines DUMP_VCD so tb_ring_osc.sv's $dumpfile/$dumpvars fires.
# Verilator: cocotb's verilator.cpp wrapper owns the trace lifecycle; it only
#            calls Verilated::traceEverOn(true) when the Vtop binary receives
#            --trace at runtime.  $dumpfile/$dumpvars from HDL is too late and
#            triggers the "traceEverOn before time 0" abort, so we skip the
#            DUMP_VCD define and let the wrapper write dump.vcd instead.
# --------------------------------------------------------------------------- #
WAVES ?= 0
ifeq ($(WAVES),1)
ifeq ($(SIM),vcs)
    COMPILE_ARGS += +define+DUMP_VCD
endif
ifeq ($(SIM),verilator)
    COMPILE_ARGS += --trace-vcd
    SIM_ARGS     += --trace          # passed to Vtop binary; triggers traceEverOn
endif
endif

# --------------------------------------------------------------------------- #
# cocotb environment
# --------------------------------------------------------------------------- #
export COCOTB_RESULTS_FILE = results.xml
export PYTHONPATH          := $(VERIF_DIR):$(PYTHONPATH)

# Prepend the local venv to PATH so that every $(shell cocotb-config …) call
# inside the included cocotb makefiles resolves to our venv's installation,
# not whatever happens to be on the system PATH.
export PATH := $(VENV_DIR)/bin:$(PATH)

# Use cocotb-config from the local venv so this Makefile is self-contained
COCOTB_MAKEFILES := $(shell $(VENV_DIR)/bin/cocotb-config --makefiles 2>/dev/null)

ifeq ($(COCOTB_MAKEFILES),)
    $(error "Could not find cocotb. Run 'make setup' first to create the venv.")
endif

include $(COCOTB_MAKEFILES)/Makefile.sim

# --------------------------------------------------------------------------- #
# venv setup
# --------------------------------------------------------------------------- #
.PHONY: setup
setup:
	@echo ">>> Creating Python venv in $(VENV_DIR)"
	python3.10 -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install \
	    cocotb==1.9.2 \
	    cocotb-coverage==1.2.0 \
	    junit_xml \
	    junit2html
	@echo ">>> venv ready. Activate with: source $(VENV_DIR)/bin/activate"

# --------------------------------------------------------------------------- #
# Convenience: open waveform in Verdi (VCS runs only)
# --------------------------------------------------------------------------- #
.PHONY: waves
waves:
	verdi -ssf $(BUILD_DIR)/dump.vpd &

# --------------------------------------------------------------------------- #
# Clean
# --------------------------------------------------------------------------- #
.PHONY: clean
clean::
	rm -rf __pycache__ results.xml *.log *.vpd *.vcd ucli.key
