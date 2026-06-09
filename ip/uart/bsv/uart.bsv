
import Semi_FIFOF :: *;
import axi4_types:: *;
import Uart_Reg_csr::*;

interface Uart_Ifc;
   interface Ifc_axi4_master#(0,32,32,0) axi4;
endinterface

(*synthesize*)
module mkUart(Uart_Ifc);

   ConfigCSR_Uart_Reg csr <- mkConfigCSR_Uart_Reg();
   Ifc_axi4_master_xactor#(0,32,32,0) xactor <- mkaxi4_master_xactor(QueueSize {
   wr_req_depth: 1,
   wr_resp_depth: 1,
   rd_req_depth: 1,
   rd_resp_depth: 1}
);
   interface Ifc_axi4_master axi4 = xactor.axi4_side;
endmodule
