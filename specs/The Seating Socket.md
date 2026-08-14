# The Seating Socket — ♎ Ledger · SEAT

*Build brief. Agreed 2026-08-12, out of the appearance pass that broke the front's seat pickers.*

---

## The ruling this implements

**Seating is the maker's act, not the reader's.** The sun/moon law has a direction: the moon
reflects the light and never sources it. The pane's three verbs (open · etch · fuse) are all
read-only with respect to the instrument — they add ways of looking, or memory. Seating is
generative: it decides what the light *is*. A pane that reseats the wheels is not a fourth verb,
it is an inversion of the law.

So seating goes to the back, which already claims it in so many words: *"engrave, seat, mint.
Configuration, not interpretation."* The front has been squatting on an act the back owns. The
z-index fight between the seat pickers and the astrolabe was the symptom; this is the cause.

**The affordance is physically true to the object.** On a real astrolabe you change the plate by
turning it over. The flip stops being navigation and becomes the meaning of the gesture.

---

## Scope

### 1 · The front becomes a readout

- The two seat cards (`showSeats`) stay exactly as they are visually: the deep plane at z:3, the
  depth transform written by `_depthTick`, the limb eclipse, the migrating civil line
  (`dateInPlate` / `dateInRete`). **None of fable's layering work is reverted.**
- They stop being pickers. Tapping a card **flips the instrument** and lands on the seating
  socket with that wheel pre-targeted (below).
- **The picker layer retires.** The z:5 layer added 2026-08-12 (`pkPlate` / `pkRete` / `pkAny`
  and its scrim) is deleted along with `seatPicker` state, `tapPlateSeat`/`tapReteSeat`'s toggle
  behaviour, `closeSeats`, `plateOpts` and `reteOpts`. The ladder returns to stars < Big Three <
  Orbo (2) < seat cards (3) < astrolabe (4) < veil (5) < pane (6). Revert the veil/pane bump.
- **⇅ reveal and ⇄ swap stay on the front.** Neither one *chooses* anything — ⇅ discloses the
  cards, ⇄ permutes two charts that are already seated. The rule is absolute for CHOOSING only,
  and this exception is stated rather than discovered.

### 2 · The socket

**One socket, `seat`, in ♎ Ledger** (`kind: 'sort'`, so the tabula keeps its own body). Label
**SEAT** — four characters, well inside the ~8-character cap that curved socket labels have.

One socket rather than two destinations, because seating is ONE act with TWO arguments (which
wheel · which chart). Splitting it across ♓ Composite and ♎ Ledger would recreate on the back
exactly the two-doors problem the front just had.

**⚠ Parity check (the v0.878 bug).** ♎ Ledger goes from 7 items to 8. `_tabVals`'s `slot()`
floors, so an even count seats one socket right of top — this is fine but **must be looked at**:
♑ Gears sat dark for its entire life because nobody checked the ring after changing an item
count. Open the ring and confirm all eight sockets render before calling this done.

### 3 · The field

The seating field is the one place on the back that is a *bench* rather than a definition, so it
gets the `sort` tabula's full well (inset to the 132px column, 26px top/bottom padding).

Two zones:

**The two seats, at the top.** Two rows, THE PLATE and THE RETE, each naming its current
occupant. Tapping one makes it the target; the other dims. When the front's card sent you here,
that wheel arrives already targeted.

**The source list, beneath.** What can be seated depends on which target is armed:

- **Plate:** Natal me · Composite me (you × now) · an A×B mint, when one exists. Same three
  options `plateOpts` carries today, same taps (`_toggleComposite` / `_unmintCompositeAB`).
- **Rete:** The sky · No one · Synchronic me (the prism) · then the roster — people, events,
  horary — through `_setRete`. The roster is ♎'s own material and should read the same way it
  reads under the ALL socket, so a long roster scrolls in the well rather than being capped.

### 4 · The return

**Picking seats the chart and flips home. An automatic AEGIS.** Tap the card, tap the name, you
are back on the face with it seated — two taps, one turn out and one turn back.

The flip is the existing back→face transition; do not build a second one. AEGIS remains in its
socket for leaving without choosing.

---

## What must not change

- **`_setRete` stays the one door for the rete's occupant.** The socket calls it; it does not
  reimplement it. Every existing guard rides along: the stale-seat identity match, the `#3` swap
  drop, `seatPicker: null` in its patch (which becomes vestigial and should be removed with the
  rest of that state).
- **The mutual exclusions hold.** Prism on the rete and composite on the plate cannot both be
  seated (the same chart on both wheels would thread every bead to itself at 0°). Seating one
  releases the other, exactly as `reteOpts` does today.
- **`_reteSeated()` / `_reteFrozen()` / `_reteIsOther()` are untouched.** Three questions of a
  seat, three predicates; a seating UI is not a fourth.
- **Composite-me requires an engraved natal** (S3's stale-seat guard). A native with no natal is
  offered the engrave path, not a dead row.
- **The instrument survives it.** Nothing here runs on the RAF and nothing here may take the
  plate down.

## Register

The back is impersonal, third person, declarative, Georgia, engraved (grain, paired hairlines,
incised type, one light direction from above). Not "put my chart on the wheel" but "the chart the
plate is read from". **Orbo never uses the em-dash.** Middot instead, as the rim does.

## Definition of done

- All eight ♎ sockets render.
- A front card tap lands on SEAT with the right wheel armed.
- A pick seats and flips home in one motion.
- Prism and composite still cannot co-exist.
- No `seatPicker` state, no picker layer, no z:5 rung; veil back to 5, pane back to 6.
- A tap on either seat card does something visible in every reading state, including with the
  pane up. The gate that failed silently does not return in a new costume.
