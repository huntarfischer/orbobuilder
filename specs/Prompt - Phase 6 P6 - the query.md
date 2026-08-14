# Prompt · Phase 6 · P6 · the query

*Proves:* electional over the sASC, in ♏ Timing. Every other reading in Orbo says what the hour is. The
clock says which minute to take.

Plan of record: `specs/Phase 6 - The Synchronic Prism.md` §5, §6, §7, §9, §11.4, §13. Predecessors: P0,
P0b, P1, P2, P3, P4 (v0.894, prism CODEC 3), P5. Nothing here is built.

---

## 0 · Why this phase exists at all

**You cannot choose where Saturn is. You choose when you walk in the door, and that choice sets the sASC
and every relation it forms.** That is the whole argument for the clock being actionable, and it is why
the query is a phase rather than a nicety: P5's ledger tells you the shape of the day, and a shape you
cannot act on is a horoscope. The query turns the itinerary into a decision.

It is also the phase where the prism stops being a way of looking and becomes a way of choosing, so the
sun/moon law wants restating up front: **nothing here lands on the instrument.** The query is moonlight
and its configuration is the back's.

## 1 · Where it lives, and why not ♓

**RULED (§7): the electional query stays ♏ Timing's, where electional already lives.** Do not put it in
♓ Composite beside `Clock`. ♓ is the chart × chart tabula and its items name READINGS; ♏ Timing is where
election is the subject and where `electional.js` already answers to. Two electional engines on two
tabulae would be the second-refraction-path mistake in a different costume.

So P6 adds to ♏ rather than creating anything: the sASC becomes a criterion the existing electional
machinery can score, and ♏'s existing shape (streams, chips, the field) carries it.

**Mechanical check owed, same class as P5's:** if ♏'s item count changes, `_tabVals`' `slot()` floors and
an even count seats one socket right of top. ♑ Gears shipped dark for exactly this and ♐ Almanac joined
it at six streams. Screenshot the ♏ ring and confirm every socket is present and tappable before
building any scoring. Review path:

```js
__orbo.setState({ flipped: true, panel: 'timing', tabSel: '<the new item>', depth: 'scholarly' })
```

## 2 · What a synchronic election actually scores

This is the design work of the phase, and it differs in kind from natal electional. Natal electional
scores **where the bodies are**, which you cannot change. A synchronic election scores **what your
arrival does to the refracted chart**, which is entirely yours.

Three criteria are available and they are not interchangeable:

1. **The stop.** Which of the seven segments you land in: its sign, its **natal whole-sign** house, and
   its Synchronic Ascendant Ruler. This is SELECTION on a moving Ascendant, which §5 explicitly rules
   legal, and it is the criterion with the largest effect for the least precision, because a stop lasts
   from minutes to hours.
2. **The marks.** Which perfections the sASC forms to the occupants inside that window, at **halved**
   synchronic orbs. P5's ledger already computes these; the query reorders them by desirability instead
   of by time.
3. **The position within the stop.** `dialOf`'s σ and its `degFraction` say whether you are arriving at
   the opening, the middle or the close of a segment, and whether a boundary is about to hand the hour to
   a different ruler. A minute before a handoff and a minute after are different elections.

**The flip is not a special criterion.** P4 ruled it an ordinary boundary crossing of the same class as
the other six, and §13.3 ruled the sASC has no flip kind: its transitions are all one kind, a change of
Synchronic Ascendant Ruler, the flip being one of them with a larger step. **Scoring the flip as an
exception would reintroduce the very thing P4 deleted**, in the scorer instead of the detector. It may
carry more weight because the step is 6 houses rather than 1; it may not carry a different *kind* of
weight.

**The two lords must stay qualified.** §11.4: the sky's keeps `rising lord`; the synchronic one is the
**Synchronic Ascendant Ruler**. A query result that says "lord Mercury" without saying which is the
defect the qualified-house discipline exists to prevent. *Owed and still owed:* a short form that fits an
8 character socket or a chip.

## 3 · The engine question, which P5 will have already settled

P5 is required to build the ledger on `scanTargets` first, measure an inverted path against it, keep both
counts as test constants, and then delete one. **P6 inherits whichever survived and must not re-open
it.** If P5 kept the inverted path, the query uses it; if P5 kept the scanner, the query uses that. Two
paths to a synchronic mark, chosen per feature, is the same failure as two refraction paths.

What P6 does add is **a search over arrival times**, which is a different shape from a scan over events:
the ledger asks "what happens today", the query asks "when today is best". Since the itinerary is fixed
at engrave and the stops are known, the search space is **seven windows, not a grid** — evaluate the
stops, rank them, then refine inside the winner. A minute-grid sweep of the whole day would work and is
the wrong shape; it also risks skipping roots exactly as `STEP_FOR` does at its default of a day (marks
come as close as **6°** apart, so at 180°/day a step must be under **0.033 days** merely not to skip one,
about **0.01 days** to satisfy loom's own comment).

**Every window's clock time comes from `ramcJdNear` at read time.** A duration has no epoch. Nothing is
stored, nothing is fused, no row reaches the spine, and `fertilize.CODEC` does not move.

## 4 · The locality result, which the query must state rather than assume

§8 and P7's subject, but P6 is where it becomes operational: **the sASC is an angle, so it depends on
place.** The synastry cancellation is over bodies and does not cover it. Therefore:

- **A synchronic election is for a PLACE**, not just a moment. An election computed at one city is not
  valid at another, and this is the only layer in Orbo where that is true.
- A pp mint has no place, so it gets **no query**, and the reason is recorded rather than faked, exactly
  as Chronicle already stays dark on one and as P5's ledger does.
- **Say this to the reader in the field's definition.** Discovering it by exporting two different answers
  is the failure mode.

## 5 · Refused

- **Any query result stored on the spine, or fused.** The pre-ruling, upheld through P2, P3, P4 and P5.
- **Re-housing from the derived Ascendant.** Houses are natal whole-sign. The derived frame may NAME the
  hour and may never RENUMBER a placement. A query that ranks "sASC in the synchronic 1st" is ranking
  nothing, since the derived 1st is always the 1st, which is §1.1's own point about why the 10th-to-4th
  walk is the story.
- **A second electional engine.** ♏ has one.
- **Any new drawing on the instrument.** P1's proof obligation, and the standard since. The query is
  moonlight.
- **Natal-width orbs.** They halve on the synchronic layer, and a query at natal orbs will return
  confident nonsense.
- **A whole-day grid sweep** as the primary search, per §3.

## 6 · Acceptance

`tests/prism.test.html` gains a P6 section (85 on that page after P4, 938 total, plus whatever P5 adds).

1. **The query's windows are the itinerary's windows.** Every returned candidate falls inside exactly one
   stop, and its stop, sign, house and Synchronic Ascendant Ruler match `template.stops[i]` rather than
   being re-derived.
2. **The marks a candidate reports are exactly the marks P5's ledger reports for that instant**, at max
   delta 0.00 minutes on the times. One path to a mark, measured, not assumed.
3. **Determinism:** the same chart, day and criteria return byte-identical results across runs and across
   sample orders. Nothing may depend on a previous sample (the P4 law) or on iteration order.
4. **Ranking is stable and explicable:** every candidate carries the reasons it scored, and reversing the
   criteria reverses the order rather than reshuffling it.
5. **The flip is scored as an ordinary boundary crossing**, not a special case. Assert a synthetic day
   where the flip window and an ordinary window are otherwise identical, and require the scorer to treat
   them as the same kind with only step weight differing.
6. **No unqualified lord and no unqualified house** appears in any query output.
7. **Orbs halve:** a candidate that would qualify at natal orb and not at synchronic orb is absent.
8. **A placeless chart gets no query, with the reason recorded**; above the polar circle the template
   refuses rather than inventing arrival times.
9. **The instrument is unmoved:** natal-solo and live-sky renders stay byte-identical, as P0b pinned them.
10. Nothing was written to the spine and no event table gained a row.

## 7 · Hygiene owed

- `prism.js` / `prism.browser.js`, `framing.js` / `framing.browser.js`, `loom.js` / `loom.browser.js` are
  hand-maintained mirror pairs with **no generator**. Mirror in the **same turn** and verify by running
  `tests/prism.test.html`, `tests/loom-algebra.test.html` and `tests/loom.test.html`, never by assuming.
- Snapshot `archive/Orbo Astrolabe YYYY-MM-DD.dc.html` before the first DC edit.
- Version to v0.896 (assuming P5 took v0.895).
- No em-dash, anywhere, including the write-up.
- Bump the CODEC if a stored shape changes; filed tables must miss rather than be read wrong.

## 8 · Suggested order

Ring screenshot first. Then scoring over the seven stops with the stop criterion alone, which is testable
against the template with no marks involved. Then the marks, reusing P5's surviving path verbatim. Then
refinement within the winning stop. Then the locality copy, which is the piece most likely to be skipped
and is the one that prevents a wrong answer being trusted.
