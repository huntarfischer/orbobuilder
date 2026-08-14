# Phase 6 · The Synchronic Prism

Planning document, 2026-08-06. Nothing in here is built. It supersedes nothing; it resolves the
pre-ruling in `The Connectome Pass.md` §3.13 ("the synchronic clock is a windowed generator in the
shape of `luna.js`, never a table on the spine and never fused") by finding that most of what that
pre-ruling budgeted for a scan is **fixed at engrave** and belongs in the Connectome instead.

---

## 0 · The statement

**The prism is an optical element in the path between the sun and the moon.**

The astrolabe is the light: real time, zodiacal, unchanged. The lunar pane reflects that light, by
exactly the readers it already has. Insert the prism between them and nothing about the source moves
and nothing about the reader moves; **the values arriving at the reader are refracted.** Every
position becomes `midpoint(natal, now)`. The horizon becomes `midpoint(natal ASC, rising degree)` and
takes a seat as a real occupant forming real aspects.

That is the whole feature. Everything below is consequence.

**And the refracted set is a CHART, not a set of values borrowed for comparison.** It has its own
internal aspect web, its own sect, its own dispositor chains. This is settled by observation rather
than argument: see §2.1.

---

## 1 · What this buys, and why it is not a scan

The clock's pre-ruling priced it as a generator because the sASC crosses roughly 11 marks per body
per day, about 130 rows a day. That number is right and it is still the reason nothing here
materialises events. But the pre-ruling did not notice what the sASC's own algebra gives away:

**`sASC = midpoint(nASC, risingDegree)` contains no time.** The map from rising degree to synchronic
Ascendant is a fixed relation of the native's chart, settled at engrave. All of the sASC's
time-dependence is inherited from the horizon's own rotation. Stated in the user's words: the
midpoint of a Scorpio Ascendant and an Aries horizon is always the same degree; what moves every day
is **when** that horizon degree rises.

Three results follow, and together they are the reason this is a Connectome pass and not a loom pass.

### 1.1 The synchronic day is a FIXED TEMPLATE plus one number

The sASC moves forward at half the horizon's rate and makes exactly one jump per day. The day is:

| | |
|---|---|
| **anchor** | the horizon reaches nASC · sASC sits at nASC · phase 0 · **your Ascendant rising** |
| | forward through the 2nd, the 3rd, into the 4th |
| **flip** | the horizon opposes nASC · sASC jumps pole to pole · **your Ascendant setting** |
| | forward through the 11th, the 12th |
| **home** | the anchor again |

Seven houses, six sign boundaries, one flip, ending where it began. And because the arc is nASC ±90,
which is ±3 signs, the houses are **always the 10th through the 4th, for every native.** The
itinerary is universal; only which signs carry it are yours.

The **durations** of those seven segments are the ascension times of their arcs at the native's
latitude, so they are constant to within seconds over a lifetime. They are wildly unequal: some
segments run forty minutes and others three hours, permanently, as a signature of latitude and rising
sign. **The dial is uniform in degrees and the ledger is not uniform in time, and the disagreement
between them is the reading, not a rendering defect.**

What changes from day to day is only the template's **offset**: the anchor regresses about 3m56s per
day, which is pure sidereal arithmetic and needs no ephemeris.

### 1.2 The offset's own period is one year, which is why this felt like a solar return

The anchor's civil time walks backwards through the 24 hour clock and returns to itself once per
year. The sidereal and solar days beat at exactly one year. So the user's intuition that the
composite frame of the day is a solar return technique is not an analogy: **the synchronic day is a
fixed shape whose phase against civil time completes one revolution per year.** Composite chronology
samples that shape once per rotation; the clock watches the shape itself.

### 1.3 A day's ledger is a template evaluation, not a grid pass

Over one day every occupant except the Moon is effectively parked (a synchronic body moves at half its
sky rate: sMercury about 1°/day against the sASC's 180°). So a day's rows are the sASC's sweep
crossed against a nearly static set of marks, and each row's time comes from the ascension template
rather than a scan. One spine sample, table lookups, and one refinement iteration per row.

**The Moon is the exception, again, and for her own reason.** At 6.6°/day synchronic she is not parked
within a day. She is `luna.js`'s business, exactly as she already is on every other layer, and this
plan adds nothing to her but a fourth kind.

---

## 2 · The optical law (the sun/moon law, extended)

Stated so it can be enforced rather than admired:

- **The source does not change.** The astrolabe remains real-time zodiacal. No new hand, no new
  engraving, no new geometry on the wheel. The prism **bends the hands already there**; the sASC is
  not a new hand, it is the horizon refracted.
- **The readers do not change.** Every pane view reads what it already reads, by the code it already
  has. A view that shows a sign, a house, a lord or an aspect shows a refracted one when the prism is
  in, and does not know that it is.
- **The prism is the only thing inserted, and it is inserted at ONE seam.** If two places in the app
  refract, they will disagree. There is one refraction door, the way there is one spine door.
- **The seam is a wheel's occupant slot, which already exists.** §2.1. The prism does not need a new
  insertion point; it needs to be a thing a wheel can carry, the way `The sky`, `No one` and a person
  already are.
- **The face must declare the prism, and it already does.** This was written as the plan's one
  non-negotiable safety requirement, on the grounds that a reader who mistakes a refracted degree for a
  real one has been lied to by the instrument. It is satisfied by furniture already shipped: the wheel
  cards read `THE PLATE · Composite me · synchronic · you × now` against `THE RETE · The sky · current
  transits · live`. **Retired as a new requirement, kept as a standing one:** every wheel says what is
  seated on it, always.

### 2.1 THE PRISM IS A CHART, AND THE WHEEL IS THE COMPARISON ENGINE (ruled 2026-08-06, from the instrument)

Settled by looking at what is already built. In composite chronology today, with the rete carrying the
live sky, the wheel draws a full web. **With the rete set to `No one`, the composite wheel draws no web
at all.** Yet the live sky, alone, does aspect itself: the reading's solo case is implemented and #2b
even spreads its web by 14px. So the instrument knows how to aspect a single chart against itself and
declines to do it for a derived one.

That is the defect and it is also the ruling. **A composite is not one half of a comparison, it is a
chart.** If the sky alone aspects itself, a refracted chart alone must too, by the same law and the
same code.

So the answer to "is the prism a whole-instrument state or a lens you look through" is neither, and
**"both" is the committal answer** because the right unit is not a mode at all: **the prism is a chart
that can be seated on a wheel.** Seating is already a two-slot operation, so both readings exist by
construction and no switch is needed:

| plate | rete | the reading |
|---|---|---|
| prism | the sky | synchronic against real |
| prism | no one | **the synchronic chart in itself** |
| natal | prism | my chart against my refracted now |
| prism | another native's prism | synchronic synastry (§8) |
| prism | prism at another moment | the layer against its own past |

Consequences for the build, all of them reductions:

- No new insertion point. The refraction door fills an occupant slot that already exists.
- No new declaration mechanism. The wheel cards already name what they carry.
- A different astrolabe face is what seating a different chart already means, so "enabling the prism
  gives a different face" and "nothing new lands on the instrument" are both true at once.
- **The solo self-aspect defect is P0**, because it is the thing that proves a derived chart is a chart.
- **Seating has a LAYOUT law too, and it is broken today** (§12). If the prism is a chart that gets
  seated, then how two seated charts are drawn is part of this pass rather than a later polish: it is
  the law the prism inherits the moment it exists.

**And it is doctrinally unblocked, which is the surprise.** It looks like it should collide with the
twice-deferred `_compPairs` two-orb question, and it does not: a composite chart has one Mars, so its
internal web is entirely **cross-body**, where nothing halves and ordinary orbs apply. A body meets
itself only when a composite is read against its own natal, which is the paired reading that already
exists and already carries the hardcoded 3°. **So P0 needs no doctrine call and the deferred one stays
exactly where it is.**

### 2.2 THE THREE SPINES ARE THE LOOM'S THREE LAYERS

The user's framing: the synchronic spine, the timespine derived from the engrave, and the Orbo timespine
derived from the ephemeris that ships are of equal standing and must be comparable against themselves
and against one another. They are already named, and the naming is the loom's:

| the spine | the loom layer | what it is | built |
|---|---|---|---|
| Orbo timespine | **floor** | the sky with nobody in it | shipped (the embryo) |
| engrave timespine | **contact** | the chart in the sky, the two remaining two | fertilized per chart |
| synchronic spine | **synchronic** | the two become one placement | fertilized, and structurally fixed at engrave (§3) |

So "compared and contrasted" has two existing homes and needs no third: **the wheel is the
instantaneous comparison** (§2.1's matrix) and **the almanac is the temporal one** (the floor beneath,
streams on top). What this pass owes is the synchronic layer's full presence in both, not a new
comparison mechanism.

Vocabulary hazard, noted and deliberately NOT resolved here: the astrolabe's *plate* is historically
the interchangeable engraved disc, which is what the prism behaves like, and Orbo already spends
"plate" on one of the two wheels. Renaming a wheel is its own day's work and its own ruling. **This
pass uses "prism" and touches no existing name.**

---

## 3 · The honest inventory: what is fixed at engrave

The Connectome's entrance test is "fixed at engrave, never rebuilt". Applied strictly, and with one
refusal that matters:

**FIXED AT ENGRAVE (Connectome members):**

- **The arc**, per occupant: bounds at natal ±90, the six sign boundaries inside it, and each
  boundary's readings (sign, house under the native's Tympan, domicile lord, and whether the lord
  changes). `synchronicTargets` computes the boundary degrees today; what is missing is that their
  *readings* and their *order* are a permanent table of the chart.
- **The reachable set**, per occupant: the seven signs and seven houses a synchronic placement can
  ever occupy, forever. This is a fact a native should be able to read.
- **The itinerary**, for the sASC alone: the ordered seven segments with houses, lords and durations,
  plus the anchor and flip as the two structural instants. §1.1.
- **The same-body families**: `{δ/2, 180−δ/2}` per pair, already `beadFamily`, time-invariant because
  the sky term cancels. Which marks a same-body pair can EVER form is settled at engrave.

**NOT FIXED, and must never be stored:**

- **Cross-body separations.** `sA − sB` carries `(skyA − skyB)/2`, which does not cancel, so a
  cross-body pair can form any mark. There is no family and no table.
- **Any event time.** The pre-ruling stands: no synchronic clock rows on the spine, ever, and never
  fused. What is stored is the STRUCTURE the live cursor is read through, which is why "the synchronic
  timespine is calculable at engrave" and "the clock is never a table on the spine" are both true.

**REFUSED, and this is the ruling most likely to be argued with: a 360-row refraction table per
occupant.** It is tempting because it makes every synchronic position a lookup. It is refused because
the refraction is `midpoint(natal, sky)`, one wrap and one halving, and this codebase has already
ruled that arithmetic in a hot loop is not a second table (`_houseOf`'s rotation, kept inline and
pinned at one occurrence). A table would also quantize to whole degrees, and the codec law is explicit
that the genome is an identity and never a measurement source.

**So the prism's arithmetic stays arithmetic and the prism's structure becomes tables.** Which is the
same split as everything else here: categorical facts exact from the coarse reading, residuals from
the floats.

---

## 4 · The reading path: two lookups and a Ring read

At any instant, for any pair:

1. refract each occupant (one line, one door),
2. ask the Ring for the relation between the two degrees,
3. join the residual off the floats.

**No new geometry anywhere in the synchronic layer.** And a vocabulary correction owed from the
planning conversation: **the word is always the Ring's word for the mark.** Conjunction, sextile,
trine. "Contact" is the loom's LAYER name and nothing else; it never stands in for an aspect. This
plan had been using it loosely and does not, below.

---

## 5 · The sASC as an occupant

Three uses of an Ascendant (§3.13) all land on this one occupant at once, and they are three different
questions rather than three answers to one:

- **HOUSING · fixed, natal, never derived.** sASC in Leo is in the native's 10th. This is where the
  narrative lives, and §1.1 is why: the 10th-to-4th walk is a story, where the derived 1st has none
  because it is always the 1st.
- **SELECTION · legal on a moving Ascendant.** Leo rising in this hour selects Leo's frame, whose lord
  governs the hour. Seven lords a day. This is where the election lives.
- **LIGHT · sect, from sASC against sSun.** Already ruled. Consequence already ruled and worth showing
  rather than hiding: a synchronic reading can be nocturnal while the native is diurnal, and the light
  chain and all eight lots turn with it.

**The discipline that permits both of the first two: the derived frame may NAME the hour and may never
RENUMBER a placement.** That is precisely the cASC handoff's existing standing. Two rows, two facts,
and the interpretation layer is handed both instead of one contested one.

Naming hazard to settle before either is drawn: the rising-lord stream already answers "who governs
the hour" from the **sky** Ascendant, twelve handoffs a day. The clock answers it from the
**synchronic** Ascendant, six a day, at different times. Two lords of the hour on one pane need
distinct words.

**Open ruling · is the sASC in the Expression's frame vector?** The Connectome excludes the lots
because Ascendant-speed occupants change sign every couple of hours and blow the memo. The sASC is
Ascendant-speed too, and §3.12 already priced it at about six recompiles a day with eyes open. The
line I would draw: **one Ascendant-speed occupant is priced and eight are not.** The sASC is
frame-defining (its sign selects a lord) and belongs in; the lots stay read-live. Wants your ruling.

---

## 6 · The scan, and the invertibility question

Because the map inverts, a sASC event does not need to be searched for. It is looked up and then the
horizon is asked when it arrives:

- a sign boundary `B` is reached when the rising degree is `2B − nASC`. Six a day.
- a mark `m` to occupant P is reached when the rising degree is about `nASC + 2(m + sP − nASC)`, and
  since sP is slow that target barely moves, so it is one horizon root-find plus a correction.

`_risingWindows` already does horizon root-finding at exactly this cadence, and `spine.ascProbe`
exists precisely because per-sample genomes stall a horizon scan.

**This is a real tension with the one-scanner law and it is flagged, not decided.** The law says
`loom.js` scans. The counter-argument is that the horizon has standing precedent for its own door and
that invertibility is a genuine geometric difference rather than a shortcut. The resolution this
codebase's own habit prescribes: **build it on `scanTargets` first, measure the inverted path against
it, keep both counts as constants in the test, then delete one.** That is 7b's max-delta-0.00 pattern,
and it is how the pullback died honestly.

One thing the scanner will need either way: `STEP_FOR` has no Ascendant and defaults to a day for the
fastest occupant in the instrument. Marks come as close as 6° apart, so at 180°/day the step must be
under 0.033 days merely not to skip a root, and about 0.01 days to satisfy loom's own comment.

---

## 7 · Expression: the tabula and the pane

**The back configures. The pane reads.** Nothing interpretive on the back, nothing configurable on the
pane.

### The tabula

**RULED 2026-08-06: a socket in ♓ Composite**, the chart × chart tabula, which already holds `Moment`
(synchronic composite), `Chronicle` (composite chronology) and `Synastry` (synchronic synastry). The
prism is that tabula's present tense, so it is a fourth item socket there and not a plate of its own.
Word proposed: **`Clock`**, matching its siblings' habit of naming the READING rather than the
mechanism, with "prism" living in the field's definition as the mechanism's name. 5 characters, inside
the 8 character cap.

**Mechanical check owed at build:** four items is an EVEN count, and `_tabVals`' `slot()` floors, so one
socket seats right of top. ♑ Gears was dark from the day it shipped for exactly this and the record says
to check the ring after changing any item count.

Register per the back's law: the field is a glossary entry in third person declarative, the term in
incised gold, the definition in stone. Icon on top opens, rune below etches. Not "my chart and the sky
became one" but "the chart formed by refracting every position to its midpoint with a natal chart".

The electional query stays ♏ Timing's, where electional already lives.

### The pane

Three readings, one dataset, in build order:

1. **The dial** (primary, and the reason to build any of it). **SUPERSEDED BY §14.1: the dial is the
   wheel in the composite frame**, which already exists, so this is not a pane widget to draw. Kept for
   its reasoning: it is the only place in the instrument where the arc law is watchable rather than
   asserted, because Mars traverses its arc every couple of years and Pluto once in eighty-three, and
   the sASC does the whole thing between waking and sleeping.
2. **The ledger** (the user's correction, accepted, with the row redefined). A flat list of 130
   perfections a day is noise. **The row is a segment of the day**, holding the perfections that fall
   inside it: sASC in the 11th, 09:14 to 11:40, lord Mercury, and these three marks. Seven rows a day,
   forty-nine a week, which reads. This is not new machinery: it is `switchGroups`' own insight from
   the other side, where the Moon is the switch of the floor and the sASC is the switch of the clock.
3. **The query** (electional, and the reason the clock is actionable at all). You cannot choose where
   Saturn is; you choose when you walk in the door, and that choice sets the sASC and every relation
   it forms. Every other reading in Orbo says what the hour is. The clock says which minute to take.

Depth is a property of moonlight, so all three carry L1/L2/L3, and the pane keeps its first-person
spoken voice.

---

## 8 · Synchronic synastry, on the same machinery

Two natives, two arcs, one sky, and no new engine. Same-body separations remain time-invariant, so
only cross-body relations and the flips move.

**But the clock breaks the synastry cancellation, and this is the one genuinely new doctrinal result
in the plan.** The synastry law holds because body longitudes are geocentric, so the sky term cancels
and two people export byte-identical flip calendars. That cancellation is over **bodies**. The sASC is
an **angle**, and angles depend on place, so `sASC_A − sASC_B` retains `(skyASC_A − skyASC_B)/2` and
does not cancel.

Consequence: **two people in different cities have synchronic Ascendants that drift apart through the
day, and two people in the same room share theirs exactly.** Everything else Orbo computes is
place-invariant by law. The clock is the one layer in the instrument where being in the same place is
the entire content, which is also why it is the electional layer.

---

## 9 · Refused

- Any clock row on the spine. Any fuse. (The pre-ruling, upheld.)
- A refraction table. §3.
- Re-housing a synchronic placement from a derived Ascendant, in any reading, ever.
- A second refraction door.
- Lots in the frame vector. They stay read-live, per the Connectome.
- A prism that is not visibly declared on its wheel.
- A prism "mode" switch. It is a chart that gets seated, per §2.1.
- The word "contact" for anything but the loom layer.
- The em-dash.

---

## 10 · Build order, with what each step must prove

Each step is shippable and each has an acceptance that is a measurement rather than an opinion.

- **P0 · a derived chart is a chart. DONE (2026-08-06, v0.889).** The solo self-aspect: with the rete
  empty, a composite wheel draws its own web, by the same code the solo sky already uses. Cross-body
  only, ordinary orbs, no doctrine call (§2.1). The gate that suppressed the web on "a composite
  exists" now suppresses only on "a partner is threading" (`platePartnered`: a person/event seated on
  the rete, or the ambient sky threads live) — those two conditions coincided for as long as a
  composite was only ever read against something, and stopped coinciding the moment it could be read
  alone. cASC joined the web as an ordinary occupant, at the rim (`R+1`) while bodies sit at `rN`.
  *Measured:* before, `__orbo.setState({composite:true, rete:'off'})` drew no web at all among the
  gold beads; after, it draws the composite's own cross-body web. The paired case (sky on, person
  seated) and the natal-solo case (composite off, rete off) are unchanged. cASC reads well at rest;
  behavior at Ascendant speed is untested here and is the clock's first open question for P1.
- **P0b · seating. DONE, v0.890** (function only: §12.2, §12.4, §12.5. §12.3 materials and §12.6 the
  legend stay deferred by the 2026-08-06 ruling.) **REPAIRED v0.891** — see the entry below; §12.3's
  light-versus-stone framing was struck and the material law replaced it. The defect was one radius: a person or event seated
  on the rete drew at `rB = rN - 19`, a THIRD band invented because `rBody` was read as belonging to
  the sky rather than to the RETE. *Measured, two natals seated:* before, three tracks at `R-53`
  (empty, the sky's reserved track), `R-75` (A) and `R-94` (B), the two charts crowded into the plate's
  neighbourhood with two `As` chips a hair apart; after, exactly two tracks, `R-75` (A) and `R-53` (B),
  the outer track occupied by its own occupant and the third band deleted with the `rAsp` frozen-seat
  push-in that existed to make room for it. Angles: one horizon, one meridian, the plate's; the rete's
  As is a bead on the rete's track, so the collision is resolved by geometry and not by de-confliction.
  Web: the inter-chart family lost its dash and its violet hue-tag and now reads `_webColor`'s harmony
  family, cross-aspects being unmistakable as chords spanning the two tracks. Sky-vs-person and
  person-vs-person go through the one generalized track assignment. Natal-solo and composite-solo are
  untouched (P0's `platePartnered` gate, `natT`, `plateT` unchanged).
- **P0b-repair · the material law. DONE, v0.891.** P0b put the rete's occupant on the right track and
  left it drawn the wrong way, because the treatment was never a function of an occupant: it was an
  inline loop gated `skyOn ? drawOrder : []`, sourced from `this.pos`, with a hand-rolled second routine
  for everything else. §12.3 struck, §12.7 rulings 1 to 3 closed, §12.8 opened.
  *Built:* one `_drawLitTrack(ctx, occ)` taking `{pos, asc, names, r, rN, rAsp, frozen, A}`; the flat
  routine and its violet recessed band deleted; `_reteChart` gained `full` (place-dependent angles from
  the chart's own place, `pos` left alone for its existing readers); the dead
  `if (!skyOn) this._screen = {}` removed; a seated chart's Ascendant rides the track as an ordinary
  angle bead while the sky's keeps the rim badge, since the sky's Ascendant IS the horizon.
  *Measured:* `skyOn` no longer selects a treatment (8 uses left, all about occupancy or threads);
  CODE lines 8314 → 8287, **down 27** (total file +3, entirely the comment recording why); the seated
  chart now draws element-coloured, glowing, period-sized, de-collided, with its own moon phase and its
  own MC/IC/Ds/Vx; `tests/rewire-parity.test.html` all green including STEP 0's compile and tag-balance
  checks; the sky path reduces to the identical arithmetic (`frozen: false`, `asc: null`, `act` carries
  no `ASC`), so the live-sky render is unchanged.
  *Not done, deliberately:* tapping the rete's occupant to open its reading. §12.8.
- **P1 · the seam. DONE, v0.892.** One refraction door, the sASC among the occupants, the prism
  seatable on either wheel. As built:
  - **`framing.refract(natalLon, momentLon)` is THE ONE PLACE IN ORBO THAT REFRACTS,** and it is meant
    to be greppable. `loom.js`'s `lonAt` composes through it, so the scanner and the instrument cannot
    drift apart on what a synchronic degree is. `midpoint` survives untouched for what it actually is:
    chart × chart. `_mintCompositeAB`, `_ensureCompositeAB` and `_mintPP` stay on `midpoint`
    DELIBERATELY — a chart × chart composite is not a refraction, and routing them through the door
    would destroy the very greppability the door exists for.
  - **The readers take it, and that took a repair caught on review.** Three pane gates tested the OBJECT
    SHAPE (`typeof r === 'object' && r.jd`) as a stand-in for occupancy, so the string sentinel fell
    through and the instrument drew a prism while every moon view reported an empty seat. Occupancy is
    `_reteSeated()` now. **But occupancy is not otherness:** the synastry grid and Crossing build
    (natal × moment) × (natal × moment), so the prism as "them" would refract an already-refracted chart
    and returned 21 plausible, meaningless rows. They take `_reteIsOther()` and refuse with
    `reason: 'pair'`. Three questions of a seat — seated, frozen, other — three predicates.
  - **The instrument's own drawing is untouched**, which was the phase's proof obligation. No new hand,
    no new geometry, no second drawing routine: the prism reaches the rete as an ordinary occupant
    (`_prismChart()`, shaped like `_reteChart`'s return) and `_drawLitTrack` takes it without knowing
    what it is. The cross-track web, `_reteSpec` and the synastry grid likewise.
  - **The prism is `frozen: false`**, alone among non-sky occupants: it MOVES. It washes pale through a
    scrub the way the sky does, for the same reason — it is the sky, refracted.
  - **But it writes no scrub hit,** and for a sharper reason than the frozen seat's: `this.held`
    resolves longitudes through `this.pos` (the cursor's own sky) and a refracted degree is not one of
    those, so a grab would scrub against the wrong map. The rim ASC badge is exempt (it is the plate's
    horizon, not the prism's).
  - **Prism-on-rete is mutually exclusive with composite-on-plate.** The same chart on both wheels
    would thread every bead to itself at 0°, so seating it on the rete hands the plate back its stone.
  - **THE LOTS REFRACT LIVE** (all eight), which is one line and exact under any single-sect reading.
    §14.2's sect question blocks storing a lot arc, not refracting one.
  - **Double-tapping the sASC bead enters `frame: 'natalAsc'`** — §14.1's ruling, and no fourth stop:
    the natal sASC IS the natal ASC, so the frame already existed and this is a new entry point to it.
  - Verified: `tests/loom-algebra.test.html` is **48 checks** (was 43), the five new ones pinning the
    door's contract — refraction is the midpoint at 36000 samples with max delta 0, null-tolerance, the
    §13.4 lot commutation, and §1.1's 359 half-steps plus exactly one flip a day. `tests/loom.test.html`
    25/25 unchanged, so the scanner's roots did not move.
  *Not done, deliberately:* §7's ♓ Composite `Clock` socket, the P2 tables, and the qualified-house
  discipline (§13.1) beyond what the prism's own card already declares.
- **P2 · the tables. DONE, v0.893.** `prism.js` + `prism.browser.js` + `tests/prism.test.html` (55
  checks, in `_suite.html`). The user's own framing drove this and it is literally true: **the
  synchronic layer is a whole other timespine, calculated once and then displayed**, because §1's
  `sASC = midpoint(nASC, rising degree)` CONTAINS NO TIME. As built:
  - **`build(natal)`** → frozen tables per occupant: the **arc** cut into its seven stretches (each with
    sign, natal house, lord), the **boundaries** (each carrying whether the lord actually changes), and
    the **reachable set** (seven signs, seven houses, plus the five signs that are forever unreachable).
  - **`itineraryOf`** → §1.1's template: the sASC's ordered walk, anchor → 2nd, 3rd, 4th → flip → 11th,
    12th → home. Measured on the fixture: `1→2→3→4→10→11→12→1`, steps `1,1,1,6,1,1,1` — §13.2's closure
    computed rather than asserted, one full revolution against the natal frame per day in seven steps.
  - **`buildPair(A, B)`** → the same-body families, and this was a **design error caught by the tests**:
    the first build enumerated intra-chart pairs, but the sky term cancels only body-against-ITSELF.
    Measured: a same-body pair holds its family to **0.000000000°** across 14 bodies × 400 days, while
    an intra-chart Sun/Moon "family" drifts **50.49°**. Families are a PAIR fact; `build` has none, and
    that absence is correct.
  - **Refusals held:** no refraction table (the arithmetic stays arithmetic), no cross-body table, no
    event times anywhere, and no lot arcs — asserted by the suite, not just claimed.
  - **A real fact the tests exposed:** when a natal Ascendant sits near a cusp (the fixture's is 0.029°
    from it) two of the seven stretches degenerate to **slivers the sASC crosses in ~14 seconds**. The
    sky check is split into soundness and completeness so a sliver reads as structure, not a gap.
  - Wired as `_prism()` / `_prismTables()` (memoized on `prismKey`, fused). No UI yet — P3's job.
  *Full suite after the pass: **884 checks, 0 failures**.*
- **P2 (original plan text) · the tables.** `prism.js` as a Connectome member: arc, reachable set, itinerary, families,
  built at engrave, stored under the Connectome's own key discipline so a doctrine change misses and
  rebuilds. *Proves:* engrave timing does not move, measured; and the itinerary is the 10th to the 4th
  for every fixture natal.
- **P3 (original plan text) · the template.** The seven segments with real durations, the anchor and the flip, the daily
  offset, the annual return of the offset. *Proves:* segment boundaries agree with a live horizon
  root-find to the second, and the anchor's regression matches sidereal arithmetic over a year.
- **P3 · the template. DONE, 2026-08-07.** The day's other half: the itinerary is uniform in DEGREES
  and the day is not uniform in TIME. In `prism.js` (CODEC 2, so a filed table misses and rebuilds),
  plus its hand-mirror and 19 new checks in `tests/prism.test.html`.
  - **ONE IDENTITY CARRIES THE SECTION, and it has no flip case.** With σ the sASC's walk from the
    anchor (0 to 180), the horizon is at `nASC + 2σ` for the WHOLE day: leg one puts the sASC at
    `c + σ`, leg two at `c + σ − 180`, whose horizon is the same degree. **So the sASC's 180° walk IS
    the horizon's single revolution and the flip is simply σ = 90.** No branch, no parity bit, no
    second case — the same shape of result as 7b's phase gate being unnecessary rather than replaced.
  - **`risingRamc(lon, lat, eps)` is the EXACT INVERSE of ephem's own `angles()`**, algebraically
    derived from that one function rather than from a textbook oblique-ascension variant, so the
    instrument and the template cannot disagree about what rises when. *Measured:* max deviation
    **1.1e-13°** against `angles` at 3600 samples. `null` is a real answer, not a failure (below).
  - **`ramcJdNear` is the only place the template touches time**, and it is not a scan: gmst is a
    polynomial, so a linear guess plus three Newton steps closes it. §1.3's "one refinement iteration
    per row", with no ephemeris in it at all.
  - **A DURATION HAS NO EPOCH, which is why storing one is not storing an event time.** "The sASC in
    the 11th lasts 2h26m" is a permanent signature of a latitude and a rising sign; "it entered at
    09:14" is an event and is still refused. The template stores durations and rotation angles (RAMC),
    never a jd — asserted by the suite, not just claimed.
  - **LATITUDE ONLY, deliberately.** A duration is a function of latitude; only the EPOCH wants a
    longitude, which is why the anchor is stored as a RAMC and turned into a jd by the reader. That is
    §8's locality result seen from the other side.
  - *Measured, fixture natal at 43.07°N:* the stops tile **360.000000000°** of RAMC, so the real
    durations sum to exactly one sidereal day (23h56m04s). Stretch boundaries agree with a bisection
    root-find on the live `angles()` to **0.040 ms** when the template is cut at the reading's
    obliquity, and to **1.547 s** when read 41 years off its engrave epoch — that residual IS the
    obliquity drift, and it is §1.1's "constant to within seconds" measured rather than waved at
    (**3.201 s** worst stretch change over 80 years, so the template never needs recutting). At every
    stretch's own computed epoch the real refracted sASC is where the template puts it, to **1.6e-7°**.
  - *The inequality, measured:* 0.14m against 5.16h in one day, **2226×**, because this fixture's
    Ascendant is 0.029° from a cusp. §1.1's "the disagreement between the dial and the ledger is the
    reading, not a rendering defect", and P2's slivers arriving as times.
  - **§1.2 CONFIRMED AGAINST LIVE ANCHORS, and the miss is predicted rather than tolerated.** 800 real
    anchors from `findAscAnchor`: consecutive intervals are one sidereal day to **0.0001 s**, the
    regression is **3.9318 min/day**, and the anchor's civil time wraps the 24h clock exactly once in
    **366 anchors**. The return is NOT exact at an integer anchor — predicted 366.2422 anchors /
    365.2422 days — so it lands 0.9521 min short, and that residual matches the offset arithmetic's
    prediction to **0.9522 min**. The quarter it misses by is the same quarter that makes a leap year.
  - **ABOVE THE POLAR CIRCLE THE TEMPLATE REFUSES.** At |φ| ≥ 90 − ε some ecliptic degrees never rise,
    so parts of the synchronic day have no arrival time at all; `templateOf` returns
    `{circumpolar: true, reason}` and no stops rather than inventing one. Below it the map is a
    bijection (checked at 1440 degrees at 66°N) because the quadratic's constant term is negative
    there, so exactly one positive root exists. **And a chart with no place gets no template** — a pp
    mint is given no invented horizon, so `template: null` with the reason recorded, unconditionally.
  - *No UI.* P4 owns the dial, and §14.1 already made it free (the wheel in the `natalAsc` frame).
  - **Wiring, and the defect it caught twice.** `_prismTables` now hands `build` an explicit latitude
    from `_natalSource()`. The suite was green while the app got `template: null`, for two reasons in
    a row: `_natal()` returns the plate's decoded shape (`{pos, asc}`), not framing's full
    `computeNatal` record, so there was no place on it at all; and the engraved place is stored as
    TYPED TEXT from the city typeahead, so `Number.isFinite("43.07")` is false and the coercion has to
    be explicit. Both times the engine was right and the caller was starving it, and both times the
    refusal it filed ("no latitude, no invented horizon") was indistinguishable from the correct
    answer for a pp mint. *Verified live in the instrument:* 8 stops, 360.00000000° of RAMC,
    23.934470h, unevenness 5.5× at Madison.
  *Full suite after the pass: **915 checks, 0 failures** (prism's own page 62 checks; everything else
  unmoved).*
- **P4 · the dial. DONE, v0.894.** Prompt of record: `specs/Prompt - Phase 6 P4 - the dial.md`.
  - **THE DAY IS A RETURN, and the flip is not its subject.** The user's correction, and the phase.
    The sASC leaves the natal Ascendant and comes home to it, because the horizon makes one revolution
    and `sASC = midpoint(nASC, horizon)` contains no time. So the dial's quantity is the WALK: with
    P3's identity `horizon = nASC + 2σ` and no branch, `σ = norm360(horizon − nASC)/2` is continuous,
    monotone, 0 to 180 across the day, and read from ONE sample. **The flip is σ = 90**, the far point
    of the excursion, and the walk does not jump there. Only the DRAWING jumps, because a 180° walk is
    painted onto a 360° wheel. A flip is therefore a boundary crossing of the same class as the other
    six, changing which degrees the Ring measures against and nothing about the motion.
  - *New:* `prism.walkOf` (pure, one wrap and one halving, the degree through `framing.refract`),
    `stopAtWalk`, `dialOf` (which reports `drift`, the signed disagreement between degrees walked and
    time elapsed). **CODEC 2 → 3:** every stop now carries `sigma`/`sigmaEnd`, computed inside
    `templateOf` since P3 and thrown away — the `frameOffset` lesson for the third time.
  - **The defect deleted:** `_updateComposite`'s `Math.abs(wrap180(lon − prev)) > 150`, a leap detector
    that cannot survive a cursor that leaps. **At six-hour steps it reports 0 flips across a day that
    contains 1**, and that number now stands in the suite permanently. Replaced by the pole bit
    (`framing.phaseOf`, one sample, no state) plus `compReturn`, because two pole changes a cycle and
    only one is a flip: **the flip is at an arc END, the return at its CENTRE**, measured 89.9998° and
    0.0212°. Direction cannot tell them apart under bidirectional scrubbing; the walk can.
  - *No new drawing.* §14.1 stands: the dial is the wheel in the `natalAsc` frame, already built.
  - *Measured:* one flip and one return per sidereal day forward AND backward at four step sizes across
    a 1350× range; 500 random-order samples identical to the monotone walk; the walk continuous
    (0.06126° per frame) and monotone; the arc law at **89.982269°** of a permitted 90°; the walk up to
    **9.21% of the day** ahead of the clock on a template of **2225.7×** unevenness, which is §1.1's
    disagreement as a number at last.

  *Full suite after the pass: **938 checks, 0 failures** (prism's own page 85, up from 62; everything
  else unmoved).*
- **P5 · the ledger.** Segment rows with their marks inside, day and week, the Moon through luna.
  *Proves:* row times match the scanner's roots at max delta 0.00 minutes, which is the 7b bar.
- **P6 · the query.** Electional over the sASC, in ♏.
- **P7 · synastry.** Two arcs, and the locality result stated to the reader rather than discovered by
  them.

---

## 11 · Open rulings, wanted before P1

1. ~~**The prism's scope.**~~ **RESOLVED 2026-08-06 by §2.1**, from the instrument itself: neither a
   whole-app state nor a look-through lens. The prism is a chart that can be seated on a wheel, and the
   two-slot wheel is the comparison engine. "Both" was the correct answer and this is its form.
2. ~~**The tabula.**~~ **RULED: ♓ Composite, a fourth item socket, `Clock`.** §7.
3. ~~**The sASC in the frame vector.**~~ **RULED: in, and it carries more than a memo key.** See §13,
   which is the ruling's real content: the synchronic chart has its own houses, and the lots are stored
   rather than live.
4. ~~**The two lords of the hour.**~~ **RULED.** The sky's keeps `rising lord`. The synchronic one is
   **the Synchronic Ascendant Ruler** (the Synchronic Ascendant Lord), because that is what it is.
   *Owed:* a short form for an 8 character socket or a chip, since the full term will not fit.
5. ~~**The daily flip's name.**~~ **RULED: the sASC has no flip kind.** See §13.3. Its transitions are
   all one kind, a change of Synchronic Ascendant Ruler, and the flip is one of them with a larger step.
6. ~~**§12.7's four**, on seating.~~ **DEFERRED by ruling: function before appearance.** §12.3 (materials)
   and §12.6 (the legend) are held; §12.2 (the seating law), §12.4 (frame ownership) and §12.5 (geometry
   over line style) are functional and stay in P0b.

---

## 13 · The two frames, and what a transition is (ruled 2026-08-06)

### 13.1 THE SYNCHRONIC CHART HAS ITS OWN HOUSES, AND THIS IS NOT A NEW EXCEPTION

The requirement, stated outside any one chart: the sASC's bounds are the natal 10th through the natal
4th, **and when the sASC stands in the natal 10th, Orbo must also recognise that as the synchronic
1st.** The synchronic 1st changes six times a day, at every boundary. Predictable, tableable, and then
wanting interpretation.

This is a CONSEQUENCE of §2.1 rather than a carve-out from the housing law. §2.1 ruled that a derived
chart is a chart, with its own aspect web, its own sect and its own dispositor chains. **A chart with a
horizon has houses.** Doctrine already grants a composite its own ASC sign on exactly this ground, and
a synchronic composite is a composite.

**TWO HOUSE READINGS, NEVER IN COMPETITION:**

| reading | frame | answers | changes |
|---|---|---|---|
| **natal house** | the native's, fixed | where in MY LIFE this is happening | never |
| **synchronic house** | the sASC's sign | where in THE MOMENT'S OWN CHART it sits | 7× a day |

What the housing law forbids is a **bare** house number derived from a moving Ascendant, silently
replacing the natal one. Two named readings are not that. **So the discipline is: a placement's house is
always qualified, never unqualified, anywhere in the app.**

### 13.2 THE OFFSET TAKES EXACTLY SEVEN VALUES, AND THE DAY CLOSES

`synchronic house = natal house − (natal house of the sASC) + 1`, mod 12. The sASC's own natal house
cycles through exactly seven values forever, so the offset does too:

| sASC in natal house | 1 | 2 | 3 | 4 | *flip* | 10 | 11 | 12 | 1 |
|---|---|---|---|---|---|---|---|---|---|
| offset | 0 | −1 | −2 | −3 | | −9 | −10 | −11 | 0 |

Six ingresses of step 1 plus one flip of step 6 is 12. **The synchronic frame makes exactly one full
revolution against the natal frame per day, in seven steps.** Seven rows, fixed at engrave, and every
placement's synchronic house is its natal house shifted by one of seven known amounts. There is no
second housing computation anywhere.

Two things fall out and both are confirmations rather than new claims:

- **At the anchor the two frames COINCIDE** (offset 0). Which is a fresh justification for the anchor
  protocol from a direction it was not designed from: composite chronology samples at the one instant
  per day when the moment's own frame IS the native's frame, so its derived chart needs no
  reconciliation at all.
- **The flip's step is 6**, which is the Tympan's own recorded fact that a flip moves a placement
  exactly six houses, always.

### 13.3 A TRANSITION IS A CHANGE OF SYNCHRONIC ASCENDANT RULER, AND THE STEP IS A FIELD

Ruled: the sASC's daily inversion is not its own kind. Crossing to the opposite pole changes the sign,
the frame offset and the ruler, which is exactly what a boundary crossing changes. **One kind, seven a
day, six of step 1 and one of step 6. The step is data, not a kind.**

Two notes so this is not misread later:

- **Scoped to the sASC, deliberately.** Pluto's flip keeps its kind, its window and its weight. The
  reason they differ is SPEED, which is to say rarity against a life: the same mechanism at daily
  cadence is a different register, and nothing here touches `framing.flipEvents`, the weave's flip kind,
  the ♐ Field chip or the flip's window export.
- **The window collapses anyway, so instantaneity is not a loss.** A 2° flip orb on a point moving
  180°/day is about sixteen minutes. Treating the sASC's inversion as an instant is what its geometry
  already says.

### 13.4 THE LOTS ARE OCCUPANTS LIKE ANY OTHER, AND A THEOREM SAYS SO

Ruled: the lots are bound by the arc law and their structure is stored rather than live-computed, for
the natal chart and favorited charts.

**The theorem that makes this free: a lot is an affine combination whose coefficients sum to 1**
(`asc + moon − sun`, and 1 + 1 − 1 = 1), **so refraction COMMUTES with lot formation.** Refracting
Fortune and computing Fortune from the refracted Ascendant, Moon and Sun give the same degree. So there
is no second definition to choose between and no special rule: a lot is an occupant, its arc is natal
lot ± 90, and its seven reachable signs are settled at engrave like everything else's.

**Two caveats, and the second one is a real open question.** The wrap branch must agree at both ends.
And the SECT: the day and night formulae differ (Fortune day is `A + M − S`, night is `A + S − M`), and
§3.13 grants the synchronic chart its own sect, so a diurnal native with a nocturnal synchronic chart
has the two ends of the lot's arc computed by DIFFERENT FORMULAE, with Fortune and Spirit exchanging.
**The commutation breaks exactly there, and with it the single stable arc there would be to store.**
Carried to §14 as the one question that blocks storing lot structure.

**What is stored is STRUCTURE and never a position.** §3's refusal of a refraction table stands: the
arc, the reachable set, the seven offsets. And the Connectome's exclusion of lots from the FRAME VECTOR
is about a memo key, which is a different object, so both rulings hold without contradiction.

---

## 14 · Open, after the 2026-08-06 rulings

1. ~~**THE WHEEL'S HOUSE GRID.**~~ **RULED, and the answer is smaller than the question.** Default is
   real time (live). Double-tapping the sASC puts the natal sASC on the horizon, which is the composite
   frame with the points still moving.
   **And that frame already exists.** The natal sASC IS the natal ASC (at birth the horizon equals nASC,
   so the midpoint is nASC), and `_reading()`'s existing `frame: 'natalAsc'` already rotates `nat.asc` to
   the horizon. So **no fourth stop is needed**: the sASC's double-tap is a new ENTRY POINT to a frame
   the instrument already draws. The proposal to extend the ASC's cycle is withdrawn.
   **Which also settles the pause about the two-cycle: nothing needs reverting.** The pattern already
   arrived at is the right one, and it is not "fewer frames" but **a frame is reached by touching the
   thing that defines it.** The ASC's own double-tap keeps zodiacal, because zodiacal is not a frame OF
   anything: it is the null frame, the bare Ring, and the ASC is exactly the thing it suppresses.
   **Zodiacal earns its place on the synchronic chart too**, for a reason worth keeping: the arc's bounds
   are ZODIACAL facts (nASC ±90 is a pair of degrees), so the zodiacal frame is where the arc is read
   against the SIGNS and the composite frame is where it is read against the HOUSES.
   **THE CONSEQUENCE, AND IT IS THE PASS'S BIGGEST SIMPLIFICATION: the dial is free.** In the composite
   frame the wheel is rotated to the centre of the sASC's arc, so the sASC swings ±90° about the horizon
   point and is confined to ONE HALF of the wheel forever, the half spanning the 10th through the 4th.
   It descends from the horizon to the nadir, jumps the meridian to the zenith, and descends home. **So
   §7's dial is not a new pane widget, it is the wheel in a frame that already exists**, and the arc law
   becomes watchable with no new drawing at all.
2. ~~**WHICH SECT GOVERNS A SYNCHRONIC LOT.**~~ **ANSWERED provisionally: the CURRENT sect** (if it is
   day it is day), with the user's own note that it may only be answerable later. Recorded with two
   consequences the answer carries, because they decide what can be stored:
   - **This is a THIRD option**, not one of the two offered: the moment's own sect (sky Sun against sky
     ASC) rather than the native's or the synchronic chart's (§3.13's grant). It is place-and-time only,
     so it is a FLOOR fact, native-independent, and it turns at sunrise and sunset, which is why it is
     the intuitive answer.
   - **It breaks §13.4's theorem, and therefore blocks the storage §13.4 wanted.** The commutation holds
     only under ONE sect: if the natal lot is built diurnally and the moment's lot nocturnally, the two
     ends of the arc come from different formulae, so refracting a lot and computing it from refracted
     ingredients stop agreeing, and there is no single stable arc to table.
   - **It also risks two sects in one reading**, which is incoherent: sect governs Fortune's formula AND
     the sect light AND the light chain, so the lots and the chain must not disagree. Under this answer,
     the moment's sect would have to govern the whole synchronic reading, which overturns §3.13.
   - **So, deferred cleanly and at no cost:** in P1 the lots REFRACT LIVE, which is one line and exact
     under any single-sect reading, and the lot arc table waits. Nothing else in the plan depends on it,
     and a stored arc under the wrong sect rule would invalidate at doctrine-key level.
3. ~~**Does the synchronic frame house every placement?**~~ **CONFIRMED: every placement.** §13.2's
   offset makes it free.
4. ~~**The socket's word.**~~ **RULED: `Clock`, with prism in the definition.** §7.

---

## 12 · Seating: how two charts sit on one instrument

From the two-natal screenshots of 2026-08-06, and part of THIS pass because §2.1 makes the prism a
chart that gets seated. Whatever law governs how two seated charts are drawn is the law the prism
inherits on the day it exists. Get it right once and it covers every variety; get it wrong once and it
is fixed twice.

### 12.1 The defect, and its single cause

With two birth charts seated, the instrument abandons its own visual vocabulary. Both charts become
small undifferentiated white glyphs on two crowded inner tracks, the angles collide (`As As`, an `MC`
and a `Ds` belonging to nobody), the web is dotted grey over red and blue, **and the outer track sits
empty while a third ring is invented to hold the overflow.**

One cause explains all of it: **the outer track is reserved for THE SKY specifically rather than for
whatever is seated on the rete.** With the sky absent, the rete's own ring has no occupant, both charts
are pushed inward, and a third ring appears to hold what no longer fits.

The user's words for the loss are the right ones: the glyph beauty is apparently reserved for the
current sky transits, and a birth chart is demoted to plain text while the sky gets material.

### 12.2 THE SEATING LAW

**Whatever is seated on a wheel rides that wheel's track. No third ring, ever.**

Two wheels, two tracks, one occupant each, for any variety: the sky, a person, an event, a horary, a
composite, a prism. The cards already say `THE PLATE` and `THE RETE`; the layout should say it too.
This DELETES a ring rather than adding one, and it halves per-track occupancy, which is most of the
collision problem before any de-collision work is done.

The solo case is unchanged and already correct: one occupant, one track, #2b spreads the web.

### 12.3 ~~THREE MATERIALS~~ · STRUCK 2026-08-06, replaced by the material law (built v0.891)

**This section was wrong, and it was wrong in the way that costs the most: it made the distinction
between the two charts a distinction in QUALITY.** "The live sky is LIGHT, a seated chart is STONE"
reads as a hierarchy however carefully the stone is drawn, and P0b implemented it faithfully: a seated
chart came out as flat one-ink 11px glyphs with no glow, no period sizing, no de-collision and no moon
face, so it looked like a debug overlay beside the instrument. The code had the same idea in a comment
predating this spec (*"depth-1 PAPER: matte stone, never light, never moving"*), which is why it went
unargued.

**THE MATERIAL LAW, replacing it: MATERIAL FOLLOWS THE WHEEL, NOT THE OCCUPANT.**

- **The plate is ENGRAVED.** Incised, matte, beneath. Whatever sits there.
- **The rete is LIT.** Element-coloured, glowing, riding above. Whatever sits there: the sky, a person,
  an event, a composite, a prism.

A distinction in KIND. Both charts get the instrument's full treatment; neither is a demotion. It is also
physically true to the object (the rete is the pierced disc that rides on top; the plate is the engraved
body it sits in), and it can never produce two lit tracks, because the rete holds exactly one occupant.

Kept from the struck text, because it survives the change: **RELIEF carries the wheel** (the plate's
chart incised, the rete's proud above it) is exactly what "engraved versus lit" now means. **METAL for
chart identity is retired** as unnecessary: the two tracks are already distinguished by material and by
radius, and ♌ Appearance's rim metal stays what it is.

**Built v0.891.** One `_drawLitTrack(ctx, occ)` takes an occupant (`pos`, `asc`, `names`, radius,
`frozen`) and draws the rete's track for any chart; the hand-rolled flat routine and its violet recessed
band are deleted; `skyOn` no longer selects a treatment anywhere. Code lines fell by 27.

### 12.4 THE FRAME BELONGS TO THE PLATE, WHICH RESOLVES THE DOUBLE ANGLES

Two charts bring two sets of angles, and the screenshots show what that costs.

**The plate is the frame.** The houses are drawn from it, so its angles are STRUCTURAL: the horizon
line, the meridian, the `As` in its own disc. The rete's angles are four more occupants on the rete's
track, beads like any other. One `As` is the horizon, the other is a bead, and they stop looking alike.

Same ruling as the housing law, one layer down into the drawing: housing comes from one frame, always,
and the wheel should show which one.

### 12.5 LET GEOMETRY DISTINGUISH THE WEBS, NOT LINE STYLE

Two facts (self versus cross) are carried today by four visual variables (dotted, solid, red, blue),
which is why the middle of the wheel reads as lint.

With one chart per track the geometry does it free: **a line that stays inside one track is a
self-aspect; a line that spans the two tracks is a cross-aspect.** Chordal against radial,
unmistakable at any zoom. The dotted treatment retires, and colour goes back to meaning what it means
everywhere else in the instrument (the harmony family) instead of being spent on chart membership.

### 12.6 The card is the legend

Nobody should consult anything to know which bead is whose. Tint each wheel card's name to its own
metal and the wheel needs no key, no per-bead labels and no added furniture. The cards are already
there and already name the occupants.

### 12.7 Open rulings for §12

1. ~~**The two metals.**~~ **RETIRED by §12.3's replacement.** Two tracks distinguished by material and
   radius need no metal tagging; ♌ Appearance's rim metal stays what it is.
2. ~~**Element colour on a stone bead.**~~ **RESOLVED as a consequence of §12.3:** there is no stone bead
   on the rete. `_elemOf(lon)` rides the lit track for free, per body, for every occupant. And a SEATED
   chart is permanently `atRest` (it never moves), so it keeps its element colours through a scrub
   instead of washing pale the way the live sky does.
3. ~~**Whether the sky, seated on the plate, becomes stone.**~~ **RULED 2026-08-06: THE WHEEL.** I had
   leaned occupant; the two-natal screenshots settled it the other way. Material follows the wheel, so
   the sky seated on the plate would be engraved, and a person seated on the rete is lit. See §12.3.
4. **Stelliums inside one track.** Halving occupancy fixes most of the screenshots' collisions and not a
   natal stellium, which is pre-existing and probably wants the chip-ring law's derived radius plus a
   spread rather than anything new. **Note:** the lit track's own de-collision (9° clusters, alternating
   `lvl`) now applies to seated charts too, which it never did before v0.891, so this is narrower than it
   was.

### 12.8 Still open after v0.891 · the rete's occupant cannot be READ

The repair prompt asked for both charts to be "grabbable". Investigating it found that half of that
requirement is wrong by design and the other half is a genuine gap, and the two should not be conflated:

- **Scrubbing a seated chart is correctly REFUSED.** `_down` nulls its hit when `_reteFrozen()` (*"frozen
  reading — nothing scrubs"*), because a seat defines the moment: dragging a seated person's Mars to move
  time is meaningless. `_drawLitTrack` therefore writes no hit map for a frozen occupant, which also
  avoids a real hazard, since `this.held` resolves longitudes through `this.pos` (the cursor's sky) and a
  seated chart's are its own.
- **Tapping one to open its reading is a real gap.** The plate has `_openNatalSheet` via `_natalScreen`;
  the rete's occupant has no equivalent. That is a NEW view (`_openReteSheet`, reading `_reteChart`'s rows
  through the existing `_specRows`), not part of a simplification pass. Its machinery already exists:
  `_reteSpec` computes those rows for the pull-up today.
