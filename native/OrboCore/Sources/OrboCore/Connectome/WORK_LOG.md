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

Proof covers valid address bounds, canonical 0...359 order, no duplicate addresses, exactly one cell per address, and fresh cells with no allotted threads.

Explicitly excluded from Stage 0: final Loom structure, construction state, codec/persistence, birth-chart meaning, allotments, governance, Arc, Clotho, Lachesis.

Stage 0 status: COMPLETE / REVIEWED.

## 2026-08-20 — Stage 1 / Clotho

Clotho takes canonical natal AstroDNA as input and creates the twelve natal threads Lachesis receives.

Each thread carries:

```text
AstroDNAGene identity
exact RingFineState
DegreeAddress 0...359
```

The whole-degree address is only the join key into the Stage 0 grid. Exact Ring fine state remains attached and authoritative to the arcsecond.

Stage 3 required one deliberate extension to Clotho's same gathering operation: while each thread is created, Clotho simultaneously records a matching `MoiraiRecipeEntry`. `Clotho.gather` now returns `ClothoOutput` containing:

```text
packet -> Lachesis
recipe -> Atropos
```

The recipe is not a second astrological authority or a later reconstruction. It records what Clotho actually spun so Atropos can independently check what Lachesis returns.

Clotho remains the sole construction authority for threads, packets, and the Moirai recipe. She does not name signs, assign houses, consult Tympan or Mater, derive astrological meaning, or allot into the degree grid.

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/Clotho.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/ClothoStage1Tests.swift
```

Stage 1 status: COMPLETE / REVIEWED, with recipe registration added for Stage 3.

## 2026-08-20 — Stage 2 / Lachesis

For the Moirai MVP, Lachesis's canonical construction path is now explicitly narrow:

```text
fresh DegreeGrid
    +
complete ClothoSourcePacket
    ↓
Lachesis
    ↓
completed natal DegreeGrid
```

Lachesis allots the complete twelve-thread natal packet into the fresh Stage 0 grid using only the `DegreeAddress` Clotho supplied. She does not calculate degree addresses. Exact `RingFineState` survives unchanged inside the whole-degree cell.

The implementation can also accept already-valid allotments and behaves idempotently when the same authoritative thread is presented again. That behavior remains in code and its existing tests remain useful, but it is no longer part of the required MVP contract. It is supporting behavior only. Incremental or partial allotment semantics are deferred until later Connectome work actually requires them.

Lachesis does not receive the Moirai recipe and does not consult Ring, Tympan, Mater, Arc, or other authorities for meaning.

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/DegreeGrid.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/LachesisStage2Tests.swift
```

Stage 2 status: COMPLETE / REVIEWED.

## 2026-08-20 — Stage 3 / Atropos

Atropos is the Moirai's internal quality-control and sealing authority.

Clotho registers a `MoiraiRecipe` from the same act that creates the threads. Lachesis receives the threads but not the recipe. Atropos later receives the recipe and Lachesis's completed `DegreeGrid` and asks only whether the finished allotment faithfully matches what Clotho said she supplied.

```text
Clotho
    ├── packet  -> Lachesis
    └── recipe  -> Atropos

Lachesis
    └── allotted DegreeGrid -> Atropos

Atropos
    recipe <-> grid
        ↓
    PASS / REJECT
        ↓
    AtroposPackage
    ready for Hermes
```

Atropos checks:

```text
360 canonical degree cells
12 recipe entries covering the canonical AstroDNA genes
12 allotted threads covering the canonical AstroDNA genes
recipe exactState == allotted exactState
recipe degreeAddress == allotted degreeAddress
thread occupies the matching DegreeCell
```

She compares only. She does not consult AstroDNA, recalculate a degree from Ring fine state, call Ring, consult Tympan/Mater/Arc, repair, replace, or re-allot work.

A mismatch is returned as `AtroposFailure`; it is not repaired. On success only Atropos can create `AtroposPackage`, which contains the exact `DegreeGrid` Lachesis supplied.

This stage intentionally stops before Hermes. Architecturally the sealed package is ready for Hermes, who will later compare it against the original ticket of chart + expected outcome. Hermes callback/rendezvous mechanics are not designed here.

Current implementation:

```text
native/OrboCore/Sources/OrboCore/Connectome/Atropos.swift
native/OrboCore/Tests/OrboCoreTests/Connectome/AtroposStage3Tests.swift
```

Stage 3 status: BUILT / AWAITING REVIEW.
