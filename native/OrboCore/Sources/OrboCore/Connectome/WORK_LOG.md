# Connectome Work Log

## 2026-08-20 — Stage 0

Stage 0 was reduced to the universal 360-degree grid only.

Implemented:

```text
DegreeAddress
0...359 only

DegreeCell
address only at fresh construction

DegreeGrid
exactly 360 cells in canonical order
```

Proof covers:

```text
valid address bounds
exactly 360 addresses
canonical 0...359 order
no duplicate addresses
exactly one cell per address
fresh cells contain no allotted threads
```

Explicitly excluded from Stage 0:

```text
final Loom structure
construction state
codec / persistence
birth-chart meaning
allotments
governance
Arc
Clotho
Lachesis
```

The grid is universal scaffolding only. Native-specific structure begins after the birth chart enters the process.

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/DegreeGrid.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/DegreeGridStage0Tests.swift
```

The old `Loom.swift` and `LoomStage0Tests.swift` paths remain only as inert comment files because repository deletion was unavailable during the correction pass.

Stage 0 status: COMPLETE / REVIEWED.

## 2026-08-20 — Stage 1 / Clotho

Clotho takes canonical natal AstroDNA as input and creates the twelve natal threads Lachesis will receive.

Implemented:

```text
Natal AstroDNA
      ↓
    Clotho
      ↓
12 Clotho threads

Each thread:
    AstroDNAGene identity
    exact RingFineState
    DegreeAddress 0...359
```

The whole-degree address is only the join key into the Stage 0 grid. The exact Ring fine state remains attached and authoritative down to the arcsecond so later allotment can retain sub-degree precision where needed.

Clotho does not name signs, assign houses, consult Tympan or Mater, derive astrological meaning, allot into the degree grid, answer degree queries, or write the Loom.

Clotho is the sole construction authority for threads. Downstream Orbo code can read the resulting values but cannot manufacture arbitrary threads.

Proof uses the native's known natal positions at degree/minute precision and additional second-level fixtures to prove that arcseconds survive unchanged while the degree address remains the same.

Proof covers:

```text
natal AstroDNA is the input
exactly 12 threads are created
canonical AstroDNA gene order is preserved
exact RingFineState is preserved unchanged
whole-degree DegreeAddress matches Ring projection
sub-degree minute/second precision survives
retrograde motion does not change DegreeAddress
multiple genes may share a degree while retaining distinct exact states
Clotho does not mutate the Stage 0 grid
same natal AstroDNA gives the same packet
```

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/Clotho.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/ClothoStage1Tests.swift
```

Stage 1 status: COMPLETE / REVIEWED.

## 2026-08-20 — Stage 2 / Lachesis

Lachesis fills the existing Stage 0 `DegreeGrid` with the Clotho threads already addressed to it.

Implemented:

```text
DegreeGrid
    +
ClothoSourcePacket
    ↓
Lachesis
    ↓
same DegreeGrid type
360 existing DegreeCells
threads allotted into matching cells
```

`DegreeCell` now carries:

```text
address
threads[]
```

A fresh `DegreeGrid()` still contains 360 canonical cells with empty thread arrays. Lachesis is the only construction path in this stage that creates cells containing allotted Clotho threads.

Lachesis does not calculate degree addresses. She uses only the `DegreeAddress` Clotho supplied and places each complete thread into the matching existing cell. The exact `RingFineState` remains unchanged, retaining arcsecond precision inside the whole-degree cell.

The initial Stage 2 implementation required the input grid to be completely empty. Review identified that as too narrow: it would make Lachesis a one-shot empty-grid filler rather than the owner of allotment. That restriction has been removed.

Lachesis may now receive a grid that already contains valid Clotho-thread allotments. Existing allotments are validated before use: every thread must already occupy its supplied degree address and natal genes must be unique across the grid. Re-allotting the same authoritative thread is idempotent and does not duplicate it. A conflicting thread for a gene already allotted is rejected rather than replacing the existing truth.

Lachesis does not consult Ring to recalculate position and does not consult Tympan, Mater, Arc, or other authorities for meaning in this stage.

Proof uses the same natal thread set used for Clotho, including second-level precision and the shared Mars / North Node degree.

Proof covers:

```text
grid remains exactly 360 cells
canonical 0...359 cell order remains
all 12 Clotho threads are allotted
allotted threads appear exactly once
each thread appears only at its supplied DegreeAddress
multiple threads may share one existing cell
empty cells remain valid
exact RingFineState survives unchanged to the arcsecond
whole-degree cell retains sub-degree thread precision
thread identity and address are unchanged
same empty grid + same packet gives the same result
an already allotted grid can be passed back to Lachesis
re-allotting the same packet is idempotent
existing valid allotments are preserved without duplication
```

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/DegreeGrid.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/LachesisStage2Tests.swift
```

Stage 2 status: COMPLETE / REVIEWED.
