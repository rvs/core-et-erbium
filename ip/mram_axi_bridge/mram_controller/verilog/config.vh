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

`ifndef _CONFIG_VH_
`define _CONFIG_VH_

`define CONFIG_HAS_CARRY4 1
`define CONFIG_PIPELINE_LFSR 1
`define CONFIG_CONST_OP 1

`ifndef LUT_SZ
`define CONFIG_LUT_SZ 6
`endif

`ifndef LUT_MAX_SZ
`define CONFIG_LUT_MAX_SZ 8
`endif

`ifndef CONFIG_HAS_CARRY4
`define CONFIG_HAS_CARRY4 0
`endif

`ifndef CONFIG_PIPELINE_LFSR
`define CONFIG_PIPELINE_LFSR 0
`endif

`ifndef CONFIG_CONST_OP
`define CONFIG_CONST_OP 0
`endif

`endif
