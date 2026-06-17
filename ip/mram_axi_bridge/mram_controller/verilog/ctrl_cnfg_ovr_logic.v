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

module ctrl_cnfg_ovr_logic (
        input  [42:0]  treg_gbl_cfg_ovr,
        input          treg_gbl_cfg_ovr_en,
        inout  [42:0]  gbl_cfg,
        input          dsleep,
        input          treg_mram_dsleep_en,
        input          test_cal_en,
        output         mram_dsleep
    );

    assign  mram_dsleep    =  dsleep  |  treg_mram_dsleep_en;
    assign  gbl_cfg        =  (treg_gbl_cfg_ovr_en | test_cal_en) ? treg_gbl_cfg_ovr  :  {43{1'bz}};
    
endmodule

