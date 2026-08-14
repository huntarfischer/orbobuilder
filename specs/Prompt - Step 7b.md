# Prompt · Step 7b · delete the union algebra, retire the scanning body, strike the word "union"

Companion to `specs/Rewire - Angles onto the Ring.md` §6 and `specs/Prompt - The Ring.md` §7 and §10.
Read `CLAUDE.md` first. Orbo never uses the em-dash, here or in chat.

**Status of the rewire when this was written (2026-08-04, v0.879):** steps 0, 1, A, B, C, D, D2, E, F,
G, 7a, J and K are done. `tests/_suite.html` is the gate. 7b is the last step of the rewire that
touches stored bytes, and L (the Connectome compiler) is additive after it.

---

## 0. Why these four things are ONE session

Each of them moves `fertKey`, and a step that moves a cache key must not run twice. That is the same
argument §3 made for putting F and G in one block, and the same one 7a was built to satisfy.

- the union target algebra deletion changes the row layout
- retiring `synEvents`' scanning body changes nothing stored, but it is the same code
- `loom.js`'s hand-rolled nearest dies with the algebra
- the rename puts `syn` where `union` is, and **`layer` rides inside the stored bytes**

Run them separately and every reader rebuilds a century of weave two or three times instead of once.
Note what 7a bought and what it did not: the arcsecond widening rebuilt nothing because the key is cut
at the whole-degree projection, but **7b's rebuild is real and unavoidable**, because the bytes
themselves change. Accept one rebuild. Do not try to be clever about avoiding it.

## 1. THE CONTRADICTION TO RESOLVE BEFORE WRITING A LINE

Two records in `CLAUDE.md` disagree, and 7b is where the disagreement comes due. Do not start until
this is settled, because the whole shape of the step depends on which one wins.

**The Ring's record says the algebra is an artifact of asking the wrong question:**

> EVERYTHING IN ORBO EXISTS ON THE RING [...] and the whole union target algebra (`unionToSky`,
> `skyToUnion`, `unionIngressTargets`, `unionFlipTarget`, `unionSepToSky`, `unionSepFamily`,
> `unionSepClass`), the double-target hazard and `serves` exist only because sky-space questions were
> being asked about a Ring occupant. `layer` is not a geometry, it is which occupant is sitting there.
> The only genuine difference between layers is SPEED (natal 0, transiting v, synchronic v/2).

**The Loom's record credits the pullback with deleting a real bug:**

> Scanning in SKY space deletes the phase gate. The union placement's sky argument is continuous
> through a flip, so the `d > 150` heuristic and its successor parity gate have no analog here: a flip
> is one target of its own and can no longer be miscounted as six ingresses.

Both are true statements about different things, and the tension is not rhetorical. `midpoint(N, S)`
is **discontinuous in S**: as the transiting body passes `N + 180` the displayed point jumps 180
degrees. Scan that raw value and the six-ingresses bug returns, exactly as the Loom record warns. So
"just delete the pullback and scan the occupant where it sits" is not automatically safe, and a
session that assumes it is will reintroduce the most expensive bug in the subsystem's history.

**The proposed resolution, to be verified and not assumed: scan the AXIS, carry the PHASE.** The
discontinuity lives in the pole CHOICE, not in the occupant. The axis (`mod180` of the point) is
continuous through a flip and moves at half the transiting rate, and the phase bit selects which pole
is displayed. `axisOf` and `axialOf` already exist in `framing.js` and `spine.axialAt` is already the
only door to the triple, which is a strong hint this is what they were for. If that holds, the scan
runs in the occupant's own space at half speed with no pullback, no double-target hazard, no `serves`,
and no phase gate, and the Ring's record wins without costing the Loom's.

**Verify it before committing to it,** on the fixture natal, against the numbers already recorded:
`tests/loom.test.html` measures 128 ingresses and 19 flips over a decade, identical to `synEvents`,
max delta 0.00 minutes. If an axis scan does not reproduce those exactly, the resolution is wrong and
the pullback stays. Say so in the record rather than shipping a near miss.

If it does NOT hold, the fallback is narrower and still worth doing: keep `unionToSky` and
`unionSepToSky` as the scanner's internal coordinate change, delete only `serves`, the double-target
dedup and the hand-rolled nearest, and rename everything. State plainly in the spec that the pullback
survived and why, so the next session does not relitigate it.

## 2. What is being deleted, precisely

In `framing.js`:
`unionToSky` (399) · `skyToUnion` (400) · `unionIngressTargets` (408) · `unionFlipTarget` (421) ·
`unionSepToSky` (442) · `unionSep` (443) · `unionAxisSep` (444) · `unionSepFamily` (445) ·
`unionSepClass` (447) · the `serves` field emitted at 510 · the supplement dedup loop at 495 to 512.
`unionTargets` (487) and `loomTargets` (517) survive as the renamed target builders.

In `loom.js`, the `t.serves` block at 183 to 194, including:

```js
rec.angle = t.serves.reduce((a, b) => Math.abs(b - sep) < Math.abs(a - sep) ? b : a, t.serves[0]);
```

**That reduce is the last piece of nearest-mark arithmetic living outside the Ring**, and it is why
the harness prints STILL OWED for it. If any nearest-mark decision survives 7b, it goes through
`ring.nearest`, and if the reader carries a cut of the marks it does min-residual over its own admitted
set, exactly as steps A, B and E each decided independently.

In `framing.js`, `synEvents` (241) keeps its signature and its return shape and loses its scanning
body. **It stays as the fallback**, because the DC reaches it whenever the weave cannot answer: not
built, different chart, or a window past the edge of the fertilized span. `_synEvents` at DC 5235
already tries `_fertSyn` first and falls through, so the fallback path is live today and must stay
live. Deleting `synEvents` outright would make ♐ Field go dark for every reader who has not finished
fertilizing, which is every new reader.

## 3. The rename

`union` is not an Orbo word. The layer is **synchronic**, matching `synOrb`, `synEvents` and
`synKinds`, which already speak correctly. Rename the functions, the `layer: 'union'` tag on every
weave row, the fertilize codec's layer dictionary, and the three test files.

Two cautions:
- **The row tag lives inside stored bytes**, so `fertKey` moves and every weave rebuilds once. This is
  the rebuild §0 says to accept. Bump nothing else in the same breath: `fertilize.CODEC` moving is
  correct here and was deliberately held at 1 through step J for exactly this reason.
- **Do not rename `midpoint`.** It is the display derivation and it is untouched. And never describe
  the synchronic layer as the transiting layer "halved": the midpoint is primary, and the factor of two
  lives inside the target algebra and nowhere else.

## 4. What must NOT change

- **The embryo does not rebuild.** Native-independent, place-free, angle-valued codec. Nothing in 7b
  touches a mundane row.
- `transits.js`, `luna.js`, `electional.js`, `timespine.js`: downstream, no edit. Re-verify rather
  than assume, on §1's own lesson: the tables and the call sites cluster by CONSTRUCT, not by subject,
  and this inventory has been wrong three times for that reason.
- **The instrument does not move.** Nothing in 7b is on the plate. If the wheel changes by one pixel,
  something is wrong.
- **The v0.878 residency guards stay**, expressed in whatever coordinate the scan ends up in: 0.1
  degrees of union residual and 0.2 degrees of sky residual are the same law. The synchronic Node
  parked within 0.02 degrees of 0 Aries produced seven ingresses in six weeks without it.
- **Supplement closure is still a real fact and does not go away with `serves`.** 0/180, 30/150,
  45/135, 60/120 pair and 90 pairs with itself; 72 and 144 do not. What dies is the LIST that conflated
  a root with its supplement's label. The reading still has to say which class is live, and it is still
  read off the two displayed points and never from parity. The parity-only rule holds for same-body
  pairs, where the sky term cancels, and for nothing else.
- **Retrograde flip stutter is three events, not one with three exacts.** Do not let a cleaner scanner
  smooth it.
- The falsy-zero contract, everywhere it crosses into the Ring.

## 5. Order inside the session

1. Snapshot `archive/Orbo Astrolabe 2026-08-0X.dc.html` before the DC is touched (versioning law), and
   note that the harness will want to read the PRE snapshot to measure against.
2. Settle §1 with a measurement, in a scratch harness, before editing `framing.js`.
3. `framing.js`: the deletion and the rename together. Regenerate `framing.browser.js`.
4. `loom.js`: the `serves` block dies, nearest goes through the Ring. Regenerate `loom.browser.js`.
5. `fertilize.js`: the layer dictionary and the codec bump. Regenerate `fertilize.browser.js`.
6. `synEvents` loses its body, keeps its shape.
7. The DC: `_synEvents`, `_fertSyn`, `_almField`, `_flips`, the ♐ Field chips. Shapes unchanged, so
   this should be small. If it is not small, the shape changed and something is wrong.
8. `tests/loom-algebra.test.html` is 23 checks ON THE ALGEBRA BEING DELETED. Do not delete the file:
   rewrite it to check whatever replaces the algebra, and keep the assertions that are about geometry
   rather than about function names.
9. Regenerate, bump `?v=` in every harness that loads a rebuilt engine, and confirm load order and the
   `__ORBO_RING` guards still hold.

## 6. Verification

- `tests/_suite.html` green, all twelve pages. Record the new totals.
- `tests/loom.test.html`'s conformance numbers reproduce EXACTLY: 128 ingresses, 19 flips, max delta
  0.00 minutes over the decade on the fixture natal. This is the check that says the deletion cost
  nothing.
- The rewire harness's STILL OWED print for the `t.serves` reduce is gone, and a new check asserts no
  nearest-mark arithmetic remains outside the Ring (a source regex, on step 1's precedent).
- The word `union` appears nowhere in `framing.js`, `loom.js`, `fertilize.js` or the DC except in
  prose explaining why it was struck.
- Load the DC and confirm the aspect web, the ♍ chip ring, ♐ Field with all three synchronic kinds on,
  and one ICS export all still read. Confirm the weave rebuilds ONCE and then stops.
- **Watch the chunk budget.** Step G already flagged it: both background builds run at 26ms of work per
  90ms gap, and after 7b every existing reader pays a weave rebuild. The wheel keeps drawing, but a
  synthetic DOM capture cannot complete while it runs. If it is too slow to be invisible, the fix is to
  SERIALIZE the two builds, not to widen either slice, and that is a decision about the instrument's
  feel rather than a refactor.

## 7. Rulings needed before writing

1. **§1, the axis-versus-pullback question.** The only one that changes the shape of the step.
2. `_compPairs`' hardcoded 3 degree orb, flagged STILL OWED since step E and deliberately not moved.
   Putting it on `synOrb` is a doctrine call. 7b is a reasonable place to take it or to explicitly
   defer it again, but not a place to take it by accident.
3. Whether the renamed layer tag is `syn` or `synchronic` in the stored bytes. One byte per row across
   two weaves is not nothing, and the dictionary makes it free either way, so this is a legibility
   choice and should be made on purpose.
