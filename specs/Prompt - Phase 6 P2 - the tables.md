# Prompt · Phase 6 · P2 — the tables (the Connectome members)

Plan of record: `specs/Phase 6 - The Synchronic Prism.md`, §3, §12(§13), §13.1–13.4. Requires P1 (the
seam) landed — this pass tables structure that P1's live refraction already computes correctly; it is
an optimization/permanence pass, not a new capability. Nothing in this pass should change what any
reading SHOWS; it should only change where the structure that reading relies on lives.

**The one sentence:** four facts about the sASC (and, by the same code, any occupant's arc) are fixed
the moment a chart is engraved and belong in the Connectome as a new member, `prism.js` — never
recomputed live, never a position table (§3's refusal stands).

Do NOT build the pane views (dial/ledger/query), electional, or synastry in this pass. Do NOT store any
lot arc — §14.2 is still open (which sect governs it) and storing one now would invalidate at doctrine-key
level the moment that ruling lands. This pass tables the sASC's own structure and the general arc/family
machinery every occupant already has a live form of; it does not resolve the lot question.

---

## 0 · Before anything

- Snapshot first, next free letter.
- Version bump per convention.
- Orbo never uses the em-dash.
- Read the Connectome's existing member modules (whichever `.js`/`.browser.js` pair currently implements
  the Connectome's key discipline — the codec versioning, the entrance test "fixed at engrave, never
  rebuilt") before writing `prism.js`. This pass's ENTIRE job is to match that existing discipline, not
  invent a new one. If unsure which file that is, grep for `CODEC` version constants and the Connectome's
  own key-building function first.

---

## 1 · What goes in `prism.js` (pure, no scanning, no ephem import)

Same header discipline as `framing.js`/`ring.js`: no import of `ephem`, no scanning. Callers hand in
whatever positions are needed; this module is pure geometry over a natal chart's own fixed values.

### 1.1 The arc, per occupant

`arcFor(natalLon)` — already exists per the plan (§1.1 references it as already used by
`synchronicTargets`). Confirm it, reuse it, do not reimplement. Bounds: `natalLon ± 90`.

### 1.2 The six sign boundaries inside the arc, with their readings

For a given natal longitude, compute the (up to six) sign-boundary crossings inside its arc, and for
each boundary, the STRUCTURAL reading fixed at engrave:

- the sign entered,
- the natal house that sign falls in (under the native's own whole-sign Tympan — reuse whatever house
  lookup the natal chart already has; do not write a second one),
- the domicile lord of the entered sign,
- whether that lord differs from the previous segment's lord (a boolean, "does the dispositor change
  here" — every boundary crossing changes sign, not every one changes lord if co-rulership/reception
  cases exist in this instrument's rulership table; check `rulers.js` for how lordship is read rather
  than assuming one-lord-per-sign naively if the codebase's own rulership handling says otherwise).

### 1.3 The reachable set, per occupant

The seven signs and seven houses a synchronic placement can EVER occupy — directly derived from 1.2 (the
starting sign/house plus the six crossed into). Store as a simple ordered list per occupant, not
recomputed.

### 1.4 The itinerary, for the sASC specifically (§13.1–13.2)

The sASC's own arc, walked as the SEVEN ORDERED SEGMENTS with:

- each segment's sign and (per §13.1's two-reading law) BOTH its natal house label and its synchronic
  house label (the synchronic house is always sequential 1→7 in itinerary order — do not compute it a
  second way, it falls out of the segment's position in the list),
- the domicile lord governing that segment (§13.3: "the Synchronic Ascendant Ruler"),
- the FRAME OFFSET for that segment, per §13.2's exact table: 0, −1, −2, −3, [flip], −9, −10, −11 → back
  to 0. Store this as data on the segment, not derived elsewhere.
- which of the two structural instants (if any) bound this segment: the anchor (start of segment 1) and
  the flip (the transition into segment 5, i.e. the entry to the natal 10th) — per §13.3, the flip is
  NOT a distinct kind, it is a transition whose step is 6 instead of 1. Model transitions as ONE shape
  (`{fromSegment, toSegment, step}`) with step as a data field, not two different transition types.

**Do not compute segment DURATIONS in this pass** (that's P3 — ascension-time arithmetic is a separate,
larger piece of work involving the native's latitude and is explicitly out of scope here per the plan's
build order). This pass tables which segments and their order and their readings; P3 tables how long
each one lasts.

### 1.5 The same-body families

`beadFamily` (or wherever `{δ/2, 180−δ/2}` already lives per the plan's §3) — confirm it already covers
this, since the plan states it's already built (`already beadFamily`). If it's genuinely already
correct and time-invariant, this pass may need NO new code here beyond confirming/testing it — do not
duplicate existing logic to make this section "have something in it."

---

## 2 · Storage: the Connectome's own key discipline

Follow whatever pattern the existing Connectome members use for build-time storage (grep for how e.g.
the fertilized weave's `fertKey` is built and invalidated, per CLAUDE.md's Fertilization section — same
class of discipline, adapted to this module's own key). The key must be natal identity × doctrine
version × this module's own codec version, so:

- A re-engraved chart misses and rebuilds.
- A doctrine change that moves any of §1.2–1.4's readings (e.g. a rulership-table change) misses and
  rebuilds — bump this module's own CODEC constant when you ship, the same discipline as `fertilize.CODEC`.
- Nothing else's key moves. Do NOT touch `fertKey`, `connectome.CODEC` (unless this module genuinely
  needs to register under it — check how other members register), or any other module's version constant.

**Do not build a generator/chunking mechanism.** Unlike `fertilizeChunks`, this is engrave-time
arithmetic over a handful of segments — cheap enough to build synchronously. If it turns out NOT to be
cheap (it shouldn't be), that's a signal something in this pass duplicated a scan rather than doing
fixed-point geometry, not a signal to add chunking.

Regenerate `prism.browser.js` from `prism.js` per the generated-files convention in CLAUDE.md — never
hand-edit the browser build.

---

## 3 · What P1 already built that this pass must NOT duplicate

- Live refraction (`midpoint(natal, sky)`) — P1's door, untouched, still the live path for anything not
  covered by §1's structural facts.
- The sASC's live position — still computed live via P1's door for the CURRENT instant. This pass tables
  where the arc's BOUNDARIES and STRUCTURE are, not a substitute for knowing where the sASC is right now.
- Lot positions — still refracted live per P1 (§14.2 still open).
- Seating, wheel drawing, the frame entry gesture — P1/P0b's, untouched.

---

## 4 · Acceptance, measured

1. **Universality check**, per the plan's own acceptance bar for P2: for every fixture natal in the test
   suite, the sASC's itinerary is the 10th through the 4th (in whatever house numbering the fixture's own
   natal ASC produces) — i.e., segments 1–7 land on natal houses {1,2,3,4,10,11,12} in that order for
   EVERY fixture, regardless of rising sign. This is the single most important test in this pass: if any
   fixture produces a different set of seven houses, something in §1.2/1.4 is wrong, not the fixture.
2. **Offset table check**: segment offsets are exactly `[0,-1,-2,-3,-9,-10,-11]` in order for every
   fixture, with the flip's step measured as 6 between segments 4 and 5.
3. **Engrave timing does not move**, measured before/after (per the plan's own acceptance line for P2) —
   time a chart engrave before and after this pass; this module's synchronous cost should be negligible.
4. **Rebuild-on-doctrine-change check**: bump this module's CODEC constant, confirm a previously-engraved
   chart's prism table is rebuilt rather than silently reused.
5. **No regression to P1's live readings** — spot check that live sASC position, live lot refraction, and
   the seated prism's web are unaffected (this pass adds tables alongside the live path, it does not
   replace P1's reading path with table lookups for anything P1 already computes correctly, per §3 of
   the plan's refusal of a position table).
6. STEP 0 of `tests/rewire-parity.test.html` passes. Full suite green, no zero-row suite. Add
   `tests/prism.test.html` (or extend an existing suite) with the universality and offset checks above as
   its own named assertions, following the existing test-suite convention (plain assertions, a visible
   pass/fail count) used by `tests/mundane.test.html`/`tests/fertilize.test.html`.

---

## 5 · Traps

- Never build an `old_string` from truncated grep output.
- Verify by loading/running the test suite, never by reading a diff.
- Do not let "the reachable set" (§1.3) silently diverge from "the itinerary" (§1.4) — the itinerary's
  seven segments' signs ARE the reachable set for the sASC specifically; compute the general
  per-occupant reachable set (§1.3) and the sASC's ordered itinerary (§1.4) off the SAME boundary list
  (§1.2), not two separate walks of the arc.
- Watch for co-rulership/dual-lord signs in `rulers.js` — if the instrument already handles a sign with
  two possible lords (traditional vs. modern), §1.2's "does the lord change here" must use whichever
  lordship reading the rest of the instrument already treats as authoritative, not invent a second
  convention.
- Resist storing anything that varies with TIME rather than with the chart alone. If a field you're about
  to store depends on `jd`, it does not belong in `prism.js` — it belongs live (P1) or in a future weave
  (P3+).

---

## 6 · Owed on completion

- `CLAUDE.md`: a short note under the Connectome section (find wherever the other members —
  `fertilize.js`, `luna.js`, `ring.js` — are each given a paragraph) describing `prism.js`: what it
  stores (arc, reachable set, itinerary, families), what it refuses (any position, any lot arc pending
  §14.2), and its key discipline.
- `specs/Phase 6 - The Synchronic Prism.md` §10: mark P2 done, with the universality measurement (which
  fixtures were tested and that all produced the 10th-through-4th itinerary) and the engrave-timing
  before/after numbers.
