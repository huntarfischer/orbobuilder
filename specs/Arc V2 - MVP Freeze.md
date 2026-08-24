# Arc V2 — MVP Freeze

**Status:** FROZEN  
**Date:** 2026-08-24  
**Branch:** `feature/arc-v2`  
**Qualified suite:** 375 tests, 0 failures  
**Scope:** Arc itself only. Titan's Pass / Lachesis integration remains future work.

---

## Frozen doctrine

> **Arc is the Titan of the half-arc. It governs the composite of lawful zodiacal coordinates and, from any fixed coordinate, reveals the complete 180° field of positions that composition can ever produce.**

Arc's primitive is composition:

```text
lawful coordinate A
+
lawful coordinate B
        │
        ▼
       ARC
        │
        ▼
canonical half-arc / composite state
```

Away from exact opposition, Arc uses the signed shortest displacement from A to B and places the result halfway along that arc.

At exact opposition, neither half-arc is privileged. Arc returns the **Seam** with both ±90° poles lawful.

Fixing A and allowing B to occupy the full zodiac yields exactly the 180° Arc centered on A. Therefore **Cast is the complete range of Compose**.

Synchronic Time is one sanctioned application:

```text
native coordinate
+
mundane celestial coordinate
        │
        ▼
       ARC
        │
        ▼
synchronic coordinate
```

The Mundane Timespine supplies the changing second coordinate. Arc does not own chronology, UT, interpretation, or artifact manufacture.

---

## Frozen MVP surface

### A. Exact Core

Arc accepts lawful whole-arcsecond input coordinates over:

```text
1,296,000 input positions
```

Arc stores outputs on the exact half-arcsecond circle:

```text
2,592,000 output ticks
```

Canonical Arc truth is integer-backed.

Arc supports:

```text
CAST
coordinate → ArcField

COMPOSE
coordinate + coordinate → ArcComposite
```

`ArcComposite` is either:

```text
position(exact ArcPosition)
```

or:

```text
seam(two exact poles)
```

The frozen core includes:

- conjunction preservation;
- exact half-distance / Half-Life;
- positive and negative shortest-arc composition;
- exact half-arcsecond outputs for odd source arcseconds;
- rotational symmetry;
- symmetric composition away from the Seam;
- exact two-pole Seam at opposition;
- no natal, temporal, Hearth, Tapestry, Spine, Ring, Mater, or Tympan prerequisite.

### B. 360 Arc Grid

Arc projects a Cast onto exactly the canonical 360 absolute degree windows:

```text
0–1
1–2
...
359–360
```

The grid is an address layer over exact Arc truth, not a competing coordinate system.

Each degree cell records:

```text
possible
impossible
or exact partial possible subrange

optional center
optional -90° pole
optional +90° pole
```

Subdegree truth remains exact to the half-arcsecond tick.

There is no first-class 720-row Arc zodiac.

### C. Generic Subjects

Arc may receive a minimal coordinate-bearing subject with:

```text
identity
provenance
exact lawful coordinate
```

Arc preserves identity and provenance but never interprets them.

The same coordinate always produces the same Arc geometry regardless of whether its provenance is planet-shaped, angle-shaped, Lot-shaped, Ring-target-shaped, or another later lawful source.

Multiple subjects at the same coordinate may share one calculated field while retaining distinct identities/provenance.

Arc does not decide whether a downstream derived point should itself be midpointed or instead recalculated from a completed chart. That remains the owning doctrine's decision.

---

## Frozen architectural boundary

Arc MVP now exists as:

```text
                    ARC

          ┌──────────┴──────────┐
          │                     │
        CAST                 COMPOSE
          │                     │
one coordinate             two coordinates
          │                     │
          ▼                     ▼
180° possibility         exact composite
field                    position / Seam
          │
          ▼
       PROJECT
          │
          ▼
      360° ARC GRID
```

Arc may operate on lawful coordinates without knowing where they came from.

What Arc does **not** own remains frozen:

```text
aspects / relationship doctrine        Ring
zodiacal condition                     Mater
whole-sign form / house governance     Tympan
geography / horizon                    Terra + Horizon
chronology / temporal search           Timespine + Loom
artifact manufacture                   Hephaestus
interpretation                         downstream readers
```

---

## Qualified implementation

Implementation files:

```text
native/OrboCore/Sources/OrboCore/Arc/Arc.swift
native/OrboCore/Sources/OrboCore/Arc/ArcGrid.swift
native/OrboCore/Sources/OrboCore/Arc/ArcSubject.swift
```

Tests:

```text
native/OrboCore/Tests/OrboCoreTests/ArcTests.swift
native/OrboCore/Tests/OrboCoreTests/ArcGridTests.swift
native/OrboCore/Tests/OrboCoreTests/ArcSubjectTests.swift
```

Build sequence:

```text
fbe96662  Freeze Arc MVP composition doctrine and build plan
da89a527  Build Arc MVP Pass A exact core
678cc241  Add Arc MVP Pass A exact-core tests
58ee5c24  Fix Arc grid degree-tick accessor
019037f0  Add Arc MVP Pass B grid tests
ed9c6734  Build Arc MVP Pass C generic subjects
03a51721  Add Arc MVP Pass C generic-subject tests
```

Qualification supplied from terminal on 2026-08-24:

```text
Test Suite 'OrboCorePackageTests.xctest' passed
Executed 375 tests, with 0 failures (0 unexpected)

Test Suite 'All tests' passed
Executed 375 tests, with 0 failures (0 unexpected)
```

---

## Explicitly deferred

Arc MVP does not yet include:

```text
Clotho integration
Titan's Pass
Lachesis integration
Tympan → Mater → Ring → Arc orchestration
provisional natal compile
ArcPass over real Tapestry-bound data
synchronic house-system intersection
real Ring-target handoff
Mundane Timespine traversal
Synchronic Spine manufacture
Synchronic Synastry manufacture
synchronic Lot derivation
interpretation
```

---

## Next pass

The next architectural work is not another Arc-law expansion.

It follows real data through the agreed Titan's Pass:

```text
CLOTHO
   ↓
LACHESIS
   ↓
TYMPAN
   ↓
MATER
   ↓
RING
   ↓
provisional compiled natal plane
   ↓
copy lawful coordinate-bearing matter
   ↓
ARC
   ↓
ArcPass
   ↓
LACHESIS
   ↓
TAPESTRY
```

That pass may expand the set of lawful coordinates presented to Arc, but it must not require a different Arc law.
