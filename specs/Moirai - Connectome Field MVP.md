# Moirai - Connectome Field MVP

**Status:** Stage 0-3 implementation plan  
**Target:** Orbo 1.0 native  
**Primary language:** Swift  
**Implementation root:** `native/OrboCore/Sources/OrboCore/Connectome/`

## Governing objective

Build the smallest complete version of the Moirai that proves the native-specific Connectome structure can be constructed once and then read without reconstructing its sources.

```text
CLOTHO
creates natal threads once
    ↓
LACHESIS
allots those threads once
    ↓
ATROPOS
validates and serves the finished structure
```

Stages 0-3 prove the Sisters. They do not attempt to finish the Connectome or define the final Loom shape.

## MVP boundary

This pass does not add:

- final Loom architecture
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
address only at Stage 0 construction

DegreeGrid
exactly 360 cells
```

Stage 0 does not define the Loom, construction state, persistence, natal threads, allotments, governance, Arc data, or birth-chart meaning.

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
each fresh cell has its degree address and no allotted threads
```

---

# Stage 1 - Clotho

## Goal

Define the smallest birth-chart input Clotho needs to create the natal threads that Lachesis will allot onto the 360-degree grid.

Clotho receives input. She does not expose a query surface and she does not derive astrological meaning.

For the MVP, the input is the native birth chart through its canonical natal AstroDNA. Clotho walks the twelve canonical AstroDNA genes. For each gene she creates one thread containing the gene identity, the exact `RingFineState`, and the matching whole-degree `DegreeAddress` supplied by Ring's existing exact-to-coarse projection.

```text
INPUT
natal AstroDNA

CLOTHO
for each canonical gene:
    creates one thread
    preserves gene identity
    preserves exact RingFineState to arcsecond precision
    takes Ring's whole-degree projection
    attaches the matching DegreeAddress

OUTPUT
12 Clotho threads for Lachesis
```

Clotho is the sole construction authority for Clotho threads and the source packet. Downstream Orbo code may read them but does not manufacture arbitrary thread or packet values.

Clotho does not name signs, assign houses, consult Tympan or Mater, interpret positions, allot threads into the degree grid, answer degree queries, or write the Loom.

The whole degree is only the address for the Stage 0 grid. The exact `RingFineState` travels with the thread and remains authoritative at arcsecond precision. Lachesis may therefore use the whole-degree address for placement while retaining the exact position for later allotment work that requires finer precision.

The source packet is an in-memory handoff for the MVP and is not a persisted or Codable artifact.

## Stage 1 gate

Prove:

```text
natal AstroDNA is the input
exactly 12 Clotho threads are created
threads remain in canonical AstroDNA gene order
each exact RingFineState is preserved unchanged to the arcsecond
each DegreeAddress matches RingFineState.coarseState.degree
sub-degree precision does not alter the containing DegreeAddress
retrograde motion does not change the 0...359 DegreeAddress
multiple genes may share one DegreeAddress while retaining distinct exact states
Clotho does not alter the Stage 0 DegreeGrid
same natal AstroDNA produces the same packet
no sign, house, ruler, or other astrological meaning is added
Clotho alone constructs threads and packets
```

---

# Stage 2 - Lachesis

## Goal

Fill the existing Stage 0 `DegreeGrid` with the Clotho threads already addressed to it.

Lachesis receives only the existing degree grid and Clotho's source packet. She does not recalculate thread positions or derive additional astrological meaning.

```text
INPUT
DegreeGrid
ClothoSourcePacket

LACHESIS
for each existing DegreeCell:
    allots every Clotho thread whose supplied DegreeAddress matches that cell

OUTPUT
the same DegreeGrid type
with Clotho threads allotted into its existing cells
```

A `DegreeCell` therefore evolves at Stage 2 from an empty address holder into:

```text
DegreeCell
    address
    threads[]
```

The cell remains whole-degree. Each allotted thread still carries its exact `RingFineState`, so arcsecond precision is preserved inside the degree-addressed structure.

Lachesis is the sole allotment authority for Clotho threads. She trusts the `DegreeAddress` Clotho supplied. She does not call Ring to recalculate the address and does not consult Tympan, Mater, Arc, or other authorities in this stage.

This stage does not define or persist the final Loom. It proves the first allotment operation on the grid that already exists.

## Stage 2 gate

Prove:

```text
the grid remains exactly 360 cells in canonical 0...359 order
all 12 Clotho threads are allotted
 each thread appears exactly once
each thread appears only in its supplied DegreeAddress
multiple threads may share one existing cell
empty cells remain valid
exact RingFineState survives unchanged to the arcsecond
Lachesis does not change thread identity or address
same empty grid + same Clotho packet produces the same allotted grid
no sign, house, ruler, aspect, or other astrological meaning is added
```

---

# Stage 3 - Atropos

## Goal

Define the smallest validation and serving boundary for the structure produced by Lachesis.

Atropos does not enrich, allot, or recalculate it.

The exact Stage 3 representation should be designed only after the Stage 2 allotted grid has been reviewed. Do not assume the final Loom shape here.

---

# Native Swift repository layout

```text
native/OrboCore/Sources/OrboCore/Connectome/
native/OrboCore/Tests/OrboCoreTests/Connectome/
```

Reuse existing native OrboCore vocabulary wherever possible.

---

# MVP acceptance

```text
STAGE 0
360 degree places exist.

CLOTHO
creates exact natal threads and gives each a degree address.

LACHESIS
allots those threads into the existing degree cells without changing them.

ATROPOS
validates and serves the resulting native structure.
```

> **Build the places. Create the threads. Allot the threads. Then decide what must be sealed and served.**
