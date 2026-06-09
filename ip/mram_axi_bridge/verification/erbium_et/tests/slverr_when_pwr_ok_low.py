import cocotb
from tb import *


@cocotb.test()
async def slverr_when_pwr_ok_low(dut):
    """Force MRAM power-not-ok via dsleep_mram_en and verify AXI SLVERR.

    This test uses bank test-register control to assert deep sleep
    (dsleep_mram_en=1), waits for pwr_ok to drop, then checks both write and
    read transactions return SLVERR while the bank is unpowered.
    """
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(610)

    axi_master = my_tb.axi_master
    reg_model = build_treg_reg_model(my_tb.axi_treg_master)

    # Keep clocks ungated for deterministic test-reg behavior.
    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )

    # Enter deep-sleep from test regs.
    await write_mram_control_fields(
        reg_model.bank0_tregs,
        dsleep_mram_en=1
    )

    # Wait until bank power status reflects deep-sleep.
    pwr_ok = 1
    for _ in range(100):
        pwr_ok = await reg_model.bank0_tregs.mram_status_1.pwr_ok.read()
        if pwr_ok == 0:
            break
        await Timer(10, unit="ns")
    assert pwr_ok == 0, "Expected bank0 pwr_ok to go low after dsleep_mram_en=1"

    async def read_slverr_status():
        raw = await my_tb.axi_treg_master.read(SLVERR_STATUS_REG_ADDR, 8)
        return int.from_bytes(raw.data, "little")

    async def assert_status_after_burst(op_desc):
        # slverr_status_reg is clear-on-read, so this read captures just-fired causes.
        status = await read_slverr_status()
        assert (status & (1 << 3)) != 0, (
            f"{op_desc}: expected mram_unpowered[3] set in slverr_status_reg, got 0x{status:016x}"
        )
        assert (status & ((1 << 2) | (1 << 3) | (1 << 4))) != 0, (
            f"{op_desc}: expected one of mram_not_ready/mram_unpowered/maintenance bits set, "
            f"got 0x{status:016x}"
        )

    # Clear stale sticky bits before per-burst checks.
    _ = await read_slverr_status()

    # Cover different read burst sizes (ARSIZE) and lengths (ARLEN) and verify:
    #   1) AXI response is SLVERR
    #   2) status register asserts power-state error immediately after each burst
    burst_sizes = list(range(7))  # 1B .. 64B beats
    read_base = 0x0000_0200
    MAX_BURST_BYTES = 4096

    # ARLEN/AWLEN are 8-bit fields (0..255), where beats = LEN+1 (1..256).
    def is_prime(n):
        if n < 2:
            return False
        d = 2
        while d * d <= n:
            if n % d == 0:
                return False
            d += 1
        return True

    all_prime_lens = [n for n in range(2, 256) if is_prime(n)]
    PRIME_SAMPLE_COUNT = 12
    if len(all_prime_lens) <= PRIME_SAMPLE_COUNT:
        prime_lens = all_prime_lens
    else:
        # Keep a compact but well-spread prime subset across the full range.
        prime_sample_idxs = sorted({
            round(i * (len(all_prime_lens) - 1) / (PRIME_SAMPLE_COUNT - 1))
            for i in range(PRIME_SAMPLE_COUNT)
        })
        prime_lens = [all_prime_lens[i] for i in prime_sample_idxs]
    pow2_beat_corners = [(1 << k) - 1 for k in range(0, 9)]  # 0,1,3,...,255
    pow2_field_corners = [1 << k for k in range(0, 8)]       # 1,2,4,...,128
    burst_lens = sorted(set(prime_lens + pow2_beat_corners + pow2_field_corners + [0, 255]))
    def req_bytes(size, length_field):
        return (1 << size) * (length_field + 1)

    case_idx = 0
    for size in burst_sizes:
        size_lens = [x for x in burst_lens if req_bytes(size, x) <= MAX_BURST_BYTES]
        for arlen in size_lens:
            beats = arlen + 1
            beat_bytes = 1 << size
            burst_bytes = beat_bytes * beats
            assert burst_bytes <= MAX_BURST_BYTES
            addr = read_base + (case_idx * 0x80)
            timeout_ns = max(2000, 200 + (beats * 40))

            read_op = axi_master.init_read(addr, burst_bytes, size=size)
            await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
            assert axi_resp(read_op) == AxiResp.SLVERR, (
                f"Unpowered read burst size={size} arlen={arlen} addr=0x{addr:08x}: "
                f"expected SLVERR, got {axi_resp(read_op)}"
            )
            await assert_status_after_burst(
                f"read burst size={size} arlen={arlen} bytes={burst_bytes} addr=0x{addr:08x}"
            )
            case_idx += 1

    # Cover different write burst sizes (AWSIZE) and lengths (AWLEN) with same checks.
    write_base = 0x0000_0600
    case_idx = 0
    for size in burst_sizes:
        size_lens = [x for x in burst_lens if req_bytes(size, x) <= MAX_BURST_BYTES]
        for awlen in size_lens:
            beats = awlen + 1
            beat_bytes = 1 << size
            burst_bytes = beat_bytes * beats
            assert burst_bytes <= MAX_BURST_BYTES
            addr = write_base + (case_idx * 0x80)
            timeout_ns = max(2000, 200 + (beats * 40))
            payload = bytes(rand_bytes(burst_bytes))

            write_op = axi_master.init_write(addr, payload, size=size)
            await cocotb.triggers.with_timeout(write_op.wait(), timeout_ns, "ns")
            assert axi_resp(write_op) == AxiResp.SLVERR, (
                f"Unpowered write burst size={size} awlen={awlen} addr=0x{addr:08x}: "
                f"expected SLVERR, got {axi_resp(write_op)}"
            )
            await assert_status_after_burst(
                f"write burst size={size} awlen={awlen} bytes={burst_bytes} addr=0x{addr:08x}"
            )
            case_idx += 1

    my_tb.dut._log.info("SLVERR on pwr_ok low verified across read/write size+len matrix")
    await Timer(100, unit="ns")
