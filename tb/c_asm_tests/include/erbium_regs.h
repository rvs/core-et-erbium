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


#ifndef ERBIUM_REGS_H
#define ERBIUM_REGS_H

#include <stdint.h>

#include "cpu_regs.h"
#include "fcc.h"

static inline void write_mem_reg (
    void (*write_fn)(uint32_t value),
    uint32_t value
) {
    if (get_hart_id() == 0) {
        DECL_REGMAP(cpu_regs);
        write_fn(value);
        FENCE;
        cpu_regs->cpu_registers.User_cpu.CREDINC0.w = -1LL; // FCC Thread 0
        cpu_regs->cpu_registers.User_cpu.CREDINC2.w = -1LL; // FCC Thread 1
    }
    wait_for_credit(0);
}

#define DEFINE_REG_FIELD_SETTER(prefix, regexpr, fieldname) \
    static void _set_##prefix##_##fieldname(uint32_t v) {   \
        DECL_REGMAP(cpu_regs);                              \
        (regexpr).f.fieldname = v;                          \
    }                                                       \
    void set_##prefix##_##fieldname(uint32_t v) {           \
        write_mem_reg(_set_##prefix##_##fieldname, v);      \
    }

#endif /* ERBIUM_REGS_H */
