"""Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.

Author: Vijayvithal <jvs@nekko.ai>
Created on: 2026-12-09
Description: Bus Creator.
"""

from cocotb_bus.bus import Bus
from typing import ClassVar


class XspiBus(Bus):
    """For most cases the defaault bus creator in cocotb_bus is ok. Some protocols have edge cases that need to be handled here.

    1. Multiple names for the same signal. e.g. RDY vs not_busy
    2. relationship between signals that need to be checked e.g. byte_enable == width_of(data)/8
    3. Depending on version/profile have different lists of signals.
    """

    _signals: ClassVar[list[str]] = [
        "csn",
        "dq_in",
        "dq_out",
        "dq_out_ena",
        "rwds_in",
        "rwds_out",
        "rwds_out_ena",
        "clk",
    ]
    _optional_signals: ClassVar[list[str]] = ["clkn", "fsm"]

    def __init__(
        self,
        dut,
        prefix,
        bus_separator="_",
        case_insensitive=True,
        array_idx=None,
    ):
        """Init."""
        super().__init__(
            entity=dut,
            name=prefix,
            signals=self._signals,
            optional_signals=self._optional_signals,
            bus_separator=bus_separator,
            case_insensitive=case_insensitive,
            array_idx=array_idx,
        )
