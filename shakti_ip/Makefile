# Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
# Author: Vijayvithal <jvs@nekko.ai>
# Created on: 2026-01-13
# Description: A brief description of the file's purpose.
#
SHAKTI=../ip/shakti_uncore/
BSC_PARAMS=-u -no-warn-action-shadowing -verilog -elab -D axi4_internal_fifo_depth=1 -D axi4_transactor_fifo_depth=1 -D axi4_lite_internal_fifo_depth=1 -D axi4_lite_transactor_fifo_depth=1 -bdir ./build/hw/intermediate/ -info-dir ./build/hw/intermediate/ +RTS -K400M -RTS -check-assert  -keep-fires -opt-undetermined-vals -remove-false-rules -remove-empty-rules -remove-starved-rules -remove-dollar -unspecified-to X -show-schedule -steps-warn-interval 500000 -show-module-use -D VERBOSITY=2 -D simulate -D ASSERT=True -D nmasters= -D nslaves= -D simulate -D CORE_AXI4 -D paddr=32 -D debug_bus_sz=64 -vdir $(HDLET_ROOT)/shakti_ip/verilog 
all:qspi uart  bridge
bug:i2c
qspi:
	bsc $(BSC_PARAMS) -p bsv/:$(SHAKTI)/common_bsv/:$(SHAKTI)/fabrics/axi4/:$(SHAKTI)/fabrics/bridges/:$(SHAKTI)/fabrics/axi4lite/:%/Libraries: $(HDLET_ROOT)/shakti_ip/bsv/qspi_wrapper.bsv 
uart:                                                              
	bsc $(BSC_PARAMS) -p bsv:$(SHAKTI)/common_bsv/:$(SHAKTI)/fabrics/axi4/:$(SHAKTI)/fabrics/bridges/:$(SHAKTI)/fabrics/axi4lite/:%/Libraries:  $(HDLET_ROOT)/shakti_ip/bsv/uart_wrapper.bsv 
bridge:
	cd ../ip/shakti_uncore && bsc $(BSC_PARAMS) -p $(SHAKTI)common_bsv/:$(SHAKTI)fabrics/axi4/:$(SHAKTI)fabrics/bridges/:$(SHAKTI)fabrics/axi4lite/:%/Libraries:  $(HDLET_ROOT)/shakti_ip/bsv/axi42axil4.bsv
	bsc -u -verilog -p /prj/bsvlib/bdir:%/Libraries:  $(HDLET_ROOT)/shakti_ip/bsv/axi2apb_bridge.bsv
