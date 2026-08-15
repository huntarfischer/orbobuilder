# Specs Archaeology · Temporal Core and Spine Evolution

**Status:** archaeology record. Read-only comparison against `specs/Ideal Data Flow - Embryo AstroDNA Connectome Loom.md`. This document does not authorize a rewrite and does not claim that the living application already implements the target architecture.

The purpose of this pass is to answer one question before restoration begins:

> **Which pieces of the intended Embryo → AstroDNA → Connectome → Loom → Spines organism already exist, and in which historical layers did they land?**

The comparison test for every temporal module is:

1. Is it **manufacturing celestial state**? That belongs at the Embryo boundary.
2. Is it **expressing an AstroDNA state**? That belongs to the Connectome.
3. Is it **finding a temporal crossing, perfection or boundary**? That is Loom work.
4. Is it **indexing or materializing results through time**? That is spine work.

A module may currently perform several of these jobs. Archaeology records that fact; restoration will separate ownership later under the Bay Bridge rule.

---

## 0 · Executive finding

The target architecture is not being invented from nothing. **Its pieces already exist, but the Embryo is distributed across three historical objects and the word “spine” has been used for two different things.**

The strongest reconstruction is:

```text
CURRENT HISTORICAL PIECES

_makeSpine() in the DC
    cursor ownership
    + sky-door facade
    + AstroDNA mint door

astrodna.js
    ephemeris acquisition
    + canonical encoding
    + substantial chart expression

mundane.js + embryo.browser.js
    verified universal temporal floor
    + packed finite event backbone

loom.js
    one crossing scanner

fertilize.js
    personal weave materializer/cache

luna.js
    dense-window policy over Loom

progressions.js
    progression mapping + sign-span index

progressed-aspects.js
    progression crossing scanner + hit index

Phase 7 Synchronic Time
    domain-specific chronology on its natural celestial grid
```

The target organism gathers those responsibilities as:

```text
EPHEMERIS
    ↓ private mechanics
EMBRYO
    ├── finite shipped proto-spine
    └── fertilize(address) → physical AstroDNA
                     ↓
                 ASTRODNA
                     ↓
                CONNECTOME
           per-gene expression tables
           relation edges / Forged Ring
                     ↓ targets
                   LOOM
                     ↓
             SPECIALIZED SPINES
```

The most important archaeological discovery is therefore not “replace TimeSpine.” It is:

> **The live spine already contains a prototype of the Embryo’s mint door, while the shipped Embryo already contains a prototype of the universal temporal backbone. Restoration needs to gather those two halves rather than invent either one.**

---

# PART I · THE TWO THINGS CALLED SPINE

## 1 · The live `this.spine` is the cursor-owner and sky facade

The current project convention explicitly distinguishes the live spine from `timespine.js`.

The living doctrine says the DC’s `_makeSpine()` creates `this.spine`, which is the **sole owner of time**: it owns `jd`, live/play/home modes, bounds, and advancement. All UI time movement routes through it.

It also became the application’s only sky door:

```text
spine.at(jd, lat, lon)
    → memoized AstroDNA genome

spine.posAt(jd, lat, lon)
    → decoded instrument-shaped positions

spine.probe(jd)
    → bulk position map for scanners

spine.ascProbe(jd, lat, lon)
    → light horizon probe

spine.bodyProbe(jd, body)
    → light single-body probe
```

This was already a major architectural improvement over readers calling ephemeris functions independently.

### Target comparison

The target architecture reveals that `this.spine` currently combines **two legitimate but separate concepts**:

```text
LIVE CURSOR
owns WHEN
    jd
    advance
    play/home state
    bounds

CELESTIAL PROVIDER
owns WHAT THE CLOCK READS AT THAT WHEN
    at
    posAt
    probe
    ascProbe
    bodyProbe
```

The first remains the live temporal cursor.

The second is the embryonic form of the restored **Embryo API**.

So the correct restoration question is not “does the live spine survive?” It is:

> **Which methods remain cursor responsibilities, and which move behind the Embryo boundary without changing the traffic they currently carry?**

The important positive fact is that `spine.at(...)` already returns **AstroDNA**, not merely a random chart object. The architecture had already started moving toward “Orbo runs on AstroDNA” before the Embryo was named as the owner of that operation.

### Migration implication

Under the target architecture, the conceptual route becomes:

```text
live cursor.jd
      ↓
Embryo.fertilize(jd, place)
      ↓
AstroDNA
```

The cursor owns the address. The Embryo owns the celestial reading at that address.

The existing `probe`, `bodyProbe` and `ascProbe` performance doors need not disappear as optimizations. Their contract changes: they become optimized **Embryo gene/state reads**, definitionally equivalent to the AstroDNA that a full fertilization would produce, rather than alternate ways around AstroDNA.

---

## 2 · `timespine.js` is a different object: an early materialized event spine

`timespine.js` calls itself the “unspool engine.” Its thesis is that the genome is code and the TimeSpine is a one-time expression of expensive temporal events over roughly a lifetime.

It materializes:

- exact transit hits to natal targets
- synchronic-composite hits (`chit`)
- planetary ingresses
- stations

It derives returns and flips as views of those rows and refuses dense Moon events and cASC handoffs.

This is an event-table architecture, not a cursor architecture.

### The module currently owns too many layers

`timespine.js` directly imports `positions` and `bodyLon` from `ephem.js`. It reconstructs a natal target shape from AstroDNA, creates target functions, computes speed, scans ingresses, scans stations, calls the older transit scanner, and finally materializes the event table.

Against the target architecture, its responsibilities separate cleanly:

| Current `timespine.js` work | Target owner |
|---|---|
| physical sky acquisition | Embryo |
| rebuild natal target shape from DNA | Connectome / Forged Ring |
| exact crossing/root finding | Loom |
| ingress/station universal chronology | Embryo proto-spine where universal |
| native-contact event chronology | specialized Contact Spine |
| synchronic chronology | specialized Synchronic Spine |
| sorted event materialization/query | spine/index layer |

That is why `timespine.js` now looks like an **older bundled implementation of several later concepts**, not the future central object.

### What should be preserved

The module contains valuable engineering lessons even if its ownership changes:

- incremental chunking
- overlap at seams
- event-identity deduplication
- phase-locked sample grids
- flat sorted event-table reads
- explicit refusal of high-cardinality event families

Most importantly, its test suite is already proto-Resonator behavior: `tests/timespine.test.html` requires the materialized event table to agree with the live one-shot scan, including event identities and timing, and checks seam deduplication.

So the correct archaeological judgment is:

> **Retire duplicated ownership later, preserve its conformance discipline now.**

---

# PART II · THE EMBRYO ALREADY EXISTS IN TWO HALVES

## 3 · `mundane.js` + `embryo.browser.js` are the temporal half

`mundane.js` already declares itself “the embryo’s source of truth.” Its governing law is exactly the universal-half law now adopted for the target architecture:

- the sky’s own event table
- native-independent
- place-free
- byte-identical for every reader
- shipped with Orbo
- verified once rather than rescanned at runtime where trust matters

The generated `embryo.browser.js` is a finite packed artifact. Its tests establish a 1700–2100 span, windowed decoding, steady event density, canonical eclipse classification, read-time filtering, and parity against fresh live scans.

The shipped artifact therefore already satisfies much of the **proto-spine** concept.

### What it does not yet own

The current Embryo is not yet the full celestial mint.

It does **not** currently own the application-wide operation:

```text
address → AstroDNA
```

That operation is presently distributed between `_makeSpine().at(...)` and `astrodna.js`.

This is the central restoration opportunity:

```text
CURRENT

mundane.js / embryo.browser.js
    = universal temporal backbone

_makeSpine().at + astrodna.js
    = physical moment → AstroDNA

TARGET

EMBRYO
    ├── universal temporal backbone
    └── physical moment → AstroDNA
```

The target Embryo is therefore a **reunion of already-existing ideas**.

---

## 4 · The original “Mundane Spine” became infrastructure larger than mundane astrology

Phase 5 describes the sky thread as the mundane floor and then names the shipped object the Embryo. This matches the historical evolution: a native-independent Mundane Spine was discovered to be useful as the universal thread beneath contact and synchronic chronology.

The target architecture completes that evolution:

> **Mundane astrology reads the Embryo. It does not own the Embryo.**

`mundane.js` is therefore best understood as a historical filename from the first use case of an object whose final ownership is broader.

This is a naming/ownership archaeology finding, not a request to rename the file immediately.

---

# PART III · `astrodna.js` IS BOTH GENOME AND EXPRESSION TODAY

## 5 · `astrodna.js` currently crosses the future Embryo/Connectome boundary

The current module directly imports `positions`, `angles` and other astronomical functions from `ephem.js`. `buildAstroDNA(jd, lat, lon)` then:

1. obtains physical planetary positions and angles,
2. samples neighboring moments to derive motion,
3. encodes the 12-gene sequence,
4. assigns sign, house, element and direction fields,
5. calculates aspects,
6. detects stelliums,
7. calculates elemental balance,
8. derives chart ruler,
9. derives extras and angles,
10. derives sect and the eight Lots.

That was a sensible consolidation step when the goal was “engines decode from AstroDNA rather than each reopening ephemeris.” It is also the clearest evidence that the codebase was already trying to make AstroDNA the internal language.

The target architecture now separates two concepts that this file currently bundles:

```text
EMBRYO
physical celestial acquisition
        ↓
ASTRODNA
canonical identity-bearing clock reading
        ↓
CONNECTOME
what that reading expresses
```

### Target ownership of current `astrodna.js` contents

| Current content | Target classification |
|---|---|
| physical positions/angles acquisition | Embryo |
| canonical 12-gene encoding | AstroDNA encoder |
| position + directional gene state | AstroDNA |
| sign/house/ruler projections | per-gene Connectome tables |
| detailed speed/speed ratio/station state | Connectome motion expression |
| aspects | Connectome relation edges |
| chart ruler/dispositor relationships | Connectome governance |
| stellium/density structures | Connectome relational expression |
| elemental balance | Connectome aggregate expression |
| Lots | state-derived Connectome expression |
| sect | geometric state property available to Connectome/readers |

This does **not** mean that the living `nodes` object should be stripped during the first migration. It means its current fields tell us where the final owners are.

### Important continuity

The current source explicitly says speed, speed ratio and stationarity are “expression levels, not genes.” That matches the architecture now settled by Ean: the genome’s positional/directional combination is already the unique combination lock; detailed motion belongs to the Connectome’s per-gene expression table.

---

# PART IV · LOOM IS THE STRONGEST SURVIVING TEMPORAL PRIMITIVE

## 6 · `loom.js` already has the correct role almost exactly

The living Loom says:

- “the one scanner”
- three layers, one scanner
- layers differ by target set
- there is no synchronic spine inside the scanner
- scanner returns raw roots
- decoration is separate
- no direct ephemeris import in the app path
- the caller injects the sky probe

That is remarkably close to the target architecture.

Its final conceptual contract becomes:

```text
moving AstroDNA / optimized gene reads
            +
meaningful target lattice
            +
finite temporal range
            ↓
           LOOM
            ↓
roots / windows
```

### What changes conceptually

The current injected probe returns naked position maps or body longitudes. The target contract says those reads are semantically **Embryo-produced AstroDNA genes**.

This may not require expensive full-genome construction at each sampling point. The architecture explicitly allows an optimized single-gene door so long as it is definitionally equivalent to the corresponding gene in the full AstroDNA for that address.

### Where target creation should move

Current Loom target builders still come from `framing.js` for floor/contact/synchronic families. The target architecture suggests a later ownership split:

- universal sign/aspect boundaries can be stamped from Ring/Embryo law,
- natal exact contact targets should come from the Connectome/Forged Ring,
- synchronic targets should come from the derived state’s structural expression and doctrine,
- Loom should solve the supplied targets rather than reconstruct why they matter.

The clean law survives:

> **The Connectome knows the target. The Loom finds the crossing.**

---

# PART V · `fertilize.js`: CORRECT MECHANICS, NOW THE WRONG ROOT WORD

## 7 · Phase 5 fertilization means something narrower than the restored Embryo’s fertilization

The current `fertilize.js` defines fertilization as the one-time process that scans and packs the native’s Contact and Synchronic weaves across a century.

It has several strong properties:

- no ephemeris import
- sky arrives through injected probes
- Loom performs the scanning
- chunked generator
- caller owns yielding
- packed byte codec
- read-time cuts rather than rebuilding for every filter
- cache identity separates natal identity / doctrine / codec

Its tests explicitly require a long build to be chunked, preserve a sorted table, round-trip the codec, rebuild derived sign/house/government facts at read, and narrow views without rescanning.

### The semantic collision

The restored architecture now uses **fertilization** at a more fundamental level:

```text
Embryo.fertilize(address)
        ↓
AstroDNA
```

Every physical celestial-state request is a fertilization.

Therefore the current `fertilize.js` no longer owns the root concept. What it actually does is closer to:

```text
materialize personal temporal weaves
pack them
cache them
read them
```

That is spine-materialization/cache work.

This is a future naming/restoration problem, not an immediate rename request.

### Eager synchronic chronology is an older ruling

Phase 5 wanted both Contact and Synchronic century weaves materialized at engraving. Later Phase 7 and the current architectural ruling make the SynchronicSpine lazy on first relevant use.

So the useful parts of `fertilize.js` are its chunking, codec and read strategy. The older “build every synchronic century at natal engraving” policy is historical sediment.

---

# PART VI · THE MOON CONFIRMS THAT SPINE STRATEGY MUST FOLLOW CARDINALITY

## 8 · `luna.js` is not another scanner; it is a temporal cardinality policy

`luna.js` is one of the cleanest modules in the temporal stack.

Its header says the Moon is a **cardinality problem, not a difficulty problem**. Dense Moon families are never century-materialized. Instead, `lunaWindow(...)`:

1. chooses the lunar target family,
2. enforces a maximum read window,
3. invokes the one Loom scanner,
4. decorates the roots,
5. memoizes the requested window,
6. evicts old windows under pressure.

The tests enforce the cardinality rationale and explicitly require that dense lunar work not be materialized by the Loom itself.

### Target classification

`luna.js` does not manufacture a sky and does not own root-finding. It is mostly:

```text
DOMAIN POLICY
    which Moon event family?
    how wide may the query be?

WINDOWED TEMPORAL INDEX
    memoize what was asked
    discard under pressure

STRUCTURAL GROUPING
    switchGroups
```

This means it is already an example of the target principle:

> **A spine may be eager or lazy according to cardinality and use; caching never becomes a second source of truth.**

The Moon proves that “spine” cannot mean “persist every event for a century.” A temporal structure can be a windowed index over the same Embryo/Loom backbone.

### Future target-source cleanup

Natal-contact and synchronic target construction should eventually read the appropriate Connectome/Forged Ring structures rather than rebuilding target meaning inside a lower layer. But the Moon-specific windowing strategy itself is sound.

---

# PART VII · PROGRESSIONS REVEAL A DIFFERENT KIND OF SPINE

## 9 · `progressions.js` already obeys the old single-sky-door law

`progressions.js` is explicitly pure and never imports ephemeris. The caller injects `sample(ageYears)`, which current comments say comes from `spine.progressedAt(...)`.

The module separates:

- progression time mapping (`ageYears`, `progressedJd`, real-JD conversion),
- angle doctrine (Naibod, quotidian, solar arc),
- a one-time scan that stores sign spans for progressed Sun, Moon and Ascendant,
- a read-time exact join for degree values.

It says “TABLE, NOT RECOMPUTE” and deliberately stores sign-resolution spans because finer degree state is cheap to read live.

### Target classification

This file currently contains two species of work:

```text
PROGRESSION DERIVATION LAW
real age → progressed ephemeris address
angle policy → progressed angle state

PROGRESSION SPINE
sign-stamped spans across real life
```

Those should remain conceptually distinct even if one module carries both during migration.

### AstroDNA consequence

Under the target architecture, the physical sky at the mapped progressed ephemeris address comes through the Embryo:

```text
real life jd
    ↓ progression mapping
progressed ephemeris jd
    ↓
Embryo.fertilize(mapped jd, relevant place)
    ↓
physical AstroDNA of mapped day
    ↓ progression doctrine / angle policy
Progressed Derived AstroDNA
```

The progression engine’s public state should eventually be a provenance-marked **derived AstroDNA**, not a bespoke `{Sun, Moon, asc, mc, eps}` sample object.

The sign-span table then becomes a Progression Spine/index over that derived state.

### An architectural question revealed, not settled here

The living progression law says progressed bodies are housed from the **natal Ascendant sign**, while progressed ASC/MC have their own track and do not re-house the bodies.

The new target architecture also establishes that derived AstroDNA may possess its own meaningful horizon and sect.

These statements are not automatically contradictory, but they answer different questions:

- What horizon belongs to the derived celestial state itself?
- Which house frame does a particular progression doctrine use when reading progressed bodies?

The restoration must keep those separate. A derived AstroDNA can carry its own horizon/sect while a progression reader deliberately uses natal whole-sign houses if that is the doctrine. Do not bake that reading policy into the universal definition of derived AstroDNA.

### Cache identity debt

`progressions.tableKey` currently keys from natal JD plus angle doctrine. The target architecture suggests eventual identity should be rooted in AstroDNA identity plus the exact doctrine/logic whose change can alter the table, at the resolution the table actually stores.

This is migration debt, not a current correctness claim.

---

## 10 · `progressed-aspects.js` contains a second Loom because the older boundaries forced it to

This module is especially revealing.

It explicitly refuses to import `transits.js` because transits was considered a lower tier allowed to touch raw ephemeris. To avoid pulling that dependency boundary transitively, it wrote a small independent root-finder.

That was a defensible decision under the old architecture.

Under the restored architecture, it is precisely the duplication that **Loom** exists to remove.

The module currently:

- declares the Alan Leo aspect subset,
- samples a progression grid,
- linearly interpolates body positions,
- scans every progressed-to-natal ordered pair,
- scans every progressed-to-progressed unordered pair,
- bisects exact aspect crossings,
- stamps real-life JD,
- returns a frozen hit table.

### Target decomposition

| Current progressed-aspects responsibility | Target owner |
|---|---|
| which aspects Alan Leo doctrine admits | doctrine / pack engine requirements using Ring marks |
| mapped progressed celestial state | progression derivation → Derived AstroDNA |
| natal positions/targets | natal Connectome / Forged Ring |
| progressed relation targets | progressed Connectome relation lattice |
| exact root finding | Loom |
| shared sample-grid optimization | Loom/provider optimization worth preserving |
| frozen hit list | Progression Aspect Spine/index |

The test suite’s performance guard is important: the whole build should sample the expensive progression provider roughly once per global grid point, not once per body-pair/bisection iteration. A generalized Loom path must preserve or improve this property.

### Ring ownership issue

`progressed-aspects.js` carries ten explicit aspect angles because those are the aspects Alan Leo uses. The *selection* is doctrinal and valid. The geometry should still be admitted from the universal Ring rather than becoming a second aspect die.

The future shape is conceptually:

```text
Alan Leo doctrine
    ↓ chooses Ring marks
Connectome / Forged Ring
    ↓ supplies targets
Progressed AstroDNA through age
    ↓
Loom
    ↓
Progressed Aspect Spine
```

---

# PART VIII · TRANSITS ARE AN EARLIER LOOM

## 11 · `transits.js` is a historical scanner whose injection seam makes retirement safe

The living `transits.js` calls itself a transit ephemeris engine and directly imports `positions` from `ephem.js`. It scans exact partile crossings by sampling residuals and bisecting sign changes.

However, it already accepts `transitPos` as an injected provider.

This makes it a transitional layer rather than a dead end.

The chronological evolution appears to be:

```text
transits.js
    standalone transit root scanner
        ↓
timespine.js
    uses transit scanner + adds other scans/materialization
        ↓
loom.js
    one scanner parameterized by target family
```

The target architecture simply completes that evolution:

```text
Embryo AstroDNA/gene provider
        ↓
Loom
        ↓
Contact / Transit temporal index
```

Any unique numerical behavior in `transits.js` must be carried across by parity tests before retirement. Its direct ephemeris default should not survive as a competing sky authority.

---

# PART IX · PHASE 7 IS THE SPECS TURN TOWARD DOMAIN-SPECIFIC SPINES

## 12 · Synchronic Time stops treating every chronology as one generic event table

Phase 7’s Synchronic Time plan is a major architectural turn.

It says the clock, chronology and synchronic synastry are not three features but one object read at different scales. It identifies duplicate ways to find the same sASC anchor and insists on one principled RAMC conversion path.

Most importantly for spine architecture, it observes that Chronicle already enumerates a natural sequence of celestial frames and discards most of the state it computes. The proposed solo SynchronicSpine is essentially the existing cache widened from:

```text
i → jd
```

to:

```text
i → refracted state
```

The natural sampling grid is not civil midnight. It is the same-Ascendant return grid, because that holds the horizon frame constant across samples.

This is fully consistent with the new general rule:

> **A spine is a domain-specific temporal index of a body of truths, and its natural coordinate/grid should follow the phenomenon rather than a generic sampling cadence.**

### The apparent Phase 5 / Phase 7 contradiction

Phase 5 wanted the Synchronic weave materialized for a century at engraving.

Phase 7 recognizes a more natural synchronic chronology and the current Ean ruling is to mint the SynchronicSpine lazily on first relevant Pisces use.

The reconciliation is:

- static synchronic geometry / Prism constraints may be prepared with the natal field,
- the full temporal SynchronicSpine does not need to exist at engraving,
- when minted, it should use the synchronic phenomenon’s natural celestial coordinate/grid,
- Loom remains available for exact crossings/windows against that chronology.

Later ruling supersedes eager materialization, not the underlying Field Theory relationship.

---

# PART X · THE TEMPORAL ORGANISM WE CAN NOW SEE

## 13 · Reconstructed target flow from the archaeology

The source history supports the architecture now codified rather than fighting it.

```text
                           SHIPPED LAW
             Ring · Tympan · Mater/Rulers
                           │
                           │ references
                           ▼
                       EPHEMERIS
                   private mechanics
                           │
                           ▼
                        EMBRYO
             ┌─────────────┴─────────────┐
             │                           │
      celestial mint              finite proto-spine
  address → physical AstroDNA     universal sky events
             │                           │
             └─────────────┬─────────────┘
                           ▼
                        ASTRODNA
                           │
                           ▼
                       CONNECTOME
               one table per AstroDNA gene
                   + canonical relation edges
                   + Forged Ring lattice
                           │ targets
                           ▼
                         LOOM
                   one temporal solver
                           │
          ┌────────────────┼─────────────────┐
          ▼                ▼                 ▼
       Contact         Synchronic        Progression
        Spine             Spine             Spine
          │                │                 │
          ├────────────────┼─────────────────┤
          │                ▼                 │
          │         Luna window policy       │
          │         where cardinality        │
          │             demands it           │
          │                                  │
          └────────────── shared JD / celestial address backbone
```

ZR and other arithmetic chronologies can join the common time coordinate without pretending to have been produced by the ephemeris.

Electional consumes these structures downstream and must not manufacture another sky.

---

## 14 · The four ownership classes now sort the living temporal files cleanly

| File / object | Manufactures celestial state today? | Expresses state? | Solves crossings? | Indexes/materializes? | Target reading |
|---|---:|---:|---:|---:|---|
| `_makeSpine()` live object | yes, behind its sky doors | partly | some helpers | cursor memo | split cursor ownership from Embryo sky facade |
| `astrodna.js` | **yes** | **yes** | no temporal scan | no long chronology | split Embryo acquisition / AstroDNA encoding / Connectome expression |
| `mundane.js` + shipped Embryo | build-time only through injection | decorates universal rows | delegates Loom | **yes** | core of Embryo proto-spine |
| `timespine.js` | **yes** | rebuilds natal target shape | **yes** | **yes** | historical bundle to decompose |
| `transits.js` | default yes | target functions | **yes** | short hit arrays | older scanner; migrate behavior into Loom path |
| `loom.js` | no | minimal root decoration | **yes** | returns roots/rows | strongest surviving temporal primitive |
| `fertilize.js` | no | read-time row reconstruction | delegates Loom | **yes** | spine materializer/cache; root word “fertilize” now belongs to Embryo mint |
| `luna.js` | no | structural grouping | delegates Loom | window memo | cardinality/window strategy over Loom |
| `progressions.js` | no, injected | progression-derived state/policy | sign-boundary scan | **yes** | progression derivation + Progression Spine currently bundled |
| `progressed-aspects.js` | no, injected | relation selection | **yes, duplicated** | **yes** | move root work to Loom; keep doctrine + progression-index semantics |
| Phase 7 Synchronic cache | no direct authority intended | derived refracted state | crossings elsewhere | **yes** | domain-specific lazy SynchronicSpine |

---

# PART XI · WHAT SHOULD NOT BE “CLEANED UP” PREMATURELY

## 15 · Do not flatten every optimization into full AstroDNA objects

“Orbo runs on AstroDNA” is a contract, not a demand to allocate a 12-gene object for every bisection sample.

The current code correctly discovered that century scanning needs light single-body and bulk-position doors. The restored Embryo can preserve those optimizations so long as:

- they are the Embryo’s doors,
- the returned gene is definitionally identical to that gene in the full AstroDNA at the same address,
- no consumer can use them to establish a competing celestial truth.

This is where the Resonator can sample full-fertilization vs optimized-gene parity.

---

## 16 · Do not force every technique onto one sampling grid

The archaeology shows at least four legitimate temporal shapes:

1. sparse universal sky events in the Embryo,
2. exact target crossings solved by Loom,
3. dense Moon families generated in local windows,
4. natural-domain chronologies such as synchronic return frames or progression age mapping.

The commonality is **authority and address**, not cadence.

Every spine can still share the Embryo’s supported temporal domain/JD addressing without pretending that all phenomena should be sampled at midnight, daily, or on one universal fixed step.

---

## 17 · Do not move doctrine into the Loom

Progressed aspects make this especially clear.

Alan Leo may choose ten Ring marks. Another pack or school may choose five. That selection belongs to doctrine/engine requirements.

Loom receives the admitted targets and finds their crossings.

Likewise, Loom should not decide:

- which bodies count for a technique,
- what is fortunate,
- which house frame a doctrine wants to read,
- whether an orb is admitted for interpretation,
- which event deserves prose.

It is a temporal solver, not an astrologer.

---

# PART XII · RESONATOR OPPORTUNITIES DISCOVERED HERE

## 18 · Existing tests already describe the future regulation points

The temporal tests reveal several durable Resonator checks:

### Embryo regulation

`tests/embryo.test.html` compares the packed shipped artifact against fresh live scans at separated historical/future windows and expects row-for-row agreement within the codec/timing tolerance.

```text
Ephemeris / live Embryo build
            ↕
        Resonator
            ↕
shipped Embryo proto-spine
```

### Materialized-spine regulation

`tests/timespine.test.html` compares chunked materialized transit hits with one-shot live scans and checks seam identity.

```text
live Loom solution
      ↕
  Resonator
      ↕
materialized spine rows
```

### Luna regulation

The lunar test requires dense Moon families to remain absent from the permanent floor while window generation still agrees with the common Loom record contract.

### Progression regulation

Progression tests provide deterministic synthetic state functions with hand-computable sign and aspect crossings. Those are ideal non-ephemeris fixtures for verifying a future progression provider + Loom path.

### Provider regulation

The target Embryo should add a new permanent seam check:

```text
Embryo.fertilize(jd, place).gene(body)
        ==
Embryo.geneAt(jd, body, place)
```

for sampled addresses and bodies.

That is the exact runtime fidelity question created by retaining optimized scan doors while making AstroDNA canonical.

---

# PART XIII · MIGRATION ORDER SUGGESTED BY THE ARCHAEOLOGY

## 19 · The safest Bay Bridge sequence is now visible

This is not implementation authorization. It is the order the archaeology suggests when implementation is later approved.

### Bridge A · name and expose the Embryo mint beside the current spine sky facade

Current traffic remains on `_makeSpine()`.

Build a parallel Embryo provider that can prove:

```text
Embryo.fertilize(jd, place)
        ==
current spine.at(jd, place)
```

at the canonical AstroDNA contract.

Do not change readers yet.

### Bridge B · give Embryo optimized gene/probe doors with parity checks

Prove them against full AstroDNA fertilizations.

Then scanners can move from `spine.probe/bodyProbe/ascProbe` to Embryo-owned equivalents without changing numerical behavior.

### Bridge C · make AstroDNA encoding pure of sky acquisition

Only after Embryo can supply the physical inputs. Preserve the living `buildAstroDNA` path until parity is complete.

### Bridge D · restore Connectome per-gene tables and Forged Ring in parallel

Use current AstroDNA as input. Do not delete the current sign-stay Expression.

### Bridge E · feed Loom targets from the restored Connectome/Forged Ring

Compare against current framing-generated targets and current transit/timespine results.

### Bridge F · migrate specialized spines one family at a time

Suggested order from easiest ownership separation to most doctrinal:

1. universal Embryo floor
2. Contact/Transit crossings
3. Luna windowed families
4. Progression sign spans / progressed aspects
5. SynchronicSpine
6. ElectionalSpine

Each bridge retains the old path until the new path carries the same traffic and Resonator/parity tests agree.

---

# PART XIV · THE ANSWER TO THE ARCHAEOLOGY QUESTION

## 20 · What Ean had already decided that never became one living object

The historical source contains all of these decisions separately:

- one authoritative cursor owns time,
- one door should own sky access,
- AstroDNA should be the genome downstream systems decode,
- the sky has a native-independent shipped temporal floor,
- that floor was named the Embryo,
- Loom should be one scanner rather than separate technique scanners,
- dense Moon chronology should be windowed rather than permanently materialized,
- materialized chronology should equal live derivation,
- synchronic chronology has its own natural celestial grid,
- caches should store the resolution that actually changes the answer.

What never fully crossed into one living architecture was the synthesis:

> **The one sky door belongs to the Embryo; the result of opening that door is AstroDNA; the Connectome unfolds that DNA into targetable structure; the Loom is the one temporal crossing machine; and spines are domain-specific indexes seated on the Embryo’s common temporal backbone.**

The restoration is therefore principally an act of **reuniting decisions already present in the project**.

---

## 21 · Short form

```text
THE LIVE SPINE DISCOVERED ONE SKY DOOR.
THE SHIPPED EMBRYO DISCOVERED ONE UNIVERSAL TIME FLOOR.
ASTRODNA DISCOVERED ONE CELESTIAL LANGUAGE.
THE CONNECTOME DISCOVERED ONE EXPRESSION NETWORK.
THE LOOM DISCOVERED ONE CROSSING MACHINE.
LUNA DISCOVERED THAT CARDINALITY CHOOSES CACHE STRATEGY.
PROGRESSIONS DISCOVERED THAT A TECHNIQUE CAN HAVE ITS OWN NATURAL TIME AXIS.
PHASE 7 DISCOVERED THAT A SPINE IS A DOMAIN CHRONOLOGY, NOT ONE UNIVERSAL EVENT TABLE.

THE TARGET ARCHITECTURE JOINS THOSE DISCOVERIES INTO ONE ORGANISM.
```
