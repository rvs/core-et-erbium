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