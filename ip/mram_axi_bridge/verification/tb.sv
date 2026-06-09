module tb();
    `ifdef DUMP_WAVES
    initial begin
        $vcdpluson;
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
    end
    `endif
    axi2mram_wrapper #(
        .ADDR_WIDTH(24)
    ) dut ();
endmodule : tb