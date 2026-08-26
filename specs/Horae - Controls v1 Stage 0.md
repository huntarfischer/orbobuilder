# Horae - Controls v1 Stage 0

**Status:** STAGE 0 / CONTRACT
**Target:** Orbo 1.0 native
**Branch:** `feature/engraving-orbospine-graft`

## Purpose

Extend the proven Horae adapter with a control grammar for Timespine navigation without creating another Horae output or moving visual responsibility out of Iris.

## Existing law remains

Horae remain posted at OrboSpine Door I: Locate.

```text
ORBOSPINE
    |
I. LOCATE
    |
  HORAE
    |
HoraeOutput
    |
    v
   IRIS
```

`HoraeOutput` remains the single outward Horae signal.

Controls do not create a second output, side channel, or parallel representation. They change which valid Spine address Horae is exposing through the same output cable.

```text
CONTROL INTENT
      |
      v
    HORAE
      |
      v
HoraeOutput
      |
      v
     IRIS
```

If control/readout metadata must later travel outward, it belongs inside this one Horae signal rather than beside it as another Horae output.

## Native control address

The control grammar uses the existing three-part Spine address:

```text
(body, directionalDegree, UT)
```

For the control model:

```text
x = body
y = directionalDegree
z = UT
```

These are not three independent truths. They are three grips on one valid point of the OrboSpine.

## Bodies are the scrubbers

There is no generic timeline scrubber in Horae Controls v1.

A body is a temporal grip because moving that body along its own forged tract changes UT according to that body's actual motion.

```text
BODY + DIRECTIONAL DEGREE
          |
          v
     body tract
          |
          v
          UT
          |
          v
        SEEK
          |
          v
    HoraeOutput
```

Horae do not assign a common movement rate to the bodies. The Moon, Mercury, Venus, Saturn, and every other canonical body traverse UT according to the geometry already present in their own OrboSpine tracts, including retrograde motion and stations.

## Control roles

At any controlled address, each of the three coordinates has one role:

```text
DRIVEN
PINNED
RESOLVED
```

### DRIVEN

The coordinate the user is actively moving.

Exactly one coordinate is driven during one control action.

### PINNED

A coordinate the user requires to remain fixed while another coordinate is driven.

Zero, one, or two coordinates may be pinned.

### RESOLVED

A coordinate determined by OrboSpine truth from the driven coordinate and any pinned constraints.

Horae never fabricate a resolved value merely to satisfy a control gesture.

## Core examples

### Body pinned, directional degree driven

```text
BODY                 Mercury     PINNED
DIRECTIONAL DEGREE   379.42      DRIVEN
UT                   2461274.53  RESOLVED
```

Mercury is the scrubber. Moving Mercury along its tract resolves UT. The resulting UT is exposed through the same `HoraeOutput` as every other Horae interaction.

### UT driven

```text
BODY                 Mercury     RESOLVED
DIRECTIONAL DEGREE   379.42      RESOLVED
UT                   2461274.53  DRIVEN
```

Driving UT follows the already-proven SEEK truth path. Body positions are read from the resulting cross-section.

### UT pinned, body driven

```text
BODY                 Venus       DRIVEN
DIRECTIONAL DEGREE   112.08      RESOLVED
UT                   2461274.53  PINNED
```

The horizontal celestial cross-section remains fixed while the user moves among bodies within that level of the Spine.

## Constraint law

Pinning does not grant permission to violate the Spine.

When two coordinates are fixed and the third is driven, Horae may expose only addresses that actually exist on the forged OrboSpine. If no valid address satisfies the control state, Horae must not clamp, wrap, guess, or invent one.

Occurrence disambiguation and continuity rules belong to later implementation stages. Stage 0 freezes only the requirement that any chosen occurrence must be real Spine truth.

## Iris boundary

Iris owns representation and gesture.

Horae own the temporal consequence of a control action.

OrboSpine owns the truth being exposed.

```text
IRIS
user manipulates a visible body or readout
        |
        v
HORAE
applies driven / pinned constraints
        |
        v
ORBOSPINE LOCATE
supplies the valid address and cross-section
        |
        v
HORAE
one HoraeOutput
        |
        v
IRIS
redraws the top-down view
```

Iris does not decide planetary rates, occurrence choice, retrograde behavior, station behavior, or celestial truth.

Horae do not decide glyphs, layout, camera, animation style, drag geometry, or visual emphasis.

## Stage 0 laws

1. Horae retain exactly one outward signal: `HoraeOutput`.
2. All controls act on that same signal; no control receives its own Horae output channel.
3. The control address is `(body, directionalDegree, UT)`.
4. Exactly one coordinate is driven during one control action.
5. Zero, one, or two other coordinates may be pinned.
6. Every remaining coordinate is resolved from real OrboSpine truth.
7. Canonical bodies are the scrubbers; there is no generic Horae timeline scrubber.
8. Each body moves through UT according to its own forged tract. Horae invent no common body speed.
9. Retrograde motion and stations remain OrboSpine truth, not Horae control logic.
10. Iris owns how controls appear and how gestures are captured.
11. Horae own the valid temporal consequence of those gestures.
12. Impossible constraints never produce fabricated output.

## Non-goals for Stage 0

No production code.
No new output type.
No playback controls.
No generic slider.
No rate multiplier.
No Chronos search.
No Iris rendering.
No occurrence-disambiguation algorithm yet.
No modification to the frozen Horae core.

## Stage 0 acceptance

```text
The planets are the scrubbers.
The control address is (body, directionalDegree, UT).
One coordinate is driven; zero to two may be pinned; the rest resolve from Spine truth.
Every control ultimately changes the same HoraeOutput.
Iris receives one Horae cable.
```
