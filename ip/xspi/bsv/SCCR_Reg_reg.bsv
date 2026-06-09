import SCCR_Reg_signal::*;

interface ConfigReg_HW_ID0;
    interface HW_ID0_mgf_id smgf_id;
interface HW_ID0_devid0 sdevid0;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_ID0;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_ID0;
interface ConfigReg_HW_ID0 hw;
interface ConfigReg_Bus_ID0 bus;
endinterface
module mkConfigReg_ID0(ConfigReg_ID0);
    Ifc_CSRSignal_ID0_mgf_id sig_mgf_id <- mkCSRSignal_ID0_mgf_id(2);
Ifc_CSRSignal_ID0_devid0 sig_devid0 <- mkCSRSignal_ID0_devid0(0);

interface ConfigReg_HW_ID0 hw;
    interface HW_ID0_mgf_id smgf_id = sig_mgf_id.hw;
interface HW_ID0_devid0 sdevid0 = sig_devid0.hw;

    method Bit#(64) value();
    let rv=0;
rv[3:0]=4'b0;
rv[15:4]=12'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_ID0 bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods
sig_mgf_id.bus.write(data[3:0],wstrb[3:0]);
sig_devid0.bus.write(data[15:4],wstrb[15:4]);

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_mgf_id<-sig_mgf_id.bus.read();
rv[3:0]=var_mgf_id;
let var_devid0<-sig_devid0.bus.read();
rv[15:4]=var_devid0;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_ID1;
    interface HW_ID1_dev_type sdev_type;
interface HW_ID1_devid1 sdevid1;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_ID1;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_ID1;
interface ConfigReg_HW_ID1 hw;
interface ConfigReg_Bus_ID1 bus;
endinterface
module mkConfigReg_ID1(ConfigReg_ID1);
    Ifc_CSRSignal_ID1_dev_type sig_dev_type <- mkCSRSignal_ID1_dev_type(0);
Ifc_CSRSignal_ID1_devid1 sig_devid1 <- mkCSRSignal_ID1_devid1(0);

interface ConfigReg_HW_ID1 hw;
    interface HW_ID1_dev_type sdev_type = sig_dev_type.hw;
interface HW_ID1_devid1 sdevid1 = sig_devid1.hw;

    method Bit#(64) value();
    let rv=0;
rv[3:0]=4'b0;
rv[15:4]=12'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_ID1 bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods
sig_dev_type.bus.write(data[3:0],wstrb[3:0]);
sig_devid1.bus.write(data[15:4],wstrb[15:4]);

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_dev_type<-sig_dev_type.bus.read();
rv[3:0]=var_dev_type;
let var_devid1<-sig_devid1.bus.read();
rv[15:4]=var_devid1;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_CFG;
    interface HW_CFG_BurstLength sBurstLength;
interface HW_CFG_HybridBurstEnable sHybridBurstEnable;
interface HW_CFG_FixedLatency sFixedLatency;
interface HW_CFG_InitialLatency sInitialLatency;
interface HW_CFG_Reserved sReserved;
interface HW_CFG_DriveStrength sDriveStrength;
interface HW_CFG_DeepPowerDown sDeepPowerDown;
interface HW_CFG_BurstEnable sBurstEnable;
interface HW_CFG_UltraDeepPowerDown sUltraDeepPowerDown;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_CFG;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_CFG;
interface ConfigReg_HW_CFG hw;
interface ConfigReg_Bus_CFG bus;
endinterface
module mkConfigReg_CFG(ConfigReg_CFG);
    Ifc_CSRSignal_CFG_BurstLength sig_BurstLength <- mkCSRSignal_CFG_BurstLength(2);
Ifc_CSRSignal_CFG_HybridBurstEnable sig_HybridBurstEnable <- mkCSRSignal_CFG_HybridBurstEnable(0);
Ifc_CSRSignal_CFG_FixedLatency sig_FixedLatency <- mkCSRSignal_CFG_FixedLatency(1);
Ifc_CSRSignal_CFG_InitialLatency sig_InitialLatency <- mkCSRSignal_CFG_InitialLatency(8);
Ifc_CSRSignal_CFG_Reserved sig_Reserved <- mkCSRSignal_CFG_Reserved(1);
Ifc_CSRSignal_CFG_DriveStrength sig_DriveStrength <- mkCSRSignal_CFG_DriveStrength(3);
Ifc_CSRSignal_CFG_DeepPowerDown sig_DeepPowerDown <- mkCSRSignal_CFG_DeepPowerDown(0);
Ifc_CSRSignal_CFG_BurstEnable sig_BurstEnable <- mkCSRSignal_CFG_BurstEnable(0);
Ifc_CSRSignal_CFG_UltraDeepPowerDown sig_UltraDeepPowerDown <- mkCSRSignal_CFG_UltraDeepPowerDown(0);

interface ConfigReg_HW_CFG hw;
    interface HW_CFG_BurstLength sBurstLength = sig_BurstLength.hw;
interface HW_CFG_HybridBurstEnable sHybridBurstEnable = sig_HybridBurstEnable.hw;
interface HW_CFG_FixedLatency sFixedLatency = sig_FixedLatency.hw;
interface HW_CFG_InitialLatency sInitialLatency = sig_InitialLatency.hw;
interface HW_CFG_Reserved sReserved = sig_Reserved.hw;
interface HW_CFG_DriveStrength sDriveStrength = sig_DriveStrength.hw;
interface HW_CFG_DeepPowerDown sDeepPowerDown = sig_DeepPowerDown.hw;
interface HW_CFG_BurstEnable sBurstEnable = sig_BurstEnable.hw;
interface HW_CFG_UltraDeepPowerDown sUltraDeepPowerDown = sig_UltraDeepPowerDown.hw;

    method Bit#(64) value();
    let rv=0;
rv[1:0]=sig_BurstLength.hw;
rv[2:2]=sig_HybridBurstEnable.hw;
rv[3:3]=sig_FixedLatency.hw;
rv[7:4]=sig_InitialLatency.hw;
rv[11:8]=4'b0;
rv[14:12]=sig_DriveStrength.hw;
rv[15:15]=sig_DeepPowerDown.hw;
rv[16:16]=sig_BurstEnable.hw;
rv[17:17]=sig_UltraDeepPowerDown.hw;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_CFG bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods
sig_BurstLength.bus.write(data[1:0],wstrb[1:0]);
sig_InitialLatency.bus.write(data[7:4],wstrb[7:4]);
sig_DeepPowerDown.bus.write(data[15:15],wstrb[15:15]);
sig_BurstEnable.bus.write(data[16:16],wstrb[16:16]);
sig_UltraDeepPowerDown.bus.write(data[17:17],wstrb[17:17]);

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_BurstLength<-sig_BurstLength.bus.read();
rv[1:0]=var_BurstLength;
let var_HybridBurstEnable<-sig_HybridBurstEnable.bus.read();
rv[2:2]=var_HybridBurstEnable;
let var_FixedLatency<-sig_FixedLatency.bus.read();
rv[3:3]=var_FixedLatency;
let var_InitialLatency<-sig_InitialLatency.bus.read();
rv[7:4]=var_InitialLatency;
let var_Reserved<-sig_Reserved.bus.read();
rv[11:8]=var_Reserved;
let var_DriveStrength<-sig_DriveStrength.bus.read();
rv[14:12]=var_DriveStrength;
let var_DeepPowerDown<-sig_DeepPowerDown.bus.read();
rv[15:15]=var_DeepPowerDown;
let var_BurstEnable<-sig_BurstEnable.bus.read();
rv[16:16]=var_BurstEnable;
let var_UltraDeepPowerDown<-sig_UltraDeepPowerDown.bus.read();
rv[17:17]=var_UltraDeepPowerDown;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_xspi_status;
    interface HW_xspi_status_wip swip;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_xspi_status;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_xspi_status;
interface ConfigReg_HW_xspi_status hw;
interface ConfigReg_Bus_xspi_status bus;
endinterface
module mkConfigReg_xspi_status(ConfigReg_xspi_status);
    Ifc_CSRSignal_xspi_status_wip sig_wip <- mkCSRSignal_xspi_status_wip(0);

interface ConfigReg_HW_xspi_status hw;
    interface HW_xspi_status_wip swip = sig_wip.hw;

    method Bit#(64) value();
    let rv=0;
rv[0:0]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_xspi_status bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_wip<-sig_wip.bus.read();
rv[0:0]=var_wip;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_xspi_control;
    interface HW_xspi_control_use_xspi_clk suse_xspi_clk;
interface HW_xspi_control_interrupt_enable sinterrupt_enable;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_xspi_control;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_xspi_control;
interface ConfigReg_HW_xspi_control hw;
interface ConfigReg_Bus_xspi_control bus;
endinterface
module mkConfigReg_xspi_control(ConfigReg_xspi_control);
    Ifc_CSRSignal_xspi_control_use_xspi_clk sig_use_xspi_clk <- mkCSRSignal_xspi_control_use_xspi_clk(0);
Ifc_CSRSignal_xspi_control_interrupt_enable sig_interrupt_enable <- mkCSRSignal_xspi_control_interrupt_enable(0);

interface ConfigReg_HW_xspi_control hw;
    interface HW_xspi_control_use_xspi_clk suse_xspi_clk = sig_use_xspi_clk.hw;
interface HW_xspi_control_interrupt_enable sinterrupt_enable = sig_interrupt_enable.hw;

    method Bit#(64) value();
    let rv=0;
rv[0:0]=sig_use_xspi_clk.hw;
rv[1:1]=sig_interrupt_enable.hw;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_xspi_control bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods
sig_use_xspi_clk.bus.write(data[0:0],wstrb[0:0]);
sig_interrupt_enable.bus.write(data[1:1],wstrb[1:1]);

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_use_xspi_clk<-sig_use_xspi_clk.bus.read();
rv[0:0]=var_use_xspi_clk;
let var_interrupt_enable<-sig_interrupt_enable.bus.read();
rv[1:1]=var_interrupt_enable;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_xspi_rates;
    interface HW_xspi_rates_cmd_rate scmd_rate;
interface HW_xspi_rates_addr_rate saddr_rate;
interface HW_xspi_rates_data_rate sdata_rate;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_xspi_rates;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_xspi_rates;
interface ConfigReg_HW_xspi_rates hw;
interface ConfigReg_Bus_xspi_rates bus;
endinterface
module mkConfigReg_xspi_rates(ConfigReg_xspi_rates);
    Ifc_CSRSignal_xspi_rates_cmd_rate sig_cmd_rate <- mkCSRSignal_xspi_rates_cmd_rate(0);
Ifc_CSRSignal_xspi_rates_addr_rate sig_addr_rate <- mkCSRSignal_xspi_rates_addr_rate(0);
Ifc_CSRSignal_xspi_rates_data_rate sig_data_rate <- mkCSRSignal_xspi_rates_data_rate(0);

interface ConfigReg_HW_xspi_rates hw;
    interface HW_xspi_rates_cmd_rate scmd_rate = sig_cmd_rate.hw;
interface HW_xspi_rates_addr_rate saddr_rate = sig_addr_rate.hw;
interface HW_xspi_rates_data_rate sdata_rate = sig_data_rate.hw;

    method Bit#(64) value();
    let rv=0;
rv[7:0]=sig_cmd_rate.hw;
rv[15:8]=sig_addr_rate.hw;
rv[23:16]=sig_data_rate.hw;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_xspi_rates bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods
sig_cmd_rate.bus.write(data[7:0],wstrb[7:0]);
sig_addr_rate.bus.write(data[15:8],wstrb[15:8]);
sig_data_rate.bus.write(data[23:16],wstrb[23:16]);

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_cmd_rate<-sig_cmd_rate.bus.read();
rv[7:0]=var_cmd_rate;
let var_addr_rate<-sig_addr_rate.bus.read();
rv[15:8]=var_addr_rate;
let var_data_rate<-sig_data_rate.bus.read();
rv[23:16]=var_data_rate;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_interrupt_status;
    interface HW_interrupt_status_axi_resp saxi_resp;
interface HW_interrupt_status_read_underflow sread_underflow;
interface HW_interrupt_status_write_overflow swrite_overflow;

    method Bit#(64) value();

endinterface

interface ConfigReg_Bus_interrupt_status;
    method Action write( Bit#(64) data,Bit#(64)wstrb);
    method ActionValue#(Bit#(64)) read();
endinterface

interface ConfigReg_interrupt_status;
interface ConfigReg_HW_interrupt_status hw;
interface ConfigReg_Bus_interrupt_status bus;
endinterface
module mkConfigReg_interrupt_status(ConfigReg_interrupt_status);
    Ifc_CSRSignal_interrupt_status_axi_resp sig_axi_resp <- mkCSRSignal_interrupt_status_axi_resp(0);
Ifc_CSRSignal_interrupt_status_read_underflow sig_read_underflow <- mkCSRSignal_interrupt_status_read_underflow(0);
Ifc_CSRSignal_interrupt_status_write_overflow sig_write_overflow <- mkCSRSignal_interrupt_status_write_overflow(0);

interface ConfigReg_HW_interrupt_status hw;
    interface HW_interrupt_status_axi_resp saxi_resp = sig_axi_resp.hw;
interface HW_interrupt_status_read_underflow sread_underflow = sig_read_underflow.hw;
interface HW_interrupt_status_write_overflow swrite_overflow = sig_write_overflow.hw;

    method Bit#(64) value();
    let rv=0;
rv[1:0]=sig_axi_resp.hw;
rv[2:2]=sig_read_underflow.hw;
rv[3:3]=sig_write_overflow.hw;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_interrupt_status bus;
    method Action write(Bit#(64) data,Bit#(64) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(64)) read;
        Bit#(64) rv=0;
    //read methods
let var_axi_resp<-sig_axi_resp.bus.read();
rv[1:0]=var_axi_resp;
let var_read_underflow<-sig_read_underflow.bus.read();
rv[2:2]=var_read_underflow;
let var_write_overflow<-sig_write_overflow.bus.read();
rv[3:3]=var_write_overflow;

    return rv;
    endmethod
endinterface
endmodule
                  
