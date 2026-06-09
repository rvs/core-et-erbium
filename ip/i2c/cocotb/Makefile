I2C_ROOT=$(shell git rev-parse --show-toplevel)

VERILOG_SOURCES +=$(I2C_ROOT)/hdl/rtl/i2c_slave_axil_master.v
VERILOG_SOURCES +=$(I2C_ROOT)/hdl/rtl/i2c_slave.v
VERILOG_SOURCES +=$(I2C_ROOT)/hdl/rtl/i2c_master.v
VERILOG_SOURCES +=$(I2C_ROOT)/hdl/verilog/I2C_Reg_pkg.sv 
VERILOG_SOURCES +=$(I2C_ROOT)/hdl/verilog/I2C_Reg.sv 
VERILOG_SOURCES +=$(I2C_ROOT)/hdl/verilog/i2c_apb.v
VERILOG_SOURCES +=$(I2C_ROOT)/cocotb/tb_axil_slave.v
VERILOG_SOURCES +=$(I2C_ROOT)/cocotb/tb_apb.v
MODULE=slave_axil_tb
TOPLEVEL=tb
COMPILE_ARGS= -f $(I2C_ROOT)/cocotb/flags.f
include $(shell cocotb-config --makefiles)/Makefile.sim
apb:
	$(MAKE) sim MODULE=test_apb TOPLEVEL=tb_apb 
	$(MAKE) sim MODULE=test_apb_comprehensive TOPLEVEL=tb_apb 
