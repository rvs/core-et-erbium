/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-06
 Description: A brief description of the file's purpose.
*/
module ram#(parameter ADDRESS_WIDTH=9,parameter DATA_WIDTH=64)(
		input wire [ADDRESS_WIDTH-1:0] address,
		input wire clk,
		input wire deep_sleep,
		input wire rst_n,
		input wire isRead,
		input wire enable,
		input wire [DATA_WIDTH -1 :0] din,
		input wire [DATA_WIDTH -1 :0] bit_enable,
		output wire [DATA_WIDTH -1 :0] dout
	);
wire enable_n=~enable;
`ifdef SIMULATION
supply1 VDD;
supply0 VSS;
ram_upf ram(
            .VDD(VDD),
            .VSS(VSS),
`else
 ram_tsmc ram(
`endif
	.SLP(1'b0),
		.DSLP(1'b0),
		.SD(deep_sleep),
		.PUDELAY(),
		.CLK(clk),
		.CEB(enable_n),
		.WEB(isRead),
		.A(address[8:0]),
		.D(din),
		.BWEB(~bit_enable),
		.RTSEL(2'b01),
		.WTSEL(2'b00),
		.Q(dout)
	);

endmodule
