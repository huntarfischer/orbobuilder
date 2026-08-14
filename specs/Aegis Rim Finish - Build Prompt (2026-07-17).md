# Build prompt — the Aegis finish for the Tabula (♌ Appearance)

**Reference:** `uploads/aegis-shield-ancient-shield-gods-used-battle-...-321878138.webp`
(Athena's aegis as an aged-bronze war-shield: a rim of hammered segment-plates, evenly
spaced domed rivet-bosses, concentric grooves, a raised central boss, verdigris-and-brass
patina.)

**Current tabula:** `uploads/Screenshot 2026-07-17 at 1.58.42 PM.png` — the back face.
Twelve zodiac-glyph slots on a dark-indigo stone disk, divided by radial spokes, arced
section labels (NATAL, HERE·NOW, …) on an inner ring, a gold "THE TABULA" legend at the
hub, "⟲ FRONT" below. **This structure is already a segmented round shield** — the aegis
maps onto it almost 1:1.

## What to build
A **bronze aegis finish for the tabula (the back)**, chosen in ♌ Appearance. It re-skins
the existing back rim; it adds no new geometry, glyphs, spokes, or slots. A finish, not a
reading — the maker's choice of how the tabula is worked.

## ⚠ The back is DOM + SVG, not canvas
The front wheel is `<canvas>` (template ~line 131) and its brass/silver limb is painted in
the "limb as material" block (~5079); **that is NOT this surface.** The tabula is the
`inset:15px` radial-gradient `<div>` at template ~line 133, containing an SVG whose
twelve plates are `<path d="{{ sg.d }}">` (~line 139). So everything below is SVG/DOM,
inline-styled — **do not** reuse `_giltBead` (canvas) or the `MP` palette; bosses are SVG
`<circle>`s with `<radialGradient>` fills.

## Where it lands (real hooks)
- **Control:** add a third chip to `metalChips` (`renderVals`, ~line 2651) — `none · brass ·
  aegis` — and a `metalNote` line (~2661): *"the tabula worked as the aegis — aged bronze,
  plated and bossed."* State/persistence is free: `skin.metal` already persists and the ♌
  dirty check (`case 'skin':`, ~1780) already fires on any non-`none` metal. `_migrateSkin`
  passes a fresh `'aegis'` through untouched — leave it alone.
- **Plate fills:** the twelve segments get their color in `segs` (~line 1810: `fill`, `col`).
  Gate those on `skin.metal === 'aegis'` to swap the near-transparent white plates for a
  bronze gradient set (active slot stays the gold `rgba(232,171,65,…)`). Glyph/label `col`
  may need lifting for contrast against bronze — keep them legible.
- **Geometry you build against (don't reinvent):** `_segPt(a,r)` (viewBox 0–100, center 50,
  Aries at 9 o'clock, CCW), `_segD(k)` plates (outer **r49**, inner **r38.5**, 30° each),
  glyphs at r43.75, arced labels r34.4/36.6, dots at r40.2. Spokes (plate boundaries) sit
  at angles `180 + k*30`, k=0..11.

## The aegis grammar (on the tabula rim only, all SVG)
1. **Rivet-bosses** — a domed stud on each of the **twelve spokes** at the outer edge
   (~r49, angles `180 + k*30`): SVG `<circle>` with a `<radialGradient>` (highlight offset
   up-left, bronze mid, dark rim) so it reads as a dome, not a dot. One larger accent boss
   at the top spoke (90°). Twelve bosses = the twelve sign boundaries, so the ornament means
   something. They sit *between* glyphs — must not collide with the glyphs at r43.75.
2. **Hammered plates** — the twelve `segs` filled bronze with a faint per-plate sheen; keep
   the existing spoke strokes as the plate seams (darken them for the aegis).
3. **Concentric grooves** — one or two SVG `<circle>` register rings (stroke, low-alpha dark)
   just inside the outer edge, echoing the ref's inner rings.
4. **Central boss** — a bronze domed disk (SVG radialGradient) seated behind the "THE TABULA"
   legend (~line 192, within r<38.5) — the shield's raised centre. The gold legend text rides
   on top of it.
5. **Patina** — break the sheen with subtle gradient mottling so it reads *aged*; the front's
   brass limb stays the clean finish.

## Palette (against the indigo stone field)
Aged bronze, not polished brass — warm golds dirtied with a green cast in the lows, e.g.
plate `#6e5a30`→`#3d3418`, boss highlight `240,224,170`, boss rim `20,16,4`, groove stroke
`rgba(20,16,4,0.4)`. Tune against the ref. Active slot keeps gold; glyphs/labels stay in the
lavender/gold family, contrast-lifted as needed.

## Constraints (the law)
- **Tabula only.** No new slots/spokes/glyphs; no radiating spikes across the hub (the ref's
  central star lands where the legend lives — take the *boss*, not the star). Front wheel
  geometry untouched.
- It's the maker's side, so the aegis is chosen on ♌ and dresses the back. **Open decision
  for the user:** should picking aegis *also* retint the front limb bronze (one coherent
  instrument), or dress the tabula alone? Recommend also theming the front limb for
  coherence — confirm before wiring.
- Inline-styled SVG/DOM like the rest of the back; no new CSS classes.

## Acceptance
- ♌ Appearance shows three chips: none · brass · aegis. Aegis re-skins the back: twelve
  bronze plates, a domed rivet-boss on every spoke (accent at top), grooved rings, a raised
  central boss under "THE TABULA"; glyphs and labels stay legible.
- Reset returns to `none`; the choice survives reload; no console errors; slot taps and the
  ⟲ FRONT flip still work.
