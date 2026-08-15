# Orbo 1.0 Native Construction Plan

**Status:** Working construction plan for the native iOS rebuild of Orbo 1.0.

**Date:** 2026-08-15

**Purpose:** Define how Orbo moves from the JavaScript/HTML prototype to a native Swift application without rediscovering solved work. The existing prototype remains the reference specimen. The new application is built piece by piece in Swift, beginning with OrboCore and proving each part before the next depends upon it.

---

# 0. Governing Premise

The project is no longer asking:

> How do we progressively migrate the existing JavaScript application?

It is asking:

> **Knowing what we know now, how would we build Orbo correctly from the beginning?**

The JavaScript/HTML Orbo is the prototype.

It contains a large amount of work that should survive:

- visual design
- interaction design
- equations
- tables
- algorithms
- tests
- fixtures
- astrological doctrine
- working engines
- known outputs
- successful behaviors

The native build does not discard those discoveries.

It transposes them into a production architecture with better ownership, better connectors, stronger contracts, native type safety, and fewer historical compromises.

The default presumption is that **much of the prototype should be replicated rather than reinvented**.

---

# 1. Correct Readout Before Presentation

The primary construction law is:

> **Get the instrument to know the right answer before teaching it how to show the answer.**

The astrolabe is a display of OrboCore.

It does not calculate astrology.

```text
CELESTIAL TRUTH
      ↓
ORBOCORE
      ↓
READOUT
      ↓
ASTROLABE / PANE / TABULA / ALMANAC
```

No native view should independently calculate astrology, repair an astrological result, or ask the astronomical substrate what the sky is doing.

---

# 2. OrboCore First

The first substantial product of the native rebuild is not the interface.

It is:

```text
OrboCore
```

OrboCore is a Swift package containing the computational organism.

It should be usable and testable without SwiftUI.

During the early rebuild, the native Orbo application may remain an immaculate black screen while OrboCore is constructed underneath it.

The initial development goal is not visual fidelity.

It is computational fidelity.

---

# 3. The Three Layers

The production application is built in this order:

```text
ORBOCORE
truth and computation

        ↓

ORBO APP
native instrument and interaction

        ↓

EXPRESSION
modular appearance and atmosphere
```

The existing Orbo appearance becomes the **default canonical Orbo appearance** once the native interface is reconstructed.

The later Expression System modifies that complete base instrument. It does not replace it.

---

# 4. The Ovum Is the Walled Garden

Every copy of Orbo ships with the complete unpersonalized celestial organism required to know the heavens.

That organism is the **Ovum**.

```text
┌──────────────────────── ORBO OVUM ────────────────────────┐
│                                                          │
│  INHERENT LAW                                            │
│  Ring                                                    │
│  Mater                                                   │
│  Tympan                                                  │
│  Rulers                                                  │
│                                                          │
│  CELESTIAL SOURCE / FORGE                                │
│  Ephemeris Kernel                                        │
│                                                          │
│  CANONICAL CELESTIAL CHRONOLOGY                          │
│  Orbo Spine                                              │
│                                                          │
│  CELESTIAL ENCODING                                      │
│  AstroDNA                                                │
│                                                          │
│  TEMPORAL SOLVING                                        │
│  Loom                                                    │
│                                                          │
│  INTEGRITY                                               │
│  Resonator / invariant checks                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

The Ovum is an architectural membrane, not merely a naming convention.

The rest of Orbo should not independently ask the ephemeris, the Orbo Spine, or other raw astronomical machinery for competing versions of celestial state.

The walled garden should ultimately be enforced by Swift module and access-control boundaries wherever practical.

---

# 5. The Orbo Spine Is the Runtime Celestial Substrate

The Orbo Spine exists specifically so Orbo does not continuously query the ephemeris during ordinary runtime.

The production direction is:

```text
EPHEMERIS KERNEL
      │
      │ forge / verify / extend
      ▼
ORBO SPINE
versioned shipped celestial chronology
      │
      ├── Ovum state reads
      ├── Loom searches
      └── temporal indexes
      │
      ▼
ASTRODNA
```

The normal runtime question is not:

```text
What does the ephemeris say right now?
```

It is:

```text
What does the canonical Orbo Spine say
at this celestial-time address?
```

The Orbo Spine is versioned because changes to its astronomical source, precision, supported range, interpolation strategy, indexed event families, corrections, or codec must produce an identifiable new celestial artifact.

The Spine may carry specialized indexes for ingresses, stations, retrograde periods, lunations, eclipses, aspect perfections, and other universal hinges.

Those indexes are conveniences over one chronology, not competing celestial authorities.

---

# 6. The Ephemeris Is the Forge

The ephemeris comes into the native project early, but its primary production role is upstream of the Orbo Spine.

Its principal jobs are:

```text
build Orbo Spine
verify Orbo Spine
extend supported range
test astronomical accuracy
repair a future Spine version
produce golden fixtures
```

OrboLab may inspect or compare the ephemeris directly during construction.

Production Orbo should not normally query it directly.

Any future runtime ephemeris fallback would require an explicit architectural ruling. It is not assumed by this plan.

---

# 7. Loom Lives Inside the Ovum

The Loom is temporal solving machinery inside the walled garden.

It searches the Orbo Spine rather than querying the ephemeris.

```text
celestial target
      ↓
     LOOM
      ↓
  ORBO SPINE
      ↓
coordinate / crossing / range
      ↓
 OVUM RESOLVER
      ↓
   ASTRODNA
```

The governing sentence remains:

> **The Connectome knows the target. The Loom finds the crossing.**

The Loom knows how to search.

It does not know why a condition matters astrologically.

---

# 8. The 4R Process

Every prototype component receives one of four treatments before native construction.

## 8.1 Replicate

The prototype component is fundamentally correct.

Transpose its law, behavior, tests, and proven output faithfully into Swift.

Typical candidates include:

- Ring
- Mater
- Tympan
- many static tables
- many pure mathematical utilities

**Replicate is the default presumption unless there is a specific architectural reason to do otherwise.**

## 8.2 Rehouse

The logic is correct but currently belongs to the wrong owner.

Preserve the logic while moving it to the correct native component.

Example:

- pure Prism algebra survives
- unrelated temporal or horizon machinery currently living near it moves to its proper owner

## 8.3 Reproduce

The prototype solved the correct problem or produces the correct result, but its implementation should not survive.

Build the native implementation against the proven result, fixtures, and behavior.

## 8.4 Retire

The component is prototype scaffolding, duplicate authority, browser machinery, or a superseded idea.

Do not port it.

---

# 9. The Swift Sanding Pass

After 4R classification, every surviving component receives a native-language pass.

Questions include:

- Can a string name become an actual domain type?
- Can an arbitrary integer become a Sign, House, or other constrained value?
- Can `null` / `undefined` ambiguity become deliberate optionality?
- Can runtime validation become impossible input?
- Can mutable data become immutable values?
- Can browser-global mirrors disappear?
- Can canonical ordering become structural rather than conventional?
- Can a law currently enforced by comments become enforced by Swift?
- Can a component expose less surface area?
- Can the wrong connector become impossible to attach?

This is not conceptual redesign.

It is manufacturing a discovered component to production tolerances.

---

# 10. The Repeated Construction Rhythm

Every individual component follows the same process:

```text
1. Inspect the prototype part.

2. State what it actually owns.

3. State what law it embodies.

4. Apply 4R:
   Replicate
   Rehouse
   Reproduce
   Retire

5. Define the native mating surface.

6. Perform the Swift sanding pass.

7. Transpose or build it.

8. Expose it in OrboLab.

9. Port or create its tests.

10. Compare against prototype and golden fixtures.

11. Connect it to the already-proven Core.

12. Run the entire accumulated test suite.

13. Inspect combined readouts.

14. Declare it native canonical.

15. Only then move to the next piece.
```

The construction model is therefore cumulative:

```text
A
✓

A + B
✓

A + B + C
✓

A + B + C + D
✓
```

A component is not finished merely because its file compiles or its isolated tests pass.

It is finished when it works by itself, connects correctly to the already-proven organism, and the combined system still passes.

---

# PHASE 0: The Lab

## Purpose

Create the native worksite and convert the existing prototype archaeology into a native porting manifest.

## Build

```text
Orbo
native iOS application

OrboCore
Swift computational package

OrboLab
internal development application

OrboCoreTests
native tests and fixtures
```

### Orbo

Initially:

```text
black native screen
```

Nothing more is required.

### OrboLab

Intentionally boring.

Its purpose is to expose construction state and correct readouts.

Example:

```text
ORBO LAB

RING
...

EPHEMERIS
...

ORBO SPINE
...

ASTRODNA
...

TESTS
...
```

OrboLab is allowed to open the engine hood.

A path exposed in OrboLab does **not** automatically become a production OrboCore API.

## Native Port Manifest

The previous system maps become a porting manifest rather than a migration wiring diagram.

Each important component receives:

```text
COMPONENT

CURRENT JOB

ACTUAL LAW

WHAT IS PROVEN

DEPENDENCIES

USER-VISIBLE CONSEQUENCE

4R
Replicate / Rehouse / Reproduce / Retire

SWIFT SANDING

NATIVE OWNER

PARITY STANDARD

FIXTURES / TESTS

STATUS
```

Statuses:

```text
NOT STARTED
IN LAB
PROVEN
CONNECTED
NATIVE CANONICAL
```

## Phase 0 Gate

Phase 0 ends when:

- the native Xcode worksite builds
- OrboCore can be tested independently
- OrboLab can inspect Core
- foundational prototype components are mapped
- 4R is the agreed porting process
- temporary lab access is clearly distinguished from production APIs
- no production architecture has been forced merely to accommodate prototype wiring

---

# PHASE 1: The Ovum

This is the foundational phase.

The complete unpersonalized celestial organism is built piece by piece inside the walled garden.

Each piece becomes native canonical before the next depends upon it.

---

## Phase 1A: Native Domain Language

Establish only the domain distinctions that materially protect Orbo.

Candidates include:

```text
Planet
Sign
House
Longitude
ArcsecondAddress
Motion
JulianDay
CelestialAddress
Horizon
```

Avoid decorative abstraction.

The goal is to eliminate meaningful category mistakes.

---

## Phase 1B: Ring

Expected 4R treatment:

```text
REPLICATE
```

Transpose:

- exact degree geometry
- admitted marks
- target relationships
- address projections
- immutability rules
- precision rules
- existing fixtures and invariants

JavaScript-specific guards may be replaced by stronger Swift types where the underlying law remains unchanged.

### Gate

The native Ring must pass its golden fixtures exactly before becoming canonical.

---

## Phase 1C: Mater

Expected 4R treatment:

```text
REPLICATE
```

Transpose:

- signs
- elements
- modalities
- traditional rulership
- exaltation
- detriment
- fall
- classical dispositor set

Use native typed vocabulary where appropriate.

### Gate

Mater agrees exactly with prototype doctrine and tests.

---

## Phase 1D: Tympan

Expected 4R treatment:

```text
REPLICATE
```

Transpose:

- twelve whole-sign frames
- reverse sign / house index
- governed-house index
- separate modern co-rulership index
- flip-house law

Swift should make Sign and House harder to confuse than they are in JavaScript.

### Gate

All 144 frame relationships and governance inversions pass.

---

## Phase 1E: Rulers and Remaining Inherent Law

Inspect the current ruler, dignity, and related inherent machinery using 4R.

Replicate what is correctly inherent.

Rehouse anything currently duplicated across modules.

At completion:

```text
Ring
Mater
Tympan
Rulers
```

are the single shipped inherent law set from which later structures read.

---

## Phase 1F: Ephemeris Kernel

Bring the astronomical source into the native worksite.

Do not assume automatically that the current JavaScript ephemeris is the final production astronomical source.

Establish:

- supported time range
- expected accuracy by body
- required output precision
- horizon calculations
- motion data
- source and version identity
- validation fixtures

The existing ephemeris remains valuable prototype code and reference material, but receives its own 4R assessment.

### Primary role

```text
EPHEMERIS
     ↓
SPINE FORGE
```

---

## Phase 1G: AstroDNA Contract

Define the production celestial genome before finalizing the Orbo Spine representation, because the Spine must be able to reproduce the state AstroDNA requires.

Settle:

- canonical body order
- supported nodes
- positional fidelity
- directional and motion encoding
- exact integer / address representation
- horizon-sensitive content
- projections
- identity rules
- what does not belong in AstroDNA

Core law:

> **AstroDNA contains celestial identity, not everything that can be derived from celestial identity.**

Canonical order must be explicit and must never rely on unordered dictionary iteration.

---

## Phase 1H: Orbo Spine

The Orbo Spine is the **versioned compiled celestial chronology** that ships with Orbo.

```text
EPHEMERIS
     ↓
SPINE FORGE
     ↓
ORBO SPINE vN
```

It must support the actual state resolution required by AstroDNA, not merely a list of interesting event timestamps.

It may also carry specialized indexes for:

- ingresses
- stations
- retrograde periods
- lunations
- eclipses
- aspect perfections
- other universal celestial hinges

Those indexes are conveniences over the same chronology.

### Prototype ancestry to preserve

From the native-independent shipped celestial floor:

- shipped chronology rather than routine runtime rescanning
- verified-once principle
- native-independent artifact
- packed/versioned storage

From the historical TimeSpine work:

- version discipline
- chunking
- seam overlap
- deduplication
- sorted temporal reads
- conformance testing against expensive scans

Neither current JavaScript object dictates the final Swift representation.

### Gate

For a broad fixture set:

```text
Ephemeris source
       ↓
expected celestial state

Orbo Spine
       ↓
resolved celestial state
```

must agree within explicitly declared fidelity.

Once proven, the Orbo Spine becomes the runtime celestial substrate.

---

## Phase 1I: Ovum AstroDNA Resolver

Build the main production celestial door:

```text
Celestial Address
      ↓
ORBO SPINE
      ↓
Ovum Resolver
      ↓
AstroDNA
```

The resolver should not silently reopen the ephemeris because a requested coordinate is inconvenient.

Unsupported range or missing Spine coverage is a declared condition, not permission to create a second astronomical authority.

---

## Phase 1J: Loom

The Loom now lives inside the Ovum and searches the Orbo Spine.

Inputs:

```text
target
temporal range
search parameters
```

Outputs:

```text
coordinate
crossing
range
boundary
```

When a complete celestial configuration is required:

```text
Loom result
    ↓
Ovum Resolver
    ↓
AstroDNA
```

### Gate

Prove known:

- ingresses
- stations
- exact aspects
- horizon crossings
- temporal boundaries

No Loom search may require an external ephemeris hose.

---

## Phase 1K: Ovum Resonator

Build the foundation's fidelity checks.

The Resonator may compare:

```text
Orbo Spine
vs
Ephemeris source

AstroDNA
vs
known fixtures

Loom result
vs
known crossing

inherent law
vs
golden tables
```

The Resonator is not another celestial authority.

It checks authority.

---

## Phase 1L: Seal the Wall

At the end of Phase 1:

```text
┌──────────────────────── OVUM ────────────────────────┐
│ Ring                                                 │
│ Mater                                                │
│ Tympan                                               │
│ Rulers                                               │
│                                                      │
│ Ephemeris Kernel / Spine Forge                       │
│                                                      │
│ Orbo Spine                                           │
│                                                      │
│ AstroDNA Resolver                                    │
│                                                      │
│ Loom                                                 │
│                                                      │
│ Resonator                                            │
└─────────────────────────┬────────────────────────────┘
                          │
                       AstroDNA
                          │
                          ▼
                    rest of Orbo
```

The exact Swift package and access-control layout should make this boundary real rather than merely documented.

## Phase 1 Gate

Do not leave the Ovum until:

- inherent law is canonical
- ephemeris accuracy is understood
- AstroDNA is defined
- the Orbo Spine is versioned and validated
- normal runtime state resolution uses the Spine
- Loom searches the Spine
- the Ovum operates without a native
- golden celestial fixtures pass
- no downstream component needs raw ephemeris access

At this point:

> **Orbo knows the heavens.**

---

# PHASE 2: The Connectome

Now unfold AstroDNA.

```text
ASTRODNA
    ↓
CONNECTOME
```

The Connectome is the structural expression of a celestial configuration.

Likely content includes:

- one first-class node per AstroDNA gene
- sign expression
- house placement
- motion expression
- dignity
- rulership
- dispositorship
- governance
- receptions where admitted
- exact relation edges
- applying / separating
- Lots
- Forged Ring
- legitimate aggregate structures

Core laws:

> **Each gene has a node. Relationships are edges.**

> **Velocity belongs to the node. Applying and separating belong to the edge.**

> **The Connectome is AstroDNA unfolded.**

Existing `connectome.js`, dispositor code, rulers, and related readers receive individual 4R judgments.

## Phase 2 OrboLab Readout

Plain-text inspection should make the full structural state auditable without an astrolabe.

Example:

```text
MARS
longitude
sign
motion
house
domicile ruler
dignity
dispositor
governed houses
relations
...
```

## Phase 2 Gate

Do not continue until:

- one AstroDNA produces one deterministic Connectome
- inherent law is referenced rather than duplicated
- structural facts have one owner
- duplicate derivations are removed
- node relationships agree with fixtures
- houses and rulership agree
- dispositor chains agree
- admitted relation edges agree
- all Phase 1 tests remain green

At this point:

> **Orbo knows what a celestial configuration structurally contains.**

---

# PHASE 3: Fertilization

Now personalize the universal organism.

Build the nonvisual onboarding mechanics required to determine the native's exact natal celestial address, including rectification when required.

Then:

```text
birth address
     ↓
OVUM
     ↓
AstroDNA
     ↓
ENGRAVE
     ↓
MY ASTRODNA
```

`my AstroDNA` remains the universal AstroDNA format.

No native flag is encoded into the genome.

Its specialness comes from being seated as Orbo's root.

Then:

```text
my AstroDNA
     ↓
my Connectome
```

## Phase 3 Gate

Before fertilization:

> **Orbo knows the heavens.**

After fertilization:

> **Orbo knows which celestial configuration is me.**

The same Ovum must operate correctly before and after engraving.

---

# PHASE 4: Personalized Temporal Core

Use the universal Ovum and the native root to create personal chronology.

Reconcile:

- transit/contact chronology
- native temporal indexes
- lazy versus eager materialization
- dense-window policies
- personal caching
- the useful mechanics in historical `fertilize.js`
- natal-specific historical TimeSpine work
- Luna's cardinality strategy

Core relationship:

```text
ORBO SPINE
universal source

      +

MY ASTRODNA / CONNECTOME
personal target structure

      ↓

PERSONAL TEMPORAL STRUCTURES
```

Personal spines are not celestial authorities.

They are regenerable organizations of universal celestial truth relative to the native.

---

# PHASE 5: Synchronic Core

Build the synchronic system against the stable native Core.

## Prism

Prism is pure synchronic algebra.

```text
my AstroDNA
     +
moment AstroDNA
     ↓
Prism
     ↓
synchronic AstroDNA
```

Inverse:

```text
desired synchronic coordinate
        ↓
Prism
        ↓
required celestial coordinate
        ↓
Ovum / Loom / Orbo Spine
```

Prism does not receive ephemeris geometry, GMST, temporal scanning, or raw astronomical probes.

## Synchronic Spine

The temporal extension of the native Field.

Conceptually continuous.

Materialized only as useful.

## Synchronic Clock

The continuous playhead through the synchronic chronology.

Distinct from analytical Composite Frames.

## Phase 5 Gate

Require:

- identity case passes
- inverse refraction passes
- Connectome unfolds synchronic AstroDNA
- Loom solves Prism-generated targets through Orbo Spine
- no second sky path appears
- all previous phases remain green

---

# PHASE 6: Derived Fields

Reconcile other ways Orbo creates valid derived celestial configurations.

Includes:

- midpoint relationship composites
- progressed charts
- progressed composites
- mundane transits to composites
- Synchronic Synastry
- other admitted derived Fields

Central law:

```text
DERIVED OPERATION
     ↓
derived AstroDNA
     ↓
Connectome
```

Parent relationships belong in Field or relationship structures, not inside the genome.

This phase prevents each derived technique from inventing its own chart-shaped payload.

---

# PHASE 7: Profiles, Fields, Crystals, Threads, and Memory

Build Orbo's durable user-knowledge layer.

```text
Profile
Field
Crystal
Thread
Favorite
Journal Observation
Evidence
```

Keep identity and meaning separate from celestial computation.

Preserve:

```text
irreplaceable user meaning
```

while treating:

```text
spines
indexes
cached Connectomes
derived artifacts
```

as rebuildable computational material.

Old Pin, Ledger, Favorite, and Journal ancestors receive their 4R judgments here.

---

# PHASE 8: Technique Engines

Port specialized astrological techniques onto the completed Core rather than allowing them to manufacture independent infrastructure.

Examples:

- transits
- progressions
- progressed aspects
- Zodiacal Releasing
- profections
- Horary
- electional
- Lots and time-lord techniques
- Synchronic Synastry readers

Each receives its own 4R pass.

Technique engines consume canonical structures such as:

```text
AstroDNA
Connectome
Ovum
Loom
Spines
Fields
Crystals
```

They do not create new celestial authorities.

---

# PHASE 9: Interpretation and Readout Contracts

Ensure OrboCore can provide every meaningful readout the application requires.

Interpretation packs sit above structural truth.

They do not recalculate it.

Define stable readout contracts for:

- astrolabe
- Big Three
- Lunar Pane
- Almanac
- Tabulas
- sockets
- timeline readers
- technique views

The native UI receives prepared truth rather than assembling astrology itself.

---

# PHASE 10: Whole-Core Resonator

Before serious visual reconstruction, perform an organism-wide integrity pass.

Questions include:

- Can every important prototype readout be reproduced?
- Does every celestial fact have one authority?
- Does normal runtime ever query ephemeris instead of the Orbo Spine?
- Does Loom ever bypass the Spine?
- Can every AstroDNA be traced to the Ovum?
- Can every Connectome fact be traced to AstroDNA plus inherent law?
- Are personal spines regenerable?
- Are there duplicate formulas?
- Are there accidental second paths?
- Do all previous phase tests still pass together?

At the end of this phase the gloriously boring Orbo should be computationally complete.

---

# PHASE 11: Native Default Orbo

Now rebuild the visible instrument.

The existing prototype is the visual design authority.

The default treatment is:

```text
REPLICATE
```

Transpose the current Orbo appearance:

- astrolabe
- geometry
- depth
- materials
- typography
- Big Three
- Lunar Pane
- menus
- Tabulas
- sockets
- Almanac
- beads
- aspect web
- seating
- Orbo sphere
- visual hierarchy

The default Orbo appearance is the appearance already designed.

It is not temporary.

It is the canonical base instrument.

Presentation reads Core outputs.

```text
OrboCore
    ↓
Readout Models
    ↓
Native Views
```

Never:

```text
View
  ↓
calculate astrology
```

---

# PHASE 12: Native Interaction Fidelity

Rebuild the prototype's physical language in native iOS:

- drag
- scrub
- springs
- depth
- lunar rise
- eclipse behavior
- parallax
- wheel manipulation
- touch targets
- navigation
- presentation clock

Native technology may improve performance and feel.

The interaction grammar should remain recognizably Orbo unless a change is deliberate.

---

# PHASE 13: Expression System

Only after Default Orbo has been faithfully reconstructed.

Build the modular expression layer.

```text
DEFAULT ORBO
      ↓
EXPRESSION SYSTEM
      ↓
RISING-SIGN DEFAULT EXPRESSION
```

The twelve rising-sign expressions inherit the complete default instrument.

They may modify permitted presentation qualities such as:

- material treatment
- lighting
- atmosphere
- motion temperament
- texture
- density
- environmental treatment
- accent behavior

They do not alter astrological truth.

Underlying geometry, information architecture, accessibility, and interaction grammar remain stable unless explicitly redesigned.

---

# PHASE 14: Prototype Retirement

Only when native Orbo carries the required computational and experiential load does the HTML/JavaScript prototype cease to be the active implementation.

Retire production dependence on:

- browser mirrors
- standalone export machinery
- Capacitor wrapper
- obsolete runtime bridges
- temporary lab adapters

Keep:

- prototype history
- useful golden fixtures
- architectural archaeology
- enduring visual reference material

Production authority becomes:

```text
OrboCore
   +
Native Orbo
```

---

# 11. Native Construction Topology

The target architecture can be summarized as:

```text
                  BUILD / VERIFICATION

                     EPHEMERIS
                         │
                         ▼
                    SPINE FORGE
                         │
                         ▼

┌────────────────────── OVUM ─────────────────────────┐
│                                                    │
│ Ring · Mater · Tympan · Rulers                     │
│                                                    │
│                 ORBO SPINE                         │
│                versioned truth                     │
│                     │                              │
│          ┌──────────┴──────────┐                   │
│          ▼                     ▼                   │
│    AstroDNA Resolver          Loom                 │
│          │                     │                   │
│          └──────────┬──────────┘                   │
│                     ▼                              │
│                  AstroDNA                          │
│                                                    │
└──────────────────────┬─────────────────────────────┘
                       │
                       ▼
                  CONNECTOME
                       │
                       ▼
                  FERTILIZATION
                       │
                       ▼
                  MY ASTRODNA
                       │
          ┌────────────┼─────────────┐
          ▼            ▼             ▼
      personal       Prism       derived Fields
       time            │
                       ▼
                synchronic AstroDNA
          └────────────┬─────────────┘
                       ▼
                 ORBOCORE READOUT
                       │
                       ▼
                  NATIVE ORBO
                       │
                       ▼
                 DEFAULT ORBO
                       │
                       ▼
               EXPRESSION SYSTEM
```

---

# 12. Final Construction Principle

The JavaScript prototype is not a failed first version that must be escaped.

It is the working specimen that taught us what Orbo is.

The native rebuild should therefore preserve solved work aggressively while correcting the underlying organism.

The project should repeatedly ask:

> **What about this part is genuinely Orbo, and what about it only exists because this was the JavaScript prototype?**

The first is preserved through the 4R process.

The second is sanded away.

The goal is not to rewrite Orbo.

The goal is to manufacture Orbo 1.0 from everything the prototype already taught us.
