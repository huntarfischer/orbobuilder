# Native Port Manifest

**Status:** Living native port authority for Orbo 1.0 construction.

**Last updated:** 2026-08-16

**Governing authorities:**

1. `specs/Orbo 1.0 Native Construction Plan.md`
2. `specs/Phase 0 - The Lab.md`
3. `specs/Phase 1 - The Ovum.md`
4. `specs/Phase 1a - Native Foundation Implementation Plan.md`
5. `specs/Phase 1b - Ovum Completion Outline.md`
6. `specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md`

This document is the maintained ledger and manifest for moving solved Orbo work from the JavaScript/HTML prototype into native Orbo 1.0.

It does not replace the governing plans. It records the decisions earned while following them.

---

# 0. Maintenance Law

This file is **living construction evidence**.

Every meaningful component pass must update this manifest.

A pass is not complete until this document records the result.

For each component:

1. inspect the current prototype source and relevant tests / fixtures
2. state the component's current job
3. state the actual law it owns
4. identify current dependencies and consumers
5. choose exactly one primary 4R treatment
6. state why that treatment is correct
7. define the native owner and mating surface
8. record the Swift Sanding decisions
9. declare the parity standard before implementation
10. record proof evidence after implementation
11. update status only when the relevant gate has actually been passed

Do not infer a 4R result merely because a future phase predicts one.

`PENDING` means the assessment has not yet been earned.

Each named component receives **one primary 4R treatment**:

```text
REPLICATE
REHOUSE
REPRODUCE
RETIRE
```

Swift Sanding is a separate pass after 4R. It does not split one component across multiple 4R labels.

If inspection proves that one apparent component actually contains multiple independently owned components, establish that ontology first, create separate manifest entries, and then give each component one primary 4R treatment.

---

# 1. Phase 0 Native Worksite Proof

The native worksite has been proven through the initial environment gate.

```text
OrboCore builds independently         PASS
OrboCore tests run                    PASS
OrboCore has no SwiftUI dependency    PASS

OrboLab builds in Xcode               PASS
OrboLab runs in simulator             PASS
OrboLab runs on physical iPhone       PASS
OrboLab links to OrboCore at runtime  PASS

Orbo builds in Xcode                  PASS
Orbo runs in simulator                PASS
Orbo runs on physical iPhone          PASS
Orbo links to OrboCore                PASS

Prototype/native separation           PASS
ios-wrapper untouched                 PASS
No premature Phase 1 component port   PASS
```

The original `OrboCoreBuild.linkageSentinel` remains only as an inert historical smoke fixture inside `OrboCoreTests`. The production Orbo shell no longer consumes it, and the Phase 1a OrboLab now proves live OrboCore linkage by reading Ring, Mater and Tympan directly.

---

# 2. Native Proof Apparatus

## Prototype source

Prototype browser test suites, fixtures, parity harnesses, and `tests/_suite.html`.

## Current job

Preserve known truths independently of the new Swift implementation, execute native laws, and determine whether a component is safe to become native canonical.

## Actual law

Tests are construction machinery, not an afterthought.

Native proof must support:

```text
unit laws
golden expected answers
cross-language parity
exhaustive invariants
integration accumulation
explicit PASS / FAIL evidence
```

## 4R

**REPRODUCE**

## Why

The prototype solved the testing problem correctly, but native Orbo should not preserve HTML runners, DOM readouts, browser globals, script-order dependencies, or browser fixture loading.

Preserve the behavior, acceptance criteria, fixtures, and proof discipline. Manufacture native test machinery in Swift/XCTest.

## Native owner

```text
OrboCoreTests
```

Production `OrboCore` must not depend on golden fixtures, parity fixtures, or XCTest infrastructure.

## Native layout

```text
native/OrboCore/
├── Sources/
│   └── OrboCore/
└── Tests/
    └── OrboCoreTests/
        ├── FixtureSupport/
        ├── Fixtures/
        │   ├── Golden/
        │   └── Parity/
        └── component tests
```

One fixture mechanism supports two different authorities:

### Golden

A known correct answer preserved independently of the new implementation.

### Parity

A prototype answer preserved specifically to compare the native transpose against the reference specimen.

The Swift runtime never calls JavaScript to obtain an answer.

## Swift Sanding

```text
HTML test runner
-> XCTest

DOM PASS / FAIL rows
-> XCTest assertions

fetch() fixture loading
-> SwiftPM test resources

JavaScript dynamic fixture objects
-> Codable fixture records where useful

browser globals
-> disappear

truthiness / undefined traps
-> Swift types and explicit Optional

one giant browser suite page
-> accumulated native test suite
```

## OrboLab boundary

OrboLab does not own tests.

```text
OrboCoreTests
    proves

OrboLab
    interrogates actual OrboCore when useful
```

OrboLab may later display construction internals from native components. It must not become the source of truth for test fixtures or test outcomes.

## Proof gate

Before the first production astrology component uses the apparatus, prove that:

```text
a Golden fixture can be loaded
a Parity fixture can be loaded
fixtures can be decoded
a mismatch is detectable
a missing fixture fails explicitly
SwiftPM / XCTest runs the apparatus
existing Core tests remain green
```

## Status

**IMPLEMENTED / NATIVE PROVEN**

The exact fixture apparatus was first dry-run with SwiftPM before repository installation: 5 tests passed, 0 failures.

Native Xcode proof was then completed on 2026-08-15 by opening `OrboCore` as the standalone Swift package and running its test action on the development Mac. Xcode reported **5 passed** with one test target:

```text
testGoldenFixtureLoadsAndDecodes()    PASS
testMismatchIsDetectable()            PASS
testMissingFixtureFailsExplicitly()   PASS
testParityFixtureLoadsAndDecodes()    PASS
testPhaseZeroLinkageSentinel()        PASS
```

The native proof apparatus gate is satisfied.

## Phase 1a native domain vocabulary proof

Phase 1a Pass 1 installed the approved native vocabulary directly under:

```text
native/OrboCore/Sources/OrboCore/Domain/
```

The pass established the typed foundational sockets required by Ring, Mater and Tympan, including:

```text
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
DignityRung
EssentialDebility
dignity doctrine vocabulary
```

`Package.swift` required no source-layout change.

Native Xcode proof was completed on 2026-08-15 by running the standalone `OrboCore` package test action on the development Mac. The accumulated suite reported:

```text
13 DomainTests                         PASS
4 FixtureInfrastructureTests          PASS
1 Phase 0 linkage sentinel test       PASS
------------------------------------------
18 total                              PASS
0 failures
```

Phase 1a Pass 1 is **IMPLEMENTED / NATIVE PROVEN**.

---

# 3. Port Ledger

| Component | Primary 4R | Parity | Native destination | Status |
|---|---|---|---|---|
| Native proof apparatus | REPRODUCE | Behavioral | OrboCoreTests | IMPLEMENTED / NATIVE PROVEN |
| Ring | REPLICATE | EXACT | OrboCore / Ring | NATIVE CANONICAL |
| Mater | REPLICATE | EXACT | OrboCore / Mater | NATIVE CANONICAL |
| Tympan | REPLICATE | EXACT | OrboCore / Tympan | NATIVE CANONICAL |
| Rulers | REHOUSE | STRUCTURAL | OrboCore / Mater | PROVEN / COMPLETE |
| Geoplacement Atlas | REPRODUCE | BEHAVIORAL | OrboCore / GeoplacementAtlas | NATIVE CANONICAL |
| Civil Time | REPRODUCE | BEHAVIORAL | OrboCore / CivilTime | NATIVE CANONICAL |
| AstroDNA | REPRODUCE | STRUCTURAL | OrboCore / AstroDNA | NATIVE CANONICAL |
| Ephemeris Kernel | REPRODUCE | STRUCTURAL | OrboCore / Ephemeris | REFERENCE QUALIFIED / PASS 4 COMPLETE |
| Forge | REPRODUCE | STRUCTURAL | OrboCore / Forge | OWNERSHIP QUALIFIED / PASS 4 COMPLETE |
| Mundane Timespine | PENDING | PENDING | OrboCore / MundaneTimespine | PASS 5 READY |
| Timespine temporal lessons | PENDING | PENDING | PENDING | ARCHAEOLOGY CAPTURED |
| Loom | PENDING | PENDING | PENDING | QUEUED |

The Phase 1 plan may contain expected 4R treatments. Those expectations are hypotheses until the component's actual pass is performed and recorded here.

---

# 4. Component Card Template

Use this structure for every significant component pass.

```markdown
## Component: <name>

### Prototype source

### What it currently does

### Actual law

### What is proven

### Current dependencies

### Current consumers

### Known tests / fixtures

### User-visible consequence

### 4R
<exactly one: REPLICATE / REHOUSE / REPRODUCE / RETIRE>

### Why

### Swift Sanding

### Native destination

### Native dependencies

### Native mating surface

### Parity standard
<EXACT / STRUCTURAL / BEHAVIORAL / RETIREMENT PROOF>

### Proof method

### Proof evidence

### Status
```

---

# 5. Component: Ring

## Prototype source

Primary authority:

```text
ring.js
```

Reference / browser material:

```text
ring.browser.js
```

Primary proof material:

```text
tests/ring.test.html
tests/fixtures/aspect-atlas.md
tests/rewire-parity.test.html
```

Native implementation:

```text
native/OrboCore/Sources/OrboCore/Ring/Ring.swift
native/OrboCore/Sources/OrboCore/Ring/RingTypes.swift
```

Native proof material:

```text
native/OrboCore/Tests/OrboCoreTests/RingTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/ring-parity.json
```

## What it currently does

The Ring is the prototype's inherent circular relationship surface.

It provides the universal degree geometry consulted by multiple later systems without knowing what occupies those positions.

The native implementation transposes that same law into typed Swift without introducing occupants, sign meaning, time, place, orb or interpretation.

## Actual law

The Ring owns:

```text
360-degree circular geometry
the eleven admitted marks
coarse Ring addressing
fine Ring addressing
direct / retrograde address encoding
exact target relationships
directed separation
folded arc distance
nearest admitted mark
exact admitted relation
supplement relationships
coarse-from-fine projection
error / absence behavior
```

It does not own:

```text
occupants
time
place
sign meaning
houses
rulers
orb
interpretation
```

## What is proven

Prototype tests and parity work establish, among other laws:

```text
11 admitted marks
septiles deliberately absent
360 degree positions
720 coarse motion-aware states
2,592,000 fine motion-aware states
motion-blind relationship geometry
exact fine-to-coarse projection
lower-mark tie rule
0 is a valid conjunction
absence is distinct from conjunction
no tolerance inside exact relation
supplement closure of the admitted mark set
immutable stamped relationship behavior
720-state / 14,400-target aspect atlas agreement
```

The native suite exercises the same laws, including exhaustive coarse-state relation and target sweeps, and has passed its accumulated standalone Xcode proof gate.

## Current dependencies

Prototype Ring has none.

Native Ring depends only on the Phase 1a domain vocabulary where stronger native categories replace JavaScript validators:

```text
CelestialLongitude
Motion
```

Ring remains independent of Mater, Tympan, AstroDNA, time, place and interpretation.

## Current consumers

Prototype consumers include systems that require canonical aspect / degree geometry, including AstroDNA, framing, Loom-related work, and parity/readout machinery.

Native Ring is now canonical and may be consumed by later native components whose own architecture requires Ring geometry.

## Known tests / fixtures

Prototype:

```text
tests/ring.test.html
tests/fixtures/aspect-atlas.md
tests/rewire-parity.test.html
```

Native:

```text
native/OrboCore/Tests/OrboCoreTests/RingTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/ring-parity.json
```

## User-visible consequence

Any later Orbo feature that reads relationships between celestial positions depends on the Ring remaining stable. A Ring error can move aspect identity or target geometry across natal, mundane, synchronic, temporal, and derived reads.

## 4R

**REPLICATE**

## Why

The component has a coherent single responsibility, no astrological dependency, mature tests, a golden human-auditable atlas, and later prototype systems already treat it as canonical degree-relation authority.

No architectural defect has been found that justifies reopening its solved design.

Replication does not require line-for-line Swift translation. It requires preservation of the Ring's law, behavior, tests, and proven outputs.

## Swift Sanding

The native implementation applies the approved sanding without changing Ring law:

```text
11 numeric angle constants
-> RingMark enum

integer state accepted by every public read
-> RingState, valid only for 0..<720

integer fine state accepted by every public read
-> RingFineState, valid only for 0..<2,592,000

truthy / falsey retrograde flag
-> Motion

non-zero numeric direction sign
-> RingDirection.minus / .plus

arbitrary finite separation Number
-> RingSeparation with finite validation and canonical normalization

0 conjunction versus null absence
-> RingMark.conjunction versus Optional.none

mutable-looking returned row / plate views
-> immutable Swift value records and private stamped tables

Object.freeze and typed-array mutation defenses
-> immutable static values and private storage

browser-global registration
-> no native counterpart

ring.browser.js
-> no production native mirror
```

The JavaScript source used runtime validators because every argument entered as an untyped Number or flag. Native Ring moves those checks to type construction so malformed state IDs, fine-state IDs, unknown marks and ambiguous directions cannot enter ordinary Ring reads.

The stamped target authority remains private. Consumers receive values, not a writable live plate.

## Native destination

```text
OrboCore / Ring
```

## Native dependencies

Only the minimum Phase 1a domain vocabulary required to keep unlike things unlike.

Ring must not depend on Mater, Tympan, AstroDNA, ephemeris, Orbo Spine, Loom, UI, time, place, or interpretation.

## Native mating surface

The implemented native surface provides typed equivalents of the prototype's meaningful capabilities:

```text
coarse state encoding
fine state encoding
fine -> coarse projection
target degree / target states
complete row reads
exact relation / related
separation / folded arc
nearest mark / residual
exact mark
supplement
```

Later native components must receive canonical Ring geometry from OrboCore rather than reintroducing competing angle tables or asking the JavaScript prototype at runtime.

The public surface should expose only what downstream native components actually require. Lab-only or test-only inspection does not automatically become production API.

## Parity standard

**EXACT**

```text
same valid input
same Ring law
same output
```

Swift type shape is allowed to differ where the type system replaces a JavaScript validation trap. The resulting valid-domain answers must remain exact.

## Proof method

```text
native unit laws
+
exhaustive invariant sweeps
+
720-row / 14,400-target atlas law
+
compact JavaScript-reference parity fixture
+
full motion-blind relation sweep
+
fine-to-coarse projection checks
+
accumulated integration tests
```

## Proof evidence

Implementation is present.

A local Swift preflight of the Ring suite reported:

```text
12 RingTests    PASS
0 failures
```

Native Xcode proof was completed on 2026-08-16 by running the standalone `OrboCore` package test action on the development Mac. The accumulated suite reported:

```text
13 DomainTests                         PASS
4 FixtureInfrastructureTests          PASS
1 Phase 0 linkage sentinel test       PASS
12 RingTests                           PASS
------------------------------------------
30 total                              PASS
0 failures
```

The native Ring tests include:

```text
all 720 coarse state encodings
all 720 rows
14,400 exact atlas targets
full 360 x 360 absolute-degree relation surface under all direct/retro combinations
fine-state projection checks
all nine lower-angle tie cases
supplement closure
prototype doctrine example
compact parity fixture reads
```

The accumulated Xcode gate is satisfied.

## Status

**NATIVE CANONICAL**

Ring may now serve as the canonical native degree-relation authority for later components.

---

# 6. Component: Mater

## Prototype source

Primary authority:

```text
mater.js
```

Reference / browser material:

```text
mater.browser.js
```

Primary proof material:

```text
tests/mater.test.html
tests/rulers.test.html
tests/rewire-parity.test.html
```

Relevant ownership neighbors:

```text
tympan.js
rulers.js
```

Native implementation:

```text
native/OrboCore/Sources/OrboCore/Mater/Mater.swift
native/OrboCore/Sources/OrboCore/Mater/DignityTables.swift
native/OrboCore/Sources/OrboCore/Mater/DignityDoctrine.swift
```

Native proof material:

```text
native/OrboCore/Tests/OrboCoreTests/MaterTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/mater-parity.json
```

## What it currently does

The prototype Mater is the inherent sign-level zodiacal structure.

The Ring owns inherent relation. The Mater owns inherent zodiacal meaning at sign resolution.

It is stamped before the app runs and requires no person, time, place, chart, or UI.

The native Mater combines that proven sign-level law with the surviving essential-dignity law rehoused from prototype `rulers.js`.

## Actual law

The prototype Mater owns:

```text
twelve signs in canonical zodiacal order
element of each sign
modality of each sign

traditional domicile ruler of each sign
the seven classical dispositors
signs ruled by each traditional governor

classical exaltation sign
classical exaltation degree

detriment derived from opposite domicile
fall derived from opposite exaltation

longitude -> sign
sign-level essential dignity:
    domicile
    exaltation
    detriment
    fall
    absence
```

It also preserves stable sign-symbol metadata, but that metadata is not foundational to computation.

Prototype Mater does not currently own:

```text
houses
whole-sign frames
modern co-rulership
triplicity
bounds
faces
degree-level dignity ladder
peregrine determination
occupants
time
place
sect calculation
orbs
interpretation prose
```

The Rulers assessment below changes the **native receiving boundary**, not the historical prototype fact. Native Mater receives the surviving sub-sign essential-dignity law from `rulers.js` through that component's REHOUSE treatment.

The resulting native Mater is the single canonical owner of essential dignity at both sign and sub-sign resolution.

## What is proven

Prototype tests establish, among other laws:

```text
12 sign names in canonical order
12 sign symbols
four-element cycle from Aries
each element holds three signs
three-modality cycle from Aries
each modality holds four signs
name-keyed and index-keyed sign facts agree

traditional domicile rulership is canonical
every traditional ruler is one of the classical seven
Pluto, Uranus and Neptune are absent from the traditional backbone
ruler -> ruled-sign reverse relationships are complete

all seven classical exaltations exist
all seven exact exaltation degrees exist

all detriments are oppositions of domicile
all falls are oppositions of exaltation

sign-level dignity uses one vocabulary:
domicile / exaltation / detriment / fall / null

absence at the prototype Mater layer is null, not peregrine

house frames are absent from Mater
house frames are owned by Tympan

framing, AstroDNA, and Rulers read Mater's canonical tables rather than maintaining private copies
```

The test suite checks table identity where possible, not merely equality, so central ownership is proven rather than inferred from matching values.

The Rulers archaeology additionally establishes that its surviving law is essential-dignity law, not a second kind of rulership law. That surviving law is recorded in the Rulers card and is implemented inside native Mater.

## Current dependencies

Prototype Mater has none.

Mater is an inherent floor component and imports nothing.

It is a sibling of Ring, not a child of Ring.

Native Mater depends only on the approved Phase 1a domain vocabulary. It does not depend on native Ring or any chart, time, place, horizon, UI, or interpretation component.

## Current consumers

Current prototype consumers include:

```text
Tympan
Rulers
AstroDNA
framing
dispositor
Connectome-related readers
instrument/readout code
```

Consumers must read Mater's sign-level facts rather than maintain competing copies.

Native consumers read Mater for the complete essential-dignity substrate as well.

## Known tests / fixtures

Prototype:

```text
tests/mater.test.html
tests/rulers.test.html
tests/rewire-parity.test.html
```

Native:

```text
native/OrboCore/Tests/OrboCoreTests/MaterTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/mater-parity.json
```

The native parity fixture preserves the proven Mater tables plus the factual dignity tables and boundaries received from Rulers.

## User-visible consequence

A Mater error can change sign identity, element, modality, traditional rulership, dispositor eligibility, exaltation, detriment, fall, triplicity, bound, face, peregrine status, and every downstream technique that depends on those facts.

The traditional / modern boundary is especially consequential. Adding Pluto, Uranus, or Neptune to Mater's traditional ruler table would alter classical disposition and governance logic rather than merely changing display.

## 4R

**REPLICATE**

## Why

Mater's own prototype law has a coherent single responsibility, no prototype dependency, mature tests, established consumers, and explicit boundaries with Tympan.

The prototype has already completed important centralization work:

```text
house frames moved out to Tympan
modern co-rulership remains separate
sign-level dignity remains in Mater
private duplicate sign-level tables were removed from readers
```

No architectural defect was found in Mater's own law, so Mater remains REPLICATE.

The Rulers assessment does not give Mater a second 4R treatment. Rulers receives its own single primary treatment, REHOUSE, and Mater is the receiving native owner for that surviving dignity law.

This produces one native owner for one kind of inherent fact:

```text
Mater
    complete zodiacal meaning
    complete essential dignity
```

rather than preserving the prototype's historical sign-level / sub-sign file seam.

## Swift Sanding

The native implementation applies the approved sanding while manufacturing the combined owner to native tolerances:

```text
string sign identity
-> Sign

string planet identity
-> Planet

string element / modality identity
-> Element / Modality

raw longitude Number
-> CelestialLongitude

0..<30 sub-sign position
-> DegreeInSign

0...30 interval boundary
-> DegreeBoundaryInSign

string dignity names
-> DignityRung / EssentialDebility

Boolean / null sect
-> Sect?

scheme labels
-> typed DignityDoctrine selections

parallel JavaScript table shapes
-> one maintained native fact with derived views

Object.freeze
-> immutable Swift static values

null / undefined
-> explicit Optional

load-time JavaScript mutation / completeness defenses
-> typed construction plus invariant tests

mater.browser.js / rulers.browser.js
-> no production native counterpart
```

Native Mater receives through the Rulers REHOUSE:

```text
Egyptian bounds
Chaldean faces
Dorothean triplicity rulers
bound lookup
face lookup
triplicity lookup
complete five-rung essential-dignity resolution
correct peregrine determination
```

Doctrine variants are not separate owners. They are doctrine-qualified tables held behind Mater's canonical dignity surface.

Only implemented and proven variants are available. The initial admitted profile is:

```text
Egyptian bounds
Dorothean triplicity
Chaldean faces
```

Mater does not calculate sect. Where a dignity read needs sect to select a triplicity lord, sect is supplied by the caller as an explicit input.

Swift Sanding does not merge modern co-rulers into the traditional rulership backbone.

Swift Sanding does not move houses back into Mater.

The old single-valued sign helper is not used as the native definition of peregrine. Native `EssentialCondition` can preserve simultaneous debilities, and peregrine is derived only from the complete set of positive dignity rungs.

## Native destination

```text
OrboCore / Mater
```

## Native dependencies

```text
Sign
Planet
Element
Modality
CelestialLongitude
DegreeInSign
DegreeBoundaryInSign
Sect
DignityRung
EssentialDebility
DignityDoctrine
```

`Sect` and `DignityDoctrine` are inputs where required, not external engines that Mater must own.

Mater does not depend on Ring, Tympan, AstroDNA, ephemeris, Orbo Spine, Loom, UI, time, place, sect calculation, or interpretation.

## Native mating surface

The implemented native surface provides canonical reads for:

```text
Mater.element(of:)
Mater.modality(of:)
Mater.domicileRuler(of:)
Mater.signsRuled(by:)
Mater.exaltation(in:)
Mater.exaltation(of:)
Mater.detrimentRuler(in:)
Mater.fallRuler(in:)
Mater.debilities(of:in:)
Mater.bound(at:doctrine:)
Mater.face(at:doctrine:)
Mater.triplicity(of:doctrine:)
Mater.essentialCondition(of:at:sect:doctrine:)
```

Alternate keyed or indexed shapes are derived views, not independently maintained authorities.

The native ownership seam is:

```text
Ring
    inherent degree relation

Mater
    inherent zodiacal meaning
    complete essential dignity

Tympan
    sign <-> house and governance indexes
```

There is no separate native `Rulers` or `EssentialDignity` owner.

## Parity standard

**EXACT** for the law already owned by prototype Mater.

The dignity law received from Rulers is governed by the Rulers card's **STRUCTURAL** parity standard, with exact parity required for the factual tables, boundaries, and admitted ladder semantics.

## Proof method

Prove:

```text
all 12 sign identities and order
all 12 elements
all 12 modalities

all 12 traditional domicile rulers
classical dispositor membership
traditional / modern separation

all 7 exaltation signs
all 7 exaltation degrees

all detriments
all falls

Egyptian bound table and every boundary
Chaldean face sequence and every boundary
Dorothean triplicity table and sect selection
five-rung dignity facts
peregrine only when no positive rung is held
simultaneous detriment + fall can be represented
positive dignity and debility remain independent facts

doctrine choices remain explicit
no separate native Rulers authority exists

house material absent
modern co-rulership absent

JavaScript-reference parity fixture
native unit invariants
accumulated Ring + Mater suite green
```

## Proof evidence

Implementation is present in the three native Mater source files listed above. No native production `Rulers.swift` or `Rulers/` owner was created.

The Mater suite contains 12 tests covering:

```text
12 canonical sign-fact parity records
all 7 exaltations and exact degrees
all 60 Egyptian bounds
all Egyptian half-open boundaries
Egyptian ownership totals:
    Saturn 57
    Jupiter 79
    Mars 66
    Venus 82
    Mercury 76
all 36 Chaldean faces and boundaries
all 4 Dorothean triplicity groups
7 classical planets x 360 whole degrees x 3 sect states
    = 7,560 complete essential-condition comparisons
simultaneous Mercury detriment + fall in Pisces
Moon fall plus participating triplicity in Scorpio
Mars face dignity in Gemini, proving the old sign-only peregrine shortcut is not native canon
modern-planet exclusion from the classical dignity ladder
```

Native Xcode proof was completed on 2026-08-16 by running the standalone `OrboCore` package test action on the development Mac. The accumulated suite reported:

```text
13 DomainTests                         PASS
4 FixtureInfrastructureTests          PASS
1 Phase 0 linkage sentinel test       PASS
12 RingTests                           PASS
12 MaterTests                          PASS
------------------------------------------
42 total                              PASS
0 failures
```

The accumulated Xcode gate is satisfied.

## Status

**NATIVE CANONICAL**

Mater may now serve as the canonical native owner of inherent zodiacal meaning and complete essential dignity.

---

# 7. Component: Tympan

## Prototype source

Primary authority:

```text
tympan.js
```

Reference / browser material:

```text
tympan.browser.js
```

Primary proof material:

```text
tests/tympan.test.html
tests/rewire-parity.test.html
```

Relevant ownership neighbors:

```text
mater.js
connectome.js
rulers.js
```

Native implementation:

```text
native/OrboCore/Sources/OrboCore/Tympan/Tympan.swift
```

Native proof material:

```text
native/OrboCore/Tests/OrboCoreTests/TympanTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/tympan-parity.json
```

## What it currently does

The Tympan is the prototype's canonical whole-sign housing die and governance index.

It takes a rising sign and exposes the universal structural consequences of that frame. It requires no person, time, place, occupants, chart persistence, or UI.

It is inherent like Ring and Mater, but unlike those two it has one intentional dependency: Mater supplies canonical sign and traditional rulership facts.

The native implementation now stamps the same twelve frames and governance indexes from the canonical native Mater.

## Actual law

The Tympan owns:

```text
twelve whole-sign frames

rising sign + sign
-> house

rising sign + house
-> sign

rising sign + house
-> traditional ruler

rising sign + traditional governor
-> houses governed

sign
-> optional modern co-ruler

rising sign + modern co-ruler
-> house co-governed

canonical frame records

six-house opposition / flip law

absence / empty / malformed address contracts
```

The Tympan does not own:

```text
sign meaning beyond the Mater facts it reads
house interpretation words
occupants
chart-specific destination houses
house-routing graphs
planet disposition graphs
essential dignity
aspects
orbs
sect
lots
time
place
latitude / longitude of place
persistence
UI
```

## What is proven

Prototype tests establish, among other laws:

```text
12 frames of 12 signs
all 144 sign -> house cells
all 144 house -> sign round trips
its own ASC sign is always house 1
every house answer is an ordinal 1-12

traditional ruler of every house agrees with Mater
all 84 frame / traditional-governor reverse indexes agree with the hand-walk they replaced
the seven traditional governors account for all twelve houses in every frame
Mercury, Venus, Mars, Jupiter and Saturn govern two houses; Sun and Moon govern one

modern co-rulers are exactly Pluto for Scorpio, Uranus for Aquarius, Neptune for Pisces
modern co-rulership is held in a separate index
no modern appears in the traditional reverse index
traditional planets return a well-formed empty result from the co-rulership index

frame records agree with the canonical forward and reverse tables
frame records are immutable

flipping moves exactly six houses
flipping twice returns the original house

absence is null
well-formed empty is []
malformed sign, house and governor addresses throw

Tympan imports Mater and nothing else
no aspects, orbs, sect, lots, decans, terms, faces, triplicity, occupants, time, place, or house-meaning text enter the component
```

## Current dependencies

Prototype Tympan imports Mater and nothing else.

Native Tympan depends on:

```text
Mater
Sign
House
Planet
CelestialLongitude
```

Native Tympan does not depend on Ring, AstroDNA, Connectome, ephemeris, Orbo Spine, Loom, UI, occupants, time, place, or interpretation.

## Current consumers

Current prototype consumers include systems that need canonical housing or governance structure, including:

```text
Connectome
AstroDNA-related reads
framing
Prism-related reads
instrument / pane readouts
other governance readers
```

Consumers should read Tympan rather than recompute house rotations or scan signs to discover governed houses.

## Known tests / fixtures

Prototype:

```text
tests/tympan.test.html
tests/rewire-parity.test.html
```

Native:

```text
native/OrboCore/Tests/OrboCoreTests/TympanTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/tympan-parity.json
```

The parity fixture preserves all 144 forward cells, all 144 inverse cells, the twelve traditional sign rulers, the separate modern co-ruler assignments, and the six-house flip constant.

## User-visible consequence

A Tympan error can place a sign or body in the wrong house, assign the wrong house ruler, report the wrong houses governed by a planet, or allow modern co-rulership to contaminate traditional disposition logic.

Its structural traditional / modern split protects techniques that count one classical governor while still allowing the interface to display a modern co-ruler.

## 4R

**REPLICATE**

## Why

Tympan has a coherent responsibility, mature invariant tests, a deliberate single dependency on Mater, established downstream consumers, and explicit refusals around interpretation and occupant-specific computation.

The prototype has already completed the architectural cleanup that matters most:

```text
whole-sign frames moved out of Mater
forward and reverse housing are centralized
traditional reverse governance is stamped once
modern co-governance is physically separate
chart-specific routing remains in Connectome
house meaning remains outside the die
```

No architectural defect has been found that justifies redesigning or redistributing Tympan's law.

The Phase 1 plan predicted REPLICATE. Prototype archaeology and test evidence independently support that ruling.

## Swift Sanding

The native implementation applies the approved sanding without changing Tympan law:

```text
0-11 sign address integers
-> Sign

1-12 house ordinal integers
-> House

string governor identity
-> Planet plus Tympan.TraditionalGovernor for the traditional reverse path

manual sign-address and house-ordinal validators
-> failable native type construction before Tympan reads

traditional reverse read accepting any string planet
-> typed TraditionalGovernor, so a modern cannot enter that socket

modern co-ruler absence
-> Optional<Planet>

well-formed traditional planet in the modern co-ruler index
-> empty [House]

parallel JavaScript table shapes
-> one immutable stamped Frame value per rising sign with forward and reverse indexes

Object.freeze
-> immutable Swift values

browser-global registration / tympan.browser.js
-> no native counterpart
```

The traditional and modern governance paths remain structurally separate. `Tympan.TraditionalGovernor(planet:)` rejects Uranus, Neptune and Pluto before a traditional reverse read can occur.

The reverse governance indexes are stamped once inside each immutable frame. Downstream readers do not hand-walk twelve houses per query.

The longitude convenience read resolves the two `CelestialLongitude` values to their already-typed signs and then reads the stamped frame; it does not introduce place or time.

## Native destination

```text
OrboCore / Tympan
```

## Native dependencies

```text
Mater
Sign
House
Planet
CelestialLongitude
```

Tympan does not depend on Ring, AstroDNA, Connectome, ephemeris, Orbo Spine, Loom, UI, occupants, time, place, or interpretation.

## Native mating surface

The implemented native surface provides:

```text
Tympan.frame(for:)
Tympan.house(of:rising:)
Tympan.house(of:ascendant:)
Tympan.sign(of:rising:)
Tympan.ruler(of:rising:)
Tympan.coRuler(of:)
Tympan.coRuler(of:rising:)
Tympan.housesRuled(by:rising:)
Tympan.housesCoRuled(by:rising:)
Tympan.opposite(of:)
```

Each `Frame` also carries the canonical house records and the pre-stamped traditional and modern reverse reads.

The ownership seam remains:

```text
Mater
    zodiacal meaning + essential dignity
        |
        v
Tympan
    sign <-> house and governance indexes
        |
        v
later Connectome
    occupants + frame -> chart-specific routing
```

The prototype Rulers dignity law is rehoused into native Mater, not Tympan.

## Parity standard

**EXACT**

Exact means law and result parity, not line-for-line JavaScript array or object-shape parity.

## Proof method

Prove:

```text
all 12 complete frames
all 144 sign -> house reads
all 144 house -> sign reads
all forward / reverse round trips

every traditional house ruler agrees with canonical native Mater
all 84 traditional governor / frame reverse indexes
all seven governors account for exactly twelve houses per frame
five traditional non-lights govern two houses; Sun and Moon govern one

all three modern co-ruler assignments
all modern reverse co-governance indexes
traditional planets return [] from the co-rulership read
traditional / modern structural separation

canonical frame record parity
six-house opposition / flip law
flip involution

malformed raw Sign / House / traditional-governor inputs fail at native type construction
no occupant-specific facts
no interpretation content

JavaScript-reference parity fixture
native invariant tests
accumulated Ring + Mater + Tympan suite green
```

## Proof evidence

Implementation is present in `native/OrboCore/Sources/OrboCore/Tympan/Tympan.swift`.

The native suite contains 10 Tympan tests covering:

```text
all 144 prototype forward frame cells
all 144 prototype inverse frame cells
all 144 forward / reverse round trips
all 144 house-ruler reads against native Mater
all 84 traditional reverse-governance reads
traditional governor cardinalities in every frame
all modern co-ruler assignments and reverse indexes
Scorpio-rising governance examples from the prototype suite
frame-record agreement
six-house flip law and involution
native malformed-address boundary behavior
```

Native Xcode proof was completed on 2026-08-16 by running the standalone `OrboCore` package test action on the development Mac. The first accumulated Tympan gate reported:

```text
52 total tests    PASS
0 failures
```

The final Phase 1a closure run then added and proved the three foundation-integration tests, bringing the accumulated package suite to:

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

The accumulated Xcode gate is satisfied.

## Status

**NATIVE CANONICAL**

Tympan may now serve as the canonical native whole-sign frame and governance authority for later components.

---

# 8. Component: Rulers

## Prototype source

Primary authority:

```text
rulers.js
```

Reference / browser material:

```text
rulers.browser.js
```

Primary proof material:

```text
tests/rulers.test.html
tests/rewire-parity.test.html
```

Relevant ownership neighbors and duplicate readers:

```text
mater.js
dispositor.js
electional.js
```

Native receiving implementation:

```text
native/OrboCore/Sources/OrboCore/Mater/Mater.swift
native/OrboCore/Sources/OrboCore/Mater/DignityTables.swift
native/OrboCore/Sources/OrboCore/Mater/DignityDoctrine.swift
```

There is deliberately no native production `Rulers` component.

## What it currently does

The current prototype `rulers.js` no longer owns general sign rulership and no longer owns chart-level disposition.

Mater owns the traditional sign-level rulership and exaltation facts that Rulers reads.

Dispositor owns chart-specific chains, cycles, and receptions that were removed from Rulers.

The surviving coherent job inside Rulers is the sub-sign and assembled **essential-dignity law**.

## Actual law

The useful surviving Rulers law is:

```text
Egyptian bounds
Chaldean faces
Dorothean triplicity rulers

bound lookup
face lookup
triplicity lookup

five positive essential-dignity rungs:
    domicile
    exaltation
    triplicity
    bound
    face

debilities read from Mater:
    detriment
    fall

peregrine determination:
    true only when none of the five positive rungs is held
```

Rulers does not properly own:

```text
canonical sign identity
canonical domicile rulership
canonical exaltation table
canonical detriment / fall table
house governance
modern co-rulership
chart-specific disposition graphs
receptions
sect calculation
solar condition
motion condition
accidental house condition
scoring / almuten
interpretation
```

## What is proven

Prototype source and tests establish:

```text
Egyptian bounds are twelve rows of five arcs and close every sign at 30 degrees
Sun and Moon hold no Egyptian bounds
bound ownership totals close the whole 360-degree circle

faces follow the Chaldean sequence from Mars at 0 Aries
all 36 ten-degree faces are derivable from one seven-planet cycle

Dorothean triplicity is element-based
triplicity preserves day, night, and participating rulers
sect is supplied as an argument rather than calculated inside Rulers

five positive dignity rungs are assembled without a score
peregrine is a property of the complete ladder, not merely absence of sign-level dignity
```

The archaeology also exposes a prototype API inconsistency that must not become native canon:

```text
dignityOf(...)
    treats absence of sign-level dignity as peregrine

ladderOf(...)
    correctly treats peregrine as holding none of the five positive rungs
```

The complete ladder semantics are the coherent law preserved by native Mater.

A second important finding is duplication in `electional.js`: Electional currently carries its own dignity substrate for several of the same facts. Native Orbo must not preserve competing bound, face, triplicity, exaltation, or related dignity tables there.

## Current dependencies

```text
Mater
```

Current prototype Rulers reads Mater's:

```text
SIGNS
DOMICILE
EXALTATION
DISPOSITORS
dignityOfSign
elementOf
```

This is evidence that sign-level rulership already has a canonical owner elsewhere.

## Current consumers

Prototype consumers include readers that need pointwise lord or dignity facts.

Electional is also a duplicate dignity implementer that must eventually become a consumer of the canonical native dignity owner rather than maintaining competing tables.

## Known tests / fixtures

Prototype:

```text
tests/rulers.test.html
tests/rewire-parity.test.html
```

Native receiving proof:

```text
native/OrboCore/Tests/OrboCoreTests/MaterTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/mater-parity.json
```

Electional's dignity machinery is additional architectural evidence for deduplication, but electional judgment and scoring remain outside this component pass.

## User-visible consequence

A dignity ownership error can misstate whether a planet is in domicile, exaltation, triplicity, bound, face, detriment, fall, or peregrine, and can cause downstream Horary, Electional, natal, and interpretive systems to disagree about the same celestial fact.

## 4R

**REHOUSE**

## Why

The useful law survives, but the prototype component name and owner no longer match the law.

`rulers.js` has already lost the two jobs its name suggests:

```text
sign rulership -> Mater
chart disposition -> Dispositor
```

What remains is essential dignity.

Creating a new native `EssentialDignity` owner would preserve an unnecessary seam through one kind of inherent zodiacal meaning:

```text
domicile / exaltation / detriment / fall
    in Mater

triplicity / bound / face / peregrine
    somewhere else
```

There is no architectural gain sufficient to justify that split.

Therefore the surviving Rulers dignity law is rehoused into **Mater**, making Mater the single canonical native owner of complete essential dignity.

Rulers still receives exactly one primary 4R treatment: REHOUSE.

Mater still receives exactly one primary 4R treatment for its own component: REPLICATE.

The receiving relationship does not create a second treatment for Mater.

## Swift Sanding

The rehouse preserves factual law while removing JavaScript and historical-file seams:

```text
string planet identity
-> Planet

raw longitude Number
-> CelestialLongitude

Boolean / null sect argument
-> Sect?

string scheme labels
-> DignityDoctrine / typed scheme identity

string rung names
-> DignityRung

single debility slot
-> Set<EssentialDebility>

Object.freeze
-> immutable Swift values

null / undefined
-> explicit Optional

rulers.browser.js
-> no production native counterpart

old sign-only dignityOf(...)=peregrine shortcut
-> not native canon

complete ladder semantics
-> EssentialCondition.isPeregrine derived from all five positive rungs
```

Doctrine variation belongs behind the same Mater owner rather than spawning duplicate engines.

The initial factual substrate is:

```text
Egyptian bounds
Dorothean triplicity
Chaldean faces
```

Future admitted alternatives, such as Ptolemaic bounds or Ptolemaic triplicity, require explicit doctrine selections with provenance and tests.

No score belongs in Mater. Five rungs remain five facts.

No accidental dignity or broader planetary condition is absorbed in this rehouse. Combustion, cazimi, under-the-beams status, motion state, angularity, broader sect condition, and similar chart-context facts require their own later ownership analysis.

Reception also remains outside Mater. Reception is a relationship mediated by dignity and belongs with the chart-specific disposition/reception machinery.

## Native destination

```text
OrboCore / Mater
```

There is no separate native `Rulers` component.

## Native dependencies

The received law lives inside Mater and uses Mater's native domain vocabulary.

Inputs include:

```text
Planet
Sign
CelestialLongitude
Sect?
DignityDoctrine
```

Mater does not derive sect. A caller supplies it when the selected triplicity doctrine requires it.

## Native mating surface

The useful capability is part of Mater's canonical zodiacal surface:

```text
Mater.bound(...)
Mater.face(...)
Mater.triplicity(...)
Mater.essentialCondition(...)
```

Downstream systems such as Electional should consume these factual reads and apply their own technique-specific weighting or judgment afterward.

## Parity standard

**STRUCTURAL**

The ownership and API shape intentionally change, so whole-component exact API parity would preserve a known historical seam and a misleading `dignityOf` shortcut.

Within structural parity, the factual substrate must be exact:

```text
Egyptian bound endpoints and owners            EXACT
bound half-open boundary behavior              EXACT
Chaldean face sequence                         EXACT
face boundaries                                EXACT
Dorothean triplicity table                     EXACT
sect / participating selection                 EXACT
five-rung dignity facts                        EXACT
detriment and fall facts from Mater            EXACT
classical-seven restriction                    EXACT
no-score rule                                  EXACT
```

Peregrine follows the complete five-rung law, not the older sign-only shortcut.

## Proof method

Prove:

```text
all Egyptian bound rows, owners, and boundaries
all bound coverage invariants
all Chaldean faces and boundaries
all Dorothean triplicity rows and sect selections
all five-rung dignity facts across the complete whole-degree / sect surface
peregrine is false whenever any positive rung is held
peregrine is true only when none is held

Mater remains the only maintained native owner of domicile / exaltation / detriment / fall
native Mater is the only maintained owner of bound / face / triplicity / complete dignity
no native Rulers component exists
no score enters Mater
no chart-specific condition enters Mater

JavaScript-reference factual parity
native invariant tests
accumulated Ring + Mater suite green
```

## Proof evidence

The REHOUSE is implemented inside native Mater. The prototype Rulers tables and complete ladder law were transposed into `DignityTables.swift`, `DignityDoctrine.swift`, and `Mater.essentialCondition(...)`; no native `Rulers.swift` or `Rulers/` production owner was created.

The Mater tests include exact factual parity for the 60 Egyptian bounds, 36 Chaldean faces, four Dorothean triplicity groups, all bound/face boundaries, and 7,560 complete whole-degree/sect essential-condition comparisons.

The test suite explicitly pins the architectural correction that motivated STRUCTURAL rather than whole-API parity: Mars at 10 Gemini holds face dignity and is therefore **not peregrine**, even though the old sign-only `dignityOf(...)` helper called that position peregrine.

The same accumulated Xcode proof that canonized Mater completed the Rulers rehouse proof:

```text
42 total tests    PASS
0 failures
```

## Status

**PROVEN / COMPLETE**

Rulers has no independent native production component. Its surviving essential-dignity law is now canonically owned by native Mater.

---

# 9. Component: Geoplacement Atlas

## Prototype source

There is no single prototype Geoplacement component.

The current behavior is distributed across:

```text
cities.js
cities.browser.js
Orbo Astrolabe.dc.html
packs/index.js
```

The factual city corpus is `cities.js`. Its header identifies the source as:

```text
city-timezones cityMapping.json (MIT)
+
hand-curated major cities
```

The file is deduplicated by rounded latitude / longitude and stores coordinates rounded to two decimal places.

The current corpus contains 7,356 records in the compact prototype shape:

```text
n   display / canonical-ish place label
la  latitude
lo  longitude
tz  timezone identifier
```

The older `packs/index.js` location path references `packs/data/cityMap.json`, but that data file is not present in the current repository and is therefore stale scaffolding rather than the live authority.

## What it currently does

Prototype Orbo uses the city corpus and embedded UI code to:

```text
search city labels by case-insensitive substring
cap UI suggestions at 50
resolve an exact city label
fall back to a `name, ...` prefix read
return latitude
return longitude
return timezone identity
```

Device geolocation is a separate path and can supply exact coordinates without passing through the named-place corpus.

The selected timezone identifier is later passed to separate civil-time logic, which calculates the historical/local UTC offset. That offset calculation is not Geoplacement law.

## Actual law

The useful component law is:

```text
human place query
-> zero / one / many matching canonical place records

canonical place record
-> latitude
-> geographic longitude
-> timezone jurisdiction identity

stable offline search over the shipped place corpus

explicit Atlas version / provenance
```

It does not own:

```text
UTC offset
DST calculation
historical timezone transition law
local clock -> absolute time
planetary astronomy
horizon geometry
AstroDNA
interpretation
```

## What is proven

Archaeology establishes several important current behaviors and defects:

```text
7,356 shipped records
coordinates rounded to two decimal places
IANA-style timezone identifiers carried as data
case-insensitive substring search
prototype exact-name resolution
prototype prefix convenience resolution
```

The current dataset also contains duplicate exact labels with different coordinates. For example, `Tokyo, Japan` appears with more than one coordinate pair.

Prototype matching silently resolves ambiguity:

```text
Map construction can overwrite an earlier exact duplicate
prefix fallback uses the first match
```

That behavior conflicts with the Phase 1 gate requiring ambiguous place names to be surfaced rather than guessed.

## Current dependencies

The factual `cities.js` corpus is static and has no astrology dependency.

The browser implementation depends on UI/runtime machinery for matching and browser geolocation, but those are not part of the native Atlas law.

## Current consumers

Current prototype consumers include:

```text
natal / birth-place entry
current-location / place state
local civil-time preparation
UI suggestion lists
```

The immediate native consumer is Civil Time, which receives the stable timezone jurisdiction identity after place resolution.

## Known tests / fixtures

There is no mature dedicated prototype Geoplacement test suite.

Native proof is therefore built from:

```text
the versioned 7,356-record source artifact
known place rows
real duplicate-label evidence
synthetic ambiguity cases
search behavior
native coordinate invariants
```

Native implementation and proof material:

```text
native/OrboCore/Sources/OrboCore/Domain/GeographicCoordinates.swift
native/OrboCore/Sources/OrboCore/Geoplacement/GeoplacementAtlas.swift
native/OrboCore/Sources/OrboCore/Geoplacement/Resources/geoplacement-atlas-v1.js
native/OrboCore/Tests/OrboCoreTests/GeoplacementTests.swift
```

## User-visible consequence

A Geoplacement error can choose the wrong terrestrial coordinate or timezone jurisdiction before any astronomical calculation begins.

Ambiguity is therefore a correctness state, not a UI inconvenience.

## 4R

**REPRODUCE**

## Why

There is no single coherent prototype component to transpose.

The solved result is distributed across:

```text
static city data
browser mirror
embedded UI search / matching logic
stale pack-era lookup scaffolding
```

The useful behavior survives, but the implementation shape should not.

Native Orbo reproduces the capability as one explicit offline Atlas owner with typed coordinates, stable versioned data, and explicit resolution outcomes.

## Swift Sanding

```text
raw latitude Number
-> Latitude

raw geographic longitude Number
-> GeographicLongitude

celestial and geographic longitude sharing a primitive type
-> distinct native types

raw timezone String
-> TimezoneIdentifier

plain city object
-> Place

null / implicit miss
-> GeoplacementResolution.notFound

silent duplicate overwrite / first prefix match
-> GeoplacementResolution.ambiguous([...])

browser substring matcher
-> deterministic Core search

browser-global cities mirror
-> no native counterpart

unversioned runtime corpus
-> Geoplacement Atlas v1 resource
```

The current prototype corpus is reused as the **v1 source artifact** rather than silently swapping datasets during migration. This keeps the native pass auditable and gives future dataset improvements an explicit version boundary.

The Atlas parser treats malformed shipped records as artifact/programmer failure rather than silently dropping them.

The current two-decimal coordinate precision is preserved and declared as the fidelity of Atlas v1. It is not represented as exact street-address or hospital-level geolocation.

## Native destination

```text
OrboCore / GeoplacementAtlas
```

## Native dependencies

```text
Latitude
GeographicLongitude
TimezoneIdentifier
Place
Foundation resource loading / string parsing
```

Geoplacement does not depend on Ring, Mater, Tympan, AstroDNA, Ephemeris, Orbo Spine, Horizon, Loom, UI, or Civil Time calculations.

## Native mating surface

```text
GeoplacementAtlas.search(...)
GeoplacementAtlas.resolve(...)
GeoplacementAtlas.version
GeoplacementAtlas.count

GeoplacementResolution
    found(Place)
    ambiguous([Place])
    notFound
```

Civil Time receives the resolved `TimezoneIdentifier`; it does not ask Geoplacement for a UTC offset.

## Parity standard

**BEHAVIORAL**

For unambiguous valid reads, preserve the useful prototype result:

```text
same v1 source record
same canonical label
same rounded coordinates
same timezone identity
same case-insensitive search behavior
same unique prefix convenience
```

Intentional native correction:

```text
ambiguous exact or prefix match
prototype: silently chooses
native: returns ambiguity
```

The browser implementation shape, mirror, and implicit selection bugs are not parity requirements.

## Proof method

Prove:

```text
Atlas v1 loads exactly 7,356 records
Latitude rejects values outside [-90, 90]
GeographicLongitude rejects values outside [-180, 180]
geographic longitude is not celestial cyclic longitude
known unique place rows agree with prototype data
case and surrounding whitespace do not change exact resolution
unique prefix convenience survives
real duplicate exact labels surface ambiguity
synthetic prefix ambiguity surfaces ambiguity
unknown and empty queries return notFound
search remains stable, case-insensitive, substring-based and bounded
JavaScript escaped place names decode correctly
timezone jurisdiction identity survives without civil-offset calculation
```

Then run the entire accumulated standalone Xcode package suite and inspect the Atlas in OrboLab.

## Proof evidence

Implementation is present.

A local Swift preflight of the Geoplacement code passed before native proof. The first Xcode launch exposed an incorrect expected-record invariant: the source contains two internal comment marker lines, so the true record count is 7,356 rather than 7,358. The invariant and tests were corrected without changing the Atlas data.

Native Xcode proof was completed on 2026-08-16. The standalone `OrboCore` package reported:

```text
66 total tests    PASS
0 failures
```

All 11 Geoplacement tests were green, including the 7,356-record corpus gate and ambiguity behavior.

OrboLab was then launched successfully. After the diagnostic view's vertical scrolling was made explicit, the Lab visibly showed the full Tympan section followed by Geoplacement with:

```text
atlas version    1
records          7356
query            Madison, WI, USA
```

The Geoplacement native proof gate is satisfied.

## Status

**NATIVE CANONICAL**

Geoplacement Atlas may now serve as the canonical native offline place -> coordinates + timezone-jurisdiction authority.

---

# 10. Component: Civil Time

## Prototype source

There is no single prototype Civil Time component.

The current law is distributed across:

```text
Orbo Astrolabe.dc.html
    _zoneOffH(...)
    _resolveJd(...)

aaf.js
    parseDate(...)
    parseZone(...)
    toJD(...)
    Local Mean Time validation

ephem.js
    julianDay(...)
    jdToDate(...)
```

Relevant authority notes include:

```text
specs/Phase 1 - The Ovum.md
specs/Phase 1b - Ovum Completion Outline.md
specs/Celestial to Civil Time Conversion.md
AAF Translation Protocol.md
```

Native implementation:

```text
native/OrboCore/Sources/OrboCore/Domain/CivilTimeVocabulary.swift
native/OrboCore/Sources/OrboCore/CivilTime/CivilTime.swift
```

Native proof material:

```text
native/OrboCore/Tests/OrboCoreTests/CivilTimeTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/civil-time-parity.json
```

## What it currently does

Prototype Orbo has two useful time paths.

The app path resolves a human local birth clock through the birthplace's IANA timezone using browser `Intl`, with longitude/15 and finally the device timezone as fallbacks. It converts the selected offset into Julian Day.

The AAF path accepts an explicit applied UTC offset, preserves Local Mean Time metadata, and computes a calendar-aware Julian Day. It correctly distinguishes Gregorian and Julian calendar arithmetic where the app's `ephem.julianDay()` does not.

## Actual law

Civil Time owns:

```text
civil date
civil clock
calendar identity
UTC offset identity
IANA timezone jurisdiction resolution
historical timezone offset at an instant
repeated local-clock detection
nonexistent local-clock detection
explicit fixed-offset conversion
explicit Local Mean Time conversion
absolute instant
Julian Day conversion
timezone-data provenance/version
supported year range
```

It does not own:

```text
place search
latitude / longitude lookup
planetary astronomy
horizon geometry
AstroDNA
interpretation
live cursor state
celestial event solving
```

## What survives

Prototype archaeology establishes several correct laws worth preserving:

```text
the birth clock belongs to the birthplace, not the device
UTC offsets are east-positive
IANA timezone history is the preferred civil-zone authority
Julian Day is the canonical absolute-time address used downstream
explicit applied offsets are legitimate inputs
Local Mean Time is longitude / 15 hours
AAF calendar-aware JD distinguishes Gregorian and Julian arithmetic
```

## Prototype scaffolding and defects

The native implementation must not preserve:

```text
browser Intl as an architectural dependency
device timezone fallback
silent first/last choice during a repeated clock hour
silent shifting through a nonexistent clock time
separate competing JD formulas
proleptic-Gregorian-only ephem.julianDay as universal calendar law
raw strings and numbers flowing through every time socket
```

The browser `_zoneOffH` two-pass probe is useful evidence of DST-edge awareness, but it still returns one offset rather than representing ambiguity as a first-class result.

## Current dependencies

Prototype Civil Time logic is coupled to browser runtime services, city matching, raw date strings, and ephemeris-style JD math.

Native Civil Time depends on:

```text
CivilDate
CivilClockTime
CivilCalendar
UTCOffset
AbsoluteInstant
JulianDay
TimezoneIdentifier
GeographicLongitude
Foundation Calendar / TimeZone
```

It does not depend on Geoplacement itself. Geoplacement supplies a typed `TimezoneIdentifier`; Civil Time does the temporal work.

## Current consumers

The immediate next native consumer is the AstroDNA contract / eventual Ovum Resolver, which needs a stable absolute instant from the human civil address.

Later consumers may also use fixed-offset or Local Mean Time reads for imported historical records.

## 4R

**REPRODUCE**

## Why

There is no coherent single prototype owner to transpose. The useful law is split across app UI code, AAF import code, and ephemeris helpers, and those paths disagree about calendar handling and failure behavior.

The result should survive; the implementation shape should not.

Native Orbo therefore reproduces the civil-time capability as one explicit owner with one typed contract.

## Swift Sanding

```text
raw Y/M/D numbers
-> CivilDate

raw H/M/S numbers
-> CivilClockTime

implicit calendar convention
-> CivilCalendar

floating offset hours
-> UTCOffset in exact seconds east of UTC

raw Julian Day Number
-> JulianDay

JS Date / millisecond timestamp
-> AbsoluteInstant

null / guessed clock result
-> CivilTimeResolution

repeated local time silently chosen
-> ambiguous(first, second)

spring-forward gap silently adjusted
-> nonexistent

unknown zone -> device fallback
-> unknownTimeZone

longitude/15 arithmetic scattered in callers
-> UTCOffset.localMeanTime(for:)

browser Intl timezone probing
-> Foundation TimeZone / Calendar

unidentified system timezone rules
-> CivilTime.timeZoneDataVersion
```

The native zone path uses strict matching and the platform's repeated-time policy to obtain both valid instants when a local clock reading occurs twice. A strict miss is represented as `nonexistent` rather than shifted to a nearby legal time.

The explicit fixed-offset / LMT path preserves the AAF law without asking an IANA zone to reinterpret a historically stated applied offset.

## Native destination

```text
OrboCore / CivilTime
```

## Native dependencies

Only Foundation date/time primitives plus the typed native domain vocabulary listed above.

Civil Time does not depend on Ring, Mater, Tympan, AstroDNA, Ephemeris, Orbo Spine, Horizon, Loom, UI, or interpretation.

## Native mating surface

```text
CivilTime.resolve(date:time:in: TimezoneIdentifier)
CivilTime.resolve(date:time:fixedOffset:)
CivilTime.resolveLocalMeanTime(date:time:longitude:)
CivilTime.julianDay(date:time:offset:)
CivilTime.supportedYearRange
CivilTime.timeZoneDataVersion

CivilTimeResolution
    resolved(CivilTimeMatch)
    ambiguous(first:second:)
    nonexistent
    unknownTimeZone
    unsupportedYear
    unsupportedCalendar
```

The Phase 1b v1 operating range is explicitly:

```text
1700...2149
```

This aligns Civil Time with the current Orbo temporal instrument. Spine v1 may later narrow the final Ovum domain by intersection, but Civil Time does not silently widen its declared operating range.

Zone-based resolution currently accepts Gregorian civil dates across that operating range. Calendar-aware explicit-offset Julian Day conversion remains available for provenance/import work, including the older AAF calendar law.

## Parity standard

**BEHAVIORAL**

Preserve exact valid-domain results where the prototype has coherent answers:

```text
same applied east-positive offset
same resulting Julian Day
same birthplace-zone law
same calendar-aware AAF fixed-offset law
same longitude/15 LMT law
```

Intentional native corrections:

```text
ambiguous local clock
prototype: chooses one
native: returns both

nonexistent local clock
prototype/runtime service may shift or guess
native: explicit nonexistent

unknown timezone
prototype: may fall back to device
native: explicit unknownTimeZone
```

## Proof method

Prove:

```text
CivilDate / CivilClockTime / UTCOffset reject invalid states
Gregorian and Julian calendar arithmetic remain distinct
J2000 noon UTC = JD 2451545.0
prototype / AAF parity fixture reproduces valid results
1985 Madison clock resolves through America/Chicago without device timezone
pre-1970 timezone history is read correctly
fall-back repeated hour yields two instants one hour apart
spring-forward gap yields nonexistent
unknown timezone never uses device fallback
1700...2149 range is explicit
fixed-offset historical AAF case remains exact
Local Mean Time remains longitude / 15
timezone data version/source is exposed
```

Then run the full accumulated standalone Xcode suite and inspect the Civil Time section in OrboLab.

## Proof evidence

Implementation is present.

A local Swift 6.2 mini-package preflight ran all 12 new `CivilTimeTests`:

```text
12 CivilTimeTests    PASS
0 failures
```

The preflight includes the real DST gap/repeat behavior through Foundation timezone history, not mocked offsets.

Native Xcode proof was completed on 2026-08-16. The standalone `OrboCore` package reported:

```text
12 CivilTimeTests    PASS
78 total tests       PASS
0 failures
```

OrboLab was then launched successfully and visibly resolved the native Civil Time sample as:

```text
local date       1985-04-10
local clock      20:16:00
tzdb version     2026c
year range       1700-2149
resolution       resolved
timezone         America/Chicago
UTC offset       -06:00
source           timeZoneDatabase
Julian Day       2446166.59444444
```

The Civil Time native proof gate is satisfied.

## Status

**NATIVE CANONICAL**

Civil Time may now serve as the canonical native local-clock -> absolute-time / Julian-Day authority.

---

# 11. Component: AstroDNA Genome Contract

## Prototype source

Primary authority:

```text
astrodna.js
```

Reference / browser material:

```text
astrodna.browser.js
```

Relevant proof and architecture material:

```text
tests/astrodna.test.html
specs/Unified Architecture Plan - Ovum AstroDNA Embryo and Connectome.md
specs/Ideal Data Flow - Embryo AstroDNA Connectome Loom.md
specs/Phase 1 - The Ovum.md
specs/Phase 1b - Ovum Completion Outline.md
```

Native implementation:

```text
native/OrboCore/Sources/OrboCore/AstroDNA/AstroDNA.swift
native/OrboCore/Sources/OrboCore/AstroDNA/AstroDNAGene.swift
```

Native proof material:

```text
native/OrboCore/Tests/OrboCoreTests/AstroDNAContractTests.swift
native/OrboCore/Tests/OrboCoreTests/Fixtures/Parity/astrodna-contract.json
```

## What it currently does

Prototype `astrodna.js` combines multiple historical responsibilities in one file:

```text
physical ephemeris acquisition
horizon acquisition
canonical sequence encoding
node records and full-precision longitude peers
speed / speed ratio / stationary expression
sign / house / element expression
aspects
stelliums
elemental balance
chart ruler
extras
sect
Lots
```

The Phase 1b contract pass isolates only the genome itself.

The native AstroDNA owner does not port the prototype file as a chart-expression engine. It owns the canonical identity-bearing sequence that later components manufacture and unfold.

## Actual law

Native AstroDNA owns:

```text
exactly twelve genes
one explicit canonical order
one RingFineState per gene
codec identity
position plus admitted direction identity
fine -> coarse projection
longitude / sign / degree projection from the gene
South Node opposition derived from the North Node
serialization of identity only
```

Canonical order:

```text
1   Ascendant
2   Moon
3   Sun
4   Mercury
5   Venus
6   Mars
7   Jupiter
8   Saturn
9   Uranus
10  Neptune
11  Pluto
12  North Node
```

The native gene is the sole positional truth. AstroDNA does not store an independent floating-point longitude beside the Ring fine state.

The native North Node gene is the **true / osculating North Node**. It may be direct or retrograde. Its South Node is exactly opposite and is derived rather than admitted as a thirteenth gene.

The mean North Node is a separate astronomical quantity and is not AstroDNA identity.

## Explicit exclusions

AstroDNA does not own:

```text
velocity
speed ratio
stationary classification
station proximity
applying / separating
relative motion
aspects
Ring target tables
house placement
rulers
dignity
dispositorship
reception
stelliums
elemental balance
chart ruler
sect
Lots
MC
IC
Descendant
Vertex
interpretation
```

These may be derived from or related to a physical or derived state, but they do not enlarge the genome.

## What is proven

Prototype archaeology established the structural organism that survives:

```text
twelve ordered genes
Ascendant first
Moon before Sun
Mercury through Pluto in canonical sequence
North Node as gene 12
South Node derived rather than sequenced
Ring fine-state encoding at arcsecond identity
coarse whole-degree sequence as a projection
motion represented by the two Ring fine-state halves
codec stamped rather than inferred
```

Two prototype decisions were intentionally not preserved as native canon:

```text
prototype codec 3:
    gene 12 = mean North Node
    mean node forced into retrograde half

native codec 4:
    gene 12 = true / osculating North Node
    direct or retrograde are both legal
```

and:

```text
prototype node record:
    Ring gene plus an independent full-precision floating longitude

native genome:
    RingFineState alone is positional identity
    longitude / DMS / sign are projections of that gene
```

Codec 4 is therefore required. Reusing codec 3 would cause two incompatible meanings of gene 12 to claim the same persisted version stamp.

## Current dependencies

Prototype `astrodna.js` imports astronomy, Ring, Mater and Tympan because it also performs acquisition and expression.

Native AstroDNA depends only on the canonical native identity vocabulary it actually needs:

```text
RingFineState
RingState
CelestialLongitude
Sign
DegreeInSign
Motion
```

It does not depend on Ephemeris, Horizon, Mater, Tympan, Connectome, Civil Time, Geoplacement, Loom, UI or interpretation.

## Current consumers

The immediate future consumers are the Mundane Timespine/Horizon manufacturing path and the Ovum Resolver.

Later Connectome work will unfold the genome into expression rather than adding expression back into AstroDNA.

## User-visible consequence

AstroDNA is Orbo's celestial identity contract. A change to gene order, precision, node identity or codec meaning changes persisted chart identity and the required output of the entire celestial manufacturing chain.

## 4R

**REPRODUCE**

## Why

The prototype discovered the correct basic organism, but its implementation and two contract decisions should not survive unchanged.

Native Orbo preserves the twelve-gene ordered Ring identity while deliberately changing:

```text
gene 12
    mean North Node -> true / osculating North Node

positional authority
    Ring gene + floating peer -> RingFineState only
```

That is not exact replication. It is reproduction of the solved identity concept against the now-settled native architecture.

## Swift Sanding

```text
array position remembered by convention
-> AstroDNAGene with explicit ordinal and canonicalOrder

raw fine-state integer
-> RingFineState

codec implied by data shape
-> AstroDNA.codec == 4

wrong gene count
-> rejected at construction

invalid Ring address
-> rejected before genome exists

retrograde Ascendant / Moon / Sun
-> rejected by gene motion policy

true North Node direction
-> variable, both Ring halves legal

independent stored floating longitude
-> removed from identity

longitude / sign / DMS
-> projected from RingFineState

South Node stored separately
-> derived opposition

large prototype nodes/extras object
-> excluded from genome

mutable JavaScript arrays
-> immutable Swift value storage

browser mirror
-> no native counterpart
```

## Native destination

```text
OrboCore / AstroDNA
```

## Native mating surface

```text
AstroDNA.codec
AstroDNA.geneCount
AstroDNAGene.canonicalOrder
AstroDNA(sequence:)
AstroDNA(rawSequence:)
AstroDNA[gene]
AstroDNA.sequence
AstroDNA.rawSequence
AstroDNA.sequenceString
AstroDNA.degreeSequence
AstroDNA.degreeSequenceString
AstroDNA.longitude(of:)
AstroDNA.sign(of:)
AstroDNA.degreeInSign(of:)
AstroDNA.motion(of:)
AstroDNA.southNodeLongitude
Codable identity envelope { codec, sequence }
```

The later AstroDNA Encoder receives physical celestial values and creates these genes. The contract itself does not calculate the sky.

## Parity standard

**STRUCTURAL**

The following structural laws are exact:

```text
12 genes
canonical order through Pluto
North Node remains gene 12
gene value is RingFineState
arcsecond positional identity
two equal direct / retrograde Ring halves
Ascendant / Moon / Sun fixed direct
Mercury through Pluto variable
South Node derived +180 degrees
coarse sequence is a projection
codec is explicit
```

Intentional native divergence:

```text
codec 3 mean-node identity
-> codec 4 true/osculating-node identity

independent floating longitude peer
-> no second positional authority
```

The prototype's derived-expression object shape is not a parity target.

## Proof method

Prove:

```text
codec == 4
exactly 12 genes
canonical order explicit and complete
all genes are legal RingFineState values
sequence preserves each fine state exactly
whole-degree sequence derives from each fine state
wrong cardinality fails
malformed fine addresses fail
Ascendant / Moon / Sun reject retrograde states
Mercury through Pluto accept either motion where supplied
true North Node accepts direct and retrograde states
longitude / sign / degree are projections rather than stored peers
South Node is exact opposition and never gene 13
serialization contains only codec + sequence
codec 3 payload is rejected
returned sequence values cannot mutate the genome
accumulated native suite remains green
OrboLab reads the live contract
```

## Proof evidence

Implementation was completed under the explicitly authorized Phase 1b Pass 3 scope.

The native `AstroDNAContractTests` contain 10 tests covering the contract above. The corrected codec-4 suite was run in Xcode on 2026-08-16 and every AstroDNA contract test was green.

The user confirmed the accumulated standalone package run at:

```text
88 total tests    PASS
0 failures
```

OrboLab then visibly read the corrected live native contract:

```text
codec          4
genes          12
identity       12 x RingFineState
gene order     Ascendant · Moon · Sun · Mercury · Venus · Mars · Jupiter · Saturn · Uranus · Neptune · Pluto · North Node
Node source    true / osculating north node
Node motion    retrograde
South Node     derived
```

The Lab sample happens to carry a retrograde true Node. The XCTest contract separately proves that a direct true North Node is also legal.

The Phase 1b Pass 3 gate is satisfied.

## Status

**NATIVE CANONICAL**

AstroDNA codec 4 is the canonical native celestial identity contract that the Mundane Timespine, Horizon and Ovum Resolver must satisfy.

---

# 12. Component: Ephemeris Kernel

## Prototype source

Primary prototype astronomical source:

```text
ephem.js
ephem.browser.js
```

Relevant proof and consumer material:

```text
tests/ephem.test.html
tests/astrodna.test.html
tests/timespine.test.html
astrodna.js
timespine.js
mundane.js
```

Qualified external source inspected during Pass 4:

```text
Official Swiss Ephemeris
repository: aloistr/swisseph
release: v2.10.3bfinal
published: 2026-08-02
2026 .se1 planetary/asteroid rebuild lineage: JPL DE441
```

Integration archaeology also inspected:

```text
vsmithers1087/SwissEphemeris
```

That archived repository demonstrates an unmodified Swiss C target beneath a Swift-facing package target. It is not Orbo's qualified astronomical authority.

## What the prototype currently does

Prototype `ephem.js` currently combines several jobs:

```text
planetary / lunar astronomy
true and mean lunar node reads
Julian Day helpers
Delta-T approximation
GMST / obliquity
Ascendant / MC / Vertex
Part of Fortune
Ascendant-anchor solving
```

The component archaeology splits those jobs by owner.

## Actual law

The Ephemeris Kernel owns **deep physical astronomical capability**.

It is capable of supplying the Forge with the universal celestial facts required to manufacture and verify the Mundane Timespine.

For AstroDNA v1 that includes at least:

```text
Sun
Moon
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
true / osculating North Node
```

For those physical celestial occupants the qualified Forge read must provide:

```text
geocentric tropical ecliptic longitude of date
standard apparent astrological position
signed longitudinal speed in degrees/day
```

The true North Node may move direct or retrograde.

The mean North Node may remain available as a separate supplementary astronomical read, but it is not AstroDNA gene 12.

## Explicit exclusions

Ephemeris does not own:

```text
civil calendar / timezone resolution
Julian Day policy already owned by Civil Time
Ascendant
MC
IC
Descendant
Vertex
whole-sign houses
Part of Fortune or other Lots
aspect geometry
root-solving policy
child-spine materialization
interpretation
```

Horizon owns local horizon geometry. Ring owns universal angle geometry. Loom owns temporal solving as earned in its later pass. Forge owns durable temporal artifact manufacture.

## What is proven

Prototype source is sufficient to prove the capability but insufficient to become native astronomical authority.

Its own comments document:

```text
JPL approximate Keplerian planetary elements primarily fit for 1800-2050
prototype use stretched to roughly 1700-2150
truncated Meeus lunar longitude series
simple Delta-T approximation identified as suitable around 1950-2050
body-dependent errors in the arcminute class or worse over parts of the range
```

AstroDNA codec 4 uses a one-arcsecond Ring positional quantum. The prototype ephemeris therefore cannot be promoted unchanged as the source that manufactures canonical codec-4 celestial identity.

Official Swiss Ephemeris `v2.10.3bfinal` is qualified as the v1 reference source. Its official 2026 documentation states that the current `.se1` planetary data were rebuilt from JPL DE441 and that Swiss Ephemeris is designed as a precision astronomical/astrological programming engine.

The Orbo v1 operating interval remains:

```text
1700...2149
```

which lies comfortably inside Swiss Ephemeris capability. The actual ephemeris-data bundle selected for Orbo must explicitly cover the entire declared Orbo interval.

## Current dependencies

The final integration details are a Pass 5 construction matter, but the qualified Ephemeris boundary will depend on:

```text
official Swiss Ephemeris C source
qualified Swiss ephemeris data files
JulianDay / absolute-time input from canonical native time vocabulary
```

It must not depend on AstroDNA, Connectome, Loom, child spines, UI, or interpretation.

## Current consumers

The sanctioned production consumer is:

```text
Forge
```

Construction tests and OrboLab may receive controlled inspection access where needed to prove the boundary, but that does not create another production celestial door.

Disallowed ordinary consumers include:

```text
AstroDNA
Connectome
Loom
Horizon for planetary positions
child spines
UI
interpretation
```

## 4R

**REPRODUCE**

## Why

The prototype solved the right capability but not at the numerical fidelity or ownership shape required by native Orbo.

The native component preserves the deep astronomical job while replacing the prototype numerical implementation with a qualified precision source and removing Civil Time, Horizon, Lots and solving responsibilities from its boundary.

## Swift Sanding

The native integration must make the source and requested mode explicit:

```text
implicit / mixed JavaScript astronomy
-> one Ephemeris owner

prototype approximate algorithms
-> qualified Swiss Ephemeris source

string body names at the boundary
-> typed admitted celestial body identity

raw numeric time
-> canonical JulianDay / absolute-time value

implicit numerical fallback
-> explicit failure when qualified Swiss data are unavailable

finite-difference direction as the primary source
-> signed longitudinal velocity supplied by qualified astronomy

mean/true Node ambiguity
-> explicit mean versus true node identities

horizon formulas mixed into ephem.js
-> Horizon later

civil JD helpers mixed into ephem.js
-> Civil Time already canonical
```

The Forge must explicitly request the intended Swiss ephemeris and speed output. It must not silently accept a lower-precision Moshier fallback when required `.se1` data are unavailable.

## Native destination

```text
OrboCore / Ephemeris
```

## Native mating surface

The exact Swift surface is intentionally not frozen before Pass 5 integration measurement, but the ownership-level contract is:

```text
Forge asks Ephemeris for physical celestial state at an absolute instant
Ephemeris returns qualified position + signed longitudinal motion
no other production component receives routine Ephemeris access
```

## Parity standard

**STRUCTURAL**

The astronomy capability and body semantics survive. Exact numerical parity with prototype `ephem.js` is not desired because its documented approximations are the reason for REPRODUCE.

Parity instead requires:

```text
same conceptual bodies
same geocentric tropical astrological coordinate family
true North Node as a distinct physical point
signed longitudinal motion
same downstream ability to manufacture the required celestial identity
```

Numerical authority comes from the qualified Swiss reference.

## Proof method

Pass 4 proves the reference boundary. Pass 5 will prove the integrated astronomical reads and the resulting Mundane Timespine numerically.

Pass 5 reference testing must include:

```text
random moments across 1700...2149
known natal moments
fast Moon cases
slow outer-body cases
true North Node direct and retrograde cases
0/360 wrap
stations
ingresses
range edges
position residuals by body
velocity residuals by body
```

## Proof evidence

Pass 4 archaeology inspected:

```text
prototype ephem.js and browser counterpart
prototype ephemeris regression suite
AstroDNA conformance material
TimeSpine conformance material
official Swiss Ephemeris repository and current release
official Swiss licensing notice
archived Swift/C wrapper architecture
```

The official Swiss release inspected is `v2.10.3bfinal`. The official readme records the 2026 DE441 rebuild of Swiss `.se1` data.

No native Ephemeris source was installed in Pass 4 by design. This pass qualified the astronomical authority and ownership seam rather than pretending source integration was complete.

Swiss Ephemeris is dual-licensed. Distribution of an Ovum containing Swiss Ephemeris code requires the project to resolve the AGPL versus Swiss Ephemeris Professional License path before release. Pass 4 records that as a release gate and does not silently make a project-wide license choice.

## Status

**REFERENCE QUALIFIED / PASS 4 COMPLETE**

The Ephemeris may now enter Pass 5 integration as the qualified deep astronomical capability used only through Forge.

---

# 13. Component: Forge

## Prototype source

There is no single prototype Forge component.

The successful manufacturing behavior is distributed across:

```text
mundane.js
timespine.js
fertilize.js
loom-related callers
prototype codecs and conformance suites
```

The earned temporal architecture is documented in:

```text
specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md
```

## What the prototype currently does

Different historical components already perform parts of the maker's job:

`mundane.js` establishes:

```text
native-independent universal artifact
byte-identical data for every reader
verified-once principle
packed storage
runtime decoding
universal event indexes
canonical correction before shipping
```

`timespine.js` establishes:

```text
chunked temporal manufacture
seam overlap
phase-locked sampling
event-identity deduplication
sorted materialization
version identity
conformance between materialized and expensive live scans
```

`fertilize.js` establishes:

```text
resumable / optional manufacturing
caller-owned yield points
packing and codec discipline
cache ancestry
child temporal materialization
materialize broadly, filter at read
```

Those behaviors are useful, but their ownership is historically scattered.

## Actual law

> **The Forge is Orbo's maker, not Orbo's oracle.**

Forge manufactures durable temporal artifacts from canonical ingredients.

Its permanent jobs include:

```text
manufacture a Mundane Timespine version
verify a Mundane Timespine version
compare Mundane Timespine against Ephemeris
maintain artifact provenance
extend supported temporal range
repair by manufacturing a newly identified version
produce golden celestial fixtures
measure candidate chronology representations
manufacture admitted universal temporal indexes
materialize child spines
pack child spines
version child spines
checksum child spines
rebuild child spines when canonical ancestry changes
```

Forge has two legitimate input paths.

Deep path:

```text
Ephemeris
    ↓
Forge
    ↓
Mundane Timespine vN
```

Orbo-native path:

```text
Mundane Timespine
+ canonical Orbo state
+ Loom results where required
    ↓
Forge
    ↓
child spine
```

Only the deep path may open the Ephemeris.

## Mundane Timespine law

The Mundane Timespine is the first and universal spine.

It is native-independent world chronology, not a feature owned by later Mundane Astrology.

```text
same Mundane Timespine version
=
same universal celestial chronology
for every Orbo carrying that version
```

A released Timespine version is immutable. Repairs, source changes, range extensions, fidelity changes, or representation changes that alter the artifact produce a newly identified version rather than silently changing v1.

Normal celestial runtime traffic reads the Mundane Timespine. The presence of Ephemeris and Forge inside the Ovum does not create competing ordinary celestial authorities.

## Child-spine law

A child spine is not another sky.

Every child spine descends from the versioned Mundane Timespine plus canonical Orbo state.

A child spine must never reopen the Ephemeris.

Conceptually, child-spine ancestry includes enough identity to determine when it must be reforged, such as:

```text
child-spine version / codec
parent Mundane Timespine version or checksum
relevant AstroDNA identity
relevant doctrine / Connectome identity
transformation provenance where applicable
```

## Loom boundary

Loom and Forge are separate.

```text
Connectome / doctrine owner
    knows the target
        ↓
Loom
    finds the crossing / interval / root
        ↓
Forge
    materializes / packs / indexes / versions
        ↓
child spine
```

The governing pair is:

> **The Connectome knows the target. The Loom finds the crossing.**

> **The Forge makes the durable temporal artifact.**

## Explicit exclusions

Forge does not own:

```text
astronomical equations
zodiacal meaning
house law
Ring aspect geometry
target doctrine
interpretation
root-solving mathematics
user presentation
```

Those belong to Ephemeris, Mater/Tympan/Ring, Connectome/doctrine owners, Loom, and UI respectively.

## 4R

**REPRODUCE**

## Why

The prototype already discovered much of the correct manufacturing behavior, but no coherent single Forge component exists to transpose.

The useful behavior is scattered across universal chronology construction, old personal TimeSpine work, fertilization-era packing, browser build machinery, and conformance tests.

Native Orbo reproduces those laws as one explicit permanent Ovum owner.

## Swift Sanding

Pass 5 implementation should turn historical manufacturing conventions into explicit artifact contracts:

```text
scattered build functions
-> Forge owner

implicit parent chronology
-> explicit Mundane Timespine ancestry

ad hoc version constants
-> typed artifact/version identities

browser/IndexedDB assumptions
-> storage-independent Core artifacts

mutable arrays and JSON-ish rows
-> immutable versioned artifact values / packed resources

implicit source provenance
-> explicit source + codec + range + checksum metadata

child builder opening ephemeris
-> impossible sanctioned path

Loom scanner plus packing mixed together
-> Loom solves, Forge materializes
```

## Native destination

```text
OrboCore / Forge
```

## Native dependencies

The full dependency surface is constructed piece by piece. At the ownership level Forge may consume:

```text
Ephemeris, only for Mundane Timespine manufacture/maintenance
Mundane Timespine
AstroDNA / later canonical state identities
Loom results
artifact codecs / checksum machinery
```

Forge does not make the target doctrine it consumes.

## Native mating surface

The exact Swift API is intentionally left for Pass 5 measurement, but the permanent owner must expose sanctioned operations for:

```text
Mundane Timespine manufacture
Mundane Timespine verification / reforge
universal index manufacture
golden fixture manufacture
child-spine manufacture
artifact provenance / version / checksum
```

No generic "give me an ephemeris" escape hatch belongs on the public surface.

## Parity standard

**STRUCTURAL**

The prototype's HTML, browser, IndexedDB, generator and file seams are not parity targets.

The surviving structure is:

```text
verified universal artifact
version discipline
chunk/resume capability where manufacturing cost demands it
seam-safe temporal construction
packing / compact storage
stable sorted reads
explicit cache / ancestry identity
child temporal materialization
conformance against authoritative parent data
```

## Proof method

Pass 4 proves Forge ownership and source boundaries.

Pass 5 must prove the actual Forge by manufacturing candidate Mundane Timespines and comparing each against the qualified Ephemeris across the full fidelity corpus.

Later child-spine passes must additionally prove:

```text
no child Forge path queries Ephemeris
same parent state + same Forge/artifact version -> deterministic child artifact
ancestry changes invalidate/rebuild deterministically
Loom result identity survives packing
read-time views do not silently mutate stored ancestry
```

## Proof evidence

Pass 4 inspected the prototype manufacturing ancestors and established one coherent owner.

The resulting architecture is recorded in `specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md` and incorporated into the Phase 1b outline.

No native Forge source was added during Pass 4. That is intentional. Pass 4 qualifies Forge's ownership and its relationship to the Ephemeris and spines. Pass 5 gives the Forge its first concrete manufacturing job and earns its native implementation through measurement.

## Status

**OWNERSHIP QUALIFIED / PASS 4 COMPLETE**

Forge is the canonical destination for temporal-artifact manufacturing work entering Pass 5.

---

# 14. Phase 1a Closure and Current Construction Boundary

Phase 1a was implemented under `specs/Phase 1a - Native Foundation Implementation Plan.md` in five controlled passes:

```text
Pass 1    Native domain vocabulary
Pass 2    Ring
Pass 3    Mater + Rulers rehouse
Pass 4    Tympan
Pass 5    Phase 1a closure
```

Final native state:

```text
Native domain vocabulary    IMPLEMENTED / NATIVE PROVEN
Ring                         NATIVE CANONICAL
Mater                        NATIVE CANONICAL
Rulers -> Mater              PROVEN / COMPLETE
Tympan                       NATIVE CANONICAL
```

Pass 5 added `FoundationIntegrationTests.swift`, which proves the three native foundation authorities compose rather than merely passing independently:

```text
Ring + Mater + Tympan share one canonical longitude/address vocabulary
Tympan consumes canonical Mater rulership
modern co-rulership remains outside the traditional governor socket
canonical foundational surfaces remain closed and complete
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

The Phase 1a OrboLab microscope was also launched successfully and displayed live native reads from Ring, Mater and Tympan. The sample read showed the same shared foundation used by the integration suite, including Ring relation, Mater dignity facts and Tympan frame data.

The production Orbo shell no longer consumes the Phase 0 linkage sentinel. The sentinel remains only as an inert historical smoke fixture and is not part of the production Phase 1a API.

Phase 1a is therefore:

```text
COMPLETE
```

Phase 1b is active under:

```text
specs/Phase 1b - Ovum Completion Outline.md
specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md
```

Current checkpoint:

```text
Pass 1    Geoplacement + terrestrial vocabulary    NATIVE CANONICAL / COMPLETE
Pass 2    Civil Time and timezone history          NATIVE CANONICAL / COMPLETE
Pass 3    AstroDNA contract                         NATIVE CANONICAL / COMPLETE
Pass 4    Ephemeris + Forge qualification           QUALIFIED / COMPLETE
Pass 5    Forge + Mundane Timespine v1              READY
Pass 6    Horizon + AstroDNA Encoder + Resolver     NOT STARTED
Pass 7    Loom                                      NOT STARTED
Pass 8    Resonator + Lab + seal Ovum               NOT STARTED
```

Pass 4 is complete at the ownership and astronomical-reference gate.

The qualified v1 astronomical reference is official Swiss Ephemeris `v2.10.3bfinal`, with its 2026 Swiss planetary-data rebuild based on JPL DE441. Ephemeris and Forge are separate Ovum organs. Forge is the sole sanctioned production client of Ephemeris.

Pass 5 may now measure candidate chronology representations and implement Forge's first manufacturing path. The result must be one immutable, versioned Mundane Timespine whose same version/checksum represents the same celestial chronology for every Orbo carrying it.

Swiss Ephemeris code/data must not be distributed inside Orbo until the project's AGPL-versus-Professional-License path is resolved. That is a release gate, not permission to substitute a weaker astronomical source silently.

No child spine may query the Ephemeris. Child spines must descend from the canonical Mundane Timespine plus their other canonical Orbo ancestry.

This ordering does not preassign any later component's 4R. Every meaningful Phase 1b component begins unclassified, receives fresh archaeology, and gets exactly one earned primary treatment before implementation.

Do not begin Phase 2 until the full Phase 1 Ovum exit gate is satisfied.