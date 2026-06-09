all:../verilog/HB_Reg.sv
../verilog/HB_Reg.sv:hb.rdl 
	peakrdl regblock --cpuif axi4-lite-flat --default-reset arst_n hb.rdl -o ../verilog
