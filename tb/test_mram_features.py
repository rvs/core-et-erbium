import os
import random

import cocotb
from cocotb.triggers import Timer

from env import ETEnv


def fmt_hex_word(data: bytes) -> str:
    """Format a byte payload as a zero-padded little-endian hex word."""
    return f"0x{int.from_bytes(data, 'little'):0{len(data) * 2}x}"


async def read_mem_bytes(
    xspi_cmd,
    address: int,
    byte_count: int,
    latency_offset_cycles: int = 0,
) -> bytes:
    """Read byte_count bytes from memory using burstlength-sized xSPI transfers."""
    prev_burst = xspi_cmd.burstlength
    prev_latency = xspi_cmd.latency
    # xspi_cmd.set_BurstLength(max(1, (byte_count + 7) // 8))
    if latency_offset_cycles:
        xspi_cmd.setLatency(prev_latency + latency_offset_cycles)
    try:
        data = await xspi_cmd.read_Mem(address)
    finally:
        # xspi_cmd.set_BurstLength(prev_burst)
        xspi_cmd.setLatency(prev_latency)
    return data[:byte_count]


MASK79 = (1 << 79) - 1


class TestMRAMFeaturesEnv(ETEnv):
    async def _read(self, addr: int, width: int, accesswidth: int):
        byte_width = max(width // 8, 8)
        result = 0
        for offset in range(0, byte_width, 8):
            rv = await self.ifc.read((addr + offset).to_bytes(4, "big"))
            chunk = int.from_bytes(rv[:8], "little")
            result |= chunk << (offset * 8)
        return result & ((1 << width) - 1)

    async def _write(self, addr: int, width: int, accesswidth: int, data: int):
        byte_width = max(width // 8, 8)
        for offset in range(0, byte_width, 8):
            chunk = (data >> (offset * 8)) & 0xFFFFFFFF_FFFFFFFF
            print(f"writing addr=0x{addr + offset:08x} data=0x{chunk:016x}")
            await self.ifc.write((addr + offset).to_bytes(4, "big"), chunk.to_bytes(8, "little"))


def get_bank_tregs(tb, bank: int):
    if not 0 <= bank < 4:
        raise ValueError(f"MRAM bank out of range: {bank}")
    return getattr(tb.reg.mram_registers, f"bank{bank}_tregs")


async def init_mram_control_fields(tregs):
    return dict(await tregs.mram_control.read_fields())


async def write_mram_control_fields(tregs, control_fields, *, mram_clk_single_pulse: int = 0, **kwargs):
    """Update the cached mram_control field image, then commit via pulse reg."""
    control_fields.update(kwargs)
    await tregs.mram_control.write_fields(**control_fields)
    await tregs.mram_control_pulse.write_fields(
        mram_clk_single_pulse=1 if mram_clk_single_pulse else 0
    )


async def setup_manual_treg_access(tb, bank: int):
    """Enable the selected bank for direct test-register driven accesses."""
    await tb.reg.mram_registers.bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)
    tregs = get_bank_tregs(tb, bank)
    control_fields = await init_mram_control_fields(tregs)
    await write_mram_control_fields(
        tregs,
        control_fields,
        test_reg_ovr_en=1,
        mram_clk_en=0,
        ce=0,
        we=0,
        dout_en=0,
    )
    return tregs, control_fields


async def pulse_manual_clock(tregs, count: int = 1):
    for _ in range(count):
        await tregs.mram_control_pulse.mram_clk_single_pulse.write(1)


async def pulse_until_idle(tregs, inst_sel: int, max_pulses: int = 32):
    for _ in range(max_pulses):
        await pulse_manual_clock(tregs)
        busy = await tregs.mram_status_1.busy.read()
        if (busy & inst_sel) == 0:
            return
    raise AssertionError(
        f"Timed out waiting for instance select 0x{inst_sel:02x} to go idle"
    )


async def manual_treg_write_word(tregs, control_fields, inst: int, addr: int, data: int, bwe: int = MASK79):
    inst_sel = 1 << inst
    await write_mram_control_fields(
        tregs,
        control_fields,
        we=1,
        ce=inst_sel,
        addr_in=addr,
    )
    await write_mram_control_fields(
        tregs,
        control_fields,
        bwe=bwe & MASK79,
        din=data & MASK79,
    )
    await pulse_until_idle(tregs, inst_sel)
    await write_mram_control_fields(
        tregs,
        control_fields,
        ce=0,
        we=0,
    )


async def manual_treg_read_word(tregs, control_fields, inst: int, addr: int) -> int:
    inst_sel = 1 << inst
    await write_mram_control_fields(
        tregs,
        control_fields,
        we=0,
        ce=inst_sel,
        addr_in=addr,
    )
    await pulse_until_idle(tregs, inst_sel)
    await write_mram_control_fields(
        tregs,
        control_fields,
        we=0,
        ce=0,
        dout_en=inst_sel,
    )
    await pulse_manual_clock(tregs, count=2)
    if inst % 2 == 0:
        lower = await tregs.mram_dout_even_lower.dout.read()
        upper = await tregs.mram_dout_uppers.dout_even_msb.read()
    else:
        lower = await tregs.mram_dout_odd_lower.dout.read()
        upper = await tregs.mram_dout_uppers.dout_odd_msb.read()
    await write_mram_control_fields(tregs, control_fields, dout_en=0)
    return (upper << 64) | lower


async def start_write_bist(tb, din, start_addr, stop_addr, bwe=MASK79,
                           loop_count=0, data_inv=0, add_inc=0,
                           stop_on_error=0, bank=0, wait=False,
                           mram_control_fields=None):
    """Start a write BIST operation on the specified MRAM bank.

    Args:
        din:           79-bit write/compare data pattern.
        start_addr:    20-bit BIST start address.
        stop_addr:     20-bit BIST stop address.
        bwe:           79-bit byte-write-enable mask (default all 1s).
        loop_count:    Number of extra loops (0 = run once).
        data_inv:      Invert din on odd loops (0 or 1).
        add_inc:       Address step power-of-two (0..7, step = 1 << value).
        stop_on_error: Stop on first compare mismatch (0 or 1).
        bank:          MRAM bank index (0-3).
        wait:          Poll bist_busy until BIST completes (default False).
    """
    tregs = get_bank_tregs(tb, bank)
    if mram_control_fields is None:
        mram_control_fields = await init_mram_control_fields(tregs)

    await write_mram_control_fields(
        tregs,
        mram_control_fields,
        sah_en=1,
        din=din & MASK79,
        mram_clk_en=1,
        bwe=bwe & MASK79,
        eccrom_deep_sleep=1,
        mram_clk_single_pulse=1,
    )

    # 3. Build bist_control (128-bit): config + arm + start in one write
    bist_ctrl = ((1 << 101)                              # bist_wr_en
                 | (1 << 98)                              # bist_rst_b
                 | (1 << 95)                              # bist_start (pulse)
                 | ((loop_count & 0xFFFF) << 79)          # bist_loop_count
                 | (0xA << 46)                            # RH4margin default
                 | ((stop_addr & 0xFFFFF) << 26)          # bist_stop_add
                 | ((start_addr & 0xFFFFF) << 6)          # bist_start_add
                 | ((stop_on_error & 1) << 5)             # bist_stop_on_error
                 | ((add_inc & 7) << 2)                   # bist_add_inc
                 | ((data_inv & 1) << 1))                 # bist_data_inv
    await tregs.bist_control.write(bist_ctrl)

    if wait:
        while await tregs.bist_status_1.bist_busy.read():
            await Timer(20, units="ns")


async def start_read_bist(tb, din, start_addr, stop_addr, bwe=MASK79,
                           loop_count=0, data_inv=0, add_inc=0,
                           stop_on_error=1, bank=0, wait=False,
                           mram_control_fields=None):
    """Start a read BIST operation on the specified MRAM bank.

    Args:
        din:           79-bit expected compare data pattern.
        start_addr:    20-bit BIST start address.
        stop_addr:     20-bit BIST stop address.
        bwe:           79-bit byte-write-enable / compare mask (default all 1s).
        loop_count:    Number of extra loops (0 = run once).
        data_inv:      Invert din on odd loops (0 or 1).
        add_inc:       Address step power-of-two (0..7, step = 1 << value).
        stop_on_error: Stop on first compare mismatch (default 1).
        bank:          MRAM bank index (0-3).
        wait:          Poll bist_busy until BIST completes (default False).
    """
    tregs = get_bank_tregs(tb, bank)
    if mram_control_fields is None:
        mram_control_fields = await init_mram_control_fields(tregs)

    await write_mram_control_fields(
        tregs,
        mram_control_fields,
        sah_en=1,
        din=din & MASK79,
        mram_clk_en=1,
        bwe=bwe & MASK79,
        eccrom_deep_sleep=1,
        mram_clk_single_pulse=1,
    )

    # 3. Build bist_control (128-bit): config + arm + start in one write
    bist_ctrl = ((1 << 100)                              # bist_rd_en
                 | (1 << 98)                              # bist_rst_b
                 | (1 << 95)                              # bist_start (pulse)
                 | ((loop_count & 0xFFFF) << 79)          # bist_loop_count
                 | (0xA << 46)                            # RH4margin default
                 | ((stop_addr & 0xFFFFF) << 26)          # bist_stop_add
                 | ((start_addr & 0xFFFFF) << 6)          # bist_start_add
                 | ((stop_on_error & 1) << 5)             # bist_stop_on_error
                 | ((add_inc & 7) << 2)                   # bist_add_inc
                 | ((data_inv & 1) << 1))                 # bist_data_inv
    await tregs.bist_control.write(bist_ctrl)

    if wait:
        while await tregs.bist_status_1.bist_busy.read():
            await Timer(20, units="ns")


@cocotb.test(timeout_time=1990000, timeout_unit="ns")
async def test_mram_features(dut):
    cocotb.log.info("Initializing ETEnv...")
    tb = TestMRAMFeaturesEnv(dut)
    cocotb.log.info("Beginning Test Reset...")
    await tb.reset()
    cocotb.log.info("Starting Test...")
    tb.start()
    data = await tb.xspi_cmd.read_SFDP(0x0)
    await tb.xspi_cmd.setLatency(0x17)
    id = await tb.reg.system_registers.Version.read_fields()
    assert id == {'chipid': 60264, 'respin': 0, 'variation': 0}, "Error chip id match failed"
    assert data[0:4] == b'SFDP'

    ############################################
    # MRAM Test
    ############################################
    cocotb.log.info("Checking MRAM Ready...")
    mram_ready = await tb.reg.mram_registers.bridge_regs.bridge_status_reg.mram_ready.read()
    cocotb.log.info(f"MRAM Status: {mram_ready:04b}")
    assert mram_ready == 0xf, "MRAM failed to bring up and be available at startup."

    cocotb.log.info("MRAM Available for Writes / Reads")
    test_values = [
        0xC001D00D_DEADBEEF,
        0xABADBABE_BAADF00D,
        0xFEE1DEAD_CAFEBABE,
        0xDEADC0DE_0BADC0DE,
        0x8BADF00D_FEEDFACE,
    ]
    addresses = [idx * 64 for idx in range(len(test_values))]

    await tb.reg.mram.write(0, test_values)
    cocotb.log.info("MRAM writes done -- starting batch reads.")

    readbacks = []
    for idx, addr in enumerate(addresses):
        rv = await read_mem_bytes(tb.xspi_cmd, addr, 64, latency_offset_cycles=1)
        readbacks.append(rv)
        cocotb.log.info(f"rv{idx}[64B] @0x{addr:08x} = {fmt_hex_word(rv)}")

    for idx, (addr, expected, raw) in enumerate(zip(addresses, test_values, readbacks)):
        actual = int.from_bytes(raw, "little")
        cocotb.log.info(
            f"check rv{idx} @0x{addr:08x}: expected=0x{expected:016x} actual=0x{actual:016x}"
        )
        assert actual == expected, (
            f"MRAM read mismatch idx={idx} addr=0x{addr:08x} "
            f"expected=0x{expected:016x} actual=0x{actual:016x}"
        )

    din_value = 0x12345678901234567890
    bwe_value = 0x7fffffffffffffffffff
    bank0_tregs = get_bank_tregs(tb, 0)
    bank0_control_fields = await init_mram_control_fields(bank0_tregs)
    await write_mram_control_fields(
        bank0_tregs,
        bank0_control_fields,
        din=din_value,
        bwe=bwe_value,
        mram_clk_single_pulse=1,
    )
    rv = await bank0_tregs.mram_control.read_fields()
    assert din_value == rv['din'], f"Return: {rv['din']:08x} vs Exp: {din_value:08x}"
    assert bwe_value == rv['bwe'], f"Return: {rv['bwe']:08x} vs Exp: {bwe_value:08x}"
    await tb.reg.mram_registers.bridge_regs.control_reg.write_fields(disable_clock_gate=0xF)
    await bank0_tregs.bist_control.bist_rst_b.write(0)
    await bank0_tregs.bist_control.bist_rst_b.write(1)
    await start_write_bist(
        tb,
        din=0x5555_5555_5555_5555 ^ din_value,
        start_addr=0,
        stop_addr=127,
        wait=True,
        mram_control_fields=bank0_control_fields,
    )
    await bank0_tregs.bist_control.bist_reset.write(1)
    await bank0_tregs.bist_control.bist_start.write(1)
    await bank0_tregs.bist_control.bist_reset.write(0)
    await bank0_tregs.bist_control.bist_start.write(0)

    await start_read_bist(
        tb,
        din=0x5555_5555_5555_5555 ^ din_value,
        start_addr=0,
        stop_addr=127,
        wait=True,
        mram_control_fields=bank0_control_fields,
    )

    bist_pattern = (0x5555_5555_5555_5555 ^ din_value) & MASK79
    bist_verify_tregs, bist_verify_control_fields = await setup_manual_treg_access(tb, bank=0)
    for addr in range(5):
        manual_readback = await manual_treg_read_word(
            bist_verify_tregs,
            bist_verify_control_fields,
            inst=0,
            addr=addr,
        )
        assert manual_readback == bist_pattern, (
            f"Manual tregs read of BIST data failed at bank=0 inst=0 addr=0x{addr:05x}: "
            f"expected=0x{bist_pattern:020x} actual=0x{manual_readback:020x}"
        )

    manual_bank = int(os.getenv("MANUAL_TREG_BANK", "0"), 0)
    manual_inst = 0
    manual_tregs, manual_control_fields = await setup_manual_treg_access(tb, manual_bank)
    manual_transactions = []
    for idx in range(10):
        addr = 0x140 + idx
        data = (0x1234567890ABCDEF1200 + idx) & MASK79
        manual_transactions.append((addr, data))
        await manual_treg_write_word(
            manual_tregs,
            manual_control_fields,
            manual_inst,
            addr,
            data,
        )

    for addr, expected in manual_transactions:
        manual_readback = await manual_treg_read_word(
            manual_tregs,
            manual_control_fields,
            manual_inst,
            addr,
        )
        assert manual_readback == expected, (
            f"Manual tregs write/read mismatch on bank={manual_bank} inst={manual_inst} "
            f"addr=0x{addr:05x}: expected=0x{expected:020x} actual=0x{manual_readback:020x}"
        )
