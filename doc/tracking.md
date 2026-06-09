# Architecture close Tracking.|project:erbium +architecture
* [ ] OpenSource(Jose and team)  #b0557ceb
    * [ ] Setup CI/CD for Synopsys tools and figure out if/how to make it accessible.  #4c5071f3
    * [ ] Ensure code compiles with Verilator.  #9491755a
    * [ ] Port the testplan to cocotb/verilator+UVM  #dd2a758b
* [ ] Architecture  #f8ff2edc
    * [X] Boot Sequence  #0e350d07
    * [.] IO  #8aa9cbaf
        * [X] Freeze on IO  #dcfe5967
        * [X] QSPI  #d6ebb87a
        * [X] UART  #69ef9ce5
        * [ ] Identify IP's and source them.  #f66d15d9
        * [ ] I2C  #9958abcb
        * [ ] JTAG  #163ccb97
    * [.] Power, Reset and Clock Management  #41111ecd
        * [X] Cpu Subsystem only power domain or per minion power domain? Ans: Per Minion  #57a5de6d
        * [X] Signoff on reset signal implementation for neighborhood.  #bdc719d3
        * [ ] Port Watchdog from cpu_subsystem.  #b3e96152
        * [ ] Power Estimate  #2edadff3
    * [ ] Interrupts  #6b0f944e
        * [X] Finalize PLIC  #cf5d6bf8
        * [X] CLINT? (Timers)  #96429414
        * [ ] Finalize List of Interrupts.  #799969fc
    * [ ] IP  #7da3c097
        * [ ] Watchdog timer  #d608e359
    * [ ] Memory Map  #ef2b2730
        * [X] SystemReg  #994e0fc1
        * [ ] PeakRDL (Documentation/RTL/Verif/Firmware)  #f8e9cc28
        * [ ] NeighESR  #18816059
        * [ ] ShireESR  #a91e8ab7
        * [ ] PeriphReg  #1f06b4f4
        * [ ] PLIC  #3ef8eec6
    * [ ] DFT/DFM  #67c885d4
    * [ ] Debug  #02a7e07d
    * [ ] Physical Design  #3cf3c372
        * [X] Trial Run  #0bc90f2c
    * [ ] Verification  #d4fe553a
        * [X] Verification Plan  #60a64f17
        * [ ] SoC Plan  #8b860ffe
        * [ ] CPU Subsystem Plan  #f800f9a7
        * [ ] XSPI Plan  #b5a24b9f
        * [ ] 3rd party IP Plan  #ce760d8a
        * [ ] Github Runner  #4805a9ee
        * [ ] Need to setup Access token on Github  #8a17203e
        * [ ] List of testcases  #f712e38c
    * [ ] CPU Subsystem  #58d01b83
        * [X] Atomics Requirements from SoC  #aa2a959f
        * [X] Blackbox Entity  #3ce7334b
        * [X] Bandwidth  Requirements from SoC 64GB/s  #00fe6c53


* Atomics requires Exclusive access through AXI. Needs logic at MRAM
* Is MRAM providing 1 data/cycle or higher rate?
* 
# RTL close Tracking.|project:erbium +rtl
* [ ] Discuss Tetramax usage with Nishad.  #862c65ba
* [ ] Use Tetramax for JTAG Insertion for debug  #7927a846
* [ ] Use Tetramax for JTAG DFT (scan chain)  #b0b7b7c1
* [ ] RTL Activities  #86d2f61e
    * [X] Finish xSPI Coding  #96156429
    * [X] Integrate I2C  #0e5b180a
    * [X] Integrate QSPI  #075699eb
    * [X] Integrate UART.  #45056597
    * [X] generate NIC  #74b98907
    * [X] Integrate System Registers  #5e309053
    * [ ] Integrate chiptop  #c8692300
    * [ ] update PRCM  #5f3fddd7
    * [ ] Bootrom code + Wellnesscheck code FCLC  #dbfe7e36
    * [ ] Integrate MRAM  #b0e444f2
    * [ ] Integrate xSPI  #0fa53494
    * [ ] Create SRAM  #3708c816
        * [X] Create SRAM AXI Wrapper  #b3b29965
    * [ ] VCST  #368cce8c
# Verification close Tracking.|project:erbium +verification
* [ ] Port tests to Erbium-ET  #2d155feb
* [ ] Environments  #4d373a0a
    * [ ] Verification  #de2d9e0a
        * [ ] SOC ET Env Cocotb: with new IP's  #fde345a1
            * [ ] Debug Accessibility test  #23b6a205
                * [ ] GDB + JTAG  #769c38bc
                * [ ] GDB + Hyperbus  #601f5a02
                * [ ] GDB + UART  #df026e9b
            * [ ] Migration of Bootrom code to RISC-V assign:FCLC  #229de0ce
            * [ ] Compile with Verilator.  #af54f101
        * [ ] SOC iRAM Env Cocotb:  60+ tests  #a7f3c115
        * [ ] Unit UVM: XSPI and QSPI With Synopsys VIP  #ffdbabcb
            * [ ] xSPI  #4277cc9b
                * [ ] Cross coverage between rates, burst length, commands, address ranges  #ee276f74
                * [ ] Verify SFPD data.  #ef0f2449
                * [ ] Verify interop with QSPI Master.  #330f8eb3
                * [ ] Verify hyperbus behavior not tested in old code (burst and latency combinations)  #459589ed
        * [ ] SOC Cocotb: Chiptop  #017cc171
            * [ ] Chip level tests  #22ff9f04
                * [ ] Able to access each interface in each isotope.  #c0e34619
        * [ ] Unit: Chiptop with sllab's RTL. Offsite  #64f8586c
        * [ ] Unit SV: Neighborhood  #3bed4fcf
        * [ ] Unit UVM: MRAM  #c3a04004
            * [ ] MRAM Tests  #817b0855
                * [ ] Access from Minion, xSPI, JTAG, UART.  #b4f751d6
                * [ ] Verify different regions, data and OTP  #38f47aa2
                * [ ] Access to test registers  #67a40416
                * [ ] Exclusive access.  #3c83cfb8
                * [ ] Data Arbiteration logic  #956c79b9
                * [ ] Non Exclusive access  #cbd4300b
                * [ ] Different data width access from AXI (e.g. 64bit from xspi and 512 bit from cpu)  #3c94c208
                * [ ] Power control logic.  #4a8202b6
        * [ ] GLS Cocotb:  #fc3a1e5a
            * [ ] Zero Delay Sim  #6b76c2c7
            * [ ] Timing Sim  #b4def685
            * [ ] ATPG Tests  #285f4c2c
        * [ ] GPIO Tests.  #77889a97
            * [ ] Testmode  #29e5eb40
                * [ ] Change default boot minion.  #9670a91a
            * [ ] SPI/QSPI  #3410cf0f
                * [ ] Can talk to xSPI.  #9fb96c27
                * [ ] Can talk to popular memories.  #5ac60ed9
            * [ ] I2C Talk to different memories  #6129749f
            * [ ] UART Accessibility test  #31c6460b
            * [ ] Sram access test.  #dee5d52c
                * [ ]  From Minion  #d924308e
                * [ ] from xSPI, JTAG and UART.  #3df9869e
    * [ ] Validation  #caa5ecb1
        * [ ] SOC-FPGA  #246258f3
        * [ ] SOC: GDB +Hyperbus test  #d13cb01e
