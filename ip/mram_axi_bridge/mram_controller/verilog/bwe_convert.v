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

module bwe_convert (
                        input [7:0] bwe_in,
                        output [78:0]  bwe_out
                     );
    assign bwe_out = { {15{1'b1}},
                       {8{bwe_in[7]}},
                       {8{bwe_in[6]}},
                       {8{bwe_in[5]}},
                       {8{bwe_in[4]}},
                       {8{bwe_in[3]}},
                       {8{bwe_in[2]}},
                       {8{bwe_in[1]}},
                       {8{bwe_in[0]}}
                     };
endmodule
