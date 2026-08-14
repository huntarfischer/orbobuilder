# Orbo AstroLabe v0.878 — the synchronic engine, first light

Phase 4 Stages A and B, plus Stage C items 1–3 and 6. Plan of record:
`specs/Phase 4 - The Synchronic Engine.md`. Doctrine of record: `CLAUDE.md · Synchronic doctrine`.

## The headline

The white paper's phase formula was wrong, and correcting it removed a research project from the
critical path. There is no unwrapped trace from birth, no accumulation, no `numpy.unwrap`. Parity is
one line of wrapped arithmetic, a flip is transiting P opposite natal P, and the transits engine
already solved that exactly. What was blocking ♓ for two versions turned out to be two functions.

## Stage A · the axial triple

`framing.js` gained `phaseOf`, `axisOf` and `axialOf` — the whole triple: displayed point, axis (the
mod-180 storage coordinate), phase bit, permitted arc. `midpoint()` is untouched and remains the
display derivation.

The spine gained one door, `axialAt(jd, natal, lat, lon)`, which computes the triple off the genome's
own decode and memoizes it on the genome entry. Readers use `_axialAt(jd)`; nothing calls `axialOf`
directly and nothing reaches past the spine.

The triple does not ride *inside* `spine.at`, as the plan had it, because the genome is keyed on
`jd|lat|lon` and the triple also needs a natal. A door memoized on the entry keeps the single-door law
intact without polluting the genome cache key.

Verified against a real natal: at `T = N` the placement equals natal and phase is 0; parity toggles
exactly at `T = N + 180`; the displayed point's offset from natal never exceeds 89.99° across 3600
samples; both poles share one axis.

**One surprise worth knowing.** Phase resets silently at the return. Parity goes 0→1 at the opposition,
which is a flip, and 1→0 at `T = N`, which is not — the displayed point is continuous there. So there
is exactly one flip per cycle, and every flip record carries `phase: 1`.

## Stage B · flips as first-class events

`frameEvents` no longer fakes flips. The `d > 150` frame-to-frame jump heuristic is retired, along with
its day-quantised dates, and that function now emits sign ingresses only.

`flipEvents()` detects the parity change on a half-day grid and bisects the hinge to about a fifth of a
second. Each record carries the inversion on both sides — sign, house **and** dispositor, from and to —
because the inversion is the reading. It also carries `enter / hinge / exit`: a flip is a window, since
at the hinge neither pole has a privileged claim. Half-width is 1° of separation converted to time
through the local synchronic speed, which makes a lunar flip about three hours and a Jupiter flip about
nine days.

**Retrograde stutter is honoured as three events.** Confirmed on Mercury, which returns exactly three
per station (Sept–Oct 2028, Sept–Oct 2035), unsmoothed and uncollapsed.

Surfaced in **♐ Field**, the sixth fusible stream, described below.

Numbers: 17 flips in the coming year against a real natal, 13 of them lunar (matching the sidereal
month); worst hinge error 0.0002° from exact opposition; 43ms for a one-year scan.

### No body is excluded, and the first draft was wrong to exclude two

A first pass dropped Pluto and Lilith from the flip scan. Both exclusions were wrong, and wrong the
same way: an average was used to settle a question that is not about averages.

**Pluto flips, and it is the most consequential flip a life contains.** The ~124 year half-cycle that
justified dropping it is the MEAN, and Pluto's orbit is far too eccentric for a mean to rule here:
twelve years to cross Scorpio, thirty-two to cross Taurus. Measured against real natals, a native born
1946 to 1955 reaches transiting Pluto opposite natal Pluto at **age 83 to 86**, and it arrives as
**five events across about two years** as Pluto retrogrades back and forth over its own opposition.
The boomer generation is at or approaching its Pluto flip right now. For a native with Pluto as modern
chart ruler, that is not an edge case to compute away, it is the headline.

**Lilith stays in.** Its osculating apogee does oscillate its opposition into repeated crossings, 17
in eight years against a real natal. But that is the same phenomenon as retrograde stutter, which
doctrine already says to honour rather than smooth, and Lilith is not decoration to the natives who
read it.

The general law now stands in `CLAUDE.md`: **which bodies are in play is the reader's choice** (♊
Bodies, passed as `opts.bodies`). The engine does not decide for a native which of their own
placements deserve an event.

## ♐ Field · three kinds of synchronic event

Flips alone are a thin reading. `synEvents()` scans three kinds off one grid, and the ♐ socket's chips
toggle them individually (**flips · houses · contacts**, persisted as `synKinds`).

- **flip** — the placement reaches the end of its arc and is lived from the opposite pole. A change of
  government by inversion.
- **ingress** — the placement crosses a sign boundary. Because houses are natal whole-sign anchored to
  the natal ASC, **a sign boundary IS a house boundary**: one crossing carries both readings at once, a
  new manner and a new arena, and it hands the placement to a new dispositor. A change of government by
  ordinary motion. Rows read *"Mercury enters Gemini · house 7 to house 8 · answers now to Mercury."*
- **aspect** — two synchronic placements come to exact contact. Both move, each at half its own
  transiting speed, so unlike the same-body pair families these genuinely form, perfect and separate.
  Orbs from `synOrb`; the aspect set follows ♍ Aspects, so conjunctions and hard aspects alone is a
  matter of turning the soft ones off there.

**Every non-flip crossing is gated on the phase bit being unchanged** across the interval. A flip jumps
the displayed point 180°, which crosses sign boundaries and separations wholesale — counting those as
ingresses or contacts would be the old `d > 150` trap from the other side.

The Moon is out of the contact scan by default, exactly as the transits stream excludes her: at about
6.6°/day synchronic she alone outnumbers every other body combined. Her flips and ingresses still ride.

Bodies come from ♊ Bodies, aspects and orb from ♍ Aspects. 67ms for a 90-day window returning 60
events (24 ingresses, 29 contacts, 7 flips). `_exportFieldICS` writes flips as their window and
ingresses and contacts as instants.

## Stage C · what landed early

The closed-form parts, since they cost nothing once the triple exists.

- `beadFamily(a, b)` — the time-invariant same-body family `{δ/2, 180−δ/2}`, with its
  `selfComplementary` flag for the square.
- `beadMode(fam, φA, φB)` — the live mode by `φ_A ⊕ φ_B`, suppressed on a square, where a flip changes
  which side and not the class.
- `beadModeDays(fam, period)` — first-order durations, free and shown before any refinement. Verified:
  δ=60 on the Moon gives 4.55 and 22.77 days.
- `synOrb(angle, natalOrb)` — **synchronic orbs, halved and tapered.** At the natal default of 6°:
  3.0° conjunction and opposition, 2.5° trine and square, 2.0° sextile, 1.0° minors. ♍ Orb is the
  override, not the default.

Nothing here is scanned. It is all closed form, which is precisely why same-body and cross-body
contacts must not share one list.

## Still open for v0.88

Stage C items 4, 5, 7 and 8: cross-body contacts presented as a different kind of thing;
**un-anchoring the Crossing window**, which is the actual blocker on exporting a year; wiring the
families into ♐ Crossing with place-invariance stated in the UI; and the pair's film — composite A on
the plate, composite B on the rete, shared cursor. Stage D (governance chains, Bearer and Keeper,
dependency-triggered events) stays in v0.89. Stage E, ♓ Relation, lands with or after D.

Also carried: the cross scans still pass a hardcoded `orb: 3` and should move onto `synOrb`.

## Two old bugs the sixth stream exposed

Adding a sixth ♐ socket emptied the whole Almanac ring. `_tabVals`'s `slot()` centres the filled
sockets on the top by subtracting `(list.length - 1) / 2`, which is a **half-integer for an even item
count** — and the slot loop tests integer `j` only, so no socket ever matched and the ring came back
blank. `slot` now floors, seating one socket right of top on an even count.

This was never about Flips. **♑ Gears has four items and has therefore been dark on the ring since the
day the spread shipped** — Speed, Rim, Snap and Feel appear on it for the first time in this version.
Recorded in `CLAUDE.md` as a law of the spread: socket slots must land on integers, and the ring wants
a look after any change to an item count.

**Retrograde ingresses were landing up to 10.6 hours late.** The ingress bisection targeted `s2*30`,
the start of the sign being entered, in both directions. Going retrograde the boundary actually crossed
is the start of the sign being LEFT, so the target sat 30° away, the root was never bracketed, and the
bisection degenerated to returning the raw grid sample. Direction now picks the boundary, and
retrograde ingresses land within about a second of the true crossing, the same as direct ones.

**A placement parked on a cusp was reported as seven changes of arena.** A slow placement whose drift
near a boundary is comparable to its own libration crosses that boundary back and forth. The synchronic
Node drifts about 0.023°/day while the transiting Node librates ±0.1° (±0.05° synchronic), so parked
within 0.02° of 0° Aries it crossed seven times in six weeks, each one emitted as a full ingress and a
calendar event, doubled by the mirrored South Node. That is **not** the retrograde stutter doctrine says
to honour: a real stutter moves the point whole degrees across weeks, and these excursions were 0.002°
to 0.08°. A crossing is now PENDING until the placement takes up residence, clearing the boundary by
0.1°; the emitted timestamp is still the exact crossing, the one that stuck, and a crossing that
reverses before confirming emits nothing. The same confirmation guards contacts at 0.02°.

Measured: the Jul–Aug 2027 window goes from 17 Node/SNode rows to none, the Node's 400-day total falls
to one ingress and the South Node's to one, and **no legitimate ingress was lost** (Moon 88, Mercury 8,
Sun 7, Venus 5, Mars 2, all unchanged). Timestamps remain exact and contacts remain exact to 1e-5°.

**A contact row was reporting its scan tolerance as if it were a measurement.** `synOrb` is the
tolerance the scan searches within; the contacts it returns are *exact*, bisected to about 1e-5°. Rows
read "orb 2.5°", which a reader would take to mean two and a half degrees from exact. The field is
renamed `tol` with a comment saying what it is, and the row now reads **"synchronic contact · exact"**.

## Untouched by design
Nothing landed on the instrument. Every reading here is moonlight. The spine remains the sole owner of
time and the only door to the sky, the presentation clock is unchanged, and `framing.browser.js` was
regenerated from source rather than hand-edited.
