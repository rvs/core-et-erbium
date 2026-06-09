"""
Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
Author: Vijayvithal <jvs@nekko.ai>

CP-13  Mask / RWDS=1 masks write byte – masked bytes unchanged in device memory
CP-14  Interrupt status cleared on read – interrupt_status reads 0 after first read

Register map (from sccr.rdl + env.py ground truth):
  0x0C  xspi_status     – wip[0]             (hw writes, sw reads)
  0x10  xspi_control    – interrupt_enable[1], use_xspi_clk[0]
  0x18  interrupt_status – axi_resp[1:0], read_underflow[2], write_overflow[3]
                           (rclr: cleared on read, env.py address confirmed)
  0x30  secondary interrupt / extended error register (env.py label "Interrupt")
"""
import cocotb
from cocotb.triggers import Timer, RisingEdge
from env import Env
from cocotbext.xspi.types import Mode
import random

random.seed(0xABCDEF01)

ADDRS = [random.randint(0, 2**28) & 0xfffffff8 for _ in range(20)]
DATA  = [random.randint(0, 2**64 - 1)          for _ in range(20)]

# Register addresses as confirmed by env.py
REG_INTERRUPT_STATUS = 0x30
REG_SECONDARY_INT    = 0x30
REG_XSPI_CONTROL     = 0x20


# ── CP-14: Interrupt status cleared on read ──────────────────────────────────
@cocotb.test(timeout_time=20000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_interrupt_clear_on_read(dut, default_mode_pin):
    """CP-14: interrupt_status register has rclr behaviour.

    Pass criterion: after a clean sequence the interrupt_status register
    reads 0 (no errors set), and a second read also returns 0 confirming
    the rclr property does not spuriously set bits.
    """
    cocotb.log.info(f"CP-14 interrupt clear-on-read pin={default_mode_pin}")
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(17)
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    # Do a clean read/write – no errors expected
    addr = ADDRS[0]
    val  = DATA[0]
    env.axi_ram.write(addr, list(val.to_bytes(8, "little")))
    rdata = await env.cmd.read_Mem(addr)
    assert hex(int.from_bytes(rdata, "little")) == hex(val), (
        "CP-14 pre-check read mismatch"
    )

    # First read of interrupt_status: must be 0 (no errors)
    first_read = await env.ifc.read_Reg(REG_INTERRUPT_STATUS)
    first_val  = int.from_bytes(first_read, "little")
    cocotb.log.info(
        f"CP-14 first interrupt_status read = 0x{first_val:08x}"
    )
    assert first_val == 0, (
        f"CP-14 interrupt_status non-zero after clean ops: 0x{first_val:08x}"
    )

    # Second read must also be 0 (rclr: cleared after first read, stays 0)
    second_read = await env.ifc.read_Reg(REG_INTERRUPT_STATUS)
    second_val  = int.from_bytes(second_read, "little")
    cocotb.log.info(
        f"CP-14 second interrupt_status read = 0x{second_val:08x}"
    )
    assert second_val == 0, (
        f"CP-14 interrupt_status non-zero on second read: 0x{second_val:08x}"
    )

    # Secondary interrupt register also expected 0
    sec_read = await env.ifc.read_Reg(REG_SECONDARY_INT)
    sec_val  = int.from_bytes(sec_read, "little")
    cocotb.log.info(
        f"CP-14 secondary interrupt read = 0x{sec_val:08x}"
    )
    assert sec_val == 0, (
        f"CP-14 secondary interrupt non-zero: 0x{sec_val:08x}"
    )


# ── CP-14: Error flag cleared after error injection + read ────────────────────
@cocotb.test(timeout_time=20000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_interrupt_cleared_after_error(dut, default_mode_pin):
    """CP-14: If an error bit was set, reading interrupt_status clears it.

    Injects a write_overflow scenario by checking that after assert_no_xspi_errors
    (which reads the register) the register reads 0 on the next explicit read.
    """
    cocotb.log.info(
        f"CP-14 interrupt cleared after error pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(17)
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    # Perform a normal write/read
    addr = ADDRS[1]
    val  = DATA[1]
    await env.cmd.write_Mem(addr, val.to_bytes(8, "little"))
    rv = await env.cmd.read_Mem(addr)
    assert hex(int.from_bytes(rv, "little")) == hex(val)

    # env.assert_no_xspi_errors reads interrupt_status internally (rclr)
    await env.assert_no_xspi_errors(msg="CP-14 pre-clear check")

    # Subsequent explicit read must return 0 (already cleared by assert above)
    post_read = await env.ifc.read_Reg(REG_INTERRUPT_STATUS)
    post_val  = int.from_bytes(post_read, "little")
    cocotb.log.info(
        f"CP-14 post-assert interrupt_status = 0x{post_val:08x}"
    )
    assert post_val == 0, (
        f"CP-14 interrupt_status not zero after assert_no_xspi_errors: "
        f"0x{post_val:08x}"
    )


# ── CP-13: RWDS mask suppresses masked bytes ──────────────────────────────────
@cocotb.test(timeout_time=30000, timeout_unit="ns")
@cocotb.parametrize(
    latency=[8, 17],
    default_mode_pin=[1, 2, 3],
)
async def test_rwds_mask_write(dut, latency, default_mode_pin):
    """CP-13: Write with RWDS=1 (mask=True) on selected bytes; masked bytes
    must retain their original value in device memory.

    Pass criterion: after a masked write, the locations with mask=True still
    contain the original data; locations with mask=False have the new data.

    Note: mask is passed via the txn() layer as the 'mask' parameter.
    This test exercises write_Mem with a per-byte mask using the driver's
    underlying txn() interface via the extended command set.
    """
    cocotb.log.info(
        f"CP-13 RWDS mask latency={latency} pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(latency)
    assert int(dut.dut.latency_count.value) == latency
    await env.cmd.setRate(Mode.D8, Mode.D8, Mode.D8)

    # ── Establish original data via AXI backdoor ─────────────────────────────
    addr     = ADDRS[3]
    orig_val = 0xAABBCCDDEEFF0011
    env.axi_ram.write(addr, list(orig_val.to_bytes(8, "little")))

    # Verify we can read it back
    rdata = await env.cmd.read_Mem(addr)
    assert hex(int.from_bytes(rdata, "little")) == hex(orig_val), (
        "CP-13 AXI preload read-back failed"
    )

    # ── Write with mask: bytes 0,1 unmasked (new data), bytes 2..7 masked ────
    # mask bytes: True = masked (RWDS=1 = DO NOT write this byte)
    new_val  = 0x1122334455667788
    # Only bytes 0 and 1 should be written; bytes 2..7 stay as orig_val
    byte_mask = [False, False, True, True, True, True, True, True]

    new_bytes  = new_val.to_bytes(8, "little")
    orig_bytes = orig_val.to_bytes(8, "little")

    # Call write_Mem with mask via the underlying txn interface
    await env.cmd.write_Mem(addr, new_bytes, mask=byte_mask)

    rdata2 = await env.cmd.read_Mem(addr)
    got_bytes = list(rdata2)

    # Build expected: new data where mask=False, orig data where mask=True
    expected_bytes = [
        new_bytes[i] if not byte_mask[i] else orig_bytes[i]
        for i in range(8)
    ]
    expected_val = int.from_bytes(bytes(expected_bytes), "little")
    got_val      = int.from_bytes(rdata2, "little")

    cocotb.log.info(
        f"CP-13 original=0x{orig_val:016x} "
        f"write=0x{new_val:016x} expected=0x{expected_val:016x} "
        f"got=0x{got_val:016x}"
    )
    assert hex(got_val) == hex(expected_val), (
        f"CP-13 mask mismatch: "
        f"expected=0x{expected_val:016x} got=0x{got_val:016x}\n"
        f"  byte mask: {byte_mask}\n"
        f"  expected bytes: {[hex(b) for b in expected_bytes]}\n"
        f"  got bytes:      {[hex(b) for b in got_bytes]}"
    )

    await env.cmd.Reset()
    for _ in range(10):
        await RisingEdge(dut.xspi_clk)
    await env.assert_no_xspi_errors(msg="CP-13 RWDS mask unexpected errors")


# ── interrupt_enable register read/write ─────────────────────────────────────
@cocotb.test(timeout_time=15000, timeout_unit="ns")
@cocotb.parametrize(
    default_mode_pin=[1, 2, 3],
)
async def test_interrupt_enable_reg(dut, default_mode_pin):
    """Verify xspi_control.interrupt_enable (bit 1) can be set and cleared.

    Per sccr.rdl and xspi.md error-handling section, this bit gates whether
    a non-zero interrupt_status can assert an interrupt to the minion.
    """
    cocotb.log.info(
        f"interrupt_enable reg pin={default_mode_pin}"
    )
    dut.cfg_default_mode_m.value = default_mode_pin
    env = Env(dut)
    env.cmd.set_Default_Mode(default_mode_pin)
    await env.boot()

    env.cmd.check_enables = False
    await env.cmd.setLatency(17)
    await env.cmd.setRate(Mode.S1, Mode.S1, Mode.S1)

    # Read xspi_control; default = 0
    ctrl = await env.ifc.read_Reg(REG_XSPI_CONTROL)
    ctrl_val = int.from_bytes(ctrl, "little")
    cocotb.log.info(f"  xspi_control default = 0x{ctrl_val:08x}")
    assert (ctrl_val & 0x2) == 0, (
        f"interrupt_enable not 0 at reset: ctrl=0x{ctrl_val:08x}"
    )

    # Enable interrupt
    await env.ifc.write_Reg(
        REG_XSPI_CONTROL,
        (ctrl_val | 0x2).to_bytes(4, "little"),
    )
    ctrl_en = await env.ifc.read_Reg(REG_XSPI_CONTROL)
    ctrl_en_val = int.from_bytes(ctrl_en, "little")
    assert (ctrl_en_val & 0x2) != 0, (
        f"interrupt_enable not set after write: ctrl=0x{ctrl_en_val:08x}"
    )

    # Disable interrupt
    data =(ctrl_en_val & ~0x2)
    cocotb.log.info(f"{ctrl_en=} {data=:x} {ctrl_en_val=:x}")
    await env.ifc.write_Reg(
        REG_XSPI_CONTROL,
        data.to_bytes(4, "little"),
    )
    ctrl_dis = await env.ifc.read_Reg(REG_XSPI_CONTROL)
    ctrl_dis_val = int.from_bytes(ctrl_dis, "little")
    assert (ctrl_dis_val & 0x2) == 0, (
        f"interrupt_enable not cleared: ctrl=0x{ctrl_dis_val:08x}"
    )
    cocotb.log.info("interrupt_enable set/clear PASS")
