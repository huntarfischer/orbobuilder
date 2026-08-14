# Prompt · Phase 6 · P5 · the ledger

*Proves:* row times match the scanner's roots at max delta 0.00 minutes, which is the 7b bar.

Plan of record: `specs/Phase 6 - The Synchronic Prism.md` §1.1, §1.3, §5, §6, §7, §8, §9. Predecessors:
P0, P0b (v0.890/0.891), P1 (v0.892), P2 (v0.893), P3, P4 (v0.894, prism CODEC 3). Nothing here is built.

---

## 0 · What P5 is, in one sentence

**P4 gave the day a continuous coordinate; P5 gives that coordinate its clock face and its contents.**
The walk (σ) and the itinerary (seven stops, their houses, lords and durations) already exist and are
already measured. What does not exist is (a) the way in from the back, and (b) the rows: each stop of
the day holding the perfections that fall inside it.

So P5 is two deliverables and they are independent enough to land in either order:

1. **The ♓ Clock socket** — the way in. Small, mechanical, and governed almost entirely by existing law.
2. **The segment rows** — the reading. Where the real work and the only real risk is.

---

## 1 · The ♓ Clock socket

Already RULED (§7, and open question 2/4 both closed): a fourth **item** socket in ♓ Composite, beside
`Moment`, `Chronicle` and `Synastry`. The word is **`Clock`** — it names the READING like its siblings,
with "prism" living in the field's definition as the mechanism's name. 5 characters, inside the 8
character cap.

Nothing here is new machinery. A tabula joins the spread by returning `{kind, items}` from
`_tabItems(panel)`; ♓ is already an `item` tabula with the verbs at tabula level; `_tabVals(s)` turns
the registry into the `tab*` keys the shared field template reads.

**THE ONE MECHANICAL CHECK, AND IT HAS ALREADY BITTEN TWICE.** Four items is an **EVEN** count, and
`_tabVals`' `slot()` floors, so one socket seats right of top. ♑ Gears was dark from the day it shipped
for exactly this, and ♐ Almanac joined it the moment it reached 6 streams. **Screenshot the ♓ ring after
the item count changes and confirm all four sockets are present and tappable**, via the review path:

```js
__orbo.setState({ flipped: true, panel: 'composite', tabSel: 'clock', depth: 'scholarly' })
```

Register per the back's law: third person, declarative, definition-shaped, in the glossary's voice. The
term in incised gold caps, the definition beneath in stone. Georgia, not the sans. Icon on top **opens**
(`_openTabLens`, transient, must NOT write `paneLenses`), rune below **etches** (`_togglePaneLens`).
Those are two distinct verbs and ♐ has already been fixed once for conflating them: **never force-etch
on the way in.** No em-dash.

The definition owes the §5 naming hazard a resolution (below), and it owes the mechanism its name: not
"my chart and the sky became one" but the chart formed by refracting every position to its midpoint with
a natal chart.

**The electional query stays ♏ Timing's.** That is P6 and it is not in scope here.

## 2 · The naming hazard, which must be settled before a row is drawn

§5 flags it and P5 is where it comes due. **Two lords of the hour will appear on one pane:**

- the **rising-lord** stream already answers "who governs the hour" from the **sky** Ascendant, twelve
  handoffs a day;
- the **clock** answers it from the **synchronic** Ascendant, **six** a day (the itinerary's seven stops
  are separated by six sign boundaries), at entirely different times.

Two different answers to one sentence on one surface is exactly the confusion the qualified-house
discipline exists to prevent, one level up. **A lord is always qualified, never bare** — the same law
§13.1 lays down for houses. The prompt does not pick the two words; it requires that they be picked and
that neither reading can be rendered unqualified anywhere in the app.

## 3 · The segment rows

**The row is a segment of the day, not a perfection.** A flat list of ~130 perfections a day is noise;
seven rows a day and forty-nine a week reads. This is `switchGroups`' own insight from the other side:
the Moon is the switch of the floor, the sASC is the switch of the clock.

A row is one itinerary stop plus its contents:

> sASC in the 11th · 09:14 to 11:40 · lord Mercury · and these three marks.

**What the row must carry, and where each field comes from (all of it already built):**

- the stop, its **natal whole-sign** house, its sign, its lord, its span in degrees — `template.stops[i]`
- its **walk** address, σ to σ_end — CODEC 3 carries it on the stop
- its clock times — from `ramc` via `ramcJdNear`; **a duration has no epoch**, so the epoch is supplied
  at read time and no jd is ever stored on the template
- the day's **structural instants** — the anchor (the return) and the flip, from `template.anchor` /
  `template.flip`; §14.1 and P4 already rule the flip an ordinary boundary crossing of the same class as
  the other six, so **it must not be styled as an exception** in the ledger
- the marks falling inside it — §6, below
- the **disagreement**, which is the reading and not a rendering defect: rows are uniform in degrees and
  wildly unequal in time. The fixture measures **2225.7×** unevenness and up to **9.21% of the day** of
  drift. `dialOf` already reports it. **A row that is 0.14 minutes long and a row that is 5.16 hours long
  must both be legible**, which means the ledger cannot lay rows out proportionally to duration and
  cannot silently drop slivers. **P2's ruling stands: a sliver is structure, never a gap. Never "fix" one
  away.**

**Depth is a property of moonlight**, so the ledger carries L1/L2/L3 and keeps the pane's first-person
spoken voice. The pane's own sentence is the model for L1.

**Day and week.** Seven rows and forty-nine. The week is seven template evaluations at seven epochs, not
seven scans: §1.3 is that a day's ledger is a template evaluation. The offset walks **3.9318 min/day**
(measured, §1.2), which is why consecutive days' rows sit at visibly different civil times, and that is
worth showing rather than normalising away.

**The Moon through `luna`.** Over one day every occupant except the Moon is effectively parked (a
synchronic body moves at half its sky speed). The Moon is the one occupant whose own motion matters
inside a row, and `luna.js` is its existing door.

## 4 · The marks, and the one-scanner tension

This is the only genuinely open engineering question in P5, and §6 already prescribes how to settle it.

Because the map inverts, a sASC event does not need to be searched for. A sign boundary `B` is reached
when the rising degree is `2B − nASC`; a mark `m` to occupant P is reached when the rising degree is about
`nASC + 2(m + sP − nASC)`, and since sP is slow that target barely moves, so it is one horizon root-find
plus a correction.

**This is a real tension with the one-scanner law and it is flagged, not decided.** The law says
`loom.js` scans. The counter-argument is that the horizon has standing precedent for its own door
(`spine.ascProbe` exists precisely because per-sample genomes stall a horizon scan, and `_risingWindows`
already root-finds at this cadence) and that invertibility is a genuine geometric difference rather than
a shortcut.

**The resolution this codebase's own habit prescribes, and the acceptance bar:** build it on
`scanTargets` **first**, measure the inverted path against it, keep **both counts as constants in the
test**, then delete one. That is 7b's max-delta-0.00 pattern and it is how the pullback died honestly.
Do not skip the scanner build to save time; the measurement is the deliverable.

**One thing the scanner needs either way:** `STEP_FOR` has no Ascendant entry and defaults to a day for
the fastest occupant in the instrument. Marks come as close as **6°** apart, so at 180°/day the step must
be under **0.033 days** merely not to skip a root, and about **0.01 days** to satisfy loom's own comment.
A missed root here would look exactly like a quiet engine failure, which is the P4 harness lesson.

**Orbs HALVE on the synchronic layer.** Natal orb defaults are too wide here; a ledger built at natal
orbs will over-report and look plausible while doing it.

**Same-body vs cross-body must look different**, and the reason is P2's: a same-body pair's family is
`{δ/2, 180−δ/2}` forever (measured to 0.000000000°) and only the MODE alternates; a cross-body pair
retains `(skyA − skyB)/2`, forms any mark, and genuinely perfects. One list for both kinds is wrong.
**And the square is self-complementary** (`{90,90}`): suppress the mode display there, since a flip
changes which side and not the class.

**Always the Ring's word for the mark** — conjunction, sextile, trine. "Contact" is the loom's LAYER
name and never stands in for an aspect.

## 5 · Refused, carried forward unchanged

- **Any clock row on the spine. Any fuse. Ever.** The pre-ruling, upheld through P2, P3 and P4. What is
  stored is the STRUCTURE a live cursor is read through. The ledger is computed at read time from the
  template; it is not materialised and `fertilize.CODEC` does not move. (`timespine.js`, the materialised
  event-table unspooler, is a different thing and is not touched.)
- **A refraction table.** §3. The refraction is one wrap and one halving through `framing.refract`, the
  one door, and a table would quantize to whole degrees against the codec law.
- **Re-housing a synchronic placement from a derived Ascendant, in any reading, ever.** Houses are natal
  whole-sign, anchored to the natal ASC sign. **The derived frame may NAME the hour and may never
  RENUMBER a placement** (§5). Two rows, two facts, both qualified.
- **No new drawing on the instrument.** P1's proof obligation and the standard for every pass since: the
  ledger is moonlight, and the astrolabe does not change. §14.1 already ruled the dial needs no widget.
- **`_reteIsOther()` still refuses the prism.** The prism is ME refracted and is never a partner. A
  ledger row is one chart's own reading; it must not become a pair reading by accident.

## 6 · Locality, which the ledger is the first surface to expose

§8's result, and it is the one place the ledger differs in kind from everything else in Orbo: the
synastry cancellation is over **bodies**, and the sASC is an **angle**. So `sASC_A − sASC_B` retains
`(skyASC_A − skyASC_B)/2` and does not cancel. **Two people in different cities have synchronic
Ascendants that drift apart through the day; two people in the same room share theirs exactly.**

Everything else Orbo computes is place-invariant by law, and the flip calendar is exported
byte-identical by two people. The clock is the one layer where being in the same place is the entire
content, which is also why it is the electional layer. **State this to the reader rather than letting
them discover it** (P7 owes the same for two arcs). A pp mint has no place, so it gets no ledger and the
reason is recorded rather than faked, exactly as Chronicle already stays dark on one.

## 7 · Acceptance

`tests/prism.test.html` gains a P5 section (the suite stands at **85** on that page, **938** total).

1. **THE BAR: row times match the scanner's roots at max delta 0.00 minutes.** Both counts recorded as
   constants. This is the 7b bar and it is not negotiable down.
2. Seven rows a day, tiling the day with **no hole and no overlap**: the rows' spans sum to one sidereal
   day, and every instant in the day falls in exactly one row. Slivers included and asserted to exist.
3. Row boundaries are the itinerary's boundaries, and each row's σ range is the stop's own `sigma` to
   `sigmaEnd` (CODEC 3), not re-derived.
4. Every mark reported inside a row is inside that row's time span, and every mark the scanner finds in
   the day appears in exactly one row.
5. A row's house is the **natal whole-sign** house; assert no reading anywhere renumbers from the
   derived Ascendant, and no lord and no house is rendered unqualified.
6. The week is seven evaluations, not seven scans: assert the day-to-day civil offset matches the
   measured **3.9318 min/day** regression.
7. Orbs are halved: assert a mark that would perfect at natal orb and not at synchronic orb is absent.
8. Same-body rows show a family and a mode; cross-body rows show a perfection. The square suppresses its
   mode.
9. A placeless chart (pp mint) gets **no** ledger, with the reason recorded, and above the polar circle
   the template refuses rather than inventing arrival times.
10. **The instrument is unmoved:** the natal-solo and live-sky renders stay byte-identical, as P0b pinned
    them.

## 8 · Hygiene owed

- `prism.js` / `prism.browser.js` are a hand-maintained mirror pair with **no generator**: any change to
  one is mirrored in the **same turn**, and the mirror is verified by running
  `tests/prism.test.html`, `tests/loom-algebra.test.html` and `tests/loom.test.html` rather than assumed.
  Same for `framing.js` / `loom.js` and their mirrors.
- Snapshot `archive/Orbo Astrolabe YYYY-MM-DD.dc.html` before the first DC edit.
- Version to v0.895.
- No em-dash, anywhere, including the write-up.
- If the CODEC changes shape again, say so and bump it; filed tables must miss rather than be read wrong.

## 9 · Suggested order

Socket first (small, mechanically risky in one known way, and it gives you the way in to look at
anything you build after). Then the scanner-based ledger for one day, then the inverted path measured
against it, then the week, then the Moon. Land the ♓ ring screenshot before writing any row code, so an
even-count regression cannot masquerade as a ledger bug.
