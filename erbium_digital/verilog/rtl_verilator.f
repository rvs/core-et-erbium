//+lint=TFIPC-L
+libext+.v
+libext+.sv
//-sverilog
//-full64
-y ${BSC_VLIB_TOP}/
../../ip/mram_axi_bridge/mram_controller/testbench/erbium_et_bank_wrapper/stdcell_stubs.sv 


../../ip/i2c/hdl/rtl/axis_fifo.v
../../ip/i2c/hdl/rtl/i2c_single_reg.v
../../ip/i2c/hdl/rtl/i2c_slave.v
../../ip/i2c/hdl/rtl/i2c_init.v
../../ip/i2c/hdl/rtl/i2c_master.v
../../ip/i2c/hdl/verilog/I2C_Reg_pkg.sv
../../ip/i2c/hdl/verilog/I2C_Reg.sv
../../ip/i2c/hdl/verilog/i2c_apb.v

-F ../../ip/xspi/verilog/rtl.f
-f ../../ip/cpu_subsystem/rtl/cpu_subsystem/cpu_subsystem_top_rtl.f
// NoC interconnect filelist (swap point). Default: open-source erbium_noc stub
// (NOC_FLIST is set in .autoenv.zsh). Override NOC_FLIST to point at a different
// NoC filelist, e.g. the proprietary NIC-700 (ip/ni700_ErbiumET).
-F ${NOC_FLIST}
-F ../../ip/mram_axi_bridge/verilog/rtl_et_beh.f
-F ../../ip/mram_axi_bridge/verilog/rtl_et_base.f
-F ../../regblocks/verilog/rtl.f
-F ../../shakti_ip/verilog/rtl.f
-F ../../romram/verilog/rtl.f
-F ../../ring_osc/verilog/rtl.f
//      -f gates.f
 -F ../../prcm/verilog/prcm.f
erbium_digital_et.v
erbium_digital_et_aon.v
aon_ctrl.v
