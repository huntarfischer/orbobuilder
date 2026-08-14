# Aspect Line Depth — Build Spec

Agreed 2026-07-20. Scope: aspect lines drawn on the astrolabe face (sky↔sky, sky↔natal, held-hand, composite/B-plate thread families). Goal: give lines a sense of depth against the starfield center (a porthole into night sky, not a metal plate) via gradient stroke, z-ordering by orb tightness, and applying/separating as the driving concept — with shading as the visible expression of z-order (threads cast shadow on what's beneath them).

## 1. Applying/separating (foundation, computed once, shared)

- New helper alongside `_orbFor`/`_aspects`: for any pair (a, b) with an angle hit, compute signed rate of orb change from each body's true daily motion (handles retrograde/stations correctly — no assumed direct-motion order).
- Natal↔natal pairs are exempt (both frozen at birth) — that family keeps its current flat, non-graded treatment untouched.
- Output per line: `{ applying: bool, tt: tightness 0–1 }` — reused by every family below instead of recomputed per site.

## 2. Gradient stroke

- Replace flat `strokeStyle` with a `createLinearGradient` between the two endpoints.
- Applying: gradient runs trailing → leading body, brightening toward the leading (approached) end.
- Separating: gradient runs the reverse and diffuses (fades toward both ends rather than resolving on one).
- Direction/behavior is truth-driven, not a style choice — always on, no toggle.

## 3. Z-ordering

- Current paint order is fixed by category (sky-web → natal-web → ambient threads → held threads → composite). Change to: within each applying-eligible family, sort draws by `tt` and applying-first, so tight/applying lines always paint last (on top) regardless of category.
- Always on, no toggle — this is a legibility fix, not a look.

## 4. Shading (shadow-casting, the visible expression of z-order)

- Two-pass draw per thread, executed in the sorted back-to-front order from §3:
  - **Pass A (shadow):** soft blurred dark stroke, slightly offset, using the same light-from-above convention as the instrument's existing debossed glyphs (`shadowOffsetY` negative equivalent). Cast onto whatever's currently painted beneath — starfield void and lower threads alike.
  - **Pass B (glow):** the thread's own gradient stroke from §2, on top.
- Net effect: tight/applying threads visibly float above and dim the stars/looser threads beneath; separating threads sink in the stack and pick up shadow from what's above — reinforcing fade with recession.
- Always on, no toggle.

## Augmentable (Appearance panel, alongside existing rim-metal / decan-face style pickers)

- Glow/shadow **intensity** (subtle ↔ pronounced) — one slider or 2–3 preset steps.
- Applying/separating **color temperature** (e.g. warm/cool or single-hue-brightness) — a material/identity choice, same slot as brass vs. silver.
- Whether the ambient/held-thread families (currently flat lavender-dashed) adopt this same gradient+shadow language, or stay in their simpler current style — default: unify them; can expose as a toggle if wanted later.

## Scope guard

Natal↔natal web and the A+B minted composite (currently no lines) are untouched by this pass — no applying/separating concept applies to frozen charts.

## Reference: current state (pre-this-spec)

- Color is keyed to aspect angle only (`this.ASPECTS`), never varies with depth/strength.
- 6 line families, all flat straight chords on one ring radius, differing only in alpha/width driven by orb tightness:
  1. Sky↔sky web
  2. Natal↔natal web
  3. Ambient sky→natal threads (dashed, flat lavender `#b9aee0`, ignores aspect color)
  4. Held-hand→natal threads (dashed, same flat lavender)
  5. Composite/B-plate threads (dashed, tinted per entity kind)
  6. A+B minted composite (no lines, stamped marks only)
- No shadow, no gradient, no arc/bow, no z-order beyond fixed category paint sequence.
