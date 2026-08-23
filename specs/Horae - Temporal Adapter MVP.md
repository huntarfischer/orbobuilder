# Horae - Temporal Adapter MVP

**Status:** Stage 0 contract / awaiting review  
**Target:** Orbo 1.0 native  
**Branch:** `feature/horae-mvp`  
**Baseline:** `feature/hestia-orbospine-transplant`

## Purpose

Prove one thing:

> Horae can expose the complete OrboSpine state at one UT, whether that UT is the current real-world moment or an explicitly selected moment.

Horae exist to make OrboSpine demonstrable. They are the presentation-neutral temporal adapter between OrboSpine Door I (`Locate`) and future visualization systems.

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

For the MVP, Horae do not use Library or Link and do not change any OrboSpine access law.

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

Both resolve through the same underlying output path.

```text
LIVE ----\
          > HoraeOutput
SEEK ----/
```

`SEEK` is the architectural term. Scrubbing is one future interface behavior that may generate repeated seeks.

## One output

Horae produce one presentation-neutral temporal signal.

Conceptually:

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

## MVP build stages

```text
Stage 0   contract
Stage 1   HoraeOutput
Stage 2   SEEK
Stage 3   reversibility proof
Stage 4   LIVE
Stage 5   Spine boundary integration
Stage 6   demonstration stress
Stage 7   freeze
```

### Stage 0 - Contract

Freeze the Door I relationship, two inputs, one output, ownership, and explicit non-goals.

No production code.
No tests.
No OrboSpine changes.

### Stage 1 - HoraeOutput

Define the minimum neutral output using existing OrboSpine types.

### Stage 2 - SEEK

Implement:

```text
seek(to: JulianDay) -> HoraeOutput
```

At one UT, ask Locate for every canonical body and Terra Marrow, then assemble the output.

### Stage 3 - Reversibility

Prove:

```text
T1 -> T2 -> T3 -> T1
```

returns the same output at `T1` both times.

Also prove that approaching the same UT from either direction or jumping directly to it produces the same output.

### Stage 4 - LIVE

Implement:

```text
live() -> HoraeOutput
```

LIVE obtains current UT and routes it through the same internal output path as SEEK.

Required proof:

```text
LIVE at known T == SEEK to T
```

### Stage 5 - Spine boundary integration

Add thin integration proofs at representative OrboSpine boundaries, including exact station topology, Terra source seams, degree crossings, and Bone edges.

Do not duplicate Locate's own interpolation or topology tests.

### Stage 6 - Demonstration stress

Feed dense forward and reverse seek sequences, jumps, returns, and LIVE/SEEK alternation.

This proves that Horae can supply a rapidly changing neutral signal to a future visualizer without drift, stale values, or accumulated state.

### Stage 7 - Freeze

Freeze the MVP surface.

Conceptually:

```text
Horae

live()               -> HoraeOutput
seek(to: JulianDay)  -> HoraeOutput
```

A shared internal `output(at:)` may exist as implementation detail.

## Canonical home

When implementation begins, Horae should live as an OrboSystem sibling:

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Horae/
native/OrboCore/Tests/OrboCoreTests/OrboSystem/Horae/
```

Horae do not live inside `OrboSystem/OrboSpine/`.

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

## Stage 0 acceptance

Stage 0 is ready to freeze when we can truthfully say:

```text
Horae post up at OrboSpine Door I: Locate.
They accept LIVE or SEEK.
Both resolve to one neutral HoraeOutput.
They repeat Spine truth without recalculating it.
They do not own how that truth is drawn.
```

> **Door I supplies the truth. Horae carry the signal. Visualization comes later.**
