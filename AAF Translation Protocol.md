# AAF Translation Protocol

*How an astro.com **AAF** chart database (`#A93` / `#B93` line format) becomes Orbo roster records. Companion to `aaf.js`, which is this document made executable. Kept deliberately **separate from the app** — not wired into `Orbo Astrolabe.dc.html` this pass; Fable is the master coder for that step.*

---

## 0. Scope

AAF is astro.com / Astro-Databank's line-based export. Each chart is a **two-line pair**:

```
#A93:*,<name>,<code>,<date>,<time>,<place…>
#B93:*,<lat>,<lon>,<zone>,<flag>
```

The protocol's job is to turn each pair into **one record in the shape the roster already speaks** — the same shape `sfcht.js` emits, so a translated record drops into `chartToPerson()` unchanged — plus a set of AAF-specific extensions (calendar, canonical JD, a two-tier chart taxonomy, LMT validation, relational metadata, provenance).

The north-star law still holds: **the solar system is the clock.** A row's civil `{date, time, zone}` is the *label*; its true address is the sky-state at that instant. So the protocol's real output is a correct **`jd` + `lat` + `lon`**, from which `astrodna.buildAstroDNA()` derives the genome everything downstream decodes from.

---

## 1. Record shape

**Base (roster-compatible, identical to the SFcht importer):**

| field | meaning |
|---|---|
| `name` | chart name, verbatim |
| `y, mo, d, h, mi, sec` | civil date/time **as written** — display only |
| `tz` | UTC offset in **hours, east-positive** (the offset *as applied*) |
| `lat` | degrees, **north-positive** |
| `lon` | degrees, **east-positive** |
| `place` | reassembled place string |
| `kind` | `'person'` \| `'moment'` (roster already branches on this) |

**AAF extensions:**

| field | meaning |
|---|---|
| `jd` | **calendar-aware UT Julian Day — the canonical time.** `null` if the row has no coordinates. |
| `calendar` | `'gregorian'` \| `'julian'` |
| `city, region, country` | parsed place components |
| `tzRaw` | original zone token, e.g. `"6hw00"` |
| `dst` | `true` (DST was in force) \| `false` \| `null` (LMT / unknown) |
| `lmt` | `true` when the zone was flagged Local Mean Time |
| `lmtRecomputed`, `lmtDeltaMin` | longitude/15 offset and its distance from the stated offset (LMT rows) |
| `code` | raw AAF code `'m'` \| `'f'` \| `'e'` |
| `gender` | `'m'` \| `'f'` \| `null` |
| `type`, `subtype` | semantic category (see §6) |
| `codeConflict` | `true` when the code's implied kind disagrees with the name (see §6) |
| `relatesTo` | best-effort links to other charts/people (see §7) |
| `raw` | `{ a, b }` original lines, for provenance |

---

## 2. Field decode rules

- **name** — field 1 of the A-line, verbatim (whitespace-trimmed).
- **code** — field 2, lower-cased: `m` male, `f` female, `e` event. Treated as a *hint*, not truth (§6).
- **date** — `D.M.Y`, dots. A trailing `g` (`5.5.1577g`, `7.2.120g`) forces Gregorian; see §3.
- **time** — `H:M` or `H:M:S` (`11:34:20` occurs once). Missing → noon.
- **place** — every comma-field after time, reassembled. Component order in the source is inconsistent (`City, USA, Wisconsin` vs `City, UK, England` vs `City, Country`), so `city` = first part; `country`/`region` = the next two positionally; `place` keeps the joined original for display. Empty city (`, US, NY`) is tolerated.
- **lat** — `DDnMM` / `DDsMM` → `deg + min/60`, south negative.
- **lon** — `DDDwMM` / `DDDeMM` → `deg + min/60`, **west negative** (east-positive convention).
- **zone** — `Hhw MM` / `Hhe MM` (e.g. `6hw00`, `2he24`) → `h + min/60`, **west negative**. This is the offset *actually applied*, DST already folded in.
- **flag** — `1` DST in force, `0` standard time, `L` Local Mean Time (§4/§5).

---

## 3. Calendar & the JD divergence *(the load-bearing decision)*

The app's `ephem.julianDay()` applies the Gregorian century correction **unconditionally** — it treats every date as proleptic Gregorian. That is correct for modern and `g`-flagged dates, but a bare pre-1582 **Julian** date re-derived through it lands **~10+ days wrong** (and more, further back — Vettius Valens, 120 CE).

Rule:

- Trailing `g` → **Gregorian** (proleptic).
- Otherwise, the **1582-10-15** reform is the boundary: before it → **Julian**, on/after → **Gregorian**.

`aaf.js` computes `jd` with a calendar-aware routine (`toJD`) whose Gregorian branch is byte-identical to `ephem.julianDay()` and whose Julian branch drops the correction (`B = 0`). **`jd` is therefore the canonical time; `{y,mo,d}` are for display only.** When wiring in, downstream must read the record's `jd` (or adopt a Julian-aware `julianDay`) — never re-derive a jd from a stored Julian `{y,mo,d}` via the current Gregorian-only routine.

> **Note on this specific database:** every pre-1582 row present (Vettius Valens `120g`, the two 1577 charts) carries the `g` suffix, so in *this* file the calendar is effectively all-Gregorian and the Julian branch never fires. The rule exists for the next file that isn't so tidy.

---

## 4. DST flag (`1` / `0`)

The zone field already encodes the offset *as applied*, so `1`/`0` are **metadata, not math**: they are stored on `dst` (`true`/`false`) and never adjust `tz` or `jd`. (The data can look internally inconsistent — e.g. a 1968 UK row stamped `0he00` with flag `1`; the protocol trusts the stated offset and records the flag as provenance rather than "correcting" it.)

---

## 5. Local Mean Time (`L`) — and the validation pass

Pre-civil-zone charts carry `L`: the offset given is longitude-derived LMT (`longitude ÷ 15` hours), not a civil zone. `dst` is `null` for these.

Per the agreed policy, I ran a **recomputation pass** over every `L` row in the supplied database, comparing the stated offset against `lon/15`:

| chart | lon | stated | lon/15 | Δ |
|---|---|---|---|---|
| Millard Fillmore | 76w20 | 5h05m W | 5h05.3m | 0.3 min |
| Nathan Harris | 71w33 | 4h46m W | 4h46.2m | 0.2 min |
| Nathen Campbell Freeman | 74w27 | 4h57m W | 4h57.8m | 0.8 min |
| Nelson Calef Strang | 73w48 | 4h55m W | 4h55.2m | 0.2 min |
| Philip Abramse VR | 78w52 | 5h15m W | 5h15.5m | 0.5 min |
| Washington Irving | 74w0 | 4h56m W | 4h56.0m | 0.0 min |
| Ruth V Long | 82w28 | 5h29m W | 5h29.9m | 0.9 min |
| Pluto in Aries 1577 | 89w24 | 5h57m W | 5h57.6m | 0.6 min |
| Vettius Valens | 36e9 | 2h24m E | 2h24.6m | 0.6 min |
| *(all remaining `L` rows)* | | | | **< 1 min** |

**Every** `L` row agrees with `lon/15` to **under one arcminute**. So the file's LMT values are trustworthy →

**Default: store the stated offset and set `lmt = true`** (shown honestly on the maker's/back side). The recomputed value and its delta are retained on `lmtRecomputed` / `lmtDeltaMin` as a validated cross-check. Recompute becomes the *fallback* only if a future file's stated LMT diverges materially (a `lmtDeltaMin` above, say, ~4 min is the trip-wire — swap to the longitude-derived value and note it).

---

## 6. The two-tier taxonomy

Chart identity is **two tiers**: `kind` (the ontological class the roster branches on) then `type` / `subtype` (semantic category). "Event" is not one thing, and — as you noted — a composite is not really an event at all but a chart that exists *in relation to* others; the taxonomy reflects that.

**Tier 1 — `kind`:**

- **`person`** — a natal chart of a being or entity (`m` / `f`).
- **`moment`** — a chart of an instant (`e`).
- **`relational`** — *(reserved; not present in AAF)* a chart that exists only against ≥2 others — composite, synastry, Davison. The app **derives** these; AAF never ships one. The taxonomy names the slot so the derived charts have a home.

**Tier 2 — `type` (and `subtype`):**

| kind | type | subtype examples |
|---|---|---|
| person | `natal` | — |
| person | `fictional` | *(character)* |
| person | `entity` | `company`, `sports-team` |
| moment | `event` | *(generic)* |
| moment | `lunation` | `new-moon`, `full-moon` |
| moment | `ingress` | *(planet → sign / station)* |
| moment | `return` | `solar-return`, `nodal-return`, `lunar-return` |
| moment | `election` | — |
| moment | `communication` | `email`, `text` |
| relational | `composite` / `synastry` / `davison` | — |

**The code is a hint, not the truth.** The same file tags "New Moon" as `e`, a stadium as `m`, and "Toronto Blue Jays" once as `e` and once as `m`. So: **code seeds `kind`, name heuristics refine it**, and whenever the two disagree the record is flagged `codeConflict: true` rather than silently trusting either. Verified reclassifications from the supplied data: `SOLAR RETURN 2026` (coded `m` → moment/return), `Oct 29 Merc - Sag` (coded `m` → moment/ingress), `Toronto Blue Jays` & `Toyota` (coded `e` → person/entity). Heuristics are intentionally conservative and legible (keyword matches, listed in `aaf.js`); they are meant to be corrected by hand or by Fable, not to be the last word.

---

## 7. Relational metadata (`relatesTo`)

Some charts only mean something *pointed at another chart* — and you asked that these be connectable in metadata to people in the database:

- **communication** (`email` / `text` — "Respect email 10-22", "text back", "reachout?", "texto?") — a moment addressed to/from a person.
- **return** — belongs to a native (`SOLAR RETURN 2026` → you).
- **fictional** — belongs to a source work (`STRANGER THINGS- ELEVEN` → `Stranger Things`, populated automatically).
- **relational** (composite/synastry) — references its two constituents.

`relatesTo` is an array of best-effort link targets. Names inside the AAF strings can't be resolved to roster identities from the file alone, so the field is populated where unambiguous (fictional → source work) and otherwise left for the app to **resolve at import time against the live roster** (match the native of a return, the counterpart of an email). That resolution is a wiring-in task, not a parsing one.

---

## 8. The astrodna bridge — how values are stored

You want imported charts stored the way **`astrodna.js`** stores them. The pipeline:

```
parseAAF(text) → record{ jd, lat, lon } → buildAstroDNA(jd, lat, lon) → record.dna, record.sequence
```

`aaf.js` exposes `attachAstroDNA(records)` (lazy `import()` of `astrodna.js`, so the parser stays dependency-free) which decorates each coordinate-bearing record with:

- `dna` — the full `buildAstroDNA` genome (nodes, aspects, stelliums, elemental balance, chart ruler).
- `sequence` — the compact `sequenceString(dna)` identity.

Records without coordinates (a name-only A-line with no B-line) pass through untouched — no `jd`, no genome. `astrodna` reads `jd` (the calendar-aware value from §3), so Julian charts encode correctly.

---

## 9. Landing & wiring-in *(for Fable)*

- **Where they land:** the **people roster**, exactly as SFcht does today — `person` selectable as a partner/plate, `moment` as a moment/plate. `chartToPerson()` consumes the base shape unchanged; the extensions ride along for anything that wants them.
- **Deliberately NOT done this pass:** no import-dialog wiring, no `.aaf` file-picker branch, no roster persistence of the taxonomy, no `relatesTo` resolution. Those are app-side decisions for the master coder. Suggested wiring mirrors the SFcht flow: `import('./aaf.js')` on file select → `parseAAF(text)` → `attachAstroDNA()` → the existing import-review list → `chartToPerson()` on add.
- **Dedup:** the roster's existing `personKey = name|Y-M-D` works as-is. Consider keying on `jd` for moments that share a name+day (e.g. "text back" vs "Respect email", 2 minutes apart) if collisions matter.

---

## 10. File map

- **`aaf.js`** — the parser + `attachAstroDNA` bridge. Standalone; no UI.
- **`tests/aaf-test.html`** — a probe over a representative slice (person/event/lunation/return/election/comm/ingress/fictional/entity, Julian-`g`, and every LMT edge). Open it to see the decode.
- **this doc** — the spec.
