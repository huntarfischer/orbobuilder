# Mundane Timespine 3D Build Contract

Status: frozen architecture after Round 5. Build branch only. No production implementation yet.

## Core coordinate

```text
(body, state, UT)
```

- `body`: one of the 11 mundane celestial tracts.
- `state`: `0...719` directional whole-degree index.
  - `0...359` = increasing/direct lane.
  - `360...719` = decreasing/retrograde lane.
- `UT`: continuous civic-time Bone shared by every tract.

`state % 360` gives the physical zodiac degree. Sign and degree are views, not separate stored indexing dimensions.

Fractional longitude is refinement inside the indexed state, not another global axis.

## Station rule

A station is an exact zero-speed boundary between directional lanes.

Store the exact station longitude as the astronomical fact. Derive its 0...719 navigation state from the lane entered after the station, using the same half-open ownership law as other temporal boundaries:

```text
direct station      -> 0...359
retrograde station  -> 360...719
```

Thus a retrograde station at physical 19 degrees indexes to state 379; a direct station at physical 19 degrees indexes to state 19. UT never reverses. Only the body's state direction changes.

## Geometry

- Bone = continuous UT axis.
- Tract = one body's celestial path through the Bone.
- Regular celestial grips = the 720 directional whole-degree states.
- Horae = the fixed-UT synchronization plane across all tracts.
- Astrolabe = top-down projection of that Horae plane.
- Ring contact = lateral exact relationship between two tracts at one UT.
- Dioscuri resonance = path independence through the same `(body, state, UT)` occurrence.

## Primary entrances

All three routes must resolve the same occurrence:

```text
body -> state -> UT
state -> body -> UT
UT -> body -> state
```

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

The 0...719 state index remains whole-degree even when a tract is supported more finely or more sparsely. Body-specific support density is not the indexing resolution.

Every reversible body's selected support divides 1 degree exactly, preserving direct whole-degree state crossings for both directional lanes. Do not coarsen merely to save rows unless the entire body/state/UT navigation contract remains superior.

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

Castor traverses from civic time into celestial state:

```text
UT -> body -> state
```

Pollux traverses from celestial structure toward civic occurrence:

```text
body/state/relations -> UT
```

Resonance means independent routes identify the same coordinate to the fidelity requested by the caller. Safe non-resonance is valid. False resonance is failure.

## Round 5 architectural result

The 3D coordinate/index architecture passed the Round 5 read-only tests:

- `(body,state)` and `(state,body)` indexes agreed with zero disagreements across 1,540,586 Ring endpoints.
- the contact corpus occupied all 7,200 theoretically expected body/state cells: Sun and Moon 360 each, each reversible body 720.
- pair chronology remained cheap for angle-specific navigation.
- per-body Ring endpoint indexes remained unnecessary.
- eclipse normalization and shell-address derivation remained valid.
- top-down `state % 360` projection reproduced the Astrolabe geometry in the operational test.

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
