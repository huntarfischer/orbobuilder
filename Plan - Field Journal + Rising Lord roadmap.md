# Roadmap — Field Journal + Rising Lord (combined)

*Project lead: **Opus**. Easier / mechanical passes: **Sonnet**. Visual + interaction design: **Fable** (lead designer). Grounded in `Orbo Astrolabe.dc.html`, `rulers.js`, `astrodna.js`. Two subsystems, one release train; sequenced so the shared moon-side surfaces don't collide.*

---

## Locked decisions (this pass)

**Field Journal**
- **Kind vocabulary:** reuse `SUBTYPES.event` — no parallel taxonomy. The draft's kind select is that list.
- **Rating:** **signed −2…+2** ("went against me → went for me"), read directly against the predicted `outcome`. Not neutral stars.
- **Pin gesture:** "pin ♒" stays **silent-instant** (flash, current behavior); **⊕ opens the draft**. Two speeds, one store.

**Rising Lord** — carried from its spec; still-open items (name, timing host, peregrine, export trigger) stay open and are **Opus decisions at Phase R1**, not blockers for the shared engine work.

**House law (both):** additive migration — old ♒ pins with no `kind`/`rating` render exactly as today; the fast-hand Rising Lord windows are **live, never materialized on the spine**.

---

## Delegation model
- **Opus (lead):** data-model shape, the pin-record contract, the boundary root-finder, dignity math, migration correctness, sequencing, and every "is this the right astrology" call. Reviews all merges.
- **Sonnet (easier tasks):** mechanical, well-specified passes — wiring an existing handler onto more rows, adding fields to a renderVals map, ICS string assembly, copy growth, repetitive ⊕ placements once the first is proven. Never the root-finder or the calibration semantics.
- **Fable (lead designer):** the draft form, the entry row, the ⊕ affordance treatment, the signed-rating control, the Rising Lord glance-row + tap-open, the condition badge, element-color application. Owns every surface a user sees; hands Opus/Sonnet the markup, they wire state.

---

## Phase 0 — snapshot (Opus)
Copy `Orbo Astrolabe.dc.html` → `archive/Orbo Astrolabe 2026-07-19.dc.html` before any edit (CLAUDE.md: subsystem addition qualifies).

---

# Track F — Field Journal

### F1 · Data + persistence — invisible (Opus)
- Extend `_pinMoment` / `_saveChart('event',…,'pin')`: optional `kind`, `rating` (−2…+2), `source:'pin'|'log'|'photo'`, `from`. Default empty.
- Additive migration in `memoryItems`, mirroring the lazy `outcome` backfill.
- Verify round-trip through `_persist({ memory })` + reload. No UI.

### F2 · The draft form + entry row (Fable → Sonnet wires)
- **Fable:** design the compose row in `pMemory` (~615–641) — `SUBTYPES.event` kind select · signed −2…+2 control · note textarea · Save/Cancel, from CF v2's `journalDraft`. Design the kept-entry row: when · kind · signed rating · snapshot (at `depth`) · note, with inline note/rating edit.
- **Sonnet:** wire Fable's markup to state — extend `memoryItems` to expose the new fields, hook Save → `_persist`, add the inline edit handlers. Grow empty-state copy to the CF v2 line.
- **Opus:** confirm frozen `asp`/`outcome` are never re-decoded on edit.

### F3 · ⊕ log affordances (Opus proves one → Sonnet fans out)
- **Fable:** the ⊕ treatment (quiet, moon-side only, never on the instrument).
- **Opus:** build the log handler once on `evRow` (almanac) — mints a `source:'log'` draft, `name` = row label, snapshot = `_aspectSnapshot()` at that jd, opens the Journal.
- **Sonnet:** replicate the proven handler onto the aspects grid, transit ledger, timing/ZR windows.

### F4 · Calibration read (Opus + Fable)
- Surface `outcome` (predicted) × `rating` (felt) together on each entry.
- Optional signature filter (group by `asp` signature). Deferrable past first ship.

---

# Track R — Rising Lord

### R1 · Open decisions (Opus)
Settle before code: the **name**, the **Timing host** (new sub-view under `releasing` vs. own sheet), **peregrine** badge behavior, **export trigger**. Condition scope stays dignity+retro (hold combustion).

### R2 · Engine (Opus)
- Add `dignityOf(planet, lonDeg)` to `rulers.js` (detriment/fall — currently missing). Edit the `.js` source, then regenerate `rulers.browser.js` (CLAUDE.md: never hand-edit the browser build).
- Build `_risingWindows(a,b,lat,lon)` — bisect `asc(jd) − k·30` across the 0/360 seam; **12 windows/day, never merge same-lord signs** (house recomputed per window via `astrodna.houseOf`); high-latitude graceful degrade. Never materialized on the spine.

### R3 · Timing surface — standalone (Fable → Opus wires)
- **Fable:** glance-row (`7:35 ♀ Taurus`), tap-open (lord sign · rotating whole-sign house · condition · rising-sign life areas), element color on rising sign, condition **badge** (mirrors ZR `LB`).
- **Opus:** render `_risingWindows` into the chosen Timing host.

### R4 · Almanac fusion (Sonnet)
- Mechanical, once R2/R3 exist: `_almRisingLord(a,b)` wraps `_risingWindows` into `{ jd, kind:'rising', col, label, sub }`; register in `_almEvents`; add one `almStreams` row (`id:'rising', ok:hasLoc`). Reuses `evRow`.

### R5 · Export (Sonnet, Opus reviews)
- Own named `VCALENDAR` — `X-WR-CALNAME:<name> · <locus>`, `CATEGORIES` per VEVENT, bounded range. String assembly is mechanical; Opus confirms the locus/horizon-dependence law.

---

## Sequencing & collision control
1. **Phase 0** (Opus) — snapshot.
2. **F1** and **R1+R2** run in parallel — F1 is pure data (Opus), R2 is engine + `rulers.js` (Opus). No surface overlap.
3. **F2/F3** and **R3** both touch moon-side panels — **serialize Fable** across them (Journal first, it unblocks photo recall; then Rising Lord Timing). Sonnet's fan-out (F3, R4, R5) trails each proven pattern.
4. **F4** and Rising Lord polish last.

**Shared-surface watch:** `evRow` is touched by both (F3 adds ⊕, R4 adds a `rising` kind). Land F3's ⊕ handler first so R4 inherits it cleanly rather than merging against it.

## What this unblocks
F1–F2 land the exact fields (`source`, snapshot, `kind`) that `Spec - Field Journal photo recall.md` reads — photos become a `source:'photo'` feed with an EXIF decoder, **no store changes**. Rising Lord shares the almanac fused-stream engine, so R4 is near-free once R2 exists.

## Verification (per track, from the specs)
- **F:** instant pin still works; old pins unchanged; ⊕ snapshot matches `_aspectSnapshot()` at that jd; edits persist without re-decoding frozen `asp`/`outcome`; depth toggles snapshot verbosity; beads still render; `outcome`×`rating` both shown.
- **R:** ~12 unequal windows/day at plausible crossing minutes; Saturn-in-Aries → Capricorn 4th **and** Aquarius 3rd as two rows; badge matches live lord state; fuses into the almanac day view correctly; export opens as its own toggleable calendar with locus in the name.
