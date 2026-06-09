.ONESHELL:
SHELL=/bin/bash
BO_DIR ?= bo
TOP_FILE = $(UART_ROOT)/verilog/mkUart.v
BSC_PARAMS=-u -no-warn-action-shadowing -verilog -elab -D axi4_internal_fifo_depth=1 -D axi4_transactor_fifo_depth=1 -D axi4_lite_internal_fifo_depth=1 -D axi4_lite_transactor_fifo_depth=1 -bdir ./build/hw/intermediate/ -info-dir ./build/hw/intermediate/ +RTS -K400M -RTS -check-assert  -keep-fires -opt-undetermined-vals -remove-false-rules -remove-empty-rules -remove-starved-rules -remove-dollar -unspecified-to X -show-schedule -steps-warn-interval 500000 -show-module-use -D VERBOSITY=2 -D simulate -D ASSERT=True -D nmasters= -D nslaves= -D simulate -D CORE_AXI4 -D paddr=32 -D debug_bus_sz=64 -vdir $(UART_ROOT)/verilog 

build_opts= $(BSC_PARAMS) -elab -p $(BSC_PATH) +RTS -K128M -RTS -u -verilog -remove-dollar -steps 10000000 -vdir $(UART_ROOT)/verilog -bdir $(BO_DIR) -info-dir $(BO_DIR) -aggressive-conditions -no-warn-action-shadowing -no-show-timestamps -check-assert -show-range-conflict -keep-fires

build: folders
	$(MAKE) build_bsv 
rdl:
	$(MAKE) -C ../systemrdl
folders:
	mkdir -p $(BO_DIR)
	mkdir -p $(UART_ROOT)/verilog/

build_bsv: 
	bsc $(build_opts)   uart_wrapper.bsv

