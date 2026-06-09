module ddr_o #( parameter BUS_WIDTH=1) (
input wire [BUS_WIDTH-1:0] data_re,
input wire [BUS_WIDTH-1:0] data_fe,
input wire ddr_mode,
output wire [BUS_WIDTH -1 : 0] dout,
input wire clk
);
wire sdr_mode=!ddr_mode;
assign dout = (clk||sdr_mode)? data_re:data_fe;
endmodule
