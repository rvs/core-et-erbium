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

/* set_qspi_cr_qspi_enable(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, qspi_enable)

/* set_qspi_cr_abort(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, abort)

/* set_qspi_cr_dmaen(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, dmaen)

/* set_qspi_cr_tcen(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, tcen)

/* set_qspi_cr_sshift(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, sshift)

/* set_qspi_cr_dfm(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, dfm)

/* set_qspi_cr_fsel(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, fsel)

/* set_qspi_cr_fthres(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, fthres)

/* set_qspi_cr_teie(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, teie)

/* set_qspi_cr_tcie(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, tcie)

/* set_qspi_cr_ftie(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, ftie)

/* set_qspi_cr_smie(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, smie)

/* set_qspi_cr_toie(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, toie)

/* set_qspi_cr_apms(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, apms)

/* set_qspi_cr_pmm(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, pmm)

/* set_qspi_cr_prescaler(uint32_t v) */
DEFINE_REG_FIELD_SETTER(qspi_cr, cpu_regs->qspi_registers.CR, prescaler)
