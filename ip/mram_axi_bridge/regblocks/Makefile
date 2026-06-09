# Directories
PEAKRDL_DIR     := systemrdl
VERILOG_DIR     := verilog
PYTHON_DIR      := python

# Tool name
PEAKRDL_CMD     := peakrdl

# Prefer a repo-local PeakRDL environment with the python exporter plugin.
PEAKRDL_TOOL := $(shell \
	if [ -x venv/bin/$(PEAKRDL_CMD) ]; then \
		echo venv/bin/$(PEAKRDL_CMD); \
	elif [ -x ../mram_controller/regblocks/venv/bin/$(PEAKRDL_CMD) ]; then \
		echo ../mram_controller/regblocks/venv/bin/$(PEAKRDL_CMD); \
	elif command -v $(PEAKRDL_CMD) >/dev/null 2>&1; then \
		command -v $(PEAKRDL_CMD); \
	else \
		echo venv/bin/$(PEAKRDL_CMD); \
	fi)

# Top-level RDL (includes both bridge regs and mram_controller test regs)
TOP_RDL         := $(PEAKRDL_DIR)/top.rdl
BRIDGE_RDL      := $(PEAKRDL_DIR)/axi2mram_regs.rdl
MRAM_TREG_RDL   := ../mram_controller/regblocks/systemrdl/erbium_test_registers.rdl
MRAM_REGBLOCK_DIR := ../mram_controller/regblocks

# Build the mram_controller regblocks first (only when its inputs change).
MRAM_REGBLOCK_STAMP := .mram_regblocks.stamp
MRAM_REGBLOCK_SRCS := \
	$(wildcard $(MRAM_REGBLOCK_DIR)/systemrdl/*.rdl) \
	$(MRAM_REGBLOCK_DIR)/Makefile

# All RDL sources (for dependency tracking)
ALL_RDL         := $(TOP_RDL) $(BRIDGE_RDL) $(MRAM_TREG_RDL)

.PHONY: all clean check_peakrdl setup_venv python

all: check_peakrdl $(MRAM_REGBLOCK_STAMP) regblock python docs

$(MRAM_REGBLOCK_STAMP): $(MRAM_REGBLOCK_SRCS)
	$(MAKE) -C $(MRAM_REGBLOCK_DIR) all
	@touch $@

# Generate Verilog register block from the top-level addrmap
regblock: $(MRAM_REGBLOCK_STAMP) $(ALL_RDL)
	@mkdir -p $(VERILOG_DIR)
	$(PEAKRDL_TOOL) regblock $(TOP_RDL) -o $(VERILOG_DIR) \
		--cpuif axi4-lite-flat --peakrdl-cfg $(PEAKRDL_DIR)/peakrdl.toml

# Generate Python register access package
python: $(MRAM_REGBLOCK_STAMP) $(ALL_RDL)
	@mkdir -p $(PYTHON_DIR)
	$(PEAKRDL_TOOL) python --async $(TOP_RDL) -o $(PYTHON_DIR)

# Generate documentation
docs: $(MRAM_REGBLOCK_STAMP) $(ALL_RDL)
	$(PEAKRDL_TOOL) markdown $(TOP_RDL) -o README.md

# Check if peakrdl is available; if not, setup venv and install requirements
check_peakrdl:
	@test -x $(PEAKRDL_TOOL) || $(MAKE) setup_venv

# Setup venv and install requirements if peakrdl not found
setup_venv:
	@echo "peakrdl not found. Creating virtual environment and installing requirements..."
	python3 -m venv venv
	./venv/bin/pip install -r ../mram_controller/regblocks/requirements.txt
	@echo "Virtual environment created and peakrdl installed."

clean:
	rm -rf $(VERILOG_DIR)/*
	rm -rf $(PYTHON_DIR)/*
	rm -f README.md
	rm -f $(MRAM_REGBLOCK_STAMP)
