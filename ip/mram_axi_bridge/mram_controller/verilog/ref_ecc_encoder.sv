// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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