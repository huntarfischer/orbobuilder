# Aegis finish — spec

**Control:** replace the `metalChips` (`none/brass`) with a single **finish switch**: `cobalt` (default) / `aegis`. Lives in ♌ Appearance, same slot. `skin.finish`, replacing `skin.metal`. `_migrateSkin`: any legacy `skin.metal` value just maps to `finish: 'cobalt'` (nobody has "aegis" saved yet), and `skin.metal`/`skin.limb`/`skin.decans` all retire for good.

**Front, cobalt:** unchanged from today minus the brass-band code path (no more none/brass toggle on the front — cobalt is just the current stone-and-glow face, permanently).

**Front, aegis:** the whole disc reads as worked bronze, not stone-with-a-brass-trim.
- Sky/plate field (currently indigo radial gradient + stars) swaps to the bronze base gradient (the `MP`-style linear sheen already used for the brass limb, extended across the whole face) — stars either drop out or stay as faint dark flecks against metal, TBD by look.
- Limb band keeps its bevel/polish treatment, same bronze family, no seam between "band" and "face" — one metal object.
- Wheel chrome (spokes, house/degree ticks, numerals, glyph rings) shifts to the aegis palette (bronze-lit golds, dark patina strokes) for contrast — same logic as the brass-limb numeral recolor today, just applied face-wide.
- Aspect lines, planet glyphs, data stay as-is (chart data is sacred, never re-skinned) — only the instrument's *material* changes.

**Back, cobalt:** current layout, "more polished stone" — glossier gradient on the `inset:15px` tabula disc (tighter, brighter specular highlight; less flat), same indigo hue, same rings/plates/labels. A finish upgrade, not a redesign.

**Back, aegis:** the shield grammar from the earlier plan, unchanged in substance:
- 12 plates (`segs`) recolored to hammered bronze with per-plate sheen variation, spoke seams darkened.
- Domed rivet-boss (SVG radialGradient circle) on each of the 12 spoke angles at r49, top spoke (90°) gets the larger accent boss.
- 1–2 concentric groove rings inside the outer edge, dark bronze stroke.
- Central domed boss (r~14–18) seated behind "THE TABULA" legend.
- Glyphs/labels/active-slot gold stay legible — contrast-lifted against bronze where needed, otherwise untouched.

**Zero geometry/text/copy change either mode** — same slots, spokes, legend, "⟲ FRONT" flip, chart data. Pure material swap, both faces, one switch.

---
*Next step: snapshot current `Orbo Astrolabe.dc.html` to `archive/` before implementing, per project versioning convention.*
