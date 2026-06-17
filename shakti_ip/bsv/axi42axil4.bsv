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

import axi2axil::*;
(*synthesize*)
module axi2axil_64(Ifc_axi2axil#(32, 9, 64, 32, 64, 0));
let t<- mkaxi2axil();
//Ifc_axi2axil#(axi_addr, axi_id, axi_data, axil_addr, axil_data, user))
return t;
endmodule

(*synthesize*)
module axi2axil_32(Ifc_axi2axil#(32, 9, 64, 32, 32, 0));
let t<- mkaxi2axil();
//Ifc_axi2axil#(axi_addr, axi_id, axi_data, axil_addr, axil_data, user))
return t;
endmodule

