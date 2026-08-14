# Orbo Whole-Sign Frames: Traditional and Modern Rulers

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
