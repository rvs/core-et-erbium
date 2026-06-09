import axi2axil::*;
(*synthesize*)
module axi2axil_64(Ifc_axi2axil#(32, 9, 64, 32, 64, 0));
let t<- mkaxi2axil();
//Ifc_axi2axil#(axi_addr, axi_id, axi_data, axil_addr, axil_data, user))
return t;
endmodule

(*synthesize*)
module axi2axil_32(Ifc_axi2axil#(32, 9, 64, 32, 32, 0));
let t<- mkaxi2axil();
//Ifc_axi2axil#(axi_addr, axi_id, axi_data, axil_addr, axil_data, user))
return t;
endmodule

