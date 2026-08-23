# Horae - Temporal Adapter MVP

**Status:** FROZEN / PROVEN  
**Target:** Orbo 1.0 native  
**Branch:** `feature/horae-mvp`  
**Baseline:** `feature/hestia-orbospine-transplant`

## Purpose

> Horae expose the complete OrboSpine state at one UT, whether that UT is the current real-world moment or an explicitly selected moment.

Horae are the presentation-neutral temporal adapter between OrboSpine Door I (`Locate`) and future visualization systems.

```text
ORBOSPINE
    |
I. LOCATE
    |
  HORAE
    |
HoraeOutput
    |
    v
future visualization owner
```

Horae do not become a fourth OrboSpine door. They post up at Door I and consume its canonical answers.

## Door I boundary

Every Spine exposes three stable access ports:

```text
I    LOCATE
II   LIBRARY
III  LINK
```

Horae use only:

```text
I    LOCATE
```

Horae do not use Library or Link and do not change any OrboSpine access law.

`OrboSpineLocate` remains the owner of coordinate navigation, interpolation, exact station topology, Bone bounds, directional degree, and Terra Marrow refinement.

Horae never recalculate those facts.

## Two entrances

Horae expose two ways to supply the same temporal coordinate.

```text
LIVE
current real-world UT

SEEK
explicit UT
```

Both resolve through the same output path.

```text
LIVE ----\
          > HoraeOutput
SEEK ----/
```

`SEEK` is the architectural term. Scrubbing is one future interface behavior that may generate repeated seeks.

## One output

```text
HoraeOutput
    julianDay
    celestial
        [OrboSpineCelestialCoordinate]
    terra
        TerraMarrowSample
```

The celestial collection is populated from:

```text
OrboSpineContract.canonicalBodies
```

Horae reuse existing OrboSpine types. They do not create duplicate owners for longitude, motion, directional degree, navigation cell, Terra turn, or Terra tilt.

## Ownership

Horae own:

```text
LIVE
SEEK
OUTPUT
```

Horae do not own:

- astronomy
- interpolation
- OrboSpine storage
- Bone bounds
- station topology
- Chronos navigation or search
- Library queries
- Link relations
- playback speed
- playhead state
- gestures
- animation cadence
- screen geometry
- camera
- visual style
- rendering
- interpretation
- event recognition

## Governing laws

1. Horae consume OrboSpine Door I (`Locate`) and no other Spine door in the MVP.
2. Horae never alter OrboSpine or create another access port.
3. One UT produces one canonical `HoraeOutput`.
4. LIVE and SEEK produce the same output shape.
5. LIVE is only an automatically supplied UT, not a second truth path.
6. SEEK is deterministic: position on the Bone determines output; path does not.
7. Horae perform no astronomy or interpolation of their own.
8. Horae preserve the existing OrboSpine coordinate and Terra types unchanged.
9. Requests outside the Bone follow Locate failure law. Horae do not clamp, wrap, guess, or fabricate.
10. Horae own no presentation. A future visualizer consumes their output.

## Frozen MVP surface

```text
Horae

live()               -> HoraeOutput
seek(to: JulianDay)  -> HoraeOutput
```

LIVE obtains the current `AbsoluteInstant`, converts it to `JulianDay`, and calls SEEK. There is one truth path.

SEEK asks `OrboSpineLocate` for every canonical body and Terra Marrow at the supplied UT, then packages those existing values as `HoraeOutput`.

## Build record

```text
Stage 0   contract                     PROVEN
Stage 1   HoraeOutput                  PROVEN
Stage 2   SEEK                         PROVEN
Stage 3   reversibility                PROVEN
Stage 4   LIVE                         PROVEN
Stage 5   Spine boundary integration   PROVEN
Stage 6   demonstration stress         PROVEN
Stage 7   freeze                       COMPLETE
```

### Stage 1 - HoraeOutput

Proves the adapter preserves canonical OrboSpine coordinate and Terra types, including directional-degree and Terra precision.

### Stage 2 - SEEK

Proves one supplied UT yields the direct Locate cross-section for every canonical body plus Terra, and that Locate failures propagate unchanged.

### Stage 3 - Reversibility

Proves:

```text
T1 -> T2 -> T3 -> T1
```

returns the same output at `T1`, and that approaching a UT from either direction or jumping directly to it produces the same result.

> Position determines output. Path does not.

### Stage 4 - LIVE

Proves:

```text
LIVE at known T == SEEK to T
```

LIVE introduces no second calculation path and inherits SEEK failure law.

### Stage 5 - Spine boundary integration

Proves Horae remain transparent at:

- exact station topology
- whole-degree crossing
- 1850 Terra source seam
- 2050 Terra source seam
- Bone start
- immediately before Bone end
- exact half-open Bone end

No special Horae boundary logic was required.

### Stage 6 - Demonstration stress

Proves no drift, stale state, or mode contamination through:

- 100 dense forward seeks followed by the same 100 in reverse
- arbitrary jumps with repeated return to an anchor UT
- alternating LIVE and SEEK
- 100 repeated seeks to the exact same UT

No production changes were required for Stages 3, 5, or 6.

## Canonical home

Horae live as an OrboSystem sibling:

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Horae/
native/OrboCore/Tests/OrboCoreTests/OrboSystem/Horae/
```

They do not live inside `OrboSystem/OrboSpine/`.

Production surface:

```text
Horae/
    Horae.swift
    HoraeOutput.swift
```

Proof surface:

```text
Horae/
    HoraeStage1Tests.swift
    HoraeStage2Tests.swift
    HoraeStage3Tests.swift
    HoraeStage4Tests.swift
    HoraeStage5Tests.swift
    HoraeStage6Tests.swift
```

## Final proof

Final accumulated local package pass on 2026-08-23:

```text
swift test

Executed 304 tests
0 failures
0 unexpected
```

Horae contributes 18 XCTest methods across Stages 1-6. The full OrboCore package passed together.

## Branch audit

Before the freeze update, `feature/horae-mvp` compared with `feature/hestia-orbospine-transplant` as:

```text
10 commits ahead
0 commits behind
```

All changed files were confined to:

```text
OrboSystem/Horae/**
OrboCoreTests/OrboSystem/Horae/**
specs/Horae - Temporal Adapter MVP.md
```

No OrboSpine, Hermes, Moirai, Hestia, Hephaestus, or Dioscuri file was changed by the Horae MVP.

## Endgame

Horae are built for demonstrating the Timespine.

Their long-term role is to expose a stable temporal signal that interchangeable visualization systems can consume.

```text
REAL TIME -----------\
                      \
EXPLICIT UT / SEEK ----> HORAE
                         |
                         v
                    HoraeOutput
                         |
              +----------+----------+
              |          |          |
              v          v          v
          Astrolabe   3D Spine   future view
```

The visualizer may later own playhead position, scrubber state, playback rate, animation cadence, projection, and rendering. None of those responsibilities belong to Horae v1.

## Frozen acceptance

```text
Horae post up at OrboSpine Door I: Locate.
They accept LIVE or SEEK.
Both resolve to one neutral HoraeOutput.
They repeat Spine truth without recalculating it.
They do not own how that truth is drawn.
```

> **Door I supplies the truth. Horae carry the signal. Visualization comes later.**

No further Horae MVP work belongs here without an explicit new requirement.
