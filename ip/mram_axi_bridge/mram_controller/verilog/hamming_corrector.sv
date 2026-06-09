module hamming_corrector(
    input  wire [19:0] codeword_in,
    output reg  [19:0] codeword_out,
    output reg  error_detected
);

    // Compute syndrome bits S[4:0]
    wire S0, S1, S2, S3, S4;

    assign S0 = codeword_in[0]  ^ codeword_in[2]  ^ codeword_in[4]  ^ codeword_in[6]  ^
                codeword_in[8]  ^ codeword_in[10] ^ codeword_in[12] ^ codeword_in[14] ^
                codeword_in[16] ^ codeword_in[18];

    assign S1 = codeword_in[1]  ^ codeword_in[2]  ^ codeword_in[5]  ^ codeword_in[6]  ^
                codeword_in[9]  ^ codeword_in[10] ^ codeword_in[13] ^ codeword_in[14] ^
                codeword_in[17] ^ codeword_in[18];

    assign S2 = codeword_in[3]  ^ codeword_in[4]  ^ codeword_in[5]  ^ codeword_in[6]  ^
                codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14] ^
                codeword_in[19];

    assign S3 = codeword_in[7]  ^ codeword_in[8]  ^ codeword_in[9]  ^ codeword_in[10] ^
                codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14];

    assign S4 = codeword_in[15] ^ codeword_in[16] ^ codeword_in[17] ^ codeword_in[18] ^
                codeword_in[19];

    // Combine syndrome bits into a single error position
    wire [4:0] error_position = {S4, S3, S2, S1, S0};

    // Correct the codeword if there's an error
    always @(*) begin
        codeword_out = codeword_in;
        if (error_position != 5'd0 && error_position <= 5'd20) begin
            codeword_out[error_position - 1] = ~codeword_in[error_position - 1];
            error_detected = 1'b1;
        end else if (error_position != 5'd0) begin
            // Syndrome indicates an error outside the codeword length
            error_detected = 1'b1;
        end else begin
            // No error detected
            error_detected = 1'b0;
        end
    end

endmodule
