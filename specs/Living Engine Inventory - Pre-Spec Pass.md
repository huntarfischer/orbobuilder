# Living Engine Inventory - Pre-Spec Pass

Status: living-code inventory, before the specifications reconciliation pass.

Date: 2026-08-15.

Purpose: record what Orbo's current engines and tests actually know, where each truth lives, at what resolution it changes, which facts are persisted or recomputed, and which architectural questions must be carried into the specs pass before Connectome Restoration is designed or coded.

This document is deliberately NOT the restored Connectome specification.

The order of work is:

```text
1. living engine inventory
2. specifications pass
3. reconciled Connectome Restoration design
4. State / Derived State / Relation / Event / Span taxonomy
5. Transit contract pass
6. ElectionalSpine design
7. code, using the Bay Bridge migration rule
```

No engine is to be rewritten from this inventory alone.

---

# 0. The inventory question

For every fact Orbo currently knows, ask:

```text
What kind of truth is this?
Who owns it now?
At what resolution does it change?
Is it inherent, engraved, derived, relational, or temporal?
Is it persisted, memoized, materialized, or recomputed?
Which engines consume it?
Is another engine independently deriving the same fact?
Is there a test proving the invariant?
Could a repeated derivation instead be an invariant forged once?
Does Alan Leo or another operational doctrine require a fact Orbo cannot currently address directly?
```

This is the lens for the later Connectome Restoration.

---

# 1. Resolution ladder visible in the living code

The current codebase already contains a multi-resolution architecture even though the word Connectome currently names only one layer of it.

```text
UNIVERSAL / INHERENT
    Ring marks and target geometry
    Mater sign law
    Tympan whole-sign frames
    Rulers pointwise dignity tables

ENGRAVED FINE STATE
    AstroDNA arcsecond positions
    natal motion / velocity
    sect, angles, lots, extras

POINTWISE
    exact degree
    bound
    face
    triplicity
    exact dignity ladder

SIGN-STAY
    sign
    house under a chosen Tympan
    bearer
    dispositor path
    keeper
    receptions
    agency / light / charged
    house routing

RELATIONAL
    aspects
    applying / separating state
    cross-chart receptions and handoffs
    synchronic pair families

TEMPORAL
    ingress
    station
    exact contact
    synchronic contact
    progression segment
    ZR period
    Moon window
    future SynchronicSpine state
```

The important existing law is already visible:

> A cached representation should be keyed at the resolution at which its contents can actually change.

AstroDNA can remain exact while a sign-stay expression is memoized by signs, and a century event artifact can use a coarser key if sub-degree changes cannot alter its stored result.

---

# 2. Inherent and stamped engines

## 2.1 `ring.js`

### Current role

Universal degree geometry. It imports nothing and knows no native.

It owns:

```text
MARKS
coarse 0-719 state encoding
fine arcsecond state encoding
separation
arc
exact / nearest relation
targetDegree / targetStates
universal stamped target plate
```

The eleven Ring marks are:

```text
0 30 45 60 72 90 120 135 144 150 180
```

### Resolution

The die remains 360 whole-degree rows because every admitted mark is a whole-degree division. Occupants can be addressed at arcsecond precision without making the universal die itself larger.

### Important invariants already tested

`tests/ring.test.html` checks, among other things:

```text
all eleven marks
perfect whole-degree lattice
fine-to-coarse projection
motion-blind relation geometry
0 as a valid conjunction value
null as absence
target directedness
immutability of the stamped plate
input validation
```

This is one of the strongest existing examples of Orbo separating the resolution of the law from the resolution of the occupant.

### Connectome relevance

The Ring should remain universal. A restored Connectome should expose its results without absorbing or duplicating its geometry.

### Forged Ring relevance

The Ring is the source from which a natal-specific geometric lattice can be forged. See Section 11.

---

## 2.2 `mater.js`

### Current role

Universal sign law and sign meaning.

It owns:

```text
sign names
sign elements
modalities
traditional domicile rulers
signs ruled by each traditional planet
exaltation
exaltation degree
sign-level detriment / fall
modern co-ruler declarations as a separate structure
```

### Resolution

Sign.

### Important architectural law

Traditional rulership and modern co-rulership are structurally separate. Modern rulers do not enter the traditional `RULERS` / dispositor path accidentally.

### Connectome relevance

Mater remains a stamped source. Sign-stay Connectome expressions consume it.

---

## 2.3 `tympan.js`

### Current role

The twelve whole-sign frames and the reverse governance index.

The source explicitly calls the Tympan an inherent member of the Connectome family, like the Ring and Mater.

It owns:

```text
frame + sign -> house
frame + house -> sign
house -> traditional ruler
planet -> houses governed under a frame
modern co-ruler house index, separately
frame records
six-house flip relation
```

### Resolution

Frame sign plus sign / house ordinal.

It contains no native, time, place, aspect, orb, sect, lots, bounds, faces, or house interpretation.

### Tests

`tests/tympan.test.html` pins all 144 forward and reverse cells, governance indexes, modern separation, error contracts, immutability, and the six-house flip relation.

### Architectural precedent

The Tympan is important for future design because it proves that a frequently re-derived relationship can deserve its own stamped object rather than being recalculated by every consumer.

---

## 2.4 `rulers.js`

### Current role

Pointwise traditional dignity law below sign resolution.

It owns:

```text
lordOf
exaltation facts
Egyptian bounds
Chaldean faces
Dorothean triplicity rulers
five-rung dignity ladder
peregrine / debility facts
```

### Resolution

Degree or sub-sign boundary, plus sect for triplicity.

### Important refusal

`rulers.js` explicitly refuses to score dignity. It reports the separate facts and leaves weighting to judgment / doctrine.

`tests/rulers.test.html` enforces this with a source grep for score / rank / almuten style logic.

### Inventory finding

This makes the dignity point tables still typed inside `electional.js` especially important for the specs pass. The living system currently has a clean canonical fact owner in `rulers.js` and a separate older scoring implementation in the electional engine.

No change is made here yet.

---

# 3. Celestial source and engraved identity

## 3.1 `ephem.js`

### Current role

Numerical sky generator.

It supplies celestial positions, angle geometry, body-specific positions, time conversion, and the astronomical primitives from which AstroDNA and the live instrument are built.

### Resolution

Continuous numerical astronomy, within the accuracy of the implemented ephemeris.

### Boundary

Downstream architecture increasingly tries to keep raw ephemeris behind a single sky door or injected probe rather than letting every reader import it.

---

## 3.2 `astrodna.js`

### Current role

Canonical engraved celestial identity plus the full decoded expression of the natal moment.

The 12-gene order is:

```text
Ascendant
Moon
Sun
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
Node
```

The Node gene is the mean node. The instrument's flattened extras retain the osculating node under the display key.

### Fine identity

Each gene is a Ring fine state at arcsecond precision.

```text
0..1,295,999       direct half
1,296,000..2,591,999 retrograde half
```

`sequence` is the fine identity.

`degreeSequence` is the whole-degree projection for artifacts whose truth does not need the fine address.

### Current node expression

Each node currently carries:

```text
longitude
sign
signIndex
degreeInSign
house
isRetrograde
element
numericalValue
state
dms
source
speed
speedRatio
isStationary
```

### Natal velocity is already present

This is a major inventory result.

The current AstroDNA build calculates and stores a signed natal speed in degrees per day by centered finite difference. It also records normalized speed and station status.

```text
speed
speedRatio
isStationary
```

The source explicitly classifies these as expression levels rather than genes.

This distinction is sensible: velocity does not need to be packed into the identity integer in order to be a canonical fact of the engraved state.

### Tests

`tests/astrodna.test.html` verifies:

```text
node longitudes exactly match ephemeris output
genes re-encode through Ring fineStateOf
fine -> coarse projection
retrograde flag agrees with speed sign
speed is present and sane
speedRatio is finite
angle and extra-body parity
mean-node gene / osculating display boundary
small timestamp motion changes fine identity before coarse artifact key
```

### Restoration requirement carried forward

The later architecture must preserve natal velocity as part of the engraved expression and make it directly reachable downstream.

A consumer should not need to reopen the birth ephemeris merely to rediscover how quickly natal Venus was moving.

---

# 4. Regulatory graph and current Connectome

## 4.1 `dispositor.js`

### Current role

Generic sign-map walker.

Input:

```text
{ occupantName: signIndex, ... }
```

It does not require a genome and therefore works for natal, moment, synchronic, composite, and other occupant sets.

It owns:

```text
bearer
path
keeper
terminal kind
cycles
receptions
cross-set receptions
cross-set one-step handoffs
```

### Resolution

Sign.

### Node classes

Only the traditional seven can be bearers. Other bodies, angles, points, nodes, lots, and moderns can be disposed but do not become outgoing rulers in the traditional graph.

### Terminal shape

A fixed point is a one-member cycle, not a special exception.

```text
length 1 -> domicile
length 2 -> mutual-reception
length 3+ -> dispositor-loop
```

`keeper` is consistently `{ kind, id }`.

### Tests

`tests/dispositor.test.html` checks fixed points, cycles, incomplete frames, leaves, reception types, stable cycle IDs, real-genome projection, and cross-set relationships.

---

## 4.2 `connectome.js`, current implementation

### Current role

A sign-resolution compiler / join over:

```text
occupant-to-sign map
+
Tympan selector
+
sect
```

Current entry point:

```text
express(occupants, ascSignIdx, sect, meta)
```

### Current output

```text
planetTable
houseTable
chains
cycles
houseChains
houseCycles
receptions
agency
light
charged
frame
indexes
metadata
```

Indexes include:

```text
planetByName
houseByNumber
chainByPlanet
cycleByPlanet
planetsDisposedByPlanet
descendantsByPlanet
housesRuledByPlanet
housesRoutingToHouse
```

### Current resolution law

The current `Expression` intentionally carries no longitude, exact degree, retrograde state, aspects, lots, bounds, faces, or velocity.

Its memo key is the frame vector:

```text
ascendant-frame selector
+
ordered occupant signs
+
sect bit
```

This is a good optimization for this layer because the whole expression remains unchanged until a sign, frame, or sect changes.

### Critical distinction for restoration

The current sign-stay `Expression` is a valid and useful tissue of the Connectome.

It should not be inflated into a per-sample exact object merely to satisfy the broader conceptual meaning of Connectome.

The restoration problem is therefore not:

```text
put every field into connectome.js
```

It is:

```text
restore Connectome as the comprehensive retrievable map
while preserving this sign-resolution Expression at its correct resolution
```

### Tests

`tests/connectome.test.html` actively enforces the current narrow contract. It greps the source to refuse longitude, time, genome, Ring/aspects/orbs, lots, bounds/faces/triplicity, and interpretation words.

Those tests are not evidence that the broader Connectome concept must remain narrow. They are evidence that the current sign-stay layer must remain narrow.

Under the Bay Bridge migration rule, the restored Connectome must be built beside this working implementation and prove parity for this layer before consumers move.

---

# 5. Motion and velocity audit

Velocity deserves its own inventory because several systems use motion in materially different ways.

## 5.1 Engraved natal motion

Canonical current source:

```text
AstroDNA.nodes[body].speed
AstroDNA.nodes[body].speedRatio
AstroDNA.nodes[body].isStationary
```

This is the value that should survive engraving and be available to the later Connectome.

## 5.2 Current live/event motion

Different engines also derive motion for legitimate local purposes:

### Loom root velocity

`loom.js` records the slope at an exact root as `v` and uses it to derive event windows.

This is event-relative motion at the crossing, not natal velocity.

### Station scans

`timespine.js` calculates live body speed around a JD to locate station sign changes.

This is temporal root-finding, not a replacement for engraved natal speed.

### Synchronic speed

`framing.js` defines synchronic speed as half the body speed.

### Electional / synchronic synastry

`electional.js` contains a `speedModel` that currently calculates:

```text
natalSpd
transitSpd
compSpd = (natalSpd + transitSpd) / 2
filmSpd = transitSpd / 2
```

This is structurally important because applying / separating state and synchronic synastry use these values.

### Inventory discrepancy

Although AstroDNA already stores natal speed, `electional.speedModel()` currently recomputes natal speed from raw ephemeris and caches it on `natal._spd`.

That is exactly the kind of repeated derivation the specs pass must examine.

The desired architectural question is:

```text
Should natalSpd be read from the engraved AstroDNA expression
rather than regenerated from natal.jd?
```

Given the stated requirement that natal velocity survive engraving and affect synchronic work, this is a high-priority reconciliation item.

No code change is made in this inventory.

---

# 6. Temporal engines

## 6.1 Live instrument spine

The assembled app has a live spine that owns the current celestial cursor and the app's sky access.

This is conceptually distinct from the file `timespine.js`.

Planet scrubbing changes celestial time and the instrument rereads the sky.

## 6.2 `timespine.js`

### Current role

Century-scale materialized sparse event index.

Materialized kinds:

```text
hit
ochit / synchronic-composite hit
 ingress
station
```

Cheap derived views include returns and flips.

Dense Moon events and frequent cASC handoffs are deliberately refused.

### Resolution

Event hinge time plus compact event identity.

### Tests

`tests/timespine.test.html` states the central conformance law directly:

> the materialized expression must equal the live one

It compares chunked materialized hits against a one-shot live transit scan, checks seam deduplication, station cadence and alternation, returns, synchronic-composite geometry, incremental unspooling, and slicing.

### Resonator relevance

This test is already a model of resonance: a cached / materialized representation is checked against an independent live derivation of the same truth.

### Specs-pass question

The current synchronic-composite target is locally expressed with midpoint arithmetic. The newer architecture has a declared single `framing.refract` door. Whether this should be rerouted or whether the import boundary intentionally justifies a local algebraic equivalent must be decided in the specs pass, not guessed here.

---

## 6.3 `loom.js`

### Current role

The one root scanner for three layers:

```text
floor
contact
synchronic
```

It accepts injected probes and does not import the ephemeris on the app path.

### Resolution

Continuous root-finding over a target degree or relative separation.

### Current root shape

```text
{ target, jd, v, retro }
```

Decoration then produces richer event records.

### Important law

For synchronic occupants, Loom uses `framing.refract`, so it already honors the one refraction door.

### SynchronicSpine relevance

The source explicitly says there is no SynchronicSpine in Loom. The synchronic layer is currently another target set scanned through the same root engine.

That is current implementation, not proof that the planned cached SynchronicSpine is unnecessary.

---

## 6.4 `mundane.js`

### Current role

Native-independent, place-free floor chronology, including verified eclipses.

The shipped mundane table exists for trust and verification, not because the ephemeris itself is unavailable.

### Resolution

Temporal events across the shared sky.

### Architectural significance

It is a clear example of an artifact worth materializing because it can be verified once and reused for everyone.

---

## 6.5 `fertilize.js`

### Current role

Builds century CONTACT and SYNCHRONIC event weaves from the native and the common sky floor.

### Important distinction

The current synchronic weave stores synchronic events / crossings. It is not the same object as the planned SynchronicSpine of cached refracted states.

This distinction must remain explicit during the specs pass.

### Cache law

The weave key uses a deliberate coarse projection of natal identity plus doctrine and codec.

### Materialization law

Build generously at the widest admitted settings and filter at read time so a reader preference does not force century rebuilds.

---

## 6.6 `luna.js`

### Current role

Dense Moon window generator.

The code names the core problem correctly: Moon chronology is a cardinality problem, not a difficulty problem.

The Moon's dense mutual, contact, and synchronic events are generated for requested windows and memoized under pressure rather than materialized for a century.

### Architectural significance

A restored Connectome must not become an excuse to cache everything forever.

Different temporal facts deserve different storage strategies based on density, horizon, and cost.

---

# 7. Synchronic field inventory

## 7.1 `framing.js`

Current responsibilities include:

```text
midpoint
refract
phase
axis
permitted arc
synchronic orb scaling
frame construction
flip geometry
synchronic target algebra
```

The declared refraction law is:

```text
refract(natalLon, momentLon) = midpoint(natalLon, momentLon)
```

For a fixed natal placement, the result is confined to a 180-degree range.

### Velocity

`framing.synSpeed(bodySpeed)` returns half the source body speed.

### Inventory discrepancy: lots

`framing.js` still contains a seven-Lot arithmetic function, and `electional.js` imports and uses it.

At the same time, `astrodna.js` declares the eight-Lot set and `tests/lots.test.html` describes AstroDNA as the one formula / one place for the eight lots, with `zr.js` delegating to it.

This is a concrete specs-pass reconciliation item.

The first seven formulas may currently agree numerically, but two formula owners are still two formula owners.

Do not remove either path until the living call sites and intended sect behavior are reconciled.

---

## 7.2 `prism.js`

### Current role

Permanent natal-dependent synchronic structure.

It currently records:

```text
permitted 180-degree arcs
arc segments
reachable signs
unreachable signs
reachable houses
reachable lords
segment boundaries
whether government changes at a boundary
same-body two-native pair families
sASC itinerary
ascension template
real stretch durations by latitude
walk / sigma coordinate
```

### Tests

`tests/prism.test.html` heavily verifies this structure against live geometry.

Especially important:

```text
every permitted arc tiles 180 degrees
reachable-set tables agree with thousands of live refracted samples
same-body pair families stay invariant against the real sky
cross-body pairs do not falsely acquire a fixed family
sASC itinerary and ascension template agree with geometry
```

### Clarification for the later specs pass

The current Prism phrase "synchronic timespine, fixed at engrave" refers to the permanent structural template.

The planned cached SynchronicSpine of refracted states should be lazy-built on first use by the Pisces domain, analogous to ZR's lazy construction behavior.

These are different objects and must not be collapsed.

### Range law

The finite permitted range is more fundamental than the flip. A flip is one seam in the range.

This needs to be carried into any future SynchronicSpine contract.

---

# 8. Progressions and Alan Leo

## 8.1 `progressions.js`

### Current role

Secondary progression chronology for Sun, Moon, and progressed angles.

It stores sign-level segments across a life and joins exact degree at read time.

### Resolution

Stored:

```text
sign spans
```

Read live:

```text
exact longitude
```

### Doctrine

Progressed angle policy is explicit:

```text
naibod
quotidian
solarArc
```

The method is not silently chosen.

### Tests

`tests/progressions.test.html` verifies time conversion, angle policies, sign segment tables, natal-frame housing, and doctrine-sensitive table keys.

---

## 8.2 `progressed-aspects.js`

### Current role

Operational event engine based explicitly on Alan Leo's progressed-horoscope methodology.

### Why this matters to Connectome Restoration

This file demonstrates the distinction between:

```text
what facts / events an astrologer's methodology asks Orbo to find
```

and:

```text
what prose the astrologer writes about those valid events
```

Leo's methodology currently determines an admitted aspect set and pair-scanning rules.

The engine scans:

```text
progressed A -> natal B, ordered, including own-place contacts
progressed A <-> progressed B, undirected once per pair
```

### Aspect set

It carries ten Leo-used aspects, excluding the Ring's 144-degree biquintile and separately deferring declination parallel because parallel is not a Ring mark.

### Tests

`tests/progressed-aspects.test.html` verifies synthetic exact ages, directionality rules, unique mutual pair storage, hit windows, and the performance rule that the expensive sample grid is shared rather than recomputed per pair.

### Inventory use of Alan Leo

During the specs pass, the Alan Leo canon should be used as a requirements probe:

```text
What celestial or structural fact does Leo require?
Can the living system address it directly?
If yes, who owns it?
If no, is a Connectome expression, Forged Ring invariant, temporal index, or new stamped frame missing?
```

Leo should not be put inside the Connectome as meaning. His work helps reveal which nerves the system must expose.

---

# 9. Zodiacal Releasing

## `zr.js`

### Current role

Pure zodiacal period chronology from AstroDNA Lots.

It computes:

```text
L1-L4 periods
Loosing of the Bond
true-angle peaks
Brennan-self peaks
peak overlap views
```

### Fundamental row

```text
{
  signIndex,
  sign,
  startJd,
  endJd,
  durationDays
}
```

This is naturally a temporal SPAN rather than a point event.

### Important law

ZR uses zodiacal time arithmetic first. Civil date is display.

This aligns directly with the newer celestial-to-civil conversion doctrine.

---

# 10. Electional inventory

## `electional.js`

This is currently one of the most architecturally mixed engines in the repo and should therefore be studied rather than immediately cleaned up.

It currently contains:

```text
traditional dignity tables
Lilly-style dignity scores
sect weights
house accidental scores
motion scoring
combustion thresholds
aspect grading
Moon / VOC logic
activity profiles
Lots
fixed stars
Field Theory checks
arc-bound reachability
synchronic speed model
synchronic synastry
final weighted aggregation
```

### Current output

A moment assessment currently resolves to a shape like:

```text
{
  t,
  score,
  veto,
  outcome,
  cAscSign,
  actorSig,
  drivers
}
```

### High-priority inventory findings

#### A. Dignity law is duplicated

`rulers.js` now owns bounds, faces, triplicity, and the uns cored dignity ladder.

`electional.js` still types its own bounds, faces, triplicity, exaltation, and point values.

This may reflect an older implementation predating the Rulers rewire.

The specs pass must decide the correct seam between:

```text
canonical dignity facts
```

and:

```text
electional doctrine weights / scores
```

#### B. Natal velocity is recomputed

As noted in Section 5, the electional speed model recomputes natal body speed from ephemeris even though AstroDNA already engraved it.

This is directly relevant to synchronic synastry.

#### C. Reception is locally approximated

`scoreMomentV2` contains a local reception helper based on ruler chains and a visibility-style test instead of consuming the Dispositor / Connectome's existing reception structures.

This is another question for the specs pass.

#### D. Lots use the framing copy

Electional scoring calls `framing.lots`, while the AstroDNA / ZR path declares one canonical eight-Lot formula set.

#### E. No dedicated `tests/electional.test.html` is present in the current tests directory

Electional behavior may be exercised indirectly from the app or older tests, but unlike Ring, AstroDNA, Connectome, Prism, TimeSpine, Rulers, Progressions, and Progressed Aspects, there is no dedicated current electional conformance suite visible in the copied repository.

That makes ElectionalSpine redesign a particularly good candidate for the Bay Bridge method plus a new parity harness before traffic moves.

---

# 11. Candidate derived object: Forged Ring / natal lattice

Status: candidate for the specs pass. Not currently implemented as a named engine.

The universal Ring answers:

```text
What relationships can any degree have to any other degree?
```

A Forged Ring would be derived once from:

```text
Universal Ring
+
engraved AstroDNA
```

and answer:

```text
What exact Ring target degrees belong permanently to this nativity?
```

Example:

```text
natal Venus = 9°49'17" Aries

trine targets:
  9°49'17" Leo
  9°49'17" Sagittarius

square targets:
  9°49'17" Cancer
  9°49'17" Capricorn

opposition target:
  9°49'17" Libra
```

### Why `Lattice` remains useful language

The Forged Ring is a personal lattice of exact target coordinates generated from universal geometry.

It is derived, chart-specific, finite, and permanent for the engraving.

### What should NOT be forged into it by default

```text
orb
benefic / malefic judgment
importance
score
interpretive prose
```

Those are doctrine or reading concerns.

### Possible indexes

The specs pass should evaluate both directions:

```text
by occupant:
  targetsOf(Venus, 120)

by celestial coordinate:
  resonancesAt(129°49'17")
```

### Potential consumers

```text
transit target solving
TimeSpine
progressed contacts
celestial-range electional solving
Resonator checks
Connectome retrieval
```

### Important caution

The current Ring already calculates these targets cheaply. The question is not whether the math can be recomputed. The question is whether a forged per-natal index improves the architecture, temporal solving, and retrieval enough to deserve permanent derived storage.

That decision belongs to the specs pass.

---

# 12. Resonator inventory

Status: concept to reconcile with living tests and cache behavior before formal design.

The Resonator should not be confused with a second copy of the Connectome.

Working distinction:

```text
Ring          = universal law
Forged Ring   = personal geometric lattice
Connectome    = comprehensive nervous-system map
Resonator     = fidelity / regulation
Spines        = temporal backbones
```

## 12.1 Proto-Resonator behavior already exists

The codebase contains many independent checks where one representation is verified against another.

### Ring projection checks

Fine state must project exactly to coarse state.

### AstroDNA conformance

```text
stored longitude == ephemeris longitude
encoded gene == Ring fineStateOf(longitude, retro)
retrograde flag == sign of velocity
DMS == decomposition of the gene
```

### TimeSpine conformance

Materialized chunked events must equal live one-shot scanning.

### Prism conformance

Stored reachable sets and pair families are compared against thousands of live refracted samples.

### Rewire parity harness

`tests/rewire-parity.test.html` reads source files themselves and verifies that duplicated angle tables have actually been replaced by Ring-derived structures rather than merely agreeing by accident.

It also contains a crucial lesson: source greps once all passed while the assembled app did not parse. The harness therefore added an explicit compilation check.

This is Resonator thinking already:

> an invariant stated in a comment is not an invariant until another mechanism can prove it.

## 12.2 Candidate permanent Resonator relationships

The specs pass should inventory reciprocal checks such as:

```text
fine AstroDNA -> coarse projection
velocity sign <-> retrograde state
velocity magnitude <-> speedRatio / stationary state
AstroDNA sign <-> floor(longitude / 30)
Forged Ring target <-> universal Ring target calculation
cached SynchronicSpine value <-> live framing.refract sample
materialized event <-> live root solve
persisted codec <-> current codec / shape
browser mirror <-> source module
```

## 12.3 Resonator is not Bay Bridge

Bay Bridge is temporary migration infrastructure.

Resonator is permanent regulation.

A Bay Bridge comparison may eventually be removed when the old span is demolished. A Resonator check remains because its job is to detect future drift or stale derived state.

---

# 13. Test census and what the tests reveal

The copied repo contains a substantial test surface.

The core `_suite.html` aggregates the principal engine tests including Ring, Mater, Tympan, Dispositor, Connectome, Rulers, TimeSpine, Loom, Loom Algebra, Prism, Mundane, Embryo, Fertilize, Luna, Lots, AstroDNA, and Rewire Parity.

Additional tests in the directory include Progressions, Progressed Aspects, Lunar Port, depth contracts, explanation corpus, AAF, ephemeris, three-global-min, and others.

The tests are not merely unit verification. Many of them document architecture more precisely than prose comments do.

Recurring test laws include:

```text
one canonical owner
one projection path
absence is null
0 is a real value
malformed addresses throw
stamped structures are frozen
chunked build == one-shot build
stored table == live geometry
source and browser mirror must agree
new doctrine must not silently alter geometry
```

For the specs pass, tests should therefore be treated as a third source alongside:

```text
living source code
written specifications
test-enforced invariants
```

When all three disagree, the disagreement must be made explicit rather than silently choosing one.

---

# 14. Current duplicate / re-derivation register

This is not a bug list. It is a list of places the specs pass must reconcile.

| Fact | Canonical-looking owner | Other current derivation | Question for specs pass |
|---|---|---|---|
| natal body velocity | AstroDNA node expression | `electional.speedModel` reopens natal ephemeris | Should all downstream natal-motion reads consume engraved velocity? |
| bounds / faces / triplicity / dignity facts | `rulers.js` | `electional.js` carries local tables and scores | Which layer owns fact vs judgment? |
| Lots | `astrodna.js` eight-Lot formula set | `framing.js` seven-Lot function used by electional | Can all consumers route through one formula family while preserving synchronic sect law? |
| synchronic refraction | `framing.refract` | some temporal engines use local midpoint algebra | Is one-door law universal or tier-limited by dependency constraints? |
| natal target geometry | universal Ring + natal degree at runtime | transit scanners repeatedly solve against target chart | Does a Forged Ring lattice deserve materialization? |
| sign projection | AstroDNA already exposes signIndex | callers often reduce longitudes independently for generic states | Should restored Connectome provide one generic projection service without making every derived state pass through natal AstroDNA? |
| reception | Dispositor / current Connectome | electional has local reception logic | Is electional's rule actually a different doctrine, or duplicated structure? |
| synchronic chronology | event weave exists | planned SynchronicSpine state cache not built | Which current artifacts remain, which become readers of the new spine? |

This table should expand during the specs pass.

---

# 15. Resolution matrix for Connectome Restoration

This is the initial living-code matrix, not the final restored contract.

| Truth | Current owner | Natural resolution | Changes when | Current storage strategy | Important consumers |
|---|---|---:|---|---|---|
| celestial longitude | AstroDNA / live spine | arcsecond or float | continuously | engraved natal; live moment | instrument, all techniques |
| natal velocity | AstroDNA | continuous | fixed for engraving | node expression | synchronic/electional/synastry |
| retrograde state | AstroDNA / Ring encoding | directional | station | engraved flag / event | instrument, condition logic |
| sign | AstroDNA projection / Mater arithmetic | sign | ingress | engraved + recomputable | Connectome, houses, doctrine |
| house | AstroDNA natal; Tympan lookup for generic frame | sign/frame | sign or frame handoff | derived | readers, Connectome |
| universal aspect target | Ring | whole-degree mark applied to precise source degree | never for given source coordinate | calculated from stamped law | Loom, Transit, future Forged Ring |
| exact natal resonance target | not named yet | natal fine coordinate | never after engraving | currently recomputed | future Forged Ring candidate |
| bound | Rulers | sub-sign boundary | bound crossing | table lookup | electional / doctrine |
| face | Rulers | 10-degree | decan crossing | table lookup | electional / doctrine |
| triplicity lord | Rulers | sign + sect | sign or sect | table lookup | doctrine |
| bearer | Dispositor / Connectome | sign | ingress | sign-stay compile | natal, synchronic, electional |
| path / keeper | Dispositor / Connectome | sign-vector | any governing sign change | sign-stay compile | structural readers |
| reception | Dispositor / Connectome | sign-vector | relevant sign change | sign-stay compile | interpretation, electional |
| applying/separating | local technique logic | exact position + relative speed | continuously / perfection | recomputed | electional, synastry |
| transit exact hit | Transits / TimeSpine | event hinge | perfection | scan or materialized | Almanac/readers |
| ingress | Loom/TimeSpine/Mundane | event hinge | boundary | materialized by horizon | temporal readers |
| station | Loom/TimeSpine | velocity zero | station | materialized | temporal readers |
| ZR period | ZR | span | period boundary | arithmetic table | timing |
| progressed sign | Progressions | span | progressed ingress | table | progressions readers |
| progressed aspect | Progressed Aspects | event hinge | perfection | table | Leo progression layer |
| synchronic reachable set | Prism | natal-dependent invariant | never after engraving | permanent table | Pisces / field theory |
| synchronic state through time | live refraction today | exact refracted state | continuously | repeated live computation / event weaves | future SynchronicSpine |
| dense Moon contacts | Luna | local window | continuously | bounded memo | lunar readers |

---

# 16. Candidate new stamped / forged structures

The inventory must remain open to the possibility that a repeated truth deserves a new table rather than being stuffed into an existing engine.

A candidate deserves consideration when it is:

```text
stable
reused broadly
mathematically well-defined
repeatedly re-derived
not already owned cleanly
valuable to query in more than one direction
```

Current candidates:

## Forged Ring

Natal-specific exact Ring lattice, derived at engraving from the universal Ring and AstroDNA.

## Synchronic permanent geometry

Much of this already exists correctly in Prism. The specs pass should determine whether Prism remains the owner or whether some of its permanent tables become a named Connectome tissue.

## Resonator registry

Potential registry of invariants and reciprocal derivations. This would not own astrology facts. It would know how to verify that derived representations still agree with their canonical sources.

No additional frame should be invented merely for symmetry. The inventory is a search for missing ownership, not a quota of new objects.

---

# 17. What the specs pass must now do

The next phase is not coding.

For each relevant spec / Phase document, compare it against this inventory and classify every major promise as:

```text
BUILT AS SPECIFIED
BUILT DIFFERENTLY
PARTIALLY BUILT
BUILT THEN SUPERSEDED
DEFERRED EXPLICITLY
PLANNED BUT NEVER BUILT
CONTRADICTED BY LATER DOCTRINE
STILL VALUABLE BUT NEEDS NEW OWNER
```

High-priority reconciliation questions are already visible:

1. Was the broader multi-resolution meaning of Connectome ever specified before implementation narrowed `Expression` to sign resolution?
2. What portions of the old Regulatory Snapshot model belong to the restored Connectome, if any?
3. Which exact natal expressions are supposed to survive engraving and persistence, especially velocity?
4. Does a Forged Ring / natal lattice fit an already-described architecture under another name?
5. What was the intended role of the Resonator, if it appears in prior notes or specs?
6. Which current duplicate formula paths are deliberate dependency boundaries and which are unfinished rewires?
7. How should the planned lazy SynchronicSpine coexist with the current synchronic event weave and Prism's permanent structure?
8. Which Alan Leo operational rules require structural addresses Orbo does not yet expose?
9. Which current `doctrine` keys affect calculation, cache identity, judgment, provenance, or interpretation, and where have those meanings been conflated?
10. Which tests represent final laws and which pin an implementation that later doctrine intentionally superseded?

---

# 18. Gate before Connectome Restoration design

Connectome Restoration design begins only after the specs pass produces a reconciled map.

At that point the design must answer, at minimum:

```text
What is the public Connectome query surface?
Which expression families exist?
Which existing engine remains canonical owner of each fact?
Which facts are indexed by the Connectome rather than copied into it?
Which caches exist at which resolutions?
What is persisted for a natal engraving?
What is lazy-built?
What is materialized by horizon?
What remains live arithmetic?
Does the Forged Ring become a first-class derived object?
What does the Resonator verify and when?
How does SynchronicSpine attach?
What new table, if any, is truly missing?
```

Then, and only then, the Bay Bridge build can start beside the current working Connectome.

---

# 19. Current strongest conclusion

The living Orbo code already contains the pieces of a multi-resolution nervous system.

The problem is not that Orbo has no architecture for precision, structure, relation, and time.

The problem is that those tissues are distributed under several engine names while `connectome.js` currently names only the sign-stay compile.

The restoration task is therefore likely to be one of **mapping and joining existing canonical tissues before inventing new computation**.

The inventory also shows three especially important facts to protect during that restoration:

```text
1. exact natal identity and natal velocity already exist in AstroDNA
2. sign-stay Connectome Expression is a successful cache and should remain narrow
3. the tests already contain much of the fidelity philosophy that a formal Resonator may eventually gather
```

The next move is the specifications pass.