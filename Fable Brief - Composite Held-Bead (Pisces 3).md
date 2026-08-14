# Fable brief — ♓ step 3: the held composite bead

*You have ~12% of your budget. Spend all of it here. This is the debut of the **gilt** material and the composite focus states; ♓ 4/5/6 all inherit whatever you set. Everything below the "What's already wired" line is done and tested — you should not need to build plumbing, only decide how the held bead **looks and feels**.*

Base file: `Orbo Astrolabe.dc.html` (snapshot of this exact runway kept as `Orbo Astrolabe v4.dc.html` — revert target if a pass goes sideways).

---

## The one thing to get right
When the user grabs a composite bead and scrubs, it should feel like **pouring molten light along a channel cut in the plate** — the third material (sky = light, natal = engraved stone, composite = **gilt**). A flip (the bead hitting a channel end) is an ingress-grade event and should *land* — a pulse + the big haptic. One channel lit at a time, ever.

## The three focus states (the law everything inherits)
- **Resting** — channels invisible; beads faint gilt points among the engraving. The plate whispers. *(current behavior)*
- **Held** — the held bead's channel lights **end-to-end**, its two flip stops glow, the sky web dims (same rule as a held transit hand today). Only ever one channel lit.
- **Plate view** — deferred, not this pass.

## Design intent (from the design map, already decided — don't re-litigate)
- **Gilt recipe** = the brass-limb bevel, shrunk: directional sheen + radial polish + dark stamped cut with a light-leak edge. `_giltBead(ctx,x,y,r,alpha,violet)` is the seed — extend it, don't replace it.
- **Channel** = the 180° arc, natal degree at its *center*, ends at natal ±90 (`this.compArc[key]`). Light it as a cut slot with two engraved terminal stops.
- **Flip** = bead drains out one stop and wells up at the other — never slides through the natal notch. Pulse at both ends, big haptic. Fires on `this.compFlip[key]` going true.
- **Zodiac-true** — channels pin to degrees and ride with the zodiac in horizon lock (same anchoring as the natal plate; don't screen-fix).

---

## What's already wired (verified — consume, don't rebuild)

**Engine data layer** (recomputed every jd in `_updateComposite`):
- `this.comp[key]` — bead longitude. `key` = body name (`'Sun'`…`'Pluto'`) or `'cASC'`.
- `this.compArc[key]` — `{center, start, end}`, the 180° channel centered on the natal mark.
- `this.compFlip[key]` — boolean, **true only on the tick the bead flips** (>150° leap). This is your pulse/haptic trigger.

**Hit-map + grab** (in `_down` / `_move`):
- Every frame `_draw` fills `this._beadScreen[key] = [x,y]` (screen coords of each bead).
- Grabbing a bead sets `this.held = 'bead:<key>'`. Read it anywhere with **`this._heldBeadKey()`** → returns `<key>` or `null`.
- Scrub runs at the correct **half-gear**: the bead moves at ½ the transit's rate, verified — a drag moves jd exactly 2× the transit-hand equivalent. (`_move` uses `2 * PERIODS[body]` for beads. Snap-magnetism is deliberately skipped for beads — that's ♓ 5, not yours unless you want it.)

**The draw hook** (in `_draw`, the `if (this.state.composite && this.comp && natT.length)` block):
- `const heldB = this._heldBeadKey();` and per-bead `const isHeld = heldB === beadKey;` are already computed.
- There's a **placeholder** brighten when `isHeld` (bigger radius, brighter channel). Replace that placeholder with the real held treatment — channel ignition end-to-end, glowing flip stops, and a pulse driven by `this.compFlip[beadKey]`. `_pulseFx(kind)` + `this._pulse` already exist for the transit-hand pulse; mirror or extend for the flip.

## Known tension for you to decide (feel call, not a bug)
Beads sit at `rN = rBody − 17`, **17px inside** the transit ring, and transit-body hit-testing (`this._screen`, 30px radius) runs *first* — so a bead directly under a transit glyph gets shadowed and can't be grabbed. Your call: shrink the transit radius when composite is engaged, give beads priority in the inner band, add a dedicated promote gesture, or accept it. This is the kind of interaction-priority decision that's yours.

## Explicitly NOT this pass
cAs rim arc (♓ 4 — reassigned to Opus/main), bead↔bead threads + composite lenses + bead snap (♓ 5), person/B plates (♓ 6). Leave hooks, don't build them.

## How to verify
Engage: back → ♓ Composite Framing → toggle on (needs a natal on ♈). Front: beads appear on the plate. Grab one and scrub; watch the channel and flip stops. Test a flip by scrubbing a fast bead (Moon ≈ monthly, cASC ≈ daily) until it hits a channel end.
