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

#include <stdint.h>
#include <stdio.h>
#include "macros.h"
#include "minion.h"
#include "fcc.h"
#include "cpu_regs.h"

#define REG_READ(reg)      (*(volatile uint32_t *)&(reg))
#define REG_WRITE(reg, val) (*(volatile uint32_t *)&(reg) = (val))

#define REG_WRITE64(reg, val) (*(volatile uint64_t *)&(reg) = (val))

void program_ring_osc() {
    DECL_REGMAP(cpu_regs);
    ring_osc_ctrl_t reg = { .w = REG_READ(cpu_regs->system_registers.ring_osc) };
    reg.f.en         = 1;
    reg.f.divby2_sel = 0;
    reg.f.trm        = 27;
    REG_WRITE(cpu_regs->system_registers.ring_osc, reg.w);
    FENCE;
}

void program_cpu_divider() {
    DECL_REGMAP(cpu_regs);
    clock_divider_t reg = { .w = REG_READ(cpu_regs->system_registers.cpu_divider) };
    reg.f.count      = 0;
    reg.f.div_enable = 0;
    REG_WRITE(cpu_regs->system_registers.cpu_divider, reg.w);
    FENCE;
}

void program_system_divider() {
    DECL_REGMAP(cpu_regs);
    clock_divider_t reg = { .w = REG_READ(cpu_regs->system_registers.system_divider) };
    reg.f.count      = 3;
    reg.f.div_enable = 0;
    REG_WRITE(cpu_regs->system_registers.system_divider, reg.w);
    FENCE;
}

void program_periph_divider() {
    DECL_REGMAP(cpu_regs);
    clock_divider_t reg = { .w = REG_READ(cpu_regs->system_registers.periph_divider) };
    reg.f.count      = 0xF;
    reg.f.div_enable = 1;
    REG_WRITE(cpu_regs->system_registers.periph_divider, reg.w);
    FENCE;
}

void program_prcm() {
    DECL_REGMAP(cpu_regs);
    if (get_hart_id() == 0) {
        program_ring_osc();
        program_cpu_divider();
        program_system_divider();
        program_periph_divider();
        REG_WRITE64(cpu_regs->cpu_registers.User_cpu.CREDINC0, -1LL); // FCC Thread 0
        REG_WRITE64(cpu_regs->cpu_registers.User_cpu.CREDINC2, -1LL); // FCC Thread 1
    }
    wait_for_credit(0);
}
