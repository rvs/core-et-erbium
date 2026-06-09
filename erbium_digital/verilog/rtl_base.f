//+lint=TFIPC-L
+libext+.v
+libext+.sv
//-sverilog
//-full64
-y ${BSC_VLIB_TOP}/
${BSC_VLIB_TOP}/FIFO1.v
${BSC_VLIB_TOP}/SyncFIFO.v
${BSC_VLIB_TOP}/SyncFIFO1.v
${BSC_VLIB_TOP}/SizedFIFO.v
${BSC_VLIB_TOP}/Counter.v
${BSC_VLIB_TOP}/GatedClock.v
${BSC_VLIB_TOP}/FIFO2.v
${BSC_VLIB_TOP}/MakeReset0.v
-F ../../ring_osc/verilog/rtl.f
-F ../../tsense/verilog/rtl_base.f

../../ip/i2c/hdl/rtl/axis_fifo.v
../../ip/i2c/hdl/rtl/i2c_single_reg.v
../../ip/i2c/hdl/rtl/i2c_slave.v
../../ip/i2c/hdl/rtl/i2c_init.v
../../ip/i2c/hdl/rtl/i2c_master.v
../../ip/i2c/hdl/verilog/I2C_Reg_pkg.sv
../../ip/i2c/hdl/verilog/I2C_Reg.sv
../../ip/i2c/hdl/verilog/i2c_apb.v

../../ip/uart/verilog/uart.v
../../ip/qspi/verilog/qspi_32_64_0.v
-F ../../ip/xspi/verilog/rtl.f
-f ../../ip/cpu_subsystem/rtl/cpu_subsystem/cpu_subsystem_top_rtl.f
// NoC interconnect filelist (swap point). Default: open-source erbium_noc stub
// (NOC_FLIST is set in .autoenv.zsh). Override NOC_FLIST to point at a different
// NoC filelist, e.g. the proprietary NIC-700 (ip/ni700_ErbiumET).
-F ${NOC_FLIST}
-F ../../ip/mram_axi_bridge/verilog/rtl_et_base.f
-F ../../regblocks/verilog/rtl.f
-F ../../shakti_ip/verilog/rtl.f
-F ../../romram/verilog/rtl.f
-F ../../prcm/verilog/prcm.f
../../ERBIUM_DIGITAL_TOP/verilog/ERBIUM_DIGITAL_TOP_16MB.sv
erbium_digital_et.v
erbium_digital_et_aon.v
aon_ctrl.v
