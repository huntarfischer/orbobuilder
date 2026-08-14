# Orbo AstroLabe — Version Notes v0.83 (July 21, 2026)

## Shipped this pass — Interpretation Layer: Composite Expansion (placements only)
Per `uploads/Interpretation Layer - Composite Expansion (2026-07-20).md`. Aspect-based readings remain **out of scope** (the source CSVs bundle conjunction/soft/hard into one untearable block — no clean per-flavor key yet).

### The pack — 228 → 876 entries (`packs/dark-pixie.pack.json`)
- **Phase A — namespace migration.** Every existing key prefixed `natal.*` (`jupiter.house.1` → `natal.jupiter.house.1`). All 228 natal planet×sign / planet×house entries preserved verbatim.
- **Phase B — ingested all in-hand content** (648 new entries), each parsed from the Dark Pixie hub CSVs by internal section header:
  - `composite.house.{n}.sign.{sign}` — 144 (12×12)
  - `natal.house.{n}.sign.{sign}` — 144 (12×12)
  - `composite.{planet}.house.{n}` — 120 (from the clean per-planet "Composite {Planet} in the Houses" files, not the redundant house-file fragments)
  - `transit.{planet}.composite.house.{n}` — 120
  - `transit.{planet}.house.{n}` — 120
- **Still the one coverage gap:** composite **planet×sign** (Sun–Pluto) — no source content exists yet. A composite body reading therefore honestly surfaces only its house layer.
- Multi-paragraph readings are stored with `\n\n` breaks and render as paragraphs (eclipse text div now `white-space: pre-line`).

### The resolver (`packs/interp.js` + generated `dark-pixie.browser.js`)
- New signature: **`readingsFor(pack, domain, planet, signName, houseNum)`**. Domains: `natal`, `composite`, `transit`, `transit.composite`.
- Body reading = sign layer then house layer, both domain-prefixed.
- The **Ascendant** ('As') carries no planet keys — its reading *is* the 1st-house-in-sign entry, so it resolves `{domain}.house.1.sign.{sign}` (gives natal + composite ascendants a real reading for the first time).
- Transit domains resolve the house layer only (a transit has no natal sign): `transit` → natal houses, `transit.composite` → composite houses.
- Missing layers are simply absent — honest gap, never a placeholder.

### The instrument (`Orbo Astrolabe.dc.html`)
- **`_sheetDataCompositeBody(name, kind)`** — the composite analogue of `_sheetDataNatal`. `kind:'ab'` reads the minted Natal Composite (`this.compAB` + its `cASC`, frozen); `kind:'live'` reads the Synchronic Composite (the live you×now plate, `this.comp`). House/sign reckoned from the composite's **own** ascendant (cASC), matching how the prose means "the composite Nth house."
- Wired in four places: the generic eclipse gate (now keys off **`sd.domain`**, not the old `sd.natal` boolean, so natal + composite + transit flow through one `readingsFor` call); composite plate rows are now **tappable** (`'composite'` short → 'ab', `'synchronic'` → 'live'); the **held-bead long-press** path opens the synchronic composite body reading (was excluded); and the live sheet-refresh hook rebuilds composite/transit sheets each tick.
- **Live transit body readings**: tapping a live sky/plate body reads it through the *seated chart's* houses — natal houses when natal is on the plate, composite houses when a composite is engaged; recomputes live; no seated chart = no reading.

### Discipline checks (audited)
- **Spine law (July 12)** held: the new readers consume only already-decoded state (`compAB`, `comp`, memoized `_natal()`, the plate's own cursor sample) — **zero** new `eph.positions/angles` or `spine.at/posAt/probe` calls, so the refresh hook adds no sky cost. Composite element is sign-derived (`ELEM_NAME`), consistent with how `_specRows` treats epoch-less midpoints.
- **Attribution** single-source: every reading flows through `eclipseAttribution = pack.attribution` = "The Dark Pixie Astrology"; all 648 new entries came from Dark Pixie CSVs.

### Boot fix
- A transit-block edit had been written as one physical line with literal `\n` escapes, so `//` commented out its own `return` → `logic class eval FAILED: unexpected token ':'` (the v0.82 red banner). Re-expanded to real newlines; logic parses clean and the instrument boots.

---

## Roadmap — pick up in the morning (sequenced by dependency)
Do in this order; each rests on the one before.

**2. solo-chart-and-frame-spec** — foundational instrument change: 3rd frame, conditional plate/rete, swap control, badges. Aspect lines and both composite specs below all touch the plate/rete state this introduces, so it goes first.

**3. aspect-line-depth-spec** — its "6 line families" include the plate / B-plate thread families that #2 makes conditional. Do right after #2 so z-order/shading isn't re-derived against a plate model that's about to change.

**4. Ledger Tabula Spec** — retires the single `abComposite` slot for a **roster-based Minted Composite**. Data-model foundation; do before #5 so composite reading is built against the final structure, not the slot about to be retired.

**5. Interpretation Layer – Composite Expansion** (this pass, to be re-based) — needs #4's roster-based composites to read against, and #2's plate/rete for two-chart states. The placements engine shipped above already reads from `this.compAB` / the live plate; once #4 lands, re-point `_sheetDataCompositeBody('ab', …)` at the roster's minted composite instead of the retired slot. Then the still-open items: composite planet×sign content (when supplied) and, optionally, surfacing the transit×house data (ingested, reader-wired) more prominently.

### Note on current coupling
`_sheetDataCompositeBody(kind:'ab')` currently reads `this.compAB` + `this.state.abWith` — the very slot the Ledger Tabula spec (#4) retires. Expect to re-point it during #4; the `'live'` path (synchronic) is unaffected.
