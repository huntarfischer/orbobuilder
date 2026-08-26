# Horae - Controls v1 Stage 7 Solvability Matrix

**Status:** STAGE 7 / CONTRACT
**Target:** Orbo 1.0 native
**Branch:** `feature/engraving-orbospine-graft`

## Purpose

Freeze the complete Horae control-solvability law before adding the remaining controls.

Horae navigate one native OrboSpine coordinate system:

```text
(body, directionalDegree, UT)
```

The three values are not independent. Horae may expose only combinations that exist on the forged Spine.

## Two outward situations

Horae have one outward signal, `HoraeOutput`, but they may expose two different temporal situations through it.

### Point address

A selected body is part of the control/readout:

```text
(body, directionalDegree, UT)
```

This is represented by `HoraeAddress` inside `HoraeControlState`.

### UT cross-section

A UT may also be selected without choosing one body:

```text
UT
 |
 v
all canonical body coordinates
+
Terra
```

This is the existing SEEK/LIVE truth path. A pure UT cross-section must not invent a dummy body merely to satisfy point-address metadata.

The distinction is:

```text
POINT ADDRESS
one selected body + its state + UT

UT CROSS-SECTION
one UT + all body states at that UT
```

Both remain one `HoraeOutput` cable.

## Solvability classes

### 1. Unique solution

Two supplied coordinates determine the third exactly.

```text
BODY + UT -> DIRECTIONAL DEGREE
```

For a canonical body at a valid UT, Locate supplies one directional state.

### 2. Discrete solution set

Two supplied coordinates admit zero, one, or many isolated solutions.

```text
BODY + DIRECTIONAL DEGREE -> [UT occurrences]
```

Locking a body and directional degree removes most UT values from the available Bone. Horae may navigate only the real occurrence set.

### 3. Exact constraint

All three coordinates are supplied.

```text
BODY + DIRECTIONAL DEGREE + UT
```

The triple either exists on the forged Spine or it does not. Horae must validate it and must not clamp, wrap, interpolate to a different address, or guess.

### 4. Continuous domain

UT alone selects a continuous horizontal level of the Bone.

```text
UT -> complete celestial cross-section + Terra
```

This is the SEEK domain. Pure UT control is a first-class Horae capability and does not require a selected body.

### 5. Underdetermined request

A request that does not identify a unique address, a valid occurrence-navigation problem, or a UT cross-section is not silently completed by Horae.

Horae do not invent a body, occurrence, direction, or continuity anchor.

## Complete control matrix

`DRIVEN` means the coordinate the consumer is actively changing.
`PINNED` means the consumer requires the value to stay fixed.
`RESOLVED` means Spine truth supplies the value.

Exactly one coordinate is driven during a control action.

### UT driven

#### Pure UT seek

```text
BODY                 --
DIRECTIONAL DEGREE   --
UT                   DRIVEN
```

Result: one UT cross-section.

Law: continuous on the half-open Bone. No selected body is required.

#### Body pinned, UT driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   RESOLVED
UT                   DRIVEN
```

Result: one point address carried with the complete UT cross-section.

#### Body + degree pinned, UT driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   PINNED
UT                   DRIVEN
```

Result: UT may move only among the real occurrence set for `(body, directionalDegree)`.

This is a discrete temporal domain, not continuous free UT.

### Directional degree driven

#### Body pinned, degree driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   DRIVEN
UT                   RESOLVED
```

Result: planetary tract scrub. A continuity anchor selects among repeated occurrences. The body's forged tract determines the resulting UT movement.

#### Body + UT pinned, degree driven

```text
BODY                 PINNED
DIRECTIONAL DEGREE   DRIVEN
UT                   PINNED
```

This is not freely movable. `BODY + UT` already uniquely determines degree.

Therefore the degree is logically RESOLVED, not DRIVEN. Horae must not pretend this is an independent control mode.

#### UT pinned, degree driven with no body

```text
BODY                 --
DIRECTIONAL DEGREE   DRIVEN
UT                   PINNED
```

This is underdetermined as a point-address request because multiple or zero bodies may occupy that state at the UT. If the consumer wants to move among matching bodies, BODY is the driven coordinate and degree remains pinned.

### Body driven

#### UT pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   RESOLVED
UT                   PINNED
```

Result: move among canonical bodies within one fixed horizontal cross-section.

#### Degree pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   PINNED
UT                   RESOLVED
```

Result: for each selected body, Horae resolves a valid occurrence of that fixed directional state using an explicit temporal continuity anchor.

This is the missing Stage 8 control.

#### Degree + UT pinned, body driven

```text
BODY                 DRIVEN
DIRECTIONAL DEGREE   PINNED
UT                   PINNED
```

Result: exact constraint satisfaction. The selected body is valid only if it occupies the pinned directional state at the pinned UT.

No match means no valid address.

## Occurrence law

For `(body, directionalDegree)` the available UT values form an occurrence set:

```text
UT1, UT2, UT3, ...
```

Horae may support two distinct operations over this same truthful set:

```text
CONTINUITY RESOLUTION
choose the occurrence nearest an explicit temporal anchor

OCCURRENCE NAVIGATION
move previous / next through the ordered occurrence set
```

The first supports continuous control gestures. The second is an explicit navigation capability to be added later.

Neither operation is Chronos search because the destination is already defined by an exact body/state coordinate.

## Relative UT law

Pure UT control may be expressed as either:

```text
ABSOLUTE
seek to UT

RELATIVE
advance / retreat by delta-UT
```

Relative UT changes the requested temporal coordinate only. It does not define a planetary rate. Iris may decide how a visible interaction produces the delta; Horae apply the delta truthfully within Bone bounds.

## Boundaries

The Bone is half-open:

```text
[start, endExclusive)
```

Horae must preserve Locate's boundary law for every control mode.

No control may wrap from one Bone end to the other, clamp an outside request, or fabricate an endpoint occurrence.

## Ownership

```text
ORBOSPINE / LOCATE
owns valid coordinates, occurrence sets, stations, lanes, Bone bounds, and Terra truth

HORAE
owns truthful navigation grammar, continuity choice, constrained validation, and consumer-facing temporal control capability

IRIS
owns representation, gesture capture, visible rate, buttons, sliders, animation, camera, and display

CHRONOS
later owns search for meaningful temporal destinations
```

## Stage 7 acceptance

The remaining Horae work is now bounded by this matrix:

1. Complete `DEGREE PINNED / BODY DRIVEN / UT RESOLVED`.
2. Add exact `DEGREE + UT PINNED / BODY DRIVEN` validation.
3. Add explicit occurrence navigation over `(body, degree)` solutions.
4. Make pure absolute and relative UT movement available through the consumer control seam without inventing a body.
5. Expose only the control-domain metadata needed by consumers.
6. Prove direct/station/retrograde and zodiac-wrap continuity.
7. Prove every canonical body can act as a planetary clock with no Horae speed table.
8. Prove LIVE coexists with every control path without hidden state.
9. Freeze only after the complete matrix is covered.

No production Swift is changed in Stage 7.
