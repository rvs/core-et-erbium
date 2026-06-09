.ONESHELL:
SHELL=/bin/bash
BO_DIR ?= bo
export REPO_ROOT=$(shell git rev-parse --show-toplevel)
TOP_MODULES ?= mkBist mkEtBist
TOP_FILES := $(addprefix $(REPO_ROOT)/verilog/,$(addsuffix .v,$(TOP_MODULES)))
BSC_PATH = /tools/bluespec/2024/lib/Libraries/

build_opts= -elab -p +:.:$(BSC_PATH) +RTS -K128M -RTS -u -verilog -remove-dollar -steps 10000000 -vdir $(REPO_ROOT)/verilog -bdir $(BO_DIR) -info-dir $(BO_DIR) -aggressive-conditions -no-warn-action-shadowing -no-show-timestamps -check-assert -show-range-conflict

build:
	mkdir -p bo
	mkdir -p $(REPO_ROOT)/verilog/
	$(MAKE) build_bsv

build_bsv:
	bsc $(build_opts) -g mkBist bist.bsv
	bsc $(build_opts) -g mkEtBist etBist.bsv
