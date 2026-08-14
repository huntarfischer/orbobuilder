# Prompt · Phase 6 · P0b-repair — two tracks, two treatments, one path each

Plan of record: `specs/Phase 6 - The Synchronic Prism.md`. P0b (v0.890) put the rete's occupant on the
rete's track correctly and that part stays. What it did not do is give that occupant the instrument's
own body treatment, because the treatment was never a function of an occupant: it was a loop hardwired
to the live sky.

**The one sentence:** there are exactly two tracks, each holds exactly one chart, everything on the
plate's track is drawn ONE way and everything on the rete's track is drawn THE OTHER way, by one
function each, and both are fully functional charts.

This is a SIMPLIFICATION pass. It should delete more code than it adds. If it does not, stop and
re-read this prompt.

---

## 0 · Before anything

- Snapshot first: `archive/Orbo Astrolabe 2026-08-06d.dc.html` (or the next free letter that day).
- Version → v0.891.
- Orbo never uses the em-dash.

---

## 1 · THE LAW (this is the whole prompt)

**Material follows the WHEEL, not the occupant.**

- **The plate is ENGRAVED.** Incised, matte, beneath. Whatever sits there.
- **The rete is LIT.** Element-coloured, glowing, riding above. Whatever sits there: the sky, a person,
  an event, a composite, a prism.

This is a distinction in KIND, not in quality. Both charts get the instrument's full treatment. Neither
is a demotion of the other.

**This RULES §12.7's open ruling 3 in favour of the wheel and STRIKES §12.3 of the plan** (which said
"the live sky is LIGHT, a seated chart is STONE"). That was wrong: it made the distinction one of
quality, so one chart always looked finished and the other looked like a debug overlay. Update the spec
accordingly (§6 below).

---

## 2 · What exists today, and what it becomes

### The defect

Line ~9919: `for (const o of (skyOn ? drawOrder : [])) {`

That ternary reserves the entire lit treatment for the sky. It is not merely a gate: the loop takes its
positions from `this.pos` (the sky's map) rather than from an occupant. When anything else is seated, the
loop runs zero times and a **separate hand-rolled routine** (~lines 9856–9887) draws the seated chart in
flat one-colour 11px glyphs with no glow, no sizing, no de-collision and no hit map.

### The fix, in three moves

**MOVE 1 · Extract the lit loop into one function that takes an occupant.**

Turn the existing sky-body loop into a single function called once for whatever is on the rete's track.
It needs, handed in: the position map (`{body: lon}`), the chart's own ASC/angles, and the radius
(`rBody`). Everything else it already does stays EXACTLY as it is, unchanged:

- `_elemOf(lon)` per body
- glow via `shadowBlur` × `A.glow`
- size by period, `23 − 1.2·log10(PERIODS[name])`
- the backing disc
- conjunction clustering within 9° with alternating `lvl`
- `_moonFace` for the Moon, using THAT CHART'S OWN Sun (so a seated chart's Moon shows that chart's own
  phase, which is correct and is a genuine gain)
- the `O3` angle badge treatment for MC/IC/Vx/DS
- `drawNotch()`
- writing `this._screen[name]` for every body

Do not redesign any of that. It is already right. It is only in the wrong shape.

**MOVE 2 · Delete the hand-rolled seated-chart routine.**

The block at ~9856–9887 (the `if (rc) { ... }` engraving pass that draws B's bodies in flat `ink`) goes
away entirely, replaced by a call to MOVE 1's function. Keep the recessed band/track furniture around it
if it reads well on a lit track; drop it if it fights the glow. Judgement call, state which you chose.

**KEEP the B-thread pass** (the `bItems` loop above it) exactly as is. §12.5's geometry ruling is
working correctly and is not in scope.

**MOVE 3 · One occupant resolution point.**

There should be exactly ONE place that answers "what is on the rete's track, and what is its position
map." It resolves to one of:

- the sky (`this.pos` + `this.asc`), or
- a seated chart (`_reteChart(rete).pos` + `.asc`), or
- nothing (`rete === 'off'` → the track is empty)

and hands the result to MOVE 1's function. No `skyOn` branch anywhere downstream of that point.

Do the same on the plate's side if it is not already single-pathed: the plate's engraved pass should
take `plateT`-style targets from ONE resolution point (natal, composite, abComposite) and draw them one
way. P0 already built `plateT` this way, so this may be a no-op. Confirm rather than assume.

---

## 3 · Both charts must be FULLY FUNCTIONAL

This is the "all the other stuff it needs to" requirement, and it is the part P0b silently dropped.
Whatever is seated on either track must support everything a chart supports:

- **Grabbable/holdable.** `this._screen[name]` must be populated for every body on the lit track. Line
  ~9443's `if (!skyOn) this._screen = {};` ("no sky glyphs — nothing up there to grab") is now false and
  must go: there ARE glyphs up there, they are just not the sky's. Same for `this._natalScreen` /
  `this._beadScreen` on the plate's side if those are gated on anything.
- **Element colour always.** The sky's lit path falls back to pale white while `this.held || this.playing`
  (`atRest`). A SEATED chart never moves, so it is permanently at rest and must always carry element
  colour. Do not let a scrub wash out a frozen chart.
- **Its angles.** Both tracks draw their own As/MC/Ds/IC on their own track, per P0b's law. One horizon
  LINE and one house grid, from the plate only (unchanged, §12.4).
- **De-collision.** The clustering the sky loop already does now applies to seated charts too, which is
  most of the crowding in the 2026-08-06 screenshots.
- **Tap/hold/readout.** Whatever the sky's bodies feed (the readout strip, the single-body sheet, the
  hold gesture), a seated chart's bodies feed identically. Grep every read site of `this._screen` and
  confirm none of them assume the sky.

---

## 4 · What must NOT move

- P0's `platePartnered` gate and plate-web logic.
- P0b's track assignment (`rBody` for the rete's occupant, `rN` for the plate's) and §12.4's single
  frame from the plate.
- The B-thread pass and §12.5's geometry-not-line-style ruling.
- `_compPairs`, `synOrb`, any orb, any `.browser.js`, any codec, `fertKey`, the spine seed.
- The plate's engraved treatment. It is correct in both screenshots and is the "other way" of the law.
- Web DENSITY. Image 1's thread count is a separate problem with a separate lever (♍ Orb) and is not in
  this pass.

---

## 5 · Acceptance, measured

1. **`skyOn` no longer selects a treatment.** Grep it: any surviving use must be about whether the sky
   is the occupant, never about how bodies are drawn.
2. **One lit function, one engraved function.** Two draw paths total for chart bodies. The hand-rolled
   seated-chart glyph routine is gone from the file.
3. **The screenshot case:** plate = `Natal me`, rete = a person (`cb`). The rete's chart draws
   element-coloured, glowing, sized by period, de-collided, with its own Moon phase, at `rBody`. It
   looks like image 2's outer ring, not image 1's.
4. **The sky case is unchanged.** Plate = natal, rete = sky: pixel-identical to v0.890.
5. **Both charts are grabbable.** Hold a body on the plate's track and a body on the rete's track; both
   respond, both drive the readout.
6. **Scrub with a seated chart:** the frozen chart keeps its element colours; it does not wash to white.
7. **Line count goes DOWN.** Report the before/after. A simplification pass that grows the file has
   misunderstood the ask.
8. STEP 0 of `tests/rewire-parity.test.html` passes. Full suite green, no zero-row suite.

---

## 6 · Owed on completion

- `specs/Phase 6 - The Synchronic Prism.md`: **strike §12.3's light-vs-stone framing**, replace with the
  law in §1 above. **Mark §12.7 ruling 3 RULED: material follows the wheel.** Note that ruling 2
  (element colour on a seated chart) is resolved as a consequence, since `_elemOf` rides the lit track
  for free.
- `CLAUDE.md`: extend the seating law already recorded there with one sentence — material follows the
  WHEEL, not the occupant: the plate is engraved and the rete is lit, whatever is seated on each, and
  both tracks are fully functional charts (grabbable, de-collided, element-coloured).
- State in the write-up whether the rete's recessed band furniture was kept or dropped, and the
  before/after line count.

---

## 7 · Traps

- Never build an `old_string` from truncated grep output.
- Verify by loading and running the suite, never by reading a diff.
- The lit loop currently closes over `this.pos`, `this.asc`, `this.held`, `this.playing`, `act` and `A`.
  Extracting it means being deliberate about which of those become parameters (the positions, the ASC,
  the radius) and which stay ambient (`A`, `held`). Getting `held` wrong will make a seated chart
  un-grabbable or make holding one body highlight another.
- `PERIODS` and `GLYPH` are keyed by body name and are chart-agnostic. `_elemOf` takes a longitude. None
  of them need changing; if you find yourself adding a parameter to them, you have gone off-path.
- Do not add a third treatment, a third track, or an "is this the sky" flag inside the lit function. If
  the lit function needs to know whose chart it is drawing, the law has been broken.
