# Prompt · Phase 6 · P0b — seating (the law the prism inherits)

Plan of record: `specs/Phase 6 - The Synchronic Prism.md`, §12. P0 is done (v0.889): a solo derived
chart draws its own web. This pass is the layout law that follows §2.1's ruling that a derived chart is
a chart that gets SEATED — so how two seated charts are drawn is the law the prism inherits the day it
exists. Function only, per the 2026-08-06 ruling deferring §12.3 (materials) and §12.6 (the legend,
metal tinting) to later. This pass builds §12.2, §12.4 and §12.5 only.

Do NOT touch materials, metal, or card tinting in this pass. Do NOT build the prism, sASC, or any
Connectome table. This is purely: where things sit, whose angles frame the wheel, how the web reads.

---

## 0 · Before anything

- Snapshot first: `archive/Orbo Astrolabe 2026-08-06c.dc.html` (or the next free letter that day).
- Version → v0.890.
- Orbo never uses the em-dash.

---

## 1 · THE DEFECT, exactly located

With two birth charts seated (plate = a person, rete = a person/event), find the drawing code that
currently invents a THIRD ring for the rete's occupant when the outer track is reserved for the sky.
Search the wheel-draw block for wherever `skyOn` (or its equivalent "is the sky seated" test) gates
which radius a rete occupant draws at — that gate is the single cause of:

- both charts crowding the same one or two inner tracks,
- colliding angle labels (`As As`, an unowned `MC`/`Ds`),
- the outer track sitting empty.

Locate it before writing anything. Do not guess at a fix without finding the actual radius-selection
code (it is near the same neighborhood as `plateT`/`platePartnered` from P0, in the wheel draw).

---

## 2 · The law (§12.2)

**Whatever is seated on a wheel rides that wheel's track. No third ring, ever.**

- The plate's occupant (natal, composite, prism, whatever) draws at the plate's track/radius —
  unchanged, this is `plateT` from P0.
- The rete's occupant — sky, a person, an event, another composite — draws at the RETE's track, which
  today is exclusively the sky's. Generalize that radius assignment from "is the sky on" to "whatever
  is seated on the rete," the same generalization P0 already made for the plate.
- Delete whatever third-ring/overflow mechanism exists for the two-chart case. There should be exactly
  two tracks after this pass, always, regardless of what is seated on each.

This alone should resolve most of the crowding: halving per-track occupancy is most of the fix before
any de-collision logic is touched.

---

## 3 · The frame belongs to the plate (§12.4)

Only ONE set of angles is structural: the plate's. Its ASC anchors the horizon line, its MC anchors the
meridian, houses are drawn from it — unchanged from today's natal-solo case.

The RETE's angles (As/MC/Ds/IC, or cASC/cDSC for a composite) are occupants like any other body on the
rete's track — same bead/glyph treatment as any rete body, not a second structural frame. This is what
resolves the `As As` collision: one `As` is the horizon itself; the other is just a bead sitting at the
rete's track, wherever the rete's ASC longitude happens to fall.

Do not draw two horizon lines, two meridians, or two house grids. One frame, always the plate's.

---

## 4 · Geometry over line style (§12.5)

Retire whatever visual distinction (dotted vs solid, or a second color) currently marks "which chart's
aspect" a web line represents. Replace it with geometry:

- A line whose both endpoints sit on the SAME track (both plate, or both rete) is a self-aspect —
  radial/internal to that track.
- A line spanning FROM the plate's track TO the rete's track is a cross-aspect — chordal, crossing the
  gap between tracks.

Color goes back to meaning harmony family (the existing red/green/whatever-you-use-for-tension/ease
convention used elsewhere in the instrument), consistently, rather than being spent on chart membership.
Reuse whatever color-by-family logic already exists (`_webColor` or equivalent from P0) — do not invent
a second color scheme.

---

## 5 · What must NOT move

- P0's `platePartnered` gate and plate-web logic — untouched.
- The natal-solo case, the composite-solo case (P0's fix) — must render byte-identically to today.
- `_compPairs`, `synOrb`, any orb value, any `.browser.js`, any codec, `fertKey`, spine seed.
- Materials, metal, card tinting — deferred by ruling, not this pass.
- Any Connectome/prism/sASC work — not this pass.

---

## 6 · Acceptance, measured

1. Two natal charts seated (plate = person A, rete = person B): exactly two tracks draw, no third ring,
   each chart's full body set at its own track's radius.
2. Angles: one horizon line, one meridian, from the plate only. The rete's As/MC/Ds/IC draw as ordinary
   beads on the rete's track.
3. Web: lines internal to one track (self-aspects) are visually distinct in FORM (radial/short) from
   lines spanning both tracks (cross-aspects, chordal), with no dotted/solid distinction remaining.
4. Sky-vs-person and person-vs-person cases both draw via the same generalized rete-track logic — no
   special-cased "if sky" branch left where a general "whatever is seated" branch belongs.
5. Natal-solo and composite-solo (P0) cases are pixel-identical to before this pass.
6. STEP 0 of `tests/rewire-parity.test.html` passes (compile check). Full suite green.

---

## 7 · Traps

- Never build an `old_string` from truncated grep output — read the actual file region first.
- Verify by PARSING/loading, not by reading the diff.
- The rete's radius logic likely has several read sites (draw, hit-testing for holds/scrubs, the readout
  strip). Grep for every place today's code branches on "is the sky seated" before declaring this done —
  a partial generalization that fixes drawing but leaves scrubbing reading the old track will produce a
  bead you can see but not grab correctly.
- Do not add a THIRD track "just for angles" — §3 puts the rete's angles ON the rete's existing track, at
  the same radius as its bodies, not a new one.

---

## 8 · Owed on completion

- `CLAUDE.md`: a short note under or beside the solo-web law — the seating law, one sentence: whatever is
  seated on a wheel rides that wheel's track, no third ring, ever; the frame is always the plate's.
- `specs/Phase 6 - The Synchronic Prism.md` §10: mark P0b done, with before/after measurement (the
  screenshot pair this was diagnosed from vs. the fixed layout).
