# Lunar Pane — Delegation Briefs

*2026-07-15. Nine user todos for the pull-up sheet ("the lunar pane"). No code yet at time of
writing; this is the hand-off spec for Opus / Fable / Sonnet. Line anchors are against
`Orbo Astrolabe.dc.html` as of the 2026-07-15 snapshot and will drift as edits land — treat them as
"start here," not gospel.*

---

## 0. Shared context — every agent reads this first

**The sun/moon law (project doctrine).** The astrolabe wheel is the **sun** — it IS the light: the
real geometry of the moment. It does not change; new features never land on the instrument. The
pull-up sheet is the **moon** — it reflects and interprets the light. Every *way of looking* is a moon
view. **All nine todos are moon-side.** Nothing in this batch touches the wheel/`_draw` instrument
geometry. If a task tempts you toward the wheel, stop — you've misread it.

**"The lunar pane" is a rename, not a move (L1).** The user is renaming the pull-up sheet to "the
lunar pane." It behaves *exactly* as today: peeks from the bottom at rest, **rises when called**, and
occludes the wheel as the established eclipse (veil + corona + first-contact flash). **Do not rebuild,
relocate, or dock it differently.** The one conceptual gain from the rename: the pane *reflects the
light of the sun* — so its chrome should increasingly read as the sun's own materials (rete + plate)
reflected onto the moon. That frames Fable's work below.

**The one big idea binding L7/L8 (from the user).** *"We already have the visual language of the rete
and plate on the sun; apply it to the lunar pane — keep the default clutter-free but let the user
customize to their use."* So the pane's navigation becomes two-tier:
- **Primary = the rete** — a left/right **rotating** ring of lens tabs (mimics the moving heaven you
  spin). Clutter-free by default; the user rotates to reach more.
- **Secondary = the plate** — an engraved, "settled" **sub-menu** for the active lens's options.
- **Customization = "Add to lunar pane"** — opt-in lenses (releasing, electional) are pinned onto the
  rete ring from their back-side tabula, so the default stays sparse.

### The nine todos, mapped
| # | User words | Owner |
|---|---|---|
| L1 | moon panel shows at bottom | *(none — rename only; frames Fable)* |
| L2 | planet lettering → element; space house & dispositor | **Sonnet** |
| L3 | "the sky" → full chart (all current positions); drop big three + "tightening now" | **Opus** spec → **Sonnet** build |
| L4 | redundant tab absorbed into transits (= the **lunar** tab) | **Opus** |
| L5 | "releasing" tab toggled on from ♏ tabula ("Add to lunar pane") | **Opus** model → **Sonnet** wire |
| L6 | same for electional | **Opus** model → **Sonnet** wire |
| L7 | left/right **rotating** menu mimics the rete | **Fable** |
| L8 | secondary items on a **sub-menu** mimics the plate | **Fable** |
| L9 | legibility pass — brighten the text | **Sonnet** |

### Code map (the surfaces these touch)
- **The pane container + eclipse:** `sheetTf`/`eclipseVeil`/`coronaUp`/`sheetRisen` (~1846–1851).
  Rise behavior — leave alone.
- **The lens menu (today = static arced fan):** template `viewChips`/`viewArcOn` loop, **726–728**;
  builder **1914–1943**; which modes show the arc, `viewArcOn` **1946**.
  - The fan is contextual and *follows the rete*: sky-seat → `[plate, the sky, transits, lunar,
    releasing]`; person-seat → `[them, synastry, intersections]`. Geometry: symmetric fan, `STEP=16°`,
    `R=412.7`, labels rotated to ride the curved rim.
- **The registers (body-by-body tables):** `sheetPlate` template **743–786**, `sheetRete` **787–825**;
  both render rows from `_specRows(posMap, ascLon)` (**2707**, chart-agnostic). Column header at
  **750–752**; row markup **756–770**.
- **"The sky" lens (today):** `_sheetDataSky` **3476–3496** (moon phase + big three + `_skyHits()`);
  `_skyHits` **3499**; template `sheetSky` **827–866**.
- **Transits lens (absorption target for L4):** `_sheetDataTransits`; `txMoon` "+ include the moon"
  toggle + per-natal-body filter chips (see screenshot 2); ♋ "fast hand" door `openLunarLedger`
  **2258**.
- **♏ Timing tabula (L5/L6 home):** `pReleasing` panel template **299–334** — holds the `openZr`
  releasing door (**307**) and `openElection` windows door (**322**), plus the peak-doctrine chips.
- **Element palette:** `this.ELEM = ['#d64541','#d97036','#e8ab41','#4da4d9']` (fire/earth/air/water),
  **1221**; `_elemOf(lon)` **1328**.
- **Dispatch:** `_sheetData(name)` **3778**; `_restingLens()` **2683** (returns `plate` if a plate
  chart exists, else `sky`).
- **Persist:** `this._persist({...})` merges into saved state (see existing `zrLot`/`crossBack` uses).

### What NOT to touch (all agents)
- The wheel/`_draw` instrument (the sun). The rete/plate you *reflect* are read-only references.
- The pane's physical rise/eclipse (veil, corona, first-contact flash).
- Engine files (`ephem/transits/electional/zr/astrodna/framing`) — this batch is presentation +
  a small persisted config flag, no new astronomy.

### Sequence (dependencies are real — respect them)
1. **Opus** — L4 + L5/L6 model + L3 spec. **Output: the final lens registry** (which lenses exist,
   which are core vs pinned, each lens's secondary options). *Fable is blocked on this.* In parallel,
   **Sonnet** takes L2 + L9 (independent of the menu redesign — safe early wins).
2. **Fable** — L7 + L8 against Opus's registry. Sets the rotating-rete + plate-sub-menu feel + the
   reflected materials. *Blocked by step 1; blocks Sonnet's wiring of the sub-menu.*
3. **Sonnet** — L3 build, L5/L6 pin wiring, fold L2/L9 into Fable's new chrome, regression + re-bundle
   (`Orbo Astrolabe Standalone.html` + `ios-wrapper/www/index.html`).

---

## 1. Brief — OPUS (structure & law; design already decided)

You own **what lenses exist and how they're governed.** Your deliverable is a clean, persisted **lens
registry** that Fable's rotating menu and Sonnet's wiring both consume. Do the model; hand the
templating to Sonnet where noted.

### O-A · L4 — absorb the **lunar** tab into transits
The Moon-only "lunar / fast hand" lens duplicates Transits, which already carries a "+ include the
moon" toggle **and** a per-natal-body filter (Moon chip included). This reverses the July-11 "lunar as
a first-class view" decision — that's intentional; the user confirmed it.
- Remove `lunar` from the lens set: drop the `chips.push({ id:'lunar' … })` at **1927** and `'lunar'`
  from `viewArcOn` (**1946**).
- Decide + document what "absorbed" means concretely. Recommended: the Moon becomes a first-class
  **preset inside Transits** — redirect the ♋ Moon panel's "fast hand — lunar transits →" door
  (`openLunarLedger`, **2258**) to open `sheet:'transits'` with `txMoon:true` and the **Moon filter
  chip pre-selected**, so the fast-hand reading still has a front door, now inside Transits.
- Leave `_sheetDataLunar` / the `sheetLunar` template dormant OR delete — your call, but if you leave
  it, make sure nothing routes to it anymore (search `sheet: 'lunar'`, `openLunarLedger`,
  `_restingLens`).
- Confirm the resting/idle lens logic (`_restingLens` **2683**) never lands on `lunar`.

### O-B · L5 + L6 — the "Add to lunar pane" mechanism (the pin registry)
Today the menu is hardcoded and releasing auto-appears whenever `zr && natal` (**1928**); electional
has **no** rete tab at all (only reachable via the ♏ door). Replace this with an explicit, persisted
opt-in model.
- **Registry shape.** Define a single source of truth for lenses, e.g.
  `LENS = [{ id, label, glyph, tier:'core'|'optin', needs:(fn)→bool, seat:'sky'|'person'|'any' }]`.
  - **Core** (always on the ring when available + seat-appropriate): `plate` (the chart), `sky`,
    `transits` (sky-seat), and the person-seat set (`rete`/them, `synastry`, `cross`).
  - **Opt-in** (only on the ring when pinned): `zr` (releasing) and `election` (windows). Both live
    under ♏ Timing.
- **Persisted pin set.** `state.paneLenses` (array of ids) or per-lens booleans, saved via
  `_persist`. Default **empty** (clutter-free). Migration: existing users currently get releasing
  auto-shown — decide whether to seed `paneLenses:['zr']` on first load or start clean (recommend
  clean + a one-time note; document it).
- **Back-side toggles.** Add an **"Add to lunar pane"** control beside each ♏ door in `pReleasing`
  (template **307** for releasing, **322** for electional): a small pill/switch that toggles the id in
  `paneLenses` and persists. Copy suggestion: `add to lunar pane ✓` / `on the lunar pane`. Keep it in
  the ♏ maker's-side voice ("♏ holds the maker's choices" — see the caption at **333**).
- **Menu reads the registry.** Rewrite `viewChips` (**1914**) to build from `LENS`: core (seat- and
  availability-filtered) + pinned opt-ins. Keep it contextual (follows the rete). This is the data
  Fable's rotating ring renders — coordinate the shape with Fable so the ring gets `{id,label,glyph,
  active}` plus each lens's **secondary options** (for the plate sub-menu, L8): e.g. transits → the
  body-filter chips + moon toggle; the chart → which-chart sub-choice; releasing → lot chips.
- **Truth table to document** (availability × pinned × seat): a pinned lens whose `needs()` fails
  (e.g. releasing with no natal) should **not** appear on the ring — and the ♏ toggle should show
  *why* (the existing "needs your natal — engrave it in ♈ first" pattern, **319/329**).

### O-C · L3 — "the sky" becomes a positions register
The user: *"change [the sky] to the full astrology chart. Get rid of big three and 'the tightening
now'. I want the current positions of all planets."*
- `_specRows(posMap, ascLon)` (**2707**) is chart-agnostic and already powers the plate & rete
  registers. **Respec `_sheetDataSky` (3476) to return a register** via `_specRows(this.pos, this.asc)`
  — the live sky, body by body — instead of the moon-phase + big-three + `_skyHits()` payload.
- **Decisions you own:** (a) the label — recommend `THE SKY` / "the sky itself · body by body" to
  match the plate's "the chart itself · body by body". (b) Whether a **small phase strip** survives as
  a header (the user killed the *big three* and *tightening now*, not necessarily the moon-phase disc —
  but default to **pure positions** unless you see a reason). (c) What the idle/resting tap shows now
  that `sky` is a table — `_restingLens` still returns `sky`; confirm that reads well as a resting
  state (a positions table is a fine depth-0 "the instrument reporting itself"). (d) Whether
  `_skyHits()` is now dead (check other callers before deleting).
- **Hand to Sonnet:** the template build (mirror the `sheetPlate` block **743–786** into a `sheetSky`
  register; remove the old `sheetSky` markup **827–866**) and the `renderVals` wiring
  (`skyRows`/`skyTitle`/`skyOk`). You set the shape + copy; Sonnet builds.

### O-D · The gating artifact
Publish the **final lens registry** (ids, tiers, glyphs, secondary options per lens, seat rules) as a
short section appended to this file or the design map. Fable cannot design the rotating ring until this
exists. Keep it to one screen.

**Opus constraints:** logic in the `Component` class + `renderVals`; no new stylesheets; persist via
`_persist`; don't touch `_draw`.

---

## 2. Brief — FABLE (interaction feel + reflected materials; the one rationed sitting)

You own **L7 + L8**: the lunar pane's navigation becomes a two-tier instrument that *reflects the sun's
own rete and plate.* This is the single highest-leverage sitting in the batch — everything else hangs
off the model you set. **Do not start until Opus's O-D registry exists** (you need the real lens set).

### The metaphor you're building (from the user)
The pane is the **moon**; it reflects the sun's light. The sun already has two materials the user loves
and wants to see mirrored here:
- **The rete** (the moving heaven) — the outer ring you *rotate*. → The pane's **primary lens switcher
  becomes a left/right rotating ring.** Today it's a static symmetric fan of labels riding the curved
  rim (`viewChips`, template **726–728**; geometry in the builder **1929–1942**: `STEP=16°`,
  `R=412.7`, per-label `rotate()`). Make it **grab-drag rotatable** — spin lenses through a
  **top-center detent** (the active lens sits at the crown, lit), with momentum/snap. This is what lets
  an arbitrary number of pinned lenses live here without the crowding a fixed fan would cause — and it
  *feels* like spinning the rete.
- **The plate** (the engraved, fixed tablet beneath) — → the pane's **secondary sub-menu** for the
  active lens's options reads as **engraved/recessed plate material** (intaglio, the "settled" layer).
  Content per lens comes from Opus's registry (e.g. transits → body-filter chips + moon toggle, already
  visible in screenshot 2 as circular chips; the chart → which-chart sub-choice; releasing → lot
  chips). You set how the sub-menu presents and animates; Sonnet wires each lens's content into it.

### Reflect the light (materials)
Study the wheel's own rete + plate rendering in `_draw` and **lift the recipe** rather than inventing a
new look:
- **Brass limb / rete recipe** (per the design map, July 9–10): directional linear sheen + radial
  polish across the band + dark stamped cuts with a light-leak edge offset. Radii for reference:
  `rBody = R−53`, sky/rete ring outer; `rN = R−75`, the plate.
- **Intaglio plate recipe:** debossed engraving — dark glyphs cut into stone with a thin rim-light
  leaking through below (the natal plate treatment).
- The pane's silver corona is **law** (the moon's metal — the sheet is always cool silver; warm gold
  appears only as the first-contact flash and as active-lens/applying-aspect accents). Keep it. The
  rotating rete labels + plate sub-menu should feel like *silver-cast reflections* of the sun's brass
  rete and stone plate — related materials, cooled.

### Hard constraints
- **Physical behavior is frozen (L1).** Still peeks from the bottom, rises when called, same eclipse
  (veil `eclipseVeil` **1849**, corona `coronaUp` **1850**, first-contact flash). You're re-skinning
  the *switcher inside the risen pane*, not the rise.
- **Clutter-free default.** With `paneLenses` empty, the ring shows only the core lenses — spare and
  calm. The rotation is what makes "add more" scale.
- **Consume Opus's registry** — render `{id,label,glyph,active}` + secondary options; don't hardcode a
  lens list.
- Inline styles only; DC template patterns (`sc-camel-on-*` handlers, refs for canvas). Animated bits
  (rotation, detent) belong in `renderVals`/logic per the "don't drive animation from the template"
  rule. Don't touch `_draw` or the engines.
- **Legibility is a shared goal** — coordinate with Sonnet's L9. If your reflected materials naturally
  brighten the labels, say so, so Sonnet doesn't double-correct.

### Deliverable
The rotating rete switcher + plate sub-menu, feel + materials fully set, rendering Opus's registry.
Expose clear hooks (per-lens secondary-option slot) so Sonnet can wire each lens's controls into the
sub-menu. Snapshot before you start (see convention).

---

## 3. Brief — SONNET (formulaic, testable)

### S-A · L2 — element lettering + column spacing in the registers *(independent — start anytime)*
Applies to all body-by-body registers (`sheetPlate` **743–786**, `sheetRete` **787–825**, and the new
sky register once L3 lands). Source: `_specRows` **2707**.
- **What already exists:** the body glyph is already element-colored — `gc: this.ELEM[sg%4]` (**2718**).
  In screenshot 1 three of four bodies are in Aries (fire) so they *look* uniformly red; that's correct
  behavior, not a bug.
- **The actual ask (user-clarified 2026-07-15):** *make the row text match the glyph color.* Today the
  glyph is element-colored but the **name text is flat near-white** (`r.name`, `#f2f0fc`, template
  **759** & **801**). Change the name to render in `r.gc` (the same element color as its glyph), so each
  row reads as one element-colored unit — glyph + name in the sign's element.
  - Do it via the row markup (swap the hardcoded `color:#f2f0fc` on the name `div` to `{{ r.gc }}`) —
    `gc` is already on every row object, no `_specRows` change needed for the color itself.
  - The **position sub-line** (`r.pos`, `#8f86c0`, template **761** & **803**) can stay muted, OR take
    a dimmed tint of `gc` if it reads better — Sonnet's call, keep it clearly secondary to the name.
  - Distinctness check: fire `#d64541` and earth `#d97036` read close. Now that the *name* carries the
    color too, confirm fire-sign vs earth-sign rows are still tellable apart; if not, nudge earth
    toward clearer separation **inside** the existing 4-color language (no 5th hue).
- **Space HSE ↔ DISPOSITOR.** The right cluster crowds (screenshot 1). In the header (**750–752**) and
  rows (**764–770** / **806–812**): widen the `gap` between the `hse` column (currently 16px wide) and
  the dispositor cluster (`min-width:52px`), and/or give `hse` more room, so the number and the
  dispositor glyph+chip don't kiss. Keep both registers identical (they share markup).
- Applies to all three registers (plate, rete, and the new sky register from L3).

### S-B · L3 build — the sky register *(after Opus O-C sets the shape)*
- Mirror the `sheetPlate` register block (**743–786**) into a `sheetSky` register: header
  ("THE SKY" / "the sky itself · body by body" per Opus), the shared column header, `sc-for` over
  `skyRows`.
- Remove the old `sheetSky` markup (**827–866**) and its renderVals (moon disc, big three, hits).
- Wire `renderVals`: `sheetSky`, `skyTitle`, `skyOk`, `skyRows` from `_sheetDataSky` (Opus rewrites it
  to `_specRows(this.pos, this.asc)`). Verify the resting/idle tap (`_restingLens → 'sky'`) opens the
  table cleanly.

### S-C · L5/L6 wiring — the pin toggles *(after Opus O-B model + Fable's sub-menu exists)*
- Build the ♏ "Add to lunar pane" toggles in `pReleasing` (**307**, **322**) against Opus's
  `paneLenses` model: toggle the id, `_persist`, reflect on/off state, and gate on availability
  (`needs()` — reuse the "needs your natal" empty-state pattern **319/329**).
- Confirm the rete ring (Fable) picks up newly-pinned lenses live (state → `viewChips` → ring).

### S-D · L9 — legibility / brighten pass *(independent — start anytime; coordinate with Fable)*
The pane leans on very dim purples that fail legibility, especially over the silver corona. Brighten
consistently. Concrete targets across the pull-up templates (`sheet*` blocks) and register markup:
- `#5a5090` (captions, "tap to dismiss", column headers) → noticeably brighter (e.g. toward `#8478b8`
  or lighter — pick one and apply everywhere).
- `#6f66a3`, `#8f86c0` (sub-text, position lines, glosses) → up one clear step.
- Row separators `rgba(214,222,240,0.08)` → raise alpha (~0.14–0.18) so rows read as rows.
- Keep the **one color language** — brighten within the existing purple/violet family and the ELEM
  palette; don't introduce new hues. Don't brighten so far that active-lens gold loses its emphasis.
- **Coordinate with Fable:** if Fable's reflected-material pass already lifts label contrast, don't
  double-apply — align on final token values so there's one source of truth.

### S-E · Regression + re-bundle *(last)*
After everything lands: click through every lens (sky/transits/chart/synastry/intersections + pinned
releasing/electional), seated and unseated, natal-present and absent; confirm no console errors and the
rotating ring + sub-menu behave. Then re-bundle `Orbo Astrolabe Standalone.html` from master and push
into `ios-wrapper/www/index.html` (the phone build), per the standing convention.

**Sonnet constraints:** logic in `Component`/`renderVals`; inline styles; `_persist` for the pin flag;
regenerate any `*.browser.js` from its `.js` source of truth (none expected this batch); don't touch
`_draw`.

---

## 4. Open decisions surfaced to the user (confirm as they come up)
- **L4 "absorbed" shape** — recommended: Moon becomes a preset inside Transits + the ♋ door redirects
  there (Opus O-A). Confirm vs. a plain deletion of the ♋ door.
- **L2 scope** — *resolved:* the row **name text** takes its glyph's element color (glyph + name read as
  one element-colored unit); plus HSE↔DISPOSITOR spacing. Position sub-line tint is Sonnet's judgment.
- **Pin-set migration (L5/L6)** — start clean (empty `paneLenses`) vs. seed `['zr']` so current users
  don't "lose" releasing. Opus proposes; user confirms.

---

## 5. Final lens registry — OPUS, delivered 2026-07-15

*The Opus block (O-A/O-B/O-C) is built in `Orbo Astrolabe.dc.html`. This is the gating artifact Fable
consumes and the state Sonnet wires against.*

### The lens set (driven by `state.paneLenses`, persisted)
Base is still **contextual — it follows the rete seat** (the standing "you never see a dead tab" law):
- **Sky seat** (`rete === 'sky'`/none): `the sky` (always) · `transits` (needs natal) · then pinned opt-ins.
- **Person seat** (`rete` = a person/event object): `<their name>` · `synastry` · `intersections`
  (needs natal + electional engine).
- **Plate:** the plate's short name is prepended whenever a plate chart exists, either seat.

**Core (always on the ring when available):** `plate`, `sky`, `transits` (sky seat);
`rete`/`synastry`/`cross` (person seat).

**Opt-in (on the ring only when pinned AND prereqs hold):**
| id | label | pinned from | prereq |
|---|---|---|---|
| `zr` | releasing | ♏ Timing | `this.zr && this._natalDna()` |
| `election` | windows | ♏ Timing | natal + `window.__ORBO_ELECTIONAL` |

### Mechanism (built)
- `state.paneLenses` (array of ids), **default `[]`** → pane opens clutter-free.
- `_togglePaneLens(id)` adds/removes + `_persist`. ♏ pills `toggleZrPane`/`toggleElPane` call it;
  label flips `+ add to lunar pane` ⇄ `✓ on the lunar pane` (gold when on).
- `viewChips` (the builder, ~1918) now reads `pinned = s.paneLenses`; `viewArcOn` lists
  `sky·transits·zr·election·synastry·cross·rete·plate` (was `…·lunar·…`). Election is now a
  first-class arc lens (previously only reachable via the ♏ door); its chip tap seeds
  `_elAnchor`/`_elCache` like transits does.

### Migration decision (Opus call — flag if you disagree)
`paneLenses` defaults **empty**. Deliberate reset: users who saw releasing auto-shown re-pin it once
from ♏. Rejected seeding `['zr']` — it fights the "clutter-free default" the user asked for; one
re-pin is trivial in a prototype.

### L4 absorption (built)
`lunar` removed from `viewChips` + `viewArcOn`. The ♋ "fast hand" door (`openLunarLedger`) now opens
`sheet:'transits'` with `txMoon:true`. `_sheetDataLunar` / `_moonTransitsData` / the `sheetLunar`
template are left **dormant + unreachable** — Sonnet may prune in S-E (low priority; harmless).

### L3 (built — data + template)
`_sheetDataSky` now returns a register via `_specRows(this.pos, this.asc)`; the `sheet:'sky'` template
is a body-by-body table mirroring plate/rete (kept the footer's "how to play" + "transits to you →"
doors). Big three, moon-phase disc, and "tightening now" are gone per the user. Now dead and safe to
prune later: `_skyHits()` and the `moonSheetRef` draw block (~3178).

### What Fable consumes (do not re-derive)
`viewChips` yields `[{ id, name, on, tap, col, bd, ml, top, rot, ub }]`. Today `ml/top/rot` position a
static fan on the rim. **Replace that geometry with the rotating-rete interaction; keep consuming
`{id, name, on, tap}`.** Each lens's **secondary options** for the plate sub-menu already exist as
renderVals arrays — wire, don't rebuild: transits → `txChips` + `txToggleMoon`; election →
`elProfileChips` + `elSpanChips`; releasing → `zrLotChips` + `zrPeakChips`.

---

## 6. L7 + L8 — FABLE, delivered 2026-07-15

*Per the user (2026-07-15): the pane's elemental look/feel is unchanged — same label styling, colors,
fan step (16°), rim radius (412.7), silver corona. Use + build only.*

### L7 — the rotating rete (built)
- Chips sit at fixed fan angles on a 0×0 wheel wrapper (`paneRingRef`) centered at the old fan
  center; the wrapper spins (`paneRingTf`/`paneRingTr`) so the **active lens always rests at the
  crown detent, lit gold**. Chips fade gently past ~20° off-crown (min 0.35).
- A transparent grab strip (430×66 at the crown) owns the gesture: drag turns the wheel live via
  direct DOM writes (no re-render), release adds momentum (`vel·170`) then snaps to the nearest
  detent and activates that lens. A still tap activates the chip under the finger (<11° away) or
  falls through to the pane's normal tap. Handlers: `_paneDown/_paneMove/_paneUp/_paneCancel/
  _paneFade/_paneGo` (above `_restingLens`).
- `_paneGo(id)` is the single activation door (seeds tx/el anchors, sets `sheet` + `sheetData`).
  Newly pinned lenses appear on the wheel automatically (`viewChips` still reads `paneLenses`).

### L8 — the plate sub-menu (v2, arc'd — user direction 2026-07-15 evening)
- The band card is gone. Secondary chips ride a **second arc concentric under the rete**: a 0×0
  wheel (`paneSubRef`, rim radius 348, step 5.8°) with chips **tilted with the arc**. Free-slide
  drag (own grab strip below the crown band), clamped ends, momentum, **no detent** — filters
  aren't positions. Handlers `_subDown/_subMove/_subUp/_subCancel/_subFade`; slide position kept
  per lens (`_paneSubRot`, resets on lens change).
- **All three option lenses wired:** transits → `txChips`; windows → `elChips`; releasing →
  `zrLotChips` (the lot column was lifted out of the zr sheet body — timeline is full-width now).
  Non-filter controls sit as centered pills under the arc's crown: tx moon toggle, el span chips.
- **Wiring a new lens:** the lens's chip builder stashes its list (`this._<x>ChipsNow = …`), then
  add a branch in `paneSubChips` + a `paneSub<X>` gate. Chips normalize to
  `{name/glyph, col, bd, bg, tap}`.
- **Redundant titles removed on ALL switcher sheets** (plate, rete, sky, transits, windows,
  releasing, synastry, intersections): the lit crown label IS the title; only the one-line gloss
  remains. `txTitle`/`syTitle`/`cxTitle` renderVals keys are now unused (prune in S-E if desired).

### For Sonnet's L9
Fable did **not** brighten any labels — materials/colors untouched by user instruction. L9 proceeds
exactly as specced; the ring chips use the same `#8f86c0`/`#e8ab41` tokens, so brightening those
tokens in renderVals covers the new chrome too.
