#!/usr/bin/env python3
"""Record the Pass 5 P22 proof result and promote the Native Port Manifest only on success."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STATUS_PATH = ROOT / "tools/pass5/p22-verification-status.json"
MANIFEST_PATH = ROOT / "specs/Native Port Manifest.md"

LEDGER_OLD = "| Mundane Timespine | PENDING | PENDING | OrboCore / MundaneTimespine | PASS 5 READY |"
LEDGER_NEW = "| Mundane Timespine | REPRODUCE | STRUCTURAL | OrboCore / MundaneTimespine | P22 BODY SUBSTRATE PROVEN / RUNTIME READER PENDING |"
CARD_MARKER = "# Pass 5 Component: Mundane Timespine (P22)"

CARD = r'''

---

# Pass 5 Component: Mundane Timespine (P22)

## Prototype / construction source

```text
prototype temporal archaeology
specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md
tools/pass5/p22-data/
tools/pass5/p22-results/
```

## What it currently does

The corrected Pass 5 body substrate records eleven body-specific celestial clocks across the common half-open P22 Pluto Zeitgeist, with every stored celestial-time occurrence bound to civic UT and enough simultaneous celestial markers to remain non-repeating inside P22.

## Actual law

```text
planetary celestial time = focal zodiacal position
planetary celestial time ↔ civic UT occurrence
separate body tables = one universal Mundane Timespine
P22 = first common shipping span
stations = turns in celestial-time direction
user-facing motion = direct / retrograde
```

The Timespine is native-independent universal chronology. It contains no user, natal chart, Horizon, interpretation, or Connectome meaning.

## What is proven

```text
11 focal body tables
P22 half-open bounds
1 degree resolution Sun through Mars
0.1 degree resolution Jupiter through Pluto + True North Node
Sun-first companion marker law for every non-Sun body
zero repeated selected marker keys across P22
33-bit civic offset requirement
committed body/motion files bound by SHA-256
station and retrograde table counts agree with the P22 summary
```

## Current dependencies

Construction evidence descends from the qualified Pass 4 Ephemeris/Forge source work. The native P22 contract depends only on existing OrboCore domain types required to keep body identity and Julian Day explicit.

## Current consumers

```text
OrboLab construction readout
Pass 5 tests
future runtime Timespine reader
future Loom / Horizon / AstroDNA resolver mating surfaces
```

## Known tests / fixtures

```text
tools/pass5/verify_p22_substrate.py
native/OrboCore/Tests/OrboCoreTests/MundaneTimespineTests.swift
.github/workflows/pass5-p22-verification.yml
```

The committed P22 data itself is the construction specimen. The retired temporal-knot golden fixture is not carried forward.

## User-visible consequence

Once the runtime reader is earned, every ordinary Orbo celestial read inside the supported P22 span will descend from this universal chronology rather than routine Ephemeris queries.

## 4R

**REPRODUCE**

## Why

The universal shipped-chronology problem is correct and permanent, but the earlier Pass 5 time-knot implementation imposed the wrong representation. P22 re-establishes the component from the actual celestial-time law and measured body behavior rather than transposing that discarded implementation.

## Swift Sanding

```text
body strings
-> MundaneBody canonical enum

implicit body order
-> MundaneBody.canonicalOrder

loose resolution/marker notes
-> MundaneTimespineBodyContract values

open/closed range ambiguity
-> explicit half-open P22 contains law

Timespine codec-number confusion
-> no Timespine codec number in the body contract

AstroDNA codec 4
-> remains the independent canonical AstroDNA identity contract
```

No ornamental protocol or speculative runtime reader has been added before its mating surface is earned.

## Native destination

```text
OrboCore / MundaneTimespine
```

## Native dependencies

Current body-contract layer:

```text
JulianDay
Planet only where a MundaneBody maps to a physical Planet
```

The True North Node remains a MundaneBody without being forced into Planet.

## Native mating surface

Current earned surface:

```text
P22 span
canonical body order
per-body celestial resolution
per-body whole-degree companion markers
construction record counts
shared motion-table identities
half-open range check
```

Bidirectional celestial-time/civic-time runtime reads are the next native mating surface and are not claimed complete here.

## Parity standard

**STRUCTURAL**

The proof target is the corrected P22 construction artifact and its independently verified astronomical build evidence, not the retired time-knot implementation.

## Proof method

```text
direct committed-file verification
+
SHA-256 artifact identity
+
row/schema/order/uniqueness invariants
+
station and retrograde consistency
+
native contract-to-artifact comparisons
+
accumulated OrboCore XCTest
+
OrboCore Apple-Swift build
+
OrboLab build against live OrboCore
```

## Proof evidence

The Pass 5 P22 verification workflow reported both the repository-substrate and native-proof gates successful for the source commit recorded in `tools/pass5/p22-verification-status.json`.

## Status

**P22 BODY SUBSTRATE PROVEN / RUNTIME READER PENDING**

This status proves the body substrate and its native construction contract only. It does not yet seal the complete Mundane Timespine or authorize skipping the remaining Pass 5 gates.
'''


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--substrate-result", required=True)
    parser.add_argument("--native-result", required=True)
    parser.add_argument("--source-commit", required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    success = args.substrate_result == "success" and args.native_result == "success"
    result = {
        "sourceCommit": args.source_commit,
        "repositorySubstrate": args.substrate_result,
        "nativeProof": args.native_result,
        "status": "success" if success else "failure",
    }
    STATUS_PATH.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    if not success:
        return

    text = MANIFEST_PATH.read_text(encoding="utf-8")
    text = text.replace("**Last updated:** 2026-08-16", "**Last updated:** 2026-08-17", 1)

    if LEDGER_OLD in text:
        text = text.replace(LEDGER_OLD, LEDGER_NEW, 1)
    elif LEDGER_NEW not in text:
        raise SystemExit("Mundane Timespine ledger row is not in an expected state")

    if CARD_MARKER not in text:
        text += CARD

    MANIFEST_PATH.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
