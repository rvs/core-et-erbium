#
# Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
# Author: Vijayvithal <jvs@nekko.ai>
# Created on: 2026-01-05
# Description: A brief description of the file's purpose.
#
.ONESHELL:
SHELL=/bin/bash
BO_DIR ?= bo
TOP_FILE = ../verilog/mkRomRam.v
REPO_ROOT=../
rd=-remove-dollar
build_opts= -elab -p $(BSC_PATH) +RTS -K128M -RTS -u -verilog  -steps 10000000 -vdir $(REPO_ROOT)/verilog -bdir $(BO_DIR) -info-dir $(BO_DIR) -aggressive-conditions -no-warn-action-shadowing -no-show-timestamps -check-assert -show-range-conflict -keep-fires -keep-inlined-boundaries   $(rd) -u

all: clean bodir verilogdir build_bsv
build: bodir
	rm -rf *.bo || echo ""
	$(MAKE) build_bsv 

build_bsv: 
	bsc $(build_opts)   RomRam.bsv

verilogdir:
	mkdir -p ../verilog/
bodir:
	mkdir -p bo
clean:
	rm -rf bo/* ||echo ""
	rm -rf *.bo ||echo ""
