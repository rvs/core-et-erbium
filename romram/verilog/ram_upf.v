/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-06
 Description: A brief description of the file's purpose.
*/
module ram_upf#(parameter addr_width=9,parameter data_width=64)(
  input VDD,
  input VSS,
input wire SLP,
input wire DSLP,
  input SD,
input wire PUDELAY,
input wire CLK,
input wire CEB,
input wire WEB,
input wire [addr_width-1:0] A,
input wire [data_width -1 :0] D,
input wire [data_width -1 :0] BWEB,
input wire [1:0] RTSEL,
input wire [1:0] WTSEL,
output reg [data_width-1:0] Q
);
wire VDD_i;
reg [data_width-1:0] ram[2**addr_width-1:0];

// always_ff @(posedge CLK)begin
// 	if (~WEB)begin
// 		ram[A]<=(D & ~BWEB)|(ram[A] & BWEB);
// 	end
// 	Q<=ram[A];
// end
initial begin
`ifdef SRAM_HEXFILE
        $display("preloading `SRAM_HEXFILE hexfile");
	$readmemh(`SRAM_HEXFILE, ram);
`endif
forever begin
@(posedge CLK);
	if (~WEB)begin
		ram[A]<=(D & ~BWEB)|(ram[A] & BWEB);
	end
	Q<=ram[A];
end
end
endmodule
