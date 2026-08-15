# Phase 0 - Living Traffic Map and Migration Ledger

**Status:** detailed Phase 0 planning document.

**Date:** 2026-08-15.

**Purpose:** define the archaeology-to-engineering handoff for the Orbo unified architecture. Phase 0 does not change runtime behavior. It establishes a trustworthy map of what the living organism does today, how information circulates through it, where truth is owned, how persisted artifacts are keyed, which tests pin current invariants, and what each load-bearing path must eventually do under the reconciled architecture.

This plan is subordinate to:

- `specs/Unified Architecture Plan - Ovum AstroDNA Embryo and Connectome.md`
- `specs/Bay Bridge Migration Rule.md`
- `specs/Living Engine Inventory - Pre-Spec Pass.md`

The governing question is:

> **What traffic is actually moving through Orbo today, and across which bridges?**

The output of Phase 0 must make Phase 1 concrete enough that the first celestial-state path can be moved behind the Ovum boundary without guessing.

---

# 0. Phase law

Phase 0 is observation, tracing, classification, and migration preparation.

During Phase 0:

```text
NO runtime refactors
NO ownership changes
NO renames in production code
NO cache or codec changes
NO persistence migrations
NO UI changes
NO deleting old paths
NO opportunistic cleanup
```

Diagnostic scripts or tests are allowed only when they observe the existing organism without changing its behavior.

The current implementation is the measuring instrument.

The Bay Bridge rule applies from the beginning:

```text
COPY
BUILD BESIDE
COMPARE
SWITCH
RETIRE
```

Phase 0 prepares the measurements required for that process. It does not begin the switch.

---

# 1. What Phase 0 must answer

For every load-bearing fact or component, Phase 0 must make it possible to answer:

```text
What produces it?
What does that producer depend on?
At what precision does it operate?
What shape leaves the producer?
Who consumes it?
Is it cached?
Is it persisted?
What key identifies it?
Is there a browser mirror?
Is there another copy or consumer in the standalone?
What tests prove it?
Does another engine independently derive the same fact?
What happens if we move it?
```

The final document is not merely a file inventory. It is a **traffic map**.

---

# 2. Phase 0 baseline

Before tracing individual systems, freeze what "current Orbo" means.

Record:

```text
repository commit
authoritative branch
current standalone build
internal build / version number
source modules used by standalone
browser/global mirrors used by standalone
current passing test counts
known failing tests, if any
persisted codec versions
generated artifacts currently shipping
```

The baseline should be written at the top of the completed census:

```text
PHASE 0 BASELINE

Git commit:
Standalone:
Internal build:
Date:
Tests:
Known failures:
Persisted codecs:
Generated shipped artifacts:
```

This creates a known reference state for every later parity comparison.

---

# 3. Celestial Authority Matrix

This is the highest-priority census because Phase 1 changes this boundary.

Phase 0 must find **every path capable of obtaining physical celestial information**.

Start at the ephemeris and trace outward.

Candidate areas include, but are not limited to:

```text
astrodna.js
live celestial cursor / live spine
framing.js
prism.js
transits.js
timespine.js
mundane.js
progressions.js
progressed-aspects.js
zr.js
electional.js
fertilize.js
loom.js
browser mirrors
standalone copies or adapters
```

A direct ephemeris dependency must not automatically be called a defect. Each use must be classified first.

Possible current roles include:

```text
actual competing sky door
internal astronomical utility
build-time generation
verification
legacy dependency
legitimate low-level AstroDNA encoding
injected provider source
```

For each path record:

```text
FILE / MODULE
API / FUNCTION
WHY IT TOUCHES CELESTIAL DATA
INPUT
OUTPUT
PRECISION
PHYSICAL STATE OR UTILITY?
CALLERS
CAN STATE ALREADY BE INJECTED?
SOURCE / BROWSER / STANDALONE FORM
TESTS
TARGET PHASE
```

The final matrix should look roughly like:

| Current caller | Gets astronomy from | Output | Precision | Consumers | Current role | Target classification |
|---|---|---|---|---|---|---|
| `astrodna.js` | ... | ... | ... | ... | ... | TBD |
| `transits.js` | ... | ... | ... | ... | ... | TBD |
| `timespine.js` | ... | ... | ... | ... | ... | TBD |

`TBD` is intentional until the actual code path has been inspected.

## 3.1 Control case: `fertilize.js`

The current `fertilize.js` already demonstrates a useful separation:

- it does not scan;
- Loom scans;
- it receives celestial probe functions;
- it owns span, chunking, packing, materialization, and read cuts.

Phase 0 must trace where those injected probes ultimately come from and where their output goes.

The file should be treated as an architectural ancestor, not assumed to be the final fertilization contract.

---

# 4. AstroDNA Circulation Map

AstroDNA is the universal celestial encoding language in the reconciled architecture.

Phase 0 must trace AstroDNA end to end as a packet moving through the living system.

Find every place AstroDNA is:

```text
created
encoded
decoded
projected
serialized
cached
used as identity
reconstructed
derived
passed into another engine
stored persistently
mirrored into browser/global form
consumed by the standalone
```

For every path record:

```text
producer
inputs
twelve-node order
native vs arbitrary moment
precision entering producer
precision leaving producer
direction encoding
sequence representation
degree projection
cache-key projection
serialization
consumer
```

The central precision law is:

> **Maximum-fidelity AstroDNA is authoritative. Coarser representations are deliberate projections whose validity depends on the truth being stored.**

Therefore Phase 0 must explicitly distinguish:

```text
AUTHORITATIVE ASTRODNA
fine / arcsecond-level state

PROJECTION
whole-degree representation

PROJECTION
sign representation

CACHE IDENTITY
a named cut at the resolution the artifact actually requires
```

The current `fertilize.js` distinction between the fine genome and a coarser degree-sequence cache key should be recorded as an explicit traffic-map example rather than left buried in comments.

## 4.1 Deliverable

A living flow diagram such as:

```text
ephemeris / current provider
   ↓
AstroDNA producer
   ↓
fine AstroDNA
   ├── consumer A
   ├── degree projection → cache X
   ├── sign projection → Expression
   ├── derived operation → ...
   └── persistence → ...
```

The diagram must describe the current implementation, not the desired one.

---

# 5. Structural Ownership Matrix

Trace the current ownership of inherent and expressed astrological structure.

Required areas:

```text
Ring
Mater
Tympan
Rulers
Dispositor
connectome.js
```

For each structural fact ask:

```text
Who currently owns it?
Who imports that owner?
Is anyone re-deriving it?
At what resolution can it change?
Is it immutable?
Is it cached?
Which tests pin it?
```

The census should distinguish:

```text
INHERENT CONNECTOME LAW
Ring / Mater / Tympan / Rulers

CURRENT EXPRESSION
sign-stay Connectome / Dispositor

FUTURE EXPRESSION
gene nodes / relation edges / motion / Lots / Forged Ring
```

Phase 0 does not build the future expression. It determines exactly what traffic the current sign-stay Expression already carries so the restored Connectome cannot accidentally discard it.

Example matrix:

| Fact | Current owner | Resolution | Re-derived elsewhere? | Consumers | Tests | Future action |
|---|---|---|---|---|---|---|
| sign rulership | Mater | sign | ? | ? | ? | TBD |
| bound | Rulers | pointwise | ? | ? | ? | TBD |
| keeper | Connectome | sign-stay | ? | ? | ? | TBD |
| aspect | ? | relational | ? | ? | ? | TBD |

---

# 6. Temporal Traffic Map

Orbo currently contains several systems that manipulate, search, derive, or index time.

Required areas include:

```text
live celestial cursor
Orbo Spine ancestors / mundane temporal substrate
timespine.js
mundane.js
transits.js
loom.js
fertilize.js
luna.js
framing.js
prism.js
progressions.js
progressed-aspects.js
zr.js
electional.js
```

Each must be classified by its actual **job**, not by the feature that currently owns it.

Useful job labels are:

```text
CURSOR
moves to a celestial address

STATE PROVIDER
resolves a celestial configuration

SOLVER
finds a time satisfying a condition

INDEX
stores temporal hinges

WINDOW / INTERVAL DERIVER
describes an interval during which a condition remains true

TRANSFORMATION
derives another AstroDNA

TECHNIQUE
asks a doctrine-specific astrological question
```

A living file may currently perform more than one job. That is important evidence.

For every temporal engine record:

```text
Does it scan?
Does it root-find?
Does it directly read ephemeris?
Does it use injected probes?
Does it return AstroDNA?
Does it return raw positions?
Does it return events?
Does it return intervals?
Does it own persistence?
Does it define a cache codec?
Does it recompute something another engine already knows?
```

## 6.1 Deliverable

A current-system map such as:

```text
CURRENT LIVE CURSOR
       │
       ├── consumer ...
       └── probe ...

TIMESPINE.JS
       │
       ├── builds ...
       ├── stores ...
       └── consumers ...

LOOM
       │
       ├── inputs ...
       └── outputs ...

FERTILIZE
       │
       ├── calls Loom
       ├── materializes ...
       └── persists ...
```

The later Cursor / Loom / Spine separation must be derived from this census rather than imposed before inspection.

---

# 7. Derived AstroDNA Matrix

Create one census specifically for complete configurations that are not simply the physical sky at the requested address.

Trace every living implementation of:

```text
composite
synchronic / refract
progressed
progressed composite, if living
other derived-state constructors
```

For each operation record:

```text
owner
parents
algorithm
output shape
precision
horizon treatment
sect treatment
whether output is AstroDNA
whether result gets Connectome expression
whether result is persisted
callers
other routes producing equivalent states
```

Example:

| Operation | Current owner | Inputs | Output shape | Consumers | Duplicate path? |
|---|---|---|---|---|---|
| composite | ... | ... | ... | ... | ... |
| synchronic | ... | ... | ... | ... | ... |
| progressed | ... | ... | ... | ... | ... |

This is inventory only. The actual operation-family reconciliation belongs to later phases.

---

# 8. Persistence and Cache Ledger

Persisted artifacts are traffic already parked on the current bridge.

Inventory every user-specific or expensive structure that survives runtime, including where applicable:

```text
my AstroDNA / natal data
saved charts
Pins / memory
Ledger entries
Favorites
fertilized weaves
TimeSpine materialization
Connectome Expressions
ZR caches
progression caches
Almanac saved data
Journal ancestors
settings that affect celestial computation
```

For every artifact record:

```text
OWNER
STORAGE
SHAPE
KEY
CODEC / VERSION
PRECISION OF KEY
REBUILDABLE?
USER-AUTHORED?
CAN BE LAZILY REMINTED?
MUST NEVER BE LOST?
SOURCE / BROWSER / STANDALONE PATH
```

Every artifact must be classified as one of:

```text
DERIVED / REBUILDABLE

USER DATA / IRREPLACEABLE

MIXED
derived celestial snapshot + authored meaning
```

The current Pin / `state.memory` system is an ancestor of Crystal persistence and must be treated as existing user traffic, not as disposable scaffolding.

---

# 9. Runtime Mirror Matrix

Source modules, browser mirrors, and the standalone executable are different physical representations of one product.

For every load-bearing engine identify:

```text
source file
browser mirror
generation / build mechanism
standalone copy or reference
which representation the executable actually runs
```

Example matrix:

| Engine | Source | Browser mirror | Standalone consumer | How synchronized | Test |
|---|---|---|---|---|---|

Any manual-copy seam should be flagged prominently.

Phase 0 does not fix the seam. It makes sure later phases cannot accidentally migrate only one representation.

A consumer is not considered migrated in later phases if source uses one architecture while the shipped browser/standalone runtime still uses another.

---

# 10. Invariant / Test Ledger

Tests are architecture.

For every load-bearing truth identify the test that proves it.

Record:

```text
INVARIANT
OWNER
TEST
COMPARISON TYPE
MIGRATION VALUE
```

Example:

```text
INVARIANT
zero is a valid conjunction

OWNER
Ring

TEST
tests/ring.test.html

TYPE
exact equality

MIGRATION VALUE
must pass on replacement
```

Classify coverage as:

```text
STRONG
direct invariant test

INDIRECT
behavior happens to exercise it

MIRRORED
test duplicates implementation rather than exercising the real owner

ABSENT
nothing currently proves it
```

The final invariant ledger becomes an ancestor of the later Resonator system.

---

# 11. Consumer Dependency Graph

The most important visualization at the end of Phase 0 is a diagram of the **living system**, not the desired system.

It should show actual current edges, for example:

```text
              CURRENT REALITY

ephem
 ├────> astrodna
 ├────> framing
 ├────> prism
 ├────> transits
 ├────> timespine
 └────> ...

live cursor
 ├────> ...
 └────> probe
          ├────> Loom
          └────> fertilize

AstroDNA
 ├────> Connectome
 ├────> ...
 └────> persistence

Ring
 ├────> ...
Mater
 ├────> ...
```

If the living diagram is ugly, that is useful information.

Phase 0 must not redraw the desired architecture and label it current.

---

# 12. Canonical component row

Every load-bearing component should eventually have one canonical row in the migration ledger.

Use this schema:

```text
COMPONENT

CURRENT OWNER
file / module

ROLE
what it actually does today

INPUTS

OUTPUTS

RESOLUTION / PRECISION

UPSTREAM AUTHORITY

CALLERS / CONSUMERS

PERSISTENCE

CACHE KEY / CODEC

SOURCE MIRROR

BROWSER MIRROR

STANDALONE CONSUMER

TESTS

DUPLICATED FACTS

TARGET OWNER
from Unified Architecture

MIGRATION CLASS
PRESERVE / RELOCATE / EXPAND / REPLACE / RETIRE

DEPENDENCIES

RISK

PHASE
when it moves
```

This row is the Rosetta Stone for later implementation work.

---

# 13. Migration classifications

Once the census is complete, every load-bearing current behavior receives one Bay Bridge disposition:

```text
PRESERVE
current behavior is canonical

RELOCATE
behavior stays materially the same but ownership moves

EXPAND
current behavior remains a valid subset of a broader architecture

REPLACE
current contract is intentionally superseded

RETIRE
behavior is duplicate, accidental, obsolete, or no longer legitimate
```

Do not classify from intuition before inspecting callers.

Likely examples may include:

```text
current sign-stay Connectome
likely EXPAND

direct application ephemeris access
likely RELOCATE or RETIRE

Pin storage
likely EXPAND / MIGRATE into Crystal

Loom solver concept
likely PRESERVE with input ownership changes

fertilize.js semantics
likely EXPAND / RECONCILE

duplicate TimeSpine naming
likely REPLACE / RENAME later
```

These remain hypotheses until the census proves them.

---

# 14. Inspection order

Perform the census from authority outward.

Recommended order:

```text
1. AstroDNA
2. ephemeris
3. live celestial cursor
4. Orbo Spine ancestors / mundane temporal substrate
5. Ring / Mater / Tympan / Rulers
6. Connectome / Dispositor
7. Loom
8. timespine / transits / fertilize / Luna
9. framing / Prism / synchronic paths
10. progressions / progressed aspects / composites
11. Zodiacal Releasing
12. electional
13. persistence / Pin / Ledger / Favorites
14. browser mirrors
15. standalone wiring
16. tests
```

Why this order:

- establish what AstroDNA currently is before tracing its consumers;
- establish who can manufacture physical sky before studying temporal caches;
- establish current Connectome ownership before designing restoration;
- only then trace higher-order techniques and user-memory structures.

This prevents Phase 0 from degenerating into arbitrary repository wandering.

---

# 15. The Phase 0 master record

Phase 0 should remain centralized in this document rather than scattering the census across many new specs.

As the census is performed, expand this file into:

```text
0. Baseline
1. Celestial authority
2. AstroDNA circulation
3. Connectome law + expression
4. Temporal machinery
5. Derived AstroDNA
6. Persistence + caches
7. Source / browser / standalone mirrors
8. Tests + invariants
9. Consumer dependency graph
10. Migration ledger
11. Phase 1 handoff
```

If the matrices eventually become too large or need machine analysis, a structured companion artifact may be justified later. Do not invent another architecture database unless the census demonstrates the need.

The existing `Living Engine Inventory - Pre-Spec Pass.md` remains source material. Do not rewrite it into this document. This Phase 0 record adds the thing the earlier inventory could not have had: **a migration disposition against the now-settled Unified Architecture.**

---

# 16. Exit gates

Phase 0 is complete only when all of these are true.

## Gate 0.1

Every direct ephemeris consumer has been found and classified.

## Gate 0.2

Every complete physical celestial-state production path is traceable from request to consumer.

## Gate 0.3

Every AstroDNA creation, encoding, decoding, projection, serialization, and identity path is mapped.

## Gate 0.4

Ring, Mater, Tympan, Rulers, Dispositor, and current Connectome ownership are mapped down to their consumers.

## Gate 0.5

Cursor, Loom, TimeSpine, transits, fertilize, mundane, progression, ZR, and synchronic temporal responsibilities are distinguished by actual job.

## Gate 0.6

Every persisted artifact has an owner, shape, key, codec/version, and rebuild/data-loss classification.

## Gate 0.7

Every load-bearing source/browser/standalone mirror relationship is known.

## Gate 0.8

Every canonical current behavior intended to survive has a known test, or is explicitly marked as having no direct test.

## Gate 0.9

Every load-bearing current path has a migration disposition:

```text
PRESERVE
RELOCATE
EXPAND
REPLACE
RETIRE
```

## Gate 0.10

The exact first consumers that Phase 1 will move behind the Ovum boundary are known, and the order can be justified from dependencies and risk.

---

# 17. Phase 1 handoff

The final Phase 0 handoff must not say merely:

```text
Build the Ovum.
```

It must be able to say something closer to:

```text
These are every living path that currently obtains celestial state.

These are their contracts.

These are their consumers.

These are the mirrors and persistence obligations attached to them.

These are the tests that prove their current behavior.

These are the paths that can move first.

This is why that order is safe.

This is how parity will be measured.
```

At that point Phase 1 is no longer speculative architecture. It is a controlled traffic migration.

---

# 18. Governing phrases

> **Phase 0 maps the bridge before Phase 1 moves the traffic.**

> **Describe the living organism, not the organism we wish were already there.**

> **No current behavior becomes obsolete merely because the new architecture is prettier. Inspect first, classify second.**

> **Tests are architecture. Persistence is parked traffic. Browser mirrors are part of the bridge.**

> **The output of Phase 0 is certainty about where to make the first cut.**
