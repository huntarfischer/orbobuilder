# Prompt · Phase 6 · P4 · the dial

*Proves:* it survives a full day of scrubbing with the flip crossed in both directions, and it shows
the flip as a pole change rather than a glitch.

Plan of record: `specs/Phase 6 - The Synchronic Prism.md` §7, §14.1, §10. **BUILT 2026-08-07, v0.894.**

---

## 0 · The ruling, as amended by the user and built

The first draft of this prompt put the flip at the centre and proposed predicting its hinge. **That was
the wrong emphasis and the user corrected it.** The correction is the phase:

> **The synchronic day is a RETURN.** The sASC leaves the natal Ascendant, walks, and comes home to the
> natal Ascendant, because `sASC = midpoint(nASC, horizon)` and the horizon makes exactly one
> revolution. Its value contains no time: nASC at 0° Aries with the horizon at 0° Taurus puts the sASC
> at 15° Aries, at every epoch there has ever been. So the map is a table and the day is that table
> plus one number.
>
> **The dial's quantity is therefore the WALK, not the jump.** P3's identity is `horizon = nASC + 2σ`
> for the whole day with no branch, so `σ = norm360(horizon − nASC)/2` is continuous, monotone, 0 to
> 180 across the day, and read from ONE sample. **The flip is σ = 90**, the far point of the excursion,
> the degree opposite the return. The walk does not jump there; only the DRAWING jumps, because a 180°
> walk is being painted onto a 360° wheel.
>
> **So a flip is a boundary crossing of the same class as the other six** (`itineraryOf` already ruled
> this: one kind, seven a day, six of step 1 and one of step 6). It changes the sign, the house, the
> dispositor and which degrees the Ring is measuring against. It changes nothing about the motion.

Everything the first draft wanted from prediction falls out of this for free, and the machinery it
proposed to build is not needed. Nothing detects anything.

## 1 · The defect it deleted

`_updateComposite` marked a flip with `Math.abs(F.wrap180(lon - prev[key])) > 150`, a between-samples
leap detector, and a leap detector cannot survive a cursor that leaps. The synchronic Ascendant walks
180° a day, so a scrub steps past 150° with no crossing in the interval, and can step across the real
crossing under 150°. Nothing guarantees two consecutive calls are adjacent in time either: a memory
tap, a glide home and an almanac jump all move the cursor arbitrarily far in one tick.

**Measured, and now standing in the suite forever:** at six-hour steps the deleted detector reports
**0** flips across a day that contains exactly **1**. That number is the whole argument.

## 2 · What was built

- **`prism.js` §6 (mirrored by hand into `prism.browser.js` in the same turn).**
  - `walkOf(nASC, horizon)` · the whole of P4's arithmetic. Pure: no time, no latitude, no ephemeris,
    one wrap and one halving. Returns σ, the pole bit, the refracted degree, the fraction of the day
    walked, the distance to the flip and to home, and which end of the arc the walk is heading for.
    The degree comes through `framing.refract`; the algebraically identical closed form
    `c + σ − 180·pole` is deliberately not written, because a second expression for a refracted degree
    is a second refraction path however correct it is.
  - `stopAtWalk(template, σ)` · where the walk is on the itinerary. A lookup, not a re-derivation.
  - `dialOf(template, nASC, horizon, opts)` · the reading, **including the disagreement §1.1 promised**:
    `fraction` is the day walked in degrees, `timeFraction` is the day elapsed in time, and `drift` is
    the signed difference. Hand it a null template and the walk half still answers, so a chart with no
    place still has a dial. `flipJd`/`homeJd` on request, from `ramcJdNear`, rotation only.
  - **CODEC 2 → 3.** Every stop now carries `sigma`/`sigmaEnd`. The value was computed inside
    `templateOf` since P3 and thrown away, which is the `frameOffset` lesson for the third time: a value
    computed and not recorded is invisible to every reader, and the dial is the reader that wanted it.
- **`_updateComposite` in the DC.** The `> 150` test is deleted, not tuned. `compPole` (the bit, from
  `framing.phaseOf`, exact from one sample) and `compReturn` join `comp`/`compArc`/`compFlip`.
  **Two pole changes a cycle and only one is a flip:** parity also turns over at the return, where the
  point is continuous and doctrine says that is not a flip. Direction cannot discriminate them under
  bidirectional scrubbing. The walk can, and does, without a threshold in disguise: **the flip is at an
  END of the arc, the return at its CENTRE, 90° apart.** Measured 89.9998° and 0.0212°.
- **No new drawing, no new geometry, no new widget.** §14.1's ruling stands: the dial is the wheel in
  the `natalAsc` frame, which already exists. The instrument is untouched, which was P1's proof
  obligation and remains the standard.

## 3 · Acceptance, measured

`tests/prism.test.html`, three new sections, **85 checks 0 failures** (was 62).

- One flip and one return per sidereal day, **forward and backward, at four step sizes spanning a
  1350× range** (a frame, a minute, an hour, six hours): 1→/1← at every one.
- Every crossing found, in both directions and at every step, is the same **predicted** hinge, missed
  by exactly the step size and never more. A detected crossing can only ever be the first sample past
  the hinge; that is the sampling's error, never the dial's.
- **A discontinuous cursor reads identically:** 500 samples visited in random order agree with the
  monotone walk. There is no state to corrupt.
- The walk is **continuous** through the flip (largest single-frame change 0.06126°) and **monotone**
  (the horizon never stations, so the sASC has no retrograde and no stutter).
- The arc law holds all day: measured maximum **89.982269°** of a permitted 90°. The sASC never leaves
  the half-wheel §14.1 confines it to.
- The pole bit equals `framing.phaseOf` at 720 samples, checked rather than assumed.
- The flip is the horizon opposing nASC at the predicted hinge, and the sASC is at an arc END there.
- **The disagreement, as a number at last:** the walk runs up to **9.21% of the day** ahead of the
  clock, at σ 115.4°, on a template whose unevenness is **2225.7×**. §1.1's claim, measured.
- The dial's degree equals the instrument's degree to 1e-12 at 400 samples: one refraction door, so
  they cannot disagree.
- A placeless chart gets a walk and no clock; above the polar circle the dial refuses the time half.
- Untouched: `framing.js`, the instrument's drawing, `fertilize.CODEC`. Nothing fused, nothing on the
  spine, no event table gained a row.

## 4 · Still P5's

§7's ♓ Composite `Clock` socket, the ledger's segment rows, and the electional query. The dial is a
reading; the socket that opens it is the pane's, with the ledger.
