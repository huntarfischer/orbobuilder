# Planet Mark

**Status:** ENCOUNTERED · NOT INVESTIGATED  
**Aello MVP specimen:** 1

## Boundary

Aello will investigate only the visible presentation of one planetary body:

- body glyph / visible body form
- relative visual size
- body identity treatment
- color relationship
- glow relationship
- label relationship
- orientation
- anchor / placement behavior
- selection treatment
- intrinsic motion, if any

## Excluded neighbors

Proximity does not imply ownership. These are outside this specimen unless a direct dependency must be recorded:

- zodiac ring
- aspect web
- whole camera or stage
- whole planet layer
- astrology or ephemeris calculation
- Lunar Pane reading content
- unrelated surrounding UI

## Canonical source map

### Primary executable source

`/Orbo Astrolabe.dc.html`

Encounter anchors already visible in the source:

- `this.BODIES`
- `this.GLYPH`
- `this.LABEL`
- `this.held`
- `_togglePlanet(...)`

The exact front-side Planet Mark construction, styling, gesture, and update paths are **Turn 2 investigation work**. They are not inferred here.

### Design / authorial record

`/Astrolabe Model - Design Map.md`

Relevant encounter regions include:

- **The Bodies** in the canonical lexicon
- **The gearbox — bodies as the hands of the clock**
- **The touch grammar — zone × gesture**, especially the Planet ring
- the persistent-instrument / truthful-position laws surrounding those sections

This document is evidence of intent, not executable truth.

### Supporting prototype data shape

`/03_PlanetNode.md`

This records the prototype's `PlanetNode` data shape. It is supporting provenance only. Turn 2 will determine whether any field matters to the visual constituent.

## Nearby files not admitted into the specimen

`/orbo-sphere.js` and `/three-d-stage.js` exist in the same prototype repository, but Turn 1 has found no reason to treat either as Planet Mark source. Aello will add them only if Turn 2 evidence establishes a direct dependency.

## Questions

None yet. Aello has not investigated deeply enough to ask.

## Salvage

Not begun. Turn 1 makes no salvage judgments.
