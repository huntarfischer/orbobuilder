# Build order — `ring.js`, the zodiac wheel as an artifact

Paste this whole file as the opening message of a fresh chat. Read `CLAUDE.md` first; it is the
law. This file adds the part of the law that is not yet written down, then asks for one module.

---

## 1. What the Ring is

**The Ring is the zodiac wheel itself: a flat circle of 360 positions.** No bodies, no time, no
native, no place. It is a reference surface, not a computation and not a cache.

Three things are PLACED on it:

- **mundane** — the sky. Moving, place-free, nobody's.
- **natal** — the engraved birth chart. Fixed forever at engrave.
- **synchronic** — derived from those two, confined to its 180 degree arc.

Angles (ASC, MC) are placements too, with one difference: they depend on PLACE, and they sweep
the entire wheel daily instead of crawling.

**The Ring holds the geometry BETWEEN positions, not just the positions.** Every aspect, major
and minor, is an offset on the wheel, and the offsets belong to the wheel rather than to the
planets sitting on it. 0 is square 90 whether anything is there or not. 1 is square 91. This is
why ONE Ring serves all three placements: they contribute positions, the wheel contributes every
relation between them.

## 2. The Ring already half exists, in AstroDNA

This is the part that must not be missed, and the reason this module is a FORMALIZATION rather
than a new idea.

`astrodna.js` already encodes every node as a position on the Ring plus a direction bit:
`encodeValue` gives **1–360 direct, 361–720 retrograde**. `nodes` is the full-precision decode
surface; `sequence` is the compact 1–720 genome. `spine.at(jd, lat, lon)` returns that genome and
is the sole door to the sky (the July 12 law in CLAUDE.md).

So: **the genome is a placement on the Ring.** The 720 encoding is the Ring with direction. The
integer position is the Ring cell; the residual comes from `nodes`' full precision. Build `ring.js`
to make that explicit, and make `astrodna` read the Ring rather than keep its own copy.

Corollary already banked: synchronic velocity is exactly half transit velocity and carries the
SAME SIGN, so a synchronic placement retrogrades exactly when its body does, and the embryo's
shipped stations and retrograde periods give synchronic direction for free.

## 3. The five rules of the Ring

1. **The Ring contains NO ORB.** It returns an offset and a **residual**; orb is a threshold
   applied to that residual by the caller. The Ring is immutable, orb is a comparison. This is the
   read-time-cut law (embryo, fertilization) expressed as geometry: choosing an orb can never
   invalidate the embryo, a weave, or a century of anything.
2. **Every aspect is an offset — majors and minors alike.** No major/minor distinction inside the
   Ring. That distinction is a CUT (which offsets a reader admits) and a TAPER (how much residual
   each is allowed). Both live outside, on ♍ Aspects.
3. **Each of the 360 positions is owned by exactly one offset**, its nearest. The Ring is therefore
   a partition, and "is this an aspect" is one read plus one comparison, never a search over twelve
   definitions.
4. **The Ring carries its own involution.** Adding 180 maps every offset to its supplement:
   conjunction↔opposition, sextile↔trine, square↔square. The square is the only fixed point. This
   is the flip, and it belongs to the Ring, not to flip code.
5. **The Ring is declared, not derived.** A printable artifact: 360 rows, offset owner, supplement.
   The one table in Orbo that is never rebuilt, never keyed, never versioned per chart.

## 4. What the layers actually are

Not four engines. **One wheel, one set of offsets, and a choice of which placements you read
against each other.** A layer differs in exactly two ways: its OPERANDS and its ORB BUDGET.

| layer | operands | budget |
|---|---|---|
| mundane | two sky positions | full |
| natal | one sky, one natal (fixed) | full |
| synchronic | two synchronic positions | half, tapered (`synOrb`) |
| bridge | one synchronic, one mundane | argue it; one operand moves at half speed, one at full |

The Ring must not be able to tell a fixed operand from a moving one. A natal position is just a
position that does not move.

Same-body synchronic pairs stop being special: they are the Ring read on a pair whose separation is
fixed, which is exactly why only the MODE alternates and why the square is self-complementary
(`beadFamily` / `unionSepClass` in `framing.js`). Rule 4 IS that rule.

## 5. Reading versus timing

Both point at the Ring, and keeping them distinct is what stops a second scanner being written.

- **What is this, now** → forward. Evaluate operands, read the Ring, compare residual to the
  layer's budget. One code path for all four layers.
- **When does this happen** → inverse. `loom.js` scans MUNDANE space for the Ring's offsets
  transformed into mundane space by the layer's weights: `(1,0)` ingress and station, `(1,−1)`
  contact, `(1,−2)` bridge. Monotone operands (angles) INVERT instead of scanning — the ASC never
  reverses, so you evaluate the rising-time curve at a degree rather than bisecting for it.

**Never scan synchronic space.** The synchronic placement jumps 180 at a flip; mundane space is
continuous, so in mundane space a flip is one target of its own and cannot be miscounted (this is
what deleted the v0.878 phase gate — see CLAUDE.md).

## 6. What `ring.js` must export

Names are yours; the shape is not.

- the 360-cell partition: position → owning offset
- `aspectAt(sep)` → `{ offset, word, residual, class }` — orb-free
- `supplementOf(offset)` — the involution
- the offset set, majors and minors, as the single source of truth
- **a SEPARATE export** for orb budgets (layer × class → scale), so the Ring itself stays orb-free

Resolution: the partition is integer-degree (matching astrodna's gene), residual is computed
exactly from full-precision longitudes. Do not quantize the residual — residency guards are 0.1
and 0.02 degrees and emitted times are exact crossings.

## 7. What this DELETES, which is the point

There are currently FIVE aspect definitions in the project. Find them all and collapse them:

- `astrodna.js` `ASPECT_DEFS` — orbs 7/7/5/5/4 baked in, **no minors**
- `framing.js` `synOrb` — becomes the synchronic layer's budget, not its own engine
- `transits.js`, `luna.js`, `loom.js` — their own lists and any surviving hardcoded `orb: 3`

Also collapse `loom.js`'s three scan modes (`lon`, `sep`, and the `mix` I was about to add) into
ONE weighted form over at most two mundane longitudes compared against a constant. `(1,0)` and
`(1,−1)` must reproduce current output byte-for-byte before `(1,−2)` lands.

Every event record then has one shape: **(root time, offset, residual, layer, operands)** — read
by the ICS export, the pane rows and the almanac alike.

## 8. Order of work

1. `ring.js` + budget table. Tests: the partition covers 360 exactly once; the involution is an
   involution; the square is its only fixed point; residual is exact.
2. Rewire readers onto the Ring, delete the five duplicates. Behaviour-preserving — the existing
   test suites are the check, and `astrodna`'s sequences must stay bit-stable.
3. Collapse `loom.js` to the weighted form, `(1,0)`/`(1,−1)` byte-identical to current output.
4. Land bridge as `(1,−2)`: bodies scanned, angles inverted. Small addition, not a stage.
5. Regenerate every `.browser.js` touched. Never hand-edit a browser build.

Do NOT start on step 4 or 5 in this session. Ring first, standing and tested.

## 9. Doctrine to write down while you are here

These were settled in conversation on 2026-07-30 and are not yet in the docs. Put them in
`docs/Field Theory Astrology for Orbo Timespine.md`, with the short forms in `CLAUDE.md`.

- **Orbo runs on celestial time.** The ASC, Moon and Sun are set LARGER than the date and time
  because they are the primary clock; the calendar is the annotation. Human time is the translation
  layer, offered because we live in it. This is why the spine owns `jd` and not a wall clock, and
  why the pull-up's sentence names house, sign and dispositor rather than an hour. The type
  hierarchy on the face is the evidence; state it as a law with a display corollary.
- **A flip happens AT THE SQUARE to the natal placement.** The arc is natal ±90, so its two ends
  ARE the two squares. A flip is the placement at its waxing square taking the only other position
  available to it — the waning square — and the 180 it adds is the distance between them. Prefer
  this definition to "transiting P opposes natal P": both are true, but this one is stated in the
  space the event lives in, and it explains why the arc is 180 wide.
- **A flip replaces that placement's ENTIRE aspect set with its complement**, in one instant,
  across every layer at once: its natal contacts, its synchronic contacts, its bridge angles. What a
  flip MEANS therefore depends on everything else the placement now aspects. It is not a caveat, it
  is the mechanism, and rule 4 is where it lives.
- **The flip is the one relation that is not an offset.** Layers are nouns (floor, contact,
  synchronic, bridge); aspects are the verbs (conjunct, sextile, square, trine, opposite). A row
  reads *synchronic Mars trine transiting Saturn*. A flip is a placement reaching the end of its own
  permitted arc, so it is the exception, and should read as one.
- **Parity** goes 0→1 at the opposition (the flip) and resets 1→0 at `T = N`, which is NOT a flip —
  the displayed point is continuous there. One flip per cycle. Say this explicitly so nobody reads
  the wrap at 720 as a second event.

## 10. Terminology — strike "union"

The word came in with the Phase 5 plan and is not in the glossary. **The layer is synchronic.**
`unionToSky`, `skyToUnion`, `unionIngressTargets`, `unionFlipTarget`, `unionSep*`, `unionTargets`,
`layer: 'union'` on every weave row, the fertilize codec and three test files all rename to `syn*`
— matching `synOrb` / `synEvents` / `synKinds`, which already speak correctly. The row tag lives
inside stored bytes, so `fertKey` moves and existing weaves rebuild once. Accept that.

Also: **Orbo never uses the em-dash**, anywhere, including in write-ups and chat.

## 11. Where S6 stands

The plan of record calls S6 "the one genuinely new root-finder in the phase." **That is wrong and
should be corrected in `specs/Phase 5 - The Loom.md`.** Substituting the synchronic map into the
bridge relation gives

```
syn(P) − sky(Q) = θ     →     S_P − 2·S_Q = 2θ − N
```

a fixed linear form in mundane longitudes with the natal as a constant. Continuous, no midpoint
evaluated per sample, no 180 jump dragged into the scan, no guard needed. S6 adds a COEFFICIENT,
not a scanner. Same-body bridge is excluded: `syn(P) − S_P = (N_P − S_P)/2`, an ordinary natal
aspect at double the angle that the contact layer already finds.
