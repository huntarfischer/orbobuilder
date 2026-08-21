# Mundane Timespine 3D Build Contract

Status: frozen architecture after Round 5 plus approved Terra/Spine revisions. Build branch only. No production implementation yet.

## 1. Canonical shipped Spine

The canonical universal Mundane Timespine shipped with every Orbo may also be called the **OrboSpine**.

It is the universal ancestral Spine. It contains no native, birthplace, Ascendant, houses, or natal frame.

Hephaestus forges and seals the OrboSpine. Later Natal and Synchronic Spines may also be forged by Hephaestus, but they are outside Pass 5.

## 2. Core celestial coordinate

```text
(body, directionalDegree, UT)
```

- `body`: one of the 11 canonical mundane celestial tracts.
- `directionalDegree`: continuous directional zodiac degree in `[0, 720)`.
  - `[0, 360)` = increasing/direct lane.
  - `[360, 720)` = decreasing/retrograde lane.
- `UT`: continuous civic-time Bone shared by every tract.

The coordinate is expressed in degrees, including fractional degrees.

```text
physicalDegree = directionalDegree % 360
isDecreasing   = directionalDegree >= 360
```

Examples:

```text
19.372 degrees increasing  -> 19.372
19.372 degrees decreasing  -> 379.372
359.8 degrees increasing   -> 359.8
359.8 degrees decreasing   -> 719.8
```

Sign and degree-in-sign are views of `physicalDegree`, not separate indexing dimensions.

### Whole-degree navigation projection

The proven 720-cell navigation system remains a projection of the continuous coordinate:

```text
navigationCell = floor(directionalDegree)
```

Therefore:

```text
0...359   = increasing/direct whole-degree cells
360...719 = decreasing/retrograde whole-degree cells
```

The cell is a coarse navigation grip. Decimal degree precision remains in `directionalDegree`.

## 3. Canonical Eleven

The OrboSpine core has exactly these 11 celestial tracts:

1. Sun
2. Moon
3. Mercury
4. Venus
5. Mars
6. Jupiter
7. Saturn
8. Uranus
9. Neptune
10. Pluto
11. True North Node

South Node is derived at +180 degrees and is not an independent tract.

Do not broaden the canonical Eleven merely to admit later celestial factors.

## 4. Geometry

- Bone = continuous UT axis.
- Tract = one body's continuous celestial path through the Bone.
- Directional degree = continuous celestial position on a tract with direction encoded in the lane.
- Regular celestial grips = the 720 projected whole-degree navigation cells.
- Terra Marrow = Earth's universal turn + tilt carried at UT inside the Bone.
- Ring contact = lateral exact relationship between two celestial tracts at one UT.
- Shell interval = large-scale temporal grip on the Bone.
- Horae, Chronos, and Clotho are future external consumers through neutral ports only in Pass 5.

Retrograde never reverses time. UT remains monotonic.

## 5. Terra Marrow

The shipped OrboSpine carries original **Terra Marrow**.

Operational coordinate:

```text
(turn, tilt, UT)
```

Where:

```text
turn = Greenwich sidereal orientation / Greenwich ARMC, degrees [0,360)
tilt = true ecliptic obliquity at UT
```

Terra is not a twelfth celestial tract, not a Ring occupant, and does not use the `[0,720)` directional-degree law.

Terra support cadence for the default shipped OrboSpine:

```text
6 hours
```

Use simple linear refinement between supports, with explicit one-sided handling at the Swiss sidereal-model source seams around 1850 and 2050. Do not interpolate through a source-model discontinuity.

Terra contains no observer place.

```text
localTurn = normalize(Terra.turn + longitude)
```

Latitude enters only downstream through Horizon.

Pass 5 must preserve Terra precisely enough that future Horizon/Clotho consumers do not need to reopen the ephemeris merely to recover Earth's orientation.

## 6. Three neutral external ports

The finished OrboSpine must expose stable read seams for exactly three currently planned external consumers:

```text
ChronosPort
HoraePort
ClothoPort
```

Pass 5 does not implement Chronos, Horae, or Clotho and does not define their future domain behavior beyond the port boundary.

The ports must not expose storage internals as contract.

## 7. Auxiliary socket

The sealed OrboSpine core remains the Eleven plus Terra Marrow.

Provide an auxiliary celestial socket outside the canonical Eleven so later celestial packs can be forged/reforged without reopening the sealed core.

Pass 5 builds the socket only. It does not manufacture Auxiliary Pack 1.

First intended Auxiliary Pack:

```text
True Black Moon Lilith
Chiron
```

Additional factors may be admitted later by their own studies.

Auxiliary pack membership does not automatically imply Ring membership.

## 8. Station rule

A station is an exact zero-speed boundary between directional lanes.

Store the exact station longitude as the astronomical fact. Derive its directional degree from the lane entered after the station using half-open ownership:

```text
if laneAfter == increasing:
    directionalDegree = normalizedExactLongitude

if laneAfter == decreasing:
    directionalDegree = normalizedExactLongitude + 360
```

Then:

```text
navigationCell = floor(directionalDegree)
```

At a station UT never reverses, longitude remains continuous, and only the directional lane changes.

No interpolation may cross a station.

## 9. Primary celestial entrances

All three routes must resolve the same occurrence:

```text
body -> directional degree -> UT

directional degree -> body -> UT

UT -> body -> directional degree
```

Whole-degree queries may enter through `navigationCell` and resolve to the containing directional-degree occurrence/reach.

Ring relationships provide a fourth lateral entrance.

Dioscuri resonance remains path independence through the same canonical occurrence.

## 10. Selected celestial support

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

The continuous `[0,720)` coordinate is independent of stored tract density.

Every reversible body's selected support divides 1 degree exactly. Preserve the frozen densities unless canonical evidence proves a specific failure.

Prefer higher-fidelity canonical tables over avoiding manufacture-time calculation. Existing rows may be reused only when equivalence to the desired canonical DE441 result is proven.

## 11. Motion ownership

Exact stations own topology.

Derive from stations + ordered supports:

- directional reaches
- retrograde passages
- retrograde crossing views
- motion at UT
- planetary shadows from station degrees + corresponding crossings

Do not create competing truth owners for these derived views.

True North Node remains topology-dominant and requires canonical station certification.

## 12. Ring

Use one complete chronological exact Ring-contact stream.

Canonical cleaned P22 counts:

```text
major   308,474
minor   461,819
total   770,293
```

Runtime indexing:

```text
ordinary body access:
UT binary search -> short outward scan in chronological Ring stream

specific pair access:
pair -> ordered contact chronology
```

Do not build a duplicated per-body endpoint index. Do not split major/minor into separate operational mechanisms.

Pair chronology is preferred to pair+angle.

Ring owns angular relationship geometry. The OrboSpine stores/navigates exact Ring occurrences but does not become the owner of Ring geometry.

## 13. Eclipses and syzygies

A solar or lunar eclipse is metadata keyed to the qualifying exact Sun-Moon conjunction/opposition Ring contact.

Do not duplicate the phase hinge.

Preserve eclipse-specific metadata such as type, centrality, greatest time, magnitude, and secondary magnitude where present.

## 14. Temporal shells

The four shell systems remain independent canonical interval systems:

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

Ownership is half-open:

```text
[start, next_start)
```

Shell families own their interval truth. A later Chronos may navigate by those intervals but does not own or calculate them.

A combined F.R.W.Z table may exist only as a derived acceleration cache, never as a second canonical owner.

## 15. Hephaestus lifecycle

Hephaestus is the Spine forge.

For the OrboSpine:

```text
Hephaestus manufactures candidate
        -> Dioscuri pre-seal resonance/certification
        -> Hephaestus final seal
```

The Timespine is not complete until Hephaestus seals it.

After sealing, the Dioscuri may continue maintenance resonance of the existing sealed Spine without requiring a new Hephaestus signature.

Hephaestus returns when something is actually forged, reforged, or resealed.

Hephaestus does not participate in ordinary runtime query handling.

Later Natal Spines, Synchronic Spines, and auxiliary packs may also be Hephaestus manufactures, outside this Pass 5 build.

## 16. Dioscuri

Castor and Pollux remain independent traversals through the same finished Spine.

Castor:

```text
UT -> celestial coordinate
```

Pollux:

```text
celestial structure -> UT occurrence
```

Law:

```text
ASK -> ANSWER -> CONFIRM
```

Do not blindly average answers.

Safe non-resonance is valid. False resonance is failure.

Pre-seal they certify the candidate. Post-seal they continue maintenance resonance.

## 17. AstroDNA isolation

AstroDNA remains its own native identity owner.

Preserve:

```text
AstroDNA.codec == 4
```

Do not reuse Codec 4 as an OrboSpine/Timespine codec.

Any historical Timespine reference that treated Codec 4 as a Timespine identity is superseded.

## 18. Canonical manufacture authority

Canonical celestial authority:

```text
Swiss Ephemeris 2.10.03
DE441
geocentric
tropical
apparent ecliptic longitude
UT
```

Terra Marrow shares the Swiss 2.10.03 forge provenance but is Earth-orientation/frame data, not a DE441 planetary tract.

The final shipped OrboSpine seal spans:

```text
Z21
Z22
Z23
```

including both Z seams.

Do not silently substitute DE431 or Moshier for canonical celestial manufacture.

## 19. Round 5 results preserved

The proven whole-degree navigation projection remains valuable:

```text
1,540,586 canonical Ring relationship endpoints tested
(body, navigationCell) vs (navigationCell, body): 0 disagreements
occupied navigation cells: 7,200
Sun: 360 increasing cells
Moon: 360 increasing cells
Mercury-Pluto: 720 cells each
True North Node: 720-cell operational behavior, canonical station seal still required
```

Pair chronology remains preferred.
Per-body Ring endpoint index remains rejected.
Relationship one-longitude packing passed.
Eclipse normalization passed.
Shell F.R.W.Z derivation passed.

These results now validate the coarse navigation projection, not an integer-only physical coordinate.

## 20. Pass 5 acceptance laws

Hard-zero requirements include:

```text
UT ordering errors                 0
missed celestial occurrences       0
invented celestial occurrences     0
directional identity errors        0
station lane errors                0
shell address errors               0
Ring occurrence errors             0
false Dioscuri resonance           0
Z-seam continuity errors           0
Terra source-seam smearing         0
Terra longitude-translation errors 0 at support truth
```

Minute/second resonance coverage may legitimately be less than 100 percent. False certification may not.

## 21. Revised Pass 5 build order

### Pass A - repo/owner audit

Completed read-only audit.

### Pass A.5 - shell adoption

Bring the already-finished canonical temporal-shell work from `main` onto the build branch deliberately. Do not merge all of `main`.

Stop and report after this pass.

### Pass B - final OrboSpine laws/types

Implement only the core Timespine substrate needed for:

- canonical Eleven identity
- continuous directional degree + whole-degree navigation projection
- Bone / UT
- station topology
- occurrence/reach identity
- Terra Marrow
- auxiliary socket
- three neutral ports

Do not implement Chronos, Horae, Clotho, Horizon, Natal Spine, or Synchronic Spine.

### Pass C - canonical manufacture

Forge/adapt canonical Z21-Z23 manufacture for:

- selected Eleven supports
- exact stations
- True North Node topology
- Terra 6-hour supports
- directional reaches/derived views
- Ring occurrence normalization
- shells
- eclipse annotations

### Pass D - indexes/runtime image

Implement compact indexes for:

- body / directional degree / reach -> UT
- whole-degree navigation cell -> body/reach -> UT
- UT -> tract support/refinement
- pair -> ordered Ring chronology
- shell interval -> UT region
- UT -> Terra Marrow

Do not duplicate entire truth tables merely for indexing.

### Pass E - Dioscuri certification

Wire independent Castor/Pollux traversals against the candidate OrboSpine.

Zero false resonance required.

### Pass F - three-Z adversarial proof

Test:

- random UT
- celestial crossings
- direct/retro/direct repeats
- stations
- Ring contacts
- shell boundaries
- Z seams
- eclipses
- longest sparse intervals
- high-curvature regions
- True North Node pathologies
- reverse queries
- Terra 1850/2050 source seams
- Terra wrap
- Terra reconstruction fidelity

### Pass G - Hephaestus seal

Hephaestus seals the completed Z21-Z23 OrboSpine only after Dioscuri certification and final adversarial proof.

Pass 5 ends here.

Chronos, Horae, Clotho, Horizon, Natal Spine, Synchronic Spine, and Auxiliary Pack 1 are later work.

## 22. Storage/performance law

Prefer:

- high-fidelity canonical facts
- compact indexes
- derivable views
- local refinement
- exact structural landmarks

Avoid:

- repeated strings
- duplicate event timestamps
- redundant relationship indexes
- separate owners for derived truths
- runtime ephemeris work that properly belongs in Hephaestus manufacture

One law, one owner.
