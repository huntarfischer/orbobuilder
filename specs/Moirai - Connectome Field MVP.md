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

# Stage 0 - The Grid

## Goal

Build the durable 360-cell Loom before deciding what will fill it.

Stage 0 creates one native Field address type:

```text
FieldAddress
0 ... 359
```

and one Loom containing exactly 360 stable cells:

```text
Loom
└── cells[0...359]
```

A cell initially needs only its address.

The whole-degree cell is an indexing address, not Orbo's positional authority. Exact coordinates added later must retain their own precision inside or alongside the cell they belong to.

Stage 0 does not define threads, allotments, governance, Arc data, or source facts.

## Persistence

Stage 0 needs only:

```text
Loom schema / codec
construction state
360-cell grid
deterministic encode / decode
```

The artifact checksum is external to the encoded Loom rather than self-referential.

## Stage 0 gate

Prove:

```text
exactly 360 cells
addresses exactly 0...359
no duplicates
no missing addresses
stable cell identity
whole-degree address is not positional authority
encode → destroy from memory → decode preserves the Loom
same input → same encoded bytes
```

---

# Stage 1 - Clotho

## Goal

Build the smallest source/query surface that can supply authoritative facts to the completed grid.

Clotho gathers. She does not allot.

The exact MVP source packet is defined after Stage 0, against the actual Loom rather than in advance.

## Stage 1 gate

Clotho can persist a complete source packet sufficient for MVP Lachesis without requiring Lachesis to return to the original authorities.

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

Reuse existing native OrboCore vocabulary wherever possible. Stage 0 should add only what the 360-cell Loom itself requires.

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

> **Build the grid first. Gather only what it needs. Allot once. Persist. Seal. Read.**
