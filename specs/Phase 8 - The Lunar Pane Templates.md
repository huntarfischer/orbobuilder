# Phase 8 · The Lunar Pane Templates

Plan of record, agreed 2026-08-12 in conversation. The law this implements is recorded in
`CLAUDE.md` under **The lunar pane's law · bands and templates** — that section is doctrine, this
file is the build order.

**The thesis.** Every layout defect found in review is a template mismatch: the right data in the
wrong shape. Eleven surfaces have eleven layouts because each reader decides its own markup, its own
row object, and its own height. Fix that and the rest of the pane's problems stop being separate
design jobs.

**Standing rule for the whole phase.** One step per pass. Never two. A wide mechanical change reads
correctly line by line and still does not run (see the bulk-edit lesson in `CLAUDE.md`). Snapshot to
`archive/Orbo Astrolabe YYYY-MM-DD[a-z].dc.html` before each step that touches shared geometry.

---

## Step 0 · The lens rail is broken — unblock everything else

**Nothing below can be judged while the rail cannot be clicked**, because the lens rail is how you
reach the content the templates are meant to fix.

`sheetLenses` (≈ line 5142) is a hardcoded four-item fan:

```
signif   ml −168px  rot −24°
aspects  ml  −56px  rot −7.8°
motion   ml  +56px  rot +7.8°
toyou    ml +168px  rot +24°
```

Three defects, all of them fatal, all measured in the live view:

1. **Even count, symmetric about the crown — nothing is ever AT the crown.** ASPECTS and MOTION
   straddle it at ±56px. This is the ♑ Gears socket-ring defect for the second time (`CLAUDE.md`:
   "Socket slots must land on INTEGERS… an EVEN item count"), here as literal hardcoded offsets
   rather than a slot calculation. The active lens' gold underline therefore lands on the steep part
   of the limb and reads as a tilted horizon line.
2. **±168px is outside the surface at the real window width.** Measured at 682px wide: SIGNIFICATION
   and TO YOU are clipped by the limb. Not a phone-only problem — this is the preview window as
   shipped. Two of four lenses cannot be hit at any size the app is actually used at.
3. **The two reachable ones are swallowed by the drag.** Their `tap` is a CLICK handler with
   `stopPropagation()`, but they sit on the pane's grab band and `_paneGrabDown` owns POINTERDOWN,
   which fires first, starts the drag, and resolves the tap as a pane step-down. Stopping
   propagation on click cannot undo a gesture that already began. Precedent for the fix is in the
   file: `_paneUp` swallows the lift so a chip-hold does not also navigate.

**Fix:** data-driven rail, active item at the crown (rotate to a detent as ZR does, or use an odd
centred count), every item inside the surface, and **wedge hit areas on pointerdown** — the back's
own ruling, "sockets are tapped by their wedge, never by the curved word."

**Measured before the fix, so the repair can be checked:** `needs: "pager"`, `eclipseAvail: true`,
stops `peek 334 · facts 0 · eclipse −182`, pack loaded, `_eReadLen: 1`. **The rise was never lost** —
the natal sheet rests at facts with the eclipse detent live 182px above it. It only feels missing
because the lens carrying the interpretation cannot be reached.

---

## Step 1 · Standardize the rest values

`_paneLadder()` is already the one door (the old `_eGeo` stash was retired for exactly this reason),
so this is a change of what it keys on, not new machinery.

- Three named rests, one lookup: **CREST** (templates A · E) · **FACTS** (B · D) · **ECLIPSE** (C).
- **Rest follows template, never pane, and never content length.** Today the eclipse rest is derived
  from `_eReadLen` — how much content happens to exist — so the same sheet has a different ladder
  depending on whether a pack has an entry for that body. Content-derived height is why no two panes
  agree and why the eclipse pane rises too far.
- A pane may no longer choose its own height. "Rises too far" becomes structurally impossible rather
  than tuned away.

---

## Step 2 · The band scaffold + the SPAN template, proved on ZR

Emit the seven bands once, each wrapped in `sc-if` so a pane that omits one returns nothing for it:

```
header · side rail · chip rail · caption · body · legend · provenance
```

Extract **D · SPAN** from ZR verbatim (`disclosure ▸ · glyph · level · date · badge · ⊕`, nesting by
indent and coloured outline, the L1–L4 rail beside it).

**The fidelity proof: migrate ZR onto the scaffold and require the render to be visually identical.**
ZR is the reference implementation; if the scaffold cannot reproduce it exactly, the scaffold is
wrong. Same discipline as the P0b ruling that pinned the natal-solo render byte-identical.

---

## Step 3 · Row contracts + the load-time refusal

The duplication is not markup, it is that every reader invents its own row OBJECT. Fix the object
and the markup collapses on its own.

```
FACT    { k, v }
ROSTER  { glyph, subject, state, qualifier }
LEDGER  { mark, what, when, rate, pin }
SPAN    { glyph, level, start, end, badge, children, pin }
TRACK   { value, min, max, direction, marks }
```

A row missing a field, or carrying an ad-hoc extra, is **refused at build**, not rendered as a
plausible half-row. Precedent: the prism's self-test catching `frameOffset` computed and never
recorded. A plausible-looking result is worse than an error.

---

## Step 4 · LEDGER, and the `exact to N°` mislabel

Extract **C · LEDGER** from the almanac's upcoming row (`● dot · label · sub · time · ⊕`) — the bones
are right. The July cross-aspects table is the reference for **column discipline**: its four fixed
columns are what the almanac row approximates with flex. The election rows
(`dateStr · timeStr · scoreStr · ⊕`) confirm the shape generalizes.

Fix in the same pass, because it is one defect in the template's own fields:

- **`_almCross` prints `'intersection · exact to ' + p.orb`, where `p.orb` is the orb NOW and the
  time beside it is `p.exactJd`.** At an exact moment the orb is **0 by construction** — that is what
  exact means. The same North Node square Venus reads `0.0°` in the Crossing pane and `3.0°` in the
  almanac. Neither number is labelled with what it actually is.
- **The `rate` field replaces it**: `within 1° for 4h` — which distinguishes a slow wide Node contact
  from a Moon contact that is over in an hour, and is the fact that was actually missing.
- `intersection` is legend text in a row; it moves to the legend.
- **Sun square North Node and Sun square South Node print as two rows at the same minute** because the
  axis is stored as two bodies. A ledger says it once.
- The almanac's coloured row dots have **no legend anywhere**, while its caption spells the stream
  count out in words. The legend `● releasing  ● crossing  ● eclipses` says both and teaches the dots;
  "THE TIMESPINE · 3 STREAMS FUSED" then disappears rather than moves.

---

## Step 5 · FACT, and the natal sheet's redundancy

Extract **A · FACT** from `signifRows` — already clean (9px/0.14em small-caps key, value right,
hairline under, no decoration). Nothing to redesign; it just becomes the only fact row.

Two trims that are pure legend-law application:

- **The subtitle repeats the first row.** `my Moon / 7° 34′ Capricorn · earth · engraved` then
  `SIGN — Capricorn · earth`. Say the sign once: keep the subtitle (it carries the degree) and drop
  the SIGN row, or reduce the subtitle to `7° 34′ · engraved`.
- **Provenance is printed on every row.** `house routing graph · the Connectome`,
  `mutual/mixed reception · the Connectome`, `Egyptian bounds · terms, the third rung` — a source
  note per row nearly doubles every row's height for something needed once per session. It moves to
  the provenance band, said once.

---

## Step 6 · The almanac gets its rails, and etch follows fuse

- **Side rail = tabs** (`ALL · CROSS · REL · ECL`), **chip rail = filter**, its contents a property of
  the selected tab. On `ALL` the chips are the STREAMS THEMSELVES (mute without unfusing — what the
  ☑ Gears chips on the back are reaching for from the wrong side), and `upcoming | calendar` are that
  page's view chips.
- Every side rail carries an **ALL**, the way back to the whole lens.
- **Fusing a stream etches the almanac; unfusing the last one un-etches it.** The almanac is a
  reader, not a lens — a container whose occupants are the fused streams, the same class of thing as
  the plate and the rete. This does not violate the dock's three verbs: what is forbidden is OPENING
  force-etching, because merely looking must never keep.
- **Delete or bind the dead etch controls.** `almPaneLabel` / `almPaneCol` / `almPaneBd` /
  `almPaneBg` / `toggleAlmPane`, and the identical sets for `election`, `prog` and `rising`, are
  computed in `renderVals()` and referenced NOWHERE in the template. The "+ Etch to the pane"
  affordance the logic believes it offers does not exist on screen; the only wired path is the tabula
  rune on the back. The `frameOffset` lesson for the fourth time.
- Put the verb on the dock: **tap a dotless crown chip to etch, hold an etched chip to drop.**

---

## Step 7 · ROSTER — the one template with no exemplar

The best roster ever built is the July "Locked dyad spectrum," and it is a desktop-width table that
cannot be copied to a phone as-is. The live candidates are all wrong-shaped (synastry rows are
two-line cards; dyad rows are ledger-shaped for content with no time axis). So ROSTER is **designed,
not extracted** — from the July table's structure, narrowed to one line:

```
♀ Venus    conjunct until Aug 12, 2026
☽ Moon     trine until Aug 17, 2026
```

- The aspect word carries the pole, the date carries the flip. **"(fixed since birth)" is deleted** —
  it is a legend printed on every row, and it describes the wrong half: the SEPARATION is fixed, the
  MODE is live, which is exactly what the two-state table showed and the current rows lost.
- The separation degree leaves the row (fixed, derivable, least useful thing there) and belongs to
  the expanded single-body reading.
- Subheaders: **`DYADS · SAME BODY, TWO STATES`** and **`APPROACHING`**. Never "our dyads" (the word
  implies it), never "what's forming". Separating contacts dim in place; the ledger owns the past.

---

## Step 8 · The pair panes, on the finished set

- Move them to the **facts rest** — they are currently at C's rest showing B's content, which is most
  of the "all over the place" feeling. There is also no room for a chip rail inside the limb's curve
  at the eclipse perch, which is why they never grew one.
- Side rail `DYADS · APPROACHING`, chip rail the shared bodies. Same two rails, same meanings.
- **The crown is one native's facts on a two-native pane.** `As · ☾ · ☉ · Σ · DRIFT` is my big three
  and my return dial, identical on both pair panes; only the `CB` token knows there are two people.
- **`drift` is already spent** on `dialOf`. The sASC separation is **SPREAD**.
- The locality paragraph collapses into the caption; the window caption and "adjust on ♓" disappear
  into the reach rail.

---

## Step 9 · TRACK — build it, give it the sASC separation

No exemplar exists, but the seed is in the file: the election row's `barW`, a width as a fraction of
a known maximum, is the only place a quantity is drawn against its range.

`_sheetDataCross`'s **"right now 35.8° apart" is template E rendered as template A**, which is
precisely why it has no origin, no range and no direction — A has no room for them. It becomes:

```
SYNCHRONIC ASCENDANTS · 35.8° APART · TODAY 0°–71.6° · OPENING
```

…answering from where (A relative to B), how far normally (the day's range), and which way. And the
copy stops saying "drift apart through the day," which implies monotonic separation for a quantity
that oscillates and returns.

---

## Deferred, deliberately

- **The synchronic clock's stretch rows** are template D drawn as cards, and their marks name neither
  endpoint: `♅ Uranus trine · 1:09 PM` is the synchronic ASCENDANT trining synchronic Uranus, read as
  transiting Uranus to the natal Ascendant by every reader who has tried. The subject is stated once
  per stretch when it moves onto SPAN in a later pass; the housing law's discipline ("always
  qualified, never bare") applies to bodies too.
- **Drift and σ in the header.** Drift is a property of the clock in the pane below it, not a fact
  about the sky, and σ duplicates a dial the wheel already draws in the `natalAsc` frame (§14.1).
  Both move when the crown is redesigned, not before.
