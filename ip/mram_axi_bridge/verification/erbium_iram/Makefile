ROOT := $(shell git rev-parse --show-toplevel)
COCOTB_MAKEFILES_DIR := $(shell cocotb-config --makefiles)

IN_SLURM := $(if $(SLURM_JOB_ID),1,0)
SLURM_PARTITION ?= batch
SLURM_TIME ?= 01:00:00
SLURM_CPUS ?= 4
SLURM_MEM ?= 8G
BUILD_ARGS ?= -j$(SLURM_CPUS)

BSV_DIR := $(ROOT)/mram_controller/bsv
BSV_SRCS := $(wildcard $(BSV_DIR)/*.bsv)
BSV_GENERATED_V := $(ROOT)/mram_controller/verilog/mkBist.v

VERILOG_SOURCES += $(ROOT)/verification/erbium_iram/tb.sv
VERILOG_SOURCES += $(ROOT)/verilog/axi2mram.v
VERILOG_SOURCES += $(ROOT)/verilog/axi2mram_wrapper.sv
VERILOG_SOURCES += $(ROOT)/verilog/mram.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/bank.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/bist_mux.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/bist_wrapper.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/boot_sequencer.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/bwe_convert.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/clk_gate.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/cpu_intr_logic.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ctrl_cnfg_ovr_logic.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ctrl_mux.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ctrl_wrapper.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ecc_rom_wrapper.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ecc_wrapper.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/mram_wrapper.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/rom_16kb_top.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ref_ecc_encoder.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/ref_ecc_repair.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/mkBist.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/test_regs.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/hamming_corrector.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/hamming_encoder.sv
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/Counter.v
VERILOG_SOURCES += $(ROOT)/mram_controller/verilog/FIFO2.v
VERILOG_SOURCES += /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/verilog/tcbn16ffcllbwp7d5t16p96cpd_100b/tcbn16ffcllbwp7d5t16p96cpd.v

VERILOG_INCLUDE_DIRS += $(ROOT)/mram_controller/verilog

TOPLEVEL ?= tb
TOPLEVEL_LANG ?= verilog
SIM ?= vcs
BEHAVIORAL_BANK ?= 1
WAVES ?= 0

USER_MODULE := $(strip $(MODULE))
ifeq ($(USER_MODULE),)
TEST_MODULES ?= tb
else
TEST_MODULES := $(USER_MODULE)
undefine MODULE
endif

ifneq ($(findstring cocotb_tools,$(COCOTB_MAKEFILES_DIR)),)
COCOTB_TEST_MODULES ?= $(TEST_MODULES)
else
MODULE ?= $(TEST_MODULES)
endif

export PYTHONPATH := $(CURDIR):$(PYTHONPATH)

ifeq ($(SIM),verilator)
COMPILE_ARGS += --timing
COMPILE_ARGS += --top-module $(TOPLEVEL)
COMPILE_ARGS += -Wno-fatal -Wno-DECLFILENAME -Wno-EOFNEWLINE -Wno-PINCONNECTEMPTY -Wno-IMPLICIT
COMPILE_ARGS += $(addprefix -I,$(VERILOG_INCLUDE_DIRS))
ifeq ($(WAVES),1)
COMPILE_ARGS += -DDUMP_WAVES
COMPILE_ARGS += --trace-fst --trace-structs
SIM_ARGS += --trace
endif
else
PLUS_ARGS = -debug_access+all +vcs+dumpvars +vcs+dumpon
COMPILE_ARGS += -sverilog -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait
COMPILE_ARGS += $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
ifeq ($(WAVES),1)
COMPILE_ARGS += +define+DUMP_WAVES
endif
endif

ifeq ($(BEHAVIORAL_BANK),1)
ifeq ($(SIM),verilator)
COMPILE_ARGS += -DBEHAVIORAL_BANK
else
COMPILE_ARGS += +define+BEHAVIORAL_BANK
endif
endif

SIM_DEPS := $(VERILOG_SOURCES) $(wildcard $(CURDIR)/*.py) $(wildcard $(CURDIR)/tests/*.py)
SIM_STAMP := .sim_sources.stamp

$(BSV_GENERATED_V): $(BSV_SRCS)
	@echo "BSV sources changed, regenerating mkBist.v..."
	$(MAKE) -C $(BSV_DIR) build

$(SIM_STAMP): $(SIM_DEPS) $(BSV_GENERATED_V)
	@echo "Simulation sources changed; forcing rebuild..."
	@rm -rf sim_build
	@touch $@

sim: $(SIM_STAMP)

clean::
	rm -rf sim_build __pycache__ *.xml *.vcd *.fst *.wlf *.log $(SIM_STAMP)

include $(COCOTB_MAKEFILES_DIR)/Makefile.sim

ifeq ($(IN_SLURM),0)
.PHONY: run
run: $(SIM_STAMP)
	@echo "Not in SLURM job - submitting to SLURM..."
	sbatch --partition=$(SLURM_PARTITION) \
	       --time=$(SLURM_TIME) \
	       --cpus-per-task=$(SLURM_CPUS) \
	       --mem=$(SLURM_MEM) \
	       --job-name="cocotb-$(TEST_MODULES)" \
	       --output=slurm-%j.log \
	       --wrap="$(MAKE) -C $(CURDIR) sim"

.PHONY: srun
srun: $(SIM_STAMP)
	@echo "Not in SLURM job - running interactively via srun..."
	srun --partition=$(SLURM_PARTITION) \
	     --time=$(SLURM_TIME) \
	     --cpus-per-task=$(SLURM_CPUS) \
	     --mem=$(SLURM_MEM) \
	     $(MAKE) -C $(CURDIR) sim
else
.PHONY: run
run: sim
	@echo "Running in SLURM job $(SLURM_JOB_ID)"
endif
