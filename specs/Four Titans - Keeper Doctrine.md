# Four Titans - Keeper Doctrine

**Status:** Stage 3 frozen

## Purpose

Place named sovereign keepers around the four frozen foundational laws without changing the laws themselves.

```text
THEMIS   keeps TYMPAN
RHEA     keeps MATER
OCEANUS  keeps RING
ASTERIA  keeps ARC
```

The distinction is permanent:

```text
TITAN
who is petitioned
        ↓
LAW
the canonical truth the Titan keeps
        ↓
CANONICAL MATTER
the existing structures of that law
```

A Titan does not replace, rename, absorb, or reimplement the law it keeps.

## Keeper Law

> Each Titan is keeper and authoritative witness of one foundational law. The law remains independently canonical. A Titan may testify only from the law it keeps.

## The Four Keepers

| Titan | Keeps | Canonical matter | Mythic act |
|---|---|---|---|
| **Themis** | Tympan | Imprints | **sets** |
| **Rhea** | Mater | Tempers and field condition | **bears** |
| **Oceanus** | Ring | Templates | **encircles** |
| **Asteria** | Arc | half-arc fields and composite truth | **refracts** |

## Boundaries

### Themis

Themis keeps Tympan.

She **sets form**.

She may testify to lawful whole-sign arrangement, Imprints, houses, signs, and governance already known by Tympan.

She does not condition, relate, or refract.

### Rhea

Rhea keeps Mater.

She **bears condition**.

She may testify to Tempers, planetary condition, rulership, reception, dependency, and field circuitry already known by Mater.

She does not set form, judge angular relation, or refract.

### Oceanus

Oceanus keeps Ring.

He **encircles relation impartially**.

He may testify to exact angular relation and the canonical relational targets already known by Ring and its Templates.

He does not interpret, privilege, rank, or moralize one relation over another, and he does not refract.

### Asteria

Asteria keeps Arc.

She **refracts celestial possibility**.

From one lawful coordinate, Arc reveals the complete bounded half-arc possibility field. From two lawful coordinates, Arc yields the exact composite state or Seam.

Asteria does not establish chronology, manifestation, or meaning.

## Mythic Grounding

The mythology illuminates the architecture but does not create software coupling.

- **Themis** is associated with setting, placing, and lawful order. She fits Tympan as keeper of the form set down by orientation and preserved in the Imprint.
- **Rhea** is the generative mother of the Olympian order. Her pairing with Cronus illuminates Orbo's zodiacal cosmology, but creates no software dependency between them in this pass.
- **Oceanus** encircles the world and remains neutral in the Titanomachy. He fits Ring as the impartial keeper who sees every angular relation around the circle without taking sides.
- **Asteria** is the wandering star and wandering isle, daughter of Phoebe and mother of Hecate. She fits Arc as keeper of bounded celestial possibility and composite transformation.

## Vocabulary

Asteria's keeper verb is **refract**.

```text
ASTERIA refracts.
HECATE may later cast.
```

`Cast` is therefore not Asteria's keeper verb.

The frozen Arc implementation may continue to use its existing internal `cast` and `compose` APIs. This doctrine does not rename or alter those proven internals.

## Keeper Routing

The proven transit now approaches the four laws through their keepers:

```text
AstroDNA
   ↓
THEMIS   → TYMPAN
RHEA     → MATER
OCEANUS  → RING
ASTERIA  → ARC
```

Keeper routing must preserve the same canonical answer as a direct law call.

## Frozen Testimony Contracts

Each keeper returns testimony in the natural shape of the law it keeps. The four testimonies are intentionally not forced into a common structure.

```text
ThemisPass
└── imprint: Tympan.Imprint

RheaPass
└── field: Mater.QualifiedField

OceanusPass
└── objectTemplates: [RingObjectTemplate]

AsteriaPass
├── refractions: [ArcSubjectCast]
└── projections: [ArcGrid]
```

The testimony law is:

> No Titan mutates, absorbs, or becomes owner of another Titan's testimony.

There is no generic `TitanPass<T>`, Titan protocol, superclass, or shared testimony abstraction in this freeze.

## Proof

The keeper-routed transit and the four testimony contracts passed the native Swift suite at the Stage 3 boundary:

```text
395 tests
0 failures
```

## Explicit Non-Scope

The Keeper Pass ends here.

Not included:

- Clotho changes
- Lachesis changes
- Titan's Pass orchestration
- Tapestry compilation
- Hecate implementation
- Synchronic Time work
- interpretation
- Titan hierarchy
- generic Titan protocol or generic Pass abstraction
- Rhea-Cronus software dependency
- Arc internal API renaming

Any work beyond this boundary requires a separate design and approval.
