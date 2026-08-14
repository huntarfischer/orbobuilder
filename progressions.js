// progressions.js — secondary progressions engine (specs/Orbo Plan 2026-07-26.md, Phase 8).
// Scope: progressed Sun, progressed Moon (L2/L3), progressed angles — Naibod / quotidian / solar
// arc, hard-labelled (L3, Depth Manifest: "178° divergence" — the method is never picked silently).
//
// PURE. No ephemeris import, ever. Every sky-touching value arrives already computed, via a
// `sample(ageYears)` function the caller injects — same convention as prism.js's own
// probe-parameter functions. Raw ephemeris stays behind the spine's one door
// (Orbo Astrolabe.dc.html's `_makeSpine().progressedAt`); this file never reaches past it.
//
// TABLE, NOT RECOMPUTE. build() runs ONE scan across ageYears 0..spanYears (spanYears real YEARS
// of life = spanYears progressed-DAYS of ephemeris — a life's progressed motion is a ~110-day
// ephemeris domain, the same order as zr.js's own 110-year chapter horizon) and returns sign-
// stamped, real-jd-stamped segments per tracked body/angle. SIGN ONLY, never degree — a node any
// finer destroys the memo (connectome.js's own law): degree is cheap arithmetic, read live at
// at()-time from the caller's exactSample, never stored.
//
// HOUSING extends the existing synchronic law verbatim: a progressed BODY houses off the NATAL
// Ascendant sign, never a derived one. The progressed ASC/MC get their own segment table — their
// sign changes are a reading in themselves ("progressed ASC ingress") — and never re-house
// anything else.
//
// Year length: 365.2422 (TROPICAL_YEAR_DAYS) — the same constant zr.js already uses. One tropical
// year in this app, not two. Aging is always continuous (elapsedDays / 365.2422); the `yearStart`
// doctrine key is profections' own and has no meaning here.

export const TROPICAL_YEAR_DAYS = 365.2422;
export const NAIBOD_RATE = 0.98564733; // deg/year, mean solar motion in right ascension
export const BODIES = ['Sun', 'Moon'];

const D2R = Math.PI / 180, R2D = 180 / Math.PI;
function norm360(x) { x %= 360; return x < 0 ? x + 360 : x; }
function signIdx(lonDeg) { return Math.floor(norm360(lonDeg) / 30); }

export function ageYears(natalJd, jd) { return (jd - natalJd) / TROPICAL_YEAR_DAYS; }
export function progressedJd(natalJd, jd) { return natalJd + ageYears(natalJd, jd); }
export function realJdFromAge(natalJd, age) { return natalJd + age * TROPICAL_YEAR_DAYS; }

// ---------- angle policies — pure spherical trig, same formulas ephem.js's angles() uses
// internally, taken as plain-number parameters (eps/lat/ramc) exactly as prism.js's risingRamc
// does — never a second ephemeris path, just the caller handing in what it already has. ----------

export function anglesFromRamc(ramcDeg, latDeg, epsDeg) {
  const eps = epsDeg * D2R, phi = latDeg * D2R, ra = norm360(ramcDeg) * D2R;
  const mc = norm360(Math.atan2(Math.sin(ra), Math.cos(ra) * Math.cos(eps)) * R2D);
  const asc = norm360(Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(eps) + Math.tan(phi) * Math.sin(eps))) * R2D);
  return { mc, asc };
}
// Inverse of the MC half: given a target MC ecliptic longitude, the RAMC that produces it —
// needed by the solar-arc policy, which fixes MC first and derives ASC from it.
export function ramcFromMc(mcLonDeg, epsDeg) {
  const eps = epsDeg * D2R, mc = norm360(mcLonDeg) * D2R;
  return norm360(Math.atan2(Math.sin(mc) * Math.cos(eps), Math.cos(mc)) * R2D);
}

// ctx: { natalArmc, natalMc, natalSunLon, progSunLon, progEps, progAsc, progMc, progAge, lat }
// progAsc/progMc are the REAL angles at the progressed jd (quotidian's whole answer, and the
// base data the other two policies still need for eps/context).
export function progressedAngles(policy, ctx) {
  if (policy === 'quotidian') return { asc: ctx.progAsc, mc: ctx.progMc };
  if (policy === 'solarArc') {
    const arc = norm360(ctx.progSunLon - ctx.natalSunLon);
    const mc = norm360(ctx.natalMc + arc);
    const ramc = ramcFromMc(mc, ctx.progEps);
    return { mc, asc: anglesFromRamc(ramc, ctx.lat, ctx.progEps).asc };
  }
  // naibod (default)
  const armc = norm360(ctx.natalArmc + ctx.progAge * NAIBOD_RATE);
  const a = anglesFromRamc(armc, ctx.lat, ctx.progEps);
  return { mc: a.mc, asc: a.asc };
}

function pushSeg(track, sign, realJd) {
  if (track.length && track[track.length - 1].sign === sign) return;
  if (track.length) track[track.length - 1].endJd = realJd;
  track.push({ sign, startJd: realJd, endJd: null });
}
function closeTrack(track, endJd) { if (track.length) track[track.length - 1].endJd = endJd; }

function findSegment(list, jd) {
  let lo = 0, hi = list.length - 1;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1, seg = list[mid];
    if (jd < seg.startJd) hi = mid - 1;
    else if (seg.endJd != null && jd >= seg.endJd) lo = mid + 1;
    else return seg;
  }
  return null;
}

// natal: { jd, lat, armc, mc, pos: { Sun, ... }, ascSign } — ascSign is the NATAL Ascendant's
// sign index, the housing anchor for every progressed body per the law above.
// doctrine: { progAngle: 'naibod' | 'quotidian' | 'solarArc' }
// sample(age): caller-injected, returns { Sun, Moon, asc, mc, eps } at the progressed jd for that
// age — i.e. spine.progressedAt(natalJd, realJdFromAge(natalJd, age), lat, lon) reshaped. Never
// called by this file directly against ephemeris — only through whatever the caller hands in.
export function build(natal, doctrine, sample, opts = {}) {
  const spanYears = opts.spanYears || 110;
  const step = opts.stepYears || 0.05; // ~18 days of progressed-age resolution
  const policy = (doctrine && doctrine.progAngle) || 'naibod';
  const tracks = {}; BODIES.forEach((b) => tracks[b] = []);
  const angleTrack = [];
  for (let age = 0; age <= spanYears + 1e-9; age += step) {
    const s = sample(age);
    if (!s) continue;
    const realJd = realJdFromAge(natal.jd, age);
    BODIES.forEach((b) => { if (s[b] != null) pushSeg(tracks[b], signIdx(s[b]), realJd); });
    const angles = progressedAngles(policy, {
      natalArmc: natal.armc, natalMc: natal.mc, natalSunLon: natal.pos.Sun,
      progSunLon: s.Sun, progEps: s.eps, progAsc: s.asc, progMc: s.mc, progAge: age, lat: natal.lat,
    });
    pushSeg(angleTrack, signIdx(angles.asc), realJd);
  }
  const endJd = realJdFromAge(natal.jd, spanYears);
  BODIES.forEach((b) => closeTrack(tracks[b], endJd));
  closeTrack(angleTrack, endJd);
  return Object.freeze({
    natalJd: natal.jd, doctrine: policy, spanYears,
    tracks: Object.freeze(Object.fromEntries(BODIES.map((b) => [b, Object.freeze(tracks[b])]))),
    angleTrack: Object.freeze(angleTrack),
  });
}

// Read-time join: table lookup (sign + house, free) plus — if exactSample is given — the cheap
// live arithmetic for exact degree. exactSample(age) has the same shape as build()'s sample().
export function at(table, natal, jd, exactSample) {
  const age = ageYears(natal.jd, jd);
  const out = { age, bodies: {}, angle: null, doctrine: table.doctrine };
  BODIES.forEach((b) => {
    const seg = findSegment(table.tracks[b], jd);
    out.bodies[b] = seg ? { sign: seg.sign, house: ((seg.sign - natal.ascSign + 12) % 12) + 1 } : null;
  });
  const aseg = findSegment(table.angleTrack, jd);
  if (aseg) out.angle = { sign: aseg.sign };
  if (exactSample) {
    const s = exactSample(age);
    if (s) {
      BODIES.forEach((b) => { if (out.bodies[b] && s[b] != null) out.bodies[b].lon = s[b]; });
      const angles = progressedAngles(table.doctrine, {
        natalArmc: natal.armc, natalMc: natal.mc, natalSunLon: natal.pos.Sun,
        progSunLon: s.Sun, progEps: s.eps, progAsc: s.asc, progMc: s.mc, progAge: age, lat: natal.lat,
      });
      if (out.angle) { out.angle.lon = angles.asc; out.angle.mc = angles.mc; }
    }
  }
  return out;
}

// Memo key — same shape as the DC's own _zrData() key (natal jd + doctrine string). Callers own
// the actual memoization; this is just the string both sides should agree on.
export function tableKey(natal, doctrine) {
  return natal.jd + '|' + ((doctrine && doctrine.progAngle) || 'naibod');
}
