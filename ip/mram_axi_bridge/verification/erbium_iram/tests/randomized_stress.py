import random

import cocotb
from cocotb.triggers import Timer

from tb import TEST_SEED, my_tb, rand_bytes, seed_rng


@cocotb.test()
async def randomized_stress(dut):
    """Initialize a small address window, then mix random reads and writes."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("randomized_stress")
    await my_tb.reset_sequence()

    seed_rng(7)
    random.seed(TEST_SEED + 7)

    region_bytes = 4096
    expected = bytearray(region_bytes)
    size_list = [0, 1, 2, 3]
    init_size = 3
    init_chunk_bytes = 64

    for address in range(0, region_bytes, init_chunk_bytes):
        chunk_len = min(init_chunk_bytes, region_bytes - address)
        data = bytes(rand_bytes(chunk_len))
        dut._log.info(
            "init_write addr=0x%08x len=%d size=%d data=%s",
            address,
            chunk_len,
            init_size,
            data.hex(),
        )
        await my_tb.axi_write(address, data, size=init_size)
        expected[address:address + chunk_len] = data

    for _ in range(250):
        size = random.choice(size_list)
        byte_width = 1 << size
        length = byte_width * random.randint(1, 8)
        length = min(length, region_bytes)
        max_addr = region_bytes - length
        address = (random.randrange(max_addr + 1) // byte_width) * byte_width

        if random.randrange(2) == 0:
            data = bytes(rand_bytes(length))
            dut._log.info(
                "write addr=0x%08x len=%d size=%d data=%s",
                address,
                length,
                size,
                data.hex(),
            )
            await my_tb.axi_write(address, data, size=size)
            expected[address:address + length] = data
        else:
            observed = await my_tb.axi_read(address, length, size=size)
            dut._log.info(
                "read addr=0x%08x len=%d size=%d observed=%s expected=%s",
                address,
                length,
                size,
                observed.hex(),
                expected[address:address + length].hex(),
            )
            assert observed == expected[address:address + length]

    await Timer(100, unit="ns")
