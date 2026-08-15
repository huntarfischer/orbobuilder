# Phase 0: The Lab

**Status:** Native construction worksite plan for Orbo 1.0.

**Purpose:** Establish the native construction site, preserve the prototype as a reference specimen, and turn everything already learned about Orbo into a practical porting map before the first production component is transposed into Swift.

Phase 0 does **not** rebuild Orbo.

It builds the place where Orbo will be rebuilt.

The goal is to leave Phase 0 with a boring but trustworthy native worksite where one prototype component at a time can be assessed with the 4R process, transposed into Swift, proven, connected to the growing OrboCore, and only then followed by the next component.

---

# 0.1 Governing Idea

We are not beginning with:

```text
How do we make the HTML app run in Swift?
```

We are beginning with:

```text
Knowing what we know now,
how would we build Orbo correctly from the beginning?
```

The current JavaScript/HTML Orbo remains intact.

It is the **prototype bridge**, the reference specimen, and often the oracle for behavior that has already been solved.

Phase 0 creates a separate native worksite:

```text
PROTOTYPE ORBO                         NATIVE ORBO 1.0
JavaScript / HTML                      Swift
still intact                           begins empty
reference specimen                     production future

        │                                      │
        │ inspect                              │
        │ compare                              │
        │ extract                              │
        └──────────────► THE LAB ◄─────────────┘
```

There is no requirement for the native application to operate with the prototype.

They remain separate.

---

# 0.2 The Three Native Targets

Phase 0 establishes three distinct things.

## OrboCore

```text
OrboCore
```

A Swift package containing Orbo's computational organism.

At Phase 0 it may contain almost nothing.

Its significance is architectural:

- no SwiftUI dependency
- no visual assumptions
- independently testable
- reusable by the native application
- future home of the Ovum, Connectome, Prism, temporal systems, and other computational structures
- production code lives here rather than inside views

The basic law begins immediately:

> **OrboCore knows. The app displays.**

---

## OrboLab

```text
OrboLab
```

An internal native development application.

It is deliberately not Orbo's user interface.

Its job is to expose and interrogate OrboCore while we build it.

Eventually it may show something like:

```text
ORBO LAB

OVUM
Status: Proven

ORBO SPINE
Version: 1
Coverage: ...
Status: Proven

ASTRODNA
Ascendant: ...
Moon: ...
Sun: ...
...

CONNECTOME
...

LOOM
...

TEST STATUS
418 passed
0 failed
```

But Phase 0 only needs the shell that allows those panels to appear later.

### Lab law

> **OrboLab may expose construction internals that production Orbo must never expose.**

For example, later the Lab may directly inspect:

```text
raw ephemeris output
raw Spine entries
Ring tables
AstroDNA bytes
Loom roots
Connectome nodes
cache identities
precision comparisons
```

That does not mean those become public OrboCore interfaces.

The Lab has the engine hood open.

The finished instrument does not.

---

## Orbo

The actual native iOS application.

At the end of Phase 0 it can be almost nothing:

```text
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│            BLACK            │
│                             │
│                             │
│                             │
└─────────────────────────────┘
```

No astrolabe yet.

No effort to recreate the prototype interface.

No rising-sign expression system.

No panels.

No interpretation.

The important fact is simply:

> **The real native Orbo exists.**

And it consumes `OrboCore`, even if there is almost nothing to consume yet.

---

# 0.3 Repository Structure

Phase 0 should establish a clean native home rather than evolving the Capacitor wrapper into the production app.

Conceptually:

```text
orbobuilder/
│
├── existing prototype files
│   ├── *.js
│   ├── *.browser.js
│   ├── standalone HTML
│   ├── ios-wrapper/
│   └── tests/
│
├── native/
│   │
│   ├── Orbo/
│   │   native iOS application
│   │
│   ├── OrboLab/
│   │   internal development app
│   │
│   └── OrboCore/
│       Swift package
│       │
│       ├── Sources/
│       └── Tests/
│
└── specs/
```

The exact folder layout can be decided when implementation begins.

What matters is the boundary:

```text
PROTOTYPE
separate

NATIVE PRODUCTION
separate
```

We are not stuffing Swift beside JavaScript one file at a time and gradually turning one application into the other.

---

# 0.4 Establish the Native Build Environment

Phase 0 proves the basic native toolchain before any meaningful astrology is involved.

We should be able to:

```text
build OrboCore

run OrboCore tests

launch OrboLab

launch Orbo

run both on simulator

run Orbo on a physical iPhone

make Orbo import OrboCore

make OrboLab import OrboCore
```

A tiny temporary Core function may be used merely to prove linkage.

For example:

```text
OrboCore.version
→ "0.0"
```

If OrboLab can display it, the connector works.

Then that construction stub can disappear.

---

# 0.5 Establish the Test Laboratory

Tests are not something added after OrboCore is built.

They are part of the construction machinery from the first day.

Phase 0 establishes places for several kinds of proof.

## Unit tests

A native component against its own laws.

Example later:

```text
Ring.target(...)
```

produces the correct result.

## Golden fixtures

Known inputs and expected outputs preserved independently of the new implementation.

For example:

```text
INPUT
state 0
angle 90
direction +

EXPECTED
90
```

The prototype can help produce these where appropriate.

## Cross-language parity fixtures

Temporary construction evidence:

```text
JAVASCRIPT
input → output

SWIFT
same input → output

COMPARE
```

This is particularly useful for **Replicate** components.

The Swift runtime does not call JavaScript.

The comparison happens in the Lab/tests.

## Integration tests

As OrboCore grows:

```text
A
PASS

A + B
PASS

A + B + C
PASS
```

Every new component must prove that it has not damaged previously canonical components.

## Invariant tests

Some Orbo laws are better expressed as properties than individual examples.

For example:

```text
there are always twelve signs

each whole-sign frame contains houses 1–12 exactly once

a Ring target always remains inside 0–359

an AstroDNA genome always has canonical gene order
```

These become executable laws.

---

# 0.6 The 4R Port Manifest

The most important intellectual work of Phase 0 is converting the existing archaeology and traffic map into a **native port manifest**.

We do not need to inspect every pixel and every file before Phase 1.

We need enough information to understand the parts approaching the native construction line.

Each significant prototype component gets a record like this:

```markdown
## Component: Ring

### Prototype source
ring.js

### What it currently does
...

### Actual law
...

### What is proven
...

### Current dependencies
...

### Current consumers
...

### Known tests / fixtures
...

### User-visible consequence
...

### 4R
REPLICATE

### Why
...

### Swift sanding
...

### Native destination
OrboCore / Ovum / Ring

### Native dependencies
none

### Parity standard
exact

### Status
NOT STARTED
```

---

# 0.7 The 4R Decision

Each component receives exactly one primary treatment.

## Replicate

```text
REPLICATE
```

The part is fundamentally right.

Translate it into native material without reopening solved design.

Examples we currently suspect strongly:

```text
Ring
Mater
Tympan
many immutable tables
many pure equations
```

Replication does not require line-for-line Swift translation.

It means:

> **Preserve this part's law and behavior.**

## Rehouse

```text
REHOUSE
```

The thing is right but lives with the wrong neighbors.

Example:

```text
prototype prism.js
```

may contain pure synchronic mathematics worth preserving exactly, but some horizon and temporal machinery belongs elsewhere.

The law survives.

The wiring changes.

## Reproduce

```text
REPRODUCE
```

The prototype solved the problem correctly but we do not want its machinery.

We preserve:

```text
behavior
result
acceptance criteria
fixtures
```

and manufacture a new implementation.

## Retire

```text
RETIRE
```

Prototype construction material that has served its purpose.

Examples may eventually include:

```text
browser-global mirrors
Capacitor-specific production assumptions
duplicate calculation paths
old Pin ontology
superseded adapters
```

Retirement should still state **what lesson or capability was extracted** so we do not accidentally throw away a solved requirement with the obsolete implementation.

---

# 0.8 Add the Swift Sanding Assessment

The 4R decision answers:

> What survives?

The Swift Sanding section answers:

> What can now become cleaner because we are using native Swift?

For each component we inspect:

```text
strings that should become types

integers whose meanings should differ

undefined/null behavior

mutability

canonical ordering

runtime validators

module visibility

browser-specific machinery

duplicate representation

error behavior

precision types
```

Example:

```text
PROTOTYPE

house = 7
sign = 7

both Number
```

Possible native sanding:

```text
House.seventh
Sign.scorpio
```

The astrology has not changed.

The connector has become harder to misuse.

---

# 0.9 Parity Level Must Be Declared Before Porting

Every manifest entry should state **what kind of sameness we are trying to prove**.

## Exact parity

Usually for Replicate.

```text
same input
same law
same output
```

## Structural parity

Often for Rehouse.

```text
same astrological truth
new owner / new data shape
```

## Behavioral parity

Often for Reproduce.

```text
same intended behavior
different implementation
```

## Retirement proof

For Retire.

```text
no required capability disappears

or

the capability has a new canonical owner
```

This prevents "looks about right" from becoming a migration standard.

---

# 0.10 Build the First Foundational Port Queue

Phase 0 does not have to classify the entire repository.

It should identify the initial manufacturing queue for Phase 1.

That queue should include at minimum:

```text
Ring

Mater

Tympan

Rulers

Ephemeris

AstroDNA

mundane / existing universal chronology

timespine temporal lessons

Loom

relevant tests and fixtures
```

For each, we should know enough to begin the later detailed 4R pass.

We should also identify obvious browser-only artifacts so they are not mistaken for production components:

```text
*.browser.js

window.__ORBO_...

standalone bundling glue

Capacitor wrapper mechanics
```

Those may still be useful for prototype comparison, but they are not presumed to have native counterparts.

---

# 0.11 Preserve the Prototype

Phase 0 should establish a **prototype freeze principle**, but not necessarily freeze the repository in the literal Git sense.

The prototype remains usable for:

```text
design experiments

behavior comparison

visual reference

interaction reference

fixture generation

archaeology

checking historical assumptions
```

But we stop putting new foundational production architecture into it.

A useful rule:

> **If the work is intended to become part of Orbo 1.0's permanent computational foundation, it belongs in native OrboCore.**

Prototype changes remain legitimate when they help us learn something, prove something, or preserve the reference implementation.

---

# 0.12 The Lab Notebook

Establish one simple running Phase 0 artifact:

```text
Native Port Ledger
```

This is not another giant architecture document.

It is the manufacturing record.

| Component | 4R | Native Owner | Parity | Status |
|---|---|---|---|---|
| Ring | Replicate | Ovum | Exact | Not Started |
| Mater | Replicate | Ovum | Exact | Not Started |
| Tympan | Replicate | Ovum | Exact | Not Started |
| Rulers | TBD | Ovum | TBD | Review |
| Ephemeris | TBD | Ovum / Forge | Astronomical | Review |
| AstroDNA | Rehouse | Ovum | Structural | Review |
| Orbo Spine ancestors | Reproduce/Rehouse | Ovum | Celestial | Review |
| Loom | Replicate/Rehouse | Ovum | Behavioral | Review |
| Prism | Rehouse | Synchronic Core | Mathematical | Later |

This table should grow as we work rather than requiring the whole universe to be classified on day one.

---

# 0.13 What Phase 0 Explicitly Does Not Do

Phase 0 could otherwise expand into a swamp.

Do **not** yet:

```text
port Ring

port the ephemeris

define final AstroDNA

build the Orbo Spine

build the Loom

build Connectome

build persistence

build onboarding

recreate the astrolabe

design rising-sign expressions

rewrite technique engines

move user data

retire the prototype
```

Those are subsequent phases.

Phase 0 prepares the bench.

---

# 0.14 Phase 0 Deliverables

At completion, we should possess:

## Native project

```text
Orbo
```

Launchable native iOS shell.

## Core package

```text
OrboCore
```

Independently compiling and testable.

## Development instrument

```text
OrboLab
```

Able to inspect OrboCore.

## Test infrastructure

```text
OrboCoreTests
golden fixtures
parity-fixture mechanism
integration test structure
```

## Native Port Manifest

The existing architectural map converted into component-by-component 4R manufacturing records.

## Foundational port queue

Enough archaeology completed to begin Phase 1A without reopening the question of what we are building.

---

# 0.15 Phase 0 Exit Gate

We do **not** enter Phase 1 merely because Xcode opens.

All of these should be true:

```text
[ ] The native Orbo project builds.

[ ] The native Orbo launches on iOS.

[ ] OrboCore builds independently.

[ ] OrboCore can run tests independently.

[ ] Orbo imports OrboCore.

[ ] OrboLab imports OrboCore.

[ ] OrboLab can expose development-only Core information.

[ ] The existing prototype remains intact and usable.

[ ] Production native work is clearly separated from prototype work.

[ ] The 4R process is represented in the port manifest.

[ ] Swift Sanding is represented in the port manifest.

[ ] Parity standards are represented in the port manifest.

[ ] The foundational Phase 1 component queue is identified.

[ ] The old map has been repurposed from migration wiring
    into a prototype-to-native manufacturing map.

[ ] No temporary Lab interface has accidentally been declared
    a production OrboCore API.

[ ] No foundational Swift component has been prematurely built
    before its port treatment and native owner are understood.
```

Then Phase 0 closes.

---

# The Handoff to Phase 1

Phase 0 ends with an empty bench that is no longer empty.

```text
ORBO
black native shell

ORBOCORE
ready

ORBOLAB
ready

TESTS
ready

4R MANIFEST
ready

PROTOTYPE
beside us

           ↓

PHASE 1
THE OVUM
```

Phase 1 begins with the first real part:

```text
Ring
```

We open `ring.js`, complete its individual 4R card, identify exactly what is law and what is JavaScript survival equipment, transpose it to Swift, put it in OrboLab, port its tests, prove parity, connect it to OrboCore, and declare it native canonical.

**Then, and only then, the next part gets placed on the bench.**

Phase 0 gives us structure without trying to solve Phase 1 prematurely, and it turns the prototype map into the thing we actually need now: a manufacturing manifest for the native Orbo.
