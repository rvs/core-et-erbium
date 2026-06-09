# Erbium Bootrom Emulator Tests

All tests require MRAM bridge status pre-loaded at `0x02001008` with value `0x0F00` (all 4 banks ready).

Zephyr ELF: built from `zephyr-erbium-uart` worktree, `feat/erbium-shakti-uart-aif-main` branch, `samples/hello_world`, interrupt-driven UART. Entry point `0x40000200`.

OTP registers use 5-copy majority voting. Each register occupies 5 consecutive 8-byte slots.

OTP_CFGR value `0x80000000001FFFC0` = pmode=1, osc=0, cpu_div=0x1F, sys_div=0x1F, periph_div=0x1F (reset defaults).

---

## Test 1: Normal cold boot

Bootrom ELF: `ErbiumROM_test1.elf` (built with `-DCOSIM`, writes validation0 on deep sleep).

No pre-loading needed (OTP defaults to zero).

**Mailbox0:** `0x17C79F`
**Path:** MRAM init → no early jump → no fwup → trim(0) → dividers(0) → deep sleep
**PASS signal:** Yes

---

## Test 2: Firmware update skip → Zephyr payload

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

| Address      | Value                | Meaning              |
|--------------|----------------------|----------------------|
| `0x7FFFD000` | `0x1`                | OTP_FWUP copy 0      |
| `0x7FFFD008` | `0x1`                | OTP_FWUP copy 1      |
| `0x7FFFD010` | `0x1`                | OTP_FWUP copy 2      |
| `0x7FFFD018` | `0x1`                | OTP_FWUP copy 3      |
| `0x7FFFD020` | `0x1`                | OTP_FWUP copy 4      |
| `0x7FFFD028` | `0x80000000001FFFC0` | OTP_CFGR copy 0      |
| `0x7FFFD030` | `0x80000000001FFFC0` | OTP_CFGR copy 1      |
| `0x7FFFD038` | `0x80000000001FFFC0` | OTP_CFGR copy 2      |
| `0x7FFFD040` | `0x80000000001FFFC0` | OTP_CFGR copy 3      |
| `0x7FFFD048` | `0x80000000001FFFC0` | OTP_CFGR copy 4      |
| `0x40000020` | `0x40FFFFF0`         | MRAM_PAYL_SP         |
| `0x40000028` | `0x40000200`         | MRAM_PAYL_PC (Zephyr)|

**Mailbox0:** `0xFEF9F`
**Path:** MRAM init → no early jump → enter fwup, PC=0 skip → trim + dividers → jump to Zephyr
**PASS signal:** Yes

---

## Test 3: Firmware update jump → Zephyr

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

| Address      | Value              | Meaning              |
|--------------|--------------------|----------------------|
| `0x7FFFD000` | `0x1`              | OTP_FWUP copy 0      |
| `0x7FFFD008` | `0x1`              | OTP_FWUP copy 1      |
| `0x7FFFD010` | `0x1`              | OTP_FWUP copy 2      |
| `0x7FFFD018` | `0x1`              | OTP_FWUP copy 3      |
| `0x7FFFD020` | `0x1`              | OTP_FWUP copy 4      |
| `0x40000010` | `0x40FFFFF0`       | MRAM_FWUP_SP         |
| `0x40000018` | `0x40000200`       | MRAM_FWUP_PC (Zephyr)|

**Mailbox0:** `0x1F9F`
**Path:** MRAM init → no early jump → enter fwup → jump to Zephyr
**PASS signal:** Yes

---

## Test 4: Payload mode → Zephyr

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

| Address      | Value                | Meaning              |
|--------------|----------------------|----------------------|
| `0x7FFFD028` | `0x80000000001FFFC0` | OTP_CFGR copy 0      |
| `0x7FFFD030` | `0x80000000001FFFC0` | OTP_CFGR copy 1      |
| `0x7FFFD038` | `0x80000000001FFFC0` | OTP_CFGR copy 2      |
| `0x7FFFD040` | `0x80000000001FFFC0` | OTP_CFGR copy 3      |
| `0x7FFFD048` | `0x80000000001FFFC0` | OTP_CFGR copy 4      |
| `0x40000020` | `0x40FFFFF0`         | MRAM_PAYL_SP         |
| `0x40000028` | `0x40000200`         | MRAM_PAYL_PC (Zephyr)|

**Mailbox0:** `0xFC79F`
**Path:** MRAM init → no early jump → no fwup → trim + dividers → jump to Zephyr
**PASS signal:** Yes

---

## Test 5: Early jump SRAM → Zephyr

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

**BLOCKED:** ChipMode not writable in emulator.

| Address      | Value        | Meaning              |
|--------------|--------------|----------------------|
| `0x02000060` | `0x08`       | ChipMode: bootload=01 (SRAM) |
| `0x0200CFF0` | `0x40FFFFF0` | SRAM_EJMP_SP         |
| `0x0200CFF8` | `0x40000200` | SRAM_EJMP_PC (Zephyr)|

**Mailbox0:** `0x3F`
**Path:** MRAM init → early jump SRAM → jump to Zephyr

---

## Test 6: Early jump MRAM → Zephyr

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

**BLOCKED:** ChipMode not writable in emulator.

| Address      | Value        | Meaning              |
|--------------|--------------|----------------------|
| `0x02000060` | `0x10`       | ChipMode: bootload=10 (MRAM) |
| `0x40000000` | `0x40FFFFF0` | MRAM_EJMP_SP         |
| `0x40000008` | `0x40000200` | MRAM_EJMP_PC (Zephyr)|

**Mailbox0:** `0x35F`
**Path:** MRAM init → MRAM wait → early jump MRAM → jump to Zephyr

---

## Test 7: Payload with 1 corrupt OTP_CFGR copy

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

Copy 4 has pmode=0 (corrupted). Voter corrects: 4 vs 1 → pmode=1.

| Address      | Value                | Meaning              |
|--------------|----------------------|----------------------|
| `0x7FFFD028` | `0x80000000001FFFC0` | OTP_CFGR copy 0      |
| `0x7FFFD030` | `0x80000000001FFFC0` | OTP_CFGR copy 1      |
| `0x7FFFD038` | `0x80000000001FFFC0` | OTP_CFGR copy 2      |
| `0x7FFFD040` | `0x80000000001FFFC0` | OTP_CFGR copy 3      |
| `0x7FFFD048` | `0x0`                | OTP_CFGR copy 4 (CORRUPT) |
| `0x40000020` | `0x40FFFFF0`         | MRAM_PAYL_SP         |
| `0x40000028` | `0x40000200`         | MRAM_PAYL_PC (Zephyr)|

**Mailbox0:** `0xFC79F`
**Path:** MRAM init → no early jump → no fwup → trim + dividers → jump to Zephyr
**PASS signal:** Yes

---

## Test 8: Payload with 2 corrupt OTP_CFGR copies

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

Copies 3-4 have pmode=0 (corrupted). Voter corrects: 3 vs 2 → pmode=1.

| Address      | Value                | Meaning              |
|--------------|----------------------|----------------------|
| `0x7FFFD028` | `0x80000000001FFFC0` | OTP_CFGR copy 0      |
| `0x7FFFD030` | `0x80000000001FFFC0` | OTP_CFGR copy 1      |
| `0x7FFFD038` | `0x80000000001FFFC0` | OTP_CFGR copy 2      |
| `0x7FFFD040` | `0x0`                | OTP_CFGR copy 3 (CORRUPT) |
| `0x7FFFD048` | `0x0`                | OTP_CFGR copy 4 (CORRUPT) |
| `0x40000020` | `0x40FFFFF0`         | MRAM_PAYL_SP         |
| `0x40000028` | `0x40000200`         | MRAM_PAYL_PC (Zephyr)|

**Mailbox0:** `0xFC79F`
**Path:** MRAM init → no early jump → no fwup → trim + dividers → jump to Zephyr
**PASS signal:** Yes

---

## Test 9: FWUP with 1 corrupt OTP_FWUP copy

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

Copy 4 is zero (corrupted). Voter corrects: 4 vs 1 → fwup=1.

| Address      | Value              | Meaning              |
|--------------|--------------------|----------------------|
| `0x7FFFD000` | `0x1`              | OTP_FWUP copy 0      |
| `0x7FFFD008` | `0x1`              | OTP_FWUP copy 1      |
| `0x7FFFD010` | `0x1`              | OTP_FWUP copy 2      |
| `0x7FFFD018` | `0x1`              | OTP_FWUP copy 3      |
| `0x7FFFD020` | `0x0`              | OTP_FWUP copy 4 (CORRUPT) |
| `0x40000010` | `0x40FFFFF0`       | MRAM_FWUP_SP         |
| `0x40000018` | `0x40000200`       | MRAM_FWUP_PC (Zephyr)|

**Mailbox0:** `0x1F9F`
**Path:** MRAM init → no early jump → enter fwup → jump to Zephyr
**PASS signal:** Yes

---

## Test 10: FWUP with 2 corrupt OTP_FWUP copies

Bootrom ELF: `ErbiumROM.elf`. Payload ELF: `zephyr.elf`.

Copies 3-4 are zero (corrupted). Voter corrects: 3 vs 2 → fwup=1.

| Address      | Value              | Meaning              |
|--------------|--------------------|----------------------|
| `0x7FFFD000` | `0x1`              | OTP_FWUP copy 0      |
| `0x7FFFD008` | `0x1`              | OTP_FWUP copy 1      |
| `0x7FFFD010` | `0x1`              | OTP_FWUP copy 2      |
| `0x7FFFD018` | `0x0`              | OTP_FWUP copy 3 (CORRUPT) |
| `0x7FFFD020` | `0x0`              | OTP_FWUP copy 4 (CORRUPT) |
| `0x40000010` | `0x40FFFFF0`       | MRAM_FWUP_SP         |
| `0x40000018` | `0x40000200`       | MRAM_FWUP_PC (Zephyr)|

**Mailbox0:** `0x1F9F`
**Path:** MRAM init → no early jump → enter fwup → jump to Zephyr
**PASS signal:** Yes

---

## Test 11: Payload with 3 corrupt OTP_CFGR copies (expected: no payload)

Bootrom ELF: `ErbiumROM_test1.elf` (COSIM).

3 copies have pmode=0 (corrupted). Voter resolves pmode=0: 2 vs 3 → corruption wins. Bootrom skips payload and enters deep sleep.

| Address      | Value                | Meaning              |
|--------------|----------------------|----------------------|
| `0x7FFFD028` | `0x80000000001FFFC0` | OTP_CFGR copy 0      |
| `0x7FFFD030` | `0x80000000001FFFC0` | OTP_CFGR copy 1      |
| `0x7FFFD038` | `0x0`                | OTP_CFGR copy 2 (CORRUPT) |
| `0x7FFFD040` | `0x0`                | OTP_CFGR copy 3 (CORRUPT) |
| `0x7FFFD048` | `0x0`                | OTP_CFGR copy 4 (CORRUPT) |
| `0x40000020` | `0x40FFFFF0`         | MRAM_PAYL_SP         |
| `0x40000028` | `0x40000200`         | MRAM_PAYL_PC (Zephyr)|

**Mailbox0:** `0x17C79F` (same as T1 — deep sleep, no payload)
**Path:** MRAM init → no early jump → no fwup → trim(0) → dividers(0) → deep sleep
**PASS signal:** Yes (COSIM deep sleep validation0)

---

## Mailbox0 bit map

### Status bits [23:0]

| Bit | State            | T1 | T2 | T3 | T4 | T5 | T6 |
|-----|------------------|----|----|----|----|----|-----|
|  0  | BROM_START       | x  | x  | x  | x  | x  | x  |
|  1  | MRAM_START       | x  | x  | x  | x  | x  | x  |
|  2  | MRAM_DSLEEP      | x  | x  | x  | x  | x  | x  |
|  3  | MRAM_DONE        | x  | x  | x  | x  | x  | x  |
|  4  | EJMP_START       | x  | x  | x  | x  | x  | x  |
|  5  | EJMP_SRAM        |    |    |    |    | x  |    |
|  6  | EJMP_MRAM        |    |    |    |    |    | x  |
|  7  | EJMP_END         | x  | x  | x  | x  |    |    |
|  8  | MWAIT_START      | x  | x  | x  | x  |    | x  |
|  9  | MWAIT_DONE       | x  | x  | x  | x  |    | x  |
| 10  | FWUP_START       | x  | x  | x  | x  |    |    |
| 11  | FWUP_MRAM        |    | x  | x  |    |    |    |
| 12  | FWUP_MRAM1       |    |    | x  |    |    |    |
| 13  | FWUP_MRAM2       |    | x  |    |    |    |    |
| 14  | FWUP_END         | x  | x  |    | x  |    |    |
| 15  | CFGR_START       | x  | x  |    | x  |    |    |
| 16  | CFGR_READ        | x  | x  |    | x  |    |    |
| 17  | OSC_START        | x  | x  |    | x  |    |    |
| 18  | OSC_END          | x  | x  |    | x  |    |    |
| 19  | PAYL             |    | x  |    | x  |    |    |
| 20  | DSLEEP           | x  |    |    |    |    |    |

T7-T8 have the same mailbox as T4. T9-T10 have the same mailbox as T3. T11 has the same mailbox as T1.

### Error bits [31:24]

| Bit | Error        |
|-----|--------------|
| 24  | OKAY         |
| 25  | UNREACHABLE  |
| 26  | TRAP         |

### Expected values

| Test | Mailbox0     | PASS signal |
|------|--------------|-------------|
| T1   | `0x17C79F`   | Yes         |
| T2   | `0x0FEF9F`   | Yes         |
| T3   | `0x001F9F`   | Yes         |
| T4   | `0x0FC79F`   | Yes         |
| T5   | `0x00003F`   | Blocked     |
| T6   | `0x00035F`   | Blocked     |
| T7   | `0x0FC79F`   | Yes         |
| T8   | `0x0FC79F`   | Yes         |
| T9   | `0x001F9F`   | Yes         |
| T10  | `0x001F9F`   | Yes         |
| T11  | `0x17C79F`   | Yes (deep sleep) |
