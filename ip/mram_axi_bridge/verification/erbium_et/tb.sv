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

module tb();
    logic [1023:0] tb_matrix_label;
    logic [31:0]   tb_matrix_step;

    initial begin
        tb_matrix_label = '0;
        tb_matrix_step = '0;
    end

    `ifdef DUMP_VPD
    initial begin
        $vcdplusfile("dump.vpd");
        $vcdpluson(0, dut);
    end
    `endif

    `ifdef DUMP_VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
    end
    `endif
    // Lint waiver (intentional): keep `dut()` minimally instantiated for cocotb
    // hierarchy-driven stimulus/inspection. This triggers TFIPC in VCS because
    // ports are intentionally left unconnected in this SV shell testbench.
    // See top-level README "Known lint waivers" section.
    axi2mram_et_wrapper #(
    ) dut ();
endmodule : tb
