# Native Port Manifest

**Status:** Living Phase 0 port authority for Orbo 1.0 native construction.

**Last updated:** 2026-08-15

**Governing authorities:**

1. `specs/Orbo 1.0 Native Construction Plan.md`
2. `specs/Phase 0 - The Lab.md`
3. `specs/Phase 1 - The Ovum.md`

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
ios-wrapper unchanged                 PASS
No premature Phase 1 component port   PASS
```

The temporary `OrboCoreBuild.linkageSentinel` remains construction scaffolding only. It defines no production OrboCore API.

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

---

# 3. Port Ledger

| Component | Primary 4R | Parity | Native destination | Status |
|---|---|---|---|---|
| Native proof apparatus | REPRODUCE | Behavioral | OrboCoreTests | IMPLEMENTED / NATIVE PROVEN |
| Ring | REPLICATE | EXACT | OrboCore / Ring | ASSESSED / NOT IMPLEMENTED |
| Mater | REPLICATE | EXACT | OrboCore / Mater | ASSESSED / NOT IMPLEMENTED |
| Tympan | REPLICATE | EXACT | OrboCore / Tympan | ASSESSED / NOT IMPLEMENTED |
| Rulers | PENDING | PENDING | PENDING | QUEUED |
| Ephemeris | PENDING | PENDING | PENDING | QUEUED |
| AstroDNA | PENDING | PENDING | PENDING | QUEUED |
| Mundane chronology | PENDING | PENDING | PENDING | QUEUED |
| Timespine temporal lessons | PENDING | PENDING | PENDING | QUEUED |
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

## What it currently does

The Ring is the prototype's inherent circular relationship surface.

It provides the universal degree geometry consulted by multiple later systems without knowing what occupies those positions.

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

## Current dependencies

None. Ring is the prototype floor for inherent degree relation.

## Current consumers

Prototype consumers include systems that require canonical aspect / degree geometry, including AstroDNA, framing, Loom-related work, and parity/readout machinery.

## Known tests / fixtures

```text
tests/ring.test.html
tests/fixtures/aspect-atlas.md
tests/rewire-parity.test.html
```

## User-visible consequence

Any later Orbo feature that reads relationships between celestial positions depends on the Ring remaining stable. A Ring error can move aspect identity or target geometry across natal, mundane, synchronic, temporal, and derived reads.

## 4R

**REPLICATE**

## Why

The component has a coherent single responsibility, no foundational dependency, mature tests, a golden human-auditable atlas, and later prototype systems already treat it as canonical degree-relation authority.

No architectural defect has been found that justifies reopening its solved design.

Replication does not require line-for-line Swift translation. It requires preservation of the Ring's law, behavior, tests, and proven outputs.

## Swift Sanding

Preserve law and outputs while manufacturing to native tolerances.

Expected sanding includes:

```text
anonymous Number
-> meaningful Swift numeric/domain types where category errors matter

runtime boolean validation
-> Bool

Object.freeze and typed-array mutation defenses
-> immutable native values / storage

null / undefined absence behavior
-> explicit Optional

browser-global registration
-> no native counterpart

ring.browser.js
-> no production native mirror
```

Do not expand or reduce Ring ownership merely because Swift permits a different representation.

## Native destination

```text
OrboCore / Ring
```

## Native dependencies

Only the minimum Phase 1 native domain vocabulary approved before Ring construction, if required.

Ring must not depend on Mater, Tympan, AstroDNA, ephemeris, Orbo Spine, Loom, UI, time, or place.

## Native mating surface

Later native components must receive canonical Ring geometry from OrboCore rather than reintroducing competing angle tables or asking the JavaScript prototype at runtime.

The public surface should expose only what downstream native components actually require. Lab-only or test-only inspection does not automatically become production API.

## Parity standard

**EXACT**

```text
same valid input
same Ring law
same output
```

## Proof method

```text
native unit laws
+
exhaustive invariant sweeps
+
existing aspect atlas
+
JavaScript / Swift parity fixtures
+
accumulated integration tests
```

## Proof evidence

Not yet implemented natively.

## Status

**ASSESSED / NOT IMPLEMENTED**

Ring is not native canonical yet.

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
tests/rewire-parity.test.html
```

Relevant ownership neighbors:

```text
tympan.js
rulers.js
```

## What it currently does

The Mater is the prototype's inherent sign-level zodiacal structure.

The Ring owns inherent relation. The Mater owns inherent meaning at sign resolution.

It is stamped before the app runs and requires no person, time, place, chart, or UI.

## Actual law

The Mater owns:

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

The Mater does not own:

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
sect
orbs
interpretation prose
```

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

absence at the Mater layer is null, not peregrine

house frames are absent from Mater
house frames are owned by Tympan

framing, AstroDNA, and Rulers read Mater's canonical tables rather than maintaining private copies
```

The test suite checks table identity where possible, not merely equality, so central ownership is proven rather than inferred from matching values.

## Current dependencies

None.

Mater is an inherent floor component and imports nothing.

It is a sibling of Ring, not a child of Ring.

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

## Known tests / fixtures

```text
tests/mater.test.html
tests/rewire-parity.test.html
```

Mater's native parity fixtures should be derived from these proven tables and reads during Phase 1 preparation / implementation.

## User-visible consequence

A Mater error can change sign identity, element, modality, traditional rulership, dispositor eligibility, exaltation, detriment, fall, and every downstream technique that depends on those facts.

The traditional / modern boundary is especially consequential. Adding Pluto, Uranus, or Neptune to Mater's traditional ruler table would alter classical disposition and governance logic rather than merely changing display.

## 4R

**REPLICATE**

## Why

Mater has a coherent single responsibility, no prototype dependency, mature tests, established consumers, and explicit boundaries with both Tympan and Rulers.

The prototype has already completed important centralization work:

```text
house frames moved out to Tympan
modern co-rulership remains separate
sign-level dignity remains here
sub-sign dignity remains in Rulers
private duplicate tables were removed from readers
```

No architectural defect has been found that justifies redesigning or redistributing Mater's law.

The Phase 1 plan predicted REPLICATE. The prototype archaeology and test evidence now independently support that result, so the ruling is earned rather than assumed.

## Swift Sanding

Preserve law and exact values while manufacturing the component to native tolerances.

Expected sanding includes:

```text
string sign identity
-> native Sign type

string planet identity
-> native Planet type where appropriate

string element / modality identity
-> native Element / Modality types

raw longitude Number
-> CelestialLongitude or approved native numeric vocabulary

parallel JavaScript table shapes
-> one maintained native fact with derived views where useful

Object.freeze
-> immutable Swift values

null
-> explicit Optional

load-time JavaScript mutation / completeness defenses
-> construction-time invariants and native tests

mater.browser.js / window.__ORBO_MATER
-> no production native counterpart
```

Swift Sanding must not merge modern co-rulers into the traditional rulership backbone.

Swift Sanding must not move houses back into Mater.

Swift Sanding must not absorb triplicity, bounds, faces, or the degree-level dignity ladder from Rulers.

Swift Sanding must preserve the semantic distinction:

```text
no sign-level essential dignity
!=
peregrine
```

`peregrine` can only be decided by the later degree-level dignity layer after checking all admitted dignity rungs.

## Native destination

```text
OrboCore / Mater
```

## Native dependencies

Only the minimum approved Phase 1 native domain vocabulary required to keep unlike things unlike.

Likely vocabulary includes:

```text
Sign
Planet
Element
Modality
CelestialLongitude
```

Mater must not depend on Ring, Tympan, Rulers, AstroDNA, ephemeris, Orbo Spine, Loom, UI, time, place, or interpretation.

## Native mating surface

Native consumers should ask Mater for canonical sign-level facts rather than importing duplicate tables.

Conceptually, the mating surface may provide reads such as:

```text
element(of: Sign)
modality(of: Sign)
domicileRuler(of: Sign)
exaltation(in: Sign)
dignity(of: Planet, in: Sign)
sign(of: CelestialLongitude)
```

The exact Swift API is not decided in Phase 0.

The production surface should expose only what downstream native components actually require. Alternate keyed / indexed shapes should be derived views, not independently maintained authorities.

The ownership seam remains:

```text
Mater
    sign-level zodiacal law

Tympan
    sign <-> house and governance indexes

Rulers
    sub-sign dignity law
```

## Parity standard

**EXACT**

Exact means law and value parity, not line-for-line JavaScript API-shape parity.

## Proof method

When Phase 1 implementation begins, prove:

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

all 84 classical-planet / sign dignity reads
longitude -> sign boundary behavior

house material absent
modern co-rulership absent
sub-sign dignity material absent

Golden fixture parity
JavaScript / Swift parity
native unit invariants
Ring + Mater accumulated suite green
```

## Proof evidence

Prototype law and ownership are proven by the existing Mater and rewire parity tests.

Native implementation has not begun.

## Status

**ASSESSED / NOT IMPLEMENTED**

Mater is not native canonical yet.

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

## What it currently does

The Tympan is the prototype's canonical whole-sign housing die and governance index.

It takes a rising sign and exposes the universal structural consequences of that frame. It requires no person, time, place, occupants, chart persistence, or UI.

It is inherent like Ring and Mater, but unlike those two it has one intentional dependency: Mater supplies canonical sign and traditional rulership facts.

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
triplicity
bounds
faces
degree-level dignity
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

```text
Mater
```

Prototype Tympan imports Mater's:

```text
SIGNS
RULERS
DISPOSITORS
signIndexOf
```

It imports nothing else.

Ring is not a dependency.

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

```text
tests/tympan.test.html
tests/rewire-parity.test.html
```

The native parity fixtures should preserve every frame and both governance indexes during Phase 1 preparation / implementation.

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

The Phase 1 plan predicted REPLICATE. Prototype archaeology and test evidence now independently support that ruling.

## Swift Sanding

Preserve exact law and outputs while eliminating JavaScript's category traps.

Expected sanding includes:

```text
0-11 sign address integers
-> native Sign type

1-12 house ordinal integers
-> native House type

string governor identity
-> native Planet / approved governor vocabulary

manual sign-address and house-ordinal validators
-> stronger native types and boundary validation where external raw input still exists

repeated ordinal-minus-one indexing concerns
-> hidden native representation detail

parallel mutable-looking JavaScript table shapes
-> immutable native frame records and derived indexes

Object.freeze
-> immutable Swift values

null / undefined
-> explicit Optional

browser-global registration
-> no native counterpart

tympan.browser.js
-> no production native mirror
```

The native representation may collapse redundant JavaScript storage, but it must preserve these capabilities as canonical reads:

```text
sign -> house
house -> sign
house -> traditional ruler
traditional governor -> houses ruled
modern co-ruler -> houses co-ruled
frame record
opposite / six-house relation
```

The traditional and modern governance paths must remain structurally separate. A native API that expects a traditional governor should not silently accept a modern co-ruler.

The reverse governance indexes must remain pre-stamped, cached, or otherwise canonical. Downstream readers must not return to scanning twelve houses on every read.

`houseOfLon` may remain as a convenience read or be expressed as Mater sign resolution followed by a Tympan lookup. That API-shape decision is deferred to Phase 1 and does not alter Tympan ownership.

## Native destination

```text
OrboCore / Tympan
```

## Native dependencies

```text
Mater
minimum approved Phase 1 native domain vocabulary
```

Likely vocabulary includes:

```text
Sign
House
Planet
CelestialLongitude
```

Tympan must not depend on Ring, Rulers, AstroDNA, Connectome, ephemeris, Orbo Spine, Loom, UI, occupants, time, place, or interpretation.

## Native mating surface

Native consumers should ask Tympan for canonical whole-sign housing and governance rather than reproduce modular rotations or hand-walk Mater's ruler table.

Conceptually, the mating surface may provide reads such as:

```text
frame(forRising: Sign)
house(of: Sign, rising: Sign)
sign(of: House, rising: Sign)
ruler(of: House, rising: Sign)
housesRuled(by: Planet, rising: Sign)
coRuler(of: Sign)
housesCoRuled(by: Planet, rising: Sign)
opposite(of: House)
```

The exact Swift API is not decided in Phase 0.

The ownership seam remains:

```text
Mater
    sign-level zodiacal law
        |
        v
Tympan
    sign <-> house and governance indexes
        |
        v
later Connectome
    occupants + frame -> chart-specific routing
```

Rulers remains the owner of sub-sign dignity law and is not absorbed into Tympan.

## Parity standard

**EXACT**

Exact means law and result parity, not line-for-line JavaScript array or object-shape parity.

## Proof method

When Phase 1 implementation begins, prove:

```text
all 12 complete frames
all 144 sign -> house reads
all 144 house -> sign reads
all forward / reverse round trips

every traditional house ruler
all 84 traditional governor / frame reverse indexes
all seven governors account for exactly twelve houses per frame

all three modern co-ruler assignments
all modern reverse co-governance indexes
traditional / modern structural separation

canonical frame record parity
six-house opposition / flip law
flip involution

absence / empty / malformed semantics
no occupant-specific facts
no interpretation content

Golden fixture parity
JavaScript / Swift parity
native unit invariants
Ring + Mater + Tympan accumulated suite green
```

## Proof evidence

Prototype law and ownership are proven by the existing Tympan and rewire parity tests.

Native implementation has not begun.

## Status

**ASSESSED / NOT IMPLEMENTED**

Tympan is not native canonical yet.

---

# 8. Current Construction Boundary

Phase 0 may continue archaeology, fixture work, manifest work, and Phase 1 queue preparation.

Do not implement the following production components during Phase 0:

```text
Ring
Mater
Tympan
Rulers
Ephemeris / Spine
AstroDNA
Horizon
Loom
Connectome
```

The native proof apparatus prepares the bench.

The Native Port Manifest records what has actually been learned.

Neither is permission to begin Phase 1 early.
