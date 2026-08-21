# Orbo 3D Mundane Timespine Build Handoff

Status: authoritative branch handoff after the Round 5 architecture, Pass A audit, continuous-degree correction, Terra Marrow study, Pass A.5 shell import, and Pass B OrboSpine type contract.

## Repository

```text
huntarfischer/orbobuilder
```

## Working branch

```text
agent/mundane-timespine-3d-build
```

Do not mutate other branches. Do not create or launch GitHub Actions or remote benchmark workflows unless explicitly requested.

## Frozen contract

```text
tools/pass5/mundane-timespine-3d-build-contract.md
```

The frozen contract is authoritative over older Timespine designs.

In particular:

- AstroDNA Codec 4 belongs to AstroDNA, not the Timespine.
- Chronos and Horae are not part of Pass 5 implementation anymore.
- Clotho is not being designed in Pass 5.
- Pass 5 creates only neutral ports for Chronos, Horae, and Clotho.
- Terra Marrow is now part of the shipped universal Spine.

---

# 1. What Pass 5 is building

The canonical universal Mundane Timespine shipped with every Orbo may also be called the **OrboSpine**.

It is the ancestral universal Spine shared by every Orbo before any later native-specific derivation.

The shipped OrboSpine contains:

```text
Bone / continuous UT
canonical Eleven celestial tracts
Terra Marrow
station topology
Ring occurrence chronology
temporal shells F.R.W.Z
eclipse annotations
compact navigation indexes
auxiliary celestial socket
three neutral external ports
```

It contains no native, birthplace, Ascendant, houses, natal frame, Chronos implementation, Horae implementation, Clotho implementation, Natal Spine, or Synchronic Spine.

---

# 2. Celestial coordinate

The physical celestial coordinate is:

```text
(body, directionalDegree, UT)
```

`directionalDegree` is continuous and preserves fractional degrees:

```text
[0,360)   increasing/direct
[360,720) decreasing/retrograde
```

```text
physicalDegree = directionalDegree % 360
isDecreasing   = directionalDegree >= 360
```

Example:

```text
19.372 degrees direct      -> 19.372
19.372 degrees retrograde  -> 379.372
```

The proven 720 whole-degree system remains a navigation projection:

```text
navigationCell = floor(directionalDegree)
```

Do not collapse the physical coordinate back to integer-only state.

---

# 3. Canonical Eleven

The sealed core remains exactly:

```text
Sun
Moon
Mercury
Venus
Mars
Jupiter
Saturn
Uranus
Neptune
Pluto
True North Node
```

South Node is derived +180 degrees.

Selected support remains frozen:

```text
Sun          10 degrees
Moon         10 degrees
Mercury       1 degree
Venus         1 degree
Mars          1 degree
Jupiter       0.5 degree
Saturn        0.5 degree
Uranus        0.2 degree
Neptune       0.1 degree
Pluto         0.1 degree
TrueNorthNode 0.1 degree
```

Prefer higher-fidelity canonical tables. Existing rows may be reused only where equivalence to desired canonical manufacture is proven.

---

# 4. Terra Marrow

The Bone carries original Terra Marrow:

```text
(turn, tilt, UT)
```

Where:

```text
turn = Greenwich sidereal orientation / Greenwich ARMC
tilt = true ecliptic obliquity
```

Terra is not a twelfth celestial tract and does not use directional-degree encoding.

Approved default support:

```text
6 hours
```

Approved refinement:

```text
linear between supports
```

Explicitly preserve the Swiss sidereal-model source seams around 1850 and 2050. Do not interpolate through those discontinuities.

Terra carries no observer place.

```text
localTurn = normalize(Terra.turn + longitude)
```

Latitude belongs downstream to Horizon.

The Phase III representation study found the six-hour candidate to be comfortably sub-arcsecond for downstream Horizon reconstruction while retaining modest storage. Three-hour support is a possible future higher-density instrument tier, not the Pass 5 default.

---

# 5. Stations and topology

Exact stations own motion topology.

At a station the lane entered after the station owns the exact boundary instant:

```text
increasing lane:
    directionalDegree = exactLongitude

decreasing lane:
    directionalDegree = exactLongitude + 360
```

No interpolation may cross a station.

Directional reaches, retrograde passages, crossing views, motion-at-UT, and shadows are derived from stations + ordered supports. Do not give them competing ownership.

True North Node remains topology-dominant and still needs final canonical station certification.

---

# 6. Ring and eclipses

Ring owns universal angular relationship geometry.

Use one chronological exact Ring-contact stream plus pair chronology.

Canonical cleaned P22 counts:

```text
major   308,474
minor   461,819
total   770,293
```

Do not restore the five old duplicate minor emissions.

Do not build a duplicated per-body relationship endpoint index.

Eclipses remain metadata on qualifying exact Sun-Moon Ring contacts. Do not duplicate the phase hinge.

---

# 7. Temporal shells

Canonical shell families:

```text
Frame      = Saturn
Revolt     = Uranus
Wave       = Neptune
Zeitgeist  = Pluto
```

Address:

```text
F.R.W.Z
```

They are independent half-open interval systems:

```text
[start,next_start)
```

A later Chronos may navigate by shell intervals, but Chronos does not own shell truth.

Pass A.5 selectively imported the finished canonical temporal-shell work from `main` onto this feature branch. No wholesale merge of `main` was performed.

---

# 8. Auxiliary celestial socket

The sealed core stays Eleven + Terra Marrow.

Pass 5 creates an auxiliary socket but does not manufacture an auxiliary pack.

First intended Auxiliary Pack:

```text
True Black Moon Lilith
Chiron
```

Additional factors require their own studies.

Auxiliary-pack membership does not automatically imply Ring membership.

A later auxiliary pack may be forged/reforged without reopening the sealed Eleven-body core.

---

# 9. Three neutral ports

Pass 5 must create stable, storage-independent read seams for:

```text
ChronosPort
HoraePort
ClothoPort
```

Do not implement or pre-design those consumers in Pass 5.

Do not expose internal storage layout as their contract.

---

# 10. Hephaestus and Dioscuri lifecycle

Hephaestus is the Spine forge.

For the shipped OrboSpine:

```text
Hephaestus manufactures candidate
        -> Dioscuri pre-seal resonance/certification
        -> Hephaestus final seal
```

The OrboSpine is not complete until Hephaestus seals it.

After sealing, Castor and Pollux continue maintenance resonance without requiring a new Hephaestus signature unless something is actually forged, reforged, or resealed.

Hephaestus may later forge Natal Spines, Synchronic Spines, and auxiliary packs. Those are outside Pass 5.

Dioscuri law remains:

```text
ASK -> ANSWER -> CONFIRM
```

Resonance is independent path agreement through the same canonical occurrence. Safe non-resonance is valid. False resonance is failure.

---

# 11. Canonical manufacture authority

Canonical celestial manufacture:

```text
Swiss Ephemeris 2.10.03
DE441
geocentric
tropical
apparent ecliptic longitude
UT
```

Terra shares the Swiss 2.10.03 forge provenance but is Earth-orientation/frame data rather than a DE441 planetary tract.

Final seal spans:

```text
Z21
Z22
Z23
```

including both Z seams.

Never silently substitute DE431 or Moshier and call the result canonical.

---

# 12. Pass A audit status

Pass A is complete. No code was changed during the audit.

Important findings:

- existing native Timespine code is useful but contains superseded P22 representation assumptions
- current storage is ORBOTS02, while some tests still appear stale against ORBOTS01
- existing reader/runtime machinery contains useful half-open, station-safe, ephemeris-free patterns
- Forge/Hephaestus and Dioscuri machinery are substantial and reusable after ownership corrections
- Z21, Z22, and Z23 body, motion, Ring, eclipse, and related canonical source material already exists
- the last recorded P22 native proof status is failure, so do not describe the current substrate as fully sealed/green
- Pass A.5 selectively imported the finished canonical temporal-shell work from `main`
- Chronos and Horae are not currently implemented natively and are no longer Pass 5 implementation targets

---

# 13. Revised Pass 5 build order

```text
A     repo/owner audit                           DONE
A.5   selectively adopt finished shell work     DONE
B     final OrboSpine laws/types                 DONE
C     canonical Z21-Z23 manufacture              NEXT
D     compact indexes/runtime image
E     Dioscuri certification
F     three-Z adversarial proof
G     Hephaestus final seal
```

Pass 5 ends at the Hephaestus seal.

### Pass B scope

Pass B establishes:

- canonical Eleven identity
- continuous directional degree
- whole-degree navigation projection
- Bone / UT
- exact station topology
- occurrence/reach identity
- Terra Marrow
- Ring occurrence seam
- F/R/W/Z shell identity seam
- auxiliary socket
- ChronosPort
- HoraePort
- ClothoPort
- Hephaestus/Dioscuri lifecycle boundaries
- AstroDNA Codec 4 isolation

Pass B does not implement Chronos, Horae, Clotho, Horizon, Natal Spine, Synchronic Spine, or Auxiliary Pack 1.

### Pass C scope

Canonical manufacture should cover:

- selected Eleven supports
- exact stations
- True North Node topology
- Terra six-hour supports
- Ring occurrence normalization
- shell linkage
- eclipse annotations
- full Z21-Z23 span

### Pass F adversarial proof

Must include:

- random UT
- degree/directional crossings
- direct/retro/direct repeats
- stations
- True North Node pathologies
- Ring contacts
- shell boundaries
- Z seams
- eclipses
- longest sparse intervals
- high-curvature regions
- reverse queries
- Terra wrap
- Terra 1850/2050 source seams
- Terra reconstruction fidelity

### Pass G

Only after the candidate passes Dioscuri certification and adversarial proof does Hephaestus seal Z21-Z23 as the shipped OrboSpine.

---

# 14. Working rule

Work in narrow, reviewable passes.

Inspect before changing.

Do only what was approved for the current pass.

Do not resurrect superseded Timespine designs merely because names overlap.

Preserve:

```text
AstroDNA.codec == 4
```

but never reuse Codec 4 as a Timespine identity.

No astrology glyphs or emojis in source artifacts.

Next action is **Pass C canonical Z21-Z23 manufacture**, subject to explicit user approval.
