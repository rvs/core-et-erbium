# erbium_noc

An open-source, configurable **AXI4/APB4 network-on-chip (NoC)**. It connects a
small set of bus initiators to a set of memory/peripheral targets across several
asynchronous clock domains, with width conversion, per-initiator address
remapping, exclusive-access support, low-power handshakes, and a read-only
discovery block.

## Features

- **2 AXI4 initiators**, **9 targets** (8 AXI4 + 1 APB4) routed through a single
  internal crossbar.
- **512-bit internal fabric** with per-leg width conversion (e.g. 512↔64, 512→32
  to the APB leg); each target runs at its native width.
- **4 asynchronous clock domains** (CPU / SYSTEM / XSPI / PERIPH) bridged with
  clock-domain-crossing FIFOs and per-domain reset synchronizers.
- **Per-initiator static address remap** — each initiator sees the targets at its
  own base addresses, decoded into one canonical internal map.
- **AXI exclusive access** (load-linked / store-conditional) via an inline
  exclusive-access monitor on the memory legs.
- **Low-power Q-Channel** clock controllers (per domain) and a **P-Channel**
  power controller.
- **Read-only discovery block** at the configuration base returning a
  magic / version / interface-count word.
- Unmapped addresses return a decode error (DECERR).

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the topology, address map,
clocks and port summary.

## Layout

```
rtl/ni700_ErbiumET.sv        integration wrapper (instantiate this)
rtl/erbium_noc_top.sv    generated NoC top
rtl/blocks/                  leaf blocks (Q/P-Channel, reset sync, discovery,
                             exclusive monitor)
deps/                        vendored third-party AXI / cell library (see NOTICE.md)
flow/gen_top.py              top generator (data-driven from the topology tables)
flow/gen_flist.py            filelist generator
flow/gen_tb.py               testbench-harness generator
flow/prefix.py               applies the erbium_noc_ name prefix to internal units
flow/erbium_noc.f             full file list (file-relative paths)
flow/deps.flist              vendored-library file list
flow/run.sh                  regenerate -> prefix -> lint -> run smoke
constraints/*.sdc            clock constraints (4 async domains)
tb/                          functional testbench
docs/ARCHITECTURE.md         topology, address map, ports
```

## Build & run

```sh
# regenerate, prefix, lint and run the functional smoke in one step
flow/run.sh

# or just elaborate the top from the (file-relative) filelist:
verilator --lint-only --sv -Wno-fatal -Wno-WIDTH -Wno-WIDTHCONCAT \
  -Wno-UNOPTFLAT -Wno-SELRANGE -Wno-UNSIGNED -Wno-UNUSEDSIGNAL \
  -F flow/erbium_noc.f --top-module ni700_ErbiumET
```

The functional testbench checks routing, per-initiator remap, decode errors,
the discovery read, the full LL/SC exclusive sequence, the clock-domain
crossings, a burst transfer, and the Q/P-Channel handshakes (17 checks).

## Integration

Instantiate **`ni700_ErbiumET`** (the wrapper) — it exposes the flat AXI4/APB4
ports, the four clock/reset pairs, and the sideband (Q/P-Channel, debug-auth,
PMU, AWAKEUP, DFT, ECOREVNUM).

Add the IP to your build with a **file-relative** filelist include — the paths in
`flow/erbium_noc.f` are relative to the filelist's own directory, so include it
with Verilator `-F` (or your tool's file-relative equivalent):

```
-F path/to/erbium_noc/flow/erbium_noc.f
```

Every internal module/package/interface carries a `erbium_noc_` prefix to avoid
name collisions with other IP in your design; only the top `ni700_ErbiumET`
keeps its name. The design is SystemVerilog (packed structs) — use an
SV-capable compiler.

## License

This IP is licensed **Apache-2.0** (see `LICENSE`). It vendors a third-party
AXI / cell library under the Solderpad Hardware License v0.51 — see `NOTICE.md`
and `deps/*/LICENSE`.
