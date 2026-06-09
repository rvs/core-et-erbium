#!/usr/bin/env python3
"""Generate ordered file lists from the vendored PULP Bender.yml manifests.

Emits two filelists in flow/:
  - deps.flist     : the vendored third-party AXI/cell library (deps) only
  - erbium_noc.f    : the full IP — vendored deps + leaf blocks + the top and the
                     `ni700_ErbiumET` integration wrapper

All paths are written **relative to the filelist's own directory** (flow/), e.g.
`../deps/axi/src/axi_pkg.sv`, `+incdir+../deps/axi/include`. Include them with a
file-relative directive (Verilator `-F`, or the equivalent in your tool) so the
paths resolve regardless of the invocation directory.
"""
from __future__ import annotations
import os
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML required")

ROOT = Path(__file__).resolve().parent.parent
FLOW = ROOT / "flow"
DEPS = ROOT / "deps"
PKG_ORDER = ["tech_cells_generic", "common_cells", "axi"]
SKIP_TARGETS = {"simulation", "test", "synth_test", "fpga"}
SKIP_PATH = ("/deprecated/", "/fpga/")


def rel(p: Path) -> str:
    """Path relative to the flist directory (flow/)."""
    return os.path.relpath(p, FLOW)


def _target_blocked(node) -> bool:
    tgt = node.get("target")
    if tgt is None:
        return False
    names: list[str] = []
    if isinstance(tgt, str):
        names = [tgt]
    elif isinstance(tgt, dict):
        for v in tgt.values():
            names += v if isinstance(v, list) else [v]
    return bool(names) and all(n in SKIP_TARGETS for n in names)


def _walk(node, out: list[str]) -> None:
    if isinstance(node, str):
        if not any(s in ("/" + node) for s in SKIP_PATH):
            out.append(node)
    elif isinstance(node, list):
        for item in node:
            _walk(item, out)
    elif isinstance(node, dict):
        if _target_blocked(node):
            return
        if "files" in node:
            _walk(node["files"], out)
        elif "sources" in node:
            _walk(node["sources"], out)


def pulp_lines() -> list[str]:
    lines: list[str] = []
    for pkg in PKG_ORDER:
        data = yaml.safe_load((DEPS / pkg / "Bender.yml").read_text())
        inc = DEPS / pkg / "include"
        if inc.is_dir():
            lines.append(f"+incdir+{rel(inc)}")
        files: list[str] = []
        _walk(data.get("sources", []), files)
        for f in files:
            p = DEPS / pkg / f
            if p.suffix == ".sv" and p.exists():
                lines.append(rel(p))
    seen: set[str] = set()
    return [l for l in lines if not (l in seen or seen.add(l))]


def main() -> None:
    deps = pulp_lines()
    (FLOW / "deps.flist").write_text("\n".join(deps) + "\n")
    nsrc = sum(1 for l in deps if l.endswith(".sv"))
    print(f"wrote {FLOW/'deps.flist'} : {nsrc} sources, {len(deps)-nsrc} incdirs")

    # consolidated full-IP filelist: deps -> leaf blocks -> top -> integration wrapper
    full = list(deps)
    full.append("// --- leaf blocks ---")
    for f in sorted((ROOT / "rtl" / "blocks").glob("*.sv")):
        full.append(rel(f))
    full.append("// --- top + ni700_ErbiumET integration wrapper ---")
    full.append(rel(ROOT / "rtl" / "erbium_noc_top.sv"))
    full.append(rel(ROOT / "rtl" / "ni700_ErbiumET.sv"))
    (FLOW / "erbium_noc.f").write_text("\n".join(full) + "\n")
    print(f"wrote {FLOW/'erbium_noc.f'} : {sum(1 for l in full if l.endswith('.sv'))} sources "
          f"(include with a file-relative directive, e.g. Verilator -F)")


if __name__ == "__main__":
    main()
