# Orbo AstroLabe — Version Notes v0.81 (July 18, 2026)

## The time law
- **jd is the address; civil time is the label** (AAF §3 law, now enforced app-wide). The natal's canonical JD is resolved ONCE at engrave time and persisted — never re-derived from the device clock.
- Birth-clock resolution order: **birthplace IANA zone** (historical DST via Intl) → **longitude/15** (LMT-style) → device zone as last resort. The applied offset and its source show in ♈ ("clock applied: UTC−6 · birthplace zone").
- All 382 gazetteer cities carry an IANA zone (`cities.js`). Existing saves migrated silently: legacy device-zone reading kept verbatim (no chart jumps); trues up on any ♈ edit.
- Known limit: gazetteer is 382 cities; full GeoNames upgrade (7.3k cities, native tz) deferred — waiting on `cityMap.json` drop.

## The record shape
- One gate, `_resolveJd()`: ♈ natal, ♎ ledger persons, and AAF imports all emit the same canonical core `{ jd, tz, tzSrc, lat, lon, place, name }`.
- ♎ addPerson obeys the time law (a Tokyo birth entered in Chicago lands right); `whenStr` is the birth-local label, never re-zoned.

## Engines
- **AstroDNA (genome)**: every node now carries `speed` (deg/day, signed), `speedRatio` (÷ mean motion — comparable across bodies), `isStationary`. The 1–720 sequence encoding is UNTOUCHED — all persisted sequences stay valid. New `.extras` decode surface: SNode/Chiron/Lilith/Ceres/Pallas/Juno/Vesta + full angle family (MC/IC/DSC/Vertex/Fortune, sect). `_natal()` rebased to decode from the genome — plate, composite, threads, transit targets inherit it in one move.
- **rulers.js (new)**: rulership layer (degree→lord, exaltations, dignity-table extensible) + disposition layer (chains, final dispositors, loops, domicile/exaltation/mixed mutual receptions). Decoder engine — reads the genome, never joins it. Ready for the composite-frame cASC dispositor lens (~6 handoffs/day, read live).
- **ephem.js**: new `bodyLon(jd, name)` single-body evaluator — cut spine scan cost ~50×.
- Terminology engraved in CLAUDE.md: composite / synchronic composite / synchronic synastry / composite frame.

## The timespine
- **timespine.js (new)**: the genome's expression, materialized. Unspools birth→~100yr once: transit exact hits to natal AND synchronic-composite targets, sign ingresses, stations (~162k events, <1 MB). Returns and flips are derived views, never stored. Moon, Moon bead, and cASC handoffs refused by fast-hand law — computed live.
- Chunked unspooler with phase-locked grids + identity seam-dedupe — **proven bit-identical to a one-shot live scan** (tests/timespine.test.html, 13/13).
- **Persistence**: IndexedDB (`orbo.spine`), keyed by exact seed + engine version; built in ~26 ms idle chunks (the instrument never stutters); auto-pruned and rebuilt on seed change. ♐ shows progress ("unspooling the life — N%").
- **Readers**: `_spineQuery(a,b,filter)` with live fallback everywhere. Transit ledger + almanac transit stream now read one shared table (provably consistent). Deliberately live: ZR (pure genome arithmetic), elections (continuous scoring), synchronic synastry (the windowed pair scan IS the lazy pair-spine — same-body separations are time-invariant).

## Conformance harnesses (rerun after any engine change)
- `tests/astrodna.test.html` — genome expresses the ephemeris exactly; golden sequences pinned.
- `tests/rulers.test.html` — rulership law & disposition graphs (16 checks).
- `tests/timespine.test.html` — materialized == live, bit-exact (13 checks).

## Archive trail (July 18)
- `2026-07-18a` — pre time-law · `b` — pre record-shape · `c` — pre genome-rebase · `d` — pre timespine wiring.
