// zr.browser.js — auto-generated browser-global build of zr.js (no ES modules; assigns window.__ORBO_ZR).
// Source of truth is zr.js — regenerate this file if zr.js changes, don't hand-edit.
// Load order: after ephem.browser.js and astrodna.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!(window.__ORBO_EPH && window.__ORBO_ASTRODNA)){return void setTimeout(boot,0);}
const { norm360 } = window.__ORBO_EPH;
const SIGNS = window.__ORBO_ASTRODNA.SIGNS;
const lots = window.__ORBO_ASTRODNA.lots;

const LOT_ORDER = window.__ORBO_ASTRODNA.LOTS;

// Valens' sign periods — years at L1; the SAME numbers serve as months (L2), days (L3), hours (L4).
const PERIOD_UNITS = {
  Aries: 15, Taurus: 8, Gemini: 20, Cancer: 25, Leo: 19, Virgo: 20,
  Libra: 8, Scorpio: 15, Sagittarius: 12, Capricorn: 27, Aquarius: 30, Pisces: 12,
};

const TROPICAL_YEAR_DAYS = 365.2422;
const LEVEL_UNIT_DAYS = { 1: TROPICAL_YEAR_DAYS, 2: TROPICAL_YEAR_DAYS / 12, 3: 1, 4: 1 / 24 };

function signIdx(lonDeg) { return Math.floor(norm360(lonDeg) / 30); }

function computeLots(dna) {
  const n = dna.nodes;
  const asc = n.Ascendant.longitude;
  const pos = {
    Sun: n.Sun.longitude, Moon: n.Moon.longitude, Mercury: n.Mercury.longitude,
    Venus: n.Venus.longitude, Mars: n.Mars.longitude, Jupiter: n.Jupiter.longitude,
    Saturn: n.Saturn.longitude,
  };
  const isDay = norm360(pos.Sun - asc) >= 180;
  return { isDay, longitudes: lots(asc, isDay, pos) };
}

function findBundles(longitudes) {
  const bySign = {};
  for (const [name, lon] of Object.entries(longitudes)) {
    const idx = signIdx(lon);
    (bySign[idx] ||= []).push(name);
  }
  return Object.entries(bySign)
    .map(([idx, lots]) => ({ signIndex: Number(idx), sign: SIGNS[Number(idx)], lots }))
    .sort((a, b) => a.signIndex - b.signIndex);
}

function angularSet(startSignIdx) {
  return [0, 3, 6, 9].map((k) => (startSignIdx + k) % 12);
}

function trueAngleSigns(dna) {
  return angularSet(signIdx(dna.nodes.Ascendant.longitude));
}

function brennanAngleSigns(longitudes) {
  const out = {};
  for (const [name, lon] of Object.entries(longitudes)) out[name] = angularSet(signIdx(lon));
  return out;
}

function buildLevel(startSignIdx, jdStart, unitDays, untilJd, applyLB) {
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

function buildChapters(startSignIdx, jdBirth, horizonYears = 110) {
  return buildLevel(startSignIdx, jdBirth, LEVEL_UNIT_DAYS[1], jdBirth + horizonYears * TROPICAL_YEAR_DAYS, false);
}

function subPeriods(period, parentLevel) {
  const childLevel = parentLevel + 1;
  if (!LEVEL_UNIT_DAYS[childLevel]) return [];
  return buildLevel(period.signIndex, period.startJd, LEVEL_UNIT_DAYS[childLevel], period.endJd, true);
}

function withPeaks(period, trueSet, brennanSet) {
  return { ...period, peakTrueAngles: trueSet.includes(period.signIndex), peakBrennanSelf: brennanSet.includes(period.signIndex) };
}

function scheduleAtLevel(startSignIdx, jdBirth, level, jdFrom, jdTo) {
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
  let lo = 0, hi = periods.length - 1, ans = null;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (periods[mid].startJd <= jd) { ans = periods[mid]; lo = mid + 1; } else hi = mid - 1;
  }
  return ans && jd < ans.endJd ? ans : null;
}

function isoDate(jd) {
  return new Date((jd - 2440587.5) * 86400000).toISOString().slice(0, 10);
}

function scanPeakOverlaps({ dna, level = 3, jdFrom, jdTo, peakDef = 'trueAngles', minCount = 2 }) {
  const { longitudes } = computeLots(dna);
  const bundles = findBundles(longitudes);
  const trueSet = trueAngleSigns(dna);
  const brennanSets = brennanAngleSigns(longitudes);

  const bundleSchedules = bundles.map((b) => ({
    ...b,
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

window.__ORBO_ZR = {
  LOT_ORDER, PERIOD_UNITS, LEVEL_UNIT_DAYS,
  computeLots, findBundles, trueAngleSigns, brennanAngleSigns,
  buildLevel, buildChapters, subPeriods, withPeaks, scheduleAtLevel, scanPeakOverlaps,
};
})();
