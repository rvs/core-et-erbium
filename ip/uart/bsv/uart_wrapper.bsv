import uart_axi::*;

(*synthesize*)
module uart(Ifc_uart_axi4lite#(32, 64, 0, 16));
   let ifc <- mkuart_axi4lite(5, 0, 0);
   return ifc;
endmodule
