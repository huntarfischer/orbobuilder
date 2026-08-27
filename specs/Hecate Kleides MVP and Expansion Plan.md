# Hecate · Kleides MVP and Expansion Plan

## Purpose

Hecate is Orbo's caster of lawful results from established points.

She does not seek, establish, or possess her ingredients. Other Orbo actors bring lawful resources to her. What they bring determines which of her spells can be cast.

> **It is not Hecate's to know. It is Hecate's to show.**

Her permanent spellbook is the **Kleides**. Each spell in it is a **kleis**.

```text
ESTABLISHED RESOURCES
        ↓
      HECATE
        ↓
      KLEIDES
        ↓
 requested kleis
        ↓
   lawful cast
        ↓
      RESULT
```

## Domain law

Hecate:

- receives established resources;
- never queries Horae, Timespine, Atlas, or another source for missing ingredients;
- consults the Kleides;
- casts only when the requested kleis exists and every required resource has been supplied;
- returns the lawful result of that spell;
- does not own Ring, Arc, Mater, or Tympan;
- does not start or require a Moirai/Tapestry workflow.

The same Hecate must be usable by ordinary Orbo runtime and by the Moirai.

## Kleides taxonomy

The Kleides begins with three separate shelves:

```text
Hecate/
└── Kleides/
    ├── AstroDNA/
    ├── Lots/
    └── Parts/
```

**AstroDNA** remains its own family unless a truer larger family emerges later.

**Lots** and **Parts** remain separate families from the beginning.

Additional spell families may be added only when their domain is understood.

## Admission law for a kleis

A candidate belongs in the Kleides when:

1. its required ingredients are already-established values;
2. its operation is deterministic;
3. the operation produces a lawful result from those supplied ingredients; and
4. Hecate does not need to seek additional truth in order to perform it.

The Kleides may contain many spells that are not castable from a particular resource inventory. Castability is determined by what Hecate is given.

## AstroDNA

AstroDNA is a reusable Hecate cast, not a service owned by the Moirai.

Once the canonical twelve node values are supplied, Orbo should be able to ask Hecate for AstroDNA without beginning a Tapestry commission.

During natal compilation, Clotho may eventually bring those same twelve established values to Hecate and receive AstroDNA as cast matter.

## Tapestry consequence

Fortune is not the only Hecate result worth preserving.

After the Kleides is substantially populated, the useful natal results it can cast should be considered for the complete thread set handed to Lachesis. The final cast inventory must be understood before Clotho is redesigned.

```text
HECATE MVP
    ↓
KLEIDES EXPANSION
    ↓
define complete useful cast inventory
    ↓
redesign CLOTHO
```

Do not return to Clotho before the Kleides expansion pass.

---

# Build order

## Stage 0 · Forge Hecate vocabulary and shelves

Create only the minimum reusable language:

```text
Hecate
Kleides
Kleis
KleisID
KleisFamily
HecateResourceKey
HecateFailure
```

Create the three Kleides source folders:

```text
AstroDNA/
Lots/
Parts/
```

Stage 0 behavior is limited to the cast gate:

```text
requested kleis
+ supplied resource keys
        ↓
      HECATE
        ↓
known kleis?
all required resources present?
```

If yes, the requested kleis is ready for a future cast.

If no, Hecate reports either:

```text
unknown kleis
missing resources
```

There is **no real spell and no cast result in Stage 0**.

Stage 0 must not modify Atlas, Hermes, Horae, Timespine, Moirai, Ring, Arc, Mater, Tympan, or existing AstroDNA behavior.

### Stage 0 gate

Tests prove:

1. Kleides recognizes its three families.
2. A kleis has one family and a unique non-empty resource requirement set.
3. Kleides rejects duplicate kleis identities.
4. Hecate accepts a known kleis when all required resources are supplied.
5. Hecate refuses an unknown kleis or a known kleis with missing resources.

Stop after local green.

## Stage 1 · AstroDNA kleis

Only after Stage 0 passes.

Add the first real spell under:

```text
Kleides/AstroDNA/
```

It requires the canonical twelve node states and returns canonical `AstroDNA`.

This stage proves that AstroDNA can be requested directly from Hecate without invoking the Moirai.

Do not change Clotho.

## Stage 2 · Fortune kleis

Only after Stage 1 passes.

Add the first real Lot under:

```text
Kleides/Lots/
```

Before implementation, freeze the exact Fortune doctrine, required resources, sect handling, and result representation. Do not silently adopt a simplified formula.

This stage proves a classic multi-point Hecate cast that returns a new lawful point.

Do not change Clotho.

---

# Kleides expansion campaign

After the MVP is green and frozen, immediately expand the Kleides before returning to the Moirai.

Research and add, one approved family/pass at a time:

```text
AstroDNA/
Lots/
Parts/
additional families only if warranted
```

The goal is not merely to collect names. Each kleis must freeze:

```text
identity
family
required resources
exact casting law
result type
failure conditions
```

The expansion campaign ends only when we have a credible inventory of the cast values that benefit from becoming natal Tapestry threads.

Only then redesign Clotho's procession:

```text
CLOTHO
  ↓
HORAE
  ↓
gathers established event resources
  ↓
HECATE
  ↓
casts required Kleides results
  ↓
CLOTHO gathers raw + cast matter
  ↓
complete thread set
  ↓
LACHESIS
```

## Frozen workflow discipline

For every stage:

1. inspect/orient;
2. design;
3. obtain explicit approval;
4. implement only the approved stage;
5. run the local green gate;
6. report the result;
7. advance only after approval.

No opportunistic refactors. No coding ahead.
