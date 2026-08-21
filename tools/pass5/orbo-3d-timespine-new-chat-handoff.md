# Orbo 3D Mundane Timespine Build Handoff

We are continuing the Orbo 1.0 Mundane Timespine build.

This is a fresh chat. Treat this prompt and the repository branch below as the authoritative handoff. Do not rely on older chat memory to reconstruct the design.

## Repository

`huntarfischer/orbobuilder`

## Working branch

`agent/mundane-timespine-3d-build`

## Frozen build contract

`tools/pass5/mundane-timespine-3d-build-contract.md`

The branch was created specifically for this build. You are authorized to inspect, edit, test, and commit implementation work ONLY on this branch for the 3D Mundane Timespine. Do not mutate other branches. Do not create or launch GitHub Actions or remote benchmark workflows unless I explicitly ask.

Before writing code:

1. Inspect the branch and the frozen build contract.
2. Inspect the existing Pass 5 P22 tools/data, shell tables, Ring implementation, Chronos/Horae-related code if any, and relevant tests.
3. Identify what already exists and can be reused.
4. Do not resurrect or build on superseded Timespine work merely because it has a similar name.
5. In particular, any old Timespine design that references AstroDNA Codec 4 as though Codec 4 owns the Timespine is superseded and wrong. AstroDNA Codec 4 belongs to AstroDNA.
6. Then begin the build in clean, reviewable passes.

The architecture itself is frozen after five experimental rounds. This task is implementation, canonical DE441 manufacture/certification, Chronos, Horae, and integration. Do not reopen the resolution/design search unless canonical evidence proves a frozen law fails.

---

# I. Fundamental 3D model

The Mundane Timespine is one navigable three-dimensional celestial chronology.

Its operational coordinate is:

```text
(body, state, UT)
```

For the current mundane substrate:

### body

One of 11 independent celestial tracts:

- Sun
- Moon
- Mercury
- Venus
- Mars
- Jupiter
- Saturn
- Uranus
- Neptune
- Pluto
- True North Node

South Node is derived at +180 degrees and is NOT an independent tract.

### state

Directional whole-degree celestial index:

```text
0...359   = increasing/direct lane
360...719 = decreasing/retrograde lane
```

### UT

Continuous civic-time Bone shared by all tracts.

This is the essential coordinate law:

```text
BODY × STATE × UT
```

Do not expand sign, zodiac degree, and motion into separate indexing dimensions.

For a state:

```text
physical whole degree = state % 360
decreasing/retrograde = state >= 360
```

Sign and degree-in-sign are views of state, not stored primary coordinates.

Fractional longitude is refinement INSIDE a whole-degree state. It is not another global axis.

For example:

```text
Pluto at physical 19 Aries increasing:
    (Pluto, 19, UT)

Pluto at physical 19 Aries decreasing:
    (Pluto, 379, UT)
```

The 0...719 system matters because state-first navigation should be able to grab only the retrograde/decreasing 19 Aries lane immediately rather than find every 19 Aries occurrence and filter afterward.

---

# II. Geometry

Think of the Timespine physically in 3D.

### BONE

Continuous UT / z-axis.

### TRACT

One body's continuous celestial path winding through the Bone.

### STATE / DEGREE RUNG

A regular known celestial grip through the structure.

### RING CONTACT

An exact lateral relationship between two tracts at the same UT.

### HORAE PLANE

Fixed-UT horizontal cross-section intersecting all eleven tracts.

### ASTROLABE

Top-down projection of the Horae plane.

The Astrolabe is therefore not the underlying model. It is looking down the Timespine from above at one synchronized UT slice.

Retrograde does NOT move backward through time.

UT always remains monotonic.

Retrograde is the body's positional winding changing direction while it continues upward along the Bone.

---

# III. "Rung" does not mean a new rung_id

Do not invent a universal `rung_id` ontology merely because the word "rung" is useful conceptually.

"Rung" means a regular indexed/known grip already present in the celestial structure, especially a degree/state or another known interval/landmark.

The user may grab the Timespine by:

- body
- state
- UT
- Ring relationship
- shell interval

and push through the structure from there.

The goal is not to create more objects. The goal is to make what already exists efficiently traversable.

---

# IV. Three primary entrances

The same occurrence must be reachable from all three coordinate directions.

## Entity first

```text
body
  -> state
  -> UT occurrence/reach
```

Example:

```text
Pluto
  -> 379
  -> all Pluto occurrences/reaches through retrograde 19 Aries
```

## State first

```text
state
  -> body
  -> UT occurrence/reach
```

Example:

```text
379
  -> all bodies that occupy decreasing 19 Aries
  -> Pluto
  -> Pluto occurrences
```

## Time first

```text
UT
  -> body
  -> state
```

Example:

```text
UT T
  -> all eleven bodies
  -> each body's directional state at T
```

These routes must commute.

For an occurrence P:

```text
Pluto -> 379 -> T
379 -> Pluto -> T
T -> Pluto -> 379
```

must identify the same occurrence.

This "path independence" is foundational.

Ring relationships form a fourth lateral entrance into the same structure.

---

# V. State indexing vs tract support

Do not confuse the 0...719 index resolution with stored tract density.

The celestial index remains whole-degree 0...719 for all bodies.

The selected stored support densities are:

```text
Sun         10 degrees
Moon        10 degrees
Mercury      1 degree
Venus        1 degree
Mars         1 degree
Jupiter      0.5 degree
Saturn       0.5 degree
Uranus       0.2 degree
Neptune      0.1 degree
Pluto        0.1 degree
NorthNode    0.1 degree
```

These were selected after the Moon test, per-body tests, full-web resonance test, Pareto deletion round, and Round 5 3D conformance audit.

Do not casually change them.

A major Round 5 insight is that every body capable of reversing is supported at 1 degree or finer, and every selected spacing divides 1 degree exactly.

Therefore every whole-degree direct/retrograde state boundary for the reversible bodies is directly supported by the tract.

Sun and Moon are the exceptions:

```text
both are 10 degree support
neither uses the retrograde 360...719 lane
```

For Sun and Moon, do NOT recreate their discarded 1-degree tables merely to implement state-first lookup.

A state-first lookup should locate the containing 10-degree support reach and refine locally.

For example, a Moon query for state 19 can identify the appropriate 10 -> 20 degree support intervals and refine within those intervals.

The state index should therefore resolve to the containing support/reach when the exact whole-degree crossing is not itself stored.

Preserve the sparse architecture.

---

# VI. Stations

Stations own motion topology.

A station is an exact zero-speed boundary where the body changes directional lane.

Store:

- exact UT
- exact astronomical longitude
- body
- lane before
- lane after

The 0...719 navigation state at the station is derived from the lane ENTERED after the station, using the same half-open boundary law used elsewhere.

Therefore:

```text
direct station
    enters increasing/direct lane
    -> state 0...359

retrograde station
    enters decreasing/retrograde lane
    -> state 360...719
```

Example at physical 19 degrees:

```text
retrograde station
    -> state 379

direct station
    -> state 19
```

Operational mapping:

```text
wholeDegree = floor(normalized exact longitude)

if laneAfter == increasing:
    state = wholeDegree
else:
    state = wholeDegree + 360
```

The exact station longitude remains the astronomical fact.

The 0...719 value gives us additional navigation/topology information essentially for free.

At a station:

```text
UT never reverses
longitude remains continuous
only state direction changes
```

No interpolation may ever cross a station.

---

# VII. Motion ownership

ONE LAW, ONE OWNER.

Exact stations own motion topology.

From stations + ordered tract supports derive:

- directional reaches
- retrograde passages
- retrograde crossing views
- motion at T

A directional reach means:

> how far along the UT Bone can this body be traversed before its motion topology changes?

These are first-class navigation views but NOT independent astronomical owners.

Planetary shadows are also derived:

```text
station degrees
+
corresponding pre/post crossings
=
shadow interval
```

Preserve shadows as useful derived navigation/event views. Do not give them competing ownership.

North Node remains topology-dominant. Do not force it into ordinary planetary minute-level behavior.

---

# VIII. Selected resolution results to preserve

Frozen tract support:

```text
Sun         10°
Moon        10°
Mercury      1°
Venus        1°
Mars         1°
Jupiter      0.5°
Saturn       0.5°
Uranus       0.2°
Neptune      0.1°
Pluto        0.1°
North Node   0.1°
```

Round 4 P22 dedicated candidate body rows were approximately:

```text
515,850
```

versus original P22:

```text
1,811,967
```

about a 71.5% reduction in dedicated body rows.

Do not treat that P22 count as the expected count for the full Z21-Z23 build. It is only a P22 regression/reference figure.

A compact speed/tangent field at anchors was tested during the pre-Round-5 audit and can improve interpolation substantially, but it was NOT selected as a reason to coarsen the frozen tracts.

Why:

```text
it risks trading away direct state/reverse chronology for reconstructed state
the 3D body/state/UT navigation law is more valuable than maximizing forward interpolation sparsity
```

Do not add stored velocity as a canonical runtime field merely because it exists during Swiss manufacture.

Swiss velocity may of course be used during manufacture and station/root solving.

---

# IX. Ring contacts

Ring owns angular relationship geometry.

The canonical P22 relationship vocabulary stored in the Timespine consists of the 11 integer Ring angles.

### Major

```text
0
60
90
120
180
```

### Minor

```text
30
45
72
135
144
150
```

Canonical cleaned P22 counts:

```text
major    308,474
minor    461,819
total    770,293
```

The older Library minor copy contained five duplicate emissions. Do not restore them.

Important vocabulary boundary:

The full live aspect vocabulary also contains:

```text
septile
biseptile
triseptile
```

Those are non-integer angles and deliberately are NOT Ring marks.

Therefore:

```text
"full Ring contact stream" is correct
"all aspects" is not
```

Do not accidentally force septiles into the integer Ring state system.

---

# X. Ring runtime indexing

Use one complete chronological exact Ring-contact stream.

Ordinary body access:

```text
binary search UT
  -> chronological Ring stream
  -> scan outward until requested body contacts are found
```

Round 4/5 evidence:

```text
ordinary body queries required only about 20-21 Ring rows at p99
worst observed about 32
```

Therefore:

> DO NOT build a duplicated per-body relationship endpoint index.

For specific pair access use:

```text
pair -> ordered exact-contact chronology
```

Prefer pair chronology over pair+angle.

Why:

- same basic one-reference-per-relationship cost
- preserves the ordered sequence of relational boundaries
- preserves negative information between contacts
- supports active relationship-sector inference
- still makes requested-angle lookup cheap

The absence of another exact pair contact between two pair-contact boundaries is information.

For P22, one UInt32 relationship reference per relationship is roughly 2.94 MiB plus negligible bucket offsets.

---

# XI. Relationship packing

An exact Ring contact is a lateral edge between two tract coordinates at the same UT.

Conceptually:

```text
(bodyA, state/refined longitude, UT)
        <- Ring relation ->
(bodyB, state/refined longitude, UT)
```

Runtime relationship rows may derive:

- aspect text from Ring-angle code
- orientation text from direction
- second exact endpoint longitude from first endpoint longitude + directed Ring relation
- civic offset from precise event time
- audit residual as manufacture/provenance only

Round 5 reconstruction using one stored longitude:

```text
p99 discrepancy about 0.006 arcsec
max about 0.034 arcsec
no tested endpoint exceeded 0.1 arcsec
```

Preserve enough manufacture/audit data to prove this, but runtime does not need redundant human-readable fields.

---

# XII. Eclipses and syzygies

Do not store eclipse phase as a duplicate temporal hinge.

New Moon / conjunction:

```text
exact Sun-Moon 0-degree Ring contact
```

Full Moon / opposition:

```text
exact Sun-Moon 180-degree Ring contact
```

Eclipse:

```text
annotation on the qualifying Sun-Moon contact
```

P22:

```text
1,133 eclipses
```

Unique eclipse metadata survives, including:

- eclipse type
- centrality
- greatest-eclipse time
- magnitude
- secondary magnitude

Derive what is already owned by the Ring contact, including:

- phase hinge
- eclipse longitude/degree where safe
- solar/lunar kind from 0 vs 180

---

# XIII. Temporal shells

The four shell systems remain independent interval systems:

```text
Frame       Saturn
Revolt      Uranus
Wave        Neptune
Zeitgeist   Pluto
```

Address:

```text
F.R.W.Z
```

They are NOT a permanently nested hierarchy.

Their boundaries can cross.

Ownership is half-open:

```text
[start, next_start)
```

Each shell family owns its own interval truth.

The combined temporal-address segment table may exist as a derived Chronos acceleration cache because it is tiny and makes lookup cheap, but it must never become a second canonical owner.

Large shell intervals are useful large-scale grips on the UT Bone.

Chronos may use them to jump large distances efficiently.

---

# XIV. Hephaestus

Hephaestus is manufacture only.

He:

- forges canonical Timespine data
- calls Swiss Ephemeris during manufacture/certification
- root-refines crossings
- root-refines stations
- constructs indexes/artifacts
- validates checksums/contracts

He does NOT participate at runtime.

He does NOT receive Chronos/Hermes fallback queries.

He does NOT adjudicate Dioscuri disagreement.

Once the Timespine is forged, Hephaestus leaves.

---

# XV. Dioscuri

Pollux and Castor continue to resonate after manufacture.

They are not separate databases. They are independent traversals through the same finished 3D Timespine.

## Castor

Civic / mortal route:

```text
UT
  -> body
  -> state/refinement
```

## Pollux

Celestial / immortal route:

```text
body/state/Ring/topology
  -> UT occurrence
```

Law:

```text
ASK -> ANSWER -> CONFIRM
```

Do not blindly average their answers.

Dioscuri resonance means:

```text
independent paths identify the same
(body, state, UT)
occurrence to the fidelity requested
```

This can be stated more fundamentally as:

```text
RESONANCE = PATH INDEPENDENCE THROUGH THE TIMESPINE
```

Safe non-resonance is valid.

False resonance is failure.

Caller-sensitive fidelity matters:

- sign
- degree
- minute
- second
- occurrence identity
- motion
- shell address
- relationship identity

A broad proposition may resonate safely even when a finer proposition does not.

Do not turn historical Round 3 global error guards into unexplained production constants. Production certification should be grounded in canonical DE441 behavior.

---

# XVI. Chronos - owner and spec

Chronos is the navigator/locator of the finished Timespine.

Core verb:

```text
LOCATE
```

Chronos owns:

- navigation along the Bone
- jumping to a Timespine address
- selecting efficient available grips/indexes
- locating exact UTs or bounded UT reaches
- returning occurrence candidates when a celestial address repeats

Chronos does NOT own:

- ephemeris calculation
- body astronomy
- Ring geometry
- shell astronomy
- interpretation
- houses
- natal data
- UI
- continuous playback synchronization

Chronos may enter by:

- UT
- body/state
- state/body
- shell interval
- Ring relationship occurrence

but must always resolve back onto the same shared Timespine coordinate system.

Think of Chronos as choosing the right stride.

Large scale:

```text
Zeitgeist / Wave / Revolt / Frame
```

Medium/fine celestial scale:

```text
slow body state
faster body state
```

Exact civic location:

```text
UT
```

These are independent grips, not a mandatory hierarchy.

Chronos should be able to say:

```text
"go to UT T"
"go to Pluto state 379"
"go to the next Mars-Saturn square"
"go to Z22"
```

and resolve a Timespine address or an ordered set of candidate addresses.

Chronos must NOT invent one occurrence when a body/state has multiple valid occurrences.

If the target is underdetermined, return ordered candidate occurrences/reaches with enough identity to refine/select them.

Directional state already resolves direct vs retrograde, but repeated direct occurrences still require occurrence identity.

Existing occurrence-marker work must not be lost.

Earlier P22 body-table audits used companion celestial markers to prove repeated celestial crossings could be uniquely distinguished. Preserve that insight when designing occurrence identity, even if the final runtime index can be leaner.

## Chronos output

Design a compact presentation-neutral `TimespineAddress`, roughly capable of carrying:

- UT or UT interval
- exact vs bounded status
- source/index route
- body/state occurrence identity when applicable
- shell address F.R.W.Z at that UT
- neighboring structural boundaries when useful

Do not stuff a whole sky slice into `TimespineAddress`. That belongs to Horae.

## Chronos and playback

Chronos is deliberate navigation:

```text
locate
jump
seek
```

Chronos is NOT the continuous playback motor.

---

# XVII. Horae - owner and spec

The Horae are tapped into the UT Bone.

Core verb:

```text
SYNCHRONIZE
```

At fixed UT T, the Horae hold the horizontal plane:

```text
(*, *, T)
```

and intersect all eleven celestial tracts at that same civic coordinate.

They produce the synchronized `TemporalSlice`.

The Horae do NOT calculate canonical astronomy from scratch.

They read/interpolate/refine the already-forged Timespine.

Their job is reconciliation of independent celestial chronologies through their shared UT coordinate.

The Horae are the correct owner for continuous temporal movement/playback.

As UT moves:

```text
the Horae plane moves up/down the Bone
every tract is reconciled at the same UT
the Astrolabe can redraw the top-down projection
```

## Chronos vs Horae

Chronos:

```text
"take me there"
```

Horae:

```text
"what coexists here?"
```

Chronos:

```text
locate/jump
```

Horae:

```text
synchronize/continuously reconcile
```

---

# XVIII. TemporalSlice

The Horae should emit a presentation-neutral `TemporalSlice`.

It should contain enough information for downstream consumers without importing natal/place/UI concerns.

At minimum consider:

### UT

### F.R.W.Z shell context

### For each of 11 bodies

- body
- directional 0...719 state
- refined longitude inside state
- increasing/decreasing lane
- bracketing stored supports
- containing directional reach
- nearest relevant station boundaries
- shadow context if applicable
- fidelity/resonance status as appropriate

### Nearby/exact Ring contacts

### Relevant exact celestial hinges

### Syzygy/eclipses where present

The exact final struct should stay lean. Do not duplicate derivable labels.

## TemporalSlice must NOT contain

- houses
- Ascendant
- local horizon/place
- natal chart
- native-specific AstroDNA
- Connectome interpretation
- UI state
- astrological prose
- synastry
- presentation layout

Those belong downstream.

---

# XIX. Horae boundary law

Use deterministic half-open ownership consistently.

For intervals:

```text
[start, next_start)
```

At an exact station:

```text
station state is owned by the lane entered after the station
```

At shell boundaries:

```text
new shell owns the exact boundary instant
```

At body-support boundaries:

```text
make ownership deterministic and identical in all indexes
```

This matters so the Horae plane never flickers between contradictory states at an exact boundary.

---

# XX. Astrolabe projection

The Astrolabe is a top-down projection of a Horae `TemporalSlice`.

For each body:

```text
physical longitude
    = refined longitude on the 0...360 zodiac

whole-degree view
    = state % 360

retrograde/decreasing indicator
    = state >= 360
```

Do not make the Astrolabe the model owner.

The Timespine should be independently modellable in 3D from the same data.

The Astrolabe simply looks down the UT/z axis at one Horae plane.

---

# XXI. Ring, AstroDNA, Horizon, Hermes ownership boundaries

Do not contaminate ownership.

## Ring

Owns angular relationship geometry.

Do not repurpose Ring as a Timespine storage owner merely because state uses zodiac degrees.

## AstroDNA

Remains native identity encoding.

Preserve:

```text
AstroDNA.codec == 4
```

Do not use Codec 4 as a Timespine codec.

## Horizon

Owns local rising/place geometry.

No local place/houses in the Mundane Timespine.

## Hermes

Query messenger/router.

Hermes knows who owns answers.

Hermes does not own answers.

Hermes may route:

```text
locate/navigation question -> Chronos
synchronized moment question -> Horae
relationship geometry -> Ring
local geometry -> Horizon
etc.
```

## Connectome / Loom

Native-specific downstream structure.

Not part of the Mundane Timespine.

---

# XXII. Canonical manufacture

Canonical astronomical authority:

```text
Swiss Ephemeris
DE441
geocentric
tropical
apparent ecliptic longitude
UT
```

Known Swiss version used in the existing Z21-Z23 material:

```text
2.10.03
```

The final seal must span:

```text
Z21
Z22
Z23
```

including:

- Z21 -> Z22 seam
- Z22 -> Z23 seam
- shell seams
- stations
- retrograde loops
- sign/degree seams
- relationship contacts
- eclipse/syzygy events

The P22 canonical interval is approximately:

```text
start:
1822-04-16T13:54:20.135Z

end:
2066-06-17T15:24:10.695Z
```

P22 is `[start, end)`.

The existing P22 canonical substrate was forged with DE441.

Do not silently substitute DE431 and call the result canonical.

DE431 may be used only as a diagnostic comparison if explicitly labeled noncanonical.

---

# XXIII. Remaining Round 5 seal

Round 5 froze the architecture but did NOT complete the final three-Zeitgeist DE441 manufacture seal.

Remaining certification:

```text
canonical DE441
  -> selected body supports
  -> Z21 + Z22 + Z23
  -> exact canonical station chronology
  -> especially canonical NorthNode stations
  -> rerun frozen Round 5 conformance
  -> seal
```

If the necessary DE441 ephemeris files are not available locally or in the repo/Library, first inspect every available source before asking me to retrieve them.

Do not fake a canonical result with Moshier or DE431.

---

# XXIV. Round 5 acceptance laws

The Timespine must support these equivalent routes.

## Entity route

```text
BODY -> STATE -> UT
```

## State route

```text
STATE -> BODY -> UT
```

## Time route

```text
UT -> BODY -> STATE
```

## Relation route

```text
RING CONTACT -> BODY/STATE/UT
```

All must commute to the same canonical occurrence.

Hard requirements:

```text
UT ordering errors                 0
missed state occurrences           0
invented state occurrences         0
direct/retro identity errors       0
station lane errors                0
shell address errors               0
Ring occurrence errors             0
Horae state-plane errors           0
false Dioscuri resonance           0
Z-seam continuity errors           0
```

Minute/second resonance coverage may legitimately be less than 100%.

False certification may not.

---

# XXV. Round 5 results already established

Do not needlessly repeat architecture search that was already completed.

Round 5 showed:

```text
1,540,586 canonical Ring relationship endpoints tested

(body,state) and (state,body) indexes:
    0 disagreements

occupied body/state cells:
    7,200

Sun:
    all 360 increasing states
    no decreasing states

Moon:
    all 360 increasing states
    no decreasing states

Mercury through Pluto:
    all 720 directional states

Node:
    720-state behavior confirmed in operational diagnostics
    final canonical DE441 station seal still required
```

Pair chronology:

```text
retained as preferred pair index
```

Per-body Ring endpoint index:

```text
rejected as unnecessary
```

Relationship one-longitude packing:

```text
passed runtime precision test
```

Eclipse normalization:

```text
passed
```

Shell F.R.W.Z derivation:

```text
passed
```

Top-down Horae -> Astrolabe geometry:

```text
passed architecturally
```

---

# XXVI. Important lessons from Rounds 1-4

## Moon

Full exact lunar Ring-contact chronology is Pollux's strong celestial support.

Reduced six-angle Pollux was rejected.

Moon 10-degree Castor support was the Pareto knee.

Full Pollux + Moon 10-degree Castor gave:

```text
sign essentially complete
degree about 99.965% zero-false in the adversarial test
minute about 95.72% with a narrow observed guard
```

Do not turn those observed thresholds into unexplained production constants.

## Other bodies

The slow-body problem is mostly occurrence identity and temporal landmark density, not a need for arbitrarily fine slow-body grids.

Cross-body relationships help identify repeated positions.

## Whole web

The full Ring web is excellent relationally but does not magically replace body coordinate support.

Round 3:

```text
relational-sector resonance about 99.999656%
false relational certifications 0
```

## Pareto

Round 4 removed:

- per-body relationship endpoint index
- operational major/minor split
- duplicate eclipse phase hinge
- independently owned retrograde-passage/crossing truth

Round 4 preserved:

- exact stations
- full chronological Ring stream
- shell owners
- eclipse-specific metadata
- Dioscuri resonance

Venus returned from 2 degrees to 1 degree because reverse chronology/state navigation earned the extra rows.

North Node remains at 0.1 degree + exact topology. Do not invent a special reinforcement subsystem merely to force minute-level resonance.

---

# XXVII. Build order

Proceed in deliberate implementation passes.

## Pass A - repo/owner audit

Inspect:

- current native Timespine-related code
- Pass 5 tools
- P22 data contracts
- shell artifacts
- Ring
- AstroDNA boundaries
- any Chronos/Horae stubs
- tests

Report briefly:

- what exists
- what is obsolete
- what will be reused
- exact files you intend to add/change

Then proceed without waiting for another design conversation unless a material contradiction is found.

## Pass B - core types / coordinate

Implement clean native types for:

- body
- directional state 0...719
- UT/Bone coordinate
- occurrence/reach identity
- exact station topology
- TimespineAddress
- TemporalSlice support types

Centralize state encoding/decoding.

One law, one owner.

## Pass C - canonical manufacture

Build or adapt Hephaestus tooling for:

- selected support densities
- exact stations
- directional reaches
- shadows
- canonical Ring contact normalization
- shell linkage
- eclipse annotations
- three-Z span

Use DE441.

## Pass D - indexes

Implement:

```text
body -> state/reach -> UT
state -> body/reach -> UT
UT -> tract support
pair -> ordered Ring chronology
shell interval -> UT region
```

Do not duplicate entire truth tables just to make indexes.

Especially preserve Sun/Moon 10-degree sparsity.

## Pass E - Chronos

Implement `LOCATE` / navigation.

Chronos should return `TimespineAddress` or ordered candidate addresses.

Test:

- UT jumps
- body/state jumps
- repeated occurrences
- shell jumps
- relationship jumps
- seam behavior

## Pass F - Horae

Implement `SYNCHRONIZE`.

Given fixed UT:

- resolve all eleven bodies
- respect stations/reaches
- derive state + refinement
- attach F.R.W.Z
- attach nearby exact hinges as appropriate
- emit presentation-neutral TemporalSlice

Implement continuous UT-plane movement suitable for playback.

## Pass G - Dioscuri

Wire Pollux and Castor as independent traversal paths.

Test proposition-sensitive resonance.

Zero false resonance required.

## Pass H - Astrolabe projection test

Prove mechanically that a Horae `TemporalSlice` projects to the same top-down celestial geometry expected by the Astrolabe.

Do not make the Astrolabe an owner.

## Pass I - three-Z canonical seal

Run adversarial tests across:

- random UT
- every relevant state crossing
- direct/retro/direct repeats
- stations
- Ring contacts
- shell boundaries
- Z seams
- eclipses
- longest sparse support intervals
- high-curvature regions
- Node pathologies
- reverse state queries

Produce a final certification matrix.

---

# XXVIII. Storage / performance law

The Timespine should feel rich because its structure is well indexed, not because every possible answer is duplicated.

Prefer:

- sparse canonical facts
- compact indexes
- derivable views
- local refinement
- exact structural landmarks

over:

- repeated strings
- duplicate event timestamps
- repeated longitudes
- redundant per-body relationship indexes
- separate truth owners for derived facts

One law, one owner.

---

# XXIX. User-facing query capabilities the build should eventually support

The finished substrate should make these kinds of questions natural:

```text
What is the sky at UT T?

When was Pluto in state 379?

Give me every occurrence of Pluto at this directional state.

What bodies have occupied state 379?

What is the next Moon crossing of this state?

When is the next Mars-Saturn square?

What exact relationship boundary comes next for this pair?

What F.R.W.Z address contains this UT?

Take me to Z22.

Move forward through the Timespine from this occurrence.

Hold Pluto and travel its tract.

Hold state 379 and push through all bodies/time.

Hold UT and let the Horae show the synchronized plane.
```

The architecture should support entering through one coordinate and leaving through another.

That is the practical meaning of the 3D Timespine.

---

# XXX. Working style / safety

This is a real build, but do not bulldoze the repo.

Use branch:

```text
agent/mundane-timespine-3d-build
```

Do not touch:

- other branches
- unrelated Orbo systems
- production owners outside necessary interfaces

Do not create remote workflows.

Prefer local tests.

Keep commits coherent and reviewable.

Do not use astrology glyphs or emojis in source artifacts.

Use plain-text names:

```text
Sun
Moon
Mercury
Aries
etc.
```

Do not repurpose:

- AstroDNA Codec 4
- Ring
- Horizon
- Connectome
- Loom

Preserve:

```text
AstroDNA.codec == 4
```

If a legacy implementation conflicts with this frozen architecture, do not quietly merge the two. Identify the legacy code as superseded or isolate it.

---

# START NOW

Begin by inspecting the `agent/mundane-timespine-3d-build` branch and the frozen build contract.

Then inspect the current Pass 5 implementation/data and give me a concise build-state report:

1. What already exists that belongs in the 3D Timespine.
2. What is legacy/superseded.
3. What canonical DE441 material is already available for Z21-Z23.
4. What is still missing for the final DE441 seal.
5. Where Chronos and Horae should live in the native architecture.
6. The first implementation pass you will execute.

Then begin that first pass on the branch.

Do not redesign the Timespine unless actual canonical evidence forces a specific correction.
