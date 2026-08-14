# Prompt · Phase 6 · P7 · synastry

*Proves:* two arcs on one machinery, and the locality result stated to the reader rather than discovered
by them.

Plan of record: `specs/Phase 6 - The Synchronic Prism.md` §8, §5, §7, §9, §11.4, §13. Predecessors: P0,
P0b, P1 (v0.892), P2 (v0.893), P3, P4 (v0.894, prism CODEC 3), P5, P6. Nothing here is built.

---

## 0 · What P7 is, and what it is not

Two natives, two arcs, one sky, **and no new engine.** Same-body separations remain time-invariant, so
only cross-body relations and the flips move. The machinery for all of it exists: `buildPair`, the
families, `scoreMomentSynastry`, the two-slot wheel.

**So P7 is almost entirely a doctrine and expression phase, not a computation phase.** The one genuinely
new result in it is a negative one, and it is the reason the phase is last.

## 1 · THE CLOCK BREAKS THE SYNASTRY CANCELLATION

§8, and the one genuinely new doctrinal result in the whole plan. State it precisely, because everything
in P7 follows from it:

- The synastry law holds because body longitudes are **geocentric**: they depend on time alone, so
  `T_A = T_B`, the sky term cancels, and two people export **byte-identical** flip calendars.
- **That cancellation is over BODIES.** The sASC is an **ANGLE**, and angles depend on place. So
  `sASC_A − sASC_B` retains `(skyASC_A − skyASC_B)/2` and **does not cancel.**

**Consequence, and it is the phase's headline:** two people in different cities have synchronic
Ascendants that drift apart through the day, and **two people in the same room share theirs exactly.**

Everything else Orbo computes is place-invariant by law. The clock is the one layer in the instrument
where being in the same place is the entire content, which is also why it is the electional layer.

**This must be STATED to the reader, not left to be discovered.** The failure mode is concrete and
embarrassing: two people compare their readings, get different answers, and conclude the instrument is
broken, when the difference IS the reading. The bar: a reader who has only ever seen the pane, never the
spec, must be able to say why their answer differs from their partner's.

## 2 · What is invariant and what moves, as a table the build must honour

| quantity | over time | over place | why |
|---|---|---|---|
| same-body separation `sP_A − sP_B` | **fixed forever** | **fixed** | `(natalA − natalB)/2`; the sky term is the same term on both sides and cancels exactly |
| its family `{δ/2, 180−δ/2}` | fixed | fixed | `beadFamily`, settled at engrave |
| its **mode** | alternates | fixed | selected by `φ_A ⊕ φ_B` |
| cross-body relation `sA − sB` | **moves** | fixed | retains `(skyA − skyB)/2`, a difference of two different bodies |
| flips | move | **fixed** | a flip is transiting P opposing natal P, bodies only |
| **`sASC_A − sASC_B`** | moves | **MOVES** | an angle, not a body. §1 |

P2 measured the first row at **0.000000000°** across 14 bodies × 400 days, and measured the
plausible-looking wrong version (intra-chart pairs) drifting **50.49°**. **A family is two natives, never
two bodies.** `build(natal)` correctly has no family table, and that absence is correct rather than
missing. Do not add one.

**Same-body and cross-body must look different in Orbo.** One list for both kinds is wrong: a same-body
pair can only ever form its two family marks and only the mode alternates; a cross-body pair genuinely
perfects and separates. **The square is self-complementary** (`{90,90}`), so suppress the mode display
there: a flip changes which side, not the class.

## 3 · The frame question, already settled and easy to get wrong again

Doctrine is explicit and P7 must not re-litigate it:

- **Synchronic synastry** is `(natal A × moment at A's birthplace) × (natal B × moment at B's
  birthplace)`, both at the **SAME instant**. One instant, two horizons.
- The engine already encodes the split: `positions(jd)` takes time alone, `angles(jd, lat, lon)` takes
  time and place. `scoreMomentSynastry(natA, natB, jd, posAt, ...)` is **already correct** (one
  `posAt(jd)`, both natals).
- **No frame protocol.** A pair contact is an ANGLE and needs only time. The same-ascendant anchor is a
  **SOLO** protocol, definitionally unshareable, since two natives cannot both be on their own anchor at
  one instant. Crossing therefore never needed one.
- **Each-native-on-its-own-anchor is FORBIDDEN:** the frames are hours apart, never simultaneous, and
  same-body separations wobble by up to **~6.6°** on the Moon from the anchors disagreeing.
- **A's-anchor-for-both is a NAMED asymmetric alternate** ("my life, with you in it"). It does not
  commute. Do not build it by accident, and if it is built, label it.
- **Keep the layer geocentric by law.** A topocentric toggle would break the cancellation for the Moon
  through parallax, and the Moon is the body the synastry spine cares most about.

**`_reteIsOther()` is the gate.** The prism is ME refracted and is never a partner: handing it to a
two-native reader applies the synchronic operator a second time, `midpoint(natal, midpoint(natal, sky))`,
which is not a doctrine object and **returns 21 plausible rows instead of an error** (measured, before the
gate was split). P7 is the phase most likely to reach for the prism as "them". It must not.

## 4 · The two arcs

The pair's version of P4's dial. Each native has an arc centred on their own natal degree, and the
reading is the two arcs held against each other:

- Each native's walk σ is read from **their own** nASC and **their own** horizon. Two walks, one instant.
- **In the same place the two walks are identical in rate and offset by a fixed amount** (their natal
  Ascendants differ by a constant), so the pair's sASC separation is fixed. **In different places the
  walks diverge**, and the divergence is §1's residual made visible. This is the single best expression of
  the locality result available, because it is watchable rather than asserted.
- **The instrument already draws it:** composite A on the plate, composite B on the rete, per the seating
  law, driven by a **shared cursor with no anchor**. Whatever is seated on a wheel rides that wheel's
  track. **No third ring, ever.** The plate's occupant draws at `rN`, the rete's at `rBody`.
- **The frame is always the plate's.** One horizon, one meridian, one house grid, from the plate's angles.
  B's angles are ordinary occupants on the rete's track. Two `As` chips never collide because they sit on
  different tracks: geometry, not de-confliction.
- **Both tracks are drawn by `_drawLitTrack`.** There is one lit-track routine and `skyOn` selects a
  treatment nowhere. Material follows the wheel, not the occupant.
- Web lines are solid and coloured by **harmony family** (`_webColor`). Geometry carries chart membership;
  line style carries nothing.

## 5 · Expression

- **The tabula:** ♓ Composite already holds `Synastry`. P7 does not add a socket; it gives that item its
  synchronic present tense. If an item count changes, the even-count check applies (`slot()` floors; ♑
  Gears shipped dark for exactly this). Review path:
  `__orbo.setState({ flipped: true, panel: 'composite', tabSel: 'synastry', depth: 'scholarly' })`.
- **Depth is a property of moonlight:** L1/L2/L3, first-person spoken voice on the pane, impersonal
  third-person declarative in the back's field. Georgia engraved on the back, the sans on the pane.
- **Qualification, twice over.** Every house is qualified (natal house vs synchronic house, §13.1) and
  every lord is qualified (`rising lord` for the sky's, **Synchronic Ascendant Ruler** for the
  synchronic one, §11.4). In synastry the zodiacal aspect is shared but **the topic is native-specific**,
  so alignment does not require the same topic, and a row that shows one house for a shared aspect is
  wrong.
- **The locality statement is a first-class piece of copy**, not a footnote. Two people in the same room
  share a clock; two people apart do not. Where the pair has two places, say so on the reading itself.
- **Always the Ring's word for the mark.** "Contact" is the loom's LAYER name and never stands in for an
  aspect.

## 6 · Refused

- Any synchronic row on the spine, any fuse. Upheld through P2 to P6.
- A refraction table; a second refraction path. `framing.refract` is the one door and must stay greppable.
- Re-housing a synchronic placement from a derived Ascendant, in any reading, ever.
- **Davison, or any invented horizon.** A derived chart is never given a geodetic midpoint place or any
  other place neither native stood under. A composite has a Sun and a horizon, which give sect, which
  gives all eight lots (`lots(asc, isDay, pos)` takes no place). **A relationship needs no place.**
- A pp mint's **composite chronology**: the daily anchor is definitionally place-bound, so Chronicle stays
  dark on one rather than being faked. Same for the ledger and the query.
- Each-native-on-its-own-anchor. §3.
- A topocentric option on this layer. §3.
- **Any new drawing on the instrument.** P1's proof obligation and the standard since; the hardware for
  the two arcs already exists and P7 must use it rather than add to it.
- The counter-dispositor. The axis is storage, never a second placement; one dispositor at a time.

## 7 · Acceptance

`tests/prism.test.html` gains a P7 section (85 on that page after P4, 938 total, plus P5's and P6's).

1. **THE CANCELLATION, MEASURED IN BOTH DIRECTIONS.** Same-body separations for a real pair hold to
   **0.000000000°** across 14 bodies × 400 days (P2's bar, re-asserted on the pair path). And
   `sASC_A − sASC_B` **fails** to cancel: report the measured drift across a day for two natives in
   different cities, and assert it is nonzero and grows. **Both numbers in the suite**, because the second
   is the phase's headline and an untested claim is a comment.
2. **Same place, same clock, exactly.** Two natives given identical lat/lon have a sASC separation that is
   constant across the whole day to numerical tolerance, and equal to half their natal Ascendant
   difference. This is the sentence the copy makes, asserted as arithmetic.
3. **One instant, two horizons.** Assert both natives are read at the same jd, and that swapping only
   longitude changes angles and leaves every body longitude untouched.
4. **Commutation:** A × B equals B × A for every same-body family and every cross-body mark. And assert
   the asymmetric alternate does **not** commute, so the two cannot be confused.
5. **Anchors are refused for pairs:** assert no pair reading consults `findAscAnchor`, and that a
   both-on-own-anchor construction is absent. If a test constructs it to measure the ~6.6° Moon wobble,
   label it as the forbidden object.
6. **The prism is refused as a partner:** `_reteIsOther()` returns false for it, the synastry grid reports
   `reason: 'pair'`, and **zero** rows are produced. Pin the count at zero; it was 21 before the gate.
7. **Flips are place-invariant:** two natives at different places export byte-identical flip calendars,
   asserted as a byte comparison, not a spot check.
8. **Same-body rows show a family and a mode; cross-body rows show a perfection**; the square suppresses
   its mode. Orbs are halved on this layer.
9. **No unqualified house and no unqualified lord** in any output, and a shared aspect carries a
   native-specific topic on each side.
10. **The instrument is unmoved:** natal-solo and live-sky renders byte-identical, per P0b. No third ring
    is drawn; both tracks come from `_drawLitTrack`.
11. Nothing written to the spine, no event table row, `fertilize.CODEC` unmoved.

## 8 · Hygiene owed

- `prism.js` / `prism.browser.js`, `framing.js` / `framing.browser.js`, `loom.js` / `loom.browser.js` are
  hand-maintained mirror pairs with **no generator**. Mirror in the **same turn** and verify by running
  `tests/prism.test.html`, `tests/loom-algebra.test.html` and `tests/loom.test.html`.
- Snapshot `archive/Orbo Astrolabe YYYY-MM-DD.dc.html` before the first DC edit.
- Version to v0.897 (assuming P5 took 0.895 and P6 took 0.896).
- No em-dash, anywhere, including the write-up.

## 9 · Suggested order

The cancellation tests first, before any UI: they are cheap, they are the phase's actual content, and the
divergence number is what the copy has to be written against. Then the two arcs on the existing two-slot
wheel, which should require no drawing work if P0b's seating law held. Then the pane's rows. Then the
locality copy last, written against the measured number rather than the doctrine sentence.

## 10 · A note on why this is last

P7 needs P5's ledger to have a row shape and P6's query to have settled the engine path, and it needs
P4's pole to be exact, because a pair reading multiplies any residual error by two natives. It is also
the phase where the plan's one new doctrinal result gets built, so it wants everything under it measured
rather than assumed.
