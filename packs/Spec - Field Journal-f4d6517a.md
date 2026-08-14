# Spec — the Field Journal (♒ memory as an evidence surface)

*Draft for review, not a build order. Grounds against the current `Orbo Astrolabe.dc.html` (the ♒ **Archive** panel, `_pinMoment`, `_aspectSnapshot`, `_electOutcome`, `memoryItems`), and takes its shape from `archive/Composite Framing v2 2026-07-14.dc.html` — the **Journal** tab there and its ⊕ "log to journal" affordances. This is the foundational surface the `Spec - Field Journal photo recall.md` already presumes exists; photos are a later feed into the same store.*

---

## The frame
The Field Journal is the **read-form of ♒ memory** — authored meaning pinned to moments. Today the ♒ Archive is a *list of pins*; the Field Journal is the same store grown into the thing Composite Framing v2 called it: **how the theory eats evidence.** You log what actually happened, and the sky as it stood comes attached automatically.

This is entirely **moon → memory**. The instrument (the sun) does not change; the Field Journal is a way of *looking* and *keeping*, and it lives where you already pin — from wherever you're reading.

**The astrolabe's own twist on the CF v2 idea:** the electional engine already writes a *predicted* verdict onto every pin (`_electOutcome` → the Moon's next perfection). The Field Journal adds the *felt* result. Over a life the ♒ spine accumulates **predicted-vs-felt pairs** — the instrument's calibration data, not just a diary. That is the astrolabe form of "eating evidence."

## What it is (the pattern, borrowed from Composite Framing v2)
- Every ♒ entry can carry, beyond its name: a **kind/activity** (what the moment *was*), a **rating** (how it landed), a **note**, and an **auto-attached snapshot** of the sky's standings at that jd.
- A **⊕ "log" affordance** sits next to readable things across the moon views — an aspect, a transit row, a timing window, a ZR period. One tap mints a ♒ entry pre-filled with that thing's conditions; you add the rating and the note.
- The Archive panel becomes the Field Journal: a draft row on top, then the kept entries, each showing its snapshot and note, editable and deletable, tap-to-travel to its date (existing behavior).

---

## Hard law — state before any code
1. **Local-only, same as today.** ♒ memory persists in `localStorage` (the `memory` array under the app's saved blob). Nothing new leaves the device. The Field Journal adds fields to existing entries; it does not add a backend.
2. **The instrument is untouched.** No ⊕, no rating, no journal chrome lands on the front/plate. Logging is a moon-side act; affordances appear only in the pull-up reading surfaces.
3. **The snapshot is frozen, the reading is live.** `asp` / `outcome` are captured **at pin time** and stored verbatim (they already are). Re-opening an entry never re-decodes and silently rewrites what you logged — the whole point of evidence is that it doesn't move. (Contrast the fast-hand rulers, which are always live and never materialized.)
4. **Additive migration.** Old pins (no `kind`, no `rating`) render exactly as before; new fields default empty. The lazy `outcome` backfill already in `memoryItems` is the precedent — follow it.

---

## What already exists — consume, don't rebuild

- **The ♒ store.** `state.memory` — array of pinned entries, each a full sequenced record: `{ jd, kind:'event', subtype:'pin', whenStr, name, note:'', asp:[…snapshot strings…], outcome, sequence, … }`. Persisted via `_persist({ memory })`. **The `note` field already exists and is already empty — the Field Journal is largely giving it, plus a rating and a kind, a real UI.**
- **`_pinMoment(label)` / `_saveChart('event','…','pin')`** — the two entry points that mint a pin from where you're reading. Both already stamp `asp` and `outcome`. This is the "log" verb; the ⊕ affordances are new callers of the same path with a richer pre-fill.
- **`_aspectSnapshot()`** — freezes the sky's standings at `this.jd` as up to 8 glyph strings (sky×sky over the active bodies, then sky×natal over `_natalTargets()`, nearest-orb first). This IS the CF v2 "snapshot" line, already built. Every pin carries it.
- **`_electOutcome(jd)`** — the Moon's next perfection from the pinned jd: the classical *predicted* verdict, lazily backfilled onto older pins in `memoryItems`. This is the "predicted" half of the calibration pair.
- **`memoryItems`** (renderVals) + the **Archive panel** (`pMemory`, lines ~615-641) — the current read-form: when · name · snapshot · tap-to-travel (`go`) · export-to-cal (`cal`) · delete (`del`). The Field Journal extends this row, it doesn't replace it.
- **The `♒` pin control** on the pull-up sheet (`pinSheet` / `pinLabel` "pin ♒" → "kept ♒"; `ptPin` on the point inspector). The gesture and its flash already exist.
- **Taxonomy.** `SUBTYPES.event` already lists `pin · ♒`; the "kind/activity" field can reuse or extend this vocabulary rather than inventing a parallel one (**decide** — see open questions).
- **`_almBeads`** — ♒ pins already surface on the almanac spine as beads. Journal entries stay in sync there for free.
- **Depth-of-information law.** Plain / studied / scholarly is a property of moonlight; the Field Journal's snapshot detail should honor `state.depth` (plain = the headline contact, scholarly = the full 8-line snapshot), not invent its own verbosity control.

**Gaps (small builds, flag them):**
- **Entry fields.** Add `kind`/`activity` and `rating` to the pin record (both optional). Extend `_pinMoment` / the save path to accept them; default empty.
- **The draft form.** A compose row in the Archive panel (kind select · star rating · note textarea · Save/Cancel), mirroring CF v2's `journalDraft`. Currently pins are name-only.
- **The ⊕ affordance** on moon-view rows (`evRow` in the almanac, the aspects grid, transit ledger, timing/ZR windows). Each needs a "log this" handler that pre-fills a draft with that row's label as `name`, its conditions as (or alongside) the snapshot, and opens the Field Journal.
- **Note editing.** Today `note` is set once and never edited from the UI. The Field Journal needs an inline edit on kept entries.
- **Suggested → journal.** Optional: CF v2's "sent → journal" pattern — an entry pre-drafted from a strong reading (a peak, an exact transit) offered for keeping. Nice-to-have, not core.

---

## Data model (extend, don't replace)

```
MemoryEntry {              // existing pin record — new fields are additive & optional
  jd, subtype:'pin',
  whenStr, name,           // existing
  note,                    // existing but UI-less today → gets a real editor
  asp: [snapshot…],        // existing — the frozen sky (honor `depth` on render)
  outcome,                 // existing — the PREDICTED verdict (Moon's next perfection)
  sequence, …,             // existing genome ride-along

  kind?,                   // NEW: what the moment was — reuse SUBTYPES.event or a small set
  rating?,                 // NEW: how it landed — 1-5 (the "felt" half of the pair)
  source?: 'pin'|'log'|'photo',  // NEW: which affordance minted it (photo = the later spec)
   from?,                  // NEW (for ⊕ logs): the row/reading it was logged from
}
```
- `rating` × `outcome` is the calibration pair. Surface both on the entry so a scan of the Archive reads as *predicted vs. felt*.
- `source` distinguishes a deliberate pin from a one-tap ⊕ log from an involuntary photo entry (the photo spec's feed) — same store, keyed the same way.

## The evidence loop (the CF v2 core, ported)

1. **Log.** From any moon view, ⊕ (or the existing pin ♒) mints a draft: `name` and snapshot pre-filled, cursor in the note.
2. **Rate + note.** Kind select, 1-5 stars ("how it landed"), free note ("what happened"). Save → `_persist`.
3. **Keep.** The entry lands in ♒ with its frozen snapshot and its predicted `outcome`, sorted onto the spine, beaded onto the almanac.
4. **Read back.** The Field Journal panel lists entries newest-relevant first; each shows when · kind · stars · snapshot (at current depth) · note, with edit/delete and tap-to-travel. The theory eats evidence: over time you can filter to a signature (e.g. all Saturn-square-Venus pins) and read felt-vs-predicted across occurrences.

## Surfaces (all moon-side)

- **Archive panel → Field Journal.** The primary home (`pMemory`). Draft compose row on top; kept entries below with the new fields; the existing empty-state copy grows into CF v2's line ("…log real interactions and their outcomes, and the sky comes attached automatically").
- **⊕ on reading rows.** `evRow` (almanac), the aspects grid, the transit ledger, timing/ZR windows each gain a quiet ⊕ that logs that row with its conditions. This is the CF v2 "click ⊕ next to any aspect or timing window" behavior, mapped onto the astrolabe's moon views.
- **The pull-up pin (existing).** "pin ♒" stays; it now opens the draft (or logs silently, then offers to annotate — **decide**).
- **Almanac beads (existing).** Journal entries already bead; no new work, but confirm the richer entries still render their bead label cleanly.

## Relationship to the photo-recall spec
`Spec - Field Journal photo recall.md` is **Direction A/B on top of this store**: a photo is an involuntary `source:'photo'` entry, decoded to the same `asp`-style snapshot and keyed to the same spine. Build this first — the store's fields (`source`, snapshot, kind) are exactly what that spec reads. Nothing here blocks on photos; photos block on this.

## Still open (your call before code)
1. **Kind vocabulary.** Reuse `SUBTYPES.event` (lunation/return/election/…/pin) as the activity list, or a separate small "what was this" set (meeting / decision / event / feeling / …)? The CF v2 list was social-activity flavored; the astrolabe's is chart-flavored — they may not be the same axis.
2. **Rating semantics.** Neutral 1-5 stars, or a signed scale (−2…+2, "went against me / for me") that reads more naturally against a predicted `outcome`?
3. **Pin gesture.** Does "pin ♒" still log silently-with-flash (fast, current behavior) and *offer* annotation, or does it now always open the draft (slower, richer)? I lean: silent pin stays instant; ⊕ opens the draft.
4. **Where ⊕ lives.** All four moon views at once, or start with the almanac `evRow` (highest traffic) and the aspects grid?
5. **Depth coupling.** Snapshot shows the headline contact at *plain* and the full 8 at *scholarly* — confirm the Field Journal reads `state.depth` rather than carrying its own toggle.
6. **Filter/scan.** Ship a signature filter now (group entries by `asp` signature to read felt-vs-predicted across occurrences), or land logging first and add the scan later?

## Verification
- A pin from the pull-up sheet still logs instantly with its snapshot; old pins render unchanged (no `kind`/`rating` → no new chrome).
- ⊕ on an almanac row opens a draft whose `name` is that row's label and whose snapshot matches `_aspectSnapshot()` at that jd; Save persists; reload restores it.
- Editing a kept entry's note and rating persists; the frozen `asp`/`outcome` are **not** re-decoded on edit.
- An entry carries both `outcome` (predicted) and `rating` (felt); the Archive row shows both.
- Depth = plain shows one snapshot line; scholarly shows the full set — same entry, no re-pin.
- No image bytes, no network calls (the photo feed's law holds here too, pre-emptively).
- Journal entries still bead correctly on the almanac spine.
