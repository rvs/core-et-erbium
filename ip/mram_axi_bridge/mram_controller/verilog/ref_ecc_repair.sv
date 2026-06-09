module ref_ecc_repair(
    input  wire  [79:0] codeword_in,
    output wire  [79:0] codeword_out,
    output logic  [3:0] error_detected
);
    logic [79:0] data_shuffle;
    assign data_shuffle[74:0] = codeword_in[74:0];
    assign data_shuffle[79:76] = codeword_in[78:75];
    assign data_shuffle[75] = codeword_in[79];
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : hamming_decoders
            hamming_corrector section_inst (
                .codeword_in(data_shuffle[20*i + 19 : 20*i]),
                .codeword_out(codeword_out[20*i + 19 : 20*i]),
                .error_detected(error_detected[i])
            );
        end
    endgenerate

endmodule