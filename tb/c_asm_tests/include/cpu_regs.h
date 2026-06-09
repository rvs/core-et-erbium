
// Helper header for C headers hal file
#pragma once

#include <stdint.h>

// PLEASE NOTE -> Run `make -C regblocks/systemrdl` to obtain this file!
#include "hal_cpu_mm.h"


typedef volatile ErbiumCPU_MemoryMap_t * cpu_regs_p;

#define INIT_REGMAP(x) x = (cpu_regs_p)(uintptr_t)0;
#define DECL_REGMAP(x) cpu_regs_p x = (cpu_regs_p)(uintptr_t)0;
