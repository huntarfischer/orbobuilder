# Door III Pass 2 — Point Resolution Gate

**Date:** 2026-08-30  
**Branch:** `feature/orbo-lawbook-2026-08-30`  
**Law authority:** `ORBO_LAWBOOK.md`  
**Status:** PROVEN / GREEN

## Scope

Pass 2 completes only the OrboSpine side of Door III / Relation / Link.

```text
SpineLinkSet
    2+ exact members
        ↓
OrboSpine Link
        ↓
2+ resolved OrboSpine points
```

No Hecate ritual logic is added in this pass.

## Implemented

### `OrboSpinePointAddress`

OrboSpine now owns two exact point-address forms for Link:

```text
occurrence
    exact chronological occurrence binding

celestialOccurrence
    body
    directional celestial degree
    exact occurrence binding
```

The celestial form intentionally retains its occurrence binding so repeated passages through the same zodiacal degree remain distinct points.

The serialized `memberIdentity` syntax is an OrboSpine implementation detail and is not frozen as universal Spine law.

### `OrboSpinePoint`

A resolved Door III point is one full immutable OrboSpine cross-section:

```text
exact occurrence
11 canonical celestial coordinates
Terra Marrow
source Link identity
```

Door III does not decide which fields a later ritual will use.

### `OrboSpineLink`

The living OrboSpine Link implementation:

- resolves exactly the members supplied by `SpineLinkSet`
- requires members to belong to the addressed OrboSpine
- preserves caller order
- returns the full Timespine point for each member
- verifies that a celestial occurrence address actually matches the named celestial state at that occurrence
- rejects unknown or foreign members
- does not search for substitutes
- computes no relation
- performs no cast
- summons no Titan
- performs no interpretation

`OrboSpineRuntime.link` exposes this Door III implementation from the assembled runtime without duplicating Timespine truth.

## Proof added

`OrboSpineLinkResolutionTests` proves:

1. 2+ exact points resolve in caller order.
2. occurrence and celestial-occurrence address forms remain distinct and round-trip.
3. a celestial address must match its claimed celestial state at its exact occurrence.
4. foreign and unrecognized members fail instead of causing fallback/search behavior.
5. each resolved point returns the canonical full celestial cross-section.

Existing `SpineLinkTests` and `HecateLinkTests` remain unchanged.

## Acceptance proof

Development-Mac package acceptance was completed on 2026-08-30 from the checked-out branch head containing Pass 2.

Command from `native/OrboCore`:

```text
swift test
```

Result:

```text
TympanTests
19 tests
0 failures

OrboCorePackageTests.xctest
759 tests
0 failures
0 unexpected

All tests
759 tests
0 failures
0 unexpected
```

Target reported by the test runner:

```text
x86_64-apple-macos14.0
```

Pass 2 is therefore accepted as **PROVEN / GREEN**.

## Explicitly not in Pass 2

```text
Hecate RELATE grammar
Hecate CAST routing changes
RelationTable
Synastry
Composite
Titan SUMMON
cross-Spine resolver orchestration
Door II / Chronos changes
Link universal vocabulary redesign
```

Pass 3 may begin only by explicit approval.
