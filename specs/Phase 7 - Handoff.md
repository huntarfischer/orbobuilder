# Phase 7 · Handoff

Written 2026-08-12 at the close of the planning conversation. Read this, then read
`specs/Phase 7 - Synchronic Time.md`, which is the plan of record. **Nothing in Phase 7 is built.**

---

## Where this came from

The user asked for a review of synchronic synastry, then pushed back four times, and each pushback
moved the design. The corrections matter more than the conclusions, because a fresh build will be
tempted to re-derive the versions that were rejected:

1. **"The lunar pane is mostly static information."** True of the layout, but the deeper finding was
   that the window control (`crossBack`/`crossFwd`) filters a snapshot taken at `now`, so it can only
   subtract. 150 days ahead reads about a week. Same defect exists a second time in Chronicle's
   `ptSpan`, which only raises `min`.
2. **"The static part isn't true — CB hits their Venus opposition today, ours are opposed until I hit
   mine. That's nowhere."** Correct, and it is a *dropped value*, not a missing calculation:
   `_sheetDataCross` computes the live mode correctly from `phA ^ phB` and then labels it "fixed since
   birth." Same-body pairs are also excluded from the chronology by construction
   (`exactJd: sameBody ? null : …`).
3. **"It shouldn't have to step out the flip. Compare values, don't calculate."** This killed my
   proposed flip-calendar engine. `timespine.js` already has `isFlip` under *"tagged views — derived,
   never stored."* The answer is stored values read by comparison.
4. **"There should be a synchronic spine, an exact copy of the engraved spine but refracted — and this
   is a different way of discussing the chronology socket."** Chronicle already enumerates the sample
   grid and stores only `i → jd`.
5. **"If you see the natal chart as the prism, then it refracts — it refracts itself and shows
   itself."** This removed an exception I had written into the spec (see below).
6. **"Solo spine first — same way ZR builds its table when first enabled."** Reversed the build order
   and gave the trigger its contract.
7. **"The beads are beads, not glyphs that tell the user what they're using."** Settled the marking
   question.

---

## The five things to hold in your head

**1 · Synchronic time is one number.** `frame index + σ/180`. Chronology owns the integer part, the
Clock owns the fraction. They are currently two subsystems that compute the same anchor two different
ways (`_ptFrameJd` Newton-polishes `posAt` inside a 90 ms play timer; `_sheetDataClock` uses
`ramcJdNear` on gmst alone). One door, and it is `ramcJdNear`.

**2 · The natal is the prism, and the fixed point of its own refraction.** `refract(natal, natal) =
natal`. So the overlay refracts **uniformly, with no skip list and no natal conditional** — the natal
comes back unchanged because the arithmetic says so, not because it is exempted. Do not confuse this
with `refract(natal, refract(natal, sky))`, which is P1's double-application error (21 plausible rows,
measured). §2.4 and §2.4.1.

**3 · The prism is a MODE as well as a seat.** P1 seated it as an occupant. Phase 7 lays it over the
whole instrument, inserted as a field on `_reading()` beside `frame` — so every reader refracts with
none rewritten and **no new drawing routine, no new geometry, no new widget.** Prism-as-seat survives
untouched; two acts, two mechanisms, never unified.

**4 · Store values, read events by comparison.** Nothing detects, thresholds, or differences the
cursor. Precise boundaries are recovered by bisecting *on the table* at read time. This keeps "no
event times, ever" intact — a sample is a value at a time and asserts nothing happened.

**5 · Tables before views.** Building the live view first means building it against live recomputation
and then rebuilding it against the spine.

---

## Build order (§8)

1. **One anchor door** — `_ptFrameJd` → `ramcJdNear`, second path deleted, no fallback. Prerequisite:
   the anchor IS the solo spine's sample grid. Also removes ephemeris work from the play loop.
2. **The solo synchronic spine** — `_ptCache` widened from `i → jd` to `i → refracted state`. Not a
   new subsystem; a cache that keeps what it already computes. Lazy on first enable like `_zrData`,
   incremental unspool on idle, century, IndexedDB. Key: chart × prism `CODEC` × `doctrineKey` (today
   it is keyed on `njd` alone — a live staleness defect).
3. **Clock to the instrument** — ♓ Clock sets the mode instead of opening a sheet. σ and drift legible
   on the face. `ledgerOf` stays on the pane under its own name; it is a moon view and always was.
4. **The prism overlay** — refraction on `_reading()`; bead marking; inverse hit map; entry spring;
   house qualification.
5. **`_prismTables(chart)`** takes a chart and keys a small cache. Pure refactor. Today hardcoded to
   `this._natal()` with a single cache slot, so no chart but the user's can have a template.
6. **The pair spine** — minted on favorite. Same-body → value runs; cross-body → crossings. Century,
   IndexedDB, place-free.
7. **Synastry reads slices**; the Venus case (§5.1) appears; the window control becomes real; the two
   `_almCross` defects go.
8. **The pane's layout**, last.

---

## Decisions already made · do not reopen

- **Century span, IndexedDB persistence**, both spines. User's call.
- **Lazy trigger.** Engraving a natal mints nothing. Opening Chronicle, Clock or the overlay does.
  `_progData` already states the rule for ZR verbatim.
- **Marking is on the BEADS** — a bead says *who* and not *what*. Not a corner badge, not a field wash
  alone, not rim copy. It is an occupant property beside `frozen` inside `_drawLitTrack`; **never**
  branch that routine into a refracted variant (the `skyOn ? drawOrder : []` mistake). The visual
  treatment itself is still open — propose against §2.7's constraint list at step 4.
- **Two spines, because the anchor is solo.** The rising-return anchor is definitionally unshareable,
  so the pair spine has no anchor: it samples uniform time, is place-free, and is therefore the
  byte-identical export doctrine promises.
- **Same-body separations are piecewise-constant two-valued** (`{δ/2, 180−δ/2}`), so they store as
  runs — a few hundred segments per body per century. Cross-body vary continuously and store as
  crossings, exactly as the engraved spine stores hits.
- **Mode is orthogonal to frame.** The full dial is prism mode **and** `natalAsc` frame together.
- **Geocentric by law**; lot arcs still deferred (sect is the synchronic chart's own).

## Refused

A flip-calendar engine (a third path to a fact that already has two). A refraction table (quantizes
against the codec law). A second refraction path. A natal exemption. Unifying prism-mode with
prism-seat. Event times on any spine. Any new drawing routine.

---

## The hard part, and its answer

Under a full overlay every grabbable bead is refracted, and `this.held` resolves through `this.pos` —
the cursor's own sky. P1 gave the seated prism no scrub hit for exactly this reason.

Refraction inverts: `skyLon = 2·sLon − nLon`, two roots 180° apart, root chosen by `framing.phaseOf`
(exact from wrapped longitudes, one sample, no stored state). So refracted beads stay grabbable and
scrub through a spine door as always. **`d(sLon)/d(skyLon) = ½`, so in prism mode the wheel is geared
2:1 and a drag of the same size covers twice the time.** That is the operation made tactile, not a bug
to correct.

**NEVER** take the pole from a difference of two samples. P4 settled this and `tests/prism.test.html`
holds the line: at six-hour steps a leap detector reports 0 flips across a day containing 1.

---

## Live defects to fix in passing

- `_ptCache` keyed on `njd` alone — changed birth place or codec serves stale frames.
- `_almCross`'s cache key omits `crossBack`/`crossFwd`, which feed `scanH` — stale almanac rows.
- `_almCross` gates on `typeof r === 'object' && r.jd`, the shape-not-occupancy test the seating law
  outlawed. Wants `_reteIsOther()`.
- `_loomFloor`'s row mapper has no `kind === 'eclipse'` branch (pre-existing, noted in CLAUDE.md).

## Proof obligations (§9)

Drawing routines unchanged. Natal-solo render with prism off byte-identical to today. Fixed point
holds to 0.000000000° including Ascendant and all eight lots. No skip list in the refraction path (a
grep obligation). `_drawLitTrack` still one routine. No spine built by engraving alone. Chunked build
bit-identical to one-shot. Same-body separations 0.000000000° across the century. A window control
test that sets 150 days and asserts rows beyond day 7.

## House rules that will bite

- `framing.browser.js`, `loom.browser.js`, `prism.browser.js` are **hand-maintained mirrors** with no
  generator. Mirror in the same turn as the source and verify by running
  `tests/loom-algebra.test.html`, `tests/loom.test.html`, `tests/prism.test.html` — 938 checks, 0
  failures is the current green.
- Snapshot to `archive/Orbo Astrolabe YYYY-MM-DD[a].dc.html` before any significant revision. No
  parallel `v8` root files.
- The back's review path is `window.__orbo.setState({flipped: true, panel: …})`; a rim double-tap is
  not reproducible with synthetic pointer events.
- **Orbo never uses the em-dash**, in UI, write-ups, or chat.
- Presentation clock: one `dt` from the one RAF, springs never on the spine, no CSS transitions on
  gesture-driven motion.
- A `ref="{{ x }}"` binds only if `x` is returned from `renderVals()`. It fails silently.

## The recording law (§7)

*A value computed and not recorded is invisible to every reader.* Four instances now: `frameOffset`,
`sigma`/`sigmaEnd`, Chronicle's frames, and the live mode. Every table Phase 7 adds carries a
load-time check that refuses an incomplete row, in the shape of P2's offset check.
