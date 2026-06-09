import Vector::*;
import SCCR_Reg_reg::*;

interface ConfigCSR_SCCR_Reg;
    interface ConfigReg_HW_ID0 id0;
interface ConfigReg_HW_ID1 id1;
interface ConfigReg_HW_CFG cfg;
interface ConfigReg_HW_xspi_status xspi_status;
interface ConfigReg_HW_xspi_control xspi_control;
interface ConfigReg_HW_xspi_rates xspi_rates;
interface ConfigReg_HW_interrupt_status interrupt_status;

    method Action write(Bit#(6) address, Bit#(64) data, Bit#(8) wstrb);
    method ActionValue#(Bit#(64)) read(Bit#(6) address);
endinterface
Bit#(6) address_ID0 = 0;
Bit#(6) address_ID1 = 8;
Bit#(6) address_CFG = 16;
Bit#(6) address_xspi_status = 24;
Bit#(6) address_xspi_control = 32;
Bit#(6) address_xspi_rates = 40;
Bit#(6) address_interrupt_status = 48;


(*synthesize*)
module mkConfigCSR_SCCR_Reg(ConfigCSR_SCCR_Reg);
    ConfigReg_ID0 reg_ID0 <- mkConfigReg_ID0();
ConfigReg_ID1 reg_ID1 <- mkConfigReg_ID1();
ConfigReg_CFG reg_CFG <- mkConfigReg_CFG();
ConfigReg_xspi_status reg_xspi_status <- mkConfigReg_xspi_status();
ConfigReg_xspi_control reg_xspi_control <- mkConfigReg_xspi_control();
ConfigReg_xspi_rates reg_xspi_rates <- mkConfigReg_xspi_rates();
ConfigReg_interrupt_status reg_interrupt_status <- mkConfigReg_interrupt_status();

    interface ConfigReg_HW_ID0 id0 = reg_ID0.hw;
interface ConfigReg_HW_ID1 id1 = reg_ID1.hw;
interface ConfigReg_HW_CFG cfg = reg_CFG.hw;
interface ConfigReg_HW_xspi_status xspi_status = reg_xspi_status.hw;
interface ConfigReg_HW_xspi_control xspi_control = reg_xspi_control.hw;
interface ConfigReg_HW_xspi_rates xspi_rates = reg_xspi_rates.hw;
interface ConfigReg_HW_interrupt_status interrupt_status = reg_interrupt_status.hw;

    method Action write(Bit#(6) address,Bit#(64) data,Bit#(8) wstrb);
     Vector#(8,Bit#(1)) wstrb_bin= unpack(wstrb);
     Vector#(64,Bit#(1)) wstrb_bin_64= concat(map(replicate,wstrb_bin));
     Bit#(64) wstrb_expanded=pack(wstrb_bin_64);

    if(address== address_ID0)reg_ID0.bus.write(data,wstrb_expanded);
if(address== address_ID1)reg_ID1.bus.write(data,wstrb_expanded);
if(address== address_CFG)reg_CFG.bus.write(data,wstrb_expanded);
if(address== address_xspi_status)reg_xspi_status.bus.write(data,wstrb_expanded);
if(address== address_xspi_control)reg_xspi_control.bus.write(data,wstrb_expanded);
if(address== address_xspi_rates)reg_xspi_rates.bus.write(data,wstrb_expanded);
if(address== address_interrupt_status)reg_interrupt_status.bus.write(data,wstrb_expanded);

    endmethod
    method ActionValue#(Bit#(64)) read(Bit#(6) address);
        let rv=0;
    if(address== address_ID0)rv<-reg_ID0.bus.read();
if(address== address_ID1)rv<-reg_ID1.bus.read();
if(address== address_CFG)rv<-reg_CFG.bus.read();
if(address== address_xspi_status)rv<-reg_xspi_status.bus.read();
if(address== address_xspi_control)rv<-reg_xspi_control.bus.read();
if(address== address_xspi_rates)rv<-reg_xspi_rates.bus.read();
if(address== address_interrupt_status)rv<-reg_interrupt_status.bus.read();

    return rv;
    endmethod
endmodule
                  
