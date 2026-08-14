// transits.browser.js — auto-generated browser-global build of transits.js (no ES modules; assigns window.__ORBO_TRANSITS).
// Source of truth is transits.js — regenerate this file if transits.js changes, don't hand-edit.
// Load order: after ephem.browser.js and framing.browser.js.
(function boot(){
// transits.js — transit ephemeris engine: finds exact aspect-partile crossings between
// moving (transiting) bodies and a target chart's points.
//
// Chart-agnostic by construction: `target` is just a function jd -> {bodyName: lonDeg}
// (a plain object is accepted too, and treated as constant across jd). This means the
// same scanner serves:
//   - a natal chart          → natalTarget(natal)             (constant; natal doesn't move)
//   - the live You×moment    → compositeTarget(natal)         (midpoint(natal, positions(jd)) per jd,
//                                                                same law as framing.js's "live composite")
//   - a fixed A+B composite  → compositeABTarget(natalA,natalB) (constant; midpoint of two natals)
// Any of these — or a hand-built target fn — plugs into scanTransitHits() identically.
//
// Method mirrors ephem.js's findAscAnchor: sample a signed function for sign changes,
// then bisect to the exact instant. Aspect definitions/glyphs are imported from framing.js
// so this never drifts from the rest of the app's aspect language.
//
// Numerically verified 2026-07-10 against a sample natal (1990-06-15 14:30 -5, 43.34N 90.38W):
// transiting Sun conjunct natal Sun (the solar return) lands at +365.242 days, on 1991-06-16 —
// exactly the expected date; transiting Moon conjunct natal Sun recurs every 27.2-27.4 days
// (the sidereal month) across a 120-day window; a live composite's rate of motion measured
// 0.502°/day against a ~1.004°/day transiting Sun — the required half-gear ratio. A conjunction/
// opposition sign-flip bug (unsigned separation only touches those extremes, never crosses them)
// was caught by this same test and fixed — see fOf() below.

if(!(window.__ORBO_EPH && window.__ORBO_FRAMING)){return void setTimeout(boot,0);}
const { positions, wrap180 } = window.__ORBO_EPH;
const { ASPECTS, midpoint } = window.__ORBO_FRAMING;

// Generous ceiling on each body's instantaneous |daily motion| (deg/day), used only to pick
// a safe sampling step (finer for faster bodies) — not an accuracy claim about the body itself.
const MAX_DAILY = {
  Sun: 1.1, Moon: 15.5, Mercury: 2.3, Venus: 1.35, Mars: 0.8,
  Jupiter: 0.25, Saturn: 0.14, Uranus: 0.07, Neptune: 0.045, Pluto: 0.045,
  Node: 0.22, SNode: 0.22, Chiron: 0.13, Lilith: 0.5,
  Ceres: 0.9, Pallas: 1.1, Juno: 1.0, Vesta: 1.0,
  ASC: 370, MC: 370, DSC: 370, Vertex: 370, cASC: 2.2, cMC: 2.2,
};
const DEFAULT_MAX_DAILY = 1.5;

// The standard transiting-body set: BODY_ORDER minus SNode (an aspect to SNode always mirrors
// one to Node 180° away — counting both double-credits the same contact; framing.js skips it
// for the same reason).
const DEFAULT_TRANSIT_BODIES = ['Sun','Moon','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto','Node','Chiron','Lilith'];

function sepAngle(a, b) { return Math.abs(wrap180(a - b)); } // unsigned separation, 0..180
function clamp(x, lo, hi) { return Math.max(lo, Math.min(hi, x)); }

// ---------- target-chart builders (chart-agnostic front door) ----------

// A natal chart is a constant target: it doesn't move. Includes ASC/MC alongside the ten
// planet-class bodies already on natal.pos so transits-to-angles work through the same path.
function natalTarget(natal) {
  const snap = { ...natal.pos, ASC: natal.asc, MC: natal.mc };
  return () => snap;
}

// The live You×moment composite (per the design map's "live by default" law): midpoint of the
// natal degree and the transiting position of the same body, recomputed at whatever jd is asked —
// no anchoring/frame step needed for this use. transitPosFn defaults to ephem's positions().
function compositeTarget(natal, transitPosFn = positions) {
  return (jd) => {
    const moment = transitPosFn(jd);
    const out = {};
    for (const b in natal.pos) if (moment[b] != null) out[b] = midpoint(natal.pos[b], moment[b]);
    return out;
  };
}

// A fixed A+B (two-person) composite: the classical midpoint chart, constant like a natal.
function compositeABTarget(natalA, natalB) {
  const out = {};
  for (const b in natalA.pos) if (natalB.pos[b] != null) out[b] = midpoint(natalA.pos[b], natalB.pos[b]);
  out.ASC = midpoint(natalA.asc, natalB.asc);
  out.MC = midpoint(natalA.mc, natalB.mc);
  const snap = out;
  return () => snap;
}

// ---------- the scanner ----------

/**
 * Find every exact (partile) transit aspect between a moving body set and a target chart
 * over [jdStart, jdEnd]. Returns hits sorted by jd, each:
 *   { jd, transitBody, targetBody, angle, name, glyph }
 *
 * opts:
 *   target         required. jd => {bodyName: lonDeg}, or a plain (constant) {bodyName: lonDeg}.
 *   jdStart, jdEnd required. UT Julian day range to scan.
 *   targetBodies   which points in the target chart to test against (default: all its keys).
 *   transitPos     jd => {bodyName: lonDeg} for the moving side (default: ephem's positions()).
 *   transitBodies  which moving bodies to scan (default: DEFAULT_TRANSIT_BODIES).
 *   aspects        subset of ASPECTS to test (default: all five majors).
 *   stepDays       override the sampling grid; default auto-picks from the fastest transitBody
 *                  requested (fine enough that a sign change is never straddled unseen).
 */
function scanTransitHits(opts) {
  const {
    target, jdStart, jdEnd,
    targetBodies = null,
    transitPos = positions,
    transitBodies = DEFAULT_TRANSIT_BODIES,
    aspects = ASPECTS,
    stepDays = null,
  } = opts;
  if (!(jdEnd > jdStart)) return [];
  const targetFn = typeof target === 'function' ? target : () => target;
  const tBodies = targetBodies || Object.keys(targetFn(jdStart));
  const maxSpeed = transitBodies.reduce((m, b) => Math.max(m, MAX_DAILY[b] ?? DEFAULT_MAX_DAILY), 0.01);
  const step = stepDays || clamp(4 / maxSpeed, 0.01, 2);

  // f(jd) for a given (transitBody,targetBody,aspect) trio. Conjunction (0°) and opposition
  // (180°) sit at the extremes of unsigned separation (0..180) — separation only TOUCHES those
  // values and turns around, it never sign-crosses them, so an unsigned "sep - angle" test would
  // silently miss every conjunction/opposition. Those two use the signed relative longitude
  // instead (wrap180(diff) / wrap180(diff-180)), which genuinely crosses zero at the exact hit.
  // 60/90/120 keep the unsigned form: it correctly yields BOTH real occurrences per cycle
  // (e.g. a waxing AND a waning square) as two proper sign changes of one smooth peak-shaped curve.
  const fOf = (angle, tl, gl) => {
    if (angle === 0) return wrap180(tl - gl);
    if (angle === 180) return wrap180(tl - gl - 180);
    return sepAngle(tl, gl) - angle;
  };
  const bisect = (lo, hi, fLo, angle, trB, taB) => {
    let a = lo, b = hi, fa = fLo;
    for (let i = 0; i < 40; i++) {
      const mid = (a + b) / 2;
      const fm = fOf(angle, transitPos(mid)[trB], targetFn(mid)[taB]);
      if ((fa < 0) === (fm < 0)) { a = mid; fa = fm; } else { b = mid; }
    }
    return (a + b) / 2;
  };

  const prev = new Map(); // key "trB|taB|angle" -> previous f value
  const hits = [];
  for (let jd = jdStart; jd <= jdEnd + 1e-9; jd += step) {
    const tp = transitPos(jd);
    const gp = targetFn(jd);
    for (const trB of transitBodies) {
      const tl = tp[trB];
      if (tl == null) continue;
      for (const taB of tBodies) {
        const gl = gp[taB];
        if (gl == null) continue;
        for (const asp of aspects) {
          const key = trB + '|' + taB + '|' + asp.angle;
          const f = fOf(asp.angle, tl, gl);
          const p = prev.get(key);
          if (p !== undefined && ((p < 0 && f >= 0) || (p > 0 && f <= 0)) && Math.abs(f - p) < 90) {
            const jdHit = bisect(jd - step, jd, p, asp.angle, trB, taB);
            hits.push({ jd: jdHit, transitBody: trB, targetBody: taB, angle: asp.angle, name: asp.name, glyph: asp.glyph });
          }
          prev.set(key, f);
        }
      }
    }
  }
  hits.sort((a, b) => a.jd - b.jd);
  return hits;
}

/**
 * Convenience: the next `count` exact hits at or after jdFrom, expanding the search window
 * geometrically until enough are found (or maxWindowDays is hit). Same opts as scanTransitHits
 * minus jdStart/jdEnd, which are supplied by the loop.
 */
function nextExactHits(opts, jdFrom, count = 10, maxWindowDays = 730) {
  let windowDays = 30, hits = [];
  while (windowDays <= maxWindowDays) {
    hits = scanTransitHits({ ...opts, jdStart: jdFrom, jdEnd: jdFrom + windowDays });
    if (hits.length >= count) break;
    windowDays *= 2;
  }
  return hits.slice(0, count);
}

window.__ORBO_TRANSITS = { DEFAULT_TRANSIT_BODIES, natalTarget, compositeTarget, compositeABTarget, scanTransitHits, nextExactHits, ASPECTS };
})();
