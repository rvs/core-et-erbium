module MramBusyNegedgeReg (
    input  wire       RST_N,
    input  wire       BANK_CLK,
    input  wire       BANK_CLK_GATE,
    input  wire [7:0] D_IN,
    input  wire       EN,
    output reg  [7:0] Q_OUT
);
    always @(negedge BANK_CLK or negedge RST_N) begin
        if (!RST_N) begin
            Q_OUT <= 8'b0;
        end else if (EN) begin
            Q_OUT <= D_IN;
        end
    end
endmodule
