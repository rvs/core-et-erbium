import random

import cocotb

from tb import WrapperTB


@cocotb.test()
async def basic_axi_activity(top):
    tb = WrapperTB(top)
    await tb.reset()

    random.seed(11)
    for i in range(8):
        addr = i * 4
        data = random.getrandbits(64)
        await tb.issue_axi_write(addr=addr, data=data, stripe=0x1, byte_en=0xFF)

    await tb.wait_axi_idle()

    for i in range(8):
        _ = await tb.issue_axi_read(addr=i * 4, stripe=0x1)
