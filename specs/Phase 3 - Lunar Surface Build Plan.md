# Phase 3 — The Lunar Surface · build plan

Written 2026-07-28, against `Orbo Astrolabe.dc.html` at v0.855. Reads
`specs/Orbo Plan 2026-07-26.md` § Phase 3 as the brief; this is the how, the order, and the
acceptance tests. **A (moonglass) and its snapshot shipped 2026-07-27.** Remaining: B ladder ·
C rimmed box + tabula spread · D occulter · E cohesion sweep, plus the four shared components —
of which the **rune button is now unblocked** (rune reference supplied 2026-07-28).

---

## 0 · The rune, since it arrived first

The supplied glyph is **two discs, one occulting the other** — a full circle with a second circle
riding up from behind it, the crescent of the far disc showing over the near one's shoulder. That
is not a generic pin icon. It is *the pane rising in front of the chart*, which is exactly the
motion the thing does, and it is the same figure as the occulter in D. One glyph, one meaning,
across the whole app: **something has come up in front of the sky.**

So the rune is not decoration on a button — it is the pin-to-pane verb's portrait.

**Decisions I'd make:**

1. **Vector, not the PNG.** The upload is 1024×1024 / 1.4 MB with transparency; as a raster it
   can't tint (silver unpinned → gold hem pinned), can't animate the inner disc's rise, and would
   have to be declared as a hidden `<img>` to survive the standalone bundler (the export law:
   CSS `url()` and JS paths are invisible to it). The figure is **two circles** — I can draw it
   as two `<circle>` strokes with a clip, tint it by `stroke`, and animate the far disc's `cy`.
   The upload stays in `uploads/` as the reference of record.
2. **44px round hit target, 22px glyph.** Round, glyph-forward, no label — the general note in the
   plan file is *more circles, more glyphs, fewer rectangular buttons.*
3. **Three states, by finish not by value** (the plate/rete rule, reused): *unpinned* — silver
   stroke, far disc down behind the near one, no fill; *pinned* — far disc risen, gold hem on the
   rising limb only, faint dark fill so it reads as occulting; *unavailable* — same geometry at
   0.35, no tap. The pin action animates the far disc from down → risen on the presentation clock
   (one `_spr`, no CSS transition), so the button performs the pane's own rise.
4. **Where it lands.** It retires five text chips that all say the same sentence in different
   widths: `+ Pin to Moon pane` at ZR (renderVals 3220), rising lord (3230), election (3357),
   almanac (3580), and the ♒ `ptPin` glyph (template 911). Those five sites already share
   `_togglePaneLens(id)` / `paneLenses`, so the swap is one component × five mounts — `[S]` work
   once the component is approved.
5. **What it is NOT.** ♒ pin-to-memory keeps the ♒ glyph. Two pins in one app need two glyphs,
   and memory is a *different destination* (moon → memory). The rune means the pane.

**Open for you:** is this the first member of a rune *family* (one glyph per moon view, so the pane
header can wear its own rune) or the single pin-to-pane rune only? I'd build one and hold — a family
needs the tabula spread's headers to exist first, i.e. after C.

---

## 1 · Why B before C, and C before D

The plan's order is right and worth restating as a dependency, not a preference:

- **C cannot be built on today's geometry.** The rimmed box has to be positioned against a known
  pane rise. Today "how high is the pane" is derived independently in five places, so a content
  rectangle seated inside the dome would be correct at one stop and clipped at the others — which
  is precisely the v0.85 defect (bead ring sliced, `NATAL`/`THE SKY` half-clipped).
- **D is C's proof.** The occulter is only real once a *non-moon* surface can rise; a surface with
  no content rectangle has nothing to put in it.
- **E is last by definition** — it is the sweep that makes the four agree.

---

## 2 · B — the stop ladder (`this.pane`)

**The situation, measured.** "How high is the pane" currently lives in: `state.sheet` and
`state.eclipse`; `_raisedLens` (2675) and `_eGeo` (2676), both recomputed in renderVals and
stashed onto `this`; `_eReadLen` (2678); the three constants `_PANE_MIN` / `_PANE_FACTS` /
`_PANE_FLIPPED`; `_eclipseTranslate()` (5800) plus its `_eYCache` memo (5060) and the resize
invalidation (4174); `_paneTick`'s target ladder (5014–5018); `_shadeTick` (5037); and the three
drag handlers (5807–5841), which re-derive `base`, `avail` and `eY` for themselves. `flipped`
enters as a fourth independent input. Seven owners of one number.

**The object.** `this.pane`, built by `_makePane()`, sibling to `this.spine`, **never on it** — it
is presentation state and the presentation-clock law puts it here. Shape:

```
pane = {
  stops: { gone, peek, facts, eclipse },   // px, device-relative via _box()
  target,                                  // which stop the ladder resolves to
  y, f,                                    // live rise (spring x) + per-segment 0..1 factor
  rise(name), rest(),                      // the one door in
  at(name), available(name),               // declared by CONTENT, not by caller
  drag: { down, move, up }                 // rubber band lives here
}
```

**Five rules for the migration:**

1. **Stops are computed from `_box()`**, not from a 740px fallback and not from an `offsetParent`
   walk. `_eclipseTranslate()` collapses into `stops.eclipse`; `_eYCache` collapses into the
   object's own memo, invalidated on the same `_size()` door.
2. **Availability is declared by content.** Each sheet/lens declares `needs: 'eclipse' | 'facts'`;
   `pane.available('eclipse')` answers from that. This retires `_eReadLen > 0 || _raisedLens`
   (5813) and the `_raisedLens` special-case in the release branch (5839).
3. **`flipped` is not an input, it is a reason.** It resolves the ladder to `gone`, alongside
   "no sheet". One resolver, `pane.resolve()`, is the only place the four old booleans meet.
4. **Read-only downstream.** `_shadeTick`, `_draw`'s `_eclipse`, the veil/corona/rim/limb refs and
   every drag handler read `pane.y` / `pane.f` and never derive a rise. The RAF stays the sole
   writer of the transforms and opacities the springs own.
5. **Behaviour-identical, provably.** This is a refactor, not a redesign.

**Acceptance (all must be indistinguishable from v0.855):** peek → facts tap; facts → eclipse drag;
the flick-vs-nudge release velocity; `>150px` dismiss; the zr/election/rising/almanac lenses opening
straight to raised and *staying* raised; the almanac's 0.30 veil vs. 0.16 elsewhere; flip-while-raised;
a device rotate mid-drag (the stop re-measures, the drag doesn't jump). I'd capture the five rise
states as screenshots before touching it and diff after.

**Risk:** the drag's rubber band is the one place with real feel in it. Move it last, on its own,
after the ladder is otherwise live.

---

## 3 · C — the rimmed box + tabula spread

Two things, and I want to separate them because one is a bug and one is doctrine.

**C1 · The content rectangle (a geometry fix — do it with B).** Headers, subheaders and lists live
in a straight-sided panel seated inside the dome. The dome silhouette stays; the panel is inset far
enough that at every stop the bead ring is whole and `NATAL` / `THE SKY` are not clipped. The panel
**is** the scrim from A — a component with the one glass recipe, not another gradient. Restore the
ledger's `BODY / HSE / DISPOSITOR` column headers that v0.82 had. No `backdrop-filter` unless a
measured contrast floor forces it, and then on the ledger column only.

**C2 · The tabula spread (doctrine — needs Phase 2's answer).** *Items along one edge · description
field beside them · pin at the bottom*, built once on ♐ and applied to ♍ ♎ ♏ ♋ ♑ ♒. Its headers and
subheaders carry a **depth slot as a first-class prop** — L1/L2/L3 with the lineage label. That
contract is Phase 2's (`_depth()` / `_atDepth`), which is not built.

**My recommendation:** build C1 now, and build C2's *layout* now with the depth slot as an explicit,
empty prop hole (`depth={null}` renders nothing) — so the spread lands while the pane is open on the
bench, and Phase 2 fills the hole rather than rebuilding the spread. What I would *not* do is invent
a depth contract here to unblock myself; two depth contracts is worse than none.

The pin at the bottom of the spread is the rune.

**Risks to settle before I start (from the plan file, still open):** the moon's darkness value against
the brightest plate state; the contrast floor for ledger rows — it sizes the *panel*, not the pane's
alpha; and whether the arc-riding labels keep their curve with an inset or move into the panel. I'd
answer the third one with the instrument: labels that ride the dome's arc are moon-surface labels and
keep the curve; anything in the rectangle is set straight. Mixed is honest here — the arc is the moon's
limb, the rectangle is the page laid on it.

---

## 4 · D — the occulter

Split the concept in two:

- **The eclipse** — a state of the *instrument*. One scalar; light retreats, corona blooms, gold
  first-contact flares, `_eclipse` feeds `_draw`. Belongs to nobody in particular.
- **The occulter** — whatever body is doing the eclipsing. Registers, and inherits the rise spring,
  limb light, corona, first contact and dismiss gesture for free.

`pane.occulter = { id, needs, render }`, one at a time, default the lunar pane. **Prove it by moving
the cold open onto it** — a non-moon surface, already staged (Phase 0b's `--instr-op` handoff), and
the one place where "the instrument's light arrives as the occulter withdraws" is the actual
choreography rather than a demo.

Two hard constraints:

- **Fused layer.** Per instrument-survives-everything: occulter fails → `_eclipse` sits at 0 and the
  plate keeps drawing. `_fuse('occulter', …)` in the loop.
- **Motion contract only.** The maker's side may ride the eclipse spring; it must not inherit silver
  or the moonlight depth ladder. Brass stays brass. I'd enforce it in the shape of the registration:
  the occulter declares `surface: 'moon' | 'brass'`, and the silver palette and depth ladder are
  keyed off `surface === 'moon'`, not off "is rising".

---

## 5 · E — the cohesion sweep

Inventory before rewriting: the pane body, the sub-arc pills, the "how to play" tab (template 1102),
the mark/calendar sheets (964, 978 — each with its own `rgba(8,5,20,0.7)` + `blur(4px)` +
`radial-gradient(closest-side, #171040, #0b0722)`), the ♒ pin strip (897), and the `sheetTab` (1016).
Six inventions of one material.

- **One glass recipe**, derived from A's ramp — the same stops, one alpha scalar per surface.
- **One limb-light source**, so pane edge, chip borders and rim agree where the light comes from.
  Today the limb is a static literal in the template lit by `_shadeTick`; the chips have their own
  borders. One direction constant, consumed by all three.
- Inline-styles-only stands: this is a shared *recipe* (a function returning the same literal), not a
  stylesheet.

---

## 6 · Order of work

| # | Item | Who | Notes |
|---|---|---|---|
| 1 | Rune button, one component, one mount (ZR) | `[O]` | approve the glyph in place before the other four |
| 2 | Apply the rune to the remaining 4 pin sites + retire the text chips | `[S]` | one rule, five sites |
| 3 | `this.pane` ladder, behaviour-identical | `[O]` design, `[S]` sweep | rubber band moved last |
| 4 | C1 rimmed content box; ledger column headers back | `[O]` | seated against the ladder's stops |
| 5 | C2 tabula spread on ♐, depth slot empty | `[O]` | applied to ♍ ♎ ♏ ♋ ♑ ♒ by `[S]` after review |
| 6 | Occulter API; cold open proves it | `[O]` | fused layer, `surface` flag |
| 7 | Cohesion sweep | `[S→O]` | inventory above |
| 8 | Arc slider (the fourth shared component) | `[O]` | can slot anywhere after 3; ♑ is its first customer |

Snapshot to `archive/Orbo Astrolabe 2026-07-28c.dc.html` before step 3 — the ladder is the risky one.

## 7 · Questions I need answered to start

1. **Rune scope** — single pin-to-pane rune, or the first of a family? (Affects step 1 only.)
2. **C2 timing** — build the spread now with an empty depth slot (my recommendation), or wait for
   Phase 2 and keep the pane on C1 for a while?
3. **Contrast floor** — do you want to judge the ledger-row contrast on device before I size the
   panel, or should I pick a floor and show you the result?
4. **The cold open as occulter proof** — agreed, or would you rather the maker's side be the proof
   (riskier: it is the one that tests the brass-stays-brass constraint)?
