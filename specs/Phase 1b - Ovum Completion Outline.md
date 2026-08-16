# Phase 1b: Ovum Completion Outline

**Status:** Outline only. No production implementation is authorized by this document.

**Purpose:** Continue Phase 1 from the completed native foundation through the sealed Ovum: offline human celestial address -> canonical AstroDNA, plus temporal solving and integrity checking.

**Authority:**

1. `specs/Orbo 1.0 Native Construction Plan.md`
2. `specs/Phase 1 - The Ovum.md`
3. `specs/Native Port Manifest.md`

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
implementation
        ↓
focused + accumulated proof
        ↓
native canonical / proven status
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

Define the required output before freezing the physical Orbo Spine format.

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

No Orbo Spine codec is frozen before this gate.

---

# 4. Pass 4: Ephemeris Forge Archaeology and Reference Qualification

Now inspect the astronomical source itself.

The pass begins with the actual ephemeris source, browser counterpart, tests, known fixtures, consumers, and any horizon logic currently mixed into it.

Do not decide its 4R before archaeology.

The pass must determine:

```text
what current algorithms calculate
body-by-body accuracy
supported temporal range
known weaknesses
which material is planetary astronomy
which material belongs to Horizon instead
what source will be the reference Forge for Spine v1
what accuracy claim Orbo is willing to make
```

The output of this pass is a qualified astronomical reference boundary for construction and verification.

It is not permission for normal Orbo runtime to query the ephemeris.

### Gate

```text
reference source is named
version/provenance is known
supported range is known
accuracy policy is explicit
required AstroDNA celestial state can be generated
```

---

# 5. Pass 5: Spine Forge and Orbo Spine v1

With the AstroDNA contract known and the astronomical reference qualified, determine the smallest runtime chronology that meets the fidelity contract.

Do not preselect the storage representation.

Measure candidates such as:

```text
samples
segments
interpolation coefficients
knots
compressed runs
hybrid representations
event indexes
```

Then build the deterministic Spine Forge and first production candidate.

Orbo Spine v1 must identify at least:

```text
Spine version
codec version
astronomical source version
supported temporal range
precision/fidelity contract
checksum
indexed event families, if admitted
```

### Proof

Compare runtime reconstruction against the Forge reference across:

```text
random moments
known natal moments
fast Moon cases
slow-body cases
0/360 wrap
ingresses
stations
retrograde changes
range boundaries
historical dates
future dates
```

### Gate

Normal runtime celestial-state reads can use Orbo Spine v1 across the declared range at the declared fidelity without querying the ephemeris.

---

# 6. Pass 6: Horizon Geometry, AstroDNA Encoder, and Ovum Resolver

The Orbo Spine is geographically universal. Horizon is local.

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
Orbo Spine
+ Horizon
        ↓
AstroDNA Encoder
        ↓
canonical AstroDNA
```

### Reference parity

Compare the production path against the reference construction path:

```text
reference astronomy + reference horizon
versus
Orbo Spine + native Horizon
```

The resulting AstroDNA must agree at the declared contract fidelity.

### Gate

A supported human celestial address resolves fully offline to canonical AstroDNA, and routine production resolution has no ephemeris path.

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

It must not own the meaning or desirability of the target.

Runtime solving should read canonical Ovum machinery, primarily Orbo Spine and Horizon when required.

### Gate

Known ingresses, stations, aspect crossings, sign boundaries, planetary crossings, and admitted horizon-dependent crossings can be solved without ephemeris queries or interpretation logic.

---

# 8. Pass 8: Resonator, OrboLab Completion, and Seal the Ovum

The last Phase 1 pass is fidelity and enclosure, not another source of celestial truth.

Fresh archaeology should determine which existing parity/checking machinery belongs in the Resonator and which remains ordinary tests.

The Resonator may compare or inspect:

```text
Ephemeris reference <-> Orbo Spine
Geoplacement <-> place fixtures
Civil Time <-> timezone fixtures
Horizon <-> angle fixtures
AstroDNA <-> known genomes
Ring <-> geometry fixtures
Mater/Tympan <-> canonical invariants
Loom <-> known crossings
artifact versions / checksums / codec compatibility
```

It detects drift. It does not invent missing truth.

Complete OrboLab so the entire unfertilized organism can be inspected from one human address through AstroDNA, Loom, and integrity results.

Then make the Ovum wall real: ordinary production code receives sanctioned capabilities rather than raw Forge, raw Spine storage, timezone internals, horizon internals, or Loom sampling machinery.

### Final Phase 1 gate

```text
supported human date/time/place resolves offline
place ambiguity is explicit
civil-time ambiguity is explicit
Orbo Spine is versioned and fidelity-proven
Horizon is independent of planetary ephemeris
AstroDNA contract is explicit and canonical
production AstroDNA resolution reads Spine, not ephemeris
Loom searches canonical Ovum machinery
Resonator detects drift
no accidental alternate celestial authority exists
all accumulated tests pass
OrboLab can inspect the complete organism
the offline Ovum test passes end to end
```

Only then is Phase 1 complete and the Ovum sealed.

---

# 9. Efficient Phase 1b Rhythm

The likely construction sequence is:

```text
1. Geoplacement + terrestrial vocabulary
2. Civil Time
3. AstroDNA contract
4. Ephemeris Forge qualification
5. Spine Forge + Orbo Spine v1
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
canonical celestial state
        ↓
canonical AstroDNA
```

fully offline across Orbo's declared supported domain.
