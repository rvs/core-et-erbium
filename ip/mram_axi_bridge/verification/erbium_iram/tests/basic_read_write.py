import random

import cocotb
from cocotb.triggers import Timer

from tb import TEST_SEED, my_tb, seed_rng, sig_int


@cocotb.test()
async def basic_read_write(dut):
    """Perform basic 64-bit AXI writes followed by random readback checks."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("basic_read_write")
    await my_tb.reset_sequence()

    seed_rng(1)
    random.seed(TEST_SEED + 1)

    word_count = 256
    expected = bytearray(word_count * 8)

    for word_idx in range(word_count):
        data = random.getrandbits(64).to_bytes(8, "little")
        byte_addr = word_idx * 8
        await my_tb.axi_write(byte_addr, data, size=3)
        expected[byte_addr:byte_addr + 8] = data

    for _ in range(128):
        word_idx = random.randrange(word_count)
        byte_addr = word_idx * 8
        observed = await my_tb.axi_read(byte_addr, 8, size=3)
        if observed != expected[byte_addr:byte_addr + 8]:
            bank = my_tb.get_behavioral_bank(0)
            nonzero_cells = []

            for cell_idx in range(32):
                try:
                    cell_value = int(my_tb.get_behavioral_mem_word(0, cell_idx).value)
                except Exception:
                    continue
                if cell_value != 0:
                    nonzero_cells.append((cell_idx, hex(cell_value)))

            dut._log.error("first_bad_addr=0x%08x", byte_addr)
            dut._log.error("bank_busy=%d bank_sel=%d int_add=0x%x", sig_int(bank.busy), sig_int(bank.bank_sel), sig_int(bank.int_add))
            dut._log.error("nonzero_cells=%s", nonzero_cells[:8])
            assert observed == expected[byte_addr:byte_addr + 8]

    await Timer(100, unit="ns")
