# Hestia - Keeper MVP

**Status: FROZEN / PROVEN**

Hestia v1 is complete. Stages 0-5D passed 60 Hestia tests, and the full OrboCore suite passed 215 tests with 0 failures after the restart proof. No further Hestia work belongs in this MVP without a new explicit requirement.

## Purpose

Prove one thing:

> Hestia can keep one native in the Hearth, lightweight saved subjects in Holdings, built-out saved Tapestries in the Hall, answer for what she keeps through one door, Handback what she refuses, and restore the same house after restart.

Hestia is the keeper and the query surface. She is not a fourth place where things are stored.

```text
                    HESTIA
              keeper / one door
                       |
          +------------+------------+
          |            |            |
          v            v            v
      HOLDINGS       HEARTH        HALL
```

Her delivery vocabulary is:

```text
Hermes -> Hestia
          |
          +-> Holdings
          +-> Hearth
          +-> Hall
          +-> Handback -> Hermes
```

Handback is a refusal, not storage.

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
11. Handback leaves nothing behind in Holdings, Hearth, or Hall.
12. Holdings, Hearth, and Hall persist together as one atomic house snapshot.
13. A persisted Tapestry restores exactly; Clotho, Lachesis, and Atropos are not called to weave it again.
14. A restored Hestia enforces the same residence laws as before restart.

## Canonical house

### Holdings

```text
Holding
    subjectID
    AstroDNA
```

Holdings is lightweight retention. A Holding has no Tapestry in v1.

### Hearth

```text
Hearth
    nativeSubjectID
    resident?
        AstroDNA
        Tapestry
```

The resident does not persist another subject ID. Its identity is definitionally `Hearth.nativeSubjectID`.

### Hall

```text
Hall
    residents[]
        subjectID
        AstroDNA
        Tapestry
```

Hall order is preserved.

## Hestia query surface

Downstream systems ask Hestia, not her rooms directly.

The v1 query surface is:

```text
native()
holding(subjectID)
saved(subjectID)
tapestry(for: subjectID)
```

`tapestry(for:)` searches the only two places where a Tapestry can live: Hearth or Hall.

## Hermes boundary

Hermes comes to Hestia, never directly to Holdings, Hearth, or Hall.

For the proven Moirai route:

```text
HermesParcel<AtroposPackage>
        |
        v
      Hestia
        |
        +-> native + valid Tapestry -> Hearth
        +-> saved + valid Tapestry  -> Hall
        +-> unacceptable Tapestry   -> Handback
```

The parcel is unpacked at the Hestia boundary. Once accepted, Hestia keeps the resident content rather than a Hermes parcel.

Holdings is already a canonical Hestia destination, but the separate non-Moirai Hermes delivery contract that will bring lightweight Holdings is not part of this MVP. In v1, Holdings itself and Hestia's `hold` seam are proven; a future route may deliver those saves through Hermes without changing what Holdings means.

A Handback returns corrective provenance so Hermes can open a new journey. Hestia keeps none of the rejected work.

## Durability

Hestia persistence is codec 1.

One atomic snapshot contains exactly:

```text
Holdings
Hearth
Hall
```

The caller supplies the file URL. OrboCore does not choose Documents, Application Support, iCloud, or another app storage location.

Tapestry serialization is private persistence plumbing, not a fourth domain object or storage location. It preserves the canonical 360-cell grid, cell order, thread order, exact Ring fine state, gene, and degree address.

On load, the house is rejected if its persisted state violates the established laws or a Tapestry no longer matches its stored AstroDNA.

## Build record

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

Frozen proving record:

```text
60 Hestia tests passed
215 OrboCore tests passed
0 failures
```

The final restart proof established that:

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

## Explicit non-goals / deferred work

No Holding -> Hall promotion.
No removal or unfavorite behavior.
No moving residents between places.
No multiple Halls.
No Hall naming or ordering system beyond resident order.
No relationship, Crystal, project, or other resident categories.
No generic repository abstraction.
No cloud or sync layer.
No UI.
No app storage-location policy.
No Tapestry regeneration during restore.
No new Moirai behavior.
No generic non-Moirai Hermes route for Holdings yet.
No Hermes persistence work inside Hestia.

Hermes manifest restart durability remains a separate Hermes concern and is not repaired by Hestia persistence.

## Frozen acceptance record

Hestia v1 can truthfully say:

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
