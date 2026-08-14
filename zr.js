// zr.js — zodiacal releasing engine. Decodes lot start-longitudes from an AstroDNA snapshot
// (astrodna.js) rather than talking to raw ephemeris directly, so a lot's position and its
// AstroDNA node are always the same number read two ways.
//
// SCOPE (per the July 12 conversation): eight lots at parity — Fortune, Spirit, Eros,
// Necessity, Courage, Victory, Nemesis, and Death. Formulas below are the Pauline/Hermetic
// family (day formula given; night is the operands reversed) — same convention the design
// doc's pseudocode uses:
//   Fortune   = day: Asc+Moon-Sun        | night: Asc+Sun-Moon
//   Spirit    = day: Asc+Sun-Moon        | night: Asc+Moon-Sun         (Fortune's mirror)
//   Eros      = day: Asc+Venus-Spirit    | night: Asc+Spirit-Venus
//   Necessity = day: Asc+Fortune-Mercury | night: Asc+Mercury-Fortune
//   Courage   = day: Asc+Fortune-Mars    | night: Asc+Mars-Fortune
//   Victory   = day: Asc+Jupiter-Spirit  | night: Asc+Spirit-Jupiter
//   Nemesis   = day: Asc+Fortune-Saturn  | night: Asc+Saturn-Fortune
//   Death     = day: Asc+House8-Moon     | night: Asc+Moon-House8
// Death is not in the research doc's seven Hermetic lots — this uses a documented classical
// variant (8th-whole-sign-cusp / Moon, the "prison of the body" place paired with vitality),
// same house-8/Saturn-adjacent family as Nemesis but keyed to the Moon instead of Saturn.
// Flagged explicitly: formula variance across sources is real here (same caution the research
// doc gives for Eros/Necessity) — swap in a different source's formula if you have one in mind.
//
// PEAK, two definitions, both always computed (no reason to choose):
//   peakTrueAngles  — the chart's real whole-sign angles: Ascendant's sign + the 4th/7th/10th
//                      signs from it (Asc+0,+3,+6,+9). Fixed per NATAL CHART, shared by every lot.
//   peakBrennanSelf — Brennan's angular-triad reading: each lot's OWN natal starting sign + its
//                      own +3,+6,+9. Fixed per LOT, independent of the other lots.
//
// TIME BASIS — "zodiacal time," not civil/Roman calendar arithmetic: L1 (years) and L2 (months)
// are measured in the mean tropical year (365.2422 days) and its twelfth, so period math is pure
// day-counts added straight onto jd — exactly like every other engine in this project. Civil
// (Gregorian) dates are derived from jd only for display, never used as the arithmetic itself.
// L3 (days) and L4 (hours) are already unambiguous and need no such scaling.
//
// LOOSING OF THE BOND: only applies to a NESTED level (L2 inside an L1 period, L3 inside L2, L4
// inside L3) — never to the unbounded top level. If a full 12-sign circuit at the nested level
// completes before its containing period ends, the next circuit starts from the sign OPPOSITE
// whichever sign started the circuit just finished (alternating start/opposite each time this
// repeats) — verified against the design doc's own worked example: an L2 (months) circuit
// starting Cancer takes 211 months = 17y7m, matches "17 years" as Brennan's cutoff for when a
// bond can loosen at all, and the doc's worked continuation resumes at Capricorn (opposite
// Cancer) — exactly what buildLevel() below produces.
//
// Data engine only — no UI, no wiring into Orbo Astrolabe.dc.html.

import { norm360, wrap180 } from './ephem.js';
import { SIGNS, lots, LOTS } from './astrodna.js';

// ONE list, not two (2026-08-05): the chronology's lot order IS the decode's lot set.
export const LOT_ORDER = LOTS;

// Valens' sign periods — years at L1; the SAME numbers serve as months (L2), days (L3), hours (L4).
export const PERIOD_UNITS = {
  Aries: 15, Taurus: 8, Gemini: 20, Cancer: 25, Leo: 19, Virgo: 20,
  Libra: 8, Scorpio: 15, Sagittarius: 12, Capricorn: 27, Aquarius: 30, Pisces: 12,
};

const TROPICAL_YEAR_DAYS = 365.2422;
export const LEVEL_UNIT_DAYS = { 1: TROPICAL_YEAR_DAYS, 2: TROPICAL_YEAR_DAYS / 12, 3: 1, 4: 1 / 24 };

function signIdx(lonDeg) { return Math.floor(norm360(lonDeg) / 30); }

// ---------- lot formulas ----------

// Returns { longitudes: {Fortune..Death}, isDay } from an AstroDNA snapshot (astrodna.js's
// buildAstroDNA output). THE LOT ARITHMETIC IS NOT HERE (2026-08-05): it is astrodna.lots,
// expressed off the same decode surface this function reads, so the chronology's lots and the
// plate's lots cannot drift apart. This function's whole job is reading a genome and settling sect.
export function computeLots(dna) {
  const n = dna.nodes;
  const asc = n.Ascendant.longitude;
  const pos = {
    Sun: n.Sun.longitude, Moon: n.Moon.longitude, Mercury: n.Mercury.longitude,
    Venus: n.Venus.longitude, Mars: n.Mars.longitude, Jupiter: n.Jupiter.longitude,
    Saturn: n.Saturn.longitude,
  };
  // Sect: day if the Sun sits in the above-horizon half (houses 7-12 from Asc) — same
  // convention already used elsewhere in this project (norm(Sun-Asc) >= 180 => day).
  const isDay = norm360(pos.Sun - asc) >= 180;
  return { isDay, longitudes: lots(asc, isDay, pos) };
}

// Lots sharing a natal start sign run one identical schedule forever — group them so the
// caller draws/reads one track instead of N duplicates. Returns an array of
// { signIndex, sign, lots: [names] }, one entry per distinct occupied start sign.
export function findBundles(longitudes) {
  const bySign = {};
  for (const [name, lon] of Object.entries(longitudes)) {
    const idx = signIdx(lon);
    (bySign[idx] ||= []).push(name);
  }
  return Object.entries(bySign)
    .map(([idx, lots]) => ({ signIndex: Number(idx), sign: SIGNS[Number(idx)], lots }))
    .sort((a, b) => a.signIndex - b.signIndex);
}

// The four whole-sign angle signs from a given start sign: itself, +3, +6, +9 (1st/4th/7th/10th).
function angularSet(startSignIdx) {
  return [0, 3, 6, 9].map((k) => (startSignIdx + k) % 12);
}

// Fixed per natal chart — every lot is tested against this same set.
export function trueAngleSigns(dna) {
  return angularSet(signIdx(dna.nodes.Ascendant.longitude));
}

// Fixed per lot — each lot's own natal starting sign defines its own angular set.
export function brennanAngleSigns(longitudes) {
  const out = {};
  for (const [name, lon] of Object.entries(longitudes)) out[name] = angularSet(signIdx(lon));
  return out;
}

// ---------- level builder (generic — serves L1 through L4 identically) ----------

// Walks signs in zodiacal order from startSignIdx, each period lasting PERIOD_UNITS[sign]*unitDays,
// starting at jdStart, until reaching untilJd. If applyLB is true, a full 12-sign circuit
// completing before untilJd triggers loosing-of-the-bond: the next circuit starts from the sign
// opposite whichever sign started the circuit just finished (alternates on repeat). Top-level
// (L1, unbounded) should pass applyLB=false and untilJd = a practical horizon, not Infinity.
export function buildLevel(startSignIdx, jdStart, unitDays, untilJd, applyLB) {
  const periods = [];
  let circuitStart = startSignIdx, sign = startSignIdx, jd = jdStart, stepsInCircuit = 0;
  const SAFETY = 5000;
  let guard = 0;
  while (jd < untilJd && guard++ < SAFETY) {
    const name = SIGNS[sign];
    const durationDays = PERIOD_UNITS[name] * unitDays;
    const endJd = jd + durationDays;
    periods.push({ signIndex: sign, sign: name, startJd: jd, endJd, durationDays });
    jd = endJd;
    sign = (sign + 1) % 12;
    stepsInCircuit++;
    if (applyLB && stepsInCircuit === 12) {
      circuitStart = (circuitStart + 6) % 12;
      sign = circuitStart;
      stepsInCircuit = 0;
    }
  }
  return periods;
}

// L1 chapters for one lot/bundle, from its natal start sign out to jdBirth + horizonYears.
export function buildChapters(startSignIdx, jdBirth, horizonYears = 110) {
  return buildLevel(startSignIdx, jdBirth, LEVEL_UNIT_DAYS[1], jdBirth + horizonYears * TROPICAL_YEAR_DAYS, false);
}

// The next level nested inside a given period (level 1->2, 2->3, or 3->4). Matches the
// screenshot's column-browser: click a period, see its children.
export function subPeriods(period, parentLevel) {
  const childLevel = parentLevel + 1;
  if (!LEVEL_UNIT_DAYS[childLevel]) return [];
  return buildLevel(period.signIndex, period.startJd, LEVEL_UNIT_DAYS[childLevel], period.endJd, true);
}

// Attaches peak flags to a period in place-friendly fashion (returns a new object).
export function withPeaks(period, trueSet, brennanSet) {
  return { ...period, peakTrueAngles: trueSet.includes(period.signIndex), peakBrennanSelf: brennanSet.includes(period.signIndex) };
}

// ---------- schedule-at-level (descends L1->target, only expanding containers that overlap range) ----------

// Returns the periods AT `level` (1-4) for one lot/bundle that overlap [jdFrom, jdTo].
export function scheduleAtLevel(startSignIdx, jdBirth, level, jdFrom, jdTo) {
  let containers = [{ signIndex: startSignIdx, startJd: jdBirth, endJd: Infinity }];
  for (let lvl = 1; lvl <= level; lvl++) {
    const unitDays = LEVEL_UNIT_DAYS[lvl];
    const applyLB = lvl > 1;
    const next = [];
    for (const c of containers) {
      if (c.endJd < jdFrom || c.startJd > jdTo) continue;
      const untilJd = lvl === 1 ? jdTo + unitDays : c.endJd;
      const periods = buildLevel(c.signIndex, c.startJd, unitDays, untilJd, applyLB);
      for (const p of periods) if (p.endJd >= jdFrom && p.startJd <= jdTo) next.push(p);
    }
    containers = next;
  }
  return containers;
}

function findCurrent(periods, jd) {
  // periods sorted ascending by startJd (buildLevel/scheduleAtLevel guarantee this)
  let lo = 0, hi = periods.length - 1, ans = null;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (periods[mid].startJd <= jd) { ans = periods[mid]; lo = mid + 1; } else hi = mid - 1;
  }
  return ans && jd < ans.endJd ? ans : null;
}

function isoDate(jd) {
  // Gregorian calendar date from a UT julian day, for display labels only — never used as
  // the arithmetic itself (the "zodiacal time, not Roman time" law).
  return new Date((jd - 2440587.5) * 86400000).toISOString().slice(0, 10);
}

// ---------- peak-overlap scan ----------

// Walks day-by-day across [jdFrom, jdTo], testing each lot-bundle's current sign (at `level`,
// default 3 = day-scale periods) against `peakDef` ('trueAngles' | 'brennanSelf'), and returns
// both a raw daily table (mirrors the CSV) and compressed overlap ranges (mirrors the PDF):
// contiguous day-spans where >= minCount bundles are peak simultaneously, with the max count
// reached and example lot combinations in that span.
export function scanPeakOverlaps({ dna, level = 3, jdFrom, jdTo, peakDef = 'trueAngles', minCount = 2 }) {
  const { longitudes } = computeLots(dna);
  const bundles = findBundles(longitudes);
  const trueSet = trueAngleSigns(dna);
  const brennanSets = brennanAngleSigns(longitudes);

  const bundleSchedules = bundles.map((b) => ({
    ...b,
    // any lot in the bundle shares the same start sign/schedule; angular set for brennanSelf
    // uses that shared start sign (all lots in a bundle produce the identical set anyway).
    angularSet: peakDef === 'trueAngles' ? trueSet : brennanSets[b.lots[0]],
    schedule: scheduleAtLevel(b.signIndex, dna.jd, level, jdFrom, jdTo),
  }));

  const daily = [];
  for (let jd = Math.floor(jdFrom); jd <= jdTo; jd += 1) {
    const row = { jd, date: isoDate(jd), perBundle: [], peakCount: 0, lotsInPeak: [] };
    for (const b of bundleSchedules) {
      const cur = findCurrent(b.schedule, jd);
      const isPeak = !!cur && b.angularSet.includes(cur.signIndex);
      row.perBundle.push({ lots: b.lots, sign: cur ? cur.sign : null, isPeak });
      if (isPeak) { row.peakCount++; row.lotsInPeak.push(b.lots.join(' / ')); }
    }
    daily.push(row);
  }

  // compress into contiguous ranges where peakCount >= minCount
  const ranges = [];
  let cur = null;
  for (const row of daily) {
    const qualifies = row.peakCount >= minCount;
    if (qualifies) {
      if (!cur) cur = { startDate: row.date, endDate: row.date, days: 1, maxCount: row.peakCount, examples: [row.lotsInPeak.join(' | ')] };
      else {
        cur.endDate = row.date; cur.days++;
        if (row.peakCount > cur.maxCount) cur.maxCount = row.peakCount;
        const ex = row.lotsInPeak.join(' | ');
        if (!cur.examples.includes(ex)) cur.examples.push(ex);
      }
    } else if (cur) { ranges.push(cur); cur = null; }
  }
  if (cur) ranges.push(cur);

  return { bundles: bundles.map((b) => b.lots), daily, ranges };
}
