# Horae - Controls v1 Implementation Plan

**Status:** PLANNED

## Purpose

Extend the proven Horae without reopening their frozen LIVE/SEEK core.

Horae Controls v1 makes the native OrboSpine address controllable:

```text
(body, directionalDegree, UT)
```

For control/readout purposes:

```text
X = body
Y = directionalDegree
Z = UT
```

The bodies themselves are the temporal scrubbers. Each body follows its own forged tract, so moving a Moon grip and moving a Saturn grip traverse UT at different actual rates. Horae never supplies generic planetary speed.

## Ownership

```text
ORBOSPINE / LOCATE
        |
        v
      HORAE
        |
        +-- LIVE
        +-- SEEK
        +-- ADDRESS
        +-- CONTROL ROLES
        +-- TRACT CONTINUITY
        +-- CONSTRAINED SOLUTIONS
```

OrboSpine owns truth. Horae controls access to that truth. This plan ends at Horae.

## Control roles

Each coordinate is one of:

```text
HELD       keep this value fixed
DRIVEN     this is the value being moved
RESOLVED   OrboSpine truth determines this value
```

One coordinate may be DRIVEN at a time. Zero, one, or two others may be HELD. A coordinate that is uniquely determined by the held/driven values is RESOLVED rather than freely movable.

## Build stages

### Stage 0 - Freeze the control law

Spec only. Freeze the address, roles, planetary-scrubber law, continuity law, and non-goals. No Swift.

### Stage 1 - Readout

Add neutral Horae control types that report one truthful address and the role of each coordinate. No navigation behavior.

Conceptual shape:

```text
HoraeAddress
    body
    directionalDegree
    julianDay

HoraeCoordinateRole
    held
    driven
    resolved

HoraeControlState
    address
    bodyRole
    directionalDegreeRole
    julianDayRole
```

### Stage 2 - Z-driven Horae

Drive UT through the existing frozen SEEK path. Body and directional degree are resolved from the resulting cross-section.

### Stage 3 - Planetary scrub

Support the fundamental Orbo control:

```text
BODY                HELD
DIRECTIONAL DEGREE  DRIVEN
UT                  RESOLVED
```

Use Locate's existing `(body, directionalDegree, *)` occurrence surface. When the same directional state occurs more than once, Horae preserves continuity with the current tract neighborhood rather than jumping arbitrarily to another passage.

### Stage 4 - Direction and stations

Prove planetary scrubbing across direct motion, stations, retrograde motion, and directional-space wrap. Following a planet means following its tract, not dragging a zodiac longitude independently of the Spine.

### Stage 5 - One held coordinate

Support the useful one-hold combinations:

```text
BODY held, DEGREE driven, UT resolved
BODY held, UT driven, DEGREE resolved
UT held, BODY driven, DEGREE resolved
DEGREE held, BODY driven, UT resolved where valid
```

Horae returns valid Spine solutions and does not fabricate continuity where none exists.

### Stage 6 - Two held coordinates

Support constrained navigation when two coordinates are fixed.

Law:

```text
If two coordinates uniquely determine the third,
the third is RESOLVED.

If two coordinates admit multiple valid solutions,
the third may navigate those solutions.

If no solution exists,
Horae reports no valid address.
```

### Stage 7 - LIVE coexistence

Reconcile the control state with existing LIVE without creating a transport deck. LIVE means Z follows present UT; any other readout remains resolved from Spine truth.

### Stage 8 - Stress and freeze

Prove every canonical body can act as the held planetary scrubber; different body rates emerge only from Spine geometry; repeated occurrences do not cause passage jumping; station and wrap continuity hold; Bone boundaries remain exact; and existing LIVE/SEEK behavior is unchanged.

Then freeze Horae Controls v1.

## Non-goals

Do not add rendering, gestures, buttons, sliders, camera behavior, display styling, generic playback, speed multipliers, Chronos search, event interpretation, ephemeris work, or duplicate astronomical truth.

## Final target

```text
HORAE
|
+-- LIVE
+-- SEEK
|
+-- ADDRESS
|     body
|     directionalDegree
|     UT
|
+-- CONTROLS
      held
      driven
      resolved
      planetary tract continuity
      valid constrained solutions
```
