# Arc V2 — Pass 0 Doctrine

**Status:** FROZEN  
**Date:** 2026-08-24  
**Branch:** `feature/arc-v2`  
**Scope:** doctrine only; no implementation

Arc is the fourth foundational Ovum law alongside Ring, Tympan, and Mater.

---

# 0. The statement

> **Arc is the law of the half-arc.**

Given two zodiacal coordinates, Arc determines their canonical halfway state within a 180° field.

For Synchronic Time, Arc is applied correspondingly between the fixed natal coordinate of a body and that body's mundane coordinate through time:

```text
N_P       fixed natal coordinate
M_P(t)    mundane coordinate through time

          ARC
           │
           ▼

S_P(t)    synchronic coordinate
```

Arc does not interpret the resulting coordinate. It owns the geometry by which a mundane position is refracted through its natal anchor.

---

# 1. Law One — Arc owns the half-arc

Given two zodiacal coordinates, Arc owns their canonical half-arc geometry.

For ordinary non-opposition states:

```text
δ = signed shortest displacement from N to M

S = N + δ / 2
```

The synchronic point occupies the halfway position between natal anchor and mundane position along the shorter arc.

Arc Core is not inherently natal, mundane, or synchronic. Its primitive is:

```text
coordinate A
+
coordinate B
        │
        ▼
       ARC
        │
        ▼
canonical half-arc state
```

Synchronic Time is the sanctioned temporal application:

```text
N_P × M_P(t) → S_P(t)
```

Broader midpoint applications may use the same primitive later, but are not part of Arc V1/V2 implementation scope.

## Universal system availability

Arc is a system law before it is a personal law.

Given legal Orbo coordinates, Arc must be usable without requiring:

```text
AstroDNA
Tapestry
Hearth
native identity
Natal Spine
Synchronic Spine
personal artifact manufacture
```

Arc therefore remains available to Orbo for any lawful coordinate query whether the coordinates are mundane, natal, synchronic, or otherwise admitted by the system.

Synchronic Refraction is one native × moment application of Arc. It is not the condition of Arc's existence or availability.

No personal authorization, product entitlement, or forged Spine may gate access to Arc as a foundational Orbo law.

---

# 2. Law Two — the native anchor is the center

For Synchronic Time, the natal coordinate is the center of the permitted Arc.

The synchronic placement is confined to the 180° field centered on that natal anchor.

Normalized in Orbo degrees:

```text
pole A = N + 90°  mod 360
pole B = N + 270° mod 360
```

The natal point is the center, not an endpoint.

The synchronic placement can never leave this half-zodiacal field. Whatever mundane degree exists, its corresponding synchronic state is deterministically knowable from:

```text
Natal anchor
+
Mundane coordinate
+
Arc
```

---

# 3. Law Three — Refraction creates Synchronic Time

Refraction is Arc's same-body natal × mundane temporal application.

For every admitted body or coordinate P:

```text
N_P = fixed natal coordinate
M_P(t) = mundane coordinate

S_P(t) = Arc[N_P, M_P(t)]
```

Therefore, if the Mundane Timespine already contains the mundane chronology and AstroDNA supplies the natal anchors, the synchronic chronology is deterministically knowable across the same supported temporal range.

```text
MUNDANE TIMESPINE
        +
NATAL ASTRODNA
        │
        ▼
       ARC
        │
        ▼
SYNCHRONIC CHRONOLOGY
```

Arc supplies the law.

Hephaestus materializes that law across time as the durable **Synchronic Spine**.

Arc does not reopen the Ephemeris.

---

# 4. Law Four — exact opposition is the Seam

When the mundane coordinate exactly opposes its natal anchor:

```text
M = N + 180°
```

there is no unique shorter arc.

The two halfway solutions are:

```text
N + 90°
N + 270°
```

Both are equally valid.

Therefore exact mundane opposition is not assigned arbitrarily to either pole. It is a distinct Arc state:

> **THE SEAM**

At the Seam:

```text
mundane relationship = opposition
synchronic relationship to natal = square

two half-arcs are equal
two Arc poles are valid
neither pole is privileged
```

The synchronic placement therefore occupies the Seam rather than a uniquely privileged displayed longitude.

A temporal trajectory carries enough provenance to know which pole is approached before the Seam and which pole continues after it.

The apparent 180° jump in normalized display is a consequence of resolving the state onto the opposite Arc pole. That appearance is not the governing doctrine.

**The Seam is the doctrine.**

---

# 5. Law Five — Arc imposes Half-Life

A synchronic placement lives the mundane body's relationship to its natal anchor at one-half angular scale.

This is Arc's **Half-Life**.

## Half-distance

```text
mundane displacement  60°  → synchronic displacement 30°
mundane displacement 120°  → synchronic displacement 60°
mundane displacement 180°  → synchronic displacement 90° / Seam
```

Every ordinary mundane angular displacement from the natal anchor is expressed at one-half scale in synchronic space.

## Half-motion

Between Seam states:

```text
vS = vM / 2
```

The synchronic coordinate inherits mundane direction while expressing mundane velocity at one-half scale.

## Half-cycle

A mundane body's full 360° cycle relative to the natal anchor unfolds through Arc's two 180° phases.

At mundane opposition the synchronic placement reaches the Seam.

The Seam crossing is not a burst of velocity and does not constitute a separate motion law.

```text
ordinary movement
= half mundane movement

Seam
= equal-half-arc topology
```

Half-Life belongs to Arc itself, not to presentation.

---

# 6. Law Six — Arc owns coordinates and topology only

Arc owns:

```text
half-arc geometry
Refraction
180° permitted field
native-centered bounds
Half-Life
Seam
pole identity
phase / branch topology
synchronic coordinate production
sAsc Arc topology
canonical Arc reference states
```

Arc does not own:

```text
aspects
zodiacal condition
house governance
house frames
geography
planetary astronomy
temporal root solving
artifact manufacture
interpretation
```

Permanent ownership remains:

```text
RING
angular relationships

MATER
zodiacal condition / field circuitry

TYMPAN
whole-sign Imprints / house governance

TERRA + HORIZON
local terrestrial orientation

LOOM
exact temporal crossings and interval solving

HEPHAESTUS
materialization of durable temporal artifacts
```

Arc references those authorities rather than reproducing them.

Arc outputs must be directly consumable by the rest of Orbo. Given an Arc result, Ring, Mater, Tympan, and other lawful readers must be able to do their ordinary work without requiring that the result first be saved into a personal Spine.

A forged Spine may preserve, index, and navigate Arc results through time. It is not a prerequisite for Arc to know or return the state of a legal coordinate pair at an instant.

---

# 7. Law Seven — the Synchronic Spine is a first-class child spine

Once Arc has transformed the mundane chronology through the fixed natal anchors, Hephaestus can materialize the resulting chronology as the **Synchronic Spine**.

```text
Mundane Timespine
+
Natal AstroDNA
+
Arc
+
Loom results where required
        │
        ▼
   HEPHAESTUS
        │
        ▼
SYNCHRONIC SPINE
```

The Synchronic Spine is separate from the Mundane and Natal / Contact temporal substrates but has equal temporal standing.

It is not a UI mode, temporary calculation, Prism cache, or live-only midpoint query.

Once `S(t)` exists as a first-class coordinate chronology, the rest of Orbo reads it through existing laws:

```text
S ↔ S      Ring
S ↔ N      Ring
M ↔ S      Ring
S ↔ N_B    Ring
S_A ↔ S_B  Ring

S          Mater qualification
S          Tympan framing
S          Loom temporal search
```

Arc does not need separate natal, mundane, electional, or synastry modes.

It creates synchronic coordinates. Other Orbo laws do their ordinary work upon them.

---

# 8. The Synchronic Ascendant

The Ascendant follows the same Arc law:

```text
nAsc
+
local mundane Ascendant
        │
        ▼
       ARC
        │
        ▼
      sAsc
```

Terra and Horizon supply the correct local mundane horizon.

Arc refracts it.

The sAsc is therefore confined to the 180° Arc centered on the natal Ascendant.

Its traversal reaches seven whole-sign positions around that native center.

Arc owns the permitted path, Half-Life, Seam, poles, and temporal topology.

Tympan owns the corresponding whole-sign Imprint whenever the sAsc changes rising sign.

Arc must never copy Tympan's twelve Imprints.

---

# 9. Two framings of one Synchronic Spine

There is one Synchronic Spine.

There are at least two legitimate ways to frame it.

## A. Natal framing / Composite Chronology

```text
Synchronic coordinates
+
fixed natal Ascendant
+
fixed natal Tympan Imprint
```

The refracted chronology moves through the permanent natal scaffold.

## B. Synchronic Horizon / Synchronic Clock

```text
Synchronic coordinates
+
moving sAsc
+
Tympan-selected Imprint
```

The refracted chronology is viewed through its moving local synchronic horizon.

These are two views of the same Synchronic Spine. They are not independently generated chronologies.

---

# 10. Canonical Arc reference

Arc should support a universal canonical reference for mundane displacement around the zodiac at Orbo fidelity.

The recovered target remains:

```text
360° × 3600 arcseconds
=
1,296,000 whole-arcsecond mundane-offset states
```

The reference is rotationally symmetric.

It does not require:

```text
one table per natal chart
one table per planet
one table per natal degree
```

Natal position supplies the center. The canonical Arc reference supplies the half-arc state.

The canonical representation must preserve the intended half-arcsecond output fidelity and represent the exact opposition state as the Seam rather than silently assigning it to either pole.

No floating-point representation should become canonical storage where exact integer representation is available.

The precise native storage shape is an implementation question for a later pass.

---

# 11. Prism relationship

Older Prism work remains architectural archaeology.

The following ideas survive into Arc:

```text
Refraction
±90° permitted field
Arc bounds
Half-Life / half-speed
Seam / pole behavior
phase topology
sAsc reachability
sAsc itinerary topology
synchronic chronology
synchronic synastry as a consequence of S(t)
```

The following do not survive as Prism-owned authority:

```text
duplicate Refraction
house frames
house governance
zodiacal condition
Ring aspects
quasi-Timespine ownership
live-only synchronic chronology
```

Prism may survive later as presentation or compatibility vocabulary.

It is not the source of truth.

---

# 12. Pass 0 freeze

Arc Pass 0 freezes exactly these seven laws:

1. **Arc is the law of the half-arc.**
2. **For Synchronic Time, the natal anchor is the center of a 180° permitted field.**
3. **Refraction is the same-body natal × mundane application that produces synchronic coordinates through time.**
4. **Exact mundane opposition is the Seam: both ±90° Arc poles are equally valid and neither is privileged.**
5. **Arc imposes Half-Life: mundane displacement and ordinary motion are expressed at one-half scale in synchronic space.**
6. **Arc owns coordinates and topology only; Ring, Mater, Tympan, Terra/Horizon, Loom, and Hephaestus retain their established authorities.**
7. **The Synchronic Spine is a first-class child spine, forged from the Mundane Timespine, natal AstroDNA, and Arc, and may be read through either fixed natal framing or the moving synchronic horizon.**

These seven laws include one implementation acceptance condition: a compliant Arc must answer legal coordinate queries without requiring native context or a forged personal Spine. Personal materialization may preserve Arc through time, but may never be the source of Arc's availability.

Nothing beyond these laws is frozen by Pass 0.

In particular, Pass 0 does not yet freeze:

```text
Swift type names
file layout
API surface
binary packing
phase encoding
pole encoding
Seam storage representation
Synchronic Spine storage format
body scope
midpoint feature scope
UI behavior
animation
electional behavior
interpretation
```

Those must be earned by later passes.

> **Pass 0 freezes the law before Orbo builds the instrument that carries it.**
