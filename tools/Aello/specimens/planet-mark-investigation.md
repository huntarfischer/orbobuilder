# Aello Investigation: Planet Mark

Status: TURN 2 / INVESTIGATION

Salvage judgments: NOT YET MADE

## Specimen boundary

This investigation concerns the **front Astrolabe body mark** only: the visible and touchable manifestation of a lawful celestial body on the instrument.

It does not include the Tabula planet chips, Lunar Pane readings, aspect calculation, ephemeris calculation, Orbo sphere, camera/stage, or whole Astrolabe geometry.

## Source set

1. `Orbo Astrolabe.dc.html` is the executable prototype and primary behavioral evidence.
2. `Astrolabe Model - Design Map.md` records the intended instrument grammar and body-as-hand semantics.
3. `03_PlanetNode.md` supplies supporting prototype data-shape provenance only.

## Observed anatomy

### 1. Lawful angular placement

A body's source longitude supplies its angular position. The prototype transforms that longitude through the current presentation frame to obtain screen coordinates. The body glyph itself is not rotated with the wheel.

Observed relationship:

```text
lawful longitude
    ↓
presentation-frame transform
    ↓
mark position
```

The mark does not calculate celestial longitude.

### 2. Collision rails

Bodies separated by roughly 4.5° or more return to the main radial track. Tighter bodies are stepped inward onto additional radial rails. With a larger active set, a second inner rail is available.

Deeper collision marks are drawn first and are slightly smaller, dimmer, and less luminous than the outer mark. This preserves angular truth while giving overlapping bodies separate visible seats.

The numeric threshold and offsets are prototype implementation values, not yet salvage judgments.

### 3. Body identity and glyph

The visible mark carries the body's conventional astronomical/astrological glyph. The prototype maintains an explicit body-to-glyph vocabulary for the ten principal bodies and additional objects.

The front mark has no persistent body-name label. Name, degree, condition, and interpretation are handled elsewhere. The mark itself remains compact.

### 4. Symbolic size hierarchy

The prototype does not use literal astronomical size. Glyph size is compressed from the body's orbital period, so faster temporal hands tend to appear slightly larger and slower hands slightly smaller. Collision-depth can reduce size further.

This agrees with the Design Map's broader body-as-clock-hand grammar: fast body means finer temporal resolution, slow body means coarser temporal resolution.

The exact logarithmic period-to-size curve is source-specific implementation, not a visual-law decision.

### 5. Bead material

A normal body is not a naked glyph. It is a compound mark:

```text
dark violet circular bead
+ luminous accent outline
+ local glow
+ centered upright glyph
```

The bead gives the body a physical seat on the instrument and separates the glyph from the surrounding engraving and aspect web.

### 6. Resting color

When the instrument is at rest, the mark's accent is derived from the body's current elemental/sign relationship rather than from a permanent body brand color.

The prototype therefore allows lawful position to affect presentation color without changing the body's identity.

### 7. Held focus

The held body changes state visibly:

- accent becomes gilt/gold
- a larger gold halo appears behind the bead
- the held body becomes the temporal hand
- non-held bodies wash toward a pale neutral while the instrument is active

Selection is therefore not merely a border toggle. It establishes a visual hierarchy between the hand currently driving temporal navigation and the rest of the lawful sky.

### 8. Moon variant

The Moon is a special Planet Mark variant. Instead of the normal dark bead interior, the prototype draws a phase disc from the relevant lunar phase and then places the Moon glyph above it.

For a natal Moon, the phase is taken from the natal moment rather than from the current clock moment. The mark still occupies the same body-mark role.

No equivalent special surface treatment was observed for the Sun in the front mark path.

### 9. Upright readability

The mark's position follows the rotating celestial frame, but the glyph remains screen-upright. The prototype solves instrument rotation and label readability separately.

### 10. Touch footprint

The visible bead is much smaller than its interaction target. Hit testing searches approximately a 30-point neighborhood around stored body screen coordinates while the visible bead radius is roughly 11 points before appearance scaling.

The prototype therefore treats **visible footprint** and **touch footprint** as separate things.

### 11. Exact-event pulse

After an exact snap/event associated with the held body, the prototype emits a short expanding pale ring around that body's mark. The source duration is about 600 ms.

The pulse is presentation feedback attached to an already-established event. The mark does not decide whether an event is exact.

### 12. Retrograde relationship

No static retrograde badge was observed in the front Planet Mark draw path. Retrograde belongs to lawful body state and is experienced through the body's real movement, temporal navigation, and supporting readouts rather than by moving the mark independently of truth.

### 13. Aspect-thread relationship

The Design Map states that while a body is held and scrubbed, its live aspect threads remain tied to that body and visually radiate from the user's held point. The Planet Mark is therefore the visible anchor of this interaction, but aspect determination itself is outside the specimen.

### 14. Body as temporal hand

The strongest behavioral finding is that the mark is not decorative celestial notation. A body can be promoted into the instrument's temporal hand.

The Design Map describes one full rim sweep as one full orbit of the held body, with faster bodies giving finer time and slower bodies giving coarser time. The executable prototype's `held` state, orbital-period table, focus treatment, snapping, and pulse all support that same meaning.

## Dependencies observed

The front Planet Mark depends on lawful or already-resolved inputs for:

- body identity
- body longitude
- current presentation frame/orientation
- current sign or elemental presentation relationship
- held/focus state
- body period as the prototype's current symbolic-size source
- lunar phase when the body is the Moon
- exact-event/snap notification for the pulse

It does **not** require the mark itself to calculate ephemerides, aspects, time, houses, or interpretations.

## Explicitly outside this specimen

- ephemeris and celestial-state calculation
- aspect detection or orb logic
- Horae/time solving
- Lunar Pane content or readings
- Tabula planet/object chips
- whole Astrolabe rings and engraving
- Orbo sphere
- camera or stage behavior
- browser rendering mechanisms

## Investigation result

The prototype Planet Mark is a compound visible and interactive constituent:

```text
lawful body identity + lawful longitude
        ↓
screen position
        ↓
collision-aware radial seat
        ↓
dark luminous bead
+ upright body glyph
+ symbolic temporal-hand scale
+ positional/elemental resting accent
+ held gold focus and halo
+ pale de-emphasis of peers
+ larger invisible touch field
+ exact-event pulse
+ Moon phase-disc variation
```

The source code, Design Map, and current Orbo destination law are sufficiently aligned to proceed to salvage judgment without authorial clarification.

Turn 3 will decide what is PRESERVE, TRANSLATE, REFERENCE, or DISCARD. This document makes none of those judgments.