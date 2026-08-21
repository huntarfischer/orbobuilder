# Connectome Work Log

## 2026-08-20 — Stage 0

Stage 0 was reduced to the universal 360-degree grid only.

Implemented:

```text
DegreeAddress
0...359 only

DegreeCell
address only

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
cell contains only its degree address
```

Explicitly excluded from Stage 0:

```text
Field terminology
Loom structure
construction state
codec / persistence
birth-chart facts
threads
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

Thread and packet construction is not public. Clotho is the construction door; downstream code can read the resulting values but cannot manufacture arbitrary threads through the public API.

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

Stage 1 status: BUILT / AWAITING FINAL REVIEW.
