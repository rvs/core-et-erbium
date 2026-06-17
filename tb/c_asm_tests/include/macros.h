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


#ifndef __MACROS
#define __MACROS

// Write to validation0 (0x8d0)
#define C_TEST_START      \
   __asm__ __volatile__ ( \
         "fence\n"\
         "lui  a7, 0xDEAD0\n" \
         "csrw 0x8d0, a7\n" \
         : : : "a7");

// Write to validation0 (0x8d0)
#define C_TEST_PASS       \
   __asm__ __volatile__ ( \
         "fence\n" \
         "lui a7, 0x1FEED\n" \
         "csrw 0x8d0, a7\n" \
         "1:wfi\n" \
         "j 1b\n" \
         : : : "a7");

// Write to validation0 (0x8d0)
#define C_TEST_FAIL \
   __asm__ __volatile__ ( \
         "fence\n"\
         "lui a7, 0x50BAD\n" \
         "csrw 0x8d0, a7\n" \
         "wfi\n" \
         : : : "a7");

#define ASM_TEST_FAIL \
   fence	   ;\
   lui a7, 0x50BAD; \
   csrw 0x8d0, a7; \
   wfi;

#define NOP  __asm__ __volatile__ ("nop\n");
#define FENCE __asm__ __volatile__ ("fence\n");
#define WFI __asm__ __volatile__ ("wfi\n");
#define WAIT_TENSOR_LOAD_0     __asm__ __volatile__ ( "csrwi 0x830, 0\n" : : );
#define WAIT_TENSOR_LOAD_1     __asm__ __volatile__ ( "csrwi 0x830, 1\n" : : );
#define WAIT_TENSOR_LOAD_L2_0  __asm__ __volatile__ ( "csrwi 0x830, 2\n" : : );
#define WAIT_TENSOR_LOAD_L2_1  __asm__ __volatile__ ( "csrwi 0x830, 3\n" : : );
#define WAIT_PREFETCH_0        __asm__ __volatile__ ( "csrwi 0x830, 4\n" : : );
#define WAIT_PREFETCH_1        __asm__ __volatile__ ( "csrwi 0x830, 5\n" : : );
#define WAIT_CACHEOPS          __asm__ __volatile__ ( "csrwi 0x830, 6\n" : : );
#define WAIT_TENSOR_FMA        __asm__ __volatile__ ( "csrwi 0x830, 7\n" : : );
#define WAIT_TENSOR_STORE      __asm__ __volatile__ ( "csrwi 0x830, 8\n" : : );
#define WAIT_TENSOR_REDUCE     __asm__ __volatile__ ( "csrwi 0x830, 9\n" : : );
#define WAIT_TENSOR_QUANT      __asm__ __volatile__ ( "csrwi 0x830, 10\n" : : );
#define STALL                  __asm__ __volatile__ ( "csrw stall, x0\n" : : );
#define CLEAR_TENSOR_ERROR     __asm__ __volatile__ ( "csrwi 0x808, 0" : : );
#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)

#endif // ! __MACROS
