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

Clotho now takes natal AstroDNA as input and gathers the minimum authoritative fact needed for the first Lachesis allotment.

Implemented:

```text
Natal AstroDNA
      ↓
    Clotho
      ↓
ClothoSourcePacket
    risingSign
```

Clotho does not query the degree grid, answer degree questions, allot facts, or write the Loom.

The Stage 1 packet contains only the natal rising sign projected from the authoritative Ascendant gene in AstroDNA.

Proof covers:

```text
natal AstroDNA is the input
correct rising sign is gathered
packet contains only risingSign
same natal AstroDNA gives the same packet
different rising signs give different packets
Ascendant degree changes within one sign do not change the MVP packet
packet round-trips without retaining natal AstroDNA
```

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/Clotho.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/ClothoStage1Tests.swift
```

Stage 1 status: BUILT / AWAITING REVIEW.
