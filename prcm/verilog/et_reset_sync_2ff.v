module et_reset_sync_2ff (input wire rst_in_n,
input wire clk,
input wire d,
output reg q);
parameter RESET_VALUE=0;
reg d0;
always@(posedge clk or negedge rst_in_n)begin
	if(!rst_in_n) begin
		d0<=RESET_VALUE;
		q<=RESET_VALUE;
	end else begin
		d0<=d;
		q<=d0;
	end
end
endmodule

