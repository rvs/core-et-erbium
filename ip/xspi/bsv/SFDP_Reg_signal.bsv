// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SFDP Signature', 'reset': 1346651731, 'width': 32, 'signal_name': 'signature', 'reg_name': 'reg6_2_1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_2_1_signature;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_2_1_signature;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_2_1_signature;
interface HW_reg6_2_1_signature hw;
interface SW_reg6_2_1_signature bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_2_1_signature#(Integer resetValue)(Ifc_CSRSignal_reg6_2_1_signature);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_2_1_signature hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_2_1_signature bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SFDP Version Minor', 'reset': 12, 'width': 8, 'signal_name': 'minor', 'reg_name': 'reg6_2_2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_2_2_minor;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_2_2_minor;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_2_2_minor;
interface HW_reg6_2_2_minor hw;
interface SW_reg6_2_2_minor bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_2_2_minor#(Integer resetValue)(Ifc_CSRSignal_reg6_2_2_minor);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_2_2_minor hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_2_2_minor bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SFDP Version Major', 'reset': 1, 'width': 8, 'signal_name': 'major', 'reg_name': 'reg6_2_2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_2_2_major;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_2_2_major;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_2_2_major;
interface HW_reg6_2_2_major hw;
interface SW_reg6_2_2_major bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_2_2_major#(Integer resetValue)(Ifc_CSRSignal_reg6_2_2_major);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_2_2_major hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_2_2_major bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.r', 'sw': 'AccessType.r', 'desc': 'Num Parameter Header TBD', 'reset': 6, 'width': 8, 'signal_name': 'numHdr', 'reg_name': 'reg6_2_2', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.r
// AccessType.r
//False
//False
//True
//True
//8
interface SW_reg6_2_2_numHdr;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_2_2_numHdr;
	
	
	
	
	
	

 method Bit#(8) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_2_2_numHdr;
interface HW_reg6_2_2_numHdr hw;
interface SW_reg6_2_2_numHdr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_2_2_numHdr#(Integer resetValue)(Ifc_CSRSignal_reg6_2_2_numHdr);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_2_2_numHdr hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(8) _read;
	return r;
endmethod


endinterface
interface SW_reg6_2_2_numHdr bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'TBD SFDP Access protocol', 'reset': 250, 'width': 8, 'signal_name': 'access_protocol', 'reg_name': 'reg6_2_2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_2_2_access_protocol;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_2_2_access_protocol;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_2_2_access_protocol;
interface HW_reg6_2_2_access_protocol hw;
interface SW_reg6_2_2_access_protocol bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_2_2_access_protocol#(Integer resetValue)(Ifc_CSRSignal_reg6_2_2_access_protocol);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_2_2_access_protocol hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_2_2_access_protocol bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 0, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_4__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__1_id;
interface HW_reg6_4__1_id hw;
interface SW_reg6_4__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_4__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 9, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_4__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__1_minor_rev;
interface HW_reg6_4__1_minor_rev hw;
interface SW_reg6_4__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_4__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_4__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__1_major_rev;
interface HW_reg6_4__1_major_rev hw;
interface SW_reg6_4__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_4__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 23, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_4__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__1_tbl_len;
interface HW_reg6_4__1_tbl_len hw;
interface SW_reg6_4__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_4__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 1024, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_4__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_4__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_4__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__2_param_tbl_ptr;
interface HW_reg6_4__2_param_tbl_ptr hw;
interface SW_reg6_4__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_4__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_4__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4__2_param_id_msb;
interface HW_reg6_4__2_param_id_msb hw;
interface SW_reg6_4__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_4__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 132, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_7__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_7__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_7__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__1_id;
interface HW_reg6_7__1_id hw;
interface SW_reg6_7__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_7__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 1, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_7__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_7__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_7__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__1_minor_rev;
interface HW_reg6_7__1_minor_rev hw;
interface SW_reg6_7__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_7__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_7__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_7__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_7__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__1_major_rev;
interface HW_reg6_7__1_major_rev hw;
interface SW_reg6_7__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_7__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 2, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_7__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_7__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_7__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__1_tbl_len;
interface HW_reg6_7__1_tbl_len hw;
interface SW_reg6_7__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_7__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 1792, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_7__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_7__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_7__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__2_param_tbl_ptr;
interface HW_reg6_7__2_param_tbl_ptr hw;
interface SW_reg6_7__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_7__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_7__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_7__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_7__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_7__2_param_id_msb;
interface HW_reg6_7__2_param_id_msb hw;
interface SW_reg6_7__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_7__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_7__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_7__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_7__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 6, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_9__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_9__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_9__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__1_id;
interface HW_reg6_9__1_id hw;
interface SW_reg6_9__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_9__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 0, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_9__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_9__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_9__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__1_minor_rev;
interface HW_reg6_9__1_minor_rev hw;
interface SW_reg6_9__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_9__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_9__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_9__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_9__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__1_major_rev;
interface HW_reg6_9__1_major_rev hw;
interface SW_reg6_9__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_9__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 3, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_9__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_9__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_9__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__1_tbl_len;
interface HW_reg6_9__1_tbl_len hw;
interface SW_reg6_9__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_9__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 2304, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_9__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_9__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_9__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__2_param_tbl_ptr;
interface HW_reg6_9__2_param_tbl_ptr hw;
interface SW_reg6_9__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_9__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_9__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_9__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_9__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_9__2_param_id_msb;
interface HW_reg6_9__2_param_id_msb hw;
interface SW_reg6_9__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_9__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_9__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_9__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_9__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 135, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_10__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_10__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_10__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__1_id;
interface HW_reg6_10__1_id hw;
interface SW_reg6_10__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_10__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 1, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_10__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_10__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_10__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__1_minor_rev;
interface HW_reg6_10__1_minor_rev hw;
interface SW_reg6_10__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_10__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_10__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_10__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_10__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__1_major_rev;
interface HW_reg6_10__1_major_rev hw;
interface SW_reg6_10__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_10__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 28, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_10__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_10__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_10__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__1_tbl_len;
interface HW_reg6_10__1_tbl_len hw;
interface SW_reg6_10__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_10__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 2560, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_10__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_10__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_10__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__2_param_tbl_ptr;
interface HW_reg6_10__2_param_tbl_ptr hw;
interface SW_reg6_10__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_10__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_10__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_10__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_10__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_10__2_param_id_msb;
interface HW_reg6_10__2_param_id_msb hw;
interface SW_reg6_10__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_10__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_10__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_10__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_10__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 9, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_11__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_11__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_11__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__1_id;
interface HW_reg6_11__1_id hw;
interface SW_reg6_11__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_11__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 0, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_11__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_11__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_11__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__1_minor_rev;
interface HW_reg6_11__1_minor_rev hw;
interface SW_reg6_11__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_11__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_11__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_11__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_11__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__1_major_rev;
interface HW_reg6_11__1_major_rev hw;
interface SW_reg6_11__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_11__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 13, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_11__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_11__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_11__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__1_tbl_len;
interface HW_reg6_11__1_tbl_len hw;
interface SW_reg6_11__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_11__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 2816, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_11__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_11__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_11__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__2_param_tbl_ptr;
interface HW_reg6_11__2_param_tbl_ptr hw;
interface SW_reg6_11__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_11__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_11__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_11__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_11__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_11__2_param_id_msb;
interface HW_reg6_11__2_param_id_msb hw;
interface SW_reg6_11__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_11__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_11__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_11__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_11__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'parameter id lsb', 'reset': 15, 'width': 8, 'signal_name': 'id', 'reg_name': 'reg6_17__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_17__1_id;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_17__1_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__1_id;
interface HW_reg6_17__1_id hw;
interface SW_reg6_17__1_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__1_id#(Integer resetValue)(Ifc_CSRSignal_reg6_17__1_id);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__1_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__1_id bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'minor rev', 'reset': 1, 'width': 8, 'signal_name': 'minor_rev', 'reg_name': 'reg6_17__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_17__1_minor_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_17__1_minor_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__1_minor_rev;
interface HW_reg6_17__1_minor_rev hw;
interface SW_reg6_17__1_minor_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__1_minor_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_17__1_minor_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__1_minor_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__1_minor_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'major_rev', 'reset': 1, 'width': 8, 'signal_name': 'major_rev', 'reg_name': 'reg6_17__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_17__1_major_rev;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_17__1_major_rev;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__1_major_rev;
interface HW_reg6_17__1_major_rev hw;
interface SW_reg6_17__1_major_rev bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__1_major_rev#(Integer resetValue)(Ifc_CSRSignal_reg6_17__1_major_rev);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__1_major_rev hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__1_major_rev bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Tbl Len', 'reset': 10, 'width': 8, 'signal_name': 'tbl_len', 'reg_name': 'reg6_17__1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_17__1_tbl_len;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_17__1_tbl_len;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__1_tbl_len;
interface HW_reg6_17__1_tbl_len hw;
interface SW_reg6_17__1_tbl_len bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__1_tbl_len#(Integer resetValue)(Ifc_CSRSignal_reg6_17__1_tbl_len);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__1_tbl_len hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__1_tbl_len bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table Pointer TBD', 'reset': 4352, 'width': 24, 'signal_name': 'param_tbl_ptr', 'reg_name': 'reg6_17__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//24
interface SW_reg6_17__2_param_tbl_ptr;


method ActionValue#(Bit#(24)) read ();

endinterface

interface HW_reg6_17__2_param_tbl_ptr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__2_param_tbl_ptr;
interface HW_reg6_17__2_param_tbl_ptr hw;
interface SW_reg6_17__2_param_tbl_ptr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__2_param_tbl_ptr#(Integer resetValue)(Ifc_CSRSignal_reg6_17__2_param_tbl_ptr);

	Reg#(Bit#(24)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(24),Bit#(24)))sw_wdata <-mkRWire();
RWire#(Bit#(24))hw_wdata <-mkRWire();
RWire#(Bit#(24))r_incr <-mkRWire();
RWire#(Bit#(24))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__2_param_tbl_ptr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__2_param_tbl_ptr bus;


method ActionValue#(Bit#(24)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Parameter Table ID MSB', 'reset': 255, 'width': 8, 'signal_name': 'param_id_msb', 'reg_name': 'reg6_17__2', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_17__2_param_id_msb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_17__2_param_id_msb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_17__2_param_id_msb;
interface HW_reg6_17__2_param_id_msb hw;
interface SW_reg6_17__2_param_id_msb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_17__2_param_id_msb#(Integer resetValue)(Ifc_CSRSignal_reg6_17__2_param_id_msb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_17__2_param_id_msb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_17__2_param_id_msb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Block/Sector Erase size.', 'reset': 3, 'width': 2, 'signal_name': 'erase_size', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_4_4_erase_size;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_4_4_erase_size;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_erase_size;
interface HW_reg_6_4_4_erase_size hw;
interface SW_reg_6_4_4_erase_size bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_erase_size#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_erase_size);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_erase_size hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_erase_size bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write Granularity (1byte).', 'reset': 0, 'width': 1, 'signal_name': 'write_granularity', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_write_granularity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_write_granularity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_write_granularity;
interface HW_reg_6_4_4_write_granularity hw;
interface SW_reg_6_4_4_write_granularity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_write_granularity#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_write_granularity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_write_granularity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_write_granularity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Volatile Status Register Block Protect.', 'reset': 1, 'width': 1, 'signal_name': 'always_volatile_csr', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_always_volatile_csr;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_always_volatile_csr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_always_volatile_csr;
interface HW_reg_6_4_4_always_volatile_csr hw;
interface SW_reg_6_4_4_always_volatile_csr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_always_volatile_csr#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_always_volatile_csr);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_always_volatile_csr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_always_volatile_csr bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write Enable Instruction select for writing to volatile status reg.', 'reset': 1, 'width': 1, 'signal_name': 'we_instruction', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_we_instruction;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_we_instruction;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_we_instruction;
interface HW_reg_6_4_4_we_instruction hw;
interface SW_reg_6_4_4_we_instruction bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_we_instruction#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_we_instruction);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_we_instruction hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_we_instruction bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Unused', 'reset': 7, 'width': 3, 'signal_name': 'unused1', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_4_unused1;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_4_unused1;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_unused1;
interface HW_reg_6_4_4_unused1 hw;
interface SW_reg_6_4_4_unused1 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_unused1#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_unused1);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_unused1 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_unused1 bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Does not support 4KB Erase', 'reset': 255, 'width': 8, 'signal_name': 'erase_4kb', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_4_erase_4kb;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_4_erase_4kb;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_erase_4kb;
interface HW_reg_6_4_4_erase_4kb hw;
interface SW_reg_6_4_4_erase_4kb bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_erase_4kb#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_erase_4kb);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_erase_4kb hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_erase_4kb bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Does not support 1S-1S-2S Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'fs_1s1s2s', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_fs_1s1s2s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_fs_1s1s2s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_fs_1s1s2s;
interface HW_reg_6_4_4_fs_1s1s2s hw;
interface SW_reg_6_4_4_fs_1s1s2s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_fs_1s1s2s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_fs_1s1s2s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_fs_1s1s2s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_fs_1s1s2s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address Bytes (4-Byte Only Addressing)', 'reset': 2, 'width': 2, 'signal_name': 'addrBytes', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_4_4_addrBytes;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_4_4_addrBytes;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_addrBytes;
interface HW_reg_6_4_4_addrBytes hw;
interface SW_reg_6_4_4_addrBytes bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_addrBytes#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_addrBytes);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_addrBytes hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_addrBytes bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Supports DTR mode', 'reset': 1, 'width': 1, 'signal_name': 'dtr_mode', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_dtr_mode;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_dtr_mode;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_dtr_mode;
interface HW_reg_6_4_4_dtr_mode hw;
interface SW_reg_6_4_4_dtr_mode bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_dtr_mode#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_dtr_mode);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_dtr_mode hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_dtr_mode bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Does not support 1S-2S-2S Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'fs_1s2s2s', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_fs_1s2s2s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_fs_1s2s2s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_fs_1s2s2s;
interface HW_reg_6_4_4_fs_1s2s2s hw;
interface SW_reg_6_4_4_fs_1s2s2s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_fs_1s2s2s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_fs_1s2s2s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_fs_1s2s2s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_fs_1s2s2s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Does not support 1S-4S-4S Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'fs_1s4s4s', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_fs_1s4s4s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_fs_1s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_fs_1s4s4s;
interface HW_reg_6_4_4_fs_1s4s4s hw;
interface SW_reg_6_4_4_fs_1s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_fs_1s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_fs_1s4s4s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_fs_1s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_fs_1s4s4s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Does not support 1S-1S-4S Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'fs_1s1s1s', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_4_fs_1s1s1s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_4_fs_1s1s1s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_fs_1s1s1s;
interface HW_reg_6_4_4_fs_1s1s1s hw;
interface SW_reg_6_4_4_fs_1s1s1s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_fs_1s1s1s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_fs_1s1s1s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_fs_1s1s1s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_fs_1s1s1s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Unused', 'reset': 255, 'width': 9, 'signal_name': 'unused0', 'reg_name': 'reg_6_4_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//9
interface SW_reg_6_4_4_unused0;


method ActionValue#(Bit#(9)) read ();

endinterface

interface HW_reg_6_4_4_unused0;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_4_unused0;
interface HW_reg_6_4_4_unused0 hw;
interface SW_reg_6_4_4_unused0 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_4_unused0#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_4_unused0);

	Reg#(Bit#(9)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(9),Bit#(9)))sw_wdata <-mkRWire();
RWire#(Bit#(9))hw_wdata <-mkRWire();
RWire#(Bit#(9))r_incr <-mkRWire();
RWire#(Bit#(9))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_4_unused0 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_4_unused0 bus;


method ActionValue#(Bit#(9)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'memory Density(in bits)', 'reset': 16777215, 'width': 32, 'signal_name': 'mem_density', 'reg_name': 'reg_6_4_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_4_5_mem_density;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_4_5_mem_density;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_5_mem_density;
interface HW_reg_6_4_5_mem_density hw;
interface SW_reg_6_4_5_mem_density bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_5_mem_density#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_5_mem_density);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_5_mem_density hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_5_mem_density bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4s-4s fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_1s4s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg6_4_6_waitstate_1s4s4s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg6_4_6_waitstate_1s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_waitstate_1s4s4s;
interface HW_reg6_4_6_waitstate_1s4s4s hw;
interface SW_reg6_4_6_waitstate_1s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_waitstate_1s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_waitstate_1s4s4s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_waitstate_1s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_waitstate_1s4s4s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4s-4s fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_1s4s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg6_4_6_mode_1s4s4s;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg6_4_6_mode_1s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_mode_1s4s4s;
interface HW_reg6_4_6_mode_1s4s4s hw;
interface SW_reg6_4_6_mode_1s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_mode_1s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_mode_1s4s4s);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_mode_1s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_mode_1s4s4s bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4s-4s fast read wait states', 'reset': 171, 'width': 8, 'signal_name': 'fr_inst_1s4s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4_6_fr_inst_1s4s4s;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4_6_fr_inst_1s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_fr_inst_1s4s4s;
interface HW_reg6_4_6_fr_inst_1s4s4s hw;
interface SW_reg6_4_6_fr_inst_1s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_fr_inst_1s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_fr_inst_1s4s4s);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_fr_inst_1s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_fr_inst_1s4s4s bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-4s fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_1s1s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg6_4_6_waitstate_1s1s4s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg6_4_6_waitstate_1s1s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_waitstate_1s1s4s;
interface HW_reg6_4_6_waitstate_1s1s4s hw;
interface SW_reg6_4_6_waitstate_1s1s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_waitstate_1s1s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_waitstate_1s1s4s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_waitstate_1s1s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_waitstate_1s1s4s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-4s fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_1s1s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg6_4_6_mode_1s1s4s;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg6_4_6_mode_1s1s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_mode_1s1s4s;
interface HW_reg6_4_6_mode_1s1s4s hw;
interface SW_reg6_4_6_mode_1s1s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_mode_1s1s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_mode_1s1s4s);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_mode_1s1s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_mode_1s1s4s bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-4s fast read instruction', 'reset': 170, 'width': 8, 'signal_name': 'fr_inst_1s1s4s', 'reg_name': 'reg6_4_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4_6_fr_inst_1s1s4s;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4_6_fr_inst_1s1s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_6_fr_inst_1s1s4s;
interface HW_reg6_4_6_fr_inst_1s1s4s hw;
interface SW_reg6_4_6_fr_inst_1s1s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_6_fr_inst_1s1s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_6_fr_inst_1s1s4s);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_6_fr_inst_1s1s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_6_fr_inst_1s1s4s bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '2S mode is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_7', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_7_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_7_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_7_reserved;
interface HW_reg6_4_7_reserved hw;
interface SW_reg6_4_7_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_7_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_7_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_7_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_7_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Supports 2S-2S-2S fast read mode(not supported)', 'reset': 0, 'width': 1, 'signal_name': 'mode_2s', 'reg_name': 'reg6_4_8', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg6_4_8_mode_2s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg6_4_8_mode_2s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_8_mode_2s;
interface HW_reg6_4_8_mode_2s hw;
interface SW_reg6_4_8_mode_2s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_8_mode_2s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_8_mode_2s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_8_mode_2s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_8_mode_2s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Supports 4S-4S-4S fast read mode', 'reset': 1, 'width': 1, 'signal_name': 'mode_4s', 'reg_name': 'reg6_4_8', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg6_4_8_mode_4s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg6_4_8_mode_4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_8_mode_4s;
interface HW_reg6_4_8_mode_4s hw;
interface SW_reg6_4_8_mode_4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_8_mode_4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_8_mode_4s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_8_mode_4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_8_mode_4s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '2S mode is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_9', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_9_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_9_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_9_reserved;
interface HW_reg6_4_9_reserved hw;
interface SW_reg6_4_9_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_9_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_9_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_9_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_9_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4s-4s fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_4s4s4s', 'reg_name': 'reg6_4_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg6_4_10_waitstate_4s4s4s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg6_4_10_waitstate_4s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_10_waitstate_4s4s4s;
interface HW_reg6_4_10_waitstate_4s4s4s hw;
interface SW_reg6_4_10_waitstate_4s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_10_waitstate_4s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_10_waitstate_4s4s4s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_10_waitstate_4s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_10_waitstate_4s4s4s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4s-4s fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_4s4s4s', 'reg_name': 'reg6_4_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg6_4_10_mode_4s4s4s;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg6_4_10_mode_4s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_10_mode_4s4s4s;
interface HW_reg6_4_10_mode_4s4s4s hw;
interface SW_reg6_4_10_mode_4s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_10_mode_4s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_10_mode_4s4s4s);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_10_mode_4s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_10_mode_4s4s4s bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4s-4s fast read instruction', 'reset': 172, 'width': 8, 'signal_name': 'fr_inst_4s4s4s', 'reg_name': 'reg6_4_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4_10_fr_inst_4s4s4s;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4_10_fr_inst_4s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_10_fr_inst_4s4s4s;
interface HW_reg6_4_10_fr_inst_4s4s4s hw;
interface SW_reg6_4_10_fr_inst_4s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_10_fr_inst_4s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg6_4_10_fr_inst_4s4s4s);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_10_fr_inst_4s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_10_fr_inst_4s4s4s bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase instruction 2,1 is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_11', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_11_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_11_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_11_reserved;
interface HW_reg6_4_11_reserved hw;
interface SW_reg6_4_11_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_11_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_11_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_11_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_11_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase instruction 4,3 is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_12', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_12_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_12_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_12_reserved;
interface HW_reg6_4_12_reserved hw;
interface SW_reg6_4_12_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_12_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_12_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_12_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_12_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase instruction is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_13_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_13_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_13_reserved;
interface HW_reg6_4_13_reserved hw;
interface SW_reg6_4_13_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_13_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_13_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_13_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_13_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase/Program instruction is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_14', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_14_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_14_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_14_reserved;
interface HW_reg6_4_14_reserved hw;
interface SW_reg6_4_14_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_14_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_14_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_14_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_14_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Suspend/Resume for Erase/Program instruction is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_15', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_15_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_15_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_15_reserved;
interface HW_reg6_4_15_reserved hw;
interface SW_reg6_4_15_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_15_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_15_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_15_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_15_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Suspend/Resume for Erase/Program instruction is not suppported. Reserved', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg6_4_16', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg6_4_16_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg6_4_16_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_16_reserved;
interface HW_reg6_4_16_reserved hw;
interface SW_reg6_4_16_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_16_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_16_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_16_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_16_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 2, 'signal_name': 'reserved', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg6_4_17_reserved;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg6_4_17_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_reserved;
interface HW_reg6_4_17_reserved hw;
interface SW_reg6_4_17_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_reserved#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_reserved);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_reserved bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'device busy poll (not supported)', 'reset': 0, 'width': 6, 'signal_name': 'dev_busy_poll', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//6
interface SW_reg6_4_17_dev_busy_poll;


method ActionValue#(Bit#(6)) read ();

endinterface

interface HW_reg6_4_17_dev_busy_poll;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_dev_busy_poll;
interface HW_reg6_4_17_dev_busy_poll hw;
interface SW_reg6_4_17_dev_busy_poll bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_dev_busy_poll#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_dev_busy_poll);

	Reg#(Bit#(6)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(6),Bit#(6)))sw_wdata <-mkRWire();
RWire#(Bit#(6))hw_wdata <-mkRWire();
RWire#(Bit#(6))r_incr <-mkRWire();
RWire#(Bit#(6))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_dev_busy_poll hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_dev_busy_poll bus;


method ActionValue#(Bit#(6)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Exit Deep powerdown delay count', 'reset': 2, 'width': 5, 'signal_name': 'exit_delay_count', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg6_4_17_exit_delay_count;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg6_4_17_exit_delay_count;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_exit_delay_count;
interface HW_reg6_4_17_exit_delay_count hw;
interface SW_reg6_4_17_exit_delay_count bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_exit_delay_count#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_exit_delay_count);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_exit_delay_count hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_exit_delay_count bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Exit Deep powerdown delay units 64us', 'reset': 3, 'width': 2, 'signal_name': 'exit_delay_units', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg6_4_17_exit_delay_units;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg6_4_17_exit_delay_units;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_exit_delay_units;
interface HW_reg6_4_17_exit_delay_units hw;
interface SW_reg6_4_17_exit_delay_units bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_exit_delay_units#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_exit_delay_units);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_exit_delay_units hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_exit_delay_units bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Exit Deep powerdown Instruction', 'reset': 174, 'width': 8, 'signal_name': 'inst_deep_power_down_exit', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4_17_inst_deep_power_down_exit;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4_17_inst_deep_power_down_exit;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_exit;
interface HW_reg6_4_17_inst_deep_power_down_exit hw;
interface SW_reg6_4_17_inst_deep_power_down_exit bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_inst_deep_power_down_exit#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_exit);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_inst_deep_power_down_exit hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_inst_deep_power_down_exit bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Enter Deep powerdown Instruction', 'reset': 173, 'width': 8, 'signal_name': 'inst_deep_power_down_enter', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg6_4_17_inst_deep_power_down_enter;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg6_4_17_inst_deep_power_down_enter;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_enter;
interface HW_reg6_4_17_inst_deep_power_down_enter hw;
interface SW_reg6_4_17_inst_deep_power_down_enter bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_inst_deep_power_down_enter#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_inst_deep_power_down_enter);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_inst_deep_power_down_enter hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_inst_deep_power_down_enter bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Deep powerdown is supported', 'reset': 1, 'width': 1, 'signal_name': 'deep_power_down', 'reg_name': 'reg6_4_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg6_4_17_deep_power_down;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg6_4_17_deep_power_down;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_17_deep_power_down;
interface HW_reg6_4_17_deep_power_down hw;
interface SW_reg6_4_17_deep_power_down bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_17_deep_power_down#(Integer resetValue)(Ifc_CSRSignal_reg6_4_17_deep_power_down);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_17_deep_power_down hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_17_deep_power_down bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4-4-4 Mode disable sequence TBD', 'reset': 0, 'width': 4, 'signal_name': 'mode_disable444', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg6_4_18_mode_disable444;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg6_4_18_mode_disable444;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_mode_disable444;
interface HW_reg6_4_18_mode_disable444 hw;
interface SW_reg6_4_18_mode_disable444 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_mode_disable444#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_mode_disable444);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_mode_disable444 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_mode_disable444 bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4-4-4 Mode enable sequence TBD', 'reset': 0, 'width': 5, 'signal_name': 'mode_enable444', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg6_4_18_mode_enable444;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg6_4_18_mode_enable444;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_mode_enable444;
interface HW_reg6_4_18_mode_enable444 hw;
interface SW_reg6_4_18_mode_enable444 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_mode_enable444#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_mode_enable444);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_mode_enable444 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_mode_enable444 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-4-4 Mode supported (XIP)', 'reset': 1, 'width': 1, 'signal_name': 'xip_supported_044', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg6_4_18_xip_supported_044;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg6_4_18_xip_supported_044;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_xip_supported_044;
interface HW_reg6_4_18_xip_supported_044 hw;
interface SW_reg6_4_18_xip_supported_044 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_xip_supported_044#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_xip_supported_044);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_xip_supported_044 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_xip_supported_044 bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-4-4 Mode exit method TBD', 'reset': 0, 'width': 6, 'signal_name': 'mode_exit044', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//6
interface SW_reg6_4_18_mode_exit044;


method ActionValue#(Bit#(6)) read ();

endinterface

interface HW_reg6_4_18_mode_exit044;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_mode_exit044;
interface HW_reg6_4_18_mode_exit044 hw;
interface SW_reg6_4_18_mode_exit044 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_mode_exit044#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_mode_exit044);

	Reg#(Bit#(6)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(6),Bit#(6)))sw_wdata <-mkRWire();
RWire#(Bit#(6))hw_wdata <-mkRWire();
RWire#(Bit#(6))r_incr <-mkRWire();
RWire#(Bit#(6))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_mode_exit044 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_mode_exit044 bus;


method ActionValue#(Bit#(6)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-4-4 Mode entry method TBD', 'reset': 0, 'width': 4, 'signal_name': 'mode_entry044', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg6_4_18_mode_entry044;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg6_4_18_mode_entry044;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_mode_entry044;
interface HW_reg6_4_18_mode_entry044 hw;
interface SW_reg6_4_18_mode_entry044 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_mode_entry044#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_mode_entry044);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_mode_entry044 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_mode_entry044 bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'quad enable requirement', 'reset': 0, 'width': 3, 'signal_name': 'quad_enable', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg6_4_18_quad_enable;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg6_4_18_quad_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_quad_enable;
interface HW_reg6_4_18_quad_enable hw;
interface SW_reg6_4_18_quad_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_quad_enable#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_quad_enable);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_quad_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_quad_enable bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'hold/reset disable (not supported)', 'reset': 0, 'width': 1, 'signal_name': 'hold_rst_support', 'reg_name': 'reg6_4_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg6_4_18_hold_rst_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg6_4_18_hold_rst_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg6_4_18_hold_rst_support;
interface HW_reg6_4_18_hold_rst_support hw;
interface SW_reg6_4_18_hold_rst_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg6_4_18_hold_rst_support#(Integer resetValue)(Ifc_CSRSignal_reg6_4_18_hold_rst_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg6_4_18_hold_rst_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg6_4_18_hold_rst_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'volatile register status1', 'reset': 2, 'width': 7, 'signal_name': 'volatile_status_reg_1', 'reg_name': 'reg_6_4_19', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//7
interface SW_reg_6_4_19_volatile_status_reg_1;


method ActionValue#(Bit#(7)) read ();

endinterface

interface HW_reg_6_4_19_volatile_status_reg_1;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_19_volatile_status_reg_1;
interface HW_reg_6_4_19_volatile_status_reg_1 hw;
interface SW_reg_6_4_19_volatile_status_reg_1 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_19_volatile_status_reg_1#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_19_volatile_status_reg_1);

	Reg#(Bit#(7)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(7),Bit#(7)))sw_wdata <-mkRWire();
RWire#(Bit#(7))hw_wdata <-mkRWire();
RWire#(Bit#(7))r_incr <-mkRWire();
RWire#(Bit#(7))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_19_volatile_status_reg_1 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_19_volatile_status_reg_1 bus;


method ActionValue#(Bit#(7)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Soft reset instruction support (not supported)', 'reset': 0, 'width': 6, 'signal_name': 'soft_reset_support', 'reg_name': 'reg_6_4_19', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//6
interface SW_reg_6_4_19_soft_reset_support;


method ActionValue#(Bit#(6)) read ();

endinterface

interface HW_reg_6_4_19_soft_reset_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_19_soft_reset_support;
interface HW_reg_6_4_19_soft_reset_support hw;
interface SW_reg_6_4_19_soft_reset_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_19_soft_reset_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_19_soft_reset_support);

	Reg#(Bit#(6)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(6),Bit#(6)))sw_wdata <-mkRWire();
RWire#(Bit#(6))hw_wdata <-mkRWire();
RWire#(Bit#(6))r_incr <-mkRWire();
RWire#(Bit#(6))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_19_soft_reset_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_19_soft_reset_support bus;


method ActionValue#(Bit#(6)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Exit 4 byte addressing TBD', 'reset': 0, 'width': 10, 'signal_name': 'exit_4B_addressing', 'reg_name': 'reg_6_4_19', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//10
interface SW_reg_6_4_19_exit_4B_addressing;


method ActionValue#(Bit#(10)) read ();

endinterface

interface HW_reg_6_4_19_exit_4B_addressing;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_19_exit_4B_addressing;
interface HW_reg_6_4_19_exit_4B_addressing hw;
interface SW_reg_6_4_19_exit_4B_addressing bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_19_exit_4B_addressing#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_19_exit_4B_addressing);

	Reg#(Bit#(10)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(10),Bit#(10)))sw_wdata <-mkRWire();
RWire#(Bit#(10))hw_wdata <-mkRWire();
RWire#(Bit#(10))r_incr <-mkRWire();
RWire#(Bit#(10))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_19_exit_4B_addressing hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_19_exit_4B_addressing bus;


method ActionValue#(Bit#(10)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Enter 4 byte addressing;Always in $B mode', 'reset': 64, 'width': 8, 'signal_name': 'enter_4B_addressing', 'reg_name': 'reg_6_4_19', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_19_enter_4B_addressing;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_19_enter_4B_addressing;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_19_enter_4B_addressing;
interface HW_reg_6_4_19_enter_4B_addressing hw;
interface SW_reg_6_4_19_enter_4B_addressing bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_19_enter_4B_addressing#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_19_enter_4B_addressing);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_19_enter_4B_addressing hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_19_enter_4B_addressing bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-8s-8s fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_1s8s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_20_waitstate_1s8s8s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_20_waitstate_1s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_waitstate_1s8s8s;
interface HW_reg_6_4_20_waitstate_1s8s8s hw;
interface SW_reg_6_4_20_waitstate_1s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_waitstate_1s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_waitstate_1s8s8s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_waitstate_1s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_waitstate_1s8s8s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-8s-8s fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_1s8s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_20_mode_1s8s8s;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_20_mode_1s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_mode_1s8s8s;
interface HW_reg_6_4_20_mode_1s8s8s hw;
interface SW_reg_6_4_20_mode_1s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_mode_1s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_mode_1s8s8s);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_mode_1s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_mode_1s8s8s bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-8s-8s fast read wait states', 'reset': 171, 'width': 8, 'signal_name': 'fr_inst_1s8s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_20_fr_inst_1s8s8s;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_20_fr_inst_1s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_fr_inst_1s8s8s;
interface HW_reg_6_4_20_fr_inst_1s8s8s hw;
interface SW_reg_6_4_20_fr_inst_1s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_fr_inst_1s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_fr_inst_1s8s8s);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_fr_inst_1s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_fr_inst_1s8s8s bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-8s fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_1s1s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_20_waitstate_1s1s8s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_20_waitstate_1s1s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_waitstate_1s1s8s;
interface HW_reg_6_4_20_waitstate_1s1s8s hw;
interface SW_reg_6_4_20_waitstate_1s1s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_waitstate_1s1s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_waitstate_1s1s8s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_waitstate_1s1s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_waitstate_1s1s8s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-8s fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_1s1s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_20_mode_1s1s8s;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_20_mode_1s1s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_mode_1s1s8s;
interface HW_reg_6_4_20_mode_1s1s8s hw;
interface SW_reg_6_4_20_mode_1s1s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_mode_1s1s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_mode_1s1s8s);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_mode_1s1s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_mode_1s1s8s bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-1s-8s fast read instruction', 'reset': 175, 'width': 8, 'signal_name': 'fr_inst_1s1s8s', 'reg_name': 'reg_6_4_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_20_fr_inst_1s1s8s;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_20_fr_inst_1s1s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_20_fr_inst_1s1s8s;
interface HW_reg_6_4_20_fr_inst_1s1s8s hw;
interface SW_reg_6_4_20_fr_inst_1s1s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_20_fr_inst_1s1s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_20_fr_inst_1s1s8s);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_20_fr_inst_1s1s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_20_fr_inst_1s1s8s bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Drive Strength TBD', 'reset': 1, 'width': 5, 'signal_name': 'drive_strength', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_21_drive_strength;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_21_drive_strength;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_drive_strength;
interface HW_reg_6_4_21_drive_strength hw;
interface SW_reg_6_4_21_drive_strength bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_drive_strength#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_drive_strength);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_drive_strength hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_drive_strength bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'JEDEC reset(not supported)', 'reset': 0, 'width': 1, 'signal_name': 'jedec_reset', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_21_jedec_reset;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_21_jedec_reset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_jedec_reset;
interface HW_reg_6_4_21_jedec_reset hw;
interface SW_reg_6_4_21_jedec_reset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_jedec_reset#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_jedec_reset);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_jedec_reset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_jedec_reset bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Data strobe STR Waveform TBD', 'reset': 0, 'width': 2, 'signal_name': 'data_strobe_str_waveform', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_4_21_data_strobe_str_waveform;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_4_21_data_strobe_str_waveform;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_data_strobe_str_waveform;
interface HW_reg_6_4_21_data_strobe_str_waveform hw;
interface SW_reg_6_4_21_data_strobe_str_waveform bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_data_strobe_str_waveform#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_data_strobe_str_waveform);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_data_strobe_str_waveform hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_data_strobe_str_waveform bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Data strobe support in QPI 4S-4S-4S', 'reset': 0, 'width': 1, 'signal_name': 'data_strobe_support_4s4S4S', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_21_data_strobe_support_4s4S4S;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_21_data_strobe_support_4s4S4S;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4S4S;
interface HW_reg_6_4_21_data_strobe_support_4s4S4S hw;
interface SW_reg_6_4_21_data_strobe_support_4s4S4S bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_data_strobe_support_4s4S4S#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4S4S);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_data_strobe_support_4s4S4S hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_data_strobe_support_4s4S4S bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Data strobe support in QPI 4S-4D-4D', 'reset': 0, 'width': 1, 'signal_name': 'data_strobe_support_4s4d4d', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_21_data_strobe_support_4s4d4d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_21_data_strobe_support_4s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4d4d;
interface HW_reg_6_4_21_data_strobe_support_4s4d4d hw;
interface SW_reg_6_4_21_data_strobe_support_4s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_data_strobe_support_4s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_data_strobe_support_4s4d4d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_data_strobe_support_4s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_data_strobe_support_4s4d4d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Octal DTR Command/Extension', 'reset': 0, 'width': 2, 'signal_name': 'cmd_ext', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_4_21_cmd_ext;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_4_21_cmd_ext;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_cmd_ext;
interface HW_reg_6_4_21_cmd_ext hw;
interface SW_reg_6_4_21_cmd_ext bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_cmd_ext#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_cmd_ext);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_cmd_ext hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_cmd_ext bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Byte order in 8D-8D-8D mode same as 1S-1S-1S mode', 'reset': 0, 'width': 1, 'signal_name': 'byte_order_8D', 'reg_name': 'reg_6_4_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_21_byte_order_8D;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_21_byte_order_8D;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_21_byte_order_8D;
interface HW_reg_6_4_21_byte_order_8D hw;
interface SW_reg_6_4_21_byte_order_8D bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_21_byte_order_8D#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_21_byte_order_8D);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_21_byte_order_8D hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_21_byte_order_8D bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '8s8s8s mode disable seq', 'reset': 1, 'width': 4, 'signal_name': 'disable_seq_8s8s8s', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_22_disable_seq_8s8s8s;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_22_disable_seq_8s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_disable_seq_8s8s8s;
interface HW_reg_6_4_22_disable_seq_8s8s8s hw;
interface SW_reg_6_4_22_disable_seq_8s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_disable_seq_8s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_disable_seq_8s8s8s);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_disable_seq_8s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_disable_seq_8s8s8s bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '8s8s8s mode enable seq', 'reset': 2, 'width': 5, 'signal_name': 'enable_seq_8s8s8s', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_22_enable_seq_8s8s8s;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_22_enable_seq_8s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_enable_seq_8s8s8s;
interface HW_reg_6_4_22_enable_seq_8s8s8s hw;
interface SW_reg_6_4_22_enable_seq_8s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_enable_seq_8s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_enable_seq_8s8s8s);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_enable_seq_8s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_enable_seq_8s8s8s bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-8-8 XIP supported', 'reset': 1, 'width': 1, 'signal_name': 'xip_supported_088', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_22_xip_supported_088;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_22_xip_supported_088;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_xip_supported_088;
interface HW_reg_6_4_22_xip_supported_088 hw;
interface SW_reg_6_4_22_xip_supported_088 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_xip_supported_088#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_xip_supported_088);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_xip_supported_088 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_xip_supported_088 bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-8-8 Mode Exit method TBD', 'reset': 4, 'width': 6, 'signal_name': 'xip_exit_088', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//6
interface SW_reg_6_4_22_xip_exit_088;


method ActionValue#(Bit#(6)) read ();

endinterface

interface HW_reg_6_4_22_xip_exit_088;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_xip_exit_088;
interface HW_reg_6_4_22_xip_exit_088 hw;
interface SW_reg_6_4_22_xip_exit_088 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_xip_exit_088#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_xip_exit_088);

	Reg#(Bit#(6)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(6),Bit#(6)))sw_wdata <-mkRWire();
RWire#(Bit#(6))hw_wdata <-mkRWire();
RWire#(Bit#(6))r_incr <-mkRWire();
RWire#(Bit#(6))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_xip_exit_088 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_xip_exit_088 bus;


method ActionValue#(Bit#(6)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '0-8-8 Mode Entry method', 'reset': 1, 'width': 4, 'signal_name': 'xip_entry_088', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_22_xip_entry_088;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_22_xip_entry_088;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_xip_entry_088;
interface HW_reg_6_4_22_xip_entry_088 hw;
interface SW_reg_6_4_22_xip_entry_088 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_xip_entry_088#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_xip_entry_088);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_xip_entry_088 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_xip_entry_088 bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'octal_enable req', 'reset': 1, 'width': 3, 'signal_name': 'octal_enable_req', 'reg_name': 'reg_6_4_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_22_octal_enable_req;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_22_octal_enable_req;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_22_octal_enable_req;
interface HW_reg_6_4_22_octal_enable_req hw;
interface SW_reg_6_4_22_octal_enable_req bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_22_octal_enable_req#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_22_octal_enable_req);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_22_octal_enable_req hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_22_octal_enable_req bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 4S-4S-4S speed not using DS 200 Mhz', 'reset': 8, 'width': 4, 'signal_name': 'max_4S_speed_without_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_4S_speed_without_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_4S_speed_without_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_4S_speed_without_ds;
interface HW_reg_6_4_23_max_4S_speed_without_ds hw;
interface SW_reg_6_4_23_max_4S_speed_without_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_4S_speed_without_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_4S_speed_without_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_4S_speed_without_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_4S_speed_without_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 4S-4S-4S speed using DS 166Mhz', 'reset': 7, 'width': 4, 'signal_name': 'max_4S_speed_with_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_4S_speed_with_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_4S_speed_with_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_4S_speed_with_ds;
interface HW_reg_6_4_23_max_4S_speed_with_ds hw;
interface SW_reg_6_4_23_max_4S_speed_with_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_4S_speed_with_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_4S_speed_with_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_4S_speed_with_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_4S_speed_with_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 4S-4D-4D speed not using DS', 'reset': 8, 'width': 4, 'signal_name': 'max_4D_speed_without_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_4D_speed_without_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_4D_speed_without_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_4D_speed_without_ds;
interface HW_reg_6_4_23_max_4D_speed_without_ds hw;
interface SW_reg_6_4_23_max_4D_speed_without_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_4D_speed_without_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_4D_speed_without_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_4D_speed_without_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_4D_speed_without_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 4S-4D-4D speed using DS', 'reset': 8, 'width': 4, 'signal_name': 'max_4D_speed_with_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_4D_speed_with_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_4D_speed_with_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_4D_speed_with_ds;
interface HW_reg_6_4_23_max_4D_speed_with_ds hw;
interface SW_reg_6_4_23_max_4D_speed_with_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_4D_speed_with_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_4D_speed_with_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_4D_speed_with_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_4D_speed_with_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 8S speed not using DS', 'reset': 8, 'width': 4, 'signal_name': 'max_8S_speed_without_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_8S_speed_without_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_8S_speed_without_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_8S_speed_without_ds;
interface HW_reg_6_4_23_max_8S_speed_without_ds hw;
interface SW_reg_6_4_23_max_8S_speed_without_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_8S_speed_without_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_8S_speed_without_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_8S_speed_without_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_8S_speed_without_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 8S speed using DS 200Mhz', 'reset': 8, 'width': 4, 'signal_name': 'max_8S_speed_with_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_8S_speed_with_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_8S_speed_with_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_8S_speed_with_ds;
interface HW_reg_6_4_23_max_8S_speed_with_ds hw;
interface SW_reg_6_4_23_max_8S_speed_with_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_8S_speed_with_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_8S_speed_with_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_8S_speed_with_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_8S_speed_with_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 8D speed not using DS', 'reset': 8, 'width': 4, 'signal_name': 'max_8D_speed_without_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_8D_speed_without_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_8D_speed_without_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_8D_speed_without_ds;
interface HW_reg_6_4_23_max_8D_speed_without_ds hw;
interface SW_reg_6_4_23_max_8D_speed_without_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_8D_speed_without_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_8D_speed_without_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_8D_speed_without_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_8D_speed_without_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'max 8D speed using DS 200Mhz', 'reset': 8, 'width': 4, 'signal_name': 'max_8D_speed_with_ds', 'reg_name': 'reg_6_4_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_4_23_max_8D_speed_with_ds;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_4_23_max_8D_speed_with_ds;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_23_max_8D_speed_with_ds;
interface HW_reg_6_4_23_max_8D_speed_with_ds hw;
interface SW_reg_6_4_23_max_8D_speed_with_ds bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_23_max_8D_speed_with_ds#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_23_max_8D_speed_with_ds);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_23_max_8D_speed_with_ds hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_23_max_8D_speed_with_ds bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'supports 4S-4D-4D Fast Read', 'reset': 1, 'width': 3, 'signal_name': 'supports_4s4d4d', 'reg_name': 'reg_6_4_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_24_supports_4s4d4d;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_24_supports_4s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_24_supports_4s4d4d;
interface HW_reg_6_4_24_supports_4s4d4d hw;
interface SW_reg_6_4_24_supports_4s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_24_supports_4s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_24_supports_4s4d4d);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_24_supports_4s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_24_supports_4s4d4d bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'supports 1S-4D-4D Fast Read', 'reset': 1, 'width': 2, 'signal_name': 'supports_1s4d4d', 'reg_name': 'reg_6_4_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_4_24_supports_1s4d4d;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_4_24_supports_1s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_24_supports_1s4d4d;
interface HW_reg_6_4_24_supports_1s4d4d hw;
interface SW_reg_6_4_24_supports_1s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_24_supports_1s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_24_supports_1s4d4d);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_24_supports_1s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_24_supports_1s4d4d bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'supports 1S-2D-2D Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'supports_1s2d2d', 'reg_name': 'reg_6_4_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_24_supports_1s2d2d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_24_supports_1s2d2d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_24_supports_1s2d2d;
interface HW_reg_6_4_24_supports_1s2d2d hw;
interface SW_reg_6_4_24_supports_1s2d2d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_24_supports_1s2d2d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_24_supports_1s2d2d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_24_supports_1s2d2d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_24_supports_1s2d2d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'supports 1S-1D-1D Fast Read', 'reset': 0, 'width': 1, 'signal_name': 'supports_1s1d1d', 'reg_name': 'reg_6_4_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_4_24_supports_1s1d1d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_4_24_supports_1s1d1d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_24_supports_1s1d1d;
interface HW_reg_6_4_24_supports_1s1d1d hw;
interface SW_reg_6_4_24_supports_1s1d1d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_24_supports_1s1d1d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_24_supports_1s1d1d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_24_supports_1s1d1d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_24_supports_1s1d1d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1S2D2D and 1S1D1D not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_4_25', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_4_25_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_4_25_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_25_reserved;
interface HW_reg_6_4_25_reserved hw;
interface SW_reg_6_4_25_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_25_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_25_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_25_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_25_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4d-4d fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_1s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_26_waitstate_1s4d4d;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_26_waitstate_1s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_waitstate_1s4d4d;
interface HW_reg_6_4_26_waitstate_1s4d4d hw;
interface SW_reg_6_4_26_waitstate_1s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_waitstate_1s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_waitstate_1s4d4d);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_waitstate_1s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_waitstate_1s4d4d bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4d-4d fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_1s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_26_mode_1s4d4d;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_26_mode_1s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_mode_1s4d4d;
interface HW_reg_6_4_26_mode_1s4d4d hw;
interface SW_reg_6_4_26_mode_1s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_mode_1s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_mode_1s4d4d);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_mode_1s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_mode_1s4d4d bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s-4d-4d fast read wait states', 'reset': 177, 'width': 8, 'signal_name': 'fr_inst_1s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_26_fr_inst_1s4d4d;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_26_fr_inst_1s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_fr_inst_1s4d4d;
interface HW_reg_6_4_26_fr_inst_1s4d4d hw;
interface SW_reg_6_4_26_fr_inst_1s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_fr_inst_1s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_fr_inst_1s4d4d);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_fr_inst_1s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_fr_inst_1s4d4d bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4d-4d fast read wait states', 'reset': 2, 'width': 5, 'signal_name': 'waitstate_4s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_4_26_waitstate_4s4d4d;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_4_26_waitstate_4s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_waitstate_4s4d4d;
interface HW_reg_6_4_26_waitstate_4s4d4d hw;
interface SW_reg_6_4_26_waitstate_4s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_waitstate_4s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_waitstate_4s4d4d);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_waitstate_4s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_waitstate_4s4d4d bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4d-4d fast read num mode clocks', 'reset': 0, 'width': 3, 'signal_name': 'mode_4s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_4_26_mode_4s4d4d;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_4_26_mode_4s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_mode_4s4d4d;
interface HW_reg_6_4_26_mode_4s4d4d hw;
interface SW_reg_6_4_26_mode_4s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_mode_4s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_mode_4s4d4d);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_mode_4s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_mode_4s4d4d bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '4s-4d-4d fast read instruction', 'reset': 176, 'width': 8, 'signal_name': 'fr_inst_4s4d4d', 'reg_name': 'reg_6_4_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_4_26_fr_inst_4s4d4d;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_4_26_fr_inst_4s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_4_26_fr_inst_4s4d4d;
interface HW_reg_6_4_26_fr_inst_4s4d4d hw;
interface SW_reg_6_4_26_fr_inst_4s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_4_26_fr_inst_4s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_4_26_fr_inst_4s4d4d);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_4_26_fr_inst_4s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_4_26_fr_inst_4s4d4d bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1s1s Read cmd inst 13h support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'r_inst_1s1s1s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_r_inst_1s1s1s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_r_inst_1s1s1s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_r_inst_1s1s1s;
interface HW_reg_6_7_3_r_inst_1s1s1s hw;
interface SW_reg_6_7_3_r_inst_1s1s1s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_r_inst_1s1s1s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_r_inst_1s1s1s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_r_inst_1s1s1s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_r_inst_1s1s1s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1s1s Fast Read cmd inst 0Ch support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'fr_inst_1s1s1s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s1s1s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s1s1s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s1s;
interface HW_reg_6_7_3_fr_inst_1s1s1s hw;
interface SW_reg_6_7_3_fr_inst_1s1s1s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s1s1s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s1s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s1s1s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s1s1s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '2S not supported', 'reset': 0, 'width': 2, 'signal_name': 'reserved_2s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_7_3_reserved_2s;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_7_3_reserved_2s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_reserved_2s;
interface HW_reg_6_7_3_reserved_2s hw;
interface SW_reg_6_7_3_reserved_2s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_reserved_2s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_reserved_2s);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_reserved_2s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_reserved_2s bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1s4s fast Read cmd inst 34h support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'fr_inst_1s1s4s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s1s4s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s1s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s4s;
interface HW_reg_6_7_3_fr_inst_1s1s4s hw;
interface SW_reg_6_7_3_fr_inst_1s1s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s1s4s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s4s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s1s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s1s4s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s4s4s fast Read cmd inst 3Eh support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'fr_inst_1s4s4s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s4s4s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4s4s;
interface HW_reg_6_7_3_fr_inst_1s4s4s hw;
interface SW_reg_6_7_3_fr_inst_1s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4s4s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s4s4s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase/Page cmds not supported', 'reset': 0, 'width': 7, 'signal_name': 'erase_reserved', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//7
interface SW_reg_6_7_3_erase_reserved;


method ActionValue#(Bit#(7)) read ();

endinterface

interface HW_reg_6_7_3_erase_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_erase_reserved;
interface HW_reg_6_7_3_erase_reserved hw;
interface SW_reg_6_7_3_erase_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_erase_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_erase_reserved);

	Reg#(Bit#(7)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(7),Bit#(7)))sw_wdata <-mkRWire();
RWire#(Bit#(7))hw_wdata <-mkRWire();
RWire#(Bit#(7))r_incr <-mkRWire();
RWire#(Bit#(7))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_erase_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_erase_reserved bus;


method ActionValue#(Bit#(7)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1d1d DTR Read cmd inst 0E support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s1d1d', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s1d1d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s1d1d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1d1d;
interface HW_reg_6_7_3_fr_inst_1s1d1d hw;
interface SW_reg_6_7_3_fr_inst_1s1d1d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s1d1d#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1d1d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s1d1d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s1d1d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s2d2d DTR Read cmd inst BEh support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s2d2d', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s2d2d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s2d2d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s2d2d;
interface HW_reg_6_7_3_fr_inst_1s2d2d hw;
interface SW_reg_6_7_3_fr_inst_1s2d2d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s2d2d#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s2d2d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s2d2d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s2d2d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s4d4d DTR Read cmd inst EEh support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s4d4d', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s4d4d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4d4d;
interface HW_reg_6_7_3_fr_inst_1s4d4d hw;
interface SW_reg_6_7_3_fr_inst_1s4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s4d4d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s4d4d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Sector cmds not supported', 'reset': 0, 'width': 4, 'signal_name': 'sector_reserved', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_7_3_sector_reserved;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_7_3_sector_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_sector_reserved;
interface HW_reg_6_7_3_sector_reserved hw;
interface SW_reg_6_7_3_sector_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_sector_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_sector_reserved);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_sector_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_sector_reserved bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1s8s Fast Read cmd inst 7Ch support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s1s8s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s1s8s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s1s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s8s;
interface HW_reg_6_7_3_fr_inst_1s1s8s hw;
interface SW_reg_6_7_3_fr_inst_1s1s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s1s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s1s8s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s1s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s1s8s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s8s8s Fast Read cmd inst CCh support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s8s8s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s8s8s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8s8s;
interface HW_reg_6_7_3_fr_inst_1s8s8s hw;
interface SW_reg_6_7_3_fr_inst_1s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8s8s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s8s8s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s8d8d DTR Read cmd inst FDh support(no)', 'reset': 0, 'width': 1, 'signal_name': 'fr_inst_1s8d8d', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_fr_inst_1s8d8d;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_fr_inst_1s8d8d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8d8d;
interface HW_reg_6_7_3_fr_inst_1s8d8d hw;
interface SW_reg_6_7_3_fr_inst_1s8d8d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_fr_inst_1s8d8d#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_fr_inst_1s8d8d);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_fr_inst_1s8d8d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_fr_inst_1s8d8d bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s1s8s page program support (no)', 'reset': 0, 'width': 1, 'signal_name': 'page_program_support_1s1s8s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_page_program_support_1s1s8s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_page_program_support_1s1s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_page_program_support_1s1s8s;
interface HW_reg_6_7_3_page_program_support_1s1s8s hw;
interface SW_reg_6_7_3_page_program_support_1s1s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_page_program_support_1s1s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_page_program_support_1s1s8s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_page_program_support_1s1s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_page_program_support_1s1s8s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '1s8s8s page program support (no)', 'reset': 0, 'width': 1, 'signal_name': 'page_program_support_1s8s8s', 'reg_name': 'reg_6_7_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_7_3_page_program_support_1s8s8s;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_7_3_page_program_support_1s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_3_page_program_support_1s8s8s;
interface HW_reg_6_7_3_page_program_support_1s8s8s hw;
interface SW_reg_6_7_3_page_program_support_1s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_3_page_program_support_1s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_3_page_program_support_1s8s8s);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_3_page_program_support_1s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_3_page_program_support_1s8s8s bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'erase is not supported', 'reset': 0, 'width': 32, 'signal_name': 'erase_reserved', 'reg_name': 'reg_6_7_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_7_4_erase_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_7_4_erase_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_7_4_erase_reserved;
interface HW_reg_6_7_4_erase_reserved hw;
interface SW_reg_6_7_4_erase_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_7_4_erase_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_7_4_erase_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_7_4_erase_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_7_4_erase_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'reserved', 'reset': 0, 'width': 5, 'signal_name': 'reserved', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_3_reserved;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_3_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_reserved;
interface HW_reg_6_9_3_reserved hw;
interface SW_reg_6_9_3_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_reserved);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_reserved bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'enter SPI supported', 'reset': 1, 'width': 1, 'signal_name': 'enter_spi_supported', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_enter_spi_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_enter_spi_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_enter_spi_supported;
interface HW_reg_6_9_3_enter_spi_supported hw;
interface SW_reg_6_9_3_enter_spi_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_enter_spi_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_enter_spi_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_enter_spi_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_enter_spi_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'program/erase not supported', 'reset': 0, 'width': 9, 'signal_name': 'pgm_reserved', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//9
interface SW_reg_6_9_3_pgm_reserved;


method ActionValue#(Bit#(9)) read ();

endinterface

interface HW_reg_6_9_3_pgm_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_pgm_reserved;
interface HW_reg_6_9_3_pgm_reserved hw;
interface SW_reg_6_9_3_pgm_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_pgm_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_pgm_reserved);

	Reg#(Bit#(9)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(9),Bit#(9)))sw_wdata <-mkRWire();
RWire#(Bit#(9))hw_wdata <-mkRWire();
RWire#(Bit#(9))r_incr <-mkRWire();
RWire#(Bit#(9))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_pgm_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_pgm_reserved bus;


method ActionValue#(Bit#(9)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Deep Power down support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'deep_pd_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_deep_pd_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_deep_pd_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_deep_pd_support;
interface HW_reg_6_9_3_deep_pd_support hw;
interface SW_reg_6_9_3_deep_pd_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_deep_pd_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_deep_pd_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_deep_pd_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_deep_pd_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Cfg register load support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'cfg_reg_load_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_cfg_reg_load_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_cfg_reg_load_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_cfg_reg_load_support;
interface HW_reg_6_9_3_cfg_reg_load_support hw;
interface SW_reg_6_9_3_cfg_reg_load_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_cfg_reg_load_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_cfg_reg_load_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_cfg_reg_load_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_cfg_reg_load_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Cfg register read support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'cfg_reg_read_suport', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_cfg_reg_read_suport;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_cfg_reg_read_suport;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_cfg_reg_read_suport;
interface HW_reg_6_9_3_cfg_reg_read_suport hw;
interface SW_reg_6_9_3_cfg_reg_read_suport bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_cfg_reg_read_suport#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_cfg_reg_read_suport);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_cfg_reg_read_suport hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_cfg_reg_read_suport bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Status register clear support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'sts_reg_clr_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_sts_reg_clr_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_sts_reg_clr_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_sts_reg_clr_support;
interface HW_reg_6_9_3_sts_reg_clr_support hw;
interface SW_reg_6_9_3_sts_reg_clr_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_sts_reg_clr_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_sts_reg_clr_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_sts_reg_clr_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_sts_reg_clr_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Status register read support(yes)', 'reset': 1, 'width': 1, 'signal_name': 'sts_reg_read_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_sts_reg_read_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_sts_reg_read_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_sts_reg_read_support;
interface HW_reg_6_9_3_sts_reg_read_support hw;
interface SW_reg_6_9_3_sts_reg_read_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_sts_reg_read_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_sts_reg_read_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_sts_reg_read_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_sts_reg_read_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SREN support(no)', 'reset': 0, 'width': 1, 'signal_name': 'sren_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_sren_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_sren_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_sren_support;
interface HW_reg_6_9_3_sren_support hw;
interface SW_reg_6_9_3_sren_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_sren_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_sren_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_sren_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_sren_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'WREN2 support(no)', 'reset': 0, 'width': 1, 'signal_name': 'wren2_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_wren2_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_wren2_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_wren2_support;
interface HW_reg_6_9_3_wren2_support hw;
interface SW_reg_6_9_3_wren2_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_wren2_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_wren2_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_wren2_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_wren2_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'WREN1 support(no)', 'reset': 0, 'width': 1, 'signal_name': 'wren1_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_wren1_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_wren1_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_wren1_support;
interface HW_reg_6_9_3_wren1_support hw;
interface SW_reg_6_9_3_wren1_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_wren1_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_wren1_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_wren1_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_wren1_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'write memory linear support', 'reset': 1, 'width': 1, 'signal_name': 'write_mem_linear', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_write_mem_linear;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_write_mem_linear;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_write_mem_linear;
interface HW_reg_6_9_3_write_mem_linear hw;
interface SW_reg_6_9_3_write_mem_linear bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_write_mem_linear#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_write_mem_linear);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_write_mem_linear hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_write_mem_linear bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'write memory wrapped support', 'reset': 0, 'width': 1, 'signal_name': 'write_mem_wrapped', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_write_mem_wrapped;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_write_mem_wrapped;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_write_mem_wrapped;
interface HW_reg_6_9_3_write_mem_wrapped hw;
interface SW_reg_6_9_3_write_mem_wrapped bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_write_mem_wrapped#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_write_mem_wrapped);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_write_mem_wrapped hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_write_mem_wrapped bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'write register linear support', 'reset': 1, 'width': 1, 'signal_name': 'write_reg_linear', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_write_reg_linear;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_write_reg_linear;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_write_reg_linear;
interface HW_reg_6_9_3_write_reg_linear hw;
interface SW_reg_6_9_3_write_reg_linear bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_write_reg_linear#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_write_reg_linear);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_write_reg_linear hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_write_reg_linear bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'write register wrapped support', 'reset': 0, 'width': 1, 'signal_name': 'write_reg_wrapped', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_write_reg_wrapped;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_write_reg_wrapped;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_write_reg_wrapped;
interface HW_reg_6_9_3_write_reg_wrapped hw;
interface SW_reg_6_9_3_write_reg_wrapped bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_write_reg_wrapped#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_write_reg_wrapped);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_write_reg_wrapped hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_write_reg_wrapped bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read memory linear support', 'reset': 1, 'width': 1, 'signal_name': 'read_mem_linear', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_read_mem_linear;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_read_mem_linear;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_read_mem_linear;
interface HW_reg_6_9_3_read_mem_linear hw;
interface SW_reg_6_9_3_read_mem_linear bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_read_mem_linear#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_read_mem_linear);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_read_mem_linear hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_read_mem_linear bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read memory wrapped support', 'reset': 0, 'width': 1, 'signal_name': 'read_mem_wrapped', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_read_mem_wrapped;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_read_mem_wrapped;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_read_mem_wrapped;
interface HW_reg_6_9_3_read_mem_wrapped hw;
interface SW_reg_6_9_3_read_mem_wrapped bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_read_mem_wrapped#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_read_mem_wrapped);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_read_mem_wrapped hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_read_mem_wrapped bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read register linear support', 'reset': 1, 'width': 1, 'signal_name': 'read_reg_linear', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_read_reg_linear;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_read_reg_linear;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_read_reg_linear;
interface HW_reg_6_9_3_read_reg_linear hw;
interface SW_reg_6_9_3_read_reg_linear bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_read_reg_linear#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_read_reg_linear);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_read_reg_linear hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_read_reg_linear bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read register wrapped support', 'reset': 0, 'width': 1, 'signal_name': 'read_reg_wrapped', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_read_reg_wrapped;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_read_reg_wrapped;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_read_reg_wrapped;
interface HW_reg_6_9_3_read_reg_wrapped hw;
interface SW_reg_6_9_3_read_reg_wrapped bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_read_reg_wrapped#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_read_reg_wrapped);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_read_reg_wrapped hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_read_reg_wrapped bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'xspi profile2 support', 'reset': 1, 'width': 1, 'signal_name': 'xspi_profile_2_support', 'reg_name': 'reg_6_9_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_9_3_xspi_profile_2_support;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_9_3_xspi_profile_2_support;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_3_xspi_profile_2_support;
interface HW_reg_6_9_3_xspi_profile_2_support hw;
interface SW_reg_6_9_3_xspi_profile_2_support bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_3_xspi_profile_2_support#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_3_xspi_profile_2_support);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_3_xspi_profile_2_support hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_3_xspi_profile_2_support bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '200Mhz num cfg bit pattern to set num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'cfg_bit_pattern_num_dymmy_cycl_required', 'reg_name': 'reg_6_9_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required;
interface HW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required hw;
interface SW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_4_cfg_bit_pattern_num_dymmy_cycl_required bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '200Mhz num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'num_dymmy_cycl_required', 'reg_name': 'reg_6_9_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_4_num_dymmy_cycl_required;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_4_num_dymmy_cycl_required;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_4_num_dymmy_cycl_required;
interface HW_reg_6_9_4_num_dymmy_cycl_required hw;
interface SW_reg_6_9_4_num_dymmy_cycl_required bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_4_num_dymmy_cycl_required#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_4_num_dymmy_cycl_required);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_4_num_dymmy_cycl_required hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_4_num_dymmy_cycl_required bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '100Mhz num cfg bit pattern to set num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'cfg_bit_pattern_num_dymmy_cycl_required_100', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 hw;
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_100 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '100Mhz num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'num_dymmy_cycl_required_100', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_num_dymmy_cycl_required_100;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_num_dymmy_cycl_required_100;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_100;
interface HW_reg_6_9_5_num_dymmy_cycl_required_100 hw;
interface SW_reg_6_9_5_num_dymmy_cycl_required_100 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_100#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_100);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_num_dymmy_cycl_required_100 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_num_dymmy_cycl_required_100 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '133Mhz num cfg bit pattern to set num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'cfg_bit_pattern_num_dymmy_cycl_required_133', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 hw;
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_133 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '133Mhz num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'num_dymmy_cycl_required_133', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_num_dymmy_cycl_required_133;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_num_dymmy_cycl_required_133;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_133;
interface HW_reg_6_9_5_num_dymmy_cycl_required_133 hw;
interface SW_reg_6_9_5_num_dymmy_cycl_required_133 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_133#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_133);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_num_dymmy_cycl_required_133 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_num_dymmy_cycl_required_133 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '166Mhz num cfg bit pattern to set num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'cfg_bit_pattern_num_dymmy_cycl_required_166', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166;
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 hw;
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_cfg_bit_pattern_num_dymmy_cycl_required_166 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': '166Mhz num dummy cycl required TBD', 'reset': 2, 'width': 5, 'signal_name': 'num_dymmy_cycl_required_166', 'reg_name': 'reg_6_9_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_9_5_num_dymmy_cycl_required_166;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_9_5_num_dymmy_cycl_required_166;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_166;
interface HW_reg_6_9_5_num_dymmy_cycl_required_166 hw;
interface SW_reg_6_9_5_num_dymmy_cycl_required_166 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_9_5_num_dymmy_cycl_required_166#(Integer resetValue)(Ifc_CSRSignal_reg_6_9_5_num_dymmy_cycl_required_166);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_9_5_num_dymmy_cycl_required_166 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_9_5_num_dymmy_cycl_required_166 bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address offset for volatile registers TBD', 'reset': 0, 'width': 32, 'signal_name': 'volatile_address', 'reg_name': 'reg_6_10_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_3_volatile_address;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_3_volatile_address;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_3_volatile_address;
interface HW_reg_6_10_3_volatile_address hw;
interface SW_reg_6_10_3_volatile_address bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_3_volatile_address#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_3_volatile_address);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_3_volatile_address hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_3_volatile_address bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address offset for non-volatile registers not supported', 'reset': 0, 'width': 32, 'signal_name': 'nonvolatile_address', 'reg_name': 'reg_6_10_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_4_nonvolatile_address;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_4_nonvolatile_address;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_4_nonvolatile_address;
interface HW_reg_6_10_4_nonvolatile_address hw;
interface SW_reg_6_10_4_nonvolatile_address bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_4_nonvolatile_address#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_4_nonvolatile_address);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_4_nonvolatile_address hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_4_nonvolatile_address bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 8d-8d-8d mode', 'reset': 0, 'width': 4, 'signal_name': 'num_dummy_cycles_8d8d8d', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_10_5_num_dummy_cycles_8d8d8d;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_8d8d8d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8d8d8d;
interface HW_reg_6_10_5_num_dummy_cycles_8d8d8d hw;
interface SW_reg_6_10_5_num_dummy_cycles_8d8d8d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_8d8d8d#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8d8d8d);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_8d8d8d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_8d8d8d bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 8s-8s-8s mode', 'reset': 0, 'width': 4, 'signal_name': 'num_dummy_cycles_8s8s8s', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_10_5_num_dummy_cycles_8s8s8s;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_8s8s8s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8s8s8s;
interface HW_reg_6_10_5_num_dummy_cycles_8s8s8s hw;
interface SW_reg_6_10_5_num_dummy_cycles_8s8s8s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_8s8s8s#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_8s8s8s);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_8s8s8s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_8s8s8s bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 4d-4d-4d mode', 'reset': 0, 'width': 4, 'signal_name': 'num_dummy_cycles_4d4d4d', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_10_5_num_dummy_cycles_4d4d4d;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_4d4d4d;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4d4d4d;
interface HW_reg_6_10_5_num_dummy_cycles_4d4d4d hw;
interface SW_reg_6_10_5_num_dummy_cycles_4d4d4d bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_4d4d4d#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4d4d4d);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_4d4d4d hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_4d4d4d bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 4s-4s-4s mode', 'reset': 0, 'width': 4, 'signal_name': 'num_dummy_cycles_4s4s4s', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_10_5_num_dummy_cycles_4s4s4s;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_4s4s4s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4s4s4s;
interface HW_reg_6_10_5_num_dummy_cycles_4s4s4s hw;
interface SW_reg_6_10_5_num_dummy_cycles_4s4s4s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_4s4s4s#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_4s4s4s);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_4s4s4s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_4s4s4s bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 2s-2s-2s mode', 'reset': 15, 'width': 4, 'signal_name': 'num_dummy_cycles_2s2s2s', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_10_5_num_dummy_cycles_2s2s2s;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_2s2s2s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_2s2s2s;
interface HW_reg_6_10_5_num_dummy_cycles_2s2s2s hw;
interface SW_reg_6_10_5_num_dummy_cycles_2s2s2s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_2s2s2s#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_2s2s2s);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_2s2s2s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_2s2s2s bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number of dummy cycles for read in 1s-1s-1s mode', 'reset': 0, 'width': 2, 'signal_name': 'num_dummy_cycles_1s1s1s', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_10_5_num_dummy_cycles_1s1s1s;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_10_5_num_dummy_cycles_1s1s1s;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_1s1s1s;
interface HW_reg_6_10_5_num_dummy_cycles_1s1s1s hw;
interface SW_reg_6_10_5_num_dummy_cycles_1s1s1s bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_dummy_cycles_1s1s1s#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_dummy_cycles_1s1s1s);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_dummy_cycles_1s1s1s hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_dummy_cycles_1s1s1s bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Number address bytes(32bit)', 'reset': 3, 'width': 2, 'signal_name': 'num_addr_bytes', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_10_5_num_addr_bytes;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_10_5_num_addr_bytes;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_num_addr_bytes;
interface HW_reg_6_10_5_num_addr_bytes hw;
interface SW_reg_6_10_5_num_addr_bytes bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_num_addr_bytes#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_num_addr_bytes);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_num_addr_bytes hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_num_addr_bytes bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Generic Addressable Write Status/Control register command for volatile registers supported', 'reset': 1, 'width': 1, 'signal_name': 'gen_reg_write_supported', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_5_gen_reg_write_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_5_gen_reg_write_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_gen_reg_write_supported;
interface HW_reg_6_10_5_gen_reg_write_supported hw;
interface SW_reg_6_10_5_gen_reg_write_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_gen_reg_write_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_gen_reg_write_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_gen_reg_write_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_gen_reg_write_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Generic Addressable Read Status/Control register command for volatile registers supported', 'reset': 1, 'width': 1, 'signal_name': 'gen_reg_read_supported', 'reg_name': 'reg_6_10_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_5_gen_reg_read_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_5_gen_reg_read_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_5_gen_reg_read_supported;
interface HW_reg_6_10_5_gen_reg_read_supported hw;
interface SW_reg_6_10_5_gen_reg_read_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_5_gen_reg_read_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_5_gen_reg_read_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_5_gen_reg_read_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_5_gen_reg_read_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'No Non volatile registers', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_6_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_6_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_6_reserved;
interface HW_reg_6_10_6_reserved hw;
interface SW_reg_6_10_6_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_6_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_6_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_6_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_6_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'No Write in progress bit TBD', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_7', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_7_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_7_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_7_reserved;
interface HW_reg_6_10_7_reserved hw;
interface SW_reg_6_10_7_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_7_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_7_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_7_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_7_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'No Write enable bit TBD', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_8', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_8_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_8_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_8_reserved;
interface HW_reg_6_10_8_reserved hw;
interface SW_reg_6_10_8_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_8_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_8_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_8_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_8_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'No program Error bit', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_9', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_9_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_9_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_9_reserved;
interface HW_reg_6_10_9_reserved hw;
interface SW_reg_6_10_9_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_9_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_9_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_9_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_9_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'No Erase Error bit', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_10_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_10_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_10_reserved;
interface HW_reg_6_10_10_reserved hw;
interface SW_reg_6_10_10_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_10_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_10_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_10_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_10_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable dummy cycles not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_11', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_11_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_11_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_11_reserved;
interface HW_reg_6_10_11_reserved hw;
interface SW_reg_6_10_11_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_11_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_11_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_11_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_11_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable dummy cycles (nvreg)not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_12', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_12_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_12_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_12_reserved;
interface HW_reg_6_10_12_reserved hw;
interface SW_reg_6_10_12_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_12_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_12_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_12_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_12_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable dummy cycles not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_13_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_13_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_13_reserved;
interface HW_reg_6_10_13_reserved hw;
interface SW_reg_6_10_13_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_13_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_13_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_13_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_13_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable dummy cycles not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_14', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_14_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_14_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_14_reserved;
interface HW_reg_6_10_14_reserved hw;
interface SW_reg_6_10_14_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_14_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_14_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_14_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_14_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable dummy cycles not supported', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_15', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_15_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_15_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_15_reserved;
interface HW_reg_6_10_15_reserved hw;
interface SW_reg_6_10_15_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_15_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_15_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_15_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_15_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'QPI mode not supported TBD', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_16', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_16_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_16_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_16_reserved;
interface HW_reg_6_10_16_reserved hw;
interface SW_reg_6_10_16_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_16_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_16_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_16_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_16_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'QPI mode not supported TBD', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_17', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_17_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_17_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_17_reserved;
interface HW_reg_6_10_17_reserved hw;
interface SW_reg_6_10_17_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_17_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_17_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_17_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_17_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_18_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_18_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_reg_offset;
interface HW_reg_6_10_18_reg_offset hw;
interface SW_reg_6_10_18_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_18_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_18_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_bit_loc;
interface HW_reg_6_10_18_bit_loc hw;
interface SW_reg_6_10_18_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_18_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_18_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_local_addr_in_last_byte;
interface HW_reg_6_10_18_local_addr_in_last_byte hw;
interface SW_reg_6_10_18_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_18_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_18_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_addressable;
interface HW_reg_6_10_18_addressable hw;
interface SW_reg_6_10_18_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Octal mode Enable polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_18_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_18_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_polarity;
interface HW_reg_6_10_18_polarity hw;
interface SW_reg_6_10_18_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'STR/DDR Octal mode Enable Volatile', 'reset': 1, 'width': 1, 'signal_name': 'octal_mode_enable', 'reg_name': 'reg_6_10_18', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_18_octal_mode_enable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_18_octal_mode_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_18_octal_mode_enable;
interface HW_reg_6_10_18_octal_mode_enable hw;
interface SW_reg_6_10_18_octal_mode_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_18_octal_mode_enable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_18_octal_mode_enable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_18_octal_mode_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_18_octal_mode_enable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Octal mode Enable non Volatile (not supported)', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_19', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_19_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_19_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_19_reserved;
interface HW_reg_6_10_19_reserved hw;
interface SW_reg_6_10_19_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_19_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_19_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_19_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_19_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_20_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_20_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_reg_offset;
interface HW_reg_6_10_20_reg_offset hw;
interface SW_reg_6_10_20_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_20_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_20_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_bit_loc;
interface HW_reg_6_10_20_bit_loc hw;
interface SW_reg_6_10_20_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_20_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_20_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_local_addr_in_last_byte;
interface HW_reg_6_10_20_local_addr_in_last_byte hw;
interface SW_reg_6_10_20_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_20_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_20_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_addressable;
interface HW_reg_6_10_20_addressable hw;
interface SW_reg_6_10_20_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_20_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_20_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_polarity;
interface HW_reg_6_10_20_polarity hw;
interface SW_reg_6_10_20_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SDR/DDR mode select volatile (supported)', 'reset': 1, 'width': 1, 'signal_name': 'ddr_mode_select_available', 'reg_name': 'reg_6_10_20', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_20_ddr_mode_select_available;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_20_ddr_mode_select_available;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_20_ddr_mode_select_available;
interface HW_reg_6_10_20_ddr_mode_select_available hw;
interface SW_reg_6_10_20_ddr_mode_select_available bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_20_ddr_mode_select_available#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_20_ddr_mode_select_available);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_20_ddr_mode_select_available hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_20_ddr_mode_select_available bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SDR/DDR non Volatile (not supported)', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_21', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_21_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_21_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_21_reserved;
interface HW_reg_6_10_21_reserved hw;
interface SW_reg_6_10_21_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_21_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_21_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_21_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_21_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_22_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_22_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_reg_offset;
interface HW_reg_6_10_22_reg_offset hw;
interface SW_reg_6_10_22_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_22_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_22_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_bit_loc;
interface HW_reg_6_10_22_bit_loc hw;
interface SW_reg_6_10_22_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_22_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_22_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_local_addr_in_last_byte;
interface HW_reg_6_10_22_local_addr_in_last_byte hw;
interface SW_reg_6_10_22_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_22_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_22_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_addressable;
interface HW_reg_6_10_22_addressable hw;
interface SW_reg_6_10_22_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Octal mode Enable polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_22_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_22_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_polarity;
interface HW_reg_6_10_22_polarity hw;
interface SW_reg_6_10_22_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'STR Octal mode Enable Volatile Dup of 6_10_18? TBD', 'reset': 1, 'width': 1, 'signal_name': 'octal_mode_enable', 'reg_name': 'reg_6_10_22', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_22_octal_mode_enable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_22_octal_mode_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_22_octal_mode_enable;
interface HW_reg_6_10_22_octal_mode_enable hw;
interface SW_reg_6_10_22_octal_mode_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_22_octal_mode_enable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_22_octal_mode_enable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_22_octal_mode_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_22_octal_mode_enable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SDR/DDR non Volatile (not supported)', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_23', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_23_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_23_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_23_reserved;
interface HW_reg_6_10_23_reserved hw;
interface SW_reg_6_10_23_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_23_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_23_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_23_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_23_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_24_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_24_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_reg_offset;
interface HW_reg_6_10_24_reg_offset hw;
interface SW_reg_6_10_24_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_24_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_24_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_bit_loc;
interface HW_reg_6_10_24_bit_loc hw;
interface SW_reg_6_10_24_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_24_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_24_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_local_addr_in_last_byte;
interface HW_reg_6_10_24_local_addr_in_last_byte hw;
interface SW_reg_6_10_24_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_24_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_24_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_addressable;
interface HW_reg_6_10_24_addressable hw;
interface SW_reg_6_10_24_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Octal mode Enable polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_24_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_24_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_polarity;
interface HW_reg_6_10_24_polarity hw;
interface SW_reg_6_10_24_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'DTR Octal mode Enable Volatile Dup of 6_10_18? TBD', 'reset': 1, 'width': 1, 'signal_name': 'octal_mode_enable', 'reg_name': 'reg_6_10_24', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_24_octal_mode_enable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_24_octal_mode_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_24_octal_mode_enable;
interface HW_reg_6_10_24_octal_mode_enable hw;
interface SW_reg_6_10_24_octal_mode_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_24_octal_mode_enable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_24_octal_mode_enable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_24_octal_mode_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_24_octal_mode_enable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SDR/DDR non Volatile (not supported)', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_25', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_25_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_25_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_25_reserved;
interface HW_reg_6_10_25_reserved hw;
interface SW_reg_6_10_25_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_25_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_25_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_25_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_25_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_26_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_26_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_reg_offset;
interface HW_reg_6_10_26_reg_offset hw;
interface SW_reg_6_10_26_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_26_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_26_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_bit_loc;
interface HW_reg_6_10_26_bit_loc hw;
interface SW_reg_6_10_26_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_26_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_26_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_local_addr_in_last_byte;
interface HW_reg_6_10_26_local_addr_in_last_byte hw;
interface SW_reg_6_10_26_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_26_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_26_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_addressable;
interface HW_reg_6_10_26_addressable hw;
interface SW_reg_6_10_26_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_26_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_26_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_polarity;
interface HW_reg_6_10_26_polarity hw;
interface SW_reg_6_10_26_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Deep power down select volatile (supported)', 'reset': 1, 'width': 1, 'signal_name': 'ddr_mode_select_available', 'reg_name': 'reg_6_10_26', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_26_ddr_mode_select_available;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_26_ddr_mode_select_available;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_26_ddr_mode_select_available;
interface HW_reg_6_10_26_ddr_mode_select_available hw;
interface SW_reg_6_10_26_ddr_mode_select_available bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_26_ddr_mode_select_available#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_26_ddr_mode_select_available);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_26_ddr_mode_select_available hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_26_ddr_mode_select_available bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_27_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_27_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_reg_offset;
interface HW_reg_6_10_27_reg_offset hw;
interface SW_reg_6_10_27_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_27_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_27_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_bit_loc;
interface HW_reg_6_10_27_bit_loc hw;
interface SW_reg_6_10_27_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_27_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_27_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_local_addr_in_last_byte;
interface HW_reg_6_10_27_local_addr_in_last_byte hw;
interface SW_reg_6_10_27_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_27_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_27_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_addressable;
interface HW_reg_6_10_27_addressable hw;
interface SW_reg_6_10_27_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'polarity', 'reset': 0, 'width': 1, 'signal_name': 'polarity', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_27_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_27_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_polarity;
interface HW_reg_6_10_27_polarity hw;
interface SW_reg_6_10_27_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Ultra Deep power down select volatile (supported)', 'reset': 1, 'width': 1, 'signal_name': 'ddr_mode_select_available', 'reg_name': 'reg_6_10_27', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_27_ddr_mode_select_available;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_27_ddr_mode_select_available;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_27_ddr_mode_select_available;
interface HW_reg_6_10_27_ddr_mode_select_available hw;
interface SW_reg_6_10_27_ddr_mode_select_available bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_27_ddr_mode_select_available#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_27_ddr_mode_select_available);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_27_ddr_mode_select_available hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_27_ddr_mode_select_available bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reg Offset', 'reset': 0, 'width': 8, 'signal_name': 'reg_offset', 'reg_name': 'reg_6_10_28', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_10_28_reg_offset;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_10_28_reg_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_28_reg_offset;
interface HW_reg_6_10_28_reg_offset hw;
interface SW_reg_6_10_28_reg_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_28_reg_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_28_reg_offset);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_28_reg_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_28_reg_offset bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location in reg (TBD)', 'reset': 0, 'width': 3, 'signal_name': 'bit_loc', 'reg_name': 'reg_6_10_28', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_10_28_bit_loc;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_10_28_bit_loc;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_28_bit_loc;
interface HW_reg_6_10_28_bit_loc hw;
interface SW_reg_6_10_28_bit_loc bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_28_bit_loc#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_28_bit_loc);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_28_bit_loc hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_28_bit_loc bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'local address in last byte of address(yes)', 'reset': 0, 'width': 1, 'signal_name': 'local_addr_in_last_byte', 'reg_name': 'reg_6_10_28', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_28_local_addr_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_28_local_addr_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_28_local_addr_in_last_byte;
interface HW_reg_6_10_28_local_addr_in_last_byte hw;
interface SW_reg_6_10_28_local_addr_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_28_local_addr_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_28_local_addr_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_28_local_addr_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_28_local_addr_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit is addressable', 'reset': 1, 'width': 1, 'signal_name': 'addressable', 'reg_name': 'reg_6_10_28', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_10_28_addressable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_10_28_addressable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_28_addressable;
interface HW_reg_6_10_28_addressable hw;
interface SW_reg_6_10_28_addressable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_28_addressable#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_28_addressable);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_28_addressable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_28_addressable bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Output drive strength numbits(supported)', 'reset': 3, 'width': 2, 'signal_name': 'num_bits', 'reg_name': 'reg_6_10_28', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_10_28_num_bits;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_10_28_num_bits;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_28_num_bits;
interface HW_reg_6_10_28_num_bits hw;
interface SW_reg_6_10_28_num_bits bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_28_num_bits#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_28_num_bits);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_28_num_bits hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_28_num_bits bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'non Volatile (not supported)', 'reset': 0, 'width': 32, 'signal_name': 'reserved', 'reg_name': 'reg_6_10_29', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_10_29_reserved;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_10_29_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_10_29_reserved;
interface HW_reg_6_10_29_reserved hw;
interface SW_reg_6_10_29_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_10_29_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_10_29_reserved);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_10_29_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_10_29_reserved bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Volatile reg offset TBD', 'reset': 0, 'width': 32, 'signal_name': 'offset', 'reg_name': 'reg_6_11_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_11_3_offset;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_11_3_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_3_offset;
interface HW_reg_6_11_3_offset hw;
interface SW_reg_6_11_3_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_3_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_3_offset);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_3_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_3_offset bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'non Volatile reg offset TBD', 'reset': 0, 'width': 32, 'signal_name': 'offset', 'reg_name': 'reg_6_11_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_11_4_offset;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_11_4_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_4_offset;
interface HW_reg_6_11_4_offset hw;
interface SW_reg_6_11_4_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_4_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_4_offset);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_4_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_4_offset bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 3, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_11_5_reserved;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_11_5_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_reserved;
interface HW_reg_6_11_5_reserved hw;
interface SW_reg_6_11_5_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_reserved);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_reserved bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address of WIP Bit(not supported)', 'reset': 0, 'width': 8, 'signal_name': 'wip_address', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_11_5_wip_address;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_11_5_wip_address;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_wip_address;
interface HW_reg_6_11_5_wip_address hw;
interface SW_reg_6_11_5_wip_address bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_wip_address#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_wip_address);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_wip_address hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_wip_address bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location of WIP Bit(not supported)', 'reset': 0, 'width': 4, 'signal_name': 'wip_bit_location', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_11_5_wip_bit_location;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_11_5_wip_bit_location;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_wip_bit_location;
interface HW_reg_6_11_5_wip_bit_location hw;
interface SW_reg_6_11_5_wip_bit_location bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_wip_bit_location#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_wip_bit_location);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_wip_bit_location hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_wip_bit_location bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Local address of WIP Bit(not supported)', 'reset': 0, 'width': 1, 'signal_name': 'wip_address_byte_location', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_5_wip_address_byte_location;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_5_wip_address_byte_location;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_wip_address_byte_location;
interface HW_reg_6_11_5_wip_address_byte_location hw;
interface SW_reg_6_11_5_wip_address_byte_location bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_wip_address_byte_location#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_wip_address_byte_location);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_wip_address_byte_location hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_wip_address_byte_location bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'WIP Polarity(not supported)', 'reset': 0, 'width': 1, 'signal_name': 'wip_polarity', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_5_wip_polarity;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_5_wip_polarity;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_wip_polarity;
interface HW_reg_6_11_5_wip_polarity hw;
interface SW_reg_6_11_5_wip_polarity bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_wip_polarity#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_wip_polarity);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_wip_polarity hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_wip_polarity bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'WIP (Device busy bit) (not supported)', 'reset': 0, 'width': 1, 'signal_name': 'wip_supported', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_5_wip_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_5_wip_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_wip_supported;
interface HW_reg_6_11_5_wip_supported hw;
interface SW_reg_6_11_5_wip_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_wip_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_wip_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_wip_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_wip_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles for non-volatile reg read TBD', 'reset': 0, 'width': 5, 'signal_name': 'dummy_cycles_non_volative', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_11_5_dummy_cycles_non_volative;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_11_5_dummy_cycles_non_volative;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_dummy_cycles_non_volative;
interface HW_reg_6_11_5_dummy_cycles_non_volative hw;
interface SW_reg_6_11_5_dummy_cycles_non_volative bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_dummy_cycles_non_volative#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_dummy_cycles_non_volative);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_dummy_cycles_non_volative hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_dummy_cycles_non_volative bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles for volatile reg read TBD', 'reset': 0, 'width': 5, 'signal_name': 'dummy_cycles_volative', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_11_5_dummy_cycles_volative;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_11_5_dummy_cycles_volative;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_dummy_cycles_volative;
interface HW_reg_6_11_5_dummy_cycles_volative hw;
interface SW_reg_6_11_5_dummy_cycles_volative bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_dummy_cycles_volative#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_dummy_cycles_volative);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_dummy_cycles_volative hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_dummy_cycles_volative bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address Bytes(6 bytes)', 'reset': 0, 'width': 2, 'signal_name': 'address_bytes', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_11_5_address_bytes;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_11_5_address_bytes;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_address_bytes;
interface HW_reg_6_11_5_address_bytes hw;
interface SW_reg_6_11_5_address_bytes bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_address_bytes#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_address_bytes);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_address_bytes hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_address_bytes bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Generic addressable write ctrl/sts registers(yes)', 'reset': 1, 'width': 1, 'signal_name': 'write_ctrl_sts', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_5_write_ctrl_sts;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_5_write_ctrl_sts;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_write_ctrl_sts;
interface HW_reg_6_11_5_write_ctrl_sts hw;
interface SW_reg_6_11_5_write_ctrl_sts bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_write_ctrl_sts#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_write_ctrl_sts);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_write_ctrl_sts hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_write_ctrl_sts bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Generic addressable read ctrl/sts registers(yes)', 'reset': 1, 'width': 1, 'signal_name': 'read_ctrl_sts', 'reg_name': 'reg_6_11_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_5_read_ctrl_sts;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_5_read_ctrl_sts;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_5_read_ctrl_sts;
interface HW_reg_6_11_5_read_ctrl_sts hw;
interface SW_reg_6_11_5_read_ctrl_sts bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_5_read_ctrl_sts#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_5_read_ctrl_sts);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_5_read_ctrl_sts hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_5_read_ctrl_sts bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Program Error (Not Implemented)', 'reset': 0, 'width': 32, 'signal_name': 'p_error', 'reg_name': 'reg_6_11_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_11_6_p_error;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_11_6_p_error;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_6_p_error;
interface HW_reg_6_11_6_p_error hw;
interface SW_reg_6_11_6_p_error bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_6_p_error#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_6_p_error);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_6_p_error hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_6_p_error bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Erase Error (Not Implemented)', 'reset': 0, 'width': 32, 'signal_name': 'e_error', 'reg_name': 'reg_6_11_7', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//32
interface SW_reg_6_11_7_e_error;


method ActionValue#(Bit#(32)) read ();

endinterface

interface HW_reg_6_11_7_e_error;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_7_e_error;
interface HW_reg_6_11_7_e_error hw;
interface SW_reg_6_11_7_e_error bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_7_e_error#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_7_e_error);

	Reg#(Bit#(32)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(32),Bit#(32)))sw_wdata <-mkRWire();
RWire#(Bit#(32))hw_wdata <-mkRWire();
RWire#(Bit#(32))r_incr <-mkRWire();
RWire#(Bit#(32))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_7_e_error hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_7_e_error bus;


method ActionValue#(Bit#(32)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 31, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_8', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//31
interface SW_reg_6_11_8_reserved;


method ActionValue#(Bit#(31)) read ();

endinterface

interface HW_reg_6_11_8_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_8_reserved;
interface HW_reg_6_11_8_reserved hw;
interface SW_reg_6_11_8_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_8_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_8_reserved);

	Reg#(Bit#(31)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(31),Bit#(31)))sw_wdata <-mkRWire();
RWire#(Bit#(31))hw_wdata <-mkRWire();
RWire#(Bit#(31))r_incr <-mkRWire();
RWire#(Bit#(31))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_8_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_8_reserved bus;


method ActionValue#(Bit#(31)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable number of dummy cycles volatile reg(Not Supported)', 'reset': 0, 'width': 1, 'signal_name': 'supported', 'reg_name': 'reg_6_11_8', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_8_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_8_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_8_supported;
interface HW_reg_6_11_8_supported hw;
interface SW_reg_6_11_8_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_8_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_8_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_8_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_8_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 31, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_9', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//31
interface SW_reg_6_11_9_reserved;


method ActionValue#(Bit#(31)) read ();

endinterface

interface HW_reg_6_11_9_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_9_reserved;
interface HW_reg_6_11_9_reserved hw;
interface SW_reg_6_11_9_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_9_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_9_reserved);

	Reg#(Bit#(31)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(31),Bit#(31)))sw_wdata <-mkRWire();
RWire#(Bit#(31))hw_wdata <-mkRWire();
RWire#(Bit#(31))r_incr <-mkRWire();
RWire#(Bit#(31))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_9_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_9_reserved bus;


method ActionValue#(Bit#(31)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable number of dummy cycles non-volatile reg(Not Supported)', 'reset': 0, 'width': 1, 'signal_name': 'supported', 'reg_name': 'reg_6_11_9', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_9_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_9_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_9_supported;
interface HW_reg_6_11_9_supported hw;
interface SW_reg_6_11_9_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_9_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_9_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_9_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_9_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 31, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//31
interface SW_reg_6_11_10_reserved;


method ActionValue#(Bit#(31)) read ();

endinterface

interface HW_reg_6_11_10_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_10_reserved;
interface HW_reg_6_11_10_reserved hw;
interface SW_reg_6_11_10_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_10_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_10_reserved);

	Reg#(Bit#(31)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(31),Bit#(31)))sw_wdata <-mkRWire();
RWire#(Bit#(31))hw_wdata <-mkRWire();
RWire#(Bit#(31))r_incr <-mkRWire();
RWire#(Bit#(31))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_10_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_10_reserved bus;


method ActionValue#(Bit#(31)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable number of dummy cycles Bit pattern(Not Supported)', 'reset': 0, 'width': 1, 'signal_name': 'supported', 'reg_name': 'reg_6_11_10', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_10_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_10_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_10_supported;
interface HW_reg_6_11_10_supported hw;
interface SW_reg_6_11_10_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_10_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_10_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_10_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_10_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 31, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_11', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//31
interface SW_reg_6_11_11_reserved;


method ActionValue#(Bit#(31)) read ();

endinterface

interface HW_reg_6_11_11_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_11_reserved;
interface HW_reg_6_11_11_reserved hw;
interface SW_reg_6_11_11_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_11_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_11_reserved);

	Reg#(Bit#(31)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(31),Bit#(31)))sw_wdata <-mkRWire();
RWire#(Bit#(31))hw_wdata <-mkRWire();
RWire#(Bit#(31))r_incr <-mkRWire();
RWire#(Bit#(31))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_11_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_11_reserved bus;


method ActionValue#(Bit#(31)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable number of dummy cycles Bit pattern(Not Supported)', 'reset': 0, 'width': 1, 'signal_name': 'supported', 'reg_name': 'reg_6_11_11', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_11_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_11_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_11_supported;
interface HW_reg_6_11_11_supported hw;
interface SW_reg_6_11_11_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_11_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_11_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_11_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_11_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Reserved', 'reset': 0, 'width': 31, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_12', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//31
interface SW_reg_6_11_12_reserved;


method ActionValue#(Bit#(31)) read ();

endinterface

interface HW_reg_6_11_12_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_12_reserved;
interface HW_reg_6_11_12_reserved hw;
interface SW_reg_6_11_12_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_12_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_12_reserved);

	Reg#(Bit#(31)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(31),Bit#(31)))sw_wdata <-mkRWire();
RWire#(Bit#(31))hw_wdata <-mkRWire();
RWire#(Bit#(31))r_incr <-mkRWire();
RWire#(Bit#(31))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_12_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_12_reserved bus;


method ActionValue#(Bit#(31)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Variable number of dummy cycles Bit pattern(Not Supported)', 'reset': 0, 'width': 1, 'signal_name': 'supported', 'reg_name': 'reg_6_11_12', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_12_supported;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_12_supported;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_12_supported;
interface HW_reg_6_11_12_supported hw;
interface SW_reg_6_11_12_supported bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_12_supported#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_12_supported);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_12_supported hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_12_supported bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address of register TBD (typo in spec?)', 'reset': 0, 'width': 8, 'signal_name': 'addr', 'reg_name': 'reg_6_11_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_11_13_addr;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_11_13_addr;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_13_addr;
interface HW_reg_6_11_13_addr hw;
interface SW_reg_6_11_13_addr bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_13_addr#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_13_addr);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_13_addr hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_13_addr bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Bit location of MSB Bit TBD', 'reset': 0, 'width': 4, 'signal_name': 'msb_bit_location', 'reg_name': 'reg_6_11_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_11_13_msb_bit_location;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_11_13_msb_bit_location;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_13_msb_bit_location;
interface HW_reg_6_11_13_msb_bit_location hw;
interface SW_reg_6_11_13_msb_bit_location bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_13_msb_bit_location#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_13_msb_bit_location);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_13_msb_bit_location hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_13_msb_bit_location bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'addr in last_byte TBD', 'reset': 0, 'width': 1, 'signal_name': 'addr_not_in_last_byte', 'reg_name': 'reg_6_11_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_13_addr_not_in_last_byte;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_13_addr_not_in_last_byte;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_13_addr_not_in_last_byte;
interface HW_reg_6_11_13_addr_not_in_last_byte hw;
interface SW_reg_6_11_13_addr_not_in_last_byte bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_13_addr_not_in_last_byte#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_13_addr_not_in_last_byte);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_13_addr_not_in_last_byte hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_13_addr_not_in_last_byte bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'output drive strength num_bits (volatile)', 'reset': 3, 'width': 2, 'signal_name': 'drive_strength_num_bits', 'reg_name': 'reg_6_11_13', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//2
interface SW_reg_6_11_13_drive_strength_num_bits;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_reg_6_11_13_drive_strength_num_bits;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_13_drive_strength_num_bits;
interface HW_reg_6_11_13_drive_strength_num_bits hw;
interface SW_reg_6_11_13_drive_strength_num_bits bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_13_drive_strength_num_bits#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_13_drive_strength_num_bits);

	Reg#(Bit#(2)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(2),Bit#(2)))sw_wdata <-mkRWire();
RWire#(Bit#(2))hw_wdata <-mkRWire();
RWire#(Bit#(2))r_incr <-mkRWire();
RWire#(Bit#(2))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_13_drive_strength_num_bits hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_13_drive_strength_num_bits bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'output drive strength nv (not implemented)', 'reset': 0, 'width': 1, 'signal_name': 'reserved', 'reg_name': 'reg_6_11_14', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_14_reserved;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_14_reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_14_reserved;
interface HW_reg_6_11_14_reserved hw;
interface SW_reg_6_11_14_reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_14_reserved#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_14_reserved);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_14_reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_14_reserved bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'output drive strength bit pattern TBD', 'reset': 0, 'width': 1, 'signal_name': 'tbd', 'reg_name': 'reg_6_11_15', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_11_15_tbd;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_11_15_tbd;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_11_15_tbd;
interface HW_reg_6_11_15_tbd hw;
interface SW_reg_6_11_15_tbd bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_11_15_tbd#(Integer resetValue)(Ifc_CSRSignal_reg_6_11_15_tbd);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_11_15_tbd hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_11_15_tbd bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Gram SPI Mode TBD', 'reset': 1, 'width': 1, 'signal_name': 'gram_spi', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_17_3_gram_spi;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_17_3_gram_spi;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_gram_spi;
interface HW_reg_6_17_3_gram_spi hw;
interface SW_reg_6_17_3_gram_spi bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_gram_spi#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_gram_spi);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_gram_spi hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_gram_spi bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Address Shift TBD', 'reset': 0, 'width': 1, 'signal_name': 'address_shift', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//1
interface SW_reg_6_17_3_address_shift;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_reg_6_17_3_address_shift;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_address_shift;
interface HW_reg_6_17_3_address_shift hw;
interface SW_reg_6_17_3_address_shift bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_address_shift#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_address_shift);

	Reg#(Bit#(1)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(1),Bit#(1)))sw_wdata <-mkRWire();
RWire#(Bit#(1))hw_wdata <-mkRWire();
RWire#(Bit#(1))r_incr <-mkRWire();
RWire#(Bit#(1))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_address_shift hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_address_shift bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Multi-Die Addressformat TBD', 'reset': 4, 'width': 4, 'signal_name': 'md_address_format', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_3_md_address_format;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_3_md_address_format;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_md_address_format;
interface HW_reg_6_17_3_md_address_format hw;
interface SW_reg_6_17_3_md_address_format bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_md_address_format#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_md_address_format);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_md_address_format hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_md_address_format bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Multi-Die Addressable reg read access TBD', 'reset': 0, 'width': 4, 'signal_name': 'md_address_write_access', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_3_md_address_write_access;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_3_md_address_write_access;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_md_address_write_access;
interface HW_reg_6_17_3_md_address_write_access hw;
interface SW_reg_6_17_3_md_address_write_access bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_md_address_write_access#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_md_address_write_access);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_md_address_write_access hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_md_address_write_access bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Multi-Die Addressable reg read access TBD', 'reset': 0, 'width': 4, 'signal_name': 'md_address_read_access', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_3_md_address_read_access;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_3_md_address_read_access;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_md_address_read_access;
interface HW_reg_6_17_3_md_address_read_access hw;
interface SW_reg_6_17_3_md_address_read_access bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_md_address_read_access#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_md_address_read_access);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_md_address_read_access hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_md_address_read_access bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Active-Die Selection for Multi Die Package TBD', 'reset': 0, 'width': 4, 'signal_name': 'md_active_die', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_3_md_active_die;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_3_md_active_die;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_md_active_die;
interface HW_reg_6_17_3_md_active_die hw;
interface SW_reg_6_17_3_md_active_die bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_md_active_die#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_md_active_die);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_md_active_die hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_md_active_die bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Multi-Die Address offset for Addressable Register TBD', 'reset': 0, 'width': 4, 'signal_name': 'md_address_offset', 'reg_name': 'reg_6_17_3', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_3_md_address_offset;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_3_md_address_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_3_md_address_offset;
interface HW_reg_6_17_3_md_address_offset hw;
interface SW_reg_6_17_3_md_address_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_3_md_address_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_3_md_address_offset);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_3_md_address_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_3_md_address_offset bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write Opcode', 'reset': 113, 'width': 8, 'signal_name': 'write_opcode', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_4_write_opcode;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_4_write_opcode;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_write_opcode;
interface HW_reg_6_17_4_write_opcode hw;
interface SW_reg_6_17_4_write_opcode bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_write_opcode#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_write_opcode);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_write_opcode hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_write_opcode bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read Opcode', 'reset': 101, 'width': 8, 'signal_name': 'read_opcode', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_4_read_opcode;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_4_read_opcode;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_read_opcode;
interface HW_reg_6_17_4_read_opcode hw;
interface SW_reg_6_17_4_read_opcode bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_read_opcode#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_read_opcode);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_read_opcode hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_read_opcode bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles', 'reset': 8, 'width': 5, 'signal_name': 'dummy_cycles', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_17_4_dummy_cycles;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_17_4_dummy_cycles;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_dummy_cycles;
interface HW_reg_6_17_4_dummy_cycles hw;
interface SW_reg_6_17_4_dummy_cycles bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_dummy_cycles#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_dummy_cycles);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_dummy_cycles hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_dummy_cycles bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles override', 'reset': 0, 'width': 3, 'signal_name': 'dummy_cycles_override', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_17_4_dummy_cycles_override;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_17_4_dummy_cycles_override;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_dummy_cycles_override;
interface HW_reg_6_17_4_dummy_cycles_override hw;
interface SW_reg_6_17_4_dummy_cycles_override bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_dummy_cycles_override#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_dummy_cycles_override);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_dummy_cycles_override hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_dummy_cycles_override bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write enable', 'reset': 0, 'width': 4, 'signal_name': 'write_enable', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_4_write_enable;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_4_write_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_write_enable;
interface HW_reg_6_17_4_write_enable hw;
interface SW_reg_6_17_4_write_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_write_enable#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_write_enable);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_write_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_write_enable bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Volatile address offset TBD', 'reset': 0, 'width': 4, 'signal_name': 'volatile_addr_offset', 'reg_name': 'reg_6_17_4', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_4_volatile_addr_offset;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_4_volatile_addr_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_4_volatile_addr_offset;
interface HW_reg_6_17_4_volatile_addr_offset hw;
interface SW_reg_6_17_4_volatile_addr_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_4_volatile_addr_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_4_volatile_addr_offset);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_4_volatile_addr_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_4_volatile_addr_offset bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write Opcode', 'reset': 113, 'width': 8, 'signal_name': 'write_opcode', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_5_write_opcode;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_5_write_opcode;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_write_opcode;
interface HW_reg_6_17_5_write_opcode hw;
interface SW_reg_6_17_5_write_opcode bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_write_opcode#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_write_opcode);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_write_opcode hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_write_opcode bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Read Opcode', 'reset': 101, 'width': 8, 'signal_name': 'read_opcode', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_5_read_opcode;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_5_read_opcode;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_read_opcode;
interface HW_reg_6_17_5_read_opcode hw;
interface SW_reg_6_17_5_read_opcode bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_read_opcode#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_read_opcode);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_read_opcode hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_read_opcode bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles', 'reset': 8, 'width': 5, 'signal_name': 'dummy_cycles', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//5
interface SW_reg_6_17_5_dummy_cycles;


method ActionValue#(Bit#(5)) read ();

endinterface

interface HW_reg_6_17_5_dummy_cycles;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_dummy_cycles;
interface HW_reg_6_17_5_dummy_cycles hw;
interface SW_reg_6_17_5_dummy_cycles bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_dummy_cycles#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_dummy_cycles);

	Reg#(Bit#(5)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(5),Bit#(5)))sw_wdata <-mkRWire();
RWire#(Bit#(5))hw_wdata <-mkRWire();
RWire#(Bit#(5))r_incr <-mkRWire();
RWire#(Bit#(5))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_dummy_cycles hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_dummy_cycles bus;


method ActionValue#(Bit#(5)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dummy cycles override', 'reset': 0, 'width': 3, 'signal_name': 'dummy_cycles_override', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_17_5_dummy_cycles_override;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_17_5_dummy_cycles_override;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_dummy_cycles_override;
interface HW_reg_6_17_5_dummy_cycles_override hw;
interface SW_reg_6_17_5_dummy_cycles_override bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_dummy_cycles_override#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_dummy_cycles_override);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_dummy_cycles_override hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_dummy_cycles_override bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Write enable', 'reset': 0, 'width': 4, 'signal_name': 'write_enable', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_5_write_enable;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_5_write_enable;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_write_enable;
interface HW_reg_6_17_5_write_enable hw;
interface SW_reg_6_17_5_write_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_write_enable#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_write_enable);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_write_enable hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_write_enable bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Volatile address offset TBD', 'reset': 0, 'width': 4, 'signal_name': 'volatile_addr_offset', 'reg_name': 'reg_6_17_5', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_5_volatile_addr_offset;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_5_volatile_addr_offset;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_5_volatile_addr_offset;
interface HW_reg_6_17_5_volatile_addr_offset hw;
interface SW_reg_6_17_5_volatile_addr_offset bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_5_volatile_addr_offset#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_5_volatile_addr_offset);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_5_volatile_addr_offset hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_5_volatile_addr_offset bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SR bit 0 is busy flag', 'reset': 1, 'width': 4, 'signal_name': 'statreg_bit0', 'reg_name': 'reg_6_17_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_6_statreg_bit0;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_6_statreg_bit0;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_6_statreg_bit0;
interface HW_reg_6_17_6_statreg_bit0 hw;
interface SW_reg_6_17_6_statreg_bit0 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_6_statreg_bit0#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_6_statreg_bit0);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_6_statreg_bit0 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_6_statreg_bit0 bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'SR Access', 'reset': 1, 'width': 4, 'signal_name': 'statreg_access', 'reg_name': 'reg_6_17_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_reg_6_17_6_statreg_access;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_reg_6_17_6_statreg_access;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_6_statreg_access;
interface HW_reg_6_17_6_statreg_access hw;
interface SW_reg_6_17_6_statreg_access bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_6_statreg_access#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_6_statreg_access);

	Reg#(Bit#(4)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(4),Bit#(4)))sw_wdata <-mkRWire();
RWire#(Bit#(4))hw_wdata <-mkRWire();
RWire#(Bit#(4))r_incr <-mkRWire();
RWire#(Bit#(4))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_6_statreg_access hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_6_statreg_access bus;


method ActionValue#(Bit#(4)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Dymmy Cycles', 'reset': 2, 'width': 3, 'signal_name': 'dummy_cycles', 'reg_name': 'reg_6_17_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//3
interface SW_reg_6_17_6_dummy_cycles;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_reg_6_17_6_dummy_cycles;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_6_dummy_cycles;
interface HW_reg_6_17_6_dummy_cycles hw;
interface SW_reg_6_17_6_dummy_cycles bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_6_dummy_cycles#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_6_dummy_cycles);

	Reg#(Bit#(3)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(3),Bit#(3)))sw_wdata <-mkRWire();
RWire#(Bit#(3))hw_wdata <-mkRWire();
RWire#(Bit#(3))r_incr <-mkRWire();
RWire#(Bit#(3))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_6_dummy_cycles hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_6_dummy_cycles bus;


method ActionValue#(Bit#(3)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Aux 1 TBD SR address', 'reset': 0, 'width': 8, 'signal_name': 'aux1', 'reg_name': 'reg_6_17_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_6_aux1;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_6_aux1;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_6_aux1;
interface HW_reg_6_17_6_aux1 hw;
interface SW_reg_6_17_6_aux1 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_6_aux1#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_6_aux1);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_6_aux1 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_6_aux1 bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'hw': 'AccessType.na', 'sw': 'AccessType.r', 'desc': 'Aux 2', 'reset': 5, 'width': 8, 'signal_name': 'aux2', 'reg_name': 'reg_6_17_6', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//8
interface SW_reg_6_17_6_aux2;


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_reg_6_17_6_aux2;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_reg_6_17_6_aux2;
interface HW_reg_6_17_6_aux2 hw;
interface SW_reg_6_17_6_aux2 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_reg_6_17_6_aux2#(Integer resetValue)(Ifc_CSRSignal_reg_6_17_6_aux2);

	Reg#(Bit#(8)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(8),Bit#(8)))sw_wdata <-mkRWire();
RWire#(Bit#(8))hw_wdata <-mkRWire();
RWire#(Bit#(8))r_incr <-mkRWire();
RWire#(Bit#(8))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_reg_6_17_6_aux2 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_reg_6_17_6_aux2 bus;


method ActionValue#(Bit#(8)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
