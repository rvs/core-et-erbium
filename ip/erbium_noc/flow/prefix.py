#!/usr/bin/env python3
"""Add a `erbium_noc_` prefix to every internal design-unit name (module, package,
interface, primitive) across the IP so it can coexist with other AXI/NoC IP in a
chip without name collisions.

- The public top `ni700_ErbiumET` is left unchanged (it is the SoC's interconnect
  instance name — the integration wrapper is instantiated by that exact name).
- Every other internal unit is prepended with the prefix
  (e.g. `axi_xbar` -> `erbium_noc_axi_xbar`, `axi_pkg` -> `erbium_noc_axi_pkg`);
  units already carrying the prefix are left as-is.
- Renames definitions AND all references (instantiations, `pkg::` scopes,
  `import`, interface uses, `endmodule : name` labels) via whole-word replace.
- Only file *contents* change; filenames and the filelist are untouched.
- Idempotent: names already prefixed are skipped.
"""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCAN_DIRS = ["deps", "rtl", "tb"]
PREFIX = "erbium_noc_"
KEEP = {"ni700_ErbiumET"}          # public top — never rename

_DEF = re.compile(r'^\s*(?:module|package|interface|primitive)\s+([A-Za-z_]\w*)', re.M)


def _strip_comments(t: str) -> str:
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    t = re.sub(r'//[^\n]*', '', t)
    return t


def _new_name(n: str) -> str | None:
    if n in KEEP or n.startswith(PREFIX):
        return None
    return PREFIX + n


def main() -> None:
    files: list[Path] = []
    for d in SCAN_DIRS:
        for ext in ("*.sv", "*.svh", "*.v"):
            files += list((ROOT / d).rglob(ext))

    names: set[str] = set()
    for f in files:
        for m in _DEF.finditer(_strip_comments(f.read_text(errors="ignore"))):
            names.add(m.group(1))

    # Build old->new mapping. For names already prefixed (e.g. the vendored
    # library was renamed in a prior run), also map their un-prefixed source
    # form, so that freshly regenerated RTL — which still references the plain
    # names (axi_pkg, axi_xbar, ...) — is renamed consistently. This keeps
    # `gen_*` + prefix reproducible no matter the current tree state.
    mapping: dict[str, str] = {}
    for n in names:
        if n in KEEP:
            continue
        if n.startswith(PREFIX):
            rest = n[len(PREFIX):]
            if rest and rest not in KEEP and rest not in names:
                mapping[rest] = n
        else:
            nn = _new_name(n)
            if nn:
                mapping[n] = nn
    if not mapping:
        print("nothing to prefix (already normalised)")
        return

    alt = "|".join(re.escape(n) for n in sorted(mapping, key=len, reverse=True))
    rx = re.compile(r'\b(' + alt + r')\b')
    repl = lambda m: mapping[m.group(1)]
    # mask out comments and string literals so only *code* identifiers are renamed
    mask = re.compile(r'(//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*")', re.S)

    def rewrite(text: str) -> str:
        parts = mask.split(text)          # odd indices = comments/strings (kept verbatim)
        for i in range(0, len(parts), 2):
            parts[i] = rx.sub(repl, parts[i])
        return "".join(parts)

    changed = 0
    for f in files:
        txt = f.read_text(errors="ignore")
        new = rewrite(txt)
        if new != txt:
            f.write_text(new)
            changed += 1
    print(f"prefixed {len(mapping)} design-unit names across {changed} files; "
          f"kept public top {sorted(KEEP)}")


if __name__ == "__main__":
    main()
