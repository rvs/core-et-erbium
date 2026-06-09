import random

import cocotb

from tb import TEST_SEED, my_tb, rand_bytes, seed_rng, sig_int


STATUS_REG_INDEX = 10
STATUS_CPU_INTR_FLAG_BIT = 32
STATUS_INTR_ERROR_ADDR_LSB = 12
STATUS_INTR_ERROR_ADDR_MASK = (1 << 20) - 1

RST_CPU_INTR_REG_INDEX = 2
RST_CPU_INTR_MASK = 1 << 34

# Fixed direct corruption masks that are known to trigger ECC 2-bit / 3-bit errors.
DIRECT_ECC_MASKS = {
    2: 0x3,
    3: 0x7,
}


def axi_byte_addr_to_word_addr(byte_addr):
    assert (byte_addr & 0x7) == 0, f"Expected 8-byte aligned address, got 0x{byte_addr:x}"
    return byte_addr >> 3


def word_addr_to_behavioral_index(word_addr):
    stripe_sel = (word_addr >> 17) & 0x3
    otp_space = (word_addr >> 19) & 0x1
    low_addr = word_addr & 0x1FFFF
    return (stripe_sel << 18) | (otp_space << 17) | low_addr


def decode_status_reg(status_value):
    return {
        "cpu_intr_flag": (status_value >> STATUS_CPU_INTR_FLAG_BIT) & 0x1,
        "intr_error_addr": (status_value >> STATUS_INTR_ERROR_ADDR_LSB) & STATUS_INTR_ERROR_ADDR_MASK,
    }


@cocotb.test()
async def cpu_interrupt_repair_sweep(dut):
    """Sweep reads across a window, service CPU interrupts, repair, and resume."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("cpu_interrupt_repair_sweep")
    await my_tb.reset_sequence()

    seed_rng(21)
    random.seed(TEST_SEED + 21)

    apb = my_tb.apb_master(0)

    base_byte_addr = 0x0020_0000
    word_count = 200
    injected_error_count = 10
    bytes_per_word = 8

    entries = []
    word_to_index = {}

    for word_idx in range(word_count):
        byte_addr = base_byte_addr + (word_idx * bytes_per_word)
        word_addr = axi_byte_addr_to_word_addr(byte_addr)
        payload = bytes(rand_bytes(bytes_per_word))

        entries.append(
            {
                "index": word_idx,
                "byte_addr": byte_addr,
                "word_addr": word_addr,
                "payload": payload,
            }
        )
        word_to_index[word_addr] = word_idx

        await my_tb.axi_write(byte_addr, payload, size=3)

    await my_tb.wait_for_axi_idle()

    error_indices = sorted(random.sample(range(word_count), injected_error_count))
    pending_errors = {}

    for error_ordinal, word_idx in enumerate(error_indices):
        entry = entries[word_idx]
        error_bits = random.choice((2, 3))
        mask = DIRECT_ECC_MASKS[error_bits]
        mem_idx = word_addr_to_behavioral_index(entry["word_addr"])
        mem_word = my_tb.get_behavioral_mem_word(0, mem_idx)
        clean_codeword = int(mem_word.value)
        corrupted_codeword = clean_codeword ^ mask
        mem_word.value = corrupted_codeword

        pending_errors[entry["word_addr"]] = {
            **entry,
            "error_bits": error_bits,
            "mask": mask,
            "mem_idx": mem_idx,
        }

        dut._log.info(
            "inject_error ordinal=%d idx=%d addr=0x%08x word_addr=0x%05x mem_idx=0x%05x bits=%d mask=0x%x",
            error_ordinal,
            entry["index"],
            entry["byte_addr"],
            entry["word_addr"],
            mem_idx,
            error_bits,
            mask,
        )

    async def clear_cpu_interrupt():
        control_reg_value = await apb.read64(RST_CPU_INTR_REG_INDEX)
        await apb.write64(RST_CPU_INTR_REG_INDEX, control_reg_value | RST_CPU_INTR_MASK)
        await my_tb.wait_clocks(2)
        await apb.write64(RST_CPU_INTR_REG_INDEX, control_reg_value & ~RST_CPU_INTR_MASK)
        await my_tb.wait_clocks(2)

        cleared_status = decode_status_reg(await apb.read64(STATUS_REG_INDEX))
        assert sig_int(dut.cpu_intr) == 0, "cpu_intr did not clear after rst_cpu_intr pulse"
        assert cleared_status["cpu_intr_flag"] == 0, "cpu_intr_flag status did not clear"
        assert cleared_status["intr_error_addr"] == 0, "intr_error_addr status did not clear"

    handled_error_count = 0
    read_idx = 0

    while read_idx < word_count:
        entry = entries[read_idx]
        observed = await my_tb.axi_read(entry["byte_addr"], bytes_per_word, size=3)
        await my_tb.wait_for_axi_idle()
        await my_tb.wait_clocks(2)

        if sig_int(dut.cpu_intr):
            status_value = await apb.read64(STATUS_REG_INDEX)
            status = decode_status_reg(status_value)
            error_word_addr = status["intr_error_addr"]

            assert status["cpu_intr_flag"] == 1, "status register did not reflect asserted cpu_intr"
            assert error_word_addr in pending_errors, (
                f"Interrupt reported unexpected error address 0x{error_word_addr:05x}; "
                f"pending={sorted(hex(addr) for addr in pending_errors)}"
            )

            error_entry = pending_errors[error_word_addr]
            dut._log.info(
                "service_interrupt read_idx=%d reported_idx=%d addr=0x%08x word_addr=0x%05x bits=%d observed=%s expected=%s",
                read_idx,
                error_entry["index"],
                error_entry["byte_addr"],
                error_entry["word_addr"],
                error_entry["error_bits"],
                observed.hex(),
                error_entry["payload"].hex(),
            )

            await clear_cpu_interrupt()

            await my_tb.axi_write(error_entry["byte_addr"], error_entry["payload"], size=3)
            await my_tb.wait_for_axi_idle()

            repaired = await my_tb.axi_read(error_entry["byte_addr"], bytes_per_word, size=3)
            await my_tb.wait_for_axi_idle()
            assert repaired == error_entry["payload"], (
                f"Repair write did not restore addr 0x{error_entry['byte_addr']:08x}: "
                f"observed={repaired.hex()} expected={error_entry['payload'].hex()}"
            )

            del pending_errors[error_word_addr]
            handled_error_count += 1
            read_idx = word_to_index[error_word_addr]
            continue

        if entry["word_addr"] in pending_errors:
            pending = pending_errors[entry["word_addr"]]
            raise AssertionError(
                f"Read corrupted addr 0x{entry['byte_addr']:08x} without cpu_intr: "
                f"error_bits={pending['error_bits']} observed={observed.hex()} "
                f"expected={entry['payload'].hex()}"
            )

        assert observed == entry["payload"], (
            f"Clean read mismatch at addr 0x{entry['byte_addr']:08x}: "
            f"observed={observed.hex()} expected={entry['payload'].hex()}"
        )

        read_idx += 1

    assert handled_error_count == injected_error_count, (
        f"Handled {handled_error_count} interrupts, expected {injected_error_count}"
    )
    assert not pending_errors, f"Unrepaired errors remain: {pending_errors}"
    assert sig_int(dut.cpu_intr) == 0, "cpu_intr remained asserted at end of sweep"
