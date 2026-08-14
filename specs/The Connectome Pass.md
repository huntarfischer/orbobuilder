# The Connectome Pass

Reference document for step L of the Ring rewire. Written 2026-08-05, before any line of it exists.
Prior records: `specs/Rewire - Angles onto the Ring.md` §5 (the plan and the mockup reading),
CLAUDE.md's Connectome / Tympan / Dispositor / AstroState sections, `uploads/01_AstroState.md`
through `07_RegulatorySnapshot.md` (the shape sketches).

**Status at the time of writing: nothing exists.** No `tympan`, `connectome`, `dispositor` or
`express` on disk. Every prerequisite has landed: D2 stamped the Mater's tables, F fixed the gene
order, G and J settled the identity the compile files under, 7b left one scanner and deleted the
pullback. The rewire's own order of record calls this step additive with nothing to migrate.

---

## 1 · Where the Connectome sits

Three tiers, and the Connectome spans two of them.

**INHERENT · the floors.** No arguments, no time, no native, no place. Stamped before the app runs.
Artifacts rather than generators.
- **Ring** · the relation. Degree to degree. Imports nothing, holds no meanings, holds no orb.
- **Mater** · the meaning. Signs, elements, modalities, traditional rulership, exaltation with
  degrees, detriment and fall derived at stamp. Imports nothing.
- **Tympan** · the frames and the governance index. Twelve stampings, forward and reverse, plus the
  separate modern index. Imports the Mater, and nothing else.

**THE COMPILE · functions.**
- **dispositor.js** · the placeless wiring. Takes a sequence. Refuses everything else.
- **connectome.js** · the join. Takes occupants, a Tympan and sect. Produces an Expression.

**THE READERS.**
- The instrument and the pull-up pane. They read the tables and never own them.

### The sun/moon law's scope, corrected

The sun/moon law is an **information law about the face**: it governs what the native sees and where
a *way of looking* lands. It has never said anything about code layering, and it must not be read as
saying the Connectome is moon-side.

**The Connectome is beneath the face.** Both faces read it, neither owns it, exactly as both read the
Ring. This came up twice in conversation before being written down; it is written down now.

### Ships as the die, filled at engrave

The Tympan **ships full**: all twelve frames exist before any native does. Engraving does not fill
it, engraving **selects** one. Selection is cheap, housing is fixed.

The walker and the compiler **ship as the function**. Nothing to fill.

The **natal Expression** and the engrave-time aspect list are where "empty tables filled once
engraving happens" is literally true. Both are permanent facts of one chart.

---

## 2 · Vocabulary, settled 2026-08-05

**Essential dignity** is the ladder a placement has by its own zodiacal position: domicile ·
exaltation · triplicity · bound (term) · face (decan). Debilities: detriment · fall. Absence:
peregrine.

**Reception is NOT a dignity. It is a relation mediated by one.** A sits where B has dignity, so B
receives A. Its `kind` names the mediating dignity: `domicile` · `exaltation` · `mixed`.

**Mutual reception** is both directions holding. **Mutual reception by domicile is exactly the
two-planet cycle in the dispositor graph**, so it is already a stored row and needs no separate mark.
No word is overloaded any more: the graph reports mutual reception by domicile; the reception table
reports every kind.

**Triplicity and quadruplicity, stated correctly.** The number in the name is the SIZE of the group.
- **Triplicity** · groups of THREE signs, so four groups, so it is the **element** grouping.
- **Quadruplicity** · groups of FOUR signs, so three groups, so it is the **modality** grouping.

`rulers.js`'s existing `triplicity` layer is the classical **triplicity rulership** scheme (day lord,
night lord, participating lord per element group) and is correct as written. Do not "fix" it.

**In the UI the words are element and modality**, which are unambiguous to a native. `triplicity`
stays reserved for the rulership scheme.

**Bearer** = immediate dispositor. **Keeper** = terminal ruler, or the cycle it closes into.
**Governor** and **government** stay the general words for the traditional backbone, because
`governed` on every ingress and flip row means *the traditional dispositor changed* and "a change of
government" is the name of what a flip and an ingress ARE. **The modern is the co-ruler**, astrology's
own word, already displayed in the DC. `co-governor` retires as a duplicate.

**Terminal kinds**, one termination rule, length names the result: 1 = **domicile** · 2 = **mutual
reception** · 3+ = **dispositor loop**. Never "closed circuit", never "cycle" (which collides with
ZR's cycle).

**The two named chains are selections, not code.** **Agency** starts at the natal ASC ruler,
**light** at the sect light. The charged reading is Keeper of Agency == Keeper of Light.

**Depth levels are L1, L2, L3, exclusively and everywhere.** Build steps are named, never numbered
with an L, or the two vocabularies collide in conversation. (They did.)

---

## 3 · The laws this pass runs under

### 3.1 The four resolutions, and the key that was double-named

`spine.at`'s sample identity is the **instant**. Chart identity is the **genome** (arcseconds).
Artifact keys are **named cuts of the genome**. The Connectome adds one more cut, and it resolves a
contradiction between two prior records:

- **CLAUDE.md** said `topologyKey` is a label and never a cache key, because two charts can share a
  graph and differ in every degree.
- **The rewire §5** said the cache key IS the sign vector, because a genome key recompiles a scrubbed
  year tens of thousands of times.

Both are right about **two different keys wearing one name.** Declared separately now:

| resolution | what it is | role |
|---|---|---|
| genome | arcsecond sequence | provenance on metadata. **No stage may read it.** |
| **frame vector** | the sign ordinals plus the sect bit | **the Expression's cache key** |
| graph topology | cycles and fixed points | a label. Genuinely never a key. |

The frame vector is exact rather than approximate **because** the Expression is sign resolution by
law. CLAUDE.md's objection (correct wiring, wrong longitudes) only bites if a node carries a
longitude, which the same document forbids.

### 3.2 The frame vector, precisely

- One sign ordinal per member of the **declared occupant set**, in declared order.
- Plus **one sect bit**, because sect is settled from the floats (§3.4) and two samples with identical
  sign vectors can disagree on sect inside the horizon window. Without the bit the memo serves the
  wrong light chain, silently.
- The Tympan selector is the Ascendant's sign, which is already the first entry. Nothing extra.
- **Motion is reduced out, deliberately and by law.** The gene encodes retrograde as the upper half of
  the address space, so a naive projection would key a retrograde Mercury separately from a direct one
  at the same degree: same wiring, two keys, and the recompile explosion the key exists to prevent.
  **The modulus is the named constant**, per the arcsecond gene's own rule.
- The **occupant set is a build parameter and belongs in the version component**, never in the vector
  itself. Same law fertilization already runs under: the sequence is the identity, the occupant set is
  the reader's choice.

### 3.3 Sign resolution, by law

A node carries **no longitude, no exact degree, no retrograde flag**. Two reasons, the second fatal:

1. The sign already implies what the wiring needs, so storing more is more chances to disagree.
2. **Anything at degree resolution destroys the memo.** A longitude on a node means the record changes
   every sample and it is no longer a table.

Retrograde is **not dropped**; it is already upstream in two places, at full precision: the gene's
upper half, and `isRetrograde` on every node record (which `_specRows` reads today). Speed, exact
degree, retrograde and aspects are read live from the spine and **joined at the reading**.

### 3.4 Sect comes from the floats

"Houses 7 through 12 are above the horizon" is exact **except** when the Sun occupies the rising or
setting sign, where the whole-sign 1st straddles the actual horizon and the degree decides. That is a
two-hour window twice a day, and it flips every lot and the entire light chain.

So the join settles sect from the Sun's degree against the ASC degree, never from the whole-sign
house. `astrodna.lots` already takes `isDay` as an argument; this is the same pattern one layer up.
And it is why the frame vector carries a sect bit.

### 3.5 The occupant set

- **In the Expression:** the twelve genes plus the **slow extras**. Chiron changes sign every couple of
  years, Lilith every nine months, the nodes every eighteen months. Free.
- **Not in the Expression: the lots.** A lot moves at Ascendant speed, so it changes sign roughly every
  two hours. In the key, that turns a scrubbed year from a couple hundred compiles into several
  thousand. Their bearer and house are computed **live at the reading**, one lookup each, exactly as
  retrograde and speed are. Nothing is lost; a lot's house still reads on the pane.
- This is the same cardinality argument that keeps lots out of the ♐ Field scan, from the other side.

### 3.6 Twelve nodes OCCUPY, seven planets GOVERN

The graph is not symmetric. The seven traditional planets are dispositor-capable and each has exactly
one outgoing edge. **Everything else Orbo carries is a pendant leaf: it HAS a bearer and IS never a
bearer.** Ascendant, the three outers, the nodes, Chiron, Lilith, the asteroids, the points, the lots.

Out-degree one on the seven means the graph is **functional**, which means it decomposes into
components each holding exactly one cycle, which means **termination is guaranteed mathematically**
and not by a depth cap. The whole solve is one pass over seven items.

`PlanetNode` therefore needs `dispositorCapable`, or a naive walker routes Mars to Pluto.

### 3.7 Modern rulership stays open, and the shape it stays open in

**Now:** moderns are a **co-ruler annotation**. Every node carries a nullable `coRuler`; every frame
carries `coRules` houses. Fully readable and sayable ("Pluto co-rules your 1st"). The walker is never
handed the table, so it is structurally incapable of branching into a modern.

**Later, if wanted:** a **second functional graph**, modern-only, where Scorpio routes to Pluto,
Aquarius to Uranus, Pisces to Neptune *instead of* the traditional lord. Two graphs, each out-degree
one, each guaranteed to terminate, each with its own keeper, crossed the way doctrine already crosses
edge types. A **co-ruler chain**, plainly distinct from the dispositor chain.

**Never a weighted edge.** "Real but weaker" is a strength claim, and a weighted edge is a score with a
mathematical alibi. Weighting belongs to the interpretation packs (§4).

### 3.8 The one persistence split, three ways

| what | where | why |
|---|---|---|
| the **natal** Expression | persisted, `orbo.connectome` | a permanent fact of a fixed chart |
| **favorited** charts' Expressions | persisted, same store | frequently referenced, cheap to keep |
| **moment** Expressions | RAM memo only, evicted freely | microseconds to rebuild |

Keyed on **frame vector × doctrine version × codec version**, the same key discipline `fertKey` runs
under, so a doctrine change **misses and rebuilds** rather than serving stale wiring. That was the only
real objection to persisting, and the key structure answers it.

An Expression is a few KB and needs no byte codec (nothing in it is dense), unlike the weave. So
persist generously. Pruning is LRU outside the native's own and anything pinned.

### 3.9 Nothing synchronous is added to engrave

v0.882 exists because onboarding was doing too much behind the scenes during natal entry. Nothing goes
back on that path.

- **First read compiles.** Microseconds, imperceptible.
- **Idle warm after mount**, off the critical path, cancellable, released in
  `componentWillUnmount` with everything else.
- Acceptance criterion for the seam pass includes: **onboarding timing does not move**, measured.

### 3.10 If a pattern requires derivation, a table is missing

Every pattern named so far collapses to a field read: mutual reception is a 2-cycle row · Keeper of
Agency == Keeper of Light is two cycle ids compared · "what routes into the 7th" is an index. So there
is **no pattern layer and no reading module**. When a pattern cannot be expressed as a field read, add
the row. This protects the interpretation boundary by construction rather than by discipline.

### 3.11 The walker's input is a SIGN VECTOR, not a sequence

CLAUDE.md says the walker's input is a sequence, which is right in spirit (twelve integers, no
ephemeris, no modes) and wrong in letter. A synchronic or composite placement set **never passes
through the sequencer**: `astrodna.buildAstroDNA` needs a jd, a place and the ephemeris, and a
synchronic placement is `midpoint(natal, sky)` per occupant, which is a list of longitudes and not a
sequenced moment. Hand the walker a `sequenceString` and every derived chart needs an adapter.

So the walker takes **an occupant-to-sign map**, and a sequence **projects** to one. That is the same
law `astrodna.degreeSequenceString` already established (a cache key is a declared projection at the
resolution the contents are sensitive to), one step coarser, which CLAUDE.md itself already says of
sign resolution.

Two things fall out, both load-bearing:

- **Every layer becomes the same input with no adapter.** Natal arrives via the projection; synchronic,
  composite, mundane and solar return arrive directly. Nothing is told what it is.
- **The walker's input IS the cache key** (§3.2). No second projection step, so the two can never
  disagree about a placement the way two derivations could.

### 3.12 The layers, and which Tympan each one gets

The compile takes occupants and a Tympan as **arguments**, so no layer is special-cased and doctrine is
one line per row rather than a conditional. Natal is the degenerate case where one genome supplies
both.

| layer | occupants | Tympan | sect | persisted |
|---|---|---|---|---|
| natal | the genome | its own | its own | **yes** |
| sky / transit | the moment | **the native's** | the native's | no |
| synchronic | `midpoint(natal, sky)` per body | **the native's, always** | see §7 | no |
| composite | the midpoint chart | **its own ASC sign** | its own | yes, for a saved pair |
| mundane, placeless | the moment | **none** | none | no |
| synchronic synastry | two synchronic sets | **each native's own** | each native's own | no |

The rulings behind the column:

- **Synchronic placements are housed in the native's frame, never a derived one.** Natal whole-sign
  anchored to the natal ASC, always. This is the one thing the compiler must be **told** rather than
  derive, and it is why the Tympan is a parameter: reading the occupants' own Ascendant would force a
  per-source rule, which is the one thing "identical output regardless of source" forbids.
- **A composite supplies its own ASC sign**, because a composite genuinely has a horizon and the
  natal-whole-sign law is about not re-housing a *synchronic* placement. Doctrine already grants this
  exception explicitly.
- **A placeless field gets a FULL planet graph and no house graph.** Rulership is degree to sign to
  lord: no horizon, no place, no ASC. So houses are `null`, and agency and light are absent because both
  start from the Ascendant. Three honest absences rather than a mode switch, and `governed` is the
  single place the two halves meet.
- **Synastry contacts need no frame at all.** A solo frame is a CHART and needs a place and a moment; a
  pair contact is an ANGLE and needs only time. Two Expressions, each in its own native's Tympan, and
  the contacts between them are the Ring's business.
- **The memo is better on the synchronic layer for the BODIES and worse for the ANGLE.** A synchronic
  body moves at half its transiting speed, so it changes sign half as often. But the synchronic
  Ascendant moves at half Ascendant speed, roughly 180 degrees a day, so it changes sign about every
  four hours and drives ~6 recompiles a day on its own. A scrubbed year is a couple of thousand
  compiles rather than a couple of hundred: still microseconds each, still a working memo, but the
  earlier optimistic claim is corrected here rather than discovered later.

**What the interpretation layer receives**, and the boundary that keeps it honest: `chains`, `cycles`
and the reverse `indexes` are the handover surface, and `metadata.source` says which layer produced
them. **The compiler is source-blind; the pack is source-aware.** No stage may read `source`, and every
stage before the freeze compiles identically whether the twelve integers came from a birth, a composite
or the current second. That split is exactly what makes one dispositor engine serve the whole
astrolabe.

### 3.13 THREE USES OF AN ASCENDANT, and only one of them is fixed

The codebase already separates two. The synchronic clock (a real-time electional view, distinct from the
composite chronology's anchored daily frames) forces the third to be named, because in it the synchronic
Ascendant is a **moving occupant that forms real aspects**: the sASC sweeps the 180 degree arc centred on
the natal ASC, which for a Scorpio rising runs 10th-house Leo to 4th-house Aquarius, every day, and the
reading wanted is sASC trine sMoon, sASC conjunct sMars.

- **HOUSING** · fixed, natal, never derived. Natal whole-sign anchored to the natal ASC sign, always.
  A synchronic placement is never re-housed from a derived Ascendant.
- **SELECTION** · legal on a moving Ascendant. The rising-lord horizon scan and the composite
  chronology's cASC handoff both ask who governs a moving degree, which is not where to house a
  placement. Selection is cheap; housing is fixed.
- **LIGHT** · sect. Also legal on a derived Ascendant, and this is the new one.

**So a synchronic composite has its own sect, from its own Sun against its own Ascendant.** This
supersedes the earlier lean (synchronic Sun against natal ASC) and it is the better answer for three
reasons. Doctrine already grants it: a composite has a Sun and a horizon, and those two give sect, which
is why `lots(asc, isDay, pos)` takes no place. It costs the housing law nothing, because **sect is a
light question and not a housing question** and the two were only ever entangled by the word
"Ascendant". And it makes the clock coherent: if the sASC is a real occupant forming real relations,
then sASC against sSun is a real relation too, and sect falls out of it for free rather than being
imported from a chart the reading is not in.

Consequence, stated so it is not a surprise: **a synchronic reading can be nocturnal while the native is
diurnal.** The light chain and all eight lots flip with it. That is the honest behaviour of a derived
chart that genuinely has a horizon, and the sect bit on the frame vector (§3.2) is what keeps the memo
from serving the wrong one. The bit cannot be recovered from the sign ordinals, because sect is a degree
comparison, so §3.2's bit is now load-bearing rather than merely careful.

**The clock's own scan is NOT Connectome work, and it must never be materialized.** Its geometry belongs
to the Ring and its scan to the loom. Pre-ruling, because the cardinality decides the architecture
before anyone writes it: at ~180 degrees a day the sASC crosses roughly 11 marks per body per day, so
against a dozen bodies that is ~130 contacts a day and ~48,000 a year. That is an order of magnitude
beyond the Moon, which is already a windowed generator by law. **The synchronic clock is a windowed
generator in the shape of `luna.js`, never a table on the spine and never fused.** Its own pass, after
this one.

---

## 4 · The interpretation boundary, with the worked example

**The Connectome records the structure. The packs speak the meaning.** The forbidden-word list
(`good` · `bad` · `strong` · `weak` · `fortunate` · `difficult`) is grepped against the compiler's own
source, because a claim in a header enforces nothing.

The case that defines the boundary: **Venus in Aries and Mars in Taurus, both in detriment, in mutual
reception.** The classical reading is that the reception mitigates both debilities. That is an
assessment and it cannot appear in the compiler. What the Expression stores is only facts:

- Venus · sign Aries · dignity `detriment` · bearer `Mars`
- Mars · sign Taurus · dignity `detriment` · bearer `Venus`
- `receivedBy` on each, mediating dignity `domicile`, reciprocal
- keeper: the Venus and Mars cycle, `length: 2`, kind `mutual-reception`. **Neither routes outward;
  the pair terminates in itself.**

That last line carries the whole meaning without asserting it. A 2-cycle is the shortest possible
non-trivial terminal in a functional graph. A pack matches on exactly that shape (keeper is a 2-cycle
AND both members carry a debility) and says they hold each other up.

This is also where modern rulership's "real but weaker" eventually lives: a pack weighting, never an
edge weight.

---

## 5 · The passes, in order

### 5.1 The rulings pass · docs only

CLAUDE.md gains everything in §2 and §3 above, plus the sun/moon scope clause, the Connectome as
beneath the face, ships-as-die, the L1-L3 reservation, and the aspect lattice named as a **fixed
member** of the Connectome (natal only, needs floats, already sitting on the genome as the engrave-time
aspect list) as distinct from the Expression, which is a **compiled member** (sign resolution,
memoized). Naming both member kinds stops someone "fixing" one into the other.

No code. This pass exists so the next four have one authority to disagree with.

### 5.2 The Tympan pass · `tympan.js`

**Builds:**
- The twelve frames, **absorbed from `mater.HOUSE_FRAMES`** (the open ruling in CLAUDE.md, now
  decided: the frames move). Forward stamping plus `houseFrame` / `houseOfSign` / `houseOfLon`.
- The **reverse index**: frame + planet to the houses it governs. This is why the file exists. The DC
  hand-walks it today in two places (`for (let i=0;i<12;i++) if (_rulerOfSign(i)===name)`, around
  lines 7048 and 7927) and the watcher doctrine needs it as a lookup, not a walk.
- The **separate modern co-ruler index**, three entries per frame, one house each. Separate rather
  than a column so the walker is never handed it. The DC's `CO_RULER` becomes a read of this; the
  moderns get a stamped home for the first time.
- Free consequence worth asserting: **a flip moves a placement exactly six houses, always.**

**Refuses:** occupants · time · place (it takes an ASC sign, not a lat/lon) · the Ring · aspects ·
orbs · sect · lots · decans · terms · faces · triplicity · and **house meaning words**. The Tympan
gives the number; a glossary reader gives the word. This is the refusal it will be pushed on hardest.

**Contract:** the Ring's, exactly. Absence is `null` · well-formed and empty is `[]` (Mercury governs
no house in this frame; an empty array is truthy so a loose caller still behaves) · a malformed address
**throws** (house 13, unknown planet). One validator per **argument kind**, no exemption for flags, per
the Ring's four review rounds. Ordinals only, so 0 is never a valid answer and truthiness is safe here
by construction.

**Order:** pin the contract in `tests/tympan.test.html` **before** a single call site moves. Then
repoint `astrodna`, `framing` and the DC, and add the `tympan.HOUSE_FRAMES === ` identity assertion, so
nobody keeps a private copy that agrees today. Regenerate `tympan.browser.js`.

**Acceptance:** the two hand-walked DC loops are gone · the harness asserts identity, not equality ·
`mater.js` still imports nothing · nothing visible changes.

### 5.3 The walker pass · `dispositor.js`

**Builds:** bearer, path, keeper and terminal kind for every occupant, from an **occupant-to-sign map**
(§3.11). No modes, and no adapter per layer: a mundane moment, a composite and a synchronic set all
arrive as the same twelve-ish integers, and a natal arrives through the declared projection.

- Two node classes (§3.6).
- **One** termination rule, length names the result (§2).
- **Cycle ids derived from sorted members, never a counter** — an iteration-order id makes two
  expressions of the same genome differ, which silently breaks byte-identical output.
- The **reception** table with its kinds, moved here from `rulers.js` (see acceptance).

**Refuses:** the Tympan · place · time · the Ring · aspects · orbs · sect · the modern table. A
placeless field therefore gets a **full** planet graph and houses `null`, with no agency and no light
chain (both start from the Ascendant). Three honest absences rather than a mode switch.

**Acceptance:** `rulers.disposition` is **deleted**, not parked (it is already dead in the app path,
and the codebase's own law is delete rather than leave a fallback that drifts). Its exaltation and
mixed reception logic moves here. `tests/rulers.test.html` is **rewritten** rather than dropped, the
way `loom-algebra` was in 7b: every assertion that was about the wiring survives. `rulers.js` keeps
its own layer, degree to dignities (decans, terms, faces, triplicity rulership), untouched.

### 5.4 The compiler pass · `connectome.js`

**Builds** `express(occupants, tympan, sect)` to a **frozen Expression**. Stages: normalize · tables ·
graphs · topology · indexes · freeze.

- `planetTable` of `PlanetNode`, over `NODE_ORDER` plus slow extras, in order, always.
- `houseTable` of `HouseNode` (`house`, `sign`, `ruler`, `rulerHouse`, `destinationHouse`).
- **The house routing graph**, the twin of the planet graph. Twelve nodes, one sign each, one lord
  each, that lord in exactly one house, so it is **also functional** with the same guaranteed
  decomposition and the same one termination rule. Its fixed points are "ruler in its own house"; its
  cycles are the topic-level counterpart of mutual reception. **Unlike the planet graph its INBOUND
  degree genuinely varies** (Mercury ruling two signs means two houses route to Mercury's house), which
  is what makes house routing load a real measurement where most of Stage 8 is not. It belongs here and
  not in the walker, because it needs the Tympan.
- `chains` (a chain exists for every leaf too, so its start field is a body, not a planet), `cycles`,
  and the reverse `indexes`: `planetByName` · `houseByNumber` · `chainByPlanet` · `cycleByPlanet` ·
  `planetsDisposedByPlanet` · `housesRuledByPlanet` · `housesRoutingToHouse`. The indexes are the whole
  point: a lookup rather than a re-walk.
- `metadata` carrying `source`, `timestamp`, `stateKey` (the genome) and `topologyKey` (the label).
  **No stage may read any of them.** Harmless as provenance, fatal the first time a stage branches on
  one, because "all compile identically" dies that day.
- The frame-vector memo, and the persisted natal (§3.8).

**Drops:** `AstroState.id` (identity is the sequence; a second id invites the two disagreeing) · the
unnamed `metrics` bag (name each measurement or omit the field). Of Stage 8, **keep** path length,
descendant count, inbound degree, cycle membership, fixed-point membership and house routing load.
**Cut** outbound degree (always 1, in every chart, forever), density (a lossy re-encoding of "how many
planets are in domicile"), diameter (already `max(distanceToCycle)`) and **centrality** (a ranking with
a mathematical alibi; the moment an Expression carries one, "do not score" is over in practice with no
forbidden word anywhere).

**Told rather than derived:** synchronic placements are housed in the **native's** frame, never a frame
of their own. That is why the Tympan is an argument and not read out of the occupants' own Ascendant. A
parameter is not a branch, and passing it in preserves "identical output regardless of source" better
than reading it does. The one exception doctrine already grants: a **composite** supplies its own ASC
sign, because a composite genuinely has a horizon.

**Mechanical trap:** validate the **state** before reducing it. `720 % 360` is 0 and silently reads
row 0.

### 5.5 The seam pass · lands alone

`_connAt(jd)`, memoized on the **genome entry** beside `_axialAt` (the Tympan cannot go in the
`jd|lat|lon` cache key, so the memo keys on the entry). Fused per the instrument-survives-everything
law: the Connectome failing costs the Connectome, never the plate.

Replaces: `_specRows`' per-render ruler / house / dispositor-sign computation (around line 5581) and
the natal sheet's rules-houses loops.

**Acceptance, both measured:** nothing visible changes, and onboarding timing does not move. This pass
carries no new reading on purpose, so a regression can only be in one of the two halves.

### 5.6 The depth pass

New content at **depth level 3** on surfaces that already exist. Not a new socket, not a new sentence
needing a home: these tables become the stats under a placement for a native going deeper, and they
underwrite transit interpretation and forecasting.

- the chain under a placement (bearer, keeper, terminal kind) · the houses it governs · what routes
  into a house · reception with its kind · the co-ruler. **Shipped 2026-08-05**, on the single-body
  sheet's existing significations rows (`_signifRows`), read straight off the compiled Expression —
  no new computation, only exposure.
- **CORRECTION, 2026-08-05: the degree-level dignities did not exist anywhere in the codebase** when
  this spec claimed them as already computed. **BUILT the same day (v0.885), in `rulers.js`, where the
  dignity seam already put them.** Five rungs: domicile · exaltation · triplicity · bound · face, plus
  the Mater's debilities and `peregrine` for a planet holding none of the five.
  - **The sources were already ruled in `uploads/Orbo Traditions.md` and were not re-litigated:**
    **Egyptian** bounds, **Dorothean** triplicity rulers (day · night · participating), faces in the
    **Chaldean** order, which no tradition there disputes.
  - **The Ptolemaic bounds are NOT built,** though that document names them the alternate: a second
    table means a doctrine switch, a doctrine switch changes `_doctrineKey`, and that rebuilds every
    fertilized century in the field. Worth its own day, not a rider here.
  - **Sign resolution is the Mater's; below the sign is `rulers.js`'s.** The Mater's four tables are all
    twelve rows and stop at the sign. A bound is 1 of 60, a face 1 of 36.
  - **Stamped invariants, not asserted ones:** the five bounds of a sign close at 30°, each
    bound-holding planet holds exactly twelve, and the degree totals are the scheme's own (Saturn 57 ·
    Jupiter 79 · Mars 66 · Venus 82 · Mercury 76, summing to the circle). The lights hold no bound, and
    that is enforced rather than remembered. The 36 faces are stamped FROM the Chaldean cycle rather
    than typed out, so they cannot fall out of step with a rule that has no exceptions.
  - **Sect is an argument, never derived there:** `triplicityOf(signIdx, isDay)`, null meaning no lord
    selected, the honest answer for a placeless field. The `lots(asc, isDay, pos)` pattern again.
  - **NO SCORE: no almuten, no dignity points, no ranking.** Five rungs are five facts; which outweighs
    which is judgment, and judgment is the packs'. Grepped in `tests/rulers.test.html` against the code
    with comments stripped, since the header says the word in order to refuse it.
  - **A debility and a dignity are separate facts, never netted off.** The Moon at 20° Scorpio is in
    fall AND is water's participating lord; the ladder reports both, and `peregrine` stays the
    five-rung question.
  - Surfaced at **L3 only**, via `_dignityLadderRows` under the same ♑ Ladder toggle, on every
    single-body sheet. The rungs are a degree read and need no Connectome, so a failed Expression costs
    the chain rows and leaves the ladder standing. 34 new checks in `tests/rulers.test.html` (9 to 43).
- **The ladder is a toggle for L3 natives**, defaulting generous. A table is not an annoyance to a
  professional astrologer. **Its home is a fifth socket on ♑ Gears, provisionally** (decided
  2026-08-05): ♑ is already a `mode` tabula, and a mode socket picks what the field configures with one
  control at a time — a rung toggle is one setting even where its field holds two coupled controls
  (see below). The label caps at about 8 characters: `Ladder` (6).
- **Chain depth is a toggle too, not a "decide by looking" prototype** (revised 2026-08-05, in
  conversation): nested under the same Ladder socket, active only once the ladder itself is on —
  **Bearer+Keeper** (the terminus only, when the chain runs past the immediate dispositor already
  shown) or **Full path** (the whole chain, always inline). The native picks for themself; both
  render paths ship, permanently, replacing the earlier plan to prototype both and pick by looking.
- **The socket count goes 4 to 5, which reseats the ring**: `slot()` floors, so an odd count centres —
  an improvement over 4, which the v0.878 lesson already flags as having shipped dark once. Checked
  visually after the change.
  Register note, recorded not argued: dignity is not a gear. ♑ is the provisional home the user asked
  for, and it is worth revisiting when the back next gains a socket family.
- Held to the general depth contract already enforced by `_atDepth`/`_atLeast` (rows carry `d:3` and
  are filtered out below L3 regardless of the Ladder toggle), rather than a new bespoke
  `tests/depth-contract.test.html` — the mechanism is the one every other L3 row already runs under.

### 5.7 The watcher · named, unscheduled

Each placement watches its **current governor** rather than the engine scanning per body. This is the
reason the reverse index exists, it is where forecasting gets fine-tuned, and the "when does the
government next change" half is **already stored**: sign ingresses are materialized on the embryo and
on the synchronic weave, and both already carry `governed`.

Explicitly out of the Connectome pass, so the pass stays a table-building session.

---

## 6 · Mechanics

**Generated builds.** `tympan.js`, `dispositor.js` and `connectome.js` each get a generated
`.browser.js`. Edit the `.js` source of truth and regenerate; never hand-edit a browser build.

**Load order and the standalone law.** Plain `<script src>` for each, no module and no importmap.
`tympan.browser.js` loads after `mater.browser.js` (it imports the Mater); `dispositor` and
`connectome` after both. After the dependency change, rebuild the standalone and confirm **every**
`script[src]` in it is a `blob:` URL. Never capture a cross-script global at evaluation time; read it
lazily and gate on the dependency's own global.

**Tests.** `tests/tympan.test.html`, `tests/dispositor.test.html`, `tests/connectome.test.html`, added
to `tests/_suite.html`. Contracts pinned **before** call sites move, as the Ring's were. The forbidden
word grep is a test, not a comment.

**The review path.** The back is only reachable by a rim double-tap, which synthetic pointer events do
not reproduce, so review through `window.__orbo.setState(...)` as every other tabula pass has.

---

## 7 · Open questions

1. **ANSWERED 2026-08-05, see §3.13:** a synchronic composite has its own sect, from its own Sun against
   its own Ascendant. The three uses of an Ascendant are housing, selection and light, and only housing
   is fixed to the natal.
2. **ANSWERED 2026-08-05: favorites land on ♒ Archive, not ♎ Ledger and not an invisible LRU.** The
   sun/moon law already named the destination ("Pinning flows moon → memory (♒): you pin from where
   you're reading") — favoriting a whole chart is the same verb one level up from pinning a moment,
   so it rides the same dock rather than inventing a second one. A star on the ♎ roster row (where
   charts are already listed) toggles `favorite`; ♒ gains a fifth cut, **Favs** (label capped at ~8
   characters, so not the full word), whose field swaps its source to `state.saved.filter(favorite)`
   instead of `state.memory` — a different roster, the same row template and the same × (which
   un-favorites here, never deletes). Persistence rides the store §3.8 already named: a favorited
   chart's Expression compiles the moment it's starred (`_connFavor`) and persists to
   `orbo.connectome`, keyed exactly as `fertKey` is (frame vector × doctrine × codec). The natal
   Expression persists the same way, off the idle-warm trigger (5.5, §3.9) rather than at engrave.
3. **Confirm `rulers.disposition` is deleted** rather than parked, with its reception logic moved and
   its test rewritten.
4. Chain depth on the pane: prototyped both ways at the depth pass, per the decision above. Recorded
   here so the prototype is not mistaken for a ruling.
5. **Answered 2026-08-05, kept for the record:** the ladder toggle goes on ♑ Gears as a fifth socket,
   provisionally. See §5.6.

---

## 8 · The review pass (2026-08-05, v0.884)

Assessment after the pass landed, and what was fixed in the same session. The architecture held; the
findings were all seams.

**Three red rows in the suite, all three of them the harness telling the truth.**
- `tympan.test.html` counted the ordinal-to-index conversion at **three** call sites where the file's
  own header claimed one. Fixed in the code, not the test: `stamp()` now round-trips through
  `signOfHouse` and `rulerOfHouse`, so `house - 1` lives in exactly one place and the load-time check
  exercises the read path it is checking.
- `tympan.test.html`'s place refusal fired on `houseOfLon(lon, ascLon)`. **A body's longitude is a
  degree, not a place**, and the parameters now say so (`bodyLon`, `ascendantLon`). A refusal grep that
  fires on correct code gets muted, and then it protects nothing.
- `rewire-parity.test.html` STEP F was still grepping `rulers.js` for the `lonsFromDna` flattening loop
  that 5.3 deleted. The care spent rewriting `rulers.test.html` was not extended to the parity harness.
  It asserts the **absence** now: a deleted reader cannot flatten in the wrong order, and a regex
  hunting a function that no longer exists is a green that means nothing.

**THE HARNESS HOLE WAS HIDING A DEAD HALF OF THE SUITE, and this is the real finding of the review.**
`_suite.html` printed once at 22 seconds and counted a suite with zero `<tr>` rows as `ok`. Nine suites
(timespine, loom, loom-algebra, mundane, embryo, fertilize, luna, lots, astrodna) reported "0 rows, 0
fails" and were read as green. They were not slow. **They could not boot.** `framing.browser.js` and
`astrodna.browser.js` were repointed at the Tympan by 5.2 and both guard on `window.__ORBO_TYMPAN`
before registering, and those nine pages never loaded `tympan.browser.js`, so each sat in its dependency
poll forever with no error: about 470 checks, the whole loom / embryo / fertilization / luna / mundane
body of work, silently not running from the moment the pass landed. The nine pages load the Tympan now.
- The aggregator was fixed with them, because the pass would have been caught the same day if it
  reported honestly: it re-renders every 2s to 120s, a rowless suite reads **WAIT**, a suite whose
  `#out` carries an error reads **FAIL**, and the verdict line refuses to say ALL GREEN until every
  suite has rows. **An unfinished suite is not a passing suite, and an empty one must never look like
  one.**
- The general lesson, which is the browser-build guard's own: a dependency added to a `.browser.js`
  file is added to **every HTML page that loads it**, and the guard's patience is what makes the
  omission silent rather than loud.
- **Green after the review pass: 756 checks, zero failures, 18s** (ring 70 · mater 51 · tympan 57 ·
  dispositor 29 · connectome 62 · rulers 9 · timespine 12 · loom 25 · loom-algebra 44 · mundane 35 ·
  embryo 31 · fertilize 38 · luna 20 · lots 20 · astrodna 50 · rewire-parity 203).

**The standalone was one version behind.** The DC was v0.883 with three new `<script src>` tags and the
newest export on disk was v0.881, so §6's blob confirmation had never been run against the Connectome.
`Orbo Astrolabe v0.884 standalone.html` is built and checked at runtime: 26 `script[src]`, every one a
`blob:` URL, and `__ORBO_TYMPAN`, `__ORBO_DISPOSITOR` and `__ORBO_CONNECTOME` all registered with
`express` live.

**§3.8's store had no reader.** `_connPersist` was called from the idle warm and from `_connFavor`, and
nothing ever read `orbo.connectome` back, so the persistence this spec argued for bought nothing and
CLAUDE.md's older do-not-persist ruling was still the operative behaviour. `_connHydrate` is the reader:
one idle read a session, every filed Expression whose key still matches this codec and this doctrine
into RAM under its own key, consulted by `_connFromMap` before it compiles. A stale key is neither
loaded nor deleted; the next persist overwrites. Hydrated Expressions are re-frozen, because structured
clone drops the freeze on the way out of IndexedDB.

**There was one occupant set in the spec and two in the code.** `connAt` projected
`CANONICAL_ORDER` (14, with Node, Chiron and Lilith) and `_connFromMap` projected `this.BODIES` (10),
so the same chart compiled two frame vectors, filed two memo entries, and the natal sheet could not
show a Node or Chiron chain the persisted natal Expression already held. `_connFromMap` reads
`C.CANONICAL_ORDER` now. Both projections also hand-rolled `floor(lon/30)`; both go through the
Mater's `signIndexOf` (§3.11's declared projection) through the one `_signOf` door.

**Open, and deliberately left as doctrine calls rather than fixed in passing:**
- **CLOSED 2026-08-06 (v0.886): `keeper` is a `{kind, id}` record and a fixed point IS a cycle.** The
  ruling is the one this file's own §2 already made and the walker declined to honour: ONE termination
  rule means ONE terminal shape. A 1-cycle is registered like any other, so `indexes.cycleByPlanet`
  answers for a planet at home, `keeper` names its own kind instead of being a planet NAME here and a
  cycle ID there, and no pack has to special-case the most common terminal in astrology. `terminalKind`
  stays beside it (it is exactly `keeper.kind`) because every reader already spells it that way. The
  VALUE of a domicile keeper did not change, its SHAPE did. `connectome.CODEC` is 2; a filed Expression
  misses and recompiles in microseconds, and nothing else in the app keys on it. `topologyKey` is
  unaffected: it counts `terminalKind`, which already said `domicile`.
- **CLOSED 2026-08-06 (v0.886): the Expression publishes its own cache key.** `metadata.frameKey` is
  the frame vector `express` memoized on, and `connKey` takes the Expression. `_connKeyFor` used to
  rebuild the vector out of `planetTable`, `houseTable[0].sign` and `light`, which is a SECOND
  projection of the one thing §3.11 says must have exactly one ("the walker's input IS the cache key,
  so the two can never disagree"). It agreed only because sect and `light` are bijective; an Expression
  carrying a sect without an Ascendant would have keyed wrong, silently. The pre-compile form of
  `connKey` survives for a caller that wants to look in the store before compiling, and both go through
  one string builder.
- **SUPERSEDED, see the closure two bullets down: the six kept measurements** (path length, descendant
  count, inbound degree, cycle membership, fixed-point membership, house routing load) were not on the
  Expression by name. All six are derivable from `indexes`, which under §3.10 may be the better answer,
  but then this spec should say they collapsed into the indexes rather than reading as a list that was
  skipped. **It says so now (§10), and the one that was not a single read became a row.**
- **CLOSED 2026-08-06 (v0.887): `_connStore` prunes.** See §10.
- **CLOSED 2026-08-06 (v0.887): the six measurements.** Five were already index reads; descendant count
  became `indexes.descendantsByPlanet`. See §10.
- **♑ Ladder remains the provisional home,** and the register note stands: dignity is not a gear.

## 9 · The contract pass (2026-08-06, v0.886)

Three items off the review's own open list, taken together because the first two both move the stored
shape and the codec should bump once. Contracts pinned in the tests BEFORE either module moved, as the
Ring's were.

- **The keeper record and the registered fixed point** (§8, now closed). `dispositor.walk` and
  `connectome`'s `walkHouses` share one registrar each, so a fixed point cannot be recorded differently
  from a pair by having its own branch. Pinned in `tests/dispositor.test.html` §11 and
  `tests/connectome.test.html` §7b.
- **The published frame key** (§8, now closed). Pinned in the same §7b, including that the two `connKey`
  forms produce a byte-identical string and that a doctrine change misses.
- **The stale header in `astrodna.js`.** It named `rulers.lonsFromDna` as one of four live readers for a
  day after 5.3 deleted it, while this harness's own copy of the same sentence had been corrected. The
  instance is fixed; the GENERAL guard is the point: `rewire-parity` now greps eleven sources and fails
  on any line naming a deleted reader without a sentence recording the deletion (±1 line, because a
  sentence wraps). **A header is where a deleted reader goes on living**, and the next person to read it
  cites it as current.

**Not in this pass, on purpose, so it stayed a contract pass:** `_connStore` pruning · the store lookup
that runs before the memo in `_connFromMap` · the eighteen hand-rolled `floor(lon / 30)` projections
still in the DC outside `_signOf` · the six kept measurements not being on the Expression by name.

## 10 · The cleanup pass (2026-08-06, v0.887)

The four items §9 deferred, plus the standalone's one unresolvable reference. `connectome.CODEC` is 3.

**The `%23n` warning was a data URI eating itself.** The mater's dither is a percent-encoded
`data:image/svg+xml` whose own `<rect>` carries `filter=%22url(%23n)%22` — a fragment pointing at a
filter inside that same URI. The bundler's CSS `url()` extractor reached through the outer URI and tried
to fetch `#n`. Nothing was broken offline. Base64-encoding the data URI fixes it: identical SVG, no
`url(` substring left to extract. **A warning that is always a false positive gets ignored, and then it
protects nothing** — which is the same argument §8 made about a refusal grep firing on correct code.

**The store's growth vector was never the cap.** §3.8 named LRU, and the unbounded thing turned out to
be rows under a key this build can no longer FORM (a doctrine change, a codec bump). No cap reaches
those, because nothing loads them again. Three mechanisms, in the order they actually matter:
`_connHydrate` deletes a non-matching key · `_connForget` drops an un-favorited chart, sharing
`_connResolve` with `_connFavor` so a row cannot be filed under one key and dropped under another ·
`_connPrune` caps at 32 with `keep` on the natal alone. An evicted favorite recompiles in microseconds:
the row saves RESOLVING a chart through the spine, and was never the only copy of anything.

**The read path compiles first.** `_connFromMap` reached the store before `express`'s memo, paying for a
doctrine key and a frame vector that `express` then rebuilt. Memo first; the store read stays, off
`metadata.frameKey`, for object identity.

**The sign projections: 25 to 9.** Everything feeding a table goes through `_signOf`. Nine reads across
eight lines remain, each a named exception, and the count is pinned: 2 doors, 5 predicate reads, 2
formatters. The predicates keep the `_houseOf` ruling (arithmetic in a hot loop is not a second table);
the formatters need the sign and the remainder off one normalization, which the door does not return.

**Five of the six kept measurements were already index reads. The sixth became a row.** Path length,
inbound degree, cycle membership, fixed-point membership and house routing load are each one field read,
so this spec should have said they collapsed into `indexes` rather than listing them as owed. Descendant
count genuinely needed a walk, so `indexes.descendantsByPlanet` is a table now (§3.10, firing exactly
once). It is TRANSITIVE and `planetsDisposedByPlanet` is IMMEDIATE; they are different facts and stay
separate. The cut four are asserted absent by grep.

**Still open after this pass:** ♑ Ladder's provisional home (the register note stands: dignity is not a
gear), and the watcher (§5.7), which is named and unscheduled by design.

### The break this pass shipped, and the hole that hid it

The cleanup pass went out with a DEAD LOGIC CLASS. Two mechanical wounds from the bulk `floor(lon / 30)`
rewrite and the `_connHydrate` rewrite: a stray `0)]` (an `old_string` copied out of TRUNCATED grep
output, so the tail of the original line survived the replacement) and a duplicated `} catch (e) {}` (a
`new_string` that closed a block the surrounding text still closed). Either one alone kills the whole
class: the component never evaluates, the template renders with props only, and the instrument never
draws.

**The suite said ALL GREEN, 822 checks, zero failures.** It was telling the truth about every claim it
makes, and every claim it makes about the DC is a GREP over the file as text. **A SyntaxError passes
straight through a grep.** This is the same shape as the harness hole the review pass found in §8 (a
suite with zero rows read as `ok`) and the same shape as "an invariant in a comment is not an
invariant": a check that cannot fail on the thing that is broken.

So `rewire-parity` opens with **STEP 0**, before it asks anything about what the source says: the logic
class is extracted and compiled with `new Function`, and the template's control-flow tags are counted
open against closed. A grep is a claim about source; STEP 0 is a claim about the program.

**Two working rules, recorded because both were violated in one session:**
- **Never build an `old_string` from grep output.** Grep truncates its lines, and a truncated match
  replaces a prefix and leaves the tail welded to the replacement.
- **A bulk edit is verified by PARSING, not by reading the diff.** Every changed line in that pass reads
  correctly in isolation, and the file still could not run: the damage was a brace balance, which is
  invisible line by line and obvious to a parser.
