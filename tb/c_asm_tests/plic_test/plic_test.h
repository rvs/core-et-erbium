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
#include <stdbool.h>

#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C
#endif

EXTERN_C void  __attribute__ ((interrupt)) machine_handler();

void machine_handler() __attribute__((interrupt("machine"), aligned(4096)));

#define MRET_TO_SMODE_END()                                      \
    do {                                                         \
        void *target;                                            \
        asm volatile (                                           \
            "auipc %0, 0\n\t"                                    \
            "addi %0, %0, 40\n\t"                                \
            "li t1, 0x1800\n\t"     /* reg holds large value */  \
            "csrc mstatus, t1\n\t"  /* clear using reg */        \
            "li t0, 0x800\n\t"     /* MPP=01, MIE=1 */           \
            "csrs mstatus, t0\n\t"                               \
            "csrw mepc, %0\n\t"                                  \
            "mret\n\t"                                           \
            "nop;nop;nop;nop\n\t"                                \
            : "=r"(target) : : "t0", "t1", "memory"              \
        );                                                       \
    } while(0)

    #define MRET_TO_UMODE_END()                                  \
    do {                                                         \
        void *target;                                            \
        asm volatile (                                           \
            "auipc %0, 0\n\t"                                    \
            "addi %0, %0, 32\n\t"                                \
            "li t1, 0x1800\n\t"     /* reg holds large value */  \
            "csrc mstatus, t1\n\t"  /* clear using reg */        \
            "csrw mepc, %0\n\t"                                  \
            "mret\n\t"                                           \
            "nop;nop;nop;nop\n\t"                                \
            : "=r"(target) : :"t1", "memory"                     \
        );                                                       \
    } while(0)
 