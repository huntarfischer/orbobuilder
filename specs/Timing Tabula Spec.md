# Timing Tabula — Spec

## 1. Entry point (♏ Timing tabula)
- Remove the mid-column start; ZR/Electional launch buttons render at the top of the tabula, first thing visible, no wasted lead space.
- Rename button copy:
  - "chapters of the life — releasing →" → **"Zodiacal Releasing →"**. Title attr updates to something accurate, not "unspooled from your natal" flavor text — plain description of what it does.
  - "when should I… — windows" → **"Electional Windows →"**.
- Shrink both buttons to match the tabula's other row-height controls — currently oversized relative to peers; bring padding/font-size down to the tabula's standard chip/row scale.

## 2. Peak Periods copy (ZR doctrine picker)
- Current: `"the chart's angles"` / `"the lot's own"` — unattributed, unclear.
- Rewrite as two clearly-labeled, clearly-sourced options:
  - **"Peak at the natal angles"** — period ruler reaching the natal chart's actual ASC/MC/etc.
  - **"Peak at the Lot's own angles (Brennan)"** — Chris Brennan's method: each Lot treated as its own chart, angles derived from the Lot's position, not the natal chart.
- Apply the same rewrite to `zrLegend`'s inline legend string (currently reuses the same unattributed phrases: "peak (the chart's angles)" / "peak by (the lot's own)").

## 3. Pane-pinning vs. almanac-fusing — disambiguate, don't merge
Two distinct actions stay distinct, but need distinct language so they stop reading as duplicates:
- **"+ add to lunar pane" / "✓ on the lunar pane"** (existing `_togglePaneLens`) → keep the mechanic, but reword to make clear this pins a *tab* to the pane's rete row (alongside Natal/Sky/Transits/Almanac), not a full-screen takeover. E.g. **"+ Pin to Moon pane" / "✓ Pinned to Moon pane."**
- **Fuse-to-almanac** (existing `fused` toggle, almanac tab only) → reword to make clear this overlays ZR chapter-starts as markers on the almanac's own timespine, independent of pinning. E.g. **"Show on Almanac timeline."**
- No change to underlying logic for either — copy-only disambiguation.

## 4. Date-anchor bug — fix for both ZR and Electional
- `_zrNowPath()` (and Electional's equivalent, if it has the same issue — check `_elAnchor`/analogous seed) currently anchors "now" to `this.jd`, the astrolabe's current **dial position**, not real time.
- Fix: anchor to true wall-clock "today" JD, computed independent of wherever the instrument is currently scrubbed to. Opening ZR or Electional Windows always lands on the real present moment, regardless of dial position.

## 5. ZR sheet header — remove stray "Natal" label
- Audit the pane's shared header/tab chrome for whatever is reporting "Natal" when `sheet === 'zr'` — likely a header component reading last-active-tab or `paneLenses` state instead of `sheet`. Fix so the ZR view's header always reflects "Zodiacal Releasing," never any other tab's name.

## 6. L1–L4 rail (ZR sheet restructure)
- Replace the indent-only accordion (level implied by nesting depth) with a persistent **left-side L1/L2/L3/L4 rail** the reader can select directly.
- Selecting a level on the rail scopes/filters the visible rows to that level (or scrolls to it — decide during build) instead of requiring the reader to drill through nested indentation to find a level.
- Lot-chip arc across the top (existing arced chip row) stays as-is — no complaint there.
- Existing gestures (tap = unfold, double-tap = travel, swipe = send to almanac) carry over unchanged.

## 7. New shared primitive: Eclipse Pane (generalized, not ZR/Electional-bound)
Today "eclipse" is hardwired to interpretation readings only: gated by `s.lens === 'signif'` and `_eRead.length > 0`, driving a pager (dots/prev/next) through placement readings.

Split this into two layers:
- **Eclipse geometry** (the reusable primitive): the raised-sheet visual treatment — moon climbs higher over the sun, `sheetTf` raised position, veil opacity, corona/gold-rim swap, expanded content max-height below. This becomes a general "give this sheet more room" mode any feature can request, not owned by the signif/interpretation code path.
- **Eclipse pager** (interpretation-reading-specific): the dots/prev/next through placement packs, placement/attribution text — stays specific to the significations reading; not inherited by other consumers.
- ZR and Electional both request **eclipse geometry only** (no pager — they keep their own scroll lists and existing gestures).
- For ZR and Electional specifically: eclipse-raised is **permanent** for the duration the sheet is open (not a further slide-up gesture from a lower resting state, unlike signif → eclipse today). Opening either sheet goes straight to the raised geometry.
- Signif/interpretation keeps its current two-stage behavior (resting → slide up into eclipse) unchanged — this is a new consumer option, not a change to the existing one.
- Practically: `openZr` / the Electional open-handler set the sheet straight into eclipse-raised state on open, bypassing the `_eRead.length`-gated arming logic entirely for these two.
