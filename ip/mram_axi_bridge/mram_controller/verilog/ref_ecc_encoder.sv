module ref_ecc_encoder(
    input  wire  [63:0] data,
    output wire  [79:0] codeword_out
);
    logic [79:0] encoded_word;
    // Taking the 75th bit, and placing it on the 79th bit (which is the parity column)
    //  The reason for this is because we don't normally read the redundant column but we
    //  have 80 bits for the encoder. Since the 75th bit in the encoder is always 0, this
    //  we can shift the upper bits down and always set the 80th bit of the decoder to 0
    //  in order pretend that the redundant column has been written to 0.
    assign codeword_out[74:0]  = encoded_word[74:0];
    assign codeword_out[78:75] = encoded_word[79:76];
    assign codeword_out[79]    = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : hamming_encoders
            hamming_encoder section_inst (
                .data_in(data[15*i + 14 : 15*i]),
                .codeword_out(encoded_word[20*i + 19 : 20*i])
            );
        end
    endgenerate

endmodule