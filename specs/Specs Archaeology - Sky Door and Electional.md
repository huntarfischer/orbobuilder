# Specs Archaeology: Sky Door and Electional

Status: archaeology record, not an implementation specification.

Purpose: recover what Orbo already decided about access to the ephemeris and electional timing before designing the restored Connectome or a replacement ElectionalSpine.

This document is intentionally conservative. It distinguishes current code, earlier design strata, later rulings, and the user's current direction. Where the sources do not settle a question, it stays open.

---

## 1. The question this pass asks

The central question is not merely "which files import ephem.js?"

It is:

> Which parts of Orbo are allowed to know the sky directly, which parts are supposed to receive celestial state through a door, and where did older code quietly retain a second route to the ephemeris after that law became explicit?

That matters because the later architecture repeatedly converges on a single principle:

```text
EPHEMERIS
    |
    v
AUTHORIZED CELESTIAL DOOR
    |
    +--> AstroDNA at engraving
    |
    +--> live TimeSpine / probes through time
    |
    v
DERIVED STRUCTURE / READERS / TECHNIQUES
```

The downstream engine should ask for celestial truth, not manufacture another sky.

This is the temporal equivalent of the Ring rewire: once Orbo has a canonical owner for a fact, a second derivation is not a safety net. It is a second authority.

---

## 2. Authority chronology recovered from the specs

The important discovery is that the sky-door law did not arrive fully formed on day one. The repository preserves several architectural layers.

### 2.1 Early layer: engines were allowed to be self-contained

Older engines often carried whatever they needed locally. A technique could import or receive ephemeris functions, carry its own dignity tables, calculate its own speeds, and return its own judgment.

Current `electional.js` is the clearest surviving example of that style.

This was coherent when Orbo was still a collection of astrology engines around an astrolabe interface. It became increasingly incompatible as Orbo developed canonical objects such as the Ring, AstroDNA, the Tympan, the Connectome, and the live spine.

### 2.2 Ring and table rewires: one owner per inherent fact

`specs/Rewire - Angles onto the Ring.md`, the Mater/Tympan work, and the Connectome pass established a recurring rule:

- inventory duplicate constructions, not merely duplicate names;
- select one canonical owner;
- measure parity before rewiring;
- delete the duplicate path when the canonical door is proven;
- do not leave fallback copies that can drift later.

This rule is larger than aspect angles. It is an Orbo architectural habit.

### 2.3 Loom layer: the sky becomes injected

`specs/Phase 5 - The Loom.md` makes the temporal boundary explicit. Loom scans celestial phenomena, but it does not own the sky. The caller supplies `probe` / `bodyProbe`, and the app path does not import ephem directly.

`loom.js`, `fertilize.js`, `luna.js`, and the reader side of `mundane.js` embody this direction.

The question changes from:

```text
engine -> ephemeris -> answer
```

to:

```text
spine -> celestial state
             |
             v
          engine
```

### 2.4 Prism layer: the law becomes explicit prose

`specs/Prompt - Phase 6 P1 - the seam.md` states the boundary almost verbatim:

> risingDegree at any instant comes from spine.ascProbe(jd, lat, lon) per the spine law. Never call eph.angles() directly outside _makeSpine/the engines.

The same prompt requires one refraction function in one place. This is the same architecture on the other axis: one sky door, one refraction door.

### 2.5 Later Prism / Synchronic Time: remove ephemeris work when celestial inversion exists

The later Prism and Phase 7 work goes further. Once a celestial relation can be solved analytically, Orbo should not repeatedly ask the ephemeris to discover an answer it can derive from its own structure.

The chronology work moves from repeated Newton / sample behavior toward the fixed Prism template, RAMC, and `ramcJdNear`.

This is the precursor to the later explicit rule in `specs/Celestial to Civil Time Conversion.md`:

> Solve in celestial coordinates first. Convert to civil time second.

By this stage, minimizing ephemeris contact is no longer merely code cleanliness. It is part of Orbo's model of time.

---

## 3. Direct `ephem.js` dependency census

A repository code search currently finds exactly six source modules importing `./ephem.js` directly:

1. `astrodna.js`
2. `framing.js`
3. `prism.js`
4. `timespine.js`
5. `transits.js`
6. `zr.js`

That number by itself is misleading. The imports fall into different species.

### 3.1 `astrodna.js`: celestial ingest

What it asks from ephem:

- positions at the engraved instant;
- local angles;
- positions immediately before and after the instant to derive signed velocity;
- supporting astronomical quantities needed to construct the genome and extras.

What it produces:

- the immutable celestial identity;
- exact longitudes;
- retrograde state;
- signed speed;
- speed ratio;
- stationary state;
- local angles and lots on the decode surface.

Archaeology classification: **expected sky authority at engraving**.

This is not a reader opening another sky. It is the act that crystallizes a celestial state into AstroDNA.

### 3.2 `framing.js`: mixed layer and historical barrel

What it imports from ephem:

- `norm360`
- `wrap180`
- `julianDay`
- `jdToDate`
- `positions`
- `angles`
- `findAscAnchor`
- `BODY_ORDER`

What makes this important is not just that `framing.js` uses some of these. It also re-exports enough of them that another engine can reach raw astronomy through framing without importing ephem itself.

This is exactly how current `electional.js` reaches `positions` and `angles`.

At the same time, `framing.js` owns one genuinely canonical operation that later architecture explicitly protects: `refract(natalLon, momentLon)`.

Archaeology classification: **mixed historical layer**.

Do not delete or rewrite it casually. The problem is not "framing imports ephem." The problem is that one file currently contains both canonical field algebra and older sky-access conveniences. The specs pass should separate those concerns conceptually before any implementation change.

### 3.3 `prism.js`: terrestrial/celestial geometry, not a body-position reader

Its direct ephem dependency is unusually clean. It imports `gmst` and `obliquity` for the ascension template.

The file itself states the distinction: it takes the Earth's rotation and tilt, **no position**, because the template is geometry of the horizon at a latitude rather than a reading of a planetary sky.

Archaeology classification: **geometric ephemeris utility, not an alternate planetary sky door**.

This is a useful warning for the eventual Resonator rule: a ban on the literal string `ephem.js` would be too crude. The meaningful invariant is about unauthorized production of celestial state.

### 3.4 `zr.js`: arithmetic utility only

Its direct import is `norm360` / `wrap180`. ZR does not use ephem to obtain a sky state. Its Lots are read from AstroDNA and its chronology is period arithmetic.

Archaeology classification: **utility dependency, not sky access**.

Long term, pure circular math may deserve a lower shared home, but that is not a sky-door violation.

### 3.5 `timespine.js`: materialization authority, but worth re-auditing

`timespine.js` directly evaluates body longitudes and positions while constructing the sparse lifetime event table. Its purpose is specifically to pay expensive astronomical scanning once and materialize the result.

Archaeology classification: **currently plausible build/materialization authority**.

However, later Loom-era architecture increasingly prefers injected probes. Therefore this file should be reviewed during restoration, not automatically blessed forever.

The right question is not "does a materializer deserve ephem?" It is:

> Should the lifetime materializer itself be an authorized sky door, or should it consume the same TimeSpine probe surface as every other temporal engine?

The archaeology does not settle that yet.

### 3.6 `transits.js`: standalone ephemeris scanner from an earlier layer

`transits.js` imports `positions` directly and defaults `transitPos` to it. It is admirably chart-agnostic on its target side and already supports an injected transit-position function, but it still describes itself as a standalone transit ephemeris engine.

Archaeology classification: **historical direct-sky engine with an existing injection seam**.

This is likely easier to reconcile than `electional.js`, because the scanner already accepts the abstraction we want. The future transit pass should decide whether its default raw-ephem path remains an authorized build/test convenience or whether the app path must always inject the spine.

---

## 4. The more useful census: who actually manufactures a sky?

The six imports reduce to a smaller set when classified by behavior.

```text
DIRECT IMPORT                ACTUALLY ASKS FOR CELESTIAL STATE?

astrodna.js                  yes, by design at engraving
framing.js                   yes, in legacy/helper paths
prism.js                     no planetary state, horizon geometry only
zr.js                        no, pure circular helpers only
timespine.js                 yes, for materialization
transits.js                  yes by default, but injectable
```

This is much closer to the invariant the Resonator should eventually protect.

The future assertion should probably distinguish:

```text
1. CELESTIAL AUTHORITIES
   allowed to create state from astronomical functions

2. CELESTIAL CONSUMERS
   must receive state/probes/snapshots

3. GEOMETRIC UTILITIES
   may use Earth rotation / obliquity / coordinate math without becoming a sky source

4. PURE MATH
   should not count as ephemeris access at all
```

The exact list of authorized authorities remains a restoration decision. The important recovered law is that the list should be **small, named, and testable**.

---

## 5. `electional.js`: what kind of artifact it is

The current module is a compact record of an earlier design philosophy.

It contains, in one file:

- a topical profile dictionary;
- benefic/malefic classifications;
- traditional planet set;
- triplicity tables;
- exaltation tables;
- Egyptian bounds;
- Chaldean faces;
- essential dignity point scoring;
- accidental condition scoring;
- combustion state;
- aspect grading;
- Moon logic and void-of-course behavior;
- lots;
- fixed stars;
- Field Theory bonuses and penalties;
- reachability checks;
- natal/transit/composite speed derivation;
- applying/separating state;
- synchronic synastry scoring;
- final weighted aggregation;
- authored explanatory strings;
- day sampling and "best" selection.

It is therefore not merely an electional reader. It is simultaneously:

```text
FACT STORE
+ CELESTIAL READER
+ DERIVATION ENGINE
+ DOCTRINE
+ SCORER
+ INTERPRETER
+ SEARCH STRATEGY
```

That bundling predates most of Orbo's later separation of responsibilities.

---

## 6. The hidden ephemeris hole in `electional.js`

`electional.js` does not import `ephem.js` by name. That initially makes it look compliant.

It is not.

It imports `positions` and `angles` from `framing.js`, which imported and re-exported them from ephem.

Two cases are especially important.

### 6.1 Natal speed is recomputed

`speedModel()` mutates/uses `natal._spd`, and if a value is absent it calculates the natal speed numerically by calling `bodySpeed(natal.jd, body, positions)`.

That is now redundant with AstroDNA, which already engraves signed velocity and tests it.

This is an architecture violation by current doctrine even before arguing about performance:

```text
ENGRAVED CELESTIAL FACT EXISTS
          |
          X
     electional.js
          |
          v
    reopens the sky
```

### 6.2 The horizon is reopened too

`scoreMomentV2()` receives `posAt` for the moving bodies, but then separately calls `angles(jd, natal.lat, natal.lon)` to construct the live horizon before forming the composite/synchronic Ascendant.

That means one evaluation can use:

- an injected sky for planets;
- a separate ephemeris route for the horizon.

Later Prism law says the horizon should come through `spine.ascProbe`, not a direct `angles()` call.

So electional has two clocks in the kitchen, even if they currently agree.

---

## 7. Duplicated ownership inside `electional.js`

The ephemeris hole is not isolated. It belongs to a broader pattern.

### 7.1 Dignity facts

Current electional carries its own exaltations, triplicities, Egyptian bounds and Chaldean faces.

Later canonical owners already exist:

- Mater for sign-level rulership / exaltation / debility;
- `rulers.js` for pointwise dignity ladder, bounds, faces and triplicity.

The later rulers layer explicitly refuses an almuten/dignity score because ranking the facts is judgment.

Electional does the opposite: it reconstructs those facts and immediately converts them to Lilly-style points.

This may still be valid **electional doctrine**, but it should not be a second fact table.

### 7.2 Reception and dispositorship

Electional constructs a local reception approximation from sign rulers and aspect proximity.

Later architecture has `dispositor.js` and the sign-stay Connectome Expression as canonical structural owners of governance and reception.

Again, the question is not whether electional cares about reception. It should. The question is why it should calculate its own reception when the nervous system already knows the relation.

### 7.3 Lots

Electional consumes `lots` from `framing.js`, whose older seven-Lot family survives beside AstroDNA's later eight-Lot canonical family.

The Lots conformance suite explicitly protects "one formula, one place" on the AstroDNA side.

This is another unfinished rewire, not evidence that electional requires a private Lot system.

### 7.4 Aspect relation

Electional evaluates aspects internally against `ASPECTS`. Later architecture increasingly makes the Ring the geometric authority and readers select admitted marks/orbs at their edge.

### 7.5 Interpretation prose

Electional's `drivers` combine numeric weight and authored phrases in the engine itself.

That predates the later rule:

> The Connectome records structure; packs speak meaning.

A future electional engine may still need machine-readable reasons for an assessment. It need not author the sentence describing those reasons.

---

## 8. The wiring trace: current `electional.js` appears isolated

This is one of the strongest practical findings of the archaeology.

Repository code searches for current electional entry points find the module, its generated browser wrapper, and historical/specification references. They do **not** find current calls from `Orbo Astrolabe.dc.html`.

Specifically, searches for:

- `__ORBO_ELECTIONAL`
- `electional.browser.js`
- `scoreMomentV2`
- `scoreDaySolo`
- `openElection`
- `Electional` scoped to the current DC
- `scoreDay` scoped to the current DC

do not expose a current DC caller for the module.

This is strong evidence that `electional.js` is presently an orphaned or historical engine rather than a load-bearing dependency of the current instrument.

Caution: GitHub code search is not a formal parser of the 1.2 MB DC file, so this is evidence, not a mathematical proof. Before deleting or replacing the module, the Bay Bridge pass should still grep the actual assembled DC and standalone locally.

But architecturally the result is encouraging:

> There is no evidence yet that we must preserve the current electional module's internal contract for the sake of the live app.

That makes replacement substantially safer than rehabilitation would otherwise be.

---

## 9. What the old UI/spec layer expected

Earlier Lunar Pane delegation material describes an `openElection` door under Timing and an optional electional lens pinned to the Moon pane.

`specs/Timing Tabula Spec.md` later names the feature clearly as **Electional Windows** and keeps it under Timing.

Those documents preserve an important product contract even if the implementation behind it drifted or disappeared:

```text
TIMING owns electional.
The Moon may reflect electional windows.
Electional is not a new instrument-face mode.
```

That ownership survives the later Prism P6 spec.

---

## 10. The buried replacement architecture already exists

The largest archaeology find is `specs/Prompt - Phase 6 P6 - the query.md`.

It describes an electional engine whose computational shape is dramatically closer to the user's current ElectionalSpine idea than current `electional.js` is.

### 10.1 Choice, not prediction

The P6 premise is:

> You cannot choose where Saturn is. You choose when you walk in the door, and that choice sets the sASC and every relation it forms.

This makes electional an actionable query over a celestial field rather than a horoscope score pasted onto arbitrary timestamps.

### 10.2 Three electional criteria

P6 identifies three classes:

1. the sASC stop: sign, natal whole-sign house, Synchronic Ascendant Ruler;
2. marks formed by the sASC to occupants;
3. position inside the stop, especially proximity to a handoff.

The list is not necessarily the final complete electional doctrine. It is important because its **shape** is already right: structural celestial conditions first.

### 10.3 Seven windows, not a grid

P6 is explicit:

> the search space is seven windows, not a grid

The algorithmic idea is:

```text
KNOWN CELESTIAL WINDOWS
       |
       v
evaluate the stops
       |
       v
rank eligible windows
       |
       v
refine inside the winning window
       |
       v
ramcJdNear
       |
       v
civil clock time
```

This directly supersedes the spirit of `scoreDaySolo()`, which samples a civil day at a fixed number of points and keeps the highest score.

### 10.4 Civil time is late

P6 says every window's clock time comes from `ramcJdNear` at read time. It stores no event time on the template.

That is the same principle later generalized in `Celestial to Civil Time Conversion.md`.

### 10.5 No second electional engine

P6 explicitly refuses a second electional engine. Timing owns one.

This is useful now: replacing old `electional.js` should not mean building a second parallel public technique. It means restoring the one Timing electional function around the newer architecture.

---

## 11. P5 is the missing bridge between Prism and electional

`specs/Prompt - Phase 6 P5 - the ledger.md` establishes the temporal structure P6 expects.

Important recovered decisions:

- a synchronic day is seven itinerary rows, not a flat list of arbitrary sampled moments;
- row structure comes from the fixed Prism template;
- civil row times are produced from RAMC at read time;
- the sASC is the switch of the clock;
- Moon behavior comes through `luna.js`;
- if an inverse celestial solve can replace a scan, build the scanner first, measure both to max delta 0.00 minutes, then delete one;
- never materialize/fuse these clock rows onto the lifetime spine.

P5 and P6 together already contain the seed of an ElectionalSpine without using that name.

---

## 12. Where current user direction extends the buried P6 plan

P6 is centered on the synchronic Ascendant and its seven daily windows.

The current direction broadens the same architecture into a larger doctrine-sensitive temporal index:

```text
TimeSpine / celestial state
          |
          v
Connectome relationships
          |
          +--> rising lord / governance
          +--> dispositor chain / keeper
          +--> dignity and condition facts
          +--> aspects and application
          +--> lunar conditions
          +--> synchronic reachability / sASC relations
          |
          v
ELECTIONAL DOCTRINE
which of these facts matter for this purpose?
          |
          v
CELESTIAL INTERVALS
          |
          v
intersection / ranking
          |
          v
CELESTIAL TO CIVIL CONVERSION
          |
          v
usable windows
```

This is an expansion of P6's geometry, not a return to `scoreDaySolo()` sampling.

---

## 13. Provisional disposition of current `electional.js`

These classifications are for the Bay Bridge planning pass. They are not yet implementation orders.

### PRESERVE: concepts / product contracts

- Electional belongs to Timing.
- Electional returns windows a person can act on.
- Different purposes may prioritize different celestial conditions.
- The rising ruler / actor can matter.
- Planetary condition can matter.
- Moon condition and outcome can matter.
- Applying versus separating can matter.
- Field Theory / synchronic criteria can matter.
- A result needs machine-readable reasons for why it qualified or ranked.
- Location matters wherever the elected criterion involves a local horizon.

### RELOCATE: facts that already have better owners

- natal velocity -> AstroDNA exact expression;
- current celestial state / horizon -> live TimeSpine probes;
- sign rulership / exaltation / debility -> Mater;
- bound / face / triplicity -> rulers pointwise layer;
- dispositor chains / receptions / governance -> Dispositor + Connectome;
- lots -> AstroDNA / canonical Lot surface;
- aspect geometry -> Ring / relation layer;
- synchronic reachability / itinerary -> Prism / SynchronicSpine;
- dense Moon temporal questions -> Luna;
- prose -> interpretation / presentation layer.

### REPLACE: computational shapes that conflict with later law

- fixed civil-time sampling -> celestial interval solving;
- `scoreDaySolo()` style "sample and keep max" -> ElectionalSpine / window intersection;
- direct `angles()` inside electional -> spine / Prism horizon door;
- natal speed recomputation -> engraved velocity;
- local copies of canonical dignity tables -> canonical structural reads;
- ad hoc reception calculation -> Connectome relation;
- one monolithic scalar score as the engine's ontology -> structured assessment whose weighting belongs to declared electional doctrine.

A scalar can still be a read-side ranking convenience if doctrine calls for one. It should not erase the facts that produced it.

### RETIRE: likely historical implementation debris

Subject to final live-call grep during Bay Bridge:

- private copies of bounds, faces, triplicity and exaltation in electional;
- private Lot formula dependency through framing;
- raw natal speed reopening;
- backdoor `positions` / `angles` through framing;
- fixed-star literals in this engine if a canonical fixed-star source is later established;
- authored explanatory prose embedded in low-level scoring;
- potentially the current `electional.js` implementation in its entirety after a replacement passes parity/acceptance for the product behaviors we actually choose to preserve.

---

## 14. `framing.js` requires a separate seam pass

The electional archaeology exposes a broader issue: `framing.js` is both a valuable algebra module and a historical astronomy barrel.

The future pass should inventory every caller of these re-exports:

```text
positions
angles
julianDay
jdToDate
findAscAnchor
```

Then classify each caller.

The likely end-state principle is:

```text
framing owns FIELD ALGEBRA
not THE SKY
```

But do not perform that rewire opportunistically while replacing electional. It deserves its own parity harness because older modules may depend on the current exports.

`refract` in particular is canonical and must remain one door.

---

## 15. What the Resonator could eventually enforce

This archaeology gives the future Resonator a much sharper job than "check calculations twice."

Possible architectural invariants:

### Sky-door invariant

Every production call that produces a celestial body position or local angle originates from a declared celestial authority.

### No re-opening invariant

If an engraved or current-state fact exists on the canonical surface, downstream engines may not reconstruct it from ephemeris.

Examples:

- natal speed must agree with and come from the engraved expression;
- electional horizon must arrive from the approved horizon probe;
- lots must come from one formula owner.

### Materialization conformance

A cached/materialized chronology must equal the same truth read live at test vectors.

TimeSpine's existing test already does this.

### Inverse-solve conformance

Where Orbo replaces scanning with celestial inversion, first prove the inverse path against the scanner at zero meaningful delta, then keep one production path.

The P5 prompt already prescribes exactly this.

### Architectural grep

The eventual test should not simply forbid `ephem.js` imports. It should maintain an explicit allowlist by capability:

```text
planetary state producers
local-angle producers
Earth-rotation geometry consumers
pure circular-math consumers
```

This catches a future `electional.js` style backdoor even if it imports the raw function through another module.

---

## 16. What Ean already decided that did not fully cross into the living architecture

This is the most important archaeology output.

The repository already contains decisions that match the current restoration direction:

1. **The horizon should come through the spine.** P1 says so explicitly.
2. **Loom/readers should receive probes rather than import ephemeris.** Phase 5 says so explicitly.
3. **Refraction has one door.** P1 says so and the living framing implementation reflects it.
4. **The synchronic clock is finite structure plus a live celestial coordinate.** Prism P2/P3 establish this.
5. **Electional should search known celestial windows, not sample the civil day.** P6 says "seven windows, not a grid."
6. **Civil clock time should be generated after the celestial solution.** P5/P6 use RAMC at read time, later generalized by Celestial to Civil Time Conversion.
7. **Electional remains one Timing function, not a second technique bolted onto Pisces.** P6 explicitly refuses a second electional engine.
8. **Canonical structures should be reused rather than re-derived.** Ring/Mater/Tympan/Connectome rewires establish this repeatedly.
9. **A cheaper inverse path must be measured against the canonical scanner before one path is deleted.** P5 explicitly carries the 7b method forward.

The current `electional.js` predates or bypasses many of those decisions. The problem is therefore not that Orbo lacks an electional architectural idea.

The problem is that the **newer architectural idea never replaced the older engine**.

---

## 17. Rewrite assessment

Based on this pass, a clean replacement of `electional.js` is more plausible than incremental rehabilitation.

Reasons:

1. The module collapses too many responsibilities to separate cleanly one line at a time.
2. Many of its factual tables now have canonical owners elsewhere.
3. It reopens natal velocity already engraved in AstroDNA.
4. It reaches local angles through a historical framing re-export rather than the spine.
5. Its day-search primitive is fixed sampling, directly opposed by the later P6 finite-window design.
6. No current DC caller has been found in repository code search.
7. No dedicated electional conformance suite has been found.
8. Later specs already provide a better computational skeleton.

This does **not** mean "delete electional.js now."

It means the next architecture pass should treat it as a source of **requirements to harvest**, not a chassis that must be preserved.

The Bay Bridge sequence should be:

```text
HARVEST useful doctrine and product behaviors
          |
          v
DEFINE restored Connectome reads needed by electional
          |
          v
DEFINE ElectionalSpine celestial interval contract
          |
          v
BUILD new path beside legacy file
          |
          v
TEST against chosen preserved behaviors + new invariants
          |
          v
VERIFY current assembled app has no remaining legacy caller
          |
          v
RETIRE old implementation
```

---

## 18. Questions intentionally left open

The archaeology does not decide these yet:

1. Is `timespine.js` itself an authorized ephemeris materializer, or should it eventually receive the live spine's probes?
2. Should `transits.js` retain a raw-ephem default for tests/standalone use while production always injects the spine?
3. Which electional doctrines are Orbo defaults versus optional astrologer-authored methodology?
4. Does an ElectionalSpine persist one year of boundary intervals, cache lazily, or derive them from lower temporal indexes on demand?
5. Which electional criteria are universal sky facts and which are synchronic/personal field facts?
6. How should applying/separating velocity live in the restored Connectome without polluting the sign-stay Expression?
7. What is the canonical fixed-star source, if fixed stars remain in electional doctrine?
8. How should the Moon's dense conditions layer into long-range ElectionalSpine windows without materializing lunar noise?
9. Should `framing.js` eventually lose every astronomical re-export, and if so what is the migration sequence?

These belong after the broader specs archaeology and Connectome restoration map, not before it.

---

## 19. Current archaeology verdict

The strongest recovered law is:

> Almost nothing in Orbo should know how to ask the ephemeris for a sky.

The stronger implementation form is:

> A very small set of named celestial authorities may create sky state. Everything else receives, derives, indexes, relates, judges, or reflects that state.

And the electional verdict is:

> The current `electional.js` is best understood as an older self-contained engine whose useful doctrine should be excavated, while its computational chassis is a strong candidate for replacement.

The replacement direction was already partially specified inside Orbo before this restoration began:

```text
CELESTIAL STRUCTURE FIRST
WINDOWS, NOT SAMPLES
ONE SKY DOOR
ONE ELECTIONAL FUNCTION
CIVIL TIME LAST
```

That is the layer to build forward from.