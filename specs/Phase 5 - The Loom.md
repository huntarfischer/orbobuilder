# Phase 5 · The Loom

Plan of record for the mundane floor, the natal spine, and the synchronic spine as one machine.
Supersedes nothing; continues `specs/Phase 4 - The Synchronic Engine.md` (Stage C items 4, 5, 7, 8)
and closes the Sagittarius ticket in `uploads/Orbo Notes 7_25.md` ("Mundane astrology option in the
daily almanac, should be a default. Be able to export to ics. This ties back to the idea of the
timespine.").

---

## 0 · Vocabulary, settled before any code

**The midpoint is primary.** The synchronic field measures the midpoint of celestial energy and the
energy of the native. That is the object. Earlier drafts of this plan described the synchronic layer
as the transiting layer "halved," which is not a claim about the field: it is bookkeeping from inside
a root-finder, which asks the inverted question "where must the sky be for this midpoint to land on a
boundary." The factor of two is real inside the solver and has no standing anywhere else. It appears
in no UI string, no doctrine sentence, and no comment outside `loom.js`.

**The loom.** Two threads, and two different weaves of the same two threads.

| | |
|---|---|
| **thread · sky** | the mundane floor. Native-independent, place-free, byte-identical for everyone. |
| **thread · native** | the engraved natal chart. |
| **weave · contact** | the natal spine. Transiting body touches natal degree. The sky *meeting* you. They remain two things; the event is the touch. |
| **weave · union** | the synchronic spine. The two become one placement at the midpoint. The sky *merged with* you. |

So the second spine is a second **kind of relation** between the same two threads, not a second
dataset and not a convenience. Contact and union.

**Embryo · fertilize.** Orbo ships the embryo: the sky's own event table, 1700 to 2100. The native
enters their data and fertilizes it. Two spines come out of that one act, a century each.

**"Fuse" keeps its dock-law meaning and only that** (a reader building a stream into the event
table, `_toggleFuse`). The floor is not fused; the floor is what the spine is made of. The two weaves
are not fused; they are woven at engrave. Never say "fuse the spines."

**No em-dash**, per `CLAUDE.md`.

---

## 1 · One scanner, three target sets

All three layers are the same builders over the same sampling. They differ only in what counts as a
target.

- **floor** · absolute targets. `30k` for ingresses; mutual separations at the aspect angles;
  syzygies; stations.
- **contact** · natal-relative targets. `N + A`.
- **union** · midpoint-relative targets, resolved to sky-space inside the solver. Twelve fixed
  boundary targets per body, plus one target per aspect per pair.

`loom.js` therefore exposes ONE scanner parameterised by a target set, and three thin builders that
produce those sets. This is the whole architectural claim of the phase: **do not write a synchronic
spine, write the third target set.**

**The double-target gotcha, recorded so it is never rediscovered.** Resolving a union target into
sky-space doubles the angle, so a target defined mod 180 becomes a target defined mod 360: **every
union target corresponds to TWO sky targets, 180° apart, and both must be scanned.** That is the
algebraic shadow of the two poles. Missing it does not crash: it silently returns a plausible half of
the events.

**Union works in axis coordinates internally.** The axis (mod 180) is continuous and never wraps, so
velocity, bracketing and unwrapping are all well behaved. Only the ingress builder converts to the
displayed point, because a sign boundary is the one thing that cares which pole is being lived from.
`spine.axialAt` remains the only door to the triple.

**Stations are shared.** A union placement is stationary exactly when its sky body is, at the same
instant. The floor's station table serves all three layers; nothing rescans it.

**Every layer reads the sky through an injected probe.** `loom.js` never imports `ephem` directly in
the app path; the DC hands it `spine.probe`. The single-door law is preserved by construction.

---

## 2 · The lunar module

The Moon is a cardinality problem, not a difficulty problem, and she gets her own generator.

Order of magnitude over one century: her sign ingresses alone are ~16,000 rows; her aspects to the
other bodies are ~100,000; her contacts to a natal chart another ~150,000; her union contacts the
same again. Everything else in all three layers put together is ~50,000. She is also the most
**local** body a reader ever wants: nobody asks for the Moon in 2079, they ask for the Moon this
week.

So `luna.js` is a **windowed generator, never a materialised table**: give it a window, it produces
her rows, memoised per window and discarded under pressure. It runs independently of the engrave
build and is always available, including before fertilization.

**Two lunar exceptions DO materialise**, because they are sparse and structural rather than dense:

- **lunations and eclipses** (floor). ~1,240 syzygies and ~450 eclipses per century.
- **her flips and her sign ingresses on the union weave** (~1,300 flips per century, one per
  sidereal month, and her union ingresses), because they are chapters of the film and must be
  scrubbable end to end.

Her mutual aspects, her natal contacts and her union contacts are generated on demand, forever.

---

## 3 · The embryo

A shipped artifact, plain `<script src>` registering a window global. **No fetch, no module import:**
the standalone-export law says the bundler follows HTML `src`/`href` only, so a fetched table ships
missing and degrades in ways the served preview never shows.

Contents, 1700 to 2100:

- planet sign ingresses, all bodies
- stations and the retrograde periods they bound
- mutual aspects, excluding the Moon
- Moon sign ingresses
- lunations (new, full, and the quarters if cheap)
- **eclipses, canonical**

**The reason to ship rather than compute is trust, not size.** Positions are already offline and
already free: `ephem.js` is 18 KB of analytic Keplerian elements plus the lunar series, so an
ephemeris does not need shipping. What needs shipping is the part that can be **verified once and
then be right forever**, which above all means eclipses: a syzygy scan is not an eclipse (node
distance, latitude, magnitude, type), and getting it wrong is both likely and embarrassing. The
eclipse block is diffed against the published canon at build time and never scanned at runtime.

Budget: single-digit MB packed, ~2 MB gzipped, for an app downloaded once that works entirely
offline. Not a constraint worth designing around.

Generated by a build script into `embryo.browser.js`, with `mundane.js` as its source of truth, per
the generated-files law.

---

## 4 · Fertilization

At engrave, while Orbo gives the onboarding and orientation, the two weaves materialise a century in
the background.

- **Span** · birth minus 1 year to birth plus 100 years, clamped to `JD_MIN`/`JD_MAX`.
- **Chunked** · built in slices with yields between them, so onboarding never stalls. The
  instrument-survives-everything law applies: the build is optional and try/caught, and a failed
  build costs the almanac, never the plate.
- **Progress is narration.** Orbo already speaks during onboarding; the build reports into that,
  because fertilization is a thing the native should feel happen once.
- **Cached in IDB** (`_idb` exists), keyed by natal identity and doctrine fingerprint
  (`_doctrineKey`).

**Materialise generously, filter at read.** The table is built with every body, every aspect, and the
widest orb, and carries the exact instant plus `enter`/`exit` at that widest orb. ♊ Bodies, ♍
Aspects and ♍ Orb then filter at read time instead of invalidating the build. One century-long build
per native, and the reader's choices stay instant. Only doctrine changes that alter the natal chart
itself force a rebuild.

**Record shape, common to all three layers:**

```
{ jd, layer: 'floor'|'contact'|'union', kind, body, other, angle,
  from, to, enter, hinge, exit, axis, phase, retro }
```

`kind` ∈ ingress · station · retrograde · syzygy · eclipse · aspect · flip. `layer` is provenance and
drives colour, and it is what lets one ICS carry all three with honest labels.

---

## 5 · The lens

- **The floor is the almanac's base layer, not a fusible stream.** The ticket says the mundane option
  should be a default, and the mundane-chart reading agrees: standing structure first, personal
  triggers on top. ♐ therefore gets **density chips per mundane kind**, not a fuse toggle.
- **The two weaves are lenses** and follow the dock law exactly: the tabula field icon **opens**
  (and must never write `paneLenses`), the rune **etches**, un-etching is a 520 ms hold on the pane's
  crown.
- **Rows read as mundane charts.** The standing configuration, its government, and when the fast
  bodies next close it. This is the correction from the 14-chart review: the Moon is not the moving
  light in a still set, she is the **switch**. Because the parked cluster sits within a few degrees of
  itself, the instant she reaches one member she reaches all of them, and the whole configuration
  lights and goes dark at once. A row that says "Moon trine Mercury" is under-reporting the event.
- **The element and modality tally is a legitimate slow readout** and moves week to week off the
  Moon and one slow ingress. Cheap, honest, not event-based.
- **Distance to the next boundary, per placement.** This native has three placements parked in the
  29th degree, so months of their news is about cusps. A proximity readout says that at a glance and
  costs nothing.
- ICS export carries all three layers with `layer` in the description. A flip exports as its window
  (`_exportFieldICS` already does this); ingresses and contacts export as instants.

---

## 6 · The camera

The same-ascendant anchor is the **camera on the union weave, not its foundation**. Houses are natal
whole-sign by law, so a union ingress is a function of time alone: the anchor contributes a stable
frame to watch the film in and contributes nothing to the event table.

- Retire the `setInterval(90 ms)` in `_ptPlay`. It is a second timeline and violates the presentation
  clock law. The film advances from the one RAF through a spine door, at a rate, with a spring.
- Once the ledger no longer depends on frame sampling, **cadence chips** become available beyond
  daily: lunation, monthly, chapter. A century at one frame per day is 36,500 frames of mostly
  nothing; the film should be able to run at the rate its events actually arrive.
- `_ptInfo`'s `now + 365.25` ceiling lifts to the materialised span.
- `_ptEnter` currently forces solo (`composite: true`, `rete: 'sky'`, `compAB` cleared). The pair's
  film (Phase 4 Stage C8, composite A on the plate and composite B on the rete, shared cursor, no
  anchor) gets its place here.

---

## 7 · Carried debt, cleared in passing

- `_sheetDataCross` still passes a hardcoded `orb: 3`. Move onto `synOrb`.
- **`_crossExact` returns only the nearest root in each direction from `now`.** That is the actual
  blocker on exporting a year of Crossing, and it is not a windowing bug: a year of repeats is never
  computed. It emits every root in the window once the target algebra exists.
- ICS writes floating local times via `jdToDate` plus `getHours`, so a DST boundary makes a smooth
  stream hop an hour in the user's calendar (visible in the fixture: the anchor's civil time jumps
  from 22:30 to 23:25 across 8 Mar 2026 while the underlying instant drifts smoothly). Emit UTC or a
  real TZID.

---

## 8 · Order of work

| | |
|---|---|
| S0 | **DONE 2026-07-29.** Target algebra in `framing.js`, pure, verified in `tests/loom-algebra.test.html` (23 checks). |
| S1 | **DONE 2026-07-29.** `loom.js` plus `loom.browser.js`. Decade floor 7851 rows in 5.0s; union weave conforms to `synEvents` exactly. `tests/loom.test.html` (22 checks). |
| S2 | **DONE 2026-07-29.** `luna.js` plus the browser build, memoised and span-capped, with `switchGroups`. Wired to the floor's contacts chip. `tests/luna.test.html` (19 checks). |
| S3 | **DONE 2026-07-30.** `mundane.js` plus the generated `embryo.browser.js`: 1700 to 2100, 320,924 rows, 2.68 MB, 8.8 bytes a row. Eclipses diffed against the canon in `tests/mundane.test.html` (58 entries, 28 solar and 30 lunar, all found, none invented, one type corrected). `tests/embryo.test.html` checks the shipped artifact against a live scan. Regenerate with `tools/build-embryo.html`. |
| S4 | **DONE 2026-07-30** (narration deferred to the Orbo script, by request). `fertilize.js` plus `fertilize.browser.js`: span, cache key, chunked generator, byte codec, read cuts. 400 days of both weaves builds in 0.85s and packs at 10.1 bytes a row (~1.1 MB extrapolated to a century of both). Wired into the DC as `_fertEnsure` / `_fertQuery` / `_fertSyn`, IDB `orbo.weave`, read by `_synEvents` with the live scan intact as fallback. `tests/fertilize.test.html` (38 checks). |
| S5 | **THIN LANDED 2026-07-29:** floor as the almanac base layer, ♐ Mundane socket with density chips, mundane rows, ICS carrying `layer`. Remaining: the two weaves etchable as lenses, the switch reading (the Moon lighting a parked group at once), element and modality tally, distance to next boundary. |
| S6 | The bridge scanner: union placement against a mundane body or a mundane angle. The one genuinely new root-finder in the phase, and the operands it needs are exactly what the floor carries. |
| S7 | The camera: one RAF, cadence chips, the pair's film. |
| S8 | The debt in §7. |

S5 lands thin after S1 (ingresses and flips only) so the thing is readable on the pane early.

---

## 9 · Verification

- **The 14-chart fixture.** `uploads/Screenshot 2026-07-29 at 8.5*.png`: fourteen consecutive daily
  synchronic composites for one natal, 16 rows each, 224 values. If our displayed point matches all of
  them, we agree with the world on which pole is shown, and can then say the thing those charts
  cannot: which pole, and how far from the end of the arc. Their ASC wanders 11°08′ to 11°53′ because
  they anchor on a five-minute grid; `findAscAnchor` bisects, so ours should be an order tighter, and
  that is a number to assert.
- **The Capricorn to Aquarius counterexample.** In the fixture, union Saturn crosses 29°56′ Capricorn
  into 0°00′ Aquarius on 9 Mar 2026: a change of sign and of house with **no change of dispositor**,
  Saturn to Saturn. The ingress row must not assume the three readings always change together.
- **Retrograde on the union weave is real.** Union Mercury runs 29°08′ back to 24°14′ across the
  fixture. Direction must pick the boundary (the v0.878 fix) on this layer too.
- Eclipse block diffed against the published canon at build time.
- Station table asserted identical across all three layers.

### What S4 found

- **A flip's other end is derived, not stored.** A flip IS transiting P opposing natal P, so on the
  contact layer the row's `other` is the body itself. Storing it cost a byte a row to say what the
  header already said; not deriving it made the round trip lossy for exactly the flip rows.
- **The ephemeris does not own its own bounds.** `JD_MIN`/`JD_MAX` are the host UI's (1700 to 2149,
  per ephem.js's header), so `fertSpan` takes them as arguments rather than reading them off the
  engine. A native born near the edge is CLAMPED, never scanned past it.
- **An orb is linear in the residual, so ♍ Orb is a read-time scale, not a rescan.** Windows are
  stored at the build's widest orb (10°) and narrowed on the way out, halved and tapered through
  `synOrb` on the union layer. Measured: mean contact window 33.0 days at orb 10, 9.9 at orb 3, from
  the same bytes.
- **Chunking loses no root.** 400 days built in two slices per layer is identical to a one-shot scan
  of the same span: 398 union rows both ways, every root paired, max delta 0.00 minutes. Slices are
  half-open so a root on a boundary is emitted once.
- **A century must be chunked, and the numbers say so out loud.** 400 days costs 0.85s, which
  extrapolates to about 78 seconds for the full span. The build is a generator so the caller owns
  every yield point, and `cancel` makes a re-engrave mid-fertilization free.

### What S3 found

- **A syzygy scan is not an eclipse, and the 3D state was missing.** `ephem.js` gained `moonState`
  (lon, lat, distance) and `sunState` (lon, distance), the only two doors that read the lunar series
  in three dimensions. `positions()` stays longitude-only so no scan pays for them.
- **We do not claim hybrid.** An annular-total eclipse is a statement about the whole track, not one
  ratio at greatest eclipse: ours reads 1.014 for April 2023, on the total side, and no threshold
  separates that from a merely deep annular without relabelling half the canon. The geometry returns
  total, annular or partial and flags the knife edge; `applyCanon` takes the canon's word at build
  time and the word is packed into the row. That is the whole reason the block is shipped.
- **The umbral magnitude of a penumbral eclipse is NEGATIVE.** An unsigned varint clamped it to zero
  and lost the depth of every penumbral event.
- **A shipped table is bytes, not JSON.** Arrays of decimal numbers cost 27 bytes a row; the varint
  byte stream costs 8.8, and the row layout differs per kind because a sentinel for a field a kind
  does not have is a byte spent on nothing. Reading is two passes: index once, decode the window.
- **The residency guard was silently deleting stations, and the embryo is what exposed it.** The
  confirmation distance for a station is measured in degrees PER DAY, so 0.05 asked a body to move
  twenty times faster than Saturn ever moves retrograde. Neptune and Pluto never move that fast at
  all: they had no stations in any window, at any length, and therefore no retrograde periods either.
  `CONFIRM_SPEED` is now a hair off zero (5e-4), and a velocity sign change is not the thing residency
  guards against in the first place: a body cannot wobble across its own station without genuinely
  reversing. Per decade the table now carries Uranus 20, Neptune 20, Pluto 20, Chiron 19, as it must.

---

## 10 · Risks

- **Engrave time budget.** A century of contact plus union at v0.878 scan rates is tens of seconds.
  Chunking and narration make that a feature; failing to chunk makes it a hang.
- **IDB size** for two century tables. Pack aggressively; the reader filters, so nothing is stored
  twice.
- **The double-target gotcha** (§1). The failure mode is a plausible half-count, not an error.
- **Moon cardinality** (§2). The moment she is materialised anywhere she was not planned for, the
  table grows by an order of magnitude.
- **The standalone bundler** (§3). Anything reached by fetch or module import ships missing.
