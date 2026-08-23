# Hestia - Keeper MVP

**Status: FROZEN / PROVEN / ORBOSYSTEM TRANSPLANT COMPLETE**

Hestia v1 is complete under `native/OrboCore/Sources/OrboCore/OrboSystem/Hestia/`.

The clean transplant was built from `agent/mundane-timespine-3d-build` without merging `feature/hestia-mvp`. The proven Orbospine baseline was 230 tests. After transplanting the complete Hestia proof suite, OrboCore passed 286 tests with 0 failures. The donor suite contains 56 Hestia tests across nine files; the older note claiming 60 Hestia tests was stale.

No further Hestia work belongs in this MVP without a new explicit requirement.

## Purpose

Prove one thing:

> Hestia can keep one native in the Hearth, lightweight saved subjects in Holdings, built-out saved Tapestries in the Hall, answer for what she keeps through one door, Handback what she refuses, and restore the same house after restart.

Hestia is the keeper and query surface. She is not another storage place.

```text
                    HESTIA
              keeper / one door
                       |
          +------------+------------+
          |            |            |
          v            v            v
      HOLDINGS       HEARTH        HALL
```

```text
Hermes -> Hestia
          |
          +-> Holdings
          +-> Hearth
          +-> Hall
          +-> Handback -> Hermes
```

Handback is refusal, not storage.

## Canonical home

Production:

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Hestia/
    Holdings.swift
    Hearth.swift
    Hall.swift
    Hestia.swift
    HestiaPersistence.swift
```

Proofs:

```text
native/OrboCore/Tests/OrboCoreTests/OrboSystem/Hestia/
```

Hestia is a sibling of Hermes, Moirai, Hephaestus, Dioscuri, and OrboSpine under `OrboSystem`. She is not inside the `OrboSpine` runtime directory.

## MVP laws

1. Hestia is the one door for what she keeps.
2. There is exactly one Hearth.
3. Hearth alone owns `nativeSubjectID`; Hestia consults Hearth and does not store a second copy.
4. The native may occupy Hearth only.
5. Holdings contains zero or more lightweight saved subjects: `subjectID + AstroDNA` only.
6. Hall contains zero or more built-out saved residents: `subjectID + AstroDNA + Tapestry`.
7. A subject may not occupy both Holdings and Hall.
8. Hestia does not recalculate, reinterpret, repair, re-allot, or rewrite a Tapestry.
9. Hermes owns the parcel. Hestia opens it and keeps the contents, not the courier envelope.
10. A Hestia intake resolves to Holdings, Hearth, Hall, or Handback.
11. Handback leaves nothing behind.
12. Holdings, Hearth, and Hall persist together as one atomic house snapshot.
13. A persisted Tapestry restores exactly; Moirai does not reweave it.
14. A restored Hestia enforces the same residence laws as before restart.

## Canonical house

```text
Holdings
    Holding[]
        subjectID
        AstroDNA

Hearth
    nativeSubjectID
    resident?
        AstroDNA
        Tapestry

Hall
    residents[]
        subjectID
        AstroDNA
        Tapestry
```

The persisted Hearth resident does not store another subject ID. Native identity is definitionally `Hearth.nativeSubjectID`.

## Query surface

Downstream systems ask Hestia, not her rooms directly.

```text
native()
holding(subjectID)
saved(subjectID)
tapestry(for: subjectID)
```

`tapestry(for:)` searches the only two places where a Tapestry can live: Hearth or Hall.

## Hermes / Moirai boundary

The one intentional contract correction in this transplant is that AstroDNA no longer arrives out-of-band.

Moirai returns one package:

```text
MoiraiPackage
    AstroDNA
    Tapestry
```

Hermes carries:

```text
HermesParcel<MoiraiPackage>
        |
        v
      Hestia
        |
        +-> native + valid package -> Hearth
        +-> saved + valid package  -> Hall
        +-> unacceptable package   -> Handback
```

The Hermes route kind is `orbo.moirai-package.v1`.

Once accepted, Hestia keeps the resident content rather than the Hermes parcel.

Holdings remains a canonical Hestia destination, but a generic non-Moirai Hermes route for lightweight Holdings is deferred.

## Durability

Hestia persistence remains codec 1.

One atomic snapshot contains exactly:

```text
Holdings
Hearth
Hall
```

The caller supplies the file URL. OrboCore does not choose Documents, Application Support, iCloud, or another app storage location.

Tapestry serialization is private persistence plumbing, not a fourth domain object or storage location.

Restore uses four internal Moirai seams only:

```text
ClothoThread restoring initializer
DegreeCell restoring initializer
DegreeGrid restoring initializer
AtroposPackage restoring initializer
```

These seams reconstruct already-sealed work. They do not alter `Clotho.gather`, `Lachesis.allot`, or `Atropos.inspect`, and they do not reweave the Tapestry.

## Original Hestia build record

```text
Stage 0   resident vocabulary
Stage 1   Hearth
Stage 2   Hall
Stage 3   Hestia placement and query
Stage 4   Hermes -> Hestia integration and Handback
Stage 5A  Holdings
Stage 5B  Hestia as one door over Holdings / Hearth / Hall
Stage 5C  atomic durable house
Stage 5D  full restart proof
```

## OrboSystem transplant record

```text
Stage 0   clean branch from Orbospine consolidation; 230-test baseline
Stage 1   MoiraiPackage + Hermes route contract correction
Stage 2   four internal Moirai restoration seams
Stage 3   Hestia production transplant into OrboSystem/Hestia
Stage 4   nine Hestia proof files transplanted; 286 tests green
Stage 5   full diff audit + freeze record
```

## Frozen proving record

```text
56 Hestia tests passed
286 OrboCore tests passed
0 failures
```

The restart proof establishes:

```text
Holdings survive
Hearth survives
Hall survives
native identity still comes from Hearth
Tapestries restore exactly
Holding order survives
Hall order survives
Hestia can continue keeping after restart
cross-place exclusions still hold after restart
Handback after restart leaves the house unchanged
```

## Final transplant audit

Against `agent/mundane-timespine-3d-build`, the transplant changes only these approved surfaces:

```text
OrboSystem/Hestia/**                         added
OrboSystem/Moirai/MoiraiPackage.swift       added
OrboSystem/Moirai/Clotho.swift              restore seam only
OrboSystem/Moirai/DegreeGrid.swift          restore seams only
OrboSystem/Moirai/Atropos.swift             restore seam only
OrboSystem/Hermes/HermesRouteRegistry.swift parcel-kind correction only
OrboSystem/Hermes tests                     parcel-kind vocabulary only
OrboSystem/Hestia tests                     added
```

No transplant changes landed in:

```text
OrboSystem/OrboSpine/**
OrboSystem/Hephaestus/**
OrboSystem/Dioscuri/**
HermesCourier.swift
HermesManifest.swift
AstroDNA
Ring
```

## Explicit non-goals / deferred work

No Holding -> Hall promotion.
No removal or unfavorite behavior.
No moving residents between places.
No multiple Halls.
No Hall naming system beyond resident order.
No relationship, Crystal, project, or other resident categories.
No generic repository abstraction.
No cloud or sync layer.
No UI.
No app storage-location policy.
No Tapestry regeneration during restore.
No new Moirai weaving behavior.
No generic non-Moirai Hermes route for Holdings yet.
No Hermes persistence work inside Hestia.

Hermes manifest restart durability remains a separate Hermes concern.

## Frozen acceptance record

```text
Hermes comes to me.
I decide what I keep and where it belongs.
The native belongs only to my Hearth.
Lightweight saves belong to Holdings.
Built-out saved Tapestries belong to my Hall.
What I refuse is Handback, not another holding.
Everyone asks me for what I keep.
My house survives restart without asking the Sisters to weave again.
```
