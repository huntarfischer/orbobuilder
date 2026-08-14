# Orbo AstroLabe — Version Notes v0.82 (July 21, 2026)

## Shipped this pass — Almanac Tabula
Per `uploads/Almanac Tabula Spec-fb25a4e6.md`.

- **A. Multi-lot ZR fuse.** The releasing lens's almanac chips now pick **lots** (not just levels) — every `zr.js` lot gets a chip with its planet glyph (`this.LOTG`), alongside the existing L1–L4 chips. `_almZrStarts` walks chapter starts per selected lot and labels each row with its glyph + full parent chain (`Spirit L1 Leo › L2 Virgo › L3 …`), not just the terminal sign.
- **B. Day Timeline.** Tapping into a day now opens an hour-ruled single-day view instead of the flat event list: one lane per fused lot showing ZR periods as duration bars (drawn at the finest fused level, real start→end), transit/intersection/bead events as point markers plotted on the same ruler, a live "now" line when the day is today, and a chapter-chain readout above the ruler. Prev/next day arrows and a swipe gesture move the cursor a day at a time without leaving the timeline. Bars and markers travel the spine on tap, same as before.
- **C. Chrome fixes.**
  - Pane bottom padding so the last calendar/timeline row isn't flush with the sheet edge.
  - The "tap a day…" hint only renders once something's actually fused (`almHintOn`), instead of showing over an empty state.
  - Calendar header rows are now tappable (jump straight into that day's timeline) and show a `›` affordance.
- **D. Eclipse veil.** Reused the eclipse-rise veil mechanic for the Day Timeline specifically: a heavier veil (0.62 vs the normal 0.38) while the almanac is open but no day is engaged yet, so the calendar reads as backdrop until a day is chosen.

### State additions
- `almLots` (persisted, default `{Spirit: true}`) — which lots are fused into the ZR almanac stream.
- `_almDayTimeline(dayA, dayB)` — builds the hour-ruled lane/marker model consumed by the day view; cache keys (`_almCache`, calendar key) extended to include `almLots`.

### Known gaps
- Day Timeline lanes only populate when `zr` is fused AND at least one lot is selected; a fused-but-no-lot state (shouldn't normally arise, chips default one lot on) shows an empty ruler rather than a specific empty-state message.
- No horizontal zoom on the hour ruler — 24 fixed rows regardless of event density.

## Shipped this pass — Rising Lord
Per `Spec - Rising Lord stream.md` / `uploads/rising lord-7046d820.md` / `Plan - Field Journal + Rising Lord roadmap.md` (tracks R2–R5). Name settled: **Rising Lord**. Condition scope: dignity + retrograde only (combustion held for later). Peregrine: badge left blank.

- **Engine.** `rulers.js` gains `dignityOf(planet, lonDeg)` — detriment/fall added alongside the existing domicile/exaltation (regenerated `rulers.browser.js` to match, source untouched by hand). New `_risingWindows(a, b, lat, lon)` on the DC: bisects the whole-sign index of `eph.angles(jd).asc` to find each ascendant sign-crossing minute, then reads the crossing's lord (`rulers.DOMICILE`), the lord's own sign/house (whole-sign, rotated per that window's rising sign — Saturn-in-Aries still yields **two** separate rows, Capricorn-rising→4th and Aquarius-rising→3rd, never merged), and condition (`retro`, `dignity`). Live only, never spine-materialized, per the fast-hand law. Wide-window guard (>60 days) and coarse-step (10 min) high-latitude degrade — skips signs that don't rise rather than crashing.
- **Timing surface.** New standalone sheet (`sheet:'rising'`), reached from a "Rising Lord →" card on the ♏ Timing panel next to Zodiacal Releasing/Electional Windows. Scrub a day (prev/next), glance-row list of the day's handoffs (crossing time · rising sign glyph · lord glyph), element color per rising sign (matches ZR), tap-to-expand a row for lord's sign/rotating house, condition badge (`Rx`, `domicile`, `fall`, etc. — blank if peregrine). Pinnable to the lunar pane (`paneLenses`), same grammar as releasing/windows.
- **Almanac fusion.** `_almRisingLord(a,b)` wraps `_risingWindows` into the fused-stream event shape, registered in `_almEvents` and the Day Timeline's marker pass; new `almStreams` console row (`rising`, dot `#c98aa8`) with an "export ↓" chip when fused. `evRow`'s badge generalized (`ev.badge || 'LB'`) so Rising Lord's condition badge and ZR's `LB` both render through the same row.
- **Export.** `_exportRisingICS(evs, tag)` — its own named `VCALENDAR` (`X-WR-CALNAME: Rising Lord · <locus>`), `CATEGORIES:Rising Lord` per `VEVENT`, independently toggleable in Apple/Google Calendar rather than folded into the general almanac `.ics`. Triggered from both the Timing sheet (30-day export button) and the almanac console (30-day chip).

### Known gaps
- Combustion/cazimi (sun-relationship condition) not built — deferred per the open-decisions call.
- No swipe/travel gesture on Rising Lord rows yet (tap-to-expand only); ZR's pointer-drag travel/almanac gestures weren't ported this pass.

## Boot fix (carried into v0.83)
- A transit-block edit was briefly written with literal `\n` escapes instead of real newlines, commenting out its own `return` and failing the logic-class eval (the red banner some testers saw this pass). Fixed at the top of v0.83.
