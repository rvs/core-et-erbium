# Commands

| Commands               | 1S  | 4S  | 8D(1.0) | 8D(2.0) |
| ---                    | --- | --- | ---     | ---     |
| Read SFDP              | 5Ah |     | 5Ah     |         |
| Read (0L)              | 03h |     |         |         |
| Read Register          |     |     | 65h     | FFh     |
| Write Register         |     |     | 71h     | 7Fh     |
| Enter Power Down       |     |     | B9h     |         |
| Exit Power Down        |     |     | ABh     |         |
| Enter default mode(1S) |     |     | FF      |         |
| Read Memory            |     |     |         | BFh     |
| Write Memory           |     |     |         | 3F      |

2.0 uses the same command for multiple operations. Will need additional study to figure out the exact differences...


## Not supported in Phase 1

Wrapped bursts (Phase 2)
XIP (Phase 2)
Write Enable
Page/Sector Erase Program
