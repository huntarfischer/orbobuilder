# Arc V2 — MVP Plan

**Status:** APPROVED FOR BUILD  
**Date:** 2026-08-24  
**Branch:** `feature/arc-v2`  
**Scope:** Arc itself only. Stop before the Titan's Pass / Lachesis integration.

---

## Doctrine amendment

This plan sharpens the frozen Pass 0 doctrine without changing Arc's half-arc law, Seam, Half-Life, universal availability, or downstream ownership boundaries.

> **Arc is the Titan of the half-arc. It governs the composite of lawful zodiacal coordinates and, from any fixed coordinate, reveals the complete 180° field of positions that composition can ever produce.**

The primitive is composition:

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

For every non-opposition pair, Arc uses the signed shortest displacement from A to B and places the result halfway along that arc.

At exact opposition, the two half-arcs are equal. Arc returns the Seam with both ±90° poles valid and neither privileged.

### Cast is the full range of Compose

Fix coordinate A and allow B to occupy every lawful longitude. The set of every possible `Arc(A, B)` result is exactly the 180° field centered on A:

```text
A - 90°  ←  A  →  A + 90°
```

Therefore Arc owns both:

```text
COMPOSE
A + B → exact half-arc state

CAST
A → complete 180° composite possibility field
```

The complementary half of the zodiac is equally deterministic: it is impossible composite space for that fixed anchor.

### Synchronic Time is a sanctioned application of composition

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

The Mundane Timespine supplies the changing second coordinate. Arc does not own mundane chronology, UT, temporal search, or manifestation schedules.

Synchronic astrology is therefore the native continuously composited with celestial time.

### Coordinate universality

Arc is indifferent to why a lawful coordinate exists. Later Orbo work may present coordinates originating from planets, angles, Lots or other admitted derived points, Ring target coordinates, or other lawful sources.

Arc carries identity/provenance but does not interpret it.

This does **not** mean every derived point in a completed composite or synchronic chart should itself be midpointed. Downstream doctrine still decides which derived points are recalculated from the completed chart.

---

# MVP

Arc MVP proves three capabilities and nothing more.

## Pass A — Exact Core

Build the smallest universal Arc authority.

### CAST

Input:

```text
exact lawful zodiacal coordinate
```

Output:

```text
center
+90° pole
-90° pole
complete 180° possible field
complementary impossible field
```

### COMPOSE

Input:

```text
exact lawful coordinate A
exact lawful coordinate B
```

Output:

```text
ordinary exact composite position
```

or, at exact opposition:

```text
SEAM
both exact ±90° poles
neither privileged
```

### Precision

Canonical input fidelity is whole arcsecond. Arc output fidelity is half-arcsecond because halving an odd whole-arcsecond displacement produces a half-arcsecond result.

```text
1,296,000 whole-arcsecond input positions
2,592,000 half-arcsecond output ticks
```

Canonical Arc truth is integer-backed. No floating-point value is canonical storage.

### Pass A acceptance

- conjunction composes to the anchor;
- positive and negative shortest arcs halve exactly;
- 60° → 30°, 120° → 60°;
- exact opposition returns the Seam and both poles;
- odd arcsecond displacements preserve half-arcsecond output;
- rotation of both inputs rotates the result by the same amount;
- `Cast(A)` contains every ordinary `Compose(A, B)` result;
- Arc requires no AstroDNA, Hearth, Tapestry, Spine, UT, Ring, Mater, or Tympan.

---

## Pass B — 360 Arc Grid

Project one Cast across the canonical absolute zodiacal address space:

```text
0–1
1–2
2–3
...
359–360
```

The 360 rows are semantic degree windows, not a loss of precision.

Each row must be able to state Arc truth such as:

```text
impossible
possible
partially possible
contains center
contains +90° pole
contains -90° pole
exact subdegree boundary
```

Exact minute / second / half-second substructure remains beneath the degree address.

There is no rival 720-row zodiac.

### Pass B acceptance

- exactly 360 canonical degree windows;
- possible + impossible account for the complete zodiac;
- exact non-whole-degree anchors cut boundary rows at exact subaddresses;
- center and both poles land in the correct degree windows;
- wrap across 0°/360° is exact;
- the grid never changes the underlying exact Cast.

---

## Pass C — Generic Subjects

Prove Arc is coordinate-generic without integrating the Titan's Pass.

A minimal Arc subject carries:

```text
identity / provenance
exact lawful coordinate
```

Use fixtures representing several future origins:

```text
planet-shaped coordinate
angle-shaped coordinate
Lot-shaped coordinate
Ring-target-shaped coordinate
```

Arc must apply the identical Cast / Compose law to all of them and preserve provenance without learning their meanings.

### Pass C acceptance

- same coordinate → same Arc geometry regardless of provenance;
- multiple identities may reference the same calculated field;
- Arc never branches on planet / angle / Lot / Ring semantics;
- no Titan's Pass or Lachesis behavior is introduced.

---

# Explicitly out of MVP

```text
Lachesis integration
Titan's Pass
Clotho integration
Tympan interaction
Mater qualification
Ring target generation
synchronic house-system selection
Mundane Timespine traversal
UT / civic chronology
Loom
Synchronic Spine manufacture
Synchronic Synastry manufacture
synchronic Lot derivation
interpretation
```

---

# Freeze boundary

Arc MVP ends when this exists and is green:

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

Then Arc is frozen and the next work follows real data through the integrated Titan's Pass:

```text
Tympan → Mater → Ring → provisional compile → Arc → Lachesis → Tapestry
```

That later pass may expand what lawful coordinates are presented to Arc, but it must not require a different Arc law.
