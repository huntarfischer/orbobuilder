# Rewire · every angle table onto the Ring

Companion to `specs/Prompt - The Ring.md` §7 and §8.2. That file said "rewire readers onto the Ring,
delete the five duplicates" and left the sequencing open. This file closes it, on measured numbers
rather than argument.

Read `CLAUDE.md` first. Orbo never uses the em-dash, here or in chat.

---

## 0. Where it already stands

`tests/rewire-parity.test.html` is the harness, and it is the reason this whole job is cheap. It
reads every angle table **out of its own source file at run time** and compares it with the Ring, so
no table can drift away from what is checked. Step 0 (the harness), step 1 (`loom.ASPECT_NAME`),
**step A (`framing.ASPECTS`), step B (`astrodna.ASPECT_DEFS`) and step C (both decoders) — all done
2026-08-03, zero delta** — are green, 93 checks. **Step D (the DC's tables), D2 (the Mater), step E (the DC's loops) and steps F and G (the gene, the
node order and the two cache keys) landed 2026-08-04**, and the harness is at 166 checks, all passing.
The whole engine suite runs together through `tests/_suite.html`: 506 checks, zero failures.

Run it first, every time. As of 2026-08-03 it reports **all checks pass**, and its REPORT sections
already answer every open question in this rewire:

| question | measured answer |
|---|---|
| does the Ring's arithmetic equal the old arithmetic | yes, 49,623 pairs, max delta 8.3e-14 |
| does `framing.aspectBetween` change | no, 3,600 separations, every hit a mark, every orb the Ring residual |
| does `astrodna.calcAspects` change | no. 0 of 12 fixture pairs hold more than one row; 0 rows whose nearest mark differs |
| does the DC's readout change | not at rest. With every chip on, ONE band: 152.19 to 153.00 shows 150, nearest is 154.2857 |
| does the embryo rebuild | **no.** It stores the aspect ANGLE (`w.z(r.angle)`), never an index into an angle list. Only kinds, bodies, eclipse types and the two syzygy angles are index-coded, and the artifact ships its own header for those. Reordering a table cannot touch it |

**One caveat on "zero delta", measured after step A shipped.** An independent 246,344-pair sweep of the
new `aspectBetween` against the old formula in the live app found a worst orb delta of 8.4e-14 and
exactly ONE hit/miss flip: `a=43.40000000000003, b=37.4`, where the separation is `6.000000000000028`
and sits exactly on the `orb <= 6` cutoff. That is float noise from a changed evaluation order, not a
behaviour change, and no fix is wanted. But it is worth recording that **the harness measures maximum
delta only and would not have caught a boundary flip** — so "zero delta" is very slightly stronger
than what is actually measured. Later steps that move a comparison across a threshold should expect
the same class of one-in-a-quarter-million flip and not chase it.

So four of the five sub-tasks are provably zero-delta before a line is written. This is a
**refactor with a known answer**, not an experiment.

## 1. There are EIGHT duplicates, not five

The prompt named five. The harness found the rest:

1. `framing.ASPECTS` (five majors, with words and glyphs) — feeds `transits.js`, which re-exports it
   and needs no edit of its own
2. `astrodna.ASPECT_DEFS` (five majors with orbs 7/7/5/5/4, no minors)
3. the DC's four keyed tables: `this.ASPECTS` (colors), `ASYM`, `ASP_NAME`, `ASP_DEFAULTS`,
   `ORB_SCALE`, plus `MAJOR_ANGLES` (fourteen angles: eleven marks and three septiles)
4. `loom.ASPECT_WORD` — **done in step 1**, built by walking `MARKS`, throws at load on a mark with
   no word
5. `mundane.js` line 289 `ASPECT_WORD` — a **verbatim copy of loom's**, missed by the prompt. Exactly
   the drift the Ring exists to prevent, and the cheapest possible fix
6. `fertilize.js` line 205 `ASPECT_WORD` — **a second verbatim copy**, missed by this inventory's own
   first pass (see the correction below) and found only when step C's verification went looking for
   siblings of the table it had just fixed. Same eleven literals, same construct, same position four
   lines after its codec's `index()`
7. the DC's transit-lore table `L` at ~6907 (`{angle: {name, fam, gloss}}`) — an eighth angle-keyed
   table, decoration only
8. the DC's `_compPairs` inter-chart `MAJ` (`[[0, 'conjunct'], [60, 'sextile'], …]`) — a NINTH table,
   found only by step E on its way through the loops, and missed here for the same reason fertilize
   was: **it clusters by CONSTRUCT**, a keyed list sitting three lines above the loop that reads it.
   Third time that lesson has been paid for. Fixed in step E; see there.

`luna.js`, `electional.js` and `timespine.js` carry no angle table of their own (re-verified
2026-08-03; electional names conjunctions in prose only and reads `asp.angle` off framing).

**CORRECTION, 2026-08-03.** This section previously read "`luna.js`, `electional.js`, `fertilize.js`
and `timespine.js` carry no angle table of their own," and listed six tables. That was wrong about
fertilize, and wrong in the way an inventory is most expensive to be wrong: §1 is what steps D to H
are planned against, so a table absent from it is a table no step is assigned to. Two lessons worth
keeping, because both generalize past this one miss:
- **The tables cluster by CONSTRUCT, not by subject.** Both decoders sit immediately after a byte
  codec's `index()`, because both were written by copying the other file's codec. When one is found,
  grep for its siblings before believing a count.
- **The harness is the inventory, not this list.** A table the harness never fetches is a table
  nothing can catch, so the fix is not only to correct the prose: `fertilize.js` is now fetched and
  extracted here, and it joined the generic "extracted" and "no angle outside marks" loops the moment
  it was, which is what makes the harness header's claim (every angle table, against the Ring) true
  rather than aspirational.

## 2. The shape of every edit

One idiom, applied eight times. **Words, glyphs, colors, orbs and families stay exactly as they
are.** Only the KEY SET moves.

```js
// the narrowing is declared and CHECKED, never a coincidence
const ADMITS = [0, 60, 90, 120, 180];
for (const a of ADMITS) if (!MARKS.includes(a)) throw new Error('framing: ' + a + ' is not a Ring mark');
export const ASPECTS = Object.freeze(ADMITS.map((angle) => ({ angle, name: WORD[angle], glyph: GLYPH[angle] })));
```

Two rules that make this worth doing at all, both learned in step 1:

- **A table that omits marks must SAY SO and be checked.** `framing` and `astrodna` deliberately
  carry five of eleven; the harness's step-2 REPORT (marks not carried: 30 · 45 · 72 · 135 · 144 ·
  150) becomes a pass/fail check so the rewire cannot silently widen them.
- **A missing decoration throws AT LOAD**, never yields `undefined` at the moment a reader is reading.

### The septile gotcha, which will bite

The DC's three septiles are typed as **rounded literals** `51.4286 · 102.8571 · 154.2857` and are
used as OBJECT KEYS. `360/7` is `51.42857142857143`, so a computed septile does not match any key in
`ASYM`, `ASP_NAME`, `ASP_DEFAULTS` or `ORB_SCALE`. Keep the literals verbatim as
`this.SEPTILES = [51.4286, 102.8571, 154.2857]`, and have the harness assert each is within 1e-3 of
360k/7 and that none is a mark. Do not "tidy" them into expressions.

## 3. The order, and why it is this order

Everything except the last two steps is behaviour-preserving and touches nothing on disk. The gene
and the two cache keys are the ONLY changes that invalidate a stored artifact, so they go **last, in
one block, in the same session**. That is the whole efficiency argument: one spine rebuild and one
weave rebuild, not two of each, and no intermediate state where a user's weave is thrown away twice.

Snapshot `archive/Orbo Astrolabe 2026-08-03.dc.html` before the DC is touched (CLAUDE.md versioning law).

**A · framing.js** — **DONE 2026-08-03**
`import { MARKS, separation, arcOf } from './ring.js'`. `ASPECTS` is built from a checked
`ASPECT_ADMITS`; a member that is not a mark, or a mark with no word or glyph, throws at load. Words
and glyphs unchanged, table and entries frozen. `aspectBetween` measures `arcOf(separation(a, b))`;
the min-residual loop stays over the ADMITTED five (`ring.nearest()` would answer for marks this
reader does not carry). `transits.js` inherits it for free.
**Load-order fallout, fixed in the same pass:** `framing.browser.js` gained the `__ORBO_RING` guard,
and nine pages were reordered to put `ring.browser.js` BEFORE `framing.browser.js`. The guard alone is
not enough for a test harness: it defers boot to a `setTimeout`, so a page that reads
`window.__ORBO_FRAMING` synchronously at parse time sees nothing and dies before the retry lands. Two
harnesses (`loom-algebra`, `timespine`) did not load the Ring at all and would have spun `boot()`
forever in silence.
**NOT open · the archived DCs, checked and dismissed.** It looks as though ~24 snapshots in `archive/`
load the shared root `framing.browser.js` without `ring.browser.js` and would now spin. They do not.
An archived DC references its dependencies as bare sibling paths, which resolve to `archive/<name>`,
and none of those exist: `archive/Orbo Astrolabe 2026-07-29.dc.html` 404s on SIXTEEN files (support.js,
every `.browser.js`, three.global.js, the sphere texture, the logo) and renders as raw unresolved
template holes. **They never reach framing.browser.js at all**, so they were already non-loading long
before this change and for an unrelated reason. Framing gaining a Ring dependency is a non-event for
them. Do not add tags to frozen artifacts for zero benefit; if archived snapshots are ever wanted
working again, the fix is their sibling paths, not this.

**B · astrodna.js** — **DONE 2026-08-03** (zero delta, measured on the fixture)
Same treatment. `ASPECT_DEFS` is built from a checked `ASPECT_ADMITS` and keeps its own orbs
(7/4/5/5/7, an orb is the caller's by law) and its own words; a member that is not a mark, or a mark
with no word or no orb, throws at load. Distance is `arcOf(separation(...))`.
`calcAspects` took the **single-valued** form (min residual over the admitted five, one row per
pair) rather than emit-every-match: the fixture natal returns the same 12 rows as before, 12 of 12
pairs single-valued, every row the min-residual mark inside its own orb, and 0 rows whose nearest
mark differs. Min-residual over the ADMITTED set, not `ring.nearest()`, which would answer for the
six marks this reader does not carry.
**Load-order fallout, fixed in the same pass:** `astrodna.browser.js` gained the `__ORBO_RING` guard
and its tag moved below `ring.browser.js` in the DC; `tests/astrodna.test.html` and
`tests/rulers.test.html` did not load the Ring at all and now do. `tools/build-embryo.html` never
loads astrodna, so it needed nothing.
**Harness:** 15 new STEP B checks, and the two step-4 REPORTs on the fixture became pass/fail now
that the change has shipped. Green: rewire-parity, astrodna, rulers, timespine.

**C · the two decoders** — **DONE 2026-08-03** (zero delta, and both artifacts re-verified)
`mundane.js` **and `fertilize.js`**: `ASPECT_WORD` built by walking `MARKS` off `ASPECT_TERM`,
throwing on a gap. Verbatim of loom's step 1, with one difference that raises the stakes: these are
**decoders**. loom's missing word would be a missing word; a decoder's gets packed into a byte stream
and read back as the bare string `"135"`, with nothing thrown. So unlike framing and astrodna, these
tables narrow nothing — they carry the full eleven, and the checks assert that rather than a subset.
Neither file measures anything (the scanning is loom's), so there was no `separation`/`arcOf` swap.
**fertilize was not in §1's original inventory** — see the correction there. It is the more dangerous
of the two: mundane's wrong word is built once, in one artifact, in front of whoever ran the build;
fertilize's weave is rebuilt per chart and persisted in IndexedDB under `fertKey`, so a wrong word
would be cached in the reader's own browser and survive every later fix until the key changed.
**Load order:** already correct everywhere — `ring.browser.js` precedes framing/loom in the DC and in
all four harnesses and `tools/build-embryo.html`, and the DC reads the floor through `_loomFloor`,
never through mundane. Only the two `__ORBO_RING` guards were owed, plus `?v=` bumps.
**Harness:** 16 new STEP C checks, including a live round-trip of an aspect row on every one of the
eleven marks through **each** codec separately — fertilize's aspect row is a different byte layout
(it carries a half-window, and its dictionary is `targets`, the pair list, not `bodies`), so mundane's
round-trip proves nothing about it. No embryo loaded: 2.7 MB to assert eleven strings would be the
artifact testing itself. Green: rewire-parity (93), mundane (28), embryo (25, which decodes the
shipped 320,924-row table through the new dictionary), fertilize (38).

**D · the DC's tables** · **DONE 2026-08-04** (zero delta, measured against the pre-D snapshot)
The five keyed tables (`this.ASPECTS` · `ASYM` · `ASP_NAME` · `ASP_DEFAULTS` · `ORB_SCALE`) plus
`MAJOR_ANGLES` collapsed into ONE ordered spec, `this.ASPECT_SPEC`, rows
`[angle, color, glyph, name, onByDefault, orbScale]`, ascending. The five survive as DERIVED views
built by one walk, so no reader changed; the walk throws on an incomplete row and on a
non-ascending one. `MAJOR_ANGLES` is gone: the majors are framing's admitted five, read through
`_majorAngles()`, which also retired the two inline `[0, 60, 90, 120, 180].includes(ang)` literals in
`_synEvents` and the floor build. The lore table `L` is BUILT BY WALKING the spec (so its fourteen
NAMES stopped being a sixth copy; only `fam` and `gloss` are typed, and a gap in either throws).

**The one real decision this step forced, and it is a law, not a preference.** The spec says "walked
over `MARKS` concat `SEPTILES`". The instrument cannot do that. Every engine reaches the DC as a
plain `<script>` appended to `head`, which is ASYNC (this is why `componentDidMount` waits on all of
them and why nothing in the constructor has ever read a `window.__ORBO_*`), and the aspect web is
engraving drawn on the first frame, so by the instrument-survives-everything law it may not wait.
So the fourteen angles are DECLARED in the DC and CHECKED two ways: `_aspAudit()` runs once from
`componentDidMount` after the waits and compares the spec against `MARKS` concat `SEPTILES`, the
septile literals against 360k/7, the onByDefault column against `framing.ASPECTS`, the DC's sign
glyphs/names/elements against the Mater, and the `CO_RULER` separation, reporting only, because a
disagreeing table is a build error and never a reason to blank the wheel; and the harness extracts
the spec rows from the DC's own source. Declared and checked, never a coincidence. The same
reasoning is why the wheel keeps its own sign glyphs in D2.
**Zero delta is MEASURED, not argued.** The pre-D snapshot (`archive/Orbo Astrolabe 2026-08-04.dc.html`,
taken per the versioning law) still holds the five old tables verbatim, so the harness reads them out
of it and compares all 14 angles × 5 fields plus the five majors: identical. That is the one thing the
versioning law bought that no argument could.

**D2 · the SIGN tables, the MATER** · **DONE 2026-08-04**
`mater.js` / `mater.browser.js`, verified in `tests/mater.test.html` (49 checks) and by 16 STEP D2
checks in the rewire harness. Five stamped tables, frozen, imports nothing: signs (names, glyphs,
elements, modalities, the element and modality CYCLES rather than twelve typed rows) · traditional
rulership · the twelve house frames · exaltation with its degrees · detriment and fall derived at
stamp time and frozen. A load-time completeness check throws on a missing glyph, a missing element,
an exaltation with no degree, a frame not anchored to its own ASC sign, and, the landmine, on any
ruler that is not one of the classical seven.
- **Identity, not equality, is what the harness asserts.** `framing.RULERS === mater.RULERS`,
  `astrodna.SIGN_RULERS === mater.DOMICILE`, `rulers.EXALTATION === mater.EXALTATION`. Equal tables
  prove nothing; the same OBJECT proves nobody kept a private copy that agrees today.
- Rulership went from four copies to one, exaltation from three to one, `houseOf` from five to one
  (astrodna by sign index, framing by longitude, and three times inline in the DC). `framing.dignityOf`
  and `rulers.dignityOf` keep their own vocabularies at their own edges (`exaltation` vs `exalt`,
  `null` vs `peregrine`); the Mater speaks one, and absence is `null`, per the Ring's own contract.
- **The instrument keeps its own sign GLYPHS, sign NAMES and element COLORS**, deliberately, for the
  async reason above: they are drawn on the wheel on frame one. `_aspAudit` checks all three against
  the Mater at mount. Everything moon-side (`_rulerOfSign`, `_dignityOf`, `_houseOf`) reads the Mater;
  `_houseOf` keeps the one-line rotation as a degradation path, which is arithmetic and not a table,
  and the harness pins the count at exactly one occurrence in the file.
- **The co-rulership boundary survived verbatim** and is now asserted three ways: the DC's `CO_RULER`
  is still a sibling display table, no modern attribution appears anywhere in the Mater (source and
  live), and a merge would throw at load rather than quietly rewriting dignity, the chains, the
  rules-houses loops, ZR period lengths and the election engine.
- Load order: `mater.browser.js` sits beside `ring.browser.js` (it imports nothing), and
  `framing.browser.js`, `astrodna.browser.js` and `rulers.browser.js` gained the `__ORBO_MATER` guard.
  `rulers.js` is no longer zero-dependency: it has exactly one, and that one is a floor.
  Ten harnesses and `tools/build-embryo.html` load it; `?v=` bumped on the three rebuilt engines.
- Green after the pass: rewire-parity (122), mater (49), astrodna, rulers, timespine, loom,
  loom-algebra, mundane, embryo, fertilize, luna. The DC's own audit reports zero disagreements live.
- NOT built, as instructed: the Connectome compiler. D2 stamped the tables it will read.
- **OPEN, flagged rather than decided: `mater.HOUSE_FRAMES` vs the planned Tympan.** D2 listed the
  twelve frames as Mater table 3 and that is where they are, as the FORWARD stamping only. CLAUDE.md's
  Tympan plan names the same twelve frames its own and adds what D2 deferred: the reverse index and the
  separate modern co-governor index. Nothing is duplicated today (all five old forward copies are
  deleted, not left as fallbacks), so this costs nothing now. When the Tympan is built it should ABSORB
  `mater.HOUSE_FRAMES` and `houseOfSign` rather than stamp a second set: one die, whichever file holds it.

**On the name** (kept as written, since it is now the code's own vocabulary). `frame` is spoken for (composite framing, and the twelve house frames are only one of
five tables here). Skeleton, chassis and structure are all *engineering* words in an instrument that
otherwise speaks brass: aegis, tabula, rete, limb, plate. **The mater is the astrolabe's own body** —
the dished disc that is engraved once and into which every plate seats. It is not taken, it is the
right register, it says *the thing everything else sits in*, and it pairs with the Ring as an object
rather than as a metaphor. Fallback if it reads too obscure: `Skeleton`.

**FIVE stamped tables**, all pure, no arguments, no time, no native:
1. **signs** · twelve names, glyphs, elements, modalities
2. **rulership** · traditional, the backbone (the modern set stays a separate DISPLAY table)
3. **house frames** · twelve 12-element arrays stamped at load (144 bytes; a lookup, not a modular
   rotation per call, which is the Ring's own philosophy)
4. **exaltation** · sign AND exact degree (Sun 19 Aries, Moon 3 Taurus, and the rest)
5. **detriment and fall** · derived at stamp time as the oppositions of rulership and exaltation,
   then frozen, so the derivation happens once and readers get a table

Pure de-duplication only. **The co-rulership boundary is a landmine and must survive verbatim:** the
DC's sibling modern table (~1746) is DISPLAY ONLY, and merging Pluto into the traditional table
silently rewrites dignity, disposition chains, the rules-houses loops, ZR period lengths and the
election engine. Assert the separation in the harness. Do NOT build the Connectome compiler here.

**E · the DC's loops** (the real prize) · **DONE 2026-08-04** (one band moves, as measured; nothing else)
Snapshot `archive/Orbo Astrolabe 2026-08-04b.dc.html` first (the pre-D snapshot `2026-08-04.dc.html`
is also the pre-E one, and the harness reads BOTH out of it, so it could not be reused).

**There were TWENTY-TWO, not eight, and the count is now a measurement.** The harness reads the pre-E
snapshot and counts the loops it replaced: 22 in the archive, 0 in the working file. The eight §3 named
were the ones a human had noticed; the rest were the same construct wearing three other coats, which is
the §1 lesson a third time.
- **break-on-first-match** (9): `_aspectSnapshot` twice, the sky web, the natal web, the bead↔bead and
  bead↔natal thread families, and the three `_lineDyn` thread builders (ambient, held-hand, B-plate).
- **best-tracking, already min-residual** (6): `_applyMagnet` twice, `_applyBeadMagnet`,
  `_aspectStatus` twice, `_beadStatus`. These moved for the measurement, not the decision.
- **emit-EVERY-match readouts** (4): `_natalAspectList`, `_transitsToNatal`, `_aspectListFor`,
  `_toYouList`. These are the ones worth stating plainly: in the one overlapping band a single pair
  could emit TWO rows, so a ledger could read "☍ Mars 2°30′" and "✧ Mars 1°47′" for one pair. They are
  single-valued now, on astrodna's step-B precedent (one row per pair).
- **not converted, deliberately** (2, in `_checkTicks`): asking whether an exact angle was CROSSED
  between two frames is a sign change in the residual, not a nearest-mark decision. It keeps its own
  walk over the enabled set (now `_aspEnabled()`), and its 6° is a pre-filter, not an orb.

Two methods own it, exactly as planned: `_arc(a, b)` → `R.arcOf(R.separation(a, b))` and `_aspHit(arc,
cap)` → the nearest ENABLED angle inside its own orb, or `null`. `cap` is how the two snap magnets pass
their 1.5° catch-window. `_aspEnabled()` resolves the enabled set and each orb ONCE, memoized on the
`aspOn` object identity and the orb value, because this runs for every pair on the wheel every frame;
the old `_aspects()` door is gone, so there is one enabled set and not two, and `_orbFor` now appears
exactly once in the file, as its own definition.

**Why NOT `ring.nearest()`, stated because it will come up again.** nearest answers for all eleven
marks. A reader answers for the angles the native has ENABLED, which is a different question, and that
set includes the three septiles, which are not marks at all. The arithmetic is the Ring's; the cut is
the reader's, because an orb is the reader's by law. Same reasoning as framing's and astrodna's
min-residual-over-the-admitted-set in steps A and B.

**The falsy-zero contract crossed the boundary with it.** A hit's `angle` is 0 for a conjunction and
its `residual` is 0 when exact, both falsy, so every call site tests the HIT object. The harness carries
the tripwire (`if (hit.angle)` would silently drop the commonest aspect in the app).

**A NINTH angle table, found on the way in** (`_compPairs`, the inter-chart grid): a typed
`[[0, 'conjunct'], [60, 'sextile'], …]` three lines above its loop, with its own words and its own 3°
orb. Missed by §1 exactly as `fertilize.js` was, and for the reason §1 records: **the tables cluster by
CONSTRUCT.** The angles are `_majorAngles()` now and a gap in either its word or its family table
throws; the WORDS stay its own, because an inter-chart row is spoken "conjunct" and "opposite" rather
than "conjunction". Its hardcoded 3° is flagged in the harness as STILL OWED and deliberately NOT
changed: an orb is the reader's, and moving it onto `synOrb` is a doctrine call, not a refactor.

**What moves, measured against the pre-E snapshot on the same numbers the step-4 REPORT used:** at rest,
with the five majors enabled, first-match and nearest agree on every arc, so no reader moves at all.
With every chip enabled, exactly ONE band, 152.19° to 153.00°, stops reading quincunx (150°) and starts
reading triseptile (154.2857°), which is the nearer mark. Both facts are pass/fail checks now, not
reports.

**The degradation path, and why there is one.** `_arc` falls back to `Math.abs(this.wrap(a - b))` when
the Ring has not landed, for the same reason `_houseOf` keeps its one-line rotation: every engine
arrives as an async `<script>` and the aspect web is engraving drawn on frame one, so the wheel may not
wait. The fallback is arithmetic and never a table, it appears exactly once, and `_aspAudit` sweeps 360
pairs at mount and reports if the two ever disagree by more than 1e-9.

**Harness:** 18 new STEP E checks (145 total, all pass), including the loop count in both files, the
one-band assertion, the falsy-zero tripwire and the ninth table. Nothing outside the DC was touched, so
no engine needed regeneration and no artifact was invalidated.

The original plan, for the record:
There are roughly eight copies of

```js
for (const [ang] of aspects) { const r = Math.abs(D - ang); if (r <= this._orbFor(ang)) { …; break; } }
```

in `_aspectSnapshot`, `_snapTarget`, the bead snapper, `_natalAspects`, `_transitsToNatal` and the
readouts. Introduce two helpers and swap all eight:

- `_arc(a, b)` → `R.arcOf(R.separation(a, b))`
- `_aspHit(arc)` → min-residual over the ENABLED set (marks and septiles alike), inside `_orbFor`

`break`-on-first-match becomes min-residual. The harness measured the cost precisely: **nothing moves
at rest**; with every chip enabled, one 0.81 degree band (152.19 to 153.00) starts reading triseptile
instead of quincunx, which is the correct reading. Confirm you accept that before writing.

**F · the gene, 0-719, and the node order** · **DONE 2026-08-04** (with G, in one block)
`encodeValue` is gone: the gene is `ring.stateOf(lon, isRetro)`, so astrodna owns no encoding of its
own. The old encoder was the same arithmetic one-based, so **every gene is the old value minus one,
uniformly, in both halves**, and that is asserted against a re-implementation of the old formula
rather than argued. NODE_ORDER is
`Ascendant · Moon · Sun · Mercury · Venus · Mars · Jupiter · Saturn · Uranus · Neptune · Pluto · Node`,
`PRIMARY_NODES` reordered with it so "the first three" stays true positionally.

**THE NODE RULING (2026-08-04): the gene is the MEAN node, and the true node stays available.**
The genome holds values from which other values derive, which is why it has never carried a south
node: mean south is mean north plus 180. The mean node is a smooth secular function of time and
uniformly retrograde, so it is the steadier identity value and the better fit for how these positions
are generated. The osculating TRUE node oscillates about it and is a per-moment observable, so it
rides the decode surface as **`extras.bodies.Node`** — the same KEY the gene uses, deliberately — so
both are in hand and the reader chooses. **The sun/moon law was misapplied in the flag above:** that
law is about the astrolabe and the pull-up, and a gene is neither.

**THE INSTRUMENT DOES NOT MOVE, and the first cut of step F got this wrong.** Four readers flatten a
genome into one longitude map (the DC twice, `timespine.natalFromDna`, `rulers.lonsFromDna`) and all
four write the genes first and `extras.bodies` second. The first cut put the true node under a NEW key
(`NodeTrue`), so gene 12 survived the flatten and `pos.Node` silently became the mean node for every
genome-derived reader — including the drawn plate. Measured on the user's own chart, the engraved natal
node moved 1.344 degrees while the rete kept drawing the true node from the live decode: two
definitions on one wheel, with no chooser, which is exactly the disagreement the flag warned about,
relocated from genome-vs-rete to natal-vs-transit. Caught by the verifier before it shipped.
The fix is one line of naming rather than four call sites: **extras carries `Node`, the osculating node
the app has always drawn, and it overwrites gene 12 in every flattened map.** So a flattened surface is
byte-identical to pre-F (23 keys, no new body reaching the election scorer, the rulers' lon map or the
timespine's target build), the plate is engraved with the true node as before, and the mean value lives
where the identity lives: inside `nodes.Node`, marked by its own `source: 'NodeMean'` field so no
reader can mistake one for the other. Pinned three ways in the harness and three more in the astrodna
conformance test, including that all four flatteners still write extras last.

**One map, `GENE_SOURCE`, says which ephemeris quantity a GENE reads** — genes only, and it serves the
position, both motion samples and the speed, so those can never come from different bodies. A missing
`pos.NodeMean` throws.

No value is lost. (Superseded wording, kept because the correction is the lesson: this section first
read "nothing on the instrument is forced to move," which was a claim about intent rather than about
what the code did.)

**Versioned, never sniffed.** `SEQ_CODEC = 2` (1 = one-based 1-720, Sun-first, true node) is stamped
on every persisted row as `seqCodec`, and `_backfillSequences` re-derives anything stale from `jd`
plus place. No heuristic reads the digits: a sequence holding 720 is old and one holding 0 is new, but
every other sequence is ambiguous, and after the reorder position identifies nothing either.

**The new golden sequences** (`tests/astrodna.test.html` pins these; any future change to them is a
broken genome). Codec 3 is the ARCSECOND genome; the projection beneath each one is what codec 2
stored, and it is what every cache key is still cut at:
- J2000 · Greenwich
  - genome `87382-803978-1009371-978867-869685-1180715-91271-1440862-1133280-1091488-905235-1746160`
  - projection `24-223-280-271-241-327-25-400-314-303-251-485`
- 1991-07-04 18:30 UT · Richland Center
  - genome `701885-28991-368228-435282-524270-516354-486405-2394044-2310523-2323665-2115786-2337644`
  - projection `194-8-102-120-145-143-135-665-641-645-587-649`
- 2026-07-18 03:00 UT · Tokyo
  - genome `739173-595926-415941-1683981-573362-264878-446076-53135-232195-1311749-2392143-2490039`
  - projection `205-165-115-467-159-73-123-14-64-364-664-691`

**G · the two cache keys** · **DONE 2026-08-04**
`fertKey` files the weave under `natal.seq` when a genome is present (`w1|g<sequence>|<doctrine>`),
keeping the float fingerprint as the documented fallback for callers with no genome (the harnesses
build a natal by hand). `_electNatal()` attaches `seq`, keyed so a session that reaches it before
astrodna lands does not cache a genome-less natal forever. Measured both ways: a float wiggle below
the whole degree does NOT move the key, a moved genome does.
The IDB store `orbo.spine` now keys on `sequenceString × SPINE_VERSION`, which is what timespine.js's
own header always claimed and the DC never honoured. **The in-RAM `spine.at()` memo is untouched and
stays on `jd|lat|lon` forever** — it is a SAMPLE, and whole-degree ASC identity pins a moment only to
about four minutes of clock, so a genome-keyed sample memo would serve one moment's positions to
another and the Moon would visibly stall while the clock ran.

**H · regenerated:** `astrodna.browser.js` (rebuilt from source, gaining `stateOf` in its Ring
destructure and `SEQ_CODEC` in its global) and `fertilize.browser.js` (the key block only). `?v=`
bumped in the six harnesses that load them; the DC's tags carry no query string.

**I · verified in one pass.** 25 new STEP F/G checks in `tests/rewire-parity.test.html` (166 rows) and
the astrodna conformance test moved onto the Ring's encoder, the mean-node gene and the node boundary
(31 rows). The whole suite is green, run together through the new `tests/_suite.html`: ring 60 ·
mater 52 · rulers 16 · timespine 12 · loom 22 · loom-algebra 23 · mundane 35 · embryo 31 ·
fertilize 38 · luna 20 · astrodna 31 · rewire-parity 166 — 506 checks, zero failures. The embryo did
not rebuild, as §6 says it must not: it is native-independent and its codec is angle-valued.

**FLAGGED, not fixed · the one-time rebuild's chunk budget.** Both background builds run at 26ms of
work per 90ms gap (unchanged by this pass; only the KEY moved, so the path is the one every first-time
reader has always taken). Step G means every EXISTING reader now pays it once, and with the spine and
the weave building at the same time the two together hold roughly half the main thread: the wheel keeps
drawing, but a synthetic DOM capture cannot complete while it runs, and the weave advanced only about 5
percent per minute. If that is too slow to be invisible, the fix is to SERIALIZE the two builds rather
than widen either slice, and that is a decision about the instrument's feel, not a refactor.

The original plan, for the record:

**F · the gene, 0-719, and the node order**
`encodeValue` becomes `ring.stateOf(lon, isRetro)` and is deleted. New value is **old minus one**,
uniformly, for both halves (old direct 1..360 → 0..359, old retro 361..720 → 360..719).
Nothing outside `astrodna.js` reads `numericalValue`. `zr.js` decodes from `nodes`, not the gene.

**NODE_ORDER changes in the same breath** (decided 2026-08-03), because it invalidates exactly the
same artifacts and must not cost a second rebuild:

```
Ascendant · Moon · Sun · Mercury · Venus · Mars · Jupiter · Saturn · Uranus · Neptune · Pluto · Node
```

(was `Sun · Moon · Ascendant · …`). Still twelve genes, same set, same `PRIMARY_NODES` membership —
reorder that constant to match so "the first three" stays true positionally. `ELEMENT_WEIGHT` is keyed
by name and does not move. **`sequence` is positional, so this changes every sequence string**, which
is why it rides with F and G rather than on its own.

**FLAG, needs a ruling before writing · mean vs true node.** (RULED 2026-08-04: the gene is the MEAN
node and the true node stays on the decode surface. See the F record above. The reasoning below about
the sun/moon law was wrong: a gene is neither the instrument nor the pane.) The order above says "north node (mean)";
the genome's 12th gene is currently the TRUE (osculating) node, `ephem.positions().Node`. `ephem.js`
already computes `NodeMean` beside it, so the swap is one line, but it is a DOCTRINE change and not a
reorder: it moves the gene's value, and mean node is uniformly retrograde where the true node
oscillates, so that gene would sit permanently in the 360-719 half. The live consequence to weigh:
**the instrument draws the TRUE node on the rete** and the sun/moon law says the instrument does not
change for a moon-side feature, so the genome and the visible glyph would name different degrees
(up to ~1.8° apart). Three ways out — genome on mean and rete on true (they disagree), both on mean
(the instrument moves, against the law), or genome stays true (the order changes, the body does not).
Not guessed here.

**Legacy `entry.sequence` DOES migrate** (decided by §5). Today it is a write-once label that nothing
ever compares, which is what made a mixed archive look harmless. File the connectome and fertKey under
genome identity and that label becomes a LIVE KEY: a legacy row and a fresh derivation of the same
chart would key two different connectomes and two views of one person could disagree.
**Version it, never sniff it.** A sequence containing 720 is old and one containing 0 is new, but every
other sequence is ambiguous, so no heuristic is safe — and after the reorder, position no longer
identifies a body either. Bump a `SEQ_CODEC` constant, stamp it on the row, and have
`_backfillSequences` re-sequence anything stale. That path already exists (it walks `state.saved` and
re-derives deterministically from `jd` plus place, which is why this is four lines rather than an
encoding transform).

**G · the two cache keys**
- `fertKey(natal, doctrineKey)` keys on `natal.seq` (the `sequenceString`) when present, keeping the
  float fingerprint as a documented fallback for callers with no genome (the test harnesses).
  `_electNatal()` attaches `seq`. What the genome does not carry that the old key did: the MC and the
  extras. Both are deterministic functions of the same instant and place, and a collision needs two
  births whose every node agrees to the whole degree, which doctrine says IS the same chart.
- **`orbo.spine` does not rebuild unless you also move its key.** `_spineEnsure` keys on
  `v{SPINE_VERSION}|jd.toFixed(6)|lat,lon`. `timespine.js`'s own header claims identity is
  `sequenceString × SPINE_VERSION`, and the DC has never honoured that. Moving it is one line and it
  is the same law as fertKey, so do it here.

**TWO THINGS ARE CALLED SPINE AND ONLY ONE OF THEM MOVES.** They are keyed identically today
(`jd|lat|lon`), which is exactly why this is easy to get wrong:
- the IDB store `orbo.spine` holds the natal seed's MATERIALIZED EVENT TABLE. That is a **chart**.
  Move it onto the genome.
- the in-RAM `spine.at()` memo holds the FULL-PRECISION DECODE the instrument draws from. That is a
  **sample**, and it must stay on `jd|lat|lon` forever. Whole-degree ASC identity pins a moment to
  roughly four minutes of clock, so a genome-keyed sample memo serves one moment's positions to
  another's: the Moon would visibly stall while the clock ran. **Chart identity is the genome; sample
  identity is the instant.** The instrument draws at full precision, by law.

- Both IndexedDB stores prune to the current key on write, so each costs exactly one background
  rebuild and leaves no garbage.

**H · regenerate and wire**
Regenerate `framing.browser.js`, `astrodna.browser.js`, `mundane.browser.js`, `fertilize.browser.js`
from their sources. Never hand-edit a browser build.
(Steps A, B and C did their own regeneration and guards as they landed; what is left here is D-G's.)
Then the load-order work, which is where a silent hang lives:
- `astrodna.browser.js` now depends on the Ring, so it needs the `!window.__ORBO_RING` guard in its
  `boot()` and its `<script>` tag must move BELOW `ring.browser.js` (today it is above, at DC line 74
  against ring at 76). Same in every test harness that loads it, and in `tools/build-embryo.html`.
- `framing.browser.js` and `mundane.browser.js` gain the same guard.
- Inlining is not ordering: the guard, not the tag order, is what actually saves the standalone.

**I · verify, one pass**
Extend `tests/rewire-parity.test.html`, never rewrite it. New checks, one per step:
each table is BUILT by walking `MARKS` (regex on the source, as step 1 does) · each narrowing is
asserted at load · the septile literals are within 1e-3 of 360k/7 and are not marks · the gene is
`ring.stateOf` and new equals old minus one on the fixture · `fertKey` moves when the genome moves
and does NOT move when a float wiggles below a degree · the falsy-zero tripwire still counts
conjunctions.
Then re-run green: `ring`, `loom`, `loom-algebra`, `fertilize`, `luna`, `mundane`, `embryo`,
`astrodna`. Finally load the DC and confirm the aspect web, the ♍ chip ring and a ♐ Field stream all
still read.

## 5. The Connectome, and what this pass owes it

Concepted after the Ring work began. It does not disturb steps A through E: the Connectome is
SIGN-level wiring, the Ring is DEGREE-level relation, and the dataflow separates them by hand at the
reading step (wiring answers dignity, reception and governance; the Ring answers speed, retrograde and
aspect). It does decide F and G, and it is why D2 exists.

**It adds NO new persisted artifact.** `spine.axialAt` already memoizes the axial triple on the genome
entry, keyed by the natal it is read against, precisely because the genome cache key could not carry
the extra argument. The Connectome is that same pattern, a further memo on the entry. Built-once-at-
engraving then falls out of the memo with no special case, and the sky's connectome arrives through the
same door as the native's, which is the property the dataflow asks for.

**Its cache key is the SIGN VECTOR, not the genome.** This is the load-bearing engineering fact and it
is a restatement of the dataflow's own invalidation rule: wiring changes only when a body changes sign.
Thirteen small integers (twelve bodies plus the rising sign) collapse to a short string. Keyed on the
genome, a scrubbed year recompiles tens of thousands of times; keyed on the sign vector, that same year
reuses a few hundred compiles. Degree-resolution questions never touch it.

**"When does the government next change" is already stored.** Sign ingresses are materialized on the
embryo (mundane) and on the union weave (`_fertQuery`), and BOTH already carry `governed`, the flag
saying whether the dispositor actually changed with the sign. So that answer is a read, not a scan,
today. Nothing new is owed.

**What the compiler must be TOLD rather than derive:** union placements are housed in the natal frame,
never a frame of their own. Natal whole-sign anchored to the natal ASC, always. Everything else in the
compile is derivable from the genome plus the stamped tables.

**Step E is the Connectome's seam.** "Interpretation and visualization read the finished tables,
neither recomputes an aspect" is violated eight times over today. Collapsing those loops into one
`_aspHit` is what makes a later table-backed reader a one-line swap instead of an eighth rewrite.

Not built in this pass: the compiler, the indices, the two named chains as a materialized structure.
This pass makes the ground level.

### 5.1 The mockups, read against the code

Seven interface sketches (`uploads/01_AstroState` through `07_RegulatorySnapshot`). What lands, and
the three corrections that matter.

**Lands as-is.** `AstroState.source` as a discriminator over natal / synchronic / transit / mundane is
exactly the dataflow's "nothing knows or cares whether it came from a birth or from the current
second" · the reverse indexes (`planetsDisposedByPlanet`, `housesRuledByPlanet`, `housesRoutingToHouse`,
`incomingPlanets` on a cycle) are the whole point, a lookup rather than a re-walk ·
`HouseNode.destinationHouse` answers "what routes into the 7th" · `rulesSigns` / `rulesHouses`.

**`stateKey` + `topologyKey` in the metadata is the best thing in the set and is adopted verbatim.**
Those two names are the two-key split §5 argues for: `stateKey` is the genome, `topologyKey` is the
sign vector. Keep both words.

**"Expression", not "snapshot" — and the code already agrees.** `astrodna.js`'s own header reads "these
are EXPRESSION LEVELS, not genes" and "the genome stays 12 genes; the expression is total." So the
compiled record is an **Expression**: the genome expressed through the Mater. `RegulatorySnapshot`
becomes `Expression`; "regulatory" is not an Orbo word.

**Correction 1 · the DNA is TWELVE nodes, not eight.** The sketch lists Sun through Saturn plus
Ascendant. The genome is twelve and, per the 2026-08-03 reorder (rewire step F), reads
`Ascendant · Moon · Sun · Mercury · Venus · Mars · Jupiter · Saturn · Uranus · Neptune · Pluto · Node`
(`PRIMARY_NODES` are the first three; the seven extras ride the decode surface and are never
sequenced). The Expression is built over NODE_ORDER, in that order, always.

**Correction 2 · twelve nodes OCCUPY, seven planets GOVERN.** The sketch's `PlanetNode` gives every
entry a `dispositor`, which is right, but the graph is not symmetric: Ascendant, the three outers and
the Node answer to a governor and nobody ever answers to them, because traditional rulership is the
backbone and moderns are co-governors, never chain branches (CLAUDE.md). So every chain terminates
inside the seven, `rulesSigns` is empty for five of the twelve, and a chain-walk from the Ascendant is
the agency chain by construction. State the asymmetry or the compiler will look broken.

**Correction 3, load-bearing · `PlanetNode` must NOT carry longitude, degree or retrograde.** The
sketch has `astroDNA`, `longitude`, `retrograde`, `sign` and `degree` side by side. Two problems.
First, the 0-719 state already encodes sign, degree and retrograde, so storing all five is four chances
to disagree. Second and fatal: **anything at degree resolution destroys the memo.** Keyed on the sign
vector, a scrubbed year costs a few hundred compiles; put a longitude or even the whole-degree state on
a node and the record changes every sample, so it recompiles tens of thousands of times and is no
longer a table at all. The Expression is **sign resolution, by law.** Speed, retrograde, exact degree
and aspects are read live from the spine at full precision and joined at the reading, which is what the
dataflow already says ("reads the same bodies at degree resolution for speed, retrograde, and the
aspects it's making through the Ring — both, joined"). Dignity splits the same way: sign-level
dignity is in the Expression, the exact exaltation DEGREE is a Mater lookup applied live.

**Vocabulary map**, so the compiler speaks Orbo:
`dispositor` → **bearer** (immediate) · `terminal` → **keeper** (terminal ruler or the loop it closes
into) · `terminalType: fixed-point` → **domicile** · `mutual-reception` stays (two-planet loop, never
"closed circuit") · `cycle` → **dispositor loop** (three or more; "cycle" also collides with ZR's
cycle) · the two named chains are **agency** (from the natal ASC ruler) and **light** (from the sect
light), pointers into the general per-planet chains rather than a separate structure. The charged
reading stays Keeper of Agency == Keeper of Light.

**Drop `metrics`.** An unnamed measurement bag is exactly where a strength score sneaks in, and the
dataflow's own closing rule is that every value is a measurement and nothing says strong or weak. Name
each measurement or omit the field. Likewise drop `AstroState.id`: identity is the sequence string,
and a second id invites the two disagreeing.

## 6. Explicitly NOT in this pass

**Order of record, revised 2026-08-04** after the arcsecond question. Everything below is sequenced by
one rule: a step that moves a cache key must not run twice. Step J was going to be the third such
step, and 7a is what made it free.

- **7a · the key projection** · **LANDED EARLY, inside step J** (2026-08-04). It was planned as its own
  behaviour-identical step to pre-pay for arcseconds; since J needed it in the same breath, it shipped
  with J instead. `fertKey` and the `orbo.spine` seed key on `astrodna.degreeSequenceString`, a
  DECLARED whole-degree cut of the genome, and that string is byte-identical to what `sequenceString`
  returned under codec 2 — measured against all three golden vectors. So no reader's weave or spine
  rebuilt when the gene got finer.
- **J · the arcsecond gene** · **DONE 2026-08-04.** See the step J record below.
- **K · the provenance gate** · **DONE 2026-08-04.** See the step K record below.
- **7b · the pullback deleted and the word struck** · **DONE 2026-08-04.** Prompt of record:
  `specs/Prompt - Step 7b.md`; full record in CLAUDE.md under "Step 7b". The nine pullback functions,
  the supplement dedup, `serves` and loom's hand-rolled nearest are gone; `framing.synEvents` kept its
  door and lost its scanning body, delegating to the ONE scanner injected as `opts.loom`; the rename
  reached `framing`, `loom`, `fertilize`, `luna`, the DC and five harnesses, and the stored layer tag
  is `synchronic`. `fertilize.CODEC` moved to 2 — the one rebuild, spent once, which is why it was
  held at 1 through J.
  **§1's contradiction settled by measurement, and the Ring's record won without costing the Loom's:**
  there is no synchronic coordinate, only an occupant and a speed, and the phase gate is not replaced
  but UNNECESSARY, because a pole jump reaches the scanner as an ordinary wrap and the generic wrap
  guard has handled wraps on every layer since S1. Fixture natal, 400-day window: 128 ingresses, 19
  flips, 147 contacts, every root paired with the pullback's at max delta 0.00 minutes, `ring.nearest`
  exact on all 147. Those counts are constants in the harness now; the second path is gone.
  **The inventory was wrong a fourth time and in the same way:** §4 of the 7b prompt listed `luna.js`
  as downstream-no-edit, and it imported the target set by name and carried the layer as a public kind
  string. Clustered by CONSTRUCT. The harness fetches `luna.js` now.
  `tests/loom-algebra.test.html` was REWRITTEN rather than deleted, per §5.8: every assertion that was
  about geometry survived, the properties the pullback was credited with are asserted directly, and the
  recorded conformance numbers came with it. 23 checks became 44.
  Suite: 590 checks, zero failures, all twelve pages.
- **L · the Connectome compiler** (§5). D2 stamps the tables it reads and F/G/J settle the identity it
  files under, so the compiler becomes an additive session with nothing to migrate. Building it here
  would turn a refactor with a known answer into an experiment. J confirmed the layering from the other
  side: the Expression is sign resolution BY LAW, so arcseconds are completely invisible to it. If a
  precision change had rippled into the compiler, the layering would have been wrong.
- **The embryo is not rebuilt.** No number moves and its codec is angle-valued, not index-valued. Step
  J adds a second, independent reason: the embryo stores no PLACEMENT at all, only angles, times and
  residuals, so there is nothing in it for arcseconds to be inconsistent with. (This also retires an
  earlier worry that the embryo's and fertilize's hundredths-of-a-degree rows, 36 arcseconds, could not
  express L2. They do not need to: neither stores a placement.)
- `transits.js`, `luna.js`, `electional.js`, `timespine.js`: downstream, no edit. Re-confirmed under J
  — none of them reads a gene.

**J · the arcsecond gene, and the projection that made it free** · **DONE 2026-08-04**

*Why.* A resonator can prevent drift, detect loss and re-align a derived state, but it cannot recover
arcminutes and arcseconds that were never encoded. The precision was never actually lost — `nodes` has
always carried the full float, and every reader that wants one has one — what was missing was
precision IN THE IDENTITY. Doctrine says two moments that engrave the same genome ARE the same chart,
and at whole degrees that was not quite true: a whole-degree Ascendant pins a moment only to about four
minutes of clock, a figure this rewire's own step G already had to reason about. At arcseconds it is
true. It is also what the L1/L2/L3 ladder needs in order to say 21° Aries, 21° 08′ Aries, 21° 08′ 37″
Aries off one source of truth instead of two.

*Arcseconds, not packed digits.* A gene of `0210837` is a display format promoted to storage. It is not
arithmetic (no reader could subtract two of them to get a separation, and "walk the table yourself" is
the disease `ring.nearest` and `_aspHit` were built to cure); it admits invalid states (61 minutes
encodes fine); and it drops the sign index unless prefixed, at which point the scalar has four fields.
One absolute integer arcsecond of the circle keeps every operation a subtraction. And it lands the
lattice where the Ring wants it: every mark is a whole degree, therefore a whole arcsecond, so the
perfect lattice survives at 3600x resolution and exactness stays structural. 1,296,000 fits in 21 bits,
so the integer math is exact in both Int32 and float53 — there is no drift for a resonator to chase.

*The retrograde encoding: the coarse shape, scaled.* One integer per gene, retrograde in the upper
half. Three alternatives were weighed and rejected, each for a reason this codebase has already paid
for. A separate motion field per gene breaks the one property every persisted row, every cache key,
`_backfillSequences` and all three golden fixtures depend on, that a genome is a hyphen-joined list of
integers; it also adds a fourth chance to disagree, which is §5.1's Correction 3 turned on the genome.
Negative-for-retrograde restages the `targetDegree` returned `-1` bug: 0 direct and 0 retrograde
collide, and a negative index reaching a typed array is exactly what the falsy-zero contract was
written after. And keeping the gene coarse with a parallel arcsecond array leaves the coarse value as
the identity, so the identity never actually gets finer, and two arrays can disagree about one
placement. **The offset's MAGNITUDE means nothing** — it is a flag that happens to be addressable as
arithmetic, and its one load-bearing property is that reduction is a single modulo. Which is why the
modulus is now a NAMED CONSTANT everywhere in the state encoding and never a literal again: `ckState`
exists because 360 and 720 were typed all over the coarse space and `720 % 360` is 0, so an
out-of-range state silently read row 0. At 1,296,000 the same miss reads a position 360 degrees away
with nothing thrown. **The guard is the whole risk of this step**, so `ckFine` is applied at every fine
entry point, on the pattern the Ring already learned the hard way (hardening one function and leaving
its siblings raw is not a contract).

*Two ends of the retrograde half carry no information, by design, and are now pinned.* An angle cannot
station, the luminaries never appear geocentrically retrograde, and after step F the mean node is
UNIFORMLY retrograde — so gene 12 sits permanently in the upper half and genes 1 to 3 never do. The
uniform encoding is kept anyway (uniformity beats four special cases, and `RETROGRADE_CAPABLE` already
exists to say which is which), but a migration that flips either end is otherwise entirely invisible,
so the harness asserts both on every fixture.

*THE DIE DID NOT GROW.* `TARGETS` and `MARK_AT` are still 360 rows of eleven marks, `PLATE.degrees` is
still 360, and `nearest` still takes exact reals and quantizes nothing. Every mark is a whole degree,
so a whole-degree lattice already resolves all eleven exactly and 1.296 million rows would buy nothing.
What the Ring gained is the UNIT and a second address space, because **precision is a property of the
OCCUPANT and the relation is the die** — the same split that already keeps motion out of the
degree-to-degree relation. `ARCSEC` · `ARCSECONDS` · `FINE_STATES` · `arcsecOf` · `fineIsRetro` ·
`fineStateOf` · `fineStatesFor` · `stateOfFine` · `dmsOf`. The unit is INHERENT by the Ring's own test:
3600 to a degree and 1,296,000 to a circle are true before the app runs.

*The falsy-zero contract extended verbatim.* Arcsecond 0 is 0 Aries 0′ 0″, `stateOfFine(0)` is 0, and
every field of `dmsOf(0)` is 0. Absence is still `null`, a programmer error still throws.

*What changed, file by file.* `ring.js` gained the unit, the fine doors, `ckFine`, and named constants
in place of every state-encoding literal. `astrodna.js`: the gene is `ring.fineStateOf`, `SEQ_CODEC` is
**3**, and each node record carries two DERIVED projections beside its gene — `state` (the codec-2
whole-degree address, for readers handing a state to the plate) and `dms` (the ladder's digits,
arcseconds within the sign, cut from the gene rather than re-floored off the float, so display and
identity cannot disagree). `dna.degreeSequence` and `degreeSequenceString` are the projection.
`fertilize.js`: no code change and **CODEC stays 1, deliberately** — a bump would rebuild every weave
for a change that moves not one event — only the contract that `natal.seq` must be the projection.
The DC: `_electNatal` and `_spineEnsure` key on the projection; `entry.sequence` keeps the fine genome
as the persisted LABEL, and `_backfillSequences` re-derives it once off `seqCodec`, never transforms
it. `ring.browser.js` and `astrodna.browser.js` regenerated from source.

*Measured, not argued.* The projection is byte-identical to the codec-2 golden sequence on all three
fixture vectors. 8.6 seconds of clock (about 5 arcseconds of Moon) moves the GENOME and does NOT move
the KEY; 86 seconds moves both, because the whole degree moved. `nodes[].state` equals
`stateOfFine(gene)` and `dms` equals the gene's own arcseconds within the sign, on all twelve genes of
all three vectors. `stateOfFine` projects all 1,296,000 arcseconds of both halves onto the right coarse
state, and agrees with `stateOf` on the same longitude.

**K · the provenance gate** · **DONE 2026-08-04**
The gene carries arcseconds now, so the digits exist for every placement. Whether they are TRUE is a
different question, and it is the one question a resonator cannot answer: **precision the source never
had is the only loss nothing downstream can detect.** Two ceilings in `_precision(name, src)`, lower
wins, and it is a CEILING and never a floor — every existing caller passes no name and keeps today's
arcminute reading, verified byte-identical over 400,000 random longitudes and at both sign boundaries.
- **The clock.** A birth time is stored to the MINUTE everywhere in Orbo, so the clock is uncertain by
  60 seconds, or ~4 minutes when the zone was inferred from longitude (LMT). Drift per minute of clock,
  in arcminutes: the angles ~15, the Moon ~0.55, the Sun ~0.041, Mars ~0.022, Jupiter ~0.0035. A unit
  may be shown only when the uncertainty is smaller than that unit.
- **The ephemeris.** The osculating and derived points (both nodes, Chiron, Lilith, the four asteroids,
  Fortune, Vertex) are not arcsecond-true in this engine and cap at L2 whatever the clock allows.
  Lilith's apogee oscillates by degrees; an arcsecond on it means nothing.

**THE FINDING, and it is the reason this step was worth doing rather than just printing seven digits.**
On ordinary minute-resolution birth data the honest ladder is: the **Ascendant and MC reach L1 only**
(15′ of uncertainty), Fortune and Vertex with them; the **Moon, Sun, Mercury, Venus, Mars and the
derived points reach L2**; and **only Jupiter and beyond reach L3**, where the ephemeris then caps the
nodes and asteroids back to L2. So an L3 arcsecond on a natal placement is almost always theatre, and
the ladder now says the truth instead. A record carrying seconds drops the clock to 1s, which lifts the
Moon and the inner planets to L3 and the Ascendant to L2 — still never L3. An LMT record drops the
Ascendant to sign level, which is honest: 4 minutes of slop is a full degree of horizon.

