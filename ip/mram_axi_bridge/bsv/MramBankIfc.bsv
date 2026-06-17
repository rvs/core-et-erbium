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

package MramBankIfc;

import Vector :: *;
import Clocks :: *;

interface MRAM_Bank_IFC ;
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_dout (
        Bit #(128) dout_i
    );
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_busy (
        Vector #(8, Bool)  busy_i
    );
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_ready (
        Bool ready_i
    );
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_pwr_ok (
        Bool pwr_ok_i
    );
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_maintenance (
        Bool maintenance_i
    );
    (* always_ready, always_enabled, prefix = "" *)
    method Action get_ecc_triple_error (
        Bit #(2) ecc_triple_error_i
    );
    (* always_ready *) method Reset             rst_bo;
    (* always_ready *) method Clock             clk_o;
    (* always_ready *) method Vector #(8, Bool) ce_o;
    (* always_ready *) method Vector #(8, Bool) dout_en_o;
    (* always_ready *) method Bool              we_o;
    (* always_ready *) method Bit #(17)         addr_o;
    (* always_ready *) method Bit #(64)         din_o;
    (* always_ready *) method Bit #(64)         bwe_o;
endinterface

endpackage
