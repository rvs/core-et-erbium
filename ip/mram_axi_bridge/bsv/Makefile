# bsv/Makefile
# Usage:
#   make verilog
#   make compile
#   make clean
#   make verilog TOP=mkAxi2Mram PKG=Axi2Mram
# From repo root:
#   make -C bsv verilog

SHELL := /bin/bash

# --- Paths (figure out repo root regardless of where make is invoked) ---
THIS_MAKE := $(lastword $(MAKEFILE_LIST))
BSV_DIR   := $(dir $(abspath $(THIS_MAKE)))
ROOT      := $(abspath $(BSV_DIR)/..)

# --- Tools / knobs you may override on the command line ---
BSC  ?= /tools/bluespec/2025.07/bin/bsc
BSC_RTS ?= +RTS -K128M -RTS
TOP  ?= mkAxi2Mram
PKG  ?= Axi2Mram
TOPFILE ?= $(BSV_DIR)/$(PKG).bsv

# --- Output dirs ---
BDIR     ?= $(ROOT)/build
INFO_DIR ?= $(BDIR)/info
SIMDIR   ?= $(BDIR)/sim
VDIR     ?= $(ROOT)/verilog

# --- Source sets (simple + safe: rebuild when any BSV changes) ---
BSV_SRCS := $(wildcard $(BSV_DIR)/*.bsv) \
            $(wildcard $(ROOT)/mram_controller/bsv/*.bsv)

# --- BSC search path (+: means "also search default libs") ---
# The top-level file's directory is already visible to bsc, so only add
# extra source roots here to avoid duplicate-path warnings.
BSV_PATH := +:$(ROOT)/mram_controller/bsv

# Put your “specific command string” pieces here:
BSCFLAGS ?=
BSCFLAGS += -p $(BSV_PATH)
BSCFLAGS += -bdir $(BDIR) -info-dir $(INFO_DIR) -simdir $(SIMDIR) -vdir $(VDIR)
BSCFLAGS += -show-range-conflict
BSCFLAGS += -suppress-warnings G0024
# Examples you might add:
# BSCFLAGS += -D SOME_DEFINE=1
# BSCFLAGS += -keep-fires -aggressive-conditions

BO := $(BDIR)/$(PKG).bo
GENV := $(VDIR)/$(TOP).v

.PHONY: all help compile verilog clean print
all: verilog

help:
	@echo "Targets:"
	@echo "  make compile            # builds $(BO)"
	@echo "  make verilog            # generates $(GENV) (+ deps) into $(VDIR)"
	@echo "  make clean              # removes generated outputs"
	@echo ""
	@echo "Vars you can override:"
	@echo "  TOP=mkAxi2Mram  PKG=Axi2Mram  BSC=bsc  BSC_RTS='+RTS -K128M -RTS'  BSCFLAGS='...'"

print:
	@echo "ROOT=$(ROOT)"
	@echo "TOP=$(TOP)  PKG=$(PKG)  TOPFILE=$(TOPFILE)"
	@echo "BDIR=$(BDIR)"
	@echo "VDIR=$(VDIR)"
	@echo "BSV_PATH=$(BSV_PATH)"

# Directory creation (order-only prereqs)
$(BDIR) $(INFO_DIR) $(SIMDIR) $(VDIR):
	@mkdir -p $@

compile: $(BO)

# Compile to .bo (bsc will chase imports via -p)
$(BO): $(BSV_SRCS) | $(BDIR) $(INFO_DIR) $(SIMDIR)
	$(BSC) $(BSC_RTS) $(BSCFLAGS) -u -g $(TOP) $(TOPFILE)

verilog: $(GENV)

# Generate Verilog for TOP (and any dependent modules)
$(GENV): $(BSV_SRCS) | $(BDIR) $(INFO_DIR) $(SIMDIR) $(VDIR)
	$(BSC) $(BSC_RTS) $(BSCFLAGS) -verilog -u -g $(TOP) $(TOPFILE)
	@test -f "$(GENV)" || (echo "Expected $(GENV) not found. Check TOP/PKG/TOPFILE."; exit 1)

clean:
	@rm -f "$(GENV)" \
	       "$(VDIR)/$(TOP).v" \
	       "$(VDIR)/$(TOP).sv" \
	       "$(VDIR)/$(TOP).vh" \
	       "$(VDIR)/$(TOP).svh"
	@rm -f "$(BDIR)/$(PKG).bo" "$(BDIR)/$(PKG).ba" "$(BDIR)/$(PKG).bi" "$(BDIR)/$(PKG).info"
