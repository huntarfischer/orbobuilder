# Moirai - Connectome Field MVP

**Status:** Stage 0-3 implementation plan  
**Target:** Orbo 1.0 native  
**Primary language:** Swift  
**Implementation root:** `native/OrboCore/Sources/OrboCore/Connectome/`

## Governing objective

Build the smallest complete version of the Moirai that proves the permanent Connectome Field can be constructed once and then read without reconstructing its sources.

```text
CLOTHO
gathers once
    ↓
LACHESIS
allots once
    ↓
LOOM
persists the Field
    ↓
ATROPOS
seals and serves
    ↓
REST OF ORBO
reads
```

Stages 0-3 prove the Sisters. They do not attempt to finish the Connectome.

## Field and Loom

```text
FIELD
The native-specific relational space: what is allotted where.

LOOM
The persistent interconnected table structure that stores the Field.
```

Use **Field** for the native topology itself.

Use **Loom** for the stored artifact that materializes that Field.

> **Clotho gathers authoritative facts. Lachesis allots those facts across the Field by writing them into the Loom. Atropos seals and serves the finished Loom as the authoritative Field.**

## MVP boundary

This pass does not add:

- Ring aspects or aspect reachability
- dispositor chains
- full Synchronic Governance
- field overlap or density
- special nodal handling
- Timespine joins
- Composite Framing
- Synchronic Clock integration
- electional
- synastry
- final packing or performance optimization

---

# Stage 0 - The Degree Grid

## Goal

Define only the 360 zodiacal degree addresses.

```text
DegreeAddress
0 ... 359

DegreeCell
address only

DegreeGrid
exactly 360 cells
```

Stage 0 does not define the Loom, Field contents, construction state, persistence, threads, allotments, governance, Arc data, or birth-chart facts.

The degree grid is an index only. It does not replace exact positional precision.

## Stage 0 gate

Prove:

```text
addresses accept only 0...359
exactly 360 canonical addresses
exactly 360 cells
no duplicates
no missing addresses
canonical order is 0...359
each cell contains only its degree address
```

---

# Stage 1 - Clotho

## Goal

Define the smallest birth-chart input Clotho needs to gather the natal facts that Lachesis will allot onto the 360-degree grid.

Clotho receives input. She does not expose a query surface and she does not derive astrological meaning.

For the MVP, the input is the native birth chart through its canonical natal AstroDNA. Clotho walks the twelve canonical AstroDNA genes, preserves each gene's exact Ring fine state, and attaches the whole-degree `DegreeAddress` supplied by Ring's existing exact-to-coarse projection.

```text
INPUT
natal AstroDNA

CLOTHO
for each canonical gene:
    preserves gene identity
    preserves exact RingFineState
    takes Ring's whole-degree projection
    attaches the matching DegreeAddress

OUTPUT
12 degree-addressed natal facts for Lachesis
```

Clotho does not name signs, assign houses, consult Tympan or Mater, interpret positions, allot facts into the degree grid, answer degree queries, or write the Loom.

The whole degree is an address for the Stage 0 grid. The exact `RingFineState` remains attached to the natal fact so the coarse grid address never replaces the authoritative positional identity.

The source packet is an in-memory handoff for the MVP and is not a persisted or Codable artifact.

## Stage 1 gate

Prove:

```text
natal AstroDNA is the input
exactly 12 natal facts are emitted
facts remain in canonical AstroDNA gene order
each exact RingFineState is preserved unchanged
each DegreeAddress matches RingFineState.coarseState.degree
retrograde motion does not change the 0...359 DegreeAddress
multiple genes may share one DegreeAddress
Clotho does not alter the Stage 0 DegreeGrid
same natal AstroDNA produces the same packet
no sign, house, ruler, or other astrological meaning is added
```

---

# Stage 2 - Lachesis

## Goal

Allot Clotho's authoritative facts across the Field by writing them into the Loom.

Lachesis performs the allotment work once. The resulting Field facts persist.

## Stage 2 gate

The Loom itself contains the MVP Field facts required for lookup without returning to Clotho or the original authorities.

---

# Stage 3 - Atropos

## Goal

Turn Lachesis's completed Loom into the immutable public representation of the Connectome Field.

Atropos does not enrich, allot, or recalculate the Field.

She validates the completed Loom, seals it, and serves it to the rest of Orbo.

## Stage 3 gate

Restart with only Atropos and the sealed Loom artifact and successfully answer the MVP Field queries without loading Clotho, Lachesis, or the construction authorities.

---

# Native Swift repository layout

```text
native/OrboCore/Sources/OrboCore/Connectome/
native/OrboCore/Tests/OrboCoreTests/Connectome/
```

Reuse existing native OrboCore vocabulary wherever possible. Stage 0 adds only the 360-degree grid.

---

# MVP acceptance

```text
CLOTHO
gathers the required facts once.

LACHESIS
allots those facts once across the Field.

LOOM
persists the allotted Field.

ATROPOS
seals and serves the finished Loom.
```

> **Build the degree grid first. Gather only what it needs. Allot once. Persist. Seal. Read.**
