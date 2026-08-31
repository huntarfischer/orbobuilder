# Hecate Pass 5 — Named Relation Ritual Gate

**Date:** 2026-08-30  
**Branch:** `feature/orbo-lawbook-2026-08-30`  
**Law authority:** `ORBO_LAWBOOK.md`  
**Implementation head:** `5d57789252a89a9d65c168d6058878559f9c12f7`  
**Status:** PROVEN / GREEN

## Scope

Pass 5 adds one named RELATE ritual on top of the already-proven generic Hecate relation table.

```text
Door III / LINK
    exact linked Timespine points
        ↓
Hecate RELATE
        ↓
momentToMoment
        ↓
existing RelationTable
```

The pass does not create new astrology, a new relation result type, or a second relation engine.

## Implemented

### `HecateRelationRitual`

The named RELATE ritual vocabulary now contains exactly:

```text
momentToMoment
```

### Participant law

`momentToMoment` requires exactly two linked participants.

If the supplied `SpineLinkSet` contains any other participant count, Hecate fails explicitly with:

```text
HecateRelationRitualError.participantCount
```

### Delegation law

When the participant count is valid, `momentToMoment` delegates directly to the existing generic:

```swift
Hecate.relate(link, through: doorIII)
```

Therefore the named ritual inherits the already-proven relation behavior without duplicating:

- Door III resolution
- participant order
- Ring separation geometry
- relation row construction
- `RelationTable`
- Door III failures

A Door III failure remains a Door III failure and is not translated, substituted, or repaired by the ritual layer.

## Proof added

`HecateRelationTests` now proves:

1. `momentToMoment` returns exactly the existing generic raw `RelationTable`.
2. `momentToMoment` requires exactly two participants.
3. `momentToMoment` surfaces Door III failure unchanged.
4. All prior generic RELATE tests remain green.

## Upstream proof

GitHub Actions ran against implementation head:

```text
5d57789252a89a9d65c168d6058878559f9c12f7
```

Results:

```text
OrboSpineLinkResolutionTests
4 tests
0 failures

SpineLinkTests
3 tests
0 failures

HecateLinkTests
4 tests
0 failures

HecateRelationTests
8 tests
0 failures

runner package suite
757 tests
0 failures
0 unexpected
```

The runner package suite retains the pre-existing CI-only exclusion of `RingTests.swift`.

## Development-Mac package acceptance

Full local package acceptance was completed on 2026-08-30 at implementation head.

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
769 tests
0 failures
0 unexpected

All tests
769 tests
0 failures
0 unexpected
```

Target reported by the test runner:

```text
x86_64-apple-macos14.0
```

Pass 5 is therefore accepted as **PROVEN / GREEN**.

## Explicitly not in Pass 5

```text
Synastry ritual
Synchronic ritual
Composite cast
new RelationTable shape
new Ring geometry
Titan SUMMON
interpretation
persistence
Door II / Chronos changes
Door III / Link redesign
```

Pass 6 may begin only by explicit approval.
