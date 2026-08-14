> **STATUS (2026-07-29): not superseded.** Stages A and B and Stage C items 1 to 3 and 6 shipped
> in v0.878. The remaining Stage C items (4, 5, 7, 8) and Stages D and E are **absorbed into**
> `specs/Phase 5 - The Loom.md`, which reframes them: three layers, one scanner, three target sets.
> Read this file for what the synchronic engine IS; read Phase 5 for what is being built next.
> Note also that Phase 5 retires the word "halved" from the doctrine: the midpoint is primary, and
> the factor of two is bookkeeping that lives inside the root-finder only.

# Phase 4 · The Synchronic Engine · plan of action toward v0.88

Written 2026-07-29, after Phase 3 closed at v0.875 and after the synchronic doctrine was settled in
conversation. Doctrine of record is the new **Synchronic doctrine** section of `CLAUDE.md`. Sources:
`docs/Field Theory Astrology for Orbo Timespine.md` (white paper), `docs/Synchronic Conversation -source
for the white paper-.md` (the transcript, which wins wherever the two differ),
`docs/Field Theory Astrology 2.0 - Levels.md`.

## The headline: this is much smaller than it looked

The plan I would have written a day ago had a research project at the bottom of it: unwrap every body's
longitude from birth, through every retrograde, to recover a cycle count, and only then compute a phase
bit. That is what the white paper's formula demands, and the white paper's formula is wrong.

Working the algebra against the transcript instead:

- The synchronic placement of body P never leaves the **180° arc centred on natal P**. Orbo already has
  that arc: `arcFor(natalLon)` in `framing.js`, centre = natal, ±90.
- The conventional minor-arc midpoint jumps **only** where transiting P opposes natal P. It is
  continuous through the return.
- Therefore `phase = norm360(T − N) >= 180 ? 1 : 0`, computed from **wrapped** longitudes. No trace, no
  unwrapping, no accumulation from birth.
- Therefore **a flip is transiting P opposite natal P**, which is an ordinary natal transit aspect that
  the transits engine already finds exactly.

So the axial-first check that has been blocking ♓ resolves into a two-line function and a relabelling of
events we already compute. Unwrapped longitude is still wanted, for cycle **index** ("the 14th Mars phase
of a life") and for continuous velocity, but it comes off the critical path entirely.

Second headline: **the fourth object already exists.** `_almCross` (DC line ~7194) is commented
"intersections stream · SYNCHRONIC SYNASTRY, windowed", it is ♐'s **Crossing** stream, it fuses to the
spine, and `_exportCrossICS` already writes a calendar. Crossing does not need to be built. It needs
three things it does not have: same-body flip events, the family/mode reading, and a window that is not
anchored to the present.

---

## Stage A · the axial pair on the genome

**SHIPPED v0.878.** `framing.js` gained `phaseOf` · `axisOf` · `axialOf` (the whole triple: displayed
point, axis, phase, permitted arc) beside the untouched `midpoint()`. The spine gained
`axialAt(jd, natal, lat, lon)` — a door that computes the triple off the genome's own decode and
memoizes it on the genome entry, keyed by the natal chart it is read against. Readers go through
`_axialAt(jd)`; nothing calls `axialOf` directly and nothing reaches past the spine.

Deviation from the plan below, deliberate: the triple could not ride *inside* `spine.at` because the
genome is keyed on `jd|lat|lon` and the triple needs a **natal** as well. Making it a spine door
memoized on the entry keeps the single-door law intact without polluting the genome cache key.

Verified against a real natal: at `T = N` the placement equals natal and phase is 0 · phase toggles
exactly at `T = N + 180` · the displayed point's offset from natal never exceeds 89.99° over 3600
samples · both poles share one axis · nothing downstream moved.

Worth recording, because it surprised the implementation: **phase resets silently at the return.**
Parity goes 0→1 at the opposition, which is a flip, and 1→0 at `T = N`, which is *not* — the
displayed point is continuous there. So there is exactly one flip per cycle, and every flip record
carries `phase: 1`.

<details><summary>original plan</summary>

1. `framing.js` gains, beside the existing `midpoint()` (which stays, unchanged, as the display
   derivation): `phaseOf(natalLon, transLon)`, `axisOf(natalLon, transLon)` returning the mod-180
   coordinate, and a re-export of the existing `arcFor` as the placement's permitted arc.
2. The **genome carries the triple** (axis · phase · displayed point) per body, computed once inside
   `spine.at`, per the TimeSpine law. No reader recomputes it and no reader reaches past the spine.
3. Correct the white paper in place with a footnote pointing at the CLAUDE.md derivation, so nobody
   re-implements `⌊(T̃−N)/360⌋` from the paper in six months.
4. **Law, stated in the source comment:** the axis is storage, never a second placement. The transcript
   retracted the counter-dispositor. One dispositor at a time.
</details>

Test: at `T = N` the placement equals natal and phase is 0 · phase toggles exactly at `T = N + 180` ·
displayed point never leaves `arcFor(N)` · nothing downstream of `spine.at` moves for existing sessions.

## Stage B · flips as first-class events

**SHIPPED v0.878.** `frameEvents` no longer fakes flips: the `d > 150` jump heuristic is retired and
that function now emits ingresses only. `flipEvents(natal, jdStart, jdEnd, posAt, opts)` detects the
parity change on a coarse grid and bisects the exact hinge to about a fifth of a second. Every record
carries the inversion on both sides — sign, house **and** dispositor, from and to — plus
`enter/hinge/exit`. Window half-width is 1° of separation converted to time through the local
synchronic speed, so a Moon flip is about three hours and a Jupiter flip about nine days.

Broadened the same day into **`synEvents()`**, which scans THREE kinds off one grid — flip, **ingress**
(a sign boundary, which for natal whole-sign houses IS a house boundary: new manner, new arena, new
dispositor, one crossing) and **aspect** (two synchronic placements coming to exact contact; both move
at half their transiting speeds, so these genuinely form). Surfaced as **♐ Field**, the sixth fusible
stream, with per-kind chips and `_exportFieldICS`. Non-flip crossings are gated on the phase bit being
unchanged, or a flip's 180° jump would be miscounted as an ingress and as a dozen contacts.

Verified: 17 flips in the next year against a real natal (13 lunar, matching the sidereal month) ·
max hinge error 0.0002° from exact opposition · from/to poles 180° apart · 43ms for a one-year scan.
**Retrograde stutter confirmed: Mercury returns exactly three events per station** (Sept–Oct 2028,
Sept–Oct 2035), unsmoothed and uncollapsed.

**No body is excluded.** A first pass dropped Pluto and Lilith; both were wrong. Pluto's ~124 year
half-cycle is the MEAN, and its orbit is far too eccentric for a mean to rule: a native born 1946 to
1955 hits Pluto opposite natal Pluto at **age 83 to 86**, arriving as five events across two years, so
the boomer generation is at its Pluto flip right now. Lilith's osculating oscillation is the same
phenomenon as retrograde stutter, which doctrine honours rather than smooths. Which bodies are in play
is the reader's choice (♊ Bodies), passed as `opts.bodies`.

<details><summary>original plan</summary>

1. Retire the `d > 150` heuristic in `framing.js`'s `frameEvents`. A flip is a **parity change**, and its
   exact time is the exact opposition of transiting P to natal P, found with the same bisection the
   transits engine already uses for natal aspects.
2. **Honour retrograde stutter, as THREE EVENTS** (ruled 2026-07-29). A body stationing near its own
   opposition flips, unflips and flips again, and the transits engine already returns multiple exacts for
   a retrograde pass. Do not smooth it, and do not collapse the group into one event with three exacts:
   nothing else in Orbo has that cardinality, and a calendar should not invent one. Each of the three
   carries its own approach · hinge · departure window, so during a station the windows overlap. That
   smear across the whole retrograde passage is itself the signature, and it reads correctly as what it
   is: three changes of government in quick succession.
3. **A flip is a window, not an instant**: approach · hinge · departure, an interval with a centre.
   At the hinge neither pole has a privileged claim.
4. **A flip record carries the inversion**, because the inversion is the reading: from-sign and to-sign,
   from-house and to-house, from-dispositor and to-dispositor. For a Scorpio rising, Gemini to
   Sagittarius is 8th to 2nd is Mercury to Jupiter, and the record should say all three.
5. Retrograde and synchronic speed come from **ephemeris speed, halved**, never from differencing
   consecutive frames.
6. Nested clocks: per-body flip cadence is a property worth stating (a lunar flip reorients attention, a
   Saturn flip inverts the architecture of a decade). The outer planets may never flip in a lifetime, so
   do not scan for a Pluto flip.

Copy law for this stage: a flip is a **reformulation, not a new subject**. The concern reached the end of
one phase and is being lived from a newly oriented position.
</details>

## Stage C · the pair spine, and the calendar that was asked for

The payoff. This is the stage that produces "put the moment our Moons turn from trine to sextile on my
calendar, and tell me how that changes us."

**PARTLY SHIPPED v0.878, items 1–3 and 6.** `beadFamily(natalA, natalB)` returns the time-invariant
family `{δ/2, 180−δ/2}` with its `selfComplementary` flag; `beadMode(fam, φA, φB)` selects the live
mode by `φ_A ⊕ φ_B` and suppresses the display on a square; `beadModeDays(fam, period)` gives the
first-order durations (verified: δ=60 on the Moon → 4.55 and 22.77 days). Nothing is scanned — it is
all closed-form, which is exactly why same-body and cross-body contacts must not share one list.

**Synchronic orbs are in** as `synOrb(angle, natalOrb = 6)`: half the natal orb, tapered by aspect
strength via `SYN_ORB_FACTOR`. At the default natal orb of 6° that is **3.0° conjunction and
opposition, 2.5° trine and square, 2.0° sextile, 1.0° minors**. The ♍ Orb socket remains the
override. Note the cross scans were already passing a hardcoded `orb: 3`, so the layer was half
honouring this by accident; they should be moved onto `synOrb` when items 4–5 land.

Still open: items 4 (cross-body presented as a different kind of thing), 5 (un-anchor the Crossing
window — the actual blocker on exporting a year), 7 (into ♐ Crossing, place-invariance stated in the
UI), 8 (the pair's film).

1. **Same-body contacts as a distinct object.** Separation is fixed at half the natal separation, so
   compute the family `{δ/2, 180−δ/2}` once per pair per body and never re-scan it. Current mode is
   `φ_A ⊕ φ_B`. Next mode shift is the next flip of **either** body, which is a merge of two flip streams
   from Stage B.
2. **Square is self-complementary.** Family `{90,90}`: suppress the mode display. A flip changes which
   side, not the class, and announcing a change there would be a lie.
3. **First-order mode durations are free** and should show before any exact refinement: two natal
   positions δ apart split the transiting body's cycle into δ/360 and (360−δ)/360. For the worked Moon
   example, roughly 8.8 days and 18.5 days.
4. **Cross-body contacts stay as they are** (they genuinely form, perfect and separate) but are presented
   as a different kind of thing. One undifferentiated list of both kinds is wrong.
5. **Un-anchor the Crossing window.** Today's comment concedes that exacts are scanned about the present
   "so a window far from now is rightly bare". That is the actual blocker on exporting a year. Same-body
   flips solve at any epoch for free; the cross-body scan needs its anchor parameterised.
6. **Orbs halve on this layer.** Natal orb defaults are too wide for synchronic contacts. New defaults,
   with the existing ♍ Orb socket as the override.
7. Into ♐ Crossing and out through `_exportCrossICS`. State the place-invariance in the UI: this calendar
   is a function of two birth charts and time alone, so both people export identical events.

8. **The pair's film** (added 2026-07-29). The solo chronology is the composite on the plate and the
   transiting sky on the rete. The pair's film is exactly parallel: **composite A on the plate, composite
   B on the rete**, threads between, played through. The hardware exists already, including the
   inter-chart thread family (violet for a person, pale stone for an event), so seating a person on the
   rete and scrubbing is already this experience. The delta is a play mode with a meaningful step, the
   Stage B and C events surfacing as the playhead passes them, and Crossing's list synced to the head.

   **What drives the two charts** is the only real decision, and there are three candidates:

   | Candidate | Verdict |
   |---|---|
   | **Shared cursor, no anchor.** One instant, both natives, continuous rather than day-stepped. | **Default.** Cancellation holds, so families stay fixed and flips stay exact. Both cASCs wander, but doctrine forbids housing off a derived ASC, so the wander is cosmetic. Needs no protocol at all. |
   | **A's anchor, both natives.** One instant, so the backbone survives; A's horizon stays clean the way the solo film's does, and B is read as standing in A's hour. | Named alternate, wants a swap control since it does not commute. This is the asymmetric reading: *my life, with you in it.* |
   | **Each native on its own anchor, day-indexed.** | **Rejected.** The two frames are hours apart and were never simultaneous, so cancellation breaks and same-body separations wobble by up to about 6.6° on the Moon purely from the anchors disagreeing. That is an artifact of sampling, not a reading. |

The reading, which is the point: not "Moon trine Moon, 2°" but "Moon to Moon: sextile and trine family,
currently trine-mode, shifts Tuesday 4:12pm", plus what the shift means. Trine-mode is ambient and
self-sustaining. Sextile-mode is equally supportive but wants participation. The bond does not cycle
between harmony and conflict, only between two modes of coherence.

## Stage D · governance, the reading layer (v0.89)

Deferred out of v0.88 deliberately: Stages A through C are geometry and can be verified, this is
interpretation and wants the geometry settled first.

1. **Two named chains**, not one generic graph: the **agency chain** (natal ASC ruler) and the **light
   chain** (sect light). Every dispositor in them is synchronic, never natal and never transiting.
   `dispositorChain(startBody, compPos)` already takes composite positions, so it is already correct.
2. **Bearer** (immediate dispositor) and **Keeper** (terminal ruler, or the loop it closes into) per
   chain. Two-planet loop is **mutual reception**; three or more is a **dispositor loop**.
3. The charged event: **Keeper of Agency equals Keeper of Light**. Action and perception governed from one
   centre. This is a computable, nameable, rare event and it is the resolution of the old unresolved
   "keeper of the light" idea.
4. **Governor-condition change is a dependency-triggered event.** A placement can develop significantly
   without moving, because its governor moved. This is the one place the event engine's *shape* has to
   change: it cannot be a per-body scan, each placement must watch its current governor.
5. **Cross the two edge types.** Answering to a planet while squaring it means the concern must route
   through a function it is currently fighting. Both edges already exist; nothing has ever multiplied
   them, and it is the most readable sentence available for the cost.
6. Traditional rulership stays the backbone. Moderns are co-governors, never chain branches.
7. The pane's sentence, at last: *my life is currently mobilized around [house], through the manner of
   [sign], under the terms established by [dispositor and its condition]*.

## Stage E · ♓ RELATION, unblocked, and place-free

v0.875 shipped ♓ Composite with three sockets (Moment · Chronicle · Synastry) and recorded a deliberate
omission: no RELATION socket, "because a person × person composite needs the engine, and a dead socket
would be worse than an absent one." That reasoning no longer holds.

**The composite already exists.** ♎ Ledger already mints person × person: two saved people to one frozen
midpoint entity that joins the roster as `kind: 'pp'`, rose-gilt, seatable on the rete, with a cascade
delete so a mint cannot outlive either parent. The object was never the missing piece.

**The synchronic stack does not care that a native is derived.** Every operation in Stages A through C
needs a set of natal longitudes and a natal ASC. A `pp` mint has both.

**No geodetic midpoint. No Davison** (ruled 2026-07-29). An earlier draft of this plan proposed giving a
relationship the great-circle midpoint of its parents' birthplaces. Rejected: that is a Davison-style
time-and-space average, a different object from a midpoint composite, and it would weaken the geocentric
grounding of the whole instrument by casting charts at a horizon neither person ever stood under. Every
horizon in Orbo is a real one.

**A relationship therefore needs no place at all**, because everything a place would buy is either
derivable from the composite's own Sun and horizon, or already forbidden:

| What | Where it comes from |
|---|---|
| Sect (day or night) | Composite Sun above or below the composite ASC. Chart only. |
| Fortune and every other lot | `lots(asc, isDay, pos)` already takes exactly asc, isDay and positions, and no place. Already true in the code. |
| Houses | The composite's own ASC sign, natal whole-sign, fixed. |
| Flips, families, dispositors, chains, aspects | Bodies only, so time only. |
| A *synchronic* cASC for the relationship | The one thing a place would buy, and doctrine already forbids re-housing from a derived ASC. It was never usable. |

**So RELATION ships live, and place-free:** an `item` socket in ♓ whose field defines what a relationship
composite is, seating the `pp` mint as the reading subject, offering **Moment**, **Synastry** against a
seated person, and its **own flip stream**. Ring label **Relation**, six characters, inside the ~8
character cap.

**Chronicle stays dark for a `pp` mint, and that is not a loss.** The daily anchor is definitionally
place-bound (when does this degree rise *here*), and a mint treated as ONE derived native has nowhere, so
the socket blocks with real copy the way ♓ Synastry already does rather than sitting as a dead recess.

But the framing "a relationship has no place" was wrong: **a relationship has two places.** The film of a
pair exists, and it comes from holding both natives distinct rather than deriving a third, which is also
truer to the field theory since the natives never disappear under the composite. That object is **Stage C
item 8, the pair's film** (composite A on the plate, composite B on the rete), and it is the better
object. So the pair's chronology is not withheld; it simply is not a property of the mint.

---

## Sequencing

- **v0.878** = Stage A, Stage B, Stage C items 1–3 and 6. Shipped.
- **v0.88** = Stage C items 4, 5, 7, 8. The un-anchored Crossing window, then the pair's film.
- **v0.89** = Stage D. Governance and the reading layer.
- **Stage E** lands with or after D, since RELATION is most interesting once the chains exist.

Carried from Phase 3 and still open, unchanged by this plan: the **occulter**
(`pane.occulter = {id, needs, surface, render}`) and the **cohesion sweep** (pill buttons out of the
pull-up and the sub-arcs; the back is already clean).

## Standing constraints this plan must not break

The TimeSpine law (the spine is the sole owner of time and the only door to the sky; the axial triple is
computed inside `spine.at`, never in a reader). The presentation clock (one `dt`, one RAF; springs never
hold sky-time). The instrument-survives-everything law (per-layer fuses; a broken engraving must not
blank the wheel). The standalone-export law (every dependency a plain `script src`; rebuild and confirm
every `script[src]` is a `blob:` URL before shipping). The sun and moon law: none of this lands on the
instrument. Every reading here is moonlight, and the ways of looking belong to the pull-up. Regenerate
`framing.browser.js` from `framing.js` after any change; never hand-edit the browser build. And Orbo
never uses the em-dash.
