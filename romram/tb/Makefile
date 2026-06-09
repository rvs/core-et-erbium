DEBUG_ARGS=-debug_access+all  -debug_region+cell+lib+udp -debug_acc+pp+dmptf -debug_region+cell+encrypt
COMPILE_ARGS= +vcs+lic+wait +define+SIMULATION -y /tools/bluespec/2025.07/lib/Verilog/ +libext+.v
#VERILATOR_ARGS=verilator -cc --exe --main --no-decoration -O3 -LDFLAGS "Vtop__ALL.a" -CFLAGS " -std=c++20 -fcoroutines " --timing -sv --timescale 1ns/1ps --debug-check --vpi --assert -Wno-lint -Wno-fatal --Mdir $(BUILD_DIR) --trace-vcd --trace-structs -f cpu_subsystem_top_rtl.f --timing --output-split 20000 --verilate-jobs 8 -o $(BUILD_DIR)/simv -t top 
CUSTOM_COMPILE_DEPS=.rebuild
SIM:=vcs
TOPLEVEL_LANG=verilog
TOPLEVEL=tb
RR=$(HDLET_ROOT)/romram/verilog/
VERILOG_SOURCES=$(HDLET_ROOT)/romram/tb/tb.v
VERILOG_SOURCES+=$(RR)/bootrom_upf.v
VERILOG_SOURCES+=$(RR)/mkRomRam.v
VERILOG_SOURCES+=$(RR)/ram_tsmc.v
VERILOG_SOURCES+=$(RR)/ram_upf.v
VERILOG_SOURCES+=$(RR)/ram.v
VERILOG_SOURCES+=$(RR)/rom_64kb_top.v
VERILOG_SOURCES+=$(RR)/rom.v
COCOTB_TOPLEVEL=$(TOPLEVEL)
MODULE:=test_default
COCOTB_TEST_MODULES:=$(MODULE)
TESTS = test_default test_gpio test_regions
COCOTB_RESULTS_FILE=$(MODULE)_results.xml

include $(shell cocotb-config --makefiles)/Makefile.sim
setup:
	curl -LsSf https://astral.sh/uv/install.sh | sh
	cd .. && uv sync
regression: $(TESTS)
.rebuild:
	touch .rebuild
rebuild:
	rm .rebuild
$(TESTS):
	make sim MODULE=$@
