// {'sw': 'AccessType.rw', 'hw': 'AccessType.na', 'desc': 'Manufacturer: TODO check how to obtain this number', 'reset': 2, 'width': 4, 'signal_name': 'mgf_id', 'reg_name': 'ID0', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.na
// AccessType.rw
//True
//False
//False
//True
//4
interface SW_ID0_mgf_id;

method Action write(Bit#(4) data,Bit#(4) wstrb);


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_ID0_mgf_id;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_ID0_mgf_id;
interface HW_ID0_mgf_id hw;
interface SW_ID0_mgf_id bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_ID0_mgf_id#(Integer resetValue)(Ifc_CSRSignal_ID0_mgf_id);

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
interface HW_ID0_mgf_id hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_ID0_mgf_id bus;

method Action write(Bit#(4) data, Bit#(4) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.na', 'desc': 'DEVID0 TODO Use as suitable', 'reset': 0, 'width': 12, 'signal_name': 'devid0', 'reg_name': 'ID0', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.na
// AccessType.rw
//True
//False
//False
//True
//12
interface SW_ID0_devid0;

method Action write(Bit#(12) data,Bit#(12) wstrb);


method ActionValue#(Bit#(12)) read ();

endinterface

interface HW_ID0_devid0;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_ID0_devid0;
interface HW_ID0_devid0 hw;
interface SW_ID0_devid0 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_ID0_devid0#(Integer resetValue)(Ifc_CSRSignal_ID0_devid0);

	Reg#(Bit#(12)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(12),Bit#(12)))sw_wdata <-mkRWire();
RWire#(Bit#(12))hw_wdata <-mkRWire();
RWire#(Bit#(12))r_incr <-mkRWire();
RWire#(Bit#(12))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_ID0_devid0 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_ID0_devid0 bus;

method Action write(Bit#(12) data, Bit#(12) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


method ActionValue#(Bit#(12)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'sw': 'AccessType.rw', 'hw': 'AccessType.na', 'desc': 'Device Type set to hyperram', 'reset': 0, 'width': 4, 'signal_name': 'dev_type', 'reg_name': 'ID1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.na
// AccessType.rw
//True
//False
//False
//True
//4
interface SW_ID1_dev_type;

method Action write(Bit#(4) data,Bit#(4) wstrb);


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_ID1_dev_type;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_ID1_dev_type;
interface HW_ID1_dev_type hw;
interface SW_ID1_dev_type bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_ID1_dev_type#(Integer resetValue)(Ifc_CSRSignal_ID1_dev_type);

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
interface HW_ID1_dev_type hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_ID1_dev_type bus;

method Action write(Bit#(4) data, Bit#(4) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.na', 'desc': 'TODO Use as appropriate', 'reset': 0, 'width': 12, 'signal_name': 'devid1', 'reg_name': 'ID1', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.na
// AccessType.rw
//True
//False
//False
//True
//12
interface SW_ID1_devid1;

method Action write(Bit#(12) data,Bit#(12) wstrb);


method ActionValue#(Bit#(12)) read ();

endinterface

interface HW_ID1_devid1;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_ID1_devid1;
interface HW_ID1_devid1 hw;
interface SW_ID1_devid1 bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_ID1_devid1#(Integer resetValue)(Ifc_CSRSignal_ID1_devid1);

	Reg#(Bit#(12)) r<-mkRegA(fromInteger(resetValue));
PulseWire pw_set <-mkPulseWire();
PulseWire pw_clear <-mkPulseWire();
PulseWire pw_swacc <-mkPulseWire();
PulseWire pw_swmod <-mkPulseWire();
RWire#(Tuple2#(Bit#(12),Bit#(12)))sw_wdata <-mkRWire();
RWire#(Bit#(12))hw_wdata <-mkRWire();
RWire#(Bit#(12))r_incr <-mkRWire();
RWire#(Bit#(12))r_decr <-mkRWire();

rule r_write;
	let rr = r;
	
	if(pw_clear) rr =0;
	else if(pw_set) rr =1;
    else if(sw_wdata.wget( ) matches tagged Valid .v) rr = ((tpl_1(v) & tpl_2(v)) | (~tpl_2(v) &rr));
	else if(hw_wdata.wget( ) matches tagged Valid .v) rr = v;
	else if(r_incr.wget( ) matches tagged Valid .v)   rr = r + v;
	else if(r_decr.wget( ) matches tagged Valid .v)   rr = r - v;
	r<=rr;
endrule
interface HW_ID1_devid1 hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_ID1_devid1 bus;

method Action write(Bit#(12) data, Bit#(12) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


method ActionValue#(Bit#(12)) read;
	let rv=0;
	let mod=False;
	
        
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Burst Length', 'reset': 2, 'width': 2, 'signal_name': 'BurstLength', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//2
interface SW_CFG_BurstLength;

method Action write(Bit#(2) data,Bit#(2) wstrb);


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_CFG_BurstLength;
	
	
	
	
	
	

 method Bit#(2) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_BurstLength;
interface HW_CFG_BurstLength hw;
interface SW_CFG_BurstLength bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_BurstLength#(Integer resetValue)(Ifc_CSRSignal_CFG_BurstLength);

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
interface HW_CFG_BurstLength hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(2) _read;
	return r;
endmethod


endinterface
interface SW_CFG_BurstLength bus;

method Action write(Bit#(2) data, Bit#(2) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.r', 'desc': 'Burst Enable', 'reset': 0, 'width': 1, 'signal_name': 'HybridBurstEnable', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.r
// AccessType.r
//False
//False
//True
//True
//1
interface SW_CFG_HybridBurstEnable;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_CFG_HybridBurstEnable;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_HybridBurstEnable;
interface HW_CFG_HybridBurstEnable hw;
interface SW_CFG_HybridBurstEnable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_HybridBurstEnable#(Integer resetValue)(Ifc_CSRSignal_CFG_HybridBurstEnable);

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
interface HW_CFG_HybridBurstEnable hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_CFG_HybridBurstEnable bus;


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.r', 'desc': 'Fixed Latency', 'reset': 1, 'width': 1, 'signal_name': 'FixedLatency', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.r
// AccessType.r
//False
//False
//True
//True
//1
interface SW_CFG_FixedLatency;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_CFG_FixedLatency;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_FixedLatency;
interface HW_CFG_FixedLatency hw;
interface SW_CFG_FixedLatency bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_FixedLatency#(Integer resetValue)(Ifc_CSRSignal_CFG_FixedLatency);

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
interface HW_CFG_FixedLatency hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_CFG_FixedLatency bus;


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Initial Latency.', 'reset': 8, 'width': 4, 'signal_name': 'InitialLatency', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//4
interface SW_CFG_InitialLatency;

method Action write(Bit#(4) data,Bit#(4) wstrb);


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_CFG_InitialLatency;
	
	
	
	
	
	

 method Bit#(4) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_InitialLatency;
interface HW_CFG_InitialLatency hw;
interface SW_CFG_InitialLatency bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_InitialLatency#(Integer resetValue)(Ifc_CSRSignal_CFG_InitialLatency);

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
interface HW_CFG_InitialLatency hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(4) _read;
	return r;
endmethod


endinterface
interface SW_CFG_InitialLatency bus;

method Action write(Bit#(4) data, Bit#(4) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.na', 'reset': 1, 'width': 4, 'signal_name': 'Reserved', 'reg_name': 'CFG', 'hw_readable': False, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.na
// AccessType.r
//False
//False
//False
//True
//4
interface SW_CFG_Reserved;


method ActionValue#(Bit#(4)) read ();

endinterface

interface HW_CFG_Reserved;
	
	
	
	
	
	




	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_Reserved;
interface HW_CFG_Reserved hw;
interface SW_CFG_Reserved bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_Reserved#(Integer resetValue)(Ifc_CSRSignal_CFG_Reserved);

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
interface HW_CFG_Reserved hw;






method Action clear();
	pw_clear.send();
endmethod



endinterface
interface SW_CFG_Reserved bus;


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.r', 'desc': 'Drive Strength.', 'reset': 3, 'width': 3, 'signal_name': 'DriveStrength', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': False}
// AccessType.r
// AccessType.r
//False
//False
//True
//True
//3
interface SW_CFG_DriveStrength;


method ActionValue#(Bit#(3)) read ();

endinterface

interface HW_CFG_DriveStrength;
	
	
	
	
	
	

 method Bit#(3) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_DriveStrength;
interface HW_CFG_DriveStrength hw;
interface SW_CFG_DriveStrength bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_DriveStrength#(Integer resetValue)(Ifc_CSRSignal_CFG_DriveStrength);

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
interface HW_CFG_DriveStrength hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(3) _read;
	return r;
endmethod


endinterface
interface SW_CFG_DriveStrength bus;


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Deep Power down, Not too deep, not too shallow', 'reset': 0, 'width': 1, 'signal_name': 'DeepPowerDown', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//1
interface SW_CFG_DeepPowerDown;

method Action write(Bit#(1) data,Bit#(1) wstrb);


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_CFG_DeepPowerDown;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_DeepPowerDown;
interface HW_CFG_DeepPowerDown hw;
interface SW_CFG_DeepPowerDown bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_DeepPowerDown#(Integer resetValue)(Ifc_CSRSignal_CFG_DeepPowerDown);

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
interface HW_CFG_DeepPowerDown hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_CFG_DeepPowerDown bus;

method Action write(Bit#(1) data, Bit#(1) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Enable bust access. Applicable only to memory access. Register access are one at a time', 'reset': 0, 'width': 1, 'signal_name': 'BurstEnable', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//1
interface SW_CFG_BurstEnable;

method Action write(Bit#(1) data,Bit#(1) wstrb);


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_CFG_BurstEnable;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_BurstEnable;
interface HW_CFG_BurstEnable hw;
interface SW_CFG_BurstEnable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_BurstEnable#(Integer resetValue)(Ifc_CSRSignal_CFG_BurstEnable);

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
interface HW_CFG_BurstEnable hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_CFG_BurstEnable bus;

method Action write(Bit#(1) data, Bit#(1) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Ultra Deep Power down.', 'reset': 0, 'width': 1, 'signal_name': 'UltraDeepPowerDown', 'reg_name': 'CFG', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//1
interface SW_CFG_UltraDeepPowerDown;

method Action write(Bit#(1) data,Bit#(1) wstrb);


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_CFG_UltraDeepPowerDown;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_CFG_UltraDeepPowerDown;
interface HW_CFG_UltraDeepPowerDown hw;
interface SW_CFG_UltraDeepPowerDown bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_CFG_UltraDeepPowerDown#(Integer resetValue)(Ifc_CSRSignal_CFG_UltraDeepPowerDown);

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
interface HW_CFG_UltraDeepPowerDown hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_CFG_UltraDeepPowerDown bus;

method Action write(Bit#(1) data, Bit#(1) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.w', 'desc': 'write in progress', 'reset': 0, 'width': 1, 'signal_name': 'wip', 'reg_name': 'xspi_status', 'hw_readable': False, 'hw_writable': True, 'sw_readable': True, 'sw_writable': False}
// AccessType.w
// AccessType.r
//False
//True
//False
//True
//1
interface SW_xspi_status_wip;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_xspi_status_wip;
	
	
	
	
	
	
 method Action _write(Bit#(1) data); 



	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_status_wip;
interface HW_xspi_status_wip hw;
interface SW_xspi_status_wip bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_status_wip#(Integer resetValue)(Ifc_CSRSignal_xspi_status_wip);

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
interface HW_xspi_status_wip hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(1) data);
	hw_wdata.wset(data);
endmethod



endinterface
interface SW_xspi_status_wip bus;


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Use xspi clock as system clock', 'reset': 0, 'width': 1, 'signal_name': 'use_xspi_clk', 'reg_name': 'xspi_control', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//1
interface SW_xspi_control_use_xspi_clk;

method Action write(Bit#(1) data,Bit#(1) wstrb);


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_xspi_control_use_xspi_clk;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_control_use_xspi_clk;
interface HW_xspi_control_use_xspi_clk hw;
interface SW_xspi_control_use_xspi_clk bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_control_use_xspi_clk#(Integer resetValue)(Ifc_CSRSignal_xspi_control_use_xspi_clk);

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
interface HW_xspi_control_use_xspi_clk hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_xspi_control_use_xspi_clk bus;

method Action write(Bit#(1) data, Bit#(1) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.r', 'desc': 'Use xspi clock as system clock', 'reset': 0, 'width': 1, 'signal_name': 'interrupt_enable', 'reg_name': 'xspi_control', 'hw_readable': True, 'hw_writable': False, 'sw_readable': True, 'sw_writable': True}
// AccessType.r
// AccessType.rw
//True
//False
//True
//True
//1
interface SW_xspi_control_interrupt_enable;

method Action write(Bit#(1) data,Bit#(1) wstrb);


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_xspi_control_interrupt_enable;
	
	
	
	
	
	

 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_control_interrupt_enable;
interface HW_xspi_control_interrupt_enable hw;
interface SW_xspi_control_interrupt_enable bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_control_interrupt_enable#(Integer resetValue)(Ifc_CSRSignal_xspi_control_interrupt_enable);

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
interface HW_xspi_control_interrupt_enable hw;






method Action clear();
	pw_clear.send();
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_xspi_control_interrupt_enable bus;

method Action write(Bit#(1) data, Bit#(1) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.rw', 'desc': 'CMD Rate', 'reset': 0, 'width': 8, 'signal_name': 'cmd_rate', 'reg_name': 'xspi_rates', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': True}
// AccessType.rw
// AccessType.rw
//True
//True
//True
//True
//8
interface SW_xspi_rates_cmd_rate;

method Action write(Bit#(8) data,Bit#(8) wstrb);


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_xspi_rates_cmd_rate;
	
	
	
	
	
	
 method Action _write(Bit#(8) data); 
 method Bit#(8) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_rates_cmd_rate;
interface HW_xspi_rates_cmd_rate hw;
interface SW_xspi_rates_cmd_rate bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_rates_cmd_rate#(Integer resetValue)(Ifc_CSRSignal_xspi_rates_cmd_rate);

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
interface HW_xspi_rates_cmd_rate hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(8) data);
	hw_wdata.wset(data);
endmethod


method Bit#(8) _read;
	return r;
endmethod


endinterface
interface SW_xspi_rates_cmd_rate bus;

method Action write(Bit#(8) data, Bit#(8) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.rw', 'desc': 'CMD Rate', 'reset': 0, 'width': 8, 'signal_name': 'addr_rate', 'reg_name': 'xspi_rates', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': True}
// AccessType.rw
// AccessType.rw
//True
//True
//True
//True
//8
interface SW_xspi_rates_addr_rate;

method Action write(Bit#(8) data,Bit#(8) wstrb);


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_xspi_rates_addr_rate;
	
	
	
	
	
	
 method Action _write(Bit#(8) data); 
 method Bit#(8) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_rates_addr_rate;
interface HW_xspi_rates_addr_rate hw;
interface SW_xspi_rates_addr_rate bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_rates_addr_rate#(Integer resetValue)(Ifc_CSRSignal_xspi_rates_addr_rate);

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
interface HW_xspi_rates_addr_rate hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(8) data);
	hw_wdata.wset(data);
endmethod


method Bit#(8) _read;
	return r;
endmethod


endinterface
interface SW_xspi_rates_addr_rate bus;

method Action write(Bit#(8) data, Bit#(8) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.rw', 'hw': 'AccessType.rw', 'desc': 'CMD Rate', 'reset': 0, 'width': 8, 'signal_name': 'data_rate', 'reg_name': 'xspi_rates', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': True}
// AccessType.rw
// AccessType.rw
//True
//True
//True
//True
//8
interface SW_xspi_rates_data_rate;

method Action write(Bit#(8) data,Bit#(8) wstrb);


method ActionValue#(Bit#(8)) read ();

endinterface

interface HW_xspi_rates_data_rate;
	
	
	
	
	
	
 method Action _write(Bit#(8) data); 
 method Bit#(8) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_xspi_rates_data_rate;
interface HW_xspi_rates_data_rate hw;
interface SW_xspi_rates_data_rate bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_xspi_rates_data_rate#(Integer resetValue)(Ifc_CSRSignal_xspi_rates_data_rate);

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
interface HW_xspi_rates_data_rate hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(8) data);
	hw_wdata.wset(data);
endmethod


method Bit#(8) _read;
	return r;
endmethod


endinterface
interface SW_xspi_rates_data_rate bus;

method Action write(Bit#(8) data, Bit#(8) wstrb);
	let mod=False;
	 sw_wdata.wset(tuple2(data,wstrb));
    if (wstrb !=0)begin
	    
	    
	    
	    
        
        
	    if(mod)
		    pw_swmod.send();
    end
endmethod


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
// {'sw': 'AccessType.r', 'hw': 'AccessType.rw', 'rclr': True, 'desc': 'AXI Resp Error', 'reset': 0, 'width': 2, 'signal_name': 'axi_resp', 'reg_name': 'interrupt_status', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': False}
// AccessType.rw
// AccessType.r
//False
//True
//True
//True
//2
interface SW_interrupt_status_axi_resp;


method ActionValue#(Bit#(2)) read ();

endinterface

interface HW_interrupt_status_axi_resp;
	
	
	
	
	
	
 method Action _write(Bit#(2) data); 
 method Bit#(2) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_interrupt_status_axi_resp;
interface HW_interrupt_status_axi_resp hw;
interface SW_interrupt_status_axi_resp bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_interrupt_status_axi_resp#(Integer resetValue)(Ifc_CSRSignal_interrupt_status_axi_resp);

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
interface HW_interrupt_status_axi_resp hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(2) data);
	hw_wdata.wset(data);
endmethod


method Bit#(2) _read;
	return r;
endmethod


endinterface
interface SW_interrupt_status_axi_resp bus;


method ActionValue#(Bit#(2)) read;
	let rv=0;
	let mod=False;
	
         pw_clear.send();
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'sw': 'AccessType.r', 'hw': 'AccessType.rw', 'rclr': True, 'desc': 'Read FIFO Underflow Error', 'reset': 0, 'width': 1, 'signal_name': 'read_underflow', 'reg_name': 'interrupt_status', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': False}
// AccessType.rw
// AccessType.r
//False
//True
//True
//True
//1
interface SW_interrupt_status_read_underflow;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_interrupt_status_read_underflow;
	
	
	
	
	
	
 method Action _write(Bit#(1) data); 
 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_interrupt_status_read_underflow;
interface HW_interrupt_status_read_underflow hw;
interface SW_interrupt_status_read_underflow bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_interrupt_status_read_underflow#(Integer resetValue)(Ifc_CSRSignal_interrupt_status_read_underflow);

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
interface HW_interrupt_status_read_underflow hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(1) data);
	hw_wdata.wset(data);
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_interrupt_status_read_underflow bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
         pw_clear.send();
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
// {'sw': 'AccessType.r', 'hw': 'AccessType.rw', 'rclr': True, 'desc': 'Write FIFO Overflow Error', 'reset': 0, 'width': 1, 'signal_name': 'write_overflow', 'reg_name': 'interrupt_status', 'hw_readable': True, 'hw_writable': True, 'sw_readable': True, 'sw_writable': False}
// AccessType.rw
// AccessType.r
//False
//True
//True
//True
//1
interface SW_interrupt_status_write_overflow;


method ActionValue#(Bit#(1)) read ();

endinterface

interface HW_interrupt_status_write_overflow;
	
	
	
	
	
	
 method Action _write(Bit#(1) data); 
 method Bit#(1) _read; 


	method Action clear();
endinterface

interface Ifc_CSRSignal_interrupt_status_write_overflow;
interface HW_interrupt_status_write_overflow hw;
interface SW_interrupt_status_write_overflow bus;
// method Action bus_write(Bit#(width) data);
// method  ActionValue#(Bit#(width)) bus_read;
endinterface




module mkCSRSignal_interrupt_status_write_overflow#(Integer resetValue)(Ifc_CSRSignal_interrupt_status_write_overflow);

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
interface HW_interrupt_status_write_overflow hw;






method Action clear();
	pw_clear.send();
endmethod

method Action _write(Bit#(1) data);
	hw_wdata.wset(data);
endmethod


method Bit#(1) _read;
	return r;
endmethod


endinterface
interface SW_interrupt_status_write_overflow bus;


method ActionValue#(Bit#(1)) read;
	let rv=0;
	let mod=False;
	
         pw_clear.send();
        


	if(mod)
		pw_swmod.send();
		rv=r;
	return rv;
endmethod

endinterface
endmodule

// End getting CSR Code
