# Almanac Tabula — Functional Spec

## A. Data — what feeds the almanac

- **A1. ZR levels.** All four levels (L1 years, L2 months, L3 days, L4 hours) fusable, default on. *(done)*
- **A2. Multi-lot fuse.** Today the almanac only ever reads whichever single lot is selected in Timing (`state.zrLot`). Needs its own multi-select on the "releasing" stream card — any combination of the 8 lots (Fortune, Spirit, Eros, Necessity, Courage, Victory, Nemesis, Death), each merged into the feed independently.
- **A3. Per-row lot identity.** Each ZR row needs a visible lot glyph/color, not buried in 8px subtext, so same-day starts from different lots are distinguishable at a glance.
- **A4. Per-row parent chain.** Show the nesting (e.g. "Spirit L1 Leo › L2 Scorpio › L4 Cancer") so an isolated L4 tick has context.

## B. Views

- **B1. Duplicate views.** "Upcoming" and "calendar → tap a day" currently render the identical flat row list — not an intentional second view, needs to diverge.
- **B2. New Day Timeline view.** Hour-ruled single day (modeled on a standard calendar app's day view): ZR periods drawn as duration bars spanning real start→end (not instant ticks), transits/beads/intersections as point markers on the same ruler, multiple lots as parallel lanes or overlaid distinguishable colors.
- **B3. Entry points stay, destination changes.** "Upcoming" (rolling agenda) and "calendar" (month grid) remain the two entry points; tapping a day opens the Day Timeline, not today's flat list.
- **B4. Rise for space.** Day Timeline opens via the eclipse-tier rise (see D) rather than living in the default pull-up height.

## C. Chrome

- **C1. Wrong background wheel.** The plate/"NATAL" wheel behind the Almanac sheet is contextually wrong at rest (pre-rise) — swap for something almanac-relevant, or drop it. (Partially masked once risen — see D — but still wrong in the resting state.)
- **C2. Missing bottom padding.** The pull-up pane's content column has no `padding-bottom`; last row/hint crowds the pane's edge.
- **C3. Unconditional hint.** "Tap a day to open it · tap a row to travel" renders regardless of state — must hide when nothing's fused/tappable (e.g. the no-fuse empty state).

## D. Reuse the eclipse tier for vertical space

The eclipse tier is a *rise* mechanic used today on natal-placement readings: it translates the whole pull-up sheet further up-screen (`_eclipseTranslate()`), drops a veil over the wheel, swaps the corona glow for the gold eclipse-ring glow, then shows paged interpretation prose (swipe/dots pager) pulled from an interpretation pack. It's gated to `s.lens === 'signif'` with a non-empty reading pack — it has no awareness of almanac data today.

**Transfers to the Almanac Day Timeline:**
- The rise (further `sheetTf` translate)
- The veil over the wheel
- The corona → eclipse-glow swap
- The "slide up ↑" invite affordance
- The "tap to dismiss" / close-back-down behavior

**Does not transfer:**
- The prev/next dot pager — that assumes a small fixed set of text readings. Day-to-day navigation in the Timeline should stay a plain swipe gesture, no dot rail.

**New gating needed:** `eclipseAvail`/`eclipseOn` need an almanac-specific condition (e.g. `s.sheet === 'almanac' && almHasEvents`, specifically when the Day Timeline is engaged) added alongside — not replacing — the existing natal-reading condition. Trigger on opening a day, not on the whole Almanac sheet at rest (agenda/month-grid browsing don't need the extra height).
