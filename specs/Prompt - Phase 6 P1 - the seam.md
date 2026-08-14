# Prompt · Phase 6 · P1 — the seam (the sASC as a real occupant)

Plan of record: `specs/Phase 6 - The Synchronic Prism.md`. Requires P0 (done, v0.889) and P0b (seating)
landed first — this pass seats a NEW kind of chart on the wheels P0b just fixed, and any residual
crowding/angle-collision bug from P0b will look like a P1 bug if seating isn't already solid.

**The one sentence:** the prism becomes a real, seatable chart — every position refracted to
`midpoint(natal, now)`, the horizon becomes the sASC and joins the aspect web as an ordinary occupant —
using the seating mechanism (`The sky` / `No one` / a person / a composite) that already exists, adding
no new insertion point and no new UI switch.

Do NOT build P2's Connectome tables (arc, itinerary, reachable set), the dial/ledger/query pane views,
electional, or synastry in this pass. Those depend on structure this pass does not create. This pass is
the live decode only: one refraction door, one new occupant, seatable.

---

## 0 · Before anything

- Snapshot first, next free letter under 2026-08-06 (or the day's date).
- Version bump per convention.
- Orbo never uses the em-dash.
- Read `specs/Phase 6 - The Synchronic Prism.md` §0–§5, §9, §13.1–13.3 in full before starting — the
  reasoning for what NOT to build is as load-bearing as what to build.

---

## 1 · The refraction door — ONE function, ONE place

Add a single function that refracts a position: `refract(natalLon, skyLon) = midpoint(natalLon, skyLon)`
(reuse `framing.midpoint` — do not reimplement wrap/halving logic; §3 is explicit that this arithmetic
already exists and a table is refused). This is not new geometry — `scanTargets`'s `lonAt` already does
`nat == null ? sky : midpoint(nat, sky)` per §0 of the plan. Locate that existing line and factor the
refraction into one named door both this and the scanner can share, rather than writing a second
implementation.

**This door is the only place refraction happens in the app.** Grep-verify after: exactly one function
computes `midpoint(natal, sky)` for the synchronic layer.

---

## 2 · The sASC — the horizon refracted

`sASC = midpoint(natalASC, risingDegree)`. `risingDegree` at any instant comes from `spine.ascProbe(jd,
lat, lon)` per the spine law (never call `eph.angles()` directly outside `_makeSpine`/the engines — see
CLAUDE.md's TimeSpine law).

Build the prism's position map the same shape as `this.comp` (P0's composite map): flat `{body: lon}`
plus a horizon entry. Naming: reuse `cASC`-style convention or introduce `sASC` as its own key — your
call, but be CONSISTENT with how `this.comp.cASC` already works so the seating/drawing code (P0, P0b)
needs minimal branching to accept this as a new seatable chart alongside composites.

- Every body: `refract(natal.pos[body], sky.pos[body])`.
- The horizon: `refract(natal.asc, ascProbe(jd, lat, lon))`.
- Lots: per the 2026-08-06 ruling (§14.2), **refract live** — `refract(natalLot, liveLot)` where
  `liveLot` is computed from the SKY's own current sect (sky Sun vs. sky ASC), not stored, not tabled.
  Do not build lot storage in this pass; that's explicitly deferred pending the sect ruling.

This position map is recomputed per spine tick like any other live reading — memoize on cursor the same
way `_reading()` already memoizes, do not add a second cache.

---

## 3 · Seating: the prism as a fourth kind of occupant

Per §2.1's ruling, the prism is a chart that gets seated on either wheel via the SAME mechanism that
already seats `The sky` / `No one` / a person / a composite. Find that seating switch (likely near
`_toggleComposite`, the rete-picker, wherever `this.state.composite`/`abComposite`/`rete` are set) and
add the prism as a new option in the same place, producing a position map of the same shape P0b's
generalized track logic already expects.

Concretely, whatever your seating switch looks like, it should now be able to hold: sky, none, person,
composite (existing), OR prism (new) on either the plate or the rete slot. Do not special-case the prism
in the wheel-draw code beyond what a new occupant kind requires — if P0b's generalization was done right,
seating the prism should mostly "just work" by producing a `{body: lon}` map with a horizon entry, same
as a composite's.

**Solo self-aspect must already work for the prism, for free.** P0's fix drew a composite's own web when
seated alone; verify the prism, seated alone, does the same via the identical code path — no new web
logic should be needed here. If it doesn't "just work," that's a sign P0/P0b's generalization missed a
spot, not a reason to add prism-specific web code.

---

## 4 · The wheel declares what it carries

Per §2's optical law, the wheel card must name the prism when seated, using the SAME card mechanism that
already reads `THE PLATE · Composite me · synchronic · you × now`. Add the prism's own label/short/color
the way composites already have `label`, `short`, `color` (see the reading-shape code from P0's grep,
e.g. the object literal with `posMap, ascLon, label, short, color`). Suggested short: `synchronic clock`
or similar — keep it terse, matching the existing pattern's terseness. Do not invent a new card mechanism.

---

## 5 · The frame entry point (§14.1 — already resolved, build the small thing it actually asks for)

The plan's §14.1 resolved that NO new frame stop is needed: the natal sASC IS the natal ASC (at the
anchor, refraction of ASC against itself is a no-op), so `_reading()`'s existing `frame: 'natalAsc'`
already rotates to the composite frame. What this pass DOES need to add: **double-tapping the seated
prism's own horizon (the sASC bead) triggers entry into the `natalAsc` frame**, the same gesture class as
the existing ASC double-tap. Find wherever the ASC double-tap → frame cycle is wired and extend it to
recognize a tap on the sASC bead specifically (when the prism is seated), routing to the same
`natalAsc` frame code — not a new frame implementation.

Do not build a "fourth cycle stop." This is a new gesture ENTRY POINT to an existing frame, exactly as
§14.1 specifies.

---

## 6 · Two house readings, always qualified (§13.1)

Per the ruling, wherever the app currently shows "house" for a placement in a view that might show the
prism's readings, the label must be qualified — "natal 10th" vs. "synchronic 1st" — never a bare number
that could be misread as replacing the natal one. This pass's scope for this requirement is narrow:
**only touch a display site if it is already reachable with the prism seated** (e.g. a composite
single-body sheet analog, if one becomes reachable via this pass's seating). Do not go hunting through
the whole app rewriting house labels speculatively — that is P4/P5's job once the pane views exist. If
no house-displaying UI is actually reachable with the prism seated after this pass, note that in the
write-up and move on.

---

## 7 · What must NOT move

- P0's `platePartnered` logic, P0b's track/frame/geometry law — untouched, only extended to accept a new
  occupant kind.
- `framing.js`, `loom.js`, `ring.js`, any `.browser.js` — no edits. This pass adds a decode, not geometry.
- `fertKey`, `connectome.CODEC`, spine seed — must not move. Nothing here is a Connectome member yet
  (that's P2); this pass is pure live arithmetic.
- Any stored lot structure — refused this pass, per §2 above.
- The daily flip's kind/window/export (`framing.flipEvents`) — untouched, per §13.3's scoping note.
- Electional, the ledger, the dial-as-pane-widget (§14.1 already redirected the dial into the frame
  system — there is no separate dial to build).

---

## 8 · Acceptance, measured

1. **Grep check:** exactly one function computes `midpoint(natal, sky)` for this layer.
2. Seat the prism solo (plate = prism, rete = none): it draws its own cross-body web, same code path as
   P0's composite solo case, verified by the same kind of before/after state-set test P0 used.
3. Seat the prism against the sky, against a natal chart, against another prism: each produces a
   sensible two-track drawing via P0b's generalized seating, no special-casing needed beyond producing
   the position map.
4. The wheel card names the prism when seated (own label, distinct from `Composite me`/`The sky`).
5. Double-tapping the sASC bead (prism seated) enters the `natalAsc` frame; the sASC sits at the horizon
   point, confined to swinging ±90° around it as the cursor advances — visually confirms §14.1's "the
   dial is free" claim. Screenshot both the anchor moment and a moment mid-arc.
6. Lots (if surfaced by any reachable view) show live-refracted values, not stored ones.
7. STEP 0 of `tests/rewire-parity.test.html` passes. Full suite green, no zero-row suite.

---

## 9 · Traps

- Never build an `old_string` from truncated grep output.
- Verify by loading/parsing, never by reading a diff.
- `spine.ascProbe` takes `(jd, lat, lon)` — the prism's horizon is PLACE-DEPENDENT (the native's natal
  place, per doctrine, unless a different place is explicitly being tested). Do not accidentally feed it
  a different native's coordinates when seating two prisms against each other (§8 of the plan, synastry)
  — that's P7, not this pass, but don't let this pass's plumbing quietly break that future case either.
- Resist adding a settings toggle, mode flag, or global "prism enabled" boolean anywhere. There is no
  mode. There is only a chart that can be seated. If you find yourself writing `if (prismMode)`
  anywhere outside "what is seated on this wheel slot," stop and re-read §2.1.
- Resist building the ledger/dial/query pane views "since you're in there." They are P4–P6 and depend on
  P2's tables.

---

## 10 · Owed on completion

- `CLAUDE.md`: a short note — the prism is a seatable chart producing a `{body: lon}` map via one
  refraction door; no mode flag exists; the sASC's frame is entered by double-tapping it, not by a new
  cycle stop.
- `specs/Phase 6 - The Synchronic Prism.md` §10: mark P1 done, with what was measured, and explicitly
  note whether cASC/sASC's aspect web read well at Ascendant speed (owed from P0's write-up) — now
  actually observable since the sASC truly moves at Ascendant speed, unlike a static composite's cASC.
