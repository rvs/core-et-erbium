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

package qspi_wrapper;
import qspi::*;
`include "qspi.defines"
import device_common::*;

(*synthesize*)
module qspi_32_64_0#(Clock slow_clock, Reset slow_reset)(Ifc_qspi_axi4lite#(32,64,0) );
	let _tmp <- mkqspi_axi4lite(slow_clock,slow_reset,0,'hffffff);
	return _tmp;
endmodule

endpackage
