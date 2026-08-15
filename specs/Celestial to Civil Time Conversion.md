# Celestial to Civil Time Conversion

Status: architectural law / planning note.

This document records a foundational Orbo rule:

> **Solve in celestial coordinates first. Convert to civil time second.**

Orbo is a celestial-time instrument. Civil time is a human-readable coordinate system used to locate a celestial condition after the condition itself has been solved.

The wrong default is:

```text
8:00? calculate the sky
8:05? calculate the sky
8:10? calculate the sky
8:15? calculate the sky
...
```

The preferred Orbo direction is:

```text
What celestial relationship is wanted?
        ↓
What degree or degree range satisfies it?
        ↓
Is that degree reachable in this field?
        ↓
What horizon / sky coordinate produces it?
        ↓
When does that coordinate occur locally?
        ↓
Civil clock time
```

The calendar is therefore the final translation layer, not the computational starting point.

---

## 1. The distinction

### Celestial state

A complete configuration of the field at an instant.

Examples:

- natal state
- current sky state
- event state
- election state
- mundane state

AstroDNA is the canonical identity of a celestial state at its required precision.

### Celestial relation

A geometric or regulatory relationship within or between states.

Examples:

- Mars square Saturn
- Venus disposed by Mars
- synchronic Ascendant trine synchronic Venus
- ruler of the rising sign

The Ring, Mater, Tympan, Rulers, Dispositor, and Connectome provide the structural facts needed to answer these questions.

### Celestial range

A finite interval of celestial coordinates over which a selected condition is true.

Examples:

- a planet occupying one sign
- a planet remaining in one bound
- an aspect remaining within orb
- one synchronic placement occupying a permitted stretch
- a rising lord remaining unchanged

A range is the natural unit for electional work because most useful conditions are true for an interval, not for one isolated instant.

### Civil time

The local human-readable date and clock time at which a solved celestial coordinate or range occurs.

Civil time is an output conversion.

---

## 2. Synchronic refraction is a fixed function

Orbo has one refraction door:

```text
S = refract(N, H)
```

where:

- `N` is the natal longitude
- `H` is the corresponding moment / horizon longitude
- `S` is the synchronic longitude

For the synchronic Ascendant:

```text
sASC = midpoint(natalASC, horizonASC)
```

The same pair of celestial coordinates always produces the same synchronic coordinate.

Example:

```text
natal ASC      = 11 Scorpio = 221 degrees
horizon ASC    = 11 Capricorn = 281 degrees

sASC           = midpoint(221, 281)
               = 251 degrees
               = 11 Sagittarius
```

Every time the horizon reaches 11 Capricorn for a native with an Ascendant at 11 Scorpio, the synchronic Ascendant is 11 Sagittarius.

No historical state is required. No previous sample is required. No detector is required.

The relationship is finite, deterministic, and invertible within the correct pole / permitted range.

---

## 3. Inverse refraction

If:

```text
S = midpoint(N, H)
```

then the corresponding moment coordinate can be recovered from the synchronic coordinate:

```text
H = 2S - N
```

normalized to the circle and resolved through the valid pole / permitted range.

This is the important computational direction for Orbo.

A reader can begin with a desired synchronic degree and recover the horizon degree that produces it.

The user does not need to begin with a clock time.

---

## 4. The permitted synchronic range is the primary object

A synchronic placement does not wander arbitrarily through 360 degrees.

For a fixed natal placement, its synchronic placement is confined to its permitted 180-degree range.

The range is primary.

A flip is only one boundary event inside that finite system.

Orbo should therefore prefer questions such as:

```text
Which degrees can this placement ever occupy?
Which signs can it ever occupy?
Which houses can it ever occupy?
Which rulers can govern those stretches?
Which aspect ranges are reachable?
```

rather than organizing the model around the flip itself.

Prism already records much of this permanent structure as reachable signs, houses, lords, segments, and boundaries.

The future SynchronicSpine should cache the time-varying refracted states when first requested by a Pisces function. It must not be built merely because a natal chart was engraved.

The intended trigger is lazy first use, analogous to Zodiacal Releasing:

```text
user enables a Pisces function requiring synchronic chronology
        ↓
SynchronicSpine is minted / resumed
        ↓
subsequent Pisces readers reference the cached spine
```

---

## 5. Aspect solving should begin in celestial space

Example question:

> When is the synchronic Ascendant trine synchronic Venus?

Do not begin by sampling clock times.

Begin with the relationship.

### Step 1: read synchronic Venus

At the relevant state or spine interval, obtain the synchronic Venus longitude.

Example:

```text
sVenus = 14 Aries
```

### Step 2: ask the Ring for the trine targets

The exact trines are:

```text
14 Leo
14 Sagittarius
```

If an orb is allowed, these become degree ranges around those exact targets.

### Step 3: intersect with the sASC permitted range

Ask Prism / Connectome which of those target ranges the native's synchronic Ascendant can actually reach.

Impossible targets are rejected before any civil-time work occurs.

### Step 4: invert the reachable synchronic range

For each reachable `sASC` degree or degree range:

```text
horizon = 2 * sASC - natalASC
```

resolved through the valid pole.

This yields the horizon degree range that produces the desired synchronic relationship.

### Step 5: convert the horizon range into local time

The Prism ascension machinery already establishes the relevant pattern:

```text
horizon degree
    ↓
risingRamc(...)
    ↓
RAMC target
    ↓
ramcJdNear(...)
    ↓
Julian Day
    ↓
local civil date / clock time
```

For a range, solve both boundaries and preserve the interval.

The result is naturally a human time window.

---

## 6. Celestial window to civil window

The general conversion is:

```text
CELESTIAL PREDICATE
        ↓
TARGET DEGREE / RANGE
        ↓
REACHABILITY INTERSECTION
        ↓
INVERSE CELESTIAL MAPPING
        ↓
LOCAL ROTATION / EPHEMERIS SOLVE
        ↓
CIVIL TIME WINDOW
```

The civil result should retain provenance describing which celestial boundaries opened and closed it.

Example shape:

```text
windowStart
windowEnd

openedBy:
  sASC entered trine orb of sVenus

closedBy:
  sASC left trine orb of sVenus

celestialRange:
  ...
```

Civil time must never become the source of truth for the condition.

---

## 7. Electional consequence

This rule changes the preferred architecture of electional work.

A sampled electional engine asks:

```text
How good is 8:00?
How good is 8:30?
How good is 9:00?
...
```

A celestial-time electional engine asks:

```text
Which celestial conditions does this doctrine require?
        ↓
Where are those conditions true?
        ↓
Where do their ranges overlap?
        ↓
Which boundaries change the answer?
        ↓
Convert the surviving celestial intervals to civil time
```

This makes an ElectionalSpine a doctrine-sensitive segmentation of celestial time rather than a collection of arbitrary samples.

Possible boundaries include:

- Ascendant sign changes
- rising-lord changes
- dispositor changes
- keeper changes
- sign ingresses
- house changes
- bound changes
- face changes
- stations
- combustion / under-beams thresholds
- aspect-orb entry and exit
- exact aspect perfection
- Moon sign / house changes
- void-of-course boundaries
- next-application changes
- any astrologer-specific rule admitted by the active electional doctrine

Different astrologers may prioritize different boundaries and conditions while consuming the same underlying celestial facts.

---

## 8. Example: recurring correspondence windows

Suppose an electional doctrine for correspondence prioritizes:

- Mercury
- the current rising lord
- the condition of both
- their dispositors / keepers
- the Moon's carrying condition

Orbo should not score every five minutes of a year.

Instead it can build spans such as:

```text
08:03 rising sign changes to Gemini
      actor becomes Mercury

08:03-10:11
      actor = Mercury
      Mercury sign = Virgo
      bearer = Mercury
      keeper = Mercury
      motion = direct
      combustion state = free

09:14 Moon enters an adverse relation
09:47 Mercury crosses a bound
10:02 Moon condition changes
10:11 rising sign changes to Cancer
```

The exact doctrine determines which boundaries split the electional interval and which facts improve, weaken, or veto it.

The result can answer:

```text
better window
weaker window
avoid window
```

for every day in a long planning horizon while respecting actual celestial boundaries rather than an arbitrary sampling cadence.

---

## 9. Responsibility by system

### AstroDNA

Owns celestial-state identity and precise positional expression.

It is not an electional judgment engine.

### Ring

Owns geometric relations and target angles.

It answers where a relation exists, not whether that relation is desirable.

### Connectome

Should function as Orbo's comprehensive connection map: the retrievable network of a state or field's useful expressions and relationships at their proper resolutions.

The existing sign-stay Expression remains valuable, but it is one resolution of that broader nervous system.

### TimeSpine

Indexes the changing celestial field through time.

### SynchronicSpine

Indexes the refracted field produced by the engraved natal state and celestial time.

It is lazy-built on first use by a Pisces function that requires it and cached thereafter.

### Prism

Owns the fixed refraction law and permanent reachable synchronic structure.

### Electional doctrine

Declares which celestial facts matter, how they are prioritized, and which conditions veto or qualify a window.

### ElectionalSpine

Intersects the relevant celestial conditions into stable intervals and converts the resulting celestial ranges into usable civil windows.

---

## 10. The anti-pattern

Do not make civil time the search grid unless no analytic or boundary-based celestial solution exists.

Avoid:

```text
for each five-minute interval:
    generate state
    rebuild relationships
    rescore election
```

Prefer:

```text
solve boundaries
build stable celestial intervals
join cached expressions
apply doctrine
intersect acceptable ranges
convert only the resulting ranges to civil time
```

Sampling remains a fallback for genuinely continuous problems that cannot yet be inverted or boundary-solved. It is not Orbo's default concept of time.

---

## 11. Foundational law

Orbo is oriented around celestial time.

The Big Three and AstroDNA express a moment in celestial terms. The astrolabe allows the user to manipulate celestial time directly by grabbing its bodies. Synchronic refraction creates another finite celestial coordinate system from that time. Electional work asks which regions of those coordinate systems satisfy a doctrine.

Therefore:

> **Orbo should solve the sky in the sky's own coordinates whenever possible. Human clock time is the translation delivered at the end.**

Or more compactly:

```text
CELESTIAL TRUTH FIRST
CIVIL ADDRESS SECOND
```
