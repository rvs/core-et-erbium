import cocotb

from tb import WrapperTB


@cocotb.test()
async def smoke_reset_and_outputs(top):
    tb = WrapperTB(top)
    await tb.reset()

    for sig_name in ("axi_busy", "cpu_intr"):
        sig = getattr(tb.top, sig_name).value
        assert sig.is_resolvable, f"{sig_name} is unresolved after reset"
