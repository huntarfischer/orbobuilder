# Hecate Pass 6 — Door III Freeze Gate

**Date:** 2026-08-30  
**Branch:** `feature/orbo-lawbook-2026-08-30`  
**Law authority:** `ORBO_LAWBOOK.md`  
**Frozen implementation head:** `24a245f3bc799ef3908cc068e8a66f370e72306f`  
**Status:** PROVEN / GREEN / FROZEN

## Purpose

Pass 6 adds no new astrology and no new production behavior.

It audits the living Door III / Hecate seam against the Lawbook, records the final proof, removes stale construction guidance that contradicted the frozen architecture, and freezes the relational grammar proven through Passes 2 through 5.5.

The implementation frozen by this gate is exactly:

```text
24a245f3bc799ef3908cc068e8a66f370e72306f
Complete Hecate point and field grammar
```

Later documentation commits do not change the frozen Swift implementation.

---

# 1. Frozen Door III boundary

Door III remains the Timespine RELATION / LINK door.

Its living responsibility is only:

```text
explicit 2+ Spine addresses
        ↓
LINK
        ↓
resolve exact Timespine points
        ↓
preserve caller identity and order
        ↓
hand factual points outward
```

`OrboSpineLink` may resolve an exact point from chronological occurrence or celestial occurrence identity. Celestial occurrence addressing retains its occurrence binding so repeated visits to the same physical degree remain distinct.

Door III does not:

- choose a ritual
- search for substitute moments
- compute aspects
- compute midpoints
- perform Synastry
- cast Composite
- interpret
- persist

Door III remains domain-neutral exposure of the Spine.

---

# 2. Frozen Hecate action grammar

Hecate stands at Door III and chooses what to do with supplied relation matter.

The frozen core grammar is:

```text
HECATE

RELATE
    Aspect
        two celestial points
        → factual relation

    Synastry
        two celestial fields
        → relation table

CAST
    Midpoint
        two celestial points
        → derived point result

    Composite
        two celestial fields
        → derived field

    Kleides
        AstroDNA
        Ascendant
        Sect

        Lots
            Fortune
            Spirit
            Eros
            Necessity
            ...

        Parts
            ...

INQUIRE
    Kleides knowledge

SUMMON
    internal helper only when a chosen ritual requires another keeper
```

This grammar is defined by action and scale:

```text
point + point
    RELATE → Aspect
    CAST   → Midpoint

field + field
    RELATE → Synastry
    CAST   → Composite
```

`Kleides` is Hecate's spellbook, not the definition of Hecate. Lots and Parts are organized shelves within it. AstroDNA is a Kleis but is neither a Lot nor a Part.

---

# 3. Exact aspect law

Hecate's native/default aspect tolerance is frozen at:

```text
0 arcminutes
```

The exact angular separation remains factual matter.

A caller or downstream system may explicitly widen an orb, but widening is only a lens over the stored exact relation. It never changes the underlying separation.

Therefore:

```text
90°00′ separation
→ exact square at default orb

90°01′ separation
→ not square at default orb

90°01′ separation + explicit 1′ tolerance
→ may be admitted as square
```

No implicit traditional, modern, user, or presentation orb is smuggled into Hecate's default relation.

---

# 4. Frozen point-level primitives

## Aspect

`Hecate.relateAspect`:

- consumes two `CelestialLongitude` values
- retains exact `RingSeparation`
- retains nearest admitted Ring mark and residual
- defaults to `HecateAspectOrb.exact`
- returns an admitted mark only under the explicit tolerance
- performs no interpretation

Aspect is the atomic point-level RELATE operation.

## Midpoint

`Hecate.castMidpoint`:

- consumes two `CelestialLongitude` values
- preserves both source points
- delegates composite geometry to the existing Arc/Asteria law
- respects shortest-arc composition
- preserves the exact opposition `ArcSeam` rather than inventing one privileged midpoint
- creates derived astrological matter

Midpoint is the atomic point-level CAST operation.

---

# 5. Frozen field-level rituals

## Synastry

Synastry requires exactly two linked Timespine fields.

The current canonical Timespine field contains 11 celestial bodies. Synastry compares every point in the first field with every point in the second field through the frozen Aspect primitive:

```text
11 × 11 = 121 Aspect relations
```

The result remains `RelationTable`.

The source fields remain themselves. Synastry creates no new celestial field.

The prior Pass 5 `momentToMoment` name was temporary scaffolding and is retired. The historical Pass 5 gate is preserved as construction memory and explicitly marked historical.

## Composite

Composite requires exactly two linked Timespine fields.

Composite pairs corresponding canonical bodies only:

```text
Sun     + Sun
Moon    + Moon
Mercury + Mercury
...
Node    + Node
```

Each corresponding pair is cast through the frozen Midpoint primitive.

The current canonical result therefore contains 11 derived members.

The resulting `HecateCompositeField`:

- is new derived astrological matter
- retains both source `OrboSpinePoint` fields as provenance
- does not mutate the sources
- does not fabricate a Julian Day or claim the derived field occurred on the Timespine
- performs no interpretation or persistence

---

# 6. Lawbook audit

The final living implementation was checked against `ORBO_LAWBOOK.md`.

```text
Law 7   Door III = RELATION / LINK                  PASS
Law 8   Door remains domain-neutral                 PASS
Law 9   Hecate stands at Door III                   PASS
Law 10  Hecate chooses ritual                       PASS
Law 11  RELATE → TABLE                              PASS
Law 12  CAST → NEW VALUE / OBJECT                   PASS
Law 13  Kleides is a tool; Lots/Parts are shelves  PASS
Law 14  exact retrieval, no hunting                 PASS
Law 15  SUMMON remains internal                     PASS
Law 16  no interpretation                           PASS
Law 17  no holding                                  PASS
Law 18  AstroDNA remains downstream                 PASS
Law 19  implementation does not redefine doctrine  PASS
Law 20  documentation conflicts surfaced/fixed     PASS
Law 21  point / field grammar                       PASS
Law 22  default orb = 0′                            PASS
```

No Swift production conflict was found.

One construction-document conflict was found during the freeze audit: `AGENTS.md` still contained the old sentence `The Mundane Timespine is AstroDNA in motion` and an obsolete Pass 5 branch pointer. Pass 6 corrected that guidance to the frozen Lawbook doctrine. No production code was changed by that correction.

---

# 7. Upstream implementation proof

GitHub Actions run:

```text
33349792278
```

ran against frozen implementation head:

```text
24a245f3bc799ef3908cc068e8a66f370e72306f
```

Results:

```text
OrboSpineLinkResolutionTests
4 tests
0 failures

SpineLinkTests
3 tests
0 failures

HecateLinkTests
4 tests
0 failures

HecateRelationTests
15 tests
0 failures

runner OrboCore package suite
764 tests
0 failures
0 unexpected
```

The runner copy retains the pre-existing CI-only exclusion of `RingTests.swift`.

The new relational proof includes exact orb behavior, explicit widened orb behavior, Midpoint wrap behavior, opposition Seam preservation, Synastry participant law, 121-row field relation behavior, Composite participant law, corresponding-body composition, and unchanged Door III failure propagation.

---

# 8. Development-Mac acceptance

The user completed the full local package gate on 2026-08-30 at approximately 21:18 America/Chicago against the frozen implementation.

Result supplied from the development Mac:

```text
TympanTests
19 tests
0 failures
0 unexpected

OrboCorePackageTests.xctest
776 tests
0 failures
0 unexpected

All tests
776 tests
0 failures
0 unexpected
```

This full local package run includes the living package rather than the CI runner's reduced copy.

The frozen implementation is therefore accepted as **PROVEN / GREEN** locally as well as upstream.

---

# 9. Closure checklist

```text
Celestial-time-first law preserved?          YES
Repository inspected before changes?         YES
Existing canonical Ring/Arc law reused?       YES
Swift implementation present?                YES
Correct owners preserved?                     YES
Changed XCTest proof present?                 YES
Focused Hecate tests green?                   YES
Full development-Mac package suite green?     YES
Zero failures?                                YES
OrboLab live readout applicable?              N/A
Additional Pass 6 native build applicable?    N/A, documentation-only freeze
Native Port Manifest update applicable?       N/A, no tracked 4R port status changed
Dated gate record created?                    YES
Lawbook current?                              YES
Pending work stated explicitly?               YES
Deletion performed?                          NO
Non-Swift native dependency introduced?       NO
```

The Native Port Manifest is not changed by this pass because Pass 6 does not alter the 4R status of a component represented by that ledger. This gate records that non-applicability explicitly rather than manufacturing a false port change.

---

# 10. Explicitly outside the freeze

The following are not required to reopen the frozen Door III / Hecate core merely because they may be built later:

```text
additional RELATE rituals
synchronic relation
additional CAST rituals
additional Kleides spells
expanded Timespine field membership
angles / houses / Lots added to richer fields
presentation
interpretation
persistence of returned relation products
caller-specific orb policies
```

Future work may add lawful rituals or richer supplied matter around the frozen grammar.

Future work must not silently change these frozen laws:

```text
Door III only LINKs exact points
Hecate chooses the ritual
RELATE preserves matter
CAST creates derived matter
Aspect is point-level RELATE
Midpoint is point-level CAST
Synastry is field-level RELATE
Composite is field-level CAST
Aspect default orb is 0′
AstroDNA is downstream Timespine matter
Hecate does not interpret or hold
```

Any proposed change to those laws requires an explicit architectural ruling and a Lawbook change before implementation.

---

# Final status

```text
DOOR III / HECATE CORE

PROVEN
GREEN
FROZEN
```

The next Orbo pass must treat this seam as frozen architecture unless the user explicitly reopens it.
