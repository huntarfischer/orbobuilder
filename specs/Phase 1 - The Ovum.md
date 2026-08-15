# Phase 1: The Ovum

**Status:** Native OrboCore foundation phase for Orbo 1.0.

**Purpose:** Build the complete native-independent celestial organism that every copy of Orbo possesses before it knows a native.

Phase 1 begins with the native laboratory established in Phase 0.

It ends with a sealed **Ovum** capable of taking a supported human celestial address, resolving its terrestrial and temporal coordinates, reading the versioned celestial chronology, constructing the local horizon, and producing canonical AstroDNA without relying on an external service or querying the ephemeris during normal runtime.

At the end of Phase 1:

> **Orbo knows the heavens, the Earth beneath them, and how to locate any supported moment within both.**

It does not yet know which AstroDNA is **my AstroDNA**.

That is fertilization.

---

# 1.0 Governing Definition

The Ovum is Orbo's complete **unpersonalized walled garden**.

It contains everything required to answer:

```text
Given this date,
this clock time,
and this place,

what is the AstroDNA?
```

Conceptually:

```text
┌────────────────────────── ORBO OVUM ──────────────────────────┐
│                                                              │
│  INHERENT LAW                                                │
│  Ring                                                        │
│  Mater                                                       │
│  Tympan                                                      │
│  Rulers                                                      │
│                                                              │
│  TERRESTRIAL ADDRESS                                         │
│  Geoplacement Atlas                                          │
│  place resolution                                            │
│  latitude / longitude                                        │
│  timezone jurisdiction                                       │
│                                                              │
│  CIVIL TIME                                                  │
│  calendar / timezone history                                 │
│  local time → absolute time                                  │
│                                                              │
│  CELESTIAL CHRONOLOGY                                        │
│  Orbo Spine                                                  │
│                                                              │
│  HORIZON                                                     │
│  Earth / horizon geometry                                    │
│                                                              │
│  CELESTIAL IDENTITY                                          │
│  AstroDNA contract                                           │
│  AstroDNA encoder / resolver                                 │
│                                                              │
│  TEMPORAL SOLVING                                            │
│  Loom                                                        │
│                                                              │
│  INTEGRITY                                                   │
│  Resonator                                                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

The ephemeris is used to **forge and verify** the Orbo Spine.

It is not the normal runtime celestial door.

---

# 1.1 The Complete Celestial Address

There is no complete AstroDNA without place.

AstroDNA does not represent merely:

```text
sky at time t
```

It represents a celestial configuration crystallized at:

```text
TIME
+
PLACE
```

A human supplies something like:

```text
April 10, 1985
8:16 PM
Madison, Wisconsin
```

The Ovum resolves that into:

```text
absolute time
latitude
longitude
```

That computational coordinate is the **celestial address**.

```text
HUMAN ADDRESS

local date
local clock time
place

      ↓

GEOPLACEMENT
+
CIVIL TIME

      ↓

CELESTIAL ADDRESS

absolute time
latitude
longitude

      ↓

ORBO SPINE
+
HORIZON

      ↓

ASTRODNA
```

This is why Geoplacement belongs inside the Ovum.

Without it, the Ovum cannot independently produce AstroDNA from the form in which a human actually supplies a celestial address.

---

# 1.2 The Offline Ovum Test

A finished Ovum should pass a simple conceptual test:

> **Can an unfertilized Orbo, completely offline, take a supported date, clock time, and place and produce the correct AstroDNA?**

For supported input, the answer should not require:

```text
external geocoder
external timezone lookup
external ephemeris query
web service
user account
native profile
```

The Ovum ships already knowing enough of the heavens and Earth to perform the calculation.

---

# 1.3 The Ephemeris and Spine Law

The distinction between the ephemeris and the Orbo Spine is foundational.

## Ephemeris

The ephemeris is the **forge**.

Its jobs are:

```text
calculate
generate
verify
compare
extend
repair
```

It is used upstream to construct celestial chronology.

## Orbo Spine

The Orbo Spine is the **versioned celestial substrate** that ships with Orbo and is read during normal operation.

```text
EPHEMERIS
     ↓
SPINE FORGE
     ↓
ORBO SPINE vN
     ↓
ships with Orbo
     ↓
runtime celestial reads
```

Therefore normal Orbo runtime should not quietly do this:

```text
request
   ↓
ephemeris
```

It should do:

```text
request
   ↓
Orbo Spine
```

The existence of the Spine is precisely what removes routine ephemeris querying from the living instrument.

---

# 1.4 The Spine Is Not Merely an Event Table

Prototype Orbo already contains ancestors of the native Spine, but the production object must answer a broader question:

```text
What is the celestial state at this supported time?
```

Therefore Orbo Spine v1 must contain enough information to reconstruct the celestial state required by AstroDNA across its supported range.

It may also carry indexes for universal hinges such as:

```text
ingresses
stations
retrograde periods
lunations
eclipses
aspect perfections
other admitted celestial events
```

But those event indexes are **indexes over the chronology**.

They are not the chronology itself.

The physical representation is not predetermined.

Candidate approaches might include:

```text
samples
segments
interpolation coefficients
knots
compressed runs
event indexes
hybrid representations
```

We choose by measurement.

The governing question is:

> **What is the smallest, fastest versioned representation that reproduces the required celestial state at Orbo's declared fidelity?**

---

# 1.5 Construction Method

Phase 1 remains piece by piece.

```text
A
✓ prove A

A + B
✓ prove A + B

A + B + C
✓ prove A + B + C

then D
```

Every component receives:

```text
4R assessment
native contract
Swift Sanding
Lab exposure
tests
prototype/reference comparison
integration proof
```

before becoming native canonical.

Phase 1 is not complete when all the individual organs exist.

It is complete when they form a proven Ovum.

---

# 1.6 Native Domain Language

First establish the minimum native vocabulary needed to keep unlike things unlike.

Likely candidates include:

```text
Planet
Sign
House
Motion

CelestialLongitude
GeographicLongitude
Latitude

JulianDay
CivilDate
CivilTime

Place
TimezoneIdentifier
CelestialAddress
```

Not every primitive gets wrapped.

A distinct type is justified when confusing two values could create a meaningful Orbo error.

For example:

```text
Sign.scorpio
```

must not be casually interchangeable with:

```text
House.eighth
```

even if prototype code once represented both with integers.

Likewise:

```text
21° celestial longitude
```

and:

```text
89° west geographic longitude
```

should not fit the same socket accidentally.

### Gate

The vocabulary is strong enough to begin native construction without recreating JavaScript's most dangerous category ambiguities.

---

# 1.7 Ring

**Expected 4R:** Replicate.

Ring is the first true production component.

It is:

```text
native-independent
time-independent
place-independent
import-independent
```

Transpose its law faithfully:

```text
degree geometry
the admitted marks
state encoding
fine-state encoding
target relations
exact relationship lookup
nearest relation
projection behavior
error / absence contracts
```

## Swift Sanding

Where appropriate:

```text
anonymous Number → meaningful numeric types
runtime Bool validation → Bool
Object.freeze → immutable Swift values
null/undefined → explicit optional
browser mirror → retired
```

### Proof

Use exhaustive and golden tests wherever practical.

### Exit

Ring becomes:

```text
NATIVE CANONICAL
```

Nothing later in native Orbo asks JavaScript Ring for an answer.

---

# 1.8 Mater

**Expected 4R:** Replicate.

Transpose Orbo's inherent zodiacal structure:

```text
twelve signs
elements
modalities
traditional rulers
classical dispositor set
exaltations
exaltation degrees
detriments
falls
```

This remains universal.

No native.

No moment.

No place.

No interpretation prose.

### Gate

Every inherent relationship agrees with the prototype's proven tables.

---

# 1.9 Tympan

**Expected 4R:** Replicate.

Transpose:

```text
twelve whole-sign frames
sign → house
house → sign
houses ruled by traditional governor
separate modern co-rulership
frame records
flip-house law
```

Swift should strongly preserve the distinction between:

```text
Sign
```

and:

```text
House
```

rather than relying on remembered index conventions.

### Gate

Every frame round-trips.

Every house appears once.

Every sign appears once.

Traditional and modern governance remain structurally separated.

---

# 1.10 Rulers and Remaining Inherent Law

Perform a focused 4R pass on `rulers.js` and related doctrine tables.

The purpose is not to preserve a filename.

The purpose is to identify the canonical native owner of every remaining inherent rulership or dignity fact.

Possible outcomes:

```text
Replicate some material
Rehouse some into Mater
Rehouse some into Tympan
retain a smaller Rulers component
retire duplicated tables
```

### Core law

> **One inherent fact, one maintained owner.**

If Mater already owns it, Rulers does not own a second version.

If Tympan owns it, a reader does not recompute it independently.

### Gate

No inherent rulership/dignity fact exists in competing native tables.

---

# 1.11 Geoplacement Atlas

Now build the terrestrial address knowledge with which every Ovum ships.

The Geoplacement Atlas is not astrology.

It is part of the Ovum because AstroDNA requires a location.

Its job is to resolve a human place into a canonical terrestrial coordinate.

```text
"Madison, Wisconsin"
        ↓
Geoplacement Atlas
        ↓
canonical place record
        ↓
latitude
longitude
timezone jurisdiction
```

## The Atlas may contain

```text
place name
canonical name
alternate names
region
country
latitude
longitude
timezone identifier
search/ranking information
```

The exact schema is determined during the 4R/data-design pass.

## City dataset migration

This is where the compact city/location dataset work belongs.

We determine:

```text
what current Orbo already has
what should be migrated
what better dataset may replace it
what indexing/search structure Swift should use
what the offline size should be
```

The user-facing city search need not be visually implemented yet.

OrboLab only needs a boring place lookup.

Example:

```text
SEARCH
Madison

RESULT
Madison, Wisconsin, United States

LAT
...

LON
...

TZ
America/Chicago
```

## Versioning

The Geoplacement Atlas should be independently versionable.

```text
GEOPLACEMENT ATLAS vN
```

because terrestrial reference data and celestial chronology are different authorities.

### Gate

Supported place names resolve offline to stable coordinates and timezone identities.

Ambiguity is surfaced rather than guessed.

---

# 1.12 Civil Time and Timezone History

A latitude and longitude are not sufficient if the human supplied a **local clock time**.

The Ovum must turn:

```text
April 10, 1985
8:16 PM
Madison, Wisconsin
```

into an absolute instant.

That requires the civil-time rules in force for that place and date.

```text
local date
local clock time
timezone jurisdiction
historical timezone rules

        ↓

absolute time / Julian Day
```

This subsystem must handle the date ranges Orbo claims to support.

Relevant issues include:

```text
standard offsets
daylight saving transitions
historical offset changes
ambiguous local times
nonexistent local times
calendar conversion
```

The point is not to make Orbo a general calendrical encyclopedia.

The point is to make its celestial addresses correct.

### Core distinction

```text
PLACE RESOLUTION
where?

CIVIL TIME RESOLUTION
when, absolutely?

HORIZON
what was rising there then?
```

These are different operations.

### Gate

Known historical and modern civil addresses resolve to correct absolute instants.

---

# 1.13 AstroDNA Contract

Now define exactly what the Ovum must emit.

This happens **before the physical Orbo Spine format is frozen**, because the Spine must reproduce everything AstroDNA requires.

Settle:

```text
canonical genes
canonical gene order
positional precision
direct / retrograde representation
what motion belongs to identity
what horizon component is required
what is encoded versus derived
what projections exist
what does not belong in AstroDNA
```

The governing law remains:

> **AstroDNA is the universal maximum-useful-fidelity encoding of a complete celestial configuration.**

And:

> **There is no AstroDNA without time and place.**

AstroDNA is not:

```text
ephemeris output
+
a giant bag of derived astrology
```

It is celestial identity.

Sign meaning, house relationships, aspects, dispositorships, Lots, aggregates and other structural expression belong downstream unless the contract proves otherwise.

### Canonical order

Order must be explicit and structural.

Never depend on dictionary order.

### Gate

We can state exactly what information the Spine and Horizon must supply for the AstroDNA encoder to produce a valid genome.

---

# 1.14 Ephemeris Forge

Bring the astronomical source into native construction.

The ephemeris itself receives a 4R assessment.

Determine:

```text
current algorithm accuracy
required Orbo accuracy
supported temporal range
body-by-body limitations
which code is astronomy
which code is horizon geometry
which algorithms survive
whether a different production source is needed
```

## Boundary

The Forge provides celestial mechanics for:

```text
Spine generation
Spine verification
golden fixtures
future Spine extensions
```

It does not become a normal application runtime provider.

Conceptually:

```text
EphemerisKernel
```

defines what a qualifying Forge source must be able to provide.

The implementation remains replaceable behind that boundary.

### Gate

We know what astronomical source will forge Orbo Spine v1 and exactly what accuracy claim we are willing to make for it.

---

# 1.15 Spine Forge

Build the machinery that compiles the approved astronomical source into the shipped versioned chronology.

```text
Ephemeris
     ↓
Spine Forge
     ↓
Orbo Spine v1
```

The Forge determines, through measured engineering:

```text
temporal segmentation
state representation
interpolation
packing
compression
event indexes
checksums
version metadata
range metadata
```

The Forge should be deterministic where feasible.

Same:

```text
source
range
precision policy
codec
constants
```

should produce the same artifact.

### Prototype lessons worth preserving

Older temporal systems already discovered valuable engineering techniques:

```text
chunked generation
overlap across seams
event identity deduplication
phase-locked scans
sorted temporal reads
materialize expensive truths once
derive cheap truths later
```

Each survives only where still appropriate to the new Spine.

---

# 1.16 Orbo Spine v1

Forge the first production candidate.

The Spine must identify itself.

Conceptually:

```text
spine version
codec version
astronomical source version
supported range
precision contract
indexed event families
checksum
```

Then test it aggressively against the Forge.

For many times `t`:

```text
EPHEMERIS
    ↓
reference celestial state
```

must agree with:

```text
ORBO SPINE
    ↓
runtime reconstructed state
```

at the declared fidelity.

Test:

```text
random times
known natal moments
ingress boundaries
stations
retrograde changes
0/360 wrap
fast Moon
slow Pluto
beginning of supported range
end of supported range
historical dates
future dates
```

If the Spine cannot reproduce the required state, its physical representation changes.

The fidelity contract does not bend to protect the chosen storage format.

### Gate

Orbo Spine v1 is good enough to replace normal runtime planetary ephemeris queries across the claimed range.

---

# 1.17 Horizon Geometry

Now create the local celestial horizon.

The Orbo Spine remains geographically universal.

The Horizon Resolver combines:

```text
absolute time
latitude
longitude
```

to derive the required Earth/horizon geometry.

Potential outputs include:

```text
Ascendant
MC
IC
Descendant
Vertex
other required angles
```

according to the final AstroDNA contract.

The Horizon Resolver:

```text
does not query planetary ephemeris
does not know a native
does not interpret
does not belong to Prism
does not search cities
```

Its input has already been resolved.

### Proof

Test across:

```text
equatorial locations
high latitudes
east/west longitudes
date boundaries
known natal charts
known angle fixtures
historical dates
future dates
```

### Gate

The local horizon can be produced from the celestial address independently of planetary ephemeris access.

---

# 1.18 AstroDNA Encoder and Ovum Resolver

Now assemble the full chain.

```text
HUMAN CELESTIAL ADDRESS

date
clock time
place

        ↓

Geoplacement Atlas
Civil Time Resolver

        ↓

CELESTIAL ADDRESS

absolute time
latitude
longitude

        ↓
        ├──────────────────────┐
        ▼                      ▼

   ORBO SPINE             HORIZON
 universal state          local state

        └──────────┬───────────┘
                   ▼

            ASTRODNA ENCODER

                   ↓

               ASTRODNA
```

This is the central production capability of the unfertilized Orbo.

Conceptually:

```text
Ovum.resolve(...)
→ AstroDNA
```

The exact public Swift API is implementation work.

## Reference parity

The Lab should compare:

```text
REFERENCE PATH

place + civil time
      ↓
ephemeris + horizon
      ↓
AstroDNA
```

against:

```text
PRODUCTION PATH

place + civil time
      ↓
Geoplacement + Civil Time
      ↓
Orbo Spine + Horizon
      ↓
AstroDNA
```

The resulting AstroDNA must agree at the declared fidelity.

### OrboLab readout

```text
ORBO LAB

INPUT
April 10, 1985
8:16 PM
Madison, Wisconsin

GEOPLACEMENT
canonical place:
latitude:
longitude:
timezone:

CIVIL TIME
offset:
absolute instant:
Julian Day:

ORBO SPINE
version:
state:

HORIZON
Ascendant:
MC:
...

ASTRODNA
Ascendant:
Moon:
Sun:
Mercury:
...
```

Now we have a real instrument, even though it still looks like a terminal.

---

# 1.19 Loom

The Loom lives inside the Ovum.

Its job is:

> **Find where or when a celestial condition becomes true.**

Its runtime target is the Orbo Spine.

```text
target
   ↓
Loom
   ↓
Orbo Spine
   ↓
crossing / interval / coordinate
```

For horizon-dependent targets:

```text
target
   ↓
Loom
   ↓
Orbo Spine time axis
+
Horizon Resolver
   ↓
crossing
```

No ephemeris query is necessary.

## Loom owns

```text
root finding
crossing detection
boundary solving
temporal intervals
celestial target search
```

## Loom does not own

```text
interpretation
desirability
electional judgment
Horary judgment
career meaning
relationship meaning
```

Those systems determine **what target matters**.

The Loom determines **when it occurs**.

## 4R expectation

The existing Loom's scanner is a strong Replicate/Rehouse candidate.

Its target solving survives.

Any decoration that attaches structural astrology or reader vocabulary should be rehoused.

### Gate

Loom can find known:

```text
ingresses
stations
planetary crossings
aspects
sign boundaries
horizon crossings
```

through canonical Ovum machinery alone.

---

# 1.20 Resonator

The Ovum now gets its fidelity pass.

The Resonator is a checker, never another source of celestial truth.

During build/testing it can compare:

```text
Ephemeris ↔ Orbo Spine

Geoplacement ↔ place fixtures

Civil Time ↔ historical timezone fixtures

Horizon ↔ angle fixtures

AstroDNA ↔ known genomes

Ring ↔ geometry fixtures

Loom ↔ known crossings

Mater / Tympan / Rulers ↔ canonical tables
```

At runtime it may also inspect:

```text
Spine checksum
Spine version
Geoplacement version
codec compatibility
structural invariants
```

The Resonator cannot restore information the source never contained.

It detects drift.

It does not manufacture fidelity.

---

# 1.21 Seal the Ovum

After the organs are proven together, make the wall real in Swift.

Production code outside the Ovum should not casually access:

```text
ephemeris machinery
Spine Forge internals
raw Spine storage
timezone tables
raw horizon internals
Loom sampling internals
```

It should receive sanctioned capabilities and results.

For example, conceptually:

```text
resolve human celestial address
→ AstroDNA

resolve computational celestial address
→ AstroDNA

search celestial condition
→ coordinate / AstroDNA
```

The exact API waits until implementation proves the appropriate mating surfaces.

## OrboLab exception

OrboLab may retain privileged access to construction internals:

```text
raw ephemeris
raw Spine state
Spine/reference difference
place records
timezone resolution
horizon values
encoded genome
Loom roots
Resonator reports
```

Lab access does not define the product API.

---

# 1.22 The Completed OrboLab

By Phase 1 completion, OrboLab should be able to demonstrate the entire unfertilized organism.

```text
ORBO LAB

HUMAN ADDRESS
date
time
place

GEOPLACEMENT
canonical place
latitude
longitude
timezone

CIVIL TIME
absolute time
Julian Day

ORBO SPINE
version
coverage
codec
checksum

CELESTIAL STATE
Sun
Moon
Mercury
Venus
Mars
...

HORIZON
Ascendant
MC
...

ASTRODNA
canonical ordered genome

LOOM
target
previous crossing
next crossing

RESONATOR
all checks

TESTS
PASS
```

This is the Ovum with its shell removed.

---

# 1.23 What Phase 1 Does Not Build

Phase 1 remains completely pre-native.

It does **not** yet build:

```text
my AstroDNA
fertilization
rectification logic
rectification questions
native profile
full expressed Connectome
personal transit spine
Synchronic Spine
Synchronic Clock
Prism
Profiles
Fields
Crystals
Threads
Journal
Favorites
Horary judgment
electional judgment
interpretation
astrolabe UI
Lunar Pane
Tabulas
Expression System
```

A useful test is:

> **Would this thing still exist if nobody had ever installed Orbo?**

If yes, it may belong in the Ovum.

If it requires **this particular native**, it belongs later.

---

# 1.24 Phase 1 Deliverables

Phase 1 produces a complete native-independent celestial organism:

```text
NATIVE DOMAIN LANGUAGE

RING
canonical geometry

MATER
canonical zodiacal structure

TYMPAN
canonical whole-sign frames

RULERS
remaining inherent dignity/rulership law

GEOPLACEMENT ATLAS
offline place resolution

CIVIL TIME RESOLVER
historical local time → absolute time

ASTRODNA CONTRACT
canonical celestial identity

EPHEMERIS FORGE
upstream astronomical source

SPINE FORGE
celestial compilation machinery

ORBO SPINE v1
versioned shipped celestial chronology

HORIZON RESOLVER
place-dependent celestial geometry

OVUM RESOLVER
human address → AstroDNA

LOOM
temporal solving

RESONATOR
fidelity and invariant checking
```

---

# 1.25 Phase 1 Exit Gate

Phase 2 does not begin merely because AstroDNA can be printed.

The entire organism must pass.

```text
[ ] Native domain types protect important category boundaries.

[ ] Ring is native canonical.

[ ] Ring passes exact prototype/golden parity.

[ ] Mater is native canonical.

[ ] Tympan is native canonical.

[ ] Rulership and dignity facts have one canonical owner.

[ ] Traditional rulership and modern co-rulership remain
    structurally separate where required.

[ ] Geoplacement Atlas resolves supported places offline.

[ ] Ambiguous place names are surfaced rather than silently guessed.

[ ] Geoplacement data is versioned.

[ ] Civil Time correctly resolves supported historical and modern
    local times to an absolute instant.

[ ] Timezone ambiguity and nonexistent civil times have explicit behavior.

[ ] AstroDNA has an explicit canonical gene order.

[ ] AstroDNA precision is explicit.

[ ] AstroDNA direction/motion identity rules are explicit.

[ ] AstroDNA requires time and place.

[ ] Derived astrological expression has not been smuggled into AstroDNA.

[ ] The astronomical source used to forge Orbo Spine v1 is known.

[ ] Its supported range and accuracy are documented.

[ ] Spine Forge reproducibly generates the versioned artifact.

[ ] Orbo Spine declares version, codec, range and fidelity.

[ ] Orbo Spine agrees with the Forge reference across the
    supported domain at declared fidelity.

[ ] Boundary tests pass around ingresses, stations,
    retrograde changes and 0/360 wrap.

[ ] Fast bodies meet the fidelity requirement.

[ ] Slow bodies meet the fidelity requirement.

[ ] Horizon geometry operates from absolute time + place.

[ ] Horizon geometry does not query planetary ephemeris.

[ ] Known horizon fixtures pass.

[ ] A supported human date/time/place resolves to a
    canonical celestial address.

[ ] That celestial address resolves to AstroDNA.

[ ] Runtime AstroDNA resolution reads Orbo Spine,
    not the ephemeris.

[ ] Unsupported Spine coverage fails explicitly.

[ ] Loom searches Orbo Spine.

[ ] Loom solves horizon-dependent targets through canonical
    horizon geometry.

[ ] Loom does not interpret its results.

[ ] Resonator detects reference/runtime drift.

[ ] Production code has no ordinary route to the ephemeris.

[ ] Production code has no accidental alternate celestial authority.

[ ] OrboLab may inspect privileged internals without making
    those internals public product interfaces.

[ ] Every Phase 0 test remains green.

[ ] Every Phase 1 unit test remains green.

[ ] Every Phase 1 integration test remains green.

[ ] The entire Ovum passes as one organism.

[ ] An unfertilized Orbo can operate offline from
    supported human celestial address → AstroDNA.
```

Only then is the Ovum sealed.

---

# 1.26 Phase 1 Handoff

Phase 0 produced:

```text
THE LAB
```

Phase 1 produces:

```text
THE OVUM
```

And now the next question changes.

Phase 1 asks:

```text
Where and when is everything?
```

Phase 2 asks:

```text
What does this exact AstroDNA structurally contain?
```

The handoff is therefore:

```text
                     OVUM

Human Celestial Address
          ↓
Geoplacement + Civil Time
          ↓
Celestial Address
          ↓
Orbo Spine + Horizon
          ↓
       AstroDNA

          │
          │ Phase 2 begins
          ▼

      CONNECTOME

AstroDNA unfolded
```

The most important Phase 1 achievement is not any single engine.

It is the **closed circuit**:

> **place + time → celestial address → canonical celestial state → AstroDNA**

with every step owned, versioned where necessary, offline-capable within the supported domain, and protected behind one coherent wall.

Only after that circuit is trustworthy should Orbo begin unfolding AstroDNA into the Connectome.
