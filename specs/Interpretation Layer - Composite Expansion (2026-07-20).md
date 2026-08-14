# Interpretation Layer — Composite Expansion
*Spec, 2026-07-20. Scope: placements only (sign + house). Aspect-based readings are explicitly out of scope — see "Excluded" below.*

## Goal
Extend the Eclipse-tier interpretation reading (currently natal-only) to cover composite charts: Natal Composite (`compAB`, minted A+B) and Synchronic Composite (`compLive`, the live you×now plate). Also extend natal itself with two domains whose content is already in hand but not yet ingested (house×sign, transit×house).

## Excluded from this pass
Every aspect-based reading (natal aspects, composite-to-composite aspects, transit-to-natal/composite aspects). The source CSVs bundle conjunction/soft/hard into one untearable prose block per planet pair — no clean per-flavor key exists yet. Leave all aspect content out until that's resolved.

## Domain map (v1, placements only)

| Domain | Key shape | Content status |
|---|---|---|
| Natal planet × sign | `natal.{planet}.sign.{sign}` | in pack (partial — Venus/Mars done) |
| Natal planet × house | `natal.{planet}.house.{n}` | in pack (partial) |
| Natal house × sign | `natal.house.{n}.sign.{sign}` | content in hand, not ingested |
| Transit planet × natal house | `transit.{planet}.house.{n}` | content in hand, not ingested |
| Composite planet × sign | `composite.{planet}.sign.{sign}` | not yet supplied |
| Composite planet × house | `composite.{planet}.house.{n}` | content in hand, not ingested |
| Composite house × sign | `composite.house.{n}.sign.{sign}` | content in hand, not ingested |
| Transit planet × composite house | `transit.{planet}.composite.house.{n}` | content in hand, not ingested |

## What's reusable as-is
- **Eclipse UI/state machine** — detents, pager, gold rim, `_eRead`/`_eIdx`/`_eCur`, swipe, dots. It only consumes an ordered reading array + attribution string; it doesn't know or care what chart type produced it. No changes needed.
- **`packs/interp.js` resolver shape** — sign-then-house ordered array, `{placement, layer, text}` entry shape. Reusable verbatim for every new domain; only needs a domain parameter added.
- **`_sheetDataNatal`** as the template to clone for the new composite single-body sheet — same shape (signif rows, signName, houseNum, motion, toYou, aspects, "frozen paper" pattern).

## The real gap
No composite single-body sheet exists today. Composite currently has:
- `_sheetDataPlate` / `_specRows` — whole-chart table, all bodies at once, no single-body drill-down, no signName/houseNum per body.
- `_sheetDataCompSyn` — pairwise aspect list vs natal/day (the aspect domain being excluded here).

Neither produces the single-body `{signName, houseNum}` shape the eclipse gate needs. The held-bead long-press path already has a comment marking "composite reading goes here," but its guard clause currently **excludes** held beads — tap/hold-to-read on a composite bead isn't wired at all.

## Build phases

**Phase A — namespace migration** (mechanical)
- Prefix existing pack keys: `jupiter.house.1` → `natal.jupiter.house.1`, etc.
- Update `readingsFor(pack, domain, planet, signName, houseNum)` — add the `domain` param.
- Regenerate `dark-pixie.browser.js`.

**Phase B — ingest in-hand content** (mechanical, partially blocked)
- Parse confirmed CSVs into: `natal.house.{n}.sign.*`, `transit.{planet}.house.*` (natal), `composite.{planet}.house.*`, `composite.house.{n}.sign.*`, `transit.{planet}.composite.house.*`.
- Still missing: composite planet×sign CSVs.

**Phase C — composite single-body sheet** (the real build)
- New `_sheetDataCompositeBody(name, kind)` mirroring `_sheetDataNatal`.
  - `kind: 'ab'` → reads `this.compAB` + its `cASC` (Natal Composite, minted, frozen).
  - `kind: 'live'` → reads `_plateChart()`'s posMap + ascLon (Synchronic Composite, live).
- House/sign reckoned from the composite chart's own ascendant (`cASC`), matching how the Dark Pixie prose describes "the composite 1st house" as the composite's own houses, not natal's.
- Wire into `_sheetData` dispatch and into the held-bead long-press path (currently excludes beads — remove that exclusion for this case).

**Phase D — gate + resolve** (small, mirrors existing code)
- Replace the `sd.natal` boolean check at the eclipse gate (`_eRead` computation) with a generic `sd.domain` string, so natal and composite both flow through the same `readingsFor(pack, sd.domain, sd.name, sd.signName, sd.houseNum)` call.

## Sequencing recommendation
1. **Natal Composite (`compAB`) first** — frozen once minted, same stability as natal, so Phase C is simplest here. Content (planet×house, house×sign) already in hand for house 1.
2. **Synchronic Composite (live plate) second** — once transit-to-composite content is more complete. Reuses the same Phase C code path with `kind: 'live'`; the existing sheet-refresh hook already re-reads live state each tick, so no new freezing logic is needed.

## Open items before build
- Composite planet×sign CSVs (Sun–Pluto).
- Confirm natal house×sign / transit×house CSVs follow the same hub-file shape as composite (multiple domains per file, split by internal section headers) — expected, not yet verified for every house.
- Any additional progressed-planet content, if in scope later, follows the identical pattern once/if delivered.
