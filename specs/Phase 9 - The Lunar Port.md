# Phase 9 · The Lunar Port — the kitchen remodel

Plan of record, agreed 2026-08-13 in conversation. Supersedes nothing in
`specs/Phase 8 - The Lunar Pane Templates.md`: Phase 8 named the five templates and they stand. What
Phase 8 lacked was a door, so every one of its steps was approximated one surface at a time. **This
phase builds the door and moves the surfaces onto it.**

**Why a remodel and not more steps.** The Phase A audit (2026-08-13, recorded below) found that
Steps 1, 2, 3, 6, 8 and 9 each read correct line by line and removed **not one duplication**. The
failure mode was uniform and it was not laziness: each step wrote *documentation of the standard* and
then hand-built the surface anyway, and nothing in the code objected. **Documentation enforces
nothing. A refusal does.** Every acceptance test below is therefore a number or a refusal, never a
report that the work is done.

---

## The restaurant

Agreed in conversation, and the geography decides where code goes.

**This is an OPEN FRENCH KITCHEN.** Not a hibachi grill. You can see the kitchen from the table and
you can see the chefs working in it. **The table is not close to the kitchen, and you do not order
from the chef.**

Three consequences, all of them already law here under other names:

- **Stations, not improvisation.** Escoffier's brigade is one transformation per station and no
  station reaching into another's mise. That IS the TimeSpine law ("raw `eph.positions()` may be
  called ONLY inside `_makeSpine`") and it IS the refraction law (`framing.refract` is the one place
  in Orbo that refracts, "meant to be GREPPABLE"). The brigade has been running for months unnamed.
- **VISIBLE IS NOT REACHABLE.** The astrolabe is the kitchen's own fire — live, in view, and behind
  glass. This is the sun/moon law's real shape: the instrument is watched, never ordered from, which
  is why "new features do not land on the instrument" and why nothing in this phase touches it.
- **The order goes to the server.** The rail, the dock and the arc take the order and carry the
  plate. Their three verbs are already fixed (open · etch · fuse) and this phase adds none.

**The one flow rule.** Dependency runs one way down the line. A station may read from behind it and
hand forward. **Nothing reaches forward past the pass, and nothing reaches back around the walk-in.**
Every defect in the Phase A audit is a violation of that sentence: readers writing their own
captions and heights (reaching forward), `_paneNeeds` keying on content length (reaching sideways),
eleven cooks carrying their own plates past an empty pass.

### The line, in flow order

| # | Station | Owns | May not touch |
|---|---------|------|---------------|
| 1 | **The walk-in** — the spine | time, sky: positions, angles, horizon | anything downstream |
| 2 | **Measuring** — the Ring, framing, prism | separations, arcs, midpoints, refraction | doctrine, words |
| 2b | **Prep, and the cooler** — the Connectome | sign-level structure, compiled once and held: chains, tables, receptions, indexes | degrees, aspects, time, words |
| 3 | **The line** — the eleven readers | cooking: doctrine applied, addresses + rows produced | words, captions, layout, height, rails |
| 4 | **The pass** — THE PORT (new) | checking, naming, saucing, plating, height | computing anything |
| 5 | **The server** — rail · dock · arc | taking the order, carrying the plate | the contents of the plate |
| 6 | **The table** — the pane's bands | being read | everything |

### The three credits

Sorted in conversation, and the app had already discovered the distinction without naming it:

- **Ingredients** — positions, angles, the horizon at a moment. From the walk-in.
- **Recipes** — the DOCTRINE. Whole-sign houses, sect, Egyptian bounds, Lilly's void-of-course,
  Valens' periods, ZR's peak definition (natal angles vs the Lot's own angles, Brennan). **A recipe
  change moves the ADDRESSES**: switch ZR's peak definition and different periods become peaks.
  Credited in the **provenance band**.
- **Sauces** — the interpretation packs. Dark Pixie Astrology (first installed) and Alan Leo, both
  SOURCED, so both are credited identically. **A sauce change moves NO address**: Moon in Capricorn
  in the 7th is byte-identical under either voice; only the words change. Credited in the **byline**.
  Not a pantry ingredient — an ingredient has no author and these have voice; Leo is a chef whose
  sauce was made in 1912 and is held in the walk-in.
- **The plate** is neither. It is the reading: this moment, these measurements, that doctrine, this
  voice. It exists only at the pass and only while you are looking at it.

**TWO CREDIT LINES ALREADY EXIST IN THE APP AND THEY WERE NEVER THE SAME KIND OF THING.** The
honesty/doctrine line credits the recipe; the attribution byline credits the sauce. The port formalizes
what those two lines already knew.

**SAUCE GOES ON AT THE PASS, NEVER AT THE STATION.** If each reader fetches its own pack text, there
are eleven cooks saucing at eleven stations and no one tastes the plate before it leaves — the caption
defect again, in words instead of markup. One saucier, at the pass.

---

## The menu — six plates, and one of them was never ordered

Ruled in conversation 2026-08-13: **the templates are actual plates, and you need one per kind of dish
you serve.** Poulet rôti on a tapas plate will fail however good the chicken is. So the menu is written
BEFORE the plates are ordered, and Phase 8's five were ordered without one.

**A PLATE IS A STRUCTURAL AXIS, NOT A TOPIC.** Two dishes sharing an axis share a plate; two dishes on
different axes never can. **The test for ordering a new plate: name the axis it differs on. If you
cannot, it is not a plate — it is a FIELD on an existing one.**

| Dish | Axis | Plate | Served at |
|---|---|---|---|
| a standing fact about one subject | no time | **FACT** | the natal sheet · plate/rete/sky fact rows · the lunar facts |
| a contact between **two** subjects | no time (a flip/until date at most) | **RELATION** | the synastry grid · the composite dyads |
| a dated event | time as a **point** | **LEDGER** | the almanac · transits upcoming · crossings / approaching · election windows |
| a duration, nestable | time as an **interval** | **SPAN** | ZR · rising-lord stretches · retrograde periods · the clock's stretches (deferred) |
| a quantity against its range | magnitude | **TRACK** | the sASC spread · drift · scores riding inside LEDGER rows |
| a voice on an address | prose | **PROSE** | the eclipse tier · Dark Pixie Astrology · Alan Leo |

**`ROSTER` IS NOT ON THE MOON'S MENU.** Its contract (`glyph · subject · state · qualifier`) describes a
LIST OF THINGS YOU CHOOSE FROM — which is the ♎ Ledger tabula, on the BACK. The back is the maker's
side: configuration, not interpretation (sun/moon law). Phase 8 Step 7 said so itself without hearing
it — "**ROSTER — the one template with no exemplar**". It had no exemplar on the pane because **the pane
does not serve that dish.** The plate is well designed and it belongs in the other room.

**What synastry and the dyads actually need is RELATION**: two NAMED subjects, one contact, an optional
until/flip date. That is the real shape of the July "Locked dyad spectrum" table Step 7 was designing
from, and trying to serve it on ROSTER is what produced the trap at line ~4142 — contract fields added
beside pre-contract fields, so `_checkRow` would refuse every row for "unlisted fields." **The trap was
never a migration hazard. It was the wrong plate.**

**THE DISCRIMINATOR BETWEEN RELATION AND LEDGER, and it is not a judgement call: a contact that
PERFECTS at a moment is a LEDGER row; a contact that is FIXED is a RELATION row.** Transits perfect, so
they are dated events. Same-body synchronic dyads never perfect — the sky term cancels and the
separation is fixed forever — so they are relations with a flip date at most. **The plate boundary lands
exactly on the doctrine boundary the Crossing pane already draws** between families and crossings. That
is validation of the menu, not a coincidence: if the plates had cut across that line, the plates would
have been wrong.

**PROSE was never ordered, and it is the plate the sauce goes on.** It exists today hand-built as the
eclipse tier — serif face, page turns, dots, attribution — which is why the interpretation layer has no
template discipline at all. Phase 2 cannot land without it.

**PROSE IS SERVED ONLY AS AN EXPANSION, NEVER AS A DISH OF ITS OWN** (ruled in conversation
2026-08-13: "the prose of the natal chart is in the expansion … part of the serving"). It has no subject
of its own — **it inherits the address of the row it expands**, which is exactly what the eclipse tier
already does under Model B: the significations stay pinned above and the voice opens beneath them in the
room the rise makes. Consequences: a PROSE band with no parent row is refused; the voice can never
contradict the plate above it, because it is not given its own address to disagree from; and the second
course arrives at the same table as the first, which is why one surface cooks twice.

**A ranking is not a plate.** Election windows and the query rank their rows, but a score is a quantity
against a range — TRACK riding inside a LEDGER row. Phase 8 spotted the seed and mistook it for a
curiosity: the election row's `barW` is "the only place a quantity is drawn against its known maximum."

**A SURFACE IS NOT A DISH.** One pane may serve two courses — the natal sheet serves FACT and then
PROSE. This is why the omelet cooks the same surface twice (Phases 1 and 2) rather than once.

---

## The cooler and the sous-chef — the Connectome's place on the line

Raised in conversation 2026-08-13: the Connectome had not been placed, and it holds much of what the
recipes draw on. **Both guesses were right, about two different things, and the code already names them
apart:**

- **`express()` is the SOUS-CHEF** — a compiler pass. It takes occupants (a sign map), a Tympan
  selector (the ASC sign) and sect, and produces structure: chains, tables, receptions, indexes. It
  transforms, so it is a station.
- **The Expression is the COOLER** — the prep, held. Memoized on the **frame vector** (sign ordinals +
  the sect bit), and for favorited charts filed in IndexedDB keyed on **frame × doctrine × codec**, so a
  doctrine change or a re-engrave misses and rebuilds instead of serving stale wiring.

**THE ONE SENTENCE THAT PLACES IT: the cooler holds what is true for a WHOLE SIGN-STAY; the walk-in
holds what changes every sample; A READING IS THE JOIN.** That is why the Expression refuses degree,
retrograde, speed and aspects — not modesty, but the other side of the join. A node any finer would
destroy the memo, because the record would change every sample instead of every sign change (§3.3).

It sits **beside** the measuring station, not after it: the Ring measures degrees, the Connectome
compiles sign-level structure, and both are prep that readers draw from. Neither is a reader.

### What each plate draws from the cooler

| Plate | From the cooler | Joined live |
|---|---|---|
| **FACT** | sign · house · bearer · chain path · keeper · terminalKind · receptions · rulesHouses — the richest consumer, and what the Connectome was built for | exact degree, retrograde, speed |
| **RELATION** | **two** Expressions, each housed in **its own frame** — the housing law holds by construction, because `ascSignIdx` is a PARAMETER and is never derived from `occupants.Ascendant` | the contact, its orb, its flip date |
| **LEDGER** | the natal point's chain and rulership (the "so what" behind a dated hit); the house the transiting body falls in | the exact moment, orb, rate |
| **SPAN** | the period lord's chain — who keeps the lord of this stretch | the stretch's own start/end |
| **TRACK** | almost nothing, correctly — a quantity has no wiring. But the **synchronic** house (which turns over 7× a day) is exactly what a parameterized frame is for | the quantity itself |
| **PROSE** | the ADDRESS the pack is keyed on | the words |

**The composite is already first-class in the cooler** (`_connResolve` → `_connFromMap(c.lons,
c.lons.cASC)`), which matters more than it looks: the composite pane work deferred to the end of this
phase does not need a new prep station. A composite's Expression exists today, housed in its own frame,
with no place and no invented horizon.

### Two prep benches, and a reader must not confuse them

**The Connectome refuses decans, terms, faces and triplicity — that is `rulers.js`'s layer.** So a row
wanting a bound-lord joins rulers.js, and a row wanting a dispositor joins the Connectome. The port
must keep those two joins distinct in the ticket's `doctrine` list, or the provenance band will credit
the wrong bench.

### One doctrine key, two jobs — unify it

`_doctrineKey()` already keys the cooler, deciding what invalidates held prep. **The port's provenance
band should be derived from that SAME key** rather than from hand-written strings. The argument is not
tidiness: if what-we-credit and what-invalidates-the-cache are two separate expressions of one fact,
they will disagree eventually, and the credit line is the one that will be lying. Same shape as every
other one-door ruling here.

### Flagged, not resolved — questions the menu asks of the cooler

1. **Cross-chart reception for RELATION.** `express` takes ONE occupant map, so "A's Venus in the sign
   B's Mars rules" cannot be produced by construction. Either a new join at the pass or a deliberate
   omission — **decided when RELATION is built (Phase 4), and never faked** in the meantime.
2. **PROSE's address granularity.** Dark Pixie Astrology and Alan Leo key their entries at some
   resolution (body-in-sign, body-in-house, or both). That key space must be DECLARED before the
   saucier's door is built, and **anything finer than a sign is rulers.js's bench, not the cooler's.**
3. **`topologyKey` has no consumer.** It is computed, published, and read by nothing — the
   `frameOffset` smell in mirror image (there the value was computed and *not* recorded; here it is
   recorded and not read). Not a defect and not on this menu; recorded so it is a known absence rather
   than a forgotten one.
4. **The cooler keeps only favorites** (cap 32). A non-favorited second native compiles on demand and
   memoizes in-session, which is correct, not a gap — recorded because RELATION will make it visible.

---

## The prep survey — the whole kitchen, read before cooking (Phase 0b, done 2026-08-13)

**Why this section exists, stated plainly:** the port was designed through several rounds without the
Connectome in it. **That is the same defect the port is meant to cure** — a design that is locally
correct and not holistic — and it was caught by the user, not by me. So the prep tier was read in full
before Phase 1, from the source files rather than from memory.

### FOUR RESOLUTIONS, and a reading is a JOIN ACROSS THEM

This is the finding. The prep tier is not two benches, it is four tiers, and every plate on the menu
draws from a different subset. Getting this wrong is how a value ends up on the wrong bench.

| Tier | Argument | Engines | Changes when |
|---|---|---|---|
| **INHERENT** | none — true before the app runs | `ring.js` (degree ↔ degree, 11 marks, no occupants, no orb, imports nothing) · `mater.js` (the signs' inherent meaning, `signIndexOf`) · `tympan.js` (12 whole-sign frames, 144 forward + 144 reverse + `RULES_HOUSES` + the separate modern index) | never |
| **POINTWISE** | one degree | `rulers.js` — degree → lord, and the five-rung ladder (domicile · exaltation · triplicity · bound · face) + debilities + peregrine | every degree |
| **SIGN-STAY** — *the cooler* | an occupant→sign map (+ frame, + sect) | `dispositor.js` (the walker: bearer · path · keeper · terminalKind · cycles · receptions) → `connectome.js` (the join → a frozen Expression) | a sign changes |
| **SAMPLE** — *the walk-in* | a moment | the spine · `framing`/`prism` · the scanners | every sample |

**THE TEST THAT PROVES THE LADDER IS REAL, not a tidy diagram: bound and face lords CANNOT go in the
cooler.** They are sub-sign, so they change *within* a sign-stay and would destroy the frame-vector
memo. That is why `rulers.js` keeps them and why the DC already says so at the join site ("the dignity
rungs do not need the Connectome — they are a degree read"). Any proposed addition to the cooler meets
the same test or it belongs on another bench.

### THE ALLERGIES — already declared, and the reason the pantry is small

Ruled in conversation: *if the user has an allergy, the ingredient does not need to be in the kitchen.*
Orbo's allergies are already declared across the engines' own refusals, and they are why this kitchen
is stocked as thinly as it is. Recorded here so no future pass "adds" one back:

- **Quadrant houses.** Whole-sign only — so no cusp interpolation, no house sizes, no intercepted
  signs, and the Tympan takes an ASC SIGN and never a lat/lon.
- **A dignity score.** No almuten, no points, no ranking — grepped in `rulers.js`'s test. Five rungs
  are five facts; which outweighs which is judgment, and judgment is the packs'.
- **Ptolemaic bounds.** Named as the alternate and deliberately not built: a second table is a doctrine
  switch, and a doctrine switch rebuilds every fertilized century.
- **Septiles.** Excluded from the Ring's marks by construction — 7 does not divide 360, so a septile
  would put marks between states and reintroduce quantization everywhere.
- **Moderns as dispositors.** Held in a separate index so the walker is *structurally incapable* of
  branching into one; the native sees both lords, the engines count one.
- **A Davison chart.** A composite has a frame, not a place — never synthesize a lat/lon for one.
- **Live eclipse classification outside the embryo's span.** No data beats faked data.

### What else the cooler should hold — three tests, then the candidates

**An addition to the cooler must (1) be sign-resolution, (2) memoize on the frame vector, and (3) be
ORDERED BY A DISH ON THE MENU.** Fail any one and it belongs to another bench, or nowhere.

**BUILD — cross-chart dispositorship, on the walker's own pattern.** This is the honest answer to the
RELATION flag above, and it is build-shaped rather than an open question, because `dispositor.js`
already proves the shape: take occupant→sign maps, refuse everything else, produce a graph. The
cross-chart version takes **two** maps and produces the relations *between* them — A's occupant sitting
in the sign B's planet rules, the mirror, and the mixed cases — exactly parallel to `receptions`, which
is already a sibling export rather than something bolted inside the Expression. Then the join takes a
pair. It passes all three tests: sign-resolution, memoizable on **both** frame vectors × doctrine ×
codec, and RELATION orders it. **Prerequisite for Phase 4, not for Phase 1** — so it does not block the
omelet, and it is not invented mid-migration either.

**HIGH-VALUE CANDIDATE — one Expression per synchronic STRETCH.** The sASC's frame turns over ~7× a day,
and the prism already holds the itinerary of exactly those stretches, fixed at engrave. So the
synchronic chart's housing could be a **table read** rather than a live compile: seven Expressions a
day, precomputable, memoized on frames the prism already enumerates. Passes all three tests (TRACK and
the composite pane both order it). Not scheduled here — recorded as the strongest downstream win
available, to be ruled on when the composite pane opens.

**FREE ALREADY, no work needed:** two natives housed in their own frames (`ascSignIdx` is a parameter);
a composite's own Expression (`_connResolve` → `_connFromMap(c.lons, c.lons.cASC)`); a composite's sect
(§3.13, answered).

**REFUSED, with reasons — do not add these:**

- **An aspect graph.** Ring + orb, not sign resolution: it would change every sample and destroy the
  memo. The Ring is the relation; the readers ask it live.
- **Lots.** Degree-level affine combinations, and the prism already defers lot arcs because sect breaks
  the commutation. Computed live, exactly as they are now.
- **Bound / face / triplicity lords per occupant.** Sub-sign — see the ladder test above.
- **Antiscia.** Ring-tier if ever wanted, and no dish on the menu orders it.
- **A `topologyKey` consumer.** Computed and read by nothing today; a "charts wired like mine" reading
  is not on this menu. Left an explicit absence rather than a forgotten one.

### Join sites the port must preserve

The natal plate **already joins the cooler** in three places — `_specRows` (≈7155), `_ladderRows`
(≈10226) and `_progConnAt` (≈4996). Phase 1 does not build a join; it **routes an existing one through
the pass.** And the ticket's `doctrine` list must credit **both benches separately** — the Connectome
for chains and receptions, `rulers.js` for the rungs — which the code today already gets right at the
join site and the provenance band today does not.

---

## What the pass is

**A reader stops handing the pane a finished plate and starts handing up a TICKET.**

### The ticket

Carries only what the reader knows:

```
template   'FACT' | 'RELATION' | 'LEDGER' | 'SPAN' | 'TRACK' | 'PROSE'
subject    what is being read: which chart(s), which frame, which moment/window
rows       matching the declared template's contract
doctrine   which recipes were used (keys into a registry, never prose)
chips      what the server should offer on the arc (optional)
empty      why there is nothing, when there is nothing (optional)
```
**A ticket MAY NOT carry markup, a caption string, a height, or rails.** Those four are precisely
what the eleven readers have been inventing, and inventing them is what "eleven surfaces have eleven
layouts" means.

### What the pass does with it

1. **Names the dish.** THE CAPTION IS DERIVED FROM `subject`, NEVER AUTHORED. A reader that declares
   two natal charts gets a caption that says two natal charts. It cannot get a caption that says
   composite, because it never gets to type one. This is the fix for the live defect found 2026-08-13:
   `sySub`'s else-branch announces the seated-pair NATAL synastry grid as "composite × composite ·
   same-body pairs first", because that branch fires whenever `sd.compsyn` is falsy and the plain
   `synastry` sheet is falsy too. **A caption that is a string in a shared ternary can be pasted onto
   the wrong data and nothing objects. A caption derived from the subject cannot be.**
2. **Sets the height.** Rest follows the declared TEMPLATE — Phase 8 Step 1's actual intent, keyed on
   the template instead of on `_eReadLen` (how much interpretation text happens to exist).
3. **Renders both credits.** Provenance from the `doctrine` keys via a registry; byline from the sauce
   applied. No hand-written provenance strings.
4. **Applies the sauce** (Phase 2 below): address in, words and byline out, one shelf.
5. **Lays the bands.** One scaffold, emitted ONCE: `header · side rail · chip rail · caption · body ·
   legend · provenance`. A band with nothing to show emits nothing.
6. **REFUSES.** A ticket with no template, rows that do not match the declared template, or a house
   number with no native named (the housing law: always qualified, never bare) is refused — loudly,
   in the console, the way `_checkRow` already does correctly for FACT. Never rendered as a plausible
   half-pane. **The pass is only worth building if it can say no.**

---

## The one dish, end to end

The journey the remodel exists to make possible, traced for the natal Moon reading. Each arrow is a
handoff and each handoff is checkable.

1. **Walk-in.** `spine.at(jd, lat, lon)` → the genome. Ingredients: the Moon's degree, the horizon.
   Nobody reaches past this.
2. **Measuring.** framing / the Ring → the sign, the whole-sign house off the natal Ascendant, the
   separations in orb.
3. **Station.** The natal reader applies doctrine and produces **addresses**: `Moon · 7°34′ Capricorn
   · earth · Hn · engraved`, as FACT rows (`{k, v}`). It writes no words and no markup.
4. **Ticket up.** `template: 'FACT'` · `subject: {chart: 'natal me', frame: 'natal', at: 'engrave'}`
   · rows · `doctrine: ['whole-sign']`.
5. **Pass.** Refuses a malformed row. Derives the caption from the subject. Resolves the rest from
   FACT. Renders provenance from the doctrine keys. (Phase 2: pulls Dark Pixie or Leo for the address
   and stamps the byline.) Lays the bands.
6. **Server.** The rail already carried your order in; it carries the plate out. No new verbs.
7. **Table.** The bands render. Nothing else drew anything.

---

## Standing rules for the whole phase

- **ONE PHASE PER PASS. Never two.** A wide mechanical change reads correctly line by line and still
  does not run (the bulk-edit lesson, `CLAUDE.md`).
- **MIGRATE BY PLATE, NOT BY SURFACE.** Phase 8 went surface by surface, which is exactly why the same
  plate was hand-built four times over. Serve every dish that shares a plate together: the plate is
  designed once and immediately reused three or four times, so the duplication cannot survive the pass
  that introduces it.
- **THE PLATING GETS MORE COMPLICATED, NEVER THE TRUST** (ruled 2026-08-13). Complexity ramps on the
  ONE surface already proven — bare plate, then its expansion, then its rails — and only then does a
  second plate arrive, **inheriting finished machinery it does not have to invent.** The opposite order
  is what put a hand-rolled pill rail on the Crossing pane while the arc sat switched on and empty: new
  machinery was being debugged on an untrusted surface, so neither could be judged.
- **Snapshot first**, every phase: `archive/Orbo Astrolabe YYYY-MM-DD[a-z].dc.html`.
- **No repair rides along with a refactor.** Including the `sySub` lie, which is fixed BY Phase 3 and
  not before — a repair smuggled into a migration leaves neither verified. This is how Phase 8 went
  sideways.
- **No new features, no new copy, no new surfaces until Phase 6 closes.**
- **Every phase ends with measured numbers**, before and after. Not a claim of completion. (On
  2026-08-13 a step was reported complete that had never been written; the counters exist so that
  cannot recur.)
- **The astrolabe is not touched in any phase.** It is behind glass.

### Phase A survey — the baseline (measured 2026-08-13)

| Counter | Baseline |
|---|---|
| Sheet blocks, each with its own hand-written wrapper | **13** |
| Hand-written caption strings | **11** (`sySub cxSub almSub zrSub clockSub querySub risingSub progSub txSub elSub zrProv`) |
| Row contracts declared | **5** |
| `_checkRow` call sites | **1** (`_atDepth`, FACT only) |
| Templates actually enforced | **1 of 5** |
| Named rests keyed by template | **0** (`_paneStops` = peek · facts · eclipse · gone; no CREST) |
| `_paneNeeds` key | **content length** (`_eReadLen > 0`) |
| Hand-rolled flat chip/tab rails | **8** |
| Lenses wired into the chip arc (`paneSubChips`) | **5** (`transits election query zr almanac`) |
| `viewArcOn` lenses with an EMPTY arc | includes **`cross`** — switched on, fed by nothing |
| ZR fidelity proof (Step 2's own requirement) | **never performed** |

---

## Phase 0 · Seat the menu — paper only, no code

The menu above is the ruling; this phase applies it exhaustively, because a plate list that is right in
principle and unassigned in practice is the `frameOffset` lesson again.

- **Assign each of the 13 sheet blocks to exactly one plate per course it serves.** A surface serving
  two courses is recorded as two dishes (the natal sheet: FACT, then PROSE).
- **Anything that will not assign is one of three things, and it must be labelled as such:** a FIELD on
  an existing plate (a score), a BACK surface (the roster), or a **missing plate** — in which case the
  menu is amended here, before the pass is built, and never mid-migration.
- Output is an assignment table appended to this file. No code, no snapshot needed.

**Acceptance:** every sheet block assigned; the plate enum **final** before the ticket is written; zero
surfaces left as "decide during migration." **The pass is built around this enum — getting it wrong here
is the one mistake the refusal cannot catch,** because a wrongly-plated dish refuses nothing: it looks
like food.

### Seated 2026-08-13 — the assignment

**10 reading blocks serve 16 COURSES on 6 plates. Three more blocks are furniture, not dishes.** That
ratio is the whole Phase 8 story in one number: one hand-built layout per block was always going to
misfit, because six of the blocks serve more than one course.

| Sheet block | Course(s) | Plate(s) |
|---|---|---|
| `sheetHasData` — a body reading (signification · aspects · motion · to you) | the placement's facts, **then its expansion** | **FACT** → **PROSE** — *the omelet* |
| `sheetLedger` — plate · rete · sky | one chart's placements, qualified (body · degree · house · dispositor) | **FACT** (multi-field) |
| `sheetProg` | progressed placements · progressed aspects (dated) | **FACT** + **LEDGER** |
| `sheetSynastry` (+ `compnat` · `compday`) | fixed contacts between two named subjects | **RELATION** |
| `sheetCross` | dyads (fixed) · approaching (perfects) · the sASC spread | **RELATION** + **LEDGER** + **TRACK** |
| `sheetTransits` | contacts that perfect, with dates | **LEDGER** |
| `sheetElection` | windows, ranked | **LEDGER** (+ score as a TRACK *field*) |
| `sheetQuery` | days ranked by the day's own stretches | **LEDGER** (+ score as a TRACK *field*) |
| `sheetAlmanac` | the merged fused streams | **LEDGER** (calendar = an *arrangement*, flagged below) |
| `sheetZr` | nested periods L1–L4 | **SPAN** |
| `sheetRising` | rising-lord stretches across a day | **SPAN** |
| `sheetClock` | the day's stretches | **SPAN** (deferred per Phase 8) |
| `sheetTab` · `sheetHints` · `sheetEmpty` | — | **furniture** — the server's own signage, not a dish |

**Findings, recorded:**

1. **No missing plate.** Six hold all sixteen courses. The menu closes.
2. **The multi-course panes are exactly the ones that read as "all over the place."** `sheetCross`
   serves three dishes and had one layout — which is the whole review complaint, stated structurally
   rather than as a taste objection.
3. **One flag, deliberately not resolved here: the almanac's CALENDAR is an ARRANGEMENT of LEDGER, not
   a plate** — the same dish on a platter instead of plated. Re-examined when LEDGER is built and not
   before; forcing the ruling now would be inventing a plate to avoid admitting a question.
4. **A score is a field, not a plate** — confirmed twice (election, query), and the seed was already in
   the file (the election row's `barW`).
5. **`ROSTER` is a BACK plate.** Struck from the pane's list; it goes to the ♎ Ledger tabula's own pass.
6. **FACT must admit a QUALIFIED value** (body · degree · house · dispositor), not only `{k, v}`. That is
   a field widening, not a second plate — and it happens in Phase 5 with FACT's other two dishes, never
   mid-omelet.

---

## Phase 1 · Build the pass — the omelet

**One surface, end to end: the natal signification sheet on FACT. Geometry only. No sauce, no rails.**

**The plainest possible plating, and that is the point** — three bands and nothing else: `caption ·
body · provenance`. The other four bands emit nothing, which is the scaffold's first real test. This is
step one of the ramp: the same surface gains its expansion in Phase 2 and its rails in Phase 3.

Chosen because it is the boring one: its data is already right, its rows are already clean (Phase 8
Step 5: "nothing to redesign"), and FACT is the one contract already enforced. **If anything breaks,
the port broke it — there is nothing else to blame.** Proving a mechanism on a surface that also needs
a redesign is how a scaffold bug becomes indistinguishable from a content bug, which is exactly what
happened when Step 2 "proved" the scaffold on ZR by writing a comment on it.

Sub-moves, in order:

1. **The ticket shape** — one object, defined in one place, with the four forbidden fields named in
   the comment so a future reader knows what may not be added.
2. **The pass** — takes a ticket, returns everything the bands need. Refuses on malformed.
3. **The band scaffold** — emitted once in the template, `sc-if` per band.
4. **Migrate the natal sheet through it.**
5. **Prove the refusal** with a deliberately malformed FACT row.

**Acceptance:**

- **The natal sheet renders VISUALLY IDENTICAL.** This is the fidelity proof owed on ZR and skipped.
  If the scaffold cannot reproduce the existing sheet exactly, the scaffold is wrong, not the sheet.
- Hand-written caption strings **11 → 10**; the natal sheet's is derived from its subject.
- Bespoke pane wrappers **13 → 12**.
- `_checkRow` reached **through the pass** rather than from inside one reader (same coverage; this is
  what makes the other four templates a wiring job instead of a rewrite).
- **A malformed FACT row is refused, visibly, in the console.** If this cannot be shown on screen,
  the pass is not a pass.

**Explicitly NOT in Phase 1:** rails, the arc, rest changes for other panes, the other four
templates, the sauce door, the `sySub` lie, the composite pane.

---

## Phase 2 · The saucier's door — PROSE, and the same surface sauced

**This phase orders the plate that was never ordered.** PROSE is built here — from the eclipse tier,
which is the only exemplar and is currently hand-built (serif face, page turns, dots, attribution).
Extracted, not redesigned: the reading must come out looking as it does today.

Then the door: address in, words and byline out. **One shelf, one lookup, at the pass.**

- The eclipse tier on the natal sheet is the reading that already does this by hand; it becomes the
  first sauced plate.
- **Both packs are sourced, so the byline is uniform**: Dark Pixie Astrology and Alan Leo credited the
  same way, from the pack's own metadata, never a literal in a reader (§8's single-source rule).
- **AN EMPTY SHELF IS A REAL ANSWER.** Already ruled for eclipses (`quote: null` — "Eclipses in the
  Decanates" is mundane doctrine, not personal delineation). The pass renders an address with no words
  and invents none: the same discipline as no-invented-horizon and as `mundane.js` reporting no data
  outside the embryo's span rather than faking a classification.
- **The sauce may not move an address.** A pack that could change a house, a degree or an aspect would
  be a recipe wearing a byline. The door reads addresses; it never writes them.

**Acceptance:** the natal sheet's interpretation reads identically to today with the byline now
rendered by the pass; PROSE is a plate the other surfaces can be served on without touching the eclipse
tier again; swapping Dark Pixie for Leo changes **words only** — every address on the plate is
byte-identical, measured, not assumed.

---

## Phase 3 · The natal plate's rails — side rail + glyph arc row

**Same surface, third time, and now the plating gets complicated.** The plate is trusted and the sauce
is on it, so the server's machinery can be attached to something known-good instead of debugged on a
stranger.

The natal plate's two rails already exist as content and want the arc:

- **Side rail = the four lenses** (signification · aspects · motion · to you). This is Phase 8 Step 0's
  rail, and Step 0 fixed only half of it: it is data-driven and re-centres now, but it is still its own
  hand-rolled fan of `ml`/`rot` offsets rather than the arc.
- **Glyph arc row = the bodies** — whose signification is being read. A glyph rail is precisely what the
  arc's tight rhythm was built for.

The arc is **already built** and was bypassed: width-aware chip spacing measured on canvas,
spring-driven free-slide rotation, falloff opacity, and a `_subSet` hit table with per-chip angular
tolerance — which is also the fix for Step 0's third defect, taps swallowed by `_paneGrabDown`, since
the arc owns its own hit resolution. Wiring a lens in is documented in the file as two lines ("stash its
chip list and add a branch + gate").

The port hands the arc a chip list from the ticket. **A flat rail becomes something a reader must
justify in writing**, the way deferrals are justified in `CLAUDE.md` today.

**Acceptance:** arc-fed lenses **5 → 6**; the natal plate's lenses and bodies both reachable **on the
arc**, with no flat rail present and no `±168px` offset surviving anywhere; all four lenses hittable at
the shipped preview width (Step 0's measured defect: two of four were clipped at 682px); hand-rolled
flat rails **8 → 7**.

---

## Phase 4 · RELATION — the first NEW plate, and the lie dies

**Prerequisite: cross-chart dispositorship** (see the prep survey) — built on `dispositor.js`'s own
pattern as a sibling export, before this phase, never inside it.

The pass generalizes or it does not. RELATION is the proof, and it carries the live false statement. It
arrives **inheriting** a proven plate, a proven expansion and a proven rail — it invents nothing.

**Both of its dishes in one pass**, per the migrate-by-plate rule: the seated-pair synastry grid and
the composite dyads. They are the same dish — two named subjects, one contact, an until date — which is
why they had two hand-built layouts and one wrong contract between them.

- The plate is **designed from the July dyad table**, narrowed to one line, per Phase 8 Step 7's copy
  ruling: the aspect word carries the pole, the date carries the flip, the separation degree leaves the
  row, and "(fixed since birth)" stays deleted.
- Each row names **whose** subject each side is, so the housing law holds by construction: a house on a
  RELATION row is refused unless its native is named.
- The seated-pair grid declares its true subject (**two natal charts**), so the derived caption stops
  saying "composite × composite." **The lie is not edited; it becomes unspeakable.**
- The Crossing pane's rails come **free** here — the arc already carries rails by Phase 3, so its
  hand-rolled pill row and glyph row retire without a bespoke replacement.

**Acceptance:** caption strings **10 → 8** (both dishes); wrappers **12 → 10**; templates enforced
**1 → 2**; the composite×composite caption cannot be produced by any seated-pair reading, demonstrated
by trying; a RELATION row carrying a bare house number is refused, shown in the console; hand-rolled
flat rails **7 → 5**.

---

## Phase 5 · The rest of the menu — FACT's remaining dishes, then LEDGER, then SPAN, then TRACK

One PLATE per pass, each serving all its dishes at once:

- **FACT's other two dishes** — the plate/rete/sky ledgers and the progressed placements. This is where
  FACT's contract widens to admit a QUALIFIED value (body · degree · house · dispositor); the widening
  happens with the dishes that need it, never mid-omelet.
- **LEDGER** — the almanac, transits upcoming, crossings/approaching, election windows, the query. The
  largest reuse in the phase, the one that retires Step 4's `exact to N°` mislabel wherever it
  survives, and the pass at which the almanac's calendar arrangement is finally ruled on.
- **SPAN** — ZR (the reference implementation, and where Step 2's skipped fidelity proof is finally
  owed), rising-lord stretches, retrograde periods.
- **TRACK** — the sASC spread built properly rather than appended to a caption string, plus the scores
  that ride inside LEDGER rows.

Each pass: declare the plate, hand up tickets, delete every bespoke wrapper and caption it replaces.

**Acceptance, cumulative and per pass:** wrappers **→ 1** (the scaffold), caption strings **→ 0**
(all derived), templates enforced **→ 5 of 5**, rests keyed by template with CREST/FACTS/ECLIPSE
named, `_paneNeeds` no longer reading `_eReadLen`.

---

## Phase 6 · Close the doors

Once every station is on the line, going around it becomes illegal and greppable — the same move that
made the spine and the refraction door hold.

- Raw markup in a reader, a caption string in a reader, a height in a reader: each one a defect with a
  name.
- **A load-time self-test** (`tests/lunar-port.test.html`, following `tests/prism.test.html`):
  every surface declares a template, a subject and a doctrine list; malformed rows refuse; a house
  with no native named refuses; the caption of every surface is derived and matches its subject.
- The counters from Phase A are re-measured and recorded in `CLAUDE.md` as the port's law.

---

## Phase 7 · The synchronic frame — the sASC in its own first house

Raised by the user 2026-08-13 as a thing wanted **from inception**, and the prism apparatus was built
reaching for it. Recorded here, after the port holds, because it is a DOCTRINE ruling with a prep
addition under it — not a plate, and not something to smuggle into a migration.

**THE CLAIM: the sASC is always in the FIRST HOUSE OF ITS OWN CHART, and that is how a day is
experienced.** True by construction — any chart's Ascendant sits in its own 1st — and the consequence is
the reading: as the sASC walks, a different one of the native's natal houses takes the role of the
synchronic 1st, every day, on a fixed itinerary.

**THE RANGE IS SEVEN NATAL HOUSES — the 10th through the 4th, inclusive.** The arc is ±90° **centered
on** the natal ASC (the midpoint is 90° either side), NOT 0→180 from it — corrected 2026-08-13 after an
earlier pass here miscounted six. Worked on the fixture ASC 11° Scorpio (221°): the span is 131°→311° =
**11° Leo to 11° Aquarius**, covering Leo(10, partial) · Virgo(11) · Libra(12) · Scorpio(1) ·
Sagittarius(2) · Capricorn(3) · Aquarius(4, partial). **The bounds carry the SAME degree as the ASC**, and
this is true for every native at their own ASC degree. Houses 5–9 are never the synchronic 1st.

**THE ASC'S DEGREE SETS THE SHARE, and the split is legible: a LOW ASC degree spends more of the arc in
the 10th, a HIGH one more in the 4th** (11° gives 19° of house 10 against 11° of house 4). **Exact in
DEGREES; in TIME it is warped by the ascension template** — the itinerary is uniform in degrees and the
day is not, measured at up to 9.21% drift on a template of 2225.7× unevenness. Never quote the degree
share as a time share.

**THE TABLE SPLITS IN TWO, AND ONLY ONE HALF IS ENGRAVABLE.** This is the ruling that makes the whole
thing cheap, and it follows from the four-resolution ladder:

1. **ENGRAVABLE FOREVER (INHERENT tier) — the table wanted since inception.** For each of the ~7
   stretches: the sASC's sign, the whole-sign frame it generates, and **the lord of each of those twelve
   houses.** Zero occupants, zero time — a Tympan read over frames already stamped at load. Seven rows,
   fixed at engrave, per native.
2. **MEMOIZED, NOT ENGRAVABLE (the cooler) — where those lords SIT:** the dispositor chains and the
   house-routing graph. Cannot be fixed at engrave, because the synchronic occupants drift (each is
   `midpoint(natal, sky)`, moving at half the sky's speed). Frame-vector memoized; cheap, not permanent.

**THE POSITION IS NOT PART OF EITHER TABLE, and this guardrail is load-bearing.** The horizon→sASC
cross-list is real (horizon 11° Capricorn against ASC 11° Scorpio is sASC 11° Sagittarius, at every epoch
there has ever been) but it stays **ARITHMETIC** — one wrap and one halving through `framing.refract`. A
360-row refraction table is already REFUSED: it would quantize to whole degrees against the codec law.
**The STRUCTURE becomes a table; the POSITION never does.**

**The live defect this fixes:** the pane now says WHEN the synchronic house changes and still reports
the placement's house **in the natal frame**. That is the housing law's own discipline half-applied — a
house must always be QUALIFIED, and the synchronic chart's own house is currently the unqualified one
that goes missing rather than the one that silently substitutes.

**It already works structurally; three things are missing.**

1. **The table** (the prep addition, and the downstream win named in Phase 0b), in the two halves ruled
   above: `express` takes `ascSignIdx` as a PARAMETER and never derives it from `occupants.Ascendant`, so
   `express(synchronicOccupants, sASCSignIdx, synchronicSect)` yields the synchronic chart's own house
   table today, with no special case. The prism fixes the day's itinerary at engrave, so the seven
   frames and their house lords are engravable and the chains memoize on top of them.
2. **The qualification** — every reading that prints a synchronic placement's house names which frame it
   is in, natal and synchronic side by side, never in competition (§13.1).
3. **The consequence, and it is a RULING, not a rider: if the synchronic 1st rotates through six natal
   houses a day, then what is angular FOR THIS NATIVE rotates with it** — which is an electional input
   and a personal-timeline input. Worth its own day. Do not fold it into an election pass as a
   modifier before it is ruled on.

---

## BUILT — Phase 1 (the omelet) and Phase 2 (the saucier's door), 2026-08-13

Snapshot: `archive/Orbo Astrolabe 2026-08-13b.dc.html`. Both passes measured, not reported.

**The door.** `TICKET_FIELDS` · `TICKET_FORBIDDEN` · `_ticket` · `_captionOf` · `_pass` · `_refuse`,
beside `_checkRow`. **Ten refusals fire, each with its own reason:** no template · no subject · no
doctrine · a `caption` on a ticket · a `height` on a ticket · a malformed row · **a house with no
native named** · an uncaptionable subject kind · **a PROSE band with no parent row** · **a PROSE
ticket that fetched its own words.** The PROSE gates run BEFORE the caption derivation deliberately:
a parentless prose ticket would otherwise be refused for being uncaptionable, which is true and is
not the reason. `window.__ORBO_PORT_PROBE = true` shows a refusal on screen (body suppressed, no
half-pane) and is left in permanently — a refusal nobody can demonstrate is documentation.

**AN EMPTY `doctrine` LIST IS REFUSED**, so a migrating reader must name its recipes. That is what
keeps the field from becoming the `topologyKey` smell: it is carried AND checked.

**Caption fidelity, byte-identical** across all three single-body producers (natal · live sky ·
composite): 6 natal bodies + the Ascendant, 4 live, composite Mars — every `label`/`pos` equals the
old hand-written expression. The producers now declare a `subject` (which carries the ADDRESS:
domain · signName · houseNum) and a `doctrine` list, and author no naming string; `label`/`pos`/
`glyph`/`color` survive on the sheet only because the ♒ pin and the journal read them.

**Both credits, at the pass.** Provenance is derived from `DOCTRINE_CREDITS` — recipe key in, credit
phrase out, and where the recipe is a CHOICE the entry reads the same `_doc()` door
`_doctrineKey()` memoizes on, so the credit line and the cache key cannot disagree. **The two prep
benches are credited separately** ("dispositor chains, off the Connectome · five dignity rungs, off
rulers.js — no almuten, no score"). Rendered at L3 only, the one door every other pane's provenance
asks, so the default view is unchanged. The byline comes from the pack's own metadata via
`attributionOf` and is stamped by the pass.

**The sauce moves no address, measured.** Swapping the pack changes the byline
(`The Dark Pixie Astrology` → a second sourced voice) and the words, while the FACT caption, the FACT
rows and the provenance line are **string-identical before and after**. The swap also landed on an
empty shelf and rendered the address with no words and invented none, which is the ruled behaviour.

**Counters.** Bespoke wrappers 13 → 12. Templates enforced 1 → 2 (FACT · PROSE). `_checkRow` reached
THROUGH the pass. The 11 grey-line caption strings still stand at 11 — **none of them belongs to this
sheet**; what died here is the natal sheet's own authored naming, 3 producer pairs → 0. Untouched, per
plan: heights (`_paneNeeds` still reads `_eReadLen`), the rails, the `sySub` lie.

## BUILT — Phase 3 (the natal plate's rails), 2026-08-13

Snapshot: `archive/Orbo Astrolabe 2026-08-13c.dc.html`. Same surface, third time, and the plating got
complicated on a plate that was already trusted.

**Both rails ride the arc that was already built.** The four lenses took the crown ring (r 412.7, the
dock's own detent + falloff + 11° hit tolerance); the bodies took the width-aware inner arc (r 348),
which is what a glyph rail's tight rhythm was built for. **The hand-rolled fan is deleted** —
`sheetLenses` and `lensPickerOn` are gone, and with them the `ml`/`rot`/`top: 27 + arc*32` offsets and
the ±150px bound that was clipping two of four at the shipped width.

**The chips come from the TICKET, so the pass owns what the server offers.** `FACT_BODY_LENSES` is
declared once at the pass (the dish serves four courses wherever it is served); the ticket's own
`chips` are the reader's PEERS, because only a reader knows its own chart — `_active()` filtered to
its map, so the rail honours ♊ Bodies. `_pass` returns `chips: {views, bodies}` for a FACT body dish.

**STILL ONE ACTIVATION DOOR.** `_paneGo` gained a branch, not a rival: when `_paneRailKind === 'lens'`
an id is a course rather than a destination. No second tap path was bolted onto the arc, and the
un-etch hold is inert on lens chips by construction (a lens id is never in `paneLenses`). One new
door, `_openBodySheet`, routes a peer tap by the sheet's own `subject.chart`, so the rail never has to
know how a chart is read. The rail's slide keys on the CHART, not the sheet — keying it on the sheet
would jump the rail home every time you tapped a peer.

**Measured on screen:** SIGNIFICATION rests lit at the crown with ASPECTS/MOTION curving away ALONG
the limb (the complaint: they used to ride across it); `_paneGo('toyou')` turns the ring and TO YOU
comes to the crown lit, with the reading beneath it — **all four reachable, the active one always
centred**; tapping the 7th glyph opened `my Saturn · 27° 09′ Scorpio · water · engraved` with house 1
and Mars as ruler, and the lens returned to signification. No console output. **One `_pass` call per
render** — the header band, the lens arc and the glyph arc are three bands of one plate, so they read
one result; two calls would be two sources for one caption.

**Two defects found in review and fixed in the same pass** (both were introduced or left by it):

1. **The rail still clipped 2 of 4 — the acceptance criterion itself.** Measured at the shipped 430px
   frame: `to you` entirely off it, `motion` half off. Two causes, and the second was the real one.
   **(a) A FIXED 16° STEP IS RIGHT FOR THE DOCK AND WRONG FOR LONG LABELS** — the inner arc already
   measures each chip on canvas, and the ring bypassed that; the lens rail now derives width-aware
   steps the same way (plus the letter-spacing, padding and kept-dot that `measureText` knows nothing
   about), bringing the span to ~46° inside the ±31° the frame subtends at r 412.7. Off-frame chips
   also stop taking taps (`pointer-events: none` past ±31°, which the retired fan got right and the
   arc did not). That alone measured **3 of 4**. **(b) THE DETENT WAS THE REST OF IT: resting the
   ACTIVE course at the crown is what threw the far one off the edge.** The dock brings the active
   DESTINATION to the crown because it has more chips than the frame can show; the four courses of
   ONE DISH all fit, so **the lens rail has no detent** — mid-centred, nothing spins on a tap, the
   active marked the way it always was. Measured after: **4 of 4 in frame, all hittable, before and
   after switching course.** Consequence for the machinery: the ring's tap/hold/throw resolution
   moved from an index off a uniform step to `_paneNearest` — nearest phi with each chip's OWN
   tolerance, the shape `_subUp` already used. The dock's own fixed step is untouched.
2. **A dead chip, and this pass put it there.** `_active()` includes `SNode`, `nat.pos.SNode` exists,
   so the rail offered a ☋ chip at full opacity that opened nothing — `_sheetDataNatal` gates on
   `_natalTargets()`, which SNode is not in. **The filter was a parallel guess at the producer's own
   gate**, so it now asks that gate directly. A rail may only offer what the producer can open; a
   destination that does nothing is exactly the plausible-looking result the port exists to refuse.
   Measured: 16 chips, every one opens, no ☋.
   Companion: the glyph rail now opens **centred on what you are reading** rather than on the middle
   of the list (mid-centring put ☉ and ☽ off the left edge with seventeen peers), and does not
   re-centre when you tap a peer, so a slide set by hand stays put.

**Counters.** Arc-fed lenses **5 → 6**. Hand-rolled flat rails **8 → 7**. No `±168px` or `±150px`
offset survives on this surface. Wrappers and caption strings unchanged (12 · 11) — this pass moved
rails, not plates.

### Found while building, not fixed here (P3)

1. **Interpretation text is riding inside FACT rows on this sheet.** The `Alan Leo · Ch. XVII` row in
   `_sheetDataNatal`'s `signif` (and `Ch. XIX` in the live reader) is a VOICE served as a fact field —
   PROSE content on a FACT plate, sauced at the station. It predates the port and is exactly what the
   menu says cannot happen. Belongs to Phase 5's FACT pass, with the contract widening; recorded so
   it is a known absence rather than a forgotten one.
2. **The lens rail's clipping is Phase 3's, and it is measured already.** The fan
   (`STEP 64, BOUND 150`, `top: 27 + arc*32`, `rot: raw*0.14`) is byte-identical to the pre-port
   snapshot — the port did not move it — and at the shipped preview width "to you" is off-screen and
   the labels ride across the limb. Phase 3's acceptance covers it.

## BUILT — Phase 4 (RELATION — the first new plate, and the lie dies), 2026-08-13

Snapshot: `archive/Orbo Astrolabe 2026-08-13d.dc.html`. Measured, not reported.

**The prerequisite first, as ruled: cross-chart dispositorship lives in `dispositor.js`** as sibling
exports (`crossReceptions` · `crossHandoffs` · `crossDispose`), on the walker's own pattern — two
occupant→sign maps in, the relations between them out. Two rulings surfaced while building it, both
now pinned in `tests/dispositor.test.html` (**48 checks, 0 failures**, up from 37): **a same-name
pair is never a cross relation** (Venus rules Taurus in every set there is, so A's Venus at home
being "received" by B's Venus is a fact about A alone), and **the at-home exclusion IS still a
branch across two sets** — domicile cases exclude themselves, but a planet home in Aries would
otherwise read as exaltation-received by the other's Sun, and a host is not a guest. A handoff is
ONE STEP ACROSS, never an alternating walk (the re-compositing refusal, again); `lands: null` when
the bearer leaves the frame. The `.browser.js` mirror was updated in the same pass and verified by
running the suite, not assumed.

**One plate, four dishes, one band.** `RELATION: {required: [left, mark, right], optional: [orb,
state, until, tag, houses, recep, d]}`. The seated-pair synastry grid, the two composite lenses
(× natal, × the day) and the Crossing dyads all hand up RELATION tickets and render on ONE shared
band — the old `sheetSynastry` block, which no longer knows which dish it is serving. The two grids
used to speak different contact vocabularies for the same contact; `_relMark`/`_relRow` is the one
voice now. The dyad row kept Phase 8 step 7's copy ruling: the aspect word carries the pole, `until`
carries the flip, the separation degree stays off the row.

**THE LIE DID NOT GET EDITED; IT BECAME UNSPEAKABLE.** `sySub` is deleted. A pair subject names its
parties from their own chart descriptors (`{chart: 'natal', who: 'CB'}` →
"my natal × CB's natal · same-body pairs first", measured on screen), and a ticket that tries to
carry a caption is refused — `[pass refused] a ticket may never carry caption`, demonstrated live.
The seated-pair reading now CANNOT be captioned "composite × composite" because no reader types a
caption at all. The derived captions, measured: `my natal × CB's natal` · `the composite × my
natal` · `the composite × the sky of this day` · `my synchronic composite × CB's synchronic
composite · fixed · the mode is the live half`.

**The housing law, structural:** a RELATION house is `{native, num}` or the whole ticket refuses —
`[pass refused] a RELATION house with no native named`, demonstrated via `__ORBO_PORT_PROBE` (body
suppressed, no half-pane, same discipline as P1's FACT probe, and the probe stays in permanently).

**The cross-reception join rides the rows** (`recep`, rendered at L2+), credited as its own bench
(`cross-reception`) beside `major-marks-3` — and the RELATION dishes' provenance is now DERIVED from
their doctrine keys: the hand-written synastry and compnat/compday provenance strings in `depthSrc`
are deleted.

**The Crossing's rails retired to the arc.** The DYADS·APPROACHING pill row took the crown ring as a
course rail (`_paneRailKind: 'course'` — a branch in `_paneGo`, never a rival tap path; the courses
come from the TICKET via `CROSS_COURSES`, declared at the pass; width-aware steps, no detent, same
as the lens rail). The flat glyph row died and the shared bodies now feed the inner arc that sat
**switched on and empty** since Phase A named it (`_cxChipsNow`, the `_txChipsNow` stash pattern).
Measured: crown chips `[dyads, approaching]`, `_paneGo('dyads')` opens the RELATION band with the
derived caption and hides the ledger; approaching feeds 9 glyph chips to the inner arc.

**Counters, measured honestly against the acceptance:** templates enforced **2 → 3** (FACT · PROSE ·
RELATION). Hand-rolled flat rails **7 → 5** (the pill row and the glyph row). Arc-fed lenses
**6 → 7**. Hand-written captions **11 → 10 by the Phase A list**: `sySub` is dead; `cxSub` SURVIVES,
narrowed to the APPROACHING course only — that course is a LEDGER dish and migrates in Phase 5, and
retiring its caption now would be a repair riding along with a different plate's pass. (The
acceptance's "10 → 8" assumed both of `sySub`/`cxSub` belonged wholly to RELATION; the dyads half of
`cxSub` did die.) Bespoke wrappers **12 → 12 blocks, but the RELATION plate serves four dishes on
one of them** — the cross block survives as the approaching ledger's home until Phase 5 empties it.
Untouched, per plan: heights (`_paneNeeds`), the almanac/transits/election/query/ZR surfaces, the
astrolabe.

### Found while building, not fixed here (P4)

1. **`syBlockedText`/`cxBlockedText` are still authored empty-state strings** — `empty` is a ticket
   field the RELATION producers don't yet use. Belongs with the LEDGER pass, when the blocked states
   are looked at together.
2. **The pin/journal path still reads the pre-contract `sd.rows`** (`txt`, `sameBody`) for a pinned
   synastry moment. The rows are derived from the same source, so nothing disagrees; migrating the
   pin producers is its own step, as Phase 8 already recorded.

## BUILT — Phase 5 pass 1 (FACT's remaining two dishes), 2026-08-13

Pre-pass snapshot: `archive/Orbo Astrolabe 2026-08-13d.dc.html` (P4's).

**FACT'S CONTRACT WIDENED TO ADMIT A QUALIFIED VALUE, and it widened WITH the dishes that needed
it.** A chart ledger row is not k/v prose — it is body · degree · sign · house · dispositor, four
measurements of one occupant — so FACT gained one optional field, `q`, with its own structural
contract (`Component.QUALIFIED`, checked by `_checkQualified`). **The house rides INSIDE `q` beside
its native, so a qualified house with no native is refused**, exactly as `RELATION.houses` is: the
housing law by construction, in the second place it now holds rather than the first.

**ONE MEASUREMENT, TWO PRESENTATIONS.** `_chartOccupants` is new and is the only thing that decides
where a body lives; `_specRows` (the pane's markup rows) and `_chartFactRows` (the ticket's rows,
with `q`) both shape what it returns and neither measures. Two ruler/house walks over one chart is
the same defect class as two refraction paths, and this pass would have created it.
**IT DID CREATE IT, FOR ONE REVISION, AND THE COMMENT LIED FIRST** (caught in review the same day):
`_chartOccupants` was inserted ABOVE `_specRows` and `_specRows`' body was left running its own full
duplicate walk, under a header that said "nothing about the sky is decided below this line." An
invariant that lives only in a comment is the house rule this project states most often, and the
comment arriving BEFORE the migration is how it gets broken — write the extraction and the caller in
one edit, or the false claim ships. `_specRows` maps over `_chartOccupants` now and shapes only
glyphs, colours, depth-gated columns and the tap.
Second catch, same family: `dispSign` rode out unconditionally, so a body ruling its own sign carried
a dispositor's sign with no dispositor (the Sun in Leo, measured). The two fields travel together or
not at all.

**FOUR AUTHORED LABEL STRINGS DIED.** `_captionOf` gained `kind: 'chart'`, so the plate, the rete's
seat, the sky and the progressed placements are captioned from what they ARE. `pc.label`, the
literal `'the sky'`, `_reteSeatName()` and `progSub`'s hand-built "age N · one day after birth read
as one year" are no longer the caption — the pane's ledger and progressed bands read the pass.
(`label` survives on the sd only where markup still reads it: the ROSTER precedent, a migration and
not a repair.) `_civilOf` is the one civil-time formatter those captions share.

**THE PRISM'S LEDGER NAMES ITS NATIVE CORRECTLY, which is the one place getting it wrong would still
have looked plausible.** The prism is me refracted, so its ledger's native is me and its chart is the
synchronic composite; any other rete occupant is another native and its houses are named after IT.
`_reteIsOther`'s lesson, arriving at the qualified value.

Both refusals are demonstrable under `window.__ORBO_PORT_PROBE`: the chart ledger pushes a row
carrying a bare house with no native, and the pane shows `refused · …` instead of a table.

**Not done in this pass, deliberately:** the ledger table's markup still reads `_specRows`' rows, so
`q` is checked and captioned but not yet what the table draws. LEDGER, SPAN and TRACK are the
remaining passes; `cxSub` still survives for the APPROACHING course and dies with LEDGER.

## BUILT — Phase 5 pass 2 (LEDGER — five dishes, one plate), 2026-08-13

Pre-pass snapshot: `archive/Orbo Astrolabe 2026-08-13e.dc.html`. Measured, not reported.

**ONE PLATE, FIVE DISHES, ONE TICKET, IN ONE PASS — and that is the migrate-by-plate rule paying
out.** Transits upcoming · the Crossing's approaching course · election windows · the query's ranked
days · the almanac all hand up `template: 'LEDGER'` with a `kind: 'window'` subject, and every one of
them gets its grey rule of type from `_capLine(_ledgerP)`. The plate was declared once and reused five
times inside the same pass, so the duplication had no pass in which to survive.

**FOUR AUTHORED CAPTIONS DIED, AND ONE OF THEM WAS A LITERAL IN THE TEMPLATE.** `txSubtitle`,
`querySub` and `cxSub` were strings in readers; the election's subtitle was **markup naming the data
it was handed** ("each day's best moment, ranked · tap one to travel there", typed into the
`sheetElection` block) — the caption defect at its purest, and the one no amount of reader discipline
would ever have caught. Measured after, derived, on screen:

- `every exact hit ahead · my natal · Aug 13 – Aug 24, 2026`
- `each day’s best moment, ranked · Ask for something · Aug 13 – Aug 20, 2026`
- `the days, ranked · Ask for something · Aug 13 – Aug 14, 2026 · valid at this place only`
- `the almanac · Aug 13 – Sep 27, 2026`
- `my synchronic composite × CB’s synchronic composite · approaching · Jun 29, 2026 – Feb 9, 2027 · SYNCHRONIC ASCENDANTS · 12.4° APART`

**A WINDOW IS NOT A MOMENT, so it got its own formatter.** `_civilOf` stamps an instant (a chart's
epoch); `_windowOf` stamps the two ends of a ledger's reach and drops the redundant year. And
`_partyOf` was **hoisted out of the pair branch** rather than copied: a window subject names sides too
(transits: the sky touching my natal), and two party namers would have been two vocabularies for one
relation — the same reason there is one refraction door.

**THE INSTRUCTIONS WERE NEVER CAPTIONS.** "tap one to travel there" and "adjust on ♓" are the
SERVER'S SIGNAGE, so they moved to the hint line each of those blocks already had rather than dying
with the caption they were glued to. A caption names the dish; signage tells you what your hands can
do. Nothing was lost and no new copy was written.

**THE HOUSING GATE GENERALIZED, AND THE PASS CAUGHT THE FIX ITSELF.** P4 wrote the `houses` refusal as
RELATION's own (`t.template === 'RELATION' && row.houses`). LEDGER gained the same field this pass, and
a check keyed to one template would have let the second one through silently — **the housing law is not
a property of a plate.** The gate now fires on any row carrying `houses`, and the probe proves it in
LEDGER's own name: `[pass refused] LEDGER · a LEDGER house with no native named`.

**THE QUERY'S HOUSE IS THE SYNCHRONIC ONE, AND IT SAYS SO.** `_ledgerQueryRows` qualifies each stop as
`{native: 'me', num, frame: 'synchronic'}` — §13.1's two house readings, never in competition. That is
the qualification Phase 7 generalizes; the field carries it now rather than later.

**A SCORE IS STILL NOT ON THE PLATE.** The election and query rows rank, and the contract has no
`score`: a quantity against its range is TRACK riding inside a LEDGER row, and widening a contract for
a plate that has not been designed is how a field becomes the `topologyKey` smell. TRACK's own pass
adds it, with the dishes that need it — the FACT `q` discipline, second time.

**THE CALENDAR RULING (Phase 0's one deliberately-unresolved flag, answered here): the calendar is an
ARRANGEMENT of this dish, not a plate.** Upcoming, the month grid and the day view read the SAME dated
rows — a list, a density of dots, a timeline. An arrangement changes how rows are laid out, never what
a row IS, so there is no second contract and no sixth plate. The corollary that makes it testable: the
day view is the one arrangement that names itself, and its name is its date, so `almDayLabel` — the
almanac's only authored string — is the pass's caption now (`Thursday, August 13, 2026`, measured).
The other two arrangements carry no caption at all, and their date headers are furniture.

**One measurement, two presentations, third time.** The five shapers (`_ledgerTransitRows`,
`_ledgerElectionRows`, `_ledgerQueryRows`, `_ledgerApproachRows`, `_ledgerAlmanacRows`) shape and
**measure nothing** — the pane's rich rows still draw the tables, exactly as `_chartFactRows` sits
beside `_specRows`. Every shaper's output through the contract, measured: **transits 40 · election 7 ·
query 53 · almanac 835 rows, 0 refused, 0 console output.** A refused ledger shows `refused · …` and
no table.

**Counters.** Templates enforced **3 → 4** (FACT · PROSE · RELATION · LEDGER). Hand-written captions
**by the Phase A list: the four live ones on these surfaces are gone** — what still stands is
`zrSub · clockSub · risingSub · zrProv`, all four of them SPAN's, which is the next pass. Bespoke
wrappers unchanged at 12 blocks (five of them now serve one plate; they empty when the tables read
the ticket). Untouched, per plan: heights (`_paneNeeds` still reads `_eReadLen`), the rails, the
astrolabe.

### Found while building, not fixed here (P5 pass 2)

1. **`depthSrc` still hand-writes the provenance for these five surfaces.** The pass computes theirs
   from the doctrine keys and it is measured correct (e.g. `exact hits by root-find · the moment it
   perfects, never an orb at now · major Ptolemaic marks at 3° orb · whole-sign houses`), but the
   band still renders the old literal. P4 derived RELATION's in-pass because the strings lived in the
   reader; here they live in one shared `depthSrc` ternary that also serves ZR, rising and the clock —
   so cutting it in half would leave a repair riding along with two plates' passes. **It dies with
   SPAN**, which is when the last of its branches migrates.
2. **The ticket carries the WINDOW; the arrangement carries the CUT.** The query shapes 53 candidates
   and the table shows 8; the almanac shapes 835 events and the upcoming list shows 90. That is the
   calendar ruling applied consistently (a cut is presentation), and it becomes the pass's business
   only when the tables read the ticket's rows directly.
3. **`_ledgerApproachRows` is proven by contract, not on screen** — the Crossing needs a seated pair
   and this session has none, so the caption was derived from a synthesized pair subject instead
   (quoted above). Its dyad companion was measured live in P4.

## BUILT · Phase 6 — close the doors (2026-08-14, snapshot `archive/Orbo Astrolabe 2026-08-14a.dc.html`)

**PHASE 5 WAS AUDITED FIRST, and it stands on its own counters:** templates enforced **6 of 6**,
hand-written captions **0** (every survivor — `txSubtitle · elSub · zrSub · risingSub · clockSub ·
querySub · cxSub · progSub · almDayLabel` — is a variable NAME whose value is `_ledgerCap`/`_spanCap`/
the pass's own caption; `sySub` and `zrProv` are deleted outright), `depthSrc` fully derived, TRACK
rendering measured. **Two of its acceptance items were NOT done and were recorded as deferred rather
than claimed:** bespoke wrappers are still **12 blocks** (they empty only when the tables read the
ticket's rows, which no pass has done yet), and `_paneNeeds` still read `_eReadLen`. The second one is
Phase 6's by plan; the first is not, and it is the honest gap in the phase.

**REST IS A PROPERTY OF THE PLATE NOW, DECLARED IN ONE PLACE.** `Component.PLATE_REST` (six plates →
`facts`, PROSE → `pager`) plus `Component.RAISED_ARRANGEMENTS` (`election · rising · almanac-day`).
`_paneNeeds` reads the courses the pass declared (`this._paneCourses`, stashed once per render beside
the five tickets) and **`_eReadLen` is gone from the file entirely** — the resolver can no longer ask
how much interpretation text happens to exist as a stand-in for which plate it is holding. Behaviour is
unchanged by construction: a PROSE course is on the list exactly when the sauce came back with words,
which is the same set the old length test named. **The raised set is an ARRANGEMENT and says so** — the
almanac counts only once a day is engaged, which is precisely why the thing named is the arrangement and
not the sheet.

**THE LAST DOOR A CAPTION COULD HAVE COME THROUGH IS SHUT: `Component.SUBJECT_FORBIDDEN`.** The four
forbidden TICKET fields stopped a reader handing up a finished plate; they never stopped one hiding a
name INSIDE the subject, which is the same defect one level down and the only ticket field the pass
reads words out of. A subject declares what is being READ (kind · chart · who · stream · window · place ·
note); `name · caption · label · title · heading · text · sub · markup · height · rows` refuse the ticket.
Measured against every live subject in the file first: none carried one.

**`tests/lunar-port.test.html` — the suite, and it loads the REAL class.** No copy of the pass lives in
the test (the framing/loom/prism hand-mirror exception is a cost this deliberately does not repeat): it
fetches `Orbo Astrolabe.dc.html`, lifts the logic class out, and tries to get past every refusal. ~60
checks in eight sections: the ticket's doors, the six row contracts, the housing law on three plates,
PROSE's two gates, SPAN's recursive law (including **a child overrunning its parent's END is KEPT**),
TRACK's clamp/range/zero-mark, caption derivation for all six subject kinds (**two natal charts cannot be
captioned a composite**), the two credit benches, rest-by-plate, and a greppable half that re-measures the
Phase A counters off the source text (no content-length rest anywhere in the file — the token itself is
gone, comments included — no authored caption assignment, `depthSrc` derived, every doctrine key a reader
names registered, `_checkRow` reached only through the port's four doors: `_pass` · `_checkSpanTree` ·
`_checkTrack` · `_atDepth`, the pane's depth gate).

**Green after the pass: 77 checks, 0 failures.** The harness stubs DCLogic and React (createRef included)
and then runs the REAL constructor, so the vocabulary tables, the contracts and the credits under test are
the app's own. Two suite findings worth keeping: the SPAN-nested-track refusal surfaces under the generic
contract reason (the tree check subsumes it — `_checkTrack`'s own line still fires on the console), and
`_checkRow`'s four call sites are all the port's, so the counter is pinned at exactly four rather than
"few".

**Counters after this pass.** `_eReadLen` **1 → 0**. Rests keyed by plate: **0 → 6 declared** (+ the one
declared arrangement list). Ticket doors **10 → 13 named refusals** (the three subject-field ones).
Wrappers unchanged at **12**, deliberately: consolidating them is the tables reading the ticket, which is
the composite pane's own pass and not a door.

---

## Phase 7 · pass 1 — the wrapper inventory (2026-08-14, read-only)

**The 12 are template blocks, not producers**, each gated by its own `sheet*` flag. Enumerated at
`Orbo Astrolabe.dc.html`: `sheetLedger` 1224 · `sheetTransits` 1306 · `sheetElection` 1366 · `sheetZr`
1427 · `sheetRising` 1495 · `sheetProg` 1537 · `sheetSynastry` 1649 · `sheetCross` 1703 · `sheetClock`
1746 · `sheetQuery` 1824 · `sheetAlmanac` 1858 · the body/facts block 2010. (`sheetTab`, `sheetHints`
and `sheetEmpty` are pane-level, not plate wrappers, and are not part of the 12.)

**THEY ALREADY SHARE ONE SKELETON, which is the finding that makes the consolidation tractable:** a
caption div, an `*Ok` gate, a `max-height` scroll box holding one `sc-for`, an empty state, a blocked
state, the doctrine/honesty footer pair, and a hint strip. Verified line-by-line on `sheetTransits` and
`sheetElection`; confirmed structurally on the other ten by their gate/caption headers. **Every part of
that skeleton is already a fact the pass hands over** — caption, rows, refusal reason, rest — so the
skeleton itself is what the generic wrapper is.

**What is genuinely bespoke, and therefore the real scope — four affordances, not twelve:**
1. **A day pager** (`‹ prev` / `next ›` + a day label): `rising` · `clock` · `query`. Three copies of
   one control, all three stepping one sidereal or civil day and re-shaping through `_sheetData*`.
2. **A chip row** (profile · span · topic): `election` · `clock`. Already normalized into arc chips
   elsewhere (`_elChipsNow`), so the row is a rendering of a set the logic hands up.
3. **A side rail** (tabs down the left, "ALL" included): `zr` · `almanac`. The one part that changes
   the block's LAYOUT rather than its contents.
4. **A per-row disclosure** (the Alan Leo accordion on `transits`, the derivation list on `election`,
   the ZR accordion on `zr`). These are row-level and belong to the ROW, not the wrapper.

**Split, against the pass-1 prediction of 8/4: it is 8 skeleton-only blocks and 4 affordance kinds** —
`transits · prog · synastry · cross` carry nothing but the skeleton and a row shape, `ledger` is already
a shared scaffold serving four dishes, and the body/facts block is the port's own. The prediction holds,
so **passes 2 and 3 may land in one turn.**

**The ruling this inventory forces: an affordance becomes a declared TICKET FIELD, never a wrapper
behaviour.** The pager is a `pager: {prev, next, label}` on the ticket (the plate already declares
`PROSE → pager` as a REST — the two meanings must not share the word, so the control is `stepper`);
the chip row is `chips: [...]`; the side rail is `rail: [...]` and is the one field allowed to change
the arrangement. Anything that cannot be named as a field is a row-level concern and stays on the row.

## Phase 7 · pass 2 — the one caption band (built 2026-08-14)

**THE CAPTION DEFECT HAD ONE LEVEL LEFT IN IT.** P5 made every caption DERIVED, which killed the authored
strings; what survived was the same expression typed once per dish — `refused · X : _capLine(P)` on seven
surfaces (`txSubtitle · elSub · querySub · cxSub · zrSub · risingSub · clockSub`) plus one that joined the
caption's two parts by hand (`relCaption`). Eight copies of one sentence. **A caption is a fact of the
PLATE, so a sheet's only say in it is WHICH PLATE IT IS READING, and that is a lookup** (`_portPass`), not
a caption per sheet.

**The Crossing is the entry that proves the shape rather than breaking it:** its two courses read
different plates (approaching → LEDGER, dyads → RELATION), so the COURSE picks the pass. Same question,
asked of a surface that serves two dishes — not a special case in the band.

**A REFUSAL IS A CAPTION**, so the band carries it (`refused · …`) exactly as the eight copies did. Never
a blank rule of type over a suppressed body.

`_ledgerCap` and `_spanCap` are **deleted**: with the band derived at one point, a second joined caption
sitting in scope is a second caption path waiting to be read. `_capLine` now has exactly **one** caller,
and the suite pins that number.

**Counters after this pass.** Caption expressions **8 → 1**. Caption keys in `renderVals` **8 → 0**
(deleted, not merely derived — the suite greps both the keys and the template holes). `_capLine` callers
**8 → 1**. Sheet blocks unchanged at **12**, and that is now understood to be CORRECT: the acceptance is
one WRAPPER, and a block's ROW TABLE is per plate by design. Green: **83 checks, 0 failures** (was 77).

**Still outstanding in Phase 7, honestly:** the three affordances are not yet ticket fields (`stepper` on
rising · clock · query, `chips` on election · clock, `rail` on zr · almanac), and the doctrine/honesty
footer pair is still written five times. Both are the same act as this pass, one band further down.

## Phase 7 · pass 3 — arrangements, and ARRANGEMENT C built (2026-08-14)

**THE RULING FIRST: plates are data, arrangements are layout, and the two words never share one.** A
plate says what a ROW is; an arrangement says how a surface LAYS ITS ROWS OUT. They are independent by
construction — a LEDGER is arranged flat on transits and stepped by day on the query — so neither can be
derived from the other. `Component.ARRANGEMENT` declares the three (`stepped · railed · flat`) and
`_arrangementOf(sheet)` reads them.

**A CHIP ROW IS NOT AN ARRANGEMENT — IT IS A BAND.** Election is flat and the clock is stepped and both
carry chips, so a chip arrangement would force the clock to be two arrangements at once: a thing that
must be two categories was never a category. The bands are **caption · chips · stepper · rail**, any
arrangement may declare any of them, and uniformity comes from each band being ONE piece of markup.

**THE BAND LAW: a band with nothing to show emits nothing.** ZR and the almanac each rendered
`<div style="height:12px">` for a chip row they do not have — that is why the crown arc sat too far off
the body on exactly those two surfaces, and the ZR block's own comment three lines above said the law
while the code beneath it did the opposite. Both spacers are deleted; the suite greps for the shape.

**ARRANGEMENT C IS BUILT, and it is the pattern for A and B.** The rising block moved down beside the
clock and the query; the three now sit inside one `arrStepped` wrapper that carries the stepper band, one
scroll cap and one footer pair. What died: the day stepper written 3× (rising's `‹ prev / next ›` at 11px
lost to the chevron form, being two of the three), the nine per-sheet stepper keys, the scroll-cap
disagreement (300 · 340 · 360 → 340), and rising's authored provenance sentence — the last one in the
pane, retired because `depthSrc` derives the same credit from the SPAN ticket's own doctrine keys.

**`_portStep` is MUTATED, never replaced.** The template holds the reference, and the rising sheet fills
it from inside its own row builder, where the day bounds (`dayA`/`dayB`) live. Replacing the object would
hand the band a stale one — the same class of bug as a ref that is never exposed in `renderVals`.

**Counters after this pass.** Stepper markup **3 → 1**. Stepper keys **9 → 0**. Scroll caps in C **3
values → 1**. Empty-height spacers **2 → 0**. Authored provenance strings in the pane **1 → 0**.
Arrangements built **0 → 1 of 3**. Green: **89 checks, 0 failures** (was 83).

**Next, and mechanical now that C exists:** arrangement A (seven surfaces, where a formatting change pays
back most), then B (ZR and the almanac, whose rail is the one band that changes the layout itself). The
footer pair still stands 4× outside C.

## Phase 7 · pass 4 — ARRANGEMENT A · FLAT built (2026-08-14, snapshot `archive/Orbo Astrolabe 2026-08-14b.dc.html`)

**SEVEN SURFACES LAY THEIR ROWS OUT FLAT** — the three registers (sky · plate · rete, already one LEDGER
block since C1b), the transit ledger, the election windows, the progressions, and the synastry/Crossing
pair. Caption, table, footers; nothing paged, nothing railed. They now sit in one `arrFlat` wrapper, and
because it is seven surfaces this is where a single change to the chrome pays back most — the reason A was
ranked above B.

**THE ZR BLOCK MOVED DOWN BESIDE THE ALMANAC.** It sat between election and prog and was the one thing
breaking the flat blocks' contiguity, so it moved — the same move C made with rising, and it leaves the two
railed surfaces adjacent for B to wrap. Sharing a layout means sharing MARKUP, so contiguity is not
cosmetic here: it is the precondition.

**Three bands are now written once: provenance · the doctrine/honesty pair · signage.** The divergence they
hid was real and not merely untidy:

- **A PROVENANCE IS THE PASS'S, and prog is the proof that this has to be enforced rather than intended.**
  Prog derived `progProv` off its own pass and rendered an authored `progLegend` **in the band's place**, so
  its real provenance was **computed and never rendered** — the `frameOffset` lesson for the third time, and
  the last authored provenance string in the pane after C retired rising's. It also meant prog showed no
  honesty line at all below L3, and the Crossing showed neither line.
- **`_portFootFor` reads ONE object, MUTATED and never replaced.** Prog's pass lives inside its own
  closure, so it fills the band from there — the rising-stepper pattern exactly, and for the same reason.
- **SIGNAGE IS THE SERVER'S, NEVER THE PLATE'S.** Already ruled in pass 2, when the Crossing's "adjust on
  ♓" was moved off its caption; this pass finishes the sentence by making it a declared table
  (`FLAT_SIGNAGE`) instead of six spellings of one row, three of them per-sheet `renderVals` keys.
  `FLAT_SIGNAGE_CROSS` exists because the Crossing's two courses want different lines — the same question
  the caption band already asks of that surface, not a special case in the band.

**Counters after this pass.** Footer pair **4× → 2×** (A and C; the two remaining are B's own payback).
Provenance bands **2 shapes → 1**. Signage rows **6 → 1**. Per-sheet footer keys **9 → 0** (`elHint ·
cxHint · ledgerFoot · ledgerFootPlain · ledgerProv{,On} · progLegend · progProv{,On}` — DELETED, not
re-homed). Flat scroll caps **2 values → 1** (election's 290 to 300). Authored provenance strings in the
pane **1 → 0** again, and this time there is no reader left that could hold one. Arrangements built
**1 → 2 of 3**. Band markup net: 5 `sc-if`s and 13 divs removed, 1 `sc-for` added. Green: **104 checks, 0
failures** (was 89).

**One test defect worth recording, because it is the same lesson as the code's:** the first Crossing-signage
check held two handles on `_portFoot` and compared them after the second call — but the object is mutated in
place, so it was comparing the object to itself. A mutated-in-place band has to be READ at call time. The
check failed honestly rather than passing by accident, which is the only reason it was cheap.

**Next: arrangement B (ZR + the almanac).** Its rail is the one band that changes the layout rather than
sitting inside it, which is why it is last and why it is not mechanical — the wrapper has to own a
two-column body, and the almanac's rail already carries three arrangements of its own dated rows.

## Phase 7 · pass 5 — ARRANGEMENT B · RAILED built (2026-08-14, snapshot `archive/Orbo Astrolabe 2026-08-14c.dc.html`)

**THE LAST ARRANGEMENT, AND THE ONLY ONE THAT OWNS THE LAYOUT.** ZR and the almanac now sit in one
`arrRailed` wrapper whose body is TWO COLUMNS — the rail beside the rows. A and C only ever stacked bands
above and below a single column, which is why they were mechanical once the doctrine existed and this was
not: the wrapper had to become the layout rather than sit inside it.

**THE ALMANAC'S RAIL WAS NOT A RAIL.** Its own comment read "side rail = tabs, always includes ALL" while
the markup centred a horizontal pill row above the body — documentation of the standard with the surface
hand-built anyway, the Phase A failure mode in miniature. Sharing a layout means sharing MARKUP, so the
almanac's tabs became the actual side rail the moment the two surfaces shared one.

**THE RAIL READS ONE OBJECT, MUTATED NEVER REPLACED** (`_portRail`), reset at the pass and filled by each
surface from inside its own row builder — ZR where the level cap lives, the almanac where the fused list
does. The rising-stepper and prog-provenance pattern, third and fourth time.

**A RAIL ALWAYS CARRIES AN ALL, AND THE RAIL NAMES WHICH TAB THAT IS** (`all: true`) rather than the band
guessing from a label: the almanac's ALL, and ZR's **L4 — the deepest cap, where every level is shown**.
Nothing was invented to satisfy the law; no new tab, no new copy.

**AND THE ALMANAC'S OWN ROW ARRANGEMENTS ARE NOT THIS ARRANGEMENT.** Upcoming · calendar · day lay DATED
ROWS out inside this body; the arrangement is how the SURFACE is laid out. Same word, two meanings, kept
apart deliberately — the calendar ruling (an arrangement of LEDGER, not a plate) stands untouched, and the
wrapper's comment says so where a future reader will trip.

**Two authored survivors died, both of classes already named:**

- **The almanac rendered an AUTHORED provenance sentence while its LEDGER pass derived one** — computed and
  never rendered, the `frameOffset` lesson for the fourth time and the last authored provenance in the
  pane. Prog's exact defect, one surface later, which is the argument for enforcement over intent.
- **The two hint lines were one SIGNAGE row in two spellings** (ZR's fading affordance line, the almanac's
  "tap a day to open it"). **`FLAT_SIGNAGE` is renamed `SIGNAGE`: signage is a fact of the SHEET, never of
  the arrangement**, so a `RAILED_SIGNAGE` beside it would have been the very duplication the band exists
  to kill. `_signageMuted` holds the two live suppressions (a dismissed ZR hint, an almanac with nothing
  fused) in ONE greppable place — never a `*HintOn` key back in renderVals. **One visual change, recorded
  honestly:** ZR's hint no longer fades out over 0.6s; it is present or absent, because a band cannot hold
  a per-sheet transition and a hole for one would be an arrangement value travelling through a style hole.

**Counters.** Footer pair **2× → 1× per arrangement** (3 total, and it was 4 before the almanac's authored
sentence went). Rail markup **2 → 1**. Per-sheet keys DELETED, not re-homed: **`zrRail · zrHintOpacity ·
almTabs · almHintOn`** (4). Railed scroll caps **2 values → 1** (calendar's 340 → 320). Arrangements built
**2 → 3 of 3**. Sheet blocks unchanged at **12**, correctly: the acceptance is one wrapper per arrangement,
and a block's row table is per plate by design. Green: **120 checks, 0 failures** (was 104), including B's
own greps — one wrapper, one rail band, both surfaces inside it, the rail column a SIBLING of the rows
column, the four dead keys, and the ALL declared on both rails. Measured on screen: the ZR rail (L1–L4 with
its unit words, L4 lit) and the almanac rail (ALL · CROSS · REL) both render as the left column with the
rows beside them, unchanged in appearance from their hand-built forms.

### Found while building, not fixed here (P7 pass 5)

1. **The CHIPS band is still per surface** — election's and the clock's chip rows are two pieces of markup
   for one band, and the almanac's stream-mute chips are a third shape. Pass 3 named chips as a band and
   the three arrangements were the larger payback; unifying them is the same act, one band further down.
2. **The plate register's duplicate signage line is gone** (2026-08-14): "tap a planet for its reading"
   was rendered at the top of the register while `SIGNAGE.plate` carried "tap a planet to read it" at the
   bottom. One line cut, `ledgerIsPlate` deleted — signage rides the signage band only.



- **The composite lunar pane** — the work this remodel is clearing the way for. It opens **on** the
  port, not beside it: two natals seated, crystallized, and their engagement with the light.
- **Phase 8's own deferrals stand:** the synchronic clock's stretch rows onto SPAN (whose marks name
  neither endpoint — `♅ Uranus trine · 1:09 PM` is read as transiting Uranus to the natal Ascendant by
  everyone who has tried it), and drift/σ in the crown, which move when the crown is redesigned.
- **The `_paneNeeds` 'raised' family** (election/rising/almanac-day) keeps today's behaviour until
  Phase 5 reaches it; changing two rest families at once is the bulk-edit lesson again.

---

## BUILT · Phase 5 pass 3 — SPAN (2026-08-13, snapshot `archive/Orbo Astrolabe 2026-08-13f.dc.html`)

**ONE PLATE, THREE DISHES: ZR's nested chapters · the rising-lord handoffs · the prism clock's
stretches.** The three producers hand up a `spanTicket` (`subject` + `doctrine`) and nothing else;
`_spanZrRows` / `_spanRisingRows` / `_spanClockRows` shape the rows and measure nothing, exactly as
the five LEDGER shapers do. **The field is `spanTicket` on all three because `span` on the clock's sd
already means the day/week reach — two meanings never share one name** (the pair spine's lesson,
applied before it could bite rather than after).

**A STRETCH SERIES IS NOT A WINDOW, and that is why it is its own subject kind rather than a sixth
`stream` on `window`.** A window is a reach a dated stream is read OVER; a stretch series IS the
reading — durations that partition their span. **And the unit word is derived from the stream**
(`STRETCH_UNIT`: periods · handoffs · stretches), because a reader that could type "handoffs" could
type it over ZR's chapters. **THE TALLY IS THE PASS'S, NOT THE READER'S**: `risingSub`'s authored
"N handoffs" is now counted at the pass, over the WHOLE tree, so an opened chapter says how much is
actually on the plate.

**SPAN IS THE ONE NESTABLE PLATE, so it gained a structural law the five flat ones do not have, and
the law is checked RECURSIVELY** — a tree checked only at its root is a tree checked at one node, and
the ZR accordion's entire content lives below the root. `_checkSpanTree` refuses a child list that is
not a list of SPAN rows, a stretch that ends before it starts, and **a child that BEGINS outside the
parent holding it.**

**THE LAW IS ON THE START AND NOT ON THE END, AND THAT IS VALENS RATHER THAN LENIENCY.** The first
draft refused on containment of both ends, which is the obvious law and would have blanked every
expanded chapter in the app: `zr.js`'s `buildLevel` walks WHOLE periods `while (jd < untilJd)`, so a
chapter's last subperiod runs PAST its parent's end and is deliberately not truncated. The tradition's
overflow is real, so it is **measured** (worst overhang, in minutes) and never refused — the same
discipline as the prism's slivers: never "fix" a structural fact away.

**THE FIDELITY PROOF STEP 2 OWED IS WIRED, AND IT IS INSTRUMENTATION, NOT AN ASSERTION.**
`_spanFidelity` runs beside the four refusal probes under `__ORBO_PORT_PROBE` and logs, per stream:
row and root counts, hole count, worst tiling delta and worst overhang in minutes, the shaped roots
against **the engine asked again** (`zr.buildChapters`, max boundary delta in minutes), and the
series' own reach against the day it claims to cover. It measures the CLEAN tree via a second pass,
because the probe's own ticket is refused by design and measuring that one would prove nothing.
**The numbers are not recorded here: this session's frame never reached an engraved natal, so ZR,
rising and the clock could not be opened.** They are read off the `[span fidelity] …` console line and
belong in this section the moment the pass is run on a chart — an unmeasured claim is what Step 2 left
behind and it is not being left twice.

**Counters.** Templates enforced **4 → 5** (FACT · PROSE · RELATION · LEDGER · SPAN). Hand-written
captions **by the Phase A list: 11 → 0.** `zrSub`, `risingSub` and `clockSub` are derived from their
subjects; `zrProv` is deleted outright and its band renders the derived `depthSrc` like every other
surface's. **`depthSrc` IS FULLY DERIVED — five authored branches → none**, which retires the last
hand-written provenance in the app; the four credits its election literal named and no registry entry
covered (`lilly-voc` · `lilly-points` · `dorotheus-moon` · `egyptian-bounds`) were **registered rather
than dropped**, plus `rising-lord`, `ascension-template` and `aspect-glosses` — *a credit that lives
only in a template string is a credit nothing can check.* One duplication died on the way:
`_risingDayBounds` is now the one door to the rising day's civil bounds (the sd, the shaper and the
table each computed it).

### Found while building, not fixed here (P5 pass 3 · superseded by pass 4 for item 1)

1. **The clock's stretch ROWS are still Phase 8's deferral.** The table draws `clockRows`; what
   migrated is the caption, the credit and the count. The endpoint-naming defect Phase 8 recorded
   (`♅ Uranus trine · 1:09 PM` read as a transit to the natal Ascendant) is a copy change on that
   table and belongs with it, not with this plate.
2. **Retrograde periods are on SPAN's list and have no surface** — they exist as fused almanac events,
   not as a stretch table. Building one is a new view, not a migration, so it stays out.
3. **TRACK is now the only plate left** — the sASC spread built properly rather than appended to a
   caption string, and the scores riding inside LEDGER rows (`barW`, the query's and the election's).

---

## BUILT · Phase 5 pass 4 — TRACK, both halves (2026-08-13 data · 2026-08-14 render)

Pre-render snapshot: `archive/Orbo Astrolabe 2026-08-14.dc.html`. The pass was **fragmented across two
sessions and the leftover was twice called a future phase**; it is one pass and this is its one record.

**THE DATA HALF (2026-08-13).** `TRACK: {value, min, max}` + `direction` · `marks` · `unit`, with
`_trackOf` (the producer's door, which CLAMPS and keeps the true value on `raw`), `_trackFill` (the bar,
measured from a zero MARK when the track names one) and `_checkTrack` (the nested check, run wherever a
track nests — inside a LEDGER row and inside a SPAN row alike). **A RANGE IS A FACT OF THE MEASUREMENT,
NEVER OF THE SAMPLE SET**: fitting min/max to the rows in hand would make today's best window look
identical to a week where nothing is good. The election score rides its LEDGER row; the dial's σ and
drift stopped being hand-formatted at the point of display; and every clock stretch gained its walk arc
as a track — `sigma`/`sigmaEnd` had been on every stop since P3's CODEC 2 and were being thrown away
here, the `frameOffset` lesson for the fourth time. `track` is legal on a SPAN row for that one reason,
and `_checkSpanTree` checks it **recursively** so it cannot ride along untested. Credit:
`stretch-walk`.

**THE RENDER HALF (2026-08-14) — THE PANE DREW A STRETCH AS TIME ONLY, so the day's whole claim was
carried and invisible.** Ruled, per the two honest options: **the walk is a SECOND BAR under the clock
bar, in the same row.** The denser option (the arc as a fill inside the time bar) was refused on
doctrine rather than taste — it makes the walk a proportion OF the clock, and the interface may never
imply that one of the two descriptions is the real one and the other a figure of speech.

**THE TWO TRACKS SHARE ONE SHAPE OF RANGE, which is what makes the mismatch legible at all**: each is
this stretch against the WHOLE DAY (0–180° of walk · 0–dayHours of clock), so the two fills are
comparable BY CONSTRUCTION and the disagreement is a difference of two adjacent bar-ends rather than a
number announcing itself. Both widths come from `_trackFill`; the bar is drawn from the track and
nowhere else.

**ONE DOOR BUILDS BOTH — `_clockTracks(st, dayHours)`** — read by the SPAN shaper (which carries the
walk onto the row) and by the pane's own rows (which draw both bars). Neither measures: one
measurement, two presentations, for the fourth time in this phase. **ONLY THE WALK RIDES THE SPAN ROW,
and that is a ruling, not an omission:** a SPAN row already carries `start` and `end`, so TIME is the
plate's own axis and a time track on the row would be a second name for a fact the contract already
holds.

**THE FLIP IS ALWAYS A BOUNDARY, SO NO STRETCH CONTAINS IT — and that invalidated the data half's own
mark.** Measured on the fixture: the template BREAKS the day at σ = 90 (row 4 ends at
90.00000000000003, row 5 begins there carrying `afterFlip`), so the interior test
`sigma < 90 && sigmaEnd > 90` **could only ever fire on float noise** — it fired once a day, 2.8e-14°
past the far point, and pinned a tick at 100% of that stretch's own fill. A mark that is true only
because of a rounding error is exactly the plausible-looking result the port exists to refuse. The mark
is now on the stretch that ARRIVES at the flip (`|σ_end − 90| < 1e-6`), at the end of its own arc,
where the walk actually turns — a NAME on a boundary, never a special case in detection: P4's ruling
stands and the pole is still `framing.phaseOf`'s.

**TWO DUPLICATIONS OF A SCALE, BOTH KILLED — and one of them was pass 4's own.** The election's ±2.5
with zero marked was typed in the LEDGER shaper AND in the pane's `barW`, which is the very duplication
`_trackFill`'s comment forbids one method further down; it is `_electionScoreTrack` now. And the dial's
drift scale (±1, zero marked "the walk and the clock agree") would have been re-typed by the row's own
drift the same afternoon; it is `_driftTrack` + `_fmtDrift`, read by the crown and the row alike, so the
two cannot disagree about what drift means.

**Depth, and the one field that retired.** The bars render at every depth, because the bars ARE the
reading; the numbers keep the L2 gate `durStr` had, and `durStr` itself is gone — the duration is now
measured against the day instead of printed loose. L2 adds the flip's name, L3 the row's drift, worded
from the drift track's own zero mark when the two agree.

**Measured on screen** (fixture Test · 1985-04-10 20:16 · Madison WI · Friday Aug 14, 2026, at the
shipped preview width):

- **8 stretches. The walk sums to 180.0000° exactly and the clock to 23.935h against the day's own
  23.9345h** — both scales complete, so neither bar is measured against a range it does not fill.
- **Per-row drift −4.93% … +7.08%**, against the dial's +10.2% for the day in the crown. §1.1's claim
  is now readable per row: `2.3h` of clock against `30.0°` of walk (10% against 17%) one row above
  `5.2h` against `30.0°` (22% against 17%) — the same arc, twice the day.
- **Exactly one flip mark per day**, at its own fill's edge (6.4% on the fixture); in week mode
  **7 days × 8 rows = 56 rows, 7 marks, and each day's walk sums to 180.0000°** against **its own**
  length.
- **0 refusals**: every walk, time and drift track through `_checkTrack` on all 56 rows, no console
  output.
- Plain depth: two bars, two axis words (`clock` · `walk`), no numbers, no note. Scholarly: both
  numbers and the drift line.

**Counters.** Templates enforced **5 → 6 of 6** (FACT · PROSE · RELATION · LEDGER · SPAN · TRACK) — the
data half's, recorded here because it was never recorded there. The render half moves no counter and
closes the reading: **the plate list is complete and every plate is enforced.**

### Found while building, not fixed here (P5 pass 4)

1. **The query's score has no track, and the reason is doctrinal rather than lazy: it has no ceiling.**
   The election's ±2.5 is a scale its doctrine defines; `prism.js`'s `scoreStop` sums a house (0.8), a
   lord (0.6), an unbounded number of halved-orb marks (≤0.8 each) and an edge penalty, so no honest
   max exists — and fitting one to the candidates in hand is precisely what the range law forbids. It
   stays a signed number with a colour until the scale is ruled on. **Do not invent a range for it.**
2. **The clock ledger's MARKS still name neither endpoint** (`♅ Uranus trine · 1:09 PM`, read by
   everyone who has tried it as transiting Uranus to the natal Ascendant). Phase 8 recorded it and it
   is still a copy change on that table, not a plate.
3. **`_paneNeeds` still reads `_eReadLen`.** Untouched by every pass in Phase 5, as planned; it belongs
   to Phase 6's rest-by-template work.
