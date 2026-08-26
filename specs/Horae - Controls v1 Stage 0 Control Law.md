# Horae - Controls v1 Stage 0 Control Law

**Status:** STAGE 0 FROZEN

## Scope

Stage 0 defines the control law only. It changes no production code and adds no navigation behavior.

The proven Horae LIVE/SEEK core remains untouched.

## Native address

Horae Controls v1 operates on the existing OrboSpine address:

```text
(body, directionalDegree, UT)
```

For control/readout purposes:

```text
X = body
Y = directionalDegree
Z = UT
```

These are not three independent invented values. They are one truthful address on the OrboSpine.

## Coordinate roles

Each coordinate has exactly one role:

```text
HELD       keep this value fixed
DRIVEN     this is the value being moved
RESOLVED   OrboSpine truth determines this value
```

At most one coordinate is DRIVEN at a time.

Zero, one, or two coordinates may be HELD.

Any coordinate uniquely determined by the held/driven values is RESOLVED. Horae must not expose an impossible independent movement merely because a readout has three fields.

## Planetary scrubber law

**The bodies are the scrubbers.**

When BODY is HELD and DIRECTIONAL DEGREE is DRIVEN, Horae follows that body's actual forged tract and resolves UT from valid OrboSpine occurrences.

```text
BODY                HELD
DIRECTIONAL DEGREE  DRIVEN
UT                  RESOLVED
```

A body never moves according to a generic Horae rate.

The Moon, Mercury, Saturn, and every other canonical body traverse UT according to their own OrboSpine geometry. Their different apparent scrub rates are consequences of the forged tracts, not constants owned by Horae.

## Continuity law

The same body and directional state may occur more than once on the finite Bone.

Therefore a planetary scrub must preserve the current tract neighborhood. Horae may not jump arbitrarily between valid occurrences of the same `(body, directionalDegree)`.

```text
current address
      |
      v
body tract neighborhood
      |
      v
next driven directional state
      |
      v
continuous valid occurrence
      |
      v
resolved UT
```

**Position determines truth; tract continuity determines which repeated occurrence is being traversed.**

## Constraint law

For any control state:

```text
If held/driven coordinates uniquely determine another coordinate,
that coordinate is RESOLVED.

If the constraints admit multiple valid Spine solutions,
Horae may expose those valid solutions for navigation.

If the constraints admit no Spine solution,
Horae reports no valid address.
```

Horae never fabricates a coordinate to satisfy a requested control arrangement.

## Directional-state law

`directionalDegree` remains the OrboSpine directional state, not plain zodiac longitude.

Its direct and retrograde lanes are part of the address. Planetary scrubbing therefore follows the tract through direct motion, stations, retrograde motion, and directional-space wrap without collapsing those states into a 0..<360 longitude-only control.

## Existing Horae law remains

LIVE and SEEK retain their frozen meanings.

```text
SEEK(UT) -> one canonical celestial + Terra cross-section
LIVE()   -> current UT through the same SEEK path
```

Controls v1 sits above those proven semantics. Stage 0 does not alter either behavior.

## Ownership

```text
ORBOSPINE
owns coordinate truth and tract geometry

LOCATE
exposes valid coordinates and occurrences

HORAE
owns temporal control semantics over those truths
```

Horae performs no ephemeris work, invents no planetary speed, and creates no second representation of the Spine.

## Non-goals

Stage 0 does not define or build:

- rendering;
- gestures;
- visual controls;
- buttons or sliders;
- camera behavior;
- generic playback or speed multipliers;
- Chronos search;
- event interpretation;
- new astronomy;
- duplicate Spine truth.

## Frozen Stage 0 law

> Horae Controls v1 treats `(body, directionalDegree, UT)` as one constrained OrboSpine address. One coordinate may be driven while zero, one, or two others are held; all remaining values are resolved from Spine truth. The bodies themselves are the scrubbers, and each traverses time only according to its own forged tract. Horae preserves tract continuity, never invents planetary rate, and never fabricates an impossible address.
