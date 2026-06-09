TESTS=LiveCheck BasicReadWrite Reliability Retention Walking
# DIRECTED_TESTS=test1 test2 direct1 sbl0_short_bist_rw sbl0_lfsr_cnt20_bist_rw sbl0_full_address_space sbl1_full_address_space cbl_full_address_space sbl1_incr1_wlk0_up sbl1_incr1_wlk0_dn sbl1_incr1_wlk1_up sbl1_incr1_wlk1_dn
DIRECTED_TESTS=$(shell ls tests/ | grep toml | sed 's/.toml//g')
PENDING_TESTS =   NeighborNoise Endurance
export COCOTB_RESOLVE_X=RANDOM
SIM=vcs
export REPORTS_PATH=reports
WAVES?=1
ifeq ($(SIM), verilator)
COMPILE_ARGS+=-Wno-lint --timing -Wno-MULTIDRIVEN +incdir+$(COPPER_ROOT)/verilog
else
	COMPILE_ARGS+=+define+WAVES=$(WAVES) +incdir+$(COPPER_ROOT)/verilog +lint=TFIPC-L
endif
MODULE?=test
TOPLEVEL=tb_mram_wrapper
VERILOG_SOURCES  = $(COPPER_ROOT)/testbench/mram_wrapper/tb_mram_wrapper.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/mram_wrapper.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ecc_wrapper.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ref_ecc_repair.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ref_ecc_encoder.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/hamming_encoder.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/hamming_corrector.sv

VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bank.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bist_mux.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bist_wrapper.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/boot_sequencer.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bwe_convert.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/clk_gate.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/cpu_intr_logic.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ctrl_cnfg_ovr_logic.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ctrl_mux.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ctrl_wrapper.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ecc_rom_wrapper.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ecc_wrapper.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/hamming_corrector.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/hamming_encoder.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/rom_16kb_top.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/ste.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bist_rte.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bist_read.sv
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/bist_write.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/mkBist.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/test_regs.v
VERILOG_SOURCES += /tech/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/verilog/tcbn16ffcllbwp7d5t16p96cpd_100b/tcbn16ffcllbwp7d5t16p96cpd.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/Counter.v
VERILOG_SOURCES += $(COPPER_ROOT)/verilog/FIFO2.v

default:build_bsv reports
	$(MAKE) sim
all:
	$(MAKE) regress -j14 -O WAVES=0
regress: $(TESTS) $(DIRECTED_TESTS) reports
	dyu fcov-merge --pattern ".*coverage.xml"  --path .
$(TESTS): build_bsv reports
	COCOTB_RESULTS_FILE=$(REPORTS_PATH)/$@.xml TESTNAME=$@ $(MAKE) sim
$(PENDING_TESTS): build_bsv reports
	COCOTB_RESULTS_FILE=$(REPORTS_PATH)/$@.xml TESTNAME=$@ $(MAKE) sim
$(DIRECTED_TESTS):build_bsv reports
	COCOTB_RESULTS_FILE=$(REPORTS_PATH)/$@.xml TESTNAME=$@ MODULE=test_directed $(MAKE) sim
build_bsv:$(COPPER_ROOT)/bsv/bist.bsv
	$(MAKE) -C $(COPPER_ROOT)/bsv build
$(REPORTS_PATH):
	mkdir -p reports
include $(shell cocotb-config --makefiles)/Makefile.sim
