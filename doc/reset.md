# Reset Table

The table below specifies the different reset domain in the design and the logic that is resetted by each reset.

| Reset Source | NIC | MRAM Ctrl | Hyperbus | Watchdog | Registers | HRESET | DEBUGResetn | ARM-POR |
| -----        | --- | ---       | ---      | ---      | ---       | ----   | ----        | --      |
| POR          | Rst | Rst       | Rst      | Rst      | Rst       | Rst    | ?           | Rst     |
| Watchdog     | Rst | X         | Rst      | X        | X         | Rst    | X           | Rst     |
| LOCKUP       | Rst | X         | Rst      | Rst      | X         | Rst    | X           | Rst     |
| SYSResetReq  | Rst | Rst       | Rst      | Rst      | Rst       | Rst    | X           | X       |
| SoftReset    | Rst | Rst       | Rst      | Rst      | Rst       | Rst    | X           | Rst     |
| TRSTn        | X   | X         | X        | X        | X         | X      | Rst         | X       |

POR sequence 
1. All systems are in reset at por.
2. The reset is held for as many cycles as recommended by PD team.
3. Components are brought out of reset one at a time.
4. This is the recommended sequence.
	5. NIC is brought out of reset.
	6. Registers are brought out of reset.
	7. If Pinmode indicates hyperbus, hyperbus is brought out of reset.
	7. If Pinmode indicates GCI, GCI   is brought out of reset.
	7. If Pinmode indicates AXI/AHB, the corresponding port is brought out of reset.
	8. Then CPUSystem is brought out of reset.
	9. In hyperbus mode. It writes to TCM, and the clears the wait field.
	10. ARM boot code brings mram out of deepsleep mode 
