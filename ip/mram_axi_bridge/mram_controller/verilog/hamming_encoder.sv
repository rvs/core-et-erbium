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

module hamming_encoder(
    input  wire [14:0] data_in,    // Input data bits M[14:0]
    output wire [19:0] codeword_out  // Output codeword bits
);

    // Assign data bits to an array for clarity
    wire [14:0] M;
    wire [4:0]  P;
    assign M = data_in;

    // Compute parity bits based on the given equations
    assign P[0] = M[0]  ^ M[1]  ^ M[3]  ^ M[4]  ^ M[6]  ^ M[8]  ^ M[10] ^ M[11] ^ M[13];
    assign P[1] = M[0]  ^ M[2]  ^ M[3]  ^ M[5]  ^ M[6]  ^ M[9]  ^ M[10] ^ M[12] ^ M[13];
    assign P[2] = M[1]  ^ M[2]  ^ M[3]  ^ M[7]  ^ M[8]  ^ M[9]  ^ M[10] ^ M[14];
    assign P[3] = M[4]  ^ M[5]  ^ M[6]  ^ M[7]  ^ M[8]  ^ M[9]  ^ M[10];
    assign P[4] = M[11] ^ M[12] ^ M[13] ^ M[14];
    assign codeword_out[0]  = P[0];
    assign codeword_out[1]  = P[1];
    assign codeword_out[2]  = M[0];
    assign codeword_out[3]  = P[2];
    assign codeword_out[4]  = M[1];
    assign codeword_out[5]  = M[2];
    assign codeword_out[6]  = M[3];
    assign codeword_out[7]  = P[3];
    assign codeword_out[8]  = M[4];
    assign codeword_out[9]  = M[5];
    assign codeword_out[10] = M[6];
    assign codeword_out[11] = M[7];
    assign codeword_out[12] = M[8];
    assign codeword_out[13] = M[9];
    assign codeword_out[14] = M[10];
    assign codeword_out[15] = P[4];
    assign codeword_out[16] = M[11];
    assign codeword_out[17] = M[12];
    assign codeword_out[18] = M[13];
    assign codeword_out[19] = M[14];

endmodule