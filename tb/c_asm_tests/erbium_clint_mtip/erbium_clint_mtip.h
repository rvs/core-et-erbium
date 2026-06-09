#ifndef CLINT_MTIP_H
#define CLINT_MTIP_H

extern "C" void  __attribute__ ((interrupt)) irq_handler();
extern "C" void  __attribute__ ((interrupt)) bad_trap();
extern "C" void mtrap_vector_v();

#endif //CLINT_MTIP_H
