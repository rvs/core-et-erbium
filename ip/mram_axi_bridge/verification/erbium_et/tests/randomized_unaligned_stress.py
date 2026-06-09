import cocotb
from tb import *


@cocotb.test()
async def randomized_unaligned_stress(dut):
    """Randomized INCR-only stress with unaligned accesses."""
    import os

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(400)
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    SHADOW_SIZE = 64 * 1024
    shadow = bytearray(SHADOW_SIZE)

    # AXI sizes with meaningful alignment constraints (size=0 is always aligned).
    SIZES = [1, 2, 3, 4, 5, 6]
    BURST_LENS = [1, 2, 4, 8]

    num_iterations = int(os.environ.get("UNALIGNED_STRESS_ITERS", "4000"))
    timeout_base = 800  # ns

    OP_WEIGHTS = [
        ("write", 35),
        ("read", 30),
        ("partial_write", 15),
        ("rapid_same_bank", 10),
        ("verify_region", 10),
    ]
    total_weight = sum(w for _, w in OP_WEIGHTS)

    def pick_op():
        r = _rng.randint(0, total_weight - 1)
        cumulative = 0
        for name, weight in OP_WEIGHTS:
            cumulative += weight
            if r < cumulative:
                return name
        return OP_WEIGHTS[-1][0]

    def rand_unaligned_addr(size, length):
        """Return an address unaligned to the beat width for this size."""
        if length <= 0 or length > SHADOW_SIZE:
            return None

        max_addr = SHADOW_SIZE - length
        align_mask = (1 << size) - 1

        for _ in range(128):
            addr = _rng.randrange(0, max_addr + 1)
            if (addr & align_mask) != 0:
                return addr

        for addr in range(1, max_addr + 1):
            if (addr & align_mask) != 0:
                return addr

        return None

    async def do_write(addr, data, size):
        length = len(data)
        beat_width = 1 << size
        burst_len = max(1, length // beat_width)
        timeout = max(timeout_base, 120 * burst_len)
        await cocotb.triggers.with_timeout(
            axi_master.write(addr, bytes(data), size=size), timeout, "ns"
        )
        shadow[addr:addr + length] = data

    async def do_read_and_check(addr, length, size, label):
        beat_width = 1 << size
        burst_len = max(1, length // beat_width)
        timeout = max(timeout_base, 120 * burst_len)
        r_op = axi_master.init_read(addr, length, size=size)
        await cocotb.triggers.with_timeout(r_op.wait(), timeout, "ns")
        actual = axi_data(r_op)
        expected = bytes(shadow[addr:addr + length])
        assert actual == expected, (
            f"[{label}] mismatch @0x{addr:06x} size={size} len={length}: "
            f"expected {expected[:32].hex()}{'...' if length > 32 else ''}, "
            f"got {actual[:32].hex()}{'...' if length > 32 else ''}"
        )

    for iteration in range(num_iterations):
        op = pick_op()

        if op == "write":
            size = _rng.choice(SIZES)
            beat_width = 1 << size
            burst_len = _rng.choice(BURST_LENS if size <= 5 else [1, 2, 4])
            length = beat_width * burst_len
            addr = rand_unaligned_addr(size, length)
            if addr is None:
                continue
            data = bytearray(rand_bytes(length))
            await do_write(addr, data, size)

        elif op == "read":
            size = _rng.choice(SIZES)
            beat_width = 1 << size
            burst_len = _rng.choice(BURST_LENS if size <= 5 else [1, 2, 4])
            length = beat_width * burst_len
            addr = rand_unaligned_addr(size, length)
            if addr is None:
                continue
            await do_read_and_check(addr, length, size, f"unaligned_iter{iteration}_read")

        elif op == "partial_write":
            base_size = _rng.choice([3, 4, 5])
            base_width = 1 << base_size
            base_beats = _rng.choice([1, 2, 4])
            base_length = base_width * base_beats
            addr = rand_unaligned_addr(base_size, base_length)
            if addr is None:
                continue

            full_data = bytearray(rand_bytes(base_length))
            await do_write(addr, full_data, base_size)

            patch_size = _rng.choice([1, 2, 3, 4])
            patch_size = min(patch_size, base_size)
            patch_width = 1 << patch_size
            patch_beats = _rng.choice([1, 2])
            patch_length = patch_width * patch_beats
            if patch_length > base_length:
                patch_length = patch_width

            patch_offset = None
            max_off = base_length - patch_length
            for _ in range(64):
                candidate = _rng.randrange(0, max_off + 1)
                if ((addr + candidate) & (patch_width - 1)) != 0:
                    patch_offset = candidate
                    break
            if patch_offset is None:
                continue

            patch_data = bytearray(rand_bytes(patch_length))
            await do_write(addr + patch_offset, patch_data, patch_size)

            await do_read_and_check(
                addr,
                base_length,
                base_size,
                f"unaligned_iter{iteration}_partial"
            )

        elif op == "rapid_same_bank":
            # Keep addr[5:4] fixed, but force unaligned 8-byte accesses.
            bank = _rng.randrange(4)
            base = bank << 4
            records = []

            for inst_pair in range(4):
                addr = base + (inst_pair << 6) + 3  # +3 guarantees unaligned for size=3
                if addr + 8 > SHADOW_SIZE:
                    continue
                data = bytearray(rand_bytes(8))
                await do_write(addr, data, 3)
                records.append((addr, data))

            for addr, _ in records:
                await do_read_and_check(addr, 8, 3, f"unaligned_iter{iteration}_rapid")

        elif op == "verify_region":
            size = _rng.choice([4, 5, 6])
            beat_width = 1 << size
            beats = _rng.choice([1, 2, 4])
            length = beat_width * beats
            addr = rand_unaligned_addr(size, length)
            if addr is None:
                continue
            await do_read_and_check(addr, length, size, f"unaligned_iter{iteration}_verify")

        if iteration % 50 == 0:
            my_tb.dut._log.info(
                f"  Unaligned stress iteration {iteration}/{num_iterations} ({op})"
            )

    my_tb.dut._log.info("=== Final unaligned coherence sweep ===")
    for addr in range(1, 16384, 128):
        r_op = axi_master.init_read(addr, 128, size=3)
        await cocotb.triggers.with_timeout(r_op.wait(), 3000, "ns")
        actual = axi_data(r_op)
        expected = bytes(shadow[addr:addr + 128])
        if actual != expected:
            for j in range(128):
                if actual[j] != expected[j]:
                    my_tb.dut._log.error(
                        f"Unaligned sweep mismatch at AXI 0x{addr + j:06x}: "
                        f"expected 0x{expected[j]:02x}, got 0x{actual[j]:02x}"
                    )
                    break
            assert False, f"Final unaligned coherence failed at chunk 0x{addr:06x}"

    my_tb.dut._log.info(
        f"=== Randomized unaligned stress test passed ({num_iterations} iterations) ==="
    )
    await Timer(1000, unit="ns")
