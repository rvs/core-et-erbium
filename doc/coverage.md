# Coverage Status.
![](./coverage_status_copper.png)
Exceptions were added for the following.

1. AXI, AHB signals that are not used in this design(Burst, Cache, Prot etc.)
2. Unused AXI Interface (Chiplet AHB & AXI, ChipID)
3. Initial Latency, Burst and wstrb logic in Hyperbus (We will need to write an hyperbus driver for this.)
4. Unused signals, dead code and case defaults. RTL was updated to remove the first two whereever possible.

Current status is 90+% line and toggle coverage on most logic except 
1. MRAM and ARM Code.

## Actions for improving coverage
1. Merge MRAM test coverage 
2. Port ARM unit tests to our cpu subsystem.
3. Write a Hyperbus driver.
4. Regenerate NIC to remove unused ports, feature and associated logic.
