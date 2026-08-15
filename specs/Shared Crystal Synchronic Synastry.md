# Shared Crystal Synchronic Synastry

**Status:** recovered founding Field Theory operation. Design/reconciliation document, not yet an executable contract. Preserve this while specs archaeology determines how much of it already exists and where later plans drifted from the originating practice.

**Companion to:** `specs/Crystallized Moments - Moment Lock Favorites and Field Taxonomy.md` and `specs/Ideal Data Flow - Embryo AstroDNA Connectome Loom.md`.

---

## 0. The founding practice

The native's actual working method that led to Field Theory and Synchronic Synastry is:

1. preserve a meaningful moment or event as a chart;
2. composite Native A with that moment;
3. composite Native B with that same moment;
4. compare the two derived composites by synastry.

For an email Crystal `C`:

```text
A + C -> synchronic composite AC
B + C -> synchronic composite BC

AC <-> BC -> SYNCHRONIC SYNASTRY
```

The key word is **same**. `C` is one shared event field and one shared parent of both derived fields.

This is not merely ordinary synastry plus transits. It compares two emergent fields produced by two different persistent fields entering relation with the same crystallized moment.

---

## 1. The Crystal is the shared third parent

A Crystallized Moment already has the correct architectural shape for this operation:

```text
Crystal C
  time
  place / horizon where physically applicable
  physical AstroDNA
  provenance
```

Given a linked Field `F`, Orbo can derive:

```text
S(F, C) = composite(F, C)
```

or, in Field Theory vocabulary where the composite operation is expressed as refraction/midpoint:

```text
S(F, C) = refract(F, C)
```

The exact implementation contract is to be reconciled with `framing.js`, but the conceptual object is settled: **the Field and the Crystal produce a derived synchronic field**.

For two linked Fields:

```text
SA = S(A, C)
SB = S(B, C)

SynchronicSynastry(A, B, C) = relations(SA, SB)
```

Do not collapse `SA` and `SB` into a third composite merely to perform this reading. The relationship being examined is the relation **between the two derived fields**.

---

## 2. This belongs naturally to the Crystal process

The user should not have to reproduce the AstroGold workflow manually.

Today the manual conceptual flow is:

```text
save event
build A + event composite
build B + event composite
open synastry
set orb
read interchart aspects
```

The Orbo flow should be:

```text
CRYSTAL C
  |
  +-- linked Field A
  +-- linked Field B
          |
          v
   SYNCHRONIC SYNASTRY
```

The two synchronic composites are derived state, not user filing chores.

A Crystal detail can therefore expose at least these related readings without duplicating the stored moment:

```text
C              physical moment
A + C          A's synchronic field
B + C          B's synchronic field
(A + C) x (B + C)
               synchronic synastry
```

Horary, Journal, event reading, and other readers may operate on the same Crystal independently.

---

## 3. A useful working abstraction: the Moment Field Set

**Working name only:** `Moment Field Set`. Do not freeze this name before UI/architecture review.

For one Crystal `C` with linked Fields `F1...Fn`:

```text
MomentFieldSet(C) = {
  F1 -> S(F1, C),
  F2 -> S(F2, C),
  ...
  Fn -> S(Fn, C)
}
```

This lets a single meaningful moment be examined across one person, a pair, a family, a team, a project group, or any other legitimate set of Fields without minting duplicate event charts.

Pairwise relations become edges inside the set:

```text
S(F1,C) <-> S(F2,C)
S(F1,C) <-> S(F3,C)
S(F2,C) <-> S(F3,C)
```

The one-person case remains useful and does not require a pair.

---

## 4. Place and horizon must be reconciled against the founding method

This is a high-priority archaeology issue.

The founding AstroGold operation uses **one event chart as the common parent** of both composites. Conceptually, the Crystal has one physical celestial address, including the event's declared horizon when a place is known.

Therefore the clean shared-Crystal expression is:

```text
C = one physical AstroDNA

SA = midpoint(A, C)
SB = midpoint(B, C)
```

A later Orbo Phase 6/7 framing instead explored casting the same instant through each native's separate local horizon, producing two different moment Ascendants. That is a different operation.

Do not silently identify the two.

During archaeology determine:

1. whether the later two-horizon rule intentionally superseded the founding shared-event-chart method;
2. whether it arose accidentally from the implementation's available horizon machinery;
3. whether both are legitimate but must be named as different readings.

**Current recovery preference:** the founding operation has priority as the meaning of `Synchronic Synastry` unless the user explicitly rules otherwise after comparison.

A possible future local-horizon comparison can exist as a separately named lens if it proves useful. It must not replace the shared-Crystal operation by stealth.

---

## 5. Algebraic consequence: the common field cancels where it should

For the same body `P`, let the synchronic midpoint be expressed locally as:

```text
SA_P = midpoint(A_P, C_P)
SB_P = midpoint(B_P, C_P)
```

Within the selected midpoint branch/pole, the common Crystal term is shared. The separation between the two derived same-body placements is therefore governed by the native-to-native relation rather than by a second independent sky term.

This is the mathematical reason the later Prism work discovered stable same-body families.

But **cross-body relations remain time-sensitive**:

```text
SA_P versus SB_Q
```

contains `C_P` and `C_Q`, which move differently through celestial time. Those relations can perfect, separate, cross aspect boundaries, and form a genuine temporal chronology.

This distinction is foundational for a Synchronic Synastry spine:

```text
SAME-BODY
stable family / mode structure

CROSS-BODY
moving relation / perfection chronology
```

Do not flatten both into one event type.

### Ascendant consequence

If both derived fields share the **same Crystal Ascendant** as their moment parent, then the common event-horizon term also participates as a shared term. This differs from the later two-local-horizon formulation in which each side receives a different sky Ascendant and the difference can drift by place.

This is another reason the place rule must be reconciled explicitly rather than inherited from a later spec.

---

## 6. Derived AstroDNA and Connectome expression

The restored ideal data flow makes this operation cleaner than it was in AstroGold.

```text
Crystal C
  physical AstroDNA

Field A
  anchored AstroDNA

Field B
  anchored AstroDNA
```

Derive:

```text
SA = derived AstroDNA(A + C)
SB = derived AstroDNA(B + C)
```

Each derived AstroDNA then receives its own Connectome expression:

```text
Connectome(SA)
Connectome(SB)
```

Synchronic Synastry reads the relation edges between those two expressed states.

This preserves the architecture:

- Embryo mints the physical Crystal AstroDNA;
- the derived operation produces provenance-marked derived AstroDNA;
- Connectome expresses each derived field;
- Ring supplies geometry;
- Loom finds temporal crossings when the operation is extended through time;
- readers send the result through the Lunar Port.

No reader should reopen the ephemeris to reconstruct either composite.

---

## 7. Sect and Lots survive the operation

A derived synchronic composite has a derived Sun and, where the operation produces a meaningful derived horizon, a derived Ascendant/horizon.

Therefore it can have its own sect under the recovered AstroDNA rule:

```text
Sun above derived horizon -> diurnal
Sun below derived horizon -> nocturnal
```

Lots can then be derived from that derived state under the active doctrine.

This matters because the native's actual AstroGold Synchronic Synastry practice includes many Lots and other derived points in the interchart comparison, not only the seven classical planets.

The Orbo core does not need to expose every optional Lot by default. The architecture must simply avoid making them impossible by assuming only natal states can possess sect or derived points.

---

## 8. Crystals, Threads, and Spans make this feature much more useful

### One Crystal

A single email, call, first hearing, feeling, ritual hinge, or other moment can be read as:

```text
A + C
B + C
(A + C) x (B + C)
```

### A Thread

For a communication Thread:

```text
C1 = email sent
C2 = reply received
C3 = call
C4 = follow-up message
```

Orbo can compute the synchronic-synastry snapshot at each observational Crystal:

```text
SS(A,B,C1)
SS(A,B,C2)
SS(A,B,C3)
SS(A,B,C4)
```

The Thread then becomes a sequence of **life-selected samples of the relational field**.

This is much more informative than treating every message as an isolated event chart.

### A Span

For a bounded interval, Loom can solve the continuous relation between the two derived fields through the Span and report the exact perfections/changes that occurred between its start and end Crystals.

So:

```text
THREAD = discrete observed samples
SPINE  = continuous/computed temporal structure
SPAN   = a bounded interval through that structure
```

These are complementary, not competing representations.

---

## 9. Favorites make the pair computationally alive

If `A` and `B` are favorite Fields, Orbo should not have to build this relation from scratch every time a Crystal is linked to them.

Favoriting can maintain partial pair-spine coverage and the required Connectome state so that a new Crystal can immediately answer:

```text
what is A + this moment?
what is B + this moment?
what is happening between those two fields?
where does this Crystal sit on our longer pair spine?
```

This is the natural join between:

- Favorites
- Moment Lock
- Crystallized Moments
- Threads
- Spans
- Synchronic Synastry
- Field Journal evidence

---

## 10. The empirical/research payoff

This architecture preserves a distinction essential to Field Theory testing:

```text
COMPUTED SPINE
what Orbo says the field is doing continuously

OBSERVED CRYSTALS
moments life/user caused to be saved

JOURNAL EVIDENCE
what actually happened or was felt
```

A Thread of spontaneous messages, feelings, first hearings, or decisions can therefore be placed against the independently computed pair spine.

Orbo can ask after the fact:

- which synchronic-synastry relations recur at saved Crystals?
- what changes between a message and its reply?
- do subjective Moment Locks cluster around the same cross-body perfections?
- do journal outcomes repeat under structurally similar field states?

The observation timestamps come from lived experience first rather than from selecting an astrological condition first.

---

## 11. Process proposal

A likely user process is:

```text
1. CAPTURE OR SELECT CRYSTAL

2. LINK SUBJECT FIELDS
   me is implicit where appropriate
   add one or more saved/favorite Fields

3. ORBO DERIVES THE MOMENT FIELD SET
   one synchronic composite per linked Field

4. READ
   moment
   each Field + moment
   synchronic synastry between linked derived fields

5. OPTIONALLY ORGANIZE
   add Crystal to Thread
   pair with another Crystal as Span
   attach Journal evidence

6. IF FIELD IS FAVORITED
   place the Crystal on its partial spine/timeline
```

This removes the manual intermediate-chart bookkeeping while preserving the exact operation the native actually uses.

---

## 12. Provisional laws

1. **Synchronic Synastry begins from one shared Crystallized Moment.**
2. **The same Crystal is the common parent of every participant's synchronic composite.**
3. **Each participant plus Crystal produces a distinct derived field.**
4. **Synchronic Synastry compares those derived fields; it does not collapse them into a third composite.**
5. **The two derived composites are computational products, not filing chores for the user.**
6. **The shared-Crystal place/horizon rule must be reconciled against the later two-horizon spec before code changes.**
7. **Same-body and cross-body relations are different temporal classes and must remain distinguishable.**
8. **Threads are discrete life-selected samples; spines are continuous/computed structure; spans bound intervals.**
9. **A Favorite pair should make repeated shared-Crystal analysis cheap.**
10. **One Crystal may feed Synchronic Synastry, Horary, Journal, event, and other readers without being duplicated.**

---

## 13. Archaeology questions

Before implementation, trace:

- the original Field Theory white paper/transcript for the exact shared-event construction;
- `framing.js` and the definition of `refract`;
- Phase 4 pair-film intent;
- Phase 6 P7 Synastry and its two-horizon locality ruling;
- Phase 7 Synchronic Time pair spine;
- current composite and synchronic composite object shapes;
- whether current UI can compare two derived composites without accidentally double-refraction;
- whether event place, native birthplace, current location, or another horizon is currently used at each stage;
- how derived sect and Lots are currently obtained;
- how favorite pair identity is persisted and how a Crystal should reference that pair.

The goal is not to build a second synchronic-synastry engine. The goal is to recover the native's founding operation and route it through the settled Embryo -> AstroDNA -> Connectome -> Loom architecture.