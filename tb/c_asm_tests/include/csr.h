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


 

#ifndef __CSR_H
#define __CSR_H

inline void __attribute__((always_inline)) csr_write(uint16_t addr, uint64_t val)
{
    __asm__ __volatile__(
        "csrw %[addr],%[val]\n"
        :
        : [addr] "I" (addr), [val] "r" (val)
        :
    );
}

inline uint64_t __attribute__((always_inline)) csr_read(uint16_t addr)
{
  uint64_t ret;
   __asm__ __volatile__ ("csrr %[ret], %[addr]\n"
                         : [ret] "=r" (ret)
                         : [addr] "I" (addr)
                         :
  );
  return ret;
}






#endif // ! __CSR_H
