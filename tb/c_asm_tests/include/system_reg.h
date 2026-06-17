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


#include "cpu_regs.h"
#include "erbium_regs.h"

/* set_system_config_sys_interrupt_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, sys_interrupt_enable)

/* set_system_config_mram_startup_bypass(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, mram_startup_bypass)

/* set_system_config_wdog_disable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, wdog_disable)

/* set_system_config_i2c_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, i2c_enable)

/* set_system_config_spi_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, spi_enable)

/* set_system_config_qspi_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, qspi_enable)

/* set_system_config_uart_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, uart_enable)

/* set_system_config_osc_out_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(system_config, cpu_regs->system_registers.SystemConfig, osc_out_enable)
