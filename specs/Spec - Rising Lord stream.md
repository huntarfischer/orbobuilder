# Spec — the Rising Lord (Ascendant Lord of the moment)

*Draft for review, not a build order. Every "what exists" claim is grounded in the current `Orbo Astrolabe.dc.html` / `rulers.js` / `astrodna.js`. Name is unsettled: "Rising Lord" / "Ascendant Lord" / "Lord Ascending" — pick before code.*

---

## What it is
The lord of the sign **rising right now**, at the here-&-now horizon, and its **state** at that instant. As the ascendant crosses each 30° boundary the lord hands off (~12×/day). This is the fast hand of the disposition layer — the natal/local cousin of the composite-frame cASC handoff the doctrine already reads live.

**Not planetary hours.** No equal/seasonal twelfths. The handoff moments are the **oblique ascension** of each sign boundary — the exact thing an astrolabe plate computes.

## The one thing to get right (your correction, 07-18)
**Never merge consecutive same-lord signs.** Saturn rules both Capricorn and Aquarius, but they are two different windows because the whole-sign house framework rotates with the ascendant:
- Saturn in Aries, **Capricorn** rising → Saturn in the **4th**.
- Saturn in Aries, **Aquarius** rising → Saturn in the **3rd**.
Same planet, different house, different area of life. The window's whole-sign house is computed **relative to that window's rising sign**, recomputed each handoff. Merging would erase the only distinction the feature exists to show. So: **12 windows a day, one per rising sign, even when the lord repeats.**

## Grain (settled)
Sign-lord only for now. (Bounds/terms lord is a possible later "deep" toggle — not this pass.)

---

## What already exists — consume, do not rebuild

**Almanac = fused-stream engine** (`Orbo Astrolabe.dc.html`):
- `state.fused` — array of stream ids currently on: `transits`, `zr`, `cross`, `beads`.
- `_almEvents(a,b)` — merges + sorts every fused stream's events for the window; cached by hour-rounded window + config.
- Per-stream builders `_almTx`, `_almZrStarts`, `_almCross`, `_almBeads` — each returns event objects shaped `{ jd, kind, col, label, sub, lb? }`.
- `almStreams` (♐ console) — one row per fusible stream: `{ id, name, dot, ok, sub, chips }` + a fuse toggle (`_toggleFuse(id)`).
- Read-forms: `almUpcoming` (agenda), `almCalendar` (month grid), day view (`_almDayJd`). `evRow(ev)` renders a row from an event, already surfaces `col`, `label`, `sub`, `time`, and an `lb`→badge.

**Color law** (two coexist, neither is condition-based — this corrects my earlier "color by condition"):
- Per-stream accent: transits `#4da4d9`, zr `#e8ab41`, cross `#dd8f78`, beads `#beb8e2`.
- Per-element for sign events: the ZR detail colors periods by triplicity via `this.ELEM[signIndex % 4]` (fire/earth/air/water) — this is what the iCal screenshot shows.

**Engine helpers already available:**
- `rulers.lordOf(lonDeg)` → `{ sign, signIndex, degreeInSign, ruler, exalted, exaltDegree }`. Domicile + exaltation only.
- `astrodna.houseOf(signIdx, ascSignIdx)` — whole-sign house of a sign given the ascendant sign. Exactly the rotating-house math above.
- `ephem.angles(jd, lat, lon).asc` — the ascendant longitude at a jd/place.
- `ephem.bodyLon(jd, name)` — single-body longitude (fast); use for the lord's position + a finite-difference speed for retrograde.
- Location: `this.lat` / `this.lng`, the "Here & now" seat, `state.locLabel/locPlace`. The here-&-now horizon is already modeled.

**ICS export** (`_exportAlmanacICS`): writes **one flat VCALENDAR** of the fused window — 1h events, `SUMMARY = KIND + ': ' + label`, **no `CATEGORIES`, no `X-WR-CALNAME`**. Nothing is independently toggleable inside a calendar app today.

**Gaps in what exists (small build, flag them):**
- `rulers.js` has domicile + exaltation but **no detriment/fall** — condition needs them (planet in sign opposite its domicile = detriment; opposite its exaltation = fall). Add a `dignityOf(planet, lonDeg)` helper to `rulers.js` rather than deriving locally.
- No ascendant-boundary root-finder yet.

---

## The engine to build

`_risingWindows(a, b, lat, lon)` → ordered array, one entry per ascendant sign-crossing in `(a,b]`, each:
```
{ jd,                 // the crossing minute (oblique ascension of the boundary)
  risingSign,         // sign index now on the ascendant
  lord,               // rulers.DOMICILE[risingSign]
  lordSign,           // lord's own sign at jd (via bodyLon)
  lordHouse,          // astrodna.houseOf(lordSign, risingSign)  ← rotates per window
  condition }         // { retro, dignity }  dignity ∈ domicile|exalt|detriment|fall|peregrine
```
- **Boundary find:** bisect `asc(jd) − k·30` (unwrap the 0/360 seam). Ascendant advances ~one full turn per day but its rate varies hugely by sign — that unevenness is the feature; render true widths.
- **Live fast-hand:** computed per window, **never materialized on the timespine** — same law that refuses the Moon and cASC handoffs.
- **High latitude:** signs of short ascension can rise in minutes; some may not rise at all above ~66°. Degrade gracefully (skip non-rising signs, don't crash the finder).

## The two surfaces (one engine)

1. **Timing tab — standalone.** The primary home: scrub a day and see its rising-lord windows on their own, play with it. `_risingWindows` renders directly here. *(Confirm exact host sheet — the "Timing" tab is the `releasing` panel; tell me whether this is a new sub-view there or its own sheet.)*
2. **Almanac — fusible.** `_almRisingLord(a,b)` wraps the **same** `_risingWindows` call into `{ jd, kind:'rising', col, label, sub }`, registered in `_almEvents`, plus one `almStreams` row (`{ id:'rising', dot, ok: hasLoc }`). Fusing drops the minute-marks in among transits/ZR.

## Display (settled)
- **At a glance:** the day as a list of **sign-change minutes** — `7:35 ♀ Taurus` · `9:48 ☿ Gemini` · … Crossing time + rising sign + lord glyph. Nothing else.
- **On tap:** expand to full state — lord's sign, rotating whole-sign house, condition, and the areas of life the rising sign governs. (App's existing glance-row + tap-to-open grammar.)
- **Color:** element color on the rising sign (`this.ELEM[risingSign % 4]`), matching ZR.
- **Condition:** a **badge** (mirrors the ZR `LB` badge) — `Rx`, `domicile`, `fall`, etc. Not a recolor.

## Export
Rising Lord exports as **its own named calendar**, so it's independently toggleable in Apple/Google Calendar:
- separate `VCALENDAR` with `X-WR-CALNAME:<name> · <locus>` (locus baked in — these times are horizon-dependent),
- `CATEGORIES:<name>` per VEVENT,
- bounded date-range download (an .ics is frozen; no live webcal without a server — name the limit).

---

## Still open (your call before I code)
1. **The name.**
2. **Timing host** — new sub-view under the `releasing`/Timing tab, or its own sheet?
3. **Condition scope** — dignity + retrograde only, or also sun-relationship (combust/cazimi) now? (I'd hold combustion for later.)
4. **Peregrine** — show "peregrine" when the lord has no essential dignity, or leave the badge blank?
5. **Export trigger** — from Timing, from the almanac console, or both?

## Verification
- Feed a known chart/place: confirm ~12 windows/day, unequal widths, at plausible ascendant-crossing minutes.
- Saturn-in-Aries case: Capricorn window shows 4th house, Aquarius window shows 3rd — **two separate rows**, not one.
- Retrograde/dignity badge matches the lord's live state at the crossing jd.
- Fused into the almanac, minute-marks interleave correctly with transits/ZR in the day view.
- Export opens as its own toggleable calendar with the locus in its name.
