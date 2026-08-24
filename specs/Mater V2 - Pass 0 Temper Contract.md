# Mater V2 — Pass 0 Temper Contract

Status: PASS 0 FROZEN
Branch: `feature/mater-v2`
Date: 2026-08-24

## Purpose

Mater V2 reorganizes existing Mater truth around a reusable form:

> **Mater Temper** = the fixed-shape zodiacal condition record for one planet in one sign.

Orbo's priority is reference over recalculation. If a Mater fact can be settled once, it is recorded once and reused by natal, mundane, electional, and later synchronic reads.

The planet is the header. Each planet has twelve canonical sign Tempers.

```text
VENUS
  Aries Temper
  Taurus Temper
  ...
  Pisces Temper
```

Canonical Temper headers are the ten `Planet.canonicalOrder` bodies:

```text
Sun Moon Mercury Venus Mars Jupiter Saturn Uranus Neptune Pluto
```

Ascendant, Nodes, lots, and other points may participate later in field disposition, but they are not planetary Temper headers.

## 1. Fixed-shape rule

A resolved planet record does not gain or lose fields as it moves. Fields remain present; boolean values change.

This supports fast astrolabe scrubbing and the same read shape across natal, mundane, electional, and synchronic states.

### Sign flags

Exactly one is true:

```text
Aries Taurus Gemini Cancer Leo Virgo
Libra Scorpio Sagittarius Capricorn Aquarius Pisces
```

### Element flags

Exactly one is true:

```text
fire earth air water
```

### Modality flags

Exactly one is true:

```text
cardinal fixed mutable
```

### Condition flags

All are always present:

```text
domicile
exaltation
triplicity
bound
face
detriment
fall
peregrine
mutualReception
```

Associated identity/detail values remain separate from the booleans where needed, for example:

```text
boundRuler
faceRuler
triplicityRuler
mutualReceptionWith
mutualReceptionKind
```

A boolean answers the immediate condition question. Detail fields answer the circuitry or provenance question. A reader must not reconstruct the boolean from the detail field.

## 2. Canonical sign Tempers

Each planet has twelve reusable sign Tempers.

A sign Temper contains every condition that can be settled from:

```text
planet + sign + frozen Mater doctrine
```

Examples:

```text
VENUS · ARIES TEMPER
Aries: true
detriment: true
domicile: false
...

VENUS · TAURUS TEMPER
Taurus: true
domicile: true
detriment: false
...
```

The same Venus-in-Aries Temper is referenced whether Venus is natal, mundane, electional, or synchronic.

## 3. Degree-sensitive qualifiers

Do not create 360 full Tempers per planet.

Only the Mater facts that genuinely vary within a sign remain degree-sensitive. The existing native authorities are retained:

```text
exact exaltation degree
Egyptian bound
Chaldean face
```

The sign Temper carries sign-level exaltation. The degree-sensitive read separately records whether the planet is at its exact exaltation degree.

Example:

```text
Sun anywhere in Aries
  exaltation: true

Sun at 19° Aries
  exaltation: true
  atExaltationDegree: true
```

Bounds and faces continue to use their canonical native tables. The resolved planet record exposes `bound` and `face` as booleans plus their ruler/detail values.

No other sub-sign Mater doctrine is added in Pass 0.

## 4. Sect

Sect does not create a different Temper shape.

A resolved chart state carries:

```text
sectDay: true/false
sectNight: true/false
```

Mater already possesses both day and night triplicity rulers. The supplied sect selects the already-known triplicity result; it does not create new doctrine.

The reusable Temper form must therefore support the final `triplicity` boolean without requiring a schema change when sect changes.

## 5. Traditional and modern channels

Traditional and modern rulership are both preserved. User/Orbo selection is a read choice, not a destructive rewrite of the stored Mater truth.

### Traditional baseline

The current classical doctrine remains unchanged:

```text
traditional domicile
traditional detriment = opposite domicile
exaltation
fall = opposite exaltation
triplicity
bound
face
peregrine
```

The classical seven remain the traditional dispositor backbone.

### Modern baseline admitted in V2

For now, modern planetary condition adds only the agreed domicile/detriment facts:

```text
Pluto
  domicile: Scorpio
  detriment: Taurus

Uranus
  domicile: Aquarius
  detriment: Leo

Neptune
  domicile: Pisces
  detriment: Virgo
```

No modern exaltation, fall, triplicity, bound, face, reception, or dispositor doctrine is invented in Pass 0.

The storage contract must keep traditional and modern rulership facts distinguishable so the user or Orbo can toggle the rulership channel without recalculating the chart.

Future modern doctrine may populate additional Temper facts without changing what a Temper fundamentally is.

## 6. Reusable facts vs field-dependent facts

A canonical sign Temper is reusable because it does not depend on the other placements in a chart.

Some Mater facts only become knowable once a complete field is supplied. They still belong in the same fixed resolved planet shape, but they are not baked into the reusable sign Temper.

Field-dependent facts include:

```text
bearer
dispositor path
keeper
terminal kind
cycle membership
mutualReception
mutualReceptionWith
immediate dependents
transitive descendants
```

The fixed boolean rule still applies. For example, `mutualReception` is always present and is resolved to true or false for the supplied field.

## 7. Tympan boundary

Pass 0 does not reopen Tympan V2.

These remain Tympan facts:

```text
12 Imprints
house ↔ sign form
traditional house governorship
modern house governorship
Governance Lattice
```

Mater does not reconstruct governorship.

Later placement circuitry may consume a frozen Tympan Imprint together with actual placements. That is Pass 3 work, not part of the canonical Temper.

## 8. Ring and Arc boundary

Mater remains independent of Ring and Arc.

```text
Ring   → angular relationship law
Mater  → zodiacal condition law
Tympan → whole-sign form / governance law
Arc    → synchronic union geometry
```

Arc may produce a synchronic coordinate; Mater may then resolve that coordinate through the same Tempers used everywhere else.

## 9. Pass 0 acceptance contract

Pass 0 is complete when the following are frozen:

- the name `Mater Temper`
- planet as header
- 10 canonical planetary headers
- 12 reusable sign Tempers per planet
- fixed-shape sign, element, modality, and condition booleans
- separate identity/detail fields where a boolean needs provenance
- exact exaltation degree, bound, and face as the only admitted sub-sign qualifiers for this pass
- `sectDay` / `sectNight` fixed state
- traditional and modern rulership stored as distinguishable channels
- modern baseline limited to Pluto/Scorpio↔Taurus, Uranus/Aquarius↔Leo, Neptune/Pisces↔Virgo domicile/detriment
- field-dependent disposition/reception facts distinguished from reusable sign Tempers
- Tympan, Ring, and Arc boundaries preserved

## Next passes

```text
1  REUSABLE TEMPERS
2  FIELD TEMPER
3  PLACEMENT + CROSS-FIELD
4  QUALIFICATION
```

Pass 0 contains no implementation and changes no runtime behavior.
