# Orbo AstroLabe — Version Notes v0.86 (July 28, 2026)

**Phase 2 — the depth ladder, complete.** All five steps of `specs/Phase 2 Handoff.md` are in.
No instrument changes; the sun is untouched throughout. Every change lands on moonlight (readouts,
the pane, Orbo's voice) or in state.

Snapshot before this work: `archive/Orbo Astrolabe 2026-07-28d.dc.html`.

---

## The depth contract (step 1)

Depth is **inference distance from the sky**, not three levels of jargon. L1 what is · L2 what it
belongs to · L3 what it derives.

Three doors, in one place, above `_snapshotLines`:

- `_depthRank()` → `1|2|3` — promoted out of the Orbo section; the duplicate accessor is gone.
- `_atLeast(d)` — for single fields.
- `_atDepth(rows)` — **filters** a row list. Rows above the floor are *removed*, not
  annotated-and-hidden, so no producer can leak an L3 value into the DOM where a screenshot or an
  export would pick it up.

The ladder is **cumulative** (`<=`, never `===`) and **additive-only** — turning the dial up only
ever adds rows. **Absent `d` means L1**, so producers migrate one at a time.

All six ad-hoc `!== 'plain'` string comparisons collapsed into the doors: transit gloss, aspect
harmony, applying/separating, election top + trace, and both `_snapshotLines` call sites.

## Co-rulership (step 2)

`CO_RULER` — Scorpio→Pluto, Aquarius→Uranus, Pisces→Neptune — is a **sibling table, never a merge**.
Display only: `_lordOf(sg)` returns the traditional lord separately so a caller needing the one
*countable* lord never unpicks a label. `RULER_BY_SIGN` alone still feeds dignity scoring,
disposition chains, the rules-houses loops, ZR period lengths and the election engine.

The **ruler / dispositor split**, at all three body-reading sites:

| row | rank | reads |
|---|---|---|
| `ruler` | L2 | *♂ Mars · with ♇ Pluto* — one step, no chain |
| `dispositor` | L3 | the lord's own placement — the first link of a chain |
| `co-ruler` | L3 | names the modern attribution, and that it isn't counted |

A Scorpio rising now reads *Mars · with Pluto* **at the default depth**, without touching the dial.

## Lineage on its row (step 3)

`lin` renders whenever **its own row** renders — gated by `r.lin`, never by a depth flag.
`depthScholarly` is retired from the template; its six gates now ask `showDoctrine`
(`_atLeast(3)`).

**The honesty line is no longer depth-gated.** "Computed symbolism, faithfully traditional — not
validated prediction" was previously visible only at *scholarly*, i.e. shown to exactly the readers
least able to supply it themselves. It is now unconditional (`sheetHonesty`) on the four sheets that
carried it. Doctrine provenance (Lilly orbs, Valens periods, Egyptian bounds) stays L3 — that
genuinely is inference distance.

## The producers (step 4)

| producer | change |
|---|---|
| `_signifRows` | sign L1 · dignity/ruler/house L2 · dispositor/co-ruler/rules-houses L3 |
| `_motionRows` | ephemeris fact throughout; the derived-point `note` is L2 |
| `_sheetDataNatal` · `_sheetDataCompositeBody` | house L2; both filter their `signif` |
| `_specRows` (the ledger) | **the column count follows the dial** — hse L2, dispositor L3 |
| ♋ Moon panel | VoC + mansion L3, with their lineage beneath them |
| rising lord | the window stays L2; only its scored **condition** is L3 |
| election | `top` factors and the derivation trace are both L3 |
| `_snapshotLines` | ranks instead of counting |

Two notes on the harder calls:

**`dignity` was mis-ranked and the suite caught it.** It carried no `d`, and absent `d` means L1 —
so essential dignity was rendering at the positional level. Fixed to L2. It surfaced only because
the suite asserts the L1 set *exactly* rather than checking that expected rows are present.

**The journal snapshot no longer treats volume as depth.** A pin keeps every contact it froze; what
depth changes is how many are *shown*, by rank — tightest contact is the headline (L1), the next two
context (L2), the tail the full web (L3). The same 1/3/8 as before, now derived rather than
asserted, and the frozen array is never mutated, so moving the dial back returns all eight.

**Aspect rows are not rank-gated at all.** Which aspects are listed is a display choice owned by the
♍ toggles. A septile is not a harder *idea* than a trine; it is a narrower one. What ladders is the
*conceptual overlay* on a contact — applying/separating, harmony, the gloss.

## Doctrine + the dial (step 5)

`state.doctrine` holds the six places Orbo has to pick a school: sect rule, lot source, ZR start
lot, peak definition, profection year-start, progressed-angle method. `_doc(k)` is the only reader,
`_setDoctrine(k, v)` the only writer, `_doctrineKey()` a fixed-order six-position signature for memo
keys and lineage fingerprints.

**Migration is additive.** A session saved before `doctrine` existed reads its `zrLot`/`zrPeakDef`
through `_doc`'s legacy fallback and gets a *correct* key on its first render — not the default one
after the next write. The loose keys keep being mirrored on persist for one release, so a rollback
doesn't silently reset a maker's choice.

**The dial moved ♋ → Orbo.** Depth is a property of moonlight, so it never belonged to the Moon
*panel* — that panel is one reading among many. It sits at the foot of Orbo's panel above his input,
headed "how far I go", with a line per rung in his voice. The orientation seeds it from the one real
signal that exists (`_onbTourChoose`: walk-me-through → plain, let-me-explore → studied); a seed,
never a lock — `depthSeeded` retires on any manual pick.

---

## Fixed along the way

- **The ZR memo keyed on natal JD alone.** Correct while doctrine was inert, but `lots`
  (pauline/hermetic) reaches `computeLots`, so switching lot source would have shown stale lots
  until the natal changed. The key now includes `_doctrineKey()`.
- **Election `top` was superseded, not added to.** It was shown only at *studied*, so scholarly
  *replaced* it with the derivation trace. Both are L3 now and stack.

## Tests

`tests/depth-contract.test.html` — a new harness that extracts the DC's logic class, evaluates it
against stub `DCLogic`/`React`, and probes the prototype on a hand-built instance (no canvas, no
RAF, no pack load). **41 assertions, all green**, covering manifest acceptance tests 1–6 and 9.

Every rule carries **both halves** — the presence assertion *and* the absence assertion — per the
lesson from the corpus pass: *the lineage law passes vacuously when a technique is mis-ranked out of
L3*. So the suite asserts the L1 set exactly, that no L1/L2 row carries a lineage it hasn't earned,
that the L3 set is non-empty before asserting every L3 row has lineage, and that no aspect producer
filters by rank.

The co-rulership boundary has its own test: every `CO_RULER` / `_coRuler` / `_lordOf` mention is
walked back to its enclosing function and asserted to be a display producer — plus the cheapest tell
that the boundary broke, *Sun in Scorpio must read peregrine, not domicile*.

## Known / deferred

- **The preview harness was unresponsive for this whole session** (any page, including a trivial
  one), so the instrument was not visually confirmed. The pre-edit snapshot wedges identically —
  it is the harness, not the app. Worth a look on device.
- **A pre-existing unclosed `sc-if`** (`orboOn`, template line ~177) predates Phase 2. My edits are
  balanced; the suite asserts that imbalance is *unchanged* rather than absorbing it.
- **ZR rows are not individually rank-tagged.** The manifest ranks ZR L3 in its entirety, but it is
  an explicitly-opened lens, and filtering it would empty a lens the native asked for (acceptance
  test 9). Its provenance is carried at sheet level instead. Flagged for `[O]`.
- **Doctrine's four non-ZR fields have no UI** — sect rule, lot source, year-start, progressed
  angle sit at their defaults. Per the 7/28 decision these controls live in the **Orbo panel only**,
  never a ♑ Gears tabula section.
- **The orientation's depth question** is seeded from the existing tour/explore choice. A dedicated
  familiarity question ("I'm just starting out" / "I know my chart" / "I read traditionally") is a
  copy decision, deliberately not invented here.
- Backlog, unchanged: byline law on the eclipse tier's other pack surfaces · generator
  colon-terminated headers + re-ingest · the Orbo byline rect's position vs. the pinned input row.
