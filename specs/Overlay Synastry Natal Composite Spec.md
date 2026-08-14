# ♓ Reconciliation — Overlay / Synastry / Natal Composite / Transits

## The unification (supersedes the five-sibling draft)
Overlay, Synastry, and Transits are not separate readings to choose between. They're the
automatic sun/moon consequence of two existing choices that already exist in the app:

- **The plate** ("who is read") — Natal me | Composite me (Synchronic) | Natal Composite
  (me+B, once minted at ♎) — an extensible list of single-chart subjects.
- **The rete** ("who acts") — The sky (live transits) | No one (solo) | a seated person from
  the ♎ roster (today shown frozen at their natal moment).

Given those two picks, the astrolabe and its moon panel behave automatically:
- **rete = No one** → wheel draws the plate chart solo (+ natal-ghost/contact overlay if the
  plate is Composite me, per the existing wheel vocabulary). Panel shows that chart's own
  ledger (dispositor/house table) — no aspects, because nothing else is acting.
- **rete = The sky** → wheel draws the plate chart with live sky in motion around it (today's
  default view). Panel shows the timed aspect ledger between sky and plate — this is
  **Transits**, generalized: sky × natal, sky × Composite me, or sky × Natal Composite are all
  the same mechanism, just a different plate occupant.
- **rete = a person** → wheel draws two full rings stacked — this is **Overlay**, the default
  visual whenever a second chart is present, unaspected geometry only. Panel shows the timed
  aspect ledger between the two charts — this is **Synastry**, the automatic interpretation of
  that same picture. Per the Intersections Spec, each side (plate's chart, rete's seated
  person) can independently be that person's natal or their own Synchronic Composite — four
  combinations, one mechanism.

So there is no "five-sibling nav" to design. ♓ stays exactly what it already is — the solo
plate-framing toggle (Natal me ⟷ Composite me) plus Composite Chronology — because plate
choice already happens there and at the Plate card; nothing new needs to live under ♓ itself.
Overlay/Synastry/Transits aren't menu items anywhere — they're what the wheel and panel
already do the instant plate + rete are both populated.

## Vocabulary (locked)
- **Synchronic Composite** — one person's natal ⊕ *this instant*. Time-fused, solo by nature.
  Today's "Composite me" plate option, each independent side of a paired reading, and the
  whole My Timing engine (cASC arc, variable ruler, inherited retrograde). Bare "composite" in
  older copy defaults to this sense.
- **Natal Composite** — midpoint of two people's natal charts (classic technique). Time-
  independent, no jd term. A plate occupant like any other once minted, with its own ledger
  (BODY/COMPOSITE/HSE/DISP — the screenshot table). Today's `abComposite`/`abWith`; mints via
  the ♎ roster per the existing footer copy ("person composites mint on the ♎ roster").
- **the plate / the rete** — current in-app terms, kept as-is ("who is read" / "who acts").
  Not symmetric today (plate = engraved subject, rete = live actor), but the list of what can
  occupy each side should keep growing on both — worth revisiting once Natal Composite can
  also act as a rete occupant (e.g. transiting *someone else's* Natal Composite), not bundled
  into this pass.

## Wheel content (solo Synchronic Composite, unchanged, confirmed by reference)
- **composite (live)** — solid ring, the moving Synchronic Composite positions.
- **natal ghost** — faint reference ring at natal positions, showing drift from birth.
- **arc bounds** — the 180° limit (natal ASC ± 90°) the cASC needle ranges over.
- **cASC needle + daily sweep band** — the moving composite-ASC point and its daily sweep.
- **composite → natal contact** — dashed line from each live planet back to its natal degree.
All instrument (sun) content — geometry and motion, no interpretation.

## The pull-up model (LOCKED — this is the real structure)
The pull-up is all moonlight — it reads what's on the instrument. Everything it can say falls
into exactly three registers, and A and B *are the two wheels*:

- **A · the plate wheel, in itself** — the specifics table (BODY/[chart]/HSE/DISP) for
  whatever's engraved on the plate. This is the **default face**: open the pull-up on any
  config and you land here; switch the plate on the main page and this face re-renders to the
  new chart. This resolves the old "where's the info for the chart I switched to" gap — that
  table already exists in code (currently flagged under `sheetSynastry`) but had no proper
  home. Now it is the home.
- **B · the rete wheel, in itself** — a **peer tab** beside A. Rete = the sky → full current
  sky positions (answers "where is a planet right now," not just the header big-three). Rete =
  a seated person → that person's chart specifics. Rete = No one → B is empty, A stands alone.
- **C · the contact between the two wheels** — the aspect layer, and it *follows the rete*, so
  it is never a set of dead tabs you pick between:
  - rete = the sky → **Transits**, with the Moon split into its own cadence (**Lunar**)
    because it fires ~13°/day, far more than everything else combined.
  - rete = a seated person → **Synastry** (interchart aspects; per-side natal ⟷ Synchronic
    switch per Intersections Spec).
  - rete = No one → no contact register at all (nothing is acting).

**Contact-follows-rete law (LOCKED):** you never see "Synastry" while the sky is up or
"Transits" while a person is seated. If you want transits, you put the sky on the rete. This
kills the four-dead-tabs confusion at its root — the ♐ lens shows exactly one contact reading,
determined by the rete.

### By plate occupant (register A + the Transits/Lunar contact when rete = sky)
| plate | A · specifics | Transits (rete=sky) | Lunar (rete=sky) |
|---|---|---|---|
| Natal me | natal positions/houses/dispositors | transits to natal points | Moon transits to natal points (VOC/phase/applying) |
| Synchronic Composite (me) | live composite positions + drift | transits to composite points | Moon transits to composite points |
| Natal Composite (me+B) | the me+B midpoint table (screenshot) | transits to the two-natal composite | Moon transits to composite points |

### By rete occupant (register B + the Synastry contact when rete = person)
| rete | B · specifics | Synastry |
|---|---|---|
| The sky | full current sky positions | — (contact is Transits/Lunar) |
| No one | empty — A stands alone | — (nothing acts) |
| seated person | that person's chart specifics | plate × person, per-side natal ⟷ Synchronic switch (Intersections Spec) |

Aspect ledgers (Transits, Synastry) are timed — exact/was-exact/will-be-exact, orb,
applying/separating — not a flat static grid, per the reference screenshot.

## Depth → a tabula toggle (LOCKED)
Depth (plain/studied/scholarly) stays **global** — one setting the whole instrument honors,
matching today's stored `s.depth`. It **leaves the pull-up**: the `depthChips` row currently
duplicated inside every sheet (transits/lunar/synastry/election) collapses to a single control
that lives on a ring/tabula toggle. It's a property of the reading, set once, not re-offered on
every panel.

## Electional → ♏ Scorpio (LOCKED)
Electional ("Windows"/My Timing) does **not** belong beside the live transits feed — it isn't
"what's touching me now," it's "when is the moment," i.e. the sky-contact register projected
across future time and scored for a purpose. It moves to the **♏ Scorpio tabula**, cohabiting
with Zodiacal Releasing as two timing techniques (fate's clock + choosing the moment). It is
**enabled but not necessarily default** — a lens you switch on for a "when" question, not
ambient. My Timing's internal scoring mechanics remain a separate spec; this only relocates its
home. (Its native plate is still Synchronic Composite for the full cASC engine; classical
electional applies for Natal me / Natal Composite without that layer.)

## Build plan — Opus / Sonnet delegation

The work splits cleanly: **Opus** owns the judgment-heavy, cross-cutting reasoning (anything
where a wrong call quietly breaks the sun/moon law or the register model); **Sonnet** owns the
mechanical, well-bounded refactors once the shape is fixed. Do the Opus items first — they set
the contracts the Sonnet items fill in.

### OPUS (reasoning-heavy — design the contract, then hand off)
1. **Redesign `_restingLens` → the register model.** Today it returns a single sheet id
   (synastry / transits / sky). It must instead resolve to: default face = **A (plate
   specifics)**, with B and the rete-appropriate C available as peer tabs. This is the core
   behavioral change and touches the sun/moon law — Opus writes it.
2. **Design the A/B peer-tab pull-up shell.** How A (plate specifics) and B (rete specifics)
   present as peers, how C (Transits|Lunar OR Synastry) attaches, how switching the plate on
   the main page re-renders A live. Reuse the existing table currently under `sheetSynastry`
   as A's body — Opus decides how it's rehomed without losing the synastry grid.
3. **Wire contact-follows-rete.** The single C reading derives from `s.rete`: sky →
   transits(+lunar split), person → synastry, off → none. Remove any path that shows transits
   while a person is seated or synastry while the sky is up. Opus, because it's the law.
4. **Natal Composite as a plate occupant** (rename target + plate-list entry + its A-face
   ledger + its transits generalization). Opus specs the exact state shape and whether mint
   stays a ritual; Sonnet can execute the rename once that's pinned.

### SONNET (mechanical — bounded, follow the contract Opus sets)
5. **Rename `abComposite`/`abWith` → Natal Composite** across state keys, copy, chip labels,
   persistence (`_persist` back-object), and the ♎ mint flow strings. Pure find-and-adjust;
   no behavior change. Regenerate any affected `*.browser.js` from their `.js` source of truth
   (never hand-edit the browser build — see CLAUDE.md).
6. **Collapse the duplicated `depthChips` blocks.** They repeat in the transits, lunar,
   synastry, and election sheets (lines ~740, ~813, ~866, ~916 and their `depthSrc` siblings).
   Remove all four in-sheet copies; surface one depth control on the tabula toggle Opus
   specifies. Global `s.depth` semantics unchanged.
7. **Relocate electional to ♏.** Move the `election` sheet's entry point out of ♐ and into the
   Scorpio tabula beside Releasing; keep the `_sheetDataElection`/`openElection` machinery,
   just change where it's reached from. Enabled, not default.
8. **Copy pass:** ledger/panel headers read "Transits" when rete=sky, "Synastry" when
   rete=person, generated from the same component per the contact-follows-rete law.

### Sequence
Opus 1→2→3→4 (each unblocks the next), then Sonnet 5–8 in parallel where they don't collide
(5 and 6 are independent; 7 depends on 3's rete logic being in; 8 last, once headers have a
single source). Snapshot `archive/Orbo Astrolabe YYYY-MM-DD.dc.html` before Opus item 1 —
it's a redesign of the pull-up core, exactly the "significant revision" the CLAUDE.md rule
covers.

## Open items (small, non-blocking)
- Exact home of the depth toggle on the ring/tabula (which tabula, what affordance).
- Whether the ♐ entry point (button-hop from ♈ today) should be more direct — deferred.
- Whether Natal Composite can itself occupy the rete (act against another plate) — edge case,
  out of scope for this build.

## Not touched by this spec
ZR reading mechanics, Ammonite timespine, My Timing's internal scoring (separate specs).
