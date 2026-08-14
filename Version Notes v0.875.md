# Orbo AstroLabe — Version Notes v0.875 (July 29, 2026)

**Phase 3 — the Lunar Surface, closed.** The back's one layout is finished: the tabula spread is a
socket ring, every registrable tabula is on it, and the pane's three verbs are separated.
Predecessor: `Version Notes v0.86.md`. Plan of record: `specs/Phase 3 Plan - rebased on v0.86.md`.

## The tabula spread, complete
The back is concentric label rings. Outer ring = the twelve tabulae; **socket ring** (r 26.4–32.9) =
twelve sockets on the same 30° spokes, in the same arced Georgia. Filled sockets are centred on the
top; the rest are visibly empty, inert, and unmarked. Sockets are tapped by their wedge, never by the
curved word. When a tabula is open every other slot dims: nothing is hidden, you can still tap across.

**Three kinds of tabula**, which is what let the last six join a ring that was designed for nameable
things:

| kind | the socket picks | tabulae |
|---|---|---|
| `item` | what you read (field = glossary entry + two verbs) | ♏ Timing · ♓ Composite · ♐ Almanac |
| `mode` | what the field configures (no verbs, one control) | ♊ Bodies · ♍ Aspects · ♑ Gears |
| `sort` | how a roster is cut (tabula keeps its own body) | ♎ Ledger · ♒ Archive |

Per tabula: **♊** Planets · Objects · Points, glyphs inset on the chip ring with a text block in the
centre. **♍** Major · Minor · Orb, where Orb clears the ring because it is not a family. **♑** Speed ·
Rim · Snap · Feel, one control at a time instead of four stacked. **♐** puts its five streams on the
ring. **♎** defaults to Add, with Search · All · Pairs · People · Events · Horary. **♒** defaults to
Log, with the journal's activity kinds.

Unregistered on purpose: the forms (♈ ♉), ♌ Appearance, ♋ Moon.

- **♑ Gears did not want a slider.** Speed · Rim · Snap · Feel, one control at a time, no stack. This
  closes open question 8 without inventing the arc slider.
- **The bottom socket is always AEGIS** — the way back to the face, present on every tabula. It keeps
  the ring nominal (every socket names a destination) and retired the floating ⟲ front button, which
  the ♊ and ♍ chip rings used to displace entirely.
- **Ring labels cap at ~8 characters.** Past that a curved label overruns its 30° socket and collides
  with its neighbours. This is why ♐'s streams read Chapters · Crossing and ♎'s composites read Pairs.
- **The field is set as a glossary entry**: the term in gold incised caps, its definition beneath in
  stone. No header row, no ×. Fixed icon on top = *open*, fixed rune below = *etch*, only the entry
  between them scrolls.
- **Well geometry.** Item field 152px; a field inside a chip ring narrows to 108px; a `sort` tabula is
  inset to a 132px column whose diagonal clears the label radius.
- **Register**: third person, declarative, definition-shaped, in the voice of the Field Theory
  glossary. Engraved (Georgia) on the back, moonlight sans in the pull-up. No em-dashes.

## The dock law — open is not etch
The Lunar Pane is a dock, and its three verbs now mean one thing each:
- **open** — show a lens on the pane now. Transient. `_openTabLens`. It must never write `paneLenses`;
  `_openAlmanac` and `_zrToAlmanac` used to force-etch on the way in, which is why ♐ was the one lens
  you could not look at without keeping it.
- **etch** — keep a lens on the pane. Persisted, `_togglePaneLens`, the rune. Etched chips carry a dot
  on the pane's crown; a merely *running* lens appears there too, dotless, and leaves when you leave
  it, so the dock always shows what you are actually reading.
- **fuse** — build a stream into the timespine's event table. Belongs to the spine, not the pane.

Un-etching happens at the dock, not through the rim: a 520ms hold on an etched crown chip
(`_paneDown`'s `_chipHold`); `_paneUp` swallows the lift so the hold does not also navigate.

## Engraving recipe (unchanged, now applied throughout the back)
`feTurbulence` grain at 0.06 overlay-blended · every hairline is a pair (shadow 0.3px down-light, lit
stroke on top) · incised type carries `text-shadow 0 1px 0 rgba(0,0,0,0.6)` · an occupied socket is a
shallow recess, the selected one is the groove filled with gold. One light direction, from above,
shared with the pane's limb light.

## Review path
The back is only reachable by a rim double-tap, which synthetic pointer events do not reproduce:
`window.__orbo.setState({flipped:true, panel:'releasing', tabSel:'zr', depth:'scholarly'})`. For a
mode or sort tabula pass its own key too: `{panel:'transport', gearSel:'feel'}`,
`{panel:'people', ledSel:'all'}`, `{panel:'memory', arcSel:'all'}`, `{panel:'aspects', virgoSub:'orb'}`,
`{panel:'planets', geminiSub:'points'}`.

## Deliberately not done
- **♓ has no RELATION socket.** A person × person composite needs the engine. A dead socket would be
  worse than an absent one.
- **The axial-first check is still open**, and it is worth doing before ♓ Synastry or ♐'s flips promise
  anything.

## Carried out of Phase 3
- **The occulter** (`pane.occulter = { id, needs, surface, render }`) is not built. The plan already
  argued for landing it late; it leaves the phase instead.
- **The cohesion sweep** `[O]` (pill buttons out system-wide) is not done. The back no longer has
  pills; the pull-up and the sub-arcs still do.

## Next — the computational review, toward v0.88
Authority filed at `docs/Field Theory Astrology 2.0 - Levels.md` (Master Glossary 2.0, every term
defined at L1 / L2 / L3). The L1-L3 ladder is NOT implemented in this version; only the document is
seated. What it raises for v0.88, in the order it argues for:

1. **Axial-first storage.** A synchonic placement should be stored as an axial coordinate (mod 180)
   plus a phase bit, with displayed longitude derived. Orbo currently stores the point. This is the
   check the ♓ work is waiting on, and the glossary is explicit that a point-only system hides the
   antipodal ambiguity rather than resolving it.
2. **Phase bits, parity, and flip boundaries.** A flip is a precise temporal event to be solved from
   continuous motion, not inferred from sampled frames. Same-planet synchonic synastry needs parity to
   pick the visible member of a complementary aspect family.
3. **Unwrapped longitude.** Continuous angular coordinates, not reduced mod 360, so stations,
   retrogradation, completed cycles, and branch boundaries do not jump at 0° Aries.
4. **Exact-time refinement** as a named numerical step after a coarse window is found: ingress,
   perfection, egress, station, flip.
5. **Frame protocol as a declared object** — frequency, civil time, timezone, DST, location, house
   policy, event-driven insertions. Frames are comparable only under one protocol. Orbo's composite
   frame (same-ascendant moment at the natal location) already is one; it should say so in data.

### Terminology, settled
It is **synchronic**, with the *r*, as the instrument and `CLAUDE.md` already spell it. Where the
Master Glossary 2.0 writes *synchonic*, the glossary is wrong. No sweep needed.

### The composite computation report
`docs/Field Theory Astrology for Orbo Timespine.md` (filed 2026-07-29) is the specification for the
composite layer: axial-first storage, the phase bit, unwrapped longitude, the same-planet cancellation
law, and the flip as a phase-parity event rather than a sampled jump. It is the authority for v0.88's
engine work, and `docs/Synchronic Conversation -source for the white paper-.md` is the transcript it
was distilled from. Read the transcript alongside it: the paper is a faithful summary of the geometry
and drops most of the interpretive machinery (named chains, bearer/keeper, governor-condition change,
the flip as a governance inversion, the retraction of the counter-dispositor). Read with `framing.js` open: `midpoint()` is point-only and `frameEvents()` infers a flip
from a >150 degree jump between daily frames, which are the two things the report argues against.
