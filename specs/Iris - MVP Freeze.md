# Iris — MVP Freeze

**Status:** FROZEN  
**Date:** 2026-08-24  
**Branch:** `feature/iris-mvp`  
**Base:** `4b2323ce63b9aff441538fcec3c60185c59bfee2`  
**Final qualification:** pending one local `swift test` after I6 pull  
**Scope:** Iris MVP only: faithful 3D scene construction and Chart3D presentation of lawful Orbo celestial-time coordinates.

---

## Frozen doctrine

> **Given lawful Orbo data, Iris can construct a faithful visual scene from it without changing the data.**

The shorter law is:

> **Orbo knows. Iris shows.**

Iris may transform representation without transforming truth.

She does not calculate astrology, choose times, search the Timespine, infer motion, reinterpret coordinates, or alter source data. She receives lawful data and makes it visible.

The architectural analogy is deliberate:

```text
Hermes carries without interpreting.
Iris shows without interpreting.
```

---

## Frozen input boundary

The first Iris input atom is the existing canonical Orbo type:

```swift
OrboSpineCelestialCoordinate
```

It already carries:

```text
body
+
directional zodiac state
+
Julian Day
```

or, in Timespine terms:

```text
BODY × STATE × UT
```

Iris does not require `HoraeOutput` and does not call Horae. Any lawful caller may supply `[OrboSpineCelestialCoordinate]`.

Current Horae may be one supplier, but Iris is not architecturally owned by Horae.

This keeps Iris stable even if Horae changes later.

---

## Frozen scene truth

`IrisScene3D` preserves the canonical coordinates exactly and projects each one into one visualization-native point:

```text
physical zodiac longitude → X / Y
Julian Day                → Z
source coordinate         → retained unchanged
```

The projection is:

```text
θ = physical zodiac longitude
x = cos(θ)
y = sin(θ)
z = julianDay.value
```

No time normalization is part of scene truth.

No random identifier is added.

No source coordinate is replaced by its visual projection.

Every `IrisScenePoint3D` retains its original `OrboSpineCelestialCoordinate`, so the frozen traceability invariant is:

```text
scene point ↔ canonical source
```

Direct and retrograde states may occupy the same physical longitude in X/Y while remaining distinct in the preserved source state.

---

## Frozen 3D grammar

A single temporal slice is planar. Multiple lawful temporal states reveal the Timespine grammar:

```text
same body
   at T1
   at T2
   at T3
   ...
        ↓
points winding through X/Y
while continuing through Z
```

Thus:

```text
planet/body = tract identity
longitude   = angular position around the zodiac
UT          = Z
```

Retrograde reverses zodiacal winding while UT continues forward.

The MVP uses `PointMark(x:y:z:)`. It does not fake arbitrary tract connections with a line primitive Chart3D does not naturally provide.

A denser lawful sequence of points may visually reveal a tract without changing the underlying scene law.

The current MVP proof scene is a **celestial Timespine strand**, not literal complete AstroDNA. The canonical Timespine has eleven celestial tracts; AstroDNA also contains Ascendant. Iris does not synthesize Ascendant to close that gap.

---

## Truth versus presentation

The MVP freezes a hard boundary between scene truth and presentation state.

### Scene truth

```text
canonical source coordinate
body identity
directional degree
physical degree
Julian Day
x / y / z projection
```

### Presentation only

```text
camera azimuth
camera inclination
orthographic / perspective projection
interactive Chart3D pose
later styling choices
```

`IrisChart3DPresentation` may change how the scene is viewed. It cannot change `IrisScene3D`.

The visual proof is intentionally interactive: the user may rotate the Chart3D scene while every canonical source coordinate remains unchanged.

Frozen law:

> **Move the view, not the truth.**

---

## Frozen module boundary

Iris is a sibling Swift package product:

```text
OrboIris imports OrboCore
OrboCore never imports OrboIris
```

Therefore visualization depends on engine truth, never the reverse.

The package deployment floor remains unchanged:

```text
OrboCore package
  iOS 17+
  macOS 14+
```

The Chart3D view itself is availability-gated:

```text
iOS 26+
macOS 26+
```

The iOS visual proof runs in the existing `Orbo` app target. No alternate renderer was introduced solely for older OS versions.

---

## Frozen MVP surface

Implementation:

```text
native/OrboCore/Sources/OrboIris/IrisScene3D.swift
native/OrboCore/Sources/OrboIris/IrisChart3DPresentation.swift
native/OrboCore/Sources/OrboIris/IrisChart3DView.swift
```

Host proof:

```text
native/Orbo/OrboApp.swift
```

Tests:

```text
native/OrboCore/Tests/OrboIrisTests/IrisScene3DTests.swift
native/OrboCore/Tests/OrboIrisTests/IrisPresentationTests.swift
native/OrboCore/Tests/OrboIrisTests/IrisStressTests.swift
```

The frozen MVP proves:

```text
I1  canonical scene contract
I2  deterministic X/Y/Z projection
I3  first Chart3D sight
I4  short temporal strand
I5  truth / presentation separation
I6  deterministic stress + source traceability
```

I6 supplies 2,816 lawful typed coordinates across all eleven canonical Timespine bodies and verifies:

```text
same input → same scene
same input → same projected points
one point → one unchanged source
Z = source Julian Day exactly
X/Y remain on the unit zodiac circle
all projected values remain finite
```

---

## Build sequence

```text
93a056c8  Build Iris MVP I1 scene contract
3b1e861e  Fix Iris physical-degree precision assertion
c29aad0e  Build Iris MVP I2 coordinate projection
8c616e08  Prove Iris MVP I2 coordinate projection
6958b929  Add Iris Chart3D first-sight view
52e7f716  Host Iris I3 first sight in Orbo
9e1e3710  Link Orbo target to OrboIris

a1226811  Remove obsolete Xcode test target from Orbo scheme
70eb38cc  Remove obsolete Xcode test target from OrboLab scheme

a5edd11f  Build Iris MVP I4 short temporal strand
6a5180fe  Prove Iris MVP I4 temporal strand preservation

5edc4f97  Add Iris presentation state
 dd062085  Apply presentation state to Chart3D view
c88c032e  Prove presentation does not alter scene truth
00d82cf2  Host Iris I5 truth/presentation proof

a5513379  Stress Iris MVP scene contract
87f93a1d  Freeze Iris MVP host proof
```

---

## Explicitly deferred

The Iris MVP does **not** include:

```text
full AstroDNA-through-time rendering
Ascendant / Horizon derivation
real Timespine traversal inside Iris
Horae ownership or coupling
Astrolabe recreation
traditional chart wheel
Ring visualization
Mater visualization
Tympan visualization
Arc visualization
aspect drawing
tract interpolation or arbitrary 3D lines
animation engine
navigation engine
Harpies / sister sub-engine naming
skins / personalized appearance
temporal controls
interpretation
OrboLab rebuild
```

Those may become Iris domains later, but none may require Iris to reinterpret or mutate lawful Orbo truth.

---

## Qualification gate

The freeze is complete architecturally. Final local qualification requires:

```bash
cd native/OrboCore
swift test
```

The final passing test count should be written into this document once supplied from the native Mac toolchain.

The visual proof has already been demonstrated in the iOS 26.3.1 iPhone 17 Pro simulator with an interactive, rotatable Chart3D scene.

---

## Frozen MVP law

> **Orbo handed Iris lawful three-dimensional celestial-time data, and Iris made it visible without changing what it was.**

That is the Iris MVP.
