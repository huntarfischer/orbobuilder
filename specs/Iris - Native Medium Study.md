# Iris - Native Medium Study

**Status:** ACTIVE STUDY  
**Branch:** `feature/iris-native-medium-study`  
**Base:** frozen `feature/iris-spatial-expression-v1`  
**Purpose:** learn what native Swift wants Orbo's visual language to be before Aello begins salvaging the browser prototype.

## Governing question

> **What can Iris express naturally with native Swift before the old prototype supplies the answer?**

This is a study, not a production architecture decision.

## Law held constant

The study does not reopen Spatial Expression v1.

```text
Orbo / Horae truth remains unchanged
IrisScene3D truth remains unchanged
zodiac orientation remains unchanged
body identity remains unchanged
body-size law remains unchanged
track law remains unchanged
```

Only the rendering surface changes.

## Study A - flat celestial instrument

Compare the same exact Horae plane through:

```text
SwiftUI Canvas
vs
Chart3D top-down orthographic
```

Both receive the same:

```text
Horae-resolved celestial state
Iris zodiac expression
Iris body expression
Iris track expression
Iris zodiacal orientation
```

The host exposes only two existing presentation switches:

```text
unified <-> concentric tracks
equal <-> planet-sized bodies
```

The Canvas proof draws:

```text
zodiac rim as native paths
sign boundaries
body tracks
body marks
```

It intentionally does not add:

```text
prototype styling
brass
glyph system
aspect web
houses
Lunar Pane
new astrology
new interaction law
RealityKit
Metal
```

## What to judge visually

Do not ask which version looks more finished.

Ask:

```text
Which surface feels more like an instrument?
Which gives Iris more exact authorship over geometry?
Which makes hierarchy easiest to control?
Which feels easiest to animate without fighting the framework?
Which seems capable of rings, ticks, chords, glyph anchors, and curved surfaces?
Which capabilities are genuinely useful from Chart3D and should remain available?
```

## Decision rule

The study does not choose one universal renderer.

Possible outcome:

```text
Canvas
    -> native instrument geometry

Chart3D
    -> temporal / spatial data expression

SwiftUI
    -> composition / controls / text / transitions

heavier rendering
    -> only when a later proven visual need requires it
```

That outcome is allowed but not presumed.

## Stop condition

Study A is complete when the Canvas and Chart3D versions can be viewed against the same lawful Horae moment and compared directly.

Do not continue automatically into temporal paths, interaction, or prototype parity.

The visual result determines whether another native-medium experiment is worth doing before Aello.
