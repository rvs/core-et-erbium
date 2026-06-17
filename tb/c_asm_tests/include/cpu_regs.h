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


// Helper header for C headers hal file
#pragma once

#include <stdint.h>

// PLEASE NOTE -> Run `make -C regblocks/systemrdl` to obtain this file!
#include "hal_cpu_mm.h"


typedef volatile ErbiumCPU_MemoryMap_t * cpu_regs_p;

#define INIT_REGMAP(x) x = (cpu_regs_p)(uintptr_t)0;
#define DECL_REGMAP(x) cpu_regs_p x = (cpu_regs_p)(uintptr_t)0;
