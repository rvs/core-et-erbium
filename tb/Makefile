MK_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
HDLET_ROOT ?= $(abspath $(MK_ROOT)/..)
DEBUG_ARGS=-debug_access+all  -debug_region+cell+lib+udp -debug_acc+pp+dmptf -debug_region+cell+encrypt
VCS_ARGS=-sverilog  -full64 -notice +lint=TFIPC-L  $(DEBUG_ARGS)
COMPILE_ARGS=-f $(HDLET_ROOT)/tb/erbium_tb_vcs.f $(HDLET_ROOT)/tb/tb.v $(VCS_ARGS) $(NOC_INCDIRS) +define+BEHAVIORAL_BANK +define+SIMULATION +define+BOOTROM_HEXFILE=\"bootrom.hex\" +define+SRAM_HEXFILE=\"sram.hex\" +vcs+lic+wait
#VERILATOR_ARGS=verilator -cc --exe --main --no-decoration -O3 -LDFLAGS "Vtop__ALL.a" -CFLAGS " -std=c++20 -fcoroutines " --timing -sv --timescale 1ns/1ps --debug-check --vpi --assert -Wno-lint -Wno-fatal --Mdir $(BUILD_DIR) --trace-vcd --trace-structs -f cpu_subsystem_top_rtl.f --timing --output-split 20000 --verilate-jobs 8 -o $(BUILD_DIR)/simv -t top 
CUSTOM_COMPILE_DEPS=.rebuild
SIM:=vcs
TOPLEVEL_LANG=verilog
TOPLEVEL=tb
COCOTB_TOPLEVEL=$(TOPLEVEL)
MODULE:=test_default
# COCOTB_TEST_MODULES:=$(MODULE)
COPRA_STUB_DIR=./stubs
TESTS = test_default test_gpio test_regions test_uart test_gpio_1 test_i2c_regress test_watchdog test_qspi test_memory_map test_interrupt test_mram_features
#TESTS = test_i2c_regress
COCOTB_RESULTS_FILE=$(MODULE)_results.xml

REGMODEL_ROOT := $(HDLET_ROOT)/regblocks/systemrdl
RAL_STAMP := $(HDLET_ROOT)/tb/ral/.stamp
RAL_RDL_DEPS := \
	$(REGMODEL_ROOT)/hyperbus.rdl \
	$(REGMODEL_ROOT)/mram.rdl \
	$(REGMODEL_ROOT)/periph.rdl \
	$(REGMODEL_ROOT)/romram.rdl \
	$(REGMODEL_ROOT)/system.rdl \
	$(REGMODEL_ROOT)/top_cpu_mm.rdl \
	$(REGMODEL_ROOT)/top.rdl \
	$(REGMODEL_ROOT)/top_xspi_mm.rdl \
	$(HDLET_ROOT)/ip/xspi/systemrdl/sfdp.rdl \
	$(HDLET_ROOT)/ip/xspi/systemrdl/sccr.rdl
CUSTOM_SIM_DEPS += $(RAL_STAMP)

WAVES ?= 0

ifneq ($(WAVES),0)
	COMPILE_ARGS+=+define+WAVES=1
endif
# If in test flow, include monitors and cosim
ifdef TEST_ELF
    COMPILE_ARGS += +define+ET_SIMULATION +define+ENABLE_BEMU
    ifeq ($(SIM), vcs)
        # Custom main to initialzie the C++ tb
        # TODO: ANT: Move this to top repo
        COMPILE_ARGS += -e vcs_main $(REPOROOT)/dv/standalone/cpu_subsystem/csrc/vcs_main.cpp
    endif
    SIM_BUILD?=$(HDLET_ROOT)/tb/sim_build
    include $(MK_ROOT)/common.mk
endif


include $(shell cocotb-config --makefiles)/Makefile.sim
$(RAL_STAMP): $(RAL_RDL_DEPS) $(REGMODEL_ROOT)/Makefile
	$(MAKE) -C $(REGMODEL_ROOT) ral

setup:
	curl -LsSf https://astral.sh/uv/install.sh | sh
	cd .. && uv sync
regress: $(TESTS)
	$(MAKE) junit
junit:
	python $(REPOROOT)/scripts/junit2html.py --merge all.junit *_results.xml
	python $(REPOROOT)/scripts/junit2html.py --summary-matrix all.junit
	python $(REPOROOT)/scripts/junit2html.py --report-matrix out.html all.junit
.rebuild:
	touch .rebuild
rebuild:
	rm .rebuild
$(TESTS):
	make sim MODULE=$@ || echo Done $@
