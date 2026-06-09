//Custom Compiler Version T-2022.06-SP2
//Sat Jul  8 11:47:10 2023

////////////////////////////////////////////////////////////////////////////////
// Library          : argon
// Cell             : rom_instance_flat
// View             : schematic
// View Search List : symbol
// View Stop List   : functional behavioral symbol
////////////////////////////////////////////////////////////////////////////////
module rom_64kb_top_b0ec29e7e246d2b0e0a62d012df07f4a #(parameter data_width=64, parameter addr_width=10,parameter hexfile="bootrom.hex")( addr, ce, clk, ds, pwr_ok, rst_b, rd_out, vdd, vss);
    // Port declarations
    input [9:0]  addr;
    input ce;
    input clk;
    input ds;
    output pwr_ok;
    input rst_b;
    output [63:0]  rd_out;
    inout vdd;
    inout vss;
wire vdd_sw;

reg [data_width-1:0] rom[2**addr_width-1:0];
initial for (integer i=0;i<2**addr_width;i=i+1) rom[i]=32'b0;

	reg [63:0] r_rom_dout;
assign rd_out = r_rom_dout;
always_ff @(posedge clk)begin
	r_rom_dout <= rom[addr[addr_width -1:0]];
end

initial begin
        $display("Using Simulation model for bootrom");
        #1ps; //To avoid conflict with init 0x0 load
`ifndef BOOTROM_HEXFILE
	$readmemh("bootrom.hex", rom);
`else
        $display("Using `BOOTROM_HEXFILE hexfile  for bootrom");
	$readmemh(`BOOTROM_HEXFILE, rom);
`endif
	//$readmemb("bootrom.elf", rom);
end
endmodule //rom_64kb_top_b0ec29e7e246d2b0e0a62d012df07f4a

