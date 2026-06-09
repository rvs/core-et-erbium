/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-06
 Description: A brief description of the file's purpose.
*/

module bootrom64_upf #(parameter data_width=64, parameter addr_width=10,parameter hexfile="bootrom.hex")(
	input wire [addr_width - 1 :0] addr,
  input wire ce,
	input wire clk,
	input wire ds,
	input wire rst_b,
	output wire [data_width - 1:0] rd_out,
  input wire vdd,
  input wire vss
);
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
endmodule
