all:../fpga/verilog/HB_Reg.sv
../fpga/verilog/HB_Reg.sv:hb.rdl 
	peakrdl regblock --cpuif axi4-lite-flat --default-reset arst_n hb.rdl -o ../fpga/verilog
	peakrdl python --async -o ../testbench hb.rdl  
clean:
	rm ../fpga/verilog/HB_Reg.sv
