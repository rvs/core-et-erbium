FLUTE_REPO ?=/prj/tools/Flute
BO_DIR ?= bo
V_DIR ?= ../fpga/verilog
AWSTERIA_INFRA_REPO ?=/prj/tools/AWSteria_Infra
BLUESPEC_HOME ?=/tools/bluespec/2024
BSC_PATH := $(BSC_PATH):$(FLUTE_REPO)/src_Core/BSV_Additional_Libs
BSC_PATH := $(BSC_PATH):$(FLUTE_REPO)/src_Testbench/Fabrics/AXI4
BSC_PATH := $(BSC_PATH):$(FLUTE_REPO)/src_Testbench/Fabrics/AXI4_Lite
BSC_PATH := $(BSC_PATH):$(FLUTE_REPO)/src_Testbench/Fabrics/Adapters
BSC_PATH := $(BSC_PATH):$(AWSTERIA_INFRA_REPO)/Platform_AWSF1/HW/
BSC_PATH := $(BSC_PATH):+
build_opts= -elab -p $(BSC_PATH) +RTS -K128M -RTS -u -verilog -remove-dollar -steps 10000000 -vdir $(V_DIR) -bdir $(BO_DIR) -info-dir $(BO_DIR) -aggressive-conditions -no-warn-action-shadowing -no-show-timestamps -check-assert -show-range-conflict -keep-fires
default:
	echo $(BSC_PATH)
	bsc $(build_opts)  hb_wrapper.bsv
