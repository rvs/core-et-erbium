#!/usr/bin/env python3
"""Generate the configurable AXI4/APB4 NoC top `erbium_noc_top`.

Data-driven from the topology tables below. The body wires permissively-licensed
leaf IP (axi_xbar, axi_dw_converter, axi_cdc, axi_to_axi_lite, axi_lite_to_apb)
under a flat boundary with explicit port names and bus widths.

Fabric: 512b internal crossbar, per-leg width conversion, per-initiator static
address remap into one canonical space, built-in DECERR on unmapped addresses,
AXI exclusive (lock) passed through, multi-clock via axi_cdc, Q/P-Channel
low-power, and a read-only discovery block.
"""
from __future__ import annotations
from pathlib import Path

AW = 32
SLV_IW = 8          # unified slave-port ID width (cpu=8 native; xspi=1 zero-extended)
MST_IW = 9          # xbar master-side ID width = SLV_IW + clog2(NoSlv=2)

# canonical (= s_cpu view) address map; (name, proto, data_w, idx, start, end_excl, domain)
TARGETS = [
    ("M_MRAM",         "axi", 512, 0, 0x4000_0000, 0x8000_0000, "CPU"),
    ("M_CPU_REG",      "axi",  64, 1, 0x8000_0000, 0xC000_0000, "CPU"),
    ("M_SYSTEM_REG",   "axi",  64, 2, 0x0200_0000, 0x0200_1000, "SYSTEM"),
    ("M_MRAM_REG",     "axi",  64, 3, 0x0200_1000, 0x0200_2000, "CPU"),
    ("M_SPI_REG",      "axi",  64, 4, 0x0200_3000, 0x0200_4000, "PERIPH"),
    ("M_UART_REG",     "axi",  64, 5, 0x0200_4000, 0x0200_5000, "PERIPH"),
    ("M_SRAM",         "axi",  64, 6, 0x0200_8000, 0x0200_D000, "SYSTEM"),
    ("M_XSPI",         "axi",  64, 7, 0x0200_F000, 0x0201_0000, "XSPI"),
    ("M_I2C_REG",      "apb",  32, 8, 0x0200_2000, 0x0200_3000, "PERIPH"),
]
NO_MST = len(TARGETS)
# clock-domain wires (fabric runs on CPU); per domain: (clk, rst_sync)
DOM = {"CPU":    ("clk_cpu",    "rstn_cpu"),
       "SYSTEM": ("clk_sys",    "rstn_sys"),
       "PERIPH": ("clk_periph", "rstn_periph"),
       "XSPI":   ("clk_xspi",   "rstn_xspi")}

# AXI4 channel signal sets (flat), parameterized by ID width.
def aw_sig(idw): return [
    ("AWID","aw.id",str(idw)),("AWADDR","aw.addr",str(AW)),("AWLEN","aw.len","8"),
    ("AWSIZE","aw.size","3"),("AWBURST","aw.burst","2"),("AWLOCK","aw.lock","1"),
    ("AWCACHE","aw.cache","4"),("AWPROT","aw.prot","3"),("AWQOS","aw.qos","4")]
def ar_sig(idw): return [
    ("ARID","ar.id",str(idw)),("ARADDR","ar.addr",str(AW)),("ARLEN","ar.len","8"),
    ("ARSIZE","ar.size","3"),("ARBURST","ar.burst","2"),("ARLOCK","ar.lock","1"),
    ("ARCACHE","ar.cache","4"),("ARPROT","ar.prot","3"),("ARQOS","ar.qos","4")]
def b_sig(idw): return [("BID","b.id",str(idw)),("BRESP","b.resp","2")]
def r_sig(idw): return [("RID","r.id",str(idw)),("RDATA","r.data","DW"),("RRESP","r.resp","2"),("RLAST","r.last","1")]
W_SIG  = [("WDATA","w.data","DW"),("WSTRB","w.strb","DW/8"),("WLAST","w.last","1")]


def w(expr: str, dw: int) -> str:
    return expr.replace("DW/8", str(dw // 8)).replace("DW", str(dw))


def vec(width: str) -> str:
    return "" if width == "1" else f"[{width}-1:0] "


def slave_ports(name: str, dw: int, idw: int) -> list[str]:
    """Flat port declarations for an AXI slave (initiator-facing) port."""
    p = []
    ins  = aw_sig(idw) + [("AWVALID","",  "1")] + W_SIG + [("WVALID","","1"),("BREADY","","1")] \
         + ar_sig(idw) + [("ARVALID","","1"),("RREADY","","1")]
    outs = [("AWREADY","","1"),("WREADY","","1")] + b_sig(idw) + [("BVALID","","1")] \
         + [("ARREADY","","1")] + r_sig(idw) + [("RVALID","","1")]
    for suf,_,wd in ins:
        p.append(f"  input  logic {vec(w(wd,dw))}AXI_SLAVE_{name}_{suf}")
    for suf,_,wd in outs:
        p.append(f"  output logic {vec(w(wd,dw))}AXI_SLAVE_{name}_{suf}")
    return p


def master_ports(name: str, dw: int) -> list[str]:
    """Flat port declarations for an AXI master (target-facing) port (id=MST_IW)."""
    p = []
    outs = aw_sig(MST_IW) + [("AWVALID","","1")] + W_SIG + [("WVALID","","1"),("BREADY","","1")] \
         + ar_sig(MST_IW) + [("ARVALID","","1"),("RREADY","","1")]
    ins  = [("AWREADY","","1"),("WREADY","","1")] + b_sig(MST_IW) + [("BVALID","","1")] \
         + [("ARREADY","","1")] + r_sig(MST_IW) + [("RVALID","","1")]
    for suf,_,wd in outs:
        p.append(f"  output logic {vec(w(wd,dw))}AXI_MASTER_{name}_{suf}")
    for suf,_,wd in ins:
        p.append(f"  input  logic {vec(w(wd,dw))}AXI_MASTER_{name}_{suf}")
    return p


def pack_slave(name: str, req: str, resp: str, dw: int, idw: int) -> list[str]:
    """assign struct req fields from flat inputs; flat outputs from struct resp.
    Flat port ID width is `idw`; zero-extend into the unified SLV_IW struct."""
    pad = SLV_IW - idw
    def idext(sig): return f"{{{pad}'b0, {sig}}}" if pad > 0 else sig
    L = []
    for suf,fld,_ in aw_sig(idw):
        rhs = idext(f"AXI_SLAVE_{name}_{suf}") if suf == "AWID" else f"AXI_SLAVE_{name}_{suf}"
        L.append(f"  assign {req}.{fld} = {rhs};")
    L += [f"  assign {req}.aw.region = '0;", f"  assign {req}.aw.atop   = '0;",
          f"  assign {req}.aw.user   = '0;", f"  assign {req}.aw_valid  = AXI_SLAVE_{name}_AWVALID;"]
    for suf,fld,_ in W_SIG:
        L.append(f"  assign {req}.{fld} = AXI_SLAVE_{name}_{suf};")
    L += [f"  assign {req}.w.user   = '0;", f"  assign {req}.w_valid  = AXI_SLAVE_{name}_WVALID;",
          f"  assign {req}.b_ready  = AXI_SLAVE_{name}_BREADY;"]
    for suf,fld,_ in ar_sig(idw):
        rhs = idext(f"AXI_SLAVE_{name}_{suf}") if suf == "ARID" else f"AXI_SLAVE_{name}_{suf}"
        L.append(f"  assign {req}.{fld} = {rhs};")
    L += [f"  assign {req}.ar.region = '0;", f"  assign {req}.ar.user   = '0;",
          f"  assign {req}.ar_valid  = AXI_SLAVE_{name}_ARVALID;",
          f"  assign {req}.r_ready   = AXI_SLAVE_{name}_RREADY;"]
    L += [f"  assign AXI_SLAVE_{name}_AWREADY = {resp}.aw_ready;",
          f"  assign AXI_SLAVE_{name}_WREADY  = {resp}.w_ready;",
          f"  assign AXI_SLAVE_{name}_BID     = {resp}.b.id[{idw}-1:0];",
          f"  assign AXI_SLAVE_{name}_BRESP   = {resp}.b.resp;",
          f"  assign AXI_SLAVE_{name}_BVALID  = {resp}.b_valid;",
          f"  assign AXI_SLAVE_{name}_ARREADY = {resp}.ar_ready;",
          f"  assign AXI_SLAVE_{name}_RID     = {resp}.r.id[{idw}-1:0];",
          f"  assign AXI_SLAVE_{name}_RDATA   = {resp}.r.data;",
          f"  assign AXI_SLAVE_{name}_RRESP   = {resp}.r.resp;",
          f"  assign AXI_SLAVE_{name}_RLAST   = {resp}.r.last;",
          f"  assign AXI_SLAVE_{name}_RVALID  = {resp}.r_valid;"]
    return L


def unpack_master(name: str, req: str, resp: str) -> list[str]:
    """flat master outputs from struct req; struct resp from flat inputs (id=MST_IW)."""
    L = []
    for suf,fld,_ in aw_sig(MST_IW):
        L.append(f"  assign AXI_MASTER_{name}_{suf} = {req}.{fld};")
    L += [f"  assign AXI_MASTER_{name}_AWVALID = {req}.aw_valid;"]
    for suf,fld,_ in W_SIG:
        L.append(f"  assign AXI_MASTER_{name}_{suf} = {req}.{fld};")
    L += [f"  assign AXI_MASTER_{name}_WVALID = {req}.w_valid;",
          f"  assign AXI_MASTER_{name}_BREADY = {req}.b_ready;"]
    for suf,fld,_ in ar_sig(MST_IW):
        L.append(f"  assign AXI_MASTER_{name}_{suf} = {req}.{fld};")
    L += [f"  assign AXI_MASTER_{name}_ARVALID = {req}.ar_valid;",
          f"  assign AXI_MASTER_{name}_RREADY = {req}.r_ready;",
          f"  assign {resp}.aw_ready = AXI_MASTER_{name}_AWREADY;",
          f"  assign {resp}.w_ready  = AXI_MASTER_{name}_WREADY;",
          f"  assign {resp}.b.id     = AXI_MASTER_{name}_BID;",
          f"  assign {resp}.b.resp   = AXI_MASTER_{name}_BRESP;",
          f"  assign {resp}.b.user   = '0;",
          f"  assign {resp}.b_valid  = AXI_MASTER_{name}_BVALID;",
          f"  assign {resp}.ar_ready = AXI_MASTER_{name}_ARREADY;",
          f"  assign {resp}.r.id     = AXI_MASTER_{name}_RID;",
          f"  assign {resp}.r.data   = AXI_MASTER_{name}_RDATA;",
          f"  assign {resp}.r.resp   = AXI_MASTER_{name}_RRESP;",
          f"  assign {resp}.r.last   = AXI_MASTER_{name}_RLAST;",
          f"  assign {resp}.r.user   = '0;",
          f"  assign {resp}.r_valid  = AXI_MASTER_{name}_RVALID;"]
    return L


def typedefs(pfx: str, idw: int, dw: int) -> str:
    return (f"  typedef logic [{AW}-1:0]   {pfx}_addr_t;\n"
            f"  typedef logic [{idw}-1:0]   {pfx}_id_t;\n"
            f"  typedef logic [{dw}-1:0]  {pfx}_data_t;\n"
            f"  typedef logic [{dw}/8-1:0] {pfx}_strb_t;\n"
            f"  typedef logic [0:0]   {pfx}_user_t;\n"
            f"  `AXI_TYPEDEF_ALL({pfx}, {pfx}_addr_t, {pfx}_id_t, {pfx}_data_t, {pfx}_strb_t, {pfx}_user_t)\n")


DOMAINS = ("CPU", "SYSTEM", "XSPI", "PERIPH")


def sideband_ports() -> list[str]:
    """Flat sideband port declarations for full pin compatibility."""
    P = []
    for d in DOMAINS:
        P += [f"  output logic {d}_QACTIVE", f"  input  logic {d}_QREQn",
              f"  output logic {d}_QACCEPTn", f"  output logic {d}_QDENY",
              f"  input  logic {d}_SPIDEN", f"  input  logic {d}_NIDEN",
              f"  input  logic {d}_DBGEN", f"  input  logic {d}_SPNIDEN",
              f"  input  logic {d}_PMUSNAPSHOTREQ", f"  output logic {d}_PMUSNAPSHOTACK",
              f"  output logic {d}_nPMUINTERRUPT", f"  input  logic DFT{d}DISABLE"]
    P += ["  output logic       PD_0_PACTIVE", "  input  logic       PD_0_PREQ",
          "  input  logic [3:0] PD_0_PSTATE", "  output logic       PD_0_PACCEPT",
          "  output logic       PD_0_PDENY", "  output logic       PD_0_INTERRUPT",
          "  output logic       PD_0_NS_INTERRUPT"]
    for nm in ("S_CPU", "S_XSPI"):
        P.append(f"  input  logic AXI_SLAVE_{nm}_AWAKEUP")
    for nm, proto, *_ in TARGETS:
        if proto == "axi":
            P.append(f"  output logic AXI_MASTER_{nm}_AWAKEUP")
    P += ["  input  logic [31:0] ECOREVNUM",
          "  input  logic S_CPU_CONFIG_ACCESS", "  input  logic S_XSPI_CONFIG_ACCESS",
          "  input  logic DFTCGEN", "  input  logic DFTRSTDISABLE"]
    return P


def sideband_body() -> list[str]:
    B = ["  // ---- low-power Q-Channel clock controllers (one per domain) ----"]
    for d in DOMAINS:
        c, r = DOM[d]
        B += [f"  erbium_noc_qchannel i_qch_{d.lower()} (.clk_i({c}), .rst_ni({r}), .busy_i(1'b0),",
              f"    .qactive_o({d}_QACTIVE), .qreqn_i({d}_QREQn),",
              f"    .qacceptn_o({d}_QACCEPTn), .qdeny_o({d}_QDENY));",
              f"  assign {d}_PMUSNAPSHOTACK = {d}_PMUSNAPSHOTREQ;  // immediate snapshot ack",
              f"  assign {d}_nPMUINTERRUPT  = 1'b1;                // active-low: no PMU irq"]
    B += ["  // ---- P-Channel power controller (pd_0, CPU domain) ----",
          "  erbium_noc_pchannel #(.PSTATE_W(4), .TINIT(37)) i_pch_pd0 (",
          "    .clk_i(clk_cpu), .rst_ni(rstn_cpu),",
          "    .pactive_o(PD_0_PACTIVE), .preq_i(PD_0_PREQ), .pstate_i(PD_0_PSTATE),",
          "    .paccept_o(PD_0_PACCEPT), .pdeny_o(PD_0_PDENY));",
          "  assign PD_0_INTERRUPT = 1'b0; assign PD_0_NS_INTERRUPT = 1'b0;",
          "  // ---- AWAKEUP: each target leg requests downstream wake while issuing ----"]
    for nm, proto, *_ in TARGETS:
        if proto == "axi":
            B.append(f"  assign AXI_MASTER_{nm}_AWAKEUP = AXI_MASTER_{nm}_AWVALID | AXI_MASTER_{nm}_ARVALID;")
    # sink the observability-only inputs so lint stays quiet
    sink = (["CPU_SPIDEN","CPU_NIDEN","CPU_DBGEN","CPU_SPNIDEN","DFTCPUDISABLE",
             "SYSTEM_SPIDEN","SYSTEM_NIDEN","SYSTEM_DBGEN","SYSTEM_SPNIDEN","DFTSYSTEMDISABLE",
             "XSPI_SPIDEN","XSPI_NIDEN","XSPI_DBGEN","XSPI_SPNIDEN","DFTXSPIDISABLE",
             "PERIPH_SPIDEN","PERIPH_NIDEN","PERIPH_DBGEN","PERIPH_SPNIDEN","DFTPERIPHDISABLE",
             "S_CPU_CONFIG_ACCESS","S_XSPI_CONFIG_ACCESS","DFTCGEN","DFTRSTDISABLE",
             "AXI_SLAVE_S_CPU_AWAKEUP","AXI_SLAVE_S_XSPI_AWAKEUP"])
    B.append("  // debug-auth / DFT / config-access / slave-AWAKEUP: observability inputs (v1)")
    B.append("  wire _unused_ok = ^{1'b0, ECOREVNUM, " + ", ".join(sink) + "};")
    return B


APB_PORTS = [
    "  output logic [31:0] APB_MASTER_M_I2C_REG_PADDR",
    "  output logic [2:0]  APB_MASTER_M_I2C_REG_PPROT",
    "  output logic        APB_MASTER_M_I2C_REG_PSEL",
    "  output logic        APB_MASTER_M_I2C_REG_PENABLE",
    "  output logic        APB_MASTER_M_I2C_REG_PWRITE",
    "  output logic [31:0] APB_MASTER_M_I2C_REG_PWDATA",
    "  output logic [3:0]  APB_MASTER_M_I2C_REG_PSTRB",
    "  input  logic        APB_MASTER_M_I2C_REG_PREADY",
    "  input  logic [31:0] APB_MASTER_M_I2C_REG_PRDATA",
    "  input  logic        APB_MASTER_M_I2C_REG_PSLVERR",
]


def header_ports() -> list[str]:
    """The full ordered boundary port list (no trailing commas). Shared by the
    implementation top and the drop-in wrapper so the two never diverge."""
    P: list[str] = []
    for c in DOMAINS: P.append(f"  input  logic {c}_CLK")
    for c in DOMAINS: P.append(f"  input  logic {c}_RESETn")
    for nm, dw, idw in (("S_CPU", 512, 8), ("S_XSPI", 64, 1)):
        P += slave_ports(nm, dw, idw)
    for nm, proto, dw, *_ in TARGETS:
        if proto == "axi":
            P += master_ports(nm, dw)
    P += APB_PORTS
    P += sideband_ports()
    return P


def emit_wrapper() -> str:
    """Integration wrapper: a module named `ni700_ErbiumET` (the SoC's
    interconnect instance name) that wraps the implementation, so it drops in
    with zero edits to the SoC instantiation."""
    o = ["// SPDX-License-Identifier: Apache-2.0",
         "// GENERATED integration wrapper — module name matches the SoC's interconnect",
         "// instance name so it drops in without editing the SoC instantiation.",
         "module ni700_ErbiumET ("]
    P = header_ports()
    o += [p + "," for p in P[:-1]] + [P[-1]]
    o += [");", "  erbium_noc_top u_impl (.*);", "endmodule", ""]
    return "\n".join(o)


def emit() -> str:
    o: list[str] = []
    o.append("// SPDX-License-Identifier: Apache-2.0")
    o.append("// GENERATED — see flow/gen_top.py. Do not edit by hand.")
    o.append("// Configurable open-source AXI4/APB4 network-on-chip.")
    o.append('`include "axi/typedef.svh"')
    o.append("")
    o.append("module erbium_noc_top (")
    P = header_ports()
    o += [p + "," for p in P[:-1]] + [P[-1]]
    o.append(");")
    o.append("")
    o.append("  // ---- per-domain clocks + synchronized resets ----")
    o.append("  logic clk_cpu, clk_sys, clk_xspi, clk_periph;")
    o.append("  assign clk_cpu=CPU_CLK; assign clk_sys=SYSTEM_CLK; assign clk_xspi=XSPI_CLK; assign clk_periph=PERIPH_CLK;")
    o.append("  logic rstn_cpu, rstn_sys, rstn_xspi, rstn_periph;")
    for d, c, rin in (("cpu","clk_cpu","CPU_RESETn"), ("sys","clk_sys","SYSTEM_RESETn"),
                      ("xspi","clk_xspi","XSPI_RESETn"), ("periph","clk_periph","PERIPH_RESETn")):
        o.append(f"  erbium_noc_reset_sync i_rstsync_{d} (.clk_i({c}), .rst_n_async_i({rin}), .rst_n_sync_o(rstn_{d}));")
    # fabric aliases (xbar + width converters live in the CPU domain)
    o.append("  wire clk = clk_cpu; wire rst_n = rstn_cpu;  // fabric domain")
    o.append("")
    # typedefs
    o.append("  // ---- type sets ----")
    o.append(typedefs("axs",  SLV_IW, 512))   # slave-side 512 (cpu + post-upsize xspi), id8
    o.append(typedefs("xs",   SLV_IW, 64))    # xspi ingress 64, id8
    o.append(typedefs("axm",  MST_IW, 512))   # xbar master-side 512, id9
    o.append(typedefs("d64",  MST_IW, 64))    # downsized 64, id9
    o.append(typedefs("d32",  MST_IW, 32))    # downsized 32 (apb feed), id9
    o.append('  `AXI_LITE_TYPEDEF_ALL(lite, logic [31:0], logic [31:0], logic [3:0])')
    o.append("  typedef struct packed { logic [31:0] paddr; logic [2:0] pprot; logic psel;")
    o.append("                          logic penable; logic pwrite; logic [31:0] pwdata; logic [3:0] pstrb; } apb_req_t;")
    o.append("  typedef struct packed { logic pready; logic [31:0] prdata; logic pslverr; } apb_resp_t;")
    o.append("")
    o.append("  typedef struct packed { int unsigned idx; logic [31:0] start_addr; logic [31:0] end_addr; } rule_t;")
    o.append("")
    # slave structs
    o.append("  axs_req_t  cpu_req;  axs_resp_t cpu_resp;")
    o.append("  xs_req_t   xspi_req_raw; xs_resp_t xspi_resp;        // XSPI domain (boundary)")
    o.append("  xs_req_t   xspi_req_cpu; xs_resp_t xspi_resp_cpu;    // after XSPI->CPU cdc")
    o.append("  axs_req_t  xspi_req_up;  axs_resp_t xspi_resp_up;  // after 64->512 upsize")
    o.append("  axs_req_t  xspi_req;     // after address remap")
    o.append("  axs_req_t  [1:0] slv_req; axs_resp_t [1:0] slv_resp;")
    o.append("  axm_req_t  [9:0] mst_req; axm_resp_t [9:0] mst_resp;  // 9 targets + GPV (idx 9)")
    o.append("  rule_t [9:0] addr_map;")
    o.append("")
    # pack cpu (identity id8), xspi raw (id1 zero-extended to id8)
    o += pack_slave("S_CPU", "cpu_req", "cpu_resp", 512, idw=8)
    o.append("")
    o += pack_slave("S_XSPI", "xspi_req_raw", "xspi_resp", 64, idw=1)
    o.append("")
    # xspi ingress clock-domain crossing: XSPI -> CPU (fabric)
    o += _cdc("i_xspi_cdc", "xs", "clk_xspi", "rstn_xspi", "clk_cpu", "rstn_cpu",
              "xspi_req_raw", "xspi_resp", "xspi_req_cpu", "xspi_resp_cpu")
    o.append("")
    # xspi 64->512 upsize (CPU domain)
    o.append("  axi_dw_converter #(")
    o.append("    .AxiMaxReads(8), .AxiSlvPortDataWidth(64), .AxiMstPortDataWidth(512),")
    o.append(f"    .AxiAddrWidth({AW}), .AxiIdWidth({SLV_IW}),")
    o.append("    .aw_chan_t(axs_aw_chan_t), .mst_w_chan_t(axs_w_chan_t), .slv_w_chan_t(xs_w_chan_t),")
    o.append("    .b_chan_t(axs_b_chan_t), .ar_chan_t(axs_ar_chan_t),")
    o.append("    .mst_r_chan_t(axs_r_chan_t), .slv_r_chan_t(xs_r_chan_t),")
    o.append("    .axi_mst_req_t(axs_req_t), .axi_mst_resp_t(axs_resp_t),")
    o.append("    .axi_slv_req_t(xs_req_t), .axi_slv_resp_t(xs_resp_t)")
    o.append("  ) i_xspi_upsize (")
    o.append("    .clk_i(clk), .rst_ni(rst_n),")
    o.append("    .slv_req_i(xspi_req_cpu), .slv_resp_o(xspi_resp_cpu),")
    o.append("    .mst_req_o(xspi_req_up), .mst_resp_i(xspi_resp_up)")
    o.append("  );")
    o.append("")
    # remap xspi addresses into canonical space
    o.append("  function automatic logic [31:0] xspi_remap(logic [31:0] a);")
    o.append("    if (a < 32'h4000_0000)            xspi_remap = a + 32'h4000_0000; // MRAM")
    o.append("    else if (a < 32'h8000_0000)       xspi_remap = a - 32'h3E00_0000; // periph window")
    o.append("    else                              xspi_remap = a;                 // cpu_reg / cfg")
    o.append("  endfunction")
    o.append("  always_comb begin")
    o.append("    xspi_req = xspi_req_up;")
    o.append("    xspi_req.aw.addr = xspi_remap(xspi_req_up.aw.addr);")
    o.append("    xspi_req.ar.addr = xspi_remap(xspi_req_up.ar.addr);")
    o.append("  end")
    o.append("  assign xspi_resp_up = slv_resp[1];")
    o.append("  assign cpu_resp     = slv_resp[0];")
    o.append("  assign slv_req[0]   = cpu_req;")
    o.append("  assign slv_req[1]   = xspi_req;")
    o.append("")
    # addr_map
    for nm, proto, dw, idx, s, e, dom in sorted(TARGETS, key=lambda t: t[3]):
        o.append(f"  assign addr_map[{idx}] = '{{idx:32'd{idx}, start_addr:32'h{s:08X}, end_addr:32'h{e:08X}}}; // {nm}")
    o.append("  assign addr_map[9] = '{idx:32'd9, start_addr:32'hFE00_0000, end_addr:32'hFE01_6000}; // GPV cfg")
    o.append("")
    # xbar
    o.append("  localparam axi_pkg::xbar_cfg_t Cfg = '{")
    o.append("    NoSlvPorts:32'd2, NoMstPorts:32'd10, MaxMstTrans:32'd8, MaxSlvTrans:32'd8,")
    o.append("    FallThrough:1'b0, LatencyMode:axi_pkg::CUT_ALL_AX, PipelineStages:32'd0,")
    o.append(f"    AxiIdWidthSlvPorts:32'd{SLV_IW}, AxiIdUsedSlvPorts:32'd{SLV_IW}, UniqueIds:1'b0,")
    o.append(f"    AxiAddrWidth:32'd{AW}, AxiDataWidth:32'd512, NoAddrRules:32'd10}};")
    o.append("  axi_xbar #(")
    o.append("    .Cfg(Cfg), .ATOPs(1'b0),")
    o.append("    .slv_aw_chan_t(axs_aw_chan_t), .mst_aw_chan_t(axm_aw_chan_t),")
    o.append("    .w_chan_t(axs_w_chan_t),")
    o.append("    .slv_b_chan_t(axs_b_chan_t), .mst_b_chan_t(axm_b_chan_t),")
    o.append("    .slv_ar_chan_t(axs_ar_chan_t), .mst_ar_chan_t(axm_ar_chan_t),")
    o.append("    .slv_r_chan_t(axs_r_chan_t), .mst_r_chan_t(axm_r_chan_t),")
    o.append("    .slv_req_t(axs_req_t), .slv_resp_t(axs_resp_t),")
    o.append("    .mst_req_t(axm_req_t), .mst_resp_t(axm_resp_t),")
    o.append("    .rule_t(rule_t)")
    o.append("  ) i_xbar (")
    o.append("    .clk_i(clk), .rst_ni(rst_n), .test_i(1'b0),")
    o.append("    .slv_ports_req_i(slv_req), .slv_ports_resp_o(slv_resp),")
    o.append("    .mst_ports_req_o(mst_req), .mst_ports_resp_i(mst_resp),")
    o.append("    .addr_map_i(addr_map), .en_default_mst_port_i('0), .default_mst_port_i('0)")
    o.append("  );")
    o.append("")
    # master legs
    EXCL = {"M_MRAM", "M_SRAM"}  # legs the CPU issues exclusives to
    for nm, proto, dw, idx, s, e, dom in TARGETS:
        clk_d, rst_d = DOM[dom]
        o.append(f"  // ---- leg {idx}: {nm} ({proto}, {dw}b, {dom} domain) ----")
        # optional inline exclusive-access monitor on the 512b xbar side
        sreq, sresp = f"mst_req[{idx}]", f"mst_resp[{idx}]"
        if nm in EXCL:
            o.append(f"  axm_req_t  m{idx}_mon_req; axm_resp_t m{idx}_mon_resp;")
            o += [f"  erbium_noc_excl_monitor #(.req_t(axm_req_t), .resp_t(axm_resp_t), .AW({AW})) i_excl_{idx} (",
                  "    .clk_i(clk), .rst_ni(rst_n),",
                  f"    .slv_req_i(mst_req[{idx}]), .slv_resp_o(mst_resp[{idx}]),",
                  f"    .mst_req_o(m{idx}_mon_req), .mst_resp_i(m{idx}_mon_resp)",
                  "  );"]
            sreq, sresp = f"m{idx}_mon_req", f"m{idx}_mon_resp"
        if proto == "axi" and dw == 512:
            o += unpack_master(nm, sreq, sresp)            # MRAM native 512b, CPU domain
        elif proto == "axi" and dw == 64:
            o.append(f"  d64_req_t  m{idx}_req; d64_resp_t m{idx}_resp;")
            o += _dw512to(idx, 64, sreq, sresp)
            if dom == "CPU":
                o += unpack_master(nm, f"m{idx}_req", f"m{idx}_resp")
            else:
                o.append(f"  d64_req_t  m{idx}_cdc_req; d64_resp_t m{idx}_cdc_resp;")
                o += _cdc(f"i_cdc_{idx}", "d64", "clk_cpu", "rstn_cpu", clk_d, rst_d,
                          f"m{idx}_req", f"m{idx}_resp", f"m{idx}_cdc_req", f"m{idx}_cdc_resp")
                o += unpack_master(nm, f"m{idx}_cdc_req", f"m{idx}_cdc_resp")
        elif proto == "apb":
            o += _apb_leg(idx, nm, clk_d, rst_d, sreq, sresp)
        o.append("")
    # ---- GPV discovery block (read-only) on master port 9 ----
    o.append("  // ---- GPV discovery @0xFE00_0000 (read-only, CPU domain) ----")
    o += ["  erbium_noc_gpv #(.req_t(axm_req_t), .resp_t(axm_resp_t), .DW(512)) i_gpv (",
          "    .clk_i(clk), .rst_ni(rst_n),",
          "    .slv_req_i(mst_req[9]), .slv_resp_o(mst_resp[9])",
          "  );"]
    o.append("")
    o += sideband_body()
    o.append("endmodule")
    return "\n".join(o) + "\n"


def _cdc(inst: str, pfx: str, sclk: str, srst: str, dclk: str, drst: str,
         sreq: str, sresp: str, dreq: str, dresp: str) -> list[str]:
    return [
        "  axi_cdc #(",
        f"    .aw_chan_t({pfx}_aw_chan_t), .w_chan_t({pfx}_w_chan_t), .b_chan_t({pfx}_b_chan_t),",
        f"    .ar_chan_t({pfx}_ar_chan_t), .r_chan_t({pfx}_r_chan_t),",
        f"    .axi_req_t({pfx}_req_t), .axi_resp_t({pfx}_resp_t),",
        "    .LogDepth(2), .SyncStages(2)",
        f"  ) {inst} (",
        f"    .src_clk_i({sclk}), .src_rst_ni({srst}), .src_req_i({sreq}), .src_resp_o({sresp}),",
        f"    .dst_clk_i({dclk}), .dst_rst_ni({drst}), .dst_req_o({dreq}), .dst_resp_i({dresp})",
        "  );",
    ]


def _dw512to(idx: int, mst_dw: int, sreq: str, sresp: str) -> list[str]:
    pfx = f"d{mst_dw}"
    return [
        "  axi_dw_converter #(",
        f"    .AxiMaxReads(8), .AxiSlvPortDataWidth(512), .AxiMstPortDataWidth({mst_dw}),",
        f"    .AxiAddrWidth({AW}), .AxiIdWidth({MST_IW}),",
        f"    .aw_chan_t(axm_aw_chan_t), .mst_w_chan_t({pfx}_w_chan_t), .slv_w_chan_t(axm_w_chan_t),",
        "    .b_chan_t(axm_b_chan_t), .ar_chan_t(axm_ar_chan_t),",
        f"    .mst_r_chan_t({pfx}_r_chan_t), .slv_r_chan_t(axm_r_chan_t),",
        f"    .axi_mst_req_t({pfx}_req_t), .axi_mst_resp_t({pfx}_resp_t),",
        "    .axi_slv_req_t(axm_req_t), .axi_slv_resp_t(axm_resp_t)",
        f"  ) i_dw_{idx} (",
        "    .clk_i(clk), .rst_ni(rst_n),",   # downsize stays in fabric/CPU domain
        f"    .slv_req_i({sreq}), .slv_resp_o({sresp}),",
        f"    .mst_req_o(m{idx}_req), .mst_resp_i(m{idx}_resp)",
        "  );",
    ]


def _apb_leg(idx: int, nm: str, clk_d: str, rst_d: str, sreq: str, sresp: str) -> list[str]:
    # 512->32 downsize in CPU domain, CDC CPU->PERIPH, then lite+apb in PERIPH domain
    L = [
        f"  d32_req_t  m{idx}_req; d32_resp_t m{idx}_resp;",
        f"  d32_req_t  m{idx}_cdc_req; d32_resp_t m{idx}_cdc_resp;",
        "  lite_req_t i2c_lite_req; lite_resp_t i2c_lite_resp;",
        "  apb_req_t  i2c_apb_req;  apb_resp_t  i2c_apb_resp;",
        "  rule_t i2c_rule;",
        "  assign i2c_rule = '{idx:32'd0, start_addr:32'h0200_2000, end_addr:32'h0200_3000};",
    ]
    L += _dw512to(idx, 32, sreq, sresp)
    L += _cdc(f"i_cdc_{idx}", "d32", "clk_cpu", "rstn_cpu", clk_d, rst_d,
              f"m{idx}_req", f"m{idx}_resp", f"m{idx}_cdc_req", f"m{idx}_cdc_resp")
    L += [
        "  axi_to_axi_lite #(",
        f"    .AxiAddrWidth({AW}), .AxiDataWidth(32), .AxiIdWidth({MST_IW}), .AxiUserWidth(1),",
        "    .AxiMaxWriteTxns(1), .AxiMaxReadTxns(1), .FallThrough(1'b1),",
        "    .full_req_t(d32_req_t), .full_resp_t(d32_resp_t),",
        "    .lite_req_t(lite_req_t), .lite_resp_t(lite_resp_t)",
        f"  ) i_axi2lite_{idx} (",
        f"    .clk_i({clk_d}), .rst_ni({rst_d}), .test_i(1'b0),",
        f"    .slv_req_i(m{idx}_cdc_req), .slv_resp_o(m{idx}_cdc_resp),",
        "    .mst_req_o(i2c_lite_req), .mst_resp_i(i2c_lite_resp)",
        "  );",
        "  axi_lite_to_apb #(",
        "    .NoApbSlaves(1), .NoRules(1), .AddrWidth(32), .DataWidth(32),",
        "    .axi_lite_req_t(lite_req_t), .axi_lite_resp_t(lite_resp_t),",
        "    .apb_req_t(apb_req_t), .apb_resp_t(apb_resp_t), .rule_t(rule_t)",
        f"  ) i_lite2apb_{idx} (",
        f"    .clk_i({clk_d}), .rst_ni({rst_d}),",
        "    .axi_lite_req_i(i2c_lite_req), .axi_lite_resp_o(i2c_lite_resp),",
        "    .apb_req_o(i2c_apb_req), .apb_resp_i(i2c_apb_resp), .addr_map_i(i2c_rule)",
        "  );",
        "  assign APB_MASTER_M_I2C_REG_PADDR   = i2c_apb_req.paddr;",
        "  assign APB_MASTER_M_I2C_REG_PPROT   = i2c_apb_req.pprot;",
        "  assign APB_MASTER_M_I2C_REG_PSEL    = i2c_apb_req.psel;",
        "  assign APB_MASTER_M_I2C_REG_PENABLE = i2c_apb_req.penable;",
        "  assign APB_MASTER_M_I2C_REG_PWRITE  = i2c_apb_req.pwrite;",
        "  assign APB_MASTER_M_I2C_REG_PWDATA  = i2c_apb_req.pwdata;",
        "  assign APB_MASTER_M_I2C_REG_PSTRB   = i2c_apb_req.pstrb;",
        "  assign i2c_apb_resp.pready  = APB_MASTER_M_I2C_REG_PREADY;",
        "  assign i2c_apb_resp.prdata  = APB_MASTER_M_I2C_REG_PRDATA;",
        "  assign i2c_apb_resp.pslverr = APB_MASTER_M_I2C_REG_PSLVERR;",
    ]
    return L


if __name__ == "__main__":
    rtl = Path(__file__).resolve().parent.parent / "rtl"
    impl = rtl / "erbium_noc_top.sv"
    impl.write_text(emit())
    print(f"wrote {impl} ({len(emit().splitlines())} lines)")
    wrap = rtl / "ni700_ErbiumET.sv"
    wrap.write_text(emit_wrapper())
    print(f"wrote {wrap} (drop-in alias, {len(emit_wrapper().splitlines())} lines)")
