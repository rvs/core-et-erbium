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


import Semi_FIFOF :: *;
import axi4_types:: *;
import Uart_Reg_csr::*;

interface Uart_Ifc;
   interface Ifc_axi4_master#(0,32,32,0) axi4;
endinterface

(*synthesize*)
module mkUart(Uart_Ifc);

   ConfigCSR_Uart_Reg csr <- mkConfigCSR_Uart_Reg();
   Ifc_axi4_master_xactor#(0,32,32,0) xactor <- mkaxi4_master_xactor(QueueSize {
   wr_req_depth: 1,
   wr_resp_depth: 1,
   rd_req_depth: 1,
   rd_resp_depth: 1}
);
   interface Ifc_axi4_master axi4 = xactor.axi4_side;
endmodule
