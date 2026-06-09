
module et_ecc_wrapper (
    input   logic           clk,
    input   logic           rst_b,
    input   logic [63:0]    data_to_encode_i,   // From the user
    output  logic [78:0]    ecc_encoded_data_o, // From the user, ECC Encoded to the MRAM.

    input   logic [157:0]   uncorrected_data_i, // From the MRAM
    output  logic [127:0]   corrected_data_o,   // From the MRAM, through the ECC, to the user.
    input   logic           ecc_bypass_en_i,
    input   logic           ref_ecc_sel_i,
    output  logic [1:0]     single_error_o,
    output  logic [1:0]     double_error_o,
    output  logic [1:0]     triple_error_o,
    input   logic           disable_ted_i
);
    logic [13:0] lower_parity;
    logic [13:0] upper_parity;
    logic [78:0] lower_bch_uncorrected_data;
    logic [78:0] upper_bch_uncorrected_data;
    logic [79:0] lower_ref_uncorrected_data;
    logic [79:0] upper_ref_uncorrected_data;
    logic [78:0] bch_encoded_data;
    logic [79:0] ref_encoded_data;
    logic [63:0] bch_data_to_encode;
    logic [63:0] ref_data_to_encode;
    logic [79:0] lower_ref_ecc_codeword;
    logic [79:0] upper_ref_ecc_codeword;
    logic [63:0] lower_bch_corrected_data;
    logic [63:0] upper_bch_corrected_data;
    logic [63:0] lower_ref_corrected_data_comb;
    logic [63:0] upper_ref_corrected_data_comb;
    logic [63:0] lower_ref_corrected_data_q1;
    logic [63:0] upper_ref_corrected_data_q1;
    logic [63:0] lower_ref_corrected_data_q2;
    logic [63:0] upper_ref_corrected_data_q2;
    logic [3:0]  lower_ref_ecc_error;
    logic [3:0]  upper_ref_ecc_error;
    logic [3:0]  lower_ref_ecc_error_q1;
    logic [3:0]  upper_ref_ecc_error_q1;
    logic [3:0]  lower_ref_ecc_error_q2;
    logic [3:0]  upper_ref_ecc_error_q2;
    logic        lower_bch_single_error;
    logic        lower_bch_double_error;
    logic        lower_bch_triple_error;
    logic        upper_bch_single_error;
    logic        upper_bch_double_error;
    logic        upper_bch_triple_error;
    logic [157:0] uncorrected_data_q;
    logic         ecc_bypass_en_q;
    logic         ref_ecc_sel_q;

    always_ff @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            uncorrected_data_q <= 158'b0;
            ecc_bypass_en_q    <= 1'b0;
            ref_ecc_sel_q      <= 1'b0;
        end else begin
            uncorrected_data_q <= uncorrected_data_i;
            ecc_bypass_en_q    <= ecc_bypass_en_i;
            ref_ecc_sel_q      <= ref_ecc_sel_i;
        end
    end

    assign lower_bch_uncorrected_data = ~ref_ecc_sel_q ? uncorrected_data_q[78:0] : 79'h0;
    assign upper_bch_uncorrected_data = ~ref_ecc_sel_q ? uncorrected_data_q[157:79] : 79'h0;
    assign lower_ref_uncorrected_data = ref_ecc_sel_q ? {1'b0, uncorrected_data_q[78:0]} : 80'h0;
    assign upper_ref_uncorrected_data = ref_ecc_sel_q ? {1'b0, uncorrected_data_q[157:79]} : 80'h0;
    assign bch_data_to_encode         = ~ref_ecc_sel_i ? data_to_encode_i : 64'h0;
    assign ref_data_to_encode         = ref_ecc_sel_i ? data_to_encode_i : 64'h0;
    assign ecc_encoded_data_o         = ref_ecc_sel_i ? ref_encoded_data[78:0] : bch_encoded_data;
    assign corrected_data_o           = {
        ref_ecc_sel_q ? upper_ref_corrected_data_q2 : upper_bch_corrected_data,
        ref_ecc_sel_q ? lower_ref_corrected_data_q2 : lower_bch_corrected_data
    };
    assign single_error_o             = ref_ecc_sel_q
                                        ? ({(|lower_ref_ecc_error_q2) , (|upper_ref_ecc_error_q2)})
                                        : ({upper_bch_single_error , lower_bch_single_error});
    assign double_error_o             = ref_ecc_sel_q
                                        ? 2'b00
                                        : ({upper_bch_double_error , lower_bch_double_error});
    assign triple_error_o             = ref_ecc_sel_q
                                        ? 2'b00
                                        : ({upper_bch_triple_error , lower_bch_triple_error});

    always_comb begin
        int j;
        j = 0;
        lower_ref_corrected_data_comb = '0;
        for (int i = 0; i < 80; i = i + 1) begin
            if (
                ((i % 20) == 0 ) ||
                ((i % 20) == 1 ) ||
                ((i % 20) == 3 ) ||
                ((i % 20) == 7 ) ||
                ((i % 20) == 15)
            ) begin

            end else begin
                lower_ref_corrected_data_comb[j] = lower_ref_ecc_codeword[i];
                j = j + 1;
            end
        end
        lower_ref_corrected_data_comb[63:60] = 4'h0;
    end

    always_comb begin
        int j;
        j = 0;
        upper_ref_corrected_data_comb = '0;
        for (int i = 0; i < 80; i = i + 1) begin
            if (
                ((i % 20) == 0 ) ||
                ((i % 20) == 1 ) ||
                ((i % 20) == 3 ) ||
                ((i % 20) == 7 ) ||
                ((i % 20) == 15)
            ) begin

            end else begin
                upper_ref_corrected_data_comb[j] = upper_ref_ecc_codeword[i];
                j = j + 1;
            end
        end
        upper_ref_corrected_data_comb[63:60] = 4'h0;
    end

    always_ff @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lower_ref_corrected_data_q1 <= '0;
            upper_ref_corrected_data_q1 <= '0;
            lower_ref_corrected_data_q2 <= '0;
            upper_ref_corrected_data_q2 <= '0;
            lower_ref_ecc_error_q1      <= '0;
            upper_ref_ecc_error_q1      <= '0;
            lower_ref_ecc_error_q2      <= '0;
            upper_ref_ecc_error_q2      <= '0;
        end else begin
            lower_ref_corrected_data_q1 <= lower_ref_corrected_data_comb;
            upper_ref_corrected_data_q1 <= upper_ref_corrected_data_comb;
            lower_ref_corrected_data_q2 <= lower_ref_corrected_data_q1;
            upper_ref_corrected_data_q2 <= upper_ref_corrected_data_q1;
            lower_ref_ecc_error_q1      <= lower_ref_ecc_error;
            upper_ref_ecc_error_q1      <= upper_ref_ecc_error;
            lower_ref_ecc_error_q2      <= lower_ref_ecc_error_q1;
            upper_ref_ecc_error_q2      <= upper_ref_ecc_error_q1;
        end
    end


    // BCH Encoding for regular data.
    et_bch_encoder u_ecc_encode_top(
        .data_in(bch_data_to_encode),             // Input data
        .encoded_out(bch_encoded_data)           // Encoded output
    );


    et_pipeline_bch_decode u_ecc_decode_lower(
        .clk(clk),
        .rst_n(rst_b),
        .received(lower_bch_uncorrected_data),              // Data to be corrected from memory
        .ecc_bypass_en(ecc_bypass_en_q),
        .corrected_data({lower_parity, lower_bch_corrected_data}),      // Output from the ECC that is corrected
        .no_error(),
        .single_bit_error(lower_bch_single_error),
        .double_bit_error(lower_bch_double_error),
        .triple_bit_error(lower_bch_triple_error),
        .uncorrectable()
    );

    et_pipeline_bch_decode u_ecc_decode_upper(
        .clk(clk),
        .rst_n(rst_b),
        .received(upper_bch_uncorrected_data),              // Data to be corrected from memory
        .ecc_bypass_en(ecc_bypass_en_q),
        .corrected_data({upper_parity, upper_bch_corrected_data}),      // Output from the ECC that is corrected
        .no_error(),
        .single_bit_error(upper_bch_single_error),
        .double_bit_error(upper_bch_double_error),
        .triple_bit_error(upper_bch_triple_error),
        .uncorrectable()
    );

    // Hamming Encoding for reference data.
    ref_ecc_encoder u_ref_ecc_encode_top (
        .data(ref_data_to_encode),          // input  wire  [63:0]
        .codeword_out(ref_encoded_data)   // output wire  [79:0]
    );

    ref_ecc_repair u_ref_ecc_decode_lower (
        .codeword_in(lower_ref_uncorrected_data),   // input  wire  [79:0]
        .codeword_out(lower_ref_ecc_codeword),  // output wire  [79:0]
        .error_detected(lower_ref_ecc_error)
    );

    ref_ecc_repair u_ref_ecc_decode_upper (
        .codeword_in(upper_ref_uncorrected_data),   // input  wire  [79:0]
        .codeword_out(upper_ref_ecc_codeword),  // output wire  [79:0]
        .error_detected(upper_ref_ecc_error)
    );

endmodule
