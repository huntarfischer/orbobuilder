# Iris - Spatial Expression v1 Plan

**Status:** APPROVED PLAN  
**Target:** Orbo 1.0 native  
**Source branch:** `feature/engraving-orbospine-graft`  
**Planned work branch:** `feature/iris-spatial-expression-v1`

## Purpose

Build the first real Iris expression layer over the running OrboSpine + Horae system.

The central law is:

> **Iris expresses one lawful Orbo celestial-terrestrial state in multiple spatial forms, from flat Astrolabe face to expanded Timespine, while Horae mediate every movement through time.**

No Iris stage may bypass Horae to Locate.

```text
ORBOSPINE / LOCATE
        |
      HORAE
        |
   HoraeOutput
        |
       IRIS
        |
     CHART3D
```

Interaction returns through the same seam:

```text
user gesture / control
        |
       IRIS
        |
HoraeControlIntent
        |
      HORAE
        |
   HoraeOutput
        |
       IRIS
```

## Truth ownership

Orbo / Horae truth:

```text
body
directional degree
UT
Terra
control state
```

Frozen Iris scene truth remains canonical and traceable:

```text
source coordinate retained
physical longitude -> unit-circle X/Y
Julian Day -> raw Z
```

Iris spatial expression may add only presentation transforms:

```text
body sphere form
body display size
body track radius
sign color
zodiac frame
visible Z scale
flat / expanded time depth
camera / projection
focus / fade
```

These transforms must never mutate the canonical source.

## Expression axes

The pass must keep these controls independent:

| Dimension | State A | State B |
| --- | --- | --- |
| Body size | equal | planet-sized |
| Body tracks | unified zodiac circle | concentric body lanes |
| Time depth | flat | expanded Timespine |
| Camera | top | oblique/free 3D |
| Projection | orthographic | perspective |
| Orientation | zodiac-oriented | later ASC-oriented |
| Focus | all bodies | selected temporal hand |

True North Node remains a point for v1.

## IX0 - Canonical seam audit

No production Swift.

Inspect only:

```text
existing canonical degree -> sign law
existing placement formatting
current live OrboSpine / Horae construction seam
current Terra semantics and any local-frame seam
current Iris package surface
Chart3D primitives needed by later stages
```

If Orbo already owns sign/placement law, Iris must reuse it rather than create a duplicate zodiac implementation.

Stop and report before IX1.

## IX1 - First real Door One sight

Replace the synthetic Iris host fixture with one real `HoraeOutput` path.

```text
Horae.seek(T)
    -> HoraeOutput
    -> output.celestial
    -> IrisScene3D
```

Prove:

```text
11 canonical bodies
one exact UT
Terra accompanies the state
all source coordinates preserved unchanged
```

No new visual grammar yet.

## IX2 - Zodiac expression

Make longitude readable without creating new celestial truth.

Reuse canonical sign law.

Iris owns presentation only:

```text
FIRE   Aries / Leo / Sagittarius       red family
EARTH  Taurus / Virgo / Capricorn      green family
AIR    Gemini / Libra / Aquarius       yellow/gold family
WATER  Cancer / Scorpio / Pisces       blue family
```

Each sign receives a related shade within its elemental family.

The active body color follows current sign.

Boundary proof must include at minimum:

```text
29.999... Aries -> Aries color
30.000... Taurus -> Taurus color
```

Add placement readout from canonical longitude/directional state and the first colored zodiac rim for the active plane.

## IX3 - Body expression

Physical bodies become spheres. True North Node remains a point.

Add two presentation-only size modes:

```text
.equal
.planetSized
```

`planetSized` uses a compressed stable relative visual hierarchy, not literal astronomical scale.

Law:

```text
body size = stable identity cue
sign color = changing placement cue
```

Switching size mode must not alter scene truth.

## IX4 - Unified <-> concentric tracks

Add presentation-only radial separation.

Frozen scene truth remains on the unit zodiac circle.

Expression gains an animatable track expansion:

```text
trackExpansion = 0 -> one common zodiac radius
trackExpansion = 1 -> full concentric body lanes
```

Conceptually:

```text
renderRadius = interpolate(commonRadius, bodyRadius, trackExpansion)
renderX = renderRadius * cos(longitude)
renderY = renderRadius * sin(longitude)
```

Body-lane ordering must be explicitly approved before implementation; array order must not silently become cosmology.

## IX5 - Real Timespine viewport

Build a finite visible temporal window from repeated Horae cross-sections.

Iris owns visible window and sampling density. Horae own truthful temporal answers.

```text
UT1 -> Horae -> 11 bodies + Terra
UT2 -> Horae -> 11 bodies + Terra
UT3 -> Horae -> 11 bodies + Terra
...
```

Choose the first proof interval to include at least one sign crossing and, if practical, a station / retrograde passage.

Render body tracts as dense lawful point sequences. Do not invent an arbitrary 3D LineMark engine.

Add the central Bone as native Chart3D presentation geometry.

Raw Julian Day remains source truth; visible Z compression belongs to presentation.

## IX6 - Horae plane

Make the selected UT cross-section explicit geometry.

The active `HoraeOutput` supplies:

```text
selected UT
11 current celestial coordinates
Terra
```

The plane sits at that UT and carries the colored zodiac rim and current body marks.

Doctrine:

> **The Horae plane is the face of the Astrolabe.**

The Astrolabe must not be generated as a separate celestial scene.

## IX7 - Terra preservation and terrestrial seam

Every sampled Horae state already carries Terra. Iris must preserve that companion through the visualization pipeline instead of dropping it until a later Astrolabe stage.

Current conceptual chain:

```text
Horae state
    celestial
    +
    Terra
```

Do not synthesize Ascendant from Terra alone.

Future local chain remains:

```text
Terra universal orientation
        +
native/live geolocation
        -> local terrestrial frame
        -> Horizon
        -> Asc / MC / local orientation
```

If current canonical Terra geometry can be shown without inventing meaning, a restrained visual reference may be considered. Otherwise preserve Terra only and document the future seam.

## IX8 - Temporal flatten <-> expand

Add an animatable presentation parameter:

```text
timeExpansion
```

```text
1.0 -> full Timespine depth
0.0 -> all visible temporal depth collapsed to the active Horae plane
```

Canonical UT never changes.

Conceptually:

```text
renderZ = activePlaneZ + (expandedZ - activePlaneZ) * timeExpansion
```

This proves one lawful scene can move continuously between temporal structure and flat celestial face.

## IX9 - Astrolabe A: celestial face

At flat time depth, use top-down orthographic Chart3D presentation.

Implement zodiac-oriented mode first, matching the Orbo prototype convention:

```text
Aries at 9 o'clock
```

The face carries:

```text
12-sign elemental-color rim
current body marks
current placements
equal or planet-sized mode
unified or concentric track mode
```

ASC-oriented mode is deferred until lawful local Horizon/place truth exists.

## IX10 - First temporal controls

Connect the proven Horae consumer socket to Iris controls.

Start only with:

```text
absolute UT
relative UT
body focus
```

Closed loop:

```text
user -> Iris -> HoraeControlIntent -> Horae -> HoraeOutput -> Iris
```

Iris may show driven / pinned / resolved metadata from `HoraeControlState` but must not infer it.

## IX11 - Planet-as-hand temporal scrubbing

Freeze this interaction law:

> **Planetary scrubbing is temporal, not positional. A selected body acts as the visible hand of time. User gesture controls UT monotonically; the body's apparent direction is determined solely by its lawful tract. Retrograde may reverse the body without reversing the user's gesture.**

Thus:

```text
finger -> -> -> ->
time   -> -> -> ->
Mercury -> -> station <- <-
```

During scrub:

```text
selected body emphasized
other bodies visually fade but remain lawfully resolved
Horae plane continues moving through UT
```

When scrub settles, the full cross-section returns to emphasis.

## IX12 - Interaction polish and haptic hooks

Prove the interaction layer can support later transversal work without building the full transversal view.

Include only bounded polish:

```text
focus fade
scrub settling
selection emphasis
sign-color transitions
station reversal during monotonic temporal gesture
Bone-boundary feedback
selection-settle feedback
```

Do not add recurrence-node haptics yet; those belong to the later transversal pass where those nodes become explicit visual topology.

## IX13 - Qualification and freeze

Stress combinations, not only isolated features:

```text
equal <-> planet-sized
unified <-> concentric
flat <-> expanded
top <-> perspective
sign-color boundaries
real retrograde
real Horae movement
Terra preserved
monotonic scrub through station
canonical source unchanged
```

Visual qualification should include at minimum:

```text
celestial Astrolabe
expanded Timespine
concentric Timespine
unified Timespine
planet-sized mode
equal-size mode
planet-as-hand temporal scrub
```

Freeze only after tests and visual proof.

## Immediately following pass - Iris Transversal v1

Do not build this during Spatial Expression v1, but the current architecture must leave room for it.

Cross-sectional question:

```text
what exists at this UT?
```

Transversal question:

```text
how does this selected body's temporal path unfold?
```

The intended visual is a selected body tract opening from the active Horae plane as a spiral staircase through time. Exact repeated occurrences of a chosen body/state become nodes or landings.

The user's scrub remains temporal and continuous. Retrograde can reverse the body's visual course without reversing the gesture.

Future recurrence behavior:

```text
ordinary tract position      no haptic
exact recurrence node        haptic tick
selected occurrence          stronger selection feedback
```

After an occurrence is chosen, the Horae plane moves to that UT and the other bodies return to full emphasis.

## Explicitly deferred from Spatial Expression v1

```text
Ascendant synthesis
houses
local Horizon calculation
ASC-oriented Astrolabe
aspect visualization
Ring / Mater / Tympan / Arc overlays
full traditional chart styling
literal astronomical distance scale
literal astronomical body-size scale
Node symbolism beyond a point
arbitrary 3D line engine
Chronos search
transversal staircase
occurrence constellation UI
full recurrence-node haptic vocabulary
```

## Target end state

```text
FULL TIMESPINE
    temporal depth expanded
    body tracks concentric or unified
    planet-sized or equal spheres
    signs colored
        |
        v
HORAE PLANE
        |
        v
CELESTIAL ASTROLABE
    top-down / orthographic
    zodiac-oriented
        |
        v
later LOCAL ASTROLABE
    Terra + place + Horizon
    zodiac <-> ASC oriented
```

At every state:

```text
same Orbo truth
same Horae seam
same Iris source traceability
different Iris expression
```

## Build discipline

Each stage follows:

```text
inspect / define
-> user fires stage
-> implement only that stage
-> run tests
-> report
-> wait
```

No production Swift is changed by this plan itself.
