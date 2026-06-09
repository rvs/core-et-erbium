# System power off
We need the ability to switch off power to the entire chip and then restore power whenever an AXI event occurs or the TMS signal is toggled.

This will mean
1. Creating an AON UPF domain
2. Assigning the wakeup circuit, and the signals that feed into it to AON domain.
3. Breaking the PRCM into PRCM_AON and PRCM domains.
4. PRCM_AON will contain the global por reset logic.
5. Pre reset the System_Power_off switch state cannot be guaranteed.
6. POR Reset should wake the system.
7. Write to a cfg bit in cpu registers should initiate power off.
8. In case of
	1. hyperbus, the poweroff should take place when CS goes high.
	2. AXI: We wait for bvalid/ready handshake to complete.
	3. AHB: we wait for hready to assert.
9. It is mandatory that the host not initiate another transaction for N cycles after writing to the system power off bit.


## Open Questions.

* We have an AON domain inside copper_digital which can be turned off. Can PnR UPF flow support this?
