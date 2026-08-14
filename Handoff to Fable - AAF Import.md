# Handoff to Fable — wire AAF import into Orbo

*Prompt for the master coder. Design/spec work is done and verified; this is the app-side integration. Read `AAF Translation Protocol.md` first — it's the full rationale; this is the task list.*

---

## What already exists (done, verified, do not rebuild)

- **`aaf.js`** — standalone parser + astrodna bridge. Not imported anywhere yet.
  - `parseAAF(text)` → `record[]`. Each record is **roster-compatible** — the same base shape `sfcht.js` emits (`name, y, mo, d, h, mi, sec, tz [UTC E+], lat [N+], lon [E+], place, kind`), so `chartToPerson()` in `Composite Framing v2.dc.html` consumes it **unchanged**. Extra fields ride along: `jd, calendar, city/region/country, tzRaw, dst, lmt, lmtRecomputed, lmtDeltaMin, code, gender, type, subtype, codeConflict, relatesTo, raw`.
  - `attachAstroDNA(records)` — lazy-imports `astrodna.js`, decorates each coordinate-bearing record with `.dna` (full `buildAstroDNA` genome) and `.sequence` (compact identity). This is how values get stored the astrodna way.
  - `toJD(...)` — calendar-aware Julian Day, exported.
- **`tests/aaf-test.html`** — probe over 18 representative rows (person/event/lunation/return/election/comm/ingress/fictional/entity, Julian-`g`, every LMT edge). Open it to see the decode; console prints `AAF_TEST_OK 18`.
- **`AAF Translation Protocol.md`** — the spec.

Three decisions already made and baked into `aaf.js` — honor them, don't relitigate:
1. **`jd` is canonical time**, not `{y,mo,d}`. `ephem.julianDay()` is Gregorian-only and would misplace bare pre-1582 Julian dates by ~10+ days. Read `record.jd` downstream; never re-derive a jd from a stored Julian `{y,mo,d}`.
2. **LMT**: store the stated offset + `lmt:true`; recompute (`lon/15`) is a validated fallback only (trip-wire `lmtDeltaMin > ~4`).
3. **DST flag is metadata** (`dst`), never adjusts `tz`/`jd`.

---

## What comes next (your work)

### 1. Import-dialog branch (mirror the SFcht flow)
In `Composite Framing v2.dc.html`, `onImportClick` currently hard-codes `.SFcht`. Add `.aaf` (and plain `.txt` AAF exports):
- accept `.SFcht,.sfcht,.aaf,.txt`.
- branch on extension/content: `#A93` present → `import('./aaf.js').then(m => m.parseAAF(text))`; else the existing `parseSFcht(arrayBuffer)`.
- AAF is text — read `file.text()`, not `arrayBuffer()`.
- after parse, `await m.attachAstroDNA(charts)` before showing the review list, so `sequence`/`dna` exist on add.
- reuse the existing `importCharts` / review-list / `onImportAll` machinery untouched.

### 2. Persist the taxonomy on the roster
`chartToPerson()` today drops everything but the base fields. Decide what the roster should keep — at minimum `kind` (already kept), plus `type`, `subtype`, `jd`, `calendar`, `lmt`, `sequence`. Extend `savePeople`/load so these survive reload. `kind:'moment'` already branches in the UI; `type`/`subtype` are new and need display affordances (badge/glyph in the partner picker?).

### 3. Store via astrodna (the real point)
Right now the app re-derives positions per view from `ephem`/`framing`. The intent (per `astrodna.js` header and CLAUDE.md) is that charts store their genome once and views **decode** from it. Wiring AAF is a good first customer: persist `record.sequence` (and/or the full `dna`) with the roster entry, and start reading identity/aspects/elemental from it instead of recomputing. This is the bigger architectural move — scope it separately if needed.

### 4. `relatesTo` resolution (needs the live roster — genuinely app-side)
`aaf.js` populates `relatesTo` only where unambiguous (fictional → source work). At import time, resolve the rest against the roster:
- **return** → its native (match the person whose natal the return recurs on).
- **communication** (email/text) → counterpart person.
- **relational** (composite/synastry) → the two constituents.
Surface as links in metadata so a moment can point at the person it concerns. UI for this is your call.

### 5. Dedup for near-simultaneous moments
Roster `personKey = name|Y-M-D` collides for same-name/same-day moments ("text back" vs "Respect email", 2 min apart). Key moments on `jd` if that matters.

### 6. Reserved: `kind:'relational'`
Composites/synastry/Davison are `relational` in the taxonomy but AAF never ships one — the app derives them. The slot's named; build the derivation when you get there.

---

## Sanity checks before you ship
- Julian charts (feed a bare pre-1582 date, no `g`) must produce a `jd` ~10+ days off the Gregorian reading — confirm you're reading `record.jd`, not recomputing.
- A `codeConflict:true` row (e.g. a `SOLAR RETURN` coded `m`) must land as `kind:'moment'`, not a person.
- Round-trip an LMT chart and confirm the offset shown on the back/maker's side is the stated one with the `lmt` flag visible.
