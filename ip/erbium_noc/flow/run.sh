#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Regenerate, prefix, lint, and run the erbium_noc functional smoke.
# Filelists are file-relative, so they are included with `-F` (Verilator resolves
# the inner ../deps , ../rtl paths relative to the filelist's own directory).
set -euo pipefail
cd "$(dirname "$0")/.."

WAIVERS="-Wno-fatal -Wno-WIDTH -Wno-WIDTHCONCAT -Wno-UNOPTFLAT -Wno-SELRANGE \
         -Wno-UNSIGNED -Wno-CASEINCOMPLETE -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-UNUSEDSIGNAL"

echo "== regenerate filelists + RTL + TB harness =="
python3 flow/gen_flist.py
python3 flow/gen_top.py
python3 flow/gen_tb.py

echo "== prefix all internal design units with erbium_noc_ (keeps public top ni700_ErbiumET) =="
python3 flow/prefix.py

echo "== lint/elaborate the drop-in top (ni700_ErbiumET) =="
verilator --lint-only --sv $WAIVERS -F flow/erbium_noc.f --top-module ni700_ErbiumET

echo "== build + run functional smoke =="
verilator --binary --timing --sv $WAIVERS \
  -F flow/erbium_noc.f +incdir+tb tb/erbium_noc_tb.sv \
  --top-module erbium_noc_tb -o sim_ni700
./obj_dir/sim_ni700
