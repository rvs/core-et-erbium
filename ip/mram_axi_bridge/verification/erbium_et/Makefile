# Makefile
#VERILOG_SOURCES += $(PWD)/../verilog/mram.v
# use VHDL_SOURCES for VHDL files
ROOT := $(shell git rev-parse --show-toplevel)

# =============================================================================
# SLURM Detection - auto-submit to SLURM if not already in a job
# =============================================================================
IN_SLURM := $(if $(SLURM_JOB_ID),1,0)

# SLURM batch job settings (adjust as needed)
SLURM_PARTITION ?= batch
SLURM_TIME ?= 01:00:00
SLURM_CPUS ?= 4
SLURM_MEM ?= 8G

# =============================================================================
# BSV Source Tracking - rebuild Verilog from BSV if sources changed
# =============================================================================
BSV_DIR := $(ROOT)/bsv
BSV_SRCS := $(wildcard $(BSV_DIR)/*.bsv) \
            $(wildcard $(ROOT)/mram_controller/bsv/*.bsv)
BSV_GENERATED_V := $(ROOT)/verilog/mkAxi2Mram.v

# =============================================================================
# Verilog Sources
# =============================================================================
VERILOG_SOURCES += $(ROOT)/verification/erbium_et/tb.sv
VERILOG_INCLUDE_DIRS += $(ROOT)/mram_controller/verilog/
VERILOG_INCLUDE_DIRS += /tools/bluespec/2025.07/lib/Verilog/
RTL_FILELIST_DIR := $(ROOT)/verilog
RTL_FILELISTS := $(RTL_FILELIST_DIR)/rtl_et_base.f

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
#TOPLEVEL = mram

# MODULE is the basename of the Python test file
#
TOPLEVEL ?= tb
MODULE ?= tb

# defaults
SIM ?= vcs
SIM_BUILD ?= sim_build
COV_EN=0
BEHAVIORAL_BANK ?= 1
BYPASS_CONTROLLER ?= 0
CONTROLLER_BYPASS ?= $(BYPASS_CONTROLLER)
BYPASS_CONTROLLER := $(CONTROLLER_BYPASS)
DUMP_WAVES ?= $(WAVES)
DUMP_VPD ?= $(DUMP_WAVES)
DUMP_VCD ?= $(VCD)
export CONTROLLER_BYPASS
export BYPASS_CONTROLLER
ifeq ($(COV_EN),1)
PLUS_ARGS = -debug_access+all +vcs+dumpvars +vcs+dumpon
COMPILE_ARGS = -sverilog -cm line+cond+fsm+tgl+branch+assert -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
SIM_ARGS= -cm line+cond+fsm+tgl+branch+assert
else
PLUS_ARGS = -debug_access+all +vcs+dumpvars +vcs+dumpon
COMPILE_ARGS = -sverilog -full64 +vcs -q -notice +vcs+flush+all +vcs+lic+wait $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
endif
ifeq ($(BEHAVIORAL_BANK),1)
COMPILE_ARGS += +define+BEHAVIORAL_BANK
RTL_FILELISTS += $(RTL_FILELIST_DIR)/rtl_et_beh.f
endif
ifeq ($(CONTROLLER_BYPASS),1)
COMPILE_ARGS += +define+BYPASS_CONTROLLER
endif
ifeq ($(DUMP_VPD),1)
COMPILE_ARGS += +define+DUMP_VPD
endif
ifeq ($(DUMP_VCD),1)
COMPILE_ARGS += +define+DUMP_VCD
endif

COMPILE_ARGS += $(addprefix -F ,$(RTL_FILELISTS))

# Track all simulation-relevant inputs from the filelists:
# - explicit source files
# - -y library directories (all .v/.sv/.vh/.svh files inside)
# - +incdir+ include directories (.vh/.svh headers)
define abs_from_filelist
$(abspath $(if $(filter /%,$1),$1,$(RTL_FILELIST_DIR)/$1))
endef

RTL_FILELIST_EXPLICIT_ENTRIES := $(strip $(shell awk 'NF && $$1 !~ /^\/\// && $$1 !~ /^\+incdir\+/ && $$1 !~ /^-y/ && $$1 !~ /^-F/ { print $$1 }' $(RTL_FILELISTS)))
RTL_FILELIST_YDIR_ENTRIES := $(strip $(shell awk 'NF && $$1 !~ /^\/\// { if ($$1 == "-y" && NF >= 2) print $$2; else if ($$1 ~ /^-y[^[:space:]]+/) print substr($$1, 3); }' $(RTL_FILELISTS)))
RTL_FILELIST_INCDIR_ENTRIES := $(strip $(shell awk 'NF && $$1 !~ /^\/\// { if ($$1 ~ /^\+incdir\+/) print substr($$1, 9); }' $(RTL_FILELISTS)))

RTL_FILELIST_SRCS := $(sort $(foreach p,$(RTL_FILELIST_EXPLICIT_ENTRIES),$(call abs_from_filelist,$(p))))
RTL_FILELIST_YDIRS := $(sort $(foreach d,$(RTL_FILELIST_YDIR_ENTRIES),$(call abs_from_filelist,$(d))))
RTL_FILELIST_INCDIRS := $(sort $(foreach d,$(RTL_FILELIST_INCDIR_ENTRIES),$(call abs_from_filelist,$(d))))

RTL_FILELIST_YDIR_SRCS := $(sort $(foreach d,$(RTL_FILELIST_YDIRS), \
	$(wildcard $(d)/*.v) \
	$(wildcard $(d)/*.sv) \
	$(wildcard $(d)/*.vh) \
	$(wildcard $(d)/*.svh)))
RTL_FILELIST_HDRS := $(sort $(foreach d,$(RTL_FILELIST_INCDIRS), \
	$(wildcard $(d)/*.vh) \
	$(wildcard $(d)/*.svh)))

SIM_DEPS := $(VERILOG_SOURCES) $(RTL_FILELISTS) $(RTL_FILELIST_SRCS) $(RTL_FILELIST_YDIR_SRCS) $(RTL_FILELIST_HDRS)
#SIM_ARGS = +lint=all
TOPLEVEL_LANG ?= verilog
# =============================================================================
# Dependency Tracking
# =============================================================================
# Stamp file to track last successful sim build
SIM_STAMP := $(SIM_BUILD)/.sim_sources.stamp

# Rebuild BSV-generated Verilog if any BSV sources changed
$(BSV_GENERATED_V): $(BSV_SRCS)
	@echo "BSV sources changed, regenerating Verilog..."
	$(MAKE) -C $(BSV_DIR) verilog

# Stamp file depends on all Verilog sources - forces rebuild check
$(SIM_STAMP): $(SIM_DEPS)
	@echo "Simulation RTL dependencies changed; forcing sim rebuild..."
	@rm -rf $(SIM_BUILD)
	@mkdir -p $(SIM_BUILD)
	@touch $@

# Make sim depend on stamp file to ensure sources are checked
sim: $(SIM_STAMP)

# =============================================================================
# Clean targets
# =============================================================================
clean::
	rm -rf $(SIM_BUILD) __pycache__ *.xml *.vcd *.vpd *.fst *.wlf *.log

# =============================================================================
# Focused regressions
# =============================================================================
DELAYED_WRITE_BUSY_TESTCASE ?= delayed_write_busy_early_busy
DELAYED_WRITE_BUSY_DELAYS_PS ?= 0 800
empty :=
space := $(empty) $(empty)
comma := ,

.PHONY: delayed_write_busy_regression
delayed_write_busy_regression:
	$(MAKE) -C $(CURDIR) sim \
		TESTCASE=$(DELAYED_WRITE_BUSY_TESTCASE) \
		COCOTB_PLUSARGS="$(COCOTB_PLUSARGS) +mram_write_busy_rise_delay_sweep_ps=$(subst $(space),$(comma),$(DELAYED_WRITE_BUSY_DELAYS_PS))"


# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# =============================================================================
# SLURM Wrapper - intercept default target if not in SLURM
# =============================================================================
ifeq ($(IN_SLURM),0)
# Not in SLURM - submit via sbatch
.PHONY: run
run: $(SIM_STAMP)
	@echo "Not in SLURM job - submitting to SLURM..."
	sbatch --partition=$(SLURM_PARTITION) \
	       --time=$(SLURM_TIME) \
	       --cpus-per-task=$(SLURM_CPUS) \
	       --mem=$(SLURM_MEM) \
	       --job-name="cocotb-$(MODULE)" \
	       --output=slurm-%j.log \
	       --wrap="$(MAKE) -C $(CURDIR) sim"

# Interactive SLURM run (waits for completion)
.PHONY: srun
srun: $(SIM_STAMP)
	@echo "Not in SLURM job - running interactively via srun..."
	srun --partition=$(SLURM_PARTITION) \
	     --time=$(SLURM_TIME) \
	     --cpus-per-task=$(SLURM_CPUS) \
	     --mem=$(SLURM_MEM) \
	     $(MAKE) -C $(CURDIR) sim

.PHONY: delayed_write_busy_regression_srun
delayed_write_busy_regression_srun:
	@echo "Not in SLURM job - running delayed write-busy regression interactively via srun..."
	srun --partition=$(SLURM_PARTITION) \
	     --time=$(SLURM_TIME) \
	     --cpus-per-task=$(SLURM_CPUS) \
	     --mem=$(SLURM_MEM) \
	     $(MAKE) -C $(CURDIR) delayed_write_busy_regression

else
# Already in SLURM - run directly
.PHONY: run
run: sim
	@echo "Running in SLURM job $(SLURM_JOB_ID)"

.PHONY: srun
srun: sim
	@echo "Running in SLURM job $(SLURM_JOB_ID)"

.PHONY: delayed_write_busy_regression_srun
delayed_write_busy_regression_srun: delayed_write_busy_regression
	@echo "Running delayed write-busy regression in SLURM job $(SLURM_JOB_ID)"
endif
