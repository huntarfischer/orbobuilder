# Iris - Spatial Expression v1 Grammar

**Status:** APPROVED GRAMMAR  
**Home:** `feature/engraving-orbospine-graft` before the Spatial Expression work branch is cut

## Governing law

> **Iris may transform representation without transforming truth.**

For Spatial Expression v1:

> **Longitude determines where. Body determines its lane and form. Sign determines its color. UT determines its height. Iris may collapse or expand that height, but never changes the time it represents.**

Horae remain the sole temporal consumer seam between Iris and OrboSpine.

## Truth grammar

Canonical Orbo / Horae truth:

```text
BODY
DIRECTIONAL DEGREE
UT
TERRA
CONTROL STATE
```

Frozen Iris scene truth:

```text
canonical source coordinate retained
physical longitude -> unit-circle X/Y
raw Julian Day -> Z
```

No expression choice may mutate these values.

## Body grammar

Body identity may be expressed redundantly for legibility.

```text
physical body -> sphere
True North Node -> point for v1
```

Body size has two independent presentation modes:

```text
EQUAL
all physical body spheres use one display size

PLANET-SIZED
physical bodies use stable compressed relative display sizes
```

Planet-sized is symbolic/compressed presentation, not literal astronomical scale.

Body identity may also be expressed by radial lane when concentric tracks are enabled.

```text
body -> stable visual lane
```

## Track grammar

Track geometry is presentation, not celestial truth.

```text
UNIFIED
all bodies share one zodiac display radius

CONCENTRIC
each body receives a stable visual radius
```

The two states must be collapsible/expandable through one presentation parameter.

```text
trackExpansion = 0 -> unified
trackExpansion = 1 -> concentric
```

Body-lane order must be explicitly chosen, not inherited accidentally from array order.

## Zodiac grammar

Sign is already implicit in canonical physical longitude and must reuse Orbo's canonical zodiac/sign law if one exists.

Iris owns only its visual expression.

Element families:

```text
FIRE
Aries
Leo
Sagittarius
-> red family

EARTH
Taurus
Virgo
Capricorn
-> green family

AIR
Gemini
Libra
Aquarius
-> yellow/gold family

WATER
Cancer
Scorpio
Pisces
-> blue family
```

Each sign receives a related shade within its elemental family.

Primary sign cues:

```text
angular position -> exact sign/placement
sphere color     -> sign + elemental family
zodiac rim       -> sign regions
```

A body's sign color changes as its lawful longitude crosses a sign boundary while body size and body lane remain stable.

Example:

```text
Mercury at 29° Aries
same Mercury size
same Mercury lane
Aries-red

Mercury at 0° Taurus
same Mercury size
same Mercury lane
Taurus-green
```

## Time grammar

Canonical UT is never rewritten.

Expanded Timespine presentation maps UT into visible depth.

Flat Astrolabe presentation collapses visible temporal depth onto the active Horae plane without altering canonical UT.

```text
timeExpansion = 1 -> expanded Timespine
timeExpansion = 0 -> flat Horae plane
```

Thus flat and 3D are two spatial expressions of the same truth, not separate celestial products.

## Horae plane grammar

One `HoraeOutput` selects one exact temporal cross-section:

```text
UT
 |
 v
11 canonical celestial coordinates
+
Terra
```

The active Horae plane is the visible cross-section at that UT.

> **The Horae plane is the face of the Astrolabe.**

The Astrolabe must reuse this plane rather than rebuild celestial truth separately.

## Astrolabe grammar

Spatial Expression v1 builds the celestial face first.

```text
flat time depth
+
top-down camera
+
orthographic projection
=
celestial Astrolabe face
```

Initial orientation:

```text
ZODIAC-ORIENTED
Aries at 9 o'clock
```

Later local orientation:

```text
ASC-ORIENTED
requires lawful Terra + native/live geolocation + Horizon/local-frame truth
```

Zodiac-oriented and ASC-oriented views must rotate/reorient the same celestial state rather than regenerate it.

## Terra grammar

Terra is part of every Horae temporal state and must remain attached throughout Iris expression even when not yet prominently rendered.

```text
Horae state
= celestial + Terra
```

Current Terra alone must not be used to synthesize Ascendant.

Future lawful local chain:

```text
Terra universal orientation
+
native/live geolocation
-> local terrestrial frame
-> Horizon
-> Asc / MC
-> ASC-oriented Astrolabe
```

Iris may display lawful terrestrial/local outputs but must not invent them.

## Planet-as-hand grammar

This is a core interaction law.

> **Planetary scrubbing is temporal, not positional. A selected body acts as the visible hand of time. User gesture controls UT monotonically; the body's apparent direction is determined solely by its lawful tract. Retrograde may reverse the body without reversing the user's gesture.**

Therefore:

```text
finger motion -> temporal scrub progress
             -> Horae UT movement
             -> OrboSpine body state at that UT
             -> Iris display
```

Retrograde example:

```text
finger   -> -> -> -> ->
UT       -> -> -> -> ->
Mercury  -> -> station <- <-
```

The user never has to reverse the gesture merely because the selected body retrogrades.

## Focus grammar

During planet-as-hand scrubbing:

```text
selected body -> emphasized
other bodies  -> visually faded
```

The faded bodies remain lawfully resolved at every UT. Iris changes attention, not truth.

When the temporal selection settles, the full Horae cross-section returns to normal emphasis.

## Motion grammar

Retrograde is not a separate visual coordinate invented by Iris.

It remains encoded in the canonical directional state and becomes visible through real tract geometry:

```text
UT continues monotonically through Z
body angular motion may reverse
```

A station is therefore a real topological turn in the body's displayed temporal path.

## View grammar

The principal expression axes are orthogonal:

```text
BODY SIZE
    equal <-> planet-sized

TRACK RADIUS
    unified <-> concentric

TIME DEPTH
    flat <-> expanded

CAMERA
    top <-> oblique/free

PROJECTION
    orthographic <-> perspective

ORIENTATION
    zodiac-oriented <-> later ASC-oriented

FOCUS
    all bodies <-> selected temporal hand
```

No one axis should silently force another unless explicitly designed later.

This allows combinations such as:

```text
equal + unified + flat
planet-sized + unified + expanded
equal + concentric + flat
planet-sized + concentric + expanded
```

## Transversal reserve

Spatial Expression v1 must leave body-track geometry capable of later selective exaggeration into a body-specific temporal path anchored to the Horae plane.

The intended later Iris Transversal view is a spiral-staircase expression of one selected body's tract through time.

Exact repeated occurrences of a chosen body/state become nodes or landings along that temporal path.

The scrub remains temporal, not spatially attached to the body's longitude.

Future haptic law:

```text
ordinary tract position -> no haptic
exact occurrence node   -> haptic tick
selected occurrence     -> stronger selection feedback
```

The transversal view is explicitly deferred from Spatial Expression v1.

## Negative grammar

Spatial Expression v1 must not imply:

```text
visual body size = literal astronomical size
track radius = heliocentric distance
concentric lane = new celestial coordinate
sign color = celestial truth field
flat Z = changed UT
faded body = absent/unresolved body
planet scrub direction = planetary motion direction
Terra alone = local Horizon
Astrolabe face = independently regenerated chart
```

## Compact expression law

```text
WHAT    body identity
WHERE   longitude / sign
WHEN    UT
EARTH   Terra

FORM    sphere / point
SIZE    equal or planet-sized
RADIUS  unified or concentric
COLOR   sign / element
HEIGHT  temporal depth
PLANE   current Horae cross-section
VIEW    Iris camera + projection
```

All expression flows from lawful Orbo/Horae matter and remains reversible at the presentation layer.
