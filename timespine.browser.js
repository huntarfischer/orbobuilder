// timespine.browser.js — auto-generated browser-global build of timespine.js (no ES modules; assigns window.__ORBO_TIMESPINE).
// Source of truth is timespine.js — regenerate this file if timespine.js changes, don't hand-edit.
// Load order: after ephem.browser.js and transits.browser.js.
(function boot(){
// Bundle-safety: inlined blob scripts don't preserve <script> order, so wait for deps
// (see CLAUDE.md — browser-build-only guard, no analog in the ES-module source).
if(!window.__ORBO_EPH || !window.__ORBO_EPH.bodyLon || !window.__ORBO_TRANSITS){return void setTimeout(boot,0);}
const { positions, bodyLon, norm360, wrap180 } = window.__ORBO_EPH;
const { scanTransitHits, natalTarget, DEFAULT_TRANSIT_BODIES } = window.__ORBO_TRANSITS;

// timespine.js — the unspool engine. The genome is the code; the timespine is its one-time
// expression: every ephemeris-expensive event of the nativity's ~century, scanned once and
// materialized as a flat, sorted event table for the rest of Orbo to query instead of rescan.
//
// DOCTRINE — what the spine holds, and what it refuses:
//   MATERIALIZED (expensive: ephemeris scans)
//     hit      transit exact hit to a natal target        { jd, kind, t, g, a }
//     chit     transit exact hit to the SYNCHRONIC-COMPOSITE target (beads at half speed;
//              a chit with t===g && a===180 on the natal side IS the bead's flip)
//     ingress  a body entering a sign                      { jd, kind, t, sign, rx }
//     station  a body turning Rx or direct                 { jd, kind, t, dir }
//   DERIVED AT READ (cheap arithmetic — never stored)
//     returns    tagged views of hits (isReturn: Sun→natal Sun conjunction, etc.)
//     flips      tagged views of hits (isFlip — see above)
//     profections, ZR periods — pure period arithmetic off the genome (zr.js)
//     composite-frame series — analytic per day (ephem.findAscAnchor), only its handoffs matter
//   REFUSED (fast hands flood the table — computed live, same law that keeps the Moon
//   out of the significant-transits view): Moon events, cASC rulership handoffs (~6/day).
//
// The unspooler is INCREMENTAL by design: step() scans one chunk and returns its events, so
// the app can run it on idle time without stuttering the instrument's RAF clock. Chunks
// overlap by a few days and dedupe on the cursor, so no crossing is lost at a seam.
// Identity: a spine is (sequenceString of the genome) × SPINE_VERSION — new seed or new
// engine, new spine. Persistence itself is the app's concern (IndexedDB, step 4b), not this
// engine's: it emits rows, it never touches storage.


const SPINE_VERSION = 2; // v2: natal targets grew IC/DSC/Vertex/Fortune (parity with the app's _natalTargets)
// ex-Moon (fast-hand law). SNode already excluded upstream in DEFAULT_TRANSIT_BODIES.
const SPINE_BODIES = DEFAULT_TRANSIT_BODIES.filter((b) => b !== 'Moon');
// Sun never stations; Node/Lilith are osculating and wiggle direction constantly (noise, not
// stations); the rest turn a few times a year at most.
const STATION_BODIES = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Chiron'];
// The hit-scan sampling step — mirrors scanTransitHits' own default for the ex-Moon body set
// (4 / MAX_DAILY.Mercury). Fixed here so every chunk's grid can be PHASE-LOCKED to the spine
// start: a chunked unspool then samples the exact same jds as a one-shot scan, making the
// materialized expression bit-identical to the live one (conformance law).
const SPINE_STEP = 4 / 2.3;

// Rebuild the natal shape transits.js targets expect ({pos, asc, mc}) from a genome.
function natalFromDna(dna) {
  const pos = {};
  for (const n in dna.nodes) if (n !== 'Ascendant') pos[n] = dna.nodes[n].longitude;
  if (dna.extras && dna.extras.bodies) for (const b in dna.extras.bodies) pos[b] = dna.extras.bodies[b].longitude;
  const A = dna.extras ? dna.extras.angles : {};
  // the full angle family rides as targets too — the live path (_natalTargets) offers them
  // when enabled, so the materialized expression must cover them (they're natal-fixed points).
  if (A.ic != null) pos.IC = A.ic;
  if (A.dsc != null) pos.DSC = A.dsc;
  if (A.vertex != null) pos.Vertex = A.vertex;
  if (A.fortune != null) pos.Fortune = A.fortune;
  return { pos, asc: A.asc ?? null, mc: A.mc ?? null };
}

// The synchronic-composite bead set the spine watches — the app's BODIES minus the Moon
// (her bead runs at ~6.6°/day, fast-hand law: computed live, never materialized).
const COMP_TARGET_BODIES = ['Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto'];

// Lazy per-body charts — THE scan-cost trick. scanTransitHits' bisection asks for ONE body
// per iteration; a full positions() call computes 18 (including the expensive lunar series
// and osculating node every time). These proxies compute exactly what is read, memoized per jd.
function lazyChart(jd) {
  const c = Object.create(null);
  return new Proxy(c, { get: (o, k) => (typeof k === 'string' ? (k in o ? o[k] : (o[k] = bodyLon(jd, k))) : undefined) });
}
function lazyCompositeTarget(natal, bodies) {
  return (jd) => new Proxy(Object.create(null), {
    get: (o, k) => {
      if (typeof k !== 'string' || !bodies.includes(k)) return undefined;
      if (k in o) return o[k];
      const nat = natal.pos[k];
      if (nat == null) return undefined;
      const sky = bodyLon(jd, k);
      if (sky == null) return undefined;
      return (o[k] = norm360(nat + wrap180(sky - nat) / 2)); // short-arc midpoint, same as framing.js
    },
  });
}

function bisectF(lo, hi, f, iters = 30) {
  let a = lo, b = hi, fa = f(lo);
  for (let i = 0; i < iters; i++) {
    const m = (a + b) / 2, fm = f(m);
    if ((fa < 0) === (fm < 0)) { a = m; fa = fm; } else { b = m; }
  }
  return (a + b) / 2;
}

function speedOf(jd, t) { const h = 0.25; return wrap180(bodyLon(jd + h, t) - bodyLon(jd - h, t)) / (2 * h); }

// sign ingresses on [a,b] — 1-day grid is ample ex-Moon (fastest ~2.2°/day vs 30° signs)
function scanIngresses(a, b, bodies) {
  const out = [], step = 1;
  let prev = null;
  for (let jd = a; jd <= b + 1e-9; jd += step) {
    const p = positions(jd);
    if (prev) {
      for (const t of bodies) {
        if (p[t] == null || prev[t] == null) continue;
        const s0 = Math.floor(norm360(prev[t]) / 30), s1 = Math.floor(norm360(p[t]) / 30);
        if (s0 === s1) continue;
        const forward = wrap180(p[t] - prev[t]) > 0;
        const edge = (forward ? s1 : s0) * 30; // the boundary actually crossed
        const jdX = bisectF(jd - step, jd, (x) => wrap180(bodyLon(x, t) - edge));
        out.push({ jd: jdX, kind: 'ingress', t, sign: s1, rx: !forward });
      }
    }
    prev = p;
  }
  return out;
}

// stations on [a,b] — speed sign changes on a 2-day grid (stations are weeks apart)
function scanStations(a, b, bodies) {
  const out = [], step = 2;
  const prev = {};
  for (let jd = a; jd <= b + 1e-9; jd += step) {
    for (const t of bodies) {
      const v = speedOf(jd, t);
      const p = prev[t];
      if (p !== undefined && (p < 0) !== (v < 0)) {
        const jdX = bisectF(jd - step, jd, (x) => speedOf(x, t));
        out.push({ jd: jdX, kind: 'station', t, dir: v < 0 ? 'rx' : 'd' });
      }
      prev[t] = v;
    }
  }
  return out;
}

// ── the unspooler ───────────────────────────────────────────────────────────
function makeUnspooler(dna, opts = {}) {
  const start = opts.start ?? dna.jd;
  const end = opts.end ?? start + (opts.years ?? 100) * 365.25;
  const chunkDays = opts.chunkDays ?? 120;
  const bodies = opts.transitBodies ?? SPINE_BODIES;
  const natal = natalFromDna(dna);
  const targets = [['hit', natalTarget(natal), null]];
  if (opts.composite !== false) targets.push(['chit', lazyCompositeTarget(natal, COMP_TARGET_BODIES), COMP_TARGET_BODIES.filter((b) => natal.pos[b] != null)]);
  const OV = 3; // days of back-overlap so no seam swallows a crossing
  let cursor = start;
  // Seam dedupe is by EVENT IDENTITY, not by a jd cut-line: a hit that lands between a
  // chunk's last grid point and its border is only detectable by the NEXT chunk's scan
  // (whose grid reaches past the border), so it arrives with jd below the border — a naive
  // cut-line loses it. Phase-locked grids make duplicate detections bit-identical, so an
  // exact key (kind/bodies/angle/jd) is a safe dedupe.
  let seenKeys = new Set();
  const keyOf = (e) => e.kind + '|' + (e.t || '') + '|' + (e.g || '') + '|' + (e.a ?? '') + '|' + (e.sign ?? '') + '|' + (e.dir || '') + '|' + e.jd.toFixed(5);
  return {
    version: SPINE_VERSION, start, end,
    get progress() { return Math.min(1, (cursor - start) / (end - start)); },
    get done() { return cursor >= end - 1e-9; },
    step() {
      if (this.done) return [];
      const b = Math.min(end, cursor + chunkDays);
      // phase-locked window starts: each scan's grid lands on the same jds a one-shot
      // scan from `start` would sample, so seams can't create or lose grazing hits.
      const back = Math.max(start, cursor - OV);
      const aHit = start + Math.max(0, Math.floor((back - start) / SPINE_STEP)) * SPINE_STEP;
      const aIng = start + Math.max(0, Math.floor((back - start) / 1)) * 1;
      const aSt = start + Math.max(0, Math.floor((back - start) / 2)) * 2;
      const out = [];
      for (const [kind, target, tb] of targets) {
        for (const h of scanTransitHits({ target, jdStart: aHit, jdEnd: b, transitBodies: bodies, transitPos: lazyChart, targetBodies: tb || undefined, stepDays: SPINE_STEP })) {
          out.push({ jd: h.jd, kind, t: h.transitBody, g: h.targetBody, a: h.angle });
        }
      }
      out.push(...scanIngresses(aIng, b, bodies));
      out.push(...scanStations(aSt, b, STATION_BODIES.filter((t) => bodies.includes(t))));
      const lo = Math.max(start - 1e-9, cursor - OV - 2 * SPINE_STEP);
      const fresh = out.filter((e) => e.jd > lo && e.jd <= b + 1e-9 && !seenKeys.has(keyOf(e)));
      // remember everything seen near the new seam for the next chunk's dedupe
      const horizon = b - OV - 2 * SPINE_STEP;
      seenKeys = new Set(out.filter((e) => e.jd > horizon).map(keyOf));
      cursor = b;
      return fresh.sort((x, y) => x.jd - y.jd);
    },
  };
}

// One-shot build (tests, workers). The app should prefer the unspooler on idle time.
// Chunks can emit a borderline event a beat late (see seam dedupe above), so the table
// is sorted once at the end — incremental consumers must insert-sort their appends too.
function buildSpine(dna, opts = {}) {
  const u = makeUnspooler(dna, opts);
  const events = [];
  while (!u.done) events.push(...u.step());
  events.sort((x, y) => x.jd - y.jd);
  return { version: SPINE_VERSION, start: u.start, end: u.end, events };
}

// ── read-side helpers ───────────────────────────────────────────────────────
// slice a sorted event array to (a, b], optionally filtered; binary-searched.
function spineSlice(events, a, b, filter = null) {
  let lo = 0, hi = events.length;
  while (lo < hi) { const m = (lo + hi) >> 1; if (events[m].jd <= a) lo = m + 1; else hi = m; }
  const out = [];
  for (let i = lo; i < events.length && events[i].jd <= b; i++) {
    if (!filter || filter(events[i])) out.push(events[i]);
  }
  return out;
}
// tagged views — derived, never stored
function isReturn(e) { return e.kind === 'hit' && e.a === 0 && e.t === e.g; }
function isFlip(e) { return e.kind === 'hit' && e.a === 180 && e.t === e.g; } // bead drains channel-end → wells up opposite

window.__ORBO_TIMESPINE = { SPINE_VERSION, SPINE_BODIES, STATION_BODIES, SPINE_STEP, COMP_TARGET_BODIES, natalFromDna, makeUnspooler, buildSpine, spineSlice, isReturn, isFlip };
})();
