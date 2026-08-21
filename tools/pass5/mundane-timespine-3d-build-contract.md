# Mundane Timespine 3D Build Contract

Status: frozen architecture after Round 5. Build branch only. No production implementation yet.

## Core coordinate

```text
(body, directionalDegree, UT)
```

- `body`: one of the 11 mundane celestial tracts.
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

Sign and degree-in-sign are views of `physicalDegree`, not separate stored indexing dimensions.

### Whole-degree navigation projection

The proven 720-cell navigation system remains, but it is a projection of the continuous degree coordinate rather than the coordinate itself.

```text
navigationCell = floor(directionalDegree)
```

Therefore:

```text
0...359   = increasing/direct whole-degree cells
360...719 = decreasing/retrograde whole-degree cells
```

The cell is a coarse navigation grip. Decimal degree precision remains in `directionalDegree`.

## Station rule

A station is an exact zero-speed boundary between directional lanes.

Store the exact station longitude as the astronomical fact. Derive its directional degree from the lane entered after the station, using the same half-open ownership law as other temporal boundaries:

```text
if laneAfter == increasing:
    directionalDegree = normalizedExactLongitude

if laneAfter == decreasing:
    directionalDegree = normalizedExactLongitude + 360
```

Its whole-degree navigation cell is then:

```text
navigationCell = floor(directionalDegree)
```

Thus a retrograde station at exact physical longitude `19.372 degrees` has directional degree `379.372` and navigation cell `379`; a direct station at the same physical longitude has directional degree `19.372` and navigation cell `19`.

UT never reverses. Longitude remains continuous. Only the body's directional lane changes.

## Geometry

- Bone = continuous UT axis.
- Tract = one body's celestial path through the Bone.
- Directional degree = continuous celestial position on a tract with direction encoded in the lane.
- Regular celestial grips = the 720 projected whole-degree navigation cells.
- Horae = the fixed-UT synchronization plane across all tracts.
- Astrolabe = top-down projection of that Horae plane.
- Ring contact = lateral exact relationship between two tracts at one UT.
- Dioscuri resonance = path independence through the same `(body, directionalDegree, UT)` occurrence.

## Primary entrances

All three routes must resolve the same occurrence:

```text
body -> directional degree -> UT

directional degree -> body -> UT

UT -> body -> directional degree
```

Whole-degree queries may enter through the projected navigation cell and resolve to the containing directional-degree occurrence or reach.

Ring relationships provide a fourth lateral entrance into the same coordinate structure.

## Selected tract support

```text
Sun         10 degrees
Moon        10 degrees
Mercury      1 degree
Venus        1 degree
Mars         1 degree
Jupiter      0.5 degree
Saturn       0.5 degree
Uranus       0.2 degree
Neptune      0.1 degree
Pluto        0.1 degree
NorthNode    0.1 degree
```

The continuous `[0, 720)` directional-degree coordinate is independent of stored tract density.

The projected 720 whole-degree navigation cells also remain independent of stored tract density.

Body-specific support density is therefore neither the coordinate precision nor the navigation-cell resolution.

Every reversible body's selected support divides 1 degree exactly, preserving direct whole-degree navigation crossings for both directional lanes. Do not coarsen merely to save rows unless the entire body/directional-degree/UT navigation contract remains superior.

## Motion ownership

- exact stations own topology.
- directional reaches are derived navigation views bounded by stations.
- retrograde passages are derived views.
- retrograde crossing subsets are derived views.
- shadows are derived intervals from station degrees and their corresponding crossings.

No interpolation may cross a station.

## Ring

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

Pair chronology is preferred to pair+angle because it preserves ordered relational boundaries and negative information between contacts while still making angle-specific lookup cheap.

## Relationship packing

Runtime relationship rows may derive:

- aspect text from Ring-angle code;
- orientation text from direction;
- second exact endpoint longitude from first longitude + directed Ring relation;
- civic offset from precise event time;
- audit residuals remain manufacture/provenance data.

Round 5 test-source reconstruction remained below 0.1 arcsecond for every relationship endpoint, with p99 about 0.006 arcsecond and max about 0.034 arcsecond.

## Shells

Frame, Revolt, Wave, and Zeitgeist remain independent interval systems. F.R.W.Z is their intersection at UT.

The combined temporal-address table may exist only as a derived acceleration cache, never as a second canonical owner.

## Eclipses and syzygies

A solar or lunar eclipse is metadata keyed to the qualifying exact Sun-Moon conjunction/opposition Ring contact. Do not duplicate the phase hinge.

## Dioscuri

Castor traverses from civic time into celestial position:

```text
UT -> body -> directional degree
```

Pollux traverses from celestial structure toward civic occurrence:

```text
body/directional degree/relations -> UT
```

Whole-degree navigation may use the projected 720-cell index on either route.

Resonance means independent routes identify the same coordinate to the fidelity requested by the caller. Safe non-resonance is valid. False resonance is failure.

## Round 5 architectural result

The 3D coordinate/index architecture passed the Round 5 read-only tests.

Those tests used the whole-degree navigation projection, which remains valid under the continuous directional-degree coordinate:

- `(body,navigationCell)` and `(navigationCell,body)` indexes agreed with zero disagreements across 1,540,586 Ring endpoints.
- the contact corpus occupied all 7,200 theoretically expected body/navigation cells: Sun and Moon 360 each, each reversible body 720.
- pair chronology remained cheap for angle-specific navigation.
- per-body Ring endpoint indexes remained unnecessary.
- eclipse normalization and shell-address derivation remained valid.
- top-down `directionalDegree % 360` projection preserves the Astrolabe geometry; the previous whole-degree test was its coarse-cell projection.

## Remaining seal

Architecture is frozen. The remaining task is manufacture/certification, not redesign:

```text
canonical DE441
-> selected body supports
-> Z21 + Z22 + Z23 including seams
-> canonical NorthNode station chronology
-> rerun frozen Round 5 conformance tests
-> seal
```

If canonical manufacture reveals a failure, repair that specific failure. Do not reopen the entire design search without evidence that the coordinate law itself failed.
