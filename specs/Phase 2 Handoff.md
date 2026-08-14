# Phase 2 — handoff prompt for a new chat

*Paste the block below as the first message of a fresh chat. Everything above the line is context for
whoever is pasting; the prompt itself starts at **BEGIN PROMPT**.*

Why a new chat: the corpus session ran long (47 CSV ingests, three verifier rounds). Nothing about that
work needs to stay in context — it all landed in files. The decisions are recorded in
`specs/Depth Manifest.md`, the code is in the pack + `packs/interp.js`, and the tests are in
`tests/explain-corpus.test.html`. A fresh chat with the prompt below has everything it needs.

---

## BEGIN PROMPT

Pick up **Phase 2 of Orbo — the depth ladder**. Read these first, in order:

1. `CLAUDE.md` — the project laws (TimeSpine, sun/moon, presentation clock, standalone export).
2. `specs/Depth Manifest.md` — **the spec for this phase.** Every readout row ranked L1/L2/L3 with its
   lineage label, plus the co-rulership law's display/computation boundary and the byline law.
3. `specs/Orbo Plan 2026-07-26.md` § Phase 2 — the original brief. Where it conflicts with the
   manifest, **the manifest wins** (it resolved two contradictions and three later decisions).
4. `specs/Phase 3 - Lunar Surface Build Plan.md` § 3 (C2) — the one downstream dependency.

Do not re-read the DPA source CSVs in `uploads/`. That ingest is done and shipped.

### What is already built (verify, don't rebuild)

- **The explain corpus.** 520 entries in `packs/dark-pixie.pack.json` (1,396 total; the original 876
  placement readings untouched). Every entry carries `{depth, lineage, doctrine}`.
- **The resolver.** `explainFor` / `explainAll` / `explainByAngle` / `explainSearch` / `hasExplain` /
  `attributionOf` in `packs/interp.js`, mirrored into the generated `dark-pixie.browser.js`.
  Regenerate the browser build from the `.js` after any change — and write the pack and the browser
  build in **separate passes**, they stall the commit together.
- **Orbo's Ask is wired.** Two corpora in order (strong corpus hit → instrument glossary → weak corpus
  hit → live reading), depth-gated, with the hyperlinked byline, the modern-rulers doctrine note, and
  a named pointer when a hit sits above the native's depth.
- **`tests/explain-corpus.test.html`** — 26 assertions. Run it before and after; it must stay green.

### What Phase 2 still needs (verified absent in the DC as of 2026-07-28)

`_atDepth` does not exist. `_depthRank()` exists at 5415 but is scoped to Orbo's Ask. No `CO_RULER`.
No `state.doctrine`. All six ad-hoc depth checks still scattered (2929, 3166, 3168, 3427, 3828/3854).
Row producers still push `{k,v}` with no `d`/`lin`. The dial is still in ♋ (template 447–451).
`depthSrc`/lineage still gated on `depthScholarly` (1270, 1324, 1473). `_snapshotLines` (2374) still
counts contacts instead of ranking them.

**Snapshot `archive/Orbo Astrolabe 2026-07-28d.dc.html` before the first edit** (project convention:
one working file, snapshot before significant revisions).

### Order of work

1. **The contract.** Promote `_depthRank()` out of the Orbo section to a general accessor — **do not add
   a second `_depth()`**; two accessors for one dial is what produced the scattered checks. Add
   `_atDepth(rows)` beside it; **it filters** (removes rows above rank, does not annotate-and-hide).
   Rows gain optional `d`/`lin`; absent `d` = L1 so producers migrate one at a time. Collapse the six
   ad-hoc checks into the door.
2. **`CO_RULER` + the ruler-row split.** This is the decision the native made in the last session and
   it has not reached the instrument — **their Scorpio rising still reads Mars alone.** Add the sibling
   table (Scorpio→Pluto, Aquarius→Uranus, Pisces→Neptune) consumed by *display* sites only:
   `_specRows` (4510), composite (5773), natal (5886/5894), `_signifRows` (6728–6734). `RULER_BY_SIGN`,
   dignity scoring (6722/6724) and the `rules houses` loops stay **traditional-only** — see the
   manifest's display/computation table for why (chains, ZR period lengths, dignity terms).
   Split the L2 `ruler` row out of the L3 `dispositor` row at all four sites.
   **Acceptance: Scorpio rising reads *Mars · with Pluto* at the default depth.**
3. **Lineage rendering.** `lin` renders on its row at any depth where that row is visible. Demote
   `depthSrc` to the sheet-level honesty line it already is. Behaviour change at 1270/1324/1473.
4. **Apply the manifest**, cheapest proof first: `_signifRows` → `_motionRows` →
   `_moonReadout`/`_vocData`/`_mansionOf` → `_specRows` → ZR/rising/election → almanac/synastry last.
   `_snapshotLines` is the one real rewrite: rank at read time, not at pin time, so existing pins keep
   working and a pinned moment never loses data to a display setting.
5. **The dial moves to Orbo** (not ♑ — the manifest supersedes the plan here) and **doctrine presets**
   land with him: `state.doctrine` absorbing the loose `zrLot`/`zrPeakDef` via an additive migration,
   plus `_doctrineKey()` added now even though nothing reads it until Phase 6 (strand identity is
   `chart × doctrine`; retrofitting it after strands are materialized is expensive).

### Three settled decisions to honour

- **`_atDepth` filters.** Not annotate-and-hide.
- **Aspects are not depth-dependent.** Depth is about complexity of *concepts*, not which aspects are
  drawn. The ♍ toggles own aspect selection; no aspect row is rank-gated. What still ladders is the
  conceptual overlay on a row — applying/separating, harmony, the gloss. A row the native explicitly
  switched on must never be hidden by depth.
- **Depth is Orbo's, and orientation seeds it.** Orbo asks how familiar the native is with astrology
  and sets the level from the answer; the words *plain / studied / scholarly* must not appear in that
  flow — the options read as self-description ("I'm just starting out" / "I know my chart" / "I read
  traditionally"). Afterwards the native changes it by asking Orbo. He should be able to say which
  level he is speaking at.

### Also outstanding, small, can go any time

- The byline law (§8) reaches only Orbo's bubble. The eclipse tier's other pack surfaces still need it.
- Generator gap: colon-terminated headers ("Ruling planets and the natal chart:") aren't detected, so a
  few intro sections merge into their neighbours. Text is present and searchable; sectioning is coarse.
  One pattern in the generator plus a re-ingest.

### How to test

Prefer `tests/explain-corpus.test.html`-style harnesses over screenshots for anything about ranking —
and write **absence tests, not just presence tests**. Two defects last session passed a green suite
because the assertions validated the shape of what was produced, not whether the classification was
right: a mis-ranked entry made "every L3 has a lineage" pass *vacuously*, and a wrong lineage label
asserted a false provenance. For each new depth rule, assert both that the right rows appear **and**
that nothing landed on the wrong rung.

Do not code until you have read the manifest and confirmed the absent list above against the current
file — line numbers drift.

## END PROMPT
