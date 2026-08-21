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

Define the smallest birth-chart input Clotho needs to gather the first authoritative native facts.

Clotho receives input. She does not expose a query surface.

For the MVP, the first input is the native birth chart through its canonical natal AstroDNA. Clotho reads only the authoritative facts required for the next stage and gathers them into a source packet.

```text
INPUT
natal AstroDNA

CLOTHO
gathers required authoritative facts

OUTPUT
source packet for Lachesis
```

The degree grid remains unchanged. Clotho does not allot facts to degrees, answer degree queries, or write the Loom.

The exact contents of the first source packet should remain as small as possible and be limited to what Lachesis needs for the first allotment pass.

## Stage 1 gate

Clotho can accept canonical natal AstroDNA as input and produce a complete source packet sufficient for MVP Lachesis without requiring Lachesis to return to AstroDNA or the original authorities.

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
