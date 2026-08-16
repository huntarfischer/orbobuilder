# Phase 1a: Native Foundation Implementation Plan

**Status:** COMPLETE. Native foundation implemented and proven on 2026-08-16.

**Purpose:** Build the minimum native domain vocabulary, then efficiently manufacture and prove the foundational OrboCore components that Phase 1 depends on: Ring, Mater with the Rulers rehouse, and Tympan.

**Authority:** This plan operates under:

1. `specs/Orbo 1.0 Native Construction Plan.md`
2. `specs/Phase 0 - The Lab.md`
3. `specs/Phase 1 - The Ovum.md`
4. `specs/Native Port Manifest.md`

Phase 1a is an implementation slice inside Phase 1. It does not replace the Phase 1 authority.

---

# 1. Native Domain Vocabulary

The vocabulary receives the deepest design treatment because every later component plugs into it.

The purpose is not to create a grand abstraction layer. It is to make category mistakes impossible where confusing two values would corrupt Orbo.

## 1.1 Governing rule

Create a distinct native type when either:

```text
two values may have the same primitive representation
BUT
confusing them changes astrological meaning

or

a value has a closed canonical vocabulary
whose order or membership is structural
```

Do not wrap primitives merely to make Swift look architecturally elaborate.

The vocabulary should therefore be:

```text
small
explicit
Hashable where useful
Codable where fixtures require it
free of UI concerns
free of interpretation
free of speculative abstraction
```

---

## 1.2 Planet

`Planet` is the canonical identity of a celestial body used by foundational Orbo law.

Initial cases should reflect what the native foundation actually needs:

```swift
enum Planet {
    case sun
    case moon
    case mercury
    case venus
    case mars
    case jupiter
    case saturn

    case uranus
    case neptune
    case pluto
}
```

Do not automatically put the following inside `Planet`:

```text
Ascendant
MC
Node
Chiron
lots
angles
```

Those are different species of thing even if prototype code sometimes stores them beside planets.

The classical seven must have an explicit structural distinction, for example:

```swift
planet.isClassical
```

or an equivalent canonical collection:

```swift
Planet.classicalSeven
```

This prevents dignity and dispositor law from accepting Pluto merely because `Planet` contains Pluto.

### Required invariants

```text
classicalSeven contains exactly 7 bodies

traditional dispositor law
accepts only classicalSeven

canonical ordering is explicit
never dictionary-dependent
```

---

## 1.3 Sign

`Sign` is the twelve-case canonical zodiac.

```swift
enum Sign: Int {
    case aries = 0
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces
}
```

Using `Int` raw values is useful because canonical zodiacal order is structural.

This supports inexpensive operations such as:

```text
next sign
opposite sign
distance in signs
longitude -> sign
```

without leaking naked `0...11` integers into consumers.

### Sign owns identity, not meaning

`Sign` may know:

```text
Scorpio is Sign.scorpio
```

It must not become a second Mater by owning:

```text
Scorpio is water
Scorpio is fixed
Scorpio is ruled by Mars
```

Those remain Mater facts.

### Required invariants

```text
exactly 12 cases
Aries rawValue = 0
Pisces rawValue = 11
canonical iteration is zodiacal
opposition is six signs
```

---

## 1.4 House

`House` is a closed twelve-house ordinal vocabulary.

Do not represent houses publicly as the same zero-based address used by signs.

```swift
enum House: Int {
    case first = 1
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
    case tenth
    case eleventh
    case twelfth
}
```

This preserves the actual house ordinal and prevents these from fitting the same socket:

```swift
Sign.scorpio
House.eighth
```

Any zero-based indexing used for storage remains private inside Tympan.

### Required invariants

```text
exactly 12 cases
valid range 1...12
opposite house differs by 6
double opposition returns original
```

---

## 1.5 Element

```swift
enum Element {
    case fire
    case earth
    case air
    case water
}
```

No free-floating element strings in OrboCore.

Mater supplies:

```text
Sign -> Element
```

The enum itself does not maintain the zodiacal assignment.

---

## 1.6 Modality

```swift
enum Modality {
    case cardinal
    case fixed
    case mutable
}
```

Again:

```text
identity vocabulary
!=
Mater assignment table
```

---

## 1.7 Motion

`Motion` belongs in the native vocabulary because direct or retrograde state is categorical and used throughout Orbo.

```swift
enum Motion {
    case direct
    case retrograde
}
```

If stationary states later prove necessary as genuine AstroDNA identity rather than derived chronology, extend the type then.

Do not invent them now.

This also allows native Ring and AstroDNA work to stop using integer ranges as the public expression of retrogradation.

---

## 1.8 Sect

Use an explicit state:

```swift
enum Sect {
    case day
    case night
}
```

When sect is unknown:

```swift
Sect?
```

not:

```text
true
false
null
```

This matters particularly for Mater triplicity reads.

Mater may consume Sect.

Mater does not determine Sect.

---

## 1.9 CelestialLongitude

`CelestialLongitude` is the most important foundational numeric type.

It represents:

```text
a position on the celestial 360-degree circle
```

and prevents it from being confused with:

```text
geographic longitude
latitude
house
sign index
arbitrary Double
```

Conceptually:

```swift
struct CelestialLongitude {
    let degrees: Double
}
```

Construction should establish one canonical normalization policy.

Preferred canonical domain:

```text
0 <= longitude < 360
```

So, provided this agrees with the final Ring and AstroDNA fidelity contract:

```text
360 -> 0
-1 -> 359
721 -> 1
```

The governing implementation rule is:

> Normalize once at the boundary, not repeatedly throughout every engine.

### Useful derived reads

```text
sign
degreeWithinSign
```

These are positional geometry only.

`CelestialLongitude` must not become a second Mater by answering element, modality, rulership, dignity, or interpretation.

---

## 1.10 DegreeInSign

`DegreeInSign` earns a native type because bounds, faces, exaltation degrees, and other sub-sign laws repeatedly require a value whose legal domain is:

```text
0 <= degree < 30
```

Conceptually:

```swift
struct DegreeInSign {
    let value: Double
}
```

It should normally be derived from `CelestialLongitude`, not manually constructed throughout Core.

This prevents a 17-degree position within Scorpio from being confused with absolute celestial longitude 17 degrees.

---

# 1.11 Dignity Vocabulary

These types should exist before Mater receives Rulers so dignity law never falls back into free-form strings.

## DignityRung

```swift
enum DignityRung {
    case domicile
    case exaltation
    case triplicity
    case bound
    case face
}
```

This enum contains the five admitted positive essential dignities.

Do not put detriment and fall in this enum.

They are not lesser positive rungs.

---

## 1.12 EssentialDebility

```swift
enum EssentialDebility {
    case detriment
    case fall
}
```

Use a set rather than one optional value because both can be true simultaneously.

```swift
Set<EssentialDebility>
```

must be able to represent:

```text
detriment + fall
```

without one overwriting the other.

---

# 1.13 Doctrine Vocabulary

Doctrine types identify which admitted table is being read.

They do not become separate astrology engines.

## BoundsScheme

Initially:

```swift
enum BoundsScheme {
    case egyptian
}
```

When Ptolemaic bounds are actually implemented and proven, add:

```swift
case ptolemaic
```

Do not add placeholder cases backed by no data.

## TriplicityScheme

Initially:

```swift
enum TriplicityScheme {
    case dorothean
}
```

Add another scheme only when its table is implemented and proven.

## FaceScheme

Initially:

```swift
enum FaceScheme {
    case chaldean
}
```

---

## 1.14 DignityDoctrine

`DignityDoctrine` combines the independent switches.

```swift
struct DignityDoctrine {
    let bounds: BoundsScheme
    let triplicity: TriplicityScheme
    let faces: FaceScheme
}
```

The default profile should be explicit:

```swift
static let orboDefault
```

and initially resolve to:

```text
Egyptian bounds
Dorothean triplicity
Chaldean faces
```

The ownership law is:

```text
DignityDoctrine
is configuration

Mater
is authority
```

Doctrine does not become another engine.

---

# 1.15 Mater Result Records

These are values returned by Mater, not engines.

## Exaltation

Conceptually:

```swift
struct Exaltation {
    let planet: Planet
    let sign: Sign
    let degree: DegreeInSign
}
```

## Bound

```swift
struct Bound {
    let ruler: Planet
    let sign: Sign
    let start: DegreeInSign
    let end: DegreeInSign
    let scheme: BoundsScheme
}
```

Bounds use the half-open interval law:

```text
[start, end)
```

## Face

```swift
struct Face {
    let ruler: Planet
    let sign: Sign
    let decan: Int
    let scheme: FaceScheme
}
```

The exact native representation of decan ordinal can be tightened later if tests prove a dedicated type earns its keep.

## Triplicity

The record must preserve all three facts:

```text
day ruler
night ruler
participating ruler
```

Do not prematurely collapse triplicity into one ruler.

The operative ruler may be derived when Sect is supplied.

---

## 1.16 EssentialCondition

This becomes Mater's comprehensive dignity answer.

Conceptually:

```swift
struct EssentialCondition {
    let planet: Planet
    let longitude: CelestialLongitude

    let dignities: Set<DignityRung>
    let debilities: Set<EssentialDebility>

    let bound: Bound
    let face: Face
    let triplicity: Triplicity

    let isPeregrine: Bool
}
```

Prefer deriving peregrine rather than independently storing it:

```text
isPeregrine
=
dignities.isEmpty
```

The native design should make contradictory states such as this impossible:

```text
dignities = [face]
isPeregrine = true
```

If the final Swift representation can derive `isPeregrine` as a computed property, do that.

---

# 1.17 What Does Not Belong in the Foundational Vocabulary Yet

Do not prematurely manufacture types for:

```text
CombustionState
CazimiState
SolarPhase
AccidentalDignity
AngularityScore
ReceptionStrength
AlmutenScore
InterpretationWeight
HouseMeaning
PlanetaryConditionScore
```

Those require later ownership archaeology.

Likewise, do not invent protocols such as:

```text
DignityProviding
ZodiacResolving
PlanetConditionService
MaterProtocol
```

until there is a real substitution requirement.

The initial native foundation is concrete by design.

---

# 1.18 Vocabulary Proof

Before Ring construction begins, test the vocabulary itself.

Required proof includes:

```text
12 Signs
12 Houses
4 Elements
3 Modalities
7 classical planets

Sign ordering exact
House ordering exact

Sign and House are not interchangeable at compile time

CelestialLongitude canonicalization
DegreeInSign bounds
Sect optionality

DignityRung contains exactly five admitted positive dignities
EssentialDebility supports simultaneous detriment + fall

DignityDoctrine.orboDefault resolves to:
Egyptian / Dorothean / Chaldean
```

Then stop building vocabulary.

If Ring later requires a Ring-specific type, Ring owns it locally.

---

# 2. Efficient Ring Implementation

Implement Ring as one coherent production pass, not a procession of tiny subprojects.

Likely physical layout:

```text
native/OrboCore/Sources/OrboCore/
  Ring/
    Ring.swift
    RingTypes.swift
```

Port the complete proven Ring law.

Use the existing Phase 0 fixture apparatus to support:

```text
unit invariants
exhaustive sweeps
aspect atlas agreement
prototype parity
```

Do not introduce ornamental abstractions around Ring.

When all focused and accumulated proof passes:

```text
Ring = NATIVE CANONICAL
```

Then move on.

---

# 3. Efficient Mater plus Rulers Rehouse

Implement the entire native owner compactly.

Likely physical layout:

```text
native/OrboCore/Sources/OrboCore/
  Mater/
    Mater.swift
    DignityTables.swift
    DignityDoctrine.swift
```

These are implementation files under one owner:

```text
OrboCore / Mater
```

They are not separate architectural components.

## Mater.swift

Own:

```text
sign ordering
element
modality
traditional domicile
classical dispositor set
exaltation
exaltation degree
detriment
fall
canonical sign and dignity reads
complete essential-condition composition
```

## DignityTables.swift

Hold Mater's immutable internal data for:

```text
Egyptian bounds
Chaldean faces
Dorothean triplicity
```

These are Mater's data, not another component.

## DignityDoctrine.swift

Own:

```text
scheme vocabulary
Orbo default profile
selection logic
```

There is no native production `Rulers.swift` component.

The surviving law from prototype `rulers.js` is rehoused into Mater.

---

# 4. One Comprehensive Mater Parity Corpus

Do not manually rewrite every browser assertion as a bespoke Swift test.

Generate a machine-readable reference fixture from the proven prototype authority.

The fixture should include:

```text
12 sign facts

12 domicile rulers

7 exaltations
7 exaltation degrees

12 detriment reads
12 fall reads

60 Egyptian bounds
36 faces
4 triplicity groups

every bounds boundary
every face boundary

representative and exhaustive dignity combinations

day sect
night sect
unknown sect

multiple-dignity cases
multiple-debility cases
peregrine cases
```

Swift XCTest then consumes that corpus with table-driven assertions.

A small number of test functions should execute hundreds or thousands of comparisons.

The production runtime never reads parity JSON.

Fixtures remain construction evidence only.

---

# 5. Mater Proof

Use both targeted invariant tests and exhaustive generated checks.

Required proof includes:

```text
each bounds row ends exactly at 30
all bounds cover exactly 360

face cycle covers 36 decans
each face covers exactly 10 degrees

triplicity groups map to the correct elements

domicile exact
exaltation exact

detriment = opposite domicile
fall = opposite exaltation

peregrine iff no positive dignity

detriment and fall may coexist
multiple positive dignities may coexist

modern planets never acquire classical essential dignity
unless a future admitted doctrine explicitly establishes otherwise
```

When all focused, parity, and accumulated proof passes:

```text
Mater = NATIVE CANONICAL
Rulers = REHOUSED
```

There is no separate native Rulers object to certify.

---

# 6. Minimal OrboLab Mater Microscope

OrboLab receives one utilitarian readout after the native Mater works.

Inputs:

```text
Planet
Longitude
Sect
Doctrine
```

Readout:

```text
Sign
Element
Modality

Domicile
Exaltation

Triplicity
Bound
Face

Detriment
Fall

Peregrine
```

Its purpose is visual interrogation of real OrboCore output.

It is not:

```text
a second authority
a fixture owner
a polished product screen
an interpretation surface
```

Tests prove Mater. OrboLab lets us inspect Mater.

---

# 7. Efficient Tympan Implementation

Once Mater is native canonical, build Tympan.

Likely physical layout:

```text
native/OrboCore/Sources/OrboCore/
  Tympan/
    Tympan.swift
    TympanTypes.swift
```

Tympan consumes native Mater directly.

Do not copy Mater's ruler tables.

Implement the complete Tympan law as one pass:

```text
sign -> house
house -> sign

house -> traditional ruler

traditional planet -> houses governed

modern co-ruler -> house co-governed

frame record

opposite-house law
```

Use exhaustive generated proof because the domain is tiny:

```text
12 x 12 forward cells
12 x 12 reverse cells
84 traditional governor/frame reads
modern co-rulership
all round trips
all oppositions
```

When focused, parity, and accumulated proof passes:

```text
Tympan = NATIVE CANONICAL
```

---

# 8. Minimal OrboLab Tympan Microscope

Given:

```text
Rising Sign
```

show:

```text
House 1 -> sign -> traditional ruler -> optional modern co-ruler
...
House 12
```

and optionally reverse governance, for example:

```text
Mars governs houses:
...
```

This is diagnostic only.

---

# 9. Accumulated Proof Law

Every native-canonical promotion runs the entire accumulated suite.

The sequence is:

```text
Vocabulary
PASS
```

then:

```text
Vocabulary + Ring
PASS
```

then:

```text
Vocabulary + Ring + Mater
PASS
```

then:

```text
Vocabulary + Ring + Mater + Tympan
PASS
```

A later component is never allowed to silently disturb an earlier canonical law.

---

# 10. Efficient Working Rhythm

For each production component:

```text
inspect final prototype authority
        ↓
prepare parity fixture
        ↓
write compact native implementation
        ↓
run focused tests
        ↓
run accumulated suite
        ↓
inspect in OrboLab
        ↓
record proof in Native Port Manifest
        ↓
declare NATIVE CANONICAL
```

Avoid this pattern:

```text
write speculative architecture
write protocols
write factories
write adapters
write mocks
write component
discover none of the abstractions were needed
```

The foundation should be deliberately boring.

---

# 11. Phase 1a Completion State

The completed Phase 1a foundation is:

```text
OrboCore

Domain
    Planet
    Sign
    House
    Element
    Modality
    Motion
    Sect
    CelestialLongitude
    DegreeInSign
    DegreeBoundaryInSign
    dignity vocabulary

Ring
    NATIVE CANONICAL

Mater
    NATIVE CANONICAL
    complete essential-dignity owner

Rulers
    REHOUSED INTO MATER
    PROVEN / COMPLETE

Tympan
    NATIVE CANONICAL
```

The final closure also added `FoundationIntegrationTests`, proving Ring, Mater and Tympan compose through one native foundation rather than merely passing in isolation.

Phase 1 now continues into the terrestrial and celestial-address work of the Ovum rather than continuing to polish this foundation indefinitely.

---

# 12. Phase 1a Closure Record

Phase 1a was explicitly authorized and implemented in five passes:

```text
Pass 1    Native domain vocabulary
Pass 2    Ring
Pass 3    Mater + Rulers rehouse
Pass 4    Tympan
Pass 5    Foundation closure
```

The final standalone `OrboCore` Xcode run on 2026-08-16 reported:

```text
13 DomainTests                         PASS
4 FixtureInfrastructureTests          PASS
3 FoundationIntegrationTests          PASS
12 MaterTests                          PASS
1 Phase 0 linkage sentinel test       PASS
12 RingTests                           PASS
10 TympanTests                         PASS
------------------------------------------
55 total                              PASS
0 failures
```

The final OrboLab launch also displayed live native readouts from:

```text
Ring
Mater
Tympan
```

including the shared sample foundation read used by `FoundationIntegrationTests`.

The production Orbo shell no longer consumes the Phase 0 linkage sentinel. The sentinel remains only as an inert historical smoke fixture inside OrboCoreTests and does not define or gate the Phase 1a production API.

Phase 1a is therefore:

```text
COMPLETE
```

The next construction slice is documented in:

```text
specs/Phase 1b - Ovum Completion Outline.md
```

That outline does not preassign future 4R outcomes. Every meaningful Phase 1b component still begins with fresh archaeology and receives exactly one earned primary 4R treatment before implementation.