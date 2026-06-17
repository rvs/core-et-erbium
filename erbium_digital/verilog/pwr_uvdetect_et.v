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

module pwr_uvdetect_et( pwr_uv_b
`ifdef GLS
  , vdd18, vdd_c, vdd_d, vss
`endif
);

    // Port declarations

    output pwr_uv_b;
`ifdef GLS
    inout vdd18;
    inout vdd_c;
    inout vdd_d;
    inout vss;
`endif
    assign pwr_uv_b = 1;
endmodule

