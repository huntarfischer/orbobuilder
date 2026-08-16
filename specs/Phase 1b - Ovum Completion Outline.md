# Phase 1b: Ovum Completion Outline

**Status:** Outline only. No production implementation is authorized by this document.

**Purpose:** Continue Phase 1 from the completed native foundation through the sealed Ovum: offline human celestial address -> canonical AstroDNA, plus temporal solving and integrity checking.

**Authority:**

1. `specs/Orbo 1.0 Native Construction Plan.md`
2. `specs/Phase 1 - The Ovum.md`
3. `specs/Native Port Manifest.md`
4. `specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md`

The temporal architecture document is an earned Phase 1b clarification of the older shorthand that called the Ephemeris itself "the Forge." Native Orbo distinguishes Ephemeris, Forge, Mundane Timespine, Loom, and child spines as separate owned concepts inside the Ovum.

Phase 1a established the inherent native foundation:

```text
Domain vocabulary    native proven
Ring                 native canonical
Mater                native canonical
Rulers               rehoused into Mater
Tympan               native canonical
```

Phase 1b begins where the foundation stops: terrestrial address, civil time, celestial chronology, horizon, AstroDNA resolution, temporal solving, and the final Ovum wall.

---

# 0. Construction Law

This outline sets dependency order, not 4R outcomes.

Every meaningful component begins unclassified.

For each pass:

```text
fresh prototype archaeology
        ↓
actual law and ownership
        ↓
one primary 4R ruling
        ↓
native contract
        ↓
Swift Sanding
        ↓
implementation or qualification appropriate to the pass
        ↓
focused + accumulated proof
        ↓
native canonical / proven / qualified status
```

Do not choose a component's 4R from its filename, from a Phase 1 expectation, or from what would be convenient to build.

Do not build a parallel temporary architecture. Production work goes directly into the permanent `native/OrboCore` structure once its ownership is earned.

---

# 1. Pass 1: Terrestrial Domain Vocabulary and Geoplacement Atlas

The next dependency is place.

Before implementing the Atlas, inspect the current location/geoplacement material, datasets, tests, consumers, and any compact city-data experiments already in the repository.

Only then establish the minimum additional native vocabulary actually required, likely around concepts such as:

```text
Latitude
GeographicLongitude
Place
PlaceIdentifier
TimezoneIdentifier
```

These are candidates, not automatic wrappers.

The Geoplacement pass must settle:

```text
canonical place record
alternate names / aliases
region and country identity
latitude / longitude
canonical timezone jurisdiction
offline search/indexing
ambiguity behavior
data provenance
artifact versioning
storage size
```

The data representation is chosen by measurement rather than aesthetics.

### Gate

```text
supported places resolve offline
coordinates are stable and typed
canonical timezone identity is returned
ambiguous names are surfaced rather than guessed
Atlas version is explicit
no astrology enters the place layer
```

OrboLab receives a plain place lookup readout.

---

# 2. Pass 2: Civil Time and Timezone History

Once a place can resolve to coordinates and a timezone jurisdiction, build the local-clock-to-absolute-time path.

Fresh archaeology must inspect any existing calendar, Julian Day, timezone, date parsing, and historical offset logic before ownership is assigned.

Add only the domain vocabulary that the implementation proves it needs, potentially including:

```text
CivilDate
CivilTime
AbsoluteInstant
JulianDay
CelestialAddress
```

The Civil Time subsystem must define explicit behavior for:

```text
historical UTC offsets
daylight-saving transitions
ambiguous local times
nonexistent local times
calendar boundaries
supported historical range
```

### Gate

```text
local date + clock + timezone jurisdiction
-> one explicit absolute instant

known modern fixtures pass
known historical fixtures pass
ambiguity is explicit
nonexistent local time is explicit
supported range is explicit
```

At the end of this pass, Orbo can resolve the terrestrial and temporal half of a celestial address without the web.

---

# 3. Pass 3: AstroDNA Contract

Define the required output before freezing the physical Mundane Timespine format.

This pass begins with fresh archaeology of the current AstroDNA implementation, tests, codec assumptions, consumers, motion encoding, precision, and horizon requirements.

Settle exactly:

```text
canonical genes
canonical gene order
which bodies / angles are genes
positional precision
motion identity
retrograde representation
whether stationary state belongs in identity
required horizon values
what is encoded
what is derived
what is explicitly excluded
```

The contract must keep AstroDNA as celestial identity rather than a bag of downstream astrology.

### Gate

We can state exactly what information the celestial chronology and Horizon must provide to manufacture one valid AstroDNA, in one canonical order, at one declared fidelity.

No Mundane Timespine codec is frozen before this gate.

---

# 4. Pass 4: Ephemeris and Forge Qualification

Pass 4 establishes the deep astronomical source and the permanent maker that is allowed to use it.

Both are inside the Ovum, but they are separate organs:

```text
Ephemeris
    deep astronomical capability
        ↓
Forge
    sole sanctioned Ephemeris client
```

The pass begins with the actual prototype ephemeris source, browser counterpart, tests, known fixtures, consumers, horizon logic currently mixed into it, and the prototype manufacturing behavior distributed across `mundane.js`, `timespine.js`, `fertilize.js`, and related conformance work.

Do not decide either component's 4R before archaeology.

The pass must determine:

```text
what current astronomical algorithms calculate
body-by-body accuracy
supported temporal range
known weaknesses
which material is planetary/lunar astronomy
which material belongs to Civil Time, Horizon, Loom, or expression instead
what astronomical source will be the qualified Ephemeris for Mundane Timespine v1
source version and data provenance
physical coordinate convention
true North Node convention
signed longitudinal velocity capability
accuracy policy
licensing/distribution gate
Forge ownership law
Forge / Ephemeris access boundary
Mundane Timespine ancestry law
child-spine ancestry law
```

The earned structure is documented in:

```text
specs/Ovum Temporal Architecture - Ephemeris Forge and Spines.md
```

The Ephemeris remains in the Ovum, but normal Orbo celestial traffic does not query it.

The Forge remains in the Ovum permanently. It uses the Ephemeris to manufacture and maintain the universal Mundane Timespine, and later uses the Mundane Timespine plus canonical Orbo state to manufacture child spines.

A child spine must never reopen the Ephemeris.

### Gate

```text
Ephemeris and Forge are separate owned concepts
one primary 4R is earned for each
qualified astronomical source is named
version/provenance is known
supported Orbo range is inside source capability
coordinate convention is explicit
true North Node is available
signed longitudinal velocity is available
silent lower-precision ephemeris fallback is forbidden
Forge is the only sanctioned Ephemeris client
Mundane Timespine is the normal celestial runtime authority
same Mundane Timespine version means the same chronology for every Orbo
child spines descend from the Mundane Timespine, not the Ephemeris
licensing requirements are recorded before distribution
```

Pass 4 qualifies ownership and source. It does not freeze a Mundane Timespine storage representation.

---

# 5. Pass 5: Forge + Mundane Timespine v1

With the AstroDNA contract known and the Ephemeris/Forge boundary qualified, give the Forge its first canonical manufacturing job.

The Forge uses the qualified Ephemeris to manufacture **one immutable, versioned Mundane Timespine artifact** that ships with every Orbo.

```text
Ephemeris
    ↓
Forge
    ↓
Mundane Timespine v1
    ↓
ships identically with every Orbo carrying v1
```

The Mundane Timespine is the universal native-independent celestial chronology. It is the normal celestial substrate from which the rest of Orbo reads and from which later child spines descend.

Do not preselect the storage representation.

Measure candidates such as:

```text
samples
adaptive samples
segments
interpolation coefficients
Chebyshev or other fitted coefficients
knots
compressed runs
body-specific representations
explicit station boundaries
hybrid representations
event indexes
```

The Forge may use expensive astronomical reads and redundant verification while manufacturing. The shipped Timespine should be the smallest, fastest representation that meets Orbo's declared fidelity.

Mundane Timespine v1 must identify at least:

```text
Timespine version
artifact/storage codec
AstroDNA compatibility
astronomical source identity/version
ephemeris-data provenance
supported temporal range
coordinate convention
precision/fidelity contract
checksum
indexed universal event families, if admitted
```

A Timespine version is immutable. A repair or changed chronology produces a new version rather than silently mutating v1.

### Proof

Compare Mundane Timespine reconstruction against the qualified Ephemeris through Forge across:

```text
random moments
known natal moments
fast Moon cases
true North Node direct periods
true North Node retrograde periods
slow-body cases
0/360 wrap
ingresses
stations
retrograde changes
range boundaries
historical dates
future dates
```

Measure both categorical AstroDNA/Ring identity fidelity and numerical residuals, including longitudinal velocity where the Timespine contract exposes it.

### Gate

```text
one versioned Mundane Timespine v1 exists
same v1 artifact/checksum is shipped for every Orbo
normal celestial-state reads use the Mundane Timespine
required physical state can be reconstructed across the declared range
codec-4 AstroDNA requirements are met at the declared fidelity
ordinary consumers do not query the Ephemeris
Forge remains available inside the Ovum for maintenance and later child-spine manufacture
```

---

# 6. Pass 6: Horizon Geometry, AstroDNA Encoder, and Ovum Resolver

The Mundane Timespine is geographically universal. Horizon is local.

First perform fresh archaeology of current Ascendant/MC/horizon calculations and establish the Horizon owner's exact law.

Horizon consumes resolved:

```text
absolute time
latitude
geographic longitude
```

and produces only the local celestial geometry required by the AstroDNA contract.

Then build the AstroDNA encoder and the first complete Ovum resolution chain:

```text
human place
+ local date/time
        ↓
Geoplacement Atlas
+ Civil Time
        ↓
Celestial Address
        ↓
Mundane Timespine
+ Horizon
        ↓
AstroDNA Encoder
        ↓
canonical AstroDNA
```

### Reference parity

Compare the production path against the Forge reference construction path:

```text
qualified Ephemeris + reference horizon
versus
Mundane Timespine + native Horizon
```

The resulting AstroDNA must agree at the declared contract fidelity.

### Gate

A supported human celestial address resolves fully offline to canonical AstroDNA, and ordinary production resolution has no direct Ephemeris path.

---

# 7. Pass 7: Loom

Only after the runtime chronology exists should temporal solving move onto it.

Freshly inspect the current Loom/scanner work, tests, callers, and any logic that has accumulated around it before assigning one primary 4R.

The native Loom's eventual responsibility is narrow:

```text
find when / where a supplied celestial condition becomes true
```

It may own:

```text
root finding
crossing detection
boundary solving
interval solving
celestial target search
```

It must not own the meaning or desirability of the target, artifact packing, or spine versioning.

Runtime solving should read canonical Ovum machinery, primarily the Mundane Timespine and Horizon when required.

The manufacturing law is:

```text
Connectome / doctrine owner
    knows target
        ↓
Loom
    finds crossing
        ↓
Forge
    makes durable child spine when one is called for
```

### Gate

Known ingresses, stations, aspect crossings, sign boundaries, planetary crossings, and admitted horizon-dependent crossings can be solved from canonical Ovum machinery without child-spine Ephemeris queries or interpretation logic.

---

# 8. Pass 8: Resonator, OrboLab Completion, and Seal the Ovum

The last Phase 1 pass is fidelity and enclosure, not another source of celestial truth.

Fresh archaeology should determine which existing parity/checking machinery belongs in the Resonator and which remains ordinary tests.

The Resonator may compare or inspect:

```text
Ephemeris <-> Mundane Timespine through sanctioned Forge/reference paths
Geoplacement <-> place fixtures
Civil Time <-> timezone fixtures
Horizon <-> angle fixtures
AstroDNA <-> known genomes
Ring <-> geometry fixtures
Mater/Tympan <-> canonical invariants
Loom <-> known crossings
artifact versions / checksums / codec compatibility
child-spine ancestry
```

It detects drift. It does not invent missing truth and does not become another Forge.

Complete OrboLab so the entire unfertilized organism can be inspected from one human address through AstroDNA, Loom, Forge/Timespine integrity, and other admitted construction readouts.

Then make the Ovum wall real: ordinary production code receives sanctioned capabilities rather than arbitrary Ephemeris access, raw Timespine storage, timezone internals, horizon internals, or Loom sampling machinery.

### Final Phase 1 gate

```text
supported human date/time/place resolves offline
place ambiguity is explicit
civil-time ambiguity is explicit
Ephemeris is a qualified deep Ovum capability
Forge is its sole sanctioned client
Mundane Timespine is versioned and fidelity-proven
same Timespine version means the same chronology for every Orbo
Horizon is independent of planetary Ephemeris ownership
AstroDNA contract is explicit and canonical
production AstroDNA resolution reads Timespine, not Ephemeris
Loom searches canonical Ovum machinery
Forge can manufacture durable temporal artifacts
child spines descend from Mundane Timespine rather than Ephemeris
Resonator detects drift
no accidental alternate celestial authority exists
all accumulated tests pass
OrboLab can inspect the complete organism
the offline Ovum test passes end to end
```

Only then is Phase 1 complete and the Ovum sealed.

---

# 9. Efficient Phase 1b Rhythm

The construction sequence is:

```text
1. Geoplacement + terrestrial vocabulary
2. Civil Time
3. AstroDNA contract
4. Ephemeris + Forge qualification
5. Forge + Mundane Timespine v1
6. Horizon + AstroDNA Encoder + Ovum Resolver
7. Loom
8. Resonator + OrboLab + Ovum seal
```

This sequence is deliberately dependency-driven.

It is not a promise that each numbered pass is one commit or one afternoon. If archaeology proves a pass contains multiple independently owned components, settle that ontology before implementation and give each component its own earned 4R ruling.

Conversely, do not manufacture additional phases merely because several small tables can be named separately.

Phase 1b ends only when the closed circuit exists:

```text
place + local time
        ↓
celestial address
        ↓
Mundane Timespine + Horizon
        ↓
canonical celestial state
        ↓
canonical AstroDNA
```

fully offline across Orbo's declared supported domain.
