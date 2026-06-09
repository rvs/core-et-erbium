# Missing test: Firmware update skip → deep sleep


| Address      | Value | Meaning         |
|--------------|-------|-----------------|
| `0x7FFFD000` | `0x1` | OTP_FWUP copy 0 |
| `0x7FFFD008` | `0x1` | OTP_FWUP copy 1 |
| `0x7FFFD010` | `0x1` | OTP_FWUP copy 2 |
| `0x7FFFD018` | `0x1` | OTP_FWUP copy 3 |
| `0x7FFFD020` | `0x1` | OTP_FWUP copy 4 |

MRAM_FWUP_PC at `0x40000018` is zero (default). OTP_CFGR is zero (pmode=0).

**Mailbox0:** `0x17EF9F`
**Path:** MRAM init → no early jump → enter fwup, PC=0 skip → trim(0) → dividers(0) → deep sleep
**PASS signal:** Yes
