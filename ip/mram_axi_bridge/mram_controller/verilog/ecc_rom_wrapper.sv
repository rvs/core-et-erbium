module ecc_rom_wrapper(
    input   logic           clk,
    input   logic           rst_b,

    input   logic   [7:0]   rom_add,
    input   logic           rom_ce,
    input logic             rom_ds,
    output  logic   [78:0]  rom_data,
    output logic            rom_pwr_ok
);
    logic [63:0] data_in;
    wire [79:0] codeword_out;
    reg [7:0] rom_add_q;
    wire [7:0] rom_add_d;
    rom_16kb_top rom_instance_flat_u (
        .addr(rom_add),
        .ce(rom_ce),
        .clk(clk),
        .ds(rom_ds),
        .pwr_ok(rom_pwr_ok),
        .rst_b(rst_b),
        .rd_out(data_in)
    );

    assign rom_add_d = rom_add;
    always @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            rom_add_q <= 0;
        end else begin
            rom_add_q <= rom_add_d;
        end
    end 

    ref_ecc_encoder ref_encoder(
        .data(data_in),
        .codeword_out(codeword_out)
    );

    always @*
        case(rom_add_q)
            00: rom_data = 79'h00000000000000000000;
            01: rom_data = 79'h00000000000000000008;
            02: rom_data = 79'h00002000000000000008;
            03: rom_data = 79'h00002000080000000008;
            04: rom_data = 79'h00022000080000000008;
            05: rom_data = 79'h00022000080000200008;
            06: rom_data = 79'h0002200008000020000a;
            07: rom_data = 79'h000220000a000020000a;
            08: rom_data = 79'h000220000a0000a0000a;
            09: rom_data = 79'h000220002a0000a0000a;
            10: rom_data = 79'h000220002a0000a0002a;
            11: rom_data = 79'h000220002a0002a0002a;
            72: rom_data = 79'h7fff7f7ff7f7ff7f7ff7;
            73: rom_data = 79'h7fff7f7ffff7ff7f7ff7;
            74: rom_data = 79'h7fff7f7ffff7ff7f7fff;
            75: rom_data = 79'h7fffff7ffff7ff7f7fff;
            76: rom_data = 79'h7fffff7ffff7ffff7fff;
            77: rom_data = 79'h7ffffffffff7ffff7fff;
            78: rom_data = 79'h7ffffffffff7ffffffff;
            79: rom_data = 79'h7fffffffffffffffffff;
            default: rom_data = codeword_out[78:0];
        endcase

endmodule
