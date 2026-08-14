# Orbo Onboarding

## Part One — Introduction

**ORBO**

Welcome, traveler.  
My name is Orbo. What's yours?

> **Traveler:** [enters name]

**ORBO**

Heya, Traveler. It's nice to meet you.

*[screen]*

I am your guide to the astrosphere-the cosmic dimension on top of your own.

*[screen]*

How interested are you in astrology?

> **Traveler selects interest level. This sets L1-L2-L3.**
>
> - **L1 — NOT VERY:** it's gonna be a rough week
> - **L2 — INTERESTED:** Mercury is affecting your house of self
> - **L3 — VERY INTERESTED:** MERCURY CONJUNCT Your Natal Saturn

**ORBO**

Everyone has their place in the astrosphere. Let's find yours.

---

## Part Two — Birth Chart

**ORBO**

*[screen]*

What day were you born?

> **Traveler:** [enters birthday]

**ORBO**

Where were you Born?

> **Traveler:** [enters birthplace]

**ORBO**

DO you know what time you were born?

> **Traveler**
>
> - Yes I know when I was born.
> - No, I don't know when I was born.

### Routing

```text
IF exact birth time is known:
    derive Natal Ascendant
    go to Part Four

ELSE:
    go to Part Three — Rectification
```

---

## Part Three — Rectification

### Time Prior

**ORBO**

Do you know what time of day?

> **Traveler**
>
> - Morning
> - Afternoon
> - Evening/Night
> - I don't know

The selected answer constrains the viable birth-time intervals before structural rectification begins.

---

### Ascendant Lock

The Ascendant Lock is produced by two structural tumblers:

```text
LUNAR TUMBLER
        +
RULER / HOUSE TUMBLER
        ↓
ASCENDANT LOCK
        ↓
30° rising-sign window
```

#### Lunar Lock

**Runtime bank:** `orbo_lunar_lock_v2`

```text
1. Calculate the Moon's whole-sign house for every viable Ascendant candidate.
2. Collect the unique Moon houses represented by those candidates.
3. Pull the answer statement for each viable Moon house under Lunar Question A.
4. Present those house-derived answers as the choices, up to four at a time.
5. The selected answer returns a concrete Moon house.
6. Use Lunar Question B as confirmation when needed.
7. Preserve agreement or a split result as the Lunar tumbler.
```

> **ORBO:** [assemble Lunar Question A from `orbo_lunar_lock_v2`]  
> **Traveler:** [selects one viable house-derived answer]

> **ORBO:** [ask Lunar Question B when confirmation is needed]  
> **Traveler:** [selects one viable house-derived answer]

#### Ruler / House Lock

**Structural lookup:** `ORBO_WHOLE_SIGN_FRAMES`  
**Runtime bank:** `orbo_ruler_house_lock_v2`

The embedded Whole-Sign Frames determine the structural state for every viable rising-sign candidate.

```text
1. Normalize the candidate Ascendant longitude.

2. Select the corresponding Whole-Sign Frame.

3. Determine the candidate rising sign's PRIMARY traditional ruler.

4. Read that ruler's actual zodiac sign at the candidate time.

5. Use the Frame to convert the ruler's sign into its candidate whole-sign house.

6. Construct the lookup key:

       rising sign + primary ruler + ruler house

   Example:
       Virgo rising
       Mercury in Aries
       Aries = Virgo's 8th whole-sign house
       ↓
       VIRGO_RISING / MERCURY_8H

7. Pull the pre-authored question for that structural key from `orbo_ruler_house_lock_v2`.

8. Ask only questions belonging to currently viable Ascendant candidates.

9. A strong confirmation returns that exact rising-sign/ruler-house candidate as the Ruler tumbler. A partial answer retains it; a rejection weakens it; unsure leaves it unresolved.
```

Traditional domicile rulers are used as the primary rulers for this lock. Scorpio, Aquarius, and Pisces may retain Pluto, Uranus, and Neptune as secondary metadata, but those modern associations do not replace Mars, Saturn, and Jupiter in the canonical ruler lookup.

> **ORBO:** [pull the candidate-specific Ruler / House question from `orbo_ruler_house_lock_v2`]  
> **Traveler:** [answers]

#### Ascendant Lock Resolution

```text
resolved Moon house
        +
ruler/house-selected Ascendant candidate
        +
computed Moon house for that Ascendant candidate
        ↓

IF the structures agree:
    ASCENDANT LOCK
    preserve 30° rising-sign window

ELSE:
    retain unresolved candidates
    continue the applicable confirmation logic
```

---

### Decan Lock

**Runtime bank:** `orbo_decan_lock_v1`

The Ascendant sign is known. Orbo now determines which third of its 30° span contains `rAsc`.

```text
ASCENDANT LOCK
        ↓
30° sign

DECAN Q1
        ↓
returns Decan 1 / 2 / 3 / unresolved

DECAN Q2
        ↓
returns Decan 1 / 2 / 3 / unresolved

IF Q1 == Q2 and both are non-null:
    DECAN LOCK
```

Degree windows:

```text
Decan 1 → 0°00′00″–9°59′59″
Decan 2 → 10°00′00″–19°59′59″
Decan 3 → 20°00′00″–29°59′59″
```

> **ORBO:** [pull Decan Q1 from the embedded Decan Lock bank]  
> **Traveler:** [answers]

> **ORBO:** [pull Decan Q2 from the embedded Decan Lock bank]  
> **Traveler:** [answers]

Result:

```text
DECAN LOCK
    ↓
10° rAsc window
```

---

### Sabian Lock

**Runtime bank:** `orbo_sabian_lock_v1`

The rising sign and decan are known. Orbo now resolves the Ascendant to a one-degree interval.

Sabian convention:

```text
0°00′–0°59′ zodiac position → Sabian 1
10°00′–10°59′              → Sabian 11
29°00′–29°59′              → Sabian 30
```

Each degree record contains three pre-authored answer forms:

```text
default
integrated
stress
```

Orbo compares neighboring Sabian candidates in groups of two or three.

#### Degree Comparison

> **ORBO:** [pull the appropriate `default` comparison from the embedded Sabian Lock bank]  
> **Traveler:** [answers]

#### Confirmation

If the traveler selects a candidate degree:

> **ORBO:** [pull the confirmation comparison using `integrated` or `stress`]  
> **Traveler:** [answers]

Resolution:

```text
same Sabian degree selected twice
        ↓
SABIAN LOCK
        ↓
1° rAsc interval
```

If the comparison splits between two degrees:

```text
retain the two degrees
        ↓
ask final two-way comparison
        ↓
lock only if resolved
```

If all candidate groups return unresolved:

```text
DO NOT assign a Sabian degree by elimination
        ↓
preserve the locked 10° decan window
```

---

### rAsc Derived

```text
TIME PRIOR
    ↓
ASCENDANT LOCK
    ↓
DECAN LOCK
    ↓
SABIAN LOCK
    ↓
rAsc
```

---

## Part Four — The Big Three

**ORBO**

The moment you were born is as unique to you as your DNA.

*[screen]*

When you were born, SIGN was on the horizon.

*[screen]*

When you were born, the Moon was in SIGN.

*[screen]*

When you were born, the Sun was in SIGN.

**ORBO**

Your Sun, Moon and rising are known as your Big Three.

*[screen]*

The Big Three focus on how you show up in the world. And how the astrosphere shows up for you.

*[screen]*

Would you like a tour?

> **Traveler**
>
> - No thanks.
> - Yes please.

**ORBO**

The astrosphere awaits!

---

# Runtime Question-Bank Registry

This master file is self-contained for the current rectification flow. It embeds the structural Frames plus all four runtime question banks.

```json
{
  "structuralTables": {
    "wholeSignFrames": {
      "id": "ORBO_WHOLE_SIGN_FRAMES",
      "marker": "ORBO_WHOLE_SIGN_FRAMES"
    }
  },
  "questionBanks": {
    "lunarLock": {
      "id": "orbo_lunar_lock_v2",
      "marker": "ORBO_LUNAR_LOCK_BANK"
    },
    "rulerHouseLock": {
      "id": "orbo_ruler_house_lock_v2",
      "marker": "ORBO_RULER_HOUSE_LOCK_BANK"
    },
    "decanLock": {
      "id": "orbo_decan_lock_v1",
      "marker": "ORBO_DECAN_LOCK_BANK"
    },
    "sabianLock": {
      "id": "orbo_sabian_lock_v1",
      "marker": "ORBO_SABIAN_LOCK_BANK"
    }
  },
  "rectificationOrder": [
    "time_prior",
    "lunar_lock",
    "ruler_house_lock",
    "ascendant_lock",
    "decan_lock",
    "sabian_lock",
    "rAsc"
  ]
}
```

A parser can extract any bank or structural table by locating its `BEGIN` and `END` comments below.

## Audit manifest

| Component | Expected | Verified |
|---|---:|---:|
| Whole-Sign Frames | 12 rising-sign frames | 12 |
| Lunar Lock | 12 Moon houses × 2 answer forms | 24 answer forms |
| Ruler / House Lock | 12 rising signs × 12 ruler houses | 144 questions |
| Decan Lock | 12 signs × 2 questions | 24 questions |
| Sabian degree records | 12 signs × 30 symbols | 360 records |
| Sabian comparison groups | 12 signs × 3 decans × 4 groups | 144 groups |

### Current architectural rules

- No life-event or angular-timing stage is required in onboarding rectification.
- The Moon is tested by **candidate whole-sign house**, not by a generic Moon-sign personality quiz.
- The Lunar and Ruler/House tumblers together resolve the rising sign.
- Traditional domicile rulers are canonical for the Ruler/House lock; modern rulers remain secondary metadata in the Frames.
- Decans reduce the 30° sign to a 10° window.
- Sabian comparison reduces the locked decan toward a 1° `rAsc` interval.
- A failed or unresolved fine-tuning stage preserves the narrower valid window rather than inventing a degree.

---

<!-- BEGIN: ORBO_WHOLE_SIGN_FRAMES -->

# Embedded Structural Table — Whole-Sign Frames

## Orbo Whole-Sign Frames: Traditional and Modern Rulers

This is a stamped lookup table that exists beside **The Ring**.

- **The Ring:** degree-to-degree geometry and aspects.
- **The Frames:** Ascendant range to whole-sign houses, primary rulers, secondary modern rulers, and zodiac degree bounds.

Traditional domicile rulers remain the **primary rulers** used for dispositorship and classical house governance.
Modern rulers are stored as **secondary rulers**:

- Scorpio: Mars primary, Pluto secondary
- Aquarius: Saturn primary, Uranus secondary
- Pisces: Jupiter primary, Neptune secondary

## Frame-selection formula

```text
normalizedAsc = ((ascLongitude % 360) + 360) % 360
risingSignIndex = floor(normalizedAsc / 30)
houseSignIndex = (risingSignIndex + houseNumber - 1) % 12
houseSign = SIGNS[houseSignIndex]
primaryRuler = PRIMARY_RULER[houseSign]
secondaryRuler = SECONDARY_RULER[houseSign] ?? null
houseStart = houseSignIndex * 30
houseEndExclusive = houseStart + 30
```

All degree bounds are **start-inclusive and end-exclusive**. Aries is `[0,30)`, preserving full decimal precision.

## Stamped frames

| Ascendant Range | Rising Sign | H1 | H2 | H3 | H4 | H5 | H6 | H7 | H8 | H9 | H10 | H11 | H12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `[0,30)` | Aries | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` |
| `[30,60)` | Taurus | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` |
| `[60,90)` | Gemini | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` |
| `[90,120)` | Cancer | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` |
| `[120,150)` | Leo | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` |
| `[150,180)` | Virgo | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` |
| `[180,210)` | Libra | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` |
| `[210,240)` | Scorpio | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` |
| `[240,270)` | Sagittarius | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` |
| `[270,300)` | Capricorn | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` |
| `[300,330)` | Aquarius | Aquarius · Saturn / Uranus · `[300,330)` | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` |
| `[330,360)` | Pisces | Pisces · Jupiter / Neptune · `[330,360)` | Aries · Mars · `[0,30)` | Taurus · Venus · `[30,60)` | Gemini · Mercury · `[60,90)` | Cancer · Moon · `[90,120)` | Leo · Sun · `[120,150)` | Virgo · Mercury · `[150,180)` | Libra · Venus · `[180,210)` | Scorpio · Mars / Pluto · `[210,240)` | Sagittarius · Jupiter · `[240,270)` | Capricorn · Saturn · `[270,300)` | Aquarius · Saturn / Uranus · `[300,330)` |

## Sign and ruler constants

| Sign Index | Sign | Zodiac Bounds | Primary Ruler | Secondary Ruler |
|---:|---|---|---|---|
| 0 | Aries | `[0,30)` | Mars | — |
| 1 | Taurus | `[30,60)` | Venus | — |
| 2 | Gemini | `[60,90)` | Mercury | — |
| 3 | Cancer | `[90,120)` | Moon | — |
| 4 | Leo | `[120,150)` | Sun | — |
| 5 | Virgo | `[150,180)` | Mercury | — |
| 6 | Libra | `[180,210)` | Venus | — |
| 7 | Scorpio | `[210,240)` | Mars | Pluto |
| 8 | Sagittarius | `[240,270)` | Jupiter | — |
| 9 | Capricorn | `[270,300)` | Saturn | — |
| 10 | Aquarius | `[300,330)` | Saturn | Uranus |
| 11 | Pisces | `[330,360)` | Jupiter | Neptune |

## Primary house-rulership reverse index

This remains the canonical index for traditional dispositorship and classical house rulership.

| Rising Sign | Mars | Venus | Mercury | Moon | Sun | Jupiter | Saturn |
|---|---|---|---|---|---|---|---|
| Aries | 1, 8 | 2, 7 | 3, 6 | 4 | 5 | 9, 12 | 10, 11 |
| Taurus | 7, 12 | 1, 6 | 2, 5 | 3 | 4 | 8, 11 | 9, 10 |
| Gemini | 6, 11 | 5, 12 | 1, 4 | 2 | 3 | 7, 10 | 8, 9 |
| Cancer | 5, 10 | 4, 11 | 3, 12 | 1 | 2 | 6, 9 | 7, 8 |
| Leo | 4, 9 | 3, 10 | 2, 11 | 12 | 1 | 5, 8 | 6, 7 |
| Virgo | 3, 8 | 2, 9 | 1, 10 | 11 | 12 | 4, 7 | 5, 6 |
| Libra | 2, 7 | 1, 8 | 9, 12 | 10 | 11 | 3, 6 | 4, 5 |
| Scorpio | 1, 6 | 7, 12 | 8, 11 | 9 | 10 | 2, 5 | 3, 4 |
| Sagittarius | 5, 12 | 6, 11 | 7, 10 | 8 | 9 | 1, 4 | 2, 3 |
| Capricorn | 4, 11 | 5, 10 | 6, 9 | 7 | 8 | 3, 12 | 1, 2 |
| Aquarius | 3, 10 | 4, 9 | 5, 8 | 6 | 7 | 2, 11 | 1, 12 |
| Pisces | 2, 9 | 3, 8 | 4, 7 | 5 | 6 | 1, 10 | 11, 12 |

## Secondary modern house-rulership index

These are secondary associations only. They do not replace the traditional primary ruler.

| Rising Sign | Pluto Secondarily Rules | Uranus Secondarily Rules | Neptune Secondarily Rules |
|---|---|---|---|
| Aries | 8 | 11 | 12 |
| Taurus | 7 | 10 | 11 |
| Gemini | 6 | 9 | 10 |
| Cancer | 5 | 8 | 9 |
| Leo | 4 | 7 | 8 |
| Virgo | 3 | 6 | 7 |
| Libra | 2 | 5 | 6 |
| Scorpio | 1 | 4 | 5 |
| Sagittarius | 12 | 3 | 4 |
| Capricorn | 11 | 2 | 3 |
| Aquarius | 10 | 1 | 2 |
| Pisces | 9 | 12 | 1 |

## Minimal lookup shape

```ts
interface WholeSignFrame {
  risingSignIndex: number;
  ascendantBounds: readonly [startInclusive: number, endExclusive: number];
  houses: readonly HouseFrame[];
  housesRuledByPrimary: Readonly<Record<TraditionalPlanet, readonly number[]>>;
  housesRuledBySecondary: Readonly<Partial<Record<ModernPlanet, readonly number[]>>>;
}

interface HouseFrame {
  house: number;
  signIndex: number;
  sign: ZodiacSign;
  primaryRuler: TraditionalPlanet;
  secondaryRuler: ModernPlanet | null;
  zodiacBounds: readonly [startInclusive: number, endExclusive: number];
}

type ModernPlanet = "Uranus" | "Neptune" | "Pluto";
```

<!-- END: ORBO_WHOLE_SIGN_FRAMES -->

---

<!-- BEGIN: ORBO_LUNAR_LOCK_BANK -->

# Embedded Question Bank A — Lunar Lock v2

## Orbo Lunar Lock — Coded Tumbler Bank v2

This version implements the current Orbo architecture: the question is shared, viable Moon houses become the answer choices, and every answer returns a structural `moonHouse`.

```json
{
  "id": "orbo_lunar_lock_v2",
  "version": "2.0.0",
  "purpose": "Resolve the Moon whole-sign house as a structural tumbler by comparing only Moon houses produced by viable Ascendant candidates.",
  "prompts": {
    "emotionalGravity": "Where does life tend to become most personally or emotionally consequential for you?",
    "emotionalRegulation": "When you feel unsettled, what most often helps you regain a sense of emotional footing?"
  },
  "runtime": {
    "candidateGeneration": "For every viable time/Ascendant candidate, compute the Moon whole-sign house.",
    "questionAssembly": "For a prompt, retrieve the answer statement for each unique viable Moon house and present up to four house-derived answers. If more than four unique houses remain, partition candidates into comparison rounds without treating absence from a round as rejection.",
    "answerReturn": "Each selected option returns a concrete moonHouse. No numeric personality score is required.",
    "twoQuestionRule": "Use both prompt families when confirmation is useful. If both select the same Moon house, the Lunar tumbler is confirmed. If they split, preserve both houses for the Ascendant Lock rather than forcing one.",
    "userFacingRule": "Do not expose house numbers or astrological terminology in the answer options."
  },
  "houses": [
    {
      "house": 1,
      "label": "Moon in the 1st House",
      "meaning": "The Moon is brought directly to body, temperament, identity, appearance, and immediate experience. Feelings arrive personally and often visibly.",
      "answers": {
        "emotionalGravity": {
          "text": "My own state. What happens tends to register immediately in my mood, body, or sense of self, and it can be difficult to separate how I feel from how I am experiencing the moment.",
          "returns": {
            "moonHouse": 1
          }
        },
        "emotionalRegulation": {
          "text": "Getting myself physically and emotionally settled. I recover by tending to my own state first: my body, surroundings, comfort, rhythm, or immediate needs.",
          "returns": {
            "moonHouse": 1
          }
        }
      }
    },
    {
      "house": 2,
      "label": "Moon in the 2nd House",
      "meaning": "The Moon seeks continuity through resources, material stability, possessions, skills, self-support, and having enough.",
      "answers": {
        "emotionalGravity": {
          "text": "Security and what I can rely on. Money, resources, possessions, stability, or knowing that I have enough can carry more emotional weight for me than they may appear to from the outside.",
          "returns": {
            "moonHouse": 2
          }
        },
        "emotionalRegulation": {
          "text": "Restoring a sense of stability. I feel better when I can make things concrete: check what resources are available, protect what matters, establish a dependable plan, or return to something familiar and reliable.",
          "returns": {
            "moonHouse": 2
          }
        }
      }
    },
    {
      "house": 3,
      "label": "Moon in the 3rd House",
      "meaning": "The Moon processes experience through conversation, language, siblings or peers, local movement, information, familiar places, and everyday exchange.",
      "answers": {
        "emotionalGravity": {
          "text": "The everyday world around me. Conversations, messages, siblings or peers, familiar places, and what is happening nearby can strongly affect how I feel and how I understand an experience.",
          "returns": {
            "moonHouse": 3
          }
        },
        "emotionalRegulation": {
          "text": "Talking, thinking, or moving through it. I often regain my footing by putting feelings into words, exchanging information, taking a drive or walk, or reconnecting with the familiar world around me.",
          "returns": {
            "moonHouse": 3
          }
        }
      }
    },
    {
      "house": 4,
      "label": "Moon in the 4th House",
      "meaning": "The Moon is rooted in home, family, ancestry, memory, private life, land, belonging, and the need for an interior base.",
      "answers": {
        "emotionalGravity": {
          "text": "Home, family, roots, and private life. Where I belong, where I come from, and what happens inside the private part of my life can affect me more deeply than what is visible publicly.",
          "returns": {
            "moonHouse": 4
          }
        },
        "emotionalRegulation": {
          "text": "Returning to my base. I recover through privacy, home, family or chosen family, familiar surroundings, memory, or simply having a protected place where I do not have to perform for anyone.",
          "returns": {
            "moonHouse": 4
          }
        }
      }
    },
    {
      "house": 5,
      "label": "Moon in the 5th House",
      "meaning": "The Moon seeks emotional vitality through creation, play, pleasure, romance, children, performance, risk, affection, and personally cherished expressions.",
      "answers": {
        "emotionalGravity": {
          "text": "What I love and bring to life. Creativity, romance, pleasure, children, performance, play, or something I have personally made can become emotionally central very quickly.",
          "returns": {
            "moonHouse": 5
          }
        },
        "emotionalRegulation": {
          "text": "Expressing or creating something. I regain myself through play, affection, romance, art, entertainment, making something, or spending time with people or projects that awaken genuine delight.",
          "returns": {
            "moonHouse": 5
          }
        }
      }
    },
    {
      "house": 6,
      "label": "Moon in the 6th House",
      "meaning": "The Moon becomes involved in work, service, obligation, maintenance, health, routines, craft, problem-solving, and repeated tasks that keep life functioning.",
      "answers": {
        "emotionalGravity": {
          "text": "What needs to be taken care of. Work, responsibilities, health, routines, practical problems, or being useful to other people can occupy a surprising amount of my emotional attention.",
          "returns": {
            "moonHouse": 6
          }
        },
        "emotionalRegulation": {
          "text": "Doing what needs to be done. I often feel steadier once I can establish a routine, solve the practical problem, clean something up, organize the details, work, or make myself useful.",
          "returns": {
            "moonHouse": 6
          }
        }
      }
    },
    {
      "house": 7,
      "label": "Moon in the 7th House",
      "meaning": "The Moon encounters itself through significant others. Partnership, attachment, reciprocity, interpersonal response, conflict, negotiation, and being emotionally witnessed become major sites of lived experience.",
      "answers": {
        "emotionalGravity": {
          "text": "My close relationships. What happens between me and another person can affect my internal state profoundly; I often understand what I am feeling more clearly through partnership or one-to-one interaction.",
          "returns": {
            "moonHouse": 7
          }
        },
        "emotionalRegulation": {
          "text": "Re-establishing connection or relational clarity. I tend to feel steadier once I know where I stand with the important person involved, have talked it through, or restored some form of reciprocity.",
          "returns": {
            "moonHouse": 7
          }
        }
      }
    },
    {
      "house": 8,
      "label": "Moon in the 8th House",
      "meaning": "The Moon becomes emotionally engaged with shared stakes: dependence, trust, loss, debt, inheritance, other people's resources, vulnerability, fear, obligation, and entanglement.",
      "answers": {
        "emotionalGravity": {
          "text": "What is shared, vulnerable, or difficult to control alone. Trust, loss, dependency, obligations, shared money, secrets, or deeply consequential entanglements can carry enormous emotional weight for me.",
          "returns": {
            "moonHouse": 8
          }
        },
        "emotionalRegulation": {
          "text": "Understanding what is really at stake. I regain my footing by getting beneath the surface: clarifying the trust involved, the obligation, the shared resources, the risk, or what I may have to surrender or depend upon.",
          "returns": {
            "moonHouse": 8
          }
        }
      }
    },
    {
      "house": 9,
      "label": "Moon in the 9th House",
      "meaning": "The Moon seeks emotional orientation through worldview, religion, philosophy, divination, higher learning, teaching, foreign places, long journeys, law, interpretation, and meaning.",
      "answers": {
        "emotionalGravity": {
          "text": "What an experience means. Beliefs, philosophy, spirituality, learning, travel, or finding the larger pattern behind events can become emotionally important to me, especially when life stops making sense.",
          "returns": {
            "moonHouse": 9
          }
        },
        "emotionalRegulation": {
          "text": "Finding a larger frame. I regain perspective by learning, reading, studying, traveling, consulting a belief system, or asking how the immediate experience fits into a much larger story.",
          "returns": {
            "moonHouse": 9
          }
        }
      }
    },
    {
      "house": 10,
      "label": "Moon in the 10th House",
      "meaning": "The Moon becomes emotionally invested in public life, vocation, responsibility, authority, reputation, achievement, visibility, and one's effect on the larger world.",
      "answers": {
        "emotionalGravity": {
          "text": "What I am doing with my life in the world. Work, calling, achievement, reputation, responsibility, or whether I am making a meaningful public contribution can affect me on a deeply personal level.",
          "returns": {
            "moonHouse": 10
          }
        },
        "emotionalRegulation": {
          "text": "Regaining direction and competence. I often feel steadier when I can identify what I am responsible for, make progress toward a goal, restore my sense of purpose, or know what role I am meant to play.",
          "returns": {
            "moonHouse": 10
          }
        }
      }
    },
    {
      "house": 11,
      "label": "Moon in the 11th House",
      "meaning": "The Moon seeks belonging through friends, alliances, communities, groups, networks, patrons, shared causes, hopes, and the future.",
      "answers": {
        "emotionalGravity": {
          "text": "My people and the future we are moving toward. Friendship, community, groups, collaborators, shared causes, and whether I feel included in something larger than myself can matter to me enormously.",
          "returns": {
            "moonHouse": 11
          }
        },
        "emotionalRegulation": {
          "text": "Reconnecting with people and possibility. I regain emotional footing through friends, community, collaboration, shared plans, or remembering that I am part of a future larger than the immediate problem.",
          "returns": {
            "moonHouse": 11
          }
        }
      }
    },
    {
      "house": 12,
      "label": "Moon in the 12th House",
      "meaning": "The Moon withdraws from direct visibility. Emotional experience may collect around solitude, retreat, hidden burdens, dreams, confinement, private grief, inaccessible feelings, or spiritual interiority.",
      "answers": {
        "emotionalGravity": {
          "text": "The part of life I experience privately. Some of my strongest feelings happen away from other people, and solitude, hidden burdens, dreams, grief, retreat, or things I cannot easily explain can carry unusual emotional force.",
          "returns": {
            "moonHouse": 12
          }
        },
        "emotionalRegulation": {
          "text": "Having enough protected space to disappear for a while. I often recover through solitude, sleep, retreat, privacy, spiritual reflection, or temporarily stepping outside ordinary demands until I can hear myself again.",
          "returns": {
            "moonHouse": 12
          }
        }
      }
    }
  ]
}
```

<!-- END: ORBO_LUNAR_LOCK_BANK -->

---

<!-- BEGIN: ORBO_RULER_HOUSE_LOCK_BANK -->

# Embedded Question Bank B — Ruler / House Lock v2

## Orbo Ruler / House Lock — 144-Question Tumbler Bank v2

The 144 authored question texts are preserved from the earlier Ascendant-Ruler House Question Bank. This wrapper updates their runtime behavior to the current combination-lock architecture: no dated-event stage and no numeric FRAME4 score is required.

```json
{
  "id": "orbo_ruler_house_lock_v2",
  "version": "2.0.0",
  "framework": "Traditional domicile rulers + whole-sign houses. Whole-Sign Frames determine which of the 144 records applies to each candidate.",
  "purpose": "Test the exact chart-ruler-in-house configuration produced by each viable Ascendant candidate and return that candidate as the ruler tumbler.",
  "responseOptions": [
    {
      "id": "confirm",
      "text": "Yes — this has been a strong, recurring pattern in my life.",
      "outcome": "confirm_candidate"
    },
    {
      "id": "retain",
      "text": "Partly — this fits, but not strongly enough to define the pattern.",
      "outcome": "retain_candidate"
    },
    {
      "id": "reject",
      "text": "No — this has rarely or never described my life.",
      "outcome": "reject_candidate"
    },
    {
      "id": "unknown",
      "text": "I am not sure or do not have enough evidence.",
      "outcome": "unresolved"
    }
  ],
  "runtime": {
    "candidateGeneration": "Use ORBO_WHOLE_SIGN_FRAMES. For each viable Ascendant, identify its traditional chart ruler and the whole-sign house occupied by that ruler at the candidate time.",
    "lookup": "Select exactly the record matching risingSign + ruler + rulerHouse for that candidate state.",
    "selection": "Ask only records belonging to viable candidate states. A sign normally has one applicable ruler-house question for a given birth date/time interval; if its ruler changes signs within the remaining interval, preserve the time-qualified states separately.",
    "noNumericScoring": "Responses resolve candidate state rather than adding a generic personality score.",
    "confirm": "A confirm answer returns the record candidateKey as the Ruler/House tumbler.",
    "retain": "A retain answer keeps the candidate viable but does not hard-lock it.",
    "reject": "A reject answer removes support for that candidate but should not erase an otherwise astronomically required state without corroboration.",
    "pairWithLunar": "Ascendant Lock occurs when the ruler-selected candidate produces a Moon house consistent with the Lunar tumbler."
  },
  "questions": [
    {
      "id": "FR-ARI-MAR-H01",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people experienced you as someone who acts first, asserts independence physically, or enters situations with unmistakable urgency before they know much else about you?",
      "candidateKey": "aries_mars_h01"
    },
    {
      "id": "FR-ARI-MAR-H04",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has your private life repeatedly required you to defend the home, take charge in family crises, break from inherited patterns, or become the forceful person at the center of the household?",
      "candidateKey": "aries_mars_h04"
    },
    {
      "id": "FR-ARI-MAR-H07",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have close partners, rivals, clients, or opponents repeatedly forced you to define yourself, with one-to-one relationships feeling active, confrontational, competitive, or impossible to approach passively?",
      "candidateKey": "aries_mars_h07"
    },
    {
      "id": "FR-ARI-MAR-H10",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public life repeatedly cast you as the initiator, competitor, leader, firefighter, entrepreneur, or person expected to act when others hesitate?",
      "candidateKey": "aries_mars_h10"
    },
    {
      "id": "FR-ARI-MAR-H02",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Has earning, owning, or protecting your own resources repeatedly required initiative, competition, risk, or a strong refusal to depend on others?",
      "candidateKey": "aries_mars_h02"
    },
    {
      "id": "FR-ARI-MAR-H05",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do romance, creativity, performance, play, or children tend to awaken your competitive spirit, bold pursuit, appetite for risk, or need to create without permission?",
      "candidateKey": "aries_mars_h05"
    },
    {
      "id": "FR-ARI-MAR-H08",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have debt, shared money, inheritance, intimacy, loss, or crisis repeatedly required decisive action from you, especially when control, trust, or survival was at stake?",
      "candidateKey": "aries_mars_h08"
    },
    {
      "id": "FR-ARI-MAR-H11",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "In friendships, organizations, and long-range goals, are you usually the mobilizer who starts the effort, pushes the group forward, or turns shared ambitions into action?",
      "candidateKey": "aries_mars_h11"
    },
    {
      "id": "FR-ARI-MAR-H03",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have your voice, schooling, siblings, or local environment repeatedly placed you in the role of the blunt speaker, fast learner, challenger, or person who starts the conversation others avoid?",
      "candidateKey": "aries_mars_h03"
    },
    {
      "id": "FR-ARI-MAR-H06",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Do ordinary work, health, chores, or problem-solving repeatedly put you into battle mode, making you most effective when there is something urgent to fix, overcome, or manage?",
      "candidateKey": "aries_mars_h06"
    },
    {
      "id": "FR-ARI-MAR-H09",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do education, travel, religion, law, publishing, or questions of truth tend to become missions you pursue directly, defend fiercely, or use to test your courage?",
      "candidateKey": "aries_mars_h09"
    },
    {
      "id": "FR-ARI-MAR-H12",
      "risingSign": "aries",
      "ruler": "mars",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Is much of your anger, drive, competitiveness, or need for action hidden from others, emerging most strongly in solitude, behind the scenes, in institutions, or through periods of self-undoing?",
      "candidateKey": "aries_mars_h12"
    },
    {
      "id": "FR-TAU-VEN-H01",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as steady, composed, sensate, attractive, or difficult to hurry, with your body and presence communicating your values before you speak?",
      "candidateKey": "taurus_venus_h01"
    },
    {
      "id": "FR-TAU-VEN-H04",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has creating a peaceful, stable, beautiful, or materially secure home been central to your identity, with family continuity and private comfort carrying unusual importance?",
      "candidateKey": "taurus_venus_h04"
    },
    {
      "id": "FR-TAU-VEN-H07",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partnership, loyalty, attraction, and shared values repeatedly determined your sense of stability, with major life choices shaped through one-to-one bonds?",
      "candidateKey": "taurus_venus_h07"
    },
    {
      "id": "FR-TAU-VEN-H10",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your reputation been built around dependability, taste, calm judgment, value creation, or the ability to make people and systems feel more stable?",
      "candidateKey": "taurus_venus_h10"
    },
    {
      "id": "FR-TAU-VEN-H02",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Has building tangible security through money, possessions, craft, beauty, food, land, or dependable skills been one of the clearest organizing themes of your life?",
      "candidateKey": "taurus_venus_h02"
    },
    {
      "id": "FR-TAU-VEN-H05",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do pleasure, art, romance, performance, children, or making beautiful things feel less like side interests and more like the place where your deepest vitality becomes visible?",
      "candidateKey": "taurus_venus_h05"
    },
    {
      "id": "FR-TAU-VEN-H08",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have shared finances, debt, inheritance, intimacy, grief, or dependence repeatedly tested your need for security, making you cautious about what becomes entangled with another person?",
      "candidateKey": "taurus_venus_h08"
    },
    {
      "id": "FR-TAU-VEN-H11",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Have loyal friends, patrons, communities, or professional networks been crucial to your long-term gains, with relationships ripening slowly but becoming materially important?",
      "candidateKey": "taurus_venus_h11"
    },
    {
      "id": "FR-TAU-VEN-H03",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are your voice, learning style, sibling relationships, or local routines marked by patience, practicality, aesthetic sensitivity, and a preference for words that can be trusted and used?",
      "candidateKey": "taurus_venus_h03"
    },
    {
      "id": "FR-TAU-VEN-H06",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Do you function best when work, health, and daily routines are sustainable, well-made, calm, and physically comfortable, resisting systems that demand constant urgency or disruption?",
      "candidateKey": "taurus_venus_h06"
    },
    {
      "id": "FR-TAU-VEN-H09",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do your beliefs grow through direct experience of nature, art, culture, food, land, or the physical world, with travel and education changing you slowly rather than suddenly?",
      "candidateKey": "taurus_venus_h09"
    },
    {
      "id": "FR-TAU-VEN-H12",
      "risingSign": "taurus",
      "ruler": "venus",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Are some of your strongest attachments, pleasures, artistic impulses, or resistances kept private, emerging through retreat, secrecy, dreams, or a hidden life others rarely see?",
      "candidateKey": "taurus_venus_h12"
    },
    {
      "id": "FR-GEM-MER-H01",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as curious, quick, verbal, youthful, mobile, or difficult to reduce to one role because your identity changes with the conversation?",
      "candidateKey": "gemini_mercury_h01"
    },
    {
      "id": "FR-GEM-MER-H04",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has home life been mentally busy, changeable, divided between places, full of stories, or shaped by working, studying, writing, or conducting business from home?",
      "candidateKey": "gemini_mercury_h04"
    },
    {
      "id": "FR-GEM-MER-H07",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have close relationships depended heavily on conversation, debate, negotiation, introductions, or mental chemistry, with partners acting as mirrors for your ideas and choices?",
      "candidateKey": "gemini_mercury_h07"
    },
    {
      "id": "FR-GEM-MER-H10",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role required you to communicate, explain, write, connect people, manage information, or maintain several professional identities at once?",
      "candidateKey": "gemini_mercury_h10"
    },
    {
      "id": "FR-GEM-MER-H02",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have income and self-support repeatedly depended on words, trade, information, sales, writing, teaching, technology, or maintaining more than one skill or revenue stream?",
      "candidateKey": "gemini_mercury_h02"
    },
    {
      "id": "FR-GEM-MER-H05",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do play, romance, creativity, humor, games, writing, or children bring out your most inventive and talkative self, with mental stimulation necessary for enjoyment?",
      "candidateKey": "gemini_mercury_h05"
    },
    {
      "id": "FR-GEM-MER-H08",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Are you repeatedly drawn into research, secrets, taxes, debt, inheritance, psychology, taboo subjects, or difficult conversations that require you to gather and interpret hidden information?",
      "candidateKey": "gemini_mercury_h08"
    },
    {
      "id": "FR-GEM-MER-H11",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Do friends, networks, communities, and future plans rely on your ability to make introductions, circulate ideas, compare possibilities, or keep many people connected?",
      "candidateKey": "gemini_mercury_h11"
    },
    {
      "id": "FR-GEM-MER-H03",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have speaking, writing, learning, siblings, short trips, or the local environment been unusually central to your life, making communication itself one of your primary arenas of identity?",
      "candidateKey": "gemini_mercury_h03"
    },
    {
      "id": "FR-GEM-MER-H06",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Does daily life repeatedly fill with many small tasks, messages, fixes, errands, or shifting duties, making versatility useful but steady routines difficult to maintain?",
      "candidateKey": "gemini_mercury_h06"
    },
    {
      "id": "FR-GEM-MER-H09",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Have languages, travel, higher education, teaching, publishing, law, religion, or competing worldviews repeatedly expanded your identity and given your mind a larger field to move through?",
      "candidateKey": "gemini_mercury_h09"
    },
    {
      "id": "FR-GEM-MER-H12",
      "risingSign": "gemini",
      "ruler": "mercury",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Is your mind most active in private, with hidden correspondence, solitary research, insomnia, secret plans, or behind-the-scenes thinking taking up more energy than others realize?",
      "candidateKey": "gemini_mercury_h12"
    },
    {
      "id": "FR-CAN-MOO-H01",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people quickly sensed your moods, protectiveness, sensitivity, or responsiveness, as though your body and face reveal the emotional weather before you explain it?",
      "candidateKey": "cancer_moon_h01"
    },
    {
      "id": "FR-CAN-MOO-H04",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Have home, ancestry, family, land, belonging, or becoming the caretaker of a household been among the strongest and most recurring foundations of your identity?",
      "candidateKey": "cancer_moon_h04"
    },
    {
      "id": "FR-CAN-MOO-H07",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have close partners and clients repeatedly shaped your sense of safety and identity, making relationships feel protective, emotionally responsive, or difficult to separate from your own needs?",
      "candidateKey": "cancer_moon_h07"
    },
    {
      "id": "FR-CAN-MOO-H10",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly required you to care for, represent, protect, feed, house, remember, or emotionally respond to other people?",
      "candidateKey": "cancer_moon_h10"
    },
    {
      "id": "FR-CAN-MOO-H02",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have money and security been closely tied to home, food, family, caregiving, saving, or fluctuating emotional needs, with your sense of safety affecting how you earn and spend?",
      "candidateKey": "cancer_moon_h02"
    },
    {
      "id": "FR-CAN-MOO-H05",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do children, romance, art, performance, play, or creative work function as emotional nourishment, giving you a place to care, remember, imagine, and be openly tender?",
      "candidateKey": "cancer_moon_h05"
    },
    {
      "id": "FR-CAN-MOO-H08",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have grief, inheritance, shared money, family obligations, intimacy, or another person's crisis repeatedly pulled you into deep emotional entanglements that are hard to treat impersonally?",
      "candidateKey": "cancer_moon_h08"
    },
    {
      "id": "FR-CAN-MOO-H11",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Do friendships and communities tend to become chosen family, with your long-term goals changing according to who needs care, where you belong, and what your people require?",
      "candidateKey": "cancer_moon_h11"
    },
    {
      "id": "FR-CAN-MOO-H03",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are your memories, stories, siblings, neighborhood, or daily communications emotionally charged, with a strong instinct to remember, protect, and interpret the lives around you?",
      "candidateKey": "cancer_moon_h03"
    },
    {
      "id": "FR-CAN-MOO-H06",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Does your daily work often involve caregiving, feeding, supporting, responding, or tending to changing needs, while health and productivity rise and fall with your emotional state?",
      "candidateKey": "cancer_moon_h06"
    },
    {
      "id": "FR-CAN-MOO-H09",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do travel, education, religion, law, ancestry, or cultural tradition matter most when they create belonging, connect you to a lineage, or give emotional meaning to the wider world?",
      "candidateKey": "cancer_moon_h09"
    },
    {
      "id": "FR-CAN-MOO-H12",
      "risingSign": "cancer",
      "ruler": "moon",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Are your deepest feelings, family burdens, grief, intuition, or need for retreat largely hidden, becoming strongest in solitude, dreams, hospitals, institutions, or private acts of care?",
      "candidateKey": "cancer_moon_h12"
    },
    {
      "id": "FR-LEO-SUN-H01",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people naturally looked to you as a visible center, leader, performer, author, or source of confidence even when you were not deliberately seeking attention?",
      "candidateKey": "leo_sun_h01"
    },
    {
      "id": "FR-LEO-SUN-H04",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has the home functioned as your private kingdom, with family pride, ancestry, property, hospitality, or the need to establish your own center carrying unusual importance?",
      "candidateKey": "leo_sun_h04"
    },
    {
      "id": "FR-LEO-SUN-H07",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partners, clients, or rivals repeatedly become co-stars, audiences, or mirrors of your significance, making one-to-one relationships central to how you understand your own light?",
      "candidateKey": "leo_sun_h07"
    },
    {
      "id": "FR-LEO-SUN-H10",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has career, reputation, leadership, or public recognition been one of the most obvious organizing forces in your life, even when you tried to keep a lower profile?",
      "candidateKey": "leo_sun_h10"
    },
    {
      "id": "FR-LEO-SUN-H02",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Has your self-worth been strongly tied to being recognized for a talent, producing something distinctly yours, or earning through work that carries your personal name, taste, or authority?",
      "candidateKey": "leo_sun_h02"
    },
    {
      "id": "FR-LEO-SUN-H05",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Are creativity, romance, performance, pleasure, or children among the clearest places where you feel fully alive, seen, and able to express something unmistakably your own?",
      "candidateKey": "leo_sun_h05"
    },
    {
      "id": "FR-LEO-SUN-H08",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have shared money, inheritance, intimacy, loss, or crisis repeatedly tested your pride, authority, legacy, or ability to remain centered when control is shared or taken away?",
      "candidateKey": "leo_sun_h08"
    },
    {
      "id": "FR-LEO-SUN-H11",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Do audiences, patrons, friends, organizations, or communities amplify your creative authority, with your future goals depending on being seen by the right collective?",
      "candidateKey": "leo_sun_h11"
    },
    {
      "id": "FR-LEO-SUN-H03",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have your voice, storytelling, education, siblings, or local community repeatedly made you visible, placing you in the role of spokesperson, teacher, entertainer, or neighborhood authority?",
      "candidateKey": "leo_sun_h03"
    },
    {
      "id": "FR-LEO-SUN-H06",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Do you need ownership, recognition, or a sense of purpose in daily work, with morale and health suffering when your contribution feels invisible or merely mechanical?",
      "candidateKey": "leo_sun_h06"
    },
    {
      "id": "FR-LEO-SUN-H09",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do travel, higher learning, religion, law, teaching, or publishing call you to become a visible advocate for a worldview rather than a quiet student of it?",
      "candidateKey": "leo_sun_h09"
    },
    {
      "id": "FR-LEO-SUN-H12",
      "risingSign": "leo",
      "ruler": "sun",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Is an important part of your creativity, pride, leadership, or need for recognition hidden backstage, expressed through solitude, institutions, private sacrifice, or work for which others receive the credit?",
      "candidateKey": "leo_sun_h12"
    },
    {
      "id": "FR-VIR-MER-H01",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as observant, precise, useful, analytical, or self-correcting, noticing details and problems before anyone has asked you to?",
      "candidateKey": "virgo_mercury_h01"
    },
    {
      "id": "FR-VIR-MER-H04",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Have you repeatedly become the organizer, fixer, archivist, or practical problem-solver within the family, with private peace depending on a household that functions properly?",
      "candidateKey": "virgo_mercury_h04"
    },
    {
      "id": "FR-VIR-MER-H07",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have close relationships often taken the form of shared problem-solving, advising, editing, helping, or managing details, with criticism and usefulness becoming important relational themes?",
      "candidateKey": "virgo_mercury_h07"
    },
    {
      "id": "FR-VIR-MER-H10",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your reputation been built around competence, accuracy, diagnosis, analysis, editing, research, or being the person trusted to make a complicated system actually work?",
      "candidateKey": "virgo_mercury_h10"
    },
    {
      "id": "FR-VIR-MER-H02",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have income and security repeatedly depended on technical skill, analysis, editing, repair, organization, service, or knowing exactly how resources are being used?",
      "candidateKey": "virgo_mercury_h02"
    },
    {
      "id": "FR-VIR-MER-H05",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do creativity, dating, play, or parenting bring out your craft, discernment, and desire to improve, making you selective about what and whom you give sustained attention?",
      "candidateKey": "virgo_mercury_h05"
    },
    {
      "id": "FR-VIR-MER-H08",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Are you repeatedly the person who tracks debts, paperwork, risks, diagnoses, inheritances, shared resources, or difficult facts when a crisis requires precision rather than reassurance?",
      "candidateKey": "virgo_mercury_h08"
    },
    {
      "id": "FR-VIR-MER-H11",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "In groups and long-term plans, are you usually the organizer who creates lists, improves processes, translates ideals into tasks, or notices what the collective has overlooked?",
      "candidateKey": "virgo_mercury_h11"
    },
    {
      "id": "FR-VIR-MER-H03",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are communication, schooling, siblings, writing, and daily movement marked by detail, correction, categorization, or the need to make information clearer and more accurate?",
      "candidateKey": "virgo_mercury_h03"
    },
    {
      "id": "FR-VIR-MER-H06",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Have work, health, maintenance, service, and daily systems been unusually central to your identity, with much of life organized around making things cleaner, better, safer, or more efficient?",
      "candidateKey": "virgo_mercury_h06"
    },
    {
      "id": "FR-VIR-MER-H09",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do higher education, travel, religion, law, or publishing matter most when they provide a method, body of expertise, or practical system you can test, refine, and teach?",
      "candidateKey": "virgo_mercury_h09"
    },
    {
      "id": "FR-VIR-MER-H12",
      "risingSign": "virgo",
      "ruler": "mercury",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Do much of your worry, analysis, service, or repair work happen invisibly, with solitude, institutions, private research, or behind-the-scenes labor consuming more energy than others know?",
      "candidateKey": "virgo_mercury_h12"
    },
    {
      "id": "FR-LIB-VEN-H01",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as relational, tactful, aesthetically aware, socially responsive, or naturally inclined to consider both sides before acting?",
      "candidateKey": "libra_venus_h01"
    },
    {
      "id": "FR-LIB-VEN-H04",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has creating a harmonious, beautiful, socially welcoming home been central to your identity, with family peace often depending on your diplomacy or willingness to negotiate?",
      "candidateKey": "libra_venus_h04"
    },
    {
      "id": "FR-LIB-VEN-H07",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partnership, marriage, clients, contracts, or one-to-one alliances been among the most defining forces in your life, making identity difficult to understand apart from relationship?",
      "candidateKey": "libra_venus_h07"
    },
    {
      "id": "FR-LIB-VEN-H10",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly involved diplomacy, design, aesthetics, law, mediation, client relations, or creating alliances between people who would not otherwise cooperate?",
      "candidateKey": "libra_venus_h10"
    },
    {
      "id": "FR-LIB-VEN-H02",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have earnings and self-worth repeatedly depended on clients, collaboration, design, beauty, negotiation, social skill, or maintaining a fair exchange of value?",
      "candidateKey": "libra_venus_h02"
    },
    {
      "id": "FR-LIB-VEN-H05",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do romance, art, fashion, performance, pleasure, or creative collaboration feel like primary arenas of self-expression rather than optional decoration around the rest of life?",
      "candidateKey": "libra_venus_h05"
    },
    {
      "id": "FR-LIB-VEN-H08",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have shared money, debt, inheritance, intimacy, or grief repeatedly required negotiation about fairness, reciprocity, boundaries, and what each person owes the other?",
      "candidateKey": "libra_venus_h08"
    },
    {
      "id": "FR-LIB-VEN-H11",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Have friendships, patrons, social networks, and alliances been central to your gains and future plans, with opportunity often arriving through relationship rather than solitary effort?",
      "candidateKey": "libra_venus_h11"
    },
    {
      "id": "FR-LIB-VEN-H03",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have your voice, education, siblings, or local environment repeatedly cast you as the mediator, translator, stylist, connector, or person expected to make communication more balanced?",
      "candidateKey": "libra_venus_h03"
    },
    {
      "id": "FR-LIB-VEN-H06",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Do you work best in environments that are cooperative, elegant, fair, and socially balanced, with conflict or ugliness in daily routines affecting your health and effectiveness?",
      "candidateKey": "libra_venus_h06"
    },
    {
      "id": "FR-LIB-VEN-H09",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do law, art, culture, travel, education, ethics, or diplomacy shape your worldview, with truth often approached through comparison and the search for a just proportion?",
      "candidateKey": "libra_venus_h09"
    },
    {
      "id": "FR-LIB-VEN-H12",
      "risingSign": "libra",
      "ruler": "venus",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Are important relationships, artistic longings, resentments, or acts of accommodation hidden from public view, emerging through secrecy, retreat, institutions, or private sacrifice?",
      "candidateKey": "libra_venus_h12"
    },
    {
      "id": "FR-SCO-MAR-H01",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people quickly sensed intensity, guardedness, strategic awareness, force, or a refusal to be easily read, even when you are saying very little?",
      "candidateKey": "scorpio_mars_h01"
    },
    {
      "id": "FR-SCO-MAR-H04",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has your private life been fortified around family secrets, ancestral conflict, crisis, protection, or the need to control access to the home and to your vulnerable inner world?",
      "candidateKey": "scorpio_mars_h04"
    },
    {
      "id": "FR-SCO-MAR-H07",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partners, clients, rivals, or open enemies repeatedly confronted you with questions of trust, loyalty, power, jealousy, conflict, and the enforcement of boundaries?",
      "candidateKey": "scorpio_mars_h07"
    },
    {
      "id": "FR-SCO-MAR-H10",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly involved strategy, investigation, crisis, competition, secrecy, surgery, power, or taking command when the stakes are high?",
      "candidateKey": "scorpio_mars_h10"
    },
    {
      "id": "FR-SCO-MAR-H02",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have money and possessions repeatedly become questions of survival, control, leverage, scarcity, or strategic independence, making you unusually alert to who holds the resources?",
      "candidateKey": "scorpio_mars_h02"
    },
    {
      "id": "FR-SCO-MAR-H05",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do romance, sexuality, creativity, performance, or children awaken an all-or-nothing intensity, making pleasure transformative, consuming, competitive, or difficult to approach casually?",
      "candidateKey": "scorpio_mars_h05"
    },
    {
      "id": "FR-SCO-MAR-H08",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have shared money, debt, inheritance, intimacy, mortality, loss, secrecy, or crisis been among the most defining arenas of your life, repeatedly forcing profound reinvention?",
      "candidateKey": "scorpio_mars_h08"
    },
    {
      "id": "FR-SCO-MAR-H11",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Are you highly selective about friends and alliances, with groups, causes, and long-range goals often involving loyalty tests, hidden politics, or collective struggles for power?",
      "candidateKey": "scorpio_mars_h11"
    },
    {
      "id": "FR-SCO-MAR-H03",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are your speech, research, sibling relationships, or local environment marked by probing questions, sharp observation, secrecy, conflict, or an instinct to notice what others are concealing?",
      "candidateKey": "scorpio_mars_h03"
    },
    {
      "id": "FR-SCO-MAR-H06",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Are you repeatedly drawn into difficult work, emergencies, repair, investigation, health crises, or situations where endurance and crisis management matter more than social ease?",
      "candidateKey": "scorpio_mars_h06"
    },
    {
      "id": "FR-SCO-MAR-H09",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do religion, psychology, occult study, law, travel, or higher education become intense investigations through which you test truth, confront taboo material, or survive a change in worldview?",
      "candidateKey": "scorpio_mars_h09"
    },
    {
      "id": "FR-SCO-MAR-H12",
      "risingSign": "scorpio",
      "ruler": "mars",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Is much of your anger, fear, strategy, sexuality, or survival instinct concealed, emerging through isolation, secret work, institutions, private enemies, or patterns of self-sabotage?",
      "candidateKey": "scorpio_mars_h12"
    },
    {
      "id": "FR-SAG-JUP-H01",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as expansive, candid, humorous, restless, hopeful, opinionated, or already moving toward a larger horizon?",
      "candidateKey": "sagittarius_jupiter_h01"
    },
    {
      "id": "FR-SAG-JUP-H04",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has your home served as a base for travel, learning, guests, cultural exchange, belief, or a large family story, with private life organized around room to grow?",
      "candidateKey": "sagittarius_jupiter_h04"
    },
    {
      "id": "FR-SAG-JUP-H07",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have close partners often come from different backgrounds, widened your world, acted as teachers or fellow travelers, or made relationship itself a path of growth and belief?",
      "candidateKey": "sagittarius_jupiter_h07"
    },
    {
      "id": "FR-SAG-JUP-H10",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly involved teaching, advocacy, law, religion, publishing, travel, international work, or giving other people a larger vision of what is possible?",
      "candidateKey": "sagittarius_jupiter_h10"
    },
    {
      "id": "FR-SAG-JUP-H02",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have income and security repeatedly been tied to teaching, travel, publishing, law, risk, generosity, entrepreneurship, or a belief that opportunity grows when you move beyond limits?",
      "candidateKey": "sagittarius_jupiter_h02"
    },
    {
      "id": "FR-SAG-JUP-H05",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do romance, creativity, children, sport, performance, or play awaken your adventurous, humorous, competitive, teaching, or risk-taking side?",
      "candidateKey": "sagittarius_jupiter_h05"
    },
    {
      "id": "FR-SAG-JUP-H08",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have taxes, debt, inheritance, shared assets, grief, or crisis repeatedly required faith, legal knowledge, generosity, or the willingness to take a large risk with another person's resources?",
      "candidateKey": "sagittarius_jupiter_h08"
    },
    {
      "id": "FR-SAG-JUP-H11",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Do broad networks, communities, patrons, causes, and future visions naturally expand your opportunities, with friends often connecting you to a wider world?",
      "candidateKey": "sagittarius_jupiter_h11"
    },
    {
      "id": "FR-SAG-JUP-H03",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have speaking, writing, schooling, siblings, or local travel repeatedly placed you in the role of storyteller, teacher, preacher, translator of meaning, or person who makes the small world larger?",
      "candidateKey": "sagittarius_jupiter_h03"
    },
    {
      "id": "FR-SAG-JUP-H06",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Do you need freedom, movement, growth, and meaning in daily work, with health and morale declining when routines feel narrow, repetitive, or disconnected from a larger purpose?",
      "candidateKey": "sagittarius_jupiter_h06"
    },
    {
      "id": "FR-SAG-JUP-H09",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Have travel, higher education, religion, law, publishing, teaching, or the search for truth been among the clearest and most continuous organizing forces in your life?",
      "candidateKey": "sagittarius_jupiter_h09"
    },
    {
      "id": "FR-SAG-JUP-H12",
      "risingSign": "sagittarius",
      "ruler": "jupiter",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Is an important part of your faith, generosity, escapism, excess, or longing for freedom hidden in solitude, exile, institutions, spiritual retreat, or help received from unseen benefactors?",
      "candidateKey": "sagittarius_jupiter_h12"
    },
    {
      "id": "FR-CAP-SAT-H01",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as serious, contained, responsible, durable, cautious, or older than your years, with trust earned slowly?",
      "candidateKey": "capricorn_saturn_h01"
    },
    {
      "id": "FR-CAP-SAT-H04",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has family life carried unusual duty, austerity, hierarchy, ancestral weight, property concerns, or the expectation that you become the stable structure holding the household together?",
      "candidateKey": "capricorn_saturn_h04"
    },
    {
      "id": "FR-CAP-SAT-H07",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partnerships and contracts tended to become serious commitments, tests of endurance, duties, status arrangements, or bonds with older, authoritative, distant, or highly responsible people?",
      "candidateKey": "capricorn_saturn_h07"
    },
    {
      "id": "FR-CAP-SAT-H10",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has career, reputation, rank, leadership, institutional authority, or the slow construction of a public legacy been one of the clearest organizing forces in your life?",
      "candidateKey": "capricorn_saturn_h10"
    },
    {
      "id": "FR-CAP-SAT-H02",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have money and security been built through restraint, delayed gratification, long labor, property, durable skills, or a strong awareness of scarcity and consequence?",
      "candidateKey": "capricorn_saturn_h02"
    },
    {
      "id": "FR-CAP-SAT-H05",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Have creativity, romance, pleasure, or children developed slowly or seriously, asking for commitment, mastery, patience, or responsibility before enjoyment could feel secure?",
      "candidateKey": "capricorn_saturn_h05"
    },
    {
      "id": "FR-CAP-SAT-H08",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have debt, inheritance, grief, shared money, fear, or long-term obligation repeatedly required disciplined risk management and the acceptance of consequences others wanted to avoid?",
      "candidateKey": "capricorn_saturn_h08"
    },
    {
      "id": "FR-CAP-SAT-H11",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Have organizations, institutions, senior allies, and long-term plans produced gains slowly, with a small number of reliable friends mattering more than a large social circle?",
      "candidateKey": "capricorn_saturn_h11"
    },
    {
      "id": "FR-CAP-SAT-H03",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Have communication, schooling, siblings, or the local environment involved early duties, careful speech, long study, distance, delay, or the need to become reliable before you felt ready?",
      "candidateKey": "capricorn_saturn_h03"
    },
    {
      "id": "FR-CAP-SAT-H06",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Have work, health, duty, maintenance, and daily burdens been central to your identity, making you dependable but sometimes trapped in being the person who cannot drop the load?",
      "candidateKey": "capricorn_saturn_h06"
    },
    {
      "id": "FR-CAP-SAT-H09",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do higher education, law, religion, travel, publishing, or philosophy matter most when they offer earned authority, formal structure, tradition, credentials, or a durable body of knowledge?",
      "candidateKey": "capricorn_saturn_h09"
    },
    {
      "id": "FR-CAP-SAT-H12",
      "risingSign": "capricorn",
      "ruler": "saturn",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Have isolation, hidden burdens, institutions, private fears, self-denial, or long periods of behind-the-scenes labor shaped your life more strongly than other people can see?",
      "candidateKey": "capricorn_saturn_h12"
    },
    {
      "id": "FR-AQU-SAT-H01",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as distinct, self-contained, unconventional, cerebral, difficult to categorize, or slightly outside the social order even when you participate in it?",
      "candidateKey": "aquarius_saturn_h01"
    },
    {
      "id": "FR-AQU-SAT-H04",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has home or family life been nontraditional, emotionally detached, communal, technically organized, frequently rearranged, or treated as a private laboratory for living differently?",
      "candidateKey": "aquarius_saturn_h04"
    },
    {
      "id": "FR-AQU-SAT-H07",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partnerships tended to require unusual agreements, ample independence, friendship, intellectual equality, distance, or resistance to conventional roles?",
      "candidateKey": "aquarius_saturn_h07"
    },
    {
      "id": "FR-AQU-SAT-H10",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly placed you inside institutions as a reformer, technical authority, outsider, strategist, or person expected to redesign an outdated system?",
      "candidateKey": "aquarius_saturn_h10"
    },
    {
      "id": "FR-AQU-SAT-H02",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have income and security depended on unconventional skills, technology, systems, collective work, irregular sources, or preserving enough independence to live by your own values?",
      "candidateKey": "aquarius_saturn_h02"
    },
    {
      "id": "FR-AQU-SAT-H05",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do romance, creativity, play, performance, or children bring out your experimental, intellectual, future-oriented, or rule-breaking side more than conventional sentimentality?",
      "candidateKey": "aquarius_saturn_h05"
    },
    {
      "id": "FR-AQU-SAT-H08",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have grants, taxes, shared finances, institutional resources, inheritance, crisis, or intimacy repeatedly become systems problems you approach strategically rather than sentimentally?",
      "candidateKey": "aquarius_saturn_h08"
    },
    {
      "id": "FR-AQU-SAT-H11",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Have groups, causes, networks, communities, and long-range social goals been central to your life, with you acting more as an architect of the collective than a conventional joiner?",
      "candidateKey": "aquarius_saturn_h11"
    },
    {
      "id": "FR-AQU-SAT-H03",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are your communication, schooling, siblings, or local environment marked by unusual ideas, technical thinking, social observation, networks, or the urge to explain how the larger system works?",
      "candidateKey": "aquarius_saturn_h03"
    },
    {
      "id": "FR-AQU-SAT-H06",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Does daily work repeatedly involve systems, technology, teams, reform, troubleshooting, or service to a collective, while ordinary routines remain irregular or difficult to personalize?",
      "candidateKey": "aquarius_saturn_h06"
    },
    {
      "id": "FR-AQU-SAT-H09",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Do science, astrology, philosophy, social theory, travel, higher education, or future-oriented belief systems provide the clearest framework through which you understand the world?",
      "candidateKey": "aquarius_saturn_h09"
    },
    {
      "id": "FR-AQU-SAT-H12",
      "risingSign": "aquarius",
      "ruler": "saturn",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Do alienation, solitary research, hidden systems work, institutions, collective suffering, or the feeling of being outside humanity occupy a private part of life that others rarely understand?",
      "candidateKey": "aquarius_saturn_h12"
    },
    {
      "id": "FR-PIS-JUP-H01",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 1,
      "phase": "A — Angular",
      "question": "Across your life, have people first experienced you as receptive, imaginative, compassionate, elusive, intuitive, or able to become what a situation emotionally requires?",
      "candidateKey": "pisces_jupiter_h01"
    },
    {
      "id": "FR-PIS-JUP-H04",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 4,
      "phase": "A — Angular",
      "question": "Has home functioned as a sanctuary, refuge, dream space, place near water, or site of family sacrifice and idealization, with boundaries inside the household sometimes difficult to maintain?",
      "candidateKey": "pisces_jupiter_h04"
    },
    {
      "id": "FR-PIS-JUP-H07",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 7,
      "phase": "A — Angular",
      "question": "Have partnerships repeatedly involved idealization, compassion, inspiration, rescue, sacrifice, spiritual connection, or uncertainty about where your needs end and another person's begin?",
      "candidateKey": "pisces_jupiter_h07"
    },
    {
      "id": "FR-PIS-JUP-H10",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 10,
      "phase": "A — Angular",
      "question": "Has your public role repeatedly involved healing, art, guidance, spirituality, compassion, imagination, institutions, or a vocation that feels larger and less concrete than a conventional career?",
      "candidateKey": "pisces_jupiter_h10"
    },
    {
      "id": "FR-PIS-JUP-H02",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 2,
      "phase": "B — Succedent",
      "question": "Have income, possessions, and self-worth tended to ebb and flow through art, care, faith, generosity, institutions, or porous boundaries around what belongs to you and what belongs to others?",
      "candidateKey": "pisces_jupiter_h02"
    },
    {
      "id": "FR-PIS-JUP-H05",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 5,
      "phase": "B — Succedent",
      "question": "Do art, music, romance, children, performance, fantasy, or spiritual play feel like primary channels through which your imagination and compassion become fully alive?",
      "candidateKey": "pisces_jupiter_h05"
    },
    {
      "id": "FR-PIS-JUP-H08",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 8,
      "phase": "B — Succedent",
      "question": "Have grief, trauma, shared money, inheritance, intimacy, secrecy, or mortality repeatedly opened you to psychological, spiritual, or mystical realities while testing your boundaries?",
      "candidateKey": "pisces_jupiter_h08"
    },
    {
      "id": "FR-PIS-JUP-H11",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 11,
      "phase": "B — Succedent",
      "question": "Do friends, patrons, compassionate communities, artistic circles, spiritual groups, or utopian causes repeatedly shape your hopes and open doors toward a larger collective dream?",
      "candidateKey": "pisces_jupiter_h11"
    },
    {
      "id": "FR-PIS-JUP-H03",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 3,
      "phase": "C — Cadent",
      "question": "Are your speech, learning, siblings, or local environment shaped by intuition, image, music, memory, symbolism, indirect communication, or difficulty keeping facts separate from atmosphere?",
      "candidateKey": "pisces_jupiter_h03"
    },
    {
      "id": "FR-PIS-JUP-H06",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 6,
      "phase": "C — Cadent",
      "question": "Have work and daily life repeatedly involved care, healing, art, spirituality, institutions, rescue, or service, while firm routines and boundaries are difficult to sustain?",
      "candidateKey": "pisces_jupiter_h06"
    },
    {
      "id": "FR-PIS-JUP-H09",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 9,
      "phase": "C — Cadent",
      "question": "Have faith, travel, higher learning, art, publishing, teaching, religion, or the search for meaning been among the clearest and most continuous organizing forces in your life?",
      "candidateKey": "pisces_jupiter_h09"
    },
    {
      "id": "FR-PIS-JUP-H12",
      "risingSign": "pisces",
      "ruler": "jupiter",
      "rulerHouse": 12,
      "phase": "C — Cadent",
      "question": "Are solitude, dreams, retreat, spirituality, institutions, secret sorrow, invisible help, or escape among the strongest hidden forces in your life, even when your outer life appears ordinary?",
      "candidateKey": "pisces_jupiter_h12"
    }
  ]
}
```

<!-- END: ORBO_RULER_HOUSE_LOCK_BANK -->

---

<!-- BEGIN: ORBO_DECAN_LOCK_BANK -->

# Embedded Question Bank C — Decan Lock

## Orbo Decan Lock — Coded Question Bank

## Purpose

This is the pre-authored **middle tumbler** of Orbo's rAsc rectification system.

It is used **after the rising sign has been structurally locked** by the Lunar Lock + chart-ruler/house process and **before Sabian degree fine-tuning**.

Each rising sign has:

- **3 possible decans**
- **2 independent three-way discriminator questions**
- a fourth `unresolved` option so Orbo never forces a false choice
- deterministic returns of `decan: 1`, `2`, or `3`

The questions are based on the supplied *Thirty-Six Decans in Whole-Sign Astrology* report. The source distinguishes the first, second, and third decans as exact ten-degree divisions and treats the classical Western face ruler as the default traditional ruler while preserving other ruler systems as separate alternatives.

## Lock logic

```text
RISING SIGN LOCKED
        ↓
Decan Question 1
        ↓
returns 1 / 2 / 3 / unresolved
        ↓
Decan Question 2
        ↓
returns 1 / 2 / 3 / unresolved
        ↓
same non-null result twice
        ↓
DECAN LOCK
        ↓
1 → 0°00′–9°59′59″
2 → 10°00′–19°59′59″
3 → 20°00′–29°59′59″
        ↓
SABIAN FINE-TUNING
```

The questions do not show the user the decan number, degree range, ruler, or astrological keywords.

```json
{
  "id": "orbo_decan_lock_v1",
  "version": "1.0.0",
  "sourceBasis": {
    "description": "Question language is derived from the supplied Thirty-Six Decans report. The report treats the classical Western face ruler as the default traditional ruler and the triplicity/decan ruler as a separately labeled alternative.",
    "decanRanges": {
      "1": "0°00′00″–9°59′59″",
      "2": "10°00′00″–19°59′59″",
      "3": "20°00′00″–29°59′59″"
    }
  },
  "purpose": "After the rising sign is structurally locked, discriminate which ten-degree decan contains rAsc.",
  "runtime": {
    "input": "locked rising sign",
    "questionCountPerSign": 2,
    "answersPerQuestion": 4,
    "hardLock": "If both questions return the same non-null decan, lock that decan.",
    "splitResult": "If the two questions return different decans, preserve both as unresolved and do not force a decan.",
    "unresolved": "A null answer leaves the question non-discriminating.",
    "output": {
      "decan": "1 | 2 | 3",
      "degreeWindow": "derived from decan"
    }
  },
  "signs": [
    {
      "sign": "Aries",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars",
          "keywords": [
            "initiative",
            "confrontation",
            "autonomy",
            "urgency",
            "courage",
            "dominion"
          ],
          "kernel": "Moves by initiating, confronting, and establishing autonomy through direct action."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Sun",
          "keywords": [
            "leadership",
            "visibility",
            "confidence",
            "establishment",
            "ambition",
            "self-definition"
          ],
          "kernel": "Moves by establishing a visible position, authorship, leadership, and personal authority."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "completion",
            "alliance",
            "celebration",
            "creativity",
            "desire",
            "consolidation"
          ],
          "kernel": "Moves by joining, completing, consolidating, and turning desire into a finished or shared result."
        }
      ],
      "questions": [
        {
          "id": "decan_aries_q1",
          "prompt": "When you enter a situation where nothing has been established yet, what is most natural for you?",
          "options": [
            {
              "text": "I move first. I would rather confront the situation directly, establish my independence, and create momentum through action.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I establish a position people can recognize. I want to define the direction, take authorship, and become a clear center of authority.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I look for what can be brought together. I want to turn the initial push into an alliance, completed undertaking, or something worth celebrating.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly more characteristic of me.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_aries_q2",
          "prompt": "When your will meets resistance, which response is most familiar?",
          "options": [
            {
              "text": "I push into the obstacle and find out what happens by engaging it directly.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become more concerned with defining my position, taking command, and proving that I can carry the direction myself.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I become more concerned with securing cooperation, preserving what has already been won, or bringing the effort to a satisfying completion.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the situation to choose one.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Taurus",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Venus",
          "keywords": [
            "cultivation",
            "craft",
            "calculation",
            "embodiment",
            "productivity",
            "resourcefulness"
          ],
          "kernel": "Works matter through skill, cultivation, measurement, craft, and practical resourcefulness."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Mercury",
          "keywords": [
            "acquisition",
            "stewardship",
            "security",
            "exchange",
            "control",
            "material intelligence"
          ],
          "kernel": "Seeks security through acquiring, administering, exchanging, and controlling tangible resources."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Saturn",
          "keywords": [
            "endurance",
            "preservation",
            "scarcity",
            "patience",
            "delayed harvest",
            "consolidation"
          ],
          "kernel": "Protects value through patience, preservation, endurance, and sustaining what must mature slowly."
        }
      ],
      "questions": [
        {
          "id": "decan_taurus_q1",
          "prompt": "When you are trying to make something materially secure, where does your attention go first?",
          "options": [
            {
              "text": "To the method: how it can be cultivated, built, measured, improved, or made more skillfully.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "To possession and stewardship: what resources are available, who controls them, and how they can be managed or exchanged reliably.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "To durability: what can survive limits, scarcity, delay, or pressure and still be worth preserving over time.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these stands out clearly.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_taurus_q2",
          "prompt": "Which kind of accomplishment gives you the deepest sense that something is truly solid?",
          "options": [
            {
              "text": "I have made or cultivated something tangible with real skill and practical usefulness.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I have secured access, resources, ownership, or a dependable system of exchange that I can actually rely on.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I have kept something valuable alive through a long period of difficulty and proved that it can endure.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I cannot separate these enough to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Gemini",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Mercury",
          "keywords": [
            "inquiry",
            "interpretation",
            "teaching",
            "multiplicity",
            "expansion",
            "restless thought"
          ],
          "kernel": "Expands through inquiry, interpretation, teaching, multiplicity, and following many lines of thought."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Venus",
          "keywords": [
            "debate",
            "tactical speech",
            "experimentation",
            "contradiction",
            "desire",
            "agitation"
          ],
          "kernel": "Tests ideas through debate, contradiction, tactical language, experimentation, and verbal friction."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "culmination",
            "exposure",
            "mental overload",
            "severance",
            "finality",
            "radical insight"
          ],
          "kernel": "Pushes complexity toward exposure, decisive insight, severance, or the end of an exhausted narrative."
        }
      ],
      "questions": [
        {
          "id": "decan_gemini_q1",
          "prompt": "When a subject really captures your mind, what do you tend to do with it?",
          "options": [
            {
              "text": "I open it outward: gather more perspectives, make connections, interpret it, and often want to explain or teach what I am finding.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I test it: argue with it, experiment, look for contradictions, and sharpen my thinking through friction or exchange.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I push it toward a decisive point: expose the underlying issue, identify what no longer works, and arrive at the conclusion or break that changes the whole picture.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "No one pattern is clearly dominant.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_gemini_q2",
          "prompt": "When you have too much information or too many possibilities, what usually happens?",
          "options": [
            {
              "text": "My mind keeps branching. I want to keep learning, comparing, connecting, and following the next interesting line of thought.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become more argumentative or experimental. I need to test the competing ideas against each other to see what survives.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I reach a threshold where I need to cut through the excess, expose the decisive fact, and close or abandon part of the story.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It varies too much to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Cancer",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Moon",
          "keywords": [
            "affection",
            "hospitality",
            "attraction",
            "belonging",
            "protection",
            "fertility"
          ],
          "kernel": "Creates belonging through affection, hospitality, protection, attraction, and nurturing connection."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "emotional strategy",
            "negotiation",
            "concealment",
            "appetite",
            "rivalry",
            "resource exchange"
          ],
          "kernel": "Navigates emotional life strategically through negotiation, privacy, rivalry, appetite, and the exchange of resources."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "memory",
            "saturation",
            "imagination",
            "kinship",
            "retreat",
            "emotional abundance"
          ],
          "kernel": "Absorbs experience through memory, atmosphere, kinship, imagination, emotional saturation, and retreat."
        }
      ],
      "questions": [
        {
          "id": "decan_cancer_q1",
          "prompt": "When you care deeply about a person, place, or situation, how does that care most naturally express itself?",
          "options": [
            {
              "text": "I create belonging: protect, feed, welcome, comfort, and make the bond feel safe and wanted.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become strategic about the relationship: I notice what is being exchanged, what is unspoken, what each person needs, and how the emotional situation must be negotiated.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I absorb it deeply: memories, atmosphere, family feeling, longing, and imagination become part of the way I carry the bond inside me.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly primary.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_cancer_q2",
          "prompt": "When something threatens your sense of emotional security, what is your most familiar response?",
          "options": [
            {
              "text": "I move closer to what I love and try to restore safety, warmth, and belonging around it.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I read the room, keep some things private, and work out the emotional leverage, negotiation, or exchange needed to protect my position.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I retreat inward, into memory, family feeling, imagination, or a protected emotional world until I can process what has saturated me.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "The response depends too much on context.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Leo",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Sun",
          "keywords": [
            "tested authority",
            "struggle",
            "endurance",
            "pride",
            "restraint",
            "contested sovereignty"
          ],
          "kernel": "Builds authority through resistance, endurance, restraint, and having sovereignty tested rather than simply granted."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "victory",
            "patronage",
            "confidence",
            "generosity",
            "recognition",
            "expansion"
          ],
          "kernel": "Expands authority through confidence, recognition, generosity, patronage, and a sense of honorable victory."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars",
          "keywords": [
            "valor",
            "performance",
            "defense",
            "competition",
            "persistence",
            "dramatic courage"
          ],
          "kernel": "Proves authority through performance, competition, defense, persistence, and visible acts of courage."
        }
      ],
      "questions": [
        {
          "id": "decan_leo_q1",
          "prompt": "When you find yourself in a visible role, what tends to define the experience for you?",
          "options": [
            {
              "text": "I feel that authority has to be earned. I become serious about proving that I can withstand resistance and carry the weight of the role.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I grow into the visibility. Recognition, encouragement, generosity, and helping others rise with me make me feel more capable and expansive.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I feel called to perform under pressure. Competition, advocacy, defense, or the need to demonstrate courage tends to bring out my strongest presence.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these clearly describes me.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_leo_q2",
          "prompt": "When your pride, authority, or creative work is challenged, what response is most familiar?",
          "options": [
            {
              "text": "I become more controlled and enduring. I want to prove that opposition cannot dislodge me.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I try to rise above the challenge through confidence, perspective, generosity, and a larger sense of what success can become.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I meet the challenge directly and visibly. I want to defend the work, compete well, and show courage through action.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It varies too much to choose one.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Virgo",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Mercury",
          "keywords": [
            "prudence",
            "analysis",
            "cultivation",
            "competence",
            "service",
            "discernment"
          ],
          "kernel": "Improves through analysis, discernment, preparation, cultivation, competence, and careful service."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Saturn",
          "keywords": [
            "refinement",
            "preservation",
            "gain",
            "restraint",
            "craftsmanship",
            "selective value"
          ],
          "kernel": "Refines by selecting what is worth preserving, editing excess, practicing restraint, and improving quality through craft."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Venus",
          "keywords": [
            "accounting",
            "completion",
            "articulation",
            "commerce",
            "classification",
            "practical intelligence"
          ],
          "kernel": "Completes by auditing, classifying, articulating, accounting, and translating complexity into usable form."
        }
      ],
      "questions": [
        {
          "id": "decan_virgo_q1",
          "prompt": "When you are handed something imperfect, what kind of improvement comes most naturally?",
          "options": [
            {
              "text": "I diagnose the problem and improve the method: analyze what is happening, prepare carefully, and make the process more competent.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I refine the thing itself: edit, preserve what is valuable, remove what is unnecessary, and improve its quality through careful selection.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I bring it to completion: organize the information, audit the details, classify what belongs where, and turn the work into a clear usable result.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "No one approach dominates.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_virgo_q2",
          "prompt": "What bothers you most when work is not yet right?",
          "options": [
            {
              "text": "The underlying method is inefficient, poorly prepared, or insufficiently thought through.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "The quality is uneven because no one has made the difficult choices about what should be kept, improved, or removed.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The loose ends are still loose: the records, categories, language, accounts, or final organization have not been properly closed.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "These frustrate me about equally.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Libra",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Venus",
          "keywords": [
            "mediation",
            "reciprocity",
            "peace-making",
            "responsiveness",
            "equilibrium",
            "social intelligence"
          ],
          "kernel": "Restores balance through responsiveness, reciprocity, mediation, social sensitivity, and immediate peace-making."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "judgment",
            "sorrow",
            "contract",
            "boundaries",
            "consequence",
            "structural fairness"
          ],
          "kernel": "Creates fairness through judgment, boundaries, contracts, accountability, and accepting the consequences of imbalance."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Mercury",
          "keywords": [
            "settlement",
            "counsel",
            "reconciliation",
            "law",
            "deliberation",
            "restorative balance"
          ],
          "kernel": "Seeks restorative settlement through counsel, deliberation, law, reasoned compromise, and reconciliation after conflict."
        }
      ],
      "questions": [
        {
          "id": "decan_libra_q1",
          "prompt": "When two people or sides are out of balance, what is your instinctive way of approaching the problem?",
          "options": [
            {
              "text": "I respond to the relationship itself: listen to both sides, restore reciprocity, and try to bring the emotional or social atmosphere back into balance.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I want the terms clarified: boundaries, obligations, consequences, and what a fair structure actually requires.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I want to deliberate toward a settlement: examine the arguments, advise, negotiate, and find terms that can genuinely resolve or repair the dispute.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these clearly comes first.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_libra_q2",
          "prompt": "What makes an agreement feel truly fair to you?",
          "options": [
            {
              "text": "Both sides feel seen and the relationship has regained genuine reciprocity rather than merely obeying a rule.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "The boundaries and responsibilities are explicit, enforceable, and able to withstand disappointment or conflict.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The agreement reflects thoughtful counsel and gives the conflict somewhere constructive to go, rather than simply stopping it.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I need all three equally.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Scorpio",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "severance",
            "crisis",
            "appetite",
            "struggle",
            "penetration",
            "emotional intensity"
          ],
          "kernel": "Meets intensity by penetrating the core, confronting crisis, struggling directly, and severing what cannot continue."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "pleasure",
            "regeneration",
            "loyalty",
            "revelation",
            "magnetism",
            "hidden vitality"
          ],
          "kernel": "Finds vitality through deep loyalty, revelation, magnetism, pleasure, and regeneration from hidden or intense experience."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Moon",
          "keywords": [
            "seduction",
            "fantasy",
            "attachment",
            "ambiguity",
            "intoxication",
            "emotional entanglement"
          ],
          "kernel": "Moves through intensity by attachment, attraction, fantasy, ambiguity, and emotionally entangling bonds."
        }
      ],
      "questions": [
        {
          "id": "decan_scorpio_q1",
          "prompt": "When you become deeply involved in something, what most often gives the involvement its intensity?",
          "options": [
            {
              "text": "I need to get to the core of it. Crisis, conflict, desire, or secrecy makes me more determined to penetrate the situation and decide what must continue or be cut away.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I feel more alive through depth itself. Loyalty, revelation, intimacy, pleasure, research, or recovering hidden vitality can become regenerative for me.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The bond develops its own gravity. Attraction, attachment, fantasy, uncertainty, or emotional ambiguity can pull me further into the experience than I expected.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is distinctly more familiar.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_scorpio_q2",
          "prompt": "When emotional stakes become very high, which pattern is most recognizable?",
          "options": [
            {
              "text": "I confront the underlying issue and, if necessary, make the hard cut rather than remain indefinitely in uncertainty.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I look for the hidden source of life in the situation: what can be revealed, renewed, trusted, or regenerated through going deeper.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I can remain bound to the complexity of the attachment itself, trying to understand what is desire, intuition, fantasy, loyalty, or entanglement.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the relationship or situation.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Sagittarius",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "speed",
            "travel",
            "publication",
            "inquiry",
            "persuasion",
            "rapid expansion"
          ],
          "kernel": "Expands by moving quickly, traveling, publishing, persuading, questioning, and distributing ideas."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Mars",
          "keywords": [
            "resilience",
            "vigilance",
            "defense",
            "instinct",
            "endurance",
            "emotional conviction"
          ],
          "kernel": "Holds meaning through resilience, vigilance, defense, instinct, endurance, and emotionally lived conviction."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Sun",
          "keywords": [
            "burden",
            "doctrine",
            "authority",
            "culmination",
            "obligation",
            "ideological rigidity"
          ],
          "kernel": "Turns belief into doctrine, authority, obligation, institutional weight, and the burden of carrying a conviction to culmination."
        }
      ],
      "questions": [
        {
          "id": "decan_sagittarius_q1",
          "prompt": "When you become convinced that an idea matters, what do you most naturally do with it?",
          "options": [
            {
              "text": "I move it outward quickly: travel with it, publish it, teach it, argue for it, or connect it to new people and places.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I stand by it. The belief becomes something I protect through adversity, and its truth is tested by whether I can keep living from it under pressure.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I formalize it. I become concerned with the doctrine, standard, authority, institution, or long-term obligation that could carry the belief beyond the moment.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly strongest.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_sagittarius_q2",
          "prompt": "When your worldview is challenged, which response sounds most familiar?",
          "options": [
            {
              "text": "I go looking for more information, more territory, or a better argument and expand the field rather than stay pinned down.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become vigilant and resilient. I hold the line around what experience has taught me and defend the conviction if necessary.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I become more serious about principles, obligations, and who has the authority to define or uphold the standard.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "My response is too situational to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Capricorn",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Saturn",
          "keywords": [
            "strategic growth",
            "adaptation",
            "management",
            "exchange",
            "pragmatism",
            "opportunity"
          ],
          "kernel": "Advances through strategic adaptation, management, exchange, pragmatism, and recognizing opportunity within constraints."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Venus",
          "keywords": [
            "labor",
            "construction",
            "ambition",
            "craft",
            "disciplined desire",
            "material contest"
          ],
          "kernel": "Advances through disciplined labor, construction, craft, ambition, material effort, and competitive building."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Mercury",
          "keywords": [
            "governance",
            "consolidation",
            "executive power",
            "status",
            "calculation",
            "material command"
          ],
          "kernel": "Advances through governance, executive calculation, consolidation, status, administration, and command of material systems."
        }
      ],
      "questions": [
        {
          "id": "decan_capricorn_q1",
          "prompt": "When you are pursuing a serious long-term goal, what kind of strategy feels most natural?",
          "options": [
            {
              "text": "I adapt strategically: read the opportunity, manage changing conditions, negotiate exchanges, and find the practical route that allows growth inside real constraints.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I build it through disciplined effort. I expect labor, craft, competition, and repetition to turn ambition into something material.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I organize the whole system. I want control of the decisions, resources, calculations, and structure needed to consolidate the result and make it durable.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I use all three too evenly to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_capricorn_q2",
          "prompt": "When a major objective becomes difficult, which response is most familiar?",
          "options": [
            {
              "text": "I change the strategy without abandoning the objective, looking for a more advantageous arrangement of constraints and opportunities.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I put more disciplined effort into the build itself and focus on the work, craft, and material obstacles between me and the result.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I move toward greater command: clarify authority, consolidate resources, calculate the consequences, and take responsibility for the larger structure.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the objective.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Aquarius",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "dissent",
            "alliance",
            "social cost",
            "estrangement",
            "reform",
            "unconventional values"
          ],
          "kernel": "Relates to groups through dissent, unconventional alliances, reform, social cost, estrangement, and values that resist conformity."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Mercury",
          "keywords": [
            "systems thinking",
            "strategy",
            "analysis",
            "earned progress",
            "networks",
            "technical skill"
          ],
          "kernel": "Relates to groups through systems thinking, strategy, networks, technical skill, analysis, and earned progress."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Venus",
          "keywords": [
            "adaptation",
            "unstable effort",
            "group emotion",
            "improvisation",
            "detachment",
            "shifting loyalties"
          ],
          "kernel": "Relates to groups through adaptation, improvisation, collective feeling, detachment, and changing allegiance as conditions shift."
        }
      ],
      "questions": [
        {
          "id": "decan_aquarius_q1",
          "prompt": "When you are part of a group or system, what role do you most naturally fall into?",
          "options": [
            {
              "text": "I notice where the shared values no longer make sense and tend to question the norm, form unusual alliances, or accept some social distance in order to reform it.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I map how the system works. I want to understand the network, improve the strategy, connect the right information, and make progress through technical or structural intelligence.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I read the changing atmosphere and adapt. I may move between engagement and detachment, improvising according to the group's needs without wanting to be emotionally captured by it.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these consistently describes my role.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_aquarius_q2",
          "prompt": "When a community or institution stops working well, what is your first instinct?",
          "options": [
            {
              "text": "Challenge the assumptions and values underneath it, even if that creates disagreement or distance from the group.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "Diagnose the system: trace the information, incentives, network, or process and design a smarter way for it to function.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "Adjust to the changing field, improvise with whoever is still participating, and stay flexible about where my allegiance or involvement belongs.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I do not have a clear default response.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Pisces",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "relinquishment",
            "exile",
            "boundary",
            "depletion",
            "contemplation",
            "spiritual severity"
          ],
          "kernel": "Meets dissolution through relinquishment, boundary, contemplation, conservation, exile, and learning what cannot be carried."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Moon",
          "keywords": [
            "fulfillment",
            "generosity",
            "imagination",
            "receptivity",
            "pleasure",
            "emotional abundance"
          ],
          "kernel": "Meets dissolution through receptivity, imagination, generosity, emotional abundance, fulfillment, and allowing experience to expand."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "completion",
            "release",
            "crisis",
            "sacrifice",
            "decisive ending",
            "renewal"
          ],
          "kernel": "Meets dissolution by decisively completing, releasing, sacrificing, severing, and carrying a cycle across its ending into renewal."
        }
      ],
      "questions": [
        {
          "id": "decan_pisces_q1",
          "prompt": "When something in your life is clearly dissolving or coming to an end, what is your most natural relationship to the transition?",
          "options": [
            {
              "text": "I withdraw, conserve energy, and accept that some things must be relinquished. Boundaries and contemplation help me understand what I can no longer carry.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I open to what the transition makes possible. Imagination, generosity, receptivity, beauty, or emotional connection help me experience the ending as part of a larger flow.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I need the ending to become real. I make the decisive release, sacrifice, confrontation, or final push that allows the old cycle to finish and something new to begin.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly more natural.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_pisces_q2",
          "prompt": "When you are overwhelmed by circumstances larger than your immediate control, what restores your sense of agency?",
          "options": [
            {
              "text": "Reducing what I am carrying, stepping back, protecting my boundaries, and becoming quiet enough to know what must be surrendered.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "Allowing more room for feeling, imagination, compassion, pleasure, or generosity until I can sense possibilities beyond the immediate pressure.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "Making a concrete ending or release: deciding what is over, cutting the tie, finishing the task, or acting through the crisis so the energy can move again.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "My response changes too much to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    }
  ]
}
```

<!-- END: ORBO_DECAN_LOCK_BANK -->

---

<!-- BEGIN: ORBO_SABIAN_LOCK_BANK -->

# Embedded Question Bank D — Sabian Lock

## Orbo Sabian Lock — Coded Fine-Tuning Question Bank

## What this file is

This is the **final degree-resolution tumbler** for Orbo's `rAsc` rectification pipeline.

```text
LUNAR LOCK
    ↓
RULER / ASCENDANT LOCK
    ↓
DECAN LOCK
    ↓
SABIAN LOCK
    ↓
rAsc degree
```

The key architectural choice is that Orbo does **not** need AI to write pairwise questions in real time.

Instead, every Sabian degree contains three pre-authored answer forms:

- `default` — the degree's recurring psychological operation
- `integrated` — how the operation tends to look when functioning well
- `stress` — how the same operation can distort, overextend, or become poorly regulated

Orbo inserts the answer forms for **2 or 3 neighboring candidate degrees** into one of three fixed prompts. The resulting question is therefore dynamic in selection but completely static in language.

The original Sabian image is retained as metadata. The user-facing question is built from the **concept behind the image**, not from asking whether the user identifies with the literal picture.

## Runtime example

If Scorpio II is already locked, Orbo knows the Ascendant lies from `10°00′–19°59′ Scorpio`, corresponding to **Sabian Scorpio 11–20**.

The first probe group is Scorpio 11 / 12 / 13.

```text
Which of these patterns feels most like your ordinary way of meeting life?

A. [Scorpio 11 default option] → Scorpio 11
B. [Scorpio 12 default option] → Scorpio 12
C. [Scorpio 13 default option] → Scorpio 13
D. None of these → move to next group
```

If B is chosen, Orbo asks the same three candidates using the integrated or stress forms. If Scorpio 12 wins twice, the Sabian tumbler locks.

## Source integrity

The supplied `Sabian JSON.txt` is not a single valid JSON document and has missing degree ranges. This bank parses the valid degree objects, supplements some missing/blank material from the earlier supplied `sabian-interpretations.md`, and explicitly marks the remaining externally verified symbol titles whose Orbo kernels had to be model-derived.

Nothing externally supplemented is labeled as though it came from the supplied JSON.

```json
{
  "id": "orbo_sabian_lock_v1",
  "version": "1.0.0",
  "purpose": "Final rAsc fine-tuning after rising sign and decan are locked.",
  "importantConvention": {
    "rule": "Any fraction of a zodiac degree uses the next ordinal Sabian degree.",
    "examples": [
      "0°00′–0°59′ of a sign → Sabian 1",
      "10°00′–10°59′ → Sabian 11",
      "29°00′–29°59′ → Sabian 30"
    ],
    "decanToSabian": {
      "1": [
        1,
        10
      ],
      "2": [
        11,
        20
      ],
      "3": [
        21,
        30
      ]
    }
  },
  "questionPrompts": {
    "default": "Which of these patterns feels most like your ordinary way of meeting life?",
    "integrated": "When you are functioning well, which of these patterns feels most recognizable?",
    "stress": "When you are strained, overextended, or under pressure, which of these patterns is most familiar?"
  },
  "runtime": {
    "input": "locked rising sign + locked decan",
    "candidateCount": 10,
    "groupStrategy": "Probe adjacent groups of 2–3 Sabian degrees. Each visible question contains candidate degree options plus a None option, never more than four choices.",
    "groupOrderWithinDecan": [
      "symbols 1–3 of the decan",
      "symbols 4–6 of the decan",
      "symbols 7–8 of the decan",
      "symbols 9–10 of the decan"
    ],
    "probe": "Ask the default prompt using optionText.default for each degree in the current group.",
    "onNone": "Advance to the next group.",
    "onCandidate": "Ask a confirmation question using optionText.integrated when sufficiently distinct; otherwise use optionText.stress.",
    "hardLock": "If probe and confirmation return the same Sabian degree, lock that degree.",
    "split": "If probe and confirmation return different degrees from the same group, preserve only those two degrees and ask one final two-way comparison using the remaining question type plus a Neither option.",
    "allNone": "Do not assign a Sabian degree by elimination. Mark Sabian unresolved and preserve the 10° decan window.",
    "output": "rAsc degree interval corresponding to the locked Sabian degree"
  },
  "sourceAudit": {
    "suppliedPrimaryParsedRecords": 323,
    "combinedSuppliedRecords": 338,
    "externalSymbolOnlySupplements": 22,
    "sourceTypeCounts": {
      "supplied_primary": 242,
      "external_symbol_model_derived": 22,
      "supplied_primary_plus_secondary": 81,
      "supplied_secondary": 15
    },
    "note": "The supplied Sabian JSON is concatenated and incomplete in several degree ranges. Earlier supplied sabian-interpretations.md fills some records. Remaining gaps are explicitly marked external_symbol_model_derived rather than silently attributed to the supplied files."
  },
  "comparisonGroups": [
    {
      "id": "aries_decan1_group1",
      "sign": "aries",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "aries_01",
        "aries_02",
        "aries_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan1_group2",
      "sign": "aries",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "aries_04",
        "aries_05",
        "aries_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan1_group3",
      "sign": "aries",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "aries_07",
        "aries_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan1_group4",
      "sign": "aries",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "aries_09",
        "aries_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan2_group1",
      "sign": "aries",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "aries_11",
        "aries_12",
        "aries_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan2_group2",
      "sign": "aries",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "aries_14",
        "aries_15",
        "aries_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan2_group3",
      "sign": "aries",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "aries_17",
        "aries_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan2_group4",
      "sign": "aries",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "aries_19",
        "aries_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan3_group1",
      "sign": "aries",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "aries_21",
        "aries_22",
        "aries_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan3_group2",
      "sign": "aries",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "aries_24",
        "aries_25",
        "aries_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan3_group3",
      "sign": "aries",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "aries_27",
        "aries_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aries_decan3_group4",
      "sign": "aries",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "aries_29",
        "aries_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan1_group1",
      "sign": "taurus",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "taurus_01",
        "taurus_02",
        "taurus_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan1_group2",
      "sign": "taurus",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "taurus_04",
        "taurus_05",
        "taurus_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan1_group3",
      "sign": "taurus",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "taurus_07",
        "taurus_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan1_group4",
      "sign": "taurus",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "taurus_09",
        "taurus_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan2_group1",
      "sign": "taurus",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "taurus_11",
        "taurus_12",
        "taurus_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan2_group2",
      "sign": "taurus",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "taurus_14",
        "taurus_15",
        "taurus_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan2_group3",
      "sign": "taurus",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "taurus_17",
        "taurus_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan2_group4",
      "sign": "taurus",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "taurus_19",
        "taurus_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan3_group1",
      "sign": "taurus",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "taurus_21",
        "taurus_22",
        "taurus_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan3_group2",
      "sign": "taurus",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "taurus_24",
        "taurus_25",
        "taurus_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan3_group3",
      "sign": "taurus",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "taurus_27",
        "taurus_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "taurus_decan3_group4",
      "sign": "taurus",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "taurus_29",
        "taurus_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan1_group1",
      "sign": "gemini",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "gemini_01",
        "gemini_02",
        "gemini_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan1_group2",
      "sign": "gemini",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "gemini_04",
        "gemini_05",
        "gemini_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan1_group3",
      "sign": "gemini",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "gemini_07",
        "gemini_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan1_group4",
      "sign": "gemini",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "gemini_09",
        "gemini_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan2_group1",
      "sign": "gemini",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "gemini_11",
        "gemini_12",
        "gemini_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan2_group2",
      "sign": "gemini",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "gemini_14",
        "gemini_15",
        "gemini_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan2_group3",
      "sign": "gemini",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "gemini_17",
        "gemini_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan2_group4",
      "sign": "gemini",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "gemini_19",
        "gemini_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan3_group1",
      "sign": "gemini",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "gemini_21",
        "gemini_22",
        "gemini_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan3_group2",
      "sign": "gemini",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "gemini_24",
        "gemini_25",
        "gemini_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan3_group3",
      "sign": "gemini",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "gemini_27",
        "gemini_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "gemini_decan3_group4",
      "sign": "gemini",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "gemini_29",
        "gemini_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan1_group1",
      "sign": "cancer",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "cancer_01",
        "cancer_02",
        "cancer_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan1_group2",
      "sign": "cancer",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "cancer_04",
        "cancer_05",
        "cancer_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan1_group3",
      "sign": "cancer",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "cancer_07",
        "cancer_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan1_group4",
      "sign": "cancer",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "cancer_09",
        "cancer_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan2_group1",
      "sign": "cancer",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "cancer_11",
        "cancer_12",
        "cancer_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan2_group2",
      "sign": "cancer",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "cancer_14",
        "cancer_15",
        "cancer_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan2_group3",
      "sign": "cancer",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "cancer_17",
        "cancer_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan2_group4",
      "sign": "cancer",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "cancer_19",
        "cancer_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan3_group1",
      "sign": "cancer",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "cancer_21",
        "cancer_22",
        "cancer_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan3_group2",
      "sign": "cancer",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "cancer_24",
        "cancer_25",
        "cancer_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan3_group3",
      "sign": "cancer",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "cancer_27",
        "cancer_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "cancer_decan3_group4",
      "sign": "cancer",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "cancer_29",
        "cancer_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan1_group1",
      "sign": "leo",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "leo_01",
        "leo_02",
        "leo_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan1_group2",
      "sign": "leo",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "leo_04",
        "leo_05",
        "leo_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan1_group3",
      "sign": "leo",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "leo_07",
        "leo_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan1_group4",
      "sign": "leo",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "leo_09",
        "leo_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan2_group1",
      "sign": "leo",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "leo_11",
        "leo_12",
        "leo_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan2_group2",
      "sign": "leo",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "leo_14",
        "leo_15",
        "leo_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan2_group3",
      "sign": "leo",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "leo_17",
        "leo_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan2_group4",
      "sign": "leo",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "leo_19",
        "leo_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan3_group1",
      "sign": "leo",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "leo_21",
        "leo_22",
        "leo_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan3_group2",
      "sign": "leo",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "leo_24",
        "leo_25",
        "leo_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan3_group3",
      "sign": "leo",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "leo_27",
        "leo_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "leo_decan3_group4",
      "sign": "leo",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "leo_29",
        "leo_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan1_group1",
      "sign": "virgo",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "virgo_01",
        "virgo_02",
        "virgo_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan1_group2",
      "sign": "virgo",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "virgo_04",
        "virgo_05",
        "virgo_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan1_group3",
      "sign": "virgo",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "virgo_07",
        "virgo_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan1_group4",
      "sign": "virgo",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "virgo_09",
        "virgo_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan2_group1",
      "sign": "virgo",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "virgo_11",
        "virgo_12",
        "virgo_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan2_group2",
      "sign": "virgo",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "virgo_14",
        "virgo_15",
        "virgo_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan2_group3",
      "sign": "virgo",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "virgo_17",
        "virgo_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan2_group4",
      "sign": "virgo",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "virgo_19",
        "virgo_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan3_group1",
      "sign": "virgo",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "virgo_21",
        "virgo_22",
        "virgo_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan3_group2",
      "sign": "virgo",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "virgo_24",
        "virgo_25",
        "virgo_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan3_group3",
      "sign": "virgo",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "virgo_27",
        "virgo_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "virgo_decan3_group4",
      "sign": "virgo",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "virgo_29",
        "virgo_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan1_group1",
      "sign": "libra",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "libra_01",
        "libra_02",
        "libra_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan1_group2",
      "sign": "libra",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "libra_04",
        "libra_05",
        "libra_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan1_group3",
      "sign": "libra",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "libra_07",
        "libra_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan1_group4",
      "sign": "libra",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "libra_09",
        "libra_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan2_group1",
      "sign": "libra",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "libra_11",
        "libra_12",
        "libra_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan2_group2",
      "sign": "libra",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "libra_14",
        "libra_15",
        "libra_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan2_group3",
      "sign": "libra",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "libra_17",
        "libra_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan2_group4",
      "sign": "libra",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "libra_19",
        "libra_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan3_group1",
      "sign": "libra",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "libra_21",
        "libra_22",
        "libra_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan3_group2",
      "sign": "libra",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "libra_24",
        "libra_25",
        "libra_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan3_group3",
      "sign": "libra",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "libra_27",
        "libra_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "libra_decan3_group4",
      "sign": "libra",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "libra_29",
        "libra_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan1_group1",
      "sign": "scorpio",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "scorpio_01",
        "scorpio_02",
        "scorpio_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan1_group2",
      "sign": "scorpio",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "scorpio_04",
        "scorpio_05",
        "scorpio_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan1_group3",
      "sign": "scorpio",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "scorpio_07",
        "scorpio_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan1_group4",
      "sign": "scorpio",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "scorpio_09",
        "scorpio_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan2_group1",
      "sign": "scorpio",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "scorpio_11",
        "scorpio_12",
        "scorpio_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan2_group2",
      "sign": "scorpio",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "scorpio_14",
        "scorpio_15",
        "scorpio_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan2_group3",
      "sign": "scorpio",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "scorpio_17",
        "scorpio_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan2_group4",
      "sign": "scorpio",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "scorpio_19",
        "scorpio_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan3_group1",
      "sign": "scorpio",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "scorpio_21",
        "scorpio_22",
        "scorpio_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan3_group2",
      "sign": "scorpio",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "scorpio_24",
        "scorpio_25",
        "scorpio_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan3_group3",
      "sign": "scorpio",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "scorpio_27",
        "scorpio_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "scorpio_decan3_group4",
      "sign": "scorpio",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "scorpio_29",
        "scorpio_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan1_group1",
      "sign": "sagittarius",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "sagittarius_01",
        "sagittarius_02",
        "sagittarius_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan1_group2",
      "sign": "sagittarius",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "sagittarius_04",
        "sagittarius_05",
        "sagittarius_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan1_group3",
      "sign": "sagittarius",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "sagittarius_07",
        "sagittarius_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan1_group4",
      "sign": "sagittarius",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "sagittarius_09",
        "sagittarius_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan2_group1",
      "sign": "sagittarius",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "sagittarius_11",
        "sagittarius_12",
        "sagittarius_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan2_group2",
      "sign": "sagittarius",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "sagittarius_14",
        "sagittarius_15",
        "sagittarius_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan2_group3",
      "sign": "sagittarius",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "sagittarius_17",
        "sagittarius_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan2_group4",
      "sign": "sagittarius",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "sagittarius_19",
        "sagittarius_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan3_group1",
      "sign": "sagittarius",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "sagittarius_21",
        "sagittarius_22",
        "sagittarius_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan3_group2",
      "sign": "sagittarius",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "sagittarius_24",
        "sagittarius_25",
        "sagittarius_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan3_group3",
      "sign": "sagittarius",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "sagittarius_27",
        "sagittarius_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "sagittarius_decan3_group4",
      "sign": "sagittarius",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "sagittarius_29",
        "sagittarius_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan1_group1",
      "sign": "capricorn",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "capricorn_01",
        "capricorn_02",
        "capricorn_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan1_group2",
      "sign": "capricorn",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "capricorn_04",
        "capricorn_05",
        "capricorn_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan1_group3",
      "sign": "capricorn",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "capricorn_07",
        "capricorn_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan1_group4",
      "sign": "capricorn",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "capricorn_09",
        "capricorn_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan2_group1",
      "sign": "capricorn",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "capricorn_11",
        "capricorn_12",
        "capricorn_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan2_group2",
      "sign": "capricorn",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "capricorn_14",
        "capricorn_15",
        "capricorn_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan2_group3",
      "sign": "capricorn",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "capricorn_17",
        "capricorn_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan2_group4",
      "sign": "capricorn",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "capricorn_19",
        "capricorn_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan3_group1",
      "sign": "capricorn",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "capricorn_21",
        "capricorn_22",
        "capricorn_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan3_group2",
      "sign": "capricorn",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "capricorn_24",
        "capricorn_25",
        "capricorn_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan3_group3",
      "sign": "capricorn",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "capricorn_27",
        "capricorn_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "capricorn_decan3_group4",
      "sign": "capricorn",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "capricorn_29",
        "capricorn_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan1_group1",
      "sign": "aquarius",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "aquarius_01",
        "aquarius_02",
        "aquarius_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan1_group2",
      "sign": "aquarius",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "aquarius_04",
        "aquarius_05",
        "aquarius_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan1_group3",
      "sign": "aquarius",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "aquarius_07",
        "aquarius_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan1_group4",
      "sign": "aquarius",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "aquarius_09",
        "aquarius_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan2_group1",
      "sign": "aquarius",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "aquarius_11",
        "aquarius_12",
        "aquarius_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan2_group2",
      "sign": "aquarius",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "aquarius_14",
        "aquarius_15",
        "aquarius_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan2_group3",
      "sign": "aquarius",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "aquarius_17",
        "aquarius_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan2_group4",
      "sign": "aquarius",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "aquarius_19",
        "aquarius_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan3_group1",
      "sign": "aquarius",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "aquarius_21",
        "aquarius_22",
        "aquarius_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan3_group2",
      "sign": "aquarius",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "aquarius_24",
        "aquarius_25",
        "aquarius_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan3_group3",
      "sign": "aquarius",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "aquarius_27",
        "aquarius_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "aquarius_decan3_group4",
      "sign": "aquarius",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "aquarius_29",
        "aquarius_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan1_group1",
      "sign": "pisces",
      "decan": 1,
      "sabianDegrees": [
        1,
        2,
        3
      ],
      "degreeRefs": [
        "pisces_01",
        "pisces_02",
        "pisces_03"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan1_group2",
      "sign": "pisces",
      "decan": 1,
      "sabianDegrees": [
        4,
        5,
        6
      ],
      "degreeRefs": [
        "pisces_04",
        "pisces_05",
        "pisces_06"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan1_group3",
      "sign": "pisces",
      "decan": 1,
      "sabianDegrees": [
        7,
        8
      ],
      "degreeRefs": [
        "pisces_07",
        "pisces_08"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan1_group4",
      "sign": "pisces",
      "decan": 1,
      "sabianDegrees": [
        9,
        10
      ],
      "degreeRefs": [
        "pisces_09",
        "pisces_10"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan2_group1",
      "sign": "pisces",
      "decan": 2,
      "sabianDegrees": [
        11,
        12,
        13
      ],
      "degreeRefs": [
        "pisces_11",
        "pisces_12",
        "pisces_13"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan2_group2",
      "sign": "pisces",
      "decan": 2,
      "sabianDegrees": [
        14,
        15,
        16
      ],
      "degreeRefs": [
        "pisces_14",
        "pisces_15",
        "pisces_16"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan2_group3",
      "sign": "pisces",
      "decan": 2,
      "sabianDegrees": [
        17,
        18
      ],
      "degreeRefs": [
        "pisces_17",
        "pisces_18"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan2_group4",
      "sign": "pisces",
      "decan": 2,
      "sabianDegrees": [
        19,
        20
      ],
      "degreeRefs": [
        "pisces_19",
        "pisces_20"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan3_group1",
      "sign": "pisces",
      "decan": 3,
      "sabianDegrees": [
        21,
        22,
        23
      ],
      "degreeRefs": [
        "pisces_21",
        "pisces_22",
        "pisces_23"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan3_group2",
      "sign": "pisces",
      "decan": 3,
      "sabianDegrees": [
        24,
        25,
        26
      ],
      "degreeRefs": [
        "pisces_24",
        "pisces_25",
        "pisces_26"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan3_group3",
      "sign": "pisces",
      "decan": 3,
      "sabianDegrees": [
        27,
        28
      ],
      "degreeRefs": [
        "pisces_27",
        "pisces_28"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    },
    {
      "id": "pisces_decan3_group4",
      "sign": "pisces",
      "decan": 3,
      "sabianDegrees": [
        29,
        30
      ],
      "degreeRefs": [
        "pisces_29",
        "pisces_30"
      ],
      "probeQuestionType": "default",
      "confirmationPreference": [
        "integrated",
        "stress"
      ],
      "noneOption": {
        "text": "None of these feels clearly more characteristic.",
        "returns": {
          "sabianDegree": null
        }
      }
    }
  ],
  "degrees": [
    {
      "id": "aries_01",
      "sign": "aries",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A WOMEN HAS RISEN FROM THE OCEAN; A SEAL EMBRACES HER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Potentiality of selfhood: the individual is emerging from the collective and realizes self for the first time.",
        "integrated": "an illimitability of experience of which anyone can take advantage under any or all circumstances.",
        "stress": "A failure to find a place in life because the self cannot separate itself from its own private obsessions."
      },
      "optionText": {
        "default": "Potentiality of selfhood: the individual is emerging from the collective and realizes self for the first time.",
        "integrated": "an illimitability of experience of which anyone can take advantage under any or all circumstances.",
        "stress": "A failure to find a place in life because the self cannot separate itself from its own private obsessions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_02",
      "sign": "aries",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A COMEDIAN IS ENTERTAINING A GROUP OF HIS FRIENDS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Objective understanding through extracting salient elements of being. Joy of life's discovery; or escape through humour.",
        "integrated": "the power of personality through a full and completely uninhibited self-expression.",
        "stress": "A neglect of common responsibility through idle diversions of interest."
      },
      "optionText": {
        "default": "Objective understanding through extracting salient elements of being. Joy of life's discovery; or escape through humour.",
        "integrated": "the power of personality through a full and completely uninhibited self-expression.",
        "stress": "A neglect of common responsibility through idle diversions of interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_03",
      "sign": "aries",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A MAN'S PROFILE SUGGESTS THE OUTLINES OF HIS COUNTRY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The individual self as an avatar of greater collective reality; as participant in the larger scheme of society or life.",
        "integrated": "man's capacity for giving full play to every ramification of the reality he has created for himself.",
        "stress": "An unimaginative conventionality which leaves him in bondage to every current stereotype of human relations."
      },
      "optionText": {
        "default": "The individual self as an avatar of greater collective reality; as participant in the larger scheme of society or life.",
        "integrated": "man's capacity for giving full play to every ramification of the reality he has created for himself.",
        "stress": "An unimaginative conventionality which leaves him in bondage to every current stereotype of human relations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_04",
      "sign": "aries",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "TWO LOVERS ARE STROLLING THROUGH A SECLUDED PARK LANE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fullness of conscious participation in life without responsibility. Closing of a cycle of activity, implying satiation.",
        "integrated": "an utterly naive assimilation of self into its world and a complete flow of all effort towards some proper end.",
        "stress": "The indiscriminate loss of the self's real assets in pure self-indulgence."
      },
      "optionText": {
        "default": "Fullness of conscious participation in life without responsibility. Closing of a cycle of activity, implying satiation.",
        "integrated": "an utterly naive assimilation of self into its world and a complete flow of all effort towards some proper end.",
        "stress": "The indiscriminate loss of the self's real assets in pure self-indulgence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_05",
      "sign": "aries",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A WHITE TRIANGLE,WITH GOLDEN WINGS ON ITS UPPER SIDES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Evolution of values in the sphere of inward self, but at a stage not yet substantiated. Eagerness for a spiritual goal.",
        "integrated": "the creative transformation of everything into an expression of enduring idea and a reflection of the real vision ahead.",
        "stress": "Blissful obliviousness to all normal or everyday considerations."
      },
      "optionText": {
        "default": "Evolution of values in the sphere of inward self, but at a stage not yet substantiated. Eagerness for a spiritual goal.",
        "integrated": "the creative transformation of everything into an expression of enduring idea and a reflection of the real vision ahead.",
        "stress": "Blissful obliviousness to all normal or everyday considerations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_06",
      "sign": "aries",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A BLACK SQUARE; ONE OF ITS SIDES IS ILLUMINED RED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Primal effort toward individual selfhood. First and uncontrolled interest in any given thing. Great inner restlessness.",
        "integrated": "the absolute unimpeachability of a genuine self-direction.",
        "stress": "Complete loss of self-efficacy in a surrender to frustrations."
      },
      "optionText": {
        "default": "Primal effort toward individual selfhood. First and uncontrolled interest in any given thing. Great inner restlessness.",
        "integrated": "the absolute unimpeachability of a genuine self-direction.",
        "stress": "Complete loss of self-efficacy in a surrender to frustrations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_07",
      "sign": "aries",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A MAN EXPRESSES HIMSELF AT ONCE IN TWO REALMS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conscious duality by which man first really differentiates himself from the animals. Versatility in work. Self-expansion.",
        "integrated": "unlimited versatility and a special gift for divorcing the things of issue from whatever lacks immediate pertinence.",
        "stress": "A tendency to defeat all self-competence in an unintelligent scattering of interest."
      },
      "optionText": {
        "default": "Conscious duality by which man first really differentiates himself from the animals. Versatility in work. Self-expansion.",
        "integrated": "unlimited versatility and a special gift for divorcing the things of issue from whatever lacks immediate pertinence.",
        "stress": "A tendency to defeat all self-competence in an unintelligent scattering of interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_08",
      "sign": "aries",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A WOMAN'S HAT, WITH STREAMERS BLOWN BY THE EAST WIND",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "First real attempt at self-exteriorization and embodiment in consciousness. Individualizing Eastern forces are suggested.",
        "integrated": "continual self-orientation to the nascent potentialities of all life and experience.",
        "stress": "A tendency to idle posing or an empty pretense of good will and interest."
      },
      "optionText": {
        "default": "First real attempt at self-exteriorization and embodiment in consciousness. Individualizing Eastern forces are suggested.",
        "integrated": "continual self-orientation to the nascent potentialities of all life and experience.",
        "stress": "A tendency to idle posing or an empty pretense of good will and interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_09",
      "sign": "aries",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A SEER GAZES WITH CONCENTRATION INTO A CRYSTAL SPHERE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Direction from within. Taking advantage of all factors in a given situation, and knowing when to make decisions. Assurance.",
        "integrated": "consummate insight in planning the course of events or organizing them in the light of immediate convenience.",
        "stress": "An idle curiosity and a surrender of all reality to the vagaries of the moment."
      },
      "optionText": {
        "default": "Direction from within. Taking advantage of all factors in a given situation, and knowing when to make decisions. Assurance.",
        "integrated": "consummate insight in planning the course of events or organizing them in the light of immediate convenience.",
        "stress": "An idle curiosity and a surrender of all reality to the vagaries of the moment."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_10",
      "sign": "aries",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A SCHOLAR CREATES NEW FORMS FOR ANCIENT SYMBOLS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Deep understanding, beyond normal means. Abstract seership, integrating the inner and the outer. Interpretative gift.",
        "integrated": "an exceptional capacity for putting every part of an individual's heritage to work.",
        "stress": "Witless distortion of values and twisted perspective in general events."
      },
      "optionText": {
        "default": "Deep understanding, beyond normal means. Abstract seership, integrating the inner and the outer. Interpretative gift.",
        "integrated": "an exceptional capacity for putting every part of an individual's heritage to work.",
        "stress": "Witless distortion of values and twisted perspective in general events."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_11",
      "sign": "aries",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "THE RULER OF A COUNTRY IS BEING OFFICIALLY INTRODUCED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fine stewardship of collective racial ideals. Good and necessary, but unimaginative conformity to standards. Idealization.",
        "integrated": "the self-sacrifice required of anybody who would become the creative representative of eternal value.",
        "stress": "An often well-meaning but usually destructive assertiveness or vain pretense."
      },
      "optionText": {
        "default": "Fine stewardship of collective racial ideals. Good and necessary, but unimaginative conformity to standards. Idealization.",
        "integrated": "the self-sacrifice required of anybody who would become the creative representative of eternal value.",
        "stress": "An often well-meaning but usually destructive assertiveness or vain pretense."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_12",
      "sign": "aries",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A FLOCK OF WHITE GEESE FLIES OVERHEAD ACROSS CLEAR SKIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A soul as yet socially immature and unadjusted; not come down to full and steady concrete expression. Self-discovery.",
        "integrated": "a completely naive independence or an ever-immediate capacity for rising above any giving involvement in experience.",
        "stress": "Thoughtless disinterest in anything of real value to the self."
      },
      "optionText": {
        "default": "A soul as yet socially immature and unadjusted; not come down to full and steady concrete expression. Self-discovery.",
        "integrated": "a completely naive independence or an ever-immediate capacity for rising above any giving involvement in experience.",
        "stress": "Thoughtless disinterest in anything of real value to the self."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_13",
      "sign": "aries",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A BOMB WHICH FAILED TO EXPLODE IS NOW SAFELY CONCEALED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Intangible fears of nascent selfhood: the creative stirring up of a new perspective and a new identity suddenly revealed.",
        "integrated": "a dramatic rejection of any accomplishment falling at all short of very deep or hallowed purpose.",
        "stress": "A waste of opportunity and a futile expenditure of self through vanity or petulance."
      },
      "optionText": {
        "default": "Intangible fears of nascent selfhood: the creative stirring up of a new perspective and a new identity suddenly revealed.",
        "integrated": "a dramatic rejection of any accomplishment falling at all short of very deep or hallowed purpose.",
        "stress": "A waste of opportunity and a futile expenditure of self through vanity or petulance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_14",
      "sign": "aries",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "A SERPENT ENCIRCLES A MAN AND WOMEN IN CLOSE EMBRACE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Power of higher wisdom manifest in the bi-polar nature. Protection by the higher genius of Self. Fulfillment in truth.",
        "integrated": "exceptional self-discipline in the continual acquisition of a very real understanding.",
        "stress": "A surrender to lower or transient impulses in every area of personal experience."
      },
      "optionText": {
        "default": "Power of higher wisdom manifest in the bi-polar nature. Protection by the higher genius of Self. Fulfillment in truth.",
        "integrated": "exceptional self-discipline in the continual acquisition of a very real understanding.",
        "stress": "A surrender to lower or transient impulses in every area of personal experience."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_15",
      "sign": "aries",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 1: ARIES 1-15: THE SPAN OF REALIZATION",
      "image": "INDIAN WEAVING A BASKET IN THE GOLDEN LIGHT OF SUNSET",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Full and conscious realization of selfhood, through the memory of all the powers acquired in the past. Retentiveness.",
        "integrated": "the quiet persistence of each proper act of self in the interest of its own genius.",
        "stress": "An acceptance of the dull routine of everyday as a species of transient security."
      },
      "optionText": {
        "default": "Full and conscious realization of selfhood, through the memory of all the powers acquired in the past. Retentiveness.",
        "integrated": "the quiet persistence of each proper act of self in the interest of its own genius.",
        "stress": "An acceptance of the dull routine of everyday as a species of transient security."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_16",
      "sign": "aries",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "BRIGHTLY CLAD BROWNIES, DANCING IN WARM DYING LIGHT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Relationship between conscious and unconscious sides of life. Invisible assistance often entailing obligation to outer forces.",
        "integrated": "simple good fortune together with unlimited opportunity as the direct fruitage of effort.",
        "stress": "Delusions of adequacy with a complete inability to act in real self-interest."
      },
      "optionText": {
        "default": "Relationship between conscious and unconscious sides of life. Invisible assistance often entailing obligation to outer forces.",
        "integrated": "simple good fortune together with unlimited opportunity as the direct fruitage of effort.",
        "stress": "Delusions of adequacy with a complete inability to act in real self-interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_17",
      "sign": "aries",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "TWO PRIM SPINSTERS ARE SITTING TOGETHER IN SILENCE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Poised and dispassionate outlook, involving either great dignity and integrity of self, or inability to live life fully.",
        "integrated": "an utter fidelity to self and all its special idealizations of its own capacities.",
        "stress": "An increasing exaltation of shallow interests and a witless pretense of distinction and great virtue."
      },
      "optionText": {
        "default": "Poised and dispassionate outlook, involving either great dignity and integrity of self, or inability to live life fully.",
        "integrated": "an utter fidelity to self and all its special idealizations of its own capacities.",
        "stress": "An increasing exaltation of shallow interests and a witless pretense of distinction and great virtue."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_18",
      "sign": "aries",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "AN EMPTY HAMMOCK IS HANGING BETWEEN TWO LOVELY TREES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Rest after some notable achievement. Capacity for consciousness after the act, for reaping fruits of activity. Detachment.",
        "integrated": "a thoroughgoing integrity established by the inner reconciliation of outer inharmonies.",
        "stress": "Inability to comprehend the conflicts of life and a consistent effort to dodge them."
      },
      "optionText": {
        "default": "Rest after some notable achievement. Capacity for consciousness after the act, for reaping fruits of activity. Detachment.",
        "integrated": "a thoroughgoing integrity established by the inner reconciliation of outer inharmonies.",
        "stress": "Inability to comprehend the conflicts of life and a consistent effort to dodge them."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_19",
      "sign": "aries",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A MAGIC CARPET HOVERING OVER AN UGLY INDUSTRIAL SUBURB",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity to transform everyday life by the power of creative significance; or escape in idle fancy.",
        "integrated": "full realization of the broad endowment which every man may make his own.",
        "stress": "Detachment from ordinary living and a scorn for its responsibilities."
      },
      "optionText": {
        "default": "Capacity to transform everyday life by the power of creative significance; or escape in idle fancy.",
        "integrated": "full realization of the broad endowment which every man may make his own.",
        "stress": "Detachment from ordinary living and a scorn for its responsibilities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_20",
      "sign": "aries",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A YOUNG GIRL FEEDING SWANS IN A PARK ON A WINTRY DAY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Participation of self in a life larger than any conception of selfhood. Protection, or the need for it.",
        "integrated": "a naive genius in the administration of both the powers of nature and the potentialities of selfhood.",
        "stress": "An overzealous and wasteful use of the self's resources in an effort to win approval by bread alone."
      },
      "optionText": {
        "default": "Participation of self in a life larger than any conception of selfhood. Protection, or the need for it.",
        "integrated": "a naive genius in the administration of both the powers of nature and the potentialities of selfhood.",
        "stress": "An overzealous and wasteful use of the self's resources in an effort to win approval by bread alone."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_21",
      "sign": "aries",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A PUGILIST, FLUSHED WITH STRENGTH, ENTERS THE RING",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Complete immolation of self in things purely physical. Intense self-assertiveness, physical and psychological.",
        "integrated": "a mobilization of the self's capacities in a concentrated attempt at self-establishment.",
        "stress": "Blind rebellion and a willingness to squander every resource on pseudo values."
      },
      "optionText": {
        "default": "Complete immolation of self in things purely physical. Intense self-assertiveness, physical and psychological.",
        "integrated": "a mobilization of the self's capacities in a concentrated attempt at self-establishment.",
        "stress": "Blind rebellion and a willingness to squander every resource on pseudo values."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_22",
      "sign": "aries",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "GATEWAY OPENING TO THE GARDEN OF ALL DESIRED THINGS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Joy and utter lack of inhibitions in objective life. Self-exaltation or bondage to the craving for happiness.",
        "integrated": "a high quickening to every possibility of individual discovery and experience.",
        "stress": "A tendency to while away the years in contemplating the things which might be claimed for the self rather than making any real effort to gain them."
      },
      "optionText": {
        "default": "Joy and utter lack of inhibitions in objective life. Self-exaltation or bondage to the craving for happiness.",
        "integrated": "a high quickening to every possibility of individual discovery and experience.",
        "stress": "A tendency to while away the years in contemplating the things which might be claimed for the self rather than making any real effort to gain them."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_23",
      "sign": "aries",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "WOMAN IN SUMMER DRESS CARRIES A PRECIOUS VEILED BURDEN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "First maturity of conscious life in any phase of experience. Sense of value and delicacy- or wastefulness. Innocence.",
        "integrated": "the unimpeachable integrity of the man whose fullness of life becomes a practical contribution to the circumstances in which he dwells.",
        "stress": "A disinclination to participate at all fairly in everyday living."
      },
      "optionText": {
        "default": "First maturity of conscious life in any phase of experience. Sense of value and delicacy- or wastefulness. Innocence.",
        "integrated": "the unimpeachable integrity of the man whose fullness of life becomes a practical contribution to the circumstances in which he dwells.",
        "stress": "A disinclination to participate at all fairly in everyday living."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_24",
      "sign": "aries",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A WINDOW CURTAIN BLOWN INWARD, SHAPED AS A CORNUCOPIA",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Good fortune attending upon the putting forth of effort. Rush of spiritual forces into the conscious ego. Protection.",
        "integrated": "an irrepressible genius for capturing the richer rewards of life and providing a wider distribution for the higher realities.",
        "stress": "A smug and petty self-importance in dispensing favours to others."
      },
      "optionText": {
        "default": "Good fortune attending upon the putting forth of effort. Rush of spiritual forces into the conscious ego. Protection.",
        "integrated": "an irrepressible genius for capturing the richer rewards of life and providing a wider distribution for the higher realities.",
        "stress": "A smug and petty self-importance in dispensing favours to others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_25",
      "sign": "aries",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A DOUBLE PROMISE REVEALS ITS INNER AND OUTER MEANINGS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fortuitous cooperation between inner and outer elements of being. A sense of responsibility to self or to society.",
        "integrated": "a facility of adjustment by which everything in a given situation may be brought into the fullest co-operation with everything else.",
        "stress": "Compromising insincerity and a lean to chicanery in all human relationships."
      },
      "optionText": {
        "default": "Fortuitous cooperation between inner and outer elements of being. A sense of responsibility to self or to society.",
        "integrated": "a facility of adjustment by which everything in a given situation may be brought into the fullest co-operation with everything else.",
        "stress": "Compromising insincerity and a lean to chicanery in all human relationships."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_26",
      "sign": "aries",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A MAN, BURSTING WITH THE WEALTH OF WHAT HE HAS TO GIVE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Supreme endowment, and inexhaustibilty of resources in all possible life realms. Sometimes obsession by potentiality.",
        "integrated": "an uncompromising independence and an inexhaustible drive toward self-discovery.",
        "stress": "An obsession by ideas of no practical worth."
      },
      "optionText": {
        "default": "Supreme endowment, and inexhaustibilty of resources in all possible life realms. Sometimes obsession by potentiality.",
        "integrated": "an uncompromising independence and an inexhaustible drive toward self-discovery.",
        "stress": "An obsession by ideas of no practical worth."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_27",
      "sign": "aries",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "THROUGH IMAGINATION, A LOST OPPORTUNITY IS REGAINED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Beginning of mental maturity and slow growth of the creative faculty. Revision of attitude. Mental house-cleaning.",
        "integrated": "the self's effective command of itself in any situation brought to immediate issue.",
        "stress": "Self-pity as a retreat from reality."
      },
      "optionText": {
        "default": "Beginning of mental maturity and slow growth of the creative faculty. Revision of attitude. Mental house-cleaning.",
        "integrated": "the self's effective command of itself in any situation brought to immediate issue.",
        "stress": "Self-pity as a retreat from reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_28",
      "sign": "aries",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A CROWD APPLAUDS A MAN WHO SHATTERED A DEAR ILLUSION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A new light is shed upon cherished ideas. Fearless, constructive and public facing of the facts of existence. Adjustment.",
        "integrated": "complete spiritual independence.",
        "stress": "A destructive assimilation of the self to every defeat or frustration of human kind."
      },
      "optionText": {
        "default": "A new light is shed upon cherished ideas. Fearless, constructive and public facing of the facts of existence. Adjustment.",
        "integrated": "complete spiritual independence.",
        "stress": "A destructive assimilation of the self to every defeat or frustration of human kind."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_29",
      "sign": "aries",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "A CELESTIAL CHOIR HAS ARISEN TO SING COSMIC HARMONIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "At-one-ment of consciousness with cosmic powers. Harmonic understanding and faith in the order and meaning of life.",
        "integrated": "a gift for the effective articulation or manifestation of those eternal realities.",
        "stress": "Self-deception and an acceptance of every fantasy which will flatter the ego."
      },
      "optionText": {
        "default": "At-one-ment of consciousness with cosmic powers. Harmonic understanding and faith in the order and meaning of life.",
        "integrated": "a gift for the effective articulation or manifestation of those eternal realities.",
        "stress": "Self-deception and an acceptance of every fantasy which will flatter the ego."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aries_30",
      "sign": "aries",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 2: ARIES 16-30: THE SPAN OF EXAMINATION",
      "image": "YOUNG DUCKLINGS DISPORT THEMSELVES MERRILY UPON A POND",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Essential social cooperativeness and appreciation of selfhood. Also a sense of inner restriction. Contentedness.",
        "integrated": "an accustomed competency or ease in dealing with immediate circumstances.",
        "stress": "A tendency toward provincialism or an acceptance of life with an altogether uncritical complacency."
      },
      "optionText": {
        "default": "Essential social cooperativeness and appreciation of selfhood. Also a sense of inner restriction. Contentedness.",
        "integrated": "an accustomed competency or ease in dealing with immediate circumstances.",
        "stress": "A tendency toward provincialism or an acceptance of life with an altogether uncritical complacency."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_01",
      "sign": "taurus",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A CLEAR MOUNTAIN STREAM FLOWS THROUGH A ROCKY DEFILE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Purity, excellence and immediate availability of the strength and power of being. Refreshment. Self-sustainment.",
        "integrated": "high achievement through an unswerving fidelity to some definite course of action.",
        "stress": "A tendency to waste the potentialities of being by aimless self-ramifications."
      },
      "optionText": {
        "default": "Purity, excellence and immediate availability of the strength and power of being. Refreshment. Self-sustainment.",
        "integrated": "high achievement through an unswerving fidelity to some definite course of action.",
        "stress": "A tendency to waste the potentialities of being by aimless self-ramifications."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_02",
      "sign": "taurus",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "AN ELECTRICAL STORM BRILLIANTLY ILLUMINES THE SKIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A sensing of the power and wonder of nature's forces. Complete transformation of the implication of all being. Awe.",
        "integrated": "a genius for dramatizing both the values at hand and the potentials ahead.",
        "stress": "Unreasoning timidity in all self-expression."
      },
      "optionText": {
        "default": "A sensing of the power and wonder of nature's forces. Complete transformation of the implication of all being. Awe.",
        "integrated": "a genius for dramatizing both the values at hand and the potentials ahead.",
        "stress": "Unreasoning timidity in all self-expression."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_03",
      "sign": "taurus",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "NATURAL TERRACES LEAD UP TO A LAWN OF CLOVER IN BLOOM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The invitation extended by all nature to man for self-expression. Inspirational possibilities in all experience. Hope.",
        "integrated": "a creative optimism brought to embrace every facet of everyday striving.",
        "stress": "An unwarranted self-indulgence and a disregard of all practical reality through a concern over the phantasmal and impossible."
      },
      "optionText": {
        "default": "The invitation extended by all nature to man for self-expression. Inspirational possibilities in all experience. Hope.",
        "integrated": "a creative optimism brought to embrace every facet of everyday striving.",
        "stress": "An unwarranted self-indulgence and a disregard of all practical reality through a concern over the phantasmal and impossible."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_04",
      "sign": "taurus",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "THE RAINBOW'S POT OF GOLD GLOWS AMIDST THE SPARKLING RAIN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Unlimited resources. Overflowing sense of power. Prodigality of spiritual love showered upon seekers for the highest.",
        "integrated": "an inner assurance which enables man to hold steady in every course of his choosing.",
        "stress": "A loss of all opportunity through futile expectation and an unintelligent wandering off in the quests of pure fancy."
      },
      "optionText": {
        "default": "Unlimited resources. Overflowing sense of power. Prodigality of spiritual love showered upon seekers for the highest.",
        "integrated": "an inner assurance which enables man to hold steady in every course of his choosing.",
        "stress": "A loss of all opportunity through futile expectation and an unintelligent wandering off in the quests of pure fancy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_05",
      "sign": "taurus",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A YOUNG WIDOW, TRANSFIGURED BY GRIEF, KNEELS AT A GRAVE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Revelation of meaning behind fleeting appearances. Restless quest for understanding. Birth from illusion into reality.",
        "integrated": "man's genius for personal aplomb or an effective transcendence of disappointment and delay in an ever-spiraling self-discovery.",
        "stress": "Surrender to frustration or descent to ineptitude."
      },
      "optionText": {
        "default": "Revelation of meaning behind fleeting appearances. Restless quest for understanding. Birth from illusion into reality.",
        "integrated": "man's genius for personal aplomb or an effective transcendence of disappointment and delay in an ever-spiraling self-discovery.",
        "stress": "Surrender to frustration or descent to ineptitude."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_06",
      "sign": "taurus",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A CANTILEVER BRIDGE IN CONSTRUCTION ACROSS A DEEP CANYON",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conquest of difficulties and limitations by intelligence. Directed effort toward solving a problem. Channel-ship.",
        "integrated": "the directness and the practical instinct by which personality achieves the ultimate benefit of its powers.",
        "stress": "A love of short cuts and every possible escape from the obligations of daily living."
      },
      "optionText": {
        "default": "Conquest of difficulties and limitations by intelligence. Directed effort toward solving a problem. Channel-ship.",
        "integrated": "the directness and the practical instinct by which personality achieves the ultimate benefit of its powers.",
        "stress": "A love of short cuts and every possible escape from the obligations of daily living."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_07",
      "sign": "taurus",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "WOMAN OF SAMARIA COMES TO DRAW WATER FROM THE WELL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The gaining of perspective by a return to ancient sources of being. Introspective approach to the collective unconscious.",
        "integrated": "absolute and wholly impersonal self-giving in the hope of an honest self-realization.",
        "stress": "A debasing and carefree dissoluteness accepted in compensation for the unattained and more enduring satisfactions."
      },
      "optionText": {
        "default": "The gaining of perspective by a return to ancient sources of being. Introspective approach to the collective unconscious.",
        "integrated": "absolute and wholly impersonal self-giving in the hope of an honest self-realization.",
        "stress": "A debasing and carefree dissoluteness accepted in compensation for the unattained and more enduring satisfactions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_08",
      "sign": "taurus",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A SLEIGH SPEEDS OVER GROUND AS YET UNCOVERED BY SNOW",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Independence of the will of the self from outer circumstances. Power to mould life upon the pioneer's prophetic vision.",
        "integrated": "a complete and effective alignment of self with whatever greater possibilities may remain unrealized in a given milieu.",
        "stress": "A cheerful tolerance of today's frustrations in the vague hope of a better tomorrow."
      },
      "optionText": {
        "default": "Independence of the will of the self from outer circumstances. Power to mould life upon the pioneer's prophetic vision.",
        "integrated": "a complete and effective alignment of self with whatever greater possibilities may remain unrealized in a given milieu.",
        "stress": "A cheerful tolerance of today's frustrations in the vague hope of a better tomorrow."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_09",
      "sign": "taurus",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A CHRISTMAS TREE LOADED WITH GIFTS AND LIGHTED CANDLES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A symbol of the promise which outer life offers to the pure in heart; of immortality through giving of self to the race.",
        "integrated": "man's achievement of complete self-satisfaction through a simple sharing of his potentials with his fellows.",
        "stress": "A desire to place people under obligation and to enjoy life's riches without payment in kind."
      },
      "optionText": {
        "default": "A symbol of the promise which outer life offers to the pure in heart; of immortality through giving of self to the race.",
        "integrated": "man's achievement of complete self-satisfaction through a simple sharing of his potentials with his fellows.",
        "stress": "A desire to place people under obligation and to enjoy life's riches without payment in kind."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_10",
      "sign": "taurus",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A PRETTY RED CROSS NURSE HURRIES ON AN ERRAND OF MERCY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Natural, unrestrained pouring of self in service to one's fellowmen. Self-expression through compassionate understanding.",
        "integrated": "a complete dedication of the self to the worthwhile and enduring projects through which it can lose all sense of separativeness.",
        "stress": "A superficial pretense of humanitarianism in order to gain transient importance."
      },
      "optionText": {
        "default": "Natural, unrestrained pouring of self in service to one's fellowmen. Self-expression through compassionate understanding.",
        "integrated": "a complete dedication of the self to the worthwhile and enduring projects through which it can lose all sense of separativeness.",
        "stress": "A superficial pretense of humanitarianism in order to gain transient importance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_11",
      "sign": "taurus",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A WOMAN WATERING ROWS OF FLOWERS IN FULL BLOOM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Man's and nature's creative partnership of service and beauty. Nature's rich response to man's care or lack thereof.",
        "integrated": "the high stewardship by which man builds everything around him into an enduring organism for his own fulfillment.",
        "stress": "Superficial satisfactions and a wasteful truckling to petty concerns."
      },
      "optionText": {
        "default": "Man's and nature's creative partnership of service and beauty. Nature's rich response to man's care or lack thereof.",
        "integrated": "the high stewardship by which man builds everything around him into an enduring organism for his own fulfillment.",
        "stress": "Superficial satisfactions and a wasteful truckling to petty concerns."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_12",
      "sign": "taurus",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "YOUNG COUPLE WALKS DOWN MAIN STREET, WINDOW-SHOPPING",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Inner interest in outer life which leads to whole-souled participation and achievement. Self-projection. Estimation.",
        "integrated": "high ability in presenting the immediate potentialities of human achievement and the consequent self-realizations.",
        "stress": "Self-depreciation and a dismissal of all really desirable things as beyond actual acquisition."
      },
      "optionText": {
        "default": "Inner interest in outer life which leads to whole-souled participation and achievement. Self-projection. Estimation.",
        "integrated": "high ability in presenting the immediate potentialities of human achievement and the consequent self-realizations.",
        "stress": "Self-depreciation and a dismissal of all really desirable things as beyond actual acquisition."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_13",
      "sign": "taurus",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "A PORTER IS CHEERFULLY BALANCING A MOUNTAIN OF BAGGAGE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Joy of effort put forth. Faith in the eventual results of a simple plunging ahead in things. Extreme of self-reliance.",
        "integrated": "an effective self-competence and virility of interest in normal living.",
        "stress": "A dissipation of selfhood and a depreciation of all ambition through the performance of drudgery without protest."
      },
      "optionText": {
        "default": "Joy of effort put forth. Faith in the eventual results of a simple plunging ahead in things. Extreme of self-reliance.",
        "integrated": "an effective self-competence and virility of interest in normal living.",
        "stress": "A dissipation of selfhood and a depreciation of all ambition through the performance of drudgery without protest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_14",
      "sign": "taurus",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "CHILDREN SPLASH IN RECEDING TIDE AMID GROPING SHELLFISH",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Need for a realization of life's unity in the multiplicity of its forms. Unconscious contact with higher stages of being.",
        "integrated": "the integrity of selfhood through its absoluteness of attention to its own business of continuing to be.",
        "stress": "Hopeless self-diffusion through unnecessary concern over divergent potentials of experience."
      },
      "optionText": {
        "default": "Need for a realization of life's unity in the multiplicity of its forms. Unconscious contact with higher stages of being.",
        "integrated": "the integrity of selfhood through its absoluteness of attention to its own business of continuing to be.",
        "stress": "Hopeless self-diffusion through unnecessary concern over divergent potentials of experience."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_15",
      "sign": "taurus",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 3: TAURUS 1-15: THE SPAN OF EXPERIENCE",
      "image": "MAN WITH RAKISH SILK HAT, MUFFLED, BRAVES THE STORM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Supremacy of conscious mind over brute nature forces. Full appreciation of outer difficulties. Great inner resources.",
        "integrated": "a superb aplomb arising from the constant rediscovery of greater powers latent in selfhood.",
        "stress": "Marked insensibility to all deeper impulses and complete surrender to superficial self-interest."
      },
      "optionText": {
        "default": "Supremacy of conscious mind over brute nature forces. Full appreciation of outer difficulties. Great inner resources.",
        "integrated": "a superb aplomb arising from the constant rediscovery of greater powers latent in selfhood.",
        "stress": "Marked insensibility to all deeper impulses and complete surrender to superficial self-interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_16",
      "sign": "taurus",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "",
      "image": "AN OLD PERSON ATTEMPTING TO REVEAL THE MYSTERIES",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Transmit hard-won understanding to people who may not yet be ready to receive it.",
        "integrated": "Patiently translate difficult knowledge into a form others can use.",
        "stress": "Become frustrated, obscure, or overly insistent when insight is not understood."
      },
      "optionText": {
        "default": "Transmit hard-won understanding to people who may not yet be ready to receive it.",
        "integrated": "Patiently translate difficult knowledge into a form others can use.",
        "stress": "Become frustrated, obscure, or overly insistent when insight is not understood."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_17",
      "sign": "taurus",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "",
      "image": "A BATTLE BETWEEN THE SWORDS AND THE TORCHES",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Choose between force and illumination when competing principles come into conflict.",
        "integrated": "Defend an ideal through clarity, courage, and persuasive conviction.",
        "stress": "Turn disagreement into a rigid battle in which winning matters more than understanding."
      },
      "optionText": {
        "default": "Choose between force and illumination when competing principles come into conflict.",
        "integrated": "Defend an ideal through clarity, courage, and persuasive conviction.",
        "stress": "Turn disagreement into a rigid battle in which winning matters more than understanding."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_18",
      "sign": "taurus",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "",
      "image": "A WOMAN HOLDING AN OLD BAG OUT OF A WINDOW",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Expose something stored, stale, or inherited to fresh air so that it can be renewed or released.",
        "integrated": "Refresh what has been carried too long by bringing it into the open.",
        "stress": "Cling to old burdens or repeatedly air them without actually changing anything."
      },
      "optionText": {
        "default": "Expose something stored, stale, or inherited to fresh air so that it can be renewed or released.",
        "integrated": "Refresh what has been carried too long by bringing it into the open.",
        "stress": "Cling to old burdens or repeatedly air them without actually changing anything."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_19",
      "sign": "taurus",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "",
      "image": "A NEWLY FORMED CONTINENT",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Allow genuinely new ground to emerge after a period of deep change.",
        "integrated": "Recognize and inhabit a new reality without forcing it to resemble the old one.",
        "stress": "Mistake instability or novelty for a foundation before it has actually formed."
      },
      "optionText": {
        "default": "Allow genuinely new ground to emerge after a period of deep change.",
        "integrated": "Recognize and inhabit a new reality without forcing it to resemble the old one.",
        "stress": "Mistake instability or novelty for a foundation before it has actually formed."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_20",
      "sign": "taurus",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "",
      "image": "WIND, CLOUDS AND HASTE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Respond quickly to rapidly shifting conditions without expecting the environment to remain fixed.",
        "integrated": "Adapt decisively when circumstances are moving faster than plans.",
        "stress": "Become scattered, impatient, or reactive because everything seems to be changing at once."
      },
      "optionText": {
        "default": "Respond quickly to rapidly shifting conditions without expecting the environment to remain fixed.",
        "integrated": "Adapt decisively when circumstances are moving faster than plans.",
        "stress": "Become scattered, impatient, or reactive because everything seems to be changing at once."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_21",
      "sign": "taurus",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "",
      "image": "A FINGER POINTING IN AN OPEN BOOK",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Locate the relevant principle, precedent, or piece of knowledge that gives a situation direction.",
        "integrated": "Use established knowledge precisely when it genuinely clarifies the present problem.",
        "stress": "Treat a rule, text, or authority as the answer when direct judgment is still required."
      },
      "optionText": {
        "default": "Locate the relevant principle, precedent, or piece of knowledge that gives a situation direction.",
        "integrated": "Use established knowledge precisely when it genuinely clarifies the present problem.",
        "stress": "Treat a rule, text, or authority as the answer when direct judgment is still required."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_22",
      "sign": "taurus",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "",
      "image": "A WHITE DOVE OVER TROUBLED WATERS",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Carry a message of peace, reassurance, or orientation across disturbed conditions.",
        "integrated": "Remain a stabilizing messenger when the surrounding situation is unsettled.",
        "stress": "Use soothing language to avoid confronting the actual source of conflict."
      },
      "optionText": {
        "default": "Carry a message of peace, reassurance, or orientation across disturbed conditions.",
        "integrated": "Remain a stabilizing messenger when the surrounding situation is unsettled.",
        "stress": "Use soothing language to avoid confronting the actual source of conflict."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_23",
      "sign": "taurus",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "",
      "image": "A JEWELRY SHOP",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Recognize, refine, and display concentrated forms of value.",
        "integrated": "Discern what is genuinely precious and present it with care and proportion.",
        "stress": "Confuse display, rarity, or price with actual worth."
      },
      "optionText": {
        "default": "Recognize, refine, and display concentrated forms of value.",
        "integrated": "Discern what is genuinely precious and present it with care and proportion.",
        "stress": "Confuse display, rarity, or price with actual worth."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_24",
      "sign": "taurus",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "",
      "image": "A MOUNTAIN SURVIVOR MARKED BY HARD EXPERIENCE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Preserve independence, toughness, and identity in conditions that demand self-reliance.",
        "integrated": "Hold to essential values while adapting skillfully to demanding terrain.",
        "stress": "Become defensive, isolated, or defined by opposition to the surrounding culture."
      },
      "optionText": {
        "default": "Preserve independence, toughness, and identity in conditions that demand self-reliance.",
        "integrated": "Hold to essential values while adapting skillfully to demanding terrain.",
        "stress": "Become defensive, isolated, or defined by opposition to the surrounding culture."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_25",
      "sign": "taurus",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "",
      "image": "A LARGE WELL-KEPT PUBLIC PARK",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Cultivate resources so private effort becomes a durable benefit shared by many.",
        "integrated": "Create order, beauty, and access that support a wider community.",
        "stress": "Over-manage shared space or value appearances more than living usefulness."
      },
      "optionText": {
        "default": "Cultivate resources so private effort becomes a durable benefit shared by many.",
        "integrated": "Create order, beauty, and access that support a wider community.",
        "stress": "Over-manage shared space or value appearances more than living usefulness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_26",
      "sign": "taurus",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "",
      "image": "A SERENADE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Use voice, art, charm, or carefully chosen expression to move another person's heart or attention.",
        "integrated": "Communicate desire sincerely and beautifully enough that another person can genuinely respond.",
        "stress": "Perform for effect, manipulate sentiment, or say what sounds persuasive without meaning it."
      },
      "optionText": {
        "default": "Use voice, art, charm, or carefully chosen expression to move another person's heart or attention.",
        "integrated": "Communicate desire sincerely and beautifully enough that another person can genuinely respond.",
        "stress": "Perform for effect, manipulate sentiment, or say what sounds persuasive without meaning it."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_27",
      "sign": "taurus",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "",
      "image": "A CRAFTSPERSON SELLING HANDMADE BEADS",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Translate personal craft, culture, or practical skill into an exchange with others.",
        "integrated": "Offer something made with care and let its value circulate through fair exchange.",
        "stress": "Reduce personal or inherited meaning to transaction alone, or undervalue one's own work."
      },
      "optionText": {
        "default": "Translate personal craft, culture, or practical skill into an exchange with others.",
        "integrated": "Offer something made with care and let its value circulate through fair exchange.",
        "stress": "Reduce personal or inherited meaning to transaction alone, or undervalue one's own work."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_28",
      "sign": "taurus",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "",
      "image": "A WOMAN PURSUED BY MATURE ROMANCE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Remain receptive when desire, relationship, or recognition arrives in an unexpected season of life.",
        "integrated": "Allow later or unforeseen opportunities for affection and connection to be genuinely considered.",
        "stress": "Let attention or longing override discernment simply because the opportunity feels rare or overdue."
      },
      "optionText": {
        "default": "Remain receptive when desire, relationship, or recognition arrives in an unexpected season of life.",
        "integrated": "Allow later or unforeseen opportunities for affection and connection to be genuinely considered.",
        "stress": "Let attention or longing override discernment simply because the opportunity feels rare or overdue."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_29",
      "sign": "taurus",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "",
      "image": "TWO COBBLERS WORKING AT A TABLE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Solve practical problems through complementary skill, repetition, and cooperation.",
        "integrated": "Work side by side with another person so craftsmanship improves through shared effort.",
        "stress": "Become stuck in routine, duplication, or small corrections without questioning the larger purpose."
      },
      "optionText": {
        "default": "Solve practical problems through complementary skill, repetition, and cooperation.",
        "integrated": "Work side by side with another person so craftsmanship improves through shared effort.",
        "stress": "Become stuck in routine, duplication, or small corrections without questioning the larger purpose."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "taurus_30",
      "sign": "taurus",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "",
      "image": "A PEACOCK PARADING ON AN ANCIENT LAWN",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Express beauty, distinction, and individuality within an inherited or established setting.",
        "integrated": "Let personal brilliance enliven tradition without needing to destroy the setting that holds it.",
        "stress": "Turn self-expression into vanity, status display, or dependence on admiration."
      },
      "optionText": {
        "default": "Express beauty, distinction, and individuality within an inherited or established setting.",
        "integrated": "Let personal brilliance enliven tradition without needing to destroy the setting that holds it.",
        "stress": "Turn self-expression into vanity, status display, or dependence on admiration."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_01",
      "sign": "gemini",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "GLASS-BOTTOMED BOAT DRIFTS OVER UNDER-SEA WONDERS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Depth of realization in a consciousness constantly in touch with the sources of life. Sensitiveness to collective images.",
        "integrated": "high competence in the estimation of life's potentialities.",
        "stress": "A lack of effective participation in reality because of continual indecisiveness."
      },
      "optionText": {
        "default": "Depth of realization in a consciousness constantly in touch with the sources of life. Sensitiveness to collective images.",
        "integrated": "high competence in the estimation of life's potentialities.",
        "stress": "A lack of effective participation in reality because of continual indecisiveness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_02",
      "sign": "gemini",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "SANTA CLAUS IS FURTIVELY FILLING CHRISTMAS STOCKINGS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The natural beneficence in any normal human heart. Alertness to the wishes of others; the often hidden pride of benefactors.",
        "integrated": "an unusual capacity for bringing man's possessions into a wide acceptance and for heightening every proper joy in worldly goods.",
        "stress": "A childish or clandestine futility in seeking any normal richness of living."
      },
      "optionText": {
        "default": "The natural beneficence in any normal human heart. Alertness to the wishes of others; the often hidden pride of benefactors.",
        "integrated": "an unusual capacity for bringing man's possessions into a wide acceptance and for heightening every proper joy in worldly goods.",
        "stress": "A childish or clandestine futility in seeking any normal richness of living."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_03",
      "sign": "gemini",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "LOUIS XIV'S COURT IN THE GARDENS OF THE TUILERIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A degree of genuine aristocracy and perfection of behaviour. Self-fulfillment in form and tradition. Collective strength.",
        "integrated": "the creative stability which enables each individual to participate in the full gamut of satisfactions developed and cherished by his fellows as well as himself.",
        "stress": "Complete selfishness and a joy in lording it over others."
      },
      "optionText": {
        "default": "A degree of genuine aristocracy and perfection of behaviour. Self-fulfillment in form and tradition. Collective strength.",
        "integrated": "the creative stability which enables each individual to participate in the full gamut of satisfactions developed and cherished by his fellows as well as himself.",
        "stress": "Complete selfishness and a joy in lording it over others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_04",
      "sign": "gemini",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "HOLLY AND MISTLETOE BRING CHRISTMAS SPIRIT TO A HOME",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Holiday spirit as an attempt to preserve for individuals the wealth and power of racial background. Social warmth.",
        "integrated": "a gift for fellow participation in every rewarding expression of individuality on all levels of human relationship.",
        "stress": "Complete obsession with superficialities."
      },
      "optionText": {
        "default": "Holiday spirit as an attempt to preserve for individuals the wealth and power of racial background. Social warmth.",
        "integrated": "a gift for fellow participation in every rewarding expression of individuality on all levels of human relationship.",
        "stress": "Complete obsession with superficialities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_05",
      "sign": "gemini",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "A RADICAL MAGAZINE DISPLAYS A SENSATIONAL FRONT PAGE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The compelling power of social propaganda. Exteriorization of emotional sympathy in organized reform. Efficiency.",
        "integrated": "personality in its highly effective capacity for putting its stamp on everything it touches.",
        "stress": "A perverse determination to quarrel with everybody."
      },
      "optionText": {
        "default": "The compelling power of social propaganda. Exteriorization of emotional sympathy in organized reform. Efficiency.",
        "integrated": "personality in its highly effective capacity for putting its stamp on everything it touches.",
        "stress": "A perverse determination to quarrel with everybody."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_06",
      "sign": "gemini",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "NIGHT WORKMEN DRILL FOR OIL AMIDST NOISE AND CONFUSION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Exaggerated activity in pursuit of material wealth. Capacity to drive oneself in view of future and speculative gains.",
        "integrated": "achievement through an exceptional concentration or specialization of effort.",
        "stress": "Long-range or foolish gambling and ill-considered self exploitation."
      },
      "optionText": {
        "default": "Exaggerated activity in pursuit of material wealth. Capacity to drive oneself in view of future and speculative gains.",
        "integrated": "achievement through an exceptional concentration or specialization of effort.",
        "stress": "Long-range or foolish gambling and ill-considered self exploitation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_07",
      "sign": "gemini",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "AN OLD WELL, FILLED WITH PURE WATER, SHADED BY TREES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Deep and mature relationship between man and the basic life-giving reality of his environment. Inner assurance; poise.",
        "integrated": "absolute self-reliance and uncompromising faithfulness.",
        "stress": "Insensibility and ineptness in all human contact."
      },
      "optionText": {
        "default": "Deep and mature relationship between man and the basic life-giving reality of his environment. Inner assurance; poise.",
        "integrated": "absolute self-reliance and uncompromising faithfulness.",
        "stress": "Insensibility and ineptness in all human contact."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_08",
      "sign": "gemini",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "AROUND A CLOSED-DOWN FACTORY STRIKERS MILL DEFIANTLY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A stirring of the collective, unconscious factors of being toward the repolarization of the conscious ego. Idle protest.",
        "integrated": "undeviating self-assertiveness and a refusal to accept any lesser in lieu of a greater.",
        "stress": "A dissatisfaction which surrenders rather than regrasps the self's potential."
      },
      "optionText": {
        "default": "A stirring of the collective, unconscious factors of being toward the repolarization of the conscious ego. Idle protest.",
        "integrated": "undeviating self-assertiveness and a refusal to accept any lesser in lieu of a greater.",
        "stress": "A dissatisfaction which surrenders rather than regrasps the self's potential."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_09",
      "sign": "gemini",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "A MEDIEVAL ARCHER, WITH BOW AND ARROWS, READY TO FIGHT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Superiority and ease based upon training. Sure marksmanship. Certain self-direction. Preparedness. Invisible help in trouble.",
        "integrated": "unlimited personal capacity for rising to the issue of the moment on any level of experience.",
        "stress": "Querulous overconfidence and quixotic notions."
      },
      "optionText": {
        "default": "Superiority and ease based upon training. Sure marksmanship. Certain self-direction. Preparedness. Invisible help in trouble.",
        "integrated": "unlimited personal capacity for rising to the issue of the moment on any level of experience.",
        "stress": "Querulous overconfidence and quixotic notions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_10",
      "sign": "gemini",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "AEROPLANE, AFTER A NOSE-DIVE, RIGHTS ITSELF GRACEFULLY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity to plunge into experience without surrendering one's principles or self-control. Self-expansion through sacrifice.",
        "integrated": "the highly advantageous reorientation of self through every issue.",
        "stress": "Defeat through disinclination to lift even a finger in decent self-interest."
      },
      "optionText": {
        "default": "Capacity to plunge into experience without surrendering one's principles or self-control. Self-expansion through sacrifice.",
        "integrated": "the highly advantageous reorientation of self through every issue.",
        "stress": "Defeat through disinclination to lift even a finger in decent self-interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_11",
      "sign": "gemini",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "NEWLY OPENED LANDS OFFER VIRGIN REALMS OF EXPERIENCE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "New vista of concrete, conscious development. Renewed and enlarged opportunities. Nature's call for the pioneer spirit.",
        "integrated": "effective mobilization of the self's practical resources for the role it must play in daily living.",
        "stress": "Self-delusion through sheer fantasy."
      },
      "optionText": {
        "default": "New vista of concrete, conscious development. Renewed and enlarged opportunities. Nature's call for the pioneer spirit.",
        "integrated": "effective mobilization of the self's practical resources for the role it must play in daily living.",
        "stress": "Self-delusion through sheer fantasy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_12",
      "sign": "gemini",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "A BLACK SLAVE-GIRL DEMANDS HER RIGHTS OF HER MISTRESS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The will to rise above racial conditioning and limitations; or a sense of the need to conform to things as they are.",
        "integrated": "a high gift for taking personal advantage of every new situation in experience.",
        "stress": "A joy in pure dissatisfaction."
      },
      "optionText": {
        "default": "The will to rise above racial conditioning and limitations; or a sense of the need to conform to things as they are.",
        "integrated": "a high gift for taking personal advantage of every new situation in experience.",
        "stress": "A joy in pure dissatisfaction."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_13",
      "sign": "gemini",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "WORLD-FAMOUS PIANIST BEGINS TO PLAY TO A HUGE AUDIENCE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Extreme exaltation of social standing. Reaching of climax in selfhood. Ghastly sense of emptiness at the end of the quest.",
        "integrated": "the creative assurance which contributes enduring overtones to human understanding.",
        "stress": "Self-defeat through a delight in momentary attention or superficial adulation."
      },
      "optionText": {
        "default": "Extreme exaltation of social standing. Reaching of climax in selfhood. Ghastly sense of emptiness at the end of the quest.",
        "integrated": "the creative assurance which contributes enduring overtones to human understanding.",
        "stress": "Self-defeat through a delight in momentary attention or superficial adulation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_14",
      "sign": "gemini",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "TWO PEOPLE, LIVING FAR APART, IN TELEPATHIC COMMUNICATION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conscious mastery of space-time limitations of ordinary existence. Realization of basic realities in all situations.",
        "integrated": "an exceptional capacity for achievement through the more organic relationships of personality.",
        "stress": "Attempted accomplishment through innuendo or underhanded means."
      },
      "optionText": {
        "default": "Conscious mastery of space-time limitations of ordinary existence. Realization of basic realities in all situations.",
        "integrated": "an exceptional capacity for achievement through the more organic relationships of personality.",
        "stress": "Attempted accomplishment through innuendo or underhanded means."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_15",
      "sign": "gemini",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 5: GEMINI 1-15: THE SPAN OF ZEAL",
      "image": "TWO DUTCH CHILDREN ARE STUDYING THEIR LESSONS TOGETHER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conscious approach to spiritual truth and underlying meanings. Open-mindedness. Clarity of thought along traditional lines.",
        "integrated": "a self-confidence of spirit by which man is able to establish himself advantageously at ease in any possible situation.",
        "stress": "Extreme provincialism and inability to communicate ideas of any moment."
      },
      "optionText": {
        "default": "Conscious approach to spiritual truth and underlying meanings. Open-mindedness. Clarity of thought along traditional lines.",
        "integrated": "a self-confidence of spirit by which man is able to establish himself advantageously at ease in any possible situation.",
        "stress": "Extreme provincialism and inability to communicate ideas of any moment."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_16",
      "sign": "gemini",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "WOMAN AGITATOR MAKES AN IMPASSIONED PLEA TO A CROWD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Rising of the human soul in demand for recognition by the outer nature of the needs of inner being. Self-assertion.",
        "integrated": "an unswerving determination to expand every potential of being and take part in every possible detail of world-wide reconstruction.",
        "stress": "A bias forever exalting itself."
      },
      "optionText": {
        "default": "Rising of the human soul in demand for recognition by the outer nature of the needs of inner being. Self-assertion.",
        "integrated": "an unswerving determination to expand every potential of being and take part in every possible detail of world-wide reconstruction.",
        "stress": "A bias forever exalting itself."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_17",
      "sign": "gemini",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "HEAD OF YOUTH CHANGES INTO THAT OF A MATURE THINKER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Progression from robust participation in outer things to a realization of deeper realities. Inborn wisdom. Steady growth.",
        "integrated": "the effective orientation of selfhood in an over-all vision.",
        "stress": "A defeat of accomplishment by a senseless clinging to the illusions of youth."
      },
      "optionText": {
        "default": "Progression from robust participation in outer things to a realization of deeper realities. Inborn wisdom. Steady growth.",
        "integrated": "the effective orientation of selfhood in an over-all vision.",
        "stress": "A defeat of accomplishment by a senseless clinging to the illusions of youth."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_18",
      "sign": "gemini",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "TWO CHINAMEN CONVERSE IN CHINESE IN AN OCCIDENTAL CROWD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Alienness, but also independence from environment. Conscious self-sustainment in spite of all conditions. Individualization.",
        "integrated": "the effective mobilization of self and others for life's more specialized objectives.",
        "stress": "A thorough dissipation of selfhood through alien relationships."
      },
      "optionText": {
        "default": "Alienness, but also independence from environment. Conscious self-sustainment in spite of all conditions. Individualization.",
        "integrated": "the effective mobilization of self and others for life's more specialized objectives.",
        "stress": "A thorough dissipation of selfhood through alien relationships."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_19",
      "sign": "gemini",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "LARGE ARCHAIC VOLUME ON DISPLAY IN A MUSEUM'S ARCHIVES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Reserve of collective knowledge and wisdom beyond true individual self-expression. Deference to past experience.",
        "integrated": "a special capacity for the recovery of prior advantages or the effective disentanglement of present involvements.",
        "stress": "A slavish worship of tradition and authority."
      },
      "optionText": {
        "default": "Reserve of collective knowledge and wisdom beyond true individual self-expression. Deference to past experience.",
        "integrated": "a special capacity for the recovery of prior advantages or the effective disentanglement of present involvements.",
        "stress": "A slavish worship of tradition and authority."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_20",
      "sign": "gemini",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "A SELF-SERVICE RESTAURANT DISPLAYS AN ABUNDANCE OF FOOD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Prodigal distribution of life-resources. Inner wealth. Satiation, or discriminative use of natural energies. Rich supply.",
        "integrated": "a fullness of contribution and an effectiveness of requisition in all personal relationships.",
        "stress": "A chronic inability to make decisions or a hopelessly dilettante spirit."
      },
      "optionText": {
        "default": "Prodigal distribution of life-resources. Inner wealth. Satiation, or discriminative use of natural energies. Rich supply.",
        "integrated": "a fullness of contribution and an effectiveness of requisition in all personal relationships.",
        "stress": "A chronic inability to make decisions or a hopelessly dilettante spirit."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_21",
      "sign": "gemini",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "A LABOUR DEMONSTRATION THRONGS A LARGE CITY SQUARE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The impetuous onslaught of natural instincts within the field of the conscious ego. Blind struggle. Compelling power of fate.",
        "integrated": "a consistent courage in attacking major problems at any cost of minor well-being or inconvenience.",
        "stress": "Futile ill-will and bluster."
      },
      "optionText": {
        "default": "The impetuous onslaught of natural instincts within the field of the conscious ego. Blind struggle. Compelling power of fate.",
        "integrated": "a consistent courage in attacking major problems at any cost of minor well-being or inconvenience.",
        "stress": "Futile ill-will and bluster."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_22",
      "sign": "gemini",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "DANCING COUPLES CROWD THE BARN IN A HARVEST FESTIVAL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Richness of life in associations based on natural instincts. Warmth of simple living. Normal fulfillment of self.",
        "integrated": "an ability to plunge into major and rewarding experiences without the least self-reservation.",
        "stress": "A dependence on superficialities for self-satisfaction and on petty indulgences for self-assurance."
      },
      "optionText": {
        "default": "Richness of life in associations based on natural instincts. Warmth of simple living. Normal fulfillment of self.",
        "integrated": "an ability to plunge into major and rewarding experiences without the least self-reservation.",
        "stress": "A dependence on superficialities for self-satisfaction and on petty indulgences for self-assurance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_23",
      "sign": "gemini",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "THREE FLEDGLINGS LOOK OUT PROUDLY FROM THEIR HIGH NEST",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conscious self-establishment in the soul and its threefold nature. Innate self-confidence. Superiority of real being.",
        "integrated": "an unconditioned creativity exalted to the point of complete freedom from any immediate involvement.",
        "stress": "Psychological witlessness and a false sense of release from responsibility."
      },
      "optionText": {
        "default": "Conscious self-establishment in the soul and its threefold nature. Innate self-confidence. Superiority of real being.",
        "integrated": "an unconditioned creativity exalted to the point of complete freedom from any immediate involvement.",
        "stress": "Psychological witlessness and a false sense of release from responsibility."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_24",
      "sign": "gemini",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "CAREFREE CHILDREN SKATE OVER A SMOOTHLY FROZEN POND",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity to use every opportunity, even in the harshest environment, for self-recreation or relaxation. Appreciation.",
        "integrated": "a soul-satisfying experiment in the infinitely varying channels of possible self-discovery.",
        "stress": "A tendency to live for the momentary excitement."
      },
      "optionText": {
        "default": "Capacity to use every opportunity, even in the harshest environment, for self-recreation or relaxation. Appreciation.",
        "integrated": "a soul-satisfying experiment in the infinitely varying channels of possible self-discovery.",
        "stress": "A tendency to live for the momentary excitement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_25",
      "sign": "gemini",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "A GARDENER TRIMS BEAUTIFUL PALM TREES WITH UTMOST CARE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity in man to control his environment and the impulses of his most intense nature. Active care for possessions.",
        "integrated": "an exceptional gift for bringing all things to an effective service in some special aspect of overall achievement.",
        "stress": "An empty display of trivial excellencies."
      },
      "optionText": {
        "default": "Capacity in man to control his environment and the impulses of his most intense nature. Active care for possessions.",
        "integrated": "an exceptional gift for bringing all things to an effective service in some special aspect of overall achievement.",
        "stress": "An empty display of trivial excellencies."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_26",
      "sign": "gemini",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "FROST-COVERED TREES, LACE-LIKE, AGAINST WINTER SKIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Creative bestowal of significance upon all things. Transforming power of beauty. Keen appreciation of natural processes.",
        "integrated": "the creative transformation by which older cycles give way to newer ones.",
        "stress": "A reduction of the useless to a total annihilation."
      },
      "optionText": {
        "default": "Creative bestowal of significance upon all things. Transforming power of beauty. Keen appreciation of natural processes.",
        "integrated": "the creative transformation by which older cycles give way to newer ones.",
        "stress": "A reduction of the useless to a total annihilation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_27",
      "sign": "gemini",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "YOUNG GYPSY EMERGING FROM THE WOODS GAZES AT FAR CITIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Growth of consciousness from the instinctual to the intellectual. Anticipation and mounting self-confidence. Deep longing.",
        "integrated": "self-release through a joy in the accomplishments of the moment.",
        "stress": "Complete disinclination to enter into ordinary relationships."
      },
      "optionText": {
        "default": "Growth of consciousness from the instinctual to the intellectual. Anticipation and mounting self-confidence. Deep longing.",
        "integrated": "self-release through a joy in the accomplishments of the moment.",
        "stress": "Complete disinclination to enter into ordinary relationships."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_28",
      "sign": "gemini",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "BANKRUPTCY GRANTED TO HIM, A MAN LEAVES THE COURT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Release of self from collective pressure impossible to bear. Determination to regather forces for a new attempt. Protection.",
        "integrated": "an effective and overall resourcefulness in even the worst situations.",
        "stress": "A willingness to dodge every responsibility and betray the very core of self."
      },
      "optionText": {
        "default": "Release of self from collective pressure impossible to bear. Determination to regather forces for a new attempt. Protection.",
        "integrated": "an effective and overall resourcefulness in even the worst situations.",
        "stress": "A willingness to dodge every responsibility and betray the very core of self."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_29",
      "sign": "gemini",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "THE FIRST MOCKING BIRD OF SPRING SINGS FROM THE TREE TOP",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Recapitulation of past opportunities at the threshold of a new cycle of experience. Realization of new potentialities.",
        "integrated": "consistent stimulation to others in all human affairs.",
        "stress": "Annoying self-assertiveness."
      },
      "optionText": {
        "default": "Recapitulation of past opportunities at the threshold of a new cycle of experience. Realization of new potentialities.",
        "integrated": "consistent stimulation to others in all human affairs.",
        "stress": "Annoying self-assertiveness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "gemini_30",
      "sign": "gemini",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 6: GEMINI 16-30: THE SPAN OF RESTLESSNESS",
      "image": "A PARADE OF BATHING BEAUTIES BEFORE LARGE BEACH CROWDS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Use of individual vanity in raising racial standards. Examination of intellectual values for use in the soul life.",
        "integrated": "a special capacity for bringing familiar desires and interests to an enduring representation of worthiness.",
        "stress": "Regression to childish vanities."
      },
      "optionText": {
        "default": "Use of individual vanity in raising racial standards. Examination of intellectual values for use in the soul life.",
        "integrated": "a special capacity for bringing familiar desires and interests to an enduring representation of worthiness.",
        "stress": "Regression to childish vanities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_01",
      "sign": "cancer",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "SAILOR READY TO HOIST A NEW FLAG TO REPLACE OLD ONE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The nascent desire to align oneself with a larger and more significant life trend. Compelling decision. Repolarization.",
        "integrated": "a gift for highly profitable adjustment in every developing relationship with others.",
        "stress": "Vacillation if not complete instability."
      },
      "optionText": {
        "default": "The nascent desire to align oneself with a larger and more significant life trend. Compelling decision. Repolarization.",
        "integrated": "a gift for highly profitable adjustment in every developing relationship with others.",
        "stress": "Vacillation if not complete instability."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_02",
      "sign": "cancer",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A MAN ON A MAGIC CARPET OBSERVES VAST VISTAS BELOW HIM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Broadening of perspective. Supremacy of intelligence over circumstances. Conscientiousness. Objective self-control.",
        "integrated": "an exceptional spread of comprehension and a continual self-orientation of understanding.",
        "stress": "A flighty transcendence or an impatience with all immediate or down-to-earth considerations."
      },
      "optionText": {
        "default": "Broadening of perspective. Supremacy of intelligence over circumstances. Conscientiousness. Objective self-control.",
        "integrated": "an exceptional spread of comprehension and a continual self-orientation of understanding.",
        "stress": "A flighty transcendence or an impatience with all immediate or down-to-earth considerations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_03",
      "sign": "cancer",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "AN ARCTIC EXPLORER LEADS A REINDEER THROUGH ICY CANYONS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The pioneering, trail-blazing instinct urging man to get out beyond all things. Plunge into virgin possibilities of life.",
        "integrated": "unlimited self-reliance in and through every possible phase of self-expression.",
        "stress": "Self-imposed handicaps and a needless acceptance of everyday restrictions."
      },
      "optionText": {
        "default": "The pioneering, trail-blazing instinct urging man to get out beyond all things. Plunge into virgin possibilities of life.",
        "integrated": "unlimited self-reliance in and through every possible phase of self-expression.",
        "stress": "Self-imposed handicaps and a needless acceptance of everyday restrictions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_04",
      "sign": "cancer",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A HUNGRY CAT ARGUES WITH A MOUSE, BEFORE EATING HER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The urge to self-justification through intellectual sophistry or social-ethical considerations. Sense of self-righteousness.",
        "integrated": "a gift for persuading others to accept the motives of self and to co-operate with its end.",
        "stress": "Interminable quarrelling with the nature of things."
      },
      "optionText": {
        "default": "The urge to self-justification through intellectual sophistry or social-ethical considerations. Sense of self-righteousness.",
        "integrated": "a gift for persuading others to accept the motives of self and to co-operate with its end.",
        "stress": "Interminable quarrelling with the nature of things."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_05",
      "sign": "cancer",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "AUTOMOBILIST, RACING MADLY WITH A FAST TRAIN, IS KILLED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Individual man is brought to account for his obligations to society. Curbed recklessness. Tragic escape from emptiness.",
        "integrated": "a special genius for a creative reorganization of all experience.",
        "stress": "An insensitive recklessness."
      },
      "optionText": {
        "default": "Individual man is brought to account for his obligations to society. Curbed recklessness. Tragic escape from emptiness.",
        "integrated": "a special genius for a creative reorganization of all experience.",
        "stress": "An insensitive recklessness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_06",
      "sign": "cancer",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "INNUMERABLE BIRDS ARE BUSY FEATHERING THEIR NESTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Instinctive preparation for mature and full expression of the self. Subconscious planning or dreaming of idle dreams.",
        "integrated": "high intelligence and skill in enlisting the potentials of experience for the service of self.",
        "stress": "Unnecessary concern over everyday security."
      },
      "optionText": {
        "default": "Instinctive preparation for mature and full expression of the self. Subconscious planning or dreaming of idle dreams.",
        "integrated": "high intelligence and skill in enlisting the potentials of experience for the service of self.",
        "stress": "Unnecessary concern over everyday security."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_07",
      "sign": "cancer",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "IN A MOONLIT FAIRY GLADE TWO LITTLE ELVES ARE DANCING",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Man's recognition of the elusive play of underlying forces in nature. Cooperation with the invisible. Unusual good luck.",
        "integrated": "a transforming sensitivity or a healing imagination.",
        "stress": "A senseless retreat to make-believe."
      },
      "optionText": {
        "default": "Man's recognition of the elusive play of underlying forces in nature. Cooperation with the invisible. Unusual good luck.",
        "integrated": "a transforming sensitivity or a healing imagination.",
        "stress": "A senseless retreat to make-believe."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_08",
      "sign": "cancer",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "RABBITS IN FAULTLESS HUMAN ATTIRE PARADE WITH DIGNITY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Reaching out to participation in a higher order through imitative behaviour. Willingness to grow; also self-exploitation.",
        "integrated": "unlimited assurance in any projection of self into a superior dimension of reality.",
        "stress": "An ingenuous substitution of affirmation for accomplishment."
      },
      "optionText": {
        "default": "Reaching out to participation in a higher order through imitative behaviour. Willingness to grow; also self-exploitation.",
        "integrated": "unlimited assurance in any projection of self into a superior dimension of reality.",
        "stress": "An ingenuous substitution of affirmation for accomplishment."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_09",
      "sign": "cancer",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "NAKED LITTLE MISS LEANS OVER A POND TO CATCH A GOLD FISH",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "First curiosity of being; innocent reaching out for understanding. Untiring eagerness. Unsocial or infantile cravings.",
        "integrated": "an ingratiating and irresistible capacity for self-expression.",
        "stress": "Continual indiscretion as a bar to any appreciable achievement."
      },
      "optionText": {
        "default": "First curiosity of being; innocent reaching out for understanding. Untiring eagerness. Unsocial or infantile cravings.",
        "integrated": "an ingratiating and irresistible capacity for self-expression.",
        "stress": "Continual indiscretion as a bar to any appreciable achievement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_10",
      "sign": "cancer",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A WONDERFUL DIAMOND IS BEING CUT TO A PERFECT SHAPE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Spiritual fulfilment or the acme of civilized being. Actualization of potentialities and outpressing of real selfhood.",
        "integrated": "an effective gift for dramatizing the potentialities of everything at hand.",
        "stress": "A futile lean on purely static merit."
      },
      "optionText": {
        "default": "Spiritual fulfilment or the acme of civilized being. Actualization of potentialities and outpressing of real selfhood.",
        "integrated": "an effective gift for dramatizing the potentialities of everything at hand.",
        "stress": "A futile lean on purely static merit."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_11",
      "sign": "cancer",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A CLOWN CARICATURES MERRILY ALL KINDS OF HUMAN TRAITS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Sharp discrimination and understanding of human nature. The light touch of masterful living; self-control; or frivolity.",
        "integrated": "effective sharpening of an individual's dominant or everyday impact on others.",
        "stress": "A loss of personal influence through aimless self-exploitation."
      },
      "optionText": {
        "default": "Sharp discrimination and understanding of human nature. The light touch of masterful living; self-control; or frivolity.",
        "integrated": "effective sharpening of an individual's dominant or everyday impact on others.",
        "stress": "A loss of personal influence through aimless self-exploitation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_12",
      "sign": "cancer",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A CHINESE WOMAN NURSING A BABY HALOED BY DIVINE LIGHT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The promise to all men that God may take birth within their souls. Personality integration. Illumination; or frustration.",
        "integrated": "a gift for bringing the more Godlike resources or superior powers of self to a point of real community service.",
        "stress": "Completely unreasonable demands for recognition."
      },
      "optionText": {
        "default": "The promise to all men that God may take birth within their souls. Personality integration. Illumination; or frustration.",
        "integrated": "a gift for bringing the more Godlike resources or superior powers of self to a point of real community service.",
        "stress": "Completely unreasonable demands for recognition."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_13",
      "sign": "cancer",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "A HAND WITH PROMINENT THUMB IS HELD OUT RECEPTIVELY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Strong, active and self-certain will, or persistent yet blind plunging ahead into reality. Freedom from soft illusions.",
        "integrated": "exceptional steadiness and a high sense of self-responsibility in every issue of the moment.",
        "stress": "Unnecessary aggressiveness and a self-defeating short-sightedness."
      },
      "optionText": {
        "default": "Strong, active and self-certain will, or persistent yet blind plunging ahead into reality. Freedom from soft illusions.",
        "integrated": "exceptional steadiness and a high sense of self-responsibility in every issue of the moment.",
        "stress": "Unnecessary aggressiveness and a self-defeating short-sightedness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_14",
      "sign": "cancer",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "AN OLD MAN, ALONE, FACES THE DARKNESS IN THE NORTHEAST",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fearlessness; and noble, self-perpetuating strength arising from knowledge. Courage in the facing of spiritual problems.",
        "integrated": "a highly effective enlistment of deeper and hidden elements of life for some momentary end.",
        "stress": "Lack of purpose and utter chaos in understanding."
      },
      "optionText": {
        "default": "Fearlessness; and noble, self-perpetuating strength arising from knowledge. Courage in the facing of spiritual problems.",
        "integrated": "a highly effective enlistment of deeper and hidden elements of life for some momentary end.",
        "stress": "Lack of purpose and utter chaos in understanding."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_15",
      "sign": "cancer",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 7: CANCER 1-15: THE SPAN OF EXPANSION",
      "image": "MERRY AND SLUGGISH PEOPLE RESTING AFTER A HUGE FEAST",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A turning to superficial things for self-strengthening. Self-indulgence in sensations. Unintelligent satiation; dullness.",
        "integrated": "an effective and smooth demonstration of human competence.",
        "stress": "A self-disintegrating surrender to appetite."
      },
      "optionText": {
        "default": "A turning to superficial things for self-strengthening. Self-indulgence in sensations. Unintelligent satiation; dullness.",
        "integrated": "an effective and smooth demonstration of human competence.",
        "stress": "A self-disintegrating surrender to appetite."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_16",
      "sign": "cancer",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A MAN HOLDS A SCROLL. BEFORE HIM, A SQUARE IS OUTLINED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Underlying tendency to revert to root patterns of being: 'squaring' oneself with everyday reality. Control over life.",
        "integrated": "an absolute and personal control and organization of self for the purposes of each special situation.",
        "stress": "Self-limitation through unimaginative perspective."
      },
      "optionText": {
        "default": "Underlying tendency to revert to root patterns of being: 'squaring' oneself with everyday reality. Control over life.",
        "integrated": "an absolute and personal control and organization of self for the purposes of each special situation.",
        "stress": "Self-limitation through unimaginative perspective."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_17",
      "sign": "cancer",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "THE ARCHETYPAL SOUL BECOMES FILLED WITH LIFE-CONTENTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Gathering of all life values and experiences in the perfectly formed consciousness. Spiritually integrated knowledge.",
        "integrated": "a completeness of personal realization and self-consummation in every context of immediate concern.",
        "stress": "An assumption of self-integrity neither appreciated nor possessed."
      },
      "optionText": {
        "default": "Gathering of all life values and experiences in the perfectly formed consciousness. Spiritually integrated knowledge.",
        "integrated": "a completeness of personal realization and self-consummation in every context of immediate concern.",
        "stress": "An assumption of self-integrity neither appreciated nor possessed."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_18",
      "sign": "cancer",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "IN A CROWDED BARNYARD A HEN CLUCKS AMONG HER CHICKENS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Constructively practical, natural approach to life and its simpler joys. Concern over things. Child-like group devotion.",
        "integrated": "a marked capacity for meeting every demand of existence advantageously and with a persisting self-fulfillment.",
        "stress": "Idle bustle and unprofitable labour."
      },
      "optionText": {
        "default": "Constructively practical, natural approach to life and its simpler joys. Concern over things. Child-like group devotion.",
        "integrated": "a marked capacity for meeting every demand of existence advantageously and with a persisting self-fulfillment.",
        "stress": "Idle bustle and unprofitable labour."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_19",
      "sign": "cancer",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "AN ARISTOCRATIC AND FRAIL GIRL WEDS A PROLETARIAN YOUTH",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Blending of the cultural fruition of the past with the impetuousness of new blood. Assimilation of unconscious contents.",
        "integrated": "a genius for bringing various facets of life into organic unity.",
        "stress": "Bondage to outer form."
      },
      "optionText": {
        "default": "Blending of the cultural fruition of the past with the impetuousness of new blood. Assimilation of unconscious contents.",
        "integrated": "a genius for bringing various facets of life into organic unity.",
        "stress": "Bondage to outer form."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_20",
      "sign": "cancer",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A GROUP OF SERENADERS MAKE MERRY IN A VENETIAN GONDOLA",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Exaltation of social intercourse in the traditional manner. Sentimental clinging to old life-ideals. The will to romance.",
        "integrated": "a perfecting of those personal traits and inclinations which bring an enduring satisfaction to every immediate situation.",
        "stress": "A retreat of self from all worthwhile reality."
      },
      "optionText": {
        "default": "Exaltation of social intercourse in the traditional manner. Sentimental clinging to old life-ideals. The will to romance.",
        "integrated": "a perfecting of those personal traits and inclinations which bring an enduring satisfaction to every immediate situation.",
        "stress": "A retreat of self from all worthwhile reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_21",
      "sign": "cancer",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "AN OPERATIC PRIMA DONNA SINGS TO A GLITTERING AUDIENCE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Elevation and popularization of human values through art as a social factor. Supreme realization of the life-ambition.",
        "integrated": "an overflowing richness of self through its full command of its own deep and genuine potentials.",
        "stress": "Superficial self-affirmation and unseemly display."
      },
      "optionText": {
        "default": "Elevation and popularization of human values through art as a social factor. Supreme realization of the life-ambition.",
        "integrated": "an overflowing richness of self through its full command of its own deep and genuine potentials.",
        "stress": "Superficial self-affirmation and unseemly display."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_22",
      "sign": "cancer",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A YOUNG WOMAN DREAMILY AWAITS A SAILBOAT APPROACHING",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Longing to live life as a great adventure. The compelling power of all sustained desire and of the dreaming of dreams.",
        "integrated": "a sure insight into the meaning of chance events and the current drift of circumstance.",
        "stress": "Senseless dependence on accidents of fortune."
      },
      "optionText": {
        "default": "Longing to live life as a great adventure. The compelling power of all sustained desire and of the dreaming of dreams.",
        "integrated": "a sure insight into the meaning of chance events and the current drift of circumstance.",
        "stress": "Senseless dependence on accidents of fortune."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_23",
      "sign": "cancer",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A GROUP OF INTELLECTUAL INDIVIDUALS MEET FOR DISCUSSION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Interchange of ideas among any elite as a basis for the cultural development of the whole. Mental or physical fellowship.",
        "integrated": "accomplishment through an exacting appreciation of common effort and a rigorous revaluation of private acts and attitudes.",
        "stress": "A substitution of idle discussion for actual participation in reality."
      },
      "optionText": {
        "default": "Interchange of ideas among any elite as a basis for the cultural development of the whole. Mental or physical fellowship.",
        "integrated": "accomplishment through an exacting appreciation of common effort and a rigorous revaluation of private acts and attitudes.",
        "stress": "A substitution of idle discussion for actual participation in reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_24",
      "sign": "cancer",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "WOMAN AND TWO MEN CASTAWAYS ON A SOUTH SEAS ISLAND",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The three 'souls' in man – factional, emotional, mental – 'exiled' in the body. Potential fulfillment. Sense of being lost in life.",
        "integrated": "an unusual gift for organizing and exploiting the self's potentials.",
        "stress": "A devastating sense of ineptitude and estrangement from reality."
      },
      "optionText": {
        "default": "The three 'souls' in man – factional, emotional, mental – 'exiled' in the body. Potential fulfillment. Sense of being lost in life.",
        "integrated": "an unusual gift for organizing and exploiting the self's potentials.",
        "stress": "A devastating sense of ineptitude and estrangement from reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_25",
      "sign": "cancer",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "LEADER OF MEN WRAPPED IN AN INVISIBLE MANTLE OF POWER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Support of unconscious elements in every fearless and positive stand of the ego. Restoration of strength; or self-discovery.",
        "integrated": "some dramatic manifestation of genius vital to the general welfare of man.",
        "stress": "A tendency to unwarranted presumption if not outright megalomania."
      },
      "optionText": {
        "default": "Support of unconscious elements in every fearless and positive stand of the ego. Restoration of strength; or self-discovery.",
        "integrated": "some dramatic manifestation of genius vital to the general welfare of man.",
        "stress": "A tendency to unwarranted presumption if not outright megalomania."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_26",
      "sign": "cancer",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "GUESTS ARE READING IN THE LIBRARY OF A LUXURIOUS HOME",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Emergence of consciousness upon higher levels of being, once life has been fulfilled at normal levels. Conscious fruition.",
        "integrated": "a relaxation valuable for the momentary containment of human aspiration whenever it is strained beyond its powers of self-regeneration.",
        "stress": "The loss of all reality in a needless softness of living."
      },
      "optionText": {
        "default": "Emergence of consciousness upon higher levels of being, once life has been fulfilled at normal levels. Conscious fruition.",
        "integrated": "a relaxation valuable for the momentary containment of human aspiration whenever it is strained beyond its powers of self-regeneration.",
        "stress": "The loss of all reality in a needless softness of living."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_27",
      "sign": "cancer",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A FURIOUS STORM RAGES THROUGH A RESIDENTIAL CANYON",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Intensification of elements necessary to arouse latent possibilities. Rising to the occasion. A descent of cosmic power.",
        "integrated": "an enlistment of every resource in life for a heightened expression of self.",
        "stress": "Fatuous enjoyment of turmoil."
      },
      "optionText": {
        "default": "Intensification of elements necessary to arouse latent possibilities. Rising to the occasion. A descent of cosmic power.",
        "integrated": "an enlistment of every resource in life for a heightened expression of self.",
        "stress": "Fatuous enjoyment of turmoil."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_28",
      "sign": "cancer",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "INDIAN GIRL INTRODUCES COLLEGE BOY-FRIEND TO HER TRIBE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The human soul as intercessor between primordial natural forces and the intellectual order. Self-integration. Linkage.",
        "integrated": "high skill in bringing older or neglected reality to the service of fresher and more vital self-fulfillments.",
        "stress": "An inability to make personal adjustments and a stupid exaltation of conservatism."
      },
      "optionText": {
        "default": "The human soul as intercessor between primordial natural forces and the intellectual order. Self-integration. Linkage.",
        "integrated": "high skill in bringing older or neglected reality to the service of fresher and more vital self-fulfillments.",
        "stress": "An inability to make personal adjustments and a stupid exaltation of conservatism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_29",
      "sign": "cancer",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A GREEK MUSE WEIGHS IN GOLDEN SCALES JUST BORN TWINS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The revelation of latent worth in all things through the power of creative imagination. Piercing beyond appearances.",
        "integrated": "an effectiveness of judgment irrespective of momentary contradictions on every hand.",
        "stress": "An undisciplined perfectionism."
      },
      "optionText": {
        "default": "The revelation of latent worth in all things through the power of creative imagination. Piercing beyond appearances.",
        "integrated": "an effectiveness of judgment irrespective of momentary contradictions on every hand.",
        "stress": "An undisciplined perfectionism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "cancer_30",
      "sign": "cancer",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 8: CANCER 16-30: THE SPAN OF INGENUOUSNESS",
      "image": "A LADY OF ARISTOCRATIC DESCENT PROUDLY ADDRESSES A CLUB",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The will and ability to maintain a social supremacy based on thoroughly established tradition. Inner or outer aristocracy.",
        "integrated": "an infectious pride in leadership through which a group is able to act as a unit.",
        "stress": "The ultimate betrayal of selfhood by a false assumption of superiority."
      },
      "optionText": {
        "default": "The will and ability to maintain a social supremacy based on thoroughly established tradition. Inner or outer aristocracy.",
        "integrated": "an infectious pride in leadership through which a group is able to act as a unit.",
        "stress": "The ultimate betrayal of selfhood by a false assumption of superiority."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_01",
      "sign": "leo",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "UNDER EMOTIONAL STRESS BLOOD RUSHES TO A MAN'S HEAD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A basic symbol of Man: forceful, dangerous entrance into the Soul realm. Irresistible outpouring of self. Activity per se.",
        "integrated": "creativity in the day-by-day expression of the self's real possibilities.",
        "stress": "thoroughgoing self-indulgence and imposition on others."
      },
      "optionText": {
        "default": "A basic symbol of Man: forceful, dangerous entrance into the Soul realm. Irresistible outpouring of self. Activity per se.",
        "integrated": "creativity in the day-by-day expression of the self's real possibilities.",
        "stress": "thoroughgoing self-indulgence and imposition on others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_02",
      "sign": "leo",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "THE SCHOOL CLOSED BY AN EPIDEMIC, CHILDREN PLAY TOGETHER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Constructive result of inconveniences of life in developing communal values. Self-sensitiveness. Subtraction from things.",
        "integrated": "continual self-dramatization as the basis for participation in current affairs.",
        "stress": "indicates a retreat to self-deficiencies in a frantic effort to avoid experience."
      },
      "optionText": {
        "default": "Constructive result of inconveniences of life in developing communal values. Self-sensitiveness. Subtraction from things.",
        "integrated": "continual self-dramatization as the basis for participation in current affairs.",
        "stress": "indicates a retreat to self-deficiencies in a frantic effort to avoid experience."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_03",
      "sign": "leo",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "MATURE WOMAN, HER HAIR JUST BOBBED, LOOKS INTO MIRROR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Sense of freedom from age and realization of the value of youth. Self-creation and independence from fate. Will-power.",
        "integrated": "exceptionally effective self-mobilization for the sake of personal ambition.",
        "stress": "It reflects a wholly inadequate appreciation for the self and its destiny."
      },
      "optionText": {
        "default": "Sense of freedom from age and realization of the value of youth. Self-creation and independence from fate. Will-power.",
        "integrated": "exceptionally effective self-mobilization for the sake of personal ambition.",
        "stress": "It reflects a wholly inadequate appreciation for the self and its destiny."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_04",
      "sign": "leo",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "ELDERLY MAN GAZES AT MOOSE HEAD ON CLUBROOM'S WALL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Self-development through the culture of masculine activities. Subservience of individual to social pattern of behaviour. Taste.",
        "integrated": "an exceptional capacity for winning and holding the esteem of men.",
        "stress": "reveal dependence on applause and a tendency to perform for public approval."
      },
      "optionText": {
        "default": "Self-development through the culture of masculine activities. Subservience of individual to social pattern of behaviour. Taste.",
        "integrated": "an exceptional capacity for winning and holding the esteem of men.",
        "stress": "reveal dependence on applause and a tendency to perform for public approval."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_05",
      "sign": "leo",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "SUGGESTING FIGURES, GRANITE MASSES OVERHANG A CANYON",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Permanence of basic elements in nature underneath temporary changes and emphases. Endurance. Steadiness of self-knowledge.",
        "integrated": "man's genius for initial aplomb and ultimate competency in the face of all danger.",
        "stress": "signify pure bullheadedness."
      },
      "optionText": {
        "default": "Permanence of basic elements in nature underneath temporary changes and emphases. Endurance. Steadiness of self-knowledge.",
        "integrated": "man's genius for initial aplomb and ultimate competency in the face of all danger.",
        "stress": "signify pure bullheadedness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_06",
      "sign": "leo",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "OLD-FASHIONED BELLE AND FLAPPER ADMIRE EACH OTHER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Realization of changeless subjective worth beyond changing appearances. Interchange of sympathy. Enhanced self-awareness.",
        "integrated": "personal achievement through creative appreciation and adaptation of established values.",
        "stress": "denote overemphasis of individualistic traits and psychological timidity."
      },
      "optionText": {
        "default": "Realization of changeless subjective worth beyond changing appearances. Interchange of sympathy. Enhanced self-awareness.",
        "integrated": "personal achievement through creative appreciation and adaptation of established values.",
        "stress": "denote overemphasis of individualistic traits and psychological timidity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_07",
      "sign": "leo",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "THE CONSTELLATIONS GLOW IN THE DARKNESS OF DESERT SKIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Sense of primordial wonder and awe before life. Unquenchable faith in a spiritual being complementing our own. Realization.",
        "integrated": "consistent effectiveness in understanding and self-ordering.",
        "stress": "It may reflect a loss of present integrity through an unnecessary retreat to the mysterious."
      },
      "optionText": {
        "default": "Sense of primordial wonder and awe before life. Unquenchable faith in a spiritual being complementing our own. Realization.",
        "integrated": "consistent effectiveness in understanding and self-ordering.",
        "stress": "It may reflect a loss of present integrity through an unnecessary retreat to the mysterious."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_08",
      "sign": "leo",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "PROLETARIAN, BURNING WITH SOCIAL PASSION, STIRS UP A CROWD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Leavening of the inchoate materials of a new order by a forceful vision born of repression and misfortune. Revolution.",
        "integrated": "a determination to share the soul's vision and to make a permanent impact on history.",
        "stress": "manifest as futile ranting against superficial ills."
      },
      "optionText": {
        "default": "Leavening of the inchoate materials of a new order by a forceful vision born of repression and misfortune. Revolution.",
        "integrated": "a determination to share the soul's vision and to make a permanent impact on history.",
        "stress": "manifest as futile ranting against superficial ills."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_09",
      "sign": "leo",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "GLASS-BLOWERS SHAPE WITH THEIR BREATH GLOWING FORMS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The formative power of the soul in moments of emotional intensity. Controlled self-expression. Art as a spiritual fact.",
        "integrated": "an effectiveness of personal participation in everyday existence.",
        "stress": "indicate wilful or unintelligent distortion of reality."
      },
      "optionText": {
        "default": "The formative power of the soul in moments of emotional intensity. Controlled self-expression. Art as a spiritual fact.",
        "integrated": "an effectiveness of personal participation in everyday existence.",
        "stress": "indicate wilful or unintelligent distortion of reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_10",
      "sign": "leo",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "EARLY MORNING DEW SPARKLES AS THE SUN FLOODS THE FIELDS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Freshness of spontaneous response to life and emotions. Uplifting lightness in experience; or else superficial glamour.",
        "integrated": "a special talent for finding the better in every situation.",
        "stress": "It may lead to procrastination and insensibility to deeper selfhood."
      },
      "optionText": {
        "default": "Freshness of spontaneous response to life and emotions. Uplifting lightness in experience; or else superficial glamour.",
        "integrated": "a special talent for finding the better in every situation.",
        "stress": "It may lead to procrastination and insensibility to deeper selfhood."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_11",
      "sign": "leo",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "CHILDREN PLAY BENEATH HUGE OAK, SHELTER FROM THE SUN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The sustaining and protective power of ancestral background against emotions. Appreciation of inborn cultural restraint.",
        "integrated": "a consistent zest for living and a generous outpouring of self-expenditure.",
        "stress": "reveal laziness exalted as a virtue."
      },
      "optionText": {
        "default": "The sustaining and protective power of ancestral background against emotions. Appreciation of inborn cultural restraint.",
        "integrated": "a consistent zest for living and a generous outpouring of self-expenditure.",
        "stress": "reveal laziness exalted as a virtue."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_12",
      "sign": "leo",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "A GARDEN PARTY IS IN FULL SWING UNDER JAPANESE LANTERNS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Easy intercourse of human souls in moments of relaxation from strain. Examination of, or self-loss in, social values.",
        "integrated": "a genuine social maturity and an effective capacity for working with others.",
        "stress": "indicate a lack of appreciation for the deeper reality of life."
      },
      "optionText": {
        "default": "Easy intercourse of human souls in moments of relaxation from strain. Examination of, or self-loss in, social values.",
        "integrated": "a genuine social maturity and an effective capacity for working with others.",
        "stress": "indicate a lack of appreciation for the deeper reality of life."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_13",
      "sign": "leo",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "OLD SEA-CAPTAIN RESTS IN NEAT LITTLE COTTAGE BY THE SEA",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Reward of growth from outer to inner realms. Serenity through overcoming storms. Self-gained mellowness. Retirement.",
        "integrated": "an expression of one's unlimited capacity to recall and use personal strengths.",
        "stress": "signal insensibility to present reality by surrendering to the past."
      },
      "optionText": {
        "default": "Reward of growth from outer to inner realms. Serenity through overcoming storms. Self-gained mellowness. Retirement.",
        "integrated": "an expression of one's unlimited capacity to recall and use personal strengths.",
        "stress": "signal insensibility to present reality by surrendering to the past."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_14",
      "sign": "leo",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "CHERUB-LIKE, A HUMAN SOUL WHISPERS, SEEKING TO MANIFEST",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The desire to be, to suffer and to grow which brings Spirit to Earth. Whole-souled self-giving. Yearning for experience.",
        "integrated": "a genius for wholehearted participation in life's adventures.",
        "stress": "manifest as naive procrastination and lack of genuine enthusiasm."
      },
      "optionText": {
        "default": "The desire to be, to suffer and to grow which brings Spirit to Earth. Whole-souled self-giving. Yearning for experience.",
        "integrated": "a genius for wholehearted participation in life's adventures.",
        "stress": "manifest as naive procrastination and lack of genuine enthusiasm."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_15",
      "sign": "leo",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 9: LEO 1-15: THE SPAN OF ASSURANCE",
      "image": "THE MARDI GRAS CARNIVAL CROWDS NEW ORLEANS' STREETS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Spectacular, dramatic release of subconscious energies. Self-exaltation for social approval. Self-indulgence and license.",
        "integrated": "an irresistible heightening of self-significance across all experiences.",
        "stress": "It may lead to unconvincing claims and embarrassing self-assertion."
      },
      "optionText": {
        "default": "Spectacular, dramatic release of subconscious energies. Self-exaltation for social approval. Self-indulgence and license.",
        "integrated": "an irresistible heightening of self-significance across all experiences.",
        "stress": "It may lead to unconvincing claims and embarrassing self-assertion."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_16",
      "sign": "leo",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "REFRESHED BY A STORM, FIELDS AND GARDENS BASK IN THE SUN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A return to values after a major life crisis. Cleansing power of suffering overcome. Mastery of strain—or indifference.",
        "integrated": "marked by exceptional steadiness of perspective and fidelity to individual responsibility.",
        "stress": "be characterized by continual upset over petty issues."
      },
      "optionText": {
        "default": "A return to values after a major life crisis. Cleansing power of suffering overcome. Mastery of strain—or indifference.",
        "integrated": "marked by exceptional steadiness of perspective and fidelity to individual responsibility.",
        "stress": "be characterized by continual upset over petty issues."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_17",
      "sign": "leo",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "VOLUNTEER CHURCH CHOIR MAKE SOCIAL EVENT OF REHEARSAL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Utilization of normal human instincts as a foundation for high endeavour. Lay-participation in Mysteries. Joy in faith.",
        "integrated": "the effective quickening of the heart through broadened interests.",
        "stress": "suggest an unimaginative striving for undeserved popularity."
      },
      "optionText": {
        "default": "Utilization of normal human instincts as a foundation for high endeavour. Lay-participation in Mysteries. Joy in faith.",
        "integrated": "the effective quickening of the heart through broadened interests.",
        "stress": "suggest an unimaginative striving for undeserved popularity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_18",
      "sign": "leo",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "CHEMIST CONDUCTS AN EXPERIMENT BEFORE HIS STUDENTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Practical application of principles to everyday life. Active enlightenment; or a forced awakening to inner potentialities.",
        "integrated": "exceptional self-confidence and a delight in testing immediate application of experience.",
        "stress": "denote unintelligent dependence on rules or supposition."
      },
      "optionText": {
        "default": "Practical application of principles to everyday life. Active enlightenment; or a forced awakening to inner potentialities.",
        "integrated": "exceptional self-confidence and a delight in testing immediate application of experience.",
        "stress": "denote unintelligent dependence on rules or supposition."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_19",
      "sign": "leo",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "A BARGE MADE INTO A CLUBHOUSE IS CROWDED WITH REVELERS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The transforming power of pure joy over routine existence. Human fellowship in making life happier and freer.",
        "integrated": "characterized by a gracious eagerness for worthwhile participation in human affairs.",
        "stress": "result in thoughtless self-indulgence and contempt for the general welfare."
      },
      "optionText": {
        "default": "The transforming power of pure joy over routine existence. Human fellowship in making life happier and freer.",
        "integrated": "characterized by a gracious eagerness for worthwhile participation in human affairs.",
        "stress": "result in thoughtless self-indulgence and contempt for the general welfare."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_20",
      "sign": "leo",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "AMERICAN INDIANS PERFORM A MAJESTIC RITUAL TO THE SUN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Man's instinctive or traditional call upon basic life energies for sustainment. Sense of fitness in behavior. Worship.",
        "integrated": "an inner and absolute realization of the self's boundless resources.",
        "stress": "express a surrender of personal reality to meaningless ceremonies."
      },
      "optionText": {
        "default": "Man's instinctive or traditional call upon basic life energies for sustainment. Sense of fitness in behavior. Worship.",
        "integrated": "an inner and absolute realization of the self's boundless resources.",
        "stress": "express a surrender of personal reality to meaningless ceremonies."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_21",
      "sign": "leo",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "INTOXICATED DOMESTIC BIRDS FLY AROUND IN DIZZY ATTEMPTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Unsteady first realization of spiritual being. Forced inspiration which the ego cannot sustain. False self-intoxication.",
        "integrated": "the individual's capacity for creative self-mobilization in diverse situations.",
        "stress": "lead to unnecessary bondage to external influences."
      },
      "optionText": {
        "default": "Unsteady first realization of spiritual being. Forced inspiration which the ego cannot sustain. False self-intoxication.",
        "integrated": "the individual's capacity for creative self-mobilization in diverse situations.",
        "stress": "lead to unnecessary bondage to external influences."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_22",
      "sign": "leo",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "A CARRIER-PIGEON ALIGHTS AT DAWN BEFORE HIS OWNERS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The return of soul energies to the central Self after significant experience. Adventuring. Practical enlightenment.",
        "integrated": "a complete mastery of all things through normal thought processes.",
        "stress": "reflect a lack of simple good sense."
      },
      "optionText": {
        "default": "The return of soul energies to the central Self after significant experience. Adventuring. Practical enlightenment.",
        "integrated": "a complete mastery of all things through normal thought processes.",
        "stress": "reflect a lack of simple good sense."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_23",
      "sign": "leo",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "THE BAREBACK RIDER IN A CIRCUS THRILLS EXCITED CROWDS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The supremacy of one who has mastered his senses and emotions. Full utilization of inner powers. Audacity.",
        "integrated": "uncompromising courage in everyday living and a carefree assurance in meeting modern challenges.",
        "stress": "express itself as idle self-display and an intemperate desire for applause."
      },
      "optionText": {
        "default": "The supremacy of one who has mastered his senses and emotions. Full utilization of inner powers. Audacity.",
        "integrated": "uncompromising courage in everyday living and a carefree assurance in meeting modern challenges.",
        "stress": "express itself as idle self-display and an intemperate desire for applause."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_24",
      "sign": "leo",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "A YOGI, WITH TRANSCENDENT POWERS YET UNTIDY, UNKEMPT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Spiritual emphasis at the expense of outer refinement. Interior focalization of energies. Self-abnegation. Character.",
        "integrated": "marked by an ease of outer accomplishment through inner intensification and heightened sensibility.",
        "stress": "be accompanied by perverse satisfaction in neglecting the self."
      },
      "optionText": {
        "default": "Spiritual emphasis at the expense of outer refinement. Interior focalization of energies. Self-abnegation. Character.",
        "integrated": "marked by an ease of outer accomplishment through inner intensification and heightened sensibility.",
        "stress": "be accompanied by perverse satisfaction in neglecting the self."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_25",
      "sign": "leo",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "A MAN, ALONE, DARINGLY CROSSES THE DESERT ON CAMELBACK",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Superiority of knowledge and will over hostile nature. Mental self-control. Spiritual strength in facing past Karma.",
        "integrated": "characterized by uncompromising persistence and uncomplaining self-expenditure.",
        "stress": "manifest as ruthlessness in an unintelligent self-interest."
      },
      "optionText": {
        "default": "Superiority of knowledge and will over hostile nature. Mental self-control. Spiritual strength in facing past Karma.",
        "integrated": "characterized by uncompromising persistence and uncomplaining self-expenditure.",
        "stress": "manifest as ruthlessness in an unintelligent self-interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "leo_26",
      "sign": "leo",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "AS LIGHT BREAKS THROUGH CLOUDS, A PERFECT RAINBOW FORMS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Promise of conscious immortality after the death of useless things. Spiritual linkage through emotional stress. Blessing.",
        "integrated": "a manifestation of spiritual renewal and the promise of eternal continuity.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Promise of conscious immortality after the death of useless things."
      },
      "optionText": {
        "default": "Promise of conscious immortality after the death of useless things. Spiritual linkage through emotional stress. Blessing.",
        "integrated": "a manifestation of spiritual renewal and the promise of eternal continuity.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Promise of conscious immortality after the death of useless things."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "leo_27",
      "sign": "leo",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "IN THE EAST, LIGHT SLOWLY INCREASES, WIPING OUT THE STARS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Transforming power of creative impulses as they bring ideas to concrete manifestation. Stirring to opportunity. Soul-power.",
        "integrated": "an inspiring force that transforms potential into reality.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Transforming power of creative impulses as they bring ideas to concrete manifestation."
      },
      "optionText": {
        "default": "Transforming power of creative impulses as they bring ideas to concrete manifestation. Stirring to opportunity. Soul-power.",
        "integrated": "an inspiring force that transforms potential into reality.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Transforming power of creative impulses as they bring ideas to concrete manifestation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "leo_28",
      "sign": "leo",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "MYRIADS OF BIRDS, PERCHED UPON A BIG TREE, CHIRP HAPPILY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Social nature of experience as man finds sustainment in a larger whole of being. Normal, collective self-expression.",
        "integrated": "an affirmation of communal vitality and expressive joy.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Social nature of experience as man finds sustainment in a larger whole of being."
      },
      "optionText": {
        "default": "Social nature of experience as man finds sustainment in a larger whole of being. Normal, collective self-expression.",
        "integrated": "an affirmation of communal vitality and expressive joy.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Social nature of experience as man finds sustainment in a larger whole of being."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "leo_29",
      "sign": "leo",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "MERMAID AWAITS PRINCE WHO WILL MAKE HER IMMORTAL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Pure longing for a new order of selfhood. Critical point in 'emergent evolution.' Perspective; or a sense of incompetence.",
        "integrated": "a call to transformative change and new beginnings.",
        "stress": "a sense of incompetence."
      },
      "optionText": {
        "default": "Pure longing for a new order of selfhood. Critical point in 'emergent evolution.' Perspective; or a sense of incompetence.",
        "integrated": "a call to transformative change and new beginnings.",
        "stress": "a sense of incompetence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "leo_30",
      "sign": "leo",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 10: LEO 16-30: THE SPAN OF INTERPRETATION",
      "image": "AN UNSEALED LETTER FULL OF VITAL AND CONFIDENTIAL NEWS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Basic faith in the goodness of all life. Unthinking trust in, or desire to explore, hidden truths. Confidence.",
        "integrated": "a demonstration of profound trust and a pursuit of hidden truths.",
        "stress": "desire to explore, hidden truths. Confidence."
      },
      "optionText": {
        "default": "Basic faith in the goodness of all life. Unthinking trust in, or desire to explore, hidden truths. Confidence.",
        "integrated": "a demonstration of profound trust and a pursuit of hidden truths.",
        "stress": "desire to explore, hidden truths. Confidence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "virgo_01",
      "sign": "virgo",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "IN A PORTRAIT THE BEST OF A MAN'S TRAITS ARE IDEALIZED",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The shaping power of idea or ideal over outer form and behavior. Completeness of realization. Pure aggrandizement. Intent.",
        "integrated": "an extraordinary skill for recognizing and bringing forward the highest potential in oneself and others.",
        "stress": "A tendency toward flattery and superficial glorification that ignores substantive character."
      },
      "optionText": {
        "default": "The shaping power of idea or ideal over outer form and behavior. Completeness of realization. Pure aggrandizement. Intent.",
        "integrated": "an extraordinary skill for recognizing and bringing forward the highest potential in oneself and others.",
        "stress": "A tendency toward flattery and superficial glorification that ignores substantive character."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_02",
      "sign": "virgo",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A LARGE WHITE CROSS STANDS ALONE ON TOP OF A HIGH HILL",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Dominance of environment through individualistic self-realization. Eminence at the cost of struggle. Full self-assurance.",
        "integrated": "profound spiritual accomplishment that stands as a beacon of inspiration to others after personal sacrifice.",
        "stress": "Martyrdom as an escape from life's responsibilities and an unwarranted pride in one's suffering."
      },
      "optionText": {
        "default": "Dominance of environment through individualistic self-realization. Eminence at the cost of struggle. Full self-assurance.",
        "integrated": "profound spiritual accomplishment that stands as a beacon of inspiration to others after personal sacrifice.",
        "stress": "Martyrdom as an escape from life's responsibilities and an unwarranted pride in one's suffering."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_03",
      "sign": "virgo",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "TWO ANGELS BRING PROTECTION TO FAMILY IN THE WILDERNESS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Divine guarantee to man of supply of all his needs. Divine help when human efforts fail. Unconscious sense of strength.",
        "integrated": "exceptional resilience through an innate trust in unseen spiritual support during times of extremity.",
        "stress": "Passive dependence on outside intervention rather than mobilizing one's own inner resources."
      },
      "optionText": {
        "default": "Divine guarantee to man of supply of all his needs. Divine help when human efforts fail. Unconscious sense of strength.",
        "integrated": "exceptional resilience through an innate trust in unseen spiritual support during times of extremity.",
        "stress": "Passive dependence on outside intervention rather than mobilizing one's own inner resources."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_04",
      "sign": "virgo",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "NEGRO CHILD PLAYS WITH WHITE BOYS UNAWARE OF RACE LINE",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Underlying fellowship of all life underneath social creeds. Stimulating sense of distinctness. Rising above contrasts.",
        "integrated": "natural integrity in human relationships untainted by artificial social distinctions or prejudice.",
        "stress": "Naivety about real social conditions and a failure to address necessary reforms of inequitable structures."
      },
      "optionText": {
        "default": "Underlying fellowship of all life underneath social creeds. Stimulating sense of distinctness. Rising above contrasts.",
        "integrated": "natural integrity in human relationships untainted by artificial social distinctions or prejudice.",
        "stress": "Naivety about real social conditions and a failure to address necessary reforms of inequitable structures."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_05",
      "sign": "virgo",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "IRISHMAN DREAMS OF \"LITTLE PEOPLE\" BENEATH A TREE",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Constructive imagination as it reveals unconscious realms of being. Creative fantasy. Contact with inner life-energies.",
        "integrated": "exceptional intuitive sensitivity to subtle dimensions of experience and a fertile imagination that enriches everyday reality.",
        "stress": "Escape into fantasy and an inability to distinguish between creative vision and self-deluding wishful thinking."
      },
      "optionText": {
        "default": "Constructive imagination as it reveals unconscious realms of being. Creative fantasy. Contact with inner life-energies.",
        "integrated": "exceptional intuitive sensitivity to subtle dimensions of experience and a fertile imagination that enriches everyday reality.",
        "stress": "Escape into fantasy and an inability to distinguish between creative vision and self-deluding wishful thinking."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_06",
      "sign": "virgo",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "EXCITED CHILDREN RIDE ON A BLATANT, GAUDY MERRY-GO-ROUND",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The culture of pleasure as a transmuting force. Unfearing plunge into life. Endless and futile repetition of experience.",
        "integrated": "wholehearted participation in life's sensory experiences with a childlike capacity for joy and wonder.",
        "stress": "Superficial excitement that substitutes for genuine fulfillment, leading to cycles of repetitive sensation-seeking."
      },
      "optionText": {
        "default": "The culture of pleasure as a transmuting force. Unfearing plunge into life. Endless and futile repetition of experience.",
        "integrated": "wholehearted participation in life's sensory experiences with a childlike capacity for joy and wonder.",
        "stress": "Superficial excitement that substitutes for genuine fulfillment, leading to cycles of repetitive sensation-seeking."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_07",
      "sign": "virgo",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "IN A PALATIAL HAREM BRIGHT-EYED WOMEN LAUGH HAPPILY",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Early stage of development of individual soul, with full yet binding life-protection. Freedom from responsibility or restraint.",
        "integrated": "a valuable capacity for finding contentment and sisterhood even within limited circumstances.",
        "stress": "Acceptance of restricted personal freedom in exchange for material security and sensual indulgence."
      },
      "optionText": {
        "default": "Early stage of development of individual soul, with full yet binding life-protection. Freedom from responsibility or restraint.",
        "integrated": "a valuable capacity for finding contentment and sisterhood even within limited circumstances.",
        "stress": "Acceptance of restricted personal freedom in exchange for material security and sensual indulgence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_08",
      "sign": "virgo",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "ARISTOCRATIC FIVE-YEAR-OLD GIRL TAKES FIRST DANCING LESSON",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Early social conditioning of the superior elements of being. Proper start in self-discipline. Conventional development.",
        "integrated": "a remarkable capacity for developing personal grace and cultural refinement from an early foundation of discipline.",
        "stress": "An excessive attachment to convention and social formality at the expense of authentic expression."
      },
      "optionText": {
        "default": "Early social conditioning of the superior elements of being. Proper start in self-discipline. Conventional development.",
        "integrated": "a remarkable capacity for developing personal grace and cultural refinement from an early foundation of discipline.",
        "stress": "An excessive attachment to convention and social formality at the expense of authentic expression."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_09",
      "sign": "virgo",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A MODERN EXPRESSIONISTIC ARTIST PAINTS A STRANGE CANVAS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Original genius of every individual soul unconcerned with collective values. Absolute, tradition-less self-expression.",
        "integrated": "an extraordinary capacity for breaking through conventional perspectives to reveal profound new dimensions of reality.",
        "stress": "Rebellion against tradition merely for its own sake and a self-indulgent disregard for communicable meaning."
      },
      "optionText": {
        "default": "Original genius of every individual soul unconcerned with collective values. Absolute, tradition-less self-expression.",
        "integrated": "an extraordinary capacity for breaking through conventional perspectives to reveal profound new dimensions of reality.",
        "stress": "Rebellion against tradition merely for its own sake and a self-indulgent disregard for communicable meaning."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_10",
      "sign": "virgo",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A MAN WITH TWO HEADS IS SEEN LOOKING OUT TO THE BEYOND",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Consciousness functioning in inner and outer realms. Competence in understanding. Over-sensitiveness to life-currents.",
        "integrated": "exceptional versatility in perceiving multiple dimensions of reality simultaneously and integrating diverse perspectives.",
        "stress": "Mental confusion arising from an inability to reconcile contradictory viewpoints and inner conflict leading to indecision."
      },
      "optionText": {
        "default": "Consciousness functioning in inner and outer realms. Competence in understanding. Over-sensitiveness to life-currents.",
        "integrated": "exceptional versatility in perceiving multiple dimensions of reality simultaneously and integrating diverse perspectives.",
        "stress": "Mental confusion arising from an inability to reconcile contradictory viewpoints and inner conflict leading to indecision."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_11",
      "sign": "virgo",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A TYPICAL BOY, YET MOULDED BY HIS MOTHER'S ASPIRATIONS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Efficacy of overtones in life; of ideals in giving reality or depth to outer material things. Conformity to inner light.",
        "integrated": "a remarkable capacity to embody higher ideals while maintaining authenticity and natural character.",
        "stress": "Submission to external expectations at the cost of genuine self-development and resentment of formative influences."
      },
      "optionText": {
        "default": "Efficacy of overtones in life; of ideals in giving reality or depth to outer material things. Conformity to inner light.",
        "integrated": "a remarkable capacity to embody higher ideals while maintaining authenticity and natural character.",
        "stress": "Submission to external expectations at the cost of genuine self-development and resentment of formative influences."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_12",
      "sign": "virgo",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A BRIDE, LAUGHING, SCOLDS THE GROOM WHO LIFTED HER VEIL",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Disclosure of the hidden fruitions of nature to him who dares and who loves. Full appreciation of life. Penetration.",
        "integrated": "a delightful capacity for keeping relationships fresh through playful interaction that respects boundaries yet deepens intimacy.",
        "stress": "Excessive reserve masking fear of genuine connection or conversely, inappropriate intrusion into others' privacy."
      },
      "optionText": {
        "default": "Disclosure of the hidden fruitions of nature to him who dares and who loves. Full appreciation of life. Penetration.",
        "integrated": "a delightful capacity for keeping relationships fresh through playful interaction that respects boundaries yet deepens intimacy.",
        "stress": "Excessive reserve masking fear of genuine connection or conversely, inappropriate intrusion into others' privacy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_13",
      "sign": "virgo",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A POWERFUL STATESMAN WINS TO HIS CAUSE A HYSTERICAL MOB",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Power of personality as incarnation of subconscious race ideals. Sublimation of motives. Transmutation of energies.",
        "integrated": "exceptional leadership ability in channeling collective energies toward constructive social purposes.",
        "stress": "Manipulation of mass psychology for personal advancement and exploitation of emotional volatility for control."
      },
      "optionText": {
        "default": "Power of personality as incarnation of subconscious race ideals. Sublimation of motives. Transmutation of energies.",
        "integrated": "exceptional leadership ability in channeling collective energies toward constructive social purposes.",
        "stress": "Manipulation of mass psychology for personal advancement and exploitation of emotional volatility for control."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_14",
      "sign": "virgo",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "A SPLENDID FAMILY TREE ENGRAVED ON A SHEET OF PARCHMENT",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Importance of ancestral background in accomplishments. Power to experience deeply. Cultural sensitiveness. Heritage.",
        "integrated": "profound reverence for traditions that provide continuity and depth to present accomplishments.",
        "stress": "Excessive pride in lineage without personal merit and reliance on past glories rather than present achievements."
      },
      "optionText": {
        "default": "Importance of ancestral background in accomplishments. Power to experience deeply. Cultural sensitiveness. Heritage.",
        "integrated": "profound reverence for traditions that provide continuity and depth to present accomplishments.",
        "stress": "Excessive pride in lineage without personal merit and reliance on past glories rather than present achievements."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_15",
      "sign": "virgo",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 11: VIRGO 1-15: THE SPAN OF IDEALIZATION",
      "image": "OLD LACE HANDKERCHIEF; SOME RARE PERFUME; A MIRROR",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Ultimate fineness of material values shading into the spiritual. Schooled and aristocratic delicacy. Cultured restraint.",
        "integrated": "exquisite refinement of perception and the ability to appreciate subtle qualities that elevate experience.",
        "stress": "Precious aestheticism disconnected from vital living and concern with appearances at the expense of substance."
      },
      "optionText": {
        "default": "Ultimate fineness of material values shading into the spiritual. Schooled and aristocratic delicacy. Cultured restraint.",
        "integrated": "exquisite refinement of perception and the ability to appreciate subtle qualities that elevate experience.",
        "stress": "Precious aestheticism disconnected from vital living and concern with appearances at the expense of substance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_16",
      "sign": "virgo",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "CHILDREN CROWD AROUND THE ORANG-OUTANG CAGE IN THE ZOO",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The lesson which the very old can give to the very young in all realms. Vicarious experience. Inertia of instincts. Poise.",
        "integrated": "natural curiosity leading to profound insights about human nature and our evolutionary heritage.",
        "stress": "Unhealthy fascination with the primitive aspects of existence and failure to recognize kinship with all life forms."
      },
      "optionText": {
        "default": "The lesson which the very old can give to the very young in all realms. Vicarious experience. Inertia of instincts. Poise.",
        "integrated": "natural curiosity leading to profound insights about human nature and our evolutionary heritage.",
        "stress": "Unhealthy fascination with the primitive aspects of existence and failure to recognize kinship with all life forms."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_17",
      "sign": "virgo",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A VOLCANIC ERUPTION RELEASES POWERFUL TELLURIC ENERGIES",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Irresistible out-bursting of pent-up impulses, creatively or regeneratively. Breaking up of 'complexes.' Will to wholeness.",
        "integrated": "transformative release of inner pressures leading to renewed vitality and creative rebirth.",
        "stress": "Destructive expression of repressed energies and inability to channel primal forces constructively."
      },
      "optionText": {
        "default": "Irresistible out-bursting of pent-up impulses, creatively or regeneratively. Breaking up of 'complexes.' Will to wholeness.",
        "integrated": "transformative release of inner pressures leading to renewed vitality and creative rebirth.",
        "stress": "Destructive expression of repressed energies and inability to channel primal forces constructively."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_18",
      "sign": "virgo",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "TWO EXCITED YOUNG GIRLS EXPERIMENT WITH A OUIJA BOARD",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Human desire for contact with the beyond. Inquiry. Restless questioning of superficial facts of being. Immature curiosity.",
        "integrated": "openness to intuitive dimensions of experience and a healthy questioning of conventional boundaries.",
        "stress": "Naive dabbling in psychic matters without proper preparation and susceptibility to suggestion without discrimination."
      },
      "optionText": {
        "default": "Human desire for contact with the beyond. Inquiry. Restless questioning of superficial facts of being. Immature curiosity.",
        "integrated": "openness to intuitive dimensions of experience and a healthy questioning of conventional boundaries.",
        "stress": "Naive dabbling in psychic matters without proper preparation and susceptibility to suggestion without discrimination."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_19",
      "sign": "virgo",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A SWIMMING RACE NEARS COMPLETION BEFORE A LARGE CROWD",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Social sustainment of individual accomplishment. Encouragement. Competition as a means to create group-consciousness.",
        "integrated": "excellence achieved through focused effort within a structure of healthy competition and social recognition.",
        "stress": "Excessive drive for public acclaim and meaningless rivalry that obscures the true purpose of personal development."
      },
      "optionText": {
        "default": "Social sustainment of individual accomplishment. Encouragement. Competition as a means to create group-consciousness.",
        "integrated": "excellence achieved through focused effort within a structure of healthy competition and social recognition.",
        "stress": "Excessive drive for public acclaim and meaningless rivalry that obscures the true purpose of personal development."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_20",
      "sign": "virgo",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A GROUP OF SETILERS START ON THEIR JOURNEY IN OLD CARS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Rising to achievement in spite of inadequate equipment. Joy in meeting life's challenges. Venturing with faith.",
        "integrated": "resourceful determination to pursue new opportunities with whatever means are available, however modest.",
        "stress": "Reckless migration from established conditions without adequate preparation or realistic assessment of challenges."
      },
      "optionText": {
        "default": "Rising to achievement in spite of inadequate equipment. Joy in meeting life's challenges. Venturing with faith.",
        "integrated": "resourceful determination to pursue new opportunities with whatever means are available, however modest.",
        "stress": "Reckless migration from established conditions without adequate preparation or realistic assessment of challenges."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_21",
      "sign": "virgo",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "TWO TEAMS OF GIRLS ENGAGED IN A CONTEST OF BASKETBALL",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Physical wholesomeness as prelude to inner integration. Self-evaluation, or refusal to face self. The rhythm of instincts.",
        "integrated": "balanced development of social cooperation and individual excellence through disciplined physical activity.",
        "stress": "Excessive competitiveness or conformity to team expectations at the expense of personal growth and authentic expression."
      },
      "optionText": {
        "default": "Physical wholesomeness as prelude to inner integration. Self-evaluation, or refusal to face self. The rhythm of instincts.",
        "integrated": "balanced development of social cooperation and individual excellence through disciplined physical activity.",
        "stress": "Excessive competitiveness or conformity to team expectations at the expense of personal growth and authentic expression."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_22",
      "sign": "virgo",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "THE JEWEL-SET ROYAL COAT-OF-ARMS IS DISPLAYED IN A MUSEUM",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Preservation of ancient race values for healthy veneration by youthful individuals. Certification of merit. Aristocracy.",
        "integrated": "profound respect for cultural heritage and the ability to extract timeless values from historical accomplishments.",
        "stress": "Attachment to obsolete symbols of status and authority without understanding their original spiritual significance."
      },
      "optionText": {
        "default": "Preservation of ancient race values for healthy veneration by youthful individuals. Certification of merit. Aristocracy.",
        "integrated": "profound respect for cultural heritage and the ability to extract timeless values from historical accomplishments.",
        "stress": "Attachment to obsolete symbols of status and authority without understanding their original spiritual significance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_23",
      "sign": "virgo",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A LION-TAMER RUSHES FEARLESSLY INTO THE CIRCUS ARENA",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Readiness to face the aroused energies of one's nature and test one's moral strength. Faith in self. Valor and mastery.",
        "integrated": "exceptional courage in confronting and directing powerful instinctual forces both within and without.",
        "stress": "Reckless confrontation with dangerous energies and misguided attempts to dominate natural forces through ego assertion."
      },
      "optionText": {
        "default": "Readiness to face the aroused energies of one's nature and test one's moral strength. Faith in self. Valor and mastery.",
        "integrated": "exceptional courage in confronting and directing powerful instinctual forces both within and without.",
        "stress": "Reckless confrontation with dangerous energies and misguided attempts to dominate natural forces through ego assertion."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_24",
      "sign": "virgo",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A BOOK FOR CHILDREN PICTURES LITTLE MARY AND HER LAMB",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Freshness of viewpoint uninhibited by social intellectual preoccupations. Vibrant simplicity. Spirit-born imagination.",
        "integrated": "preservation of innocence and purity of heart that allows direct perception of life's essential truths.",
        "stress": "Infantile regression avoiding the challenges of mature consciousness and oversimplification of complex realities."
      },
      "optionText": {
        "default": "Freshness of viewpoint uninhibited by social intellectual preoccupations. Vibrant simplicity. Spirit-born imagination.",
        "integrated": "preservation of innocence and purity of heart that allows direct perception of life's essential truths.",
        "stress": "Infantile regression avoiding the challenges of mature consciousness and oversimplification of complex realities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_25",
      "sign": "virgo",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "A FLAG AT HALF-MAST IN FRONT OF LARGE PUBLIC BUILDING",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The ability to carry a task through to consummate completion. Deference to past achievement. Cultivation of public spirit.",
        "integrated": "deep respect for sacrifice and a recognition of the continuity of social values beyond individual lifetimes.",
        "stress": "Empty ritualism that substitutes for genuine feeling and manipulation of public sentiment for political purposes."
      },
      "optionText": {
        "default": "The ability to carry a task through to consummate completion. Deference to past achievement. Cultivation of public spirit.",
        "integrated": "deep respect for sacrifice and a recognition of the continuity of social values beyond individual lifetimes.",
        "stress": "Empty ritualism that substitutes for genuine feeling and manipulation of public sentiment for political purposes."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_26",
      "sign": "virgo",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "RAPT-EYED, A BOY SERVES IN A MASS READ BY AUTOMATONS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Ability to find inspiration in daily routine. Hope arising in the midst of all deadness of heart. Rejuvenation of spirit.",
        "integrated": "capacity to infuse routine ceremonies with fresh spiritual insight and genuine reverence.",
        "stress": "Naive participation in empty rituals and failure to recognize the mechanistic aspects of institutional religion."
      },
      "optionText": {
        "default": "Ability to find inspiration in daily routine. Hope arising in the midst of all deadness of heart. Rejuvenation of spirit.",
        "integrated": "capacity to infuse routine ceremonies with fresh spiritual insight and genuine reverence.",
        "stress": "Naive participation in empty rituals and failure to recognize the mechanistic aspects of institutional religion."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_27",
      "sign": "virgo",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "ELDERLY LADIES DRINKING AFTERNOON TEA IN A WEALTHY HOME",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Preservation of social and cultural values. Inward, unobtrusive superiority, or else pure smugness. Prestige of position.",
        "integrated": "graceful maintenance of social traditions that provide continuity and refinement to human relationships.",
        "stress": "Shallow exclusivity and adherence to social customs that have lost their meaningful content."
      },
      "optionText": {
        "default": "Preservation of social and cultural values. Inward, unobtrusive superiority, or else pure smugness. Prestige of position.",
        "integrated": "graceful maintenance of social traditions that provide continuity and refinement to human relationships.",
        "stress": "Shallow exclusivity and adherence to social customs that have lost their meaningful content."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_28",
      "sign": "virgo",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "BALD-HEADED MAN DOMINATES GATHERING OF NATIONAL FIGURES",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Driving power of real personality in moments of crisis. Capacity for hard work. Compelling manifestation of inner self.",
        "integrated": "exceptional authority derived from genuine wisdom and the ability to focus collective energies during critical situations.",
        "stress": "Domineering personality that imposes itself through sheer force of will rather than authentic leadership qualities."
      },
      "optionText": {
        "default": "Driving power of real personality in moments of crisis. Capacity for hard work. Compelling manifestation of inner self.",
        "integrated": "exceptional authority derived from genuine wisdom and the ability to focus collective energies during critical situations.",
        "stress": "Domineering personality that imposes itself through sheer force of will rather than authentic leadership qualities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_29",
      "sign": "virgo",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "ARCHAIC MANUSCRIPT DISCLOSES TO SCHOLAR THE OLD MYSTERIES",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The understanding built on patient steady work and persisting aspiration. Fecundative power of ancient wisdom.",
        "integrated": "profound intellectual dedication that reveals timeless spiritual insights through scholarly perseverance.",
        "stress": "Obsession with esoteric knowledge divorced from practical application and pedantry that obscures essential truths."
      },
      "optionText": {
        "default": "The understanding built on patient steady work and persisting aspiration. Fecundative power of ancient wisdom.",
        "integrated": "profound intellectual dedication that reveals timeless spiritual insights through scholarly perseverance.",
        "stress": "Obsession with esoteric knowledge divorced from practical application and pedantry that obscures essential truths."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "virgo_30",
      "sign": "virgo",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 12: VIRGO 16-30: THE SPAN OF EXPERIMENTATION",
      "image": "AN EMERGENCY CALL FREES HOUSEHOLDER FROM ROUTINE DUTY",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Joy of enlisting in a task which broadens the life-horizon. Willing rising to the occasion, or escape from narrow destiny.",
        "integrated": "readiness to respond to unexpected opportunities that expand one's field of service beyond personal concerns.",
        "stress": "Exaggeration of minor incidents to escape responsibilities and restless discontent with normal social obligations."
      },
      "optionText": {
        "default": "Joy of enlisting in a task which broadens the life-horizon. Willing rising to the occasion, or escape from narrow destiny.",
        "integrated": "readiness to respond to unexpected opportunities that expand one's field of service beyond personal concerns.",
        "stress": "Exaggeration of minor incidents to escape responsibilities and restless discontent with normal social obligations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_01",
      "sign": "libra",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "PIERCED BY A DART OF LIGHT A BUTTERFLY IS \"MADE PERFECT\"",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The symbolical death that is initiation into spiritual reality and wisdom. Sudden awakening. Coming for inner light.",
        "integrated": "transformative insight that elevates consciousness to a higher plane of understanding and being.",
        "stress": "Spiritual pretension based on superficial experiences and vulnerability to harmful psychic influences."
      },
      "optionText": {
        "default": "The symbolical death that is initiation into spiritual reality and wisdom. Sudden awakening. Coming for inner light.",
        "integrated": "transformative insight that elevates consciousness to a higher plane of understanding and being.",
        "stress": "Spiritual pretension based on superficial experiences and vulnerability to harmful psychic influences."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_02",
      "sign": "libra",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "A SYMPHONY IS PLAYED DRAMATIZING MAN'S HEROIC ASCENT",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Inspiration through creative identification with the large sweep of cycles. Spiritual expansion. Renewed encouragement.",
        "integrated": "exceptional capacity to harmonize diverse elements of experience into a unified and uplifting vision.",
        "stress": "Grandiose self-dramatization and emotional indulgence in idealistic fantasies without practical foundation."
      },
      "optionText": {
        "default": "Inspiration through creative identification with the large sweep of cycles. Spiritual expansion. Renewed encouragement.",
        "integrated": "exceptional capacity to harmonize diverse elements of experience into a unified and uplifting vision.",
        "stress": "Grandiose self-dramatization and emotional indulgence in idealistic fantasies without practical foundation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_03",
      "sign": "libra",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "A NEW DAY DAWNS, REVEALING A WORLD UTTERLY TRANSFORMED",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Transforming power of periods of silence and darkness, which lead to stirring revelations. Real touch with cosmic process.",
        "integrated": "exceptional readiness for seizing opportunity in moments of radical transformation and renewal.",
        "stress": "Disorientation in the face of change and an inability to recognize the underlying patterns of continuity."
      },
      "optionText": {
        "default": "Transforming power of periods of silence and darkness, which lead to stirring revelations. Real touch with cosmic process.",
        "integrated": "exceptional readiness for seizing opportunity in moments of radical transformation and renewal.",
        "stress": "Disorientation in the face of change and an inability to recognize the underlying patterns of continuity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_04",
      "sign": "libra",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "PILGRIMS GATHER ROUND CAMP-FIRE, IN SILENT COMMUNION",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Fellowship of higher ideals that sustains the individuals on their arduous path to Reality. Mellow participation in life.",
        "integrated": "profound spiritual companionship that transcends words and sustains individuals on their unique paths.",
        "stress": "Dependency on group support that substitutes for inner strength and retreat from genuine social engagement."
      },
      "optionText": {
        "default": "Fellowship of higher ideals that sustains the individuals on their arduous path to Reality. Mellow participation in life.",
        "integrated": "profound spiritual companionship that transcends words and sustains individuals on their unique paths.",
        "stress": "Dependency on group support that substitutes for inner strength and retreat from genuine social engagement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_05",
      "sign": "libra",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "INSPIRED DISCIPLES LISTEN TO THE WORDS OF THEIR TEACHER",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Knowledge and experience put to the test. Greatness calling its own to itself. Ordered seeking. Distrust of appearances.",
        "integrated": "receptive intelligence that recognizes authentic wisdom and assimilates higher teachings with discernment.",
        "stress": "Uncritical acceptance of authority and substitution of doctrinal adherence for genuine spiritual understanding."
      },
      "optionText": {
        "default": "Knowledge and experience put to the test. Greatness calling its own to itself. Ordered seeking. Distrust of appearances.",
        "integrated": "receptive intelligence that recognizes authentic wisdom and assimilates higher teachings with discernment.",
        "stress": "Uncritical acceptance of authority and substitution of doctrinal adherence for genuine spiritual understanding."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_06",
      "sign": "libra",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "IN A TRANCE, A PILGRIM BEHOLDS HIS IDEALS MADE CONCRETE",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Inevitable confrontation with the concrete results of one's ideals. Lessons to be learned from it. Willingness of heart.",
        "integrated": "visionary capacity that translates abstract ideals into tangible manifestations through sustained devotion.",
        "stress": "Self-deluding imagination that mistakes subjective fantasies for objective realities and avoids practical tests."
      },
      "optionText": {
        "default": "Inevitable confrontation with the concrete results of one's ideals. Lessons to be learned from it. Willingness of heart.",
        "integrated": "visionary capacity that translates abstract ideals into tangible manifestations through sustained devotion.",
        "stress": "Self-deluding imagination that mistakes subjective fantasies for objective realities and avoids practical tests."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_07",
      "sign": "libra",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "WITCH FEEDS CHICKENS FRIGHTENED BY A HAWK SHE HAD TAMED",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Control of natural forces by the higher intelligence. Taming the strong, uplifting the weak. Transmutation through service.",
        "integrated": "masterful diplomacy in reconciling opposing forces and transforming threatening situations into beneficial ones.",
        "stress": "Manipulation of circumstances for personal power and an unhealthy enjoyment of others' fear and dependency."
      },
      "optionText": {
        "default": "Control of natural forces by the higher intelligence. Taming the strong, uplifting the weak. Transmutation through service.",
        "integrated": "masterful diplomacy in reconciling opposing forces and transforming threatening situations into beneficial ones.",
        "stress": "Manipulation of circumstances for personal power and an unhealthy enjoyment of others' fear and dependency."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_08",
      "sign": "libra",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "A FIREPLACE BLAZES MYSTERIOUSLY IN A DESERTED FARMHOUSE",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Constant presence of unseen, sustaining agencies in every worthwhile activity. Great depth of initial effort. Providence.",
        "integrated": "enduring spiritual presence that continues to inspire and warm long after the originators have departed.",
        "stress": "Misplaced trust in supernatural interventions and neglect of practical responsibilities for maintaining one's creations."
      },
      "optionText": {
        "default": "Constant presence of unseen, sustaining agencies in every worthwhile activity. Great depth of initial effort. Providence.",
        "integrated": "enduring spiritual presence that continues to inspire and warm long after the originators have departed.",
        "stress": "Misplaced trust in supernatural interventions and neglect of practical responsibilities for maintaining one's creations."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_09",
      "sign": "libra",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "THREE \"OLD MASTERS\" HANG ALONE IN AN ART GALLERY",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Efficient cohesion of the three 'souls' of man; of mind, feeling and instinct. Integrated wisdom. Sagacious behavior.",
        "integrated": "profound integration of diverse aspects of consciousness resulting in enduring creative expression.",
        "stress": "Excessive reverence for past achievements at the expense of living creativity and fragmentation of inner faculties."
      },
      "optionText": {
        "default": "Efficient cohesion of the three 'souls' of man; of mind, feeling and instinct. Integrated wisdom. Sagacious behavior.",
        "integrated": "profound integration of diverse aspects of consciousness resulting in enduring creative expression.",
        "stress": "Excessive reverence for past achievements at the expense of living creativity and fragmentation of inner faculties."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_10",
      "sign": "libra",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "A CANOE LEAVING NARROW RAPIDS REACHES CALM WATERS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The reward of all sincere and daring outreaching of self in life. A sure Destiny. Reliance upon skill and circumstances.",
        "integrated": "skillful navigation through challenging transitions that leads to deserved periods of tranquility and integration.",
        "stress": "Premature relaxation after challenge and failure to consolidate the lessons of difficult experiences."
      },
      "optionText": {
        "default": "The reward of all sincere and daring outreaching of self in life. A sure Destiny. Reliance upon skill and circumstances.",
        "integrated": "skillful navigation through challenging transitions that leads to deserved periods of tranquility and integration.",
        "stress": "Premature relaxation after challenge and failure to consolidate the lessons of difficult experiences."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_11",
      "sign": "libra",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "KINDLY OLD PROFESSOR IS TEACHING A CLASS OF YOUNGSTERS",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Cooperation of genuinely superior agencies with beings less evolved. Glad willingness to assist and protect. Kindliness.",
        "integrated": "generous transmission of accumulated wisdom without condescension and gentle guidance that respects developmental stages.",
        "stress": "Intellectual arrogance masked as benevolence and imposition of limiting perspectives upon impressionable minds."
      },
      "optionText": {
        "default": "Cooperation of genuinely superior agencies with beings less evolved. Glad willingness to assist and protect. Kindliness.",
        "integrated": "generous transmission of accumulated wisdom without condescension and gentle guidance that respects developmental stages.",
        "stress": "Intellectual arrogance masked as benevolence and imposition of limiting perspectives upon impressionable minds."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_12",
      "sign": "libra",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "MINERS ARE EMERGING FROM A DEEP WELL INTO THE SUNLIGHT",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Depth of participation in the world's work. Whole-souled giving of self to service; or inability to bring self to effort.",
        "integrated": "profound dedication to excavating hidden resources that brings illuminating rewards and renewal.",
        "stress": "Exhausting labor that lacks higher purpose and reluctance to fully engage with the demanding aspects of reality."
      },
      "optionText": {
        "default": "Depth of participation in the world's work. Whole-souled giving of self to service; or inability to bring self to effort.",
        "integrated": "profound dedication to excavating hidden resources that brings illuminating rewards and renewal.",
        "stress": "Exhausting labor that lacks higher purpose and reluctance to fully engage with the demanding aspects of reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_13",
      "sign": "libra",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "CHILDREN ARE BLOWING SOAP-BUBBLES AT A YOUNGSTERS' PARTY",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Healthy stimulation through play and joy of human intercourse. Creative fantasy; spinning of idle dreams. Relaxation.",
        "integrated": "wise recognition of natural cycles of activity and rest, allowing regeneration after productive effort.",
        "stress": "Indolent self-indulgence based on privilege and exploitation of others' labor without contributing equivalent value."
      },
      "optionText": {
        "default": "Healthy stimulation through play and joy of human intercourse. Creative fantasy; spinning of idle dreams. Relaxation.",
        "integrated": "wise recognition of natural cycles of activity and rest, allowing regeneration after productive effort.",
        "stress": "Indolent self-indulgence based on privilege and exploitation of others' labor without contributing equivalent value."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "libra_14",
      "sign": "libra",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "RICH LAND-OWNER TAKES A SIESTA IN HIS TROPICAL GARDENS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Proper adjustment to the rhythm of nature. Faith in the ordered scheme of things; injudicious dependence upon others.",
        "integrated": "Proper adjustment to the rhythm of nature.",
        "stress": "Faith in the ordered scheme of things; injudicious dependence upon others."
      },
      "optionText": {
        "default": "Proper adjustment to the rhythm of nature. Faith in the ordered scheme of things; injudicious dependence upon others.",
        "integrated": "Proper adjustment to the rhythm of nature.",
        "stress": "Faith in the ordered scheme of things; injudicious dependence upon others."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_15",
      "sign": "libra",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 13: LIBRA 1-15: THE SPAN OF EXPECTATION",
      "image": "A STACK OF MACHINERY PARTS; ALL ARE NEW AND ALL CIRCULAR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Perfect and effortless participation in the universal order. Smooth approach to self-expression; inert self-satisfaction.",
        "integrated": "Perfect and effortless participation in the universal order.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Perfect and effortless participation in the universal order."
      },
      "optionText": {
        "default": "Perfect and effortless participation in the universal order. Smooth approach to self-expression; inert self-satisfaction.",
        "integrated": "Perfect and effortless participation in the universal order.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Perfect and effortless participation in the universal order."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_16",
      "sign": "libra",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "A HAPPY CREW IS RESTORING BEACH PIERS WRECKED BY STORMS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Constructive results of apparently destructive forces; stimulation to new accomplishment. Glad response to needed work.",
        "integrated": "Glad response to needed work.",
        "stress": "Constructive results of apparently destructive forces; stimulation to new accomplishment."
      },
      "optionText": {
        "default": "Constructive results of apparently destructive forces; stimulation to new accomplishment. Glad response to needed work.",
        "integrated": "Glad response to needed work.",
        "stress": "Constructive results of apparently destructive forces; stimulation to new accomplishment."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_17",
      "sign": "libra",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "RETIRED SEA-CAPTAIN IN UNIFORM WATCHES SHIPS SAIL AWAY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Vicarious or mellow participation in life. Transfer of activity from physical to mental; or self-involvement in the past.",
        "integrated": "Vicarious or mellow participation in life.",
        "stress": "mellow participation in life. Transfer of activity from physical to mental; or self-involvement in the past."
      },
      "optionText": {
        "default": "Vicarious or mellow participation in life. Transfer of activity from physical to mental; or self-involvement in the past.",
        "integrated": "Vicarious or mellow participation in life.",
        "stress": "mellow participation in life. Transfer of activity from physical to mental; or self-involvement in the past."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_18",
      "sign": "libra",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "TWO MEN PLACED UNDER ARREST ARE BEING BROUGHT TO COURT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Responsibility of individual to society in terms of normal behavior. Return to values. Obligation to face objective facts.",
        "integrated": "Responsibility of individual to society in terms of normal behavior.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Responsibility of individual to society in terms of normal behavior."
      },
      "optionText": {
        "default": "Responsibility of individual to society in terms of normal behavior. Return to values. Obligation to face objective facts.",
        "integrated": "Responsibility of individual to society in terms of normal behavior.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Responsibility of individual to society in terms of normal behavior."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_19",
      "sign": "libra",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "ROBBERS ARE HIDING, READY TO ATTACK HEAVILY ARMED CARAVAN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Protest against the perpetuation of unearned social privileges and wealth. Repudiation of bondage. Challenge to custom.",
        "integrated": "Protest against the perpetuation of unearned social privileges and wealth.",
        "stress": "Repudiation of bondage."
      },
      "optionText": {
        "default": "Protest against the perpetuation of unearned social privileges and wealth. Repudiation of bondage. Challenge to custom.",
        "integrated": "Protest against the perpetuation of unearned social privileges and wealth.",
        "stress": "Repudiation of bondage."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_20",
      "sign": "libra",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "OLD RABBI SITS CONTENTEDLY IN ROOM CROWDED WITH BOOKS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Interest in permanent rather than transient values. Accumulation of ancient wisdom brought to use. Competent service.",
        "integrated": "Interest in permanent rather than transient values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Interest in permanent rather than transient values."
      },
      "optionText": {
        "default": "Interest in permanent rather than transient values. Accumulation of ancient wisdom brought to use. Competent service.",
        "integrated": "Interest in permanent rather than transient values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Interest in permanent rather than transient values."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_21",
      "sign": "libra",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "HOT SUNDAY CROWDS DELIGHT IN THE COOL SEA BREEZE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fundamental popularity of natural values. Communion in objects of real and universally recognized worth. Association.",
        "integrated": "Fundamental popularity of natural values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Fundamental popularity of natural values."
      },
      "optionText": {
        "default": "Fundamental popularity of natural values. Communion in objects of real and universally recognized worth. Association.",
        "integrated": "Fundamental popularity of natural values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Fundamental popularity of natural values."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_22",
      "sign": "libra",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "CHILD LAUGHS AS BIRDS PERCH ON AN OLD FOUNTAIN, AND DRINK",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Intuitive understanding of simple souls in spiritual matters. Youthful life-enjoyment. Fresh grasp of the soul's needs.",
        "integrated": "Intuitive understanding of simple souls in spiritual matters.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Intuitive understanding of simple souls in spiritual matters."
      },
      "optionText": {
        "default": "Intuitive understanding of simple souls in spiritual matters. Youthful life-enjoyment. Fresh grasp of the soul's needs.",
        "integrated": "Intuitive understanding of simple souls in spiritual matters.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Intuitive understanding of simple souls in spiritual matters."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_23",
      "sign": "libra",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "CHANTICLEER SALUTES THE RISING SUN WITH EXUBERANT TONES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity for self-refreshment at the inner sources of ever-reviewed life. Anticipation of opportunity. Security in Self.",
        "integrated": "Capacity for self-refreshment at the inner sources of ever-reviewed life.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Capacity for self-refreshment at the inner sources of ever-reviewed life."
      },
      "optionText": {
        "default": "Capacity for self-refreshment at the inner sources of ever-reviewed life. Anticipation of opportunity. Security in Self.",
        "integrated": "Capacity for self-refreshment at the inner sources of ever-reviewed life.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Capacity for self-refreshment at the inner sources of ever-reviewed life."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_24",
      "sign": "libra",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "A BUTTERFLY SPREADS ITS WINGS, SHOWING AN EXTRA LEFT ONE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Potentiality of new forms and opportunities in every life. Instinctive expansion of self; or submergence in the not-self.",
        "integrated": "Potentiality of new forms and opportunities in every life.",
        "stress": "submergence in the not-self."
      },
      "optionText": {
        "default": "Potentiality of new forms and opportunities in every life. Instinctive expansion of self; or submergence in the not-self.",
        "integrated": "Potentiality of new forms and opportunities in every life.",
        "stress": "submergence in the not-self."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_25",
      "sign": "libra",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "FALLING GOLDEN LEAF TEACHES LIFE TO REBELLIOUS SCHOOLBOY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Discovery of deeper elements of wisdom after intellectual knowledge wearies. Growth through awareness of basic meanings.",
        "integrated": "Discovery of deeper elements of wisdom after intellectual knowledge wearies.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Discovery of deeper elements of wisdom after intellectual knowledge wearies."
      },
      "optionText": {
        "default": "Discovery of deeper elements of wisdom after intellectual knowledge wearies. Growth through awareness of basic meanings.",
        "integrated": "Discovery of deeper elements of wisdom after intellectual knowledge wearies.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Discovery of deeper elements of wisdom after intellectual knowledge wearies."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_26",
      "sign": "libra",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "AN EAGLE AND A WHITE DOVE CHANGE SWIFTLY INTO EACH OTHER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Necessary cooperation between mind, will, spirit and heart, love. Power of psychological balance and compensation. Unity.",
        "integrated": "Necessary cooperation between mind, will, spirit and heart, love.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Necessary cooperation between mind, will, spirit and heart, love."
      },
      "optionText": {
        "default": "Necessary cooperation between mind, will, spirit and heart, love. Power of psychological balance and compensation. Unity.",
        "integrated": "Necessary cooperation between mind, will, spirit and heart, love.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Necessary cooperation between mind, will, spirit and heart, love."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_27",
      "sign": "libra",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "A SPOT OF LIGHT IN CLEAR SKIES, AN AEROPLANE SAILS CALMLY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Dwelling above the normal stress of existence. Superior mental vision. Calm objective observation; quiet inner strength.",
        "integrated": "Dwelling above the normal stress of existence.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Dwelling above the normal stress of existence."
      },
      "optionText": {
        "default": "Dwelling above the normal stress of existence. Superior mental vision. Calm objective observation; quiet inner strength.",
        "integrated": "Dwelling above the normal stress of existence.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Dwelling above the normal stress of existence."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_28",
      "sign": "libra",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "A MAN IN DEEP GLOOM. UNNOTICED, ANGELS COME TO HIS HELP",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Spiritual sustainment given to him who opens himself to his full destiny. Slow realization of betterment. Unsolicited help.",
        "integrated": "Spiritual sustainment given to him who opens himself to his full destiny.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Spiritual sustainment given to him who opens himself to his full destiny."
      },
      "optionText": {
        "default": "Spiritual sustainment given to him who opens himself to his full destiny. Slow realization of betterment. Unsolicited help.",
        "integrated": "Spiritual sustainment given to him who opens himself to his full destiny.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Spiritual sustainment given to him who opens himself to his full destiny."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_29",
      "sign": "libra",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "VAST MASSES OF MEN PUSH FORWARD REACHING FOR KNOWLEDGE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Intense desire to overcome the blind life of passion and to uplift others. Intellectual vision. Tense mental outreaching.",
        "integrated": "Intense desire to overcome the blind life of passion and to uplift others.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Intense desire to overcome the blind life of passion and to uplift others."
      },
      "optionText": {
        "default": "Intense desire to overcome the blind life of passion and to uplift others. Intellectual vision. Tense mental outreaching.",
        "integrated": "Intense desire to overcome the blind life of passion and to uplift others.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Intense desire to overcome the blind life of passion and to uplift others."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "libra_30",
      "sign": "libra",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 14: LIBRA 16-30: THE SPAN OF REVELATION",
      "image": "A PHRENOLOGIST DISCOVERS MOUNDS OF KNOWLEDGE ON A HEAD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Ability to read spiritual meanings in concrete objects. Objectification of abstract truths. Cleverness in understanding.",
        "integrated": "Ability to read spiritual meanings in concrete objects.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Ability to read spiritual meanings in concrete objects."
      },
      "optionText": {
        "default": "Ability to read spiritual meanings in concrete objects. Objectification of abstract truths. Cleverness in understanding.",
        "integrated": "Ability to read spiritual meanings in concrete objects.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Ability to read spiritual meanings in concrete objects."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_01",
      "sign": "scorpio",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "SIGHT-SEERS IN A BUS STRAIN TO SEE CROWDS AND BUILDINGS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The perspective which leisure gives to everyday affairs. Appetite for larger things. Seeing life as whole. Social Intercourse.",
        "integrated": "The perspective which leisure gives to everyday affairs.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The perspective which leisure gives to everyday affairs."
      },
      "optionText": {
        "default": "The perspective which leisure gives to everyday affairs. Appetite for larger things. Seeing life as whole. Social Intercourse.",
        "integrated": "The perspective which leisure gives to everyday affairs.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The perspective which leisure gives to everyday affairs."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_02",
      "sign": "scorpio",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "FROM A BROKEN BOTTLE TRACES OF PERFUME STILL EMANATE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The fine scent of deeds well done as it persists in the memory of men. Stimulating recollection. Spiritual immortality.",
        "integrated": "The fine scent of deeds well done as it persists in the memory of men.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The fine scent of deeds well done as it persists in the memory of men."
      },
      "optionText": {
        "default": "The fine scent of deeds well done as it persists in the memory of men. Stimulating recollection. Spiritual immortality.",
        "integrated": "The fine scent of deeds well done as it persists in the memory of men.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The fine scent of deeds well done as it persists in the memory of men."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_03",
      "sign": "scorpio",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "HAPPY HOUSE-RAISING PARTY AMONG WESTERN PIONEERS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The constructive sharing of experience which builds social values. Interchange of efforts. Necessity to learn cooperation.",
        "integrated": "The constructive sharing of experience which builds social values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The constructive sharing of experience which builds social values."
      },
      "optionText": {
        "default": "The constructive sharing of experience which builds social values. Interchange of efforts. Necessity to learn cooperation.",
        "integrated": "The constructive sharing of experience which builds social values.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The constructive sharing of experience which builds social values."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_04",
      "sign": "scorpio",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "YOUTH CARRIES A LIT CANDLE IN HIS FIRST CHURCH SERVICE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Beginning of spiritual participation in the world's work. Sustained inspiration. Conscious linkage to inner realities.",
        "integrated": "Beginning of spiritual participation in the world's work.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Beginning of spiritual participation in the world's work."
      },
      "optionText": {
        "default": "Beginning of spiritual participation in the world's work. Sustained inspiration. Conscious linkage to inner realities.",
        "integrated": "Beginning of spiritual participation in the world's work.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Beginning of spiritual participation in the world's work."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_05",
      "sign": "scorpio",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "A MASSIVE ROCKY SHORE UNCHANGED BY CENTURIES OF STORMS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Revelation of absolutely stable elements in all life. Strong confidence born of fundamental perception; or spiritual inertia.",
        "integrated": "Revelation of absolutely stable elements in all life.",
        "stress": "spiritual inertia."
      },
      "optionText": {
        "default": "Revelation of absolutely stable elements in all life. Strong confidence born of fundamental perception; or spiritual inertia.",
        "integrated": "Revelation of absolutely stable elements in all life.",
        "stress": "spiritual inertia."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_06",
      "sign": "scorpio",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "CALIFORNIAN HILLS: THE \"GOLD RUSH\" SHATTERS THEM PEACE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The passionate quest for universal values, destructive of cultural ease of living. Leaping to opportunity. Avid seeking.",
        "integrated": "Leaping to opportunity.",
        "stress": "The passionate quest for universal values, destructive of cultural ease of living."
      },
      "optionText": {
        "default": "The passionate quest for universal values, destructive of cultural ease of living. Leaping to opportunity. Avid seeking.",
        "integrated": "Leaping to opportunity.",
        "stress": "The passionate quest for universal values, destructive of cultural ease of living."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_07",
      "sign": "scorpio",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "DIVERS OF THE DEEP SEA ARE BEING LOWERED INTO THE WATERS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Purposeful, daring plunge into life-mysteries. Fulfillment of individual selfhood through study of unconscious energies.",
        "integrated": "unflinching courage in exploring the depths of experience and bringing hidden treasures to consciousness.",
        "stress": "Reckless self-endangerment through obsessive probing of psychological shadows without proper preparation."
      },
      "optionText": {
        "default": "Purposeful, daring plunge into life-mysteries. Fulfillment of individual selfhood through study of unconscious energies.",
        "integrated": "unflinching courage in exploring the depths of experience and bringing hidden treasures to consciousness.",
        "stress": "Reckless self-endangerment through obsessive probing of psychological shadows without proper preparation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_08",
      "sign": "scorpio",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "A HIGH MOUNTAIN LAKE IS BATHED IN THE FULL MOONLIGHT.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Illumination of the soul by transcendent wisdom. Quiet touch with cosmic strength; or wayward moody effort at greatness.",
        "integrated": "Illumination of the soul by transcendent wisdom.",
        "stress": "wayward moody effort at greatness."
      },
      "optionText": {
        "default": "Illumination of the soul by transcendent wisdom. Quiet touch with cosmic strength; or wayward moody effort at greatness.",
        "integrated": "Illumination of the soul by transcendent wisdom.",
        "stress": "wayward moody effort at greatness."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_09",
      "sign": "scorpio",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "A DENTIST IS REPAIRING TEETH RUINED BY CIVILIZED HABITS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self. Applied creativity.",
        "integrated": "Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self."
      },
      "optionText": {
        "default": "Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self. Applied creativity.",
        "integrated": "Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Mechanical inventiveness and control over nature needed to balance man's emphasis on mind and self."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_10",
      "sign": "scorpio",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 15: SCORPIO 1-15: THE SPAN OF RETENTION",
      "image": "A FELLOWSHIP SUPPER REAWAKENS UNFORGETTABLE INNER TIES.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Companionship rooted in past performance. Group-personality emergence. Fraternity of ...",
        "integrated": "Companionship rooted in past performance.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Companionship rooted in past performance."
      },
      "optionText": {
        "default": "Companionship rooted in past performance. Group-personality emergence. Fraternity of ...",
        "integrated": "Companionship rooted in past performance.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Companionship rooted in past performance."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_11",
      "sign": "scorpio",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "",
      "image": "A DROWNING PERSON BEING RESCUED",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Respond to crisis through rescue, survival, mutual aid, and the restoration of life.",
        "integrated": "Act decisively when someone or something genuinely needs to be brought back from the edge.",
        "stress": "Create or remain attached to crisis because being needed in emergencies becomes part of identity."
      },
      "optionText": {
        "default": "Respond to crisis through rescue, survival, mutual aid, and the restoration of life.",
        "integrated": "Act decisively when someone or something genuinely needs to be brought back from the edge.",
        "stress": "Create or remain attached to crisis because being needed in emergencies becomes part of identity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_12",
      "sign": "scorpio",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "",
      "image": "AN EMBASSY BALL",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Navigate powerful differences through diplomacy, protocol, social intelligence, and strategic civility.",
        "integrated": "Create workable relationship across boundaries without pretending the differences do not exist.",
        "stress": "Hide conflict behind performance, politeness, status, or carefully managed appearances."
      },
      "optionText": {
        "default": "Navigate powerful differences through diplomacy, protocol, social intelligence, and strategic civility.",
        "integrated": "Create workable relationship across boundaries without pretending the differences do not exist.",
        "stress": "Hide conflict behind performance, politeness, status, or carefully managed appearances."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_13",
      "sign": "scorpio",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "",
      "image": "AN INVENTOR EXPERIMENTING",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Probe a difficult problem through experimentation until a new mechanism or solution appears.",
        "integrated": "Persist with inventive trials and learn directly from what fails.",
        "stress": "Become consumed by experimentation, novelty, or control without knowing when the problem is solved."
      },
      "optionText": {
        "default": "Probe a difficult problem through experimentation until a new mechanism or solution appears.",
        "integrated": "Persist with inventive trials and learn directly from what fails.",
        "stress": "Become consumed by experimentation, novelty, or control without knowing when the problem is solved."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_14",
      "sign": "scorpio",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "",
      "image": "A TELEPHONE LINEMAN AT WORK",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Maintain the channels that allow separated people, systems, or realities to communicate.",
        "integrated": "Repair broken connections and keep information moving under difficult conditions.",
        "stress": "Take responsibility for every broken connection or become preoccupied with monitoring communication."
      },
      "optionText": {
        "default": "Maintain the channels that allow separated people, systems, or realities to communicate.",
        "integrated": "Repair broken connections and keep information moving under difficult conditions.",
        "stress": "Take responsibility for every broken connection or become preoccupied with monitoring communication."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_15",
      "sign": "scorpio",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "",
      "image": "CHILDREN PLAYING AROUND FIVE MOUNDS OF SAND",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Discover pattern and creative order by shaping basic materials together through play.",
        "integrated": "Turn elemental resources into a shared imaginative structure without losing spontaneity.",
        "stress": "Become absorbed in controlling the pattern, the group, or the game rather than participating in it."
      },
      "optionText": {
        "default": "Discover pattern and creative order by shaping basic materials together through play.",
        "integrated": "Turn elemental resources into a shared imaginative structure without losing spontaneity.",
        "stress": "Become absorbed in controlling the pattern, the group, or the game rather than participating in it."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_16",
      "sign": "scorpio",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "A GIRL WITH ARISTOCRATIC FEATURES SMILES ENTRANCINGLY.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Fervent outreaching of self in moments of the purest beauty. Leaping to meet the potentialities of life. Blossoming forth.",
        "integrated": "an exceptional gift for bringing forth the inner beauty and highest potential in every life situation.",
        "stress": "Superficial charm used to mask selfish intentions and avoid genuine emotional engagement."
      },
      "optionText": {
        "default": "Fervent outreaching of self in moments of the purest beauty. Leaping to meet the potentialities of life. Blossoming forth.",
        "integrated": "an exceptional gift for bringing forth the inner beauty and highest potential in every life situation.",
        "stress": "Superficial charm used to mask selfish intentions and avoid genuine emotional engagement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "scorpio_17",
      "sign": "scorpio",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "WOMAN, FECUNDATED BY HER SPIRIT, IS \"GREAT WITH CHLD\".",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fullness of self-reliance and individual destiny. Cooperation between spiritual and material agencies. Pure self-revelation.",
        "integrated": "Fullness of self-reliance and individual destiny.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Fullness of self-reliance and individual destiny."
      },
      "optionText": {
        "default": "Fullness of self-reliance and individual destiny. Cooperation between spiritual and material agencies. Pure self-revelation.",
        "integrated": "Fullness of self-reliance and individual destiny.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Fullness of self-reliance and individual destiny."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_18",
      "sign": "scorpio",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "A WINDING ROAD LEADS THROUGH GLORIOUS AUTUMNAL WOODS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The light which transfigures the soul after passions have faded away. Revelation of inner wealth. Radiant consummation.",
        "integrated": "The light which transfigures the soul after passions have faded away.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The light which transfigures the soul after passions have faded away."
      },
      "optionText": {
        "default": "The light which transfigures the soul after passions have faded away. Revelation of inner wealth. Radiant consummation.",
        "integrated": "The light which transfigures the soul after passions have faded away.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The light which transfigures the soul after passions have faded away."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_19",
      "sign": "scorpio",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "A WISE OLD PARROT REPEATS THE CONVERSATION HE OVERHEARD.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Dependence upon inner or outer environment for the substance of understanding. Transmission of knowledge. Channel-ship.",
        "integrated": "Transmission of knowledge.",
        "stress": "outer environment for the substance of understanding. Transmission of knowledge. Channel-ship."
      },
      "optionText": {
        "default": "Dependence upon inner or outer environment for the substance of understanding. Transmission of knowledge. Channel-ship.",
        "integrated": "Transmission of knowledge.",
        "stress": "outer environment for the substance of understanding. Transmission of knowledge. Channel-ship."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_20",
      "sign": "scorpio",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "WOMAN FLINGS OPEN DARK CURTAINS CLOSING SACRED PATHWAY.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Courage needed to enlarge sphere of being. Readiness to press beyond self. The \"woman\" within, opening the gates to Spirit.",
        "integrated": "Courage needed to enlarge sphere of being.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Courage needed to enlarge sphere of being."
      },
      "optionText": {
        "default": "Courage needed to enlarge sphere of being. Readiness to press beyond self. The \"woman\" within, opening the gates to Spirit.",
        "integrated": "Courage needed to enlarge sphere of being.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Courage needed to enlarge sphere of being."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_21",
      "sign": "scorpio",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "SOLDIER READY TO FACE CHARGES OF DESERTION FOR LOVE'S SAKE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Conflict between old and new perspectives. A willingness to face chaos for the sake of a new order. Yielding to emotions.",
        "integrated": "Conflict between old and new perspectives.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Conflict between old and new perspectives."
      },
      "optionText": {
        "default": "Conflict between old and new perspectives. A willingness to face chaos for the sake of a new order. Yielding to emotions.",
        "integrated": "Conflict between old and new perspectives.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Conflict between old and new perspectives."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_22",
      "sign": "scorpio",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "HUNTERS SHOOTING WILD DUCKS WALK THROUGH A MARSH.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Aggressive quest for outer or inner sustenance. Purposeful satiation of desire. Tragic incorporation of ideals. Exercise.",
        "integrated": "Aggressive quest for outer or inner sustenance.",
        "stress": "inner sustenance. Purposeful satiation of desire. Tragic incorporation of ideals. Exercise."
      },
      "optionText": {
        "default": "Aggressive quest for outer or inner sustenance. Purposeful satiation of desire. Tragic incorporation of ideals. Exercise.",
        "integrated": "Aggressive quest for outer or inner sustenance.",
        "stress": "inner sustenance. Purposeful satiation of desire. Tragic incorporation of ideals. Exercise."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_23",
      "sign": "scorpio",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "PLACID WHITE RABBIT METAMORPHOSES INTO A DANCING ELF.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Revelation of unexpected vital urges latent in all beings. Great creative potentialities. Capacity for self-maintenance.",
        "integrated": "Revelation of unexpected vital urges latent in all beings.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Revelation of unexpected vital urges latent in all beings."
      },
      "optionText": {
        "default": "Revelation of unexpected vital urges latent in all beings. Great creative potentialities. Capacity for self-maintenance.",
        "integrated": "Revelation of unexpected vital urges latent in all beings.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Revelation of unexpected vital urges latent in all beings."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_24",
      "sign": "scorpio",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "CROWDS, STIRRED BY A GREAT MESSAGE, RETURN HOME.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The power in well-formulated ideas to become actual facts. Practical inspiration; or else inability to face a vital challenge.",
        "integrated": "The power in well-formulated ideas to become actual facts.",
        "stress": "else inability to face a vital challenge."
      },
      "optionText": {
        "default": "The power in well-formulated ideas to become actual facts. Practical inspiration; or else inability to face a vital challenge.",
        "integrated": "The power in well-formulated ideas to become actual facts.",
        "stress": "else inability to face a vital challenge."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_25",
      "sign": "scorpio",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "THANKS TO A FINE X-RAY DIAGNOSIS, A MAN'S LIFE IS SAVED.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Penetrating power of reality. Dependence of outer facts upon basic structures or causes. Sharp and applied discrimination.",
        "integrated": "Penetrating power of reality.",
        "stress": "causes. Sharp and applied discrimination."
      },
      "optionText": {
        "default": "Penetrating power of reality. Dependence of outer facts upon basic structures or causes. Sharp and applied discrimination.",
        "integrated": "Penetrating power of reality.",
        "stress": "causes. Sharp and applied discrimination."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_26",
      "sign": "scorpio",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "SWIFTLY, INDIANS ERECT THEIR TEEPEES. CAMP IS BEING MADE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Ability to feel at home in any outer or inner environment. Efficient functioning. Retreating into the familiar and the known.",
        "integrated": "Ability to feel at home in any outer or inner environment.",
        "stress": "inner environment. Efficient functioning. Retreating into the familiar and the known."
      },
      "optionText": {
        "default": "Ability to feel at home in any outer or inner environment. Efficient functioning. Retreating into the familiar and the known.",
        "integrated": "Ability to feel at home in any outer or inner environment.",
        "stress": "inner environment. Efficient functioning. Retreating into the familiar and the known."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_27",
      "sign": "scorpio",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "A MILITARY BAND, FLASHY AND NOISY, MARCHES ON POMPOUSLY.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Desire to impress upon others the glory of one's social eminence. Materialization of normally subjective values. Show.",
        "integrated": "Desire to impress upon others the glory of one's social eminence.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Desire to impress upon others the glory of one's social eminence."
      },
      "optionText": {
        "default": "Desire to impress upon others the glory of one's social eminence. Materialization of normally subjective values. Show.",
        "integrated": "Desire to impress upon others the glory of one's social eminence.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Desire to impress upon others the glory of one's social eminence."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_28",
      "sign": "scorpio",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "THE KING OF FAIRYLAND IS SOLEMNLY WELCOMED TO MS REALM.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Necessary respect for symbolic values holding vital forces integrated. Self-realization through devotion to the One.",
        "integrated": "Necessary respect for symbolic values holding vital forces integrated.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Necessary respect for symbolic values holding vital forces integrated."
      },
      "optionText": {
        "default": "Necessary respect for symbolic values holding vital forces integrated. Self-realization through devotion to the One.",
        "integrated": "Necessary respect for symbolic values holding vital forces integrated.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Necessary respect for symbolic values holding vital forces integrated."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_29",
      "sign": "scorpio",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "PRINCESS PLEADS BEFORE INCA KING FOR HER CAPTURED SONS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The sour mediation between spirit and matter. Sustaining power of instincts. Self-awakening to the need for action.",
        "integrated": "The sour mediation between spirit and matter.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The sour mediation between spirit and matter."
      },
      "optionText": {
        "default": "The sour mediation between spirit and matter. Sustaining power of instincts. Self-awakening to the need for action.",
        "integrated": "The sour mediation between spirit and matter.",
        "stress": "Overidentify with this pattern or apply it too rigidly: The sour mediation between spirit and matter."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "scorpio_30",
      "sign": "scorpio",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 16: SCORPIO 16-30: THE SPAN OF APPRECIATION",
      "image": "HALLOWE'EN GIVES SOCIAL RELEASE TO YOUTHFUL IMPISHNESS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Need for giving free rein to unsocial instincts within the pale of social traditions. Planned release of inner pressure.",
        "integrated": "Need for giving free rein to unsocial instincts within the pale of social traditions.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Need for giving free rein to unsocial instincts within the pale of social traditions."
      },
      "optionText": {
        "default": "Need for giving free rein to unsocial instincts within the pale of social traditions. Planned release of inner pressure.",
        "integrated": "Need for giving free rein to unsocial instincts within the pale of social traditions.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Need for giving free rein to unsocial instincts within the pale of social traditions."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "sagittarius_01",
      "sign": "sagittarius",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "",
      "image": "RETIRED ARMY VETERANS GATHER TO REAWAKEN OLD MEMORIES",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "Efforts to perpetuate the memory of collective spiritual combat against the forces of greed and passion. Fellowship of experience.",
        "integrated": "meaningful preservation of shared hardships that forged character and created lasting bonds of understanding.",
        "stress": "Obsession with past glories that prevents adaptation to present circumstances and romanticization of conflict."
      },
      "optionText": {
        "default": "Efforts to perpetuate the memory of collective spiritual combat against the forces of greed and passion. Fellowship of experience.",
        "integrated": "meaningful preservation of shared hardships that forged character and created lasting bonds of understanding.",
        "stress": "Obsession with past glories that prevents adaptation to present circumstances and romanticization of conflict."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_02",
      "sign": "sagittarius",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "",
      "image": "WHITE-CAPPED WAVES DISPLAY THE POWER OF WIND OVER SEA",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The mobilization of unconscious energies under the pressure of super-conscious forces. Transmutation of primal drives.",
        "integrated": "dynamic interaction between higher directing forces and responsive elemental energies creating visible manifestation.",
        "stress": "Agitation without purpose and turbulence that dissipates energy rather than channeling it constructively."
      },
      "optionText": {
        "default": "The mobilization of unconscious energies under the pressure of super-conscious forces. Transmutation of primal drives.",
        "integrated": "dynamic interaction between higher directing forces and responsive elemental energies creating visible manifestation.",
        "stress": "Agitation without purpose and turbulence that dissipates energy rather than channeling it constructively."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_03",
      "sign": "sagittarius",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "",
      "image": "TWO MEN PLAYING CHESS",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The transcendent ritualization of conflict. Pure mental challenge and strategic thinking. The conquest of space.",
        "integrated": "masterful engagement with complex situations through disciplined thought and respectful competition.",
        "stress": "Excessive intellectualization of life's struggles and reduction of vital issues to abstract game-playing."
      },
      "optionText": {
        "default": "The transcendent ritualization of conflict. Pure mental challenge and strategic thinking. The conquest of space.",
        "integrated": "masterful engagement with complex situations through disciplined thought and respectful competition.",
        "stress": "Excessive intellectualization of life's struggles and reduction of vital issues to abstract game-playing."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_04",
      "sign": "sagittarius",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "",
      "image": "A LITTLE CHILD LEARNING TO WALK WITH THE ENCOURAGEMENT OF PARENTS",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "Overcoming of difficulties with the help of those who are already well-established in the cultural ways of human progress.",
        "integrated": "support for necessary developmental challenges that balances protection with encouragement of independence.",
        "stress": "Prolonged dependency that prevents natural growth and excessive caution that limits exploration of potential."
      },
      "optionText": {
        "default": "Overcoming of difficulties with the help of those who are already well-established in the cultural ways of human progress.",
        "integrated": "support for necessary developmental challenges that balances protection with encouragement of independence.",
        "stress": "Prolonged dependency that prevents natural growth and excessive caution that limits exploration of potential."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_05",
      "sign": "sagittarius",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "",
      "image": "AN OLD OWL SITS ALONE ON THE BRANCH OF A LARGE TREE",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "Knowledge and detachment gained through a multitude of experiences. Wisdom born of darkness. Superior night vision.",
        "integrated": "profound understanding achieved through patient observation and solitary contemplation of life's mysteries.",
        "stress": "Isolated aloofness that prevents genuine engagement and gloomy pessimism masquerading as wisdom."
      },
      "optionText": {
        "default": "Knowledge and detachment gained through a multitude of experiences. Wisdom born of darkness. Superior night vision.",
        "integrated": "profound understanding achieved through patient observation and solitary contemplation of life's mysteries.",
        "stress": "Isolated aloofness that prevents genuine engagement and gloomy pessimism masquerading as wisdom."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_06",
      "sign": "sagittarius",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "",
      "image": "A GAME OF CRICKET",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The development of skill in group-situations testing collective goals. Social integration through competition. Fair play.",
        "integrated": "mastery of complex social interactions through adherence to tradition and cultivation of excellence.",
        "stress": "Rigid conformity to arbitrary rules and obsession with trivial competitions at the expense of genuine development."
      },
      "optionText": {
        "default": "The development of skill in group-situations testing collective goals. Social integration through competition. Fair play.",
        "integrated": "mastery of complex social interactions through adherence to tradition and cultivation of excellence.",
        "stress": "Rigid conformity to arbitrary rules and obsession with trivial competitions at the expense of genuine development."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_07",
      "sign": "sagittarius",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "",
      "image": "CUPID KNOCKS AT THE DOOR OF A HUMAN HEART",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The call of love and romance. Opening of self to higher emotional fulfillment. Activation of deeper feelings.",
        "integrated": "spontaneous awakening to life's most precious experiences through receptivity to love's transformative power.",
        "stress": "Sentimental idealization of relationships and vulnerability to emotional manipulation through desire for connection."
      },
      "optionText": {
        "default": "The call of love and romance. Opening of self to higher emotional fulfillment. Activation of deeper feelings.",
        "integrated": "spontaneous awakening to life's most precious experiences through receptivity to love's transformative power.",
        "stress": "Sentimental idealization of relationships and vulnerability to emotional manipulation through desire for connection."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_08",
      "sign": "sagittarius",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "",
      "image": "WITHIN THE DEPTHS OF THE EARTH NEW ELEMENTS ARE BEING FORMED",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "Creative gestation of new potentials under pressure. Alchemical transformation. Preparation for future manifestation.",
        "integrated": "profound inner development occurring beneath the surface of awareness that eventually transforms reality.",
        "stress": "Hidden destructive processes and pressurized conditions that create instability rather than valuable crystallization."
      },
      "optionText": {
        "default": "Creative gestation of new potentials under pressure. Alchemical transformation. Preparation for future manifestation.",
        "integrated": "profound inner development occurring beneath the surface of awareness that eventually transforms reality.",
        "stress": "Hidden destructive processes and pressurized conditions that create instability rather than valuable crystallization."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_09",
      "sign": "sagittarius",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "",
      "image": "A MOTHER LEADS HER SMALL CHILD STEP BY STEP UP A STEEP STAIRWAY",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The need in any social situation to assist the less evolved to attain a higher level of self-consciousness and achievement.",
        "integrated": "patient guidance through sequential stages of development with careful attention to individual readiness.",
        "stress": "Imposition of advancement beyond natural capacity and excessive control that prevents self-directed learning."
      },
      "optionText": {
        "default": "The need in any social situation to assist the less evolved to attain a higher level of self-consciousness and achievement.",
        "integrated": "patient guidance through sequential stages of development with careful attention to individual readiness.",
        "stress": "Imposition of advancement beyond natural capacity and excessive control that prevents self-directed learning."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_10",
      "sign": "sagittarius",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "",
      "image": "A THEATRICAL REPRESENTATION OF A GOLDEN-HAIRED GODDESS OF OPPORTUNITY",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "Society's efforts to maintain faith in life's rewards for the righteous. Public celebration of spiritual values. Inspiration.",
        "integrated": "dramatic embodiment of cultural ideals that energizes collective aspiration and individual striving.",
        "stress": "Empty symbolism divorced from authentic spiritual realization and artificial displays of virtue without substance."
      },
      "optionText": {
        "default": "Society's efforts to maintain faith in life's rewards for the righteous. Public celebration of spiritual values. Inspiration.",
        "integrated": "dramatic embodiment of cultural ideals that energizes collective aspiration and individual striving.",
        "stress": "Empty symbolism divorced from authentic spiritual realization and artificial displays of virtue without substance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_11",
      "sign": "sagittarius",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "",
      "image": "IN THE LEFT SECTION OF AN ARCHAIC TEMPLE, A LAMP BURNS IN A CONTAINER SHAPED LIKE A HUMAN BODY",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The value of the body as a temple of transcendent forces. Sacred integration of spirit with its physical vessel. Illumination.",
        "integrated": "profound reverence for the physical form as vehicle for spiritual light and respect for its intrinsic wisdom.",
        "stress": "Obsessive focus on bodily processes without spiritual connection and materialistic reduction of consciousness."
      },
      "optionText": {
        "default": "The value of the body as a temple of transcendent forces. Sacred integration of spirit with its physical vessel. Illumination.",
        "integrated": "profound reverence for the physical form as vehicle for spiritual light and respect for its intrinsic wisdom.",
        "stress": "Obsessive focus on bodily processes without spiritual connection and materialistic reduction of consciousness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_12",
      "sign": "sagittarius",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "",
      "image": "A FLAG THAT TURNS INTO AN EAGLE THAT CROWS",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The dynamic incorporation of new social values in individuals who exemplify the spiritual potential of the community.",
        "integrated": "transformative embodiment of collective ideals into living demonstration that inspires further evolution.",
        "stress": "Bombastic nationalism substituting for genuine spiritual authority and distortion of cultural symbols for personal aggrandizement."
      },
      "optionText": {
        "default": "The dynamic incorporation of new social values in individuals who exemplify the spiritual potential of the community.",
        "integrated": "transformative embodiment of collective ideals into living demonstration that inspires further evolution.",
        "stress": "Bombastic nationalism substituting for genuine spiritual authority and distortion of cultural symbols for personal aggrandizement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_13",
      "sign": "sagittarius",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "",
      "image": "A WIDOW'S PAST IS BROUGHT TO LIGHT",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The karma of past actions affecting present spiritual status. Revelation of hidden aspects of experience. Accountability.",
        "integrated": "honest confrontation with the consequences of previous choices that enables genuine liberation from them.",
        "stress": "Invasive scrutiny of others' private affairs and clinging to grievances rather than embracing new possibilities."
      },
      "optionText": {
        "default": "The karma of past actions affecting present spiritual status. Revelation of hidden aspects of experience. Accountability.",
        "integrated": "honest confrontation with the consequences of previous choices that enables genuine liberation from them.",
        "stress": "Invasive scrutiny of others' private affairs and clinging to grievances rather than embracing new possibilities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_14",
      "sign": "sagittarius",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "",
      "image": "THE PYRAMIDS AND THE SPHINX",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The enduring power of mankind's achievements which outlive those who created them. The immortality of spiritual values.",
        "integrated": "monumental expression of transpersonal wisdom that transcends individual mortality through enduring forms.",
        "stress": "Obsession with creating imperishable monuments to ego and rigid preservation of outdated cultural expressions."
      },
      "optionText": {
        "default": "The enduring power of mankind's achievements which outlive those who created them. The immortality of spiritual values.",
        "integrated": "monumental expression of transpersonal wisdom that transcends individual mortality through enduring forms.",
        "stress": "Obsession with creating imperishable monuments to ego and rigid preservation of outdated cultural expressions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_15",
      "sign": "sagittarius",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "",
      "image": "THE GROUND HOG LOOKING FOR ITS SHADOW ON GROUND-HOG DAY",
      "source": {
        "type": "supplied_secondary",
        "file": "sabian-interpretations.md"
      },
      "kernel": {
        "default": "The value of anticipating new turns of events and ascertaining future prospects through intuitive perception. Foresight.",
        "integrated": "sensitive attunement to natural cycles and appreciation for traditional wisdom about forthcoming conditions.",
        "stress": "Superstitious reliance on arbitrary omens and anxious concern with predicting outcomes rather than creating them."
      },
      "optionText": {
        "default": "The value of anticipating new turns of events and ascertaining future prospects through intuitive perception. Foresight.",
        "integrated": "sensitive attunement to natural cycles and appreciation for traditional wisdom about forthcoming conditions.",
        "stress": "Superstitious reliance on arbitrary omens and anxious concern with predicting outcomes rather than creating them."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_16",
      "sign": "sagittarius",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "A CALM OCEAN; A MOTIONLESS SHIP; LAZILY SOARING SEAGULLS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The moments of pause which sustain and presage change. Alert readiness to act; or distress at not knowing what lies ahead.",
        "integrated": "serene acceptance of temporary stillness that restores energy and clarity before the next phase of activity.",
        "stress": "Frustrating inertia and anxious uncertainty during necessary periods of suspended progress and motion."
      },
      "optionText": {
        "default": "The moments of pause which sustain and presage change. Alert readiness to act; or distress at not knowing what lies ahead.",
        "integrated": "serene acceptance of temporary stillness that restores energy and clarity before the next phase of activity.",
        "stress": "Frustrating inertia and anxious uncertainty during necessary periods of suspended progress and motion."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_17",
      "sign": "sagittarius",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "PEOPLE GATHER BEFORE DAWN FOR AN OUTDOOR EASTER SERVICE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Spiritual living in conformity to natural law. Coming out of doubt and despair. Unwavering faith in a near higher power.",
        "integrated": "communal anticipation of renewal that transcends individual concerns through shared celebration of rebirth.",
        "stress": "Ritualistic observances empty of genuine spiritual awakening and emotional dependency on collective religious experiences."
      },
      "optionText": {
        "default": "Spiritual living in conformity to natural law. Coming out of doubt and despair. Unwavering faith in a near higher power.",
        "integrated": "communal anticipation of renewal that transcends individual concerns through shared celebration of rebirth.",
        "stress": "Ritualistic observances empty of genuine spiritual awakening and emotional dependency on collective religious experiences."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_18",
      "sign": "sagittarius",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "ON THE HOT BEACH CHILDREN PLAY, PROTECTED BY SUNBONNETS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The protective agency which safeguards the free behavior of individuals. Vivifying contact with collective life-energies.",
        "integrated": "balanced exposure to powerful elemental forces with appropriate safeguards that prevent harm while allowing growth.",
        "stress": "Excessive protective measures that restrict natural development and failure to recognize genuine environmental hazards."
      },
      "optionText": {
        "default": "The protective agency which safeguards the free behavior of individuals. Vivifying contact with collective life-energies.",
        "integrated": "balanced exposure to powerful elemental forces with appropriate safeguards that prevent harm while allowing growth.",
        "stress": "Excessive protective measures that restrict natural development and failure to recognize genuine environmental hazards."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_19",
      "sign": "sagittarius",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "PELICANS, DISTURBED BY MEN, MOVE TO PLACES UNKNOWN.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Inward re-emphasis of foundations. Recuperation by retreating within. The introvert's escape. Moving about in reorientation.",
        "integrated": "instinctive withdrawal from disruptive influences to maintain integrity and find more conducive conditions.",
        "stress": "Hypersensitive retreat from necessary challenges and abandonment of established positions without clear direction."
      },
      "optionText": {
        "default": "Inward re-emphasis of foundations. Recuperation by retreating within. The introvert's escape. Moving about in reorientation.",
        "integrated": "instinctive withdrawal from disruptive influences to maintain integrity and find more conducive conditions.",
        "stress": "Hypersensitive retreat from necessary challenges and abandonment of established positions without clear direction."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_20",
      "sign": "sagittarius",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "MEN CUTTING THE ICE OF A FROZEN POND, FOR SUMMER USE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Depth of operation necessary to prepare for next phase of life. Sacrifice of present to future. Throughness of action.",
        "integrated": "far-sighted preparation that secures resources for anticipated future needs through present disciplined effort.",
        "stress": "Excessive concern with future contingencies at the expense of present enjoyment and depletion of natural reserves."
      },
      "optionText": {
        "default": "Depth of operation necessary to prepare for next phase of life. Sacrifice of present to future. Throughness of action.",
        "integrated": "far-sighted preparation that secures resources for anticipated future needs through present disciplined effort.",
        "stress": "Excessive concern with future contingencies at the expense of present enjoyment and depletion of natural reserves."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_21",
      "sign": "sagittarius",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "CHILD AND DOG PLAY GRAVELY, WITH EYEGLASSES ON THEM NOSES.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Usefulness of make-believe. Rising to situations through the imagination. Assuming a part ahead of natural development.",
        "integrated": "creative experimentation with roles and perspectives that fosters growth through playful exploration.",
        "stress": "Premature assumption of adult responsibilities and mimicry without genuine understanding of its significance."
      },
      "optionText": {
        "default": "Usefulness of make-believe. Rising to situations through the imagination. Assuming a part ahead of natural development.",
        "integrated": "creative experimentation with roles and perspectives that fosters growth through playful exploration.",
        "stress": "Premature assumption of adult responsibilities and mimicry without genuine understanding of its significance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_22",
      "sign": "sagittarius",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "THE SHOP CLOSED, CHINESE LAUNDRYMEN REVERT TO RACE TYPE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Retreat to the inner world of self after outer achievement. Safe return to ancestral patterns of behavior. Easy poise.",
        "integrated": "relaxation into natural cultural patterns after public performance and honoring of essential identity.",
        "stress": "Psychological compartmentalization that prevents authentic integration and retreat into rigid stereotypical behavior."
      },
      "optionText": {
        "default": "Retreat to the inner world of self after outer achievement. Safe return to ancestral patterns of behavior. Easy poise.",
        "integrated": "relaxation into natural cultural patterns after public performance and honoring of essential identity.",
        "stress": "Psychological compartmentalization that prevents authentic integration and retreat into rigid stereotypical behavior."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_23",
      "sign": "sagittarius",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "IN NEW YORK, ELLIS ISLAND WELCOMES THE IMMIGRANTS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "New openings that come to all who are willing to risk self for the sake of greater selfhood. Reorientation. Presumption.",
        "integrated": "institutional support for courageous transitions that facilitate cultural renewal through diversity.",
        "stress": "Disorienting displacement without adequate integration and superficial assimilation that diminishes authentic identity."
      },
      "optionText": {
        "default": "New openings that come to all who are willing to risk self for the sake of greater selfhood. Reorientation. Presumption.",
        "integrated": "institutional support for courageous transitions that facilitate cultural renewal through diversity.",
        "stress": "Disorienting displacement without adequate integration and superficial assimilation that diminishes authentic identity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_24",
      "sign": "sagittarius",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "THE SYMBOLICAL \"BLUE BIRD\" ALIGHTS UPON A LITTLE COTTAGE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The blessings bestowed upon all those who are true to themselves. Unexpected assistance. Happiness. Sheer good fortune.",
        "integrated": "serendipitous fulfillment that comes to those who maintain genuine simplicity and authentic living.",
        "stress": "Passive waiting for external happiness and idealistic fantasy that substitutes for practical efforts toward fulfillment."
      },
      "optionText": {
        "default": "The blessings bestowed upon all those who are true to themselves. Unexpected assistance. Happiness. Sheer good fortune.",
        "integrated": "serendipitous fulfillment that comes to those who maintain genuine simplicity and authentic living.",
        "stress": "Passive waiting for external happiness and idealistic fantasy that substitutes for practical efforts toward fulfillment."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_25",
      "sign": "sagittarius",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "RICH LITTLE BOY RIDES UPON HIS BRIGHT-COLORED HORSE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Growth through vicarious, imaginative experiences, which life might deny us. Detachment from reality. Self-conservation.",
        "integrated": "confident exploration of expanded possibilities through creative projection and privileged access to resources.",
        "stress": "Artificial substitutes for authentic experience and indulgence in fantasy that prevents genuine engagement with reality.\"# Sabian Symbols - New Interpretations"
      },
      "optionText": {
        "default": "Growth through vicarious, imaginative experiences, which life might deny us. Detachment from reality. Self-conservation.",
        "integrated": "confident exploration of expanded possibilities through creative projection and privileged access to resources.",
        "stress": "Artificial substitutes for authentic experience and indulgence in fantasy that prevents genuine engagement with reality.\"# Sabian Symbols - New Interpretations"
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "sagittarius_26",
      "sign": "sagittarius",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "FLAG-BEARER DISTINGUISHES HIMSELF IN HAND-TO-HAND BATTLE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Exaltation of physical valor as necessary support to lofty race ideals. Spectacular effort. Endowment beyond realization.",
        "integrated": "Exaltation of physical valor as necessary support to lofty race ideals.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Exaltation of physical valor as necessary support to lofty race ideals."
      },
      "optionText": {
        "default": "Exaltation of physical valor as necessary support to lofty race ideals. Spectacular effort. Endowment beyond realization.",
        "integrated": "Exaltation of physical valor as necessary support to lofty race ideals.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Exaltation of physical valor as necessary support to lofty race ideals."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "sagittarius_27",
      "sign": "sagittarius",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "THE SCULPTOR'S VISION IS TAKING FORM UNDER HIS HANDS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Mastery of formative intelligence over substance. Sure characterization and understanding. Permanent self-expression.",
        "integrated": "Mastery of formative intelligence over substance.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Mastery of formative intelligence over substance."
      },
      "optionText": {
        "default": "Mastery of formative intelligence over substance. Sure characterization and understanding. Permanent self-expression.",
        "integrated": "Mastery of formative intelligence over substance.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Mastery of formative intelligence over substance."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "sagittarius_28",
      "sign": "sagittarius",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "ANCIENT BRIDGE WITNESSES TO THE SKILL OF FORGOTTEN MEN.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Enduring elements in understanding as symbols of the community invisible of man, dead and living. Steady coordination.",
        "integrated": "Enduring elements in understanding as symbols of the community invisible of man, dead and living.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Enduring elements in understanding as symbols of the community invisible of man, dead and living."
      },
      "optionText": {
        "default": "Enduring elements in understanding as symbols of the community invisible of man, dead and living. Steady coordination.",
        "integrated": "Enduring elements in understanding as symbols of the community invisible of man, dead and living.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Enduring elements in understanding as symbols of the community invisible of man, dead and living."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "sagittarius_29",
      "sign": "sagittarius",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "PERSPIRING FAT BOY, EAGER TO REDUCE, IS MOWING A LAWN.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Desire for fitness inherent in all living beings. Consciously built, thus dependable determination. Persistent endeavor.",
        "integrated": "Desire for fitness inherent in all living beings.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Desire for fitness inherent in all living beings."
      },
      "optionText": {
        "default": "Desire for fitness inherent in all living beings. Consciously built, thus dependable determination. Persistent endeavor.",
        "integrated": "Desire for fitness inherent in all living beings.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Desire for fitness inherent in all living beings."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "sagittarius_30",
      "sign": "sagittarius",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 18: SAGITTARIUS 16-30: THE SPAN OF DETACHMENT",
      "image": "THE POPE IS HOLDING AUDIENCE IN A HALL OF THE VATICAN.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Wealth of spiritual resources which can be tapped for the glorification of every relationship. Concrete form of ideals.",
        "integrated": "Wealth of spiritual resources which can be tapped for the glorification of every relationship.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Wealth of spiritual resources which can be tapped for the glorification of every relationship."
      },
      "optionText": {
        "default": "Wealth of spiritual resources which can be tapped for the glorification of every relationship. Concrete form of ideals.",
        "integrated": "Wealth of spiritual resources which can be tapped for the glorification of every relationship.",
        "stress": "Overidentify with this pattern or apply it too rigidly: Wealth of spiritual resources which can be tapped for the glorification of every relationship."
      },
      "derivation": {
        "integrated": "derived_from_concept",
        "stress": "derived_from_concept"
      }
    },
    {
      "id": "capricorn_01",
      "sign": "capricorn",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "INDIAN CHIEF CLAIMS POWER FROM THE ASSEMBLED TRIBE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Mastery of a situation through purposeful planning and venturing. Bold rising to opportunity. Extreme of self-confidence.",
        "integrated": "exceptional leadership that draws authority from genuine connection with collective values and needs.",
        "stress": "Arrogant assumption of power without adequate foundation and manipulation of group energy for personal aggrandizement."
      },
      "optionText": {
        "default": "Mastery of a situation through purposeful planning and venturing. Bold rising to opportunity. Extreme of self-confidence.",
        "integrated": "exceptional leadership that draws authority from genuine connection with collective values and needs.",
        "stress": "Arrogant assumption of power without adequate foundation and manipulation of group energy for personal aggrandizement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_02",
      "sign": "capricorn",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "ROSE-WINDOWS IN A GOTHIC CATHEDRAL; ONE, DAMAGED BY WAR.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Underlying resistance to change in life foundations. Faithfulness to self. Testimony of beauty against brute force.",
        "integrated": "enduring spiritual vision that transcends temporary destructive forces through higher pattern integration.",
        "stress": "Fragile cultural achievements vulnerable to aggressive ignorance and excessive attachment to form over essence."
      },
      "optionText": {
        "default": "Underlying resistance to change in life foundations. Faithfulness to self. Testimony of beauty against brute force.",
        "integrated": "enduring spiritual vision that transcends temporary destructive forces through higher pattern integration.",
        "stress": "Fragile cultural achievements vulnerable to aggressive ignorance and excessive attachment to form over essence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_03",
      "sign": "capricorn",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "THE SOUL, AS A HOVERING SPIRIT EAGER TO GAIN EXPERIENCE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Inner and pure motivation. The power to remain superior to physical limitations; to demonstrate free will. Detachment.",
        "integrated": "transcendent consciousness that participates in material existence without being limited by its conditions.",
        "stress": "Disconnection from practical realities and spectator mentality that avoids full engagement with life's challenges."
      },
      "optionText": {
        "default": "Inner and pure motivation. The power to remain superior to physical limitations; to demonstrate free will. Detachment.",
        "integrated": "transcendent consciousness that participates in material existence without being limited by its conditions.",
        "stress": "Disconnection from practical realities and spectator mentality that avoids full engagement with life's challenges."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_04",
      "sign": "capricorn",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "MERRY-MAKERS EMBARK IN A BIG CANOE ON LANTERN-LIT LAKE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Externalization through individuals of the collective urges of the race. Foolish love for pleasure. Exploitation of self.",
        "integrated": "joyful social participation that enhances collective experience through shared celebration and ritual.",
        "stress": "Superficial pursuit of temporary pleasures without deeper meaning and excessive indulgence that depletes vital resources."
      },
      "optionText": {
        "default": "Externalization through individuals of the collective urges of the race. Foolish love for pleasure. Exploitation of self.",
        "integrated": "joyful social participation that enhances collective experience through shared celebration and ritual.",
        "stress": "Superficial pursuit of temporary pleasures without deeper meaning and excessive indulgence that depletes vital resources."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_05",
      "sign": "capricorn",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "AN AMERICAN INDIAN CAMP: A FIERCE WAR DANCE BEGINS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Mobilization of latent energies for determined self-exertion. Obsession by elemental forces. Violent awakening to reality.",
        "integrated": "powerful activation of primal energies through disciplined cultural expression and collective focus.",
        "stress": "Inflammatory arousal of destructive impulses and ritualistic simulation of conflict that generates actual hostility."
      },
      "optionText": {
        "default": "Mobilization of latent energies for determined self-exertion. Obsession by elemental forces. Violent awakening to reality.",
        "integrated": "powerful activation of primal energies through disciplined cultural expression and collective focus.",
        "stress": "Inflammatory arousal of destructive impulses and ritualistic simulation of conflict that generates actual hostility."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_06",
      "sign": "capricorn",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "TEN LOGS LIE UNDER ARCHWAY LEADING TO DARKER WOODS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Illimitability of experience, as man moves from completion to ever greater fulfillment. Keenness in knowing. Thoroughness.",
        "integrated": "readiness to advance into more challenging dimensions of experience with well-prepared foundations.",
        "stress": "Hesitation at thresholds of greater mystery and accumulation of resources without putting them to meaningful use."
      },
      "optionText": {
        "default": "Illimitability of experience, as man moves from completion to ever greater fulfillment. Keenness in knowing. Thoroughness.",
        "integrated": "readiness to advance into more challenging dimensions of experience with well-prepared foundations.",
        "stress": "Hesitation at thresholds of greater mystery and accumulation of resources without putting them to meaningful use."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_07",
      "sign": "capricorn",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "A HEAVILY VEILED HIEROPHANT LEADS A RITUAL OF POWER.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Gathering together of the power of a group to one purpose and into an individual will. \"Avatar\"-ship. Responsibility.",
        "integrated": "concentrated spiritual authority that channels collective energy toward transpersonal realization.",
        "stress": "Manipulation of group consciousness through mysterious ritual and obscuration that prevents direct understanding."
      },
      "optionText": {
        "default": "Gathering together of the power of a group to one purpose and into an individual will. \"Avatar\"-ship. Responsibility.",
        "integrated": "concentrated spiritual authority that channels collective energy toward transpersonal realization.",
        "stress": "Manipulation of group consciousness through mysterious ritual and obscuration that prevents direct understanding."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_08",
      "sign": "capricorn",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "IN A BIG LIVING ROOM FLOODED WITH SUNLIGHT CANARIES SING.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The happiness that radiates from an integrated personality. Firm self-establishment in social comfort or respectability.",
        "integrated": "harmonious self-expression that creates an atmosphere of joy and light within established circumstances.",
        "stress": "Sheltered contentment that lacks awareness of wider realities and decorative charm without substantial contribution."
      },
      "optionText": {
        "default": "The happiness that radiates from an integrated personality. Firm self-establishment in social comfort or respectability.",
        "integrated": "harmonious self-expression that creates an atmosphere of joy and light within established circumstances.",
        "stress": "Sheltered contentment that lacks awareness of wider realities and decorative charm without substantial contribution."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_09",
      "sign": "capricorn",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "AN ANGEL CARRYING A HARP COMES THROUGH A HEAVENLY LANE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The basic harmony of fulfilled selfhood. Realizing harmony in everyday life through detached and lofty understanding.",
        "integrated": "elevated consciousness that brings celestial harmony into mundane experience through refined sensitivity.",
        "stress": "Otherworldly pretension disconnected from practical reality and aesthetic superiority that avoids genuine involvement."
      },
      "optionText": {
        "default": "The basic harmony of fulfilled selfhood. Realizing harmony in everyday life through detached and lofty understanding.",
        "integrated": "elevated consciousness that brings celestial harmony into mundane experience through refined sensitivity.",
        "stress": "Otherworldly pretension disconnected from practical reality and aesthetic superiority that avoids genuine involvement."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_10",
      "sign": "capricorn",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "ON A SAILBOAT THE SEAMEN ARE FEEDING A TAME ALBATROSS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Overcoming of instinctive fears through gentle persuasion. Kindly conquest. Culture of spiritual values. Harmlessness.",
        "integrated": "transcendence of natural divisions between realms through patient nurturing and mutual adaptation.",
        "stress": "Sentimental relationship with wild elements that creates unhealthy dependency and disruption of natural independence."
      },
      "optionText": {
        "default": "Overcoming of instinctive fears through gentle persuasion. Kindly conquest. Culture of spiritual values. Harmlessness.",
        "integrated": "transcendence of natural divisions between realms through patient nurturing and mutual adaptation.",
        "stress": "Sentimental relationship with wild elements that creates unhealthy dependency and disruption of natural independence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_11",
      "sign": "capricorn",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "PHEASANTS DISPLAY THEIR BRILLIANT COLORS ON A VAST LAWN.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Latent richness of natural resources brought out through selective processes. Capitalization upon opportunity. Luxury.",
        "integrated": "magnificent display of inherent qualities that have been cultivated through careful development.",
        "stress": "Ostentatious exhibition of superficial attributes and vain preoccupation with appearance rather than substance."
      },
      "optionText": {
        "default": "Latent richness of natural resources brought out through selective processes. Capitalization upon opportunity. Luxury.",
        "integrated": "magnificent display of inherent qualities that have been cultivated through careful development.",
        "stress": "Ostentatious exhibition of superficial attributes and vain preoccupation with appearance rather than substance."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_12",
      "sign": "capricorn",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "NATURAL WONDERS ARE DEPICTED IN A LECTURE ON SCIENCE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Piercing through appearances; disclosing the magic splendor of the core of things. A universal living touch. Keen vision.",
        "integrated": "illuminating revelation of the extraordinary within ordinary phenomena through analytical insight.",
        "stress": "Reduction of natural mysteries to intellectual explanations and clinical detachment that fails to honor inherent wonder."
      },
      "optionText": {
        "default": "Piercing through appearances; disclosing the magic splendor of the core of things. A universal living touch. Keen vision.",
        "integrated": "illuminating revelation of the extraordinary within ordinary phenomena through analytical insight.",
        "stress": "Reduction of natural mysteries to intellectual explanations and clinical detachment that fails to honor inherent wonder."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_13",
      "sign": "capricorn",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "BENEATH SNOW-CLAD PEAKS A FIRE-WORSHIPPER IS MEDITATING.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Firm establishment upon immemorial principles. Consciousness of absolute unity. Depth of soul-penetration. Self-conquest.",
        "integrated": "concentrated spiritual focus that reveals universal principles underlying apparent diversity of forms.",
        "stress": "Isolation from practical realities in abstract contemplation and obsessive devotion to singular approach to truth."
      },
      "optionText": {
        "default": "Firm establishment upon immemorial principles. Consciousness of absolute unity. Depth of soul-penetration. Self-conquest.",
        "integrated": "concentrated spiritual focus that reveals universal principles underlying apparent diversity of forms.",
        "stress": "Isolation from practical realities in abstract contemplation and obsessive devotion to singular approach to truth."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_14",
      "sign": "capricorn",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "IN DENSE JUNGLE, A PERFECTLY PRESERVED MAYAN BAS-RELIEF.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Man's power to leave permanent records of his achievements. Personal immortality. Fecundation of future by past. Assurance.",
        "integrated": "enduring creative expression that maintains cultural transmission despite encroaching natural forces.",
        "stress": "Forgotten knowledge without continuing relevance and excessive concern with leaving permanent marks of individual existence."
      },
      "optionText": {
        "default": "Man's power to leave permanent records of his achievements. Personal immortality. Fecundation of future by past. Assurance.",
        "integrated": "enduring creative expression that maintains cultural transmission despite encroaching natural forces.",
        "stress": "Forgotten knowledge without continuing relevance and excessive concern with leaving permanent marks of individual existence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_15",
      "sign": "capricorn",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 19: CAPRICORN 1-15: THE SPAN OF ELUSIVENESS",
      "image": "IN A HOSPITAL, A CHILDREN'S WARD FILLED WITH PLAYTHINGS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The goodness of life in the tragic trials of first attempts at self‑regeneration. Administered responsibility; or escape.",
        "integrated": "compassionate alleviation of suffering through provision of appropriate means for healing development.",
        "stress": "Superficial distraction from genuine healing needs and institutionalized care that creates dependency rather than wholeness."
      },
      "optionText": {
        "default": "The goodness of life in the tragic trials of first attempts at self‑regeneration. Administered responsibility; or escape.",
        "integrated": "compassionate alleviation of suffering through provision of appropriate means for healing development.",
        "stress": "Superficial distraction from genuine healing needs and institutionalized care that creates dependency rather than wholeness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_16",
      "sign": "capricorn",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "SCHOOL GROUNDS FILLED WITH YOUTHS IN GYMNASIUM SUITS.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Normal dependence upon physical stimulation. Robust enthusiasm in approaching life's contests; or immature impulsiveness.",
        "integrated": "balanced development of physical capacities alongside mental faculties within structured environment.",
        "stress": "Excessive emphasis on physical prowess at the expense of intellectual growth and conformist training without individual purpose."
      },
      "optionText": {
        "default": "Normal dependence upon physical stimulation. Robust enthusiasm in approaching life's contests; or immature impulsiveness.",
        "integrated": "balanced development of physical capacities alongside mental faculties within structured environment.",
        "stress": "Excessive emphasis on physical prowess at the expense of intellectual growth and conformist training without individual purpose."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_17",
      "sign": "capricorn",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "REPRESSED WOMAN FINDS A PSYCHOLOGICAL RELEASE IN NUDISM.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Escape from bondage to social inhibitions. Readjustment of relation of spirit to body. Self-purification. Self-confrontation.",
        "integrated": "liberation from artificial constraints through honest recognition of fundamental natural realities.",
        "stress": "Rebellion against convention that merely substitutes another form of conformity and exhibitionism masquerading as freedom."
      },
      "optionText": {
        "default": "Escape from bondage to social inhibitions. Readjustment of relation of spirit to body. Self-purification. Self-confrontation.",
        "integrated": "liberation from artificial constraints through honest recognition of fundamental natural realities.",
        "stress": "Rebellion against convention that merely substitutes another form of conformity and exhibitionism masquerading as freedom."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_18",
      "sign": "capricorn",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "THE UNION JACK FLAG FLIES FROM A NEW BRITISH DESTROYER.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Extreme of objectification of inner resources. Challenge to life. Splendid self-realization. Full awareness of competition.",
        "integrated": "powerful mobilization of cultural resources for protection of established values and collective security.",
        "stress": "Aggressive nationalism and excessive pride in technological capacity for destruction rather than constructive purposes."
      },
      "optionText": {
        "default": "Extreme of objectification of inner resources. Challenge to life. Splendid self-realization. Full awareness of competition.",
        "integrated": "powerful mobilization of cultural resources for protection of established values and collective security.",
        "stress": "Aggressive nationalism and excessive pride in technological capacity for destruction rather than constructive purposes."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_19",
      "sign": "capricorn",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "FIVE-YEAR-OLD GIRL PROUDLY DOES HER MOTHER'S MARKETING.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Capacity to take place ahead of normal standards. Increased self-confidence. Waiting for conditions to catch up with self.",
        "integrated": "early assumption of responsibility that develops confidence and competence beyond chronological maturity.",
        "stress": "Premature burdening with adult duties and precocious development at the expense of appropriate childhood experience."
      },
      "optionText": {
        "default": "Capacity to take place ahead of normal standards. Increased self-confidence. Waiting for conditions to catch up with self.",
        "integrated": "early assumption of responsibility that develops confidence and competence beyond chronological maturity.",
        "stress": "Premature burdening with adult duties and precocious development at the expense of appropriate childhood experience."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_20",
      "sign": "capricorn",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "THROUGH THE EMPTY CHURCH, THE CHOIR IS HEARD, REHEARSING.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "The unrealized fullness of life even in the emptiest hours. Preparation for activity. Ray of hope through all difficulty.",
        "integrated": "dedicated cultivation of higher potentials that continue despite apparent absence of external recognition.",
        "stress": "Practice without performance and ritualistic preparation that never culminates in actual service or manifestation."
      },
      "optionText": {
        "default": "The unrealized fullness of life even in the emptiest hours. Preparation for activity. Ray of hope through all difficulty.",
        "integrated": "dedicated cultivation of higher potentials that continue despite apparent absence of external recognition.",
        "stress": "Practice without performance and ritualistic preparation that never culminates in actual service or manifestation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_21",
      "sign": "capricorn",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "A RELAY RACE. EACH RUNNER SPRINGS EAGERLY INTO PLACE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Extreme of cooperation and give-and-take in life-relationships. Full surrender of self to service. Planned group-behavior.",
        "integrated": "courageous prioritization of authentic human values over institutional demands and social expectations.",
        "stress": "Abandonment of legitimate responsibilities due to personal desires and rationalization of weakness as principle."
      },
      "optionText": {
        "default": "Extreme of cooperation and give-and-take in life-relationships. Full surrender of self to service. Planned group-behavior.",
        "integrated": "courageous prioritization of authentic human values over institutional demands and social expectations.",
        "stress": "Abandonment of legitimate responsibilities due to personal desires and rationalization of weakness as principle."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_22",
      "sign": "capricorn",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "DEFEATED GENERAL YIELDS UP HIS SWORD WITH NOBLE DIGNITY.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Apparent defeat that spells real spiritual victory. Bowing to custom. Conquest through conformity to established norm.",
        "integrated": "skilled pursuit of valuable resources with perseverance through difficult conditions for worthy sustenance.",
        "stress": "Destructive exploitation of natural beauty for trivial satisfaction and violence against vulnerable beings for sport."
      },
      "optionText": {
        "default": "Apparent defeat that spells real spiritual victory. Bowing to custom. Conquest through conformity to established norm.",
        "integrated": "skilled pursuit of valuable resources with perseverance through difficult conditions for worthy sustenance.",
        "stress": "Destructive exploitation of natural beauty for trivial satisfaction and violence against vulnerable beings for sport."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_23",
      "sign": "capricorn",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "A SOLDIER RECEIVES DECOROUSLY TWO AWARDS FOR BRAVERY.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Reward offered by society for the fulfilling of individual responsibility. Recognition of worth; unearned good fortune.",
        "integrated": "transformative awakening of magical potential within seemingly commonplace existence through inner animation.",
        "stress": "Erratic behavioral changes without integration and restless shifting of identity without genuine development."
      },
      "optionText": {
        "default": "Reward offered by society for the fulfilling of individual responsibility. Recognition of worth; unearned good fortune.",
        "integrated": "transformative awakening of magical potential within seemingly commonplace existence through inner animation.",
        "stress": "Erratic behavioral changes without integration and restless shifting of identity without genuine development."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_24",
      "sign": "capricorn",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "A WOMAN WALKING TO THE SURE HAVEN OF A CONVENT.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Protective kindness of life to weary hearts. Quiet undercurrent of real existence. Compelled assistance. Timely rescue.",
        "integrated": "profound capacity to assimilate transformative concepts and integrate them into everyday living.",
        "stress": "Temporary emotional stimulation without lasting change and collective enthusiasm that dissipates without practical application."
      },
      "optionText": {
        "default": "Protective kindness of life to weary hearts. Quiet undercurrent of real existence. Compelled assistance. Timely rescue.",
        "integrated": "profound capacity to assimilate transformative concepts and integrate them into everyday living.",
        "stress": "Temporary emotional stimulation without lasting change and collective enthusiasm that dissipates without practical application."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_25",
      "sign": "capricorn",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "LITTLE BOYS FROLIC UPON SOFT RUGS IN AN ORIENTAL STORE.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "First realization of cultural values through sensuous enjoyment. Refinement of sensations. Psychological enrichment.",
        "integrated": "exceptional analytical insight that reveals hidden causes of dysfunction and enables precise intervention.",
        "stress": "Excessive reliance on technological solutions and invasive examination that neglects holistic understanding."
      },
      "optionText": {
        "default": "First realization of cultural values through sensuous enjoyment. Refinement of sensations. Psychological enrichment.",
        "integrated": "exceptional analytical insight that reveals hidden causes of dysfunction and enables precise intervention.",
        "stress": "Excessive reliance on technological solutions and invasive examination that neglects holistic understanding."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_26",
      "sign": "capricorn",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "RADIANT SPRITE DANCES UPON THE MIST OF A WATERFALL.",
      "source": {
        "type": "supplied_primary_plus_secondary",
        "file": "Sabian JSON.txt + sabian-interpretations.md"
      },
      "kernel": {
        "default": "Transcendence of spirit over body and environment. Lightness of understanding. Inexhaustible soul resources. Effervescence.",
        "integrated": "masterful adaptation to changing circumstances through practical skill and cultural wisdom.",
        "stress": "Temporary settlement that avoids permanent commitment and retreating to primitive patterns rather than evolving."
      },
      "optionText": {
        "default": "Transcendence of spirit over body and environment. Lightness of understanding. Inexhaustible soul resources. Effervescence.",
        "integrated": "masterful adaptation to changing circumstances through practical skill and cultural wisdom.",
        "stress": "Temporary settlement that avoids permanent commitment and retreating to primitive patterns rather than evolving."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_27",
      "sign": "capricorn",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "MEN CLIMB A SACRED PEAK:BELOW,THE WORLD-ABOVE, PEACE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Necessary linkage of above and below in the seeker's personal experience. Balanced dualism of subjective-objective life.",
        "integrated": "a total reconciliation of mind and heart in an unquestioned devotion to some worth-while task at hand.",
        "stress": "Satisfaction in superficial allegiances and a parade of false virtue."
      },
      "optionText": {
        "default": "Necessary linkage of above and below in the seeker's personal experience. Balanced dualism of subjective-objective life.",
        "integrated": "a total reconciliation of mind and heart in an unquestioned devotion to some worth-while task at hand.",
        "stress": "Satisfaction in superficial allegiances and a parade of false virtue."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_28",
      "sign": "capricorn",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "THE AVIARY OF A RURAL MANSION, FILLED WITH SINGING BIRDS.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Enhancement of personality by familiarity with spiritual values. Joying in the significance of things; or mental confusion.",
        "integrated": "Exceptional success in making all personal concerns a matter of common welfare.",
        "stress": "Loss of all character in sheer officiousness."
      },
      "optionText": {
        "default": "Enhancement of personality by familiarity with spiritual values. Joying in the significance of things; or mental confusion.",
        "integrated": "Exceptional success in making all personal concerns a matter of common welfare.",
        "stress": "Loss of all character in sheer officiousness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_29",
      "sign": "capricorn",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "A GYPSY READS FORTUNES IN THE TEA-CUPS OF SOCIETY LADIES.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The quest for inner understanding through all life-conditioning. First approach to reality. Desire to transcend routine.",
        "integrated": "Naive insight as brought to high intelligence in meeting the recurrent issues of life.",
        "stress": "Superstitious dependence on the unknown."
      },
      "optionText": {
        "default": "The quest for inner understanding through all life-conditioning. First approach to reality. Desire to transcend routine.",
        "integrated": "Naive insight as brought to high intelligence in meeting the recurrent issues of life.",
        "stress": "Superstitious dependence on the unknown."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "capricorn_30",
      "sign": "capricorn",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 20: CAPRICORN 16-30: THE SPAN OF DEPENDENCE",
      "image": "THE DIRECTORS OF A LARGE FIRM MEET IN SECRET CONFERENCE.",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Activity of inner formative elements of real personality. Massing of soul-energies in an emergency. Spiritual leadership.",
        "integrated": "A gift for clever planning and successful administration in every area of life.",
        "stress": "Rampant selfishness and rank exploitation of others."
      },
      "optionText": {
        "default": "Activity of inner formative elements of real personality. Massing of soul-energies in an emergency. Spiritual leadership.",
        "integrated": "A gift for clever planning and successful administration in every area of life.",
        "stress": "Rampant selfishness and rank exploitation of others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_01",
      "sign": "aquarius",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "OLD ADOBE MISSION NESTLES IN CALIFORNIA'S BROWN HILLS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Mastery of man over environment while becoming an integral part of it. Recognition of established values. Impressiveness.",
        "integrated": "Effective breadth of vision and a respect-compelling depth of character.",
        "stress": "Lack of ambition and blind adherence to superficialities."
      },
      "optionText": {
        "default": "Mastery of man over environment while becoming an integral part of it. Recognition of established values. Impressiveness.",
        "integrated": "Effective breadth of vision and a respect-compelling depth of character.",
        "stress": "Lack of ambition and blind adherence to superficialities."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_02",
      "sign": "aquarius",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "UNEXPECTED THUNDERSTORM BRINGS RELIEF TO PARCHED FIELDS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Liberation from adverse conditions through violent spectacular developments. Galvanizing to action. Cosmic visitation.",
        "integrated": "Creative opportunism and a genius for shaping all eventualities to some desired end.",
        "stress": "Complete temperamental instability."
      },
      "optionText": {
        "default": "Liberation from adverse conditions through violent spectacular developments. Galvanizing to action. Cosmic visitation.",
        "integrated": "Creative opportunism and a genius for shaping all eventualities to some desired end.",
        "stress": "Complete temperamental instability."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_03",
      "sign": "aquarius",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "A DESERTER SUDDENLY REALIZES THE FALLACY OF HIS CONDUCT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Ability to regrasp past experience and turn it to account. Sharp self-examination. Awakened new fearlessness. Decision.",
        "integrated": "Genuine psychological courage in a repudiation of all meaningless loyalties.",
        "stress": "Complete inability to follow the rules of any game."
      },
      "optionText": {
        "default": "Ability to regrasp past experience and turn it to account. Sharp self-examination. Awakened new fearlessness. Decision.",
        "integrated": "Genuine psychological courage in a repudiation of all meaningless loyalties.",
        "stress": "Complete inability to follow the rules of any game."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_04",
      "sign": "aquarius",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "A HINDU PUNDIT REVEALS HIMSELF SUDDENLY A GREAT HEALER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Supremacy of the unsuspected faculties hidden deep within. Conscious utilization of divine potency. Revelation of self.",
        "integrated": "High personal skill in bringing the least of human potentials to some ultimate consummation.",
        "stress": "False claims of psychological power in an effort to impress others."
      },
      "optionText": {
        "default": "Supremacy of the unsuspected faculties hidden deep within. Conscious utilization of divine potency. Revelation of self.",
        "integrated": "High personal skill in bringing the least of human potentials to some ultimate consummation.",
        "stress": "False claims of psychological power in an effort to impress others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_05",
      "sign": "aquarius",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "A WORLD-LEADER IS SEEN GUIDED BY HIS ANCESTORS' SPIRITS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The rich ancestral heritage of every individual, which is the potent foundation of character. Direct, real inspiration.",
        "integrated": "Power through absolute self-integrity.",
        "stress": "Sterile conservatism."
      },
      "optionText": {
        "default": "The rich ancestral heritage of every individual, which is the potent foundation of character. Direct, real inspiration.",
        "integrated": "Power through absolute self-integrity.",
        "stress": "Sterile conservatism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_06",
      "sign": "aquarius",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "IN AN ALLEGORICAL MYSTERY RITUAL A MAN OFFICIATES ALONE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Compelling urge in every soul to express the unknown and the more-then-physical. Sensitiveness to high purpose. Conflict.",
        "integrated": "A gift for dramatizing the deeper or real opportunities of a human society.",
        "stress": "Consistent self-mystification and marked impracticability."
      },
      "optionText": {
        "default": "Compelling urge in every soul to express the unknown and the more-then-physical. Sensitiveness to high purpose. Conflict.",
        "integrated": "A gift for dramatizing the deeper or real opportunities of a human society.",
        "stress": "Consistent self-mystification and marked impracticability."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_07",
      "sign": "aquarius",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "OUT OF THE COSMIC EGG,LIFE IS BORN FRESH AND VIRGINAL",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "New actuation of effort by the power of unrealized purposes. Self-expression beyond all expectation. Spiritual protection.",
        "integrated": "A highly individual and completely unlimited resourcefulness.",
        "stress": "Naive reliance on external accident."
      },
      "optionText": {
        "default": "New actuation of effort by the power of unrealized purposes. Self-expression beyond all expectation. Spiritual protection.",
        "integrated": "A highly individual and completely unlimited resourcefulness.",
        "stress": "Naive reliance on external accident."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_08",
      "sign": "aquarius",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "WAX FIGURES DISPLAY BEAUTIFUL GOWNS IN STORE-WINDOWS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Need for public presentation of virtues and life standards. Exteriorization of value, that it may be shared with others.",
        "integrated": "Achievement through the effective dramatization of human character on some level of everyday understanding.",
        "stress": "Futile effort to recapture outworn experience."
      },
      "optionText": {
        "default": "Need for public presentation of virtues and life standards. Exteriorization of value, that it may be shared with others.",
        "integrated": "Achievement through the effective dramatization of human character on some level of everyday understanding.",
        "stress": "Futile effort to recapture outworn experience."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_09",
      "sign": "aquarius",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "IN MEDITATION, A FLAG IS SEEN, WHICH CHANGES INTO A EAGLE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Process of spiritual realization as it progresses from outer to inner standards. Rebirth, or rebellion against drudgery.",
        "integrated": "Accomplishment through utter self-dedication.",
        "stress": "Vindictive pride."
      },
      "optionText": {
        "default": "Process of spiritual realization as it progresses from outer to inner standards. Rebirth, or rebellion against drudgery.",
        "integrated": "Accomplishment through utter self-dedication.",
        "stress": "Vindictive pride."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_10",
      "sign": "aquarius",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "UNSPOILED BY POPULARITY NOW WANING A MAN PLANS ANEW",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Ability to rise above vicissitudes of passing fortune. Faithfulness to self. Dependence upon native endowment. Projection.",
        "integrated": "A gift for bringing the issues of life to a dramatic consummation at a time of crisis.",
        "stress": "Prodigal opportunism."
      },
      "optionText": {
        "default": "Ability to rise above vicissitudes of passing fortune. Faithfulness to self. Dependence upon native endowment. Projection.",
        "integrated": "A gift for bringing the issues of life to a dramatic consummation at a time of crisis.",
        "stress": "Prodigal opportunism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_11",
      "sign": "aquarius",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "ARTIST, AWAY FROM THE WORLD, RECEIVES A NEW INSPIRATION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Creative power in man: its relationship to social behaviour. Self-crystallization in a form of power; or self-exploitation.",
        "integrated": "An enthusiastic idealism and a tireless desire to serve others.",
        "stress": "Complete self-obsession."
      },
      "optionText": {
        "default": "Creative power in man: its relationship to social behaviour. Self-crystallization in a form of power; or self-exploitation.",
        "integrated": "An enthusiastic idealism and a tireless desire to serve others.",
        "stress": "Complete self-obsession."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_12",
      "sign": "aquarius",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "LIFE'S BROAD STAIRWAY: EACH LANDING, A NEW GRADE OF LIFE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Points of pause and tradition, where the soul can evaluate its progress. Graded effort. Necessity for divorcing the past.",
        "integrated": "An effective forward point of view and a genuine capitalization on all prior accomplishment.",
        "stress": "Frantic efforts to keep ahead of others."
      },
      "optionText": {
        "default": "Points of pause and tradition, where the soul can evaluate its progress. Graded effort. Necessity for divorcing the past.",
        "integrated": "An effective forward point of view and a genuine capitalization on all prior accomplishment.",
        "stress": "Frantic efforts to keep ahead of others."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_13",
      "sign": "aquarius",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "A BAROMETER HANGS UNDER THE PORCH OF A QUIET RURAL INN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Vantage point in consciousness whence life may be observed and measured in peace. Inner retreat of a soul seeking truth.",
        "integrated": "Unusual keenness of observation and exceptional competence in judgement.",
        "stress": "Superficial uncertainty and a continual trimming to passing events."
      },
      "optionText": {
        "default": "Vantage point in consciousness whence life may be observed and measured in peace. Inner retreat of a soul seeking truth.",
        "integrated": "Unusual keenness of observation and exceptional competence in judgement.",
        "stress": "Superficial uncertainty and a continual trimming to passing events."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_14",
      "sign": "aquarius",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "ON A STEEP CLIMB, A TUNNEL OFFERS SHORT-CUT TO A TRAIN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The way within to outer success. Sure relief to the toiler ready to face facts. Penetration and direct accomplishment.",
        "integrated": "Man's gift for meeting the most exacting of demands on his various potentialities.",
        "stress": "Uninspired conformity to limitation."
      },
      "optionText": {
        "default": "The way within to outer success. Sure relief to the toiler ready to face facts. Penetration and direct accomplishment.",
        "integrated": "Man's gift for meeting the most exacting of demands on his various potentialities.",
        "stress": "Uninspired conformity to limitation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_15",
      "sign": "aquarius",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "SPAN 21: AQUARIUS 1-15: THE SPAN OF DEFENSIVENESS",
      "image": "TO LOVE-BIRDS ON A FENCE SING OUT THEIR PURE HAPPINESS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Contagiousness of happiness in human associations. Revelation of constructive reality. Radiation of spontaneous faith.",
        "integrated": "A self-consistency which wins an absolute loyalty and a complete co-operation.",
        "stress": "Unreasoning jealousy."
      },
      "optionText": {
        "default": "Contagiousness of happiness in human associations. Revelation of constructive reality. Radiation of spontaneous faith.",
        "integrated": "A self-consistency which wins an absolute loyalty and a complete co-operation.",
        "stress": "Unreasoning jealousy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_16",
      "sign": "aquarius",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "BUSINESS MANAGER AT HIS DESK STUDIES A COMPLEX PROJECT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The central control of operations needed in all organized enterprise. The head-function. Surety in decision. Management.",
        "integrated": "Effective self-realization through achievement of consequence.",
        "stress": "Ambitious superficiality."
      },
      "optionText": {
        "default": "The central control of operations needed in all organized enterprise. The head-function. Surety in decision. Management.",
        "integrated": "Effective self-realization through achievement of consequence.",
        "stress": "Ambitious superficiality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_17",
      "sign": "aquarius",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "WATCH DOG ON GUARD AS GOLD-MINER SLEEPS NEAR HIS STRIKE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Nascent protective faculties in all men as they adjust themselves to new conditions. Competent organization of affairs.",
        "integrated": "Unswerving faithfulness to ideals and a real determination to achieve them.",
        "stress": "Unfriendly instincts and groundless suspicion."
      },
      "optionText": {
        "default": "Nascent protective faculties in all men as they adjust themselves to new conditions. Competent organization of affairs.",
        "integrated": "Unswerving faithfulness to ideals and a real determination to achieve them.",
        "stress": "Unfriendly instincts and groundless suspicion."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_18",
      "sign": "aquarius",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "AT MASQUERADE, THE LAST MAN UNMASKS, URGED BY THE GIRLS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The introvert's desire to protect himself from social judgement. Clinging to self-valuation. Conservation of experience.",
        "integrated": "A considered self-dedication to greater or more wonderful reasons for being.",
        "stress": "Self-betrayal through exceptional ineptitude."
      },
      "optionText": {
        "default": "The introvert's desire to protect himself from social judgement. Clinging to self-valuation. Conservation of experience.",
        "integrated": "A considered self-dedication to greater or more wonderful reasons for being.",
        "stress": "Self-betrayal through exceptional ineptitude."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_19",
      "sign": "aquarius",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "A FOREST FIRE SUBDUED, THE WEARY FIGHTERS FEEL JUBILANT",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Exaggeration of life-problems, which reveals to man his real stature and which expands him. Impatient challenge. Ascendancy.",
        "integrated": "Special skill in bringing personal interests to some larger point of effectiveness.",
        "stress": "A fear of experience and a subtle delight in calamity."
      },
      "optionText": {
        "default": "Exaggeration of life-problems, which reveals to man his real stature and which expands him. Impatient challenge. Ascendancy.",
        "integrated": "Special skill in bringing personal interests to some larger point of effectiveness.",
        "stress": "A fear of experience and a subtle delight in calamity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_20",
      "sign": "aquarius",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "WHITE DOVE CIRCLES OVERHEAD; DESCENDS, BEARING A MESSAGE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The blessing of every effort by the \"Holy Ghost\" of revealed significance. Exaltation of all individual efforts. Celebrity.",
        "integrated": "A facility for ordering all personal desires in a cosmic framework and a gift for knowing when to act and what to do.",
        "stress": "Sanctimonious self-deception."
      },
      "optionText": {
        "default": "The blessing of every effort by the \"Holy Ghost\" of revealed significance. Exaltation of all individual efforts. Celebrity.",
        "integrated": "A facility for ordering all personal desires in a cosmic framework and a gift for knowing when to act and what to do.",
        "stress": "Sanctimonious self-deception."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_21",
      "sign": "aquarius",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "A WOMAN IS DISAPPOINTED, AS A MAN LEAVES HER BOUDOIR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capitalization upon misfortune by which spiritual justification is gained. Supremacy over experience. Inward retirement.",
        "integrated": "The self's inherent gift for pressing on and gaining increased powers with every setback.",
        "stress": "The acceptance of all defeat as final."
      },
      "optionText": {
        "default": "Capitalization upon misfortune by which spiritual justification is gained. Supremacy over experience. Inward retirement.",
        "integrated": "The self's inherent gift for pressing on and gaining increased powers with every setback.",
        "stress": "The acceptance of all defeat as final."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_22",
      "sign": "aquarius",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "CHILDREN REVEL UPON A SOFT NEW CARPET IN THEIR NURSERY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Life's warmth and richness given to those who eagerly learn to live. Luxurious self-knowing, or self-appreciation. Comfort.",
        "integrated": "Unusual capacity for the exploitation of immediate resources and the deepening of every potential of selfhood.",
        "stress": "Carefree self-indulgence and meaningless luxury."
      },
      "optionText": {
        "default": "Life's warmth and richness given to those who eagerly learn to live. Luxurious self-knowing, or self-appreciation. Comfort.",
        "integrated": "Unusual capacity for the exploitation of immediate resources and the deepening of every potential of selfhood.",
        "stress": "Carefree self-indulgence and meaningless luxury."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_23",
      "sign": "aquarius",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "A BIG TRAINED BEAR PERFORMS, SITTING ON A HUGE CHAIR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Need to build an adequate concrete vehicle for cosmic power. Performance beyond native endowment. A striving for balance.",
        "integrated": "A consistent desire for genuinely significant experience and a willingness to dramatize the self's potentials to any necessary extent.",
        "stress": "Frantic efforts to gain and hold attention."
      },
      "optionText": {
        "default": "Need to build an adequate concrete vehicle for cosmic power. Performance beyond native endowment. A striving for balance.",
        "integrated": "A consistent desire for genuinely significant experience and a willingness to dramatize the self's potentials to any necessary extent.",
        "stress": "Frantic efforts to gain and hold attention."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_24",
      "sign": "aquarius",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "NOW FREED FROM PASSION, A MAN TEACHES DEEP WISDOM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Utilization of experience and passion by the intelligence that remains un-involved. Self-conquering. Genuine dispassion.",
        "integrated": "Effective accomplishment through a genuine peace of inner understanding.",
        "stress": "Thorough dissatisfaction with the normal fruits of living."
      },
      "optionText": {
        "default": "Utilization of experience and passion by the intelligence that remains un-involved. Self-conquering. Genuine dispassion.",
        "integrated": "Effective accomplishment through a genuine peace of inner understanding.",
        "stress": "Thorough dissatisfaction with the normal fruits of living."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_25",
      "sign": "aquarius",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "A BUTTERFLY EMERGES FROM ITS CHRYSALIS, RIGHT WING FIRST",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Necessary advance of volition over reflex elements. Willing approach to problems of being. Fitting to alien ideas. Choice.",
        "integrated": "A genius for turning deficiency into a real asset.",
        "stress": "Unhappy and rebellious conceit."
      },
      "optionText": {
        "default": "Necessary advance of volition over reflex elements. Willing approach to problems of being. Fitting to alien ideas. Choice.",
        "integrated": "A genius for turning deficiency into a real asset.",
        "stress": "Unhappy and rebellious conceit."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_26",
      "sign": "aquarius",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "A GARAGE MAN IS SEEN READY TO TEST THE BATTERY OF A CAR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity of self to take up and deliver spiritual power. Controlled release of power through the emotions. Measurement.",
        "integrated": "Exceptional ability in manipulating the fundamental complexities of living.",
        "stress": "Self-defeating worry over trifles."
      },
      "optionText": {
        "default": "Capacity of self to take up and deliver spiritual power. Controlled release of power through the emotions. Measurement.",
        "integrated": "Exceptional ability in manipulating the fundamental complexities of living.",
        "stress": "Self-defeating worry over trifles."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_27",
      "sign": "aquarius",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "AMID RARE BOOKS, AN OLD POTTERY BOWL HOLDS FRESH VIOLETS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Reality of spiritual or esthetic values, linking generations of seekers for the highest. Addition or commitment to value.",
        "integrated": "A high realization of values and a real gift for using them.",
        "stress": "A loss of self in conventionality and its meaningless trappings."
      },
      "optionText": {
        "default": "Reality of spiritual or esthetic values, linking generations of seekers for the highest. Addition or commitment to value.",
        "integrated": "A high realization of values and a real gift for using them.",
        "stress": "A loss of self in conventionality and its meaningless trappings."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_28",
      "sign": "aquarius",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "HUGE PILE OF SAWED-UP WOOD INSURES HEAT FOR THE WINTER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Rich contribution of nature for all who work with foresight. Intelligent preparation. Calm yet potent faith in Providence.",
        "integrated": "Man's uninhibited and enthusiastic desire to be at work or to mobilize everything around him in his own interest.",
        "stress": "Unnecessary surrender to hard or unrewarding effort through a total lack of imagination."
      },
      "optionText": {
        "default": "Rich contribution of nature for all who work with foresight. Intelligent preparation. Calm yet potent faith in Providence.",
        "integrated": "Man's uninhibited and enthusiastic desire to be at work or to mobilize everything around him in his own interest.",
        "stress": "Unnecessary surrender to hard or unrewarding effort through a total lack of imagination."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_29",
      "sign": "aquarius",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "METAMORPHOSIS COMPLETED, A BUTTERFLY SPREADS ITS WINGS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Immortality of the real self. Graduation into a new realm of being. Confident projection of self; lack of self-confidence.",
        "integrated": "Uncompromising faith in the promise of existence itself and in the wonders of a continuing creation.",
        "stress": "Utterly sluggish response to reality."
      },
      "optionText": {
        "default": "Immortality of the real self. Graduation into a new realm of being. Confident projection of self; lack of self-confidence.",
        "integrated": "Uncompromising faith in the promise of existence itself and in the wonders of a continuing creation.",
        "stress": "Utterly sluggish response to reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "aquarius_30",
      "sign": "aquarius",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 22: AQUARIUS 16-30: THE SPAN OF PERSPECTIVE",
      "image": "MOON-LIT FIELDS, ONCE BABYLON, ARE BLOOMING WHITE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Soul-refreshing inner poetry of being. Spiritually nurtured sentiment which illumines the heart. Voices from the past.",
        "integrated": "Self-illumination through exceptional service to others.",
        "stress": "Witless reaction to fantasy."
      },
      "optionText": {
        "default": "Soul-refreshing inner poetry of being. Spiritually nurtured sentiment which illumines the heart. Voices from the past.",
        "integrated": "Self-illumination through exceptional service to others.",
        "stress": "Witless reaction to fantasy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_01",
      "sign": "pisces",
      "sabianDegree": 1,
      "zodiacDegreeInterval": "0°00′00″–0°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "LATE SATURDAY AFTERNOON: CROWDS FILL THE PUBLIC MARKET",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The social nature of human responsibilities. A last-moment, joyous rallying to a task. Seed synthesis at end of cycles.",
        "integrated": "an exceptional capacity for organizing the converging and conflicting interests of many people in practical arrangements of mutual benefit.",
        "stress": "Complete insensibility to any over-all welfare."
      },
      "optionText": {
        "default": "The social nature of human responsibilities. A last-moment, joyous rallying to a task. Seed synthesis at end of cycles.",
        "integrated": "an exceptional capacity for organizing the converging and conflicting interests of many people in practical arrangements of mutual benefit.",
        "stress": "Complete insensibility to any over-all welfare."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_02",
      "sign": "pisces",
      "sabianDegree": 2,
      "zodiacDegreeInterval": "1°00′00″–1°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "SQUIRREL, SHOWING HUMAN ACUMEN, HIDES FROM HUNTER",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Instinct of self-preservation as a basis for greater realization. Lifting of self to surer foundations. Transference.",
        "integrated": "An intelligent independence of spirit and a consequent real gift for setting the conditions for all personal participation in events.",
        "stress": "Self-debasing timidity."
      },
      "optionText": {
        "default": "Instinct of self-preservation as a basis for greater realization. Lifting of self to surer foundations. Transference.",
        "integrated": "An intelligent independence of spirit and a consequent real gift for setting the conditions for all personal participation in events.",
        "stress": "Self-debasing timidity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_03",
      "sign": "pisces",
      "sabianDegree": 3,
      "zodiacDegreeInterval": "2°00′00″–2°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "A PETRIFIED FOREST: PERMANENT RECORD OF ANCIENT LIVES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Mastery of form over substance. Archetypal immortality. Conscious handling of existence. Participation in race impulses.",
        "integrated": "Effective continuity and breadth of resource in all human effort.",
        "stress": "Complete immobilization in superficial reality."
      },
      "optionText": {
        "default": "Mastery of form over substance. Archetypal immortality. Conscious handling of existence. Participation in race impulses.",
        "integrated": "Effective continuity and breadth of resource in all human effort.",
        "stress": "Complete immobilization in superficial reality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_04",
      "sign": "pisces",
      "sabianDegree": 4,
      "zodiacDegreeInterval": "3°00′00″–3°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "CARS CROWD A NARROW ISTHMUS BETWEEN TWO RESORTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Linkage in activity of all community values. Free flow from ideas to consummation. Sense of significance in relationship.",
        "integrated": "An unusual gift for organizing all transient enterprise in patterns of rewarding overall effectiveness.",
        "stress": "Stubborn blindness to the general welfare."
      },
      "optionText": {
        "default": "Linkage in activity of all community values. Free flow from ideas to consummation. Sense of significance in relationship.",
        "integrated": "An unusual gift for organizing all transient enterprise in patterns of rewarding overall effectiveness.",
        "stress": "Stubborn blindness to the general welfare."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_05",
      "sign": "pisces",
      "sabianDegree": 5,
      "zodiacDegreeInterval": "4°00′00″–4°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "A WARM-HEARTED CROWD GATHERS AT A CHURCH BAZAAR",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Interchange of spirit and understanding on which groups are built. New self-development. Discouragement mastered. Commerce.",
        "integrated": "A special genius for philanthropy and the organization of society's real concern for the well-being of men in general.",
        "stress": "Social exclusiveness and smug self-satisfaction."
      },
      "optionText": {
        "default": "Interchange of spirit and understanding on which groups are built. New self-development. Discouragement mastered. Commerce.",
        "integrated": "A special genius for philanthropy and the organization of society's real concern for the well-being of men in general.",
        "stress": "Social exclusiveness and smug self-satisfaction."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_06",
      "sign": "pisces",
      "sabianDegree": 6,
      "zodiacDegreeInterval": "5°00′00″–5°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "A PARADE OF WEST POINT CADETS IS HELD AS THE SUN SETS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Self-exaltation through consecration to the task of defending collective values. Self-testing. Perception of high goals.",
        "integrated": "Schooled self-assurance and absolute responsibility.",
        "stress": "Unimaginative exercise of special privilege."
      },
      "optionText": {
        "default": "Self-exaltation through consecration to the task of defending collective values. Self-testing. Perception of high goals.",
        "integrated": "Schooled self-assurance and absolute responsibility.",
        "stress": "Unimaginative exercise of special privilege."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_07",
      "sign": "pisces",
      "sabianDegree": 7,
      "zodiacDegreeInterval": "6°00′00″–6°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "FOG HIDES THE SHORE; BUT ON A CLEAR ROCK A CROSS RESTS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Concentration of values amidst the chaos of outer living. Clear light of high realization. Acceptance of life's limits.",
        "integrated": "A rugged independence of inner spirit and a courageous rejection of all outer compromise.",
        "stress": "Utter timidity of self-interest."
      },
      "optionText": {
        "default": "Concentration of values amidst the chaos of outer living. Clear light of high realization. Acceptance of life's limits.",
        "integrated": "A rugged independence of inner spirit and a courageous rejection of all outer compromise.",
        "stress": "Utter timidity of self-interest."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_08",
      "sign": "pisces",
      "sabianDegree": 8,
      "zodiacDegreeInterval": "7°00′00″–7°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "GIRL-SCOUT, IN CAMP, BLOWS HER BUGLE TRIUMPHANTLY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Fullness of life as it manifests in service to the whole. Spiritual socialization. Call to participation in the race work.",
        "integrated": "An eagerness for self-expression and an alertness to every opportunity for self-justification.",
        "stress": "Officiousness and delight in regimentation."
      },
      "optionText": {
        "default": "Fullness of life as it manifests in service to the whole. Spiritual socialization. Call to participation in the race work.",
        "integrated": "An eagerness for self-expression and an alertness to every opportunity for self-justification.",
        "stress": "Officiousness and delight in regimentation."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_09",
      "sign": "pisces",
      "sabianDegree": 9,
      "zodiacDegreeInterval": "8°00′00″–8°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "THE RACE BEGINS: A JOCKEY SPURS HIS HORSE TO GREAT SPEED",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The capacity of man to throw himself fully into any type of activity. Self-quickening. Premature expenditure of energy.",
        "integrated": "A spectacular gift for rising to any occasion.",
        "stress": "Witless gambling of every resource and potentiality."
      },
      "optionText": {
        "default": "The capacity of man to throw himself fully into any type of activity. Self-quickening. Premature expenditure of energy.",
        "integrated": "A spectacular gift for rising to any occasion.",
        "stress": "Witless gambling of every resource and potentiality."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_10",
      "sign": "pisces",
      "sabianDegree": 10,
      "zodiacDegreeInterval": "9°00′00″–9°59′59″",
      "decan": 1,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "THE AVIATOR SAILS ACROSS THE SKY, MASTER OF HIGH REALMS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Transcendence of normal problems. Gaining of celestial responsibilities. Consummation of the highest ideals. Coronation.",
        "integrated": "Special competence in whole judgement and long-range planning.",
        "stress": "Insensate otherworldliness or irresponsible isolationism."
      },
      "optionText": {
        "default": "Transcendence of normal problems. Gaining of celestial responsibilities. Consummation of the highest ideals. Coronation.",
        "integrated": "Special competence in whole judgement and long-range planning.",
        "stress": "Insensate otherworldliness or irresponsible isolationism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_11",
      "sign": "pisces",
      "sabianDegree": 11,
      "zodiacDegreeInterval": "10°00′00″–10°59′59″",
      "decan": 2,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "SEEKERS FOR ILLUMINATION ARE GUIDED INTO THE SANCTUARY",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Introduction of conscious mind to the intuitive soul-realms. Self-dedication. Self-awakening; or surrender to inner fears.",
        "integrated": "High accomplishment in an effective alignment with the ultimate reality.",
        "stress": "Obvious hypocrisy."
      },
      "optionText": {
        "default": "Introduction of conscious mind to the intuitive soul-realms. Self-dedication. Self-awakening; or surrender to inner fears.",
        "integrated": "High accomplishment in an effective alignment with the ultimate reality.",
        "stress": "Obvious hypocrisy."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_12",
      "sign": "pisces",
      "sabianDegree": 12,
      "zodiacDegreeInterval": "11°00′00″–11°59′59″",
      "decan": 2,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "CANDIDATES ARE BEING EXAMINED BY THE LODGE OF INITIATES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Inner ordeal before every true seeker. The individual facing collective wisdom. Re-affirmation of purpose. God-revelation.",
        "integrated": "Instinctive conformity to the highest expectation of everybody concerned in each new situation of consequence.",
        "stress": "Embittered self-solicitude."
      },
      "optionText": {
        "default": "Inner ordeal before every true seeker. The individual facing collective wisdom. Re-affirmation of purpose. God-revelation.",
        "integrated": "Instinctive conformity to the highest expectation of everybody concerned in each new situation of consequence.",
        "stress": "Embittered self-solicitude."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_13",
      "sign": "pisces",
      "sabianDegree": 13,
      "zodiacDegreeInterval": "12°00′00″–12°59′59″",
      "decan": 2,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "OLD WEAPONS IN A MUSEUM: IN A GLASS CASE, A SACRED SWORD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Courage and fearlessness needed in the quest for spirit and real understanding. Real faith in self; or emptiness of dread.",
        "integrated": "Personal power in living common ideals.",
        "stress": "Ridiculous pretence of epic merit."
      },
      "optionText": {
        "default": "Courage and fearlessness needed in the quest for spirit and real understanding. Real faith in self; or emptiness of dread.",
        "integrated": "Personal power in living common ideals.",
        "stress": "Ridiculous pretence of epic merit."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_14",
      "sign": "pisces",
      "sabianDegree": 14,
      "zodiacDegreeInterval": "13°00′00″–13°59′59″",
      "decan": 2,
      "span": "SPAN 23: PISCES 1-15: THE SPAN OF INNOCENCE",
      "image": "A YOUNG LADY, WRAPPED IN FURS, DISPLAYS SUPREME ELEGANCE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Necessary superficial advertisement of inner worth. Certification of true merit. Schooled esteem. Embarrassing wealth.",
        "integrated": "High accomplishment through a consistent representation of the self's assets in the best possible light.",
        "stress": "Amoral opportunism."
      },
      "optionText": {
        "default": "Necessary superficial advertisement of inner worth. Certification of true merit. Schooled esteem. Embarrassing wealth.",
        "integrated": "High accomplishment through a consistent representation of the self's assets in the best possible light.",
        "stress": "Amoral opportunism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_15",
      "sign": "pisces",
      "sabianDegree": 15,
      "zodiacDegreeInterval": "14°00′00″–14°59′59″",
      "decan": 2,
      "span": "",
      "image": "AN OFFICER PREPARING TO DRILL HIS PEOPLE",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Gather diffuse energy into disciplined preparation before coordinated action begins.",
        "integrated": "Create readiness, rhythm, and shared focus so a group can act effectively when needed.",
        "stress": "Over-regiment people or mistake obedience and repetition for genuine readiness."
      },
      "optionText": {
        "default": "Gather diffuse energy into disciplined preparation before coordinated action begins.",
        "integrated": "Create readiness, rhythm, and shared focus so a group can act effectively when needed.",
        "stress": "Over-regiment people or mistake obedience and repetition for genuine readiness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_16",
      "sign": "pisces",
      "sabianDegree": 16,
      "zodiacDegreeInterval": "15°00′00″–15°59′59″",
      "decan": 2,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "IN A QUIET MUSEUM, AN ART STUDENT DRINKS IN INSPIRATION",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Subjective source of strength around all manifestation. Communion with accumulated race power. Deep, vibrant realization.",
        "integrated": "Exceptional capacity for meeting the unusual developments on every level of human experience.",
        "stress": "Delusions of cleverness and contempt for real effort."
      },
      "optionText": {
        "default": "Subjective source of strength around all manifestation. Communion with accumulated race power. Deep, vibrant realization.",
        "integrated": "Exceptional capacity for meeting the unusual developments on every level of human experience.",
        "stress": "Delusions of cleverness and contempt for real effort."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_17",
      "sign": "pisces",
      "sabianDegree": 17,
      "zodiacDegreeInterval": "16°00′00″–16°59′59″",
      "decan": 2,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "EASTER: RICH AND POOR ALIKE DISPLAY THE BEST THEY OWN",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "A symbol of 'high moments' in life, when man challenges himself and renews his faith in circumstances. Self-improvement.",
        "integrated": "Tireless self-refinement in an effective inspiration of others.",
        "stress": "A craving for attention."
      },
      "optionText": {
        "default": "A symbol of 'high moments' in life, when man challenges himself and renews his faith in circumstances. Self-improvement.",
        "integrated": "Tireless self-refinement in an effective inspiration of others.",
        "stress": "A craving for attention."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_18",
      "sign": "pisces",
      "sabianDegree": 18,
      "zodiacDegreeInterval": "17°00′00″–17°59′59″",
      "decan": 2,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "IN A HUGE TENT A FAMOUS REVIVALIST CONDUCTS HIS MEETING",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Reinforcement of faith which can open up a new environment. A revision of ideas back to source. Critical survey of life.",
        "integrated": "A genius for organizing divergent capabilities in a common cause.",
        "stress": "Delusions of grandeur and unassuming bombast."
      },
      "optionText": {
        "default": "Reinforcement of faith which can open up a new environment. A revision of ideas back to source. Critical survey of life.",
        "integrated": "A genius for organizing divergent capabilities in a common cause.",
        "stress": "Delusions of grandeur and unassuming bombast."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_19",
      "sign": "pisces",
      "sabianDegree": 19,
      "zodiacDegreeInterval": "18°00′00″–18°59′59″",
      "decan": 2,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "MASTER AND PUPIL COMMUNE IN STRENGTH IN A LONG WALK",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Body-strengthening function of the soul. Release from race karma. Transmutation of everyday facts into intelligence.",
        "integrated": "High executive ability through patient investigation and genuine psychological insight.",
        "stress": "A desire to live by rule and a conceit of empty knowledge."
      },
      "optionText": {
        "default": "Body-strengthening function of the soul. Release from race karma. Transmutation of everyday facts into intelligence.",
        "integrated": "High executive ability through patient investigation and genuine psychological insight.",
        "stress": "A desire to live by rule and a conceit of empty knowledge."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_20",
      "sign": "pisces",
      "sabianDegree": 20,
      "zodiacDegreeInterval": "19°00′00″–19°59′59″",
      "decan": 2,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "IN THE QUIET OF EVENING THE FARMER'S SUPPER AWAITS HIM",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Encompassing richness of experience whenever a particular ordeal is over. Spiritual nourishment. Ingathering of forces.",
        "integrated": "An effective sensitiveness to every passing need of mankind.",
        "stress": "Naive selfishness and a wholly witless optimism."
      },
      "optionText": {
        "default": "Encompassing richness of experience whenever a particular ordeal is over. Spiritual nourishment. Ingathering of forces.",
        "integrated": "An effective sensitiveness to every passing need of mankind.",
        "stress": "Naive selfishness and a wholly witless optimism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_21",
      "sign": "pisces",
      "sabianDegree": 21,
      "zodiacDegreeInterval": "20°00′00″–20°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "CHILD WATCHED BY CHINESE SERVANT CARESSES A WHITE LAMB",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Eager probing of the soul into its many potentialities and higher reaches. Self-expansion, or refusal to grow in Spirit.",
        "integrated": "Completely unconditioned self-discovery out of wholly unlimited potentialities.",
        "stress": "Groping aimlessness."
      },
      "optionText": {
        "default": "Eager probing of the soul into its many potentialities and higher reaches. Self-expansion, or refusal to grow in Spirit.",
        "integrated": "Completely unconditioned self-discovery out of wholly unlimited potentialities.",
        "stress": "Groping aimlessness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_22",
      "sign": "pisces",
      "sabianDegree": 22,
      "zodiacDegreeInterval": "21°00′00″–21°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "DOWN A SYMBOLIC MOUNTAIN IF INDUSTRY COMES A NEW MOSES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Man's success in meeting the challenge of a new order. Codification of new values. Holding oneself to highest standards.",
        "integrated": "Self-sacrifice and a determination to further the ultimate upliftment of all men.",
        "stress": "Self-exploitation and impenetrable egotism."
      },
      "optionText": {
        "default": "Man's success in meeting the challenge of a new order. Codification of new values. Holding oneself to highest standards.",
        "integrated": "Self-sacrifice and a determination to further the ultimate upliftment of all men.",
        "stress": "Self-exploitation and impenetrable egotism."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_23",
      "sign": "pisces",
      "sabianDegree": 23,
      "zodiacDegreeInterval": "22°00′00″–22°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "A \"MATERIALIZING MEDIUM\" SUMMONS WEIRD GHOSTLY SHAPES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Display of powers which, though physical, transcend our normal awareness. Subjective mastery of, or passivity to life-forces.",
        "integrated": "Exceptional ability in shaping every immediate aspect of life to a personal convenience.",
        "stress": "Instability and confused perspective."
      },
      "optionText": {
        "default": "Display of powers which, though physical, transcend our normal awareness. Subjective mastery of, or passivity to life-forces.",
        "integrated": "Exceptional ability in shaping every immediate aspect of life to a personal convenience.",
        "stress": "Instability and confused perspective."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_24",
      "sign": "pisces",
      "sabianDegree": 24,
      "zodiacDegreeInterval": "23°00′00″–23°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "IN A TINY LOST ISLAND MEN BUILD HAPPILY THEIR OWN WORLD",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Adaptability and inherent creativeness of man. Extreme surety in self-expression. Centralization of supernal forces.",
        "integrated": "Achievement through a creative opportunism or inventiveness of exceptional order.",
        "stress": "Snobbish complacency and self-indulgence."
      },
      "optionText": {
        "default": "Adaptability and inherent creativeness of man. Extreme surety in self-expression. Centralization of supernal forces.",
        "integrated": "Achievement through a creative opportunism or inventiveness of exceptional order.",
        "stress": "Snobbish complacency and self-indulgence."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_25",
      "sign": "pisces",
      "sabianDegree": 25,
      "zodiacDegreeInterval": "24°00′00″–24°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "AFTER DRASTIC REFORMS A PURIFIED CLERGY OFFICIATES ANEW",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Ability periodically to cleanse from all selfish dross the channels for spiritual service. True vision. Soul-reformation.",
        "integrated": "Revolt against all superficial exaltation of human nature.",
        "stress": "Blind bigotry and vindictiveness."
      },
      "optionText": {
        "default": "Ability periodically to cleanse from all selfish dross the channels for spiritual service. True vision. Soul-reformation.",
        "integrated": "Revolt against all superficial exaltation of human nature.",
        "stress": "Blind bigotry and vindictiveness."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_26",
      "sign": "pisces",
      "sabianDegree": 26,
      "zodiacDegreeInterval": "25°00′00″–25°59′59″",
      "decan": 3,
      "span": "",
      "image": "A NEW MOON DIVIDING ITS INFLUENCES",
      "source": {
        "type": "external_symbol_model_derived",
        "file": "external Sabian symbol title; interpretive kernel derived for Orbo"
      },
      "kernel": {
        "default": "Recognize when a new cycle requires people, projects, or possibilities to separate and follow different paths.",
        "integrated": "Let a fresh beginning distribute energy where it can grow rather than forcing everything to remain together.",
        "stress": "Fragment too quickly, withdraw support, or treat every change of direction as a reason to abandon continuity."
      },
      "optionText": {
        "default": "Recognize when a new cycle requires people, projects, or possibilities to separate and follow different paths.",
        "integrated": "Let a fresh beginning distribute energy where it can grow rather than forcing everything to remain together.",
        "stress": "Fragment too quickly, withdraw support, or treat every change of direction as a reason to abandon continuity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_27",
      "sign": "pisces",
      "sabianDegree": 27,
      "zodiacDegreeInterval": "26°00′00″–26°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "THE HARVEST MOON RISES IN TRANSLUCENT AUTUMNAL SKIES",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "The power of creative visualization by which great Dreamers transcend outer reality. Complete dominance of circumstances.",
        "integrated": "Self-consummation which is successful beyond any possibility of measure.",
        "stress": "Loss of self in a welter of opportunity."
      },
      "optionText": {
        "default": "The power of creative visualization by which great Dreamers transcend outer reality. Complete dominance of circumstances.",
        "integrated": "Self-consummation which is successful beyond any possibility of measure.",
        "stress": "Loss of self in a welter of opportunity."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_28",
      "sign": "pisces",
      "sabianDegree": 28,
      "zodiacDegreeInterval": "27°00′00″–27°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "UNDER THE FULL MOON THE FIELDS SEEM STRANGELY ALIVE",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Normally unnoticed powers released at the fruition of natural processes. Call of universal mind to the heart. Fullness.",
        "integrated": "High reward in worldly goods and exceptional self-integrity in using them.",
        "stress": "Irritating pride of possessions."
      },
      "optionText": {
        "default": "Normally unnoticed powers released at the fruition of natural processes. Call of universal mind to the heart. Fullness.",
        "integrated": "High reward in worldly goods and exceptional self-integrity in using them.",
        "stress": "Irritating pride of possessions."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_29",
      "sign": "pisces",
      "sabianDegree": 29,
      "zodiacDegreeInterval": "28°00′00″–28°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "SCIENTIST IS MAKING TESTS BY MEANS OF SPECTRUM-ANALYSIS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Capacity of mind to transfer its power to machinery. Enlargement of perception. A closing-in of vision. Subtle analysis.",
        "integrated": "Exceptional accomplishment through judgement of unusual accuracy.",
        "stress": "Fatuous pride of intellect."
      },
      "optionText": {
        "default": "Capacity of mind to transfer its power to machinery. Enlargement of perception. A closing-in of vision. Subtle analysis.",
        "integrated": "Exceptional accomplishment through judgement of unusual accuracy.",
        "stress": "Fatuous pride of intellect."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    },
    {
      "id": "pisces_30",
      "sign": "pisces",
      "sabianDegree": 30,
      "zodiacDegreeInterval": "29°00′00″–29°59′59″",
      "decan": 3,
      "span": "SPAN 24: PISCES 16-30: THE SPAN OF PROTECTION",
      "image": "A SEER'S DREAM NOW LIVES: A FACE CARVED INTO HUGE ROCKS",
      "source": {
        "type": "supplied_primary",
        "file": "Sabian JSON.txt"
      },
      "kernel": {
        "default": "Eventual concrete manifestation of all higher poetic images and enduring truths of the race. Sure culmination of effort.",
        "integrated": "Self-integrity in its irresistible impact on the course of events.",
        "stress": "Wholly inarticulate and ineffectual self-realization."
      },
      "optionText": {
        "default": "Eventual concrete manifestation of all higher poetic images and enduring truths of the race. Sure culmination of effort.",
        "integrated": "Self-integrity in its irresistible impact on the course of events.",
        "stress": "Wholly inarticulate and ineffectual self-realization."
      },
      "derivation": {
        "integrated": "source_positive",
        "stress": "source_negative"
      }
    }
  ]
}
```

<!-- END: ORBO_SABIAN_LOCK_BANK -->

---

