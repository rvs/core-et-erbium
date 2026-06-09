import SFDP_Reg_signal::*;

interface ConfigReg_HW_reg6_2_1;
    interface HW_reg6_2_1_signature ssignature;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_2_1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_2_1;
interface ConfigReg_HW_reg6_2_1 hw;
interface ConfigReg_Bus_reg6_2_1 bus;
endinterface
module mkConfigReg_reg6_2_1(ConfigReg_reg6_2_1);
    Ifc_CSRSignal_reg6_2_1_signature sig_signature <- mkCSRSignal_reg6_2_1_signature(1346651731);

interface ConfigReg_HW_reg6_2_1 hw;
    interface HW_reg6_2_1_signature ssignature = sig_signature.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_2_1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_signature<-sig_signature.bus.read();
rv[31:0]=var_signature;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_2_2;
    interface HW_reg6_2_2_minor sminor;
interface HW_reg6_2_2_major smajor;
interface HW_reg6_2_2_numHdr snumHdr;
interface HW_reg6_2_2_access_protocol saccess_protocol;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_2_2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_2_2;
interface ConfigReg_HW_reg6_2_2 hw;
interface ConfigReg_Bus_reg6_2_2 bus;
endinterface
module mkConfigReg_reg6_2_2(ConfigReg_reg6_2_2);
    Ifc_CSRSignal_reg6_2_2_minor sig_minor <- mkCSRSignal_reg6_2_2_minor(12);
Ifc_CSRSignal_reg6_2_2_major sig_major <- mkCSRSignal_reg6_2_2_major(1);
Ifc_CSRSignal_reg6_2_2_numHdr sig_numHdr <- mkCSRSignal_reg6_2_2_numHdr(6);
Ifc_CSRSignal_reg6_2_2_access_protocol sig_access_protocol <- mkCSRSignal_reg6_2_2_access_protocol(250);

interface ConfigReg_HW_reg6_2_2 hw;
    interface HW_reg6_2_2_minor sminor = sig_minor.hw;
interface HW_reg6_2_2_major smajor = sig_major.hw;
interface HW_reg6_2_2_numHdr snumHdr = sig_numHdr.hw;
interface HW_reg6_2_2_access_protocol saccess_protocol = sig_access_protocol.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=sig_numHdr.hw;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_2_2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_minor<-sig_minor.bus.read();
rv[7:0]=var_minor;
let var_major<-sig_major.bus.read();
rv[15:8]=var_major;
let var_numHdr<-sig_numHdr.bus.read();
rv[23:16]=var_numHdr;
let var_access_protocol<-sig_access_protocol.bus.read();
rv[31:24]=var_access_protocol;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4__1;
    interface HW_reg6_4__1_id sid;
interface HW_reg6_4__1_minor_rev sminor_rev;
interface HW_reg6_4__1_major_rev smajor_rev;
interface HW_reg6_4__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4__1;
interface ConfigReg_HW_reg6_4__1 hw;
interface ConfigReg_Bus_reg6_4__1 bus;
endinterface
module mkConfigReg_reg6_4__1(ConfigReg_reg6_4__1);
    Ifc_CSRSignal_reg6_4__1_id sig_id <- mkCSRSignal_reg6_4__1_id(0);
Ifc_CSRSignal_reg6_4__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_4__1_minor_rev(9);
Ifc_CSRSignal_reg6_4__1_major_rev sig_major_rev <- mkCSRSignal_reg6_4__1_major_rev(1);
Ifc_CSRSignal_reg6_4__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_4__1_tbl_len(23);

interface ConfigReg_HW_reg6_4__1 hw;
    interface HW_reg6_4__1_id sid = sig_id.hw;
interface HW_reg6_4__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_4__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_4__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4__2;
    interface HW_reg6_4__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_4__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4__2;
interface ConfigReg_HW_reg6_4__2 hw;
interface ConfigReg_Bus_reg6_4__2 bus;
endinterface
module mkConfigReg_reg6_4__2(ConfigReg_reg6_4__2);
    Ifc_CSRSignal_reg6_4__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_4__2_param_tbl_ptr(1024);
Ifc_CSRSignal_reg6_4__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_4__2_param_id_msb(255);

interface ConfigReg_HW_reg6_4__2 hw;
    interface HW_reg6_4__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_4__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_7__1;
    interface HW_reg6_7__1_id sid;
interface HW_reg6_7__1_minor_rev sminor_rev;
interface HW_reg6_7__1_major_rev smajor_rev;
interface HW_reg6_7__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_7__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_7__1;
interface ConfigReg_HW_reg6_7__1 hw;
interface ConfigReg_Bus_reg6_7__1 bus;
endinterface
module mkConfigReg_reg6_7__1(ConfigReg_reg6_7__1);
    Ifc_CSRSignal_reg6_7__1_id sig_id <- mkCSRSignal_reg6_7__1_id(132);
Ifc_CSRSignal_reg6_7__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_7__1_minor_rev(1);
Ifc_CSRSignal_reg6_7__1_major_rev sig_major_rev <- mkCSRSignal_reg6_7__1_major_rev(1);
Ifc_CSRSignal_reg6_7__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_7__1_tbl_len(2);

interface ConfigReg_HW_reg6_7__1 hw;
    interface HW_reg6_7__1_id sid = sig_id.hw;
interface HW_reg6_7__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_7__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_7__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_7__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_7__2;
    interface HW_reg6_7__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_7__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_7__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_7__2;
interface ConfigReg_HW_reg6_7__2 hw;
interface ConfigReg_Bus_reg6_7__2 bus;
endinterface
module mkConfigReg_reg6_7__2(ConfigReg_reg6_7__2);
    Ifc_CSRSignal_reg6_7__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_7__2_param_tbl_ptr(1792);
Ifc_CSRSignal_reg6_7__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_7__2_param_id_msb(255);

interface ConfigReg_HW_reg6_7__2 hw;
    interface HW_reg6_7__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_7__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_7__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_9__1;
    interface HW_reg6_9__1_id sid;
interface HW_reg6_9__1_minor_rev sminor_rev;
interface HW_reg6_9__1_major_rev smajor_rev;
interface HW_reg6_9__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_9__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_9__1;
interface ConfigReg_HW_reg6_9__1 hw;
interface ConfigReg_Bus_reg6_9__1 bus;
endinterface
module mkConfigReg_reg6_9__1(ConfigReg_reg6_9__1);
    Ifc_CSRSignal_reg6_9__1_id sig_id <- mkCSRSignal_reg6_9__1_id(6);
Ifc_CSRSignal_reg6_9__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_9__1_minor_rev(0);
Ifc_CSRSignal_reg6_9__1_major_rev sig_major_rev <- mkCSRSignal_reg6_9__1_major_rev(1);
Ifc_CSRSignal_reg6_9__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_9__1_tbl_len(3);

interface ConfigReg_HW_reg6_9__1 hw;
    interface HW_reg6_9__1_id sid = sig_id.hw;
interface HW_reg6_9__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_9__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_9__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_9__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_9__2;
    interface HW_reg6_9__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_9__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_9__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_9__2;
interface ConfigReg_HW_reg6_9__2 hw;
interface ConfigReg_Bus_reg6_9__2 bus;
endinterface
module mkConfigReg_reg6_9__2(ConfigReg_reg6_9__2);
    Ifc_CSRSignal_reg6_9__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_9__2_param_tbl_ptr(2304);
Ifc_CSRSignal_reg6_9__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_9__2_param_id_msb(255);

interface ConfigReg_HW_reg6_9__2 hw;
    interface HW_reg6_9__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_9__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_9__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_10__1;
    interface HW_reg6_10__1_id sid;
interface HW_reg6_10__1_minor_rev sminor_rev;
interface HW_reg6_10__1_major_rev smajor_rev;
interface HW_reg6_10__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_10__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_10__1;
interface ConfigReg_HW_reg6_10__1 hw;
interface ConfigReg_Bus_reg6_10__1 bus;
endinterface
module mkConfigReg_reg6_10__1(ConfigReg_reg6_10__1);
    Ifc_CSRSignal_reg6_10__1_id sig_id <- mkCSRSignal_reg6_10__1_id(135);
Ifc_CSRSignal_reg6_10__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_10__1_minor_rev(1);
Ifc_CSRSignal_reg6_10__1_major_rev sig_major_rev <- mkCSRSignal_reg6_10__1_major_rev(1);
Ifc_CSRSignal_reg6_10__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_10__1_tbl_len(28);

interface ConfigReg_HW_reg6_10__1 hw;
    interface HW_reg6_10__1_id sid = sig_id.hw;
interface HW_reg6_10__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_10__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_10__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_10__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_10__2;
    interface HW_reg6_10__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_10__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_10__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_10__2;
interface ConfigReg_HW_reg6_10__2 hw;
interface ConfigReg_Bus_reg6_10__2 bus;
endinterface
module mkConfigReg_reg6_10__2(ConfigReg_reg6_10__2);
    Ifc_CSRSignal_reg6_10__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_10__2_param_tbl_ptr(2560);
Ifc_CSRSignal_reg6_10__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_10__2_param_id_msb(255);

interface ConfigReg_HW_reg6_10__2 hw;
    interface HW_reg6_10__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_10__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_10__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_11__1;
    interface HW_reg6_11__1_id sid;
interface HW_reg6_11__1_minor_rev sminor_rev;
interface HW_reg6_11__1_major_rev smajor_rev;
interface HW_reg6_11__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_11__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_11__1;
interface ConfigReg_HW_reg6_11__1 hw;
interface ConfigReg_Bus_reg6_11__1 bus;
endinterface
module mkConfigReg_reg6_11__1(ConfigReg_reg6_11__1);
    Ifc_CSRSignal_reg6_11__1_id sig_id <- mkCSRSignal_reg6_11__1_id(9);
Ifc_CSRSignal_reg6_11__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_11__1_minor_rev(0);
Ifc_CSRSignal_reg6_11__1_major_rev sig_major_rev <- mkCSRSignal_reg6_11__1_major_rev(1);
Ifc_CSRSignal_reg6_11__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_11__1_tbl_len(13);

interface ConfigReg_HW_reg6_11__1 hw;
    interface HW_reg6_11__1_id sid = sig_id.hw;
interface HW_reg6_11__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_11__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_11__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_11__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_11__2;
    interface HW_reg6_11__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_11__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_11__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_11__2;
interface ConfigReg_HW_reg6_11__2 hw;
interface ConfigReg_Bus_reg6_11__2 bus;
endinterface
module mkConfigReg_reg6_11__2(ConfigReg_reg6_11__2);
    Ifc_CSRSignal_reg6_11__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_11__2_param_tbl_ptr(2816);
Ifc_CSRSignal_reg6_11__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_11__2_param_id_msb(255);

interface ConfigReg_HW_reg6_11__2 hw;
    interface HW_reg6_11__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_11__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_11__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_17__1;
    interface HW_reg6_17__1_id sid;
interface HW_reg6_17__1_minor_rev sminor_rev;
interface HW_reg6_17__1_major_rev smajor_rev;
interface HW_reg6_17__1_tbl_len stbl_len;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_17__1;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_17__1;
interface ConfigReg_HW_reg6_17__1 hw;
interface ConfigReg_Bus_reg6_17__1 bus;
endinterface
module mkConfigReg_reg6_17__1(ConfigReg_reg6_17__1);
    Ifc_CSRSignal_reg6_17__1_id sig_id <- mkCSRSignal_reg6_17__1_id(15);
Ifc_CSRSignal_reg6_17__1_minor_rev sig_minor_rev <- mkCSRSignal_reg6_17__1_minor_rev(1);
Ifc_CSRSignal_reg6_17__1_major_rev sig_major_rev <- mkCSRSignal_reg6_17__1_major_rev(1);
Ifc_CSRSignal_reg6_17__1_tbl_len sig_tbl_len <- mkCSRSignal_reg6_17__1_tbl_len(10);

interface ConfigReg_HW_reg6_17__1 hw;
    interface HW_reg6_17__1_id sid = sig_id.hw;
interface HW_reg6_17__1_minor_rev sminor_rev = sig_minor_rev.hw;
interface HW_reg6_17__1_major_rev smajor_rev = sig_major_rev.hw;
interface HW_reg6_17__1_tbl_len stbl_len = sig_tbl_len.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_17__1 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_id<-sig_id.bus.read();
rv[7:0]=var_id;
let var_minor_rev<-sig_minor_rev.bus.read();
rv[15:8]=var_minor_rev;
let var_major_rev<-sig_major_rev.bus.read();
rv[23:16]=var_major_rev;
let var_tbl_len<-sig_tbl_len.bus.read();
rv[31:24]=var_tbl_len;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_17__2;
    interface HW_reg6_17__2_param_tbl_ptr sparam_tbl_ptr;
interface HW_reg6_17__2_param_id_msb sparam_id_msb;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_17__2;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_17__2;
interface ConfigReg_HW_reg6_17__2 hw;
interface ConfigReg_Bus_reg6_17__2 bus;
endinterface
module mkConfigReg_reg6_17__2(ConfigReg_reg6_17__2);
    Ifc_CSRSignal_reg6_17__2_param_tbl_ptr sig_param_tbl_ptr <- mkCSRSignal_reg6_17__2_param_tbl_ptr(4352);
Ifc_CSRSignal_reg6_17__2_param_id_msb sig_param_id_msb <- mkCSRSignal_reg6_17__2_param_id_msb(255);

interface ConfigReg_HW_reg6_17__2 hw;
    interface HW_reg6_17__2_param_tbl_ptr sparam_tbl_ptr = sig_param_tbl_ptr.hw;
interface HW_reg6_17__2_param_id_msb sparam_id_msb = sig_param_id_msb.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:0]=24'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_17__2 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_param_tbl_ptr<-sig_param_tbl_ptr.bus.read();
rv[23:0]=var_param_tbl_ptr;
let var_param_id_msb<-sig_param_id_msb.bus.read();
rv[31:24]=var_param_id_msb;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_4;
    interface HW_reg_6_4_4_erase_size serase_size;
interface HW_reg_6_4_4_write_granularity swrite_granularity;
interface HW_reg_6_4_4_always_volatile_csr salways_volatile_csr;
interface HW_reg_6_4_4_we_instruction swe_instruction;
interface HW_reg_6_4_4_unused1 sunused1;
interface HW_reg_6_4_4_erase_4kb serase_4kb;
interface HW_reg_6_4_4_fs_1s1s2s sfs_1s1s2s;
interface HW_reg_6_4_4_addrBytes saddrBytes;
interface HW_reg_6_4_4_dtr_mode sdtr_mode;
interface HW_reg_6_4_4_fs_1s2s2s sfs_1s2s2s;
interface HW_reg_6_4_4_fs_1s4s4s sfs_1s4s4s;
interface HW_reg_6_4_4_fs_1s1s1s sfs_1s1s1s;
interface HW_reg_6_4_4_unused0 sunused0;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_4;
interface ConfigReg_HW_reg_6_4_4 hw;
interface ConfigReg_Bus_reg_6_4_4 bus;
endinterface
module mkConfigReg_reg_6_4_4(ConfigReg_reg_6_4_4);
    Ifc_CSRSignal_reg_6_4_4_erase_size sig_erase_size <- mkCSRSignal_reg_6_4_4_erase_size(3);
Ifc_CSRSignal_reg_6_4_4_write_granularity sig_write_granularity <- mkCSRSignal_reg_6_4_4_write_granularity(0);
Ifc_CSRSignal_reg_6_4_4_always_volatile_csr sig_always_volatile_csr <- mkCSRSignal_reg_6_4_4_always_volatile_csr(1);
Ifc_CSRSignal_reg_6_4_4_we_instruction sig_we_instruction <- mkCSRSignal_reg_6_4_4_we_instruction(1);
Ifc_CSRSignal_reg_6_4_4_unused1 sig_unused1 <- mkCSRSignal_reg_6_4_4_unused1(7);
Ifc_CSRSignal_reg_6_4_4_erase_4kb sig_erase_4kb <- mkCSRSignal_reg_6_4_4_erase_4kb(255);
Ifc_CSRSignal_reg_6_4_4_fs_1s1s2s sig_fs_1s1s2s <- mkCSRSignal_reg_6_4_4_fs_1s1s2s(0);
Ifc_CSRSignal_reg_6_4_4_addrBytes sig_addrBytes <- mkCSRSignal_reg_6_4_4_addrBytes(2);
Ifc_CSRSignal_reg_6_4_4_dtr_mode sig_dtr_mode <- mkCSRSignal_reg_6_4_4_dtr_mode(1);
Ifc_CSRSignal_reg_6_4_4_fs_1s2s2s sig_fs_1s2s2s <- mkCSRSignal_reg_6_4_4_fs_1s2s2s(0);
Ifc_CSRSignal_reg_6_4_4_fs_1s4s4s sig_fs_1s4s4s <- mkCSRSignal_reg_6_4_4_fs_1s4s4s(0);
Ifc_CSRSignal_reg_6_4_4_fs_1s1s1s sig_fs_1s1s1s <- mkCSRSignal_reg_6_4_4_fs_1s1s1s(0);
Ifc_CSRSignal_reg_6_4_4_unused0 sig_unused0 <- mkCSRSignal_reg_6_4_4_unused0(255);

interface ConfigReg_HW_reg_6_4_4 hw;
    interface HW_reg_6_4_4_erase_size serase_size = sig_erase_size.hw;
interface HW_reg_6_4_4_write_granularity swrite_granularity = sig_write_granularity.hw;
interface HW_reg_6_4_4_always_volatile_csr salways_volatile_csr = sig_always_volatile_csr.hw;
interface HW_reg_6_4_4_we_instruction swe_instruction = sig_we_instruction.hw;
interface HW_reg_6_4_4_unused1 sunused1 = sig_unused1.hw;
interface HW_reg_6_4_4_erase_4kb serase_4kb = sig_erase_4kb.hw;
interface HW_reg_6_4_4_fs_1s1s2s sfs_1s1s2s = sig_fs_1s1s2s.hw;
interface HW_reg_6_4_4_addrBytes saddrBytes = sig_addrBytes.hw;
interface HW_reg_6_4_4_dtr_mode sdtr_mode = sig_dtr_mode.hw;
interface HW_reg_6_4_4_fs_1s2s2s sfs_1s2s2s = sig_fs_1s2s2s.hw;
interface HW_reg_6_4_4_fs_1s4s4s sfs_1s4s4s = sig_fs_1s4s4s.hw;
interface HW_reg_6_4_4_fs_1s1s1s sfs_1s1s1s = sig_fs_1s1s1s.hw;
interface HW_reg_6_4_4_unused0 sunused0 = sig_unused0.hw;

    method Bit#(32) value();
    let rv=0;
rv[1:0]=2'b0;
rv[2:2]=1'b0;
rv[3:3]=1'b0;
rv[4:4]=1'b0;
rv[7:5]=3'b0;
rv[15:8]=8'b0;
rv[16:16]=1'b0;
rv[18:17]=2'b0;
rv[19:19]=1'b0;
rv[20:20]=1'b0;
rv[21:21]=1'b0;
rv[22:22]=1'b0;
rv[31:23]=9'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_erase_size<-sig_erase_size.bus.read();
rv[1:0]=var_erase_size;
let var_write_granularity<-sig_write_granularity.bus.read();
rv[2:2]=var_write_granularity;
let var_always_volatile_csr<-sig_always_volatile_csr.bus.read();
rv[3:3]=var_always_volatile_csr;
let var_we_instruction<-sig_we_instruction.bus.read();
rv[4:4]=var_we_instruction;
let var_unused1<-sig_unused1.bus.read();
rv[7:5]=var_unused1;
let var_erase_4kb<-sig_erase_4kb.bus.read();
rv[15:8]=var_erase_4kb;
let var_fs_1s1s2s<-sig_fs_1s1s2s.bus.read();
rv[16:16]=var_fs_1s1s2s;
let var_addrBytes<-sig_addrBytes.bus.read();
rv[18:17]=var_addrBytes;
let var_dtr_mode<-sig_dtr_mode.bus.read();
rv[19:19]=var_dtr_mode;
let var_fs_1s2s2s<-sig_fs_1s2s2s.bus.read();
rv[20:20]=var_fs_1s2s2s;
let var_fs_1s4s4s<-sig_fs_1s4s4s.bus.read();
rv[21:21]=var_fs_1s4s4s;
let var_fs_1s1s1s<-sig_fs_1s1s1s.bus.read();
rv[22:22]=var_fs_1s1s1s;
let var_unused0<-sig_unused0.bus.read();
rv[31:23]=var_unused0;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_5;
    interface HW_reg_6_4_5_mem_density smem_density;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_5;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_5;
interface ConfigReg_HW_reg_6_4_5 hw;
interface ConfigReg_Bus_reg_6_4_5 bus;
endinterface
module mkConfigReg_reg_6_4_5(ConfigReg_reg_6_4_5);
    Ifc_CSRSignal_reg_6_4_5_mem_density sig_mem_density <- mkCSRSignal_reg_6_4_5_mem_density(16777215);

interface ConfigReg_HW_reg_6_4_5 hw;
    interface HW_reg_6_4_5_mem_density smem_density = sig_mem_density.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_5 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_mem_density<-sig_mem_density.bus.read();
rv[31:0]=var_mem_density;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_6;
    interface HW_reg6_4_6_waitstate_1s4s4s swaitstate_1s4s4s;
interface HW_reg6_4_6_mode_1s4s4s smode_1s4s4s;
interface HW_reg6_4_6_fr_inst_1s4s4s sfr_inst_1s4s4s;
interface HW_reg6_4_6_waitstate_1s1s4s swaitstate_1s1s4s;
interface HW_reg6_4_6_mode_1s1s4s smode_1s1s4s;
interface HW_reg6_4_6_fr_inst_1s1s4s sfr_inst_1s1s4s;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_6;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_6;
interface ConfigReg_HW_reg6_4_6 hw;
interface ConfigReg_Bus_reg6_4_6 bus;
endinterface
module mkConfigReg_reg6_4_6(ConfigReg_reg6_4_6);
    Ifc_CSRSignal_reg6_4_6_waitstate_1s4s4s sig_waitstate_1s4s4s <- mkCSRSignal_reg6_4_6_waitstate_1s4s4s(2);
Ifc_CSRSignal_reg6_4_6_mode_1s4s4s sig_mode_1s4s4s <- mkCSRSignal_reg6_4_6_mode_1s4s4s(0);
Ifc_CSRSignal_reg6_4_6_fr_inst_1s4s4s sig_fr_inst_1s4s4s <- mkCSRSignal_reg6_4_6_fr_inst_1s4s4s(171);
Ifc_CSRSignal_reg6_4_6_waitstate_1s1s4s sig_waitstate_1s1s4s <- mkCSRSignal_reg6_4_6_waitstate_1s1s4s(2);
Ifc_CSRSignal_reg6_4_6_mode_1s1s4s sig_mode_1s1s4s <- mkCSRSignal_reg6_4_6_mode_1s1s4s(0);
Ifc_CSRSignal_reg6_4_6_fr_inst_1s1s4s sig_fr_inst_1s1s4s <- mkCSRSignal_reg6_4_6_fr_inst_1s1s4s(170);

interface ConfigReg_HW_reg6_4_6 hw;
    interface HW_reg6_4_6_waitstate_1s4s4s swaitstate_1s4s4s = sig_waitstate_1s4s4s.hw;
interface HW_reg6_4_6_mode_1s4s4s smode_1s4s4s = sig_mode_1s4s4s.hw;
interface HW_reg6_4_6_fr_inst_1s4s4s sfr_inst_1s4s4s = sig_fr_inst_1s4s4s.hw;
interface HW_reg6_4_6_waitstate_1s1s4s swaitstate_1s1s4s = sig_waitstate_1s1s4s.hw;
interface HW_reg6_4_6_mode_1s1s4s smode_1s1s4s = sig_mode_1s1s4s.hw;
interface HW_reg6_4_6_fr_inst_1s1s4s sfr_inst_1s1s4s = sig_fr_inst_1s1s4s.hw;

    method Bit#(32) value();
    let rv=0;
rv[4:0]=5'b0;
rv[7:5]=3'b0;
rv[15:8]=8'b0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_6 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_waitstate_1s4s4s<-sig_waitstate_1s4s4s.bus.read();
rv[4:0]=var_waitstate_1s4s4s;
let var_mode_1s4s4s<-sig_mode_1s4s4s.bus.read();
rv[7:5]=var_mode_1s4s4s;
let var_fr_inst_1s4s4s<-sig_fr_inst_1s4s4s.bus.read();
rv[15:8]=var_fr_inst_1s4s4s;
let var_waitstate_1s1s4s<-sig_waitstate_1s1s4s.bus.read();
rv[20:16]=var_waitstate_1s1s4s;
let var_mode_1s1s4s<-sig_mode_1s1s4s.bus.read();
rv[23:21]=var_mode_1s1s4s;
let var_fr_inst_1s1s4s<-sig_fr_inst_1s1s4s.bus.read();
rv[31:24]=var_fr_inst_1s1s4s;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_7;
    interface HW_reg6_4_7_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_7;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_7;
interface ConfigReg_HW_reg6_4_7 hw;
interface ConfigReg_Bus_reg6_4_7 bus;
endinterface
module mkConfigReg_reg6_4_7(ConfigReg_reg6_4_7);
    Ifc_CSRSignal_reg6_4_7_reserved sig_reserved <- mkCSRSignal_reg6_4_7_reserved(0);

interface ConfigReg_HW_reg6_4_7 hw;
    interface HW_reg6_4_7_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_7 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_8;
    interface HW_reg6_4_8_mode_2s smode_2s;
interface HW_reg6_4_8_mode_4s smode_4s;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_8;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_8;
interface ConfigReg_HW_reg6_4_8 hw;
interface ConfigReg_Bus_reg6_4_8 bus;
endinterface
module mkConfigReg_reg6_4_8(ConfigReg_reg6_4_8);
    Ifc_CSRSignal_reg6_4_8_mode_2s sig_mode_2s <- mkCSRSignal_reg6_4_8_mode_2s(0);
Ifc_CSRSignal_reg6_4_8_mode_4s sig_mode_4s <- mkCSRSignal_reg6_4_8_mode_4s(1);

interface ConfigReg_HW_reg6_4_8 hw;
    interface HW_reg6_4_8_mode_2s smode_2s = sig_mode_2s.hw;
interface HW_reg6_4_8_mode_4s smode_4s = sig_mode_4s.hw;

    method Bit#(32) value();
    let rv=0;
rv[0:0]=1'b0;
rv[4:4]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_8 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_mode_2s<-sig_mode_2s.bus.read();
rv[0:0]=var_mode_2s;
let var_mode_4s<-sig_mode_4s.bus.read();
rv[4:4]=var_mode_4s;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_9;
    interface HW_reg6_4_9_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_9;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_9;
interface ConfigReg_HW_reg6_4_9 hw;
interface ConfigReg_Bus_reg6_4_9 bus;
endinterface
module mkConfigReg_reg6_4_9(ConfigReg_reg6_4_9);
    Ifc_CSRSignal_reg6_4_9_reserved sig_reserved <- mkCSRSignal_reg6_4_9_reserved(0);

interface ConfigReg_HW_reg6_4_9 hw;
    interface HW_reg6_4_9_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_9 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_10;
    interface HW_reg6_4_10_waitstate_4s4s4s swaitstate_4s4s4s;
interface HW_reg6_4_10_mode_4s4s4s smode_4s4s4s;
interface HW_reg6_4_10_fr_inst_4s4s4s sfr_inst_4s4s4s;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_10;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_10;
interface ConfigReg_HW_reg6_4_10 hw;
interface ConfigReg_Bus_reg6_4_10 bus;
endinterface
module mkConfigReg_reg6_4_10(ConfigReg_reg6_4_10);
    Ifc_CSRSignal_reg6_4_10_waitstate_4s4s4s sig_waitstate_4s4s4s <- mkCSRSignal_reg6_4_10_waitstate_4s4s4s(2);
Ifc_CSRSignal_reg6_4_10_mode_4s4s4s sig_mode_4s4s4s <- mkCSRSignal_reg6_4_10_mode_4s4s4s(0);
Ifc_CSRSignal_reg6_4_10_fr_inst_4s4s4s sig_fr_inst_4s4s4s <- mkCSRSignal_reg6_4_10_fr_inst_4s4s4s(172);

interface ConfigReg_HW_reg6_4_10 hw;
    interface HW_reg6_4_10_waitstate_4s4s4s swaitstate_4s4s4s = sig_waitstate_4s4s4s.hw;
interface HW_reg6_4_10_mode_4s4s4s smode_4s4s4s = sig_mode_4s4s4s.hw;
interface HW_reg6_4_10_fr_inst_4s4s4s sfr_inst_4s4s4s = sig_fr_inst_4s4s4s.hw;

    method Bit#(32) value();
    let rv=0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_10 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_waitstate_4s4s4s<-sig_waitstate_4s4s4s.bus.read();
rv[20:16]=var_waitstate_4s4s4s;
let var_mode_4s4s4s<-sig_mode_4s4s4s.bus.read();
rv[23:21]=var_mode_4s4s4s;
let var_fr_inst_4s4s4s<-sig_fr_inst_4s4s4s.bus.read();
rv[31:24]=var_fr_inst_4s4s4s;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_11;
    interface HW_reg6_4_11_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_11;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_11;
interface ConfigReg_HW_reg6_4_11 hw;
interface ConfigReg_Bus_reg6_4_11 bus;
endinterface
module mkConfigReg_reg6_4_11(ConfigReg_reg6_4_11);
    Ifc_CSRSignal_reg6_4_11_reserved sig_reserved <- mkCSRSignal_reg6_4_11_reserved(0);

interface ConfigReg_HW_reg6_4_11 hw;
    interface HW_reg6_4_11_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_11 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_12;
    interface HW_reg6_4_12_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_12;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_12;
interface ConfigReg_HW_reg6_4_12 hw;
interface ConfigReg_Bus_reg6_4_12 bus;
endinterface
module mkConfigReg_reg6_4_12(ConfigReg_reg6_4_12);
    Ifc_CSRSignal_reg6_4_12_reserved sig_reserved <- mkCSRSignal_reg6_4_12_reserved(0);

interface ConfigReg_HW_reg6_4_12 hw;
    interface HW_reg6_4_12_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_12 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_13;
    interface HW_reg6_4_13_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_13;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_13;
interface ConfigReg_HW_reg6_4_13 hw;
interface ConfigReg_Bus_reg6_4_13 bus;
endinterface
module mkConfigReg_reg6_4_13(ConfigReg_reg6_4_13);
    Ifc_CSRSignal_reg6_4_13_reserved sig_reserved <- mkCSRSignal_reg6_4_13_reserved(0);

interface ConfigReg_HW_reg6_4_13 hw;
    interface HW_reg6_4_13_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_13 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_14;
    interface HW_reg6_4_14_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_14;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_14;
interface ConfigReg_HW_reg6_4_14 hw;
interface ConfigReg_Bus_reg6_4_14 bus;
endinterface
module mkConfigReg_reg6_4_14(ConfigReg_reg6_4_14);
    Ifc_CSRSignal_reg6_4_14_reserved sig_reserved <- mkCSRSignal_reg6_4_14_reserved(0);

interface ConfigReg_HW_reg6_4_14 hw;
    interface HW_reg6_4_14_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_14 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_15;
    interface HW_reg6_4_15_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_15;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_15;
interface ConfigReg_HW_reg6_4_15 hw;
interface ConfigReg_Bus_reg6_4_15 bus;
endinterface
module mkConfigReg_reg6_4_15(ConfigReg_reg6_4_15);
    Ifc_CSRSignal_reg6_4_15_reserved sig_reserved <- mkCSRSignal_reg6_4_15_reserved(0);

interface ConfigReg_HW_reg6_4_15 hw;
    interface HW_reg6_4_15_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_15 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_16;
    interface HW_reg6_4_16_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_16;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_16;
interface ConfigReg_HW_reg6_4_16 hw;
interface ConfigReg_Bus_reg6_4_16 bus;
endinterface
module mkConfigReg_reg6_4_16(ConfigReg_reg6_4_16);
    Ifc_CSRSignal_reg6_4_16_reserved sig_reserved <- mkCSRSignal_reg6_4_16_reserved(0);

interface ConfigReg_HW_reg6_4_16 hw;
    interface HW_reg6_4_16_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_16 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_17;
    interface HW_reg6_4_17_reserved sreserved;
interface HW_reg6_4_17_dev_busy_poll sdev_busy_poll;
interface HW_reg6_4_17_exit_delay_count sexit_delay_count;
interface HW_reg6_4_17_exit_delay_units sexit_delay_units;
interface HW_reg6_4_17_inst_deep_power_down_exit sinst_deep_power_down_exit;
interface HW_reg6_4_17_inst_deep_power_down_enter sinst_deep_power_down_enter;
interface HW_reg6_4_17_deep_power_down sdeep_power_down;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_17;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_17;
interface ConfigReg_HW_reg6_4_17 hw;
interface ConfigReg_Bus_reg6_4_17 bus;
endinterface
module mkConfigReg_reg6_4_17(ConfigReg_reg6_4_17);
    Ifc_CSRSignal_reg6_4_17_reserved sig_reserved <- mkCSRSignal_reg6_4_17_reserved(0);
Ifc_CSRSignal_reg6_4_17_dev_busy_poll sig_dev_busy_poll <- mkCSRSignal_reg6_4_17_dev_busy_poll(0);
Ifc_CSRSignal_reg6_4_17_exit_delay_count sig_exit_delay_count <- mkCSRSignal_reg6_4_17_exit_delay_count(2);
Ifc_CSRSignal_reg6_4_17_exit_delay_units sig_exit_delay_units <- mkCSRSignal_reg6_4_17_exit_delay_units(3);
Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_exit sig_inst_deep_power_down_exit <- mkCSRSignal_reg6_4_17_inst_deep_power_down_exit(174);
Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_enter sig_inst_deep_power_down_enter <- mkCSRSignal_reg6_4_17_inst_deep_power_down_enter(173);
Ifc_CSRSignal_reg6_4_17_deep_power_down sig_deep_power_down <- mkCSRSignal_reg6_4_17_deep_power_down(1);

interface ConfigReg_HW_reg6_4_17 hw;
    interface HW_reg6_4_17_reserved sreserved = sig_reserved.hw;
interface HW_reg6_4_17_dev_busy_poll sdev_busy_poll = sig_dev_busy_poll.hw;
interface HW_reg6_4_17_exit_delay_count sexit_delay_count = sig_exit_delay_count.hw;
interface HW_reg6_4_17_exit_delay_units sexit_delay_units = sig_exit_delay_units.hw;
interface HW_reg6_4_17_inst_deep_power_down_exit sinst_deep_power_down_exit = sig_inst_deep_power_down_exit.hw;
interface HW_reg6_4_17_inst_deep_power_down_enter sinst_deep_power_down_enter = sig_inst_deep_power_down_enter.hw;
interface HW_reg6_4_17_deep_power_down sdeep_power_down = sig_deep_power_down.hw;

    method Bit#(32) value();
    let rv=0;
rv[1:0]=2'b0;
rv[7:2]=6'b0;
rv[12:8]=5'b0;
rv[14:13]=2'b0;
rv[22:15]=8'b0;
rv[30:23]=8'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_17 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[1:0]=var_reserved;
let var_dev_busy_poll<-sig_dev_busy_poll.bus.read();
rv[7:2]=var_dev_busy_poll;
let var_exit_delay_count<-sig_exit_delay_count.bus.read();
rv[12:8]=var_exit_delay_count;
let var_exit_delay_units<-sig_exit_delay_units.bus.read();
rv[14:13]=var_exit_delay_units;
let var_inst_deep_power_down_exit<-sig_inst_deep_power_down_exit.bus.read();
rv[22:15]=var_inst_deep_power_down_exit;
let var_inst_deep_power_down_enter<-sig_inst_deep_power_down_enter.bus.read();
rv[30:23]=var_inst_deep_power_down_enter;
let var_deep_power_down<-sig_deep_power_down.bus.read();
rv[31:31]=var_deep_power_down;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg6_4_18;
    interface HW_reg6_4_18_mode_disable444 smode_disable444;
interface HW_reg6_4_18_mode_enable444 smode_enable444;
interface HW_reg6_4_18_xip_supported_044 sxip_supported_044;
interface HW_reg6_4_18_mode_exit044 smode_exit044;
interface HW_reg6_4_18_mode_entry044 smode_entry044;
interface HW_reg6_4_18_quad_enable squad_enable;
interface HW_reg6_4_18_hold_rst_support shold_rst_support;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg6_4_18;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg6_4_18;
interface ConfigReg_HW_reg6_4_18 hw;
interface ConfigReg_Bus_reg6_4_18 bus;
endinterface
module mkConfigReg_reg6_4_18(ConfigReg_reg6_4_18);
    Ifc_CSRSignal_reg6_4_18_mode_disable444 sig_mode_disable444 <- mkCSRSignal_reg6_4_18_mode_disable444(0);
Ifc_CSRSignal_reg6_4_18_mode_enable444 sig_mode_enable444 <- mkCSRSignal_reg6_4_18_mode_enable444(0);
Ifc_CSRSignal_reg6_4_18_xip_supported_044 sig_xip_supported_044 <- mkCSRSignal_reg6_4_18_xip_supported_044(1);
Ifc_CSRSignal_reg6_4_18_mode_exit044 sig_mode_exit044 <- mkCSRSignal_reg6_4_18_mode_exit044(0);
Ifc_CSRSignal_reg6_4_18_mode_entry044 sig_mode_entry044 <- mkCSRSignal_reg6_4_18_mode_entry044(0);
Ifc_CSRSignal_reg6_4_18_quad_enable sig_quad_enable <- mkCSRSignal_reg6_4_18_quad_enable(0);
Ifc_CSRSignal_reg6_4_18_hold_rst_support sig_hold_rst_support <- mkCSRSignal_reg6_4_18_hold_rst_support(0);

interface ConfigReg_HW_reg6_4_18 hw;
    interface HW_reg6_4_18_mode_disable444 smode_disable444 = sig_mode_disable444.hw;
interface HW_reg6_4_18_mode_enable444 smode_enable444 = sig_mode_enable444.hw;
interface HW_reg6_4_18_xip_supported_044 sxip_supported_044 = sig_xip_supported_044.hw;
interface HW_reg6_4_18_mode_exit044 smode_exit044 = sig_mode_exit044.hw;
interface HW_reg6_4_18_mode_entry044 smode_entry044 = sig_mode_entry044.hw;
interface HW_reg6_4_18_quad_enable squad_enable = sig_quad_enable.hw;
interface HW_reg6_4_18_hold_rst_support shold_rst_support = sig_hold_rst_support.hw;

    method Bit#(32) value();
    let rv=0;
rv[3:0]=4'b0;
rv[8:4]=5'b0;
rv[9:9]=1'b0;
rv[15:10]=6'b0;
rv[19:16]=4'b0;
rv[22:20]=3'b0;
rv[23:23]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg6_4_18 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_mode_disable444<-sig_mode_disable444.bus.read();
rv[3:0]=var_mode_disable444;
let var_mode_enable444<-sig_mode_enable444.bus.read();
rv[8:4]=var_mode_enable444;
let var_xip_supported_044<-sig_xip_supported_044.bus.read();
rv[9:9]=var_xip_supported_044;
let var_mode_exit044<-sig_mode_exit044.bus.read();
rv[15:10]=var_mode_exit044;
let var_mode_entry044<-sig_mode_entry044.bus.read();
rv[19:16]=var_mode_entry044;
let var_quad_enable<-sig_quad_enable.bus.read();
rv[22:20]=var_quad_enable;
let var_hold_rst_support<-sig_hold_rst_support.bus.read();
rv[23:23]=var_hold_rst_support;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_19;
    interface HW_reg_6_4_19_volatile_status_reg_1 svolatile_status_reg_1;
interface HW_reg_6_4_19_soft_reset_support ssoft_reset_support;
interface HW_reg_6_4_19_exit_4B_addressing sexit_4B_addressing;
interface HW_reg_6_4_19_enter_4B_addressing senter_4B_addressing;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_19;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_19;
interface ConfigReg_HW_reg_6_4_19 hw;
interface ConfigReg_Bus_reg_6_4_19 bus;
endinterface
module mkConfigReg_reg_6_4_19(ConfigReg_reg_6_4_19);
    Ifc_CSRSignal_reg_6_4_19_volatile_status_reg_1 sig_volatile_status_reg_1 <- mkCSRSignal_reg_6_4_19_volatile_status_reg_1(2);
Ifc_CSRSignal_reg_6_4_19_soft_reset_support sig_soft_reset_support <- mkCSRSignal_reg_6_4_19_soft_reset_support(0);
Ifc_CSRSignal_reg_6_4_19_exit_4B_addressing sig_exit_4B_addressing <- mkCSRSignal_reg_6_4_19_exit_4B_addressing(0);
Ifc_CSRSignal_reg_6_4_19_enter_4B_addressing sig_enter_4B_addressing <- mkCSRSignal_reg_6_4_19_enter_4B_addressing(64);

interface ConfigReg_HW_reg_6_4_19 hw;
    interface HW_reg_6_4_19_volatile_status_reg_1 svolatile_status_reg_1 = sig_volatile_status_reg_1.hw;
interface HW_reg_6_4_19_soft_reset_support ssoft_reset_support = sig_soft_reset_support.hw;
interface HW_reg_6_4_19_exit_4B_addressing sexit_4B_addressing = sig_exit_4B_addressing.hw;
interface HW_reg_6_4_19_enter_4B_addressing senter_4B_addressing = sig_enter_4B_addressing.hw;

    method Bit#(32) value();
    let rv=0;
rv[6:0]=7'b0;
rv[13:8]=6'b0;
rv[23:14]=10'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_19 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_volatile_status_reg_1<-sig_volatile_status_reg_1.bus.read();
rv[6:0]=var_volatile_status_reg_1;
let var_soft_reset_support<-sig_soft_reset_support.bus.read();
rv[13:8]=var_soft_reset_support;
let var_exit_4B_addressing<-sig_exit_4B_addressing.bus.read();
rv[23:14]=var_exit_4B_addressing;
let var_enter_4B_addressing<-sig_enter_4B_addressing.bus.read();
rv[31:24]=var_enter_4B_addressing;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_20;
    interface HW_reg_6_4_20_waitstate_1s8s8s swaitstate_1s8s8s;
interface HW_reg_6_4_20_mode_1s8s8s smode_1s8s8s;
interface HW_reg_6_4_20_fr_inst_1s8s8s sfr_inst_1s8s8s;
interface HW_reg_6_4_20_waitstate_1s1s8s swaitstate_1s1s8s;
interface HW_reg_6_4_20_mode_1s1s8s smode_1s1s8s;
interface HW_reg_6_4_20_fr_inst_1s1s8s sfr_inst_1s1s8s;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_20;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_20;
interface ConfigReg_HW_reg_6_4_20 hw;
interface ConfigReg_Bus_reg_6_4_20 bus;
endinterface
module mkConfigReg_reg_6_4_20(ConfigReg_reg_6_4_20);
    Ifc_CSRSignal_reg_6_4_20_waitstate_1s8s8s sig_waitstate_1s8s8s <- mkCSRSignal_reg_6_4_20_waitstate_1s8s8s(2);
Ifc_CSRSignal_reg_6_4_20_mode_1s8s8s sig_mode_1s8s8s <- mkCSRSignal_reg_6_4_20_mode_1s8s8s(0);
Ifc_CSRSignal_reg_6_4_20_fr_inst_1s8s8s sig_fr_inst_1s8s8s <- mkCSRSignal_reg_6_4_20_fr_inst_1s8s8s(171);
Ifc_CSRSignal_reg_6_4_20_waitstate_1s1s8s sig_waitstate_1s1s8s <- mkCSRSignal_reg_6_4_20_waitstate_1s1s8s(2);
Ifc_CSRSignal_reg_6_4_20_mode_1s1s8s sig_mode_1s1s8s <- mkCSRSignal_reg_6_4_20_mode_1s1s8s(0);
Ifc_CSRSignal_reg_6_4_20_fr_inst_1s1s8s sig_fr_inst_1s1s8s <- mkCSRSignal_reg_6_4_20_fr_inst_1s1s8s(175);

interface ConfigReg_HW_reg_6_4_20 hw;
    interface HW_reg_6_4_20_waitstate_1s8s8s swaitstate_1s8s8s = sig_waitstate_1s8s8s.hw;
interface HW_reg_6_4_20_mode_1s8s8s smode_1s8s8s = sig_mode_1s8s8s.hw;
interface HW_reg_6_4_20_fr_inst_1s8s8s sfr_inst_1s8s8s = sig_fr_inst_1s8s8s.hw;
interface HW_reg_6_4_20_waitstate_1s1s8s swaitstate_1s1s8s = sig_waitstate_1s1s8s.hw;
interface HW_reg_6_4_20_mode_1s1s8s smode_1s1s8s = sig_mode_1s1s8s.hw;
interface HW_reg_6_4_20_fr_inst_1s1s8s sfr_inst_1s1s8s = sig_fr_inst_1s1s8s.hw;

    method Bit#(32) value();
    let rv=0;
rv[4:0]=5'b0;
rv[7:5]=3'b0;
rv[15:8]=8'b0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_20 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_waitstate_1s8s8s<-sig_waitstate_1s8s8s.bus.read();
rv[4:0]=var_waitstate_1s8s8s;
let var_mode_1s8s8s<-sig_mode_1s8s8s.bus.read();
rv[7:5]=var_mode_1s8s8s;
let var_fr_inst_1s8s8s<-sig_fr_inst_1s8s8s.bus.read();
rv[15:8]=var_fr_inst_1s8s8s;
let var_waitstate_1s1s8s<-sig_waitstate_1s1s8s.bus.read();
rv[20:16]=var_waitstate_1s1s8s;
let var_mode_1s1s8s<-sig_mode_1s1s8s.bus.read();
rv[23:21]=var_mode_1s1s8s;
let var_fr_inst_1s1s8s<-sig_fr_inst_1s1s8s.bus.read();
rv[31:24]=var_fr_inst_1s1s8s;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_21;
    interface HW_reg_6_4_21_drive_strength sdrive_strength;
interface HW_reg_6_4_21_jedec_reset sjedec_reset;
interface HW_reg_6_4_21_data_strobe_str_waveform sdata_strobe_str_waveform;
interface HW_reg_6_4_21_data_strobe_support_4s4S4S sdata_strobe_support_4s4S4S;
interface HW_reg_6_4_21_data_strobe_support_4s4d4d sdata_strobe_support_4s4d4d;
interface HW_reg_6_4_21_cmd_ext scmd_ext;
interface HW_reg_6_4_21_byte_order_8D sbyte_order_8D;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_21;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_21;
interface ConfigReg_HW_reg_6_4_21 hw;
interface ConfigReg_Bus_reg_6_4_21 bus;
endinterface
module mkConfigReg_reg_6_4_21(ConfigReg_reg_6_4_21);
    Ifc_CSRSignal_reg_6_4_21_drive_strength sig_drive_strength <- mkCSRSignal_reg_6_4_21_drive_strength(1);
Ifc_CSRSignal_reg_6_4_21_jedec_reset sig_jedec_reset <- mkCSRSignal_reg_6_4_21_jedec_reset(0);
Ifc_CSRSignal_reg_6_4_21_data_strobe_str_waveform sig_data_strobe_str_waveform <- mkCSRSignal_reg_6_4_21_data_strobe_str_waveform(0);
Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4S4S sig_data_strobe_support_4s4S4S <- mkCSRSignal_reg_6_4_21_data_strobe_support_4s4S4S(0);
Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4d4d sig_data_strobe_support_4s4d4d <- mkCSRSignal_reg_6_4_21_data_strobe_support_4s4d4d(0);
Ifc_CSRSignal_reg_6_4_21_cmd_ext sig_cmd_ext <- mkCSRSignal_reg_6_4_21_cmd_ext(0);
Ifc_CSRSignal_reg_6_4_21_byte_order_8D sig_byte_order_8D <- mkCSRSignal_reg_6_4_21_byte_order_8D(0);

interface ConfigReg_HW_reg_6_4_21 hw;
    interface HW_reg_6_4_21_drive_strength sdrive_strength = sig_drive_strength.hw;
interface HW_reg_6_4_21_jedec_reset sjedec_reset = sig_jedec_reset.hw;
interface HW_reg_6_4_21_data_strobe_str_waveform sdata_strobe_str_waveform = sig_data_strobe_str_waveform.hw;
interface HW_reg_6_4_21_data_strobe_support_4s4S4S sdata_strobe_support_4s4S4S = sig_data_strobe_support_4s4S4S.hw;
interface HW_reg_6_4_21_data_strobe_support_4s4d4d sdata_strobe_support_4s4d4d = sig_data_strobe_support_4s4d4d.hw;
interface HW_reg_6_4_21_cmd_ext scmd_ext = sig_cmd_ext.hw;
interface HW_reg_6_4_21_byte_order_8D sbyte_order_8D = sig_byte_order_8D.hw;

    method Bit#(32) value();
    let rv=0;
rv[22:18]=5'b0;
rv[23:23]=1'b0;
rv[25:24]=2'b0;
rv[26:26]=1'b0;
rv[27:27]=1'b0;
rv[30:29]=2'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_21 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_drive_strength<-sig_drive_strength.bus.read();
rv[22:18]=var_drive_strength;
let var_jedec_reset<-sig_jedec_reset.bus.read();
rv[23:23]=var_jedec_reset;
let var_data_strobe_str_waveform<-sig_data_strobe_str_waveform.bus.read();
rv[25:24]=var_data_strobe_str_waveform;
let var_data_strobe_support_4s4S4S<-sig_data_strobe_support_4s4S4S.bus.read();
rv[26:26]=var_data_strobe_support_4s4S4S;
let var_data_strobe_support_4s4d4d<-sig_data_strobe_support_4s4d4d.bus.read();
rv[27:27]=var_data_strobe_support_4s4d4d;
let var_cmd_ext<-sig_cmd_ext.bus.read();
rv[30:29]=var_cmd_ext;
let var_byte_order_8D<-sig_byte_order_8D.bus.read();
rv[31:31]=var_byte_order_8D;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_22;
    interface HW_reg_6_4_22_disable_seq_8s8s8s sdisable_seq_8s8s8s;
interface HW_reg_6_4_22_enable_seq_8s8s8s senable_seq_8s8s8s;
interface HW_reg_6_4_22_xip_supported_088 sxip_supported_088;
interface HW_reg_6_4_22_xip_exit_088 sxip_exit_088;
interface HW_reg_6_4_22_xip_entry_088 sxip_entry_088;
interface HW_reg_6_4_22_octal_enable_req soctal_enable_req;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_22;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_22;
interface ConfigReg_HW_reg_6_4_22 hw;
interface ConfigReg_Bus_reg_6_4_22 bus;
endinterface
module mkConfigReg_reg_6_4_22(ConfigReg_reg_6_4_22);
    Ifc_CSRSignal_reg_6_4_22_disable_seq_8s8s8s sig_disable_seq_8s8s8s <- mkCSRSignal_reg_6_4_22_disable_seq_8s8s8s(1);
Ifc_CSRSignal_reg_6_4_22_enable_seq_8s8s8s sig_enable_seq_8s8s8s <- mkCSRSignal_reg_6_4_22_enable_seq_8s8s8s(2);
Ifc_CSRSignal_reg_6_4_22_xip_supported_088 sig_xip_supported_088 <- mkCSRSignal_reg_6_4_22_xip_supported_088(1);
Ifc_CSRSignal_reg_6_4_22_xip_exit_088 sig_xip_exit_088 <- mkCSRSignal_reg_6_4_22_xip_exit_088(4);
Ifc_CSRSignal_reg_6_4_22_xip_entry_088 sig_xip_entry_088 <- mkCSRSignal_reg_6_4_22_xip_entry_088(1);
Ifc_CSRSignal_reg_6_4_22_octal_enable_req sig_octal_enable_req <- mkCSRSignal_reg_6_4_22_octal_enable_req(1);

interface ConfigReg_HW_reg_6_4_22 hw;
    interface HW_reg_6_4_22_disable_seq_8s8s8s sdisable_seq_8s8s8s = sig_disable_seq_8s8s8s.hw;
interface HW_reg_6_4_22_enable_seq_8s8s8s senable_seq_8s8s8s = sig_enable_seq_8s8s8s.hw;
interface HW_reg_6_4_22_xip_supported_088 sxip_supported_088 = sig_xip_supported_088.hw;
interface HW_reg_6_4_22_xip_exit_088 sxip_exit_088 = sig_xip_exit_088.hw;
interface HW_reg_6_4_22_xip_entry_088 sxip_entry_088 = sig_xip_entry_088.hw;
interface HW_reg_6_4_22_octal_enable_req soctal_enable_req = sig_octal_enable_req.hw;

    method Bit#(32) value();
    let rv=0;
rv[3:0]=4'b0;
rv[8:4]=5'b0;
rv[9:9]=1'b0;
rv[15:10]=6'b0;
rv[19:16]=4'b0;
rv[22:20]=3'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_22 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_disable_seq_8s8s8s<-sig_disable_seq_8s8s8s.bus.read();
rv[3:0]=var_disable_seq_8s8s8s;
let var_enable_seq_8s8s8s<-sig_enable_seq_8s8s8s.bus.read();
rv[8:4]=var_enable_seq_8s8s8s;
let var_xip_supported_088<-sig_xip_supported_088.bus.read();
rv[9:9]=var_xip_supported_088;
let var_xip_exit_088<-sig_xip_exit_088.bus.read();
rv[15:10]=var_xip_exit_088;
let var_xip_entry_088<-sig_xip_entry_088.bus.read();
rv[19:16]=var_xip_entry_088;
let var_octal_enable_req<-sig_octal_enable_req.bus.read();
rv[22:20]=var_octal_enable_req;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_23;
    interface HW_reg_6_4_23_max_4S_speed_without_ds smax_4S_speed_without_ds;
interface HW_reg_6_4_23_max_4S_speed_with_ds smax_4S_speed_with_ds;
interface HW_reg_6_4_23_max_4D_speed_without_ds smax_4D_speed_without_ds;
interface HW_reg_6_4_23_max_4D_speed_with_ds smax_4D_speed_with_ds;
interface HW_reg_6_4_23_max_8S_speed_without_ds smax_8S_speed_without_ds;
interface HW_reg_6_4_23_max_8S_speed_with_ds smax_8S_speed_with_ds;
interface HW_reg_6_4_23_max_8D_speed_without_ds smax_8D_speed_without_ds;
interface HW_reg_6_4_23_max_8D_speed_with_ds smax_8D_speed_with_ds;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_23;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_23;
interface ConfigReg_HW_reg_6_4_23 hw;
interface ConfigReg_Bus_reg_6_4_23 bus;
endinterface
module mkConfigReg_reg_6_4_23(ConfigReg_reg_6_4_23);
    Ifc_CSRSignal_reg_6_4_23_max_4S_speed_without_ds sig_max_4S_speed_without_ds <- mkCSRSignal_reg_6_4_23_max_4S_speed_without_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_4S_speed_with_ds sig_max_4S_speed_with_ds <- mkCSRSignal_reg_6_4_23_max_4S_speed_with_ds(7);
Ifc_CSRSignal_reg_6_4_23_max_4D_speed_without_ds sig_max_4D_speed_without_ds <- mkCSRSignal_reg_6_4_23_max_4D_speed_without_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_4D_speed_with_ds sig_max_4D_speed_with_ds <- mkCSRSignal_reg_6_4_23_max_4D_speed_with_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_8S_speed_without_ds sig_max_8S_speed_without_ds <- mkCSRSignal_reg_6_4_23_max_8S_speed_without_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_8S_speed_with_ds sig_max_8S_speed_with_ds <- mkCSRSignal_reg_6_4_23_max_8S_speed_with_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_8D_speed_without_ds sig_max_8D_speed_without_ds <- mkCSRSignal_reg_6_4_23_max_8D_speed_without_ds(8);
Ifc_CSRSignal_reg_6_4_23_max_8D_speed_with_ds sig_max_8D_speed_with_ds <- mkCSRSignal_reg_6_4_23_max_8D_speed_with_ds(8);

interface ConfigReg_HW_reg_6_4_23 hw;
    interface HW_reg_6_4_23_max_4S_speed_without_ds smax_4S_speed_without_ds = sig_max_4S_speed_without_ds.hw;
interface HW_reg_6_4_23_max_4S_speed_with_ds smax_4S_speed_with_ds = sig_max_4S_speed_with_ds.hw;
interface HW_reg_6_4_23_max_4D_speed_without_ds smax_4D_speed_without_ds = sig_max_4D_speed_without_ds.hw;
interface HW_reg_6_4_23_max_4D_speed_with_ds smax_4D_speed_with_ds = sig_max_4D_speed_with_ds.hw;
interface HW_reg_6_4_23_max_8S_speed_without_ds smax_8S_speed_without_ds = sig_max_8S_speed_without_ds.hw;
interface HW_reg_6_4_23_max_8S_speed_with_ds smax_8S_speed_with_ds = sig_max_8S_speed_with_ds.hw;
interface HW_reg_6_4_23_max_8D_speed_without_ds smax_8D_speed_without_ds = sig_max_8D_speed_without_ds.hw;
interface HW_reg_6_4_23_max_8D_speed_with_ds smax_8D_speed_with_ds = sig_max_8D_speed_with_ds.hw;

    method Bit#(32) value();
    let rv=0;
rv[3:0]=4'b0;
rv[7:4]=4'b0;
rv[11:8]=4'b0;
rv[15:12]=4'b0;
rv[19:16]=4'b0;
rv[23:20]=4'b0;
rv[27:24]=4'b0;
rv[31:28]=4'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_23 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_max_4S_speed_without_ds<-sig_max_4S_speed_without_ds.bus.read();
rv[3:0]=var_max_4S_speed_without_ds;
let var_max_4S_speed_with_ds<-sig_max_4S_speed_with_ds.bus.read();
rv[7:4]=var_max_4S_speed_with_ds;
let var_max_4D_speed_without_ds<-sig_max_4D_speed_without_ds.bus.read();
rv[11:8]=var_max_4D_speed_without_ds;
let var_max_4D_speed_with_ds<-sig_max_4D_speed_with_ds.bus.read();
rv[15:12]=var_max_4D_speed_with_ds;
let var_max_8S_speed_without_ds<-sig_max_8S_speed_without_ds.bus.read();
rv[19:16]=var_max_8S_speed_without_ds;
let var_max_8S_speed_with_ds<-sig_max_8S_speed_with_ds.bus.read();
rv[23:20]=var_max_8S_speed_with_ds;
let var_max_8D_speed_without_ds<-sig_max_8D_speed_without_ds.bus.read();
rv[27:24]=var_max_8D_speed_without_ds;
let var_max_8D_speed_with_ds<-sig_max_8D_speed_with_ds.bus.read();
rv[31:28]=var_max_8D_speed_with_ds;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_24;
    interface HW_reg_6_4_24_supports_4s4d4d ssupports_4s4d4d;
interface HW_reg_6_4_24_supports_1s4d4d ssupports_1s4d4d;
interface HW_reg_6_4_24_supports_1s2d2d ssupports_1s2d2d;
interface HW_reg_6_4_24_supports_1s1d1d ssupports_1s1d1d;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_24;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_24;
interface ConfigReg_HW_reg_6_4_24 hw;
interface ConfigReg_Bus_reg_6_4_24 bus;
endinterface
module mkConfigReg_reg_6_4_24(ConfigReg_reg_6_4_24);
    Ifc_CSRSignal_reg_6_4_24_supports_4s4d4d sig_supports_4s4d4d <- mkCSRSignal_reg_6_4_24_supports_4s4d4d(1);
Ifc_CSRSignal_reg_6_4_24_supports_1s4d4d sig_supports_1s4d4d <- mkCSRSignal_reg_6_4_24_supports_1s4d4d(1);
Ifc_CSRSignal_reg_6_4_24_supports_1s2d2d sig_supports_1s2d2d <- mkCSRSignal_reg_6_4_24_supports_1s2d2d(0);
Ifc_CSRSignal_reg_6_4_24_supports_1s1d1d sig_supports_1s1d1d <- mkCSRSignal_reg_6_4_24_supports_1s1d1d(0);

interface ConfigReg_HW_reg_6_4_24 hw;
    interface HW_reg_6_4_24_supports_4s4d4d ssupports_4s4d4d = sig_supports_4s4d4d.hw;
interface HW_reg_6_4_24_supports_1s4d4d ssupports_1s4d4d = sig_supports_1s4d4d.hw;
interface HW_reg_6_4_24_supports_1s2d2d ssupports_1s2d2d = sig_supports_1s2d2d.hw;
interface HW_reg_6_4_24_supports_1s1d1d ssupports_1s1d1d = sig_supports_1s1d1d.hw;

    method Bit#(32) value();
    let rv=0;
rv[2:0]=3'b0;
rv[4:3]=2'b0;
rv[5:5]=1'b0;
rv[6:6]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_24 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_supports_4s4d4d<-sig_supports_4s4d4d.bus.read();
rv[2:0]=var_supports_4s4d4d;
let var_supports_1s4d4d<-sig_supports_1s4d4d.bus.read();
rv[4:3]=var_supports_1s4d4d;
let var_supports_1s2d2d<-sig_supports_1s2d2d.bus.read();
rv[5:5]=var_supports_1s2d2d;
let var_supports_1s1d1d<-sig_supports_1s1d1d.bus.read();
rv[6:6]=var_supports_1s1d1d;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_25;
    interface HW_reg_6_4_25_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_25;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_25;
interface ConfigReg_HW_reg_6_4_25 hw;
interface ConfigReg_Bus_reg_6_4_25 bus;
endinterface
module mkConfigReg_reg_6_4_25(ConfigReg_reg_6_4_25);
    Ifc_CSRSignal_reg_6_4_25_reserved sig_reserved <- mkCSRSignal_reg_6_4_25_reserved(0);

interface ConfigReg_HW_reg_6_4_25 hw;
    interface HW_reg_6_4_25_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_25 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_4_26;
    interface HW_reg_6_4_26_waitstate_1s4d4d swaitstate_1s4d4d;
interface HW_reg_6_4_26_mode_1s4d4d smode_1s4d4d;
interface HW_reg_6_4_26_fr_inst_1s4d4d sfr_inst_1s4d4d;
interface HW_reg_6_4_26_waitstate_4s4d4d swaitstate_4s4d4d;
interface HW_reg_6_4_26_mode_4s4d4d smode_4s4d4d;
interface HW_reg_6_4_26_fr_inst_4s4d4d sfr_inst_4s4d4d;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_4_26;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_4_26;
interface ConfigReg_HW_reg_6_4_26 hw;
interface ConfigReg_Bus_reg_6_4_26 bus;
endinterface
module mkConfigReg_reg_6_4_26(ConfigReg_reg_6_4_26);
    Ifc_CSRSignal_reg_6_4_26_waitstate_1s4d4d sig_waitstate_1s4d4d <- mkCSRSignal_reg_6_4_26_waitstate_1s4d4d(2);
Ifc_CSRSignal_reg_6_4_26_mode_1s4d4d sig_mode_1s4d4d <- mkCSRSignal_reg_6_4_26_mode_1s4d4d(0);
Ifc_CSRSignal_reg_6_4_26_fr_inst_1s4d4d sig_fr_inst_1s4d4d <- mkCSRSignal_reg_6_4_26_fr_inst_1s4d4d(177);
Ifc_CSRSignal_reg_6_4_26_waitstate_4s4d4d sig_waitstate_4s4d4d <- mkCSRSignal_reg_6_4_26_waitstate_4s4d4d(2);
Ifc_CSRSignal_reg_6_4_26_mode_4s4d4d sig_mode_4s4d4d <- mkCSRSignal_reg_6_4_26_mode_4s4d4d(0);
Ifc_CSRSignal_reg_6_4_26_fr_inst_4s4d4d sig_fr_inst_4s4d4d <- mkCSRSignal_reg_6_4_26_fr_inst_4s4d4d(176);

interface ConfigReg_HW_reg_6_4_26 hw;
    interface HW_reg_6_4_26_waitstate_1s4d4d swaitstate_1s4d4d = sig_waitstate_1s4d4d.hw;
interface HW_reg_6_4_26_mode_1s4d4d smode_1s4d4d = sig_mode_1s4d4d.hw;
interface HW_reg_6_4_26_fr_inst_1s4d4d sfr_inst_1s4d4d = sig_fr_inst_1s4d4d.hw;
interface HW_reg_6_4_26_waitstate_4s4d4d swaitstate_4s4d4d = sig_waitstate_4s4d4d.hw;
interface HW_reg_6_4_26_mode_4s4d4d smode_4s4d4d = sig_mode_4s4d4d.hw;
interface HW_reg_6_4_26_fr_inst_4s4d4d sfr_inst_4s4d4d = sig_fr_inst_4s4d4d.hw;

    method Bit#(32) value();
    let rv=0;
rv[4:0]=5'b0;
rv[7:5]=3'b0;
rv[15:8]=8'b0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_4_26 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_waitstate_1s4d4d<-sig_waitstate_1s4d4d.bus.read();
rv[4:0]=var_waitstate_1s4d4d;
let var_mode_1s4d4d<-sig_mode_1s4d4d.bus.read();
rv[7:5]=var_mode_1s4d4d;
let var_fr_inst_1s4d4d<-sig_fr_inst_1s4d4d.bus.read();
rv[15:8]=var_fr_inst_1s4d4d;
let var_waitstate_4s4d4d<-sig_waitstate_4s4d4d.bus.read();
rv[20:16]=var_waitstate_4s4d4d;
let var_mode_4s4d4d<-sig_mode_4s4d4d.bus.read();
rv[23:21]=var_mode_4s4d4d;
let var_fr_inst_4s4d4d<-sig_fr_inst_4s4d4d.bus.read();
rv[31:24]=var_fr_inst_4s4d4d;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_7_3;
    interface HW_reg_6_7_3_r_inst_1s1s1s sr_inst_1s1s1s;
interface HW_reg_6_7_3_fr_inst_1s1s1s sfr_inst_1s1s1s;
interface HW_reg_6_7_3_reserved_2s sreserved_2s;
interface HW_reg_6_7_3_fr_inst_1s1s4s sfr_inst_1s1s4s;
interface HW_reg_6_7_3_fr_inst_1s4s4s sfr_inst_1s4s4s;
interface HW_reg_6_7_3_erase_reserved serase_reserved;
interface HW_reg_6_7_3_fr_inst_1s1d1d sfr_inst_1s1d1d;
interface HW_reg_6_7_3_fr_inst_1s2d2d sfr_inst_1s2d2d;
interface HW_reg_6_7_3_fr_inst_1s4d4d sfr_inst_1s4d4d;
interface HW_reg_6_7_3_sector_reserved ssector_reserved;
interface HW_reg_6_7_3_fr_inst_1s1s8s sfr_inst_1s1s8s;
interface HW_reg_6_7_3_fr_inst_1s8s8s sfr_inst_1s8s8s;
interface HW_reg_6_7_3_fr_inst_1s8d8d sfr_inst_1s8d8d;
interface HW_reg_6_7_3_page_program_support_1s1s8s spage_program_support_1s1s8s;
interface HW_reg_6_7_3_page_program_support_1s8s8s spage_program_support_1s8s8s;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_7_3;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_7_3;
interface ConfigReg_HW_reg_6_7_3 hw;
interface ConfigReg_Bus_reg_6_7_3 bus;
endinterface
module mkConfigReg_reg_6_7_3(ConfigReg_reg_6_7_3);
    Ifc_CSRSignal_reg_6_7_3_r_inst_1s1s1s sig_r_inst_1s1s1s <- mkCSRSignal_reg_6_7_3_r_inst_1s1s1s(1);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s1s sig_fr_inst_1s1s1s <- mkCSRSignal_reg_6_7_3_fr_inst_1s1s1s(1);
Ifc_CSRSignal_reg_6_7_3_reserved_2s sig_reserved_2s <- mkCSRSignal_reg_6_7_3_reserved_2s(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s4s sig_fr_inst_1s1s4s <- mkCSRSignal_reg_6_7_3_fr_inst_1s1s4s(1);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4s4s sig_fr_inst_1s4s4s <- mkCSRSignal_reg_6_7_3_fr_inst_1s4s4s(1);
Ifc_CSRSignal_reg_6_7_3_erase_reserved sig_erase_reserved <- mkCSRSignal_reg_6_7_3_erase_reserved(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1d1d sig_fr_inst_1s1d1d <- mkCSRSignal_reg_6_7_3_fr_inst_1s1d1d(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s2d2d sig_fr_inst_1s2d2d <- mkCSRSignal_reg_6_7_3_fr_inst_1s2d2d(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4d4d sig_fr_inst_1s4d4d <- mkCSRSignal_reg_6_7_3_fr_inst_1s4d4d(0);
Ifc_CSRSignal_reg_6_7_3_sector_reserved sig_sector_reserved <- mkCSRSignal_reg_6_7_3_sector_reserved(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s8s sig_fr_inst_1s1s8s <- mkCSRSignal_reg_6_7_3_fr_inst_1s1s8s(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8s8s sig_fr_inst_1s8s8s <- mkCSRSignal_reg_6_7_3_fr_inst_1s8s8s(0);
Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8d8d sig_fr_inst_1s8d8d <- mkCSRSignal_reg_6_7_3_fr_inst_1s8d8d(0);
Ifc_CSRSignal_reg_6_7_3_page_program_support_1s1s8s sig_page_program_support_1s1s8s <- mkCSRSignal_reg_6_7_3_page_program_support_1s1s8s(0);
Ifc_CSRSignal_reg_6_7_3_page_program_support_1s8s8s sig_page_program_support_1s8s8s <- mkCSRSignal_reg_6_7_3_page_program_support_1s8s8s(0);

interface ConfigReg_HW_reg_6_7_3 hw;
    interface HW_reg_6_7_3_r_inst_1s1s1s sr_inst_1s1s1s = sig_r_inst_1s1s1s.hw;
interface HW_reg_6_7_3_fr_inst_1s1s1s sfr_inst_1s1s1s = sig_fr_inst_1s1s1s.hw;
interface HW_reg_6_7_3_reserved_2s sreserved_2s = sig_reserved_2s.hw;
interface HW_reg_6_7_3_fr_inst_1s1s4s sfr_inst_1s1s4s = sig_fr_inst_1s1s4s.hw;
interface HW_reg_6_7_3_fr_inst_1s4s4s sfr_inst_1s4s4s = sig_fr_inst_1s4s4s.hw;
interface HW_reg_6_7_3_erase_reserved serase_reserved = sig_erase_reserved.hw;
interface HW_reg_6_7_3_fr_inst_1s1d1d sfr_inst_1s1d1d = sig_fr_inst_1s1d1d.hw;
interface HW_reg_6_7_3_fr_inst_1s2d2d sfr_inst_1s2d2d = sig_fr_inst_1s2d2d.hw;
interface HW_reg_6_7_3_fr_inst_1s4d4d sfr_inst_1s4d4d = sig_fr_inst_1s4d4d.hw;
interface HW_reg_6_7_3_sector_reserved ssector_reserved = sig_sector_reserved.hw;
interface HW_reg_6_7_3_fr_inst_1s1s8s sfr_inst_1s1s8s = sig_fr_inst_1s1s8s.hw;
interface HW_reg_6_7_3_fr_inst_1s8s8s sfr_inst_1s8s8s = sig_fr_inst_1s8s8s.hw;
interface HW_reg_6_7_3_fr_inst_1s8d8d sfr_inst_1s8d8d = sig_fr_inst_1s8d8d.hw;
interface HW_reg_6_7_3_page_program_support_1s1s8s spage_program_support_1s1s8s = sig_page_program_support_1s1s8s.hw;
interface HW_reg_6_7_3_page_program_support_1s8s8s spage_program_support_1s8s8s = sig_page_program_support_1s8s8s.hw;

    method Bit#(32) value();
    let rv=0;
rv[0:0]=1'b0;
rv[1:1]=1'b0;
rv[3:2]=2'b0;
rv[4:4]=1'b0;
rv[5:5]=1'b0;
rv[12:6]=7'b0;
rv[13:13]=1'b0;
rv[14:14]=1'b0;
rv[15:15]=1'b0;
rv[19:16]=4'b0;
rv[20:20]=1'b0;
rv[21:21]=1'b0;
rv[22:22]=1'b0;
rv[23:23]=1'b0;
rv[24:24]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_7_3 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_r_inst_1s1s1s<-sig_r_inst_1s1s1s.bus.read();
rv[0:0]=var_r_inst_1s1s1s;
let var_fr_inst_1s1s1s<-sig_fr_inst_1s1s1s.bus.read();
rv[1:1]=var_fr_inst_1s1s1s;
let var_reserved_2s<-sig_reserved_2s.bus.read();
rv[3:2]=var_reserved_2s;
let var_fr_inst_1s1s4s<-sig_fr_inst_1s1s4s.bus.read();
rv[4:4]=var_fr_inst_1s1s4s;
let var_fr_inst_1s4s4s<-sig_fr_inst_1s4s4s.bus.read();
rv[5:5]=var_fr_inst_1s4s4s;
let var_erase_reserved<-sig_erase_reserved.bus.read();
rv[12:6]=var_erase_reserved;
let var_fr_inst_1s1d1d<-sig_fr_inst_1s1d1d.bus.read();
rv[13:13]=var_fr_inst_1s1d1d;
let var_fr_inst_1s2d2d<-sig_fr_inst_1s2d2d.bus.read();
rv[14:14]=var_fr_inst_1s2d2d;
let var_fr_inst_1s4d4d<-sig_fr_inst_1s4d4d.bus.read();
rv[15:15]=var_fr_inst_1s4d4d;
let var_sector_reserved<-sig_sector_reserved.bus.read();
rv[19:16]=var_sector_reserved;
let var_fr_inst_1s1s8s<-sig_fr_inst_1s1s8s.bus.read();
rv[20:20]=var_fr_inst_1s1s8s;
let var_fr_inst_1s8s8s<-sig_fr_inst_1s8s8s.bus.read();
rv[21:21]=var_fr_inst_1s8s8s;
let var_fr_inst_1s8d8d<-sig_fr_inst_1s8d8d.bus.read();
rv[22:22]=var_fr_inst_1s8d8d;
let var_page_program_support_1s1s8s<-sig_page_program_support_1s1s8s.bus.read();
rv[23:23]=var_page_program_support_1s1s8s;
let var_page_program_support_1s8s8s<-sig_page_program_support_1s8s8s.bus.read();
rv[24:24]=var_page_program_support_1s8s8s;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_7_4;
    interface HW_reg_6_7_4_erase_reserved serase_reserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_7_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_7_4;
interface ConfigReg_HW_reg_6_7_4 hw;
interface ConfigReg_Bus_reg_6_7_4 bus;
endinterface
module mkConfigReg_reg_6_7_4(ConfigReg_reg_6_7_4);
    Ifc_CSRSignal_reg_6_7_4_erase_reserved sig_erase_reserved <- mkCSRSignal_reg_6_7_4_erase_reserved(0);

interface ConfigReg_HW_reg_6_7_4 hw;
    interface HW_reg_6_7_4_erase_reserved serase_reserved = sig_erase_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_7_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_erase_reserved<-sig_erase_reserved.bus.read();
rv[31:0]=var_erase_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_9_3;
    interface HW_reg_6_9_3_reserved sreserved;
interface HW_reg_6_9_3_enter_spi_supported senter_spi_supported;
interface HW_reg_6_9_3_pgm_reserved spgm_reserved;
interface HW_reg_6_9_3_deep_pd_support sdeep_pd_support;
interface HW_reg_6_9_3_cfg_reg_load_support scfg_reg_load_support;
interface HW_reg_6_9_3_cfg_reg_read_suport scfg_reg_read_suport;
interface HW_reg_6_9_3_sts_reg_clr_support ssts_reg_clr_support;
interface HW_reg_6_9_3_sts_reg_read_support ssts_reg_read_support;
interface HW_reg_6_9_3_sren_support ssren_support;
interface HW_reg_6_9_3_wren2_support swren2_support;
interface HW_reg_6_9_3_wren1_support swren1_support;
interface HW_reg_6_9_3_write_mem_linear swrite_mem_linear;
interface HW_reg_6_9_3_write_mem_wrapped swrite_mem_wrapped;
interface HW_reg_6_9_3_write_reg_linear swrite_reg_linear;
interface HW_reg_6_9_3_write_reg_wrapped swrite_reg_wrapped;
interface HW_reg_6_9_3_read_mem_linear sread_mem_linear;
interface HW_reg_6_9_3_read_mem_wrapped sread_mem_wrapped;
interface HW_reg_6_9_3_read_reg_linear sread_reg_linear;
interface HW_reg_6_9_3_read_reg_wrapped sread_reg_wrapped;
interface HW_reg_6_9_3_xspi_profile_2_support sxspi_profile_2_support;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_9_3;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_9_3;
interface ConfigReg_HW_reg_6_9_3 hw;
interface ConfigReg_Bus_reg_6_9_3 bus;
endinterface
module mkConfigReg_reg_6_9_3(ConfigReg_reg_6_9_3);
    Ifc_CSRSignal_reg_6_9_3_reserved sig_reserved <- mkCSRSignal_reg_6_9_3_reserved(0);
Ifc_CSRSignal_reg_6_9_3_enter_spi_supported sig_enter_spi_supported <- mkCSRSignal_reg_6_9_3_enter_spi_supported(1);
Ifc_CSRSignal_reg_6_9_3_pgm_reserved sig_pgm_reserved <- mkCSRSignal_reg_6_9_3_pgm_reserved(0);
Ifc_CSRSignal_reg_6_9_3_deep_pd_support sig_deep_pd_support <- mkCSRSignal_reg_6_9_3_deep_pd_support(1);
Ifc_CSRSignal_reg_6_9_3_cfg_reg_load_support sig_cfg_reg_load_support <- mkCSRSignal_reg_6_9_3_cfg_reg_load_support(1);
Ifc_CSRSignal_reg_6_9_3_cfg_reg_read_suport sig_cfg_reg_read_suport <- mkCSRSignal_reg_6_9_3_cfg_reg_read_suport(1);
Ifc_CSRSignal_reg_6_9_3_sts_reg_clr_support sig_sts_reg_clr_support <- mkCSRSignal_reg_6_9_3_sts_reg_clr_support(1);
Ifc_CSRSignal_reg_6_9_3_sts_reg_read_support sig_sts_reg_read_support <- mkCSRSignal_reg_6_9_3_sts_reg_read_support(1);
Ifc_CSRSignal_reg_6_9_3_sren_support sig_sren_support <- mkCSRSignal_reg_6_9_3_sren_support(0);
Ifc_CSRSignal_reg_6_9_3_wren2_support sig_wren2_support <- mkCSRSignal_reg_6_9_3_wren2_support(0);
Ifc_CSRSignal_reg_6_9_3_wren1_support sig_wren1_support <- mkCSRSignal_reg_6_9_3_wren1_support(0);
Ifc_CSRSignal_reg_6_9_3_write_mem_linear sig_write_mem_linear <- mkCSRSignal_reg_6_9_3_write_mem_linear(1);
Ifc_CSRSignal_reg_6_9_3_write_mem_wrapped sig_write_mem_wrapped <- mkCSRSignal_reg_6_9_3_write_mem_wrapped(0);
Ifc_CSRSignal_reg_6_9_3_write_reg_linear sig_write_reg_linear <- mkCSRSignal_reg_6_9_3_write_reg_linear(1);
Ifc_CSRSignal_reg_6_9_3_write_reg_wrapped sig_write_reg_wrapped <- mkCSRSignal_reg_6_9_3_write_reg_wrapped(0);
Ifc_CSRSignal_reg_6_9_3_read_mem_linear sig_read_mem_linear <- mkCSRSignal_reg_6_9_3_read_mem_linear(1);
Ifc_CSRSignal_reg_6_9_3_read_mem_wrapped sig_read_mem_wrapped <- mkCSRSignal_reg_6_9_3_read_mem_wrapped(0);
Ifc_CSRSignal_reg_6_9_3_read_reg_linear sig_read_reg_linear <- mkCSRSignal_reg_6_9_3_read_reg_linear(1);
Ifc_CSRSignal_reg_6_9_3_read_reg_wrapped sig_read_reg_wrapped <- mkCSRSignal_reg_6_9_3_read_reg_wrapped(0);
Ifc_CSRSignal_reg_6_9_3_xspi_profile_2_support sig_xspi_profile_2_support <- mkCSRSignal_reg_6_9_3_xspi_profile_2_support(1);

interface ConfigReg_HW_reg_6_9_3 hw;
    interface HW_reg_6_9_3_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_9_3_enter_spi_supported senter_spi_supported = sig_enter_spi_supported.hw;
interface HW_reg_6_9_3_pgm_reserved spgm_reserved = sig_pgm_reserved.hw;
interface HW_reg_6_9_3_deep_pd_support sdeep_pd_support = sig_deep_pd_support.hw;
interface HW_reg_6_9_3_cfg_reg_load_support scfg_reg_load_support = sig_cfg_reg_load_support.hw;
interface HW_reg_6_9_3_cfg_reg_read_suport scfg_reg_read_suport = sig_cfg_reg_read_suport.hw;
interface HW_reg_6_9_3_sts_reg_clr_support ssts_reg_clr_support = sig_sts_reg_clr_support.hw;
interface HW_reg_6_9_3_sts_reg_read_support ssts_reg_read_support = sig_sts_reg_read_support.hw;
interface HW_reg_6_9_3_sren_support ssren_support = sig_sren_support.hw;
interface HW_reg_6_9_3_wren2_support swren2_support = sig_wren2_support.hw;
interface HW_reg_6_9_3_wren1_support swren1_support = sig_wren1_support.hw;
interface HW_reg_6_9_3_write_mem_linear swrite_mem_linear = sig_write_mem_linear.hw;
interface HW_reg_6_9_3_write_mem_wrapped swrite_mem_wrapped = sig_write_mem_wrapped.hw;
interface HW_reg_6_9_3_write_reg_linear swrite_reg_linear = sig_write_reg_linear.hw;
interface HW_reg_6_9_3_write_reg_wrapped swrite_reg_wrapped = sig_write_reg_wrapped.hw;
interface HW_reg_6_9_3_read_mem_linear sread_mem_linear = sig_read_mem_linear.hw;
interface HW_reg_6_9_3_read_mem_wrapped sread_mem_wrapped = sig_read_mem_wrapped.hw;
interface HW_reg_6_9_3_read_reg_linear sread_reg_linear = sig_read_reg_linear.hw;
interface HW_reg_6_9_3_read_reg_wrapped sread_reg_wrapped = sig_read_reg_wrapped.hw;
interface HW_reg_6_9_3_xspi_profile_2_support sxspi_profile_2_support = sig_xspi_profile_2_support.hw;

    method Bit#(32) value();
    let rv=0;
rv[4:0]=5'b0;
rv[5:5]=1'b0;
rv[14:6]=9'b0;
rv[15:15]=1'b0;
rv[16:16]=1'b0;
rv[17:17]=1'b0;
rv[18:18]=1'b0;
rv[19:19]=1'b0;
rv[20:20]=1'b0;
rv[21:21]=1'b0;
rv[22:22]=1'b0;
rv[23:23]=1'b0;
rv[24:24]=1'b0;
rv[25:25]=1'b0;
rv[26:26]=1'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[29:29]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_9_3 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[4:0]=var_reserved;
let var_enter_spi_supported<-sig_enter_spi_supported.bus.read();
rv[5:5]=var_enter_spi_supported;
let var_pgm_reserved<-sig_pgm_reserved.bus.read();
rv[14:6]=var_pgm_reserved;
let var_deep_pd_support<-sig_deep_pd_support.bus.read();
rv[15:15]=var_deep_pd_support;
let var_cfg_reg_load_support<-sig_cfg_reg_load_support.bus.read();
rv[16:16]=var_cfg_reg_load_support;
let var_cfg_reg_read_suport<-sig_cfg_reg_read_suport.bus.read();
rv[17:17]=var_cfg_reg_read_suport;
let var_sts_reg_clr_support<-sig_sts_reg_clr_support.bus.read();
rv[18:18]=var_sts_reg_clr_support;
let var_sts_reg_read_support<-sig_sts_reg_read_support.bus.read();
rv[19:19]=var_sts_reg_read_support;
let var_sren_support<-sig_sren_support.bus.read();
rv[20:20]=var_sren_support;
let var_wren2_support<-sig_wren2_support.bus.read();
rv[21:21]=var_wren2_support;
let var_wren1_support<-sig_wren1_support.bus.read();
rv[22:22]=var_wren1_support;
let var_write_mem_linear<-sig_write_mem_linear.bus.read();
rv[23:23]=var_write_mem_linear;
let var_write_mem_wrapped<-sig_write_mem_wrapped.bus.read();
rv[24:24]=var_write_mem_wrapped;
let var_write_reg_linear<-sig_write_reg_linear.bus.read();
rv[25:25]=var_write_reg_linear;
let var_write_reg_wrapped<-sig_write_reg_wrapped.bus.read();
rv[26:26]=var_write_reg_wrapped;
let var_read_mem_linear<-sig_read_mem_linear.bus.read();
rv[27:27]=var_read_mem_linear;
let var_read_mem_wrapped<-sig_read_mem_wrapped.bus.read();
rv[28:28]=var_read_mem_wrapped;
let var_read_reg_linear<-sig_read_reg_linear.bus.read();
rv[29:29]=var_read_reg_linear;
let var_read_reg_wrapped<-sig_read_reg_wrapped.bus.read();
rv[30:30]=var_read_reg_wrapped;
let var_xspi_profile_2_support<-sig_xspi_profile_2_support.bus.read();
rv[31:31]=var_xspi_profile_2_support;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_9_4;
    interface HW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required scfg_bit_pattern_num_dymmy_cycl_required;
interface HW_reg_6_9_4_num_dymmy_cycl_required snum_dymmy_cycl_required;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_9_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_9_4;
interface ConfigReg_HW_reg_6_9_4 hw;
interface ConfigReg_Bus_reg_6_9_4 bus;
endinterface
module mkConfigReg_reg_6_9_4(ConfigReg_reg_6_9_4);
    Ifc_CSRSignal_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required sig_cfg_bit_pattern_num_dymmy_cycl_required <- mkCSRSignal_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required(2);
Ifc_CSRSignal_reg_6_9_4_num_dymmy_cycl_required sig_num_dymmy_cycl_required <- mkCSRSignal_reg_6_9_4_num_dymmy_cycl_required(2);

interface ConfigReg_HW_reg_6_9_4 hw;
    interface HW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required scfg_bit_pattern_num_dymmy_cycl_required = sig_cfg_bit_pattern_num_dymmy_cycl_required.hw;
interface HW_reg_6_9_4_num_dymmy_cycl_required snum_dymmy_cycl_required = sig_num_dymmy_cycl_required.hw;

    method Bit#(32) value();
    let rv=0;
rv[6:2]=5'b0;
rv[11:7]=5'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_9_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_cfg_bit_pattern_num_dymmy_cycl_required<-sig_cfg_bit_pattern_num_dymmy_cycl_required.bus.read();
rv[6:2]=var_cfg_bit_pattern_num_dymmy_cycl_required;
let var_num_dymmy_cycl_required<-sig_num_dymmy_cycl_required.bus.read();
rv[11:7]=var_num_dymmy_cycl_required;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_9_5;
    interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 scfg_bit_pattern_num_dymmy_cycl_required_100;
interface HW_reg_6_9_5_num_dymmy_cycl_required_100 snum_dymmy_cycl_required_100;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 scfg_bit_pattern_num_dymmy_cycl_required_133;
interface HW_reg_6_9_5_num_dymmy_cycl_required_133 snum_dymmy_cycl_required_133;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 scfg_bit_pattern_num_dymmy_cycl_required_166;
interface HW_reg_6_9_5_num_dymmy_cycl_required_166 snum_dymmy_cycl_required_166;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_9_5;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_9_5;
interface ConfigReg_HW_reg_6_9_5 hw;
interface ConfigReg_Bus_reg_6_9_5 bus;
endinterface
module mkConfigReg_reg_6_9_5(ConfigReg_reg_6_9_5);
    Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 sig_cfg_bit_pattern_num_dymmy_cycl_required_100 <- mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100(2);
Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_100 sig_num_dymmy_cycl_required_100 <- mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_100(2);
Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 sig_cfg_bit_pattern_num_dymmy_cycl_required_133 <- mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133(2);
Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_133 sig_num_dymmy_cycl_required_133 <- mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_133(2);
Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 sig_cfg_bit_pattern_num_dymmy_cycl_required_166 <- mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166(2);
Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_166 sig_num_dymmy_cycl_required_166 <- mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_166(2);

interface ConfigReg_HW_reg_6_9_5 hw;
    interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 scfg_bit_pattern_num_dymmy_cycl_required_100 = sig_cfg_bit_pattern_num_dymmy_cycl_required_100.hw;
interface HW_reg_6_9_5_num_dymmy_cycl_required_100 snum_dymmy_cycl_required_100 = sig_num_dymmy_cycl_required_100.hw;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 scfg_bit_pattern_num_dymmy_cycl_required_133 = sig_cfg_bit_pattern_num_dymmy_cycl_required_133.hw;
interface HW_reg_6_9_5_num_dymmy_cycl_required_133 snum_dymmy_cycl_required_133 = sig_num_dymmy_cycl_required_133.hw;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 scfg_bit_pattern_num_dymmy_cycl_required_166 = sig_cfg_bit_pattern_num_dymmy_cycl_required_166.hw;
interface HW_reg_6_9_5_num_dymmy_cycl_required_166 snum_dymmy_cycl_required_166 = sig_num_dymmy_cycl_required_166.hw;

    method Bit#(32) value();
    let rv=0;
rv[6:2]=5'b0;
rv[11:7]=5'b0;
rv[16:12]=5'b0;
rv[21:17]=5'b0;
rv[26:22]=5'b0;
rv[31:27]=5'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_9_5 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_cfg_bit_pattern_num_dymmy_cycl_required_100<-sig_cfg_bit_pattern_num_dymmy_cycl_required_100.bus.read();
rv[6:2]=var_cfg_bit_pattern_num_dymmy_cycl_required_100;
let var_num_dymmy_cycl_required_100<-sig_num_dymmy_cycl_required_100.bus.read();
rv[11:7]=var_num_dymmy_cycl_required_100;
let var_cfg_bit_pattern_num_dymmy_cycl_required_133<-sig_cfg_bit_pattern_num_dymmy_cycl_required_133.bus.read();
rv[16:12]=var_cfg_bit_pattern_num_dymmy_cycl_required_133;
let var_num_dymmy_cycl_required_133<-sig_num_dymmy_cycl_required_133.bus.read();
rv[21:17]=var_num_dymmy_cycl_required_133;
let var_cfg_bit_pattern_num_dymmy_cycl_required_166<-sig_cfg_bit_pattern_num_dymmy_cycl_required_166.bus.read();
rv[26:22]=var_cfg_bit_pattern_num_dymmy_cycl_required_166;
let var_num_dymmy_cycl_required_166<-sig_num_dymmy_cycl_required_166.bus.read();
rv[31:27]=var_num_dymmy_cycl_required_166;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_3;
    interface HW_reg_6_10_3_volatile_address svolatile_address;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_3;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_3;
interface ConfigReg_HW_reg_6_10_3 hw;
interface ConfigReg_Bus_reg_6_10_3 bus;
endinterface
module mkConfigReg_reg_6_10_3(ConfigReg_reg_6_10_3);
    Ifc_CSRSignal_reg_6_10_3_volatile_address sig_volatile_address <- mkCSRSignal_reg_6_10_3_volatile_address(0);

interface ConfigReg_HW_reg_6_10_3 hw;
    interface HW_reg_6_10_3_volatile_address svolatile_address = sig_volatile_address.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_3 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_volatile_address<-sig_volatile_address.bus.read();
rv[31:0]=var_volatile_address;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_4;
    interface HW_reg_6_10_4_nonvolatile_address snonvolatile_address;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_4;
interface ConfigReg_HW_reg_6_10_4 hw;
interface ConfigReg_Bus_reg_6_10_4 bus;
endinterface
module mkConfigReg_reg_6_10_4(ConfigReg_reg_6_10_4);
    Ifc_CSRSignal_reg_6_10_4_nonvolatile_address sig_nonvolatile_address <- mkCSRSignal_reg_6_10_4_nonvolatile_address(0);

interface ConfigReg_HW_reg_6_10_4 hw;
    interface HW_reg_6_10_4_nonvolatile_address snonvolatile_address = sig_nonvolatile_address.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_nonvolatile_address<-sig_nonvolatile_address.bus.read();
rv[31:0]=var_nonvolatile_address;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_5;
    interface HW_reg_6_10_5_num_dummy_cycles_8d8d8d snum_dummy_cycles_8d8d8d;
interface HW_reg_6_10_5_num_dummy_cycles_8s8s8s snum_dummy_cycles_8s8s8s;
interface HW_reg_6_10_5_num_dummy_cycles_4d4d4d snum_dummy_cycles_4d4d4d;
interface HW_reg_6_10_5_num_dummy_cycles_4s4s4s snum_dummy_cycles_4s4s4s;
interface HW_reg_6_10_5_num_dummy_cycles_2s2s2s snum_dummy_cycles_2s2s2s;
interface HW_reg_6_10_5_num_dummy_cycles_1s1s1s snum_dummy_cycles_1s1s1s;
interface HW_reg_6_10_5_num_addr_bytes snum_addr_bytes;
interface HW_reg_6_10_5_gen_reg_write_supported sgen_reg_write_supported;
interface HW_reg_6_10_5_gen_reg_read_supported sgen_reg_read_supported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_5;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_5;
interface ConfigReg_HW_reg_6_10_5 hw;
interface ConfigReg_Bus_reg_6_10_5 bus;
endinterface
module mkConfigReg_reg_6_10_5(ConfigReg_reg_6_10_5);
    Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8d8d8d sig_num_dummy_cycles_8d8d8d <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_8d8d8d(0);
Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8s8s8s sig_num_dummy_cycles_8s8s8s <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_8s8s8s(0);
Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4d4d4d sig_num_dummy_cycles_4d4d4d <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_4d4d4d(0);
Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4s4s4s sig_num_dummy_cycles_4s4s4s <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_4s4s4s(0);
Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_2s2s2s sig_num_dummy_cycles_2s2s2s <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_2s2s2s(15);
Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_1s1s1s sig_num_dummy_cycles_1s1s1s <- mkCSRSignal_reg_6_10_5_num_dummy_cycles_1s1s1s(0);
Ifc_CSRSignal_reg_6_10_5_num_addr_bytes sig_num_addr_bytes <- mkCSRSignal_reg_6_10_5_num_addr_bytes(3);
Ifc_CSRSignal_reg_6_10_5_gen_reg_write_supported sig_gen_reg_write_supported <- mkCSRSignal_reg_6_10_5_gen_reg_write_supported(1);
Ifc_CSRSignal_reg_6_10_5_gen_reg_read_supported sig_gen_reg_read_supported <- mkCSRSignal_reg_6_10_5_gen_reg_read_supported(1);

interface ConfigReg_HW_reg_6_10_5 hw;
    interface HW_reg_6_10_5_num_dummy_cycles_8d8d8d snum_dummy_cycles_8d8d8d = sig_num_dummy_cycles_8d8d8d.hw;
interface HW_reg_6_10_5_num_dummy_cycles_8s8s8s snum_dummy_cycles_8s8s8s = sig_num_dummy_cycles_8s8s8s.hw;
interface HW_reg_6_10_5_num_dummy_cycles_4d4d4d snum_dummy_cycles_4d4d4d = sig_num_dummy_cycles_4d4d4d.hw;
interface HW_reg_6_10_5_num_dummy_cycles_4s4s4s snum_dummy_cycles_4s4s4s = sig_num_dummy_cycles_4s4s4s.hw;
interface HW_reg_6_10_5_num_dummy_cycles_2s2s2s snum_dummy_cycles_2s2s2s = sig_num_dummy_cycles_2s2s2s.hw;
interface HW_reg_6_10_5_num_dummy_cycles_1s1s1s snum_dummy_cycles_1s1s1s = sig_num_dummy_cycles_1s1s1s.hw;
interface HW_reg_6_10_5_num_addr_bytes snum_addr_bytes = sig_num_addr_bytes.hw;
interface HW_reg_6_10_5_gen_reg_write_supported sgen_reg_write_supported = sig_gen_reg_write_supported.hw;
interface HW_reg_6_10_5_gen_reg_read_supported sgen_reg_read_supported = sig_gen_reg_read_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[9:6]=4'b0;
rv[13:10]=4'b0;
rv[17:14]=4'b0;
rv[21:18]=4'b0;
rv[25:22]=4'b0;
rv[27:26]=2'b0;
rv[29:28]=2'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_5 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_num_dummy_cycles_8d8d8d<-sig_num_dummy_cycles_8d8d8d.bus.read();
rv[9:6]=var_num_dummy_cycles_8d8d8d;
let var_num_dummy_cycles_8s8s8s<-sig_num_dummy_cycles_8s8s8s.bus.read();
rv[13:10]=var_num_dummy_cycles_8s8s8s;
let var_num_dummy_cycles_4d4d4d<-sig_num_dummy_cycles_4d4d4d.bus.read();
rv[17:14]=var_num_dummy_cycles_4d4d4d;
let var_num_dummy_cycles_4s4s4s<-sig_num_dummy_cycles_4s4s4s.bus.read();
rv[21:18]=var_num_dummy_cycles_4s4s4s;
let var_num_dummy_cycles_2s2s2s<-sig_num_dummy_cycles_2s2s2s.bus.read();
rv[25:22]=var_num_dummy_cycles_2s2s2s;
let var_num_dummy_cycles_1s1s1s<-sig_num_dummy_cycles_1s1s1s.bus.read();
rv[27:26]=var_num_dummy_cycles_1s1s1s;
let var_num_addr_bytes<-sig_num_addr_bytes.bus.read();
rv[29:28]=var_num_addr_bytes;
let var_gen_reg_write_supported<-sig_gen_reg_write_supported.bus.read();
rv[30:30]=var_gen_reg_write_supported;
let var_gen_reg_read_supported<-sig_gen_reg_read_supported.bus.read();
rv[31:31]=var_gen_reg_read_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_6;
    interface HW_reg_6_10_6_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_6;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_6;
interface ConfigReg_HW_reg_6_10_6 hw;
interface ConfigReg_Bus_reg_6_10_6 bus;
endinterface
module mkConfigReg_reg_6_10_6(ConfigReg_reg_6_10_6);
    Ifc_CSRSignal_reg_6_10_6_reserved sig_reserved <- mkCSRSignal_reg_6_10_6_reserved(0);

interface ConfigReg_HW_reg_6_10_6 hw;
    interface HW_reg_6_10_6_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_6 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_7;
    interface HW_reg_6_10_7_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_7;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_7;
interface ConfigReg_HW_reg_6_10_7 hw;
interface ConfigReg_Bus_reg_6_10_7 bus;
endinterface
module mkConfigReg_reg_6_10_7(ConfigReg_reg_6_10_7);
    Ifc_CSRSignal_reg_6_10_7_reserved sig_reserved <- mkCSRSignal_reg_6_10_7_reserved(0);

interface ConfigReg_HW_reg_6_10_7 hw;
    interface HW_reg_6_10_7_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_7 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_8;
    interface HW_reg_6_10_8_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_8;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_8;
interface ConfigReg_HW_reg_6_10_8 hw;
interface ConfigReg_Bus_reg_6_10_8 bus;
endinterface
module mkConfigReg_reg_6_10_8(ConfigReg_reg_6_10_8);
    Ifc_CSRSignal_reg_6_10_8_reserved sig_reserved <- mkCSRSignal_reg_6_10_8_reserved(0);

interface ConfigReg_HW_reg_6_10_8 hw;
    interface HW_reg_6_10_8_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_8 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_9;
    interface HW_reg_6_10_9_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_9;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_9;
interface ConfigReg_HW_reg_6_10_9 hw;
interface ConfigReg_Bus_reg_6_10_9 bus;
endinterface
module mkConfigReg_reg_6_10_9(ConfigReg_reg_6_10_9);
    Ifc_CSRSignal_reg_6_10_9_reserved sig_reserved <- mkCSRSignal_reg_6_10_9_reserved(0);

interface ConfigReg_HW_reg_6_10_9 hw;
    interface HW_reg_6_10_9_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_9 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_10;
    interface HW_reg_6_10_10_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_10;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_10;
interface ConfigReg_HW_reg_6_10_10 hw;
interface ConfigReg_Bus_reg_6_10_10 bus;
endinterface
module mkConfigReg_reg_6_10_10(ConfigReg_reg_6_10_10);
    Ifc_CSRSignal_reg_6_10_10_reserved sig_reserved <- mkCSRSignal_reg_6_10_10_reserved(0);

interface ConfigReg_HW_reg_6_10_10 hw;
    interface HW_reg_6_10_10_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_10 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_11;
    interface HW_reg_6_10_11_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_11;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_11;
interface ConfigReg_HW_reg_6_10_11 hw;
interface ConfigReg_Bus_reg_6_10_11 bus;
endinterface
module mkConfigReg_reg_6_10_11(ConfigReg_reg_6_10_11);
    Ifc_CSRSignal_reg_6_10_11_reserved sig_reserved <- mkCSRSignal_reg_6_10_11_reserved(0);

interface ConfigReg_HW_reg_6_10_11 hw;
    interface HW_reg_6_10_11_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_11 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_12;
    interface HW_reg_6_10_12_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_12;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_12;
interface ConfigReg_HW_reg_6_10_12 hw;
interface ConfigReg_Bus_reg_6_10_12 bus;
endinterface
module mkConfigReg_reg_6_10_12(ConfigReg_reg_6_10_12);
    Ifc_CSRSignal_reg_6_10_12_reserved sig_reserved <- mkCSRSignal_reg_6_10_12_reserved(0);

interface ConfigReg_HW_reg_6_10_12 hw;
    interface HW_reg_6_10_12_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_12 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_13;
    interface HW_reg_6_10_13_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_13;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_13;
interface ConfigReg_HW_reg_6_10_13 hw;
interface ConfigReg_Bus_reg_6_10_13 bus;
endinterface
module mkConfigReg_reg_6_10_13(ConfigReg_reg_6_10_13);
    Ifc_CSRSignal_reg_6_10_13_reserved sig_reserved <- mkCSRSignal_reg_6_10_13_reserved(0);

interface ConfigReg_HW_reg_6_10_13 hw;
    interface HW_reg_6_10_13_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_13 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_14;
    interface HW_reg_6_10_14_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_14;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_14;
interface ConfigReg_HW_reg_6_10_14 hw;
interface ConfigReg_Bus_reg_6_10_14 bus;
endinterface
module mkConfigReg_reg_6_10_14(ConfigReg_reg_6_10_14);
    Ifc_CSRSignal_reg_6_10_14_reserved sig_reserved <- mkCSRSignal_reg_6_10_14_reserved(0);

interface ConfigReg_HW_reg_6_10_14 hw;
    interface HW_reg_6_10_14_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_14 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_15;
    interface HW_reg_6_10_15_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_15;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_15;
interface ConfigReg_HW_reg_6_10_15 hw;
interface ConfigReg_Bus_reg_6_10_15 bus;
endinterface
module mkConfigReg_reg_6_10_15(ConfigReg_reg_6_10_15);
    Ifc_CSRSignal_reg_6_10_15_reserved sig_reserved <- mkCSRSignal_reg_6_10_15_reserved(0);

interface ConfigReg_HW_reg_6_10_15 hw;
    interface HW_reg_6_10_15_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_15 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_16;
    interface HW_reg_6_10_16_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_16;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_16;
interface ConfigReg_HW_reg_6_10_16 hw;
interface ConfigReg_Bus_reg_6_10_16 bus;
endinterface
module mkConfigReg_reg_6_10_16(ConfigReg_reg_6_10_16);
    Ifc_CSRSignal_reg_6_10_16_reserved sig_reserved <- mkCSRSignal_reg_6_10_16_reserved(0);

interface ConfigReg_HW_reg_6_10_16 hw;
    interface HW_reg_6_10_16_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_16 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_17;
    interface HW_reg_6_10_17_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_17;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_17;
interface ConfigReg_HW_reg_6_10_17 hw;
interface ConfigReg_Bus_reg_6_10_17 bus;
endinterface
module mkConfigReg_reg_6_10_17(ConfigReg_reg_6_10_17);
    Ifc_CSRSignal_reg_6_10_17_reserved sig_reserved <- mkCSRSignal_reg_6_10_17_reserved(0);

interface ConfigReg_HW_reg_6_10_17 hw;
    interface HW_reg_6_10_17_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_17 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_18;
    interface HW_reg_6_10_18_reg_offset sreg_offset;
interface HW_reg_6_10_18_bit_loc sbit_loc;
interface HW_reg_6_10_18_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_18_addressable saddressable;
interface HW_reg_6_10_18_polarity spolarity;
interface HW_reg_6_10_18_octal_mode_enable soctal_mode_enable;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_18;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_18;
interface ConfigReg_HW_reg_6_10_18 hw;
interface ConfigReg_Bus_reg_6_10_18 bus;
endinterface
module mkConfigReg_reg_6_10_18(ConfigReg_reg_6_10_18);
    Ifc_CSRSignal_reg_6_10_18_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_18_reg_offset(0);
Ifc_CSRSignal_reg_6_10_18_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_18_bit_loc(0);
Ifc_CSRSignal_reg_6_10_18_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_18_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_18_addressable sig_addressable <- mkCSRSignal_reg_6_10_18_addressable(1);
Ifc_CSRSignal_reg_6_10_18_polarity sig_polarity <- mkCSRSignal_reg_6_10_18_polarity(0);
Ifc_CSRSignal_reg_6_10_18_octal_mode_enable sig_octal_mode_enable <- mkCSRSignal_reg_6_10_18_octal_mode_enable(1);

interface ConfigReg_HW_reg_6_10_18 hw;
    interface HW_reg_6_10_18_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_18_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_18_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_18_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_18_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_18_octal_mode_enable soctal_mode_enable = sig_octal_mode_enable.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_18 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_octal_mode_enable<-sig_octal_mode_enable.bus.read();
rv[31:31]=var_octal_mode_enable;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_19;
    interface HW_reg_6_10_19_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_19;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_19;
interface ConfigReg_HW_reg_6_10_19 hw;
interface ConfigReg_Bus_reg_6_10_19 bus;
endinterface
module mkConfigReg_reg_6_10_19(ConfigReg_reg_6_10_19);
    Ifc_CSRSignal_reg_6_10_19_reserved sig_reserved <- mkCSRSignal_reg_6_10_19_reserved(0);

interface ConfigReg_HW_reg_6_10_19 hw;
    interface HW_reg_6_10_19_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_19 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_20;
    interface HW_reg_6_10_20_reg_offset sreg_offset;
interface HW_reg_6_10_20_bit_loc sbit_loc;
interface HW_reg_6_10_20_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_20_addressable saddressable;
interface HW_reg_6_10_20_polarity spolarity;
interface HW_reg_6_10_20_ddr_mode_select_available sddr_mode_select_available;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_20;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_20;
interface ConfigReg_HW_reg_6_10_20 hw;
interface ConfigReg_Bus_reg_6_10_20 bus;
endinterface
module mkConfigReg_reg_6_10_20(ConfigReg_reg_6_10_20);
    Ifc_CSRSignal_reg_6_10_20_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_20_reg_offset(0);
Ifc_CSRSignal_reg_6_10_20_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_20_bit_loc(0);
Ifc_CSRSignal_reg_6_10_20_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_20_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_20_addressable sig_addressable <- mkCSRSignal_reg_6_10_20_addressable(1);
Ifc_CSRSignal_reg_6_10_20_polarity sig_polarity <- mkCSRSignal_reg_6_10_20_polarity(0);
Ifc_CSRSignal_reg_6_10_20_ddr_mode_select_available sig_ddr_mode_select_available <- mkCSRSignal_reg_6_10_20_ddr_mode_select_available(1);

interface ConfigReg_HW_reg_6_10_20 hw;
    interface HW_reg_6_10_20_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_20_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_20_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_20_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_20_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_20_ddr_mode_select_available sddr_mode_select_available = sig_ddr_mode_select_available.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_20 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_ddr_mode_select_available<-sig_ddr_mode_select_available.bus.read();
rv[31:31]=var_ddr_mode_select_available;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_21;
    interface HW_reg_6_10_21_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_21;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_21;
interface ConfigReg_HW_reg_6_10_21 hw;
interface ConfigReg_Bus_reg_6_10_21 bus;
endinterface
module mkConfigReg_reg_6_10_21(ConfigReg_reg_6_10_21);
    Ifc_CSRSignal_reg_6_10_21_reserved sig_reserved <- mkCSRSignal_reg_6_10_21_reserved(0);

interface ConfigReg_HW_reg_6_10_21 hw;
    interface HW_reg_6_10_21_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_21 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_22;
    interface HW_reg_6_10_22_reg_offset sreg_offset;
interface HW_reg_6_10_22_bit_loc sbit_loc;
interface HW_reg_6_10_22_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_22_addressable saddressable;
interface HW_reg_6_10_22_polarity spolarity;
interface HW_reg_6_10_22_octal_mode_enable soctal_mode_enable;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_22;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_22;
interface ConfigReg_HW_reg_6_10_22 hw;
interface ConfigReg_Bus_reg_6_10_22 bus;
endinterface
module mkConfigReg_reg_6_10_22(ConfigReg_reg_6_10_22);
    Ifc_CSRSignal_reg_6_10_22_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_22_reg_offset(0);
Ifc_CSRSignal_reg_6_10_22_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_22_bit_loc(0);
Ifc_CSRSignal_reg_6_10_22_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_22_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_22_addressable sig_addressable <- mkCSRSignal_reg_6_10_22_addressable(1);
Ifc_CSRSignal_reg_6_10_22_polarity sig_polarity <- mkCSRSignal_reg_6_10_22_polarity(0);
Ifc_CSRSignal_reg_6_10_22_octal_mode_enable sig_octal_mode_enable <- mkCSRSignal_reg_6_10_22_octal_mode_enable(1);

interface ConfigReg_HW_reg_6_10_22 hw;
    interface HW_reg_6_10_22_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_22_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_22_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_22_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_22_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_22_octal_mode_enable soctal_mode_enable = sig_octal_mode_enable.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_22 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_octal_mode_enable<-sig_octal_mode_enable.bus.read();
rv[31:31]=var_octal_mode_enable;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_23;
    interface HW_reg_6_10_23_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_23;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_23;
interface ConfigReg_HW_reg_6_10_23 hw;
interface ConfigReg_Bus_reg_6_10_23 bus;
endinterface
module mkConfigReg_reg_6_10_23(ConfigReg_reg_6_10_23);
    Ifc_CSRSignal_reg_6_10_23_reserved sig_reserved <- mkCSRSignal_reg_6_10_23_reserved(0);

interface ConfigReg_HW_reg_6_10_23 hw;
    interface HW_reg_6_10_23_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_23 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_24;
    interface HW_reg_6_10_24_reg_offset sreg_offset;
interface HW_reg_6_10_24_bit_loc sbit_loc;
interface HW_reg_6_10_24_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_24_addressable saddressable;
interface HW_reg_6_10_24_polarity spolarity;
interface HW_reg_6_10_24_octal_mode_enable soctal_mode_enable;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_24;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_24;
interface ConfigReg_HW_reg_6_10_24 hw;
interface ConfigReg_Bus_reg_6_10_24 bus;
endinterface
module mkConfigReg_reg_6_10_24(ConfigReg_reg_6_10_24);
    Ifc_CSRSignal_reg_6_10_24_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_24_reg_offset(0);
Ifc_CSRSignal_reg_6_10_24_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_24_bit_loc(0);
Ifc_CSRSignal_reg_6_10_24_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_24_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_24_addressable sig_addressable <- mkCSRSignal_reg_6_10_24_addressable(1);
Ifc_CSRSignal_reg_6_10_24_polarity sig_polarity <- mkCSRSignal_reg_6_10_24_polarity(0);
Ifc_CSRSignal_reg_6_10_24_octal_mode_enable sig_octal_mode_enable <- mkCSRSignal_reg_6_10_24_octal_mode_enable(1);

interface ConfigReg_HW_reg_6_10_24 hw;
    interface HW_reg_6_10_24_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_24_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_24_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_24_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_24_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_24_octal_mode_enable soctal_mode_enable = sig_octal_mode_enable.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_24 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_octal_mode_enable<-sig_octal_mode_enable.bus.read();
rv[31:31]=var_octal_mode_enable;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_25;
    interface HW_reg_6_10_25_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_25;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_25;
interface ConfigReg_HW_reg_6_10_25 hw;
interface ConfigReg_Bus_reg_6_10_25 bus;
endinterface
module mkConfigReg_reg_6_10_25(ConfigReg_reg_6_10_25);
    Ifc_CSRSignal_reg_6_10_25_reserved sig_reserved <- mkCSRSignal_reg_6_10_25_reserved(0);

interface ConfigReg_HW_reg_6_10_25 hw;
    interface HW_reg_6_10_25_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_25 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_26;
    interface HW_reg_6_10_26_reg_offset sreg_offset;
interface HW_reg_6_10_26_bit_loc sbit_loc;
interface HW_reg_6_10_26_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_26_addressable saddressable;
interface HW_reg_6_10_26_polarity spolarity;
interface HW_reg_6_10_26_ddr_mode_select_available sddr_mode_select_available;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_26;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_26;
interface ConfigReg_HW_reg_6_10_26 hw;
interface ConfigReg_Bus_reg_6_10_26 bus;
endinterface
module mkConfigReg_reg_6_10_26(ConfigReg_reg_6_10_26);
    Ifc_CSRSignal_reg_6_10_26_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_26_reg_offset(0);
Ifc_CSRSignal_reg_6_10_26_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_26_bit_loc(0);
Ifc_CSRSignal_reg_6_10_26_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_26_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_26_addressable sig_addressable <- mkCSRSignal_reg_6_10_26_addressable(1);
Ifc_CSRSignal_reg_6_10_26_polarity sig_polarity <- mkCSRSignal_reg_6_10_26_polarity(0);
Ifc_CSRSignal_reg_6_10_26_ddr_mode_select_available sig_ddr_mode_select_available <- mkCSRSignal_reg_6_10_26_ddr_mode_select_available(1);

interface ConfigReg_HW_reg_6_10_26 hw;
    interface HW_reg_6_10_26_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_26_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_26_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_26_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_26_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_26_ddr_mode_select_available sddr_mode_select_available = sig_ddr_mode_select_available.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_26 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_ddr_mode_select_available<-sig_ddr_mode_select_available.bus.read();
rv[31:31]=var_ddr_mode_select_available;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_27;
    interface HW_reg_6_10_27_reg_offset sreg_offset;
interface HW_reg_6_10_27_bit_loc sbit_loc;
interface HW_reg_6_10_27_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_27_addressable saddressable;
interface HW_reg_6_10_27_polarity spolarity;
interface HW_reg_6_10_27_ddr_mode_select_available sddr_mode_select_available;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_27;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_27;
interface ConfigReg_HW_reg_6_10_27 hw;
interface ConfigReg_Bus_reg_6_10_27 bus;
endinterface
module mkConfigReg_reg_6_10_27(ConfigReg_reg_6_10_27);
    Ifc_CSRSignal_reg_6_10_27_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_27_reg_offset(0);
Ifc_CSRSignal_reg_6_10_27_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_27_bit_loc(0);
Ifc_CSRSignal_reg_6_10_27_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_27_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_27_addressable sig_addressable <- mkCSRSignal_reg_6_10_27_addressable(1);
Ifc_CSRSignal_reg_6_10_27_polarity sig_polarity <- mkCSRSignal_reg_6_10_27_polarity(0);
Ifc_CSRSignal_reg_6_10_27_ddr_mode_select_available sig_ddr_mode_select_available <- mkCSRSignal_reg_6_10_27_ddr_mode_select_available(1);

interface ConfigReg_HW_reg_6_10_27 hw;
    interface HW_reg_6_10_27_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_27_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_27_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_27_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_27_polarity spolarity = sig_polarity.hw;
interface HW_reg_6_10_27_ddr_mode_select_available sddr_mode_select_available = sig_ddr_mode_select_available.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_27 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_polarity<-sig_polarity.bus.read();
rv[30:30]=var_polarity;
let var_ddr_mode_select_available<-sig_ddr_mode_select_available.bus.read();
rv[31:31]=var_ddr_mode_select_available;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_28;
    interface HW_reg_6_10_28_reg_offset sreg_offset;
interface HW_reg_6_10_28_bit_loc sbit_loc;
interface HW_reg_6_10_28_local_addr_in_last_byte slocal_addr_in_last_byte;
interface HW_reg_6_10_28_addressable saddressable;
interface HW_reg_6_10_28_num_bits snum_bits;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_28;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_28;
interface ConfigReg_HW_reg_6_10_28 hw;
interface ConfigReg_Bus_reg_6_10_28 bus;
endinterface
module mkConfigReg_reg_6_10_28(ConfigReg_reg_6_10_28);
    Ifc_CSRSignal_reg_6_10_28_reg_offset sig_reg_offset <- mkCSRSignal_reg_6_10_28_reg_offset(0);
Ifc_CSRSignal_reg_6_10_28_bit_loc sig_bit_loc <- mkCSRSignal_reg_6_10_28_bit_loc(0);
Ifc_CSRSignal_reg_6_10_28_local_addr_in_last_byte sig_local_addr_in_last_byte <- mkCSRSignal_reg_6_10_28_local_addr_in_last_byte(0);
Ifc_CSRSignal_reg_6_10_28_addressable sig_addressable <- mkCSRSignal_reg_6_10_28_addressable(1);
Ifc_CSRSignal_reg_6_10_28_num_bits sig_num_bits <- mkCSRSignal_reg_6_10_28_num_bits(3);

interface ConfigReg_HW_reg_6_10_28 hw;
    interface HW_reg_6_10_28_reg_offset sreg_offset = sig_reg_offset.hw;
interface HW_reg_6_10_28_bit_loc sbit_loc = sig_bit_loc.hw;
interface HW_reg_6_10_28_local_addr_in_last_byte slocal_addr_in_last_byte = sig_local_addr_in_last_byte.hw;
interface HW_reg_6_10_28_addressable saddressable = sig_addressable.hw;
interface HW_reg_6_10_28_num_bits snum_bits = sig_num_bits.hw;

    method Bit#(32) value();
    let rv=0;
rv[23:16]=8'b0;
rv[26:24]=3'b0;
rv[27:27]=1'b0;
rv[28:28]=1'b0;
rv[31:30]=2'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_28 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reg_offset<-sig_reg_offset.bus.read();
rv[23:16]=var_reg_offset;
let var_bit_loc<-sig_bit_loc.bus.read();
rv[26:24]=var_bit_loc;
let var_local_addr_in_last_byte<-sig_local_addr_in_last_byte.bus.read();
rv[27:27]=var_local_addr_in_last_byte;
let var_addressable<-sig_addressable.bus.read();
rv[28:28]=var_addressable;
let var_num_bits<-sig_num_bits.bus.read();
rv[31:30]=var_num_bits;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_10_29;
    interface HW_reg_6_10_29_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_10_29;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_10_29;
interface ConfigReg_HW_reg_6_10_29 hw;
interface ConfigReg_Bus_reg_6_10_29 bus;
endinterface
module mkConfigReg_reg_6_10_29(ConfigReg_reg_6_10_29);
    Ifc_CSRSignal_reg_6_10_29_reserved sig_reserved <- mkCSRSignal_reg_6_10_29_reserved(0);

interface ConfigReg_HW_reg_6_10_29 hw;
    interface HW_reg_6_10_29_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_10_29 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[31:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_3;
    interface HW_reg_6_11_3_offset soffset;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_3;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_3;
interface ConfigReg_HW_reg_6_11_3 hw;
interface ConfigReg_Bus_reg_6_11_3 bus;
endinterface
module mkConfigReg_reg_6_11_3(ConfigReg_reg_6_11_3);
    Ifc_CSRSignal_reg_6_11_3_offset sig_offset <- mkCSRSignal_reg_6_11_3_offset(0);

interface ConfigReg_HW_reg_6_11_3 hw;
    interface HW_reg_6_11_3_offset soffset = sig_offset.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_3 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_offset<-sig_offset.bus.read();
rv[31:0]=var_offset;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_4;
    interface HW_reg_6_11_4_offset soffset;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_4;
interface ConfigReg_HW_reg_6_11_4 hw;
interface ConfigReg_Bus_reg_6_11_4 bus;
endinterface
module mkConfigReg_reg_6_11_4(ConfigReg_reg_6_11_4);
    Ifc_CSRSignal_reg_6_11_4_offset sig_offset <- mkCSRSignal_reg_6_11_4_offset(0);

interface ConfigReg_HW_reg_6_11_4 hw;
    interface HW_reg_6_11_4_offset soffset = sig_offset.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_offset<-sig_offset.bus.read();
rv[31:0]=var_offset;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_5;
    interface HW_reg_6_11_5_reserved sreserved;
interface HW_reg_6_11_5_wip_address swip_address;
interface HW_reg_6_11_5_wip_bit_location swip_bit_location;
interface HW_reg_6_11_5_wip_address_byte_location swip_address_byte_location;
interface HW_reg_6_11_5_wip_polarity swip_polarity;
interface HW_reg_6_11_5_wip_supported swip_supported;
interface HW_reg_6_11_5_dummy_cycles_non_volative sdummy_cycles_non_volative;
interface HW_reg_6_11_5_dummy_cycles_volative sdummy_cycles_volative;
interface HW_reg_6_11_5_address_bytes saddress_bytes;
interface HW_reg_6_11_5_write_ctrl_sts swrite_ctrl_sts;
interface HW_reg_6_11_5_read_ctrl_sts sread_ctrl_sts;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_5;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_5;
interface ConfigReg_HW_reg_6_11_5 hw;
interface ConfigReg_Bus_reg_6_11_5 bus;
endinterface
module mkConfigReg_reg_6_11_5(ConfigReg_reg_6_11_5);
    Ifc_CSRSignal_reg_6_11_5_reserved sig_reserved <- mkCSRSignal_reg_6_11_5_reserved(0);
Ifc_CSRSignal_reg_6_11_5_wip_address sig_wip_address <- mkCSRSignal_reg_6_11_5_wip_address(0);
Ifc_CSRSignal_reg_6_11_5_wip_bit_location sig_wip_bit_location <- mkCSRSignal_reg_6_11_5_wip_bit_location(0);
Ifc_CSRSignal_reg_6_11_5_wip_address_byte_location sig_wip_address_byte_location <- mkCSRSignal_reg_6_11_5_wip_address_byte_location(0);
Ifc_CSRSignal_reg_6_11_5_wip_polarity sig_wip_polarity <- mkCSRSignal_reg_6_11_5_wip_polarity(0);
Ifc_CSRSignal_reg_6_11_5_wip_supported sig_wip_supported <- mkCSRSignal_reg_6_11_5_wip_supported(0);
Ifc_CSRSignal_reg_6_11_5_dummy_cycles_non_volative sig_dummy_cycles_non_volative <- mkCSRSignal_reg_6_11_5_dummy_cycles_non_volative(0);
Ifc_CSRSignal_reg_6_11_5_dummy_cycles_volative sig_dummy_cycles_volative <- mkCSRSignal_reg_6_11_5_dummy_cycles_volative(0);
Ifc_CSRSignal_reg_6_11_5_address_bytes sig_address_bytes <- mkCSRSignal_reg_6_11_5_address_bytes(0);
Ifc_CSRSignal_reg_6_11_5_write_ctrl_sts sig_write_ctrl_sts <- mkCSRSignal_reg_6_11_5_write_ctrl_sts(1);
Ifc_CSRSignal_reg_6_11_5_read_ctrl_sts sig_read_ctrl_sts <- mkCSRSignal_reg_6_11_5_read_ctrl_sts(1);

interface ConfigReg_HW_reg_6_11_5 hw;
    interface HW_reg_6_11_5_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_5_wip_address swip_address = sig_wip_address.hw;
interface HW_reg_6_11_5_wip_bit_location swip_bit_location = sig_wip_bit_location.hw;
interface HW_reg_6_11_5_wip_address_byte_location swip_address_byte_location = sig_wip_address_byte_location.hw;
interface HW_reg_6_11_5_wip_polarity swip_polarity = sig_wip_polarity.hw;
interface HW_reg_6_11_5_wip_supported swip_supported = sig_wip_supported.hw;
interface HW_reg_6_11_5_dummy_cycles_non_volative sdummy_cycles_non_volative = sig_dummy_cycles_non_volative.hw;
interface HW_reg_6_11_5_dummy_cycles_volative sdummy_cycles_volative = sig_dummy_cycles_volative.hw;
interface HW_reg_6_11_5_address_bytes saddress_bytes = sig_address_bytes.hw;
interface HW_reg_6_11_5_write_ctrl_sts swrite_ctrl_sts = sig_write_ctrl_sts.hw;
interface HW_reg_6_11_5_read_ctrl_sts sread_ctrl_sts = sig_read_ctrl_sts.hw;

    method Bit#(32) value();
    let rv=0;
rv[2:0]=3'b0;
rv[10:3]=8'b0;
rv[14:11]=4'b0;
rv[15:15]=1'b0;
rv[16:16]=1'b0;
rv[17:17]=1'b0;
rv[22:18]=5'b0;
rv[27:23]=5'b0;
rv[29:28]=2'b0;
rv[30:30]=1'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_5 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[2:0]=var_reserved;
let var_wip_address<-sig_wip_address.bus.read();
rv[10:3]=var_wip_address;
let var_wip_bit_location<-sig_wip_bit_location.bus.read();
rv[14:11]=var_wip_bit_location;
let var_wip_address_byte_location<-sig_wip_address_byte_location.bus.read();
rv[15:15]=var_wip_address_byte_location;
let var_wip_polarity<-sig_wip_polarity.bus.read();
rv[16:16]=var_wip_polarity;
let var_wip_supported<-sig_wip_supported.bus.read();
rv[17:17]=var_wip_supported;
let var_dummy_cycles_non_volative<-sig_dummy_cycles_non_volative.bus.read();
rv[22:18]=var_dummy_cycles_non_volative;
let var_dummy_cycles_volative<-sig_dummy_cycles_volative.bus.read();
rv[27:23]=var_dummy_cycles_volative;
let var_address_bytes<-sig_address_bytes.bus.read();
rv[29:28]=var_address_bytes;
let var_write_ctrl_sts<-sig_write_ctrl_sts.bus.read();
rv[30:30]=var_write_ctrl_sts;
let var_read_ctrl_sts<-sig_read_ctrl_sts.bus.read();
rv[31:31]=var_read_ctrl_sts;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_6;
    interface HW_reg_6_11_6_p_error sp_error;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_6;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_6;
interface ConfigReg_HW_reg_6_11_6 hw;
interface ConfigReg_Bus_reg_6_11_6 bus;
endinterface
module mkConfigReg_reg_6_11_6(ConfigReg_reg_6_11_6);
    Ifc_CSRSignal_reg_6_11_6_p_error sig_p_error <- mkCSRSignal_reg_6_11_6_p_error(0);

interface ConfigReg_HW_reg_6_11_6 hw;
    interface HW_reg_6_11_6_p_error sp_error = sig_p_error.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_6 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_p_error<-sig_p_error.bus.read();
rv[31:0]=var_p_error;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_7;
    interface HW_reg_6_11_7_e_error se_error;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_7;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_7;
interface ConfigReg_HW_reg_6_11_7 hw;
interface ConfigReg_Bus_reg_6_11_7 bus;
endinterface
module mkConfigReg_reg_6_11_7(ConfigReg_reg_6_11_7);
    Ifc_CSRSignal_reg_6_11_7_e_error sig_e_error <- mkCSRSignal_reg_6_11_7_e_error(0);

interface ConfigReg_HW_reg_6_11_7 hw;
    interface HW_reg_6_11_7_e_error se_error = sig_e_error.hw;

    method Bit#(32) value();
    let rv=0;
rv[31:0]=32'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_7 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_e_error<-sig_e_error.bus.read();
rv[31:0]=var_e_error;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_8;
    interface HW_reg_6_11_8_reserved sreserved;
interface HW_reg_6_11_8_supported ssupported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_8;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_8;
interface ConfigReg_HW_reg_6_11_8 hw;
interface ConfigReg_Bus_reg_6_11_8 bus;
endinterface
module mkConfigReg_reg_6_11_8(ConfigReg_reg_6_11_8);
    Ifc_CSRSignal_reg_6_11_8_reserved sig_reserved <- mkCSRSignal_reg_6_11_8_reserved(0);
Ifc_CSRSignal_reg_6_11_8_supported sig_supported <- mkCSRSignal_reg_6_11_8_supported(0);

interface ConfigReg_HW_reg_6_11_8 hw;
    interface HW_reg_6_11_8_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_8_supported ssupported = sig_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[30:0]=31'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_8 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[30:0]=var_reserved;
let var_supported<-sig_supported.bus.read();
rv[31:31]=var_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_9;
    interface HW_reg_6_11_9_reserved sreserved;
interface HW_reg_6_11_9_supported ssupported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_9;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_9;
interface ConfigReg_HW_reg_6_11_9 hw;
interface ConfigReg_Bus_reg_6_11_9 bus;
endinterface
module mkConfigReg_reg_6_11_9(ConfigReg_reg_6_11_9);
    Ifc_CSRSignal_reg_6_11_9_reserved sig_reserved <- mkCSRSignal_reg_6_11_9_reserved(0);
Ifc_CSRSignal_reg_6_11_9_supported sig_supported <- mkCSRSignal_reg_6_11_9_supported(0);

interface ConfigReg_HW_reg_6_11_9 hw;
    interface HW_reg_6_11_9_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_9_supported ssupported = sig_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[30:0]=31'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_9 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[30:0]=var_reserved;
let var_supported<-sig_supported.bus.read();
rv[31:31]=var_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_10;
    interface HW_reg_6_11_10_reserved sreserved;
interface HW_reg_6_11_10_supported ssupported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_10;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_10;
interface ConfigReg_HW_reg_6_11_10 hw;
interface ConfigReg_Bus_reg_6_11_10 bus;
endinterface
module mkConfigReg_reg_6_11_10(ConfigReg_reg_6_11_10);
    Ifc_CSRSignal_reg_6_11_10_reserved sig_reserved <- mkCSRSignal_reg_6_11_10_reserved(0);
Ifc_CSRSignal_reg_6_11_10_supported sig_supported <- mkCSRSignal_reg_6_11_10_supported(0);

interface ConfigReg_HW_reg_6_11_10 hw;
    interface HW_reg_6_11_10_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_10_supported ssupported = sig_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[30:0]=31'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_10 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[30:0]=var_reserved;
let var_supported<-sig_supported.bus.read();
rv[31:31]=var_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_11;
    interface HW_reg_6_11_11_reserved sreserved;
interface HW_reg_6_11_11_supported ssupported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_11;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_11;
interface ConfigReg_HW_reg_6_11_11 hw;
interface ConfigReg_Bus_reg_6_11_11 bus;
endinterface
module mkConfigReg_reg_6_11_11(ConfigReg_reg_6_11_11);
    Ifc_CSRSignal_reg_6_11_11_reserved sig_reserved <- mkCSRSignal_reg_6_11_11_reserved(0);
Ifc_CSRSignal_reg_6_11_11_supported sig_supported <- mkCSRSignal_reg_6_11_11_supported(0);

interface ConfigReg_HW_reg_6_11_11 hw;
    interface HW_reg_6_11_11_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_11_supported ssupported = sig_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[30:0]=31'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_11 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[30:0]=var_reserved;
let var_supported<-sig_supported.bus.read();
rv[31:31]=var_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_12;
    interface HW_reg_6_11_12_reserved sreserved;
interface HW_reg_6_11_12_supported ssupported;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_12;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_12;
interface ConfigReg_HW_reg_6_11_12 hw;
interface ConfigReg_Bus_reg_6_11_12 bus;
endinterface
module mkConfigReg_reg_6_11_12(ConfigReg_reg_6_11_12);
    Ifc_CSRSignal_reg_6_11_12_reserved sig_reserved <- mkCSRSignal_reg_6_11_12_reserved(0);
Ifc_CSRSignal_reg_6_11_12_supported sig_supported <- mkCSRSignal_reg_6_11_12_supported(0);

interface ConfigReg_HW_reg_6_11_12 hw;
    interface HW_reg_6_11_12_reserved sreserved = sig_reserved.hw;
interface HW_reg_6_11_12_supported ssupported = sig_supported.hw;

    method Bit#(32) value();
    let rv=0;
rv[30:0]=31'b0;
rv[31:31]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_12 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[30:0]=var_reserved;
let var_supported<-sig_supported.bus.read();
rv[31:31]=var_supported;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_13;
    interface HW_reg_6_11_13_addr saddr;
interface HW_reg_6_11_13_msb_bit_location smsb_bit_location;
interface HW_reg_6_11_13_addr_not_in_last_byte saddr_not_in_last_byte;
interface HW_reg_6_11_13_drive_strength_num_bits sdrive_strength_num_bits;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_13;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_13;
interface ConfigReg_HW_reg_6_11_13 hw;
interface ConfigReg_Bus_reg_6_11_13 bus;
endinterface
module mkConfigReg_reg_6_11_13(ConfigReg_reg_6_11_13);
    Ifc_CSRSignal_reg_6_11_13_addr sig_addr <- mkCSRSignal_reg_6_11_13_addr(0);
Ifc_CSRSignal_reg_6_11_13_msb_bit_location sig_msb_bit_location <- mkCSRSignal_reg_6_11_13_msb_bit_location(0);
Ifc_CSRSignal_reg_6_11_13_addr_not_in_last_byte sig_addr_not_in_last_byte <- mkCSRSignal_reg_6_11_13_addr_not_in_last_byte(0);
Ifc_CSRSignal_reg_6_11_13_drive_strength_num_bits sig_drive_strength_num_bits <- mkCSRSignal_reg_6_11_13_drive_strength_num_bits(3);

interface ConfigReg_HW_reg_6_11_13 hw;
    interface HW_reg_6_11_13_addr saddr = sig_addr.hw;
interface HW_reg_6_11_13_msb_bit_location smsb_bit_location = sig_msb_bit_location.hw;
interface HW_reg_6_11_13_addr_not_in_last_byte saddr_not_in_last_byte = sig_addr_not_in_last_byte.hw;
interface HW_reg_6_11_13_drive_strength_num_bits sdrive_strength_num_bits = sig_drive_strength_num_bits.hw;

    method Bit#(32) value();
    let rv=0;
rv[24:17]=8'b0;
rv[28:25]=4'b0;
rv[29:29]=1'b0;
rv[31:30]=2'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_13 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_addr<-sig_addr.bus.read();
rv[24:17]=var_addr;
let var_msb_bit_location<-sig_msb_bit_location.bus.read();
rv[28:25]=var_msb_bit_location;
let var_addr_not_in_last_byte<-sig_addr_not_in_last_byte.bus.read();
rv[29:29]=var_addr_not_in_last_byte;
let var_drive_strength_num_bits<-sig_drive_strength_num_bits.bus.read();
rv[31:30]=var_drive_strength_num_bits;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_14;
    interface HW_reg_6_11_14_reserved sreserved;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_14;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_14;
interface ConfigReg_HW_reg_6_11_14 hw;
interface ConfigReg_Bus_reg_6_11_14 bus;
endinterface
module mkConfigReg_reg_6_11_14(ConfigReg_reg_6_11_14);
    Ifc_CSRSignal_reg_6_11_14_reserved sig_reserved <- mkCSRSignal_reg_6_11_14_reserved(0);

interface ConfigReg_HW_reg_6_11_14 hw;
    interface HW_reg_6_11_14_reserved sreserved = sig_reserved.hw;

    method Bit#(32) value();
    let rv=0;
rv[0:0]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_14 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_reserved<-sig_reserved.bus.read();
rv[0:0]=var_reserved;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_11_15;
    interface HW_reg_6_11_15_tbd stbd;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_11_15;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_11_15;
interface ConfigReg_HW_reg_6_11_15 hw;
interface ConfigReg_Bus_reg_6_11_15 bus;
endinterface
module mkConfigReg_reg_6_11_15(ConfigReg_reg_6_11_15);
    Ifc_CSRSignal_reg_6_11_15_tbd sig_tbd <- mkCSRSignal_reg_6_11_15_tbd(0);

interface ConfigReg_HW_reg_6_11_15 hw;
    interface HW_reg_6_11_15_tbd stbd = sig_tbd.hw;

    method Bit#(32) value();
    let rv=0;
rv[0:0]=1'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_11_15 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_tbd<-sig_tbd.bus.read();
rv[0:0]=var_tbd;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_17_3;
    interface HW_reg_6_17_3_gram_spi sgram_spi;
interface HW_reg_6_17_3_address_shift saddress_shift;
interface HW_reg_6_17_3_md_address_format smd_address_format;
interface HW_reg_6_17_3_md_address_write_access smd_address_write_access;
interface HW_reg_6_17_3_md_address_read_access smd_address_read_access;
interface HW_reg_6_17_3_md_active_die smd_active_die;
interface HW_reg_6_17_3_md_address_offset smd_address_offset;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_17_3;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_17_3;
interface ConfigReg_HW_reg_6_17_3 hw;
interface ConfigReg_Bus_reg_6_17_3 bus;
endinterface
module mkConfigReg_reg_6_17_3(ConfigReg_reg_6_17_3);
    Ifc_CSRSignal_reg_6_17_3_gram_spi sig_gram_spi <- mkCSRSignal_reg_6_17_3_gram_spi(1);
Ifc_CSRSignal_reg_6_17_3_address_shift sig_address_shift <- mkCSRSignal_reg_6_17_3_address_shift(0);
Ifc_CSRSignal_reg_6_17_3_md_address_format sig_md_address_format <- mkCSRSignal_reg_6_17_3_md_address_format(4);
Ifc_CSRSignal_reg_6_17_3_md_address_write_access sig_md_address_write_access <- mkCSRSignal_reg_6_17_3_md_address_write_access(0);
Ifc_CSRSignal_reg_6_17_3_md_address_read_access sig_md_address_read_access <- mkCSRSignal_reg_6_17_3_md_address_read_access(0);
Ifc_CSRSignal_reg_6_17_3_md_active_die sig_md_active_die <- mkCSRSignal_reg_6_17_3_md_active_die(0);
Ifc_CSRSignal_reg_6_17_3_md_address_offset sig_md_address_offset <- mkCSRSignal_reg_6_17_3_md_address_offset(0);

interface ConfigReg_HW_reg_6_17_3 hw;
    interface HW_reg_6_17_3_gram_spi sgram_spi = sig_gram_spi.hw;
interface HW_reg_6_17_3_address_shift saddress_shift = sig_address_shift.hw;
interface HW_reg_6_17_3_md_address_format smd_address_format = sig_md_address_format.hw;
interface HW_reg_6_17_3_md_address_write_access smd_address_write_access = sig_md_address_write_access.hw;
interface HW_reg_6_17_3_md_address_read_access smd_address_read_access = sig_md_address_read_access.hw;
interface HW_reg_6_17_3_md_active_die smd_active_die = sig_md_active_die.hw;
interface HW_reg_6_17_3_md_address_offset smd_address_offset = sig_md_address_offset.hw;

    method Bit#(32) value();
    let rv=0;
rv[4:4]=1'b0;
rv[5:5]=1'b0;
rv[11:8]=4'b0;
rv[19:16]=4'b0;
rv[23:20]=4'b0;
rv[27:24]=4'b0;
rv[31:28]=4'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_17_3 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_gram_spi<-sig_gram_spi.bus.read();
rv[4:4]=var_gram_spi;
let var_address_shift<-sig_address_shift.bus.read();
rv[5:5]=var_address_shift;
let var_md_address_format<-sig_md_address_format.bus.read();
rv[11:8]=var_md_address_format;
let var_md_address_write_access<-sig_md_address_write_access.bus.read();
rv[19:16]=var_md_address_write_access;
let var_md_address_read_access<-sig_md_address_read_access.bus.read();
rv[23:20]=var_md_address_read_access;
let var_md_active_die<-sig_md_active_die.bus.read();
rv[27:24]=var_md_active_die;
let var_md_address_offset<-sig_md_address_offset.bus.read();
rv[31:28]=var_md_address_offset;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_17_4;
    interface HW_reg_6_17_4_write_opcode swrite_opcode;
interface HW_reg_6_17_4_read_opcode sread_opcode;
interface HW_reg_6_17_4_dummy_cycles sdummy_cycles;
interface HW_reg_6_17_4_dummy_cycles_override sdummy_cycles_override;
interface HW_reg_6_17_4_write_enable swrite_enable;
interface HW_reg_6_17_4_volatile_addr_offset svolatile_addr_offset;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_17_4;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_17_4;
interface ConfigReg_HW_reg_6_17_4 hw;
interface ConfigReg_Bus_reg_6_17_4 bus;
endinterface
module mkConfigReg_reg_6_17_4(ConfigReg_reg_6_17_4);
    Ifc_CSRSignal_reg_6_17_4_write_opcode sig_write_opcode <- mkCSRSignal_reg_6_17_4_write_opcode(113);
Ifc_CSRSignal_reg_6_17_4_read_opcode sig_read_opcode <- mkCSRSignal_reg_6_17_4_read_opcode(101);
Ifc_CSRSignal_reg_6_17_4_dummy_cycles sig_dummy_cycles <- mkCSRSignal_reg_6_17_4_dummy_cycles(8);
Ifc_CSRSignal_reg_6_17_4_dummy_cycles_override sig_dummy_cycles_override <- mkCSRSignal_reg_6_17_4_dummy_cycles_override(0);
Ifc_CSRSignal_reg_6_17_4_write_enable sig_write_enable <- mkCSRSignal_reg_6_17_4_write_enable(0);
Ifc_CSRSignal_reg_6_17_4_volatile_addr_offset sig_volatile_addr_offset <- mkCSRSignal_reg_6_17_4_volatile_addr_offset(0);

interface ConfigReg_HW_reg_6_17_4 hw;
    interface HW_reg_6_17_4_write_opcode swrite_opcode = sig_write_opcode.hw;
interface HW_reg_6_17_4_read_opcode sread_opcode = sig_read_opcode.hw;
interface HW_reg_6_17_4_dummy_cycles sdummy_cycles = sig_dummy_cycles.hw;
interface HW_reg_6_17_4_dummy_cycles_override sdummy_cycles_override = sig_dummy_cycles_override.hw;
interface HW_reg_6_17_4_write_enable swrite_enable = sig_write_enable.hw;
interface HW_reg_6_17_4_volatile_addr_offset svolatile_addr_offset = sig_volatile_addr_offset.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[27:24]=4'b0;
rv[31:28]=4'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_17_4 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_write_opcode<-sig_write_opcode.bus.read();
rv[7:0]=var_write_opcode;
let var_read_opcode<-sig_read_opcode.bus.read();
rv[15:8]=var_read_opcode;
let var_dummy_cycles<-sig_dummy_cycles.bus.read();
rv[20:16]=var_dummy_cycles;
let var_dummy_cycles_override<-sig_dummy_cycles_override.bus.read();
rv[23:21]=var_dummy_cycles_override;
let var_write_enable<-sig_write_enable.bus.read();
rv[27:24]=var_write_enable;
let var_volatile_addr_offset<-sig_volatile_addr_offset.bus.read();
rv[31:28]=var_volatile_addr_offset;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_17_5;
    interface HW_reg_6_17_5_write_opcode swrite_opcode;
interface HW_reg_6_17_5_read_opcode sread_opcode;
interface HW_reg_6_17_5_dummy_cycles sdummy_cycles;
interface HW_reg_6_17_5_dummy_cycles_override sdummy_cycles_override;
interface HW_reg_6_17_5_write_enable swrite_enable;
interface HW_reg_6_17_5_volatile_addr_offset svolatile_addr_offset;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_17_5;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_17_5;
interface ConfigReg_HW_reg_6_17_5 hw;
interface ConfigReg_Bus_reg_6_17_5 bus;
endinterface
module mkConfigReg_reg_6_17_5(ConfigReg_reg_6_17_5);
    Ifc_CSRSignal_reg_6_17_5_write_opcode sig_write_opcode <- mkCSRSignal_reg_6_17_5_write_opcode(113);
Ifc_CSRSignal_reg_6_17_5_read_opcode sig_read_opcode <- mkCSRSignal_reg_6_17_5_read_opcode(101);
Ifc_CSRSignal_reg_6_17_5_dummy_cycles sig_dummy_cycles <- mkCSRSignal_reg_6_17_5_dummy_cycles(8);
Ifc_CSRSignal_reg_6_17_5_dummy_cycles_override sig_dummy_cycles_override <- mkCSRSignal_reg_6_17_5_dummy_cycles_override(0);
Ifc_CSRSignal_reg_6_17_5_write_enable sig_write_enable <- mkCSRSignal_reg_6_17_5_write_enable(0);
Ifc_CSRSignal_reg_6_17_5_volatile_addr_offset sig_volatile_addr_offset <- mkCSRSignal_reg_6_17_5_volatile_addr_offset(0);

interface ConfigReg_HW_reg_6_17_5 hw;
    interface HW_reg_6_17_5_write_opcode swrite_opcode = sig_write_opcode.hw;
interface HW_reg_6_17_5_read_opcode sread_opcode = sig_read_opcode.hw;
interface HW_reg_6_17_5_dummy_cycles sdummy_cycles = sig_dummy_cycles.hw;
interface HW_reg_6_17_5_dummy_cycles_override sdummy_cycles_override = sig_dummy_cycles_override.hw;
interface HW_reg_6_17_5_write_enable swrite_enable = sig_write_enable.hw;
interface HW_reg_6_17_5_volatile_addr_offset svolatile_addr_offset = sig_volatile_addr_offset.hw;

    method Bit#(32) value();
    let rv=0;
rv[7:0]=8'b0;
rv[15:8]=8'b0;
rv[20:16]=5'b0;
rv[23:21]=3'b0;
rv[27:24]=4'b0;
rv[31:28]=4'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_17_5 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_write_opcode<-sig_write_opcode.bus.read();
rv[7:0]=var_write_opcode;
let var_read_opcode<-sig_read_opcode.bus.read();
rv[15:8]=var_read_opcode;
let var_dummy_cycles<-sig_dummy_cycles.bus.read();
rv[20:16]=var_dummy_cycles;
let var_dummy_cycles_override<-sig_dummy_cycles_override.bus.read();
rv[23:21]=var_dummy_cycles_override;
let var_write_enable<-sig_write_enable.bus.read();
rv[27:24]=var_write_enable;
let var_volatile_addr_offset<-sig_volatile_addr_offset.bus.read();
rv[31:28]=var_volatile_addr_offset;

    return rv;
    endmethod
endinterface
endmodule
                  

interface ConfigReg_HW_reg_6_17_6;
    interface HW_reg_6_17_6_statreg_bit0 sstatreg_bit0;
interface HW_reg_6_17_6_statreg_access sstatreg_access;
interface HW_reg_6_17_6_dummy_cycles sdummy_cycles;
interface HW_reg_6_17_6_aux1 saux1;
interface HW_reg_6_17_6_aux2 saux2;

    method Bit#(32) value();

endinterface

interface ConfigReg_Bus_reg_6_17_6;
    method Action write( Bit#(32) data,Bit#(32)wstrb);
    method ActionValue#(Bit#(32)) read();
endinterface

interface ConfigReg_reg_6_17_6;
interface ConfigReg_HW_reg_6_17_6 hw;
interface ConfigReg_Bus_reg_6_17_6 bus;
endinterface
module mkConfigReg_reg_6_17_6(ConfigReg_reg_6_17_6);
    Ifc_CSRSignal_reg_6_17_6_statreg_bit0 sig_statreg_bit0 <- mkCSRSignal_reg_6_17_6_statreg_bit0(1);
Ifc_CSRSignal_reg_6_17_6_statreg_access sig_statreg_access <- mkCSRSignal_reg_6_17_6_statreg_access(1);
Ifc_CSRSignal_reg_6_17_6_dummy_cycles sig_dummy_cycles <- mkCSRSignal_reg_6_17_6_dummy_cycles(2);
Ifc_CSRSignal_reg_6_17_6_aux1 sig_aux1 <- mkCSRSignal_reg_6_17_6_aux1(0);
Ifc_CSRSignal_reg_6_17_6_aux2 sig_aux2 <- mkCSRSignal_reg_6_17_6_aux2(5);

interface ConfigReg_HW_reg_6_17_6 hw;
    interface HW_reg_6_17_6_statreg_bit0 sstatreg_bit0 = sig_statreg_bit0.hw;
interface HW_reg_6_17_6_statreg_access sstatreg_access = sig_statreg_access.hw;
interface HW_reg_6_17_6_dummy_cycles sdummy_cycles = sig_dummy_cycles.hw;
interface HW_reg_6_17_6_aux1 saux1 = sig_aux1.hw;
interface HW_reg_6_17_6_aux2 saux2 = sig_aux2.hw;

    method Bit#(32) value();
    let rv=0;
rv[3:0]=4'b0;
rv[11:8]=4'b0;
rv[14:12]=3'b0;
rv[23:16]=8'b0;
rv[31:24]=8'b0;
    return rv;
    endmethod
endinterface
interface ConfigReg_Bus_reg_6_17_6 bus;
    method Action write(Bit#(32) data,Bit#(32) wstrb);
    //write methods

    endmethod
    method ActionValue#(Bit#(32)) read;
        Bit#(32) rv=0;
    //read methods
let var_statreg_bit0<-sig_statreg_bit0.bus.read();
rv[3:0]=var_statreg_bit0;
let var_statreg_access<-sig_statreg_access.bus.read();
rv[11:8]=var_statreg_access;
let var_dummy_cycles<-sig_dummy_cycles.bus.read();
rv[14:12]=var_dummy_cycles;
let var_aux1<-sig_aux1.bus.read();
rv[23:16]=var_aux1;
let var_aux2<-sig_aux2.bus.read();
rv[31:24]=var_aux2;

    return rv;
    endmethod
endinterface
endmodule
                  
