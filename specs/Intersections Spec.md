# ♓ Intersections — spec (Opus, July 15)

## The finding that resolves this
`gradeSynastry(natal1, natal2, jd, posAt)` already fuses **both** charts to the wheel's
current `jd` before grading — `compA[b] = midpoint(natal1.pos[b], posAt(jd)[b])`, same for
`compB`. It never grades natal×natal. So today's "synastry" chip is *already* the
intersection reading: aspects between your moment-composite and theirs, at whatever jd the
wheel shows. There is no second engine to build. The problem is entirely in how the UI
frames, gates, and labels that one computation.

## What's actually wrong (the audit)
1. **The freeze requirement is a false dependency.** `_sheetDataSynastry` only reads `rc.pos`
   (B's fixed natal positions) and `rc.jd` — both static per-B facts, not "current state of
   the rete." Seating B and letting the rete keep animating live transits would not break the
   computation at all. Freezing today is a side effect of how seating happens to be
   implemented, not something the reading needs. **Per your call: stop denoting frozen/live
   at all** — seat B, read the intersection, whether or not the rete visually holds still.
2. **The language lies about what's being computed.** `syTitle: 'you × ' + name`, `sySub:
   'composite × composite'` — the sub-label is *right* but buried under a title that reads
   like plain synastry. `syBlockedText` says "seat a chart on the rete to read the pair" with
   no hint that it's a live, time-anchored reading, not a fixed compatibility profile.
3. **No natal-only mode exists.** You confirmed this doesn't need fixing — the composite×
   composite case (now named Intersections) is the whole thing. I'm dropping the earlier idea
   of a natal×natal "classic synastry" variant; it was my assumption, not your spec.
4. **No framing choice per side.** You want the rete's B-seat to offer **the same two
   framings your own read already shows** — natal-B (plain, unfused) vs composite-B (B × this
   moment) — mirroring natal-you vs composite-you. Today there's no such toggle; B is always
   silently fused.

## The unified model
One reading, one name: **Intersections**. Two independent per-side framing switches — mine
and theirs — each natal | composite:
- **natal × natal** — the one truly time-independent case: your birth chart's aspects to
  theirs, full stop. No `jd` fusion on either side.
- **composite × composite** — today's existing computation, now correctly named: both of you
  fused to *this* moment, aspects between the fusions. This is "the intersection" proper —
  where two lives crossing through the same instant touch each other.
- **natal × composite / composite × natal** — asymmetric: reads how your bare self relates to
  where their moment has carried them (or vice versa). Not a mode you asked for explicitly,
  but it falls out for free from two independent switches, costs nothing extra to wire, and a
  toggle platform that only supports the symmetric pair would look broken (two switches that
  can't move independently). Flag if you want the asymmetric pair hidden.

`gradeSynastry` needs one new parameter, not a new engine: a `fuseA`/`fuseB` boolean pair —
when false, `compA[b] = natal1.pos[b]` (no midpoint, no jd term) instead of fusing.

## Where it lives — the ♓ menu as the toggle platform
Per your read of point 4: ♓ is not a new engine, it's **the glossary + control surface** for
the one thing "synastry" already computes. Contents:
- Two switches, "you" and "them" (them = whoever's seated), each natal ⟷ composite. Visually
  matched to how your own natal/composite states already read elsewhere on the instrument —
  same chip grammar, not a new control language.
- A one-line gloss under each switch state (four combinations × short line), e.g.
  composite×composite: *"where your moment and theirs cross, right now."* natal×natal: *"the
  bond as written at birth, time-independent."* — exact copy TBD with your steer, but the
  principle is: the glossary explains what's being read, so the switch state is never
  ambiguous the way "synastry" alone was.
- The seat picker (→ ♎ Scroll) stays exactly as is — one-to-one, B via the rete.

## Rete seat — what changes, what doesn't
Two-seat law is untouched: rete = actor, plate = subject. What changes is just that **seating
B no longer implies a frozen/live distinction the UI cares about** — B's seat is a data
reference (which natal, optionally fused to jd per the ♓ switch), not a display-freeze flag.
`_reteFrozen()` may still exist for whatever *visual* purposes it independently serves (if
any survive after this pass) — it should no longer gate whether Intersections is readable.

## Renames (UI copy, not engine)
- `viewChips` label: `synastry` → `intersections` (or a shorter house-name if you want one).
- `syTitle` → reflects the active switches, e.g. "you (composite) × Dana (composite)" or
  "you (natal) × Dana (natal)" rather than a flat "you × name".
- `sySub` → the one-line gloss from the glossary, swapped per switch state.
- `syBlockedText` → "seat someone from ♎ to read the intersection" (drop "the pair," which
  undersells that time is doing something here).

## Open, for your steer
1. Exact glyph/label for the renamed chip and the ♓ menu header.
2. Copy for the four gloss lines (I can draft; flag if you want to write them yourself).
3. Whether the asymmetric natal×composite pair ships or gets hidden behind "explore more"
   framings later.
4. Does the composite×composite default match what's default *today* (yes, currently always
   composite×composite) — I'm assuming that stays the opening state so nothing regresses.

## Not touched by this spec
ZR reading, Ammonite timespine — separate specs, still gated on your answers to the standing
questions form.
