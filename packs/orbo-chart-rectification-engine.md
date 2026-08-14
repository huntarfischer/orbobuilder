# Orbo Chart Rectification Engine

Code it as a **search engine over possible birth times**. The questions do not construct a chart. They redistribute weight among charts that already exist.

The architecture should be:

```text
Birth date + location
        ↓
Generate every possible birth minute
        ↓
Compile each minute into a candidate Regulatory Snapshot
        ↓
Group candidates by Moon sign, rising sign, frame, and degree
        ↓
Ask the question that best separates the surviving candidates
        ↓
Reweight candidates
        ↓
Repeat until Orbo reaches a useful confidence level
```

The rectification engine should sit **after** the AstroState Compiler:

```text
Candidate AstroStates
        ↓
AstroState Compiler
        ↓
Candidate Regulatory Snapshots
        ↓
Rectification Engine
        ↓
Selected or narrowed Candidate AstroState
```

The compiler still performs zero interpretation. Rectification is an inference system consuming its output.

## 1. Generate candidate charts

For an unknown birth time, generate one candidate for every valid local minute of the birth date.

Usually this is 1,440 candidates. On daylight-saving transition dates it may be 1,380 or 1,500, so generate actual zoned minutes rather than assuming every day has exactly 24 hours.

```typescript
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

export interface ZodiacPosition {
  longitude: number;
  sign: ZodiacSign;
  degreeInSign: number;
}

export interface RectificationInput {
  birthDate: string;       // YYYY-MM-DD
  timeZone: string;        // America/Chicago
  latitude: number;
  longitude: number;
}

export interface CandidateChart {
  id: string;

  localDateTime: string;
  utcTimestamp: number;

  moon: ZodiacPosition;
  ascendant: ZodiacPosition;
  midheaven: ZodiacPosition;

  ascendantRuler: string;
  ascendantRulerHouse: number;

  snapshot: RegulatorySnapshot;

  logWeight: number;
}
```

The ephemeris should be hidden behind an adapter:

```typescript
export interface EphemerisAdapter {
  calculateChart(input: {
    utcTimestamp: number;
    latitude: number;
    longitude: number;
  }): Promise<AstroState>;
}
```

Then generate the candidates:

```typescript
export async function generateCandidates(
  input: RectificationInput,
  ephemeris: EphemerisAdapter,
  compiler: AstroStateCompiler
): Promise<CandidateChart[]> {
  const localMinutes = enumerateLocalMinutes(
    input.birthDate,
    input.timeZone
  );

  const candidates: CandidateChart[] = [];

  for (const minute of localMinutes) {
    const astroState = await ephemeris.calculateChart({
      utcTimestamp: minute.utcTimestamp,
      latitude: input.latitude,
      longitude: input.longitude
    });

    const snapshot = compiler.compile(astroState);

    const ascendant = snapshot.angles.ascendant;
    const moon = snapshot.planets.Moon;
    const midheaven = snapshot.angles.midheaven;

    const ascendantRuler =
      snapshot.frames.primaryAscendantRuler;

    const ascendantRulerHouse =
      snapshot.planets[ascendantRuler].wholeSignHouse;

    candidates.push({
      id: String(minute.utcTimestamp),
      localDateTime: minute.localDateTime,
      utcTimestamp: minute.utcTimestamp,

      moon,
      ascendant,
      midheaven,

      ascendantRuler,
      ascendantRulerHouse,

      snapshot,

      // Uniform prior before Orbo knows anything.
      logWeight: 0
    });
  }

  return candidates;
}
```

For performance, cache the generated candidate set by:

```text
birth date
birth location
time zone
ephemeris version
compiler version
```

You do not want to recalculate all 1,440 charts after every answer.

## 2. Keep the full minute candidates, but group them

The user should not see 1,440 possibilities. Orbo groups them according to the current stage.

```typescript
export interface CandidateSummary {
  moonSigns: Record<ZodiacSign, number>;
  risingSigns: Record<ZodiacSign, number>;
  ascendantDegrees: Record<number, number>;
  timeRanges: Array<{
    start: string;
    end: string;
    probability: number;
  }>;
}
```

For example:

```text
Moon:
Virgo 41%
Libra 59%

Rising signs:
Virgo 44%
Libra 38%
Scorpio 18%
```

These numbers are the total normalized weight of all candidate minutes belonging to each group.

## 3. Use log-likelihood scoring

Do not simply give candidates arbitrary points. Use likelihood multipliers stored as logarithms.

```typescript
export type TwoToFour<T> =
  | [T, T]
  | [T, T, T]
  | [T, T, T, T];

export interface PublicQuestion {
  id: string;
  prompt: string;
  options: TwoToFour<{
    id: string;
    label: string;
  }>;
}

export interface InternalQuestion extends PublicQuestion {
  evidenceType:
    | "temporal"
    | "lunar"
    | "structural"
    | "biographical"
    | "chronological"
    | "eclipse"
    | "symbolic";

  evidenceFamily: string;

  evaluateAnswer: (
    optionId: string,
    candidate: CandidateChart
  ) => number;
}
```

`evaluateAnswer` returns a likelihood:

```text
1.00 = completely neutral
0.80 = answer strongly supports candidate
0.60 = answer mildly supports candidate
0.40 = answer mildly contradicts candidate
0.20 = answer strongly contradicts candidate
0.00 = candidate is impossible
```

Apply an answer like this:

```typescript
export function applyAnswer(
  candidates: CandidateChart[],
  question: InternalQuestion,
  optionId: string
): CandidateChart[] {
  return candidates.map(candidate => {
    const likelihood =
      question.evaluateAnswer(optionId, candidate);

    if (likelihood <= 0) {
      return {
        ...candidate,
        logWeight: Number.NEGATIVE_INFINITY
      };
    }

    return {
      ...candidate,
      logWeight:
        candidate.logWeight + Math.log(likelihood)
    };
  });
}
```

Normalize afterward:

```typescript
export function normalizeCandidates(
  candidates: CandidateChart[]
): Array<CandidateChart & { probability: number }> {
  const finiteWeights = candidates
    .map(candidate => candidate.logWeight)
    .filter(Number.isFinite);

  const maximum = Math.max(...finiteWeights);

  const total = candidates.reduce((sum, candidate) => {
    if (!Number.isFinite(candidate.logWeight)) {
      return sum;
    }

    return sum + Math.exp(candidate.logWeight - maximum);
  }, 0);

  return candidates.map(candidate => ({
    ...candidate,
    probability: Number.isFinite(candidate.logWeight)
      ? Math.exp(candidate.logWeight - maximum) / total
      : 0
  }));
}
```

This lets factual answers nearly eliminate candidates while personality answers only gently steer the field.

## 4. Encode evidence strength separately

A family memory should not be treated like a birth certificate.

```typescript
export type EvidenceReliability =
  | "recorded"
  | "strong_memory"
  | "approximate_memory"
  | "objective_event"
  | "self_report"
  | "symbolic";

export const RELIABILITY_MULTIPLIER:
  Record<EvidenceReliability, number> = {
    recorded: 1.0,
    strong_memory: 0.85,
    approximate_memory: 0.55,
    objective_event: 0.85,
    self_report: 0.35,
    symbolic: 0.15
  };
```

Then soften the likelihood according to reliability:

```typescript
export function adjustLikelihood(
  likelihood: number,
  reliability: EvidenceReliability
): number {
  const strength = RELIABILITY_MULTIPLIER[reliability];

  // Pull weak evidence toward neutral 0.5.
  return 0.5 + (likelihood - 0.5) * strength;
}
```

A personality answer should never overpower three dated events. Sabian answers should never overpower eclipse or angle timing.

## 5. The first backend calculation is the Moon range

Immediately after generating the candidates:

```typescript
export function getMoonBranches(
  candidates: CandidateChart[]
): Map<ZodiacSign, CandidateChart[]> {
  const branches = new Map<ZodiacSign, CandidateChart[]>();

  for (const candidate of candidates) {
    const sign = candidate.moon.sign;
    const existing = branches.get(sign) ?? [];

    existing.push(candidate);
    branches.set(sign, existing);
  }

  return branches;
}
```

If the map has one sign:

```text
The Moon does not change signs that day.
No Moon-sign question is required.
```

If it has two signs:

```text
The Moon changes signs.
The time question may settle the Moon branch automatically.
```

Find the ingress boundary:

```typescript
export function findMoonIngress(
  candidates: CandidateChart[]
): {
  from: ZodiacSign;
  to: ZodiacSign;
  localDateTime: string;
} | null {
  for (let index = 1; index < candidates.length; index++) {
    const previous = candidates[index - 1];
    const current = candidates[index];

    if (previous.moon.sign !== current.moon.sign) {
      return {
        from: previous.moon.sign,
        to: current.moon.sign,
        localDateTime: current.localDateTime
      };
    }
  }

  return null;
}
```

The Moon sign should first be resolved temporally. Only use personality when temporal information cannot resolve it.

## 6. Broad time-of-day question

The public question can remain very simple:

```typescript
export const timeOfDayQuestion: InternalQuestion = {
  id: "birth-time-daypart",
  prompt: "When were you born?",
  options: [
    {
      id: "morning",
      label: "Morning"
    },
    {
      id: "day",
      label: "During the day"
    },
    {
      id: "night",
      label: "At night"
    },
    {
      id: "unknown",
      label: "I don’t know"
    }
  ],

  evidenceType: "temporal",
  evidenceFamily: "birth-memory:daypart",

  evaluateAnswer(optionId, candidate) {
    if (optionId === "unknown") {
      return 1;
    }

    const hour = new Date(
      candidate.localDateTime
    ).getHours();

    if (optionId === "morning") {
      return hour >= 5 && hour < 12 ? 0.85 : 0.25;
    }

    if (optionId === "day") {
      return hour >= 12 && hour < 18 ? 0.85 : 0.25;
    }

    if (optionId === "night") {
      return hour >= 18 || hour < 5 ? 0.85 : 0.25;
    }

    return 1;
  }
};
```

For production, use the zoned local hour, not JavaScript’s machine-local `Date` interpretation.

Also, this should usually be **soft evidence**. A person remembering “night” may mean 8 PM, midnight, or simply after dinner.

A recorded AM/PM indication could be hard evidence.

## 7. Build whole-sign frame features from candidates

The Frame is derived from the Ascendant sign:

```typescript
const SIGNS: ZodiacSign[] = [
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
  "Pisces"
];

export function signIndex(sign: ZodiacSign): number {
  return SIGNS.indexOf(sign);
}

export function wholeSignHouse(
  placementSign: ZodiacSign,
  ascendantSign: ZodiacSign
): number {
  return (
    (signIndex(placementSign) -
      signIndex(ascendantSign) +
      12) %
      12
  ) + 1;
}
```

Traditional rulership can remain primary:

```typescript
export const TRADITIONAL_RULERS:
  Record<ZodiacSign, string> = {
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
    Pisces: "Jupiter"
  };
```

Modern rulership can be stored as secondary metadata rather than replacing the chart ruler.

## 8. Generate personality questions compositionally

Do not write 144 separate “rising sign plus ruler-house” descriptions.

Store fragments for:

```text
12 Ascendant signs
7 traditional rulers
12 ruler houses
planetary condition modifiers
important first-house planets
```

Then synthesize them.

```typescript
const ASCENDANT_STYLE: Record<ZodiacSign, string> = {
  Aries:
    "You enter situations directly and tend to act before waiting for consensus.",
  Taurus:
    "You appear steady and deliberate, preferring continuity over sudden change.",
  Gemini:
    "You meet the world through questions, language, movement, and rapid comparison.",
  Cancer:
    "You notice safety, familiarity, and emotional atmosphere before fully engaging.",
  Leo:
    "You naturally establish presence and tend to make your position visible.",
  Virgo:
    "You notice discrepancies quickly and instinctively analyze what could be improved.",
  Libra:
    "You read situations relationally and notice balance, fairness, and social response.",
  Scorpio:
    "You approach situations with intensity, privacy, and awareness of hidden motives.",
  Sagittarius:
    "You approach the world through possibility, conviction, movement, and larger meaning.",
  Capricorn:
    "You tend to assess responsibility, structure, and long-term consequences first.",
  Aquarius:
    "You maintain a degree of distance and naturally notice systems, groups, and patterns.",
  Pisces:
    "You are sensitive to atmosphere and often enter situations through intuition or adaptation."
};
```

Then ruler-in-house descriptions:

```typescript
const RULER_HOUSE_STYLE: Record<number, string> = {
  1: "Your identity and personal direction become central to the life.",
  2: "Money, survival, values, and material security repeatedly define your choices.",
  3: "Communication, siblings, learning, and the immediate environment shape your identity.",
  4: "Home, ancestry, family, and private foundations organize much of the life.",
  5: "Creativity, children, pleasure, performance, or personal expression become central.",
  6: "Work, health, obligation, maintenance, and usefulness strongly shape the life.",
  7: "Partners, rivals, clients, and consequential one-to-one relationships redirect the life.",
  8: "Crisis, secrets, loss, shared resources, inheritance, or psychological complexity recur.",
  9: "Belief, travel, teaching, religion, law, or the search for meaning define the path.",
  10: "Career, visibility, achievement, and public responsibility become dominant.",
  11: "Friends, alliances, communities, patrons, and collective goals direct the life.",
  12: "Solitude, hidden work, retreat, confinement, or life outside ordinary visibility recur."
};
```

Synthesize a candidate description:

```typescript
export function describeCandidateFrame(
  candidate: CandidateChart
): string {
  return [
    ASCENDANT_STYLE[candidate.ascendant.sign],
    RULER_HOUSE_STYLE[candidate.ascendantRulerHouse]
  ].join(" ");
}
```

In production, rewrite those two fragments into one clean sentence rather than displaying them back-to-back.

For Virgo rising with Mercury in the eighth:

```text
Others may experience you as observant and analytical, but especially drawn toward what is hidden, complicated, psychologically charged, or difficult to discuss.
```

For Libra rising with Venus in the seventh:

```text
Others may experience you as socially perceptive and relationship-centered, often understanding situations through cooperation, conflict, attraction, or the reactions of another person.
```

## 9. Generate an either/or Frame question

Find the top two rising signs:

```typescript
export function aggregateByRisingSign(
  normalized: Array<CandidateChart & { probability: number }>
): Map<ZodiacSign, number> {
  const totals = new Map<ZodiacSign, number>();

  for (const candidate of normalized) {
    totals.set(
      candidate.ascendant.sign,
      (totals.get(candidate.ascendant.sign) ?? 0) +
        candidate.probability
    );
  }

  return totals;
}
```

Choose a representative candidate from each sign, ideally the highest-weight candidate or the modal ruler-house configuration.

```typescript
export function makeFrameComparisonQuestion(
  candidateA: CandidateChart,
  candidateB: CandidateChart
): InternalQuestion {
  const signA = candidateA.ascendant.sign;
  const signB = candidateB.ascendant.sign;

  return {
    id: `frame:${signA}:${signB}`,
    prompt:
      "Which would people close to you recognize more?",

    options: [
      {
        id: "candidate-a",
        label: describeCandidateFrame(candidateA)
      },
      {
        id: "candidate-b",
        label: describeCandidateFrame(candidateB)
      }
    ],

    evidenceType: "structural",

    evidenceFamily:
      `frame-comparison:${signA}:${signB}`,

    evaluateAnswer(optionId, candidate) {
      if (candidate.ascendant.sign === signA) {
        return optionId === "candidate-a"
          ? 0.62
          : 0.38;
      }

      if (candidate.ascendant.sign === signB) {
        return optionId === "candidate-b"
          ? 0.62
          : 0.38;
      }

      // Other rising signs remain neutral.
      return 0.5;
    }
  };
}
```

Notice the likelihood is only `0.62 / 0.38`. Personality evidence should be a thumb on the scale, not a cannonball.

## 10. Prevent personality answers from stacking endlessly

Ten questions about the chart ruler are not ten independent pieces of evidence.

Store an evidence family:

```text
personality:ascendant-style
personality:chart-ruler-house
biography:family
biography:relationships
eclipse:2017-08
```

Then cap the total influence of each family.

```typescript
export interface AppliedEvidence {
  questionId: string;
  optionId: string;
  evidenceFamily: string;
  rawLogDelta: number;
  appliedLogDelta: number;
}
```

For example:

```typescript
const FAMILY_CAPS: Record<string, number> = {
  "personality:ascendant-style": 0.8,
  "personality:chart-ruler-house": 1.0,
  "symbolic:sabian": 0.35
};
```

This keeps Orbo from “proving” a rising sign by repeatedly asking differently worded versions of the same question.

## 11. Add dated life events as structured data

Events should be stored independently from answers.

```typescript
export type LifeDomain =
  | "identity"
  | "body"
  | "money"
  | "siblings"
  | "home"
  | "children"
  | "health"
  | "relationship"
  | "loss"
  | "travel"
  | "career"
  | "community"
  | "isolation";

export interface LifeEvent {
  id: string;

  title?: string;
  dateStart: string;
  dateEnd?: string;

  datePrecision:
    | "exact"
    | "month"
    | "season"
    | "year";

  domains: LifeDomain[];

  magnitude: 1 | 2 | 3 | 4 | 5;

  chosenOrImposed?:
    | "chosen"
    | "imposed"
    | "mixed";

  publicOrPrivate?:
    | "public"
    | "private"
    | "both";
}
```

A single event can belong to multiple domains:

```json
{
  "dateStart": "2019-06-14",
  "datePrecision": "exact",
  "domains": ["relationship", "home"],
  "magnitude": 5,
  "chosenOrImposed": "mixed",
  "publicOrPrivate": "private"
}
```

The timing engine can then test the event against every candidate chart.

## 12. Code eclipse activation as a candidate feature

Store eclipse data as:

```typescript
export interface Eclipse {
  id: string;
  date: string;
  longitude: number;
  type:
    | "solar"
    | "lunar";
}
```

Angular distance:

```typescript
export function angularDistance(
  first: number,
  second: number
): number {
  return Math.abs(
    ((((first - second) % 360) + 540) % 360) - 180
  );
}
```

Calculate activation:

```typescript
export interface EclipseActivation {
  ascendantDistance: number;
  midheavenDistance: number;
  moonDistance: number;
  sunDistance: number;

  eclipseHouse: number;
  eclipseAxis: string;

  totalStrength: number;
}
```

```typescript
function gaussianStrength(
  distance: number,
  orb: number
): number {
  return Math.exp(
    -0.5 * Math.pow(distance / orb, 2)
  );
}

export function calculateEclipseActivation(
  eclipse: Eclipse,
  candidate: CandidateChart
): EclipseActivation {
  const ascendantDistance = angularDistance(
    eclipse.longitude,
    candidate.ascendant.longitude
  );

  const midheavenDistance = angularDistance(
    eclipse.longitude,
    candidate.midheaven.longitude
  );

  const moonDistance = angularDistance(
    eclipse.longitude,
    candidate.moon.longitude
  );

  const sunDistance = angularDistance(
    eclipse.longitude,
    candidate.snapshot.planets.Sun.longitude
  );

  const eclipseSign =
    longitudeToSign(eclipse.longitude);

  const eclipseHouse = wholeSignHouse(
    eclipseSign,
    candidate.ascendant.sign
  );

  const eclipseAxis =
    houseToAxis(eclipseHouse);

  const totalStrength =
    gaussianStrength(ascendantDistance, 3) * 3 +
    gaussianStrength(midheavenDistance, 3) * 3 +
    gaussianStrength(moonDistance, 2) * 1.5 +
    gaussianStrength(sunDistance, 2) * 1.5;

  return {
    ascendantDistance,
    midheavenDistance,
    moonDistance,
    sunDistance,
    eclipseHouse,
    eclipseAxis,
    totalStrength
  };
}
```

The orbs and weights should be configuration, not buried constants.

```typescript
export interface RectificationConfig {
  eclipseAngleOrb: number;
  eclipseLuminaryOrb: number;

  provisionalFrameThreshold: number;
  strongFrameThreshold: number;

  maximumSabianOptions: number;
}
```

## 13. Ask eclipse questions only when they discriminate

For every eclipse in the user’s life, compare how differently it behaves across the surviving candidates.

Suppose:

```text
Virgo rising:
Eclipse activates the 10th/4th axis

Libra rising:
Eclipse activates the 9th/3rd axis
```

That eclipse is useful because it creates distinct biographical expectations.

Generate:

> Around August and September 2017, which changed most?

```text
Career or public direction
Home or family
Education, travel, or belief
Nothing important comes to mind
```

The options represent the domains actually produced by the candidate Frames.

Do not ask:

> Did something important happen during eclipse season?

Almost everyone can manufacture a yes.

Select eclipses using a discrimination score:

```typescript
export function eclipseDiscriminationScore(
  eclipse: Eclipse,
  normalizedCandidates: Array<
    CandidateChart & { probability: number }
  >
): number {
  const weightedStrengths = normalizedCandidates.map(
    candidate => {
      const activation =
        calculateEclipseActivation(
          eclipse,
          candidate
        );

      return {
        value: activation.totalStrength,
        probability: candidate.probability
      };
    }
  );

  const mean = weightedStrengths.reduce(
    (sum, item) =>
      sum + item.value * item.probability,
    0
  );

  return weightedStrengths.reduce(
    (sum, item) =>
      sum +
      item.probability *
        Math.pow(item.value - mean, 2),
    0
  );
}
```

High variance means the eclipse strongly supports some candidates and barely touches others. Those are the periods worth asking about.

## 14. Separate Frame confidence from degree confidence

Aggregate the normalized candidate distribution.

```typescript
export interface RectificationResult {
  likelyRisingSign: ZodiacSign | null;
  risingSignSupport: number;

  estimatedStartTime: string | null;
  estimatedEndTime: string | null;

  ascendantDegreeStart: number | null;
  ascendantDegreeEnd: number | null;

  degreeSupport: number;

  survivingCandidateCount: number;

  evidenceUsed: {
    temporal: number;
    structural: number;
    biographical: number;
    chronological: number;
    eclipse: number;
    symbolic: number;
  };
}
```

A session can truthfully report:

```text
Scorpio rising support: 89%
Likely Ascendant range: 8°–15°
Degree support: 51%
```

Orbo should not call that an 89%-accurate birth time. It means Scorpio contains 89% of the surviving model weight.

## 15. Sabian symbols are the final low-weight layer

Sabian symbols use ordinal degrees:

```text
0°00′–0°59′ Aries = Aries 1
1°00′–1°59′ Aries = Aries 2
...
29°00′–29°59′ Pisces = Pisces 30
```

Code it as:

```typescript
export function sabianIndex(
  longitude: number
): number {
  const normalized =
    ((longitude % 360) + 360) % 360;

  return Math.floor(normalized) + 1;
}
```

The index is `1–360`.

```typescript
export interface SabianSymbol {
  index: number;
  sign: ZodiacSign;
  ordinalDegree: number;
  title: string;
  paraphrase: string;
}
```

Only trigger Sabian refinement when:

```text
The rising sign is already strongly supported
The remaining candidates span four or fewer Sabian degrees
Stronger chronological evidence has already been used
```

```typescript
export function distinctSabianDegrees(
  candidates: Array<
    CandidateChart & { probability: number }
  >,
  minimumProbability = 0.001
): number[] {
  return [
    ...new Set(
      candidates
        .filter(
          candidate =>
            candidate.probability >=
            minimumProbability
        )
        .map(candidate =>
          sabianIndex(
            candidate.ascendant.longitude
          )
        )
    )
  ].sort((a, b) => a - b);
}
```

The Sabian answer should have very low influence:

```typescript
const SABIAN_MATCH = 0.54;
const SABIAN_MISMATCH = 0.46;
```

It is a tie-breaker, not a bulldozer.

## 16. Build the question engine as a state machine

```typescript
export type RectificationStage =
  | "INITIALIZE"
  | "TIME_WINDOW"
  | "MOON_BRANCH"
  | "FRAME_SEARCH"
  | "BIOGRAPHY"
  | "ECLIPSE_SEARCH"
  | "DEGREE_SEARCH"
  | "SABIAN_REFINEMENT"
  | "COMPLETE";
```

```typescript
export interface RectificationSession {
  id: string;
  input: RectificationInput;

  candidates: CandidateChart[];

  answers: Array<{
    questionId: string;
    optionId: string;
  }>;

  events: LifeEvent[];

  askedQuestionIds: string[];

  stage: RectificationStage;
}
```

Then:

```typescript
export function determineStage(
  session: RectificationSession
): RectificationStage {
  const normalized =
    normalizeCandidates(session.candidates);

  const moonGroups =
    aggregateByMoonSign(normalized);

  const risingGroups =
    aggregateByRisingSign(normalized);

  const topRising =
    [...risingGroups.entries()]
      .sort((a, b) => b[1] - a[1])[0];

  const risingSupport =
    topRising?.[1] ?? 0;

  if (!hasAskedDaypart(session)) {
    return "TIME_WINDOW";
  }

  if (
    moonGroups.size > 1 &&
    !hasResolvedMoonBranch(session)
  ) {
    return "MOON_BRANCH";
  }

  if (risingSupport < 0.75) {
    return "FRAME_SEARCH";
  }

  if (session.events.length < 3) {
    return "BIOGRAPHY";
  }

  if (risingSupport < 0.9) {
    return "ECLIPSE_SEARCH";
  }

  const symbols =
    distinctSabianDegrees(normalized);

  if (symbols.length > 4) {
    return "DEGREE_SEARCH";
  }

  if (
    symbols.length >= 2 &&
    !hasUsedSabianQuestion(session)
  ) {
    return "SABIAN_REFINEMENT";
  }

  return "COMPLETE";
}
```

And route the next question:

```typescript
export function nextQuestion(
  session: RectificationSession
): InternalQuestion | null {
  const stage = determineStage(session);

  switch (stage) {
    case "TIME_WINDOW":
      return makeTimeWindowQuestion(session);

    case "MOON_BRANCH":
      return makeMoonComparisonQuestion(session);

    case "FRAME_SEARCH":
      return makeBestFrameQuestion(session);

    case "BIOGRAPHY":
      return makeBiographyQuestion(session);

    case "ECLIPSE_SEARCH":
      return makeBestEclipseQuestion(session);

    case "DEGREE_SEARCH":
      return makeTimingQuestion(session);

    case "SABIAN_REFINEMENT":
      return makeSabianQuestion(session);

    case "COMPLETE":
      return null;

    default:
      return null;
  }
}
```

## 17. Eventually choose questions by information gain

The first version can use the stage order above. Once that works, Orbo should rank available questions according to how much they are expected to reduce uncertainty.

Entropy:

```typescript
export function entropy(
  probabilities: number[]
): number {
  return probabilities.reduce((sum, probability) => {
    if (probability <= 0) {
      return sum;
    }

    return (
      sum -
      probability *
        Math.log2(probability)
    );
  }, 0);
}
```

Conceptually:

```text
Question value =
current uncertainty
− expected uncertainty after answer
```

Then adjust it:

```text
Final question priority =
information gain
× evidence reliability
× user answerability
× novelty
```

A theoretically perfect question is useless if a normal person cannot answer it.

## 18. Do not let generative AI decide the result

The actual scoring should be deterministic.

A language model may help turn:

```json
{
  "ascendant": "Virgo",
  "ruler": "Mercury",
  "rulerHouse": 8,
  "modifiers": ["retrograde", "square Saturn"]
}
```

into natural wording.

But the language model should not:

- Assign candidate scores
- Decide which birth time is correct
- Invent traits
- Invent eclipse correlations
- Override the ephemeris
- Change evidence weights
- Quietly reinterpret an answer

For reproducibility, Orbo should be able to rerun the same session and produce the same candidate distribution.

## 19. The MVP should be built in this order

```text
1. Candidate generation for every birth minute
2. Whole-sign Frame derivation
3. Moon-ingress detection
4. Hard and soft answer scoring
5. Rising-sign aggregation
6. Fixed time-of-day questions
7. Binary Frame comparison generator
8. Structured life-event input
9. Eclipse activation comparison
10. Degree-range reporting
11. Sabian refinement
12. Information-gain question selection
```

The central object is not a completed chart. It is this:

```typescript
interface RectificationField {
  candidates: CandidateChart[];
  normalizedWeights: number[];
  survivingMoonBranches: ZodiacSign[];
  survivingFrames: ZodiacSign[];
  likelyTimeRanges: TimeRange[];
  evidenceLedger: AppliedEvidence[];
}
```

That is the true rectification state. Every answer reshapes the field until one Frame, and eventually one narrow section of the Ascendant, carries most of the surviving weight. The questionnaire is simply the instrument Orbo uses to touch that field.
