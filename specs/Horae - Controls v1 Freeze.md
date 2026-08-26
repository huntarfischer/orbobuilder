# Horae - Controls v1 Freeze

**Status:** FROZEN / PROVEN  
**Target:** Orbo 1.0 native  
**Branch:** `feature/engraving-orbospine-graft`  
**Control contract:** `Horae - Controls v1 Stage 7 Solvability Matrix.md`

## Purpose

Freeze the proven Horae control surface grafted onto the original temporal-adapter MVP.

The original law remains:

```text
ORBOSPINE / LOCATE
        |
      HORAE
        |
   HoraeOutput
        |
 consumer / Iris
```

Horae receive Locate, speak truthful temporal navigation, and emit one presentation-neutral output cable.

## Native coordinate law

```text
BODY × DIRECTIONAL STATE × UT
```

These are grips on valid forged Spine addresses, not independent values Horae may combine arbitrarily.

Directional state preserves the two motion lanes:

```text
[0,360)     direct
[360,720)   retrograde
```

## Two truthful outward situations

### Point address

```text
(body, directionalDegree, UT)
```

When one body is selected, `HoraeControlState` may carry its address and the roles played by each coordinate.

### UT cross-section

```text
UT
 |
 v
all canonical body coordinates
+
Terra
```

Pure UT and LIVE outputs do not invent a dummy body. Their `controlState` remains `nil`.

Both situations use the same `HoraeOutput` type.

## Control-role law

For point-address controls:

```text
DRIVEN
PINNED
RESOLVED
```

Exactly one coordinate is `DRIVEN` during one control action.

Horae do not expose an impossible independent control merely because a coordinate exists. In particular:

```text
BODY + UT -> DIRECTIONAL DEGREE
```

is unique Spine truth, so degree is resolved rather than freely driven when body and UT are both fixed.

## Frozen control surface

### Pure UT

```text
ABSOLUTE
seekUT(to: UT)

RELATIVE
shiftUT(from: UT, by: deltaUT)
```

Pure UT is continuous over the half-open Bone and returns a complete celestial + Terra cross-section.

`HoraeUTOffset` carries displacement only. It owns no playback rate.

### Body pinned, UT driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   RESOLVED
UT                   DRIVEN
```

A supplied UT resolves the selected body's actual directional state.

### Body + degree pinned, UT driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   PINNED
UT                   DRIVEN
```

Available UT is the real occurrence set of the exact body/state pair.

Horae support:

```text
nearest occurrence to explicit UT grip
previous occurrence
next occurrence
```

There is no Bone wrap.

### Body pinned, degree driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   DRIVEN
UT                   RESOLVED
```

This is planetary tract scrubbing.

The selected body's forged tract determines the resulting UT. Horae own no planetary speed table.

All eleven canonical bodies are proven temporal grips:

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

### UT pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   RESOLVED
UT                   PINNED
```

Changing body stays on one horizontal UT cross-section and resolves each body's true state there.

### Degree pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   PINNED
UT                   RESOLVED
```

Changing body changes the occurrence set. An explicit UT continuity anchor selects the nearest real occurrence for the newly selected body.

### Degree + UT pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   PINNED
UT                   PINNED
```

This is exact constraint validation.

The requested triple either exists or fails explicitly. Horae do not snap to a nearby occurrence.

## Occurrence law

For one exact body/state pair:

```text
(body, directionalDegree) -> UT1, UT2, UT3, ...
```

Horae distinguish:

```text
CONTINUITY RESOLUTION
nearest occurrence to an explicit temporal anchor

OCCURRENCE NAVIGATION
previous / next through the ordered occurrence set
```

This is not Chronos search. The exact coordinate whose solutions are being traversed is already known.

## Availability surface

Consumers may ask Horae for truthful control availability without receiving Locate itself.

```text
controlDomain
    start
    endExclusive

occurrenceUTs(body, degree)
    -> [UT]

matchingBodies(degree, UT)
    -> [body]
```

No solution is valid availability information and is represented by an empty array where appropriate.

Availability queries do not move Horae or create control state.

## Bone law

The continuous temporal domain is:

```text
[start, endExclusive)
```

Horae preserve Locate failure law.

They do not:

```text
clamp
wrap
fabricate endpoint truth
invent an occurrence
```

## LIVE law

```text
LIVE = SEEK(now().julianDay)
```

LIVE remains a pure cross-section with `controlState == nil`.

Successful controls, failed controls, occurrence navigation, exact constraints, relative UT motion, and Bone-edge requests are proven not to contaminate subsequent LIVE output.

Horae retain no hidden cursor or current UT.

## Consumer seam

The presentation-neutral consumer socket is:

```text
HoraeControlIntent
        |
        v
Horae.respond(to:)
        |
        v
   HoraeOutput
```

Frozen intent vocabulary:

```text
seekUT
shiftUT
driveUT
driveConstrainedUT
driveDirectionalDegree
driveBody
driveBodyAtDegree
driveConstrainedBody
navigateOccurrence
```

The intent names describe consumer requests only. Every successful intent resolves through the same Horae truth paths and returns the same single output type.

## Ownership

```text
ORBOSPINE / LOCATE
owns valid coordinates, interpolation, occurrence sets, stations, motion lanes, Bone bounds, Terra truth

HORAE
own presentation-neutral temporal navigation grammar, continuity choice, exact constraint validation, availability, LIVE, SEEK, and the consumer control socket

IRIS
owns representation, gestures, visible rate, controls, animation, camera, projection, and rendering

CHRONOS
owns later search for meaningful temporal destinations
```

## Negative architecture

Horae Controls v1 contain no:

```text
persistent currentUT
playhead state
planetary speed table
playback engine
astronomical calculation
Spine interpolation
station calculation
Chronos event search
Iris gesture logic
Iris rendering logic
full OrboSpine ownership
consumer-facing Locate object
second outward control signal
```

`HoraeOutput` remains the only outward signal.

## Stage 7 matrix closure

The Stage 7 acceptance ledger is closed:

```text
1  degree pinned / body driven / UT resolved          PROVEN
2  exact degree + UT pinned / body driven             PROVEN
3  explicit occurrence previous / next                PROVEN
4  pure absolute + relative UT through consumer seam  PROVEN
5  minimal control-domain availability                PROVEN
6  direct / station / retrograde / zodiac wrap        PROVEN
7  all canonical bodies as planetary clocks           PROVEN
8  LIVE coexistence with controls                      PROVEN
9  complete matrix audit and freeze                    COMPLETE
```

No additional solvable v1 mode remains unimplemented from the frozen matrix.

## Proof record

```text
Stage 0   one-output control contract                  COMPLETE
Stage 1   control address + role vocabulary            PROVEN
Stage 2   body-pinned UT drive                         PROVEN
Stage 3   planetary tract scrub                        PROVEN
Stage 4   constrained UT + fixed-UT body drive         PROVEN
Stage 5   consumer intent seam                         PROVEN
Stage 6   consumer socket qualification                PROVEN
Stage 7   complete solvability matrix                  FROZEN
Stage 8   degree-locked body + exact triple            PROVEN
Stage 9   previous / next occurrence navigation        PROVEN
Stage 10  pure absolute + relative UT                  PROVEN
Stage 11  control-domain availability                  PROVEN
Stage 12  difficult tract geometry                     PROVEN
Stage 13  all eleven bodies as temporal grips          PROVEN
Stage 14  LIVE coexistence + socket stress             PROVEN
Stage 15  audit + freeze                               COMPLETE
```

Final accumulated package proof before this spec-only freeze, 2026-08-26:

```text
swift test

Executed 492 tests
0 failures
0 unexpected
```

## Canonical home

Production:

```text
native/OrboCore/Sources/OrboCore/OrboSystem/Horae/
    Horae.swift
    HoraeControls.swift
    HoraeOutput.swift
```

Proofs:

```text
native/OrboCore/Tests/OrboCoreTests/OrboSystem/Horae/
```

Horae remain an `OrboSystem` sibling. They do not move inside OrboSpine.

## Freeze

Horae Controls v1 are complete for the frozen solvability matrix.

> **OrboSpine owns the coordinate system. Horae speak the coordinate system.**

Future Horae work requires a new explicit requirement. Iris may now consume this socket without learning OrboSpine Locate internals.