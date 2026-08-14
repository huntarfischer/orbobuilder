# The Lunar Pane Templates — build guide for future surfaces

How to add or edit a surface on the lunar pane (the moon side of Orbo). This is the distilled
contract of Phase 8 (the templates) and Phase 9 (the port). The full reasoning lives in
`specs/Phase 9 - The Lunar Port.md` and the rulings in `CLAUDE.md`; this is the checklist.

## The one sentence
**A reader hands the pass a TICKET; the pass names, checks, credits and lays the bands; the
template renders per-plate row tables inside a shared arrangement.** A reader never writes a
caption, a height, a footer, a provenance string, or band markup of its own.

## 1 · Pick the plate (what a row IS)
One per structural axis — name the axis or it's a field, not a plate:
- **FACT** — a standing fact, no time (`{k, v}`, optional `d` depth, `lin` lineage, `q` qualified value)
- **RELATION** — a fixed contact between two NAMED subjects (`left · mark · right`, optional until/houses/recep)
- **LEDGER** — a dated event, time as a point (`mark · what · when`, optional rate/houses/track)
- **SPAN** — a duration, the only NESTABLE plate (`glyph · level · start · end`, children checked recursively; containment law on the child's START only — Valens overflow is measured, never refused)
- **TRACK** — a quantity against its range (`value · min · max`), only ever NESTED inside a LEDGER/SPAN row; the range is the measurement's, NEVER fitted to the sample set; no doctrinal ceiling → no track
- **PROSE** — a voice on an address; served only as an EXPANSION, inherits its parent row's address

Discriminator RELATION vs LEDGER: a contact that PERFECTS at a moment is LEDGER; a fixed one is
RELATION. Contracts are declared in `Component.ROW_CONTRACTS` and enforced by `_checkRow` —
unlisted fields refuse the row, loudly. Never widen a contract for one build's convenience.

## 2 · Write the ticket (what the reader hands up)
`{ template, subject, rows, doctrine, chips?, empty? }` through `this._pass(...)`.
- **subject** — what is being read (chart/pair/window/stretches…). The caption is DERIVED from it
  (`_capLine`); a ticket carrying `caption`, `name`, `height`, `rows`-inside-subject etc. is
  refused by `SUBJECT_FORBIDDEN`.
- **doctrine** — registry keys, never prose. Empty list refused. Every key must exist in
  `DOCTRINE_CREDITS` (the same key that invalidates the cooler's cache credits the provenance
  band). Credit the two prep benches separately: Connectome for chains/receptions, rulers.js for
  the dignity rungs.
- **houses** — always qualified: `{native, num}` (plus `frame` when synchronic). A bare house
  number refuses the whole ticket, on every plate.
- A refusal renders as the caption (`refused · …`) with the body suppressed — never a half-pane.
  Flip `window.__ORBO_PORT_PROBE = true` (or the `portProbe` tweak) to demonstrate all refusals.

## 3 · Pick the arrangement (how the surface lays rows out)
Declared in `Component.ARRANGEMENT`, read through `_arrangementOf`:
- **A · flat** — caption, table, footers (registers, transits, prog, synastry, cross-approaching, election). Scroll cap 300.
- **B · railed** — a side rail of tabs, always carrying an ALL, `all: true` names which (ZR, almanac). Cap 320.
- **C · stepped** — a day pager with a label (rising, clock, query). Cap 340.

## 4 · Fill the bands (never write band markup)
Each band is ONE piece of markup reading ONE object, MUTATED never replaced, reset beside the
pass and filled from inside your own row builder:
- **caption** — automatic, from the pass (`_portPass` → `_capLine`). You never touch it.
- **blocked** — declare your sheet's reason → text/panel rows in `Component.BLOCKED_SIGNAGE`;
  `_portBlockedFor` renders the dashed box. Never type the box.
- **chips** — `Object.assign(this._portChips, { on: true, items: [...] })` from your builder.
- **stepper** — same, `this._portStep` ({on, label, prev, next}).
- **rail** — same, `this._portRail`; every rail names its ALL tab.
- **footer pair** (doctrine/honesty + provenance) — automatic from the ticket's doctrine keys.
- **signage** — add your sheet's hint rows to `Component.SIGNAGE` (or `SIGNAGE_CROSS` per course);
  muting goes through `_signageMuted`, one greppable place, never a per-sheet `*HintOn` key.
**THE BAND LAW: a band with nothing to show emits nothing** — no spacers, no reserved heights.

## 5 · What is refused outright (the allergies)
No authored caption strings · no per-sheet footer/provenance/blocked/chip/stepper/rail markup ·
no content-length rests (`_eReadLen` is gone; rest is `PLATE_REST` by plate, exceptions by
ARRANGEMENT in `RAISED_ARRANGEMENTS`) · no second refraction path (`framing.refract` only) · no
second scanner · one door per scale (a track's range typed twice WILL disagree) · no invented
horizon for a composite (frame, not place) · no quadrant houses, dignity scores, septile marks,
modern dispositors · signage is the SHEET's fact, never the arrangement's · two meanings never
share one name.

## 6 · Prove it
`tests/lunar-port.test.html` loads the real class out of the DC — half its checks are source
greps (no authored captions, doors reached only through the pass, every doctrine key registered).
Run it after any pane change; a new doctrine key or signage row needs its registry entry or the
greps fail. Every pass ends with measured numbers, never a claim of completion.

## Tweaks (host editor)
The root DC carries three props: `paneDepth` (plain/studied/scholarly override of the depth
dial), `paneSignage` (mute all hint rows), `portProbe` (show every plate's refusal on screen).
Add future pane-wide switches as props here — never as a hand-rolled controls panel.

## Honest ledger of what is NOT unified
The per-sheet ROW TABLES are per PLATE by design (the Phase 7 caption ruling): a handoff card is
not a clock stretch. The LEDGER/SPAN shapers (`_ledger*Rows`, `_span*Rows`) are checked and
credited by the pass while the rich rows still draw the tables — if a future pass ever draws the
tables from the ticket rows directly, the shapers are the door it goes through.
