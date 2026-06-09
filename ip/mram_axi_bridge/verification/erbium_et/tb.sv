module tb();
    logic [1023:0] tb_matrix_label;
    logic [31:0]   tb_matrix_step;

    initial begin
        tb_matrix_label = '0;
        tb_matrix_step = '0;
    end

    `ifdef DUMP_VPD
    initial begin
        $vcdplusfile("dump.vpd");
        $vcdpluson(0, dut);
    end
    `endif

    `ifdef DUMP_VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
    end
    `endif
    // Lint waiver (intentional): keep `dut()` minimally instantiated for cocotb
    // hierarchy-driven stimulus/inspection. This triggers TFIPC in VCS because
    // ports are intentionally left unconnected in this SV shell testbench.
    // See top-level README "Known lint waivers" section.
    axi2mram_et_wrapper #(
    ) dut ();
endmodule : tb
