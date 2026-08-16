# Ovum Temporal Architecture: Ephemeris, Forge, and Spines

**Status:** Earned Phase 1b architectural clarification and Pass 4 qualification record.

**Date:** 2026-08-16

**Purpose:** Define the permanent relationship among the Ephemeris, Forge, Mundane Timespine, Loom, and derived child spines inside the Orbo Ovum, and record the qualified astronomical reference for Mundane Timespine v1 construction.

This document refines earlier shorthand in the Phase 1 plans that described the ephemeris itself as "the Forge." The earned native ontology distinguishes them as separate organs.

---

# 1. Governing Structure

The Ephemeris, Forge, and initial versioned Mundane Timespine all belong inside the Ovum.

They are not equal authorities.

```text
┌──────────────────────────── ORBO OVUM ────────────────────────────┐
│                                                                  │
│  EPHEMERIS                                                       │
│  deep astronomical capability                                   │
│       │                                                          │
│       │ only Forge opens this door                               │
│       ▼                                                          │
│  FORGE                                                           │
│  manufacture / verify / maintain / repair / extend               │
│       │                                                          │
│       ▼                                                          │
│  MUNDANE TIMESPINE vN                                           │
│  universal versioned celestial chronology                       │
│  same version = same chronology for every Orbo                   │
│       │                                                          │
│       ├──────────► Horizon                                       │
│       ├──────────► AstroDNA                                      │
│       ├──────────► Loom                                          │
│       └──────────► other sanctioned Ovum reads                   │
│                                                                  │
│  Later, after a native/state exists:                             │
│                                                                  │
│  Mundane Timespine + canonical Orbo state + Loom                 │
│                         │                                        │
│                         ▼                                        │
│                       FORGE                                      │
│                         │                                        │
│          ┌──────────────┼──────────────┐                         │
│          ▼              ▼              ▼                         │
│      Contact Spine  Synchronic Spine  other child spines         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

The hierarchy is:

```text
Ephemeris
    source capability

Forge
    maker and maintainer

Mundane Timespine
    canonical universal chronology

Child spines
    durable derived temporal artifacts
```

---

# 2. The Core Law

> **The Forge is Orbo's maker, not Orbo's oracle.**

The Ephemeris knows astronomy.

The Forge knows how to turn canonical ingredients into durable temporal artifacts.

The Mundane Timespine is the artifact normal Orbo celestial traffic runs on.

The Loom finds temporal crossings.

The Connectome or other canonical owners determine which targets matter.

Child spines remember the resulting native- or state-specific chronology.

A compact statement is:

```text
Ephemeris knows.
Forge makes.
Mundane Timespine remembers the universal sky.
Connectome knows the target.
Loom finds the crossing.
Forge makes the child spine.
```

---

# 3. Mundane Timespine Means Universal, Not a Feature

The first shipped spine is the **Mundane Timespine**.

"Mundane" here means native-independent world chronology. It does not mean that the object belongs to a later Mundane Astrology feature.

Before any native exists, the Mundane Timespine can know universal celestial facts such as:

```text
planetary longitude through time
true North Node longitude through time
signed longitudinal motion through time
stations
ingresses
retrograde periods
lunations
eclipses
other admitted universal temporal hinges
```

It does not know:

```text
a natal chart
a user
a Connectome
a contact target
a synchronic transformation
a progression target
interpretation
```

The prototype `mundane.js` already discovered the most important identity law: the universal temporal floor must be native-independent and byte-identical for every reader. Native Orbo extends that principle from a sparse event floor into the complete runtime celestial chronology required by AstroDNA.

---

# 4. Uniformity and Version Law

A Mundane Timespine version is immutable.

```text
Mundane Timespine v1
```

must mean the same celestial chronology in every Orbo carrying v1.

A released artifact therefore carries at least:

```text
Mundane Timespine version
artifact / storage codec
AstroDNA compatibility
astronomical source identity
astronomical source version
ephemeris-data provenance
supported temporal range
coordinate convention
fidelity declaration
checksum
admitted universal indexes
```

The Forge does not silently repair an installed `v1` into a different `v1`.

If repair, improved astronomy, a new representation, changed fidelity, or an extended range changes the artifact, the Forge produces a new identified version:

```text
v1
v1.1
v2
...
```

Therefore:

> **Same Timespine version means same heavens.**

---

# 5. Normal Runtime Authority

The Ephemeris remains inside the Ovum, but it is not the normal celestial door.

Ordinary Orbo code must not choose between:

```text
Ephemeris
Timespine
some alternate planetary calculator
```

The normal path is:

```text
request
    ↓
Mundane Timespine
    ↓
canonical celestial state
```

The exceptional maintenance path is:

```text
Forge
    ↓
Ephemeris
```

No other production component receives routine Ephemeris access.

This is an authority boundary, not merely a performance optimization.

---

# 6. The Forge Is a Permanent Ovum Organ

The Forge does not disappear after the first Timespine is made.

Its permanent jobs include:

```text
manufacture a Mundane Timespine version
verify a Mundane Timespine version
compare a Timespine against the Ephemeris
maintain artifact provenance
extend the supported range
repair defects by producing a new version
manufacture golden fixtures
measure candidate storage representations
build admitted universal indexes
materialize child spines
pack child spines
version child spines
checksum child spines
rebuild child spines when their canonical ancestry changes
```

The Forge is therefore the Hephaestus of the Orbo temporal ecosystem.

It manufactures durable artifacts from canonical ingredients.

It does not decide astrological meaning.

---

# 7. Two Forge Input Paths

The Forge has two legitimate source paths.

## 7.1 Deep astronomical path

Used to create, verify, maintain, repair, or extend the Mundane Timespine.

```text
Ephemeris
    ↓
Forge
    ↓
Mundane Timespine vN
```

This is the only path in which the Forge opens the Ephemeris.

## 7.2 Orbo-native path

Used to manufacture child spines.

```text
Mundane Timespine
+
canonical Orbo state
+
Loom results where required
    ↓
Forge
    ↓
child spine
```

A child spine must not reopen the Ephemeris.

This prevents a second celestial ancestry from entering the derived temporal ecosystem.

> **Every child spine descends from a versioned Mundane Timespine, not from an independent ephemeris read.**

---

# 8. Loom and Forge Are Not the Same Thing

The Loom solves.

The Forge manufactures.

```text
Connectome / doctrine owner
    defines target
        ↓
Loom
    finds root / crossing / interval
        ↓
Forge
    materializes / packs / indexes / versions
        ↓
child spine
```

The Loom must not own persistence, packing, artifact versioning, or why a target matters.

The Forge must not own the mathematical meaning of an aspect or the doctrine deciding which target is significant.

This preserves the existing law:

> **The Connectome knows the target. The Loom finds the crossing.**

and adds:

> **The Forge makes the durable temporal artifact.**

---

# 9. Prototype Archaeology Feeding the Forge

There is no single prototype `forge.js`.

Forge behavior is distributed across historical components.

## `mundane.js`

Useful surviving lessons:

```text
native-independent universal artifact
byte-identical for every reader
verified-once principle
packed storage
read-time decoding
universal event indexes
canonical correction before shipping
```

## `timespine.js`

Useful surviving lessons:

```text
chunked manufacturing
seam overlap
phase-locked grids
event-identity deduplication
sorted temporal materialization
version identity
conformance of materialized results against expensive scans
```

Its direct Ephemeris imports are historical architecture and do not survive into child-spine manufacture.

## `fertilize.js`

Useful surviving lessons:

```text
optional/resumable manufacturing
caller-owned yield points
packing and codec discipline
cache ancestry
materialize generously, filter at read
child temporal artifact construction
```

The word "fertilize" no longer owns this manufacturing job. In the restored architecture, fertilization is the production of AstroDNA from a celestial address. The temporal-artifact mechanics discovered there belong conceptually to Forge.

---

# 10. Pass 4 Ephemeris Archaeology

Prototype `ephem.js` is not one clean native component.

It currently mixes:

```text
planetary / lunar astronomy
true and mean node calculations
civil/JD helpers
horizon geometry
Vertex
Part of Fortune
Ascendant-anchor solving
```

The native ownership split is:

```text
planetary / lunar astronomy       -> Ephemeris
civil/JD helpers                  -> Civil Time, already canonical
horizon geometry                  -> Horizon, Pass 6
Part of Fortune                   -> state-derived expression, later owner
Ascendant-anchor temporal solving -> Horizon/Loom as earned later
```

The surviving Ephemeris component is therefore only the physical astronomical kernel.

---

# 11. Ephemeris 4R

**Primary 4R:** REPRODUCE

**Parity:** STRUCTURAL

**Native destination:** `OrboCore / Ephemeris`

## Why

The prototype solved the required capability but does not meet native Orbo's fidelity contract.

Its own source documents approximate Keplerian planetary elements, a truncated lunar series, a narrow Delta-T approximation, and body-dependent errors measured in arcminutes or worse over parts of the intended range.

Codec 4 identifies longitude at one-arcsecond Ring precision. A few-arcminute reference engine cannot be the authority that manufactures that identity.

Native Orbo therefore preserves the capability and replaces the numerical authority.

---

# 12. Qualified Astronomical Reference

For Mundane Timespine v1 construction, the qualified reference is:

```text
Swiss Ephemeris
official source: Astrodienst / aloistr/swisseph
release: v2.10.3bfinal
release date: 2026-08-02
planetary/lunar data lineage: JPL DE441-based Swiss .se1 data rebuilt in 2026
```

The official source remains the authority, not a third-party wrapper.

The Swiss Ephemeris is itself largely based on JPL development ephemerides and performs the coordinate transformations required for astrological geocentric positions.

The current Swiss compressed planetary/lunar data are documented as reproducing the underlying JPL ephemeris at far finer precision than AstroDNA's one-arcsecond address quantum.

Orbo's v1 claimed temporal domain remains:

```text
1700...2149
```

which is comfortably inside the qualified Swiss Ephemeris astronomical range.

The actual data bundle used by an Orbo release must explicitly cover the entire declared Orbo range.

---

# 13. The Swift Swiss Ephemeris Repository Found During Pass 4

Repository inspected:

```text
vsmithers1087/SwissEphemeris
```

This repository is useful **integration archaeology**, not the qualified astronomical authority.

What it proves:

```text
Swiss Ephemeris C can be packaged behind Swift Package Manager
an unmodified C target can sit beneath a Swift-facing target
swe_calc_ut can be exposed cleanly to Swift
longitude, latitude, distance and signed speeds can be surfaced
mean and true lunar North Node can be represented separately
```

Important limitations:

```text
repository is archived
wrapper work is incomplete
its bundled ephemeris subset is documented as 1800-2399
its Swiss source is not the current qualified release
```

Therefore native Orbo may reuse the **bridge pattern**, but must not blindly pin this archived package as the production Ephemeris.

The likely production integration is an Orbo-controlled Swift/C bridge around the qualified official Swiss source and data.

---

# 14. Ephemeris Coordinate Contract for Forge Reads

The v1 Forge reference read for physical planets is:

```text
center: geocentric
zodiac: tropical
ecliptic coordinate: longitude of date
position convention: apparent, standard astrological Swiss position
ephemeris: explicitly Swiss Ephemeris data, no silent Moshier fallback
motion: high-precision signed longitudinal speed in degrees/day
```

The Forge must request the intended Swiss ephemeris explicitly and must fail qualification if the requested data are unavailable rather than accepting a silent fallback to another numerical model.

Primary physical bodies required for AstroDNA manufacture:

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

The Ascendant is not an Ephemeris body. Horizon owns it.

The true North Node is variable-motion and may be direct or retrograde.

The mean North Node may remain available as a supplementary astronomical read for techniques that explicitly request it, but it is not AstroDNA gene 12.

---

# 15. Velocity Boundary

The Ephemeris is capable of supplying signed longitudinal velocity.

That fact is preserved into the Forge/Timespine design because later Orbo layers require truthful motion information for such concepts as:

```text
direct / retrograde
stations
station proximity
intrinsic celestial velocity
relative motion
applying / separating
```

This does **not** make continuous velocity an AstroDNA gene.

AstroDNA codec 4 continues to encode position plus admitted direct/retrograde identity through RingFineState.

The exact semantic treatment of natal intrinsic velocity versus relationship-frame effective motion remains a later Connectome/Phase 2 question and is not collapsed by Pass 4.

---

# 16. Accuracy Policy

Pass 4 qualifies the reference source.

Pass 5 qualifies the compressed Mundane Timespine representation.

The reference must be materially more precise than AstroDNA's one-arcsecond positional quantum.

For Timespine v1, the Forge must measure and publish at least:

```text
maximum angular residual by body
maximum velocity residual by body
RingFineState agreement rate / boundary behavior
station timing residual
ingress timing residual
range-edge behavior
```

The final Timespine tolerance is not invented in Pass 4. It is earned by Pass 5 measurement.

The categorical requirement remains that the shipped chronology reproduce canonical codec-4 identity under a declared, tested boundary policy.

---

# 17. Ephemeris Access Law

Only Forge receives the deep Ephemeris capability.

The architecture must make this hard to violate.

Disallowed ordinary paths include:

```text
AstroDNA -> Ephemeris
Connectome -> Ephemeris
Loom -> Ephemeris
Horizon -> Ephemeris for planetary positions
child spine -> Ephemeris
UI -> Ephemeris
interpretation -> Ephemeris
```

Allowed deep path:

```text
Forge -> Ephemeris
```

Allowed ordinary celestial path:

```text
consumer -> Mundane Timespine
```

Horizon remains a separate local-geometric authority consuming time and place, not a second planetary calculator.

---

# 18. Forge 4R

**Primary 4R:** REPRODUCE

**Parity:** STRUCTURAL

**Native destination:** `OrboCore / Forge`

## Why

The prototype already discovered much of the correct manufacturing behavior, but it is scattered across universal floor construction, personal TimeSpine work, fertilization-era packing, browser build machinery, and conformance tests.

There is no coherent prototype Forge component to transpose.

Native Orbo reproduces those successful manufacturing laws as one explicit permanent owner.

---

# 19. Forge Contract

Forge owns the act of manufacturing durable temporal artifacts.

Its future native mating surface may evolve during Pass 5 measurement, but the ownership contract is now fixed:

```text
Mundane Timespine manufacture
Mundane Timespine verification
Mundane Timespine maintenance / reforge
universal index manufacture
golden fixture manufacture
child-spine materialization
artifact packing
artifact versioning
artifact checksum/provenance
```

Forge does not own:

```text
astronomical equations themselves
zodiacal law
house law
aspect geometry
interpretive meaning
target doctrine
root-solving mathematics
user presentation
```

Those belong to Ephemeris, Mater/Tympan/Ring, Connectome/doctrine owners, Loom, and UI respectively.

---

# 20. Child Spine Ancestry Law

A child spine is not a second sky.

Every child spine must identify the canonical ancestry from which it was forged.

Conceptually:

```text
child spine version
Forge artifact codec
parent Mundane Timespine version/checksum
relevant AstroDNA identity
relevant doctrine / Connectome version
relevant transformation provenance
```

This makes invalidation deterministic.

If the parent Mundane Timespine changes in a way that matters, Orbo can know that a child artifact was forged from an older celestial substrate.

---

# 21. Licensing Is a Distribution Gate

Swiss Ephemeris is dual-licensed.

The official source requires a project using Swiss Ephemeris code to choose between:

```text
GNU Affero General Public License
or
Swiss Ephemeris Professional License
```

before distributing software containing Swiss Ephemeris or activating a public service that uses it.

Because the settled architecture keeps the Ephemeris inside the shipped Ovum, Orbo must resolve this licensing path before distribution of a build containing the Swiss Ephemeris implementation.

Pass 4 does not silently choose a project-wide license on the user's behalf.

This legal gate does not change the qualified astronomical architecture.

---

# 22. Pass 4 Gate Result

Pass 4 is satisfied at the reference-qualification / ownership level when the following are true:

```text
Ephemeris and Forge are separate Ovum organs                     PASS
Ephemeris primary 4R is REPRODUCE                               PASS
Forge primary 4R is REPRODUCE                                   PASS
qualified astronomical source is named                          PASS
qualified source version/provenance is named                    PASS
Orbo v1 supported range is inside source capability             PASS
physical coordinate convention is explicit                      PASS
signed longitudinal velocity is available                       PASS
true North Node is available with variable direction            PASS
Ascendant is excluded from Ephemeris ownership                   PASS
silent lower-precision fallback is forbidden                    PASS
Forge is sole sanctioned Ephemeris client                       PASS
Mundane Timespine is normal runtime celestial authority          PASS
same Timespine version means same chronology for every Orbo      PASS
child spines descend from the Mundane Timespine                  PASS
Loom finds; Forge makes                                          PASS
Swiss licensing is recorded as a distribution gate              PASS
```

No Mundane Timespine storage representation is selected in Pass 4.

No child spine is built in Pass 4.

---

# 23. Pass 5 Handoff

Pass 5 receives a qualified furnace and a defined smith.

Its job is now precise:

> **Use Forge, backed by the qualified Ephemeris, to manufacture the first immutable, versioned, checksum-identical Mundane Timespine that every Orbo can ship and run on.**

Pass 5 must measure candidate representations rather than preselect one.

Candidates may include:

```text
samples
adaptive samples
segments
interpolation coefficients
Chebyshev or other fitted coefficients
knots
body-specific representations
explicit station boundaries
hybrids
universal event indexes
```

The winner is chosen by:

```text
fidelity
file size
read speed
velocity fidelity
station fidelity
boundary behavior
implementation clarity
```

At the end of Pass 5:

```text
Ephemeris
    deep source inside Ovum

Forge
    permanent maker inside Ovum

Mundane Timespine v1
    first canonical universal chronology
    shipped uniformly
    normal celestial runtime substrate
```

The Forge remains alive after that milestone so the rest of Orbo can later be forged from the common sky.
