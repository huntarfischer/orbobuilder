# Phase 7 · Synchronic Time

Planning document, 2026-08-12. Nothing in here is built.

It supersedes nothing and repairs three things Phase 6 left in the wrong place: the clock, which was
built as a pane lens when P4 had already ruled it was the wheel; the chronology, which computes a
spine and throws it away; and synchronic synastry, which has no spine at all and therefore answers
every question from a snapshot at `now`.

Its one claim is that those are not three features. They are one object read at three scales, and
they were built as three subsystems because nobody had written down that they were one.

---

## 0 · The statement

**Synchronic time is one number.**

```
synchronic time = frame index + σ/180
```

`frame index` is which return you are in, counted from birth. `σ` is how far the sASC has walked from
the natal Ascendant within that return — 0 at the anchor, 90 at the flip, 180 at the anchor again;
continuous, monotone, and available from ONE sample with no previous sample and no unwrapped trace
(P4).

The Composite Chronology owns the integer part. The Clock owns the fractional part. They are the same
clock, and today they are two unrelated subsystems that compute the same anchor two different ways.

**And the prism is a MODE, not only a seat.** P1 seated the prism as an occupant so it could be read
*beside* the sky. This phase adds the other act: the prism laid over the whole instrument, so every
value arriving at every reader is refracted and you are reading the synchronic world rather than
comparing it to something. That is what a prism in the light path does, and §0 of Phase 6 already
said so in words — *"nothing about the source moves and nothing about the reader moves; the values
arriving at the reader are refracted"* — while the build applied it to exactly one occupant.

---

## 1 · Two paths to one anchor · fix this first

`_ptFrameJd(i)` finds the instant the sASC sits at the natal Ascendant by Newton-polishing
`spine.posAt(jd, la, lo).asc − nat.asc`, five ephemeris-backed iterations per frame, **inside a 90 ms
play timer.**

`_sheetDataClock` finds the same instant with `P.ramcJdNear(template.anchor.ramc, …)` — a linear
guess plus three Newton steps on gmst alone, no ephemeris, no scan.

Same instant, two computations, two error characteristics. This is the defect class
`framing.refract` exists to prevent, and P3 built `ramcJdNear` deliberately as the principled path:
*"a duration has no epoch, which is why storing one is not storing an event time… `ramcJdNear`
supplies the epoch at read time from gmst alone."*

> **LAW.** `prism.ramcJdNear` is the ONE place in Orbo that answers "when is the sASC at the natal
> degree." `_ptFrameJd` routes through it. The Newton-on-`posAt` path is deleted, not kept as a
> fallback — a second path that agrees to a fraction of a second is still a second path, and the one
> that disagrees will be the one nobody is looking at.

Consequence worth having on its own: Chronicle's playback stops doing ephemeris work per frame.

---

## 2 · The prism as an overlay

### 2.1 It is a property of the reading

*"A reading = two spine samples + a frame"* — `_reading()` already owns frame rotation, chart count
and per-body element, and every reader in the app consumes it. **Refraction joins it as a field of
the same class as `frame`.**

That is the entire insertion point. No reader is rewritten, no drawing routine is rewritten, no new
geometry is drawn. This is P1's own proof obligation held to for the second time: *"The instrument's
own drawing is UNTOUCHED — that was the phase's proof obligation and it is the standard for P2
onward."* If this pass adds a drawing routine, it has been built wrong.

### 2.2 Everything downstream refracts, and that is the point

Today, seating the prism refracts one track. The rim readout at the top of the screen, the houses,
the transit ledger, the almanac and the pane's rows all continue to read the raw sky. That is the
gap: the prism is available as a chart to look at and not as a world to be in.

Under the overlay, everything that reads the reading is refracted, including:

- the rim readout — **`As` becomes the sASC**, the Moon and Sun become the synchronic Moon and Sun
- the beads on the lit track, their glyphs, periods, de-collision and moon face
- the houses, the aspect web, the dispositor chains, the lots (which refract exactly, since a lot is
  an affine combination whose coefficients sum to 1 — established P1)
- the pane's readers, unchanged, because their inputs changed and they did not

### 2.3 One door, and it is already greppable

Every one of those values goes through `framing.refract(natalLon, momentLon)`. That is the whole
reason the door was built and made greppable, and an overlay is the first thing that actually
exercises it at scale.

> **NEVER** add a second refraction path, and **NEVER** a refraction table. The refraction is one
> wrap and one halving — cheaper to compute than to look up, and a table would quantize to whole
> degrees against the codec law.

### 2.4 THE NATAL CHART IS THE PRISM, and it is the fixed point of its own refraction

An earlier draft of this section said the natal does not refract, being an operand. That was an
exception, and this codebase does not keep exceptions it can dissolve.

**The natal chart is not passed through some external prism. The natal chart IS the prism** — the
medium every degree of sky is bent halfway toward. And a prism seen in its own light is undeviated:

```
refract(natal, natal) = midpoint(natal, natal) = natal
```

So the natal refracts like everything else, refracts *itself*, and shows itself. It is the **identity
case of the rule, not an exception to it.** Same shape as P3's identity carrying the day with no flip
case, and P4 refusing a parity bit: one expression, no branch.

> **LAW.** The overlay applies `framing.refract` **uniformly, to every occupant, with no skip list.**
> A conditional that excludes the natal is refused — it re-encodes as a special case a thing the
> arithmetic already does for free, which is the defect class of an invariant living only in a
> comment.

The plate therefore still shows natal degrees, and now for a reason rather than by exemption: they
are what the refraction returns. Material law is unchanged — plate engraved, rete lit, whatever is
seated on each.

**Twice already discovered and twice filed as coincidence.** P1: *"at birth the horizon equals nASC,
so the midpoint is nASC."* `_ptFrameJd`: *"day 0 IS the birth moment"*, where composite collapses onto
natal. Both are this fixed point. Naming it once retires both notes.

**And it says what the return returns TO.** P4 established that the synchronic day is a return; the
fixed point says the destination is the prism itself. σ = 0 is the Ascendant's daily re-touching of
the identity case, which is why the anchor is not an arbitrary protocol choice — it is the only
instant of each day at which the refraction is transparent. Chronicle's day 0 is simply the first
such instant.

### 2.4.1 The fixed point is NOT the double-application error

These are one keystroke apart in prose and must never be collapsed:

```
refract(natal, natal)              = natal                       ✓  identity · §2.4
refract(natal, refract(natal, sky)) = midpoint(natal, midpoint(natal, sky))   ✗  P1's error
```

The first refracts the prism in its own light. The second applies the operator **twice to the same
light**, producing a chart no doctrine names — the error `_reteIsOther()` was split off to prevent,
and *"worse than the empty seat it replaced, because it returns plausible rows instead of an error"*
(21 rows, measured). `_reteIsOther()` stands exactly as it is. **The prism is me refracted; it is
never a partner.**

### 2.5 The hit map is geared 2:1

This is the hard problem and it has a clean answer.

P1 gave the prism-as-occupant `frozen: false` but **no scrub hit**, because `this.held` resolves
longitudes through `this.pos` — the cursor's own sky — and a refracted degree is not one of those. As
an occupant that was fine: one untouchable track. Under a full overlay every bead you can reach is
refracted, so "nothing is grabbable" would take away the instrument's primary gesture.

Refraction is invertible. From `sLon = midpoint(nLon, skyLon)`:

```
skyLon = 2·sLon − nLon        (mod 360, two roots 180° apart)
```

and the root is chosen by the pole, which is `framing.phaseOf` — exact from wrapped longitudes, one
sample, no stored state. **So a grab on a refracted bead maps back to a sky degree and scrubs
normally**, through a spine door as always.

The physical consequence is the good part: `d(sLon)/d(skyLon) = 1/2`, so the refracted world moves at
half the sky's rate and **a drag of the same size covers twice the time.** In prism mode the wheel is
geared 2:1. That is not a quirk to be corrected — it is the operation made tactile, and it is the
right feel for an instrument built out of gear trains.

> **NEVER** determine the pole for the inverse by differencing two samples. P4 settled this
> permanently and `tests/prism.test.html` holds the line: at six-hour steps a leap detector reports
> 0 flips across a day containing 1.

### 2.6 Entering the mode animates, and the animation is the explanation

Per the presentation-clock law, entering and leaving prism mode is a spring on the one RAF — never a
CSS transition, never a second timeline. Every bead travels from its sky degree to its midpoint with
the natal.

**That transition IS the definition of the prism, performed.** It is worth more than any label the
back could carry, and it costs nothing beyond a spring that already has a factory (`_sprTo`).

And by §2.4 **the natal beads do not move** — the plate stands still while the sky halves toward it.
The animation therefore teaches the fixed point as well as the operation, without a word of copy: you
watch the world bend toward the chart that is bending it, and watch that chart hold.

The rest is springs' business: presentation state lives in `this._springs`, never on the spine, and
the RAF is the sole writer of any transform or opacity a spring owns.

### 2.7 Marking · THE BEAD CARRIES IT

Under an overlay every degree on screen is a synchronic degree, and a user who cannot tell which
world they are in is being lied to. §13.1's rule — *"a house is always QUALIFIED, never unqualified,
anywhere in the app"* — becomes acute rather than theoretical.

**A bead today says WHO and not WHAT.** ♂ tells you the point is Mars. Nothing on it tells you whether
that is the sky's Mars or Mars refracted through your chart, and under the overlay that is the only
question that matters. The bead is the smallest unit that carries a value, so it is the right unit to
carry the value's provenance — and because every refracted degree on screen is attached to a bead,
marking the bead marks **every value, with no exceptions, no legend, and nothing to keep in sync.**

> **LAW.** The mode is marked on the BEADS. Not a corner badge (it says it once, quietly, in the one
> place the eye is not), not a field wash alone, not a line of copy on the rim.

**And it is an occupant property, never a second drawing routine.** `_drawLitTrack` already works this
way: `occ.frozen` is a field on the occupant that changes how the bead renders, inside the one
routine. Refraction joins it in exactly that shape. The precedent for treatment-carries-kind within a
single track is also already there — O3 sends the angles down a different path (an ~8.5px bold-sans
badge, no backing disc) from the bodies' glyph discs, in the same loop.

> **NEVER** branch `_drawLitTrack` into a refracted variant. That is the `skyOn ? drawOrder : []`
> mistake, which reserved the lit treatment for the sky and left every other occupant to a
> hand-rolled second routine — the flat 11px debug overlay P0b-repair deleted. One routine, one more
> field.

Second requirement, unchanged: any house shown in prism mode is labelled as the synchronic house, and
the natal house stays reachable. Two readings, never in competition.

The treatment itself is the build's to propose against these constraints: legible at bead size,
survives the existing de-collision and level-stacking, does not collide with the held state's gold or
with element colour (which carries element and must keep carrying only that), and reads at a glance
across a whole track rather than requiring bead-by-bead inspection.

### 2.8 Prism mode and frame are orthogonal · never conflate them

`frame` answers *what is at the top of the wheel*. Prism mode answers *which world the values are
from*. They are independent switches and both must remain so.

P4's dial is the wheel in the `natalAsc` frame. The **full** dial — the reading §0 describes — is
prism mode **and** `natalAsc` frame together, at which point the sASC is confined to the half of the
wheel spanning the 10th through the 4th and σ is legible as an angle on the face. That is the last
piece of *"no new drawing, no new geometry, no new widget"*: the widget is the instrument, twice
configured.

### 2.9 The prism as an occupant SURVIVES

`rete: 'prism'`, `_prismChart()`, `_reteSeated()` / `_reteFrozen()` / `_reteIsOther()` all stay
exactly as they are.

Seating the prism is *comparison* — the refracted chart beside the unrefracted one. The overlay is
*immersion* — the refracted world alone. **Two acts, two mechanisms.** A later pass will be tempted
to unify them because they share arithmetic; that is the same temptation `midpoint` vs `refract`
already refused, and it is refused again here for the same reason.

Prism-mode-on **and** prism-seated-on-the-rete is the degenerate case: one chart on both wheels,
threading every bead to itself at 0°. Mutually exclusive, as composite-on-plate and prism-on-rete
already are.

---

## 3 · The solo synchronic spine

**Chronicle already is this spine's time axis and discards its values.**

`_ptFrameJd(i)` enumerates a canonical sequence of moments — one per return, birth-anchored so
indices are stable, memoized in `_ptCache` — and stores `i → jd`. Nothing else. Every scrub
recomputes the whole refracted chart live.

The engraved spine's thesis is *"every ephemeris-expensive event of the nativity's ~century, scanned
once and materialized… to query instead of rescan."* Chronicle does the scan and drops the result.

> **The solo synchronic spine is `_ptCache` widened from `i → jd` to `i → refracted state`.** Not a
> new subsystem. A cache that keeps what it already computed.

### 3.1 The anchor grid is the right grid, and a civil grid is not

Sampling at the rising return holds **the horizon constant across every sample**, so each frame is
taken in the same frame and the values are comparable sample-to-sample. A uniform civil-midnight grid
would catch the sASC at a different point in its 180° walk every sample, and the comparison would be
noise dressed as motion.

P3 measured the anchor: 800 live anchors one sidereal day apart to 0.0001 s, regression 3.9318
min/day. That is a grid you can difference against.

And the frames are exactly the **σ = 0** instants, which is why the spine's index and the clock's
fraction concatenate into §0's one number instead of merely coexisting.

### 3.2 Trigger, identity, span, persistence

- **Trigger: lazy on first enable, in the shape of `_zrData()`.** ZR builds its table when the socket
  is first read and not before — `_progData` states the rule outright: *"LAZY: never built just
  because a natal chart exists — only when the item is actually read. Memoized exactly like
  `_zrData()`."* **The composite sockets take the same contract.** Engraving a natal chart mints no
  spine; opening Chronicle, Clock or the overlay for the first time does.

  The one difference from ZR is cost, not shape: `_zrData` is pure arithmetic and can build
  synchronously on the read. A century of returns is ephemeris work, so the lazy trigger starts an
  **incremental** build and the socket reads what exists while the rest fills in. Trigger from
  `_zrData`, build from `makeUnspooler`, storage from the engraved spine.
- **Identity:** chart × prism `CODEC` × `doctrineKey`, mirroring the engraved spine's `sequenceString
  × SPINE_VERSION` and ZR's own `dna.jd + doctrineKey`. Today `_ptCache` is keyed on `njd` alone, so
  **a changed birth place or a codec change silently serves stale frames.** That is a live defect,
  not new work.
- **Span:** the century, matching the engraved spine.
- **Persistence: IndexedDB**, like the engraved spine. Rows are emitted; persistence is the app's
  concern, never the engine's.
- **Built incrementally** by an unspooler in the shape of `makeUnspooler`: chunked on idle, phase-
  locked chunk starts so a chunked build is bit-identical to a one-shot one, seams deduped.

Size: ~36,600 returns per century × ~15 refracted longitudes per row. Tractable at Float32; the
codec law forbids quantizing to whole degrees, and Float32 clears that by three orders of magnitude.

### 3.3 The window control is broken in the same way twice

`_ptInfo` caps `max` at `nowJd + 365.25`, and `ptSpan` only raises `min` — *"the same end, a raised
floor."* So Chronicle's control adjusts your view of a fixed span rather than the span.

That is the identical defect as `crossBack`/`crossFwd` filtering a snapshot (§5). Same family, two
sockets, one fix: **a window control sets what is computed, never merely what survives a filter.**

---

## 4 · The pair synchronic spine

### 4.1 It has no anchor, and that is doctrine rather than convenience

*"A solo frame is a CHART: it has a horizon, so it needs a place AND a moment… A pair contact is an
ANGLE: it needs only time. So Crossing has no frame protocol and never needed one, and the
same-ascendant anchor is a SOLO protocol, definitionally unshareable."*

So the pair spine cannot use my anchor or theirs. It samples on plain uniform time, and being
place-free it is the byte-identical export doctrine already promises.

### 4.2 Two payloads, because the two kinds of separation are not alike

**Same-body → stored VALUES.** `sP_A − sP_B = (natalA − natalB)/2` exactly: the sky term is the same
term on both sides and cancels (measured 0.000000000° across 14 bodies × 400 days). The separation is
therefore **piecewise-constant with exactly two possible values**, `{δ/2, 180−δ/2}`, selected by the
parity `phaseOf(A) ^ phaseOf(B)`. Nothing to interpolate — only a step to notice. Stored as runs, a
century is a few hundred segments per body: effectively free.

**Cross-body → stored CROSSINGS.** `(skyA − skyB)/2` does not cancel; these vary continuously at half
sky speed and genuinely perfect and separate. Storing every value would be ~15 MB of numbers nobody
reads. Store the crossings, exactly as the engraved spine stores hits — **this is the "exact copy of
the engraved spine, refracted" in the literal sense.**

Sampling: same-body needs a daily grid at most, refined only near stations (which the engraved spine
already knows the location of) so retrograde stutter is honoured rather than smoothed. Cross-body
uses `SPINE_STEP`'s own logic on refracted longitudes.

### 4.3 Minted on favorite

Favoriting a chart mints its pair spine, keyed `(natalA, natalB) × CODEC × doctrineKey`, persisted to
IndexedDB alongside the solo spine, century span, built on idle.

Also mint that chart's own **per-chart prism tables**, which requires only their latitude — already
sitting unasked-for in `_reteChart`. `_prismTables()` is currently hardcoded to `this._natal()` with a
single cache slot, so **no chart but mine can have a template.** It takes a chart and keys a small
cache. Pure refactor; Clock and Query see no behaviour change.

---

## 5 · Reading is comparison, never detection

> **LAW.** The flip is not the subject. Values are stored; events are read out of them by comparing
> adjacent samples. Nothing in a reader detects, thresholds, or differences the cursor.

This is P4's ruling carried into the readers instead of stopping at `phaseOf`. A stored value table
contains no detector, so there is nothing to survive a leaping cursor. Where a precise boundary is
wanted, it is recovered by **bisecting on the table** at read time — a reading, not a stored event,
and consistent with *"no event times, ever"*: a sample is a value at a time and asserts nothing
happened. Events remain derived views, the status `isFlip` and `isReturn` already hold in
`timespine.js` under *"tagged views — derived, never stored."*

### 5.1 The case that exposed all of this

Two natives, Venus, family `{1.8°, 178.2°}`. B's Venus flips today; A's flips in three days. Between
those two instants the parity is odd, the pair sits in **mode 1 — an opposition — for three days**,
and then returns.

Today the app cannot say this. `_sheetDataCross` sets `exactJd: sameBody ? null : …`, so same-body
pairs are excluded from the chronology by construction and `_almCross` filters them out of the
almanac and the `.ics` behind them. What the pane renders instead is `fam.separation + ' apart, fixed
since birth'` — the current mode computed **correctly** from `phA ^ phB`, and then labelled with a
phrase that denies the mode can change. "Fixed since birth" is true of the family and false of the
mode.

On the pair spine this needs no flip computed anywhere. Two rows differ; the reader says so:

> **Venus · 1.8° → 178.2° · opposition from Aug 13 to Aug 16**

### 5.2 The window control, third instance

`crossAspects(…, now, …, {orb: 3})` is a snapshot at `now`: only pairs within 3° **at this instant**
ever enter the list, and `crossBack`/`crossFwd` then filter that snapshot. **The window can only
subtract.** Pairs in orb now perfect within days, which is why 150 days ahead reads about a week.

Worse, widening the window raises `scanH`, so `_crossExact` walks 0.5 d in both directions per pair —
roughly 780 `posAt` calls each — to find nothing new. The control costs time to do nothing.

On the spine, 150 days is a binary-searched slice. Membership becomes *"perfects inside the window"*
rather than *"is in orb now"*, and orb goes back to being what it should be: a property of what you
see, not a hidden gate on what exists.

Two smaller defects to fix in passing:
- `_almCross`'s cache key omits `crossBack`/`crossFwd`, which feed `scanH` — change the window, get
  stale almanac rows.
- `_almCross` gates on `typeof r === 'object' && r.jd`, the shape-not-occupancy test the seating law
  outlawed. It wants `_reteIsOther()`.

---

## 6 · What leaves the lunar pane

The clock leaves. *"The astrolabe is the sun — it IS the light: geometry, motion, the physical truth
of the moment."* Synchronic time is the most literally geometric thing in the instrument, and it was
built as a sheet you pull up to find out what time it is.

- **The ♓ Clock socket sets the mode** (prism on, `natalAsc` frame) instead of opening a sheet.
- **`ledgerOf` stays on the pane**, correctly, under its own name: the synchronic day's *ledger* is a
  way of looking at the day. It is a moon view and always was. It is not the clock.
- **σ and drift are read off the instrument.** `dialOf` reports `drift`, the signed disagreement
  between degrees walked and time elapsed — up to **9.21% of the day** on a template **2225.7×**
  uneven. That number is the reason a synchronic clock needs a face and not a percentage, and it has
  never appeared in the UI.

Then the pane is rebuilt around what it actually holds — the static blocks move to the back where the
impersonal register lives, the window control moves to the crown beside the reading it governs, and
the chronology gets the height. That is last, deliberately: the layout cannot be settled until the
readers stop lying about what they know.

---

## 7 · The recording law

> **A value computed and not recorded is invisible to every reader.**

Fourth instance, so it stops being an anecdote:

| | computed | recorded | cost |
|---|---|---|---|
| `frameOffset` | per stop, since P3 | no | the day reported ONE offset instead of seven, silently |
| `sigma`/`sigmaEnd` | inside `templateOf`, since P3 | no, until CODEC 3 | the dial could not be built |
| Chronicle's frames | per scrub, ephemeris-backed | jd only | no synchronic spine exists |
| the live mode | `phA ^ phB`, correctly | no | labelled "fixed since birth"; §5.1 |

P2's load-time check now refuses a stop that does not carry its offset. **Every table this phase adds
carries the same kind of check**, and the suites are run rather than assumed — including the hand-
maintained `framing.browser.js` / `loom.browser.js` / `prism.browser.js` mirrors, which have no
generator and must be mirrored in the same turn as their sources.

---

## 8 · Order of work

**The tables come first.** The point of this phase is a body of reference material the readers read;
building the live view first would mean building it against live recomputation and then rebuilding it
against the spine.

1. **One anchor door.** `_ptFrameJd` → `ramcJdNear`; second path deleted. Prerequisite for everything
   below, since the anchor IS the solo spine's sample grid — and it takes ephemeris work out of the
   play loop on the way past.
2. **The solo synchronic spine.** `_ptCache` keeps refracted state, keyed chart × CODEC ×
   doctrineKey; lazy on first enable like `_zrData`; incremental unspool on idle; century; IndexedDB.
   Chronicle stops discarding what it computes.
3. **Clock to the instrument.** ♓ Clock sets the mode rather than opening a sheet; σ and drift read
   off the spine and legible on the face; `ledgerOf` stays on the pane under its own name.
4. **The prism overlay** — refraction as a field on `_reading()`; the bead marking (§2.7); the inverse
   hit map and its 2:1 gearing; the entry spring; the house qualification.
5. **`_prismTables(chart)`** takes a chart and keys a small cache. Pure refactor; unblocks 6.
6. **The pair spine** — minted on favorite; same-body value runs, cross-body crossings; century;
   IndexedDB.
7. **Synastry reads slices** and compares adjacent values; §5.1 appears; the window control becomes
   real; the two `_almCross` defects go.
8. **The pane's layout**, last — it cannot be settled until the readers stop lying about what they
   know.

## 9 · Proof obligations

- The instrument's own drawing routines are **unchanged**. A diff that adds one is a failed pass.
- A natal-solo render with prism mode off is **byte-identical** to today's, the bar P0b set.
- The inverse hit map recovers the cursor to the same precision the forward path has, and the pole is
  never taken from a difference of two samples — asserted at six-hour steps, per P4.
- **The fixed point holds to 0.000000000°**: `refract(natal, natal)` returns every natal longitude
  unchanged, including the Ascendant and all eight lots (refraction is affine and a lot's
  coefficients sum to 1, so the lots inherit it). Asserted at load, beside P2's offset check.
- The overlay's refraction path contains **no skip list and no natal conditional** — a grep obligation,
  the same kind `framing.refract` was made greppable to serve.
- **`_drawLitTrack` remains one routine.** Refraction is a field on the occupant beside `frozen`; a
  refracted drawing variant is a failed pass, per P0b-repair.
- **No spine is built by engraving a chart.** Asserted: engrave a natal, touch no composite socket,
  and no synchronic table exists.
- Same-body separations hold to 0.000000000° across the century on the pair spine, as P2 measured
  them over 400 days.
- A chunked spine build is bit-identical to a one-shot build, per the conformance law.
- The window controls compute their window. A test sets 150 days and asserts rows beyond day 7.

## 10 · Refused and deferred

- **No new widget, no new geometry, no new drawing routine.** §14.1, upheld for the third phase.
- **No second refraction path and no refraction table.**
- **No exception for the natal, and no branch that implements one.** It refracts uniformly and
  returns itself; see §2.4. What stays refused is the *double* application, §2.4.1.
- **No unification of prism-as-mode with prism-as-seat.** Two acts.
- **No event times on any spine.** Values and crossings; events are derived views.
- **Lot arcs still not stored** — sect is the synchronic chart's own, so there is no single stable arc
  to store. Lots refract live and exactly. The deferral is recorded unconditionally on every build.
- **Geocentric by law.** A topocentric toggle breaks the shared-sky cancellation through lunar
  parallax, and the Moon is the body the pair spine cares most about.
