# Notices & third-party components

`erbium_noc` is licensed under the Apache License 2.0 (see `LICENSE`).

## Vendored third-party library (`deps/`)

This repository vendors a third-party SystemVerilog AXI / common-cell / generic
tech-cell library, used for the crossbar, clock-domain crossings, width
converters and the AXI-to-APB bridge:

| Path | Component | License |
|---|---|---|
| `deps/axi/` | AXI infrastructure (crossbar, CDC, width/ID converters, AXI-Lite/APB bridges) | Solderpad Hardware License v0.51 |
| `deps/common_cells/` | FIFOs, arbiters, address decoders, synchronizers | Solderpad Hardware License v0.51 |
| `deps/tech_cells_generic/` | generic clock/SRAM technology cells | Solderpad Hardware License v0.51 |

The Solderpad Hardware License v0.51 is an Apache-2.0-based permissive license.
Each vendored package retains its upstream `LICENSE` file and copyright headers;
pinned upstream revisions are recorded in `deps/DEPS.lock`. The Solderpad and
Apache-2.0 licenses are compatible for redistribution — retain both license
texts in any redistribution.

## Naming

All internal design units in this IP carry a `erbium_noc_` prefix to avoid name
collisions when integrated alongside other IP. The single exception is the
integration wrapper module `ni700_ErbiumET`, which keeps its name so it slots
into the host design's existing instantiation.
