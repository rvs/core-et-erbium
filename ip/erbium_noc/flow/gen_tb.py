#!/usr/bin/env python3
"""Emit a TB harness (net decls + DUT instance) by parsing the generated top's
port list, so the testbench doesn't hand-wire ~330 flat ports."""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOP = ROOT / "rtl" / "erbium_noc_top.sv"

def main() -> None:
    txt = TOP.read_text().splitlines()
    # grab the port block between 'module erbium_noc_top (' and the matching ');'
    start = next(i for i, l in enumerate(txt) if l.startswith("module erbium_noc_top"))
    body = []
    for l in txt[start + 1:]:
        if l.strip() == ");":
            break
        body.append(l)
    ports = []  # (name, width_decl)  width_decl is '' or '[..]'
    rx = re.compile(r"^\s*(input|output)\s+logic\s*(\[[^\]]*\])?\s*([A-Za-z_0-9]+)\s*,?\s*$")
    for l in body:
        m = rx.match(l)
        if m:
            ports.append((m.group(3), m.group(2) or ""))
    out = ["// SPDX-License-Identifier: Apache-2.0",
           "// GENERATED TB harness (see flow/gen_tb.py). Net decls + DUT instance.",
           "// Drive/observe these `tb_<PORT>` nets from the test body."]
    for name, wd in ports:
        out.append(f"  logic {wd + ' ' if wd else ''}tb_{name};")
    out.append("")
    out.append("  erbium_noc_top i_dut (")
    out += [f"    .{n}(tb_{n})," for n, _ in ports[:-1]]
    n, _ = ports[-1]
    out.append(f"    .{n}(tb_{n})")
    out.append("  );")
    dst = ROOT / "tb" / "dut_harness.svh"
    dst.write_text("\n".join(out) + "\n")
    print(f"wrote {dst} : {len(ports)} ports")

if __name__ == "__main__":
    main()
