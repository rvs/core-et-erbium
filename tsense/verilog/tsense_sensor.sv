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

`timescale 1ps/1ps

module tsense_sensor (
  input  logic en,
  output logic hc_tsense_vctat,
  output logic hc_tsense_vref
`ifdef GLS
  ,inout vdd,
  inout vdd18,
  inout vss
`endif
);

  assign hc_tsense_vctat = en ? 1'b1 : 1'bz;
  assign hc_tsense_vref  = en ? 1'b1 : 1'bz;

endmodule
