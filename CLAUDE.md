# Orbo AstroLabe — project conventions

## ORBO RUNS ON FIELD THEORY ASTROLOGY, and Orbo is the means of proving it
**This is the user's own framing. It is not a received tradition and it is not on Google yet.** Sources
of record: `docs/Field Theory Astrology for Orbo Timespine.md` (the white paper) and, where the two
differ, `docs/Synchronic Conversation -source for the white paper-.md` (the transcript it was distilled
from). Field Theory is the thing the app exists to demonstrate, so it is not a feature area, a lens or
a mode: it is the ground the whole instrument stands on, and a design decision that contradicts it is
wrong however well it reads.
**THE SYNCHRONIC LAYER IS NOT A SEPARATE IDEA. IT EMERGES FROM FIELD THEORY.** A composite is the chart
of an emergent field produced by two fields of light in relation (see Composite terminology below). The
synchronic composite is that one operation with a MOMENT as one of the two parents. Everything the app
calls synchronic follows from that and from nothing else.
**WHAT THE SYNCHRONIC CLOCK IS ACTUALLY DEMONSTRATING: the movement of temporal energy through a fixed
point, one's natal field. AND, EXACTLY EQUIVALENTLY, THE OPPOSITE: the movement of a fixed point, one's
natal field, through temporal fields.** Physics gives the same answer both ways, and neither phrasing is
privileged over the other. Both descriptions are of ONE object, so the interface must never imply that
one of them is the real one and the other a figure of speech. This is why the instrument's own
vocabulary works in both directions and must keep doing so: the cursor moves and the plate holds still,
the sASC walks and comes home while the natal degree never moves, the itinerary is uniform in degrees
while the day is not uniform in time. Those are not three coincidences. They are the same symmetry
seen from three places.

## PLATES ARE DATA · ARRANGEMENTS ARE LAYOUT (ruled 2026-08-14, Phase 7 pass 3)
**TWO AXES, TWO WORDS, AND THEY MUST NEVER SHARE ONE.** `template: 'LEDGER' | 'SPAN' | 'FACT' |
'RELATION' | 'PROSE'` is a **PLATE**: what a ROW IS (its fields, its qualified house, its measured
range). It says nothing about how a surface looks. An **ARRANGEMENT** is how a surface LAYS ITS ROWS
OUT, and it is shared by many surfaces: change the arrangement and every surface on it moves. The two
are independent by construction — a LEDGER is arranged flat on transits and stepped by day on the query
— which is exactly why neither can be derived from the other. (The rest ladder's
`RAISED_ARRANGEMENTS` already used the word in this sense; this generalizes it rather than inventing it.)
**THE THREE ARRANGEMENTS, cut by what the layout actually does** (declared in `Component.ARRANGEMENT`,
read through `_arrangementOf`): **A · flat** (caption, table, footers — sky/natal/plate, transits, prog,
synastry, cross-approaching, election) · **B · railed** (a side rail of tabs, always carrying ALL — ZR,
almanac) · **C · stepped** (a day pager with a label — rising, clock, query).
**A CHIP ROW IS NOT AN ARRANGEMENT — IT IS A BAND.** Election is flat and the clock is stepped and BOTH
carry chips, so a chip arrangement would force the clock to be two arrangements at once: a thing that
must be two categories was never a category, it is an axis. The bands are **caption · chips · stepper ·
rail**, any arrangement may declare any of them, and uniformity comes from each band being ONE piece of
markup — not from promoting it to a kind. (Same defect class as a caption typed per sheet.)
**THE BAND LAW: A BAND WITH NOTHING TO SHOW EMITS NOTHING** — no spacer, no reserved height, no
placeholder. ZR and the almanac each rendered `<div style="height:12px">` for a chip row they do not
have, which is why the crown arc sat too far off the body on exactly those two surfaces; the ZR block's
own comment three lines above said "a band with nothing to show emits nothing" while the code under it
did the opposite. Reserved space is the same defect as a blank caption band over a suppressed body.
**Status: ALL THREE ARRANGEMENTS ARE BUILT (C 2026-08-14 · A pass 4 · B pass 5).** Sharing a layout
means sharing MARKUP (arrangement values cannot travel through `{{ }}` style holes — that is the
paint-delay anti-pattern), so it means grouping the blocks by arrangement and emitting each
arrangement's chrome once. **C is done and was the pattern for A:** the rising block was
moved down beside the clock and the query, the three sit inside one `arrStepped` wrapper, and the day
stepper is ONE band reading ONE object (`_portStep`, mutated and never replaced, so the rising sheet can
fill it from inside its own row builder where the day bounds live). The nine per-sheet stepper keys are
gone, the scroll caps agree at 340 (were 300 · 340 · 360), and the doctrine/honesty footer pair is
written once for all three — which retired rising's authored provenance sentence, the last one in the
pane, since `depthSrc` derives the same credit from the SPAN ticket's own doctrine keys.
**A · FLAT is built (2026-08-14, pass 4) and pays back 7×.** Seven surfaces lay their rows out flat — the
three registers (already one LEDGER block), transits, election, prog, synastry/Crossing — inside one
`arrFlat` wrapper. **THE ZR BLOCK MOVED DOWN BESIDE THE ALMANAC** to make the flat blocks contiguous, the
same move C made with rising, which also puts the two railed surfaces adjacent for B. Three bands are now
written once: **provenance · the doctrine/honesty pair · signage.**
**A PROVENANCE IS THE PASS'S, and prog proved why that has to be enforced rather than merely intended:**
prog derived `progProv` off its own pass and rendered an authored `progLegend` in the band's place, so the
real provenance was **computed and never rendered** (the `frameOffset` lesson, third time) and prog carried
no honesty line at all below L3 while the Crossing carried neither line. `_portFootFor` reads one object,
MUTATED never replaced, and prog's pass lives inside its own closure so it fills the band from there — the
rising-stepper pattern exactly. `progLegend` was the last authored provenance string in the pane.
**SIGNAGE IS THE SERVER'S, NEVER THE PLATE'S** (already ruled when the Crossing's "adjust on ♓" was moved
off its caption), so it is a declared table — `FLAT_SIGNAGE`, plus `FLAT_SIGNAGE_CROSS` because the
Crossing's two courses want different lines, the same question the caption band already asks of that
surface. Six spellings of one row became one, and nine per-sheet footer keys (`elHint · cxHint ·
ledgerFoot · ledgerFootPlain · ledgerProv{,On} · progLegend · progProv{,On}`) are DELETED rather than
re-homed. Flat scroll caps agree at 300 (election was 290). **Measured after A: 104 checks, 0 failures.**
**B · RAILED is built (2026-08-14, pass 5), and it is the one arrangement that owns the LAYOUT.** ZR and
the almanac sit in one `arrRailed` wrapper whose body is TWO COLUMNS — the rail beside the rows — where A
and C only ever stacked bands above and below one column. The rail is written once and reads one object
(`_portRail`, MUTATED never replaced), filled by each surface from inside its own row builder where its
tab state lives: ZR's level cap, the almanac's fused streams. **A RAIL ALWAYS CARRIES AN ALL, and each
rail NAMES which of its tabs that is** (`all: true`) rather than the band guessing from a label — the
almanac's ALL tab, ZR's L4 (the deepest cap, every level shown). Nothing invented: no new tab, no new copy.
**THE ALMANAC'S RAIL WAS A HORIZONTAL PILL ROW pretending to be a side rail** (its own comment said "side
rail = tabs" while the markup centred them above the body); sharing a layout made it the actual rail.
**AND ITS ROW ARRANGEMENTS ARE NOT THIS ARRANGEMENT** — upcoming · calendar · day lay DATED ROWS out
inside the body, which is a different question from how the surface is laid out; same word, two meanings,
kept apart deliberately (the calendar ruling, undisturbed).
**Two authored things died, both of the classes already named:** the almanac rendered an AUTHORED
provenance sentence while its LEDGER pass derived one — the `frameOffset` lesson a fourth time, and the
last authored provenance in the pane — and the two hint lines (ZR's fading affordance line, the almanac's
"tap a day to open it") were two spellings of one SIGNAGE row. **`FLAT_SIGNAGE` IS NOW `SIGNAGE`: signage
is a fact of the SHEET, never of the arrangement,** so a `RAILED_SIGNAGE` beside it would have been the
exact duplication the band exists to kill. A dismissed or absent affordance is nothing to show, so
`_signageMuted` gates it in ONE greppable place instead of a `*HintOn` key per sheet.
**Counters:** footer pair **2× → 1× per arrangement (3 total, was 4 with the almanac's authored one)** ·
rail markup **2 → 1** · four per-sheet keys DELETED (`zrRail · zrHintOpacity · almTabs · almHintOn`) ·
railed scroll caps agree at **320** (was 320 · 340) · **120 checks, 0 failures** (was 104).
**Pass 6 (2026-08-14): THE CHIPS BAND IS ONE PIECE OF MARKUP.** `_portChips` ({on, items}, MUTATED
never replaced, reset beside the stepper/rail) is filled from election's and the clock's own builders;
`elSpanChips · clockSpanChips · paneSubEl` are DELETED rather than re-homed. Chip markup **2 → 1**; the
clock's chips keep their blocked-state behaviour (they show while the body is refused, exactly as the
old row did). Riding the same pass, the Phase 8 copy defect closed: **the clock ledger's marks name
BOTH endpoints** — `sASC trine ♅ sUranus`, was `♅ Uranus trine` (which every reader took for transiting
Uranus to the natal ASC). The wording is the engine's own (`queryOf`'s drivers), s-prefix vocabulary.
**Still standing, honestly:** bespoke wrappers remain 12 — they empty when the tables read the ticket's
rows, which is the wrapper pass, the phase's last.

## The wrapper pass · one blocked band, and the phase closes (built 2026-08-14, Phase 7 pass 7)
**THE WRAPPER'S LAST DUPLICATED CONTENT WAS THE BLOCKED BOX, TYPED TEN TIMES** (plate · rete ·
transits · election · prog · synastry · cross · clock · query · zr), each with its own
`*Blocked/*BlockedText/*BlockedTap` keys — the caption defect in its last hiding place.
`Component.BLOCKED_SIGNAGE` declares text per REASON and which panel a tap opens (null = the box
is not a door: an engine that did not load, a rete with no one to seat from here); `_portBlockedFor`
derives {on, text, tap, cur} (cursor follows the tap — a box that is not a door does not pretend to
be one); ONE band renders it beside the caption. **~28 per-sheet keys DELETED** (incl.
`goNatalFromSheet`), blocked markup **10 → 1**. The compsyn lenses' composite-panel tap is a fact of
the DISH, handled in the derivation, never typed per sheet.
**WHAT REMAINS PER SHEET IS ITS ROW TABLE, AND THAT IS THE RULING, NOT A GAP** — pass 2 already said
it: "a block's ROW TABLE is per plate by design." The LEDGER/SPAN shapers stay the checked-and-
credited door; if tables are ever drawn from ticket rows directly, that is a NEW phase through the
shapers, not unfinished business of this one. **The lunar port is CLOSED.**
**TWEAKS (same pass):** the root DC carries `paneDepth` (host override of the depth dial, wins over
state, unset changes nothing) · `paneSignage` (mutes every hint row through `_signageMuted`'s one
gate) · `portProbe` (flips `window.__ORBO_PORT_PROBE` so the refusals demo without devtools). Future
pane-wide switches are PROPS, never a hand-rolled controls panel.
**The build contract for future surfaces is distilled in `specs/Lunar Pane Templates - Build
Guide.md`** — plate → ticket → arrangement → bands → allergies → tests. Read it before adding any
pane surface.

## The one caption band · a caption is the PLATE's (built 2026-08-14, Phase 7 pass 2)
**A CAPTION IS A FACT OF THE PLATE, SO A SHEET'S ONLY SAY IN IT IS WHICH PLATE IT IS READING.** P5 killed
the authored caption strings and left the defect one level up: `refused · X : _capLine(P)` typed on seven
surfaces plus one hand-joined `relCaption` — eight copies of one sentence. The band is rendered ONCE from
`_portPass`, a lookup from the open sheet to the plate's own pass; the eight keys are DELETED rather than
derived, and `_capLine` has exactly **one** caller (a second joiner is a second caption). **A REFUSAL IS A
CAPTION** and rides the same band — never a blank rule of type over a suppressed body. The Crossing's two
courses read different plates, so the COURSE picks the pass: the same question asked of a surface serving
two dishes, not a special case in the band. **Sheet blocks stay at 12 and that is correct** — the
acceptance is one WRAPPER; a block's ROW TABLE is per plate by design. Measured: 83 checks, 0 failures.

## The port's law · rest is a property of the PLATE (built 2026-08-14, Phase 9 P6)
**A CAPTION, A HEIGHT AND A REST ARE THE PASS'S, AND NOW THERE IS NO WAY ROUND ANY OF THEM.**
`Component.PLATE_REST` declares each plate's rest (six → `facts`, PROSE → `pager`) and
`RAISED_ARRANGEMENTS` names the one exception — an ARRANGEMENT (`election · rising · almanac-day`),
never a plate, because the almanac counts only once a day is engaged. `_paneNeeds` reads the COURSES
the pass declared (`this._paneCourses`) and **`_eReadLen` is gone from the file**: the resolver may
never again ask how much interpretation text happens to exist as a stand-in for which plate it holds.
**`SUBJECT_FORBIDDEN` shuts the last door** — a caption could still have ridden inside the subject, the
same defect one level down, so `name · caption · label · title · heading · text · sub · markup · height ·
rows` refuse the ticket. 13 named refusals now, from 10.
**`tests/lunar-port.test.html` LOADS THE REAL CLASS OUT OF THE DC** rather than mirroring the pass — a
second copy of a door is a door that will disagree. Half its checks are source greps, because half of
Phase 6 is not a behaviour: going around a station has to be GREPPABLE (no authored caption assignment,
no content-length rest, `_checkRow` reached only through the port's four doors, every doctrine key a
reader names actually registered). **Measured: 77 checks, 0 failures** — the harness runs the real
constructor against a stub React/DCLogic, so the caption checks read the app's own vocabulary tables.
Phase 5's own gap, recorded honestly: bespoke
wrappers are still 12 — they empty when the tables read the ticket's rows, which no pass has done.

## SPAN's nesting law · start, never end (built 2026-08-13, Phase 9 P5 pass 3)
**SPAN IS THE ONLY NESTABLE PLATE, so its rows are checked RECURSIVELY** (`_checkSpanTree`): a tree
checked only at its root is a tree checked at one node, and the ZR accordion's whole content is below
the root. **The containment law is on the child's START and never on its END, and that is Valens
rather than leniency:** `zr.js`'s `buildLevel` walks WHOLE periods `while (jd < untilJd)`, so a
chapter's last subperiod runs PAST its parent's end and is deliberately not truncated. A both-ends
law is the obvious one and would blank every expanded chapter in the app. The tradition's overflow is
real, so it is MEASURED (`_spanFidelity`, worst overhang in minutes) and never refused — same
discipline as the prism's slivers: never "fix" a structural fact away.
**A stretch series is not a window.** A window is a reach a dated stream is read OVER (LEDGER); a
stretch series IS the reading. Hence `kind: 'stretches'` with its own derivation, and the unit word
(`STRETCH_UNIT`: periods · handoffs · stretches) derived from the stream — a reader that could type
"handoffs" could type it over ZR's chapters. **The row tally is the PASS's**, over the whole tree.
**The producers' field is `spanTicket`, not `span`,** because the clock's sd already uses `span` for
its day/week reach. Two meanings never share one name.
**`depthSrc` is fully derived as of this pass** — every branch reads a ticket's doctrine keys through
`DOCTRINE_CREDITS`, and `zrProv` is deleted. Credits an authored string named but no registry entry
covered were REGISTERED, not dropped: a credit that lives only in a template string is a credit
nothing can check.

## TRACK's law · one range, two bars (built 2026-08-14, Phase 9 P5 pass 4)
**A QUANTITY IS NEVER HANDED OVER WITHOUT THE RANGE IT WAS MEASURED AGAINST**, and **the range is a fact
of the MEASUREMENT, never of the sample set** — fitting min/max to the rows in hand makes today's best
window look identical to a week where nothing is good. `_trackOf` clamps and keeps the true value on
`raw`; `_trackFill` draws the bar (from a zero MARK when the track names one, because on a signed scale
zero is the reading's own boundary); `_checkTrack` checks a track wherever it NESTS — inside a LEDGER row
and inside a SPAN row alike, recursively through `_checkSpanTree`. **THE BAR IS DRAWN FROM THE TRACK AND
NOWHERE ELSE.**
**ONE DOOR PER SCALE.** A scale typed twice is a scale that will disagree with itself: `_electionScoreTrack`
(±2.5, zero marked) is read by the LEDGER shaper AND the pane's bar, and `_driftTrack`/`_fmtDrift` (±1,
zero marked "the walk and the clock agree") by the crown's dial AND the clock row. Both duplications were
live for one afternoon each and both were the same defect as two refraction paths.
**THE CLOCK PANE DRAWS A STRETCH TWICE, NEITHER READING PRIVILEGED: a clock bar and, directly under it, a
walk bar.** The denser option (the arc as a fill inside the time bar) is REFUSED on doctrine — it makes
the walk a proportion OF the clock, and the interface may never imply one description is the real one and
the other a figure of speech. **Both tracks share one SHAPE of range — this stretch against the WHOLE DAY
(0–180° · 0–dayHours) — which is what makes the mismatch legible without a number to announce it.**
Measured: walk sums to 180.0000° and clock to the day's own 23.9345h, per-row drift −4.93%…+7.08%, 0
refusals over 56 week rows. **ONLY THE WALK RIDES THE SPAN ROW** — a SPAN row already carries start/end,
so a time track would be a second name for a fact the contract holds.
**THE FLIP IS A BOUNDARY, SO NO STRETCH CONTAINS IT.** The template breaks the day at σ = 90, so the first
draft's interior test (`sigma < 90 && sigmaEnd > 90`) could only fire on FLOAT NOISE — 2.8e-14° past the
far point, once a day, pinning a tick at 100% of that stretch's fill. The mark is on the stretch that
ARRIVES at the flip (`|σ_end − 90| < 1e-6`). A name on a boundary, never a special case in detection.
**A SCORE WITH NO DOCTRINAL CEILING GETS NO TRACK:** the query's `scoreStop` sums an unbounded number of
marks, so it stays a signed number until the scale is ruled on. Never invent a range to get a bar.

## The pair spine's field collision (found in review, 2026-08-12)**A scan series carries a second BODY on `b`; its scan bound must never also be called `b`.** The
Phase 7 pair-spine builder wrote `{ kind: 'cross', a: p.a, b: p.b, …, b, step: 1 }`, and the
shorthand `b` (the century's end jd) silently overwrote the body. Every one of the 8884 crossings
came out as `{a: 'Moon', b: 2479527.98}`, which reads as a plausible row rather than an error: the
pane rendered a body pair with a julian date in it and `posAt(jd)[c.b]` was undefined, so both
houses came back null. The bound is `end` now, and `_pairSpineKey` moved to `v2|` because the bad
rows were already persisted to IndexedDB. Two lessons, both already house rules elsewhere: a
plausible-looking result is worse than an error, and two meanings never share one name.
Two companions found in the same read: a spine crossing carried no `name` (the aspect word the
pane's row prints, so it read "undefined × ♀ Venus"), and the Crossing `.ics` export still read
`d.rows` while the pane read `d.pairRows` — the window control was real on screen and not in the
calendar. **When a reader gains a second source, every consumer of the old one is part of the
change.** Measured after the fix: a 150-day window reads 36 rows past day 7, where the live-only
fallback read 3.

## Versioning system (agreed 2026-07-11)
- **`Orbo Astrolabe.dc.html` is THE working base.** All edits and iterations happen in this one file. No version numbers in the working filename.
- **Before any significant revision** (redesign, new subsystem, risky refactor — not small tweaks), snapshot the current file first:
  `archive/Orbo Astrolabe YYYY-MM-DD[a,b,c…].dc.html` (letter suffix only if multiple snapshots same day).
- Never create parallel `v7`, `v8`, "Export", etc. root files. Alternates/explorations go in `archive/` or behind an in-design switcher.
- `Orbo Astrolabe.dc.html` was rebased on 2026-07-11 from the user's uploaded bundle `uploads/Orbo Astrolabe 711-fdee483b.html` (an evolution of v6 with direct edits). Older files (`Orbo Astrolabe v6.dc.html`, `Orbo Astrolabe Export.dc.html`) are superseded.

## Composite terminology (agreed 2026-07-18 · field-theory grounding added 2026-08-13)
**WHEREVER THIS FILE SAYS "CHART" IT MEANS A FIELD OF LIGHT, AND THAT IS NOT DECORATION.** Sources of
record: `docs/Field Theory Astrology for Orbo Timespine.md` and, where the two differ,
`docs/Synchronic Conversation -source for the white paper-.md`. A natal chart is the LIGHT OF A
MOMENT, held: my natal field is the light of the moment of my birth, CB's natal field is the light of
the moment of CB's birth, and neither is a diagram of a person. This is the same claim the sun/moon
law already makes about the instrument ("the astrolabe IS the light") carried back into what the
charts themselves are, so the vocabulary is one vocabulary: light, fields of light, and the
operations that put two of them in relation.
**A COMPOSITE IS THEREFORE NOT A CHART DESCRIBING TWO ENTITIES. It is the chart of an EMERGENT FIELD
produced by their interaction** (the transcript's central claim). Three distinct objects, never two:
`A`, `B`, and `C(A, B)`. The parents are the GENERATING fields; the composite is **the third field**,
related to both and reducible to neither, and it is never interchangeable with either parent's own
chart. It has some independent existence: it persists after contact ends, survives the death of a
participant, and evolves through transits and progressions. Its planets, rulers, houses and angles
exert pressure on the native's chart for as long as the field retains meaning.
**THE PARENTS ARE NOT REQUIRED TO BE TWO PEOPLE**, so any code or copy that assumes two natives is
wrong on the theory's own terms. Legal parents include person+person, person+event, person+historical
figure, event+event, person+ritual or working, and potentially person+place, object, institution,
artwork or idea. **This is why "natal composite" was REJECTED as the name** for chart × chart: it
misnames every one of those extensions. The unqualified word is the general one.
**THREE FIELD STATES, and they are not the same question** (the transcript's distinction, and the one
the interface should reflect): **existence** (the two entities entered meaningful relation, so the
field is), **engagement** (it is presently being inhabited, remembered, performed, read), and
**manifestation** (it produces an observable event, work, conflict, institution or state).
**ORBO COMPUTES THE GEOMETRY AND NAMES THE PARENTS; IT NEVER ADJUDICATES WHAT A FIELD MEANS.** The
context of a composite cannot be contained in the app. Tagging a mint "natal × moment" or
"natal × event" records what it was made from, and the meaning still returns to the beholder. Same
discipline as the honesty line the panes already carry: faithfully computed symbolism, never
validated prediction.
- **Composite** — chart × chart (midpoints). The general operation, and THE ROOT OBJECT OF THE THEORY:
  Field Theory Astrology is about composites as emergent fields, and the synchronic composite below is
  that idea extended to a moment as one of the parents. Priority follows from this: the general
  composite is not a peripheral feature of the app.
  **THE NAME IS FIXED AS OF 2026-08-13 (was: two meanings on one name).** `state.synchronic` is you ×
  now; `state.composite` is chart × chart. It used to be `state.composite` for the synchronic one and
  `state.abComposite` for the real composite, in the most load-bearing word in the system. 44 flag
  reads, 30 `abComposite` occurrences and `_toggleComposite`/`toggleComposite` were renamed in one
  pass (snapshot: `archive/Orbo Astrolabe 2026-08-13.dc.html`).
  **STORAGE IS SCHEMA 2, AND THERE IS EXACTLY ONE TRANSLATION POINT.** Schema 2 persists the doctrine
  names. A legacy blob carries no `schema` and means the OPPOSITE by `composite`, so it is translated
  in the constructor (`_svSchema`/`_svSyn`/`_svComp`) and nowhere else: never read `saved.composite`
  directly again. `_persist(patch)` takes STATE names (it merges into state and re-serializes the whole
  blob), so only the write block maps state to wire.
  Left deliberately: `this.comp` (the synchronic bead map) and `this.compAB` (the composite's map),
  plus `_mintCompositeAB`/`_ensureCompositeAB`/`abWith`. Those are distinct names rather than one name
  with two meanings, so they are untidy, not dangerous.
- **Crystallized** — a composite REIFIED as an object Orbo tracks and can seat (the `pp` roster mint is
  the pattern). Crystallizing does NOT bring the field into existence; existence follows from the
  relation, per the three states above. It is the ENGAGEMENT step, and it is the word for that step.
  Not to be confused with `_reteFrozen()`, which asks the narrow question "does this seat DEFINE the
  moment, so nothing scrubs." Two meanings, two words.
- **Composite × composite synastry is legitimate; further compositing is DEFERRED, not forbidden.**
  Reading two crystallized composites against each other is a real reading (the double date: my
  composite with CB, read against my friend's composite with her boyfriend, says something about how
  the two couples interact). Compositing them AGAIN is technically always available, since a midpoint
  is only the halfway point of the shorter arc between two same-body degrees, but it is muddled
  territory and deliberately not built. What it is NOT, and must never be labelled, is "a composite of
  four charts": short-arc midpoints do not compose, so re-pairing the same four charts gives a
  different degree, and the result is an artifact of the pairing order rather than a fact about the
  four.
- **A composite has a FRAME, not a PLACE.** Never synthesize a lat/lon for one: that silently produces
  a DAVISON chart, a different technique with different claims (`_mintPP` already carries this
  refusal, and the same-body law is why it holds). Available from its own ASC and Sun with no place at
  all: whole-sign houses, sect (which side of the ASC/DSC horizon the Sun falls), the lots, dispositors
  and chains, and transits to its degrees. Wanting a real horizon at a NEW time, and so unavailable:
  rising-lord handoffs, electional windows, the ascension template (`prism.templateOf` takes a
  latitude), RAMC epochs, re-casting for another moment.
- **Progressing a composite — OPEN, with the mechanism sketched (2026-08-13).** Day-for-year needs an
  epoch and a composite's `jd` is synthetic (an identity key, not a moment), so secondary progressions
  do not transfer directly. The workable framing is the Sun as the clock: tick the composite's Sun one
  degree, and ask how far everything else moves. That is answerable WITHOUT an epoch, because a
  midpoint of two moving points moves at the MEAN OF ITS PARENTS' SPEEDS, and both parents have real
  epochs and real speeds: `v_C(P) = (v_A(P) + v_B(P)) / 2`, so `Δt = 1° / v_C(Sun)` and every other
  body advances `v_C(P) · Δt`. Note this is NOT solar arc (which moves everything by one equal arc).
  Deferred deliberately; do not build it until the framing is ruled on.
- **Synchronic composite** — natal × now (or a moment): the live plate composite.
- **Synchronic synastry** — (natal × moment) × (natal × moment): two synchronic composites sharing the same sky, read against each other. Same-body bead separations are time-invariant — (natalA − natalB)/2, the sky term cancels — so only flips and cross-body contacts move.
- **Composite frame** — the basis of composite chronology: the synchronic composite taken at the same-ascendant moment (at the natal location) each day, scrubbable through time. Its cASC rulership hands off ~6×/day — read live via rulers.js, never materialized on the spine.

## The TimeSpine (built 2026-07-20 — the July 12 law, finished)
- **`this.spine` (built by `_makeSpine()` in the DC logic) is the sole owner of time**: cursor `jd`, mode (live / playing / gliding-home), JD bounds. `this.jd`/`this.live`/`this.playing`/`this._homeJd`/`this._goLive` are accessors onto it; `_tick` moves the cursor only via `spine.advance(dt, env)`.
- **The spine is the only door to the sky.** `spine.at(jd, lat, lon)` → memoized AstroDNA genome; `spine.posAt(...)` → the instrument-shaped decode ({pos, full, asc}); `spine.probe(jd)` → the engines' bulk-scan positions memo; `spine.ascProbe(jd, lat, lon)`/`spine.bodyProbe(jd, name)` → the light angle- and single-body bulk-scan doors (rising-lord horizon scan et al., where per-sample genomes would stall). Raw `eph.positions()`/`eph.angles()`/`eph.bodyLon()` may be called ONLY inside `_makeSpine` (and inside the standalone engines: timespine.js unspooler, electional, transits). Never reach past it in a reader — that regression reintroduces the bloat.
- **A "reading" = two spine samples + a frame**: `_reading()` → `{ plate, rete, frame, rotLon, solo, count, at }`, memoized on cursor × occupancy × frame. Frame rotation (#1, incl. `natalAsc` — double-tap the ASC cycles horizon → sky → natal ASC), chart-count/solo (#2, idle live sky stays solo; #2b spreads the aspect web +14px when solo), and per-body element (#4, `elName` on spec rows) are fields on the reading/genome, not scattered conditionals.
- NOTE: `timespine.js` (unchanged) is a different thing — the materialized event-table unspooler for the almanac. The cursor-owner spine lives in the DC logic only.

## The sun/moon law (agreed 2026-07-11)
- **The astrolabe is the sun** — it IS the light: geometry, motion, the physical truth of the moment. It stays as it is; new features do not land on the instrument.
- **The pull-up panel is the moon** — it reflects and interprets the light. Every *way of looking* (transit ledger, lunar workup, election windows, synastry grid, etc.) is a moon view. Depth-of-information (plain/studied/scholarly) is a property of moonlight only.
- **The back is the maker's side** — engrave, seat, mint. Configuration, not interpretation.
- Pinning flows moon → memory (♒): you pin from where you're reading.

## The presentation clock — two clocks, one heartbeat (agreed 2026-07-24)
Corollary of the TimeSpine law, for motion. **The spine owns *when*; the presentation clock owns *how it looks getting there*.**
- `spine` remains the sole owner of the cursor `jd`. Presentation springs (`this._springs`, `_spr`/`_sprTo`/`_sprStep`) hold only UI state — a ring's angle, the pane's rise, a shading factor. Spring state never goes on the spine; that would put UI in the sole owner of sky-time.
- **One `dt`, one `_mo`, from the one RAF.** `_tick` computes both at the top (clamped to 0.1s so a backgrounded tab can't leap the cursor or explode a spring) and hands them to BOTH `spine.advance(dt, env)` and `_sprStep(dt, mo)`. No spring may run off its own `performance.now()`, its own RAF, or a CSS `transition` — a second timeline is exactly what made the lunar pane feel stilted.
- Spine advances first; presentation reads after. Dependency is one-way: motion may **read** the spine, never write `jd`. Anything that moves time goes through a spine door.
- **The RAF is the sole writer** of any transform/opacity a spring owns. The template carries a static literal for first paint and no `{{ }}` hole for that property — two writers on one property is what produced the old release-time double-move.
- Fixed-duration CSS transitions are banned on gesture-driven motion: measure release velocity and hand it to the spring (`spr.v = spr.vHint`), or a flick and a nudge animate identically.

## Refs must be exposed in renderVals (learned 2026-07-24)
`ref="{{ fooRef }}"` only binds if `fooRef` is a **key returned from `renderVals()`** — declaring it in the constructor is not enough. `sheetPaneRef` was missing for a long time, and it failed *silently*: `.current` stayed null, so every pane-drag handler bailed on `if (!node) return` (the sheet never followed your finger — it only jumped on release via a style hole) and `_eclipseTranslate()` fell back to its hardcoded 740px parent height on every screen. When a direct-DOM gesture "does nothing," check that its ref is in `renderVals` before debugging the math.

## The solo-web law (agreed 2026-08-06)
A seated chart draws its own aspect web whatever kind of chart it is (natal, solo synchronic
composite, or an A+B composite) — the plate's target list is chosen by what is seated on the
plate, not by whether a composite exists. The web stands down only when something is actually
threading the plate from outside it (a partner seated on the rete, or the ambient sky threads
live), never merely because a derived chart is seated. Same defect class as an invariant living
only in a comment: the old gate encoded "a composite exists" when it meant "a partner is
threading", and those stopped being the same thing the moment a composite could be read alone
(composite mode's default is `rete: 'off'`, solo). cASC joins the web as an ordinary occupant,
riding the rim (`R+1`) while bodies sit at `rN`.

## The return dial (built 2026-08-07 as P6 P4, v0.894, prism CODEC 3)
**THE SYNCHRONIC DAY IS A RETURN AND THE FLIP IS NOT ITS SUBJECT.** The sASC leaves the natal
Ascendant, walks, and comes home to it, because the horizon makes exactly one revolution and
`sASC = midpoint(nASC, horizon)` CONTAINS NO TIME: nASC 0° Aries with the horizon at 0° Taurus is
sASC 15° Aries, at every epoch there has ever been. **So the dial's quantity is the WALK.** With P3's
identity `horizon = nASC + 2σ` and no branch, `σ = norm360(horizon − nASC)/2` is continuous, monotone,
0 to 180 across the day, and read from ONE sample with no previous sample and no unwrapped trace.
**The flip is σ = 90**, the far point of the excursion, the degree opposite the return, and the walk
does not jump there: only the DRAWING jumps, because a 180° walk is painted onto a 360° wheel. A flip
is therefore an ordinary boundary crossing of the same class as the other six (`itineraryOf` already
ruled this), changing sign, house, dispositor and which degrees the Ring measures against, and nothing
about the motion.
**NEVER DETECT A POLE CHANGE BY DIFFERENCING TWO SAMPLES.** `_updateComposite` marked a flip with
`Math.abs(wrap180(lon − prev[key])) > 150` and a leap detector cannot survive a cursor that leaps: the
sASC walks 180° a day, so a scrub exceeds 150° with no crossing in the interval and can step across
the real crossing under 150°, and nothing guarantees two consecutive calls are adjacent in time (a
memory tap, a glide home, an almanac jump). **Measured: at six-hour steps it reports 0 flips across a
day containing 1**, and that stands in `tests/prism.test.html` permanently so the regression cannot
quietly return. The pole is now `framing.phaseOf`, exact from wrapped longitudes.
**TWO POLE CHANGES A CYCLE AND ONLY ONE IS A FLIP.** Parity also turns over at the return, where the
point passes through the natal degree and is continuous, and doctrine says that is not a flip. Under
bidirectional scrubbing DIRECTION cannot discriminate them (a backward scrub crosses the opposition
the other way). The WALK can, and it is a reading rather than a threshold in disguise: **the flip is
at an END of the arc, the return at its CENTRE**, 90° apart, measured 89.9998° and 0.0212°. Hence
`compFlip` and `compReturn` as separate facts, beside `compPole`.
**`prism.walkOf` / `stopAtWalk` / `dialOf`.** `walkOf` is pure (no time, no latitude, no ephemeris) and
resolves its degree through `framing.refract`: the closed form `c + σ − 180·pole` is algebraically
identical and deliberately NOT written, because a second expression for a refracted degree is a second
refraction path however correct it is. `dialOf` reports `drift`, the signed disagreement between
degrees walked and time elapsed, which is §1.1's claim as a number at last (up to **9.21% of the day**
on a template of **2225.7×** unevenness). **CODEC 2 → 3:** every stop now carries `sigma`/`sigmaEnd`,
computed inside `templateOf` since P3 and thrown away — the `frameOffset` lesson for the third time.
**No new drawing, no new geometry, no new widget:** §14.1 stands, the dial is the wheel in the
`natalAsc` frame, which already existed.
Green after the pass: **938 checks, 0 failures** (prism's own page 85, up from 62; everything else
unmoved).

## The ascension template (built 2026-08-07 as P6 P3, prism CODEC 2)
**The itinerary is uniform in DEGREES and the day is not uniform in TIME, and the disagreement between
them is the reading, not a rendering defect.** P2 gave the walk; P3 gives the clock it walks against.
**ONE IDENTITY CARRIES IT AND IT HAS NO FLIP CASE:** with σ the sASC's walk from the anchor, the horizon
is at `nASC + 2σ` for the whole day (leg one has the sASC at `c + σ`, leg two at `c + σ − 180`, whose
horizon is the same degree), so **the sASC's 180° walk IS the horizon's single revolution and the flip is
simply σ = 90.** Never add a branch or a parity bit there; same shape of result as 7b's phase gate being
unnecessary rather than replaced.
**`prism.risingRamc` IS THE EXACT INVERSE OF `ephem.angles`,** derived algebraically from that one
function and not from a textbook oblique-ascension variant, so the instrument and the template cannot
disagree about what rises when (measured: 1.1e-13° at 3600 samples). `null` is a real answer: above the
polar circle some degrees never rise, and `templateOf` then returns `{circumpolar: true, reason}` with no
stops rather than inventing an arrival time. Below |φ| = 90 − ε the map is a bijection.
**A DURATION HAS NO EPOCH, which is why storing one is not storing an event time.** The template holds
durations and rotation angles (RAMC), never a jd; `ramcJdNear` supplies the epoch at read time from gmst
alone (a linear guess plus three Newton steps, no ephemeris, no scan). **Latitude only, deliberately** —
a duration is a fact of a latitude and only the epoch wants a longitude, which is §8's locality result
from the other side. A chart with no place gets `template: null` with the reason recorded: a pp mint is
given no invented horizon.
**The engrave-cut template's error IS the obliquity drift, and that is the price of a table fixed for a
life:** 0.040 ms against a live `angles()` root-find when cut at the reading's ε, 1.547 s when read 41
years off its engrave epoch, 3.201 s worst stretch change over 80 years. So it never needs recutting, and
§1.1's "constant to within seconds" is measured rather than waved at.
**§1.2 holds against live anchors and the miss is PREDICTED rather than tolerated:** 800 real
`findAscAnchor` anchors are one sidereal day apart to 0.0001 s, the regression is 3.9318 min/day, and the
anchor's civil time wraps the 24h clock once in exactly 366 anchors. The return is not exact at an integer
anchor (366.2422 anchors / 365.2422 days), so it lands 0.9521 min short — matching the offset arithmetic
to 0.9522 min. The quarter it misses by is the quarter that makes a leap year.
Green after the pass: **915 checks, 0 failures** (prism's own page 62; everything else unmoved).

## The prism's tables (built 2026-08-06 as P6 P2, v0.893)
**The synchronic layer IS a whole other timespine, calculated once and displayed** — not a figure of
speech. §1: `sASC = midpoint(nASC, rising degree)` CONTAINS NO TIME, so the map from a rising degree to
a synchronic Ascendant is fixed at engrave and a synchronic day is a fixed template plus one number.
`prism.js` is that template. `_prismTables()` in the DC, memoized on `prismKey`, fused.
**THE SPLIT: the prism's ARITHMETIC stays arithmetic, the prism's STRUCTURE becomes tables.** A
position is one wrap and one halving through `framing.refract` — cheaper to compute than to look up,
and a 360-row refraction table per occupant is REFUSED (it would quantize to whole degrees against the
codec law). What is stored is the structure a live cursor is read THROUGH: arcs, boundaries, reachable
sets, the itinerary, the families. This is why "the synchronic timespine is calculable at engrave" and
"the clock is never a table on the spine" are both true. No event times, ever. Nothing here is fused
to the spine.
**A FAMILY IS TWO NATIVES, NEVER TWO BODIES — the error the pass caught.** Same body, two natives:
`sMars_A − sMars_B = (natalA − natalB)/2`, the sky term is the SAME term on both sides and cancels
exactly, so the separation is fixed forever. Two bodies, one native: `sMoon − sSun` retains
`(skyMoon − skySun)/2`, a difference of two DIFFERENT bodies, which does not cancel. The first build
enumerated intra-chart pairs and produced a table that looked right and was wrong. Measured:
same-body holds to **0.000000000°** across 14 bodies × 400 days; the intra-chart version drifts
**50.49°**. So families live on `buildPair(A, B)` and `build(natal)` has NO family table — an absence
that is correct rather than missing. Same defect class as the P1 shape test: a plausible-looking
result is worse than an error.
**A SLIVER IS STRUCTURE, NOT A GAP.** When a natal Ascendant sits near a cusp (the fixture's is 0.029°
from Libra/Scorpio) two of the seven stretches degenerate to slivers the sASC crosses in about
fourteen seconds. A minute-resolution sample legitimately misses them, so the sky check is split into
SOUNDNESS (every house the real sky visits is in the template) and COMPLETENESS (every stretch wide
enough to sample is visited), with the slivers asserted to exist. Never "fix" a sliver away.
**The self-test earns its place:** `frameOffset` was computed per stop and never put on the record, so
the day reported ONE offset instead of seven — silently. The load-time check now refuses a stop that
does not carry its offset. A value computed and not recorded is invisible to every reader.
**Still deferred, deliberately:** lot arcs (§14.2 — sect is the synchronic chart's own, from sSun
against sASC, so a diurnal native can have a nocturnal synchronic chart and Fortune/Spirit exchange
formulae; there is no single stable arc to store). Lots are computed LIVE from refracted Ascendant,
Moon and Sun, which is exact under one sect. The deferral is recorded UNCONDITIONALLY on every build,
not only when lots were requested — a record that appears sometimes is one nobody can rely on.
Green after the pass: **884 checks, 0 failures** (prism 55 · loom-algebra 49 · loom 25 · the rest
unmoved).

## The refraction law (agreed 2026-08-06, built v0.892 as P6 P1)
Plan of record: `specs/Phase 6 - The Synchronic Prism.md`.
**`framing.refract(natalLon, momentLon)` IS THE ONE PLACE IN ORBO THAT REFRACTS.** A door in the sense
`spine.at` is a door, and meant to be GREPPABLE: if two places refract they will disagree. `loom.js`'s
`lonAt` composes through it, so the scanner and the instrument cannot drift apart on what a synchronic
degree is. Never add a second refraction path, and never a refraction TABLE (the refraction is one wrap
and one halving; a table would quantize to whole degrees against the codec law).
**`midpoint` is NOT the door and must not be routed through it.** A refraction is natal × MOMENT; a
composite is chart × chart. `_mintCompositeAB`, `_ensureCompositeAB` and `_mintPP` stay on `midpoint`
deliberately — folding them into `refract` would destroy the greppability the door exists for. Same
arithmetic, different act.
**The prism is an OCCUPANT, not an insertion point.** It needed no new seam because a wheel's occupant
slot already existed: the plate has carried it since ♓ (that is what `s.composite` IS, you × now), and
the rete now takes `'prism'` as a sentinel beside `'sky'` and `'off'`. `_prismChart()` returns the
`_reteChart` shape, so `_drawLitTrack`, the cross-track web, `_sheetDataRete` and the synastry grid all
take it without knowing what it is. The instrument's own drawing is UNTOUCHED — no new hand, no new
geometry, no second drawing routine. That was the phase's proof obligation and it is the standard for
P2 onward.
**OCCUPANCY IS `_reteSeated()`, NEVER AN OBJECT-SHAPE TEST** (fixed on review, v0.892). The pane's gates
asked `typeof r === 'object' && r.jd` as a stand-in for "something is seated", so a string sentinel fell
straight through and the instrument drew a prism while `_sheetDataRete`, `_sheetDataSynastry` and
`_sheetDataCompSyn` all reported an empty seat — the exact opposite of the promise that the readers do
not change and do not know the light is refracted. Shape is not occupancy. Three companions carry the
rest: `_reteSeatName()` and `_reteSeatJd()` (the prism's moment is the LIVE CURSOR, a pp mint has none).
**`_reteSeated()` IS NOT `_reteFrozen()`, and the divergence is the point.** Frozen asks "does this seat
DEFINE the moment" (paper: nothing scrubs). Seated asks "is anything there at all". The prism is seated
and NOT frozen, so widening `_reteFrozen` would freeze the one occupant that must stay live. Two
questions, two predicates; never collapse them.
**AND OCCUPANCY IS NOT OTHERNESS — a THIRD predicate, `_reteIsOther()`.** The two-native readers build
(natal × moment) × (natal × moment), so handing them the prism as "them" applies the synchronic operator
a SECOND time to an already-refracted chart, `midpoint(natal, midpoint(natal, sky))`, which is not a
doctrine object. **That failure is worse than the empty seat it replaced, because it returns plausible
rows instead of an error** — 21 of them, measured, before the gate was split. So: `_sheetDataRete` (one
chart, shows the prism's own positions) takes `_reteSeated()`; the synastry grid and Crossing take
`_reteIsOther()` and refuse the prism with `reason: 'pair'` and copy that says why. **The prism is ME
refracted; it is never a partner.** The wheel's cross-track web is exempt and correctly does take it: it
asks the Ring for the plain relation between two sets of degrees, applying no second operator. Three
questions of a seat, three predicates — the general lesson being that a shape test (`typeof r ===
'object' && r.jd`) standing in for a semantic question is the same defect class as an invariant that
lives only in a comment.
**The prism is the one occupant that MOVES,** so it is `frozen: false` (it washes pale through a scrub
the way the sky does, because it IS the sky refracted) **but writes NO scrub hit** — a sharper reason
than the frozen seat's: `this.held` resolves longitudes through `this.pos`, the cursor's own sky, and a
refracted degree is not one of those, so a grab would scrub against the wrong map. The rim ASC badge is
exempt: that is the plate's horizon, never the prism's.
**Prism-on-rete and composite-on-plate are mutually exclusive.** The same chart on both wheels would
thread every bead to itself at 0°.
**The lots refract LIVE, all eight.** A lot is an affine combination whose coefficients sum to 1
(`asc + moon − sun`), so refraction COMMUTES with lot formation and there is no second definition to
pick. Live rather than stored because a sect disagreement between the natal and the synchronic chart
breaks exactly that commutation (§14.2), and a stored arc under the wrong sect rule would invalidate at
doctrine-key level. Do not store a lot arc until the sect question is answered.
**A frame is reached by touching the thing that defines it.** Double-tapping the sASC bead enters
`frame: 'natalAsc'` — NOT a fourth stop on the ASC's cycle: the natal sASC IS the natal ASC (at birth
the horizon equals nASC, so the midpoint is nASC), so the frame already existed and this is a new entry
point to it. Consequence worth keeping: in that frame the sASC is confined to the half of the wheel
spanning the 10th through the 4th, so §7's dial is the wheel in a frame that already exists.
**Two house readings, never in competition** (§13.1): the natal house (where in MY LIFE) and the
synchronic house (where in THE MOMENT'S OWN CHART, from the sASC's sign, changing 7× a day). What the
housing law forbids is a BARE house number from a moving Ascendant silently replacing the natal one, so
the discipline is that a house is always QUALIFIED, never unqualified, anywhere in the app.
Green after the pass: loom-algebra **48** (was 43; the five new ones pin the door's contract) · loom 25.

## The sky-eclipse engine (agreed 2026-08-11)
**The astronomy is already built; this is a reading design, not an engineering one.** `mundane.js`
already owns eclipse geometry and classification (`eclipseAt`/`eclipsesIn`) — canon-verified
against the published record, packed into the embryo (1700–2100). Nothing here re-derives that; it
only reads it, the same discipline as every other embryo-backed stream (progression ingresses, ZR
starts). **No new live-scan door.** Per `mundane.js`'s own law ("computed here… and never scanned
at runtime"), eclipses exist ONLY within the embryo's span — a window outside it reports no data
rather than faking a live classification, the same honesty as the no-invented-horizon law
elsewhere. This design touches zero lines of `mundane.js`; it is entirely new DC-side readers over
data that already exists.

**The naming collision is real.** `state.eclipse` / `eclipseOn` / the pane's whole reading-tier
vocabulary means "the moon-sheet rises over the sun-wheel" — nothing astronomical, and it predates
this engine by weeks. Every new identifier for the REAL phenomenon is prefixed **`skyEclipse`**
(matching the "sky itself" = native-independent vocabulary the mundane floor's own labels already
use: "the sky itself · …") — never a bare `eclipse` token in new code. `mundane.js`'s internal
`kind: 'eclipse'` / `ECL_TYPES` stay exactly as they are; that engine is already tested against
that vocabulary and is not renamed.

**Prerequisite, not new work: `_loomFloor`'s row mapper has no `kind === 'eclipse'` branch.** It
falls through to the generic contact shape today and mislabels every eclipse row silently. Fix
this regardless of anything else below — it is a defect in already-shipped code, not a feature.

**Three surfaces, one door, no bespoke second computation:**
1. **Mundane floor / almanac.** The fixed branch labels from `e.of`/`e.type`/`e.mag` ("Solar
   eclipse · total · mag 1.02"), own color, own `.ics` category. Own ☑ Gears · Mundane chip
   (`skyEclipse`), independent of `syzygy` — muting ordinary lunations must not also mute eclipses.
   On by default. **Unconditional**: this chip does NOT gate through the ♍ Aspects orb slider —
   an eclipse is closer in kind to an ingress or a station (a fact about the sky's own structure)
   than to a scored aspect, and is never filtered by orb width.
2. **Lunar pane.** One new fact row, "next sky eclipse," same shape and position as the existing
   "next ingress" row — filtered from the same embryo rows forward of `this.jd` (a table read,
   no new door, no live scan).
3. **Natal proximity — CLASSICAL marks, FLAT 5° orb, via the Ring's own vocabulary, never a
   bespoke number invented per-feature.** An eclipse is a fixed-degree, fixed-moment fact
   (`e.lon`, `e.jd`) — "near a natal point" is exactly the shape `_transitsToNatal`/the transit
   ledger already solve, so this reads through the Ring's conjunction and opposition marks only
   (classical eclipse technique's own scope — no square/trine "activation" reading here). The
   orb is a FLAT 5°, deliberately NOT the ♍ Aspects slider: an eclipse's window of influence is a
   fact about the eclipse, not a property the user's general orb preference should widen or
   narrow. New reader `_skyEclipseNatalRows(a, b)`: for each embryo eclipse row in the window,
   test `.lon` against every `_natalTargets()` point at 0°/180° within 5°; a hit carries the
   natal point, the exact orb, its house (`_houseOf`, whole-sign off the natal ASC — same law as
   every other natal-frame reading), and the eclipse's own type/magnitude. Surfaces as its own
   almanac stream ("eclipses near your chart," gated on a natal chart existing, same pattern as
   `progasp`/`cross`) — NOT folded into the native-independent mundane floor, NOT folded into the
   transit ledger (whose "next exact hit" shape doesn't fit an already-dated table; this is closer
   in spirit to `_almProgAspects`, a flatten-the-table reader). Ships as geometry only — no
   interpretive quote (the content gap already flagged: "Eclipses in the Decanates" is mundane/
   political doctrine, not personal delineation) — with a `quote: null` slot left open so a future
   pack can fill it without a reshape.

## The seating law (agreed 2026-08-06, built v0.890 as P6 P0b)
**Whatever is seated on a wheel rides that wheel's track. No third ring, ever.** The plate's occupant
draws at `rN` (P0's `plateT`), the rete's occupant draws at `rBody` whatever it is: the sky, a person,
an event, a composite. `rBody` was only ever "the sky's track" because the sky is the rete's usual
occupant, and reading it as the sky's own is what made a seated B invent a third band at `rN - 19`.
That third ring WAS the crowding: two charts sharing the plate's neighbourhood, colliding angle chips,
the outer track empty. Occupancy per track is halved by construction, which is most of the fix before
any de-collision logic. The frozen-seat `rAsp` push-in went with it.
**The frame is always the plate's.** One horizon line, one meridian, one house grid, from the plate's
angles alone. The rete's As/MC/Ds/IC (or cASC) are OCCUPANTS on the rete's track, ordinary beads like
any body there. Two `As` chips never collide because they sit on different tracks, which is the fix:
geometry, not de-confliction.
**Geometry carries chart membership, line style carries nothing.** Both endpoints on one track is a
self-aspect; a chord spanning the two tracks is a cross-aspect, and it is unmistakable as such without
help. So the inter-chart web is solid and coloured by HARMONY FAMILY (`_webColor`) like every other web
line, never dotted or hue-tagged by whose chart it is. Chart identity lives in the MATERIAL of the
track (below). (The ambient sky threads and the
held-hand family keep their dash: they are whisper-alpha highlight families and P0b's ruling pinned the
natal-solo render byte-identical.)
**MATERIAL FOLLOWS THE WHEEL, NOT THE OCCUPANT** (ruled 2026-08-06, built v0.891). The plate is
ENGRAVED (incised, matte, beneath) and the rete is LIT (element-coloured, glowing, above), whatever is
seated on each: the sky, a person, an event, a composite, a prism. A distinction in KIND, never in
quality. The first draft of this law said "the sky is light, a seated chart is stone", and stone came out
as flat one-ink 11px glyphs with no glow, no period sizing, no de-collision and no moon face, so a seated
chart read as a debug overlay beside the instrument. The cause was one ternary, `skyOn ? drawOrder : []`,
which reserved the whole lit treatment for the sky and left every other occupant to a hand-rolled second
drawing routine over the same degrees. **There is one `_drawLitTrack(ctx, occ)` now**, taking an occupant
(`pos`, `asc`, `names`, radius, `frozen`); `skyOn` no longer selects a treatment anywhere; the flat
routine and its violet recessed band are deleted. Two lit tracks are impossible by construction, because
the rete holds exactly one occupant. Corollaries: a seated chart draws its own MOON PHASE (the Sun read
is its own) and its own angles from `_reteChart`'s `full` (angles are place-dependent, so they must come
from its place, while `pos` stays the bodies-only keyset its other readers were written against); and a
seated chart is permanently `atRest`, so it keeps its element colours through a scrub instead of washing
pale the way the live sky does.
**A frozen occupant writes NO hit map, and that is correct.** `_down` already nulls a hit when
`_reteFrozen()` ("frozen reading — nothing scrubs"): a seat DEFINES the moment, so dragging a seated
person's Mars to move time is meaningless. It also avoids a real hazard, since `this.held` resolves
longitudes through `this.pos` (the cursor's sky) and a seated chart's are its own. Tapping the rete's
occupant to OPEN its reading is a separate, genuine gap: the plate has `_openNatalSheet`, the rete has no
equivalent, and building one is a new view rather than a repair.

## The pane's three verbs · open is not etch (agreed 2026-07-29)
**The Lunar Pane is a dock.** Three verbs, one meaning each:
- **open** — show a lens on the pane NOW. Transient, like launching from a dock. The tabula's field
  icon, `_openTabLens`. It must never write `paneLenses`; `_openAlmanac` and `_zrToAlmanac` used to
  force-etch on the way in, which is why ♐ was the one lens you could not look at without keeping it.
- **etch** — KEEP a lens on the pane. Persisted (`paneLenses`), `_togglePaneLens`, the rune. Etched
  chips carry a **dot** on the pane's crown; a merely RUNNING lens (open, never etched) appears there
  too, dotless, and leaves when you leave it, so the dock always shows what you are actually reading.
- **fuse** — build a stream into the timespine's event table (`_toggleFuse`). A different act entirely;
  it belongs to the spine, not the pane, and must not be called pinning or etching.
**Un-etching happens at the dock, not through the rim:** hold an etched chip on the pane's crown for
520ms (`_paneDown`'s `_chipHold`). `_paneUp` swallows the lift so the hold does not also navigate.
Never say "pin" for any of these.

## Generated files
- `*.browser.js` (ephem, transits, framing, cities, ring, mater) are auto-generated browser-global builds of their `.js` counterparts. Edit the `.js` source of truth, then regenerate the `.browser.js` — never hand-edit the browser build.
- **EXCEPTION, recorded 2026-08-06: `framing.browser.js`, `loom.browser.js` and `prism.browser.js` have no generator in this project and are maintained BY HAND** as literal mirrors of their sources (the `export` keywords dropped, the imports turned into one `window.__ORBO_*` destructure, the whole thing wrapped in the `boot()` retry IIFE). So a change to `framing.js`/`loom.js`/`prism.js` must be mirrored into them in the same turn, and the mirror must be verified by running the suites (`tests/loom-algebra.test.html`, `tests/loom.test.html`, `tests/prism.test.html`) rather than assumed. If a generator is ever written, delete this exception.
- `vendor/three/three.global.js` is a generated classic-script build assigning `window.THREE`, flattened from the OFFICIAL minified pair `vendor/three/three.core.min.js` + `three.module.min.js` (three r184). Regenerate it if three is upgraded; never hand-edit. 745 KB — do not go back to the unminified sources (2.07 MB); `three.core.js`/`three.module.js` are kept only so archived snapshots still open.
  - Gotcha when regenerating: an `import { Outer as local }` specifier flattens to `{ Outer: local }`, an `export { local as Public }` to `{ "Public": local }` — the two statements alias in OPPOSITE directions. The unminified sources hide this (they alias nothing); the minified ones alias everything, and getting it backwards yields a `ReferenceError` deep inside three. Verify with `tests/three-global-min.test.html` (checks every symbol Orbo uses + does a live WebGL render) before shipping.

## The standalone-export law (learned 2026-07-24)
**The bundler only follows HTML `src=`/`href=` attributes.** Anything referenced from inside JS — an ES `import` specifier (even via importmap), a `fetch()`, a texture path string — is invisible to it and silently ships missing, so the exported file degrades in ways the served preview never shows (relative paths still resolve off the dev server). Rules:
- No `<script type="module">`, no importmap. Every dependency is a plain `<script src>`.
- Every asset a script needs must be declared in the HTML too — e.g. Orbo's surface map is a hidden `<img id="orbo-sphere-tex">` and `orbo-sphere.js` reads its `currentSrc`.
- After any dependency change, rebuild the standalone and confirm every `script[src]` in it is a `blob:` URL (all inlined) before shipping.
- **Inlining is not ordering (learned 2026-07-24).** Bundled scripts become `blob:` URLs and strict document order is NOT preserved — the biggest file can lose the race. Never capture a cross-script global at evaluation time (`var THREE = window.THREE` at module top); read it lazily at use time, and gate on the *dependency's own* global (`window.THREE`), never on a wrapper that registers unconditionally (`window.__ORBO_SPHERE`).

## The instrument-survives-everything law (agreed 2026-07-24)
Corollary of the sun/moon law, for code: **nothing on the instrument may depend on a character, panel, or renderer mounting cleanly.**
- In `componentDidMount`, the astrolabe's own wiring (canvas sizing, pointer listeners, RAF loop) comes FIRST and unconditionally. Optional mounts (`_orboMount`) come after and are try/caught — the sphere failing costs Orbo, never the plate.
- Per-layer fuses in the RAF loop: `_fuse(layer, fn)` logs the first failure per layer and keeps the loop alive. Wrap every optional layer; a broken engraving must not blank the wheel.
- `componentWillUnmount` releases EVERYTHING: all timers (incl. `_onbPoll`/`_ptTimer` intervals), the ResizeObserver, the canvas pointer listeners, and `_orboHandle.dispose()`. A leaked WebGL context per remount silently degrades a whole session.

## The tabula spread — the back's one layout (built 2026-07-28/29, v0.870)
- **The back is concentric label rings.** Outer ring = the twelve tabulae. **Socket ring** (r 26.4–32.9,
  `_skD`/`_skTp`) = twelve sockets on the same 30° spokes. Filled ones are centred on the top; the rest
  are visibly EMPTY, and **inert and unmarked** (the recess alone says a seat is open; the old centre
  dots said it twelve times over). Sockets are tapped by their **wedge**, never by the curved word.
- **The bottom socket is always AEGIS**, the way back to the face. Never an item, never lit gold: a warm
  recess. It is the app's own word for the front (`docs/Orbo Glossary.md`), it keeps the ring nominal
  (every socket names a destination), and it retired the floating ⟲ front button, which the ♊ and ♍
  chip rings used to displace entirely. Not "Return": **Synchronic Return** is a term in this
  instrument and the ring is the one place the vocabulary has to be exact.
- **A tabula joins the spread by returning `{kind, items}` from `_tabItems(panel)`. THREE KINDS:**
  - `item` — the socket picks WHAT YOU READ; the field is a glossary entry with two verbs.
    **♏ Timing · ♓ Composite · ♐ Almanac** (its six streams; the verbs are tabula-level).
  - `mode` — the socket picks WHAT THE FIELD CONFIGURES; no verbs, one control at a time.
    **♊ Bodies** (Planets · Objects · Points) · **♍ Aspects** (Major · Minor · Orb) · **♑ Gears**
    (Speed · Rim · Snap · Feel).
  - `sort` — the socket picks HOW A ROSTER IS CUT; the tabula keeps its own body, because a socket
    label holds about 8 characters and cannot hold a person's name. **♎ Ledger** (Add · Search · All ·
    Pairs · People · Events · Horary) · **♒ Archive** (Log · All · the journal's activity kinds).
  Unregistered, deliberately: the forms (♈ ♉), ♌ Appearance, ♋ Moon. `_tabVals(s)` turns the registry
  into every `tab*` key the one shared field template reads.
- **Ring labels cap at ~8 characters,** not 11. Past that a curved label overruns its 30° socket and
  collides with its neighbours (this is why ♐'s streams read Chapters · Crossing, not Releasing ·
  Synchronic, and ♎'s composites read Pairs).
- **Socket slots must land on INTEGERS** (fixed v0.878). `_tabVals`'s `slot()` centres the filled
  sockets on the top, and the slot loop tests integer `j` only, so an EVEN item count used to produce
  half-integer slots that never matched and the entire ring came back empty. ♑ Gears (4 items) was
  dark from the day it shipped and ♐ Almanac joined it the moment it reached 6 streams. `slot` now
  floors, so an even count seats one socket right of top. Check the ring after changing any item count.
- **The field is set as a GLOSSARY ENTRY:** the term in gold incised caps, its definition beneath in
  stone (`#b6aed2`, shadow down-light plus a hair of light above). It is what the field is, so it is
  what it looks like, and it gives the block the title a loose paragraph never had. No header row, no ×
  (the rim names the plate; re-tapping it closes). Fixed icon on top = *open*; fixed rune below =
  *etch*; only the entry between them scrolls, with `justify-content: safe center` so a long one
  scrolls from its top instead of being clipped at both ends.
- **Well geometry.** An item field is 152px and its corners run UNDER the socket ring, which is fine
  because its content is centred and short. A field that sits inside a CHIP ring (♊, and ♍ on a
  family) narrows to 108px with a short caption. A `sort` tabula fills its well, so it is inset to a
  132px column with 26px top and bottom padding, whose diagonal clears the label radius.
- **Register: the back is impersonal.** Third person, declarative, definition-shaped, in the voice of
  `uploads/Orbo Field Theory Glossary.md` — which is the authority for what things ARE and the source
  of the depth ladder's top rung. The first-person spoken voice belongs to the pull-up. Not "my chart
  and the sky dissolved into one" but "the chart formed by midpointing a natal chart with a moment".
- **Orbo never uses the em-dash.** Not in the UI, not in a write-up, not in chat. Restructure the
  sentence, or use the middot Orbo already uses on the rim (`Here·now`).
- **Type law: the back is engraved (Georgia), the pull-up is moonlight (the sans).**
- **Engraving recipe:** `feTurbulence` grain over the plate at 0.06, overlay-blended · every hairline is
  a PAIR (shadow 0.3px down-light, lit stroke on top) · incised type carries `text-shadow 0 1px 0
  rgba(0,0,0,0.6)` · an occupied socket is a shallow recess, the selected one is the groove filled with
  gold. One light direction (from above), shared with the pane's limb light.
- **Doctrine is reached from the lineage label**, L3 only, under a hairline in the field. No doctrine
  section anywhere.
- **When a tabula is open, every other slot dims** — wash, arced title and sign glyph together. Nothing
  is hidden; you can still tap straight across.
- `window.__orbo` is set in `componentDidMount` (try/caught): the back is only reachable by a rim
  double-tap, which synthetic pointer events don't reproduce, so this is the review path —
  `__orbo.setState({flipped:true, panel:'releasing', tabSel:'zr', depth:'scholarly'})`. For a mode or
  sort tabula pass its own key too: `{panel:'transport', gearSel:'feel'}`, `{panel:'people', ledSel:'all'}`,
  `{panel:'memory', arcSel:'all'}`, `{panel:'aspects', virgoSub:'orb'}`, `{panel:'planets', geminiSub:'points'}`..

## Synchronic doctrine (settled 2026-07-29, in conversation)
Sources of record: `docs/Field Theory Astrology for Orbo Timespine.md` (the white paper),
`docs/Synchronic Conversation -source for the white paper-.md` (the transcript it was distilled from,
which is the authority wherever the two differ), `docs/Field Theory Astrology 2.0 - Levels.md`.

**Spelling: synchronic, with the r.** Where Master Glossary 2.0 writes "synchonic", the glossary is wrong.

**Four objects, distinguished by WHAT SUPPLIES THE MOMENT.** This is the distinction that keeps the
frame-protocol argument from spreading into places it does not belong:
- **Synchronic composite** `C(A, M_t)` · one native, one moment. The live plate.
- **Composite chronology** · a PROTOCOL supplies the moment: each day, the instant the natal ASC
  DEGREE is on the horizon at the natal location (`findAscAnchor`). Solo, regular, unattended. The life
  as film. Degree, not sign: a sign would give a window instead of an instant.
- **Synchronic synastry** · a LIFE EVENT supplies the moment. The text at 2:14, the date Friday at 7.
  Nothing is sampled and no protocol is involved: the timestamp is handed to you by life.
- **Crossing** (the chronology of the pair, formerly "intersections", already `_almCross` + the ♐
  Crossing stream + `_exportCrossICS`) · the ordered events between two synchronic composites.

**Two frame protocols, not one, and only one of them is a protocol.** A solo frame is a CHART: it has a
horizon, so it needs a place AND a moment, which is why it needs the anchor. A pair contact is an
ANGLE: it needs only time. So Crossing has no frame protocol and never needed one, and the
same-ascendant anchor is a SOLO protocol, definitionally unshareable (two natives cannot both be on
their own anchor at one instant).

**The synastry law: one instant, two horizons.** `(natal A × moment at A's birthplace) × (natal B ×
moment at B's birthplace)`, both at the SAME instant. Body longitudes are geocentric and depend only on
time, so `T_A = T_B` and the shared-sky cancellation holds. Only the ANGLES differ by place. The engine
already encodes this split: `positions(jd)` takes time alone, `angles(jd, lat, lon)` takes time and place.
`scoreMomentSynastry(natA, natB, jd, posAt, ...)` is already correct (one `posAt(jd)`, both natals).
- **Keep the synchronic layer geocentric by law.** A topocentric toggle would break the cancellation for
  the Moon through parallax, and the Moon is the body the synastry spine cares most about.
- There is a third, asymmetric reading available on purpose: both natives on A's anchor, "how are you
  and I each fielding MY hour". It does not commute. Do not build it by accident.

**Every event has a place.** Store it always, defaulting device geolocation → my natal place → the other
person's natal place (received text vs sent text is a real distinction). What place changes is ANGLES,
never bodies, so a stored place also gives the moment's own uncomposited chart, which is the horary
reading. Consequence worth stating in the UI: **the flip calendar is place-invariant**, a function of two
birth charts and time alone, so both people export byte-identical events.

**The flip: the transcript is right and the white paper's formula is WRONG.** The paper gives
`φ = ⌊(T̃−N)/360⌋ mod 2` with `disp = axis + 180φ`, which jumps where nothing happens and requires an
unwrapped trace from birth. The truth is simpler and needs no unwrapping:
- The synchronic placement of body P lives permanently in the 180° arc centred on natal P. That arc is
  already `arcFor(natalLon)` in framing.js (centre = natal, ±90).
- `phase = norm360(T − N) >= 180 ? 1 : 0`, from WRAPPED longitudes. Two lines, no trace, no unwrap.
- **A flip is transiting P opposing natal P**, and nothing else. It is an ordinary natal transit aspect
  that the transits engine already computes exactly. Flips are therefore cheap, not a research project.
- Retrograde stutter is real: a body stationing near its own opposition can flip, unflip and flip again.
  Honour it, do not smooth it.
- Unwrapped longitude is still wanted, but only for cycle INDEX ("the 14th Mars phase of a life") and
  continuous velocity. It is not on the critical path.

**The axis is storage, never a second placement.** The transcript RETRACTS the counter-dispositor: the
two ends of the arc are the limits of the object's permitted movement, not two co-present placements with
a ruler held in reserve. One dispositor at a time. Never build a counter-dispositor field.

**A flip is a change of government, and it wants a window.** Sign, house and dispositor invert together
(for a Scorpio rising, Gemini↔Sagittarius is 8th↔2nd is Mercury↔Jupiter). At exact opposition neither
pole has a privileged claim, so a flip is approach · hinge · departure, an interval with a centre, not a
timestamp. And it is a reformulation, not a new subject: the concern reached the end of one phase and is
being lived from a newly oriented position.

**Same-body vs cross-body must look different in Orbo.** Same-body separation is fixed at half the natal
separation, so the family is `{δ/2, 180−δ/2}` forever and only the MODE alternates, selected by
`φ_A ⊕ φ_B`. The square is self-complementary (`{90,90}`): suppress the mode display, a flip changes
which side, not the class. Cross-body contacts genuinely form, perfect and separate. One list for both
kinds is wrong. Orbs HALVE on the synchronic layer, so natal orb defaults are too wide here.

**Two named chains, not one graph** (all dispositors are synchronic, never natal or transiting):
- **agency chain** · the natal ASC ruler. **light chain** · the sect light.
- **Bearer** = immediate dispositor. **Keeper** = terminal ruler or the loop it closes into. A two-planet
  loop is **mutual reception**, never "closed circuit"; three or more is a **dispositor loop**.
- The charged event is **Keeper of Agency == Keeper of Light**: action and perception governed from one
  centre.
- **Change of dispositor is not change in dispositor condition.** A placement can undergo major
  development WITHOUT MOVING, because its governor moved. The event engine therefore cannot be a
  per-body scan: each placement watches its current governor's state.
- Cross the two edge types. Answering to a planet while squaring it means the concern must route through
  a function it is currently fighting. Traditional rulership is the backbone; moderns are co-governors,
  never chain branches.

**Houses: natal whole-sign, anchored to the natal ASC sign, always.** Never re-house a synchronic
placement from a derived ASC. In synastry the zodiacal aspect is shared but the topic is native-specific,
so alignment does not require the same topic.

**No Davison, no invented horizon** (ruled 2026-07-29). A derived chart is never given a geodetic
midpoint place, or any other place neither native stood under: that weakens the geocentric grounding of
the instrument. A composite has a Sun and a horizon, and those two give sect, which gives Fortune and
every other lot (`lots(asc, isDay, pos)` already takes no place). Houses come from the composite's own
ASC sign. So a relationship needs no place, and the one thing a place would buy, a synchronic cASC, is
already forbidden by the natal-whole-sign law. What a mint treated as ONE derived native cannot have is a
**composite chronology**: the daily anchor is definitionally place-bound, so Chronicle stays dark on a pp
mint rather than being faked.

**A pair has TWO places, and its film comes from holding both natives distinct** rather than deriving a
third (which is also truer to the field theory: the natives never disappear under the composite). The
pair's film is the solo film's exact parallel, composite A on the plate and composite B on the rete, and
the hardware already draws it. Driven by a **shared cursor, no anchor**: one instant, both natives,
continuous, cancellation intact, and the wandering cASCs are cosmetic because housing off a derived ASC
is forbidden anyway. A's-anchor-for-both is a named asymmetric alternate ("my life, with you in it").
Each-native-on-its-own-anchor is FORBIDDEN: the frames are hours apart, never simultaneous, and same-body
separations wobble by up to ~6.6° on the Moon from the anchors disagreeing.

**Retrograde flip stutter is THREE EVENTS**, not one event with three exacts (ruled 2026-07-29). Nothing
else in Orbo has that cardinality and a calendar must not invent one. Each carries its own window, so the
windows overlap through the station, and that smear is the signature.

**The pane's sentence:** my life is currently mobilized around [house], through the manner of [sign],
under the terms established by [dispositor and its condition].

## The synchronic engine, as built (v0.878)
Doctrine above is settled; this is where it lives in the code.
- **`framing.js` owns the geometry.** `phaseOf` \u00b7 `axisOf` \u00b7 `axialOf` (the triple) \u00b7 `synOrb` \u00b7
  `flipEvents` \u00b7 `beadFamily` / `beadMode` / `beadModeDays`. `midpoint()` is untouched and stays the
  display derivation. Regenerate `framing.browser.js` after every change; never hand-edit the build.
- **`spine.axialAt(jd, natal, lat, lon)` is the only door to the triple.** It computes off the genome's
  own decode and memoizes on the genome entry, keyed by the natal it is read against. The triple could
  not ride inside `spine.at` because the genome is keyed `jd|lat|lon` and the triple also needs a
  natal; a door memoized on the entry keeps the single-door law without polluting the cache key.
  Readers call `_axialAt(jd)`. Nothing calls `axialOf` directly.
- **Phase resets silently at the return.** Parity goes 0\u21921 at the opposition (a flip) and 1\u21920 at
  `T = N` (not a flip \u2014 the displayed point is continuous there). One flip per cycle; every flip
  record therefore carries `phase: 1`. Do not "fix" this.
- **NO body is excluded from the flip scan** (corrected 2026-07-29, second pass). Both earlier
  exclusions were wrong, and wrong the same way: an average was used to settle a question that is not
  about averages.
  - **Pluto flips, and it is the most consequential flip a life contains.** The "~124 year half-cycle"
    is the MEAN, and Pluto's orbit is far too eccentric for a mean to rule on this: twelve years to
    cross Scorpio, thirty-two to cross Taurus. Measured against real natals, a native born 1946 to
    1955 reaches transiting Pluto opposite natal Pluto at **age 83 to 86**, so the boomer generation is
    at or approaching its Pluto flip now, and it stutters into FIVE events across about two years as
    Pluto retrogrades over its own opposition. For a native with Pluto as modern chart ruler this is
    not an edge case, it is the headline.
  - **Lilith stays in.** Its osculating apogee does oscillate its opposition into many crossings
    (17 in eight years, measured). That is the SAME phenomenon as retrograde stutter, which doctrine
    says to honour and not smooth, and Lilith is not decoration to the natives who read it.
  - The general law: **which bodies are in play is the reader's choice (♊ Bodies), passed in as
    `opts.bodies`.** The engine does not decide for the native which of their own placements deserve
    an event.
- **♐ Field carries THREE KINDS of synchronic event, not just flips.** `synEvents` scans all three off
  one grid, and the ♐ socket's chips toggle them (flips · houses · contacts, persisted as `synKinds`).
  - **flip** · the placement reaches the end of its arc and is lived from the opposite pole. A change
    of government by inversion.
  - **ingress** · the placement crosses a sign boundary. Houses are natal whole-sign anchored to the
    natal ASC, so **a sign boundary IS a house boundary**: one crossing carries both readings at once,
    a new manner and a new arena, and it hands the placement to a new dispositor. A change of
    government by ordinary motion.
  - **aspect** · two synchronic placements come to exact contact. Both move (each at half its own
    transiting speed), so unlike the same-body pair families these genuinely FORM, perfect and
    separate. Orbs from `synOrb`, aspect set from ♍ Aspects.
  - **Every non-flip crossing is gated on the phase bit being UNCHANGED** across the interval. A flip
    jumps the displayed point 180°, crossing sign boundaries and separations wholesale; counting those
    as ingresses or contacts is the old `d > 150` trap from the other side.
  - **A crossing is PENDING until the placement takes up residence** (fixed v0.878): it must clear the
    boundary by 0.1° (contacts 0.02°) before the event is emitted, and the emitted time is still the
    exact crossing. Without it, a slow placement whose drift near a cusp is comparable to its own
    libration crosses back and forth and each wobble reads as a change of arena and dispositor: the
    synchronic Node, parked within 0.02° of 0° Aries, produced seven ingresses in six weeks with
    excursions of 0.002° to 0.08°. That is NOT the stutter doctrine honours — a real stutter moves the
    point whole degrees over weeks. Do not relax this into a smoothing of genuine stutter.
  - The Moon is out of the CONTACT scan by default (as the transits stream excludes her): at ~6.6°/day
    synchronic she alone outnumbers every other body combined. Her flips and ingresses still ride.
- **Synchronic orbs are half the natal orb, tapered.** At the natal default of 6\u00b0: 3.0\u00b0 conjunction
  and opposition, 2.5\u00b0 trine and square, 2.0\u00b0 sextile, 1.0\u00b0 minors. \u264d Orb is the override, not the
  default. Anything still passing a hardcoded `orb: 3` should move onto `synOrb`.
- **A flip exports as its window, not its hinge.** `_exportFieldICS` writes DTSTART=enter, DTEND=exit
  for a flip, so a retrograde station's events overlap in the user's calendar. That smear is the
  signature. Ingresses and contacts are instants and get an hour.

## Step 7b · the pullback deleted, the word struck (2026-08-04, v0.880)
Prompt of record: `specs/Prompt - Step 7b.md`. Four things in one session because each moved
`fertKey`. **The rebuild was real and was spent once:** `fertilize.CODEC` is 2.

**§1 IS SETTLED, BY MEASUREMENT.** Two records in this file disagreed: the Ring's said the algebra was
an artifact of asking a sky-space question about a Ring occupant, the Loom's credited the pullback with
deleting the six-ingresses bug. **The Ring's record wins without costing the Loom's**, and the
resolution is smaller than the axis scan first proposed (that was the pullback wearing a third coat):
- **There is no synchronic coordinate. There is an occupant and a speed.** A target's degree is a
  degree of its own occupant, and the field is `deg`, never `sky`. An occupant is a body optionally
  measured from a natal degree: absent `nat` is the sky (floor, contact), present `nat` is
  `midpoint(nat, sky)`. That one composition in `scanTargets` is all the scanner knows about the
  layers, which is a restatement of "layer is which occupant is sitting there, differing only in SPEED".
- **THE PHASE GATE IS NOT REPLACED, IT IS UNNECESSARY.** The displayed point jumps 180 degrees at a
  flip, so it arrives as an ordinary WRAP, and the scanner has carried a generic wrap guard for every
  layer since S1. No parity bit, no mod-180 coordinate, no pullback. Do not add one back to "help".
- **Measured before a line was written**, fixture natal, 400-day window: 128 ingresses, 19 flips, 147
  contacts, every root paired with the pullback's at **max delta 0.00 minutes**, and `ring.nearest`
  exact on all 147. Those three counts are CONSTANTS in `tests/loom-algebra.test.html` now, because
  the second path is gone and there is nothing left to diff against.
- **The residency guard returned to 0.1 degrees** of the occupant's own residual, the coordinate v0.878
  wrote it in. A flip's root is a sky-space root BY NATURE (transiting P opposing natal P), so its
  target carries the same law doubled. Never relax either into smoothing genuine retrograde stutter.

**The flip keeps its name because of what it MEANS, not what it does.** Mechanically it is the contact
weave's own 180 root on the same body, shared, never rescanned. Nominally it stays its own kind: a
change of government by inversion is not an opposition, and sign, house and dispositor invert together.

**`serves` and the hand-rolled nearest are gone, and THE RING DECREES THE ASPECT AT EXACT.** That
`reduce` was the last nearest-mark arithmetic outside the Ring; the read is `ring.nearest` at the root,
where the two placements are exactly a mark apart. Supplement closure is still a fact of the set
(0/180, 30/150, 45/135, 60/120 pair, 90 with itself, 72 and 144 not); what died is the LIST that
conflated a root with its supplement's label. **How many targets a mark is worth is the Ring's fact:**
a mark whose two exact targets coincide is `single` on its own row, and those are the CONJUNCTION and
the OPPOSITION, which have no handedness at all. Every other mark is a directed pair, worth two.

**CONTACT NAMES A CONJUNCTION, and never stands in for an aspect.** `_almField` used to print
"synchronic contact · exact" on a sextile. It reads `synchronic sextile · exact` now: the word is
always the Ring's word for the mark. `contact` survives ONLY as the loom LAYER (the sky meeting the
chart, the two remaining two), and the inter-chart grid's harmony families are contact · ease · friction
(`FAMN[0]` was the invented word sitting on the conjunction).

**`framing.synEvents` kept its signature, its return shape and its job as the DC's fallback, and lost
its scanning body.** There is ONE scanner; loom imports framing, so the scanner arrives INJECTED
(`opts.loom`) and never imported. With none in hand it returns `[]`: the field goes dark, the plate
never does. Its record shaping is the single exported `framing.synShape`, which the DC's `_fertSyn`
now shares instead of keeping a second translator in step.

**THE INVENTORY WAS WRONG A FOURTH TIME, in the way §1 predicts.** `luna.js` was listed as
downstream-no-edit and was not: it imports the target set BY NAME and carries the layer as a public kind
string in `LUNA_KINDS` and `MAX_SPAN`. Clustered by CONSTRUCT again, not by subject. The harness now
fetches `luna.js` too, so the claim is checked and not asserted.

**One trap worth keeping.** `decorate`'s synchronic `orbWide` doubled `synOrb`, and that doubling existed
ONLY to compensate for a rate measured in sky space. Removing it alongside the pullback leaves every
window byte-identical; leaving it in would have silently doubled every synchronic window. In
`readWeave` the same factor sat on both sides of a ratio and cancelled, so no stored window moves.

**DEFERRED AGAIN, on purpose: `_compPairs`' hardcoded 3 degree orb.** Not a one-liner, and putting it
on `synOrb` wholesale would be wrong by the Ring's own law: its same-body rows genuinely halve
(a composite body against its own natal is half the transit separation), its cross-body rows do not,
because a moving sky term does not cancel. The honest fix is two orbs in one grid, which is a doctrine
call and not a rider on a refactor.

**Green after the pass:** ring 70 · mater 52 · rulers 16 · timespine 12 · loom 25 · loom-algebra 44 ·
mundane 35 · embryo 31 · fertilize 38 · luna 20 · astrodna 50 · rewire-parity 197 — **590 checks, zero
failures.** The embryo did not rebuild (native-independent, angle-valued codec, no placement stored).
The weave rebuilt once under `w2|g…` and stopped. The instrument did not move.

## The Loom, as built (Phase 5 · S0, S1, S5 thin · 2026-07-29; rewired by 7b 2026-08-04)
Plan of record: `specs/Phase 5 - The Loom.md`. Two threads (sky, native) and two weaves (contact,
SYNCHRONIC). **The midpoint is primary**: never describe the synchronic layer as the transiting layer
"halved". **The word is synchronic, never "union"** — see "Step 7b" below for what was deleted with it.
- **`framing.js` owns the target algebra** (pure, no scanning): `floorTargets` / `contactTargets` /
  `synchronicTargets` / `loomTargets`, plus `mod180` and `SYN_CONFIRM`. The nine pullback functions
  are DELETED. Verified in `tests/loom-algebra.test.html` (44 checks, against the fixture natal).
- **`loom.js` is ONE scanner** over a target set, plus three thin builders and `retroPeriods`. It never
  imports ephem in the app path: the DC hands it `spine.probe` and `spine.bodyProbe`. The grid is
  walked once PER GROUP (all targets on one body or one pair share a pass), which is the difference
  between minutes and seconds on a century. `tests/loom.test.html` (22 checks) builds a decade of
  floor and cross-checks the weave against the recorded numbers: 128 ingresses, 19 flips, 147 contacts,
  max delta 0.00 minutes.
- **SUPERSEDED BY 7b: the phase gate is not deleted by a coordinate, it is unnecessary.** This entry
  used to credit the sky-space pullback with deleting it. The truth is cheaper: the displayed point
  jumps 180 degrees at a flip, so it reaches the scanner as an ordinary WRAP, and `scanTargets` has
  carried a generic wrap guard for every layer since S1. Measured, not argued. The v0.878 residency
  guard survives at 0.1 degrees of the occupant's OWN residual, which is the coordinate it was written
  in; a flip's root is a sky-space root by nature, so it carries the same law doubled.
- **A synchronic placement only ever occupies the seven signs its arc touches**, and the arc contains
  SIX sign boundaries, which under the natal whole-sign law are six HOUSE boundaries. Twelve whole-sign
  houses, six of them ever reachable by that placement, forever. Six targets per body, not twelve.
- **SUPERSEDED BY 7b: there is no double-target, because there is no sky target.** Kept because the
  hazard is real whenever anyone reintroduces a pullback, and because supplement closure did NOT go
  away with it: every admitted angle is its own target in its own direction now, so no root is shared
  by two readings and nothing is relabelled after the fact. THE RING DECREES THE ASPECT AT EXACT. The
  old text: The plan says a union target resolves to two sky targets
  180 apart. The map is 2-to-1 in that direction rather than 1-to-2 (`2*theta` and `2*(theta+180)`
  are one angle mod 360), but **the hazard and the failure mode are exactly as the plan records**: one
  sky root is shared by an aspect AND ITS SUPPLEMENT (conjunction with opposition, sextile with trine,
  square with itself), so the naive target list collapses those onto one entry, drops the supplement's
  label, and the scan returns a plausible half of the events with no error anywhere. Which class is
  live is read off the two displayed points at the root, NEVER from parity: the parity-only rule holds
  for same-body pairs (`beadFamily`, where the sky term cancels) and for nothing else.
- **The ingress row must not assume the three readings change together.** The fixture's synchronic Saturn
  crosses 29°56′ Capricorn into 0°00′ Aquarius on 9 Mar 2026: new sign, new house, no change of
  dispositor, Saturn to Saturn. Every ingress record carries `governed`.
- **The floor is the almanac's BASE LAYER, not a fusible stream.** `_almFloor` is concatenated into
  `_almEvents` unconditionally; the ♐ Mundane socket carries DENSITY chips per mundane kind
  (`mundKinds`) and, where every other stream shows a fuse toggle, the words "beneath every stream".
  The floor is never fused. "Fuse" keeps its dock-law meaning and only that.
- Moon cardinality is respected by `moonCut`: her ingresses and the syzygies materialise on the floor,
  her flips and synchronic ingresses on the weave, and her mutual, natal and synchronic CONTACTS never
  do. They
  belong to `luna.js` as a windowed generator. Widening that filter grows the table by an order of
  magnitude.

## The embryo (Phase 5 · S3 · 2026-07-30)
`mundane.js` / `mundane.browser.js` (the geometry and the codec) plus the generated
`embryo.browser.js` (the artifact), verified in `tests/mundane.test.html` (28 checks) and
`tests/embryo.test.html` (25 checks). Regenerate with `tools/build-embryo.html`.
- **The embryo is a shipped artifact, not a computation.** 1700 to 2100, 320,924 rows, 2.68 MB,
  8.8 bytes a row: sign ingresses, stations and the retrograde periods they bound, the mutual
  contacts of the planets, the Moon's own ingresses, the syzygies, and 1,925 eclipses. Native
  independent, place free, byte identical for every reader. One `window.__ORBO_EMBRYO` global from a
  plain `<script src>`, per the standalone-export law.
- **The reason to ship rather than compute is TRUST, not size,** and eclipses are the reason.
  `eclipseAt` classifies a syzygy from the 3D state (`ephem.moonState` / `ephem.sunState`, the only
  doors that read latitude and distance): gamma, node distance, magnitude, type. **It does not claim
  hybrid** — that is a statement about a whole track, not one ratio at greatest eclipse — so it
  returns total, annular or partial, flags the knife edge, and `applyCanon` gives the canon
  (`docs/eclipse-canon.json`, 58 entries) the last word AT BUILD TIME. The word is packed into the
  row; runtime never diffs anything.
- **Materialise generously, filter at READ.** `readEmbryo(packed, {jdStart, jdEnd, kinds, bodies,
  aspects})` is the only door. It indexes the byte stream once and decodes only the window asked for,
  so a week of a four-century table costs a week's worth of work. ♊ Bodies and ♍ Aspects are read-time
  cuts and can never invalidate the build.
- **A station's confirmation is measured in degrees PER DAY** (`loom.CONFIRM_SPEED`, 5e-4). The 0.05
  residency figure asked a body to move twenty times faster than Saturn ever moves retrograde, so
  Neptune and Pluto had no stations at any window length and therefore no retrograde periods. A
  velocity sign change is not what residency guards against: nothing wobbles across its own station
  without reversing. Do not re-raise this figure.
- The Moon's dense kinds are still absent by law (luna.js generates them). Her ingresses and the
  syzygies materialise here, as planned.

## Fertilization (Phase 5 · S4 · 2026-07-30)
`fertilize.js` / `fertilize.browser.js`, verified in `tests/fertilize.test.html` (38 checks). The
embryo is the sky with nobody in it; **fertilization is the native entering it**: the two personal
weaves, contact and synchronic, a century each, built once per chart.
- **It owns the span, the chunking, the codec and the read cuts, and it never scans.** `loom.js`
  scans. No ephem import: the caller hands in `spine.probe` / `spine.bodyProbe`, per the
  single-door law.
- **The build is a GENERATOR** (`fertilizeChunks`, plus `fertilizeAsync`), because the caller owns
  every yield point: onboarding's own rhythm at engrave, a progress bar on a bench. A century is
  about 78 seconds of scanning, so it is chunked always. `cancel` makes a re-engrave mid-build free.
  Slices are half-open, and chunking loses no root (verified against a one-shot scan: max delta 0.00
  minutes).
- **Materialise generously, filter at READ** — the same law as the embryo. The build runs with every
  body, every aspect and the WIDEST orb (10°); ♊ Bodies, ♍ Aspects and ♍ Orb are cuts inside
  `readWeave`. An orb is linear in the residual, so a narrower orb SCALES the stored window (halved
  and tapered through `synOrb` on the synchronic layer) instead of rescanning. A reader's choice can
  never invalidate a century of work.
- **`fertKey` is natal identity × doctrine × codec version, and nothing else.** Only a re-engraved
  chart, a doctrine change that moves it, or a new row layout misses.
- Bytes, not JSON: delta-encoded minutes, hundredths of a degree, ~10 bytes a row, so a century of
  both weaves is ~1.1 MB in IDB (`orbo.weave`, pruned to the current key). Everything derivable is
  DERIVED at read — sign, house, dispositor, aspect word, `governed`. **A flip's other end is derived
  too**: a flip is transiting P opposing natal P. (`serves` is gone: 7b deleted the family.)
- **In the DC:** `_fertEnsure()` (called first and fused from `_spineEnsure`, so the weave failing
  costs the weave alone), `_fertQuery(a, b, q)` as the one read gate, `_fertSyn` translating the
  synchronic weave into the shape `framing.synEvents` returns, through the one shared `framing.synShape`. Moon-side memory only, like the timespine:
  the instrument never reads it and `_synEvents` keeps its live scan as fallback whenever the table
  cannot answer (not built, different chart, window past the edge).

## The lunar module (Phase 5 · S2 · 2026-07-29)
`luna.js` / `luna.browser.js`, verified in `tests/luna.test.html` (19 checks).
- **She is a windowed generator, never a materialised table.** Measured against the fixture natal:
  mutual aspects ~119,000 per century, natal contacts ~172,000, synchronic contacts ~60,000, against
  ~50,000 for everything else in all three layers combined. Memoised per window (LRU, oldest out
  under pressure), and `MAX_SPAN` per kind CAPS an over-wide ask rather than truncating silently.
  Available always, including before fertilization.
- **No second scanner.** Her targets are the same three target sets cut to the rows that touch her,
  run through `loom.js`. `layer` stays honest: mutual is floor, natal contacts are contact,
  synchronic contacts are synchronic (`LUNA_KINDS` and `MAX_SPAN` renamed with them in 7b).
- **She is the SWITCH, not the moving light.** `switchGroups` collapses one pass over a parked group
  into ONE event naming every member; a row that says "Moon trine Mercury" under-reports it. The
  floor's `contacts` chip renders these as "the Moon closes N at once".
  - **A group is one pass, not a chain** (fixed on first light). Without a total span cap the gap rule
    daisy-chains: each contact lands inside twelve hours of the last, and a group grew to 13 members
    across 71 hours, which is her ordinary motion reported as one configuration lighting. Bounded to
    `maxSpan` 1.2 days, and a body cannot appear twice in one group.
- Her flips and synchronic ingresses still ride the weave, and her sign ingresses and the syzygies still
  ride the floor. Never move any of those in here.

## The Ring (built 2026-07-30)
`ring.js` / `ring.browser.js`, authority `tests/fixtures/aspect-atlas.md` (720 states, 14,400
targets), verified in `tests/ring.test.html`.
- **The Ring is the database relationship of any given degree to any other given degree.** A flat
  circle, and that is the whole of it. It holds no occupants, so it never knows where the Moon is; no
  meanings, so it knows nothing of signs, elements, decans, terms, faces or rulers; and no orb.
  "What is where" is the DNA and the sky, "what it means" is the readers, and the Ring is the
  relation both consult. **It imports nothing, because it is the floor.**
- **One geometric fact carries many readings, and none of them are in the Ring.** For two degrees 58
  apart, 2 from a mark at 60: one reader says sextile, one says complementary elements, one says in
  cooperation. Readings can be added forever without touching it.
- **A fourth tier.** `timespine.js`'s constitution names MATERIALIZED (expensive), DERIVED AT READ
  (cheap), REFUSED (floods the table). The Ring is **INHERENT**: no arguments, no time, no native, no
  place, true before the app runs. A brass astrolabe contains no ephemeris — the plate, the rete and
  the limb ARE engraved tables, and the historical object computed nothing. Orbo has been converging
  on what its own object already is: the ephemeris is a GENERATOR and everything after it is an
  ARTIFACT, called once and never again (astrodna at engrave, the timespine per seed, the embryo at
  build time, fertilization per chart).
- **The eleven marks are the die, not the artifact.** 0 · 30 · 45 · 60 · 72 · 90 · 120 · 135 · 144 ·
  150 · 180, stamped into typed arrays at load, once, before anything asks. Readers point at a table
  rather than compute per call, and it is byte-identical for every reader by construction rather than
  by download. **You ship the cut plate, not the maker's rule.** The atlas markdown is a FIXTURE, never
  a runtime asset (the bundler follows only HTML src/href, so a `fetch()` of a .md ships missing from
  the standalone while the served preview looks fine).
- **Septiles are excluded** (51.4286, 102.8571, 154.2857), deliberately and not by oversight. Every
  remaining mark is a WHOLE NUMBER OF DEGREES (each is 360*k/n for an n that divides 360, WITH n <= 12
  — unbounded, n=360 admits any integer and the claim is vacuous), so every
  target is a whole degree and the table is a perfect lattice: exactness is structural. This is NOT
  the same as each mark dividing 360 — 135, 144 and 150 do not, and do not need to. 7 does not divide
  360, which is exactly why a septile is 51.4286 and lands between states. A septile would put marks between states and reintroduce half a
  degree of quantization everywhere. The DC still carries the three; they live outside the Ring.
- **The state encoding is 0-719:** 0-359 direct, 360-719 retrograde, absolute degree = state mod 360,
  retrograde state = degree + 360. Two natives with Mars at 0 Aries, one retrograde, are not in the
  same condition and the vocabulary has to say so. But **motion is a quality of an occupant and never
  enters a degree-to-degree relation**, so the relation is over 360, and the atlas's retrograde half
  is a *provable restatement* of its direct half (verified, 360 of 360).
- **EVERYTHING IN ORBO EXISTS ON THE RING.** Natal, transiting, synchronic, composite: it never
  leaves. A synchronic Mars at 0 Aries IS at 0 Aries and squares anything at 90 and 270. There is no
  synchronic space, so there is nothing to pull back from, and the whole pullback target algebra
  (`unionToSky`, `skyToUnion`, `unionIngressTargets`, `unionFlipTarget`, `unionSepToSky`,
  `unionSepFamily`, `unionSepClass`), the double-target hazard and `serves` existed only because
  sky-space questions were being asked about a Ring occupant. **`layer` is not a geometry, it is which
  occupant is sitting there.** The only genuine difference between layers is SPEED (natal 0,
  transiting v, synchronic v/2), which is time and belongs to the scanner.
- **No orb in the Ring. An orb is an EXPANSION** — a mark widened into an arc, containment rather
  than comparison. The Ring reports the mark; a caller holding two exact longitudes computes the
  residual against the mark's exact angle. **Nothing is ever quantized to a state** (up to half a
  degree, 5x the ingress residency guard and 25x the contact guard). Nearest-mark is arithmetic over
  the same eleven marks, never a second table, and it exists because `astrodna.calcAspects` does not
  break on first match while the DC's `_aspectSnapshot` does: the justification is **totality and
  single-valuedness, never speed**. **Ties resolve to the LOWER angle** (37.5 · 52.5 · 66 · 81 · 105 ·
  127.5 · 139.5 · 147 · 165).
- **Where the sky cancels, the halving is exact geometry and not a policy.** Two Moons at 7 Capricorn
  (277) and 3 Taurus (33) are 116 apart, 4 short of trine; synchronically 58 or 122, and 2 off in
  both. The same relationship read at half scale, so every length halves with it: separation,
  residual, and the arc a mark expands into. Nothing is tapered. **Cross-body does not halve** — a
  moving sky term does not cancel, so the rate halves and the value does not, and one factor applied
  to a whole layer is wrong twice over. `SYN_ORB_FACTOR` is a category error; the cross-body dwell
  question is a CHOICE and lives with whoever sets thresholds.
- **Supplement closure, a fact of the set and not a defect:** 0/180, 30/150, 45/135, 60/120 pair and
  90 pairs with itself; **72 and 144 do not** (108 and 36 are not marks). Where the two candidate
  marks are supplements the residual is identical on both sides, so a flip leaves tightness unchanged
  while the NATURE of the bond inverts (trine to sextile is four signs to two, same element to
  complementary, easy flowing to in cooperation) — a clean substitution, not a fade. Where they are
  not, the relationship goes dark at one phase and returns at the other.
- **AstroDNA is the identity, not the timestamp.** `timespine.js` already keys on `sequenceString ×
  SPINE_VERSION` and is correct. `fertKey` keys on `natal.jd.toFixed(6)` plus fifteen positions at
  three decimals, which is a timestamp identity with floats bolted on: two moments that engrave the
  same genome ARE the same chart. **DONE** (rewire step G, 2026-08-04) and then refined by step J: both
  `fertKey` and the `orbo.spine` seed key on the genome's whole-degree PROJECTION, since the gene itself
  is arcseconds now. See "The arcsecond gene, and the three resolutions" below.
- **Falsy-zero contract, API-wide (fixed on first light).** The Ring is 0-based in EVERY quantity it
  returns, so a truthiness test on any read is a bug: 0 is 0 Aries (`degreeOf`, `stateOf`), a
  conjunction (`relation`, `exact`, `separation`, `arcOf`), a real target at 0 Aries
  (`targetDegree`), the supplement of 180 (`supplementOf`), and an EXACT hit (`nearest().residual`).
  Three rules: **absence is always `null`**, never 0 and never a negative sentinel · a programmer
  error **throws** (unknown angle, malformed state) so it cannot be confused with either · test
  `!== null` or use `related()`. `if (ring.relation(a, b))` would silently drop every conjunction,
  the most common aspect in the app, with nothing thrown and the geometry still right. `targetDegree`
  originally returned `-1` for an unknown angle, which was wrong in both directions at once (valid
  result falsy, error truthy) and let a negative index reach the typed array and yield `undefined`.
  All of it pinned in `tests/ring.test.html` before any call site was rewired.
- **The guard belongs at EVERY entry point, and there are two input kinds.** Hardening one function
  and leaving its siblings indexing the typed arrays raw is how `relation` came to return
  `undefined`: a fractional index into an Int8Array is `undefined`, `undefined < 0` is false, so it
  fell through to `MARKS[undefined]` — which defeats the `=== null` test the contract itself
  prescribes and made `related()` and `relation() !== null` disagree. Three shared validators now,
  applied everywhere: `ckState` (an integer address in 0-719 — validate the STATE, never the degree
  it reduces to, since `720 % 360` is 0 and silently reads row 0) · `ckAngle` (one of the eleven
  marks; `supplementOf(108)` used to return 72 and `supplementOf(36)` 144, asserting exactly the
  closure the law denies, from the two non-marks the law names) · `ckFinite` (any finite real,
  normalized on the way in). **Do not read "throws on -1" as universal:** -1 is a malformed state and
  a perfectly good separation.
- **An invariant in a comment is not an invariant.** Four review rounds all found the same defect
  shape: a claim in the header that nothing enforced. `MARKS` is frozen · `PLATE` is frozen and the
  typed arrays NEVER leave the module (`snapshot()` copies, because `Object.freeze` does not protect
  typed-array contents, so exported buffers made "byte-identical by construction" false) · every loop
  runs on the captured `NM`, never `MARKS.length`, since mapping over the die let a mutated `MARKS`
  walk `row()` past its fixed stride into the adjacent degree and return a plausible twelfth entry ·
  and `sign` is validated like everything else, because nine of the eleven marks have two DISTINCT
  targets and a forgotten third argument silently returned the +θ half · and `stateOf`'s `retro` takes
  `ckBool`, because a truthy string was choosing between the direct and retrograde HALVES of the
  address space. **One validator per ARGUMENT KIND, no exemption for flags** — enumerate the kinds, not
  the functions, or the next argument type added is missed the same way.
- **Still owed** (named so they stay visible): the codec change below (one bump, three edits) ·
  `framing.ASPECTS`, `astrodna.calcAspects`, the DC's angle tables and `loom.ASPECT_NAME` collapse
  onto the Ring (ANGLES ONLY — words, glyphs, colors and `ASP_DEFAULTS` stay where they are, so this
  fixes the geometry duplication and not the naming one) · the pullback target algebra deletion (7b) ·
  `framing.synEvents`' scanning body, keeping its live fallback, which is the pane's answer when the
  weave cannot answer.

## The arcsecond gene, and the three resolutions (ruled and built 2026-08-04)
The gene is a Ring **fine state**: arcseconds of the circle, 0 to 1,295,999 direct and 1,296,000 to
2,591,999 retrograde. `SEQ_CODEC = 3`. Full record in `specs/Rewire - Angles onto the Ring.md` step J.
- **The reason is the identity, not the digits.** A resonator can prevent drift, detect loss and
  re-align a derived state, but it cannot recover arcminutes that were never encoded. The precision was
  never lost (`nodes` always carried the float); what was missing was precision IN THE IDENTITY, and
  doctrine says two moments that engrave the same genome ARE the same chart. At whole degrees that was
  not quite true: a whole-degree Ascendant pins a moment only to about four minutes of clock. Now it is.
- **Arcseconds, never packed DMS digits.** `0210837` is a display format promoted to storage: not
  arithmetic, admits invalid states (61 minutes), and drops the sign index. One absolute integer keeps
  every operation a subtraction, and since every mark is a whole degree every target is a whole
  arcsecond, so the perfect lattice survives at 3600x and exactness stays structural.
- **The retrograde encoding keeps the coarse SHAPE, scaled:** one integer, retrograde in the upper
  half. A separate motion field breaks "a genome is a list of integers" (every persisted row, every key,
  all three goldens); a negative value restages the `targetDegree` returned `-1` bug; a parallel
  arcsecond array leaves the coarse value as the identity so the identity never gets finer. **The
  offset's magnitude means nothing** — it is a flag addressable as arithmetic, and its one load-bearing
  property is that reduction is a single modulo. So the modulus is a NAMED CONSTANT everywhere in the
  state encoding and never a literal again, and `ckFine` guards every fine entry point: at this scale a
  missed reduction reads a position 360 degrees away with nothing thrown.
- **Four of the twelve genes carry no motion information, deliberately, and it is pinned.** An angle
  cannot station, the luminaries never appear retrograde, and the mean node is uniformly retrograde, so
  gene 12 is ALWAYS upper-half and genes 1 to 3 never are. A migration that flips either end is
  otherwise invisible.
- **THE DIE DID NOT GROW.** The plate is still 360 rows of eleven marks and `nearest` still quantizes
  nothing. Precision is a property of the OCCUPANT; the relation is the die. Same split that keeps
  motion out of the degree-to-degree relation.
- **THE THREE RESOLUTIONS, top to bottom, and each is DECLARED.** A cache key is a deliberate
  projection at the resolution the artifact's contents are sensitive to, never an accident:
  - **sample identity is the INSTANT** — `spine.at()` stays on `jd|lat|lon` forever.
  - **chart identity is the GENOME** — `sequenceString`, arcseconds. This is what `entry.sequence`
    stores as its label.
  - **artifact keys are named CUTS of the genome** — `fertKey` and the `orbo.spine` seed key on
    `astrodna.degreeSequenceString`, the whole-degree projection, which is byte-identical to what
    codec 2's `sequenceString` returned (measured on all three goldens). That is why the widening
    rebuilt NOTHING. A century-long weave does not move for one arcsecond, and `topologyKey`'s sign
    resolution is the same law one step coarser. **Never key an artifact on `sequenceString`.**
- **Provenance gates the DISPLAY, because encoding precision the source never had is the one loss
  nothing downstream can detect.** `_precision(name, src)` in the DC, two ceilings, lower wins: the
  clock (a birth time is stored to the MINUTE, so ~15′ of Ascendant, ~0.55′ of Moon, ~0.0035′ of
  Jupiter per minute of clock; LMT widens it to ~4 minutes) and the ephemeris (both nodes, Chiron,
  Lilith, the asteroids, Fortune and Vertex are not arcsecond-true here and cap at L2). It is a CEILING
  and never a floor: `_fmtLong` with no body name reads exactly as it always has.
  - **The finding, and it is the point:** on ordinary minute-resolution birth data the **Ascendant and
    MC reach L1 only**, most bodies reach **L2**, and **only Jupiter and beyond reach L3**. An L3
    arcsecond on a natal placement is almost always theatre, and the ladder says so instead of printing
    seven digits. A birth time known to the second lifts the Moon and inner planets to L3 and the
    Ascendant to L2, never L3.
- The embryo and fertilize codecs store hundredths of a degree (36″) and that is NOT an inconsistency:
  neither stores a placement, only angles, times and residuals.

## The Mater (built 2026-08-04 · rewire step D2)
`mater.js` / `mater.browser.js`, verified in `tests/mater.test.html` (49 checks) plus 16 STEP D2 checks
in `tests/rewire-parity.test.html`. **A SIBLING of the Ring and never a part of it: the Ring is the
inherent RELATION, the Mater is the inherent MEANING.** The Ring's law says it knows nothing of signs,
elements or rulers, so rulership could not go inside it. Same tier (INHERENT), same properties: no
arguments, no time, no native, no place, stamped before the app runs, an artifact rather than a
generator, and it imports nothing.
- **The name.** `frame` was spoken for (composite framing) and skeleton/chassis/structure are
  engineering words in an instrument that speaks brass. The mater is the astrolabe's own body, the
  dished disc engraved once into which every plate seats: *the thing everything else sits in*.
- **FIVE stamped tables, all frozen:** signs (names, glyphs, elements, modalities, stated as the
  element and modality CYCLES rather than twelve typed rows) · traditional rulership · the twelve house
  frames · exaltation with its traditional degrees · **detriment and fall derived at STAMP time** as
  the oppositions of the other two, then frozen, so the derivation happens once and readers get a
  table. Name-keyed and index-keyed views are both derived from one literal, never typed twice.
- **A load-time completeness check throws**, in the Ring's idiom: a missing glyph, element or modality,
  an exaltation with no degree, a frame not anchored to its own ASC sign, and above all **a ruler that
  is not one of the classical seven**.
- **The co-rulership boundary survived verbatim and is now enforced, not commented.** There is no
  modern attribution anywhere in the Mater; the DC's `CO_RULER` remains the DISPLAY-ONLY sibling; a
  merge would throw at load instead of quietly rewriting dignity, the disposition chains, the
  rules-houses loops, ZR period lengths and the election engine.
- **What it de-duplicated:** rulership from four copies to one (`framing.RULERS`,
  `astrodna.SIGN_RULERS`, `rulers.DOMICILE`, the DC's `RULER_BY_SIGN`), exaltation from three, the sign
  names from four, the elements from two, and `houseOf` from five (astrodna by sign index, framing by
  longitude, three inline in the DC). `framing.dignityOf` and `rulers.dignityOf` keep their own words
  at their own edges (`exaltation` vs `exalt`, `null` vs `peregrine`); the Mater speaks one vocabulary
  and **absence is `null`**, per the Ring's contract.
- **The harness asserts IDENTITY, not equality** (`framing.RULERS === mater.RULERS`). Equal tables
  prove nothing; the same object proves nobody kept a private copy that agrees today.
- **The instrument keeps its own sign glyphs, sign names and element colors, deliberately.** Every
  engine reaches the DC as a plain `<script>` appended to head, which is ASYNC, and the wheel is
  engraving drawn on frame one: by the instrument-survives-everything law it may not wait for a global
  to register. So those three are DECLARED on the instrument and CHECKED against the Mater at mount
  (`_aspAudit`). Everything moon-side (`_rulerOfSign`, `_dignityOf`, `_houseOf`) reads the Mater.
  `_houseOf` keeps the one-line rotation as a degradation path, which is arithmetic and not a table,
  and the harness pins it at exactly one occurrence in the file.
- **Load order:** `mater.browser.js` sits beside `ring.browser.js` (it imports nothing);
  `framing.browser.js`, `astrodna.browser.js` and `rulers.browser.js` gained the `__ORBO_MATER` guard.
  `rulers.js` is no longer zero-dependency: it has exactly one, and that one is a floor.
- **A DEPENDENCY ADDED TO A `.browser.js` IS ADDED TO EVERY HTML PAGE THAT LOADS IT** (learned
  2026-08-05, the Connectome review). The browser builds' bundle-safety guard re-queues `boot` until its
  dependencies' globals exist, which is what makes blob-order safe in the standalone and also what makes
  a MISSING dependency silent: the file simply never registers, with no error anywhere. 5.2 repointed
  `framing.browser.js` and `astrodna.browser.js` at the Tympan, and the nine test pages that load them
  without `tympan.browser.js` sat in the poll forever. About 470 checks stopped running and the suite
  called them green, because `tests/_suite.html` printed once on a timer and counted a suite with zero
  rows as `ok`. Both are fixed: the nine pages load the Tympan, and the aggregator polls, reads a
  rowless suite as WAIT, and refuses to say ALL GREEN until every suite has reported. **An unfinished
  suite is not a passing suite, and an empty one must never look like one.**
- **CLOSED 2026-08-05 (the Connectome pass, 5.2): the frames MOVED to the Tympan.** `mater.js` keeps no
  copy and no house read, `tests/mater.test.html` §3 guards their absence rather than their contents, and
  the contents are pinned in `tests/tympan.test.html`. One die, and it is `tympan.HOUSE_FRAMES`. The
  original question, kept because the reasoning is the precedent: The rewire's D2 listed the
  twelve frames as Mater table 3 and they are built there, as the FORWARD stamping only. The Tympan plan
  (below) names the same twelve frames its own, and adds what D2 explicitly deferred: the REVERSE index
  (frame + planet to the houses it governs) and the separate modern co-governor index. Nothing is
  duplicated today, because the four old forward copies are deleted rather than left as fallbacks. When
  the Tympan is built it should ABSORB `mater.HOUSE_FRAMES` and `houseOfSign` rather than stamp a
  second set: one die, whichever file holds it.

## The codec law (ruled 2026-08-03)
**AstroDNA is the codec, and the Connectome is its decode.** Not a layer above the genome: the decode
of twelve integers. `astrodna.js` is the sequencer, and the sequence is the chart's permanent identity.

- **THE TWELVE GENES, in order:** `Ascendant · Moon · Sun · Mercury · Venus · Mars · Jupiter ·
  Saturn · Uranus · Neptune · Pluto · Node`. The order has a PRINCIPLE, so it is regenerable and not
  merely frozen: **the frame first, then descending speed** (ASC 360°/day, Moon 13, Sun 1, then
  outward by period). The old order (`Sun · Moon · Ascendant · …`, inherited from the reference
  Python) is retired.
- **The encoding is 0-719, the Ring's own address space.** `floor(lon)` direct, `+360` retrograde.
  The old `floor(lon) + 1` (1-720) is retired: a `+1` puts a translation layer between the genome and
  the floor, and every translation is a place a bug lives. At 0-719 **every gene is directly
  Ring-addressable with no conversion anywhere**, and the Ring already proves its retrograde half is a
  provable restatement of its direct half.
- **The Node gene is the MEAN node** (`ephem.NodeMean`), not the osculating true node. The true node
  is a derivative of a derivative of a truncated lunar series (finite differencing at dt 0.01 on
  Meeus ch.47) and swings ~1.5° around the mean, which made it the least stable of the twelve. The
  mean node is closed-form and will never move under any ephemeris improvement. **True node stays an
  extra**, full precision, fully available to readers and to \u264a Bodies.
- **NUMBERING LAW: addresses are 0-based, ordinals are 1-based.** A degree and a state are addresses
  (they index the Ring's typed arrays, and 0 is a real answer: 0° Aries). A sign and a house are
  ordinals (Aries is the FIRST sign, the 1st house is the 1st). **Nothing in Orbo is both.**
  Consequence: the falsy-zero hazard is confined to the Ring. The Tympan deals only in ordinals, so
  it can never return 0 as a valid answer and truthiness is safe on every Tympan read BY
  CONSTRUCTION, not by discipline.
- **TWO HARD CRITERIA FOR GENEHOOD.** Membership beyond them is convention.
  1. **A gene must be stable under ephemeris refinement.** A gene is a whole-degree integer, so a
     body with ~1° of error has a gene already uncertain by a full unit, and improving its elements
     would change the identity of every chart ever engraved: every spine misses, every fertilized
     century misses, and the same birth data run a year apart yields a different genome. This is why
     **Chiron and Lilith are NOT genes** (`ephem.js`: Chiron is osculating Kepler at ~1° and
     "degrades faster"; Lilith is the oscillating osculating apogee, 17 flip crossings in 8 years).
     They matter as OCCUPANTS and are already `extras` at full precision. They cannot be IDENTITY,
     because identity must be permanent and theirs is not.
  2. **No gene may be derivable from another gene.** SNode is Node+180; Fortune is a function of asc,
     sun, moon and sect. Both are correctly extras. The genome is a basis, not a list of everything
     interesting.
- **ONE BUMP, THREE EDITS.** The reorder, the 0-719 encoding and the mean-node swap each invalidate
  `sequenceString`. Land them together under ONE `CODEC_VERSION` so persisted artifacts (`orbo.spine`
  keyed on `sequenceString \u00d7 SPINE_VERSION`, `orbo.weave` on `fertKey`) are invalidated exactly once
  instead of three times. Nothing is lost: both are derived artifacts and rebuild.
- **The sequencer consumes place and time.** The Ascendant is the only place-dependent gene, and it is
  IN the sequence, so after sequencing the birthplace and the timestamp are absorbed into gene 1 and
  **nothing downstream needs either**. Civil time was already only a label; now the coordinates are
  too. (Honest boundary: MC and Vertex are NOT recoverable from the genome, since they need latitude
  independently of the ASC. They stay extras, and whole-sign doctrine never houses off them anyway.)
- **Two programs, one boundary, and the boundary is the genome.** The SEQUENCER needs the ephemeris, a
  place and a moment, and runs once at engrave. The **COMPILER needs the sequence and the shipped
  tables and NO EPHEMERIS AT ALL** \u2014 no place, no time, no positions. That is why the connectome
  compiles in microseconds in a browser, why it is never persisted, and why the sequencer could live
  offline while the compiler is browser JS.
- **Flooring never crosses an integer boundary**, and sign (30), decan (10), term and face boundaries
  are all integers. So **every CATEGORICAL fact is exact from the truncated gene**: sign, element,
  domicile lord, decan, term, face, house, sect, and the whole wiring. What truncation destroys is
  the **residual** (distance to a mark, nearness to a cusp, speed), which is up to half a degree, 5x
  the ingress residency guard and 25x the contact guard. **The genome is an IDENTITY, never a
  measurement source.** Anything continuous reads the float longitudes that ride beside each gene.
- **`fertKey` moves onto the genome**, per the Ring's owed item: `sequenceString \u00d7 doctrine \u00d7 codec
  version`, never `natal.jd.toFixed(6)` plus floats. Two moments that engrave the same genome ARE the
  same chart. The weave's BODY SET is a build parameter and belongs in the version component, not in
  the sequence: \u264a Bodies may compile over more occupants than the genome holds, so **the sequence is
  the identity, the occupant set is the reader's choice** \u2014 two different things that both look like a
  list of bodies.

## The Connectome (planned 2026-08-03)
**The Connectome is the series of tables derived from the engraving that hold the meanings.** The Ring
is inherent and meaningless (degree to degree, imports nothing). The Connectome is the meaning layer
above it, and its first member is the Tympan. A connectome is not a set of nodes, it is the WIRING
between them: which node answers to which, which arena a function governs. The agency chain and the
light chain are traversals of the connectome; Bearer and Keeper are connectome terms.

- **Name: Connectome.** "Astronnectome" is the conversation word and never goes on a file: the double
  n is a stumble, and "astro" buys nothing inside an astrology instrument where every table is astral.
  Orbo's naming is bare nouns taken from the object (Ring, Tympan, Plate, Rete, Limb, Loom, Embryo,
  Spine) and Connectome is one of those.
- **ENTRANCE TEST: fixed at engrave, never rebuilt.** Not "categorical" \u2014 the natal aspect lattice is
  a connectome member (66 pairs, permanent) and it needs the FLOATS, because an orb is a residual.
  Fertilization is not connectome (it scans, it needs the sky). The embryo is not connectome
  (native-independent, and it is sky).
- **A connectome is an INSTANCE (the EXPRESSION, specced below); the compile is a FUNCTION; the Tympan is INHERENT.** The natal
  instance is compiled once at engrave and is a fixed fact of that chart. A moment's instance is
  compiled on demand and thrown away \u2014 it rides `spine.at`'s genome entry, memoized, exactly like
  `spine.axialAt` (the Tympan cannot go in the `jd|lat|lon` cache key, so key the memo on the ENTRY).
  Readers call `_connAt(jd)`.
- **SUPERSEDED by the Connectome Pass §3.8, and CLOSED by its review pass (v0.884): the natal and
  favorited Expressions ARE persisted, in `orbo.connectome`, and THE STORE HAS A READER.** The old
  ruling here said do not persist: it costs microseconds, so persisting buys nothing and risks a stale
  wiring table surviving a doctrine change. The key structure answers the risk (frame vector × doctrine
  × codec, `fertKey`'s own discipline: a doctrine change MISSES and rebuilds), and favorites are the
  case that pays, because a favorited chart otherwise has to be resolved through the spine at its own
  jd before it can be compiled at all. **A moment or a sky reading is still RAM only, evicted freely.**
  The rule the first cut broke and the review restored: **a store nobody reads is exactly the
  stale-artifact hazard the do-not-persist ruling was protecting against.** `_connHydrate` reads it
  once a session, keeps only keys matching this codec and this doctrine, re-freezes what it loads
  (structured clone drops the freeze), and `_connFromMap` consults it before compiling.
- **ONE occupant set, and it is `connectome.CANONICAL_ORDER`.** Both readers projected their own for a
  day (`connAt` the canonical fourteen, `_connFromMap` the ten of `this.BODIES`), which filed two frame
  vectors for one chart and hid the Node and Chiron chains from the sheet that had them. The occupant
  set is a build parameter (§3.2) and there is exactly one of it. Longitude to sign goes through the
  Mater's `signIndexOf`, via the DC's one `_signOf` door, never a hand-rolled `floor(lon/30)`.
- **The compile takes TWO arguments: occupants and a Tympan.** Natal is the degenerate case where one
  genome supplies both. Sky: occupants from the moment, Tympan from the native. Synchronic: the
  synchronic occupants, Tympan from the native. Composite: its own ASC sign, because a composite chart genuinely
  has a horizon and the natal-whole-sign law is about not re-housing a SYNCHRONIC placement. So
  nothing is told and nothing is special-cased: doctrine is one line, **the native's Tympan is the
  only one a synchronic placement is ever housed in**, and a signature is a better place for a law
  than a conditional.
- **SECT IS A TYMPAN READ, no place required.** Houses 7 through 12 are above the horizon, so day or
  night is one read of gene 3 (Sun) against gene 1 (ASC). No altitude, no latitude, no topocentric
  anything. The light chain is therefore available wherever the sequence is.
- **THE GEOCENTRIC LAW, restated for the sequencer.** The reference Python computed Sun and Moon with
  `FLG_TOPOCTR`. Never. Lunar horizontal parallax reaches ~57', so a topocentric Moon can sit a full
  degree from the geocentric one, which **can change her sign**, hence her house, her lord and her
  entire branch of the wiring, and it breaks the promise that two people export byte-identical flip
  calendars.
- **REFUSED, everywhere in the Connectome: an ORB.** The moment it holds an orb it has stopped being a
  wiring table. Aspect edges come from the Ring plus two live longitudes, joined AT READ. Doctrine
  says CROSS the two edge types, not store them together.

## The Tympan (planned 2026-08-03)
**The twelve whole-sign frames**, the companion table to the Ring and the first member of the
Connectome. Named for the astrolabe's engraved sheet under the rete that supplies the houses, swapped
out to change which set applies (the honest disanalogy: a brass tympan swaps on latitude, this one on
rising sign). `Astrolabe Model - Design Map.md` already reached for the word. It is NOT the composite
frame, the reading's frame rotation, or `framing.js`.

- **INHERENT, like the Ring**: twelve stampings, 144 rows, stamped from constants at load, before
  anything asks. **A native's frame is one read of gene 1 at sign resolution.** Nothing is computed,
  nothing is stored per native, and that is why the Tympan needs no persistence and **no tabula** (the
  socket ring being twelve is a coincidence; the Tympan is invisible infrastructure and a native only
  ever sees their own stamping).
- **The REVERSE index is why the file exists.** Forward (frame + sign \u2192 house) is one line of
  arithmetic that already exists FOUR times (`framing.houseOf`, two inline copies in framing.js,
  `astrodna.houseOf`); consolidating them is hygiene, and all four get DELETED rather than left as
  fallbacks or they drift. Reverse (frame + planet \u2192 the houses it governs) is the content: the pane's
  sentence, the loom's `governed`, and above all the watcher doctrine, where each placement watches
  its current governor rather than the engine scanning per body. Also free: a flip moves a placement
  exactly six houses, always.
- **SECONDARY MODERN RULERS ARE IN, as a SEPARATE INDEX** (ruled 2026-08-03), never a column on the
  traditional one. Traditional is the backbone: Scorpio's house has Mars as lord and Pluto as
  co-governor, Aquarius Saturn with Uranus, Pisces Jupiter with Neptune. Three co-governor entries per
  frame, one house each. Separate rather than a skip-flag because **the dispositor walker is then
  structurally incapable of branching into a modern: it is never handed that table at all.** A column
  you must remember to skip is a bug waiting for a tired afternoon.
- **The atlas markdown stays a FIXTURE, never a runtime asset**, same as the Ring's (the bundler
  follows only HTML src/href, so a fetched `.md` ships missing from the standalone while the served
  preview looks fine).
- **Error contract: the Ring's, exactly.** Absence is `null` \u00b7 well-formed and empty is `[]` (Mercury
  governs no house in this frame; an empty array is truthy, so a loose caller still behaves) \u00b7 a
  malformed address THROWS (house 13, unknown planet). Same contract as the Ring because two sibling
  tables with opposite contracts is worse than either. A throw cannot reach the database: the Tympan
  holds no user content, reads nothing from storage, writes nothing, and its inputs are ordinals and
  planet names from Orbo's own genome. A throw means a typo in Orbo's source, which fires the first
  time that line runs in development. And `_fuse` means a throwing layer costs one engraving, never
  the plate. Pin the contract in the test BEFORE rewiring any call site, as the Ring's was.
- **REFUSES:** occupants, time, place (it takes an ASC sign, not a lat/lon), the Ring, aspects, orbs,
  sect, lots, decans, terms, faces, triplicity, and **house MEANING WORDS**. The last is the one it
  will be pushed on hardest: if "the 3rd is siblings and short journeys" lives here, the Tympan becomes
  where doctrine text lives and it stops being inherent. **The Tympan gives the number; a glossary
  reader gives the word.**
- **The dignity seam:** Tympan is sign \u2192 house \u2192 domicile lord. `rulers.js` stays degree \u2192 dignities
  (decans, terms, faces, triplicity). The Connectome joins them. Nothing is duplicated.
- **Selection is not housing.** The rising-lord horizon scan and the composite chronology's cASC DO
  select other frames from the die, by a moving ASC. That is legal: they ask who governs a moving
  degree, not where to house a placement. **Selection is cheap; housing is fixed.**

## The Dispositor engine (planned 2026-08-03)
`dispositor.js`. Reads and records the dispositor chain of any occupant, on a natal, a mundane moment,
or any field. **Its input is a SEQUENCE, not a chart**, which is why it needs no modes: a mundane
moment sequences to twelve integers by exactly the same process a birth does.

- **THE CHAIN NEEDS NO TYMPAN.** Rulership is degree \u2192 sign \u2192 lord: no horizon, no place, no ASC.
  Housing is a separate reading that needs a Tympan. So a placeless field still gets a FULL dispositor
  chain, with houses `null` and no agency or light chain (both start from the Ascendant). Three honest
  absences rather than a mode switch. **`governed` is the single place the two halves meet.**
- **ONE TERMINATION RULE, not two.** Doctrine said a chain ends at a planet in its own sign OR in a
  loop; those are the same thing, because **own sign is a cycle of LENGTH 1**. The walker gets one
  exit condition and the length names the result: 1 = domicile (Keeper is itself) \u00b7 2 = **mutual
  reception** \u00b7 3+ = **dispositor loop**. Never "closed circuit".
- **The structure is a FUNCTIONAL GRAPH on seven nodes.** Each of the seven traditional planets has
  exactly one outgoing edge (its domicile lord), and a graph with out-degree one always decomposes
  into components each containing exactly one cycle. **Termination is guaranteed mathematically**, not
  by a depth cap; the whole thing solves in one pass over seven items.
- **TWO NODE CLASSES.** The seven traditional planets are dispositor-capable. Everything else Orbo
  carries (Node, Lilith, Chiron, the points, the lots, and the three moderns) **HAS** a bearer and
  **IS** never a bearer: leaf-only, hanging off the seven-node subgraph as pendants. Getting this
  wrong is the likeliest way to produce an infinite walk or a chain terminating somewhere doctrine
  does not recognize.
- **The two named chains are SELECTIONS, not code.** The engine gives every occupant its bearer, path,
  keeper and terminal kind. **Agency** starts at the natal ASC ruler, **light** at the sect light.
  The charged event stays a comparison: Keeper of Agency == Keeper of Light.
- **Sect lives one layer up**, in the join, because it needs the Tympan. The placeless wiring layer
  cannot have it.
- **REFUSES:** the Tympan, place, time, the Ring, aspects, orbs, sect, and the modern ruler table.

## The AstroState compiler and its shapes (specced 2026-08-03)
Source of record: the user's AstroState Compiler spec plus the mocked shapes in `uploads/01_AstroState.md`
through `07_RegulatorySnapshot.md`. **`express(astroState, tympan)` \u2192 a frozen `Expression`.**
Independently arrived at the same architecture as the Connectome plan above; adopted with the edits below.
- **Adopted as-is:** the stage order (normalize \u2192 tables \u2192 graphs \u2192 topology \u2192 indexes \u2192 metrics \u2192
  freeze) \u00b7 zero interpretation, with a TESTABLE forbidden-word list ("good" "bad" "strong" "weak"
  "fortunate" "difficult"), grepped against the module's own source, because a claim in a header
  enforces nothing \u00b7 static and dynamic mode behind ONE API, so no downstream system knows whether a
  snapshot came from a birth or a clock tick \u00b7 **"Caching is optional. Correctness is mandatory."**
- **NAMING (ruled 2026-08-03): the frozen per-state object is the EXPRESSION**, not the "regulatory
  snapshot" or the "compiled snapshot". One bare noun, in Orbo's register (Ring, Tympan, Loom, Embryo,
  Spine), and **already the codebase's own word**: `astrodna.js` says "EXPRESSION LEVELS, not genes"
  and "the expression is total". That narrower usage is not a collision, it is a SUBSET: speed,
  speedRatio, isStationary and the extras are part of the expression. It also says the right thing,
  that the Expression is what the genome DOES rather than an authority governing it. **The genome is
  the gene; the Expression is what it expresses.** The verb is `express`, `RegulatorySnapshot` retires
  as a shape name, and "snapshot" is not Orbo vocabulary anywhere.
- **`PlanetNode` carries BOTH `astroDNA` (the 0-719 gene) and `longitude` (the float).** This is the
  right answer and it closes the one place the spec would otherwise break a downstream engine: the
  gene is the IDENTITY, the float is the MEASUREMENT SOURCE, and aspects need precision the gene
  cannot hold. `sign`/`degree`/`retrograde` derive from them. Every Expression must carry the float.
- **THE FRAME IS AN ARGUMENT, never read out of the astroDNA.** Deriving the whole-sign house from
  the AstroState's own Ascendant violates the natal-whole-sign law: a synchronic Expression would house
  synchronic placements off a derived ASC. Passing the Tympan in preserves "identical output regardless of
  source" BETTER than reading the ASC does, because reading it forces a per-source rule, which is the
  one thing the spec forbids. A parameter is not a branch.
- **`AstroState.astroDNA`'s eight (the 7 traditional + Ascendant) is the WIRING'S MINIMAL SUFFICIENT
  INPUT, not a revision of the twelve genes.** It confirms the chain needs nothing else. But Stage 4
  breaks the moment a leaf is added unless the **two node classes** are named: a naive walker will
  route Mars to Pluto. `PlanetNode` therefore needs `dispositorCapable`.
- **`source` and `timestamp` live in `metadata` ONLY and no stage may read either.** The mockup already
  puts them there, which is the fix: harmless as provenance, fatal the first time a stage branches on
  them, because "all compile identically" dies that day.
- **`stateKey` is `sequenceString`; `topologyKey` is a LABEL and never a cache key.** Identical
  topology is not an identical Expression \u2014 two charts can share a dispositor graph and differ in every
  degree, so topology-keyed caching returns correct wiring with wrong longitudes. Same genome, same
  Expression, byte for byte.
- **`DispositorCycle.id` must be DERIVED from its sorted members**, never a counter. An iteration-order
  id makes two expressions of the same genome differ, which silently breaks byte-identical output.
- **`PlanetChain` gets `bearer` and `keeper` explicitly.** Bearer = immediate dispositor, Keeper =
  terminal ruler or the loop it closes into. The pane's sentence depends on the nouns, and doctrine
  names them; `terminalType` + `distanceToCycle` are kept as-is (good names). A chain also exists for
  every LEAF occupant, so its start field is a body, not a planet.
- **`02_Sign_Rulers.md` indexes signs 0-11 and must be 1-12** per the numbering law: a sign is an
  ORDINAL (Aries is the FIRST sign), not an address. The array is indexed `ordinal - 1` in exactly ONE
  accessor and nowhere else.
- **CUT most of Stage 8.** The graph is too constrained for network statistics to carry information.
  **Outbound degree is always 1** on a functional graph, in every chart, forever. **Density** is a
  lossy re-encoding of a number stated better as "how many planets are in domicile" (edges = 7 minus
  self-loops). **Diameter** is `max(distanceToCycle)`, already present. **Centrality is a ranking with
  a mathematical alibi** \u2014 the moment an Expression carries one, "do not score or rank" is over in
  practice with no forbidden word anywhere; its honest content is inbound degree and descendant count.
  KEEP: path length, descendant count, inbound degree, cycle membership, fixed-point membership,
  house routing load.
- **Retrograde is metadata TO THE TOPOLOGY and a first-class CONDITION on the node.** Motion never
  changes who disposits whom (the Ring's own ruling: relation is over 360), but two natives with Mars
  at 0 Aries, one retrograde, are not in the same condition and the vocabulary has to say so.
- Mechanical trap in Stage 1: **validate the STATE before reducing it**, never the degree it reduces
  to. `720 % 360` is 0 and silently reads row 0.

## The House Routing Graph (the spec's addition, 2026-08-03)
`HouseNode{house, sign, ruler, rulerHouse, destinationHouse}` plus the `housesRoutingToHouse` index.
**A second graph, the twin of the planet graph, and the structure behind "what routes into the 7th."**
- Each house has exactly one sign, one traditional lord, and that lord sits in exactly one house, so
  it is **also a FUNCTIONAL GRAPH** \u2014 on twelve nodes instead of seven, with the same guaranteed
  decomposition into components each holding exactly one cycle, and the same ONE termination rule.
  Its fixed points are "ruler in its own house"; its cycles are the topic-level counterpart of mutual
  reception.
- Unlike the planet graph, its **INBOUND degree genuinely varies** (Mercury ruling two signs means two
  houses route to Mercury's house), which is what makes **house routing load** a real measurement
  where most of Stage 8 is not.
- **It belongs to the JOIN layer, not `dispositor.js`**, because it is derived from the planet graph
  PLUS the Tympan (house \u2192 sign \u2192 lord \u2192 lord's house). That keeps `dispositor.js` testable with no
  frame at all, and it means a placeless field gets a full planet graph and NO house graph \u2014 the
  honest answer rather than a mode.

## The lots on the plate, and the chip-ring law (built 2026-08-05, v0.882)
Verified in `tests/lots.test.html` (20 checks). Snapshot: `archive/Orbo Astrolabe 2026-08-05.dc.html`.

**A LOT LIVES IN ASTRODNA, NOT IN EPHEM.** `astrodna.lots(asc, isDay, pos)` plus `astrodna.LOTS` are
the app's one lot arithmetic. The eight take no jd and no place: a lot is an arc measured between
degrees that are already decoded, so it is an EXPRESSION of a moment and not a reading of the sky.
ephem is the generator; astrodna is what the genome says. Consequences, all asserted by the test:
- `extras.lots` carries all eight off the same decode as `extras.bodies`, and `extras.angles.fortune`
  is now that set's own Fortune rather than a second call, so the two can no longer drift.
- `zr.computeLots` reads a genome and settles sect, then delegates. Its `LOT_ORDER` IS `astrodna.LOTS`:
  one list, not two. `zr`'s private `house8Cusp` is gone (Death takes the WHOLE-SIGN 8th cusp, which
  is the same whole-sign law the houses are read under).
- `ephem.partOfFortune` stays as Fortune's own leaf (the spine's degraded no-genome path still needs a
  door) and agrees by construction. That path now prefers `astrodna.lots` and falls back to it.
- Reaching them: `spine.posAt().full`, `_posAt`, and `_natalPos` all carry the eight. Nothing computes
  a lot in a reader, by the single-door law.

**The lots keep Fortune's own glyph.** `GLYPH` gives Fortune the symbol it has always had (the one lot
that has one) and the other seven a two-letter monogram in the Vx/MC/Ds line (Sp Er Nc Cg Vc Nm Dt);
the name under the chip carries the word either way, so the ring never rests on a monogram being read.
`PERIODS` is the Ascendant's own day
(Fo Sp Er Nc Cg Vc Nm Dt), **which retires Fortune's \u2297**: a lot IS a derived point, one language for
one family beats one engraved exception, and a second \u2609 on the wheel would read as the Sun. `PERIODS`
is the Ascendant's own day (a lot is asc-speed) and every lot is in `NO_RX`, `_precision`'s arcmin
ceiling, and the angle-derived list that suppresses meaningless ingress timelines. `LOTG` (the planet
glyph per lot) is untouched and still serves \u2650 Releasing, where provenance reads better than a monogram.
- **Lots are NOT in the \u2650 Field scan** (`_synEvents` filters `LOT_SET`). A lot laps the zodiac daily,
  so its flips and ingresses would carry a cardinality nothing else in the table has, and that is a
  doctrine question rather than a rider on a display pass, and it is written up for the reader in
  `docs/Orbo Glossary.md` under ♊. Fortune rode that list before only because
  it was the one lot on the plate.

**THE CHIP-RING LAW.** A chip ring is a CIRCLE: one radius for every chip on it, and the radius is
DERIVED, not typed. `_chipPos(angle, disc)` puts the disc's outer edge `_CHIP_AIR` px INSIDE the socket
band's inner edge (`_SK_R1`), measured off `this.w`, because a chip is fixed px inside a percent frame
and the plate is fluid. The air is generous (13px) on purpose: with the field's caption gone the well
has room, and a ring should read as engraved inside the sockets rather than jammed against them. Widen
it and every ring moves together, by law. Discs are 26px (planets) and 24px (the rest), glyphs 16/14/13
and names 7.5, all sized up once the centre emptied.
inner edge (`_SK_R1`) with a hairline of air, measured off `this.w`, because a chip is fixed px inside
a percent frame and the plate is fluid. The DISC is the positioned element (its own centre, not a flex
box's), which is what makes tangency exact rather than approximately right by label height, and the
label hangs off it toward the plate's CENTRE (`ch.lab`): under the disc on the top half, over it on the
bottom half, where "under" used to point the bottom row's names out at the AEGIS pill.
- **What this deleted: `_poleR`.** It pulled chips toward the equator to dodge the top socket and
  AEGIS, and the dodge cost the ring the one thing it was for. Saturn and Jupiter came off their
  domicile radius (they read as a flat horizontal row), the five objects stopped looking 72\u00b0 apart, and
  the points ring still had two chips sitting ON the poles. No dodge is needed: every socket's inner
  edge is at ONE radius, so a chip flush against it clears all twelve by construction.
- **Measured, not eyeballed** (via `__orbo.setState`, at rest \u2014 mid-flip the perspective distorts every
  reading, which is what makes a hasty measurement look like a bug): radius spread 0.02 percentage
  points across a ring, every ring's disc edge at 25.66\u201325.67% against the band's 26.4%, every label
  inward, all four rings on the same engraved line.

**\u264a is four sockets now: Planets \u00b7 Objects \u00b7 Points \u00b7 Lots.** Points is three chips (Nodes, Lilith,
Vertex) phased 120\u00b0 from 9 o'clock; Fortune moved to Lots, where it belongs. **Each lot rides its own
planet's domicile seat** (`LOTP` \u2192 `DOM_SIGN`: Fortune on the Moon's Cancer, Spirit on the Sun's Leo,
Death on Pluto's Scorpio), so \u264a's two chart rings are the same twelve spokes read twice, and Uranus's
and Neptune's seats stay empty because no lot is theirs. `DOM_SIGN` is the one seat-per-planet table,
read by the planets ring and, through `LOTP`, by the lots.

**A MODE TABULA IS ITS OWN TITLE.** \u264a's four sockets configure the wheel and their chip rings say what
they do, so the field is the term alone, CENTRED, with nothing under it (`tabTermBare`). An `item`
tabula keeps the full glossary entry. \u264d Aspects and \u2651 Gears are the same `kind` and would read more
consistently the same way; **not yet, by the user's call.**

## The Connectome rulings pass (5.1, docs only — 2026-08-05)
Full record: `specs/The Connectome Pass.md`. This section is the ruling authority the Tympan pass (5.2)
and everything after it must agree with; it supersedes nothing above but resolves two open items and
settles vocabulary the 2026-08-03 sections used loosely.

**Scope correction: the sun/moon law is about the FACE, not code layering.** It governs what the native
sees and where a way of looking lands. It says nothing about where code lives. **The Connectome is
beneath the face** — both the astrolabe and the pull-up read it, neither owns it, exactly as both read
the Ring. Never call the Connectome moon-side.

**Ships as the die, filled at engrave.** The Tympan ships full: all twelve frames exist before any
native does. Engraving does not fill it, engraving **selects** one. The walker and the compiler ship as
the function, nothing to fill. The natal Expression and the engrave-time aspect list are the one place
"empty tables filled once" is literally true.

**Vocabulary, settled:**
- **Essential dignity** is the ladder a placement has by its own position: domicile · exaltation ·
  triplicity · bound (term) · face (decan). Debilities: detriment · fall. Absence: peregrine.
- **Reception is not a dignity, it is a relation mediated by one.** A sits where B has dignity, so B
  receives A; `kind` names the mediating dignity (domicile · exaltation · mixed). **Mutual reception by
  domicile is exactly the two-planet cycle in the dispositor graph** — one stored row, no separate mark.
- **Triplicity = groups of three signs = the element grouping. Quadruplicity = groups of four signs =
  the modality grouping.** `rulers.js`'s `triplicity` layer is the classical triplicity-RULERSHIP scheme
  (day/night/participating lord). In the UI the words are **element** and **modality**; `triplicity`
  stays reserved for the rulership scheme.
  - **CORRECTION, 2026-08-05: this entry asserted "correct as written" for a layer that did not exist.**
    Bound, face and triplicity rulership were nowhere in the codebase — `rulers.js` had only sign-level
    dignity and `lordOf` — until the review pass caught the gap and built the ladder the same day
    (v0.885): Egyptian bounds, Chaldean faces, Dorothean triplicity, per `uploads/Orbo Traditions.md`
    (the Ptolemaic bounds are the named alternate, deliberately NOT built — a doctrine switch changes
    `_doctrineKey` and rebuilds every fertilized century, which is worth its own day). Full account in
    `specs/The Connectome Pass.md` §8. **A claim written here is not a substitute for the file existing
    — this doc records rulings, it does not implement them.**
- **Terminal kinds**, one termination rule, length names the result: 1 = **domicile** · 2 = **mutual
  reception** · 3+ = **dispositor loop**. Never "closed circuit", never bare "cycle" (collides with
  ZR's cycle).
- **Bearer** = immediate dispositor. **Keeper** = terminal ruler, or the cycle it closes into.
  **Governor/government** stay the general words for the traditional backbone (`governed` = the
  traditional dispositor changed). **Modern is the co-ruler** — `co-governor` retires as a duplicate.
- **Depth levels are L1, L2, L3, exclusively and everywhere.** Build steps are named, never numbered
  with an L — the two vocabularies must not collide in conversation.

**The four resolutions, and the key that was double-named.** `spine.at`'s sample identity is the
instant; chart identity is the genome (arcseconds); artifact keys are named cuts of the genome. The
Connectome adds one more cut and resolves a standing contradiction (CLAUDE.md said `topologyKey` is a
label and never a cache key; the rewire §5 said the cache key is the sign vector — both right, about
two different keys wearing one name):

| resolution | what it is | role |
|---|---|---|
| genome | arcsecond sequence | provenance on metadata. No stage may read it. |
| **frame vector** | sign ordinals + one sect bit | **the Expression's cache key** |
| graph topology | cycles and fixed points | a label. Never a key. |

The frame vector is one sign ordinal per occupant in the declared set, in declared order, plus a **sect
bit** (sect can differ between two samples sharing a sign vector, inside the horizon window — without
the bit the memo serves the wrong light chain silently). Motion is reduced out by law (retrograde lives
in the gene's upper half; keying on it would double the recompile count for no reason). The occupant set
is a build parameter, in the version component, never in the vector itself.

**Sign resolution, by law: a node carries no longitude, no exact degree, no retrograde flag.** Degree
resolution destroys the memo — a longitude on a node means the record changes every sample. Retrograde
isn't dropped, it's upstream (the gene's upper half, `isRetrograde`); speed, exact degree, retrograde and
aspects are read live from the spine and joined at the reading.

**Sect comes from the floats**, never the whole-sign house: the Sun-rising/setting-sign window (~2hrs
twice a day) makes the whole-sign 1st disagree with the true horizon, and it flips the whole light chain
and every lot. Same pattern as `astrodna.lots`'s `isDay` argument, one layer up.

**Occupant set:** the twelve genes plus slow extras (Chiron, Lilith, the nodes) are IN the Expression;
lots are NOT (Ascendant-speed, ~2hr sign changes would blow up the cache) — their bearer/house are read
live at the reading, same as retrograde and speed.

**Twelve nodes occupy, seven planets govern.** Only the seven traditional planets are dispositor-capable
(exactly one outgoing edge each); everything else (Ascendant, outers, nodes, Chiron, Lilith, asteroids,
points, lots) has a bearer and is never a bearer. Out-degree one on the seven ⇒ the graph is functional
⇒ termination is guaranteed mathematically, one pass over seven items. `PlanetNode` needs
`dispositorCapable` or a naive walker routes Mars to Pluto.

**Modern rulership stays open as a co-ruler annotation now** (nullable `coRuler` per node, `coRules`
houses per frame) — readable and sayable, never handed to the walker. Later, if wanted: a second
functional graph, modern-only (Scorpio→Pluto, Aquarius→Uranus, Pisces→Neptune instead of the traditional
lord), crossed with the traditional chain the way doctrine already crosses edge types. **Never a
weighted edge** — "real but weaker" is a strength claim and belongs to interpretation packs, never the
graph.

**Persistence, three ways**, keyed on frame vector × doctrine version × codec version (so a doctrine
change misses and rebuilds rather than serving stale wiring):

| what | where |
|---|---|
| the natal Expression | persisted, `orbo.connectome` |
| favorited charts' Expressions | persisted, same store |
| moment Expressions | RAM memo only, evicted freely |

**Nothing synchronous is added to engrave.** First read compiles (microseconds); idle warm after mount,
off the critical path, cancellable, released in `componentWillUnmount`. Acceptance for the seam pass
(5.5) includes: onboarding timing does not move, measured.

**If a pattern requires derivation, a table is missing.** Mutual reception is a 2-cycle row; Keeper of
Agency == Keeper of Light is two cycle ids compared. No pattern layer, no reading module — when a
pattern can't be expressed as a field read, add the row.

**The walker's input is a sign vector (an occupant-to-sign map), not a sequence.** A synchronic or
composite placement set never passes through the sequencer (`buildAstroDNA` needs a jd/place/ephemeris;
a synchronic placement is `midpoint(natal, sky)` per occupant — a list of longitudes, not a sequenced
moment). A sequence PROJECTS to the map; natal arrives via the projection, every other layer arrives
directly, with no adapter. The walker's input IS the frame-vector cache key — no second projection
step, so the two can never disagree.

**The layers, and which Tympan each gets:**

| layer | occupants | Tympan | sect | persisted |
|---|---|---|---|---|
| natal | the genome | its own | its own | yes |
| sky / transit | the moment | the native's | the native's | no |
| synchronic | midpoint(natal, sky) per body | the native's, always | own Sun vs own Asc (§3.13) | no |
| composite | the midpoint chart | its own ASC sign | its own | yes, for a saved pair |
| mundane, placeless | the moment | none | none | no |
| synchronic synastry | two synchronic sets | each native's own | each native's own | no |

Synchronic placements are always housed in the native's own natal frame, never a derived one — this is
why the Tympan is a parameter and not derived from the occupants' own Ascendant. A composite is the one
exception (it genuinely has a horizon). A placeless field gets a full planet graph and `houses: null`
(no agency, no light — both start from the Ascendant). Synastry needs no frame at all: a solo frame is a
chart (place + moment), a pair contact is an angle (time only).

**Three uses of an Ascendant, and only one is fixed** — HOUSING (fixed, natal, never derived) ·
SELECTION (legal on a moving Ascendant: rising-lord scan, composite chronology's cASC handoff) · LIGHT
(sect — also legal on a derived Ascendant). **A synchronic composite has its own sect**, from its own
Sun against its own Ascendant (supersedes the earlier lean of synchronic-Sun-against-natal-ASC): a
composite has a Sun and a horizon, those two give sect, and it costs the housing law nothing because
sect is a light question, not a housing question. Consequence: a synchronic reading can be nocturnal
while the native is diurnal, flipping the light chain and all eight lots — which is exactly why the sect
bit rides the frame vector. The synchronic clock's own scan (sASC as a moving occupant forming real
aspects) is a windowed generator in the shape of `luna.js`, never materialized, never fused — its own
pass, after this one.

**The interpretation boundary.** The Connectome records structure; packs speak meaning. Forbidden-word
list (`good` `bad` `strong` `weak` `fortunate` `difficult`) is grepped against the compiler's own
source — a claim in a header enforces nothing. Worked example: Venus in Aries and Mars in Taurus, both
in detriment, in mutual reception. The compiler stores only facts (each planet's sign, dignity
`detriment`, bearer, `receivedBy` with mediating dignity `domicile`, and a keeper that is their 2-cycle,
`kind: mutual-reception`) — the classical reading that reception mitigates the debility is an
assessment, and it lives in a pack that matches on the shape (2-cycle keeper + both members debilitated),
never in the compiler.

**Two member kinds, never conflated:** the **aspect lattice** (natal-only, needs floats, already the
genome's engrave-time aspect list) is a **fixed member** of the Connectome. The **Expression** (sign
resolution, memoized, compiled from occupants + Tympan + sect) is a **compiled member**. Naming both
stops someone "fixing" one into the other.

## The contract pass (2026-08-06, v0.886)
Full record: `specs/The Connectome Pass.md` §9. Three items off the review's own open list, landed
together because the first two both move the stored shape and the codec should bump once.

- **ONE TERMINATION RULE MEANS ONE TERMINAL SHAPE.** A fixed point IS a cycle of length 1, which
  `dispositor.js`'s header said from its first line while the walker declined to register it. It is
  registered like any other now, and **`keeper` is a `{kind, id}` record on both graphs** (planet:
  domicile · mutual-reception · dispositor-loop · house: own-house · house-exchange · routing-loop).
  So `indexes.cycleByPlanet` answers for a planet at home, and no reader infers a terminal's kind from
  the shape of a string. `terminalKind` stays beside it, being exactly `keeper.kind`, because every
  reader already spells it that way; absence is still `null`. **The VALUE of a domicile keeper did not
  change, its SHAPE did.** `connectome.CODEC` is 2. `topologyKey` does not move (it counts
  `terminalKind`, which already said `domicile`), and nothing else in the app keys on this.
- **THE EXPRESSION PUBLISHES ITS OWN CACHE KEY.** `metadata.frameKey` is the frame vector `express`
  memoized on, and `connKey` takes the Expression. The DC's `_connKeyFor` used to rebuild the vector out
  of `planetTable`, `houseTable[0].sign` and `light`: **a second projection of the one thing the
  Connectome pass §3.11 says must have exactly one**, agreeing only because sect and `light` happen to
  be bijective. The pre-compile form survives for a caller looking in the store before it compiles, and
  both forms go through one string builder.
- **A DELETED READER MAY NOT KEEP ITS NAME IN A LIVE SENTENCE.** `astrodna.js`'s header went on listing
  `rulers.lonsFromDna` as one of four readers that flatten a genome for a day after 5.3 deleted it,
  while `rewire-parity`'s own copy of the same sentence had been corrected. The instance is fixed; the
  guard is the point. `tests/rewire-parity.test.html` greps eleven sources and fails on any line naming
  a deleted reader without a sentence recording the deletion (±1 line, because a sentence wraps). **A
  header is where a deletion goes on living**, and the next reader cites it as current. Same defect
  class as "an invariant in a comment is not an invariant", from the other end.

## The cleanup pass (2026-08-06, v0.887)
Full record: `specs/The Connectome Pass.md` §10. Five items off the review's own open list. `connectome.CODEC` is 3.

- **THE `%23n` BUNDLER WARNING WAS A DATA URI EATING ITSELF.** The mater's dither is a
  percent-encoded `data:image/svg+xml` whose own `<rect>` carries `filter=%22url(%23n)%22`, a fragment
  pointing at a filter INSIDE that same data URI. The bundler's CSS `url()` extractor reached through
  the outer URI and tried to fetch `#n` as an asset. Nothing was ever broken offline; the warning was
  real work reported honestly about a reference that resolves inside its own document. **Fixed by
  base64-encoding the data URI**: byte-identical SVG, no `url(` substring left for an extractor to
  find, no new DOM node. A warning that is always a false positive gets ignored, and then it protects
  nothing.
- **THE STORE'S GROWTH VECTOR WAS NEVER THE CAP.** §3.8 named LRU and v0.885 shipped none, but the
  unbounded thing was rows under a key this build **can no longer form** (a doctrine change, a codec
  bump): no cap and no LRU can reach them, because nothing ever loads them again. `_connHydrate`
  DELETES those now, which is safe for exactly the reason leaving them was safe (they can never be
  served). Un-favoriting deletes its own row through `_connForget`, sharing `_connResolve` with
  `_connFavor` so a chart cannot be filed under one key and dropped under another. `_connPrune` is the
  backstop at 32 rows, and **`keep` is the natal Expression alone** so a session of favoriting cannot
  age out the row every sheet reads. An evicted favorite recompiles in microseconds, which is why a cap
  is safe at all: the row was a convenience that saves RESOLVING the chart through the spine, never the
  only copy of anything.
- **THE READ PATH COMPILES FIRST.** `_connFromMap` built a doctrine key and a fourteen-entry frame
  vector BEFORE reaching `express`'s memo, and `express` then built the same vector again. The memo
  goes first now; the store read stays (a store nobody reads is the hazard the review closed) and is a
  string concat off `metadata.frameKey`. It exists for OBJECT IDENTITY, so one Expression serves a
  chart for the session.
- **THE SIGN PROJECTIONS: 25 down to 9, and the nine are NAMED.** Every read that feeds a table goes
  through `_signOf`, including the two in `_specRows` that sat three lines from the Connectome path
  computing a sign two ways. What stays is three declared exceptions, and the COUNT is pinned in
  `rewire-parity`: **2 doors** (`_signOf`, the spine's own `sg`) · **5 predicate reads** (three `signAt`
  scans plus the crossing test, which compares two) · **2 formatters** (`_fmtShort`/`_fmtLong` need the
  sign AND the remainder off one normalization, and the door returns only the first half). Same ruling
  that keeps `_houseOf`'s rotation inline: arithmetic in a hot loop is not a second table.
- **FIVE OF THE SIX KEPT MEASUREMENTS WERE ALREADY INDEX READS; THE SIXTH BECAME A ROW.** Path length,
  inbound degree, cycle membership, fixed-point membership (free since a 1-cycle became a registered
  cycle) and house routing load are each one field read. **Descendant count needed a walk**, so
  `indexes.descendantsByPlanet` is a table now, which is §3.10 firing exactly once: if a pattern
  requires derivation, a table is missing. `planetsDisposedByPlanet` is the IMMEDIATE set and is a
  different fact; the two are not merged. The cut four (outbound degree, density, diameter,
  **centrality**) are asserted absent by grep, because a ranking with a mathematical alibi is the one
  that walks back in quietly.
- **THE SUITE SAID ALL GREEN WHILE THE APP DID NOT BOOT** (found and fixed the same day, v0.887). The
  bulk edits left a stray `0)]` and a duplicated `} catch (e) {}` in the DC's logic class; the class
  failed to evaluate, the template rendered with props only, the instrument never drew, and 822 checks
  passed. **Every DC assertion in the harness is a grep over the file as TEXT, and a SyntaxError passes
  straight through a grep.** `tests/rewire-parity.test.html` now opens with **STEP 0**: extract the
  logic class, compile it with `new Function`, and count the template's control-flow tags open against
  closed, BEFORE asking anything about what the source says. Same shape as the §8 harness hole (a suite
  with zero rows reading as `ok`) and the same lesson: a check that cannot fail on the thing that is
  broken is not a check.
  - **Never build an `old_string` out of grep output** — grep truncates its lines, and a truncated match
    replaces a prefix and welds the original's tail onto the replacement.
  - **A bulk edit is verified by PARSING, never by reading the diff.** Every changed line in that pass
    read correctly in isolation and the file still could not run: a brace balance is invisible line by
    line and obvious to a parser.

## The lunar pane's law · bands and templates (agreed 2026-08-12)
Every moon view is built from the SAME bands in the SAME order, holding ONE of five templates.
Zodiacal Releasing is the reference implementation: read it before designing any pane.
**The vocabulary is the user's; use these words and no others.**

```
header      the lit curved label on the limb (• ALMANAC, • RELEASING), neighbours falling off the edges
side rail   TABS · which page of this lens. Exclusive, vertical, left of the body.
chip rail   FILTER · what the current page shows. Its contents belong to the selected tab.
caption     ONE line, small caps, naming the current cut in words (ZR: "RELEASING FROM THE LOT OF
            SPIRIT · A NIGHT CHART")
body        exactly ONE template
legend      what the marks mean — said ONCE, at the bottom
provenance  method, sources, honesty
```
- **SIDE RAIL IS NAVIGATION, CHIP RAIL IS A FILTER.** Not glyph-vs-word (a rejected first theory), not
  small-set-vs-large. The rail switches pages; the chips cut the page you are on, so the chip set is a
  property of the selected tab. They compose: `CROSS` + the shared bodies, `REL` + the eight lots,
  `ECL` + solar/lunar. On the almanac's `ALL` tab the chips are the STREAMS THEMSELVES — muting a
  stream for a minute is a filter and must never be confused with unfusing it (which is what the ☑
  Gears chips on the back are reaching for from the wrong side).
- **Every side rail carries an `ALL`**, and it is the way back to the whole lens. On the almanac's
  `ALL`, `upcoming | calendar` are that page's chips: they are its VIEW, which is a filter of
  presentation, not a second navigation.
- **A band with nothing to hold is omitted, never filled.**
- **Legends live in the legend.** Anything printed identically on every row is a property of the GROUP:
  say it once at the bottom. "(fixed since birth)", "intersection", "3 streams fused" are all legend
  material that leaked into rows and captions. The almanac's colored row dots had NO legend at all
  while its caption spelled the count out in words — the legend `● releasing ● crossing ● eclipses`
  says both, and teaches the dots.
- **One template per body.** A pane needing two has two SUBGROUPS with subheaders, never two row styles
  interleaved.

### The five templates
Every surface in the pane is one of these. Every layout defect found on 2026-08-12 was a MISMATCH —
the right data in the wrong template — so name the template before drawing anything.
- **A · FACT** — one truth, now. `label · value`, one line. (Signification, To you, the big three.)
- **B · ROSTER** — a set of like things, no time axis, ordered by kind. `glyph · subject · state ·
  qualifier`. (Dyads, approaching contacts, the bodies list.)
- **C · LEDGER** — dated events in time order, each pinnable. `mark · what · when · rate · ⊕`.
  (Almanac, crossings, transits, eclipses, ingresses.) ONE implementation, everywhere.
- **D · SPAN** — start, end, nesting. `disclosure · glyph · level · start → end · badge · ⊕`, with a
  granularity rail. (ZR, clock stretches, house passages.)
- **E · TRACK** — a continuous quantity read AGAINST ITS OWN RANGE. The only template that is a
  drawing, because a number alone cannot carry a range. (sASC separation, σ, drift, speed of
  perfection.) **`_sheetDataCross`'s "right now 35.8° apart" is E rendered as A**, which is exactly why
  it has no origin, no range and no direction: A has no room for them.
- **REST FOLLOWS TEMPLATE, NEVER PANE.** A/E → crest · B/D → facts rest · C → eclipse rest. So the same
  information sits at the same height everywhere it appears (crossings sit low in the almanac, so they
  sit low in Synchronic). The pair panes are currently at C's rest showing B's content, which is the
  "all over the place" feeling; there is also no room for a chip rail inside the limb's curve at the
  eclipse perch, which is why the pair panes never grew one.

### Etch follows fuse (the almanac is a reader, not a lens)
`natal`, `sky`, `rete`, `releasing`, `rising lord` are one subject read one way. **The almanac is one
way of reading many subjects** — the ledger over the spine, a container whose occupants are the fused
streams, the same class of thing as the plate and the rete. So:
- **Fusing a stream ETCHES the almanac; unfusing the last one un-etches it.** Fusing is the most
  deliberate act in the app (it costs an unspool and is already persisted), so it carries the intent
  etching asks for. This does NOT violate the dock's three verbs: what the law forbids is OPENING
  force-etching — merely LOOKING must never keep. The almanac therefore needs no etch control of its
  own, which is the right resolution of "there is no way to etch the almanac."
- **DEAD ETCH CONTROLS, found 2026-08-12:** `almPaneLabel`/`almPaneCol`/`almPaneBd`/`almPaneBg`/
  `toggleAlmPane`, and the same sets for `election`, `prog` and `rising`, are computed in `renderVals()`
  and referenced NOWHERE in the template. The "+ Etch to the pane" affordance the logic believes it
  offers does not exist on screen; the only wired path is the tabula rune on the back. The
  `frameOffset` lesson for the fourth time: a value computed and not recorded is invisible to every
  reader. Bind them or delete them, and put the verb on the dock — **tap a dotless crown chip to etch,
  hold an etched chip to drop** (symmetric, both at the dock, the dot becomes the control).

### Naming
- **DYADS**, never "our dyads" — the word already implies it. Subheader: `DYADS · SAME BODY, TWO STATES`.
- **APPROACHING**, never "what's forming" — it names why the rows are worth reading. Separating contacts
  dim in place rather than getting their own section; the ledger already owns the past.
- The dyad row's live fact is the pole and its expiry: `♀ Venus  conjunct until Aug 12, 2026`. The
  separation degree is fixed, derivable, and the least useful thing in the row — it belongs to the
  expanded single-body reading, not the roster.
- **`drift` is already spent** on `dialOf`'s degrees-walked-vs-time-elapsed. Never use it for the sASC
  separation; that band is `SPREAD`, which implies the range template E gives it.

### `exact to N°` is a mislabel (found 2026-08-12, unfixed)
`_almCross`'s row builds `'intersection · exact to ' + p.orb.toFixed(1)`, but `p.orb` is the orb NOW,
carried from the live in-orb list, while the time beside it is `p.exactJd`. **At an exact moment the orb
is 0 by construction** — that is what exact means — so the row welds a future timestamp to a present
separation and prints them as one fact. Same event reads `0.0°` in the Crossing pane and `3.0°` in the
almanac. At exactness the orb is not worth printing at all: print the SPEED (`within 1° for 4h`), which
distinguishes a slow wide Node contact from a Moon contact that is over in an hour. Related: the Sun
square North Node and South Node print as two rows at the same minute because the axis is stored as two
bodies; a ledger says it once.
