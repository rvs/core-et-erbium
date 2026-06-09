
#include <cstddef>
#include "macros.h"
#include "minion.h"

constexpr size_t HARTS = 16;

constexpr uint64_t LCG_MUL = 164603309694725029ULL;
constexpr uint64_t LCG_MOD = 14738995463583502973ULL;

inline uint64_t lcg(uint64_t seed) {
    return (LCG_MUL * seed) % LCG_MOD;
}

inline void mem_fill(volatile uint64_t* mem, size_t n, uint64_t seed) {
    for (size_t i = 0; i < n; i++) {
        seed = lcg(seed);
        mem[i] = seed;
    }
}

inline void mem_verify(volatile uint64_t* mem, size_t n, uint64_t seed) {
    for (size_t i = 0; i < n; i++) {
        seed = lcg(seed);
        if (seed != mem[i]) {
            C_TEST_FAIL;
        }
    }
}

inline void mem_fill_parallel(volatile uint64_t* mem, size_t n, uint64_t seed) {

    const uint64_t hart  = get_hart_id();
    const size_t   chunk = n / HARTS;
    const size_t   start = hart * chunk;

    // Last HART takes the remainder
    const size_t end = (hart == HARTS - 1)
        ? n
        : start + chunk;

    // Make seed unique per HART
    seed ^= hart;

    // Each HART runs the same LCG sequence independently
    for (size_t i = start; i < end; i++) {
        seed = lcg(seed);
        mem[i] = seed;
    }
}

inline void mem_verify_parallel(volatile uint64_t* mem, size_t n, uint64_t seed) {

    const uint64_t hart  = get_hart_id();
    const size_t   chunk = n / HARTS;
    const size_t   start = hart * chunk;

    // Last HART takes the remainder
    const size_t end = (hart == HARTS - 1)
        ? n
        : start + chunk;

    // Make seed unique per HART
    seed ^= hart;

    for (size_t i = start; i < end; i++) {
        seed = lcg(seed);
        if (mem[i] != seed) {
            C_TEST_FAIL;
        }
    }
}
