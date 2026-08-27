# Iris — Spatial Expression v1 Freeze

**Status:** FROZEN  
**Date:** 2026-08-26  
**Branch:** `feature/iris-spatial-expression-v1`  
**Frozen base:** `0de8ae12afdb92da40d92cf16a3083d8e1c684ad`  
**Scope:** First native Swift spatial-expression layer for lawful Orbo celestial-time state.

---

## Frozen doctrine

> **Orbo knows. Iris shows.**

Iris expresses lawful Orbo state spatially without changing the underlying truth.

Canonical celestial state remains owned by OrboSpine and Horae. Iris may change presentation, orientation, scale, projection, body appearance, and visible temporal depth, but it does not calculate astrology or rewrite source coordinates.

---

## Frozen spatial grammar

Iris preserves the canonical celestial coordinate and projects it into 3D:

```text
physical zodiac longitude → X / Y
Julian Day                → Z
source coordinate         → retained unchanged
```

Body identity may affect presentation-only size and radial placement. Sign may affect presentation-only color. Directional state remains carried by the canonical source.

A single Horae moment is one exact celestial state. Multiple moments may later be expressed through Z as manifestations of time, but the frozen host proof intentionally uses one moment so camera geometry can be read cleanly.

---

## Frozen camera law

The first Iris visualization does not use a free-orbit camera.

It exposes three canonical locked readings of the same 3D state:

```text
TOP
VERTICAL
HORIZONTAL
```

Top looks along Orbo's temporal Z axis and is the one-moment celestial view.

Vertical and Horizontal are fixed edge-on readings of the same geometry. They are reserved as the natural directions in which later temporal expression may become visible.

The current proof changes among those three locked poses through an explicit selector. User tumbling of the chart is not part of this frozen layer.

---

## Horae Plane

`IrisHoraePlane` remains valid frozen work.

It represents one exact Horae snapshot, including its exact celestial coordinates, Julian Day, Terra state, and zodiac rim presentation.

It is not the architectural center of this first spatial-expression layer and is not required to define the main locked 3D visualization. It may be used later as a separate snapshot expression.

---

## Frozen implemented surface

Core Iris work on this branch includes:

```text
IrisHoraeFrame
IrisZodiacExpression
IrisBodyExpression
IrisTrackExpression
IrisTimespineViewport
IrisHoraePlane
IrisTerraReadout
IrisTemporalExpression
IrisOrientationExpression
IrisChart3DPresentation
IrisChart3DView
```

The current host proof uses one lawful Horae-resolved celestial moment containing the eleven canonical celestial bodies and presents that same state through Top, Vertical, and Horizontal locked views.

The branch also preserves earlier experiments with temporal sampling and Horae-backed control plumbing, but those experiments do not redefine the frozen camera or truth law above.

---

## What this branch proves

```text
lawful Orbo celestial coordinates can be expressed in native 3D
source truth survives presentation changes unchanged
body size and radial placement can remain presentation-only
sign color can remain presentation-only
Julian Day can serve as the spatial time axis
one Horae moment can be shown coherently from three locked viewpoints
Top is the one-moment celestial reading
Vertical / Horizontal can expose the other spatial dimensions without changing the state
Horae Plane snapshots can coexist as a separate Iris expression
```

---

## Explicitly not completed here

This freeze does not claim completion of:

```text
planet grabbing
planet-as-time scrubbing
continuous temporal navigation
camera-transition animation
final multi-moment Vertical / Horizontal temporal grammar
full local Horizon / Ascendant orientation
traditional houses or aspect rendering
final production interaction layer
```

Those are future Iris work and are not prerequisites for freezing this first spatial-expression branch.

---

## Qualification

The final host proof was visually checked in the iOS 26 iPhone 17 Pro simulator in all three locked views.

No new automated-suite count is claimed by this freeze after the final one-moment lock-off reduction. Earlier Iris stages on the branch were repeatedly exercised through the OrboCore/Xcode test suite, but this document freezes the repository state as it exists rather than inventing a final test count.

---

## Frozen law

> **Iris v1 can faithfully place lawful Orbo celestial state into native three-dimensional space and show one exact moment through three meaningful locked perspectives without changing the truth it was given.**

That is the frozen Spatial Expression v1 branch.
