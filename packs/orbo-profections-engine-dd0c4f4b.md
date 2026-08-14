# Orbo Profections Engine

Standalone TypeScript implementation derived from the canonical **Profections** source document.

```ts
// orbo-profections-engine.ts
//
// Standalone profections engine derived from the "PROFECTIONS" entry in
// Alan Leo's Dictionary of Astrology (1929), edited by Vivian E. Robson.
//
// This engine is intentionally independent of Horary, Trigonometry,
// Elections, and other Orbo engines.
//
// Source rules implemented:
// - One sign per year.
// - Apply the annual profection to Hyleg, Sun, Moon, Ascendant, Meridian.
// - Preserve the natal degree.
// - Year of life 1 begins at the natal position.
// - Monthly profections use 28-day months, one sign per month.
// - Daily subdivision uses one sign per 2 days 8 hours (56 hours).
// - Annual/monthly ruling signs are exposed for radix/transit comparison.
// - Chronocrator output preserves the source's singular "lord of the sign"
//   statement and its later observation that an exact-degree annual term
//   may span portions of two signs, whose lords are chronocrators.
//
// No interpretive scoring is performed.

export type ZodiacSign =
  | "Aries"
  | "Taurus"
  | "Gemini"
  | "Cancer"
  | "Leo"
  | "Virgo"
  | "Libra"
  | "Scorpio"
  | "Sagittarius"
  | "Capricorn"
  | "Aquarius"
  | "Pisces";

export type ClassicalPlanet =
  | "Sun"
  | "Moon"
  | "Mercury"
  | "Venus"
  | "Mars"
  | "Jupiter"
  | "Saturn";

export type ProfectionPointName =
  | "Hyleg"
  | "Sun"
  | "Moon"
  | "Ascendant"
  | "Meridian";

export interface ZodiacPosition {
  sign: ZodiacSign;
  degree: number;
  minute?: number;
  second?: number;
}

export interface AbsoluteZodiacPosition {
  longitudeDeg: number;
}

export interface NamedZodiacPosition {
  name: string;
  position: ZodiacPosition;
}

export interface ProfectionNatalState {
  Hyleg?: ZodiacPosition | null;
  Sun: ZodiacPosition;
  Moon: ZodiacPosition;
  Ascendant: ZodiacPosition;
  Meridian: ZodiacPosition;
}

export interface ProfectedPoint {
  point: ProfectionPointName;
  natal: ZodiacPosition;
  yearOfLife: number;
  signsAdvanced: number;
  profected: ZodiacPosition;
}

export interface ChronocratorSegment {
  sign: ZodiacSign;
  ruler: ClassicalPlanet;

  startDegreeInSign: number;
  endDegreeInSign: number;

  arcDegrees: number;
}

export interface AnnualChronocrator {
  yearOfLife: number;

  // The sign occupied at the beginning of the annual profectional term.
  startSign: ZodiacSign;
  startSignRuler: ClassicalPlanet;

  // The exact-degree term runs 30° to the same degree of the next sign.
  // If the natal degree is not 0°, the source says the term may include
  // portions of two signs and refers to the lords of those signs as
  // chronocrators.
  termSegments: ChronocratorSegment[];

  rulersInTerm: ClassicalPlanet[];
}

export interface AnnualProfection {
  yearOfLife: number;
  ageYears: number;
  signsAdvanced: number;

  points: Partial<
    Record<ProfectionPointName, ProfectedPoint>
  >;

  annualSignFromHyleg: ZodiacSign | null;
  chronocrator: AnnualChronocrator | null;
}

export interface MonthlyProfection {
  yearOfLife: number;

  // 1-based: month 1 is the first 28-day period of the profection year.
  monthOfProfectionYear: number;

  // 0-based offset from the annual sign.
  signsAdvancedFromAnnual: number;

  sign: ZodiacSign;
  ruler: ClassicalPlanet;

  startDayOffset: number;
  endDayOffset: number;
}

export interface DailySubdivision {
  // 1-based segment within a 28-day profection month.
  segment: number;

  // 0-based sign advance from the monthly sign.
  signsAdvancedFromMonthly: number;

  sign: ZodiacSign;
  ruler: ClassicalPlanet;

  startHourOffset: number;
  endHourOffset: number;
}

export interface ProfectionTimeSnapshot {
  annual: AnnualProfection;

  monthly: MonthlyProfection | null;
  daily: DailySubdivision | null;

  elapsedDaysIntoProfectionYear?: number;
  elapsedHoursIntoProfectionMonth?: number;
}

export interface RadixRepresentation {
  sign: ZodiacSign;
  radixOccupants: string[];
}

export interface TransitRepresentation {
  sign: ZodiacSign;
  transitingOccupants: string[];
}

export interface ProfectionContext {
  annualSign: ZodiacSign | null;
  monthlySign: ZodiacSign | null;
  dailySign: ZodiacSign | null;

  annualRadixRepresentation: RadixRepresentation | null;
  monthlyRadixRepresentation: RadixRepresentation | null;

  annualTransitRepresentation: TransitRepresentation | null;
  monthlyTransitRepresentation: TransitRepresentation | null;

  profectedRelationsToNatalAngles: Partial<
    Record<
      ProfectionPointName,
      {
        fromNatalAscendantSigns: number;
        fromNatalMeridianSigns: number;
        exactDeltaFromNatalAscendantDeg: number;
        exactDeltaFromNatalMeridianDeg: number;
      }
    >
  >;
}

export const SIGN_ORDER: ZodiacSign[] = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces",
];

export const CLASSICAL_RULER: Record<
  ZodiacSign,
  ClassicalPlanet
> = {
  Aries: "Mars",
  Taurus: "Venus",
  Gemini: "Mercury",
  Cancer: "Moon",
  Leo: "Sun",
  Virgo: "Mercury",
  Libra: "Venus",
  Scorpio: "Mars",
  Sagittarius: "Jupiter",
  Capricorn: "Saturn",
  Aquarius: "Saturn",
  Pisces: "Jupiter",
};

export const DAYS_PER_PROFECTION_MONTH = 28;
export const HOURS_PER_DAILY_SIGN = 56; // 2 days 8 hours
export const DAILY_SEGMENTS_PER_MONTH =
  (DAYS_PER_PROFECTION_MONTH * 24) /
  HOURS_PER_DAILY_SIGN; // 12

function assertFinite(
  value: number,
  label: string
): void {
  if (!Number.isFinite(value)) {
    throw new Error(`${label} must be finite.`);
  }
}

export function normalizeLongitude(
  longitudeDeg: number
): number {
  assertFinite(longitudeDeg, "longitudeDeg");

  const x = longitudeDeg % 360;
  return x < 0 ? x + 360 : x;
}

export function normalizeSignIndex(
  index: number
): number {
  if (!Number.isInteger(index)) {
    throw new Error(
      "Sign index must be an integer."
    );
  }

  const x = index % 12;
  return x < 0 ? x + 12 : x;
}

export function signIndex(
  sign: ZodiacSign
): number {
  return SIGN_ORDER.indexOf(sign);
}

export function signFromIndex(
  index: number
): ZodiacSign {
  return SIGN_ORDER[
    normalizeSignIndex(index)
  ];
}

export function rulerOf(
  sign: ZodiacSign
): ClassicalPlanet {
  return CLASSICAL_RULER[sign];
}

export function positionToLongitude(
  position: ZodiacPosition
): number {
  const degree =
    position.degree +
    (position.minute ?? 0) / 60 +
    (position.second ?? 0) / 3600;

  if (
    degree < 0 ||
    degree >= 30
  ) {
    throw new Error(
      "ZodiacPosition degree/minute/second must resolve to >= 0 and < 30 degrees within the sign."
    );
  }

  return normalizeLongitude(
    signIndex(position.sign) * 30 +
      degree
  );
}

export function longitudeToPosition(
  longitudeDeg: number
): ZodiacPosition {
  const lon =
    normalizeLongitude(longitudeDeg);

  const index =
    Math.floor(lon / 30);

  const within =
    lon - index * 30;

  let degree =
    Math.floor(within);

  const minuteFloat =
    (within - degree) * 60;

  let minute =
    Math.floor(minuteFloat);

  let second =
    (minuteFloat - minute) * 60;

  // Numerical cleanup near exact boundaries.
  if (second >= 59.9999995) {
    second = 0;
    minute += 1;
  }

  if (minute >= 60) {
    minute = 0;
    degree += 1;
  }

  if (degree >= 30) {
    return {
      sign: signFromIndex(index + 1),
      degree: 0,
      minute: 0,
      second: 0,
    };
  }

  return {
    sign: SIGN_ORDER[index],
    degree,
    minute,
    second,
  };
}

export function degreeWithinSign(
  position: ZodiacPosition
): number {
  return (
    position.degree +
    (position.minute ?? 0) / 60 +
    (position.second ?? 0) / 3600
  );
}

/**
 * The source's first year runs from the natal degree to the same degree
 * one sign later. Therefore yearOfLife 1 advances zero signs from birth.
 */
export function signsAdvancedForYearOfLife(
  yearOfLife: number
): number {
  if (
    !Number.isInteger(yearOfLife) ||
    yearOfLife < 1
  ) {
    throw new Error(
      "yearOfLife must be an integer >= 1."
    );
  }

  return yearOfLife - 1;
}

/**
 * Convenience correspondence:
 * age 0 -> year of life 1
 * age 1 -> year of life 2
 */
export function yearOfLifeFromAge(
  ageYears: number
): number {
  if (
    !Number.isInteger(ageYears) ||
    ageYears < 0
  ) {
    throw new Error(
      "ageYears must be an integer >= 0."
    );
  }

  return ageYears + 1;
}

export function profectPositionBySigns(
  position: ZodiacPosition,
  signs: number
): ZodiacPosition {
  if (!Number.isInteger(signs)) {
    throw new Error(
      "Profection sign advance must be an integer."
    );
  }

  return longitudeToPosition(
    positionToLongitude(position) +
      signs * 30
  );
}

export function profectPoint(
  point: ProfectionPointName,
  natal: ZodiacPosition,
  yearOfLife: number
): ProfectedPoint {
  const signsAdvanced =
    signsAdvancedForYearOfLife(
      yearOfLife
    );

  return {
    point,
    natal,
    yearOfLife,
    signsAdvanced,
    profected:
      profectPositionBySigns(
        natal,
        signsAdvanced
      ),
  };
}

/**
 * Exact 30-degree annual term from the Hyleg.
 *
 * Example from source:
 * 2° Libra 13' -> 2° Scorpio 13'
 *
 * This traverses:
 * - Libra from 2°13' to 30°
 * - Scorpio from 0° to 2°13'
 *
 * The source later calls the lords of the signs traversed the actual
 * chronocrators for the year. We preserve the segments without inventing
 * a numerical hierarchy.
 */
export function annualChronocratorFromHyleg(
  natalHyleg: ZodiacPosition,
  yearOfLife: number
): AnnualChronocrator {
  const annualStart =
    profectPositionBySigns(
      natalHyleg,
      signsAdvancedForYearOfLife(
        yearOfLife
      )
    );

  const d =
    degreeWithinSign(annualStart);

  const startSign =
    annualStart.sign;

  const nextSign =
    signFromIndex(
      signIndex(startSign) + 1
    );

  const segments: ChronocratorSegment[] =
    [];

  const firstArc = 30 - d;

  if (firstArc > 1e-12) {
    segments.push({
      sign: startSign,
      ruler: rulerOf(startSign),
      startDegreeInSign: d,
      endDegreeInSign: 30,
      arcDegrees: firstArc,
    });
  }

  if (d > 1e-12) {
    segments.push({
      sign: nextSign,
      ruler: rulerOf(nextSign),
      startDegreeInSign: 0,
      endDegreeInSign: d,
      arcDegrees: d,
    });
  }

  // Exact 0° begins a full 30° term in one sign.
  if (segments.length === 0) {
    segments.push({
      sign: startSign,
      ruler: rulerOf(startSign),
      startDegreeInSign: 0,
      endDegreeInSign: 30,
      arcDegrees: 30,
    });
  }

  const rulersInTerm =
    Array.from(
      new Set(
        segments.map(
          (segment) =>
            segment.ruler
        )
      )
    );

  return {
    yearOfLife,
    startSign,
    startSignRuler:
      rulerOf(startSign),
    termSegments: segments,
    rulersInTerm,
  };
}

export function annualProfection(
  natal: ProfectionNatalState,
  yearOfLife: number
): AnnualProfection {
  const signsAdvanced =
    signsAdvancedForYearOfLife(
      yearOfLife
    );

  const points: Partial<
    Record<
      ProfectionPointName,
      ProfectedPoint
    >
  > = {};

  const entries: Array<
    [
      ProfectionPointName,
      ZodiacPosition | null | undefined
    ]
  > = [
    ["Hyleg", natal.Hyleg],
    ["Sun", natal.Sun],
    ["Moon", natal.Moon],
    ["Ascendant", natal.Ascendant],
    ["Meridian", natal.Meridian],
  ];

  for (const [name, position] of entries) {
    if (!position) continue;

    points[name] = profectPoint(
      name,
      position,
      yearOfLife
    );
  }

  const chronocrator =
    natal.Hyleg
      ? annualChronocratorFromHyleg(
          natal.Hyleg,
          yearOfLife
        )
      : null;

  return {
    yearOfLife,
    ageYears: yearOfLife - 1,
    signsAdvanced,
    points,
    annualSignFromHyleg:
      points.Hyleg?.profected
        .sign ?? null,
    chronocrator,
  };
}

/**
 * Monthly profection from the annual sign.
 *
 * Month 1 is the first 28-day period and uses the annual sign.
 * Each following 28-day period advances one sign.
 *
 * The source does not limit this to twelve civil months. Because each
 * period is exactly 28 days, this function permits month 13 and beyond.
 */
export function monthlyProfection(
  annualSign: ZodiacSign,
  yearOfLife: number,
  monthOfProfectionYear: number
): MonthlyProfection {
  if (
    !Number.isInteger(
      monthOfProfectionYear
    ) ||
    monthOfProfectionYear < 1
  ) {
    throw new Error(
      "monthOfProfectionYear must be an integer >= 1."
    );
  }

  const advance =
    monthOfProfectionYear - 1;

  const sign =
    signFromIndex(
      signIndex(annualSign) +
        advance
    );

  return {
    yearOfLife,
    monthOfProfectionYear,
    signsAdvancedFromAnnual:
      advance,
    sign,
    ruler: rulerOf(sign),
    startDayOffset:
      advance *
      DAYS_PER_PROFECTION_MONTH,
    endDayOffset:
      monthOfProfectionYear *
      DAYS_PER_PROFECTION_MONTH,
  };
}

/**
 * Resolve the source's 28-day monthly period from elapsed days into the
 * annual profectional year.
 *
 * This is a computational convenience. The source gives the 28-day rule
 * but does not define a civil-calendar algorithm for anniversaries or
 * leap years.
 */
export function monthlyProfectionFromElapsedDays(
  annualSign: ZodiacSign,
  yearOfLife: number,
  elapsedDaysIntoProfectionYear: number
): MonthlyProfection {
  assertFinite(
    elapsedDaysIntoProfectionYear,
    "elapsedDaysIntoProfectionYear"
  );

  if (elapsedDaysIntoProfectionYear < 0) {
    throw new Error(
      "elapsedDaysIntoProfectionYear must be >= 0."
    );
  }

  const month =
    Math.floor(
      elapsedDaysIntoProfectionYear /
        DAYS_PER_PROFECTION_MONTH
    ) + 1;

  return monthlyProfection(
    annualSign,
    yearOfLife,
    month
  );
}

/**
 * Daily subdivision within a 28-day month.
 *
 * Source: one sign for every 2 days 8 hours = 56 hours.
 * Twelve such intervals exactly fill 28 days.
 */
export function dailySubdivision(
  monthlySign: ZodiacSign,
  elapsedHoursIntoProfectionMonth: number
): DailySubdivision {
  assertFinite(
    elapsedHoursIntoProfectionMonth,
    "elapsedHoursIntoProfectionMonth"
  );

  const monthHours =
    DAYS_PER_PROFECTION_MONTH *
    24;

  if (
    elapsedHoursIntoProfectionMonth <
      0 ||
    elapsedHoursIntoProfectionMonth >=
      monthHours
  ) {
    throw new Error(
      `elapsedHoursIntoProfectionMonth must be >= 0 and < ${monthHours}.`
    );
  }

  const zeroBasedSegment =
    Math.floor(
      elapsedHoursIntoProfectionMonth /
        HOURS_PER_DAILY_SIGN
    );

  const sign =
    signFromIndex(
      signIndex(monthlySign) +
        zeroBasedSegment
    );

  return {
    segment: zeroBasedSegment + 1,
    signsAdvancedFromMonthly:
      zeroBasedSegment,
    sign,
    ruler: rulerOf(sign),
    startHourOffset:
      zeroBasedSegment *
      HOURS_PER_DAILY_SIGN,
    endHourOffset:
      (zeroBasedSegment + 1) *
      HOURS_PER_DAILY_SIGN,
  };
}

export function buildProfectionTimeSnapshot(
  natal: ProfectionNatalState,
  yearOfLife: number,
  elapsedDaysIntoProfectionYear?: number,
  elapsedHoursIntoProfectionMonth?: number
): ProfectionTimeSnapshot {
  const annual =
    annualProfection(
      natal,
      yearOfLife
    );

  const annualSign =
    annual.annualSignFromHyleg;

  if (!annualSign) {
    return {
      annual,
      monthly: null,
      daily: null,
      elapsedDaysIntoProfectionYear,
      elapsedHoursIntoProfectionMonth,
    };
  }

  const monthly =
    elapsedDaysIntoProfectionYear ==
    null
      ? null
      : monthlyProfectionFromElapsedDays(
          annualSign,
          yearOfLife,
          elapsedDaysIntoProfectionYear
        );

  const daily =
    monthly &&
    elapsedHoursIntoProfectionMonth !=
      null
      ? dailySubdivision(
          monthly.sign,
          elapsedHoursIntoProfectionMonth
        )
      : null;

  return {
    annual,
    monthly,
    daily,
    elapsedDaysIntoProfectionYear,
    elapsedHoursIntoProfectionMonth,
  };
}

export function signsBetween(
  from: ZodiacSign,
  to: ZodiacSign
): number {
  return normalizeSignIndex(
    signIndex(to) -
      signIndex(from)
  );
}

export function exactForwardDeltaDeg(
  from: ZodiacPosition,
  to: ZodiacPosition
): number {
  return normalizeLongitude(
    positionToLongitude(to) -
      positionToLongitude(from)
  );
}

export function occupantsInSign(
  positions: NamedZodiacPosition[],
  sign: ZodiacSign
): string[] {
  return positions
    .filter(
      (entry) =>
        entry.position.sign === sign
    )
    .map((entry) => entry.name);
}

/**
 * The source asks the astrologer to notice:
 * - representation of profected places in the radix, as regards sign/planet;
 * - their progressed position relative to Ascendant and M.C.;
 * - transiting planets passing through signs ruling the year or month.
 *
 * This function compiles those facts only. It performs no interpretation.
 */
export function compileProfectionContext(
  snapshot: ProfectionTimeSnapshot,
  natal: ProfectionNatalState,
  radixPlanets: NamedZodiacPosition[],
  transits: NamedZodiacPosition[]
): ProfectionContext {
  const annualSign =
    snapshot.annual
      .annualSignFromHyleg;

  const monthlySign =
    snapshot.monthly?.sign ??
    null;

  const dailySign =
    snapshot.daily?.sign ??
    null;

  const radixFor = (
    sign: ZodiacSign | null
  ): RadixRepresentation | null =>
    sign
      ? {
          sign,
          radixOccupants:
            occupantsInSign(
              radixPlanets,
              sign
            ),
        }
      : null;

  const transitFor = (
    sign: ZodiacSign | null
  ): TransitRepresentation | null =>
    sign
      ? {
          sign,
          transitingOccupants:
            occupantsInSign(
              transits,
              sign
            ),
        }
      : null;

  const relations: ProfectionContext[
    "profectedRelationsToNatalAngles"
  ] = {};

  for (const [
    point,
    data,
  ] of Object.entries(
    snapshot.annual.points
  ) as Array<
    [
      ProfectionPointName,
      ProfectedPoint | undefined
    ]
  >) {
    if (!data) continue;

    relations[point] = {
      fromNatalAscendantSigns:
        signsBetween(
          natal.Ascendant.sign,
          data.profected.sign
        ),
      fromNatalMeridianSigns:
        signsBetween(
          natal.Meridian.sign,
          data.profected.sign
        ),
      exactDeltaFromNatalAscendantDeg:
        exactForwardDeltaDeg(
          natal.Ascendant,
          data.profected
        ),
      exactDeltaFromNatalMeridianDeg:
        exactForwardDeltaDeg(
          natal.Meridian,
          data.profected
        ),
    };
  }

  return {
    annualSign,
    monthlySign,
    dailySign,

    annualRadixRepresentation:
      radixFor(annualSign),
    monthlyRadixRepresentation:
      radixFor(monthlySign),

    annualTransitRepresentation:
      transitFor(annualSign),
    monthlyTransitRepresentation:
      transitFor(monthlySign),

    profectedRelationsToNatalAngles:
      relations,
  };
}

/**
 * Source example:
 * Hyleg = 2° Libra 13'
 * Year of life 27 should begin at 2° Sagittarius 13'
 * and end at 2° Capricorn 13'.
 */
export function sourceExampleYear27(): {
  hyleg: ZodiacPosition;
  annual: AnnualChronocrator;
  expectedStart: ZodiacPosition;
  expectedEnd: ZodiacPosition;
} {
  const hyleg: ZodiacPosition = {
    sign: "Libra",
    degree: 2,
    minute: 13,
  };

  const annual =
    annualChronocratorFromHyleg(
      hyleg,
      27
    );

  return {
    hyleg,
    annual,
    expectedStart: {
      sign: "Sagittarius",
      degree: 2,
      minute: 13,
    },
    expectedEnd: {
      sign: "Capricorn",
      degree: 2,
      minute: 13,
    },
  };
}
```
