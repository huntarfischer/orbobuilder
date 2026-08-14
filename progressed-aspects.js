// progressed-aspects.js — mutual aspects formed by secondary-progressed bodies (Alan Leo, "The
// Progressed Horoscope", Ch. XIII-XVI: Solar Aspects, Mutual Aspects, Lunar Positions and Aspects).
//
// PURE. No ephemeris import, ever — same law as progressions.js. Every sky-touching value arrives
// pre-computed via a `sample(ageYears)` function the caller injects (the DC wires this to
// spine.progressedAt, exactly as progressions.js's own build() does). This file never imports
// transits.js either, on purpose: transits.js is a STANDALONE engine allowed to touch raw ephemeris
// directly, and importing from it would drag that tier's boundary into this one transitively even
// though its exports look pure. So the root-finder here is written fresh, small, and self-contained
// — same choice progressions.js/prism.js each made for their own numerics rather than sharing a
// cross-tier utility.
//
// THE RELATION IS MUTUAL, NOT DIRECTIONAL. Leo's chapters each foreground one body as "the moving
// side" (the Sun in Ch. XIII, Mercury/Venus/Mars in Ch. XIV, the Moon in Ch. XV) against the radical
// (natal) chart, and separately allows progressed-to-progressed contacts (solar-aspects engine_rules:
// "progressed_to_progressed_allowed", framed as belonging to the Progressed Horoscope rather than the
// Nativity). But the GEOMETRY of "is A square B" does not care which body a chapter's prose is
// written from — a progressed Mars square natal Sun and a progressed Sun square natal... those are
// different events (Mars and Sun progress at different rates), but "progressed Mars square natal
// Sun" and "natal Sun square progressed Mars" are the SAME event. So this engine scans:
//   - every (progressed A, natal B) ordered pair, INCLUDING A===B (Leo's "a planet in aspect with
//     its own place"), because progressed-A-vs-natal-B and progressed-B-vs-natal-A move at different
//     rates and are genuinely different events;
//   - every (progressed A, progressed B) pair with A<B once (undirected — both sides move together
//     at the same age, so there is only one event, not two).
// No body is privileged as "the only mover": every body the caller's sample() and natal.pos both
// carry is scanned. Which combinations have Leo prose is a PACK-COVERAGE question, resolved at read
// time by the reader trying both name orderings — never an engine-level restriction.
//
// TABLE, NOT RECOMPUTE. build() runs ONE scan across ageYears 0..spanYears and returns a frozen,
// real-jd-stamped hit list — same one-shot-scan discipline as progressions.js's own build() and
// zr.js's chapter walk.

import { TROPICAL_YEAR_DAYS, realJdFromAge } from './progressions.js';

// The ten aspects Leo actually uses (his own engine_rules.aspect_angles_degrees, every chapter
// agrees) — the Ring's eleven marks minus the biquintile (144°), which none of his chapters use,
// and minus parallel (declination, not a Ring mark at all — deferred, tracked separately).
export const ASPECTS = Object.freeze([
  { name: 'conjunction', angle: 0 }, { name: 'semi-sextile', angle: 30 }, { name: 'semi-square', angle: 45 },
  { name: 'sextile', angle: 60 }, { name: 'quintile', angle: 72 }, { name: 'square', angle: 90 },
  { name: 'trine', angle: 120 }, { name: 'sesquiquadrate', angle: 135 }, { name: 'quincunx', angle: 150 },
  { name: 'opposition', angle: 180 },
]);

// Approximate mean progressed rate (degrees per progressed-YEAR == real daily ephemeris motion,
// secondary-progression's own one-day-for-a-year law) — used ONLY to pick a safe scan step so a
// fast pair's crossing is never straddled unseen. The bisection that follows is exact regardless;
// this table only bounds how coarse the coarse pass may be.
const MEAN_RATE = Object.freeze({ Sun: 0.9856, Moon: 13.176, Mercury: 1.383, Venus: 1.2, Mars: 0.524,
  Jupiter: 0.083, Saturn: 0.034, Uranus: 0.012, Neptune: 0.006, Pluto: 0.004 });
export const DEFAULT_BODIES = Object.freeze(['Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune']);

function wrap180(x) { x %= 360; if (x > 180) x -= 360; if (x < -180) x += 360; return x; }
function sepAngle(a, b) { return Math.abs(wrap180(a - b)); }
// Conjunction/opposition sit at the extremes of unsigned separation and only TOUCH those values
// without sign-crossing them, so they need the signed form; every other mark genuinely crosses
// zero at the exact hit and the unsigned form correctly yields both occurrences per cycle.
function fOf(angle, a, b) {
  if (angle === 0) return wrap180(a - b);
  if (angle === 180) return wrap180(a - b - 180);
  return sepAngle(a, b) - angle;
}
function clamp(x, lo, hi) { return Math.max(lo, Math.min(hi, x)); }

// ONE shared grid of progressed positions, sampled from the caller's (expensive) sample(age) at a
// SINGLE global step — the expensive call happens once per grid point for the WHOLE build, never
// once per body pair. Every pair then reads cheap linear interpolation off this one grid, including
// during bisection refinement, which is the fix: the earlier shape called sample(age) again inside
// each pair's own coarse loop AND inside every bisection step, multiplying an expensive ephemeris
// decode by (pairs x steps x bisection iterations) instead of by (grid points) alone.
function buildGrid(bodies, sample, spanYears, step) {
  const grid = [];
  for (let age = 0; age <= spanYears + 1e-9; age += step) {
    const s = sample(age);
    const pos = {};
    for (const b of bodies) pos[b] = (s && s[b] != null) ? s[b] : null;
    grid.push({ age, pos });
  }
  return grid;
}
// Longitude at an arbitrary age via linear interpolation between the two bracketing grid points
// (bodies move smoothly at this resolution, so this is cheap arithmetic standing in for a second
// ephemeris sample). Wraps across the 0/360 seam correctly (interpolates the shortest delta).
function interpFn(grid, body) {
  return (age) => {
    const n = grid.length;
    if (age <= grid[0].age) return grid[0].pos[body];
    if (age >= grid[n - 1].age) return grid[n - 1].pos[body];
    let lo = 0, hi = n - 1;
    while (hi - lo > 1) { const mid = (lo + hi) >> 1; if (grid[mid].age <= age) lo = mid; else hi = mid; }
    const v0 = grid[lo].pos[body], v1 = grid[hi].pos[body];
    if (v0 == null || v1 == null) return null;
    const t = (age - grid[lo].age) / (grid[hi].age - grid[lo].age);
    return ((v0 + wrap180(v1 - v0) * t) % 360 + 360) % 360;
  };
}

// Scans one pair's separation across [0, spanYears] and bisects every sign-change of fOf() into an
// exact age. lonA/lonB: age => longitude degrees, or null if that age has no value (an absence, not
// a zero). aspects: the ASPECTS subset to test.
function scanPair(lonA, lonB, spanYears, step, aspects, out, bodyA, bodyB, kind) {
  const prev = new Map();
  for (let age = 0; age <= spanYears + 1e-9; age += step) {
    const la = lonA(age), lb = lonB(age);
    if (la == null || lb == null) continue;
    for (const asp of aspects) {
      const f = fOf(asp.angle, la, lb);
      const p = prev.get(asp.angle);
      if (p !== undefined && ((p < 0 && f >= 0) || (p > 0 && f <= 0)) && Math.abs(f - p) < 90) {
        let lo = age - step, hi = age, flo = p;
        for (let i = 0; i < 40; i++) {
          const mid = (lo + hi) / 2;
          const fm = fOf(asp.angle, lonA(mid), lonB(mid));
          if ((flo < 0) === (fm < 0)) { lo = mid; flo = fm; } else { hi = mid; }
        }
        out.push({ age: (lo + hi) / 2, bodyA, bodyB, angle: asp.angle, name: asp.name, kind });
      }
      prev.set(asp.angle, f);
    }
  }
}

// natal: { jd, pos: { Sun, Moon, ... } } — the natal genome's longitudes, any body set.
// sample(age): caller-injected, returns { Sun, Moon, ... } at the progressed jd for that age —
// i.e. spine.progressedAt(natalJd, realJdFromAge(natalJd, age), lat, lon) reshaped, exactly like
// progressions.js's own build(). Never called by this file directly against ephemeris.
export function build(natal, sample, opts = {}) {
  const spanYears = opts.spanYears || 110;
  const aspects = opts.aspects || ASPECTS;
  const bodies = (opts.bodies || DEFAULT_BODIES).filter((b) => natal.pos[b] != null);
  const hits = [];
  // ONE shared step, fine enough for the fastest pair in the set — computed once, used for both
  // the grid and every pair's scan, never per-pair (the fix: see buildGrid's own note).
  let step = 0.5;
  for (const a of bodies) for (const b of bodies) step = Math.min(step, clamp(3 / ((MEAN_RATE[a] || 1) + (MEAN_RATE[b] || 1)), 0.02, 0.5));
  const grid = buildGrid(bodies, sample, spanYears, step);
  const prog = {}; for (const b of bodies) prog[b] = interpFn(grid, b);
  // progressed A vs natal B — every ordered pair including A===B ("its own place").
  for (const a of bodies) {
    for (const b of bodies) {
      scanPair(prog[a], () => natal.pos[b], spanYears, step, aspects, hits, a, b, 'prog-natal');
    }
  }
  // progressed A vs progressed B — undirected, A<B once (both sides move at the same age).
  for (let i = 0; i < bodies.length; i++) {
    for (let j = i + 1; j < bodies.length; j++) {
      scanPair(prog[bodies[i]], prog[bodies[j]], spanYears, step, aspects, hits, bodies[i], bodies[j], 'prog-prog');
    }
  }
  hits.sort((x, y) => x.age - y.age);
  const stamped = hits.map((h) => Object.freeze(Object.assign({}, h, { jd: realJdFromAge(natal.jd, h.age) })));
  return Object.freeze({ natalJd: natal.jd, spanYears, bodies: Object.freeze(bodies.slice()), hits: Object.freeze(stamped) });
}

// Hits within [jd-windowDays, jd+windowDays] of a cursor — the almanac-stream law applied here too:
// flatten the table, never recompute. Sorted nearest-exact-first so a reader can take the top N.
export function hitsNear(table, jd, windowDays) {
  if (!table) return [];
  return table.hits.filter((h) => Math.abs(h.jd - jd) <= windowDays)
    .slice().sort((x, y) => Math.abs(x.jd - jd) - Math.abs(y.jd - jd));
}

// Memo key — natal jd + the body set actually scanned (doctrine has no bearing on this table: it
// depends only on the natal chart and which bodies were asked for).
export function tableKey(natal, bodies) {
  return natal.jd + '|' + (bodies || DEFAULT_BODIES).slice().sort().join(',');
}
