"""Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.

Author: Vijayvithal <jvs@nekko.ai>
Created on: 2026-02-09
Description: Configuration for different vendor devices.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class XspiConfig:
    """Base Class. Timing constraints.

    Timing constraints for xSPI (JESD251C) and x4 Addendum.
    Values are typically in nanoseconds (ns).
    """

    # Clock Timing
    tCK: float = 5.0  # Clock cycle time (e.g., 5ns for 200MHz)
    tCH: float = 2.0  # Clock High Time
    tCL: float = 2.0  # Clock Low Time

    # Chip Select (CS#) Timing
    tCS_setup: float = 3.0  # CS# Setup Time (relative to CK)
    tCS_hold: float = 3.0  # CS# Hold Time
    tCS_high: float = 20.0  # CS# Deselect Time (Minimum time between transactions)

    # Data Timing
    tdata_setup = 1
    tdata_hold = 1
    # Data Strobe (RWDS) and DQ Timing
    tDSV: float = 0.5  # Data Strobe Valid to Output Data Valid (Read)
    tDSS: float = 0.8  # Data Strobe Setup Time (Write)
    tDSH: float = 0.8  # Data Strobe Hold Time (Write)

    # Reset and Power Management
    tPOR: float = 1000000.0  # Power-on Reset time (1ms default)
    tRP: float = 200.0  # Reset Pulse Width
    tREADY: float = 100.0  # Device Ready after Reset

    # Protocol Latency (expressed in cycles, but affects timing windows)
    default_latency_cycles: int = 16


default_config = XspiConfig()
